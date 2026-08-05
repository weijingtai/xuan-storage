/// 内存实现的 RecordBlobUnitOfWork fake。
///
/// 用于测试，不依赖 Drift 数据库。
library;

import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

/// In-memory fake of [RecordBlobUnitOfWork].
///
/// Stores records and blob refs in memory.
/// Uses a simple lock to simulate transaction atomicity.
final class InMemoryRecordBlobUnitOfWork implements RecordBlobUnitOfWork {
  final Map<String, RecordMeta> _records = {};
  final Map<String, Set<BlobHandle>> _refs = {};
  bool _locked = false;

  /// Returns all stored records (for test assertions).
  Map<String, RecordMeta> get records => Map.unmodifiable(_records);

  /// Returns all stored blob refs (for test assertions).
  Map<String, Set<BlobHandle>> get refs =>
      _refs.map((k, v) => MapEntry(k, Set.unmodifiable(v)));

  @override
  Future<void> saveWithBlobs({
    required RecordMeta record,
    required Set<BlobHandle> referencedBlobs,
  }) async {
    if (_locked) throw StateError('Transaction conflict');
    _locked = true;
    try {
      _records[record.uuid] = record;
      _refs[record.uuid] = Set.of(referencedBlobs);
    } finally {
      _locked = false;
    }
  }

  @override
  Future<void> deleteWithBlobs(String recordUuid) async {
    if (_locked) throw StateError('Transaction conflict');
    _locked = true;
    try {
      _records.remove(recordUuid);
      _refs.remove(recordUuid);
    } finally {
      _locked = false;
    }
  }
}