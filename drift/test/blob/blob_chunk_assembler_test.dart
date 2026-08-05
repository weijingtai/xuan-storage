/// 分块装配器回归测试（验收方补，2026-08-04）。
///
/// 【为什么必须有这条】S1d 修 O(n²) 时把累积器换成了 `List<Uint8List>` 队列 +
/// `pendingOffset`，`takeChunk()` 允许**一块 chunk 横跨多个上游 part**。
/// 但当时全部既有测试喂的都是 `Stream.value(整段)`（单 part），而 `putFile()`
/// 走 `file.openRead()`，其分片恰好是 64 KiB = 4 × `blobChunkSize`(16 KiB)
/// —— **两条路径都天然对齐，跨界拼装这段代码一次都没被跑到**。
/// 验收时对 `takeChunk` 注入变异（`take = need`，去掉 available 截断），整套
/// blob 测试仍然全绿 —— 这就是「代码对但门禁是假的」。
///
/// 本文件用**故意不对齐**的分片（7000 B/片）把那条路径钉住：
/// 7000 与 16384 互不整除，几乎每一块 chunk 都要跨 2–3 个 part 拼。
/// 已做变异自检：把 `takeChunk` 里的 `final take = need < available ? need :
/// available;` 改成 `final take = need;`（编译仍过）→ 本测试红在
/// `setRange` 的 `Bad state: Too few elements`；复原后绿。
library;

import 'dart:io';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/blob/blob_cipher_registry.dart';
import 'package:persistence_drift/blob/blob_metadata_repository.dart';
import 'package:persistence_drift/blob/drift_local_blob_store.dart';
import 'package:persistence_drift/blob/identity_blob_cipher.dart';
import 'package:persistence_drift/persistence_drift.dart';

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
    tmpDir = Directory.systemTemp.createTempSync('blob_assembler_');
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    store = DriftLocalBlobStore(
      scopeUid: 'scope-a',
      metadataRepository: BlobMetadataRepository(db: db, scopeUid: 'scope-a'),
      cipherResolver: BlobCipherRegistry()
        ..register('scope-a', const IdentityBlobCipher()),
      rootDir: tmpDir.path,
      db: db,
    );
  });

  tearDown(() async {
    await db.close();
    tmpDir.deleteSync(recursive: true);
    StoragePolicyRegistry.clearForTesting();
  });

  /// 分片大小刻意与 [blobChunkSize] 互质，逼出跨 part 拼装。
  Stream<List<int>> chopped(List<int> data, int partSize) async* {
    for (var i = 0; i < data.length; i += partSize) {
      yield data.sublist(i, min(i + partSize, data.length));
    }
  }

  Future<BlobHandle> putAll(Stream<List<int>> s, int total) => store.put(
        s,
        mimeType: 'application/octet-stream',
        tier: BlobTier.sourceOfTruth,
        expectedBytes: total,
      );

  test('非对齐分片流与整段输入必须产出完全相同的 handle', () async {
    final rng = Random(7);
    final data = List<int>.generate(200000, (_) => rng.nextInt(256));

    final whole = await putAll(Stream.value(data), data.length);
    final piecewise = await putAll(chopped(data, 7000), data.length);

    expect(piecewise.plaintextSha256, whole.plaintextSha256,
        reason: '跨 part 边界拼装若丢字节或串位，整段 sha256 必然不同');
    expect(piecewise.totalBytes, data.length);
    expect(piecewise.chunkCount, whole.chunkCount,
        reason: '分片方式不得改变 chunk 切分结果');
  });

  test('极小分片（1 B/片）同样正确 —— 队列长度远大于单块', () async {
    final rng = Random(11);
    // 取 blobChunkSize 的 2.5 倍，确保既有整块也有残余块。
    final data =
        List<int>.generate(blobChunkSize * 2 + 333, (_) => rng.nextInt(256));

    final whole = await putAll(Stream.value(data), data.length);
    final byteByByte = await putAll(chopped(data, 1), data.length);

    expect(byteByByte.plaintextSha256, whole.plaintextSha256);
    expect(byteByByte.chunkCount, 3, reason: '2 整块 + 1 残余块');
  });

  test('单片恰好等于 blobChunkSize 的对齐流也不得回归', () async {
    final rng = Random(13);
    final data =
        List<int>.generate(blobChunkSize * 4, (_) => rng.nextInt(256));

    final whole = await putAll(Stream.value(data), data.length);
    final aligned = await putAll(chopped(data, blobChunkSize), data.length);

    expect(aligned.plaintextSha256, whole.plaintextSha256);
    expect(aligned.chunkCount, 4);
  });
}
