import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

/// 将 FirebaseException 翻译为统一的 [PlaygroundError]。
///
/// 纯函数，无副作用。未知 Firebase error code → PlaygroundErrorCode.unknown。
final class FirebasePlaygroundErrorMapper {
  FirebasePlaygroundErrorMapper._();

  static PlaygroundError map(Object error) {
    if (error is PlaygroundError) {
      // 领域错误直接透传（如 unauthenticated），避免被转成 unknown。
      return error;
    }
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

  static PlaygroundError mapHttpStatus(int statusCode, String body) {
    String message = 'HTTP $statusCode';
    String machineCode = 'http/$statusCode';
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        message = decoded['detail'] as String? ?? decoded['title'] as String? ?? message;
        final type = decoded['type'] as String?;
        if (type != null) {
          machineCode = 'problem/$type';
        }
      }
    } catch (_) {}

    PlaygroundErrorCode code;
    switch (statusCode) {
      case 400:
        code = PlaygroundErrorCode.invalidArgument;
        break;
      case 401:
        code = PlaygroundErrorCode.unauthenticated;
        break;
      case 403:
        code = PlaygroundErrorCode.forbidden;
        break;
      case 404:
        code = PlaygroundErrorCode.notFound;
        break;
      case 409:
        code = PlaygroundErrorCode.conflict;
        break;
      case 429:
        code = PlaygroundErrorCode.rateLimited;
        break;
      case 503:
      case 504:
        code = PlaygroundErrorCode.unavailable;
        break;
      default:
        code = PlaygroundErrorCode.unknown;
    }
    return PlaygroundError(
      code: code,
      message: message,
      machineCode: machineCode,
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
      case 'failed-precondition':
        return PlaygroundError(
          code: PlaygroundErrorCode.conflict,
          message: '操作前置条件不满足',
          machineCode: 'functions/failed-precondition',
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
