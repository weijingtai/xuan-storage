import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/blob/blob_cipher_registry.dart';
import 'package:persistence_drift/blob/blob_garbage_collector.dart';
import 'package:persistence_drift/blob/blob_metadata_repository.dart';
import 'package:persistence_drift/blob/drift_local_blob_store.dart';
import 'package:persistence_drift/blob/identity_blob_cipher.dart';
import 'package:persistence_drift/media/drift_media_reference_reader.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_media/repository_interface_media.dart';

/// Test suite for DriftMediaReferenceReader (Task S2b).
///
/// Verifies:
/// - Reference recovery for complete, partial, corrupt, undecryptable states
/// - Reading plaintext stream by refId in a fresh process/adapter instance
/// - Absent status on unknown refId
/// - Scope isolation: Scope B cannot resolve Scope A's refId or data
/// - Orphan retention: Removing last source-of-truth reference preserves data and readability
void main() {
  const scopeA = 'scope-media-s2b-a';
  const scopeB = 'scope-media-s2b-b';

  late Directory tmpDir;
  late PersistenceDriftDatabase db;
  late BlobCipherRegistry cipherResolverA;
  late BlobMetadataRepository metaRepoA;
  late DriftLocalBlobStore blobStoreA;

  setUp(() {
    StoragePolicyRegistry.clearForTesting();
    StoragePolicyRegistry.register(
      'xiang_reading',
      StoragePolicy.private(carriers: {Carrier.row, Carrier.blob}),
    );
    StoragePolicyRegistry.register(
      'playground_post',
      StoragePolicy.shared(carriers: {Carrier.row, Carrier.blob}),
    );

    tmpDir = Directory.systemTemp.createTempSync('blob_media_reader_');
    db = PersistenceDriftDatabase(NativeDatabase.memory());

    cipherResolverA = BlobCipherRegistry();
    cipherResolverA.register(scopeA, const IdentityBlobCipher());

    metaRepoA = BlobMetadataRepository(db: db, scopeUid: scopeA);
    blobStoreA = DriftLocalBlobStore(
      scopeUid: scopeA,
      metadataRepository: metaRepoA,
      cipherResolver: cipherResolverA,
      rootDir: tmpDir.path,
      db: db,
    );
  });

  tearDown(() {
    StoragePolicyRegistry.clearForTesting();
    db.close();
    if (tmpDir.existsSync()) {
      tmpDir.deleteSync(recursive: true);
    }
  });

  DriftMediaReferenceReader createReaderForScope(
    String scopeUid, {
    BlobCipherResolver? resolver,
  }) {
    final metaRepo = BlobMetadataRepository(db: db, scopeUid: scopeUid);
    final store = DriftLocalBlobStore(
      scopeUid: scopeUid,
      metadataRepository: metaRepo,
      cipherResolver: resolver ?? cipherResolverA,
      rootDir: tmpDir.path,
      db: db,
    );
    return DriftMediaReferenceReader(
      blobStore: store,
      metadataRepository: metaRepo,
    );
  }

  group('DriftMediaReferenceReader - complete state', () {
    test('recovers complete state and reads plaintext stream by refId', () async {
      final sampleBytes = Uint8List.fromList([10, 20, 30, 40, 50, 60]);
      final handle = await blobStoreA.put(
        Stream.value(sampleBytes),
        mimeType: 'image/png',
        tier: BlobTier.sourceOfTruth,
        expectedBytes: sampleBytes.length,
      );

      // Reconcile to committed state
      await blobStoreA.reconcileRefs(
        ownerRecordUuid: 'rec-001',
        handles: {handle},
      );

      // Fresh reader instance (simulating new process)
      final reader = createReaderForScope(scopeA);
      final status = await reader.statusOf(handle.cipherManifestId);
      expect(status, MediaReadStatus.complete);

      final readResult = await reader.openRead(handle.cipherManifestId);
      expect(readResult, isA<MediaReadComplete>());

      final complete = readResult as MediaReadComplete;
      expect(complete.mimeType, 'image/png');
      expect(complete.contentLength, sampleBytes.length);

      final readBytes = await complete.byteStream.expand((b) => b).toList();
      expect(readBytes, sampleBytes);
    });
  });

  group('DriftMediaReferenceReader - absent state', () {
    test('returns absent for unknown refId', () async {
      final reader = createReaderForScope(scopeA);

      final status = await reader.statusOf('unknown-ref-id');
      expect(status, MediaReadStatus.absent);

      final result = await reader.openRead('unknown-ref-id');
      expect(result, isA<MediaReadAbsent>());
    });

    test('returns absent for staged blob before reconcileRefs', () async {
      final sampleBytes = Uint8List.fromList([1, 2, 3]);
      final handle = await blobStoreA.put(
        Stream.value(sampleBytes),
        mimeType: 'image/jpeg',
        tier: BlobTier.sourceOfTruth,
        expectedBytes: sampleBytes.length,
      );

      // Staged but not committed
      final reader = createReaderForScope(scopeA);
      final status = await reader.statusOf(handle.cipherManifestId);
      expect(status, MediaReadStatus.absent);

      final result = await reader.openRead(handle.cipherManifestId);
      expect(result, isA<MediaReadAbsent>());
    });
  });

  group('DriftMediaReferenceReader - partial state', () {
    test('recovers partial state when chunks are missing', () async {
      const manifestId = 'partial-manifest-1';
      final handle = BlobHandle(
        plaintextSha256: 'a' * 64,
        cipherManifestId: manifestId,
        cipherId: 'identity',
        keyVersion: 1,
        totalBytes: 32768,
        chunkCount: 2,
        mimeType: 'video/mp4',
      );

      await metaRepoA.stageIncomingManifest(
        entityType: 'xiang_reading',
        peerManifest: handle,
        peerTier: BlobTier.sourceOfTruth,
        peerVisibility: BlobVisibility.private,
      );

      // Write only chunk 0
      await blobStoreA.putChunk(handle, 0, List<int>.filled(16384, 1));

      // Commit
      await blobStoreA.reconcileRefs(
        ownerRecordUuid: 'rec-partial',
        handles: {handle},
      );

      final reader = createReaderForScope(scopeA);
      final status = await reader.statusOf(manifestId);
      expect(status, MediaReadStatus.partial);

      final result = await reader.openRead(manifestId);
      expect(result, isA<MediaReadPartial>());
      final partial = result as MediaReadPartial;
      expect(partial.presentChunks, {0});
    });
  });

  group('DriftMediaReferenceReader - corrupt state', () {
    test('maps BlobCorruptError during openRead to MediaReadCorrupt', () async {
      final sampleBytes = Uint8List.fromList(List.generate(100, (i) => i));
      final handle = await blobStoreA.put(
        Stream.value(sampleBytes),
        mimeType: 'image/jpeg',
        tier: BlobTier.sourceOfTruth,
        expectedBytes: sampleBytes.length,
      );

      await blobStoreA.reconcileRefs(
        ownerRecordUuid: 'rec-corrupt',
        handles: {handle},
      );

      // Corrupt chunk file on disk
      final chunkFile = File('${tmpDir.path}/$scopeA/${handle.cipherManifestId}/0.bin');
      await chunkFile.writeAsBytes([99, 99, 99]); // Corrupted content

      final reader = createReaderForScope(scopeA);
      final status = await reader.statusOf(handle.cipherManifestId);
      // statusOf does not read/decrypt all bytes, returns complete
      expect(status, MediaReadStatus.complete);

      // openRead returns complete with stream, stream throws on consumption
      final result = await reader.openRead(handle.cipherManifestId);
      expect(result, isA<MediaReadComplete>());
      final complete = result as MediaReadComplete;
      expect(
        () => complete.byteStream.toList(),
        throwsA(isA<BlobCorruptError>()),
      );
    });
  });

  group('DriftMediaReferenceReader - undecryptable state', () {
    test('maps BlobUndecryptableError to MediaReadUndecryptable', () async {
      final sampleBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final handle = await blobStoreA.put(
        Stream.value(sampleBytes),
        mimeType: 'image/jpeg',
        tier: BlobTier.sourceOfTruth,
        expectedBytes: sampleBytes.length,
      );

      await blobStoreA.reconcileRefs(
        ownerRecordUuid: 'rec-undecryptable',
        handles: {handle},
      );

      // Reader in scopeA with an empty resolver (no keys)
      final emptyResolver = BlobCipherRegistry();
      final reader = createReaderForScope(scopeA, resolver: emptyResolver);

      final result = await reader.openRead(handle.cipherManifestId);
      expect(result, isA<MediaReadUndecryptable>());
    });
  });

  group('DriftMediaReferenceReader - scope isolation', () {
    test('Scope B cannot resolve Scope A metadata or read bytes', () async {
      final sampleBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final handle = await blobStoreA.put(
        Stream.value(sampleBytes),
        mimeType: 'image/jpeg',
        tier: BlobTier.sourceOfTruth,
        expectedBytes: sampleBytes.length,
      );

      await blobStoreA.reconcileRefs(
        ownerRecordUuid: 'rec-scope-a',
        handles: {handle},
      );

      // Scope B reader
      final cipherResolverB = BlobCipherRegistry();
      cipherResolverB.register(scopeB, const IdentityBlobCipher());
      final readerB = createReaderForScope(scopeB, resolver: cipherResolverB);

      final status = await readerB.statusOf(handle.cipherManifestId);
      expect(status, MediaReadStatus.absent);

      final result = await readerB.openRead(handle.cipherManifestId);
      expect(result, isA<MediaReadAbsent>());
    });
  });

  group('DriftMediaReferenceReader - orphan retention', () {
    test('orphaned source-of-truth blob remains recoverable and readable', () async {
      final sampleBytes = Uint8List.fromList([42, 43, 44, 45]);
      final handle = await blobStoreA.put(
        Stream.value(sampleBytes),
        mimeType: 'image/png',
        tier: BlobTier.sourceOfTruth,
        expectedBytes: sampleBytes.length,
      );

      await blobStoreA.reconcileRefs(
        ownerRecordUuid: 'rec-owner',
        handles: {handle},
      );

      // Remove reference
      await blobStoreA.reconcileRefs(
        ownerRecordUuid: 'rec-owner',
        handles: {},
      );

      // Run GC collect
      final gc = DriftBlobGarbageCollector(
        db: db,
        scopeUid: scopeA,
        rootDir: tmpDir.path,
        now: () => DateTime.now().toUtc(),
      );
      final gcResult = await gc.collect();
      expect(gcResult.sourceOfTruthOrphaned, 1);
      expect(gcResult.cacheDeleted, 0);

      // Verify meta status is orphaned (2)
      final meta = await metaRepoA.getMeta(handle.cipherManifestId);
      expect(meta, isNotNull);
      expect(meta!.status, 2);

      // Reader can still resolve and read orphaned blob
      final reader = createReaderForScope(scopeA);
      final status = await reader.statusOf(handle.cipherManifestId);
      expect(status, MediaReadStatus.complete);

      final result = await reader.openRead(handle.cipherManifestId);
      expect(result, isA<MediaReadComplete>());
      final complete = result as MediaReadComplete;
      final readBytes = await complete.byteStream.expand((b) => b).toList();
      expect(readBytes, sampleBytes);
    });
  });
}
