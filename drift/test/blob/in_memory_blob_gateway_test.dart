/// Tests for InMemoryBlobGateway.
///
/// Verifies:
/// - beginUpload with private/public naming
/// - Out-of-order and repeated chunk writes
/// - remoteChunks for resume
/// - completeUpload gating (incomplete not downloadable)
/// - Fresh download ticket per call
/// - deleteObject
/// - getCapabilities
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/blob/in_memory_blob_gateway.dart';

void main() {
  late InMemoryBlobGateway gateway;
  int uuidCounter = 0;

  setUp(() {
    uuidCounter = 0;
    gateway = InMemoryBlobGateway(
      now: () => DateTime.utc(2026, 8, 4, 12, 0),
      generateUuid: () {
        uuidCounter++;
        return 'uuid-$uuidCounter';
      },
    );
  });

  BlobHandle makeHandle(String manifestId) {
    return BlobHandle(
      plaintextSha256: manifestId * 64,
      cipherManifestId: manifestId,
      cipherId: 'identity',
      keyVersion: 1,
      totalBytes: 100,
      chunkCount: 2,
      mimeType: 'x/test',
    );
  }

  group('beginUpload', () {
    test('private visibility generates random UUID object name', () async {
      final ticket = await gateway.beginUpload(
        scopeUid: 'scope-a',
        handle: makeHandle('m1'),
        visibility: BlobVisibility.private,
      );
      expect(ticket.objectName, 'uuid-1');
      expect(ticket.expiresAtUtc, DateTime.utc(2026, 8, 4, 13, 0));
    });

    test('public visibility uses plaintextSha256 as object name', () async {
      final ticket = await gateway.beginUpload(
        scopeUid: 'scope-a',
        handle: makeHandle('m1'),
        visibility: BlobVisibility.public,
      );
      expect(ticket.objectName, 'm1' * 64);
    });
  });

  group('chunk upload', () {
    test('out-of-order chunk writes are accepted', () async {
      final ticket = await gateway.beginUpload(
        scopeUid: 'scope-a',
        handle: makeHandle('m1'),
        visibility: BlobVisibility.public,
      );

      await gateway.putChunk(ticket: ticket, index: 1, cipherBytes: [4, 5, 6]);
      await gateway.putChunk(ticket: ticket, index: 0, cipherBytes: [1, 2, 3]);

      final chunks = await gateway.remoteChunks(ticket);
      expect(chunks, {0, 1});
    });

    test('repeated chunk writes are idempotent', () async {
      final ticket = await gateway.beginUpload(
        scopeUid: 'scope-a',
        handle: makeHandle('m1'),
        visibility: BlobVisibility.public,
      );

      await gateway.putChunk(ticket: ticket, index: 0, cipherBytes: [1, 2, 3]);
      await gateway.putChunk(ticket: ticket, index: 0, cipherBytes: [4, 5, 6]);

      final chunks = await gateway.remoteChunks(ticket);
      expect(chunks, {0});
    });
  });

  group('complete gating', () {
    test('incomplete upload cannot be downloaded', () async {
      final ticket = await gateway.beginUpload(
        scopeUid: 'scope-a',
        handle: makeHandle('m1'),
        visibility: BlobVisibility.public,
      );

      await gateway.putChunk(ticket: ticket, index: 0, cipherBytes: [1]);

      final handle = makeHandle(ticket.objectName);
      await expectLater(
        gateway.getDownloadTicket(handle),
        throwsA(isA<BlobNotFoundError>()),
        reason: '未 complete 的上传不可下载',
      );
    });

    test('completed upload becomes downloadable', () async {
      final ticket = await gateway.beginUpload(
        scopeUid: 'scope-a',
        handle: makeHandle('m1'),
        visibility: BlobVisibility.public,
      );

      await gateway.putChunk(ticket: ticket, index: 0, cipherBytes: [1]);
      await gateway.completeUpload(ticket);

      final downloadTicket = await gateway.getDownloadTicket(makeHandle(ticket.objectName));
      expect(downloadTicket.url, contains(ticket.objectName));
      expect(downloadTicket.expiresAtUtc, DateTime.utc(2026, 8, 4, 12, 5));
    });

    test('fresh download ticket per call', () async {
      final ticket = await gateway.beginUpload(
        scopeUid: 'scope-a',
        handle: makeHandle('m1'),
        visibility: BlobVisibility.public,
      );
      await gateway.completeUpload(ticket);

      final t1 = await gateway.getDownloadTicket(makeHandle(ticket.objectName));
      final t2 = await gateway.getDownloadTicket(makeHandle(ticket.objectName));
      expect(t1.url, isNot(t2.url), reason: '每次调用应返回不同票据');
    });
  });

  group('delete', () {
    test('deleteObject removes upload', () async {
      final ticket = await gateway.beginUpload(
        scopeUid: 'scope-a',
        handle: makeHandle('m1'),
        visibility: BlobVisibility.public,
      );
      await gateway.completeUpload(ticket);

      await gateway.deleteObject(makeHandle(ticket.objectName));

      await expectLater(
        gateway.getDownloadTicket(makeHandle(ticket.objectName)),
        throwsA(isA<BlobNotFoundError>()),
        reason: '删除后不可下载',
      );
    });
  });

  group('capabilities', () {
    test('getCapabilities returns resumable support', () async {
      final caps = await gateway.getCapabilities();
      expect(caps.supportsResumable, isTrue);
      expect(caps.maxChunkBytes, 16384);
      expect(caps.requestTimeout, const Duration(seconds: 30));
    });
  });
}