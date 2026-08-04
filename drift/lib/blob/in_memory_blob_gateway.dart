/// 契约完整的内存 BlobGateway fake。
///
/// 用于测试，不依赖任何远端 SDK。
library;

import 'package:persistence_core/persistence_core.dart';

/// 内存 BlobGateway fake。
///
/// 特性：
/// - 可注入的时钟和 UUID 生成器
/// - 乱序/repeated chunk 写入
/// - complete gating：未 complete 的 upload 不可下载
/// - 每次 getDownloadTicket 返回不同票据
final class InMemoryBlobGateway implements BlobGateway {
  InMemoryBlobGateway({
    required DateTime Function() now,
    required String Function() generateUuid,
  })  : _now = now,
        _uuid = generateUuid;

  final DateTime Function() _now;
  final String Function() _uuid;

  /// 上传跟踪：objectName → chunks + completed flag
  final Map<String, Map<int, List<int>>> _chunks = {};
  final Set<String> _completed = {};

  @override
  Future<BlobUploadTicket> beginUpload({
    required String scopeUid,
    required BlobHandle handle,
    required BlobVisibility visibility,
  }) async {
    final objectName = visibility == BlobVisibility.private
        ? _uuid()
        : handle.plaintextSha256;
    _chunks[objectName] = {};
    return BlobUploadTicket(
      objectName: objectName,
      expiresAtUtc: _now().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<void> putChunk({
    required BlobUploadTicket ticket,
    required int index,
    required List<int> cipherBytes,
    CancellationToken? cancel,
  }) async {
    final state = _chunks[ticket.objectName];
    if (state == null) throw BlobNotFoundError();
    state[index] = List<int>.from(cipherBytes);
  }

  @override
  Future<void> completeUpload(BlobUploadTicket ticket) async {
    if (!_chunks.containsKey(ticket.objectName)) {
      throw BlobNotFoundError();
    }
    _completed.add(ticket.objectName);
  }

  @override
  Future<Set<int>> remoteChunks(BlobUploadTicket ticket) async {
    final state = _chunks[ticket.objectName];
    if (state == null) return {};
    return Set.of(state.keys);
  }

  @override
  Future<BlobDownloadTicket> getDownloadTicket(BlobHandle handle) async {
    // 禁止从未 complete 的上传获取下载票据
    if (!_completed.contains(handle.cipherManifestId)) {
      throw BlobNotFoundError();
    }
    // 每次返回新票据
    return BlobDownloadTicket(
      url: 'https://fake.storage/${handle.cipherManifestId}?ticket=${_uuid()}',
      expiresAtUtc: _now().add(const Duration(minutes: 5)),
    );
  }

  @override
  Future<void> deleteObject(BlobHandle handle) async {
    _chunks.remove(handle.cipherManifestId);
    _completed.remove(handle.cipherManifestId);
  }

  @override
  Future<BlobGatewayCapabilities> getCapabilities() async {
    return const BlobGatewayCapabilities(
      maxChunkBytes: 16384,
      requestTimeout: Duration(seconds: 30),
      supportsResumable: true,
    );
  }
}