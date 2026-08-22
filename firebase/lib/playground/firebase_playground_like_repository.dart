import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';
import 'package:persistence_core/persistence_core.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_identity_resolver.dart';
import 'firebase_playground_error_mapper.dart';
import 'playground_http_transport.dart';
import 'playground_transport_config.dart';

final class FirebasePlaygroundLikeRepository
    implements PlaygroundLikeRemoteDataSource {
  FirebasePlaygroundLikeRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebasePlaygroundIdentityResolver identityResolver,
    FirebaseFunctions? functions,
    PlaygroundTransportConfig? config,
    PlaygroundHttpTransport? httpTransport,
    Uri? baseUri,
  })  : _firestore = firestore,
        _auth = auth,
        _functions = functions,
        _config = config ?? PlaygroundTransportConfig.defaults(),
        _httpTransport = httpTransport,
        _baseUri = baseUri;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseFunctions? _functions;
  final PlaygroundTransportConfig _config;
  final PlaygroundHttpTransport? _httpTransport;
  final Uri? _baseUri;

  FirebaseFunctions get _effectiveFunctions =>
      _functions ?? FirebaseFunctions.instance;

  String _likeDocId({PlaygroundPostId? postId, PlaygroundReplyId? replyId}) {
    final user = _auth.currentUser;
    final uid = user?.uid ?? 'anonymous';
    final targetId = postId?.value ?? replyId?.value ?? 'unknown';
    final targetType = postId != null ? 'post' : 'reply';
    return '${uid}_${targetType}_$targetId';
  }

  @override
  Future<void> setLike(SetLikeCommand command) async {
    try {
      if (_config.isRestLikeEnabled) {
        final transport = _httpTransport;
        if (transport == null) {
          throw StateError(
              'PlaygroundHttpTransport must be provided for REST like transport');
        }
        final uri = (_baseUri ?? Uri.parse('http://127.0.0.1:8080/v1'))
            .resolve('/playground/likes');
        final user = _auth.currentUser;
        final token = await user?.getIdToken();
        final headers = <String, String>{
          'Content-Type': 'application/json',
          if (command.idempotencyKey != null)
            'Idempotency-Key': command.idempotencyKey!,
          if (token != null) 'Authorization': 'Bearer $token',
        };
        final bodyMap = <String, dynamic>{
          'action': command.liked ? 'like' : 'unlike',
          if (command.postId != null) 'postId': command.postId!.value,
          if (command.replyId != null) 'replyId': command.replyId!.value,
        };
        final resp = await transport.put(
          uri,
          headers: headers,
          body: jsonEncode(bodyMap),
        );
        if (resp.statusCode >= 400) {
          throw FirebasePlaygroundErrorMapper.mapHttpStatus(
              resp.statusCode, resp.body);
        }
        return;
      }

      // BLOCK-01：敏感写走受信 Functions `setLike`。
      // 客户端只传业务参数 + idempotency_key，绝不传可伪造身份字段。
      final params = <String, dynamic>{
        'action': command.liked ? 'like' : 'unlike',
        if (command.postId != null) 'postId': command.postId!.value,
        if (command.replyId != null) 'replyId': command.replyId!.value,
        if (command.idempotencyKey != null)
          'idempotency_key': command.idempotencyKey,
      };
      await _effectiveFunctions.httpsCallable('setLike').call(params);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<bool> isLiked(
      {PlaygroundPostId? postId, PlaygroundReplyId? replyId}) async {
    try {
      // 读路径保持直连（Rules `allow read: if request.auth != null`）。
      final docId = _likeDocId(postId: postId, replyId: replyId);
      final snap = await _firestore
          .collection(PlaygroundFirestoreSchema.likes)
          .doc(docId)
          .get();
      return snap.exists;
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<int> getLikeCount(
      {PlaygroundPostId? postId, PlaygroundReplyId? replyId}) async {
    try {
      // 读路径保持直连。
      final targetId = postId?.value ?? replyId?.value ?? '';
      final snaps = await _firestore
          .collection(PlaygroundFirestoreSchema.likes)
          .where('target_id', isEqualTo: targetId)
          .get();
      return snaps.docs.length;
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }
}
