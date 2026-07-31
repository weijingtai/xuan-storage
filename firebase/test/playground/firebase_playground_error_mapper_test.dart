import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_error_mapper.dart';

void main() {
  group('FirebasePlaygroundErrorMapper', () {
    test('permission-denied → forbidden', () {
      final error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: '无权访问',
      );
      final mapped = FirebasePlaygroundErrorMapper.map(error);
      expect(mapped.code, PlaygroundErrorCode.forbidden);
      expect(mapped.machineCode, 'firestore/permission-denied');
    });

    test('not-found → notFound', () {
      final error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: '文档不存在',
      );
      final mapped = FirebasePlaygroundErrorMapper.map(error);
      expect(mapped.code, PlaygroundErrorCode.notFound);
      expect(mapped.machineCode, 'firestore/not-found');
    });

    test('already-exists → conflict', () {
      final error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'already-exists',
        message: '文档已存在',
      );
      final mapped = FirebasePlaygroundErrorMapper.map(error);
      expect(mapped.code, PlaygroundErrorCode.conflict);
      expect(mapped.machineCode, 'firestore/already-exists');
    });

    test('resource-exhausted → rateLimited', () {
      final error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'resource-exhausted',
        message: '配额已用完',
      );
      final mapped = FirebasePlaygroundErrorMapper.map(error);
      expect(mapped.code, PlaygroundErrorCode.rateLimited);
      expect(mapped.machineCode, 'firestore/resource-exhausted');
    });

    test('unavailable → unavailable', () {
      final error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
        message: '服务不可用',
      );
      final mapped = FirebasePlaygroundErrorMapper.map(error);
      expect(mapped.code, PlaygroundErrorCode.unavailable);
      expect(mapped.machineCode, 'firestore/unavailable');
    });

    test('unauthenticated → unauthenticated', () {
      final error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unauthenticated',
        message: '未认证',
      );
      final mapped = FirebasePlaygroundErrorMapper.map(error);
      expect(mapped.code, PlaygroundErrorCode.unauthenticated);
      expect(mapped.machineCode, 'firestore/unauthenticated');
    });

    test('invalid-argument → invalidArgument', () {
      final error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'invalid-argument',
        message: '参数无效',
      );
      final mapped = FirebasePlaygroundErrorMapper.map(error);
      expect(mapped.code, PlaygroundErrorCode.invalidArgument);
      expect(mapped.machineCode, 'firestore/invalid-argument');
    });

    test('aborted → conflict', () {
      final error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'aborted',
        message: '事务冲突',
      );
      final mapped = FirebasePlaygroundErrorMapper.map(error);
      expect(mapped.code, PlaygroundErrorCode.conflict);
      expect(mapped.machineCode, 'firestore/aborted');
    });

    test('deadline-exceeded → unavailable', () {
      final error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'deadline-exceeded',
        message: '操作超时',
      );
      final mapped = FirebasePlaygroundErrorMapper.map(error);
      expect(mapped.code, PlaygroundErrorCode.unavailable);
      expect(mapped.machineCode, 'firestore/deadline-exceeded');
    });

    test('unknown code → unknown', () {
      final error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'some-new-code',
        message: '未知错误',
      );
      final mapped = FirebasePlaygroundErrorMapper.map(error);
      expect(mapped.code, PlaygroundErrorCode.unknown);
      expect(mapped.machineCode, 'firestore/some-new-code');
    });

    test('non-FirebaseException → unknown', () {
      final error = Exception('普通异常');
      final mapped = FirebasePlaygroundErrorMapper.map(error);
      expect(mapped.code, PlaygroundErrorCode.unknown);
      expect(mapped.machineCode, 'unknown/internal');
    });

    test('message defaults for known codes', () {
      final error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
      );
      final mapped = FirebasePlaygroundErrorMapper.map(error);
      expect(mapped.message, contains('无权'));
    });
  });
}
