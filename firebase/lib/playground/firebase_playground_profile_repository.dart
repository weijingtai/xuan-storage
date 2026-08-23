import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_error_mapper.dart';
import 'playground_http_transport.dart';
import 'playground_transport_config.dart';

final class FirebasePlaygroundProfileRepository
    implements PlaygroundProfileRepository {
  FirebasePlaygroundProfileRepository({
    required FirebaseFirestore firestore,
    FirebaseAuth? auth,
    PlaygroundTransportConfig? config,
    PlaygroundHttpTransport? httpTransport,
    Uri? baseUri,
  })  : _firestore = firestore,
        _auth = auth ?? FirebaseAuth.instance,
        _config = config ?? PlaygroundTransportConfig.defaults(),
        _httpTransport = httpTransport,
        _baseUri = baseUri;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final PlaygroundTransportConfig _config;
  final PlaygroundHttpTransport? _httpTransport;
  final Uri? _baseUri;

  Uri get _effectiveBaseUri =>
      _baseUri ?? Uri.parse('http://127.0.0.1:8080/v1');

  @override
  Future<PlaygroundProfile> getPublicProfile(PlaygroundUserId userId) async {
    try {
      final snap = await _firestore
          .collection(PlaygroundFirestoreSchema.profiles)
          .doc(userId.value)
          .get();

      if (!snap.exists) {
        return PlaygroundProfile(
          userId: userId,
          displayName: 'User_${userId.value}',
        );
      }

      final d = snap.data()!;
      return PlaygroundProfile(
        userId: userId,
        displayName: d['display_name'] as String? ?? 'User_${userId.value}',
        avatarUrl: d['avatar_url'] as String?,
        bio: d['bio'] as String?,
        commonTechniques:
            (d['common_techniques'] as List<dynamic>?)?.cast<String>() ?? const [],
        publicPostCount: d['public_post_count'] as int? ?? 0,
        publicReplyCount: d['public_reply_count'] as int? ?? 0,
        playgroundVerificationCount:
            d['playground_verification_count'] as int? ?? 0,
        playgroundLikeCount: d['playground_like_count'] as int? ?? 0,
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<void> updateProfile({
    required PlaygroundUserId userId,
    String? displayName,
    String? avatarUrl,
    String? bio,
    List<String>? commonTechniques,
    String? idempotencyKey,
  }) async {
    try {
      if (_config.isRestProfileEnabled) {
        final transport = _httpTransport;
        if (transport == null) {
          throw StateError(
              'PlaygroundHttpTransport must be provided for REST updateProfile');
        }
        final uri = _effectiveBaseUri.resolve('/playground/profile');
        final user = _auth.currentUser;
        final token = await user?.getIdToken();
        final headers = <String, String>{
          'Content-Type': 'application/json',
          if (idempotencyKey != null) 'Idempotency-Key': idempotencyKey,
          if (token != null) 'Authorization': 'Bearer $token',
        };
        final bodyMap = <String, dynamic>{
          if (displayName != null) 'displayName': displayName,
          if (avatarUrl != null) 'avatarUrl': avatarUrl,
          if (bio != null) 'bio': bio,
          if (commonTechniques != null) 'commonTechniques': commonTechniques,
        };
        final resp = await transport.patch(
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

      final updates = <String, dynamic>{
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updates['display_name'] = displayName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (bio != null) updates['bio'] = bio;
      if (commonTechniques != null) {
        updates['common_techniques'] = commonTechniques;
      }

      await _firestore
          .collection(PlaygroundFirestoreSchema.profiles)
          .doc(userId.value)
          .set(updates, SetOptions(merge: true));
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<List<PlaygroundPrivateTechniqueStats>> getPrivateTechniqueStats(
      PlaygroundUserId userId) async {
    try {
      final profile = await getPublicProfile(userId);
      return profile.commonTechniques.map((techId) {
        return PlaygroundPrivateTechniqueStats(
          userId: userId,
          techniqueId: techId,
        );
      }).toList();
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }
}
