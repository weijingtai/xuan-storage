import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_identity_resolver.dart';
import 'firebase_playground_error_mapper.dart';
import 'playground_http_transport.dart';
import 'playground_transport_config.dart';

final class FirebasePlaygroundVerificationRepository
    implements PlaygroundVerificationRepository {
  FirebasePlaygroundVerificationRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebasePlaygroundIdentityResolver identityResolver,
    FirebaseFunctions? functions,
    PlaygroundTransportConfig? config,
    PlaygroundHttpTransport? httpTransport,
    Uri? baseUri,
  })  : _firestore = firestore,
        _auth = auth,
        _identityResolver = identityResolver,
        _functions = functions,
        _config = config ?? PlaygroundTransportConfig.defaults(),
        _httpTransport = httpTransport,
        _baseUri = baseUri;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebasePlaygroundIdentityResolver _identityResolver;
  final FirebaseFunctions? _functions;
  final PlaygroundTransportConfig _config;
  final PlaygroundHttpTransport? _httpTransport;
  final Uri? _baseUri;

  FirebaseFunctions get _effectiveFunctions =>
      _functions ?? FirebaseFunctions.instance;

  Uri get _effectiveBaseUri =>
      _baseUri ?? Uri.parse('http://127.0.0.1:8080/v1');

  @override
  Future<PlaygroundVerification> verifyRootReply(
      VerifyRootReplyCommand command) async {
    try {
      if (_config.isRestVerifyRootReplyEnabled) {
        final transport = _httpTransport;
        if (transport == null) {
          throw StateError(
              'PlaygroundHttpTransport must be provided for REST verifyRootReply');
        }
        final uri = _effectiveBaseUri
            .resolve('/playground/replies/${command.rootReplyId.value}/verification');
        final user = _auth.currentUser;
        final token = await user?.getIdToken();
        final headers = <String, String>{
          'Content-Type': 'application/json',
          if (command.idempotencyKey != null)
            'Idempotency-Key': command.idempotencyKey!,
          if (token != null) 'Authorization': 'Bearer $token',
        };
        final bodyMap = <String, dynamic>{
          'postId': command.postId.value,
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
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        return PlaygroundVerification(
          postId: command.postId,
          rootReplyId: command.rootReplyId,
          posterUserId: PlaygroundUserId(
              data['verifier_app_user_id'] as String? ?? ''),
          createdAt:
              DateTime.tryParse(data['created_at'] as String? ?? '') ??
                  DateTime.now(),
          revokedAt: null,
        );
      }

      // BLOCK-01：敏感写走受信 Functions `verifyRootReply`。
      // 只传业务参数 + idempotency_key；actor/Poster 校验在 Functions 侧。
      final params = <String, dynamic>{
        'postId': command.postId.value,
        'rootReplyId': command.rootReplyId.value,
        if (command.idempotencyKey != null)
          'idempotency_key': command.idempotencyKey,
      };
      final result =
          await _effectiveFunctions.httpsCallable('verifyRootReply').call<Map<String, dynamic>>(params);
      final data = result.data;

      return PlaygroundVerification(
        postId: command.postId,
        rootReplyId: command.rootReplyId,
        posterUserId: PlaygroundUserId(
            data['verifier_app_user_id'] as String? ?? ''),
        createdAt:
            DateTime.tryParse(data['created_at'] as String? ?? '') ??
                DateTime.now(),
        revokedAt: null,
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundVerification> revokeVerification(
      RevokeVerificationCommand command) async {
    try {
      if (_config.isRestRevokeVerificationEnabled) {
        final transport = _httpTransport;
        if (transport == null) {
          throw StateError(
              'PlaygroundHttpTransport must be provided for REST revokeVerification');
        }
        final uri = _effectiveBaseUri
            .resolve('/playground/replies/${command.rootReplyId.value}/verification');
        final user = _auth.currentUser;
        final token = await user?.getIdToken();
        final headers = <String, String>{
          if (command.idempotencyKey != null)
            'Idempotency-Key': command.idempotencyKey!,
          if (token != null) 'Authorization': 'Bearer $token',
        };
        final resp = await transport.delete(
          uri,
          headers: headers,
        );
        if (resp.statusCode >= 400) {
          throw FirebasePlaygroundErrorMapper.mapHttpStatus(
              resp.statusCode, resp.body);
        }
        PlaygroundUserId actor = const PlaygroundUserId('');
        try {
          actor = await _identityResolver.resolveActor();
        } catch (_) {}
        return PlaygroundVerification(
          postId: command.postId,
          rootReplyId: command.rootReplyId,
          posterUserId: actor,
          createdAt: DateTime.now(),
          revokedAt: DateTime.now(),
        );
      }

      final actor = await _identityResolver.resolveActor();
      final params = <String, dynamic>{
        'postId': command.postId.value,
        'rootReplyId': command.rootReplyId.value,
        if (command.idempotencyKey != null)
          'idempotency_key': command.idempotencyKey,
      };
      // BLOCK-01：敏感写走受信 Functions `revokeVerification`。
      await _effectiveFunctions
          .httpsCallable('revokeVerification')
          .call<Map<String, dynamic>>(params);

      return PlaygroundVerification(
        postId: command.postId,
        rootReplyId: command.rootReplyId,
        posterUserId: actor,
        createdAt: DateTime.now(),
        revokedAt: DateTime.now(),
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<List<PlaygroundVerification>> getVerificationsForPost(
      PlaygroundPostId postId) async {
    try {
      // 读路径保持直连（Rules `allow read: if request.auth != null`）。
      final snaps = await _firestore
          .collection(PlaygroundFirestoreSchema.verifications)
          .where('post_id', isEqualTo: postId.value)
          .get();

      return snaps.docs.map((doc) {
        final d = doc.data();
        final timestamp = d['created_at'] as Timestamp?;
        final revokedTs = d['revoked_at'] as Timestamp?;
        return PlaygroundVerification(
          postId: PlaygroundPostId(d['post_id'] as String? ?? ''),
          rootReplyId: PlaygroundReplyId(d['root_reply_id'] as String? ?? ''),
          posterUserId: PlaygroundUserId(
              d['verifier_app_user_id'] as String? ??
                  d['poster_app_user_id'] as String? ??
                  ''),
          createdAt: timestamp?.toDate() ?? DateTime.now(),
          revokedAt: revokedTs?.toDate(),
        );
      }).toList();
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<bool> isRootReplyVerified(PlaygroundReplyId rootReplyId) async {
    try {
      // 读路径保持直连。
      final snaps = await _firestore
          .collection(PlaygroundFirestoreSchema.verifications)
          .where('root_reply_id', isEqualTo: rootReplyId.value)
          .where('revoked_at', isNull: true)
          .limit(1)
          .get();

      return snaps.docs.isNotEmpty;
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }
}
