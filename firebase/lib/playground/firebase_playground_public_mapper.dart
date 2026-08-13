/// Phase 7B：公开 DTO 映射共享 helper —— 多个新端口 adapter 复用同一投影。
///
/// 只负责 Firestore 文档（snake_case）→ 安全公开 DTO（camelCase）的转换，
/// **禁止把敏感字段写进 DTO**（provider uid / presentation_identity_id /
/// canonical appUserId / 内部媒体路径一律不进公开面）。
///
/// 与 `firebase_playground_thread_query_repository.dart` 的私有映射保持同语义；
/// 本文件供 PostCommand/ReplyCommand/FeedQuery/Engagement adapter 共享，
/// 避免逐文件复制（执行令 §3.7）。
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';

/// 公开 DTO 映射 + viewer state 查询。
final class FirebasePlaygroundPublicMapper {
  FirebasePlaygroundPublicMapper({
    required FirebaseFirestore firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // ---- viewer state（直连读，Rules 允许认证读 likes/bookmarks）----

  /// 当前 viewer 对某 post 的点赞/收藏/可应验状态。
  Future<PlaygroundPostViewerState> viewerStateForPost(
    String postId,
    Map<String, dynamic> postData,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return const PlaygroundPostViewerState();

    final uid = user.uid;
    final likeSnap = await _firestore
        .collection(PlaygroundFirestoreSchema.likes)
        .doc('like_post_${uid}_$postId')
        .get();
    final bookmarkSnap = await _firestore
        .collection(PlaygroundFirestoreSchema.bookmarks)
        .where('post_id', isEqualTo: postId)
        .where('user_provider_uid', isEqualTo: uid)
        .limit(1)
        .get();

    return PlaygroundPostViewerState(
      isLiked: likeSnap.exists,
      isBookmarked: bookmarkSnap.docs.isNotEmpty,
      // 帖子不存在或作者本人时不可应验。
      canVerify: postData['author_provider_uid'] != null &&
          postData['author_provider_uid'] != uid,
    );
  }

  /// 当前 viewer 对某 reply 的点赞状态（reply 无可收藏/可应验维度）。
  Future<PlaygroundPostViewerState> viewerStateForReply(String replyId) async {
    final user = _auth.currentUser;
    if (user == null) return const PlaygroundPostViewerState();
    final likeSnap = await _firestore
        .collection(PlaygroundFirestoreSchema.likes)
        .doc('like_reply_${user.uid}_$replyId')
        .get();
    return PlaygroundPostViewerState(isLiked: likeSnap.exists);
  }

  // ---- Firestore doc（snake_case）→ DTO ----

  /// 帖子公开投影。counts/viewerState/outcomeFeedback 由调用方聚合后传入。
  PublicPost publicPostFromDoc(
    String postId,
    Map<String, dynamic> d, {
    required int replyCount,
    required int likeCount,
    required int verificationCount,
    required PlaygroundPostViewerState viewerState,
    PublicFeedbackSummary? outcomeFeedback,
    PlaygroundPresentationMode? presentationMode,
  }) {
    final status = d['status'] as String? ?? 'unavailable';
    return PublicPost(
      publicPostId: PlaygroundPostId(postId),
      body: status == 'active' ? d['text'] as String? : null,
      attachments: publicAttachmentsFromDoc(d['attachments']),
      author: publicAuthorFromDoc(d),
      replyCount: replyCount,
      likeCount: likeCount,
      verificationCount: verificationCount,
      viewerState: viewerState,
      outcomeFeedback: outcomeFeedback,
      displayStatus: switch (status) {
        'active' => PublicPostDisplayStatus.active,
        'tombstoned' => PublicPostDisplayStatus.tombstoned,
        'pending_review' => PublicPostDisplayStatus.pendingReview,
        _ => PublicPostDisplayStatus.unavailable,
      },
      latestRevision: revisionSummaryFromDoc(d['revisions']),
      presentation: presentationMode != null
          ? PublicPostPresentationInfo(mode: presentationMode)
          : null,
      createdAt: toDateTime(d['created_at']) ?? DateTime.now(),
      updatedAt: toDateTime(d['updated_at']),
    );
  }

  /// 回复公开投影（root/discussion 由 depth 判别）。
  PublicReply publicReplyFromDoc(String docId, Map<String, dynamic> d) {
    return PublicReply(
      publicReplyId: PlaygroundReplyId(docId),
      postId: PlaygroundPostId(d['post_id'] as String? ?? ''),
      body: d['is_tombstoned'] == true ? null : d['body'] as String?,
      techniqueTags:
          (d['technique_tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      chart: chartFromDoc(d['chart_attachment']),
      mediaAttachments: mediaListFromDoc(d['media_attachments']),
      author: publicAuthorFromDoc(d),
      depth: d['depth'] as int? ?? 0,
      rootReplyId: d['root_reply_id'] != null
          ? PlaygroundReplyId(d['root_reply_id'] as String)
          : null,
      replyToReplyId: d['reply_to_reply_id'] != null
          ? PlaygroundReplyId(d['reply_to_reply_id'] as String)
          : null,
      isVerified: d['verification'] != null,
      isTombstoned: d['is_tombstoned'] == true,
      presentationMode: presentationModeFromDoc(d),
      createdAt: toDateTime(d['created_at']) ?? DateTime.now(),
      updatedAt: toDateTime(d['updated_at']),
      latestRevision: revisionSummaryFromDoc(d['revisions']),
    );
  }

  /// 作者公开投影：优先 presentation_identity_id，否则由 provider uid 派生
  /// 稳定展示 ID；**不暴露 provider uid / canonical appUserId**。
  PublicAuthor publicAuthorFromDoc(Map<String, dynamic> d) {
    final presentationId = d['presentation_identity_id'] as String? ?? '';
    final resolved = presentationId.isNotEmpty
        ? presentationId
        : derivePresentationId(d['author_provider_uid'] as String? ?? '');
    return PublicAuthor(
      publicPresentationUserId: PlaygroundUserId(resolved),
      displayAlias:
          '盘友${resolved.length > 6 ? resolved.substring(resolved.length - 6) : resolved}',
      avatarUrl: null,
      publicProfileRef: null,
    );
  }

  List<PublicAttachment> publicAttachmentsFromDoc(dynamic raw) {
    if (raw is! List) return const [];
    final result = <PublicAttachment>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final m = item.cast<String, dynamic>();
      final type = m['type'] as String?;
      if (type == 'xuanChart') {
        result.add(PublicXuanChartAttachment(
          techniqueId: m['technique_id'] as String? ?? 'unknown',
          schoolId: m['school_id'] as String?,
          publicChartSnapshot: m['public_chart_snapshot'] as String? ?? '',
          rendererSchemaVersion: m['renderer_schema_version'] as int? ?? 1,
          source: PlaygroundChartSource.values.byName(
              m['chart_source'] as String? ?? 'createdInPlayground'),
        ));
      } else {
        result.add(PublicMediaAttachment(
          type: PlaygroundAttachmentType.values.byName(type ?? 'image'),
          mediaObjectId:
              PlaygroundAttachmentId(m['media_object_id'] as String? ?? ''),
          mimeType: m['mime_type'] as String? ?? '',
          width: m['width'] as int?,
          height: m['height'] as int?,
          durationSeconds: m['duration_seconds'] as int?,
          secureUrl: '/public/media/${m['media_object_id'] ?? 'unknown'}',
        ));
      }
    }
    return result;
  }

  PublicXuanChartAttachment? chartFromDoc(dynamic raw) {
    if (raw is! Map) return null;
    final m = raw.cast<String, dynamic>();
    return PublicXuanChartAttachment(
      techniqueId: m['technique_id'] as String? ?? 'unknown',
      schoolId: m['school_id'] as String?,
      publicChartSnapshot: m['public_chart_snapshot'] as String? ?? '',
      rendererSchemaVersion: m['renderer_schema_version'] as int? ?? 1,
      source: PlaygroundChartSource.values.byName(
          m['chart_source'] as String? ?? 'createdInPlayground'),
    );
  }

  List<PublicMediaAttachment> mediaListFromDoc(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((m) {
      final mm = m.cast<String, dynamic>();
      return PublicMediaAttachment(
        type: PlaygroundAttachmentType.values.byName(
            mm['type'] as String? ?? 'image'),
        mediaObjectId:
            PlaygroundAttachmentId(mm['media_object_id'] as String? ?? ''),
        mimeType: mm['mime_type'] as String? ?? '',
        width: mm['width'] as int?,
        height: mm['height'] as int?,
        durationSeconds: mm['duration_seconds'] as int?,
        secureUrl: '/public/media/${mm['media_object_id'] ?? 'unknown'}',
      );
    }).toList();
  }

  PublicFeedbackSummary? feedbackFromDoc(Map<String, dynamic> d) {
    final publishedAt = toDateTime(d['created_at']) ?? DateTime.now();
    final updatedAt = toDateTime(d['updated_at']);
    return PublicFeedbackSummary(
      body: (d['outcome_description'] as String?) ?? d['body'] as String? ?? '',
      isEdited: updatedAt != null && updatedAt != publishedAt,
      publishedAt: publishedAt,
      updatedAt: updatedAt,
    );
  }

  PlaygroundRevisionSummary? revisionSummaryFromDoc(dynamic raw) {
    if (raw is! List || raw.isEmpty) return null;
    final last = raw.last;
    if (last is! Map) return null;
    final m = last.cast<String, dynamic>();
    return PlaygroundRevisionSummary(
      editedByAlias: m['edited_by'] as String? ?? '',
      editedAt: toDateTime(m['edited_at']) ?? DateTime.now(),
      changeDescription: m['change_description'] as String?,
    );
  }

  // ---- helpers ----

  static PlaygroundPresentationMode? presentationModeFromDoc(
      Map<String, dynamic> d) {
    final mode = d['presentation_mode'] as String?;
    if (mode == null) return null;
    for (final m in PlaygroundPresentationMode.values) {
      if (m.name == mode) return m;
    }
    return null;
  }

  static DateTime? toDateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  /// 由 provider uid 派生稳定展示 ID（不暴露原文）。
  static String derivePresentationId(String providerUid) {
    final raw = providerUid.isEmpty ? 'anonymous' : providerUid;
    final hash = sha256.convert(utf8.encode(raw)).toString();
    return 'anon_${hash.substring(0, 8)}';
  }
}
