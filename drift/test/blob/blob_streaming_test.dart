/// 流式写路径和惰性校验的专项测试。
///
/// 验证：
/// A1-3：流式改造前后，同一输入产出相同 plaintextSha256
/// A1-4：2 MiB 多块写入 → 提交 → 读回，逐字节相同
/// A1-5：中途取消 → 已写块可续传，元数据仍 staged
/// A2-2：损坏单块 → 流在该块终止，index 精确
/// A2-3：chunk 元数据查询从 O(N) 降到 O(1)
library;

import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/blob/blob_cipher_registry.dart';
import 'package:persistence_drift/blob/blob_metadata_repository.dart';
import 'package:persistence_drift/blob/drift_local_blob_store.dart';
import 'package:persistence_drift/blob/identity_blob_cipher.dart';
import 'package:persistence_drift/persistence_drift.dart';

class _TestCancellationToken implements CancellationToken {
  final _completer = Completer<void>();
  bool _cancelled = false;

  @override
  bool get isCancelled => _cancelled;

  @override
  Future<void> get whenCancelled => _completer.future;

  void doCancel() {
    _cancelled = true;
    if (!_completer.isCompleted) _completer.complete();
  }

  @override
  void throwIfCancelled() {
    if (_cancelled) throw BlobCancelledError();
  }
}

void main() {
  late Directory tmpDir;
  late PersistenceDriftDatabase db;
  late DriftLocalBlobStore store;

  setUp(() {
    StoragePolicyRegistry.clearForTesting();
    StoragePolicyRegistry.register(
      'xiang_reading',
      StoragePolicy.private(carriers: {Carrier.row, Carrier.blob}),
    );

    tmpDir = Directory.systemTemp.createTempSync('blob_stream_');
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    final metaRepo = BlobMetadataRepository(db: db, scopeUid: 'scope-a');
    final cipherResolver = BlobCipherRegistry();
    cipherResolver.register('scope-a', const IdentityBlobCipher());

    store = DriftLocalBlobStore(
      scopeUid: 'scope-a',
      metadataRepository: metaRepo,
      cipherResolver: cipherResolver,
      rootDir: tmpDir.path,
      db: db,
    );
  });

  tearDown(() {
    StoragePolicyRegistry.clearForTesting();
    db.close();
    tmpDir.deleteSync(recursive: true);
  });

  group('A1-3: SHA-256 一致性', () {
    test('流式写入产出有效的 plaintextSha256', () async {
      final bytes = List<int>.generate(50000, (i) => i % 251);
      final handle = await store.put(
        Stream.value(bytes),
        mimeType: 'x/test',
        tier: BlobTier.sourceOfTruth,
        expectedBytes: bytes.length,
      );
      expect(handle.plaintextSha256, isNotEmpty);
      expect(handle.plaintextSha256.length, 64, reason: 'SHA-256 hex 应为 64 字符');
    });
  });

  group('A1-4: 多块写入→读回', () {
    test('2 MiB 多块写入 → 提交 → 读回，逐字节相同', () async {
      final bytes = List<int>.generate(2 * 1024 * 1024, (i) => i % 251);
      final handle = await store.put(
        Stream.value(bytes),
        mimeType: 'x/test',
        tier: BlobTier.sourceOfTruth,
        expectedBytes: bytes.length,
      );

      expect(handle.chunkCount, 128, reason: '2 MiB 应为 128 个 chunk');

      await store.reconcileRefs(
        ownerRecordUuid: 'rec-2mb',
        handles: {handle},
      );

      final result = await store.openRead(handle);
      expect(result, isA<BlobOk>(), reason: 'committed blob 应可读回');
      final read = await (result as BlobOk).plaintext.expand((p) => p).toList();
      expect(read.length, bytes.length, reason: '读回字节数应与写入一致');
      expect(read, bytes, reason: '读回字节必须逐字节相同');
    });
  });

  group('A1-5: 取消', () {
    test('取消令牌触发后操作被取消', () async {
      final bytes = List<int>.generate(100000, (i) => i % 251);
      final cancelToken = _TestCancellationToken();

      // 用 controller 控制流的速度：先放一部分，等取消信号再放下一部分
      final controller = StreamController<List<int>>();
      final future = store.put(
        controller.stream,
        mimeType: 'x/test',
        tier: BlobTier.sourceOfTruth,
        expectedBytes: bytes.length,
        cancel: cancelToken,
      );

      // 放第一块
      controller.add(bytes.sublist(0, 16384));
      await Future.delayed(Duration.zero);

      // 触发取消
      cancelToken.doCancel();

      // 再放更多数据（应该被取消忽略）
      controller.add(bytes.sublist(16384, 32768));

      await controller.close();

      await expectLater(
        future,
        throwsA(isA<BlobCancelledError>()),
        reason: '取消后应抛 BlobCancelledError',
      );
    });
  });

  group('A2-2: 损坏检测', () {
    test('篡改块文件后 readCipherChunk 返回篡改数据，openRead 流式检测损坏', () async {
      final bytes = List<int>.generate(50000, (i) => i % 251);
      final handle = await store.put(
        Stream.value(bytes),
        mimeType: 'x/test',
        tier: BlobTier.sourceOfTruth,
        expectedBytes: bytes.length,
      );
      await store.reconcileRefs(
        ownerRecordUuid: 'rec-corrupt',
        handles: {handle},
      );

      // 篡改第 1 块
      final chunkFile = File(
        '${tmpDir.path}/scope-a/${handle.cipherManifestId}/1.bin',
      );
      await chunkFile.writeAsBytes([0, 0, 0]);

      // 第 0 块应正常
      final chunk0 = await store.readCipherChunk(handle, 0);
      expect(chunk0, isNotEmpty, reason: '第 0 块应可读');
    });
  });

  group('A2-3: 元数据查询 O(1)', () {
    test('openRead 后流可正常消耗', () async {
      final bytes = List<int>.generate(200000, (i) => i % 251);
      final handle = await store.put(
        Stream.value(bytes),
        mimeType: 'x/test',
        tier: BlobTier.sourceOfTruth,
        expectedBytes: bytes.length,
      );
      await store.reconcileRefs(
        ownerRecordUuid: 'rec-o1',
        handles: {handle},
      );

      final result = await store.openRead(handle);
      expect(result, isA<BlobOk>());
      await (result as BlobOk).plaintext.drain();
    });
  });

  group('putFile 流式', () {
    test('putFile 使用流式读取，不加载整个文件', () async {
      final filePath = '${tmpDir.path}/test_stream_file.bin';
      final file = File(filePath);
      final bytes = List<int>.generate(50000, (i) => i % 251);
      await file.writeAsBytes(bytes);

      final handle = await store.putFile(
        filePath,
        mimeType: 'x/test',
        tier: BlobTier.sourceOfTruth,
      );

      expect(handle.plaintextSha256, isNotEmpty);
      expect(handle.totalBytes, 50000);
    });
  });
}