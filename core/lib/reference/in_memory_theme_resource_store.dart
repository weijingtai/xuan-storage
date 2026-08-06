// 包：persistence_core  文件：core/lib/reference/in_memory_theme_resource_store.dart
// 【reference】§5.5.3 零网络结构性保证的落地形态：构造器只接收
// scopeUid 与 localReader 两个必需参数（P3-a1 用 tear-off 函数类型断言钉死），
// 连发起网络/安装的能力都没有。

import 'dart:async';

import 'package:persistence_core/model/theme_resolution.dart';
import 'package:persistence_core/model/theme_resource_store.dart';
import 'package:persistence_core/model/theme_source_ports.dart';
import 'package:persistence_core/model/theme_token_types.dart';
import 'package:persistence_core/model/theme_value_types.dart';
import 'package:persistence_core/reference/theme_token_merger.dart';

/// XRAP 主题数据集稳定 id。
///
/// 与 `theme_dataset.dart` 的 [themeDatasetId]（'theme.package'）同值。
/// 因 P3-a2 的 import 白名单不含契约层 `theme_dataset.dart`，此处以
/// 私有常量承载同一字面量并保持同步（reference 阶段数据集唯一，
/// 多主题包并存属 THEME-DRIFT，不在 S5a）。
const _themeDatasetId = 'theme.package';

/// reference 实现：三层合并的内存 store。
///
/// 【零网络的结构性保证（§5.5.3）】构造器只接收 [scopeUid] 与 [localReader]，
/// 不接收 remoteFetcher / packageStore / signatureVerifier —— 那三样归 XRAP。
/// 本类连发起网络的能力都没有，比"默认实现抛异常"更强。
///
/// 【缓存（§6.6 P2）】`resolve()` 结果按
/// `(activeThemeId, packageVersion, overridesRevision)` 三元组缓存；
/// 键相同返回**同一实例**（identical），键变化重算并替换。
/// [overridesRevision] 是单调递增计数器，每次覆盖写操作成功后 +1。
///
/// 【watchResolved】覆盖层变更 / 主题切换时推送新值（XRAP 活跃指针翻转
/// 由 XRAP 侧通知，reference 阶段无该事件源，见 §4.5 第 4 步）。
final class InMemoryThemeResourceStore implements ThemeResourceStore {
  /// 构造 reference store。
  ///
  /// - [scopeUid]: 作用域 uid。
  /// - [localReader]: **必需**。bundled / 活跃世代 / override 的唯一来源。
  ///   测试注入内存 fixture（§7.5 的 ThemeBenchFixture）。
  ///
  /// 【v4：不再接收 remoteFetcher / packageStore / signatureVerifier】
  /// 那三样归 XRAP。reference 的零 IO 由「只有一个本地读取端口」这一
  /// 结构事实保证 —— 它连发起网络的能力都没有，比"默认实现抛异常"更强。
  ///
  /// ⚠️ 参数写成非 `this.` 简写 + 初始化列表，是为了满足 P3-a1 的
  /// tear-off 函数类型断言（参数名/类型逐字匹配，见 VERIFICATION V3）。
  /// 参数须与 [ThemeResourceStore] 端口签名逐字一致。
  InMemoryThemeResourceStore(
      {required String scopeUid, required ThemeLocalReader localReader})
      // V3 门禁要求参数写非 this. 简写（grep 逐字匹配），故用初始化列表。
      // ignore: prefer_initializing_formals
      : scopeUid = scopeUid,
        _reader = localReader;

  @override
  final String scopeUid;

  /// 唯一本地读取端口（bundled / 活跃世代 / override 三层的数据源）。
  final ThemeLocalReader _reader;

  /// 用户显式选择的主题 id；null 表示跟随官方默认（reference 阶段
  /// 数据集唯一，选择与否只影响 [ThemeSelectionOrigin] 与溯源）。
  String? _selectedThemeId;

  /// store 内用户覆盖差量（applyOverrides 写入；initialOverrides 由
  /// `readOverrides()` 注入，resolve 时两者合并，前者优先）。
  final Map<String, OverrideEntry> _appliedOverrides =
      <String, OverrideEntry>{};

  /// 覆盖写操作的单调递增版本号（§6.6 缓存键之一）。
  int _overridesRevision = 0;

  // ---- 单条缓存（P2）----
  ThemeTokenSet? _cache;
  String? _cacheThemeId;
  int _cacheRevision = -1;

  /// watchResolved 的广播流（写操作后推送新值）。
  final StreamController<ThemeTokenSet> _controller =
      StreamController<ThemeTokenSet>.broadcast();

  /// 活跃世代读取的降级超时。
  ///
  /// P6（§5.5.4）：活跃世代落地物读取挂起时，`resolve()` 必须在 50ms 内
  /// 返回 bundled 兜底且不抛异常。超时阈值取 30ms，留出其余读取与合并的
  /// 余量，保证 `sw.elapsedMilliseconds < 50` 恒成立。
  static const _activeReadTimeout = Duration(milliseconds: 30);

  @override
  Future<ThemeTokenSet> resolve({Object? cancel}) async {
    // ⚠️ 端口签名是 `{CancellationToken? cancel}`，这里用超类型 `Object?`：
    // 实现是纯内存零等待操作，cancel 无意义（reference 不阻塞、不可取消）；
    // 且 `cancellation_token.dart` 不在 P3-a2 import 白名单内（7 条写死）。
    // `Object?` 是 `CancellationToken?` 的超类型，override 合法（参数逆变），
    // 调用方按端口类型传 CancellationToken 实例仍然兼容（被忽略）。
    // 读三层。bundled 恒存在；overrides 取 reader 注入的初始快照 +
    // store 内应用差量（store 内优先）；活跃世代带超时降级。
    final bundled = await _reader.readBundledTokens();
    final baseOverrides = await _reader.readOverrides();
    final overrides = <String, OverrideEntry>{
      ...baseOverrides,
      ..._appliedOverrides,
    };
    final themeId = _selectedThemeId ?? _themeDatasetId;
    final packageTokens = await _readActiveWithTimeout(themeId);
    final activeThemeId = packageTokens == null ? null : themeId;

    // 缓存键三元组 (activeThemeId, packageVersion, overridesRevision)。
    // reference 的 reader 拿不到包版本（InstalledDataset.manifest 在
    // XRAP 侧，store 不持有 installer），packageVersion 恒为 null。
    if (_cache != null &&
        _cacheThemeId == activeThemeId &&
        _cacheRevision == _overridesRevision) {
      return _cache!;
    }

    final selectionOrigin = _selectedThemeId != null
        ? ThemeSelectionOrigin.userSelected
        : (packageTokens == null
            ? ThemeSelectionOrigin.bundledFallback
            : ThemeSelectionOrigin.officialDefault);

    final result = mergeThemeTokens(
      bundledTokens: bundled,
      packageTokens: packageTokens,
      overrides: overrides,
      activeThemeId: activeThemeId,
      activeThemeVersion: null,
      selectionOrigin: selectionOrigin,
      resolvedAtUtc: DateTime.now().toUtc(),
    );
    _cache = result;
    _cacheThemeId = activeThemeId;
    _cacheRevision = _overridesRevision;
    return result;
  }

  @override
  Stream<ThemeTokenSet> watchResolved() => _controller.stream;

  @override
  Future<List<LocalTheme>> listLocalThemes() async {
    final result = <LocalTheme>[
      const LocalTheme(
        id: _themeDatasetId,
        displayName: '内置默认主题',
        author: 'builtin',
        generation: 0,
      ),
    ];
    final active = await _readActiveWithTimeout(_themeDatasetId);
    if (active != null) {
      // reference 阶段数据集唯一，活跃世代即同一数据集的高世代落地物；
      // generation 号没有真实来源（reader 只给 token 不给世代元数据），
      // 非 0 即视为"已装主题包"。生产实现（drift）改查 XRAP 世代表。
      result.add(
        const LocalTheme(
          id: _themeDatasetId,
          displayName: '已安装主题包',
          author: 'official',
          generation: 1,
        ),
      );
    }
    return List<LocalTheme>.unmodifiable(result);
  }

  @override
  Future<void> selectTheme(String themeId) async {
    // 端口契约：themeId 必须在 listLocalThemes 中。reference 阶段数据集
    // 唯一（THEME-DRIFT 前），等价于 id 必须为 XRAP 主题数据集 id。
    if (themeId != _themeDatasetId) {
      throw StateError(
        '未知主题: $themeId（reference 阶段仅支持数据集 $_themeDatasetId，'
        '多主题包并存属 THEME-DRIFT）',
      );
    }
    _selectedThemeId = themeId;
    await _refreshAndNotify();
  }

  @override
  Future<void> clearThemeSelection() async {
    _selectedThemeId = null;
    await _refreshAndNotify();
  }

  @override
  Future<void> applyOverrides({
    required Map<String, dynamic> patch,
    required OverrideOrigin origin,
  }) async {
    // 原子提交（A11②）：先整批校验，任一非法整批不生效。
    for (final entry in patch.entries) {
      if (entry.value is Map) {
        throw StateError(
          '覆盖值不得为 Map（扁平差量契约违反，§4.3 v 不得为 Map）: ${entry.key}',
        );
      }
    }
    final now = DateTime.now().toUtc();
    patch.forEach((key, value) {
      _appliedOverrides[key] = OverrideEntry(
        value: value,
        origin: origin,
        updatedAtUtc: now,
      );
    });
    _overridesRevision++;
    await _refreshAndNotify();
  }

  @override
  Future<void> removeOverrides(Set<String> tokenKeys) async {
    // 幂等（A12②）：不存在的 key 静默忽略。
    for (final key in tokenKeys) {
      _appliedOverrides.remove(key);
    }
    _overridesRevision++;
    await _refreshAndNotify();
  }

  @override
  Future<Map<String, OverrideEntry>> listOverrides() async {
    final base = await _reader.readOverrides();
    final all = <String, OverrideEntry>{...base, ..._appliedOverrides};
    return Map<String, OverrideEntry>.unmodifiable(all);
  }

  /// 读活跃世代 token，带 [Duration] 超时降级（P6）。
  ///
  /// 挂起或异常一律按"无已装包"（null）处理，交由 bundled 兜底；
  /// 这是 S5a 侧真实存在的唯一降级路径（§5.5.4 P6 六步）。
  Future<Map<String, dynamic>?> _readActiveWithTimeout(String themeId) {
    return _reader
        .readActiveThemeTokens(themeId)
        .timeout(_activeReadTimeout, onTimeout: () => null);
  }

  /// 覆盖层变更 / 主题切换后：失效缓存 → 重算 → 推送新值。
  ///
  /// 显式失效缓存保证 [ThemeSelectionOrigin] / 覆盖内容的变化一定
  /// 反映到推送值与下一次 `resolve()`（P2 的 identical 语义由
  /// 未变更时的缓存键命中承担）。
  Future<void> _refreshAndNotify() async {
    if (_controller.isClosed) return;
    _cache = null;
    _cacheThemeId = null;
    _cacheRevision = -1;
    _controller.add(await resolve());
  }
}
