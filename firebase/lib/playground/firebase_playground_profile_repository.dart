import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_error_mapper.dart';

final class FirebasePlaygroundProfileRepository
    implements PlaygroundProfileRepository {
  FirebasePlaygroundProfileRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

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
  }) async {
    try {
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
