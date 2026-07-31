import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';
import 'firebase_playground_schema.dart';

/// 从 Firebase Auth session 解析 actor [PlaygroundUserId]。
///
/// 复用现有 identity_map/{providerUserId} → appUserId 模式。
/// 不信任客户端传入的 authorId/posterId/appUserId。
final class FirebasePlaygroundIdentityResolver {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebasePlaygroundIdentityResolver({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  /// 从当前认证 session 解析展示用 [PlaygroundUserId]。
  ///
  /// 流程：
  /// 1. 从 FirebaseAuth.currentUser 获取 uid（providerUserId）
  /// 2. 读取 identity_map/{uid} → 获取 appUserId
  /// 3. 若映射不存在，在事务中原子创建（UUID v4 → appUserId）
  /// 4. 返回 PlaygroundUserId(appUserId)
  ///
  /// 抛出 [PlaygroundError.unauthenticated] 当用户未登录。
  Future<PlaygroundUserId> resolveActor() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const PlaygroundError(
        code: PlaygroundErrorCode.unauthenticated,
        message: '未登录，请先注册或匿名登录',
        machineCode: 'auth/unauthenticated',
      );
    }
    final providerUserId = user.uid;
    final doc =
        _firestore.collection(PlaygroundFirestoreSchema.identityMap).doc(providerUserId);

    final appUserId = await _firestore.runTransaction<String>((tx) async {
      final snap = await tx.get(doc);
      if (snap.exists) {
        return snap.get('app_user_id') as String;
      }
      final newAppUserId = _generateAppUserId();
      tx.set(doc, {
        'app_user_id': newAppUserId,
        'provider_uid': providerUserId,
        'provider_id': 'firebase',
        'created_at': FieldValue.serverTimestamp(),
      });
      return newAppUserId;
    });

    return PlaygroundUserId(appUserId);
  }

  /// 校验请求中的 actor 是否与当前 session 一致。
  /// 用于 Functions 侧二次验证；adapter 中用于调试断言。
  bool isActor(PlaygroundUserId userId) {
    return _auth.currentUser?.uid == userId.value;
  }

  /// 生成 UUID v4 风格的 appUserId。
  String _generateAppUserId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final random = (now * 1103515245 + 12345) & 0x7fffffff;
    return 'app-${now.toRadixString(36)}-${random.toRadixString(36)}';
  }
}
