import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/storage_policy.dart';
import 'package:persistence_core/model/storage_policy_registry.dart';

void main() {
  setUp(() {
    StoragePolicyRegistry.clearForTesting();
  });

  group('结构性不变式（遍历注册表）', () {
    test('structural_invariants_hold_for_all_registered', () {
      StoragePolicyRegistry.register(
        'xiang_reading',
        StoragePolicy.private(carriers: {Carrier.row, Carrier.blob}),
      );
      StoragePolicyRegistry.register(
        'playground_post',
        StoragePolicy.shared(carriers: {Carrier.row, Carrier.blob}),
      );
      StoragePolicyRegistry.register(
        'official_theme',
        StoragePolicy.resource(
          carriers: {Carrier.row, Carrier.blob},
          sources: {Source.bundled, Source.officialRemote},
        ),
      );
      StoragePolicyRegistry.register('remote_control', StoragePolicy.control());

      final all = StoragePolicyRegistry.all;
      expect(all, hasLength(4));

      // #1 shared 策略 channels 恰为 {Channel.cloud}
      final shared = all['playground_post']!;
      expect(shared.channels, {Channel.cloud});
      expect(shared.visibility, DataVisibility.shared);

      // #2 private 策略 encryption == e2eeOverSse 且 channels 含 Channel.cloud
      final priv = all['xiang_reading']!;
      expect(priv.encryption, Encryption.e2eeOverSse);
      expect(priv.channels, contains(Channel.cloud));
      expect(priv.visibility, DataVisibility.private);

      // #3 control 策略 publisher == official 且 sources 恰为 {Source.officialRemote}
      final control = all['remote_control']!;
      expect(control.publisher, Publisher.official);
      expect(control.sources, {Source.officialRemote});
      expect(control.visibility, DataVisibility.control);
    });
  });

  group('private 通道开关', () {
    test('private_cloud_cannot_be_removed', () {
      // cloud 不是参数，结构上不可关闭
      final p = StoragePolicy.private(
        carriers: {Carrier.row},
        lan: false,
        webrtc: false,
        manualExport: false,
      );
      expect(p.channels, {Channel.cloud});
    });

    test('private_channel_flags_take_effect', () {
      // 逐个 flag 单独关闭
      final noLan = StoragePolicy.private(
        carriers: {Carrier.row},
        lan: false,
      );
      expect(noLan.channels, {Channel.cloud, Channel.webrtc, Channel.manualExport});

      final noWebrtc = StoragePolicy.private(
        carriers: {Carrier.row},
        webrtc: false,
      );
      expect(noWebrtc.channels, {Channel.cloud, Channel.lan, Channel.manualExport});

      final noManualExport = StoragePolicy.private(
        carriers: {Carrier.row},
        manualExport: false,
      );
      expect(noManualExport.channels, {Channel.cloud, Channel.lan, Channel.webrtc});

      // 默认全部开启
      final allOn = StoragePolicy.private(carriers: {Carrier.row});
      expect(
        allOn.channels,
        {Channel.cloud, Channel.lan, Channel.webrtc, Channel.manualExport},
      );
    });
  });

  group('注册期不变式（register 抛 StateError）', () {
    test('register_rejects_resource_with_user_publisher', () {
      // 不变式 #4：当前阶段 resource 仅官方可上架
      expect(
        () => StoragePolicyRegistry.register(
          'ugc_theme',
          StoragePolicy.resource(
            carriers: {Carrier.row},
            sources: {Source.bundled},
            publisher: Publisher.user,
          ),
        ),
        throwsStateError,
      );
    });

    test('register_rejects_empty_sources_on_resource', () {
      // 不变式 #5：resource 的 sources 非空
      expect(
        () => StoragePolicyRegistry.register(
          'empty_resource',
          StoragePolicy.resource(carriers: {Carrier.row}, sources: {}),
        ),
        throwsStateError,
      );
    });

    test('register_rejects_duplicate_entity_type', () {
      StoragePolicyRegistry.register(
        'dup_type',
        StoragePolicy.shared(carriers: {Carrier.row}),
      );
      expect(
        () => StoragePolicyRegistry.register(
          'dup_type',
          StoragePolicy.shared(carriers: {Carrier.row}),
        ),
        throwsStateError,
      );
    });

    test('lookup_unregistered_returns_null_not_default', () {
      // 未注册返回 null，不是默认策略 —— 调用方据此 fail closed
      expect(StoragePolicyRegistry.lookup('never_registered'), isNull);
    });
  });
}
