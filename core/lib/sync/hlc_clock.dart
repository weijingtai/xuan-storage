import 'package:crdt/crdt.dart' show Hlc;

/// 本设备的 HLC 时钟。跨重启持久化，单调不回退。
///
/// 【两条规则】（crdt 的 Hlc 已实现，本类只负责持久化与调用纪律）：
/// · 本地写入 [tick]：Hlc.increment() —— l = max(旧 l, 物理时间)；l 未变则 c++，变大则 c = 0
/// · 收到远端 [observe]：Hlc.merge(remote) —— l = max(本地 l, 远端 l, 物理时间)
///   ——【收一次别人的东西，自己的钟就被顶上去一次】，这是因果性的全部来源
///
/// ⚠ crdt 的 Hlc 是【不可变】的（increment / merge 都返回新实例），
/// 实现必须把合并结果存回内部状态，不能只调用不保存。
abstract interface class HlcClock {
  /// 本地发生一次写入，返回新的戳。
  ///
  /// nodeId 一律取 [deviceId]（= DeviceIdentity.deviceId），不许另造 id 体系。
  Future<Hlc> tick();

  /// 观测到一个远端戳，把本地时钟顶上去（内部走 Hlc.merge）。
  ///
  /// 【必须在每一条入站变更上调用】。漏调不会报错，
  /// 只会让因果性静默消失 —— 属性测试的第 ② 条就是守这个的。
  ///
  /// ⚠ crdt 的 merge 在遇到相同 nodeId 时会抛 DuplicateNodeException；
  /// 真实网络里 nodeId 即 deviceId，不会相同。测试若构造相同 nodeId
  /// 的时钟，属预期报错，不是 bug。
  Future<void> observe(Hlc remote);

  /// 当前戳（只读，不推进）。
  Hlc get current;

  /// 本设备标识，作为 Hlc.nodeId（也是 HLC 相等时的决胜位，crdt 内建）。
  String get deviceId;
}

/// 时钟状态的持久化端口。实现由 drift 提供（与 t_entity_stamp 同一次 v8 迁移）。
///
/// 不持久化的后果：重启后 l 从物理时间重来，若期间时钟被回拨，
/// 新写入的戳会小于重启前的戳 —— 单调性断裂，且没有任何报错。
///
/// 存储时把 Hlc 转成【规格化串】落库（见 ACT 08 TASK_DETAIL.hlc_wire_format_spec），
/// 读回时用 Hlc.parse 还原 —— 禁止把 Hlc 对象本身或自定义字段布局落库。
abstract interface class HlcClockStore {
  /// 读回上次退出时的时钟；从未存过返回 null。
  Future<Hlc?> load();

  /// 落盘当前时钟（以规格化串格式）。
  Future<void> save(Hlc clock);
}

/// crdt Hlc 的默认时钟实现。
///
/// 启动时从 [store] 读回上次的戳（Hlc.parse 还原），读不到则从
/// [wallClock] 的当前物理时间起步。每次 [tick] / [observe] 之后立即
/// [HlcClockStore.save]（app 被系统杀掉不会走退出路径，那正是移动端
/// 最常见的终止方式，见 ACT 08 clock_persistence_timing）。
final class HlcClockImpl implements HlcClock {
  /// 创建一个 [HlcClockImpl]。
  ///
  /// - [deviceId]: 本设备标识，作为 Hlc.nodeId（= DeviceIdentity.deviceId）。
  /// - [store]: 持久化端口。
  /// - [wallClock]: 物理时钟源，测试可注入。默认 [DateTime.now].toUtc。
  HlcClockImpl({
    required this.deviceId,
    required HlcClockStore store,
    DateTime Function()? wallClock,
  })  : _store = store,
        _wallClock = wallClock ?? DateTime.now().toUtc,
        _current = Hlc.zero(deviceId);

  /// 本设备标识，作为 Hlc.nodeId（= DeviceIdentity.deviceId）。
  @override
  final String deviceId;
  final HlcClockStore _store;
  final DateTime Function() _wallClock;

  bool _loaded = false;
  Hlc _current;

  /// 当前戳（只读，不推进）。
  ///
  /// ⚠ 在首次 [tick] / [observe] 之前访问会得到初始值；持久化恢复
  /// 只发生在首次 tick/observe 时（见 [_ensureLoaded]）。
  @override
  Hlc get current => _current;

  /// 本地写入：把当前钟 increment()，落盘，返回新戳。
  @override
  Future<Hlc> tick() async {
    await _ensureLoaded();
    final next = _current.increment(wallTime: _wallClock());
    _current = next;
    await _store.save(_current);
    return _current;
  }

  /// 观测远端戳：merge 后落盘。
  ///
  /// ⚠ crdt 的 merge 在相同 nodeId 时抛 DuplicateNodeException ——
  /// 真实场景 nodeId 即 deviceId 不会相同；测试构造同 nodeId 属预期报错。
  @override
  Future<void> observe(Hlc remote) async {
    await _ensureLoaded();
    _current = _current.merge(remote, wallTime: _wallClock());
    await _store.save(_current);
  }

  /// 首次 tick/observe 前从 store 读回上次退出时的时钟（Hlc.parse 还原）。
  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    final persisted = await _store.load();
    if (persisted != null) {
      _current = persisted;
    }
  }
}
