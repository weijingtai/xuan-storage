import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:repository_interface_xiang/repository_interface_xiang.dart';
import '../record/base_record_backed_repository.dart';
import 'xiang_deletion_audit_event.dart';

/// Concrete instantiation of the abstract [BaseRecordBackedRepository] for
/// [XiangReading], used internally by [XiangReadingRepositoryImpl] so that
/// every write flows through the unified [ScopedRecordStore].
class _XiangReadingStore extends BaseRecordBackedRepository<XiangReading> {
  _XiangReadingStore({
    required super.store,
    required super.codec,
  });
}

/// Drift-backed [XiangReadingRepository] built on the shared
/// [BaseRecordBackedRepository] and the one shared [XiangRecordCodec]
/// (TDD-XG-07: one repository and one codec serve every Xiang method).
///
/// This adapter deliberately keeps no Xiang-private record list: every read
/// and write flows through the unified [ScopedRecordStore], and [softDelete]
/// marks the shared Record deleted so a later [load] returns null
/// (governance, TDD-XG-09).
///
/// The port's `save` returns the persisted [XiangReading] while the base
/// returns the record uuid, so this adapter composes (not extends) the base
/// and maps between the two shapes. `load` additionally honours the port
/// contract that a soft-deleted record reads as absent: the base `getByUuid`
/// returns decoded metadata regardless of `deletedAt`, so the adapter checks
/// the shared Record's `deletedAt` before decoding.
class XiangReadingRepositoryImpl implements XiangReadingRepository {
  XiangReadingRepositoryImpl({
    required ScopedRecordStore store,
    required RecordModuleCodec<XiangReading> codec,
  })  : _store = store,
        _codec = codec,
        _delegate = _XiangReadingStore(store: store, codec: codec);

  final ScopedRecordStore _store;
  final RecordModuleCodec<XiangReading> _codec;
  final BaseRecordBackedRepository<XiangReading> _delegate;

  /// 删除审计日志（FA12）：只含操作/时间/操作者/媒体引用计数，无敏感内容。
  final List<XiangDeletionAuditEvent> auditLogs = [];

  String get _module => _codec.module;

  @override
  Future<XiangReading> save(XiangReading reading) async {
    final savedUuid = await _delegate.save(reading);
    // When the aggregate carried no uuid the base generates one; surface the
    // effective uuid on the returned reading.
    if (reading.uuid.isNotEmpty) return reading;
    return reading.copyWith(uuid: savedUuid);
  }

  @override
  Future<XiangReading?> load(String uuid) async {
    final meta = await _store.getRecord(uuid, module: _module);
    if (meta == null || meta.deletedAt != null) return null;
    return _codec.decode(meta, null);
  }

  @override
  Future<void> softDelete(String uuid) async {
    // FA12 单一方针：删除级联清除媒体。删除前统计该记录引用的媒体数，
    // 删除后记录审计事件（操作/时间/操作者/媒体引用计数，不记敏感内容本身）。
    final meta = await _store.getRecord(uuid, module: _module);
    var mediaRefCount = 0;
    if (meta != null && meta.deletedAt == null) {
      final reading = _codec.decode(meta, null);
      mediaRefCount = reading.evidence.where((e) => e.mediaRef != null).length;
    }
    await _delegate.softDelete(uuid);
    auditLogs.add(XiangDeletionAuditEvent(
      operation: 'reading.delete',
      recordedAt: DateTime.now().toUtc(),
      operatorUid: _store.scopeUid,
      mediaRefCount: mediaRefCount,
    ));
  }
}
