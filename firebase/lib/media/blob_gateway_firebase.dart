/// BlobGateway 的 firebase 占位实现（S2 Phase 5）。
///
/// ⚠ **真云端实现未交付**（Phase 0 审计确认：全仓库无 firebase/supabase
/// 真实现）。本类为内存 fake，仅用于打通「BlobGateway 接口 + 契约全绿」，
/// 语义与 `drift` 包的 `InMemoryBlobGateway` 一致。真云端落地后替换本文件。
///
/// 行为：
/// - `beginUpload`：public → objectName = plaintextSha256；private → UUID。
/// - `putChunk`：乱序/重复写入按 index 覆盖。
/// - `completeUpload`：未 beginUpload 的对象抛 [BlobNotFoundError]。
/// - `getDownloadTicket`：每次调用返回新票据（不缓存，支撑紧急下架语义）。
library;

import 'package:meta/meta.dart';
import 'package:persistence_core/persistence_core.dart';

/// 内存 BlobGateway fake（@visibleForTesting：仅测试与未交付期接线用）。
@visibleForTesting
final class InMemoryFirebaseBlobGateway implements BlobGateway {
  InMemoryFirebaseBlobGateway();

  /// objectName → (index → bytes)。
  final Map<String, Map<int, List<int>>> _chunks = {};

  /// 已上传的全部 chunk 字节（按 index 归位拼接），供测试断言
  /// 「上传路径上的真实字节流」。
  List<int> uploadedBytes(String objectName) {
    final state = _chunks[objectName];
    if (state == null) return const [];
    final maxIndex = state.keys.isEmpty ? 0 : state.keys.reduce((a, b) => a > b ? a : b);
    final out = <int>[];
    for (var i = 0; i <= maxIndex; i++) {
      out.addAll(state[i] ?? const []);
    }
    return out;
  }
  final Set<String> _completed = {};
  int _ticketCounter = 0;

  @override
  Future<BlobGatewayCapabilities> getCapabilities() async {
    return const BlobGatewayCapabilities(
      maxChunkBytes: 256 * 1024,
      requestTimeout: Duration(seconds: 30),
      supportsResumable: true,
    );
  }

  @override
  Future<BlobUploadTicket> beginUpload({
    required String scopeUid,
    required BlobHandle handle,
    required BlobVisibility visibility,
  }) async {
    final objectName = visibility == BlobVisibility.private
        ? 'uuid-$scopeUid-${_ticketCounter++}'
        : handle.plaintextSha256;
    _chunks[objectName] = {};
    return BlobUploadTicket(
      objectName: objectName,
      expiresAtUtc: DateTime.now().add(const Duration(hours: 1)),
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
    if (state == null) throw BlobNotFoundError();
    return state.keys.toSet();
  }

  @override
  Future<BlobDownloadTicket> getDownloadTicket(BlobHandle handle) async {
    // 每次调用新票据（不缓存）。
    return BlobDownloadTicket(
      url: 'https://fake.blob/${handle.cipherManifestId}?t=${_ticketCounter++}',
      expiresAtUtc: DateTime.now().add(const Duration(minutes: 2)),
    );
  }

  @override
  Future<void> deleteObject(BlobHandle handle) async {
    _chunks.remove(handle.cipherManifestId);
    _chunks.remove(handle.plaintextSha256);
    _completed.remove(handle.cipherManifestId);
    _completed.remove(handle.plaintextSha256);
  }
}
