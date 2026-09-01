/// WB1 — IndexedDB `WebBlobByteBackend` contract（Storage 侧）。
///
/// WB0 冻结此文件为 Chrome 真实 RED（`WebBlobByteBackend` 曾是 S1d 永久
/// `UnsupportedError` 占位，提交 7447e74）；WB1 以 IndexedDB 实现补齐后，
/// 本套件必须全绿。
///
/// 运行方式（重要）：`flutter test -d chrome` 走 DDC 测试编译器，其
/// `dart.library.js_interop` 恒为 false，任何 `dart:js_interop` /
/// `package:web` 代码都无法编译（已探明，HANDOFF 有记录）。本文件全部是
/// 纯 Dart，改用 dart2js 编译器在真实 Chrome 中运行：
/// `dart test -p chrome test/blob/web_blob_byte_backend_test.dart`
/// （工具链偏离已在 HANDOFF 登记；WB2/3 的真实应用走 dart2js 同样语义）。
///
/// 数据库 `xuan_blob_bytes_v1` / store `chunks`（版本化）；key =
/// `'$manifestDir/$index'`，manifestDir 已含 logical namespace +
/// scopeUid/cipherManifestId。每个测试用独立 manifest 前缀隔离（同一浏览器
/// 上下文共享 IndexedDB）。
library;

import 'package:test/test.dart';
// 只 import 定义 BlobNotFoundError 的窄文件：persistence_core 的 barrel 会
// 传导 import Flutter（world_country_repository），dart2js（dart test
// -p chrome）无法编译 Flutter 引擎源码。
import 'package:persistence_core/model/blob_error.dart';
// 经生产同款平台工厂构造 backend：dart2js 下解析到 IndexedDB 实现
// （`web.dart`），DDC/flutter-test 下解析到 native 桩（WB0 RED 语义）；
// MUTATION_PROOF 也针对此工厂（web 分支换 unsupported 必须 RED）。
import 'package:persistence_drift/blob/blob_byte_backend_factory.dart';

void main() {
  test('binary round trip preserves 0x00/0xFF exactly', () async {
    final backend = createBlobByteBackend(rootDir: 'xuan-blob');
    const manifestDir = 'wb1-t1-scope/77e862bf-a6b1-4ff5-a6b1-77e862bfa6b1';
    const raw = [0x00, 0xFF, 0x7F, 0x10, 0x00, 0x00, 0xFF];

    await backend.writeChunk(manifestDir, 0, raw);

    final bytes = await backend.readChunk(manifestDir, 0);
    expect(bytes, raw, reason: 'chunk 字节必须 0x00/0xFF 无损往返');
    expect(await backend.listChunks(manifestDir), {0});
  });

  test('same-key overwrite is atomic: last write wins, single index', () async {
    final backend = createBlobByteBackend(rootDir: 'xuan-blob');
    const manifestDir = 'wb1-t2-scope/overwrite-manifest';
    const first = [1, 2, 3];
    const second = [0xFA, 0x00, 0xFE, 0xFF];

    await backend.writeChunk(manifestDir, 0, first);
    await backend.writeChunk(manifestDir, 0, second);

    expect(await backend.readChunk(manifestDir, 0), second);
    expect(await backend.listChunks(manifestDir), {0});
    expect(await backend.manifestSize(manifestDir), second.length);
  });

  test('missing read maps to BlobNotFoundError', () async {
    final backend = createBlobByteBackend(rootDir: 'xuan-blob');

    await expectLater(
      backend.readChunk('wb1-t3-scope/absent-manifest', 0),
      throwsA(isA<BlobNotFoundError>()),
    );
  });

  test('exact list indices and manifestSize', () async {
    final backend = createBlobByteBackend(rootDir: 'xuan-blob');
    const manifestDir = 'wb1-t4-scope/sparse-manifest';

    await backend.writeChunk(manifestDir, 0, List<int>.filled(100, 1));
    await backend.writeChunk(manifestDir, 2, List<int>.filled(250, 2));

    expect(await backend.listChunks(manifestDir), {0, 2});
    expect(await backend.manifestSize(manifestDir), 350);
  });

  test('deleteChunk removes only the given index; deleteManifest clears all',
      () async {
    final backend = createBlobByteBackend(rootDir: 'xuan-blob');
    const manifestDir = 'wb1-t5-scope/delete-manifest';

    await backend.writeChunk(manifestDir, 0, [1]);
    await backend.writeChunk(manifestDir, 1, [2]);

    await backend.deleteChunk(manifestDir, 0);
    expect(await backend.listChunks(manifestDir), {1});
    expect(await backend.readChunk(manifestDir, 1), [2]);

    await backend.deleteManifest(manifestDir);
    expect(await backend.listChunks(manifestDir), isEmpty);
    await expectLater(
      backend.readChunk(manifestDir, 1),
      throwsA(isA<BlobNotFoundError>()),
    );
  });

  test('a new backend instance reads data written by a previous instance',
      () async {
    const manifestDir = 'wb1-t6-scope/instance-roundtrip';
    const raw = [0x00, 0x42, 0xFF];

    final first = createBlobByteBackend(rootDir: 'xuan-blob');
    await first.writeChunk(manifestDir, 3, raw);

    final second = createBlobByteBackend(rootDir: 'xuan-blob');
    expect(await second.readChunk(manifestDir, 3), raw);

    // 新实例同样能独立删除。
    await second.deleteChunk(manifestDir, 3);
    expect(await second.listChunks(manifestDir), isEmpty);
  });

  test('distinct scopes/manifests never cross-read', () async {
    final backend = createBlobByteBackend(rootDir: 'xuan-blob');
    const manifestA = 'wb1-t7-scope-a/manifest-1';
    const manifestB = 'wb1-t7-scope-b/manifest-1';

    await backend.writeChunk(manifestA, 0, [10]);
    await backend.writeChunk(manifestB, 0, [20]);

    expect(await backend.readChunk(manifestA, 0), [10]);
    expect(await backend.readChunk(manifestB, 0), [20]);

    // 删除 A 的 manifest 不影响 B。
    await backend.deleteManifest(manifestA);
    expect(await backend.listChunks(manifestB), {0});
    await expectLater(
      backend.readChunk(manifestA, 0),
      throwsA(isA<BlobNotFoundError>()),
    );
  });

  test('adjacent manifest names never bleed into each other', () async {
    // 前缀碰撞回归：`manifest-1` 与 `manifest-1-other` 共享字符前缀，
    // 枚举/删除必须按精确前缀隔离，不得误伤相邻 manifest。
    final backend = createBlobByteBackend(rootDir: 'xuan-blob');
    const manifestA = 'wb1-t7b-scope/manifest-1';
    const manifestAOther = 'wb1-t7b-scope/manifest-1-other';

    await backend.writeChunk(manifestA, 0, [10]);
    await backend.writeChunk(manifestAOther, 0, [30]);
    await backend.writeChunk(manifestAOther, 1, [31]);

    expect(await backend.listChunks(manifestA), {0});
    expect(await backend.listChunks(manifestAOther), {0, 1});
    expect(await backend.manifestSize(manifestA), 1);
    expect(await backend.manifestSize(manifestAOther), 2);

    // 删除 manifestA 只清 manifestA，邻居 ‘-other’ 完整保留。
    await backend.deleteManifest(manifestA);
    expect(await backend.listChunks(manifestA), isEmpty);
    expect(await backend.listChunks(manifestAOther), {0, 1});
    expect(await backend.readChunk(manifestAOther, 1), [31]);
  });

  test('no temp keys: orphanChunkPaths is always empty', () async {
    final backend = createBlobByteBackend(rootDir: 'xuan-blob');
    const manifestDir = 'wb1-t8-scope/never-temp';

    await backend.writeChunk(manifestDir, 0, [7]);
    expect(
      await backend.orphanChunkPaths('wb1-t8-scope'),
      isEmpty,
      reason: 'IndexedDB 后端从不创建 temp key，orphan 枚举固定为空',
    );
  });
}