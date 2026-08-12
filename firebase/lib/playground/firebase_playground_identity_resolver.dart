import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';
import 'firebase_playground_error_mapper.dart';

/// 从 Firebase Auth session 解析 actor [PlaygroundUserId]。
///
/// 流程：
/// 1. 从 FirebaseAuth.currentUser 获取 uid（providerUserId）
/// 2. 调用 Functions callable `resolveMyIdentity`（服务端基于 Auth context
///    解析/创建 identity_map → appUserId）
/// 3. 返回 PlaygroundUserId(appUserId)
///
/// 客户端不再直写/直读 identity_map（Rules 下 `write: if false`）；
/// 身份映射的创建与解析完全由受信 Functions 负责。
///
/// 抛出 [PlaygroundError.unauthenticated] 当用户未登录。
final class FirebasePlaygroundIdentityResolver {
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  /// [firestore] 参数保留以兼容既有 composition root（xuan-shell bootstrap）
  /// 与旧测试签名；本实现不再依赖 Firestore，identity_map 读写均在 Functions。
  FirebasePlaygroundIdentityResolver({
    FirebaseFirestore? firestore,
    required FirebaseAuth auth,
    FirebaseFunctions? functions,
  })  : _auth = auth,
        _functions = functions ?? FirebaseFunctions.instance;

  /// 从当前认证 session 解析展示用 [PlaygroundUserId]。
  ///
  /// 通过 Functions callable `resolveMyIdentity` 获取服务端权威的 appUserId，
  /// 不接受客户端任何身份值。
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
      final callable = _functions.httpsCallable('resolveMyIdentity');
      final result = await callable.call<Map<String, dynamic>>();
      final appUserId = result.data['appUserId'] as String;
      if (appUserId.isEmpty) {
        throw const PlaygroundError(
          code: PlaygroundErrorCode.unknown,
          message: '身份解析失败：服务端未返回 appUserId',
          machineCode: 'identity/empty-app-user-id',
        );
      }
      return PlaygroundUserId(appUserId);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }
}
