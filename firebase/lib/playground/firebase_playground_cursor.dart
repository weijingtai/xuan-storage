import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

/// 将 Firestore DocumentSnapshot/QueryDocumentSnapshot 封装为 opaque [PlaygroundCursor]。
///
/// 业务层只能存储和回传 cursor，不得解析 token 格式。
final class FirebasePlaygroundCursor {
  FirebasePlaygroundCursor._();

  /// 从 Firestore DocumentSnapshot 构造 opaque cursor。
  static PlaygroundCursor fromDocument(DocumentSnapshot doc) {
    if (!doc.exists) return PlaygroundCursor.empty;
    final payload = {'path': doc.reference.path};
    final token = base64Encode(utf8.encode(jsonEncode(payload)));
    return PlaygroundCursor(token);
  }

  /// 从 Firestore QueryDocumentSnapshot 构造 opaque cursor（用于分页）。
  static PlaygroundCursor fromQueryDocument(QueryDocumentSnapshot doc) {
    final payload = {'path': doc.reference.path};
    final token = base64Encode(utf8.encode(jsonEncode(payload)));
    return PlaygroundCursor(token);
  }

  /// 从 QueryDocumentSnapshot + orderBy 字段构造 opaque cursor。
  ///
  /// 编码排序字段值（而非仅 path）：`startAfterDocument` 要求 snapshot 来自
  /// 相同查询（fake_cloud_firestore 与部分场景不可靠），`startAfter(values)`
  /// 双端稳定。cursor 对业务层仍是不透明 token。
  static PlaygroundCursor fromQueryDocumentWithOrderBy(
    QueryDocumentSnapshot doc,
    List<String> orderByFields,
  ) {
    final values = <dynamic>[];
    for (final f in orderByFields) {
      final v = doc.get(f);
      values.add(v is Timestamp ? v.toDate().toIso8601String() : v);
    }
    final payload = {'path': doc.reference.path, 'values': values};
    final token = base64Encode(utf8.encode(jsonEncode(payload)));
    return PlaygroundCursor(token);
  }

  /// 从 opaque cursor 解码 orderBy 值数组（用于 `startAfter(values)`）。
  ///
  /// 返回 null 若 cursor 为空、格式无效或不含 values（旧 path-only token）。
  static List<dynamic>? toStartAfterValues(PlaygroundCursor cursor) {
    if (cursor.isEmpty) return null;
    try {
      final jsonStr = utf8.decode(base64Decode(cursor.token));
      final payload = jsonDecode(jsonStr) as Map<String, dynamic>;
      final values = payload['values'];
      if (values is! List || values.isEmpty) return null;
      return values
          .map((v) =>
              v is String ? (DateTime.tryParse(v) != null ? Timestamp.fromDate(DateTime.parse(v)) : v) : v)
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// 从 cursor 恢复 DocumentReference（用于 startAfterDocument 分页）。
  ///
  /// 返回 null 若 cursor 为空或格式无效。
  static DocumentReference<Map<String, dynamic>>? toDocumentReference(
    PlaygroundCursor cursor,
    FirebaseFirestore firestore,
  ) {
    if (cursor.isEmpty) return null;
    try {
      final jsonStr = utf8.decode(base64Decode(cursor.token));
      final payload = jsonDecode(jsonStr) as Map<String, dynamic>;
      final path = payload['path'] as String;
      return firestore.doc(path);
    } catch (_) {
      return null;
    }
  }
}
