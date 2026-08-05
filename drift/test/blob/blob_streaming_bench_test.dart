/// S1d blob 流式化基准测试（阶段 0 测量）。
///
/// 运行方式：flutter test --tags bench test/blob/blob_streaming_bench_test.dart
/// 不进 CI，只手动运行。
/// 测量三档输入（1 MB、50 MB、500 MB）的峰值内存和耗时。
library;

import 'dart:io';
import 'dart:math';

// ignore_for_file: avoid_print
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/blob/blob_cipher_registry.dart';
import 'package:persistence_drift/blob/blob_metadata_repository.dart';
import 'package:persistence_drift/blob/drift_local_blob_store.dart';
import 'package:persistence_drift/blob/identity_blob_cipher.dart';
import 'package:persistence_drift/persistence_drift.dart';

const _runBench = bool.fromEnvironment('BENCH', defaultValue: false);

final _sizes = [1, 50, 500]; // MB

void main() {
  if (!_runBench) {
    test('benchmark skipped (run with --dart-define=BENCH=true)', () {});
    return;
  }

  for (final sizeMb in _sizes) {
    final sizeBytes = sizeMb * 1024 * 1024;

    group('${sizeMb}MB input', () {
      late Directory tmpDir;
      late PersistenceDriftDatabase db;
      late DriftLocalBlobStore store;

      setUp(() {
        StoragePolicyRegistry.clearForTesting();
        StoragePolicyRegistry.register(
          'xiang_reading',
          StoragePolicy.private(carriers: {Carrier.row, Carrier.blob}),
        );

        tmpDir = Directory.systemTemp.createTempSync('blob_bench_');
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

      test('put() 耗时', () async {
        final rng = Random(42);
        final data = List<int>.generate(sizeBytes, (_) => rng.nextInt(256));
        final stream = Stream.value(data);

        final sw = Stopwatch()..start();
        final handle = await store.put(
          stream,
          mimeType: 'application/octet-stream',
          tier: BlobTier.sourceOfTruth,
          expectedBytes: sizeBytes,
        );
        sw.stop();

        print('[BENCH] put() ${sizeMb}MB: ${sw.elapsedMilliseconds}ms total, '
            'sha256=${handle.plaintextSha256.substring(0, 16)}...');
      });

      test('putFile() 耗时', () async {
        final filePath = '${tmpDir.path}/input_${sizeMb}mb.bin';
        final file = File(filePath);
        final rng = Random(42);
        final chunk = List<int>.generate(1024 * 1024, (_) => rng.nextInt(256));
        for (var i = 0; i < sizeMb; i++) {
          await file.writeAsBytes(chunk, mode: FileMode.append);
        }

        final sw = Stopwatch()..start();
        final handle = await store.putFile(
          filePath,
          mimeType: 'application/octet-stream',
          tier: BlobTier.sourceOfTruth,
        );
        sw.stop();

        print('[BENCH] putFile() ${sizeMb}MB: ${sw.elapsedMilliseconds}ms total, '
            'sha256=${handle.plaintextSha256.substring(0, 16)}...');
      });
    });
  }
}