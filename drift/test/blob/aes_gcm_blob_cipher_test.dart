/// AES-GCM blob cipher 测试（S6 / ACT 4 + A7 变异自检）。
///
/// 覆盖：
/// - 加解密往返：encryptChunk → decryptChunk == 明文。
/// - 真加密：密文 ≠ 明文，且长度 = nonce(12) + 明文 + mac(16)。
/// - nonce 内联头部：前 12 字节即 nonce。
/// - per-chunk nonce 由 chunkIndex 派生：同一明文不同 chunkIndex →
///   密文头部 nonce 不同。
/// - 失败语义：keyVersion 不匹配 → BlobUndecryptableError；密文被篡改
///   → BlobUndecryptableError；换一把 DEK → BlobUndecryptableError。
/// - A7：`BlobCipherRegistry.register()` 接线 —— `DriftLocalBlobStore`
///   私有 blob 加解密路径**真的走到**本 cipher（变异自检：换成另一把
///   DEK 后 openRead 必须解不开）。
library;

import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/blob/aes_gcm_blob_cipher.dart';
import 'package:persistence_drift/blob/blob_cipher_registry.dart';
import 'package:persistence_drift/blob/blob_metadata_repository.dart';
import 'package:persistence_drift/blob/drift_local_blob_store.dart';
import 'package:persistence_drift/persistence_drift.dart';

/// 固定 32 字节 DEK（测试用，非真实密钥）。
List<int> _dek(int seed) => List<int>.generate(32, (i) => (i + seed) % 251);

void main() {
  group('AesGcmBlobCipher · 加解密往返', () {
    final cipher = AesGcmBlobCipher(dek: _dek(1));

    test('encryptChunk → decryptChunk == 明文', () async {
      final plain = List<int>.generate(1000, (i) => i % 251);
      final encrypted = await cipher.encryptChunk(plain, chunkIndex: 0);
      final decrypted =
          await cipher.decryptChunk(encrypted, chunkIndex: 0, keyVersion: 1);
      expect(decrypted, plain);
    });

    test('真加密：密文 ≠ 明文，且含 nonce 头部 + mac', () async {
      final plain = List<int>.generate(100, (i) => i % 251);
      final encrypted = await cipher.encryptChunk(plain, chunkIndex: 0);
      expect(encrypted, isNot(plain), reason: '必须真加密，不得是 identity');
      expect(
        encrypted.length,
        AesGcmBlobCipher.nonceLength + plain.length + AesGcmBlobCipher.macLength,
        reason: '密文布局 = nonce(12) ‖ cipherText ‖ mac(16)',
      );
      // nonce 内联头部：前 12 字节即 nonce。
      final nonce = encrypted.sublist(0, AesGcmBlobCipher.nonceLength);
      final again = await cipher.encryptChunk(plain, chunkIndex: 0);
      expect(again.sublist(0, AesGcmBlobCipher.nonceLength), isNot(nonce),
          reason: '每 chunk 独立随机 nonce，两次加密头部不得相同');
    });

    test('per-chunk nonce 由 chunkIndex 派生：不同 chunkIndex → nonce 不同',
        () async {
      final plain = List<int>.generate(64, (i) => i);
      final e0 = await cipher.encryptChunk(plain, chunkIndex: 0);
      final e1 = await cipher.encryptChunk(plain, chunkIndex: 1);
      expect(
        e0.sublist(0, AesGcmBlobCipher.nonceLength),
        isNot(e1.sublist(0, AesGcmBlobCipher.nonceLength)),
        reason: 'chunkIndex 参与 nonce 派生，位置不同 nonce 必须不同',
      );
      // 各 chunk 独立解密仍正确。
      final d0 =
          await cipher.decryptChunk(e0, chunkIndex: 0, keyVersion: 1);
      final d1 =
          await cipher.decryptChunk(e1, chunkIndex: 1, keyVersion: 1);
      expect(d0, plain);
      expect(d1, plain);
    });

    test('多 chunk 大文件逐块往返', () async {
      final big = List<int>.generate(16384 * 5 + 7, (i) => i % 251);
      final chunks = <List<int>>[];
      for (var i = 0; i < big.length; i += 16384) {
        final end = (i + 16384) > big.length ? big.length : i + 16384;
        chunks.add(await cipher.encryptChunk(
          big.sublist(i, end),
          chunkIndex: chunks.length,
        ));
      }
      final restored = <int>[];
      for (var i = 0; i < chunks.length; i++) {
        restored.addAll(
          await cipher.decryptChunk(chunks[i], chunkIndex: i, keyVersion: 1),
        );
      }
      expect(restored, big);
    });
  });

  group('AesGcmBlobCipher · 失败语义（BlobUndecryptableError）', () {
    test('keyVersion 不匹配 → BlobUndecryptableError', () async {
      final cipher = AesGcmBlobCipher(dek: _dek(1));
      final encrypted = await cipher.encryptChunk(<int>[1, 2, 3], chunkIndex: 0);
      await expectLater(
        cipher.decryptChunk(encrypted, chunkIndex: 0, keyVersion: 2),
        throwsA(isA<BlobUndecryptableError>()),
        reason: '版本轮换未实现：不匹配即不可解',
      );
    });

    test('密文被篡改（改一个字节）→ BlobUndecryptableError', () async {
      final cipher = AesGcmBlobCipher(dek: _dek(1));
      final encrypted = await cipher.encryptChunk(<int>[1, 2, 3], chunkIndex: 0);
      final tampered = List<int>.from(encrypted);
      tampered[encrypted.length - 1] ^= 0x01; // 改 mac 末字节
      await expectLater(
        cipher.decryptChunk(tampered, chunkIndex: 0, keyVersion: 1),
        throwsA(isA<BlobUndecryptableError>()),
        reason: '认证失败（tag 不匹配）必须抛 BlobUndecryptableError',
      );
    });

    test('换一把 DEK → BlobUndecryptableError（密钥不对）', () async {
      final enc = AesGcmBlobCipher(dek: _dek(1));
      final dec = AesGcmBlobCipher(dek: _dek(2)); // 不同 DEK
      final encrypted = await enc.encryptChunk(<int>[9, 9, 9], chunkIndex: 0);
      await expectLater(
        dec.decryptChunk(encrypted, chunkIndex: 0, keyVersion: 1),
        throwsA(isA<BlobUndecryptableError>()),
        reason: 'DEK 不同 → 认证失败 → 不可解（D17 每设备独立 DEK）',
      );
    });

    test('密文过短 → BlobUndecryptableError', () async {
      final cipher = AesGcmBlobCipher(dek: _dek(1));
      await expectLater(
        cipher.decryptChunk(<int>[1, 2, 3], chunkIndex: 0, keyVersion: 1),
        throwsA(isA<BlobUndecryptableError>()),
      );
    });
  });

  group('A7 · LocalBlobStore 私有 blob 加解密路径真走到 cipher（变异自检）', () {
    late Directory tmpDir;
    late PersistenceDriftDatabase db;
    late BlobCipherRegistry registry;

    DriftLocalBlobStore buildStore() {
      return DriftLocalBlobStore(
        scopeUid: 'scope-a',
        metadataRepository: BlobMetadataRepository(db: db, scopeUid: 'scope-a'),
        cipherResolver: registry,
        rootDir: tmpDir.path,
        db: db,
      );
    }

    setUp(() {
      StoragePolicyRegistry.clearForTesting();
      StoragePolicyRegistry.register(
        'xiang_reading',
        StoragePolicy.private(carriers: {Carrier.row, Carrier.blob}),
      );
      tmpDir = Directory.systemTemp.createTempSync('aes_blob_');
      db = PersistenceDriftDatabase(NativeDatabase.memory());
      registry = BlobCipherRegistry();
    });

    tearDown(() {
      StoragePolicyRegistry.clearForTesting();
      db.close();
      tmpDir.deleteSync(recursive: true);
    });

    test('注册 AesGcmBlobCipher 后 put/openRead 往返，密文落盘为真密文',
        () async {
      registry.register('scope-a', AesGcmBlobCipher(dek: _dek(1)));
      final store = buildStore();

      final bytes = List<int>.generate(20000, (i) => i % 251); // 跨多个 chunk
      final handle = await store.put(
        Stream.value(bytes),
        mimeType: 'x/test',
        tier: BlobTier.sourceOfTruth,
        expectedBytes: bytes.length,
      );
      expect(handle.cipherId, 'aes-256-gcm',
          reason: 'handle 必须记录真 cipher 的 id');
      expect(handle.keyVersion, 1);

      await store.reconcileRefs(
        ownerRecordUuid: 'rec-a7',
        handles: {handle},
      );

      final result = await store.openRead(handle);
      expect(result, isA<BlobOk>());
      final read = await (result as BlobOk).plaintext.fold<List<int>>(<int>[],
          (acc, chunk) => acc..addAll(chunk));
      expect(read, bytes, reason: '经真 cipher 解密后必须还原明文');

      // 密文落盘为真密文：直接读 chunk 文件，必须 ≠ 明文。
      final chunk0 = await store.readCipherChunk(handle, 0);
      expect(chunk0, isNot(bytes.sublist(0, 16384)));
      expect(chunk0, hasLength(16384 + AesGcmBlobCipher.nonceLength +
          AesGcmBlobCipher.macLength),
          reason: '落盘 chunk 必须是 nonce+密文+mac 布局');
    });

    test('变异自检：换成另一把 DEK 注册 → openRead 解不开', () async {
      // 先以 DEK-A 加密写入。
      registry.register('scope-a', AesGcmBlobCipher(dek: _dek(1)));
      final store = buildStore();
      final bytes = List<int>.generate(4096, (i) => i % 251);
      final handle = await store.put(
        Stream.value(bytes),
        mimeType: 'x/test',
        tier: BlobTier.sourceOfTruth,
        expectedBytes: bytes.length,
      );
      await store.reconcileRefs(
        ownerRecordUuid: 'rec-a7m',
        handles: {handle},
      );

      // 变异注入：注册 DEK-B 的 cipher（模拟 DEK 轮换/密钥丢失）。
      registry.register('scope-a', AesGcmBlobCipher(dek: _dek(2)));

      final result = await store.openRead(handle);
      expect(result, isA<BlobOk>());
      final stream = (result as BlobOk).plaintext;
      Object? caught;
      try {
        await stream.fold<List<int>>(<int>[], (acc, chunk) => acc..addAll(chunk));
      } on Object catch (e) {
        caught = e;
      }
      expect(caught, isA<BlobUndecryptableError>(),
          reason: '变异后加解密路径必须真的走到 cipher 且解不开 —— '
              '若测试用 identity cipher 或没接线，此处会静默返回错误明文');
    });
  });
}
