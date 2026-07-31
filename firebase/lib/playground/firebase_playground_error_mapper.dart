import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

/// 将 FirebaseException 翻译为统一的 [PlaygroundError]。
///
/// 纯函数，无副作用。未知 Firebase error code → PlaygroundErrorCode.unknown。
final class FirebasePlaygroundErrorMapper {
  FirebasePlaygroundErrorMapper._();

  static PlaygroundError map(Object error) {
    if (error is FirebaseException) {
      return _fromFirebaseException(error);
    }
    return PlaygroundError(
      code: PlaygroundErrorCode.unknown,
      message: error.toString(),
      machineCode: 'unknown/internal',
      cause: error,
    );
  }

  static PlaygroundError _fromFirebaseException(FirebaseException e) {
    final code = e.code.toLowerCase();
    switch (code) {
      case 'permission-denied':
        return PlaygroundError(
          code: PlaygroundErrorCode.forbidden,
          message: '无权执行此操作',
          machineCode: 'firestore/permission-denied',
          cause: e,
        );
      case 'not-found':
        return PlaygroundError(
          code: PlaygroundErrorCode.notFound,
          message: '资源不存在',
          machineCode: 'firestore/not-found',
          cause: e,
        );
      case 'already-exists':
        return PlaygroundError(
          code: PlaygroundErrorCode.conflict,
          message: '资源已存在',
          machineCode: 'firestore/already-exists',
          cause: e,
        );
      case 'resource-exhausted':
        return PlaygroundError(
          code: PlaygroundErrorCode.rateLimited,
          message: '请求过于频繁，请稍后再试',
          machineCode: 'firestore/resource-exhausted',
          cause: e,
        );
      case 'unavailable':
        return PlaygroundError(
          code: PlaygroundErrorCode.unavailable,
          message: '服务暂时不可用',
          machineCode: 'firestore/unavailable',
          cause: e,
        );
      case 'unauthenticated':
        return PlaygroundError(
          code: PlaygroundErrorCode.unauthenticated,
          message: '未认证，请先登录',
          machineCode: 'firestore/unauthenticated',
          cause: e,
        );
      case 'invalid-argument':
        return PlaygroundError(
          code: PlaygroundErrorCode.invalidArgument,
          message: e.message ?? '参数无效',
          machineCode: 'firestore/invalid-argument',
          cause: e,
        );
      case 'aborted':
        return PlaygroundError(
          code: PlaygroundErrorCode.conflict,
          message: '操作冲突，请重试',
          machineCode: 'firestore/aborted',
          cause: e,
        );
      case 'deadline-exceeded':
        return PlaygroundError(
          code: PlaygroundErrorCode.unavailable,
          message: '操作超时',
          machineCode: 'firestore/deadline-exceeded',
          cause: e,
        );
      default:
        return PlaygroundError(
          code: PlaygroundErrorCode.unknown,
          message: e.message ?? '未知错误',
          machineCode: 'firestore/$code',
          cause: e,
        );
    }
  }
}
