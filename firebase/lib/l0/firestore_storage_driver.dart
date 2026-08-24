import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';

/// Firestore 实现的 [StorageDriver]。
///
/// 严格遵守 L0 契约：
/// - [supportsTransaction] 返回 false，[inTransaction] 退化为直接执行 body；
/// - 版本冲突抛 [StorageRevMismatch]（由 Base 转成 `conflict.version`）；
/// - 唯一键冲突抛 [StorageUniqueViolation]（由 Base 转成 `conflict.unique`）；
/// - 跨 scope 写/删抛 [StorageScopeViolation]（由 Base 转成 `permission_denied`）；
/// - [watchMany] 首帧必须立即产出当前快照（C14 判据）。
class FirestoreStorageDriver implements StorageDriver {
  /// 构造函数。
  ///
  /// [firestore] 为 Firestore 实例（可以是真实例或 FakeFirebaseFirestore）；
  /// [scopeUid] 为当前 scope 标识。
  FirestoreStorageDriver({
    required FirebaseFirestore firestore,
    required String scopeUid,
  })  : _firestore = firestore,
        _scopeUid = scopeUid;

  final FirebaseFirestore _firestore;
  final String _scopeUid;

  /// 获取 resource 对应的集合引用。
  CollectionReference<Map<String, Object?>> _col(String resource) =>
      _firestore.collection(resource);

  /// 检查行是否匹配过滤条件。
  bool _matches(Map<String, Object?> row, RawFilter f) {
    if (row['scope_uid'] != f.scopeUid) return false;
    if (!f.includeSoftDeleted && row['deleted_at'] != null) return false;
    for (final e in f.equals.entries) {
      if (row[e.key] != e.value) return false;
    }
    return true;
  }

  /// 把一行编码成游标。格式是本 driver 的私事。
  String _encodeCursor(Map<String, Object?> row) => 'id:${row['id']}';

  /// 解释游标，返回文档 ID。
  String? _decodeCursor(String cursor) =>
      cursor.startsWith('id:') ? cursor.substring(3) : null;

  @override
  bool get supportsTransaction => false;

  /// Firestore 是云端后端，属于云端 adapter。
  @override
  bool get isCloudBacked => true;

  @override
  Future<R> inTransaction<R>(Future<R> Function() body) => body();

  @override
  Future<Map<String, Object?>?> readOne(
      String resource, Object id, RawFilter filter) async {
    final doc = await _col(resource).doc(id.toString()).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    if (!_matches(data, filter)) return null;
    return data;
  }

  @override
  Future<List<Map<String, Object?>>> readMany(
      String resource, RawFilter filter, RawPage page) async {
    Query<Map<String, Object?>> query = _col(resource);

    // 添加 scope 过滤
    query = query.where('scope_uid', isEqualTo: filter.scopeUid);

    // 添加软删过滤
    if (!filter.includeSoftDeleted) {
      query = query.where('deleted_at', isNull: true);
    }

    // 添加 equals 等值条件
    for (final entry in filter.equals.entries) {
      query = query.where(entry.key, isEqualTo: entry.value);
    }

    // 添加排序
    for (final order in page.orderBy) {
      query = query.orderBy(order.field, descending: order.desc);
    }

    // 添加游标
    if (page.cursor != null) {
      final cursorId = _decodeCursor(page.cursor!);
      if (cursorId != null) {
        final cursorDoc = await _col(resource).doc(cursorId).get();
        if (cursorDoc.exists) {
          query = query.startAfterDocument(cursorDoc);
        }
      }
    }

    // 添加限制
    query = query.limit(page.limit);

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<int> count(String resource, RawFilter filter) async {
    // 使用与 readMany 相同的口径
    Query<Map<String, Object?>> query = _col(resource);

    // 添加 scope 过滤
    query = query.where('scope_uid', isEqualTo: filter.scopeUid);

    // 添加软删过滤
    if (!filter.includeSoftDeleted) {
      query = query.where('deleted_at', isNull: true);
    }

    // 添加 equals 等值条件
    for (final entry in filter.equals.entries) {
      query = query.where(entry.key, isEqualTo: entry.value);
    }

    final snapshot = await query.get();
    return snapshot.size;
  }

  @override
  Future<String> write(
    String resource,
    Object id,
    Map<String, Object?> data, {
    String? expectedRev,
  }) async {
    // 检查 scope
    final targetScope = data['scope_uid'] as String?;
    if (targetScope == null || targetScope != _scopeUid) {
      throw const StorageScopeViolation();
    }

    final ref = _col(resource).doc(id.toString());
    final snap = await ref.get();

    // 乐观锁检查
    if (expectedRev != null) {
      final currentRev = snap.data()?['_rev'] as String?;
      if (currentRev != expectedRev) {
        throw StorageRevMismatch(currentRev ?? '');
      }
    }

    // 生成新版本号（确定性：读到的 rev 解析为整数 + 1，缺失则从 '1' 起）
    final currentRevStr = snap.data()?['_rev'] as String?;
    final nextRev = currentRevStr != null
        ? '${int.parse(currentRevStr) + 1}'
        : '1';

    // 写入数据
    await ref.set({...data, '_rev': nextRev}, SetOptions(merge: false));

    return nextRev;
  }

  @override
  Future<void> deleteOne(String resource, Object id, RawFilter filter) async {
    final ref = _col(resource).doc(id.toString());
    final snap = await ref.get();

    if (!snap.exists) return;

    final data = snap.data();
    if (data == null) return;

    // 检查 scope
    if (data['scope_uid'] != filter.scopeUid) {
      throw const StorageScopeViolation();
    }

    // 物理删除
    await ref.delete();
  }

  @override
  Stream<List<Map<String, Object?>>> watchMany(
      String resource, RawFilter filter, RawPage page) async* {
    // 首帧立即产出当前快照（C14 判据）
    yield await readMany(resource, filter, page);

    // 监听后续变化
    Query<Map<String, Object?>> query = _col(resource);

    // 添加 scope 过滤
    query = query.where('scope_uid', isEqualTo: filter.scopeUid);

    // 添加软删过滤
    if (!filter.includeSoftDeleted) {
      query = query.where('deleted_at', isNull: true);
    }

    // 添加 equals 等值条件
    for (final entry in filter.equals.entries) {
      query = query.where(entry.key, isEqualTo: entry.value);
    }

    // 添加排序
    for (final order in page.orderBy) {
      query = query.orderBy(order.field, descending: order.desc);
    }

    // 添加限制
    query = query.limit(page.limit);

    // 监听快照变化
    yield* query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }
}
