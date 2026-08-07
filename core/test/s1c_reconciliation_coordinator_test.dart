import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/conflict_arbiter.dart';
import 'package:persistence_core/model/reconciliation.dart';
import 'package:persistence_core/model/reconciliation_ports.dart';
import 'package:persistence_core/core/reconciliation_coordinator.dart';
import 'package:persistence_core/sync/manifest_comparator.dart';
import 'package:persistence_core/test_support/reconciliation_contract_suite.dart';

/// S1c ACT-D/ACT-F：ReconciliationCoordinator 四阶段握手。
///
/// 契约断言在 `reconciliation_contract_suite.dart` 里提取成套件，这里用
/// 【两个结构迥异的内存 fake】各跑一遍（派工 §七第4条）：
/// - Fake A（`_RigA`）：`_FakeSource`/`_FakeStore`/`_FakeApplier` 三个独立
///   端口实现类 + `_ChannelRef` 可替换 channel 引用，两端 `linkTo` 互指。
/// - Fake B（`_RigB`）：`_BChannel` 持有对端 coordinator 引用直接转发，
///   applier/source/store 是**合并**的单一 `_BSide` 门面（结构迥异）。
///
/// 两端绝不共用同一对象（套件内置 `identical` 守卫）。
void main() {
  runReconciliationContractSuite(
    topologyName: 'Fake A · 三独立端口类 + 可替换 channel 引用互指',
    makeRig: _makeRigA,
  );
  runReconciliationContractSuite(
    topologyName: 'Fake B · 合并门面 _BSide + 显式转发 channel',
    makeRig: _makeRigB,
  );
}

/// 统一数据模型：entityId → (hlcPacked, isDeleted)。
/// deviceId 在 seed 时不区分（套件只比对 hlcPacked 与 isDeleted）。
typedef _Stamped = ({int hlcPacked, bool isDeleted});

// ── Fake A：三独立端口类 + 可替换 channel 引用 ─────────────────────────

class _RigA implements ReconciliationRig {
  _RigA(this.initiator, this.responder, this._idata, this._rdata, this._sent);

  @override
  final ReconciliationCoordinator initiator;
  @override
  final ReconciliationCoordinator responder;
  final Map<String, _Stamped> _idata;
  final Map<String, _Stamped> _rdata;
  final List<String> _sent;

  @override
  List<String> get initiatorSentOrder => _sent;

  @override
  void seed(List<TerminalSpec> specs) {
    _idata.clear();
    _rdata.clear();
    for (final s in specs) {
      _idata[s.entityId] = (hlcPacked: s.hlcPacked, isDeleted: s.isDeleted);
      _rdata[s.entityId] = (hlcPacked: s.hlcPacked, isDeleted: s.isDeleted);
    }
  }

  @override
  Map<String, _Stamped> initiatorState() => _idata;
  @override
  Map<String, _Stamped> responderState() => _rdata;
}

Future<_RigA> _makeRigA() async {
  final idata = <String, _Stamped>{};
  final rdata = <String, _Stamped>{};
  final sent = <String>[];
  final initiator = _RigA(
    _makeCoordinatorA(idata, _sideA(idata), sent),
    _makeCoordinatorA(rdata, _sideA(rdata), null),
    idata,
    rdata,
    sent,
  );
  // 把两端的 channel 互相接上（link 指向对方 coordinator）。
  (initiator.initiator.channelForTest as _ChannelRef).link =
      initiator.responder;
  (initiator.responder.channelForTest as _ChannelRef).link =
      initiator.initiator;
  return initiator;
}

_AFake _sideA(Map<String, _Stamped> data) => _AFake(data);

ReconciliationCoordinator _makeCoordinatorA(
  Map<String, _Stamped> data,
  _AFake side,
  List<String>? sentOrder,
) {
  return ReconciliationCoordinator(
    source: _FakeSource(data),
    store: _FakeStore(data),
    channel: _ChannelRef(sentOrder),
    comparator: DefaultManifestComparator(),
    applier: _FakeApplier(data),
  );
}

class _AFake {
  _AFake(this.data);
  final Map<String, _Stamped> data;
}

/// 可替换目标的可写 channel 引用：测试用它把两台 coordinator 接成握手。
/// [sentOrder] 非空时记录发起方发出的消息类型序列（线序守卫用）。
class _ChannelRef implements RemoteTerminalChannel {
  _ChannelRef([this.sentOrder]);

  ReconciliationCoordinator? link;
  final List<String>? sentOrder;

  void _log(String kind) => sentOrder?.add(kind);

  @override
  Future<void> sendManifestChunk(ManifestChunk chunk) {
    _log('manifestChunk');
    return link!.handleRemoteManifest(chunk);
  }

  @override
  Future<void> sendTerminals(List<EntityTerminal> terminals) {
    _log('terminals');
    if (terminals.isEmpty) return Future.value();
    return link!.handleRemoteTerminals(
      scopeUid: terminals.first.scopeUid,
      entityType: terminals.first.entityType,
      terminals: terminals,
    );
  }

  @override
  Future<void> requestTerminals(List<EntityRequest> requests) {
    _log('requests');
    if (requests.isEmpty) return Future.value();
    return link!.handleRemoteRequests(
      scopeUid: requests.first.scopeUid,
      entityType: requests.first.entityType,
      requests: requests,
    );
  }

  @override
  Future<void> sendCursorAdvance(CursorAdvance advance) async {
    _log('cursorAdvance');
  }
}

class _FakeSource implements ManifestSource {
  _FakeSource(this.data);
  final Map<String, _Stamped> data;

  @override
  Future<ManifestChunk?> readManifestChunk({
    required String scopeUid,
    required String entityType,
    required int chunkSeq,
    required int pageSize,
  }) async {
    final rows = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (rows.isEmpty) {
      return ManifestChunk(
        scopeUid: scopeUid,
        entityType: entityType,
        chunkSeq: chunkSeq,
        totalChunks: 0,
        entries: const [],
      );
    }
    final totalChunks = (rows.length + pageSize - 1) ~/ pageSize;
    if (chunkSeq >= totalChunks) return null;
    final start = chunkSeq * pageSize;
    final end = (start + pageSize).clamp(0, rows.length);
    return ManifestChunk(
      scopeUid: scopeUid,
      entityType: entityType,
      chunkSeq: chunkSeq,
      totalChunks: totalChunks,
      entries: rows.sublist(start, end).map((e) {
        return ManifestEntry(
          entityId: e.key,
          hlcPacked: e.value.hlcPacked,
          deviceId: 'device-${e.key}',
          isDeleted: e.value.isDeleted,
        );
      }).toList(),
    );
  }
}

class _FakeStore implements TerminalStore {
  _FakeStore(this.data);
  final Map<String, _Stamped> data;

  @override
  Future<EntityTerminal?> readTerminal({
    required String scopeUid,
    required String entityType,
    required String entityId,
  }) async {
    final s = data[entityId];
    if (s == null) return null;
    return EntityTerminal(
      scopeUid: scopeUid,
      entityType: entityType,
      entityId: entityId,
      isDeleted: s.isDeleted,
      hlcPacked: s.hlcPacked,
      deviceId: 'device-$entityId',
    );
  }

  @override
  Future<void> writeTerminal(EntityTerminal terminal) async {
    data[terminal.entityId] = (
      hlcPacked: terminal.hlcPacked,
      isDeleted: terminal.isDeleted,
    );
  }
}

/// 内存 applier：把终态写入 data（模拟过仲裁器 + 同事务写）。
class _FakeApplier implements LocalReconciliationApplier {
  _FakeApplier(this.data);
  final Map<String, _Stamped> data;

  @override
  Future<ReconciliationResult> applyTerminals({
    required String scopeUid,
    required String entityType,
    required List<EntityTerminal> terminals,
  }) async {
    var conflicts = 0;
    for (final t in terminals) {
      final local = data[t.entityId];
      if (local == null) {
        data[t.entityId] = (
          hlcPacked: t.hlcPacked,
          isDeleted: t.isDeleted,
        );
        continue;
      }
      final localStamp = VersionStamp.fromPacked(local.hlcPacked, 'device-x');
      final remoteStamp =
          VersionStamp.fromPacked(t.hlcPacked, t.deviceId);
      if (remoteStamp.compareTo(localStamp) > 0) {
        data[t.entityId] = (
          hlcPacked: t.hlcPacked,
          isDeleted: t.isDeleted,
        );
        conflicts += 1;
      }
    }
    return ReconciliationResult(
      scopeUid: scopeUid,
      entityType: entityType,
      recordsReconciled: terminals.length,
      blobsPending: 0,
      conflictsLogged: conflicts,
    );
  }
}

// ── Fake B：合并门面 _BSide + 显式转发 channel（结构迥异）────────────────

class _RigB implements ReconciliationRig {
  _RigB(this.initiator, this.responder, this._idata, this._rdata);

  @override
  final ReconciliationCoordinator initiator;
  @override
  final ReconciliationCoordinator responder;
  final Map<String, _Stamped> _idata;
  final Map<String, _Stamped> _rdata;

  @override
  void seed(List<TerminalSpec> specs) {
    _idata.clear();
    _rdata.clear();
    for (final s in specs) {
      _idata[s.entityId] = (hlcPacked: s.hlcPacked, isDeleted: s.isDeleted);
      _rdata[s.entityId] = (hlcPacked: s.hlcPacked, isDeleted: s.isDeleted);
    }
  }

  @override
  Map<String, _Stamped> initiatorState() => _idata;
  @override
  Map<String, _Stamped> responderState() => _rdata;
}

Future<_RigB> _makeRigB() async {
  final idata = <String, _Stamped>{};
  final rdata = <String, _Stamped>{};

  final sideI = _BSide(idata);
  final sideR = _BSide(rdata);

  final initiator = ReconciliationCoordinator(
    source: sideI,
    store: sideI,
    channel: _BChannel(),
    comparator: DefaultManifestComparator(),
    applier: sideI,
  );
  final responder = ReconciliationCoordinator(
    source: sideR,
    store: sideR,
    channel: _BChannel(),
    comparator: DefaultManifestComparator(),
    applier: sideR,
  );
  (initiator.channelForTest as _BChannel).peer = responder;
  (responder.channelForTest as _BChannel).peer = initiator;

  return _RigB(initiator, responder, idata, rdata);
}

/// Fake B 的合并门面：同一个类实现 ManifestSource + TerminalStore +
/// LocalReconciliationApplier 三个端口（与 Fake A 的三个独立类迥异）。
class _BSide implements ManifestSource, TerminalStore, LocalReconciliationApplier {
  _BSide(this.data);
  final Map<String, _Stamped> data;

  @override
  Future<ManifestChunk?> readManifestChunk({
    required String scopeUid,
    required String entityType,
    required int chunkSeq,
    required int pageSize,
  }) async {
    final rows = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (rows.isEmpty) {
      return ManifestChunk(
        scopeUid: scopeUid,
        entityType: entityType,
        chunkSeq: chunkSeq,
        totalChunks: 0,
        entries: const [],
      );
    }
    final totalChunks = (rows.length + pageSize - 1) ~/ pageSize;
    if (chunkSeq >= totalChunks) return null;
    final start = chunkSeq * pageSize;
    final end = (start + pageSize).clamp(0, rows.length);
    return ManifestChunk(
      scopeUid: scopeUid,
      entityType: entityType,
      chunkSeq: chunkSeq,
      totalChunks: totalChunks,
      entries: rows.sublist(start, end).map((e) {
        return ManifestEntry(
          entityId: e.key,
          hlcPacked: e.value.hlcPacked,
          deviceId: 'bdevice-${e.key}',
          isDeleted: e.value.isDeleted,
        );
      }).toList(),
    );
  }

  @override
  Future<EntityTerminal?> readTerminal({
    required String scopeUid,
    required String entityType,
    required String entityId,
  }) async {
    final s = data[entityId];
    if (s == null) return null;
    return EntityTerminal(
      scopeUid: scopeUid,
      entityType: entityType,
      entityId: entityId,
      isDeleted: s.isDeleted,
      hlcPacked: s.hlcPacked,
      deviceId: 'bdevice-$entityId',
    );
  }

  @override
  Future<void> writeTerminal(EntityTerminal terminal) async {
    data[terminal.entityId] = (
      hlcPacked: terminal.hlcPacked,
      isDeleted: terminal.isDeleted,
    );
  }

  @override
  Future<ReconciliationResult> applyTerminals({
    required String scopeUid,
    required String entityType,
    required List<EntityTerminal> terminals,
  }) async {
    var conflicts = 0;
    for (final t in terminals) {
      final local = data[t.entityId];
      if (local == null) {
        data[t.entityId] = (
          hlcPacked: t.hlcPacked,
          isDeleted: t.isDeleted,
        );
        continue;
      }
      final localStamp = VersionStamp.fromPacked(local.hlcPacked, 'bdev-x');
      final remoteStamp =
          VersionStamp.fromPacked(t.hlcPacked, t.deviceId);
      if (remoteStamp.compareTo(localStamp) > 0) {
        data[t.entityId] = (
          hlcPacked: t.hlcPacked,
          isDeleted: t.isDeleted,
        );
        conflicts += 1;
      }
    }
    return ReconciliationResult(
      scopeUid: scopeUid,
      entityType: entityType,
      recordsReconciled: terminals.length,
      blobsPending: 0,
      conflictsLogged: conflicts,
    );
  }
}

class _BChannel implements RemoteTerminalChannel {
  ReconciliationCoordinator? peer;

  @override
  Future<void> sendManifestChunk(ManifestChunk chunk) =>
      peer!.handleRemoteManifest(chunk);

  @override
  Future<void> sendTerminals(List<EntityTerminal> terminals) {
    if (terminals.isEmpty) return Future.value();
    return peer!.handleRemoteTerminals(
      scopeUid: terminals.first.scopeUid,
      entityType: terminals.first.entityType,
      terminals: terminals,
    );
  }

  @override
  Future<void> requestTerminals(List<EntityRequest> requests) {
    if (requests.isEmpty) return Future.value();
    return peer!.handleRemoteRequests(
      scopeUid: requests.first.scopeUid,
      entityType: requests.first.entityType,
      requests: requests,
    );
  }

  @override
  Future<void> sendCursorAdvance(CursorAdvance advance) async {}
}
