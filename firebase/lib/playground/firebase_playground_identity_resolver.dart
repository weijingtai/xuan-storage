import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';
import 'firebase_playground_error_mapper.dart';

/// 从 Firebase Auth session 解析 actor [PlaygroundUserId]。
///
/// 直读 Firestore identity_map（不通过 callable），读取：
/// - `app_user_id`（snake_case，兼容 `appUserId`）
/// - `public_presentation_id`
/// - `public_display_alias`
///
/// 缺 `public_presentation_id` 或 `public_display_alias` → fail closed
/// 抛出 PlaygroundErrorCode.unavailable + machineCode identity/not-ready。
///
/// Playground 不创建 identity_map。
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
  /// 直读 Firestore `identity_map/{providerUid}`，不通过 callable。
  Future<PlaygroundUserId> resolveActor() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const PlaygroundError(
          code: PlaygroundErrorCode.unauthenticated,
          message: '未登录，请先注册或匿名登录',
          machineCode: 'auth/unauthenticated',
        );
      }

      final doc = await _firestore
          .collection('identity_map')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        throw const PlaygroundError(
          code: PlaygroundErrorCode.unavailable,
          message: '身份映射不存在，请完成账号初始化',
          machineCode: 'identity/not-ready',
        );
      }

      final data = doc.data()!;
      final appUserId = _readAppUserId(data);
      final presentationId = (data['public_presentation_id'] as String?) ??
          (data['presentation_identity_id'] as String?);
      final displayAlias = (data['public_display_alias'] as String?) ??
          (data['display_alias'] as String?);

      if (appUserId == null ||
          presentationId == null || presentationId.isEmpty ||
          displayAlias == null || displayAlias.isEmpty) {
        throw const PlaygroundError(
          code: PlaygroundErrorCode.unavailable,
          message: '身份映射字段不完整，请完成账号初始化',
          machineCode: 'identity/not-ready',
        );
      }

      return PlaygroundUserId(appUserId);
    } catch (e) {
      if (e is PlaygroundError) rethrow;
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  /// 优先读 snake_case `app_user_id`，兼容旧 `appUserId`。
  String? _readAppUserId(Map<String, dynamic> data) {
    final snake = data['app_user_id'];
    if (snake is String && snake.isNotEmpty) return snake;
    final camel = data['appUserId'];
    if (camel is String && camel.isNotEmpty) return camel;
    return null;
  }
}
