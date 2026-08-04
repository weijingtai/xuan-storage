import 'dart:io';

import 'package:persistence_core/model/sync_peer.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_core/test_support/in_memory_stores.dart';
import 'package:test/test.dart';

class _FakeSyncPeer implements SyncPeer {
  _FakeSyncPeer({
    required this.pushError,
    RemoteChangesPage Function(
      String scopeUid,
      String entityType,
      PullCursor? sinceCursor,
      int limit,
    )? listChangesFn,
  }) : _listChangesFn = listChangesFn;

  final SyncError? Function(OutboxRecord record) pushError;
  final RemoteChangesPage Function(
    String scopeUid,
    String entityType,
    PullCursor? sinceCursor,
    int limit,
  )? _listChangesFn;

  @override
  PeerId get peerId => PeerId('fake');

  @override
  Channel get channel => Channel.cloud;

  @override
  Future<SyncError?> push(OutboxRecord record) async {
    return pushError(record);
  }

  @override
  Future<RemoteChangesPage> listChanges({
    required String scopeUid,
    required String entityType,
    required PullCursor? sinceCursor,
    required int limit,
  }) async {
    final fn = _listChangesFn;
    if (fn == null) {
      return const RemoteChangesPage(
          changes: [], nextCursor: null, hasMore: false);
    }
    return fn(scopeUid, entityType, sinceCursor, limit);
  }

  @override
  Future<PeerCapabilities> getCapabilities() async => PeerCapabilities(
    peerId: peerId,
    channel: channel,
    entityVersions: const {'seeker': 1, 'divination': 1},
    supportedFeatures: const {'outbox_v1', 'tag_index_v1'},
    protocolVersion: 1,
  );
}

class _FakeLocalApplier implements LocalApplier {
  _FakeLocalApplier({required this.apply});

  final LocalApplyResult Function(
    String scopeUid,
    String entityType,
    List<RemoteChange> changes,
  ) apply;

  @override
  Future<LocalApplyResult> applyRemoteChanges({
    required String scopeUid,
    required String entityType,
    required List<RemoteChange> changes,
  }) async {
    return apply(scopeUid, entityType, changes);
  }
}

void main() {
  test('pushOnce marks record dead after max attempts', () async {
    const scopeUid = 'u1';
    final now = DateTime.utc(2026, 1, 10, 9, 0, 0);

    final outbox = InMemoryOutboxStore();
    await outbox.enqueue(
      OutboxRecord(
        operationId: 'op1',
        scopeUid: scopeUid,
        entityType: 'layout_template',
        entityId: 't1',
        opType: 'upsert',
        payloadJson: '{"k":1}',
        createdAtUtc: now,
        attempt: 0,
      ),
    );

    final coordinator = SyncCoordinator(
      outboxStore: outbox,
      remoteGateway: _FakeSyncPeer(
        pushError: (_) => const SyncError(
          code: SyncErrorCode.network,
          message: 'timeout',
        ),
      ),
      nowUtc: () => now,
      maxAttemptsBeforeDead: 2,
      pushBatchSize: 10,
    );

    final r1 = await coordinator.pushOnce(scopeUid: scopeUid);
    expect(r1.processed, equals(1));
    expect(r1.failed, equals(1));
    expect(r1.dead, equals(0));
    expect(
      await outbox.backlogCount(
        scopeUid: scopeUid,
        peerId: const PeerId('firestore'),
      ),
      equals(1),
    );

    final r2 = await coordinator.pushOnce(scopeUid: scopeUid);
    expect(r2.processed, equals(1));
    expect(r2.failed, equals(1));
    expect(r2.dead, equals(1));
    expect(
      await outbox.backlogCount(
        scopeUid: scopeUid,
        peerId: const PeerId('firestore'),
      ),
      equals(0),
    );
  });

  test('SyncCoordinator updates status on success and failure', () async {
    const scopeUid = 'u1';
    final now = DateTime.utc(2026, 1, 10, 9, 0, 0);

    final outbox = InMemoryOutboxStore();
    await outbox.enqueue(
      OutboxRecord(
        operationId: 'op1',
        scopeUid: scopeUid,
        entityType: 'layout_template',
        entityId: 't1',
        opType: 'upsert',
        payloadJson: '{"k":1}',
        createdAtUtc: now,
        attempt: 0,
      ),
    );

    var shouldFail = true;

    final coordinator = SyncCoordinator(
      outboxStore: outbox,
      remoteGateway: _FakeSyncPeer(
        pushError: (_) => shouldFail
            ? const SyncError(code: SyncErrorCode.network, message: 'down')
            : null,
      ),
      nowUtc: () => now,
      maxAttemptsBeforeDead: 10,
      pushBatchSize: 10,
    );

    await coordinator.pushOnce(scopeUid: scopeUid);
    expect(coordinator.status.state, equals(SyncRunState.error));
    expect(coordinator.status.lastError?.code, equals(SyncErrorCode.network));

    shouldFail = false;
    await coordinator.pushOnce(scopeUid: scopeUid);
    expect(coordinator.status.state, equals(SyncRunState.idle));
    expect(coordinator.status.lastError, isNull);
  });

  test('pullOnce advances cursor only when apply succeeds', () async {
    const scopeUid = 'u1';
    const entityType = 'layout_template';
    final now = DateTime.utc(2026, 1, 10, 9, 0, 0);

    final stateStore = InMemorySyncStateStore();
    final remote = _FakeSyncPeer(
      pushError: (_) => null,
      listChangesFn: (scope, type, since, limit) {
        expect(scope, equals(scopeUid));
        expect(type, equals(entityType));
        expect(since, isNull);

        return RemoteChangesPage(
          changes: [
            RemoteChange(
              operationId: 'op_remote_1',
              entityType: entityType,
              entityId: 't1',
              opType: 'upsert',
              cursor: TimestampCursor(
                serverUpdatedAtUtc: DateTime.utc(2026, 1, 10, 8, 0, 0),
                tieBreaker: 'op_remote_1',
              ),
              payloadJson: '{"schemaVersion":1}',
              serverTimeUtc: DateTime.utc(2026, 1, 10, 8, 0, 0),
            ),
          ],
          nextCursor: TimestampCursor(
            serverUpdatedAtUtc: DateTime.utc(2026, 1, 10, 8, 0, 0),
            tieBreaker: 'op_remote_1',
          ),
          hasMore: false,
        );
      },
    );

    final applier = _FakeLocalApplier(
      apply: (scope, type, changes) {
        expect(scope, equals(scopeUid));
        expect(type, equals(entityType));
        expect(changes, hasLength(1));
        return const LocalApplyResult(
          canAdvanceCursor: true,
          appliedCount: 1,
          outcomes: [
            ChangeApplyOutcome(
              operationId: 'op_remote_1',
              entityType: entityType,
              entityId: 't1',
              decision: ChangeApplyDecision.applied,
              reason: null,
              message: null,
            ),
          ],
          lastError: null,
        );
      },
    );

    final coordinator = SyncCoordinator(
      outboxStore: InMemoryOutboxStore(),
      syncStateStore: stateStore,
      remoteGateway: remote,
      localApplier: applier,
      nowUtc: () => now,
      pullBatchSize: 10,
    );

    final r =
        await coordinator.pullOnce(scopeUid: scopeUid, entityType: entityType);
    expect(r.advanced, isTrue);
    expect(coordinator.status.state, equals(SyncRunState.idle));

    final cursor = await stateStore.getCursor(
      scopeUid: scopeUid,
      peerId: const PeerId('firestore'),
      entityType: entityType,
    );
    expect(cursor, isA<TimestampCursor>());
  });

  test('pullOnce does not advance cursor when apply fails', () async {
    const scopeUid = 'u1';
    const entityType = 'layout_template';
    final now = DateTime.utc(2026, 1, 10, 9, 0, 0);

    final stateStore = InMemorySyncStateStore();
    final remote = _FakeSyncPeer(
      pushError: (_) => null,
      listChangesFn: (_, __, ___, ____) {
        return RemoteChangesPage(
          changes: [
            RemoteChange(
              operationId: 'op_remote_1',
              entityType: entityType,
              entityId: 't1',
              opType: 'upsert',
              cursor: TimestampCursor(
                serverUpdatedAtUtc: DateTime.utc(2026, 1, 10, 8, 0, 0),
                tieBreaker: 'op_remote_1',
              ),
              payloadJson: '{"schemaVersion":1}',
              serverTimeUtc: DateTime.utc(2026, 1, 10, 8, 0, 0),
            ),
          ],
          nextCursor: TimestampCursor(
            serverUpdatedAtUtc: DateTime.utc(2026, 1, 10, 8, 0, 0),
            tieBreaker: 'op_remote_1',
          ),
          hasMore: false,
        );
      },
    );

    final applier = _FakeLocalApplier(
      apply: (_, __, ___) {
        return const LocalApplyResult(
          canAdvanceCursor: false,
          appliedCount: 0,
          outcomes: [],
          lastError: SyncError(code: SyncErrorCode.invalidData, message: 'bad'),
        );
      },
    );

    final coordinator = SyncCoordinator(
      outboxStore: InMemoryOutboxStore(),
      syncStateStore: stateStore,
      remoteGateway: remote,
      localApplier: applier,
      nowUtc: () => now,
      pullBatchSize: 10,
    );

    final r =
        await coordinator.pullOnce(scopeUid: scopeUid, entityType: entityType);
    expect(r.advanced, isFalse);
    expect(r.lastError, isNotNull);
    expect(coordinator.status.state, equals(SyncRunState.error));

    final cursor = await stateStore.getCursor(
      scopeUid: scopeUid,
      peerId: const PeerId('firestore'),
      entityType: entityType,
    );
    expect(cursor, isNull);
  });

  test('SyncConfigurationManager loads defaults and can persist updates',
      () async {
    final storage = InMemorySyncConfigurationStorage();
    final manager = SyncConfigurationManager(storage: storage);

    final first = await manager.load(writeBackIfMissing: true);
    expect(first.pushBatchSize, equals(50));
    expect(first.pullBatchSize, equals(50));
    expect(first.pullEntityTypes, isEmpty);

    final rawAfterDefault = await storage.read();
    expect(rawAfterDefault, isNotNull);
    expect(rawAfterDefault, contains('"pushBatchSize"'));

    await manager.update(
      (c) => c.copyWith(
        pushBatchSize: 10,
        pullBatchSize: 20,
        pushInterval: const Duration(milliseconds: 1500),
        pullEntityTypes: const ['layout_template', 'skill'],
      ),
      persist: true,
    );

    final manager2 = SyncConfigurationManager(storage: storage);
    final loaded = await manager2.load(writeBackIfMissing: false);
    expect(loaded.pushBatchSize, equals(10));
    expect(loaded.pullBatchSize, equals(20));
    expect(loaded.pushInterval, equals(const Duration(milliseconds: 1500)));
    expect(loaded.pullEntityTypes,
        containsAll(<String>['layout_template', 'skill']));
  });

  test('SyncConfigurationManager can load and persist YAML config', () async {
    final dir = await Directory.systemTemp.createTemp('persistence_core_yaml_');
    try {
      final filePath = '${dir.path}/sync_configuration.yaml';
      final storage = YamlFileSyncConfigurationStorage(filePath: filePath);
      final manager = SyncConfigurationManager(
        storage: storage,
        codec: YamlSyncConfigurationCodec(),
      );

      final first = await manager.load(writeBackIfMissing: true);
      expect(first.pushBatchSize, equals(50));

      final rawAfterDefault = await File(filePath).readAsString();
      expect(rawAfterDefault, contains('sync:'));
      expect(rawAfterDefault, contains('  pushBatchSize: 50'));

      await manager.update(
        (c) => c.copyWith(
          pushBatchSize: 7,
          pullEntityTypes: const ['layout_template'],
        ),
        persist: true,
      );

      final rawAfterUpdate = await File(filePath).readAsString();
      expect(rawAfterUpdate, contains('  pushBatchSize: 7'));
      expect(rawAfterUpdate, contains('    - layout_template'));

      final manager2 = SyncConfigurationManager(
        storage: storage,
        codec: YamlSyncConfigurationCodec(),
      );
      final loaded = await manager2.load(writeBackIfMissing: false);
      expect(loaded.pushBatchSize, equals(7));
      expect(loaded.pullEntityTypes, equals(const ['layout_template']));
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('SyncConfigurationManager emits log events', () async {
    final sink = InMemoryLogSink();
    final logger = SyncLogger(sink: sink, minLevel: SyncLogLevel.debug);

    final storage = InMemorySyncConfigurationStorage();
    final manager = SyncConfigurationManager(
      storage: storage,
      logger: logger,
    );

    await manager.load(writeBackIfMissing: true);
    await manager.update((c) => c.copyWith(pushBatchSize: 9), persist: true);

    final events = sink.records.map((r) => r.event).toList(growable: false);
    expect(events, contains('sync_config_load_start'));
    expect(events, contains('sync_config_load_missing'));
    expect(events, contains('sync_config_save_success'));
    expect(events, contains('sync_config_update'));
  });

  test('SyncRuntime can disable push', () async {
    const scopeUid = 'public';
    final now = DateTime.utc(2026, 1, 10, 9, 0, 0);

    final outbox = InMemoryOutboxStore();
    final coordinator = SyncCoordinator(
      outboxStore: outbox,
      remoteGateway: _FakeSyncPeer(
        pushError: (_) => throw StateError('push should not be called'),
      ),
      nowUtc: () => now,
      maxAttemptsBeforeDead: 10,
      pushBatchSize: 10,
    );

    final runtime = SyncRuntime(
      coordinator: coordinator,
      enablePush: false,
      pushInterval: const Duration(milliseconds: 10),
      pullInterval: const Duration(milliseconds: 10),
      minBackoff: const Duration(milliseconds: 1),
      maxBackoff: const Duration(milliseconds: 10),
      nowUtc: () => now,
    );

    await runtime.start(scopeUid: scopeUid);
    await runtime.triggerPush();
    await runtime.setOnline(false);
    await runtime.setOnline(true);
    await runtime.stop();
    await runtime.dispose();
  });
}
