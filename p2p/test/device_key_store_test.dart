/// `DeviceKeyStore` 契约测试（S6 / ACT 1）。
///
/// 覆盖：
/// - A1：sign() 产出的签名 verify() 验过；换一个 key 验不过。
/// - A2：私钥无任何导出路径--源码扫描守卫。
/// - 持久化：同一 store 二次访问 localIdentity 与首次一致；进程重启模拟。
/// - PEM 编解码往返。
/// - 指纹稳定性。
/// - 失败语义：坏 PEM 抛 StorageError 子类（不静默）。
///
/// 测试用内存 fake 的 `FlutterSecureStorage`（[_InMemorySecureStorage]），
/// 不依赖平台 Keychain/Keystore，可在 `flutter test`（无设备）下跑。
library;

import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/storage_error.dart';
import 'package:persistence_core/model/transport.dart';
import 'package:persistence_core/test_support/keystore_contract_suite.dart';
import 'package:persistence_p2p/persistence_p2p.dart';
import 'package:uuid/uuid.dart';

void main() {
  // ── ACT 5：可复用契约套件（两个结构迥异的实现各跑一遍）──
  runKeystoreContractSuite(
    name: 'PersistentDeviceKeyStore',
    makeStore: () => PersistentDeviceKeyStore(storage: _InMemorySecureStorage()),
    publicKeyPemOf: (s) => (s as PersistentDeviceKeyStore).localPublicKeyPem,
  );
  runKeystoreContractSuite(
    name: 'InMemoryKeyStore（纯内存，不经 secure storage）',
    makeStore: () => _InMemoryKeyStore('mem-device'),
    publicKeyPemOf: (s) => (s as _InMemoryKeyStore).localPublicKeyPem,
  );

  group('DeviceKeyStore · A1 sign/verify', () {
    test('sign 产出的签名 verify 能验过；换一个 key 验不过', () async {
      final alice = _makeStore(uuid: const _FixedUuid('alice-uuid'));
      final bob = _makeStore(uuid: const _FixedUuid('bob-uuid'));

      const payload = <int>[1, 2, 3, 4, 5];
      final sig = await alice.sign(payload);
      final alicePem = await alice.localPublicKeyPem;

      // 正向：用 alice 自己的公钥验 alice 的签名 -> 通过。
      expect(
        await alice.verify(
          payload: payload,
          signature: sig,
          peerPublicKeyPem: alicePem,
        ),
        isTrue,
        reason: '用本端公钥验本端签名必须通过',
      );

      // 反向：用 bob 的公钥验 alice 的签名 -> 不通过（A1 核心：换 key 验不过）。
      final bobPem = await bob.localPublicKeyPem;
      expect(
        await alice.verify(
          payload: payload,
          signature: sig,
          peerPublicKeyPem: bobPem,
        ),
        isFalse,
        reason: '换一个 key（bob）验 alice 的签名必须失败',
      );
    });

    test('签名与 payload 绑定：改一个字节验不过', () async {
      final store = _makeStore();
      const payload = <int>[10, 20, 30];
      final sig = await store.sign(payload);
      final pem = await store.localPublicKeyPem;

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
          payload: <int>[10, 20, 31], // 改一个字节
          signature: sig,
          peerPublicKeyPem: pem,
        ),
        isFalse,
        reason: '签名必须与 payload 绑定，改字节即失效',
      );
    });

    test('签名为 64 字节（Ed25519 标准长度）', () async {
      final store = _makeStore();
      final sig = await store.sign(<int>[1, 2, 3]);
      expect(sig, hasLength(64),
          reason: 'Ed25519 签名固定 64 字节');
    });
  });

  group('DeviceKeyStore · 持久化', () {
    test('二次访问 localIdentity 与首次一致（seed 落盘后确定性重建）',
        () async {
      final storage = _InMemorySecureStorage();
      final store = PersistentDeviceKeyStore(
        storage: storage,
        uuid: const _FixedUuid('fixed-device-id'),
      );

      final first = await store.localIdentity;
      final second = await store.localIdentity;
      expect(second.deviceId, first.deviceId);
      expect(second.publicKeyFingerprint, first.publicKeyFingerprint);

      // 关键：用一个读同一份 secure storage 的全新 store 实例模拟
      // 「进程重启后重新加载」。指纹必须与首次一致（seed 确定性派生公钥）。
      final reloaded = PersistentDeviceKeyStore(
        storage: storage, // 同一份存储
        uuid: const _FixedUuid('should-not-be-used'),
      );
      final reloadedIdentity = await reloaded.localIdentity;
      expect(
        reloadedIdentity.deviceId,
        first.deviceId,
        reason: 'deviceId 持久化后重载必须一致',
      );
      expect(
        reloadedIdentity.publicKeyFingerprint,
        first.publicKeyFingerprint,
        reason: 'seed 持久化后重载，派生的公钥指纹必须一致',
      );
    });

    test('首次访问即持久化 seed 与 deviceId', () async {
      final storage = _InMemorySecureStorage();
      final store = PersistentDeviceKeyStore(
        storage: storage,
        uuid: const _FixedUuid('new-device'),
      );

      await store.localIdentity;

      expect(storage.map.containsKey('device_identity.ed25519_seed'), isTrue,
          reason: 'seed 必须落 secure storage');
      expect(storage.map.containsKey('device_identity.device_id'), isTrue,
          reason: 'deviceId 必须落 secure storage');
      expect(storage.map['device_identity.device_id'], 'new-device');
    });

    test('localPublicKeyPem 与指纹同源（重载后一致）', () async {
      final storage = _InMemorySecureStorage();
      final store = PersistentDeviceKeyStore(
        storage: storage,
        uuid: const _FixedUuid('pem-consistency'),
      );
      final pem1 = await store.localPublicKeyPem;

      final reloaded = PersistentDeviceKeyStore(storage: storage);
      final pem2 = await reloaded.localPublicKeyPem;
      expect(pem2, pem1,
          reason: '同一 seed 派生的公钥 PEM 必须一致');
    });
  });

  group('DeviceKeyStore · PEM 与指纹', () {
    test('PEM 含标准头尾', () async {
      final store = _makeStore();
      final pem = await store.localPublicKeyPem;
      expect(pem, contains('-----BEGIN PUBLIC KEY-----'));
      expect(pem, contains('-----END PUBLIC KEY-----'));
    });

    test('指纹为 SHA-256 hex `:` 分组，32 字节公钥 -> 32 组 hex', () async {
      final store = _makeStore();
      final identity = await store.localIdentity;
      final groups = identity.publicKeyFingerprint.split(':');
      expect(groups, hasLength(32),
          reason: 'SHA-256 产出 32 字节，每字节一组 hex');
      for (final g in groups) {
        expect(g, hasLength(2));
        expect(int.tryParse(g, radix: 16), isNotNull,
            reason: '每组必须是合法 hex');
      }
    });

    test('PEM 解析失败抛 DeviceKeyStoreError（非静默）', () async {
      final store = _makeStore();
      const payload = <int>[1];
      final sig = await store.sign(payload);
      await expectLater(
        store.verify(
          payload: payload,
          signature: sig,
          peerPublicKeyPem: 'not-a-pem',
        ),
        throwsA(isA<DeviceKeyStoreError>()),
        reason: '坏 PEM 必须抛 StorageError 子类，不静默',
      );
    });

    test('DeviceKeyStoreError 是 StorageError 子类（契约 §3.6）', () {
      // 编译期即证：DeviceKeyStoreError is-a StorageError。
      expect(
        DeviceKeyStoreError(message: '', reason: '', suggestion: ''),
        isA<StorageError>(),
      );
    });
  });

  group('DeviceKeyStore · A2 私钥无导出路径', () {
    // 机械扫描源码：实现类不得有任何「取出私钥/seed/KeyPair 对象」的
    // public 成员。这是契约层 `transport_contract_test.dart` 同款守卫手法
    // 的实现层补充--契约层守 DeviceKeyStore 抽象，本测试守具体实现。
    //
    // 允许的 public 成员：
    // - localIdentity（契约；返回指纹，不含私钥）
    // - sign（契约；返回签名，不含私钥）
    // - verify（契约；返回 bool，不含私钥）
    // - localPublicKeyPem（公钥，非私钥；配对流程要交换它）
    // - encodePublicKeyPem（静态 helper；公钥，非私钥）
    test('源码扫描：无私钥/seed/KeyPair 导出的 public 成员', () {
      final src = File('lib/device_key_store.dart').readAsStringSync();

      // 禁止出现「取出私钥」语义的 public getter。
      expect(src.contains('get privateKey'), isFalse,
          reason: '不得有 privateKey getter');
      expect(src.contains('get seed'), isFalse,
          reason: '不得有 seed getter（私钥材料）');
      expect(src.contains('get keyPair'), isFalse,
          reason: '不得有 keyPair getter（含私钥对象）');
      expect(src.contains('get privateKeyBytes'), isFalse,
          reason: '不得有 privateKeyBytes getter');
      expect(src.contains('get privatePem'), isFalse,
          reason: '不得有 privatePem getter');

      // extractPrivateKeyBytes 不得出现在 public 成员返回路径。
      // 允许在私有方法（_ 开头）内调用（如 _loadOrCreateIdentity 持久化时）。
      expect(
        RegExp(r'return\s+.*extractPrivateKeyBytes').hasMatch(src),
        isFalse,
        reason: '不得把 extractPrivateKeyBytes 的结果返回给调用方',
      );

      // 「privateKey」「seed」字样只允许出现在注释或以 _ 开头的私有方法里。
      // 粗略守卫：源码里出现 'extractPrivateKeyBytes' 的行必须在该行含 '_'
      // （私有方法名）或为注释（/// 或 //）。
      for (final line in src.split('\n')) {
        if (line.contains('extractPrivateKeyBytes') &&
            !line.contains('///') &&
            !line.contains('//')) {
          // 代码行：必须在一个 _ 开头的方法体内（保守判据：行内含
          // 'await _' 或方法定义以 _ 开头）。这里只断言「不直接 return
          // 给 public API」--上面那条 return 正则已覆盖核心。
          // 额外：禁止出现公开方法签名里 extractPrivateKeyBytes。
          expect(
            RegExp(r'^\s*(?:Future|List|String)\s+\w*\s*\(')
                .hasMatch(line) &&
                !line.trim().startsWith('_'),
            isFalse,
            reason: 'extractPrivateKeyBytes 不得出现在 public 方法签名：$line',
          );
        }
      }
    });

    test('localPublicKeyPem 返回的是公钥 PEM，可被 verify 接受', () async {
      // 证明 localPublicKeyPem 拿到的是公钥（非私钥）：用它验本端签名通过。
      // 若它误返回私钥材料，verify 的 PEM 解析会失败（私钥不是 SPKI 公钥）。
      final store = _makeStore();
      const payload = <int>[7, 8, 9];
      final sig = await store.sign(payload);
      final pem = await store.localPublicKeyPem;
      expect(
        await store.verify(
          payload: payload,
          signature: sig,
          peerPublicKeyPem: pem,
        ),
        isTrue,
        reason: 'localPublicKeyPem 必须是合法公钥 PEM，能被 verify 接受',
      );
    });
  });
}

// ── 测试辅助 ──────────────────────────────────────────────────

/// 纯内存 `DeviceKeyStore` fake（ACT 5 第二个结构迥异的实现）：
/// 密钥对直接持在内存对象里，不经 secure storage、无持久化。
/// 结构与 `PersistentDeviceKeyStore` 迥异（无存储注入、无缓存身份、
/// 无 PEM 静态 helper 的存储语义），契约行为必须一致。
class _InMemoryKeyStore implements DeviceKeyStore, PairingIdentityProvider {
  _InMemoryKeyStore(this.deviceId);

  final String deviceId;
  final Ed25519 _ed25519 = Ed25519();
  SimpleKeyPair? _keyPair;
  PeerIdentity? _identity;

  Future<SimpleKeyPair> _kp() async => _keyPair ??= await _ed25519.newKeyPair();

  @override
  Future<PeerIdentity> get localIdentity async {
    final cached = _identity;
    if (cached != null) return cached;
    final kp = await _kp();
    final pub = await kp.extractPublicKey();
    final hash = await Sha256().hash(pub.bytes);
    final fp = hash.bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(':');
    return _identity =
        PeerIdentity(deviceId: deviceId, publicKeyFingerprint: fp);
  }

  @override
  Future<String> get localPublicKeyPem async {
    final kp = await _kp();
    final pub = await kp.extractPublicKey();
    return PersistentDeviceKeyStore.encodePublicKeyPem(pub.bytes);
  }

  @override
  Future<List<int>> sign(List<int> payload) async {
    final kp = await _kp();
    final sig = await _ed25519.sign(payload, keyPair: kp);
    return sig.bytes;
  }

  @override
  Future<bool> verify({
    required List<int> payload,
    required List<int> signature,
    required String peerPublicKeyPem,
  }) async {
    try {
      final pubBytes = _parsePublicKeyPem(peerPublicKeyPem);
      final sig = Signature(
        signature,
        publicKey: SimplePublicKey(pubBytes, type: KeyPairType.ed25519),
      );
      return _ed25519.verify(payload, signature: sig);
    } on Object catch (e) {
      // 契约 §3.6：失败一律抛 StorageError 子类，不静默。
      throw DeviceKeyStoreError(
        message: '对端公钥 PEM 解析失败',
        reason: '$e',
        suggestion: '确认 PEM 为标准 Ed25519 SPKI 格式',
      );
    }
  }

  /// SPKI PEM → 公钥原始字节（12B 前缀 + 32B 公钥）。
  static List<int> _parsePublicKeyPem(String pem) {
    const prefix = [
      0x30, 0x2a, 0x30, 0x05, 0x06, 0x03, 0x2b, 0x65, 0x70, 0x03, 0x21, 0x00,
    ];
    final lines = pem
        .split('\n')
        .where((l) => !l.startsWith('-----') && l.trim().isNotEmpty)
        .join('');
    final der = base64.decode(lines);
    if (der.length != prefix.length + 32) {
      throw FormatException('SPKI DER 长度异常: ${der.length}');
    }
    for (var i = 0; i < prefix.length; i++) {
      if (der[i] != prefix[i]) {
        throw FormatException('SPKI 前缀不匹配（非 Ed25519？）');
      }
    }
    return der.sublist(prefix.length);
  }
}

PersistentDeviceKeyStore _makeStore({Uuid? uuid}) =>
    PersistentDeviceKeyStore(storage: _InMemorySecureStorage(), uuid: uuid);

/// 内存版 `FlutterSecureStorage`：实现 read/write 用 Map 承载，供测试注入。
///
/// 仅实现本测试用到的方法（read/write），其余经 [noSuchMethod] 兜底。
class _InMemorySecureStorage implements FlutterSecureStorage {
  final Map<String, String> map = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      map[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      map.remove(key);
    } else {
      map[key] = value;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 固定 UUID 生成器（测试用，保证 deviceId 确定性）。
///
/// 经 [noSuchMethod] 路由 `v4()` 调用：uuid 4.x 的 `v4` 签名带
/// `V4Options`（`package:uuid/data.dart`，主库不导出），显式覆写会
/// 因类型不可见而编译失败；走 noSuchMethod 则与 uuid 版本解耦。
class _FixedUuid implements Uuid {
  final String _value;
  const _FixedUuid(this._value);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #v4) {
      return _value;
    }
    return super.noSuchMethod(invocation);
  }
}
