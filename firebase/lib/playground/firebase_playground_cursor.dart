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
