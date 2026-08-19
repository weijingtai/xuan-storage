import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_error_mapper.dart';
import 'firebase_playground_public_mapper.dart';

/// Phase 7B：帖子命令端口 adapter（PlaygroundPostCommandRepository）。
///
/// - createPost/editPost/tombstonePost：复用 Phase 4 收敛的直写 payload
///   （text/status，字段集 == Rules postCreateFieldsOk allowlist，含
///   idempotency_key 条件写；**零 author_app_user_id**）；
/// - getPublicPost：单帖直连读（active/tombstone 可见语义沿用 Rules 约束），
///   映射安全 [PublicPost] 公开投影，无敏感字段。
final class FirebasePlaygroundPostCommandRepository
    implements PlaygroundPostCommandRepository {
  FirebasePlaygroundPostCommandRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    FirebaseFunctions? functions,
  })  : _firestore = firestore,
        _functions = functions ?? FirebaseFunctions.instance,
        _mapper = FirebasePlaygroundPublicMapper(firestore: firestore, auth: auth);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final FirebasePlaygroundPublicMapper _mapper;

  @override
  Future<PublicPost> createPost(CreatePostCommand command) async {
    try {
      final result = await _functions.httpsCallable('createPost').call<Map<String, dynamic>>({
        'text': command.text,
        'allowed_chart_technique_ids': command.allowedChartTechniqueIds,
        'attachments': command.attachments.map(_attachmentToMap).toList(),
        'presentation_mode': command.presentationMode.name,
        if (command.idempotencyKey != null) 'idempotency_key': command.idempotencyKey,
      });
      final doc = result.data;
      return _mapper.publicPostFromDoc(
        doc['id'] as String,
        doc,
        replyCount: 0,
        likeCount: 0,
        verificationCount: 0,
        viewerState: const PlaygroundPostViewerState(),
        presentationMode: command.presentationMode,
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PublicPost> editPost(EditPostCommand command) async {
    try {
      final result = await _functions.httpsCallable('editPost').call<Map<String, dynamic>>({
        'postId': command.postId.value,
        'text': command.text,
        if (command.allowedChartTechniqueIds != null) 'allowed_chart_technique_ids': command.allowedChartTechniqueIds,
        if (command.attachments != null) 'attachments': command.attachments!.map(_attachmentToMap).toList(),
        if (command.idempotencyKey != null) 'idempotency_key': command.idempotencyKey,
      });
      final doc = result.data;
      return _mapper.publicPostFromDoc(
        doc['id'] as String? ?? command.postId.value,
        doc,
        replyCount: 0,
        likeCount: 0,
        verificationCount: 0,
        viewerState: const PlaygroundPostViewerState(),
        presentationMode: null,
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<void> tombstonePost(DeletePostCommand command) async {
    try {
      await _functions.httpsCallable('tombstonePost').call({
        'postId': command.postId.value,
        if (command.idempotencyKey != null) 'idempotency_key': command.idempotencyKey,
      });
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PublicPost?> getPublicPost(PlaygroundPostId postId) async {
    try {
      final docRef = _firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc(postId.value);
      final snap = await docRef.get();
      if (!snap.exists) return null;
      final doc = snap.data()!;

      final viewerState =
          await _mapper.viewerStateForPost(postId.value, doc);
      final counts = await _aggregateCounts(postId.value);

      return _mapper.publicPostFromDoc(
        postId.value,
        doc,
        replyCount: counts.$1,
        likeCount: counts.$2,
        verificationCount: counts.$3,
        viewerState: viewerState,
        presentationMode: null,
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  /// 聚合 counts（bounded by 单帖三集合查询）。
  Future<(int, int, int)> _aggregateCounts(String postId) async {
    final repliesFuture = _firestore
        .collection(PlaygroundFirestoreSchema.replies)
        .where('post_id', isEqualTo: postId)
        .where('is_tombstoned', isEqualTo: false)
        .get();
    final likesFuture = _firestore
        .collection(PlaygroundFirestoreSchema.likes)
        .where('post_id', isEqualTo: postId)
        .get();
    final verificationsFuture = _firestore
        .collection(PlaygroundFirestoreSchema.verifications)
        .where('post_id', isEqualTo: postId)
        .where('revoked_at', isNull: true)
        .get();

    final results = await Future.wait(
        [repliesFuture, likesFuture, verificationsFuture]);
    return (
      results[0].docs.length,
      results[1].docs.length,
      results[2].docs.length,
    );
  }

  static Map<String, dynamic> _attachmentToMap(PlaygroundAttachment a) {
    return {
      'type': a.type.name,
      'technique_id': a.techniqueId,
      'school_id': a.schoolId,
      'public_chart_snapshot': a.publicChartSnapshot,
      'renderer_schema_version': a.rendererSchemaVersion,
      'chart_source': a.chartSource?.name,
      'media_object_id': a.mediaObjectId?.value,
      'mime_type': a.mimeType,
      'width': a.width,
      'height': a.height,
      'duration_seconds': a.durationSeconds,
      'moderation_state': a.moderationState?.name,
    };
  }
}
