import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';

/// 过滤语义的可执行规格（S1b 要落进 peekBatch 的判定逻辑）。
///
/// fail closed：查不到策略的 entityType 一律不推。
List<OutboxRecord> filterForChannel(
  List<OutboxRecord> all,
  Channel channel,
) =>
    all.where((r) {
      final p = StoragePolicyRegistry.lookup(r.entityType);
      if (p == null) return false;
      return p.channels.contains(channel);
    }).toList();

OutboxRecord _record(String entityType, {String id = ''}) {
  return OutboxRecord(
    operationId: '$entityType-$id',
    scopeUid: 'scope-1',
    entityType: entityType,
    entityId: id,
    opType: 'upsert',
    payloadJson: '{}',
    createdAtUtc: DateTime.utc(2026, 1, 1),
    attempt: 0,
  );
}

void main() {
  setUp(() {
    StoragePolicyRegistry.clearForTesting();
  });

  group('策略通道过滤', () {
    test('shared_records_never_reach_lan_peer', () {
      StoragePolicyRegistry.register(
        'xiang_reading',
        StoragePolicy.private(carriers: {Carrier.row}),
      );
      StoragePolicyRegistry.register(
        'playground_post',
        StoragePolicy.shared(carriers: {Carrier.row}),
      );

      final all = [
        _record('xiang_reading', id: 'a'),
        _record('playground_post', id: 'b'),
        _record('xiang_reading', id: 'c'),
        _record('playground_post', id: 'd'),
      ];

      final forLan = filterForChannel(all, Channel.lan);
      // shared 记录绝不进 LAN peer —— 「防混用」的真正验收项
      expect(
        forLan.any((r) => r.entityType == 'playground_post'),
        isFalse,
      );
      // 含全部 private 记录
      expect(
        forLan.map((r) => r.entityId),
        containsAll(['a', 'c']),
      );
    });

    test('shared_records_do_reach_cloud_peer', () {
      StoragePolicyRegistry.register(
        'xiang_reading',
        StoragePolicy.private(carriers: {Carrier.row}),
      );
      StoragePolicyRegistry.register(
        'playground_post',
        StoragePolicy.shared(carriers: {Carrier.row}),
      );

      final all = [
        _record('xiang_reading', id: 'a'),
        _record('playground_post', id: 'b'),
      ];

      final forCloud = filterForChannel(all, Channel.cloud);
      // 反向确认：过滤不是「一刀切禁掉 shared」
      expect(forCloud.map((r) => r.entityType), containsAll([
        'xiang_reading',
        'playground_post',
      ]));
    });

    test('unregistered_entity_type_fails_closed', () {
      StoragePolicyRegistry.register(
        'xiang_reading',
        StoragePolicy.private(carriers: {Carrier.row}),
      );

      final all = [
        _record('xiang_reading', id: 'a'),
        _record('unregistered_thing', id: 'z'),
      ];

      for (final ch in Channel.values) {
        final out = filterForChannel(all, ch);
        expect(
          out.any((r) => r.entityType == 'unregistered_thing'),
          isFalse,
          reason: '未注册 entityType 在通道 $ch 下必须 fail closed',
        );
      }
    });

    test('private_with_lan_disabled_excluded_from_lan', () {
      StoragePolicyRegistry.register(
        'no_lan_thing',
        StoragePolicy.private(
          carriers: {Carrier.row},
          lan: false,
        ),
      );

      final all = [_record('no_lan_thing', id: 'a')];

      expect(filterForChannel(all, Channel.lan), isEmpty);
      expect(filterForChannel(all, Channel.cloud), hasLength(1));
    });
  });

  group('barrel export', () {
    test('barrel_exports_all_new_ports', () {
      // 本文件只 import persistence_core.dart。以下 12 个类型各引用至少一次：
      // 编译通过即证明 barrel 导出完整；遗漏任一条则该类型未定义，编译失败。
      expect(DataVisibility, isNotNull); // storage_classification
      expect(CancellationToken, isNotNull); // cancellation_token
      expect(BlobNotFoundError, isNotNull); // blob_error
      expect(StoragePolicy, isNotNull); // storage_policy
      expect(StoragePolicyRegistry, isNotNull); // storage_policy_registry
      expect(BlobHandle, isNotNull); // blob_types
      expect(BlobCipherResolver, isNotNull); // blob_cipher
      expect(LocalBlobStore, isNotNull); // local_blob_store
      expect(RecordBlobUnitOfWork, isNotNull); // record_blob_unit_of_work
      expect(BlobGateway, isNotNull); // blob_gateway
      expect(PeerSession, isNotNull); // transport
      expect(ExportBundleReader, isNotNull); // export_bundle
    });
  });
}
