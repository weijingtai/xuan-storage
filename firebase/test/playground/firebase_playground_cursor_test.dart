import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'package:persistence_firebase/playground/firebase_playground_cursor.dart';

void main() {
  group('FirebasePlaygroundCursor', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    test('fromDocument → toDocumentReference 往返', () async {
      final docRef = firestore.collection('test').doc('doc-abc');
      await docRef.set({'value': 42});
      final snap = await docRef.get();

      final cursor = FirebasePlaygroundCursor.fromDocument(snap);
      expect(cursor.isEmpty, isFalse);
      expect(cursor.token, isNotEmpty);

      final restored = FirebasePlaygroundCursor.toDocumentReference(cursor, firestore);
      expect(restored, isNotNull);
      expect(restored!.path, contains('doc-abc'));
    });

    test('fromQueryDocument → toDocumentReference 往返', () async {
      await firestore.collection('test').doc('doc-1').set({'value': 1});
      await firestore.collection('test').doc('doc-2').set({'value': 2});

      final snaps = await firestore.collection('test').get();
      final cursor = FirebasePlaygroundCursor.fromQueryDocument(snaps.docs.first);
      expect(cursor.isEmpty, isFalse);

      final restored = FirebasePlaygroundCursor.toDocumentReference(cursor, firestore);
      expect(restored, isNotNull);
      expect(restored!.path, contains('doc-1'));
    });

    test('空 cursor → toDocumentReference 返回 null', () {
      final restored = FirebasePlaygroundCursor.toDocumentReference(
          PlaygroundCursor.empty, firestore);
      expect(restored, isNull);
    });

    test('无效 token → toDocumentReference 返回 null', () {
      final cursor = PlaygroundCursor('invalid-base64!!!');
      final restored = FirebasePlaygroundCursor.toDocumentReference(cursor, firestore);
      expect(restored, isNull);
    });

    test('空文档 → fromDocument 返回空 cursor', () async {
      final docRef = firestore.collection('test').doc('non-existent');
      final snap = await docRef.get();

      final cursor = FirebasePlaygroundCursor.fromDocument(snap);
      expect(cursor.isEmpty, isTrue);
    });

    test('cursor 内容不透明（业务层不能解析）', () async {
      final docRef = firestore.collection('test').doc('secret-doc');
      await docRef.set({'value': 'secret'});
      final snap = await docRef.get();

      final cursor = FirebasePlaygroundCursor.fromDocument(snap);
      expect(cursor.token, isNot(contains('secret-doc')));
      expect(cursor.token, isNot(contains('secret')));
    });
  });
}
