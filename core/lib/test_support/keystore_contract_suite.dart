/// 共享 keystore 契约套件（S6 / ACT 5）。
///
/// 【为什么存在】`DeviceKeyStore` 契约测试不能写死在某个包的 `test/`
/// 里 —— `p2p/test/` 导入不到 core 的 `test/`（Dart 的 `test/` 目录不可
/// 跨包引用），且任何 `DeviceKeyStore` 实现（本轮的
/// `PersistentDeviceKeyStore`、以后的 Secure Enclave 实现）都应跑同一套
/// 约束。提取到 `core/lib/test_support/` 后，消费方各自注入实现跑一遍。
///
/// 【签名为什么带 `publicKeyPemOf`】契约（transport.dart）只有
/// `localIdentity` / `sign` / `verify`，**没有公钥 PEM 出口** ——
/// 而「A1 换 key 验不过」必须用对端公钥验签。PEM 出口是实现层能力
/// （`PairingIdentityProvider.localPublicKeyPem`），故作为可选注入参数：
/// 提供则跑 A1 互验；不提供则跳过（契约层能表达的约束照跑）。
///
/// 【不进 barrel】守卫 `core/test/s1b_architecture_guard_test.dart:53`
/// 已断言 barrel 不得导出 `test_support`。消费方一律
/// `import 'package:persistence_core/test_support/keystore_contract_suite.dart'`。
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/storage_error.dart';
import 'package:persistence_core/model/transport.dart';

/// 在指定实现上运行全部 keystore 契约测试。
///
/// 参数说明：
/// - [name]: 实现名，只用于测试分组展示。
/// - [makeStore]: 构造一个干净的 `DeviceKeyStore` 实例。
/// - [publicKeyPemOf]: 取实现公钥 PEM（可选，提供则跑 A1 互验）。
FutureOr<void> runKeystoreContractSuite({
  required String name,
  required DeviceKeyStore Function() makeStore,
  Future<String> Function(DeviceKeyStore store)? publicKeyPemOf,
}) {
  group('Keystore 契约 · $name', () {
    test('localIdentity：deviceId 非空，指纹为 32 组 hex', () async {
      final store = makeStore();
      final identity = await store.localIdentity;
      expect(identity.deviceId, isNotEmpty);
      final groups = identity.publicKeyFingerprint.split(':');
      expect(groups, hasLength(32));
      for (final g in groups) {
        expect(g, hasLength(2));
        expect(int.tryParse(g, radix: 16), isNotNull);
      }
    });

    test('同一实例二次访问 localIdentity 一致', () async {
      final store = makeStore();
      final first = await store.localIdentity;
      final second = await store.localIdentity;
      expect(second.deviceId, first.deviceId);
      expect(second.publicKeyFingerprint, first.publicKeyFingerprint);
    });

    test('sign 产出 64 字节（Ed25519 标准长度）', () async {
      final store = makeStore();
      final sig = await store.sign(<int>[1, 2, 3]);
      expect(sig, hasLength(64));
    });

    test('verify 用坏 PEM 必须抛 StorageError 子类（不静默）', () async {
      final store = makeStore();
      final sig = await store.sign(<int>[1]);
      await expectLater(
        store.verify(
          payload: <int>[1],
          signature: sig,
          peerPublicKeyPem: 'not-a-pem',
        ),
        throwsA(isA<StorageError>()),
      );
    });

    test('A1：sign 产出的签名 verify 验过；换一个 key 验不过', () async {
      final pemOf = publicKeyPemOf;
      if (pemOf == null) {
        markTestSkipped('实现未提供公钥 PEM 出口，跳过互验');
        return;
      }
      final alice = makeStore();
      final bob = makeStore();
      const payload = <int>[1, 2, 3, 4, 5];
      final sig = await alice.sign(payload);
      final alicePem = await pemOf(alice);
      expect(
        await alice.verify(
          payload: payload,
          signature: sig,
          peerPublicKeyPem: alicePem,
        ),
        isTrue,
        reason: '用本端公钥验本端签名必须通过',
      );
      final bobPem = await pemOf(bob);
      expect(
        await alice.verify(
          payload: payload,
          signature: sig,
          peerPublicKeyPem: bobPem,
        ),
        isFalse,
        reason: '换一个 key 验同一个签名必须失败',
      );
    });

    test('A1 补：签名与 payload 绑定，改一个字节验不过', () async {
      final pemOf = publicKeyPemOf;
      if (pemOf == null) {
        markTestSkipped('实现未提供公钥 PEM 出口，跳过互验');
        return;
      }
      final store = makeStore();
      const payload = <int>[10, 20, 30];
      final sig = await store.sign(payload);
      final pem = await pemOf(store);
      expect(
        await store.verify(
          payload: payload,
          signature: sig,
          peerPublicKeyPem: pem,
        ),
        isTrue,
      );
      expect(
        await store.verify(
          payload: <int>[10, 20, 31],
          signature: sig,
          peerPublicKeyPem: pem,
        ),
        isFalse,
      );
    });
  });
}
