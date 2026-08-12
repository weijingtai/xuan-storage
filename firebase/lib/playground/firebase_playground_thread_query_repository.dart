import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_error_mapper.dart';
import 'firebase_playground_cursor.dart';

/// BLOCK-03 线程查询 adapter：
/// - 游客代表性回复走受信 Functions `getGuestRepresentativeReplies`（未认证可用，
///   服务端确定性选择 + 反绕过；客户端无随机/截断）；
/// - 注册用户完整详情 / 回复分页走直连 Firestore（Rules 认证可见）。
final class FirebasePlaygroundThreadQueryRepository
    implements PlaygroundThreadQueryRepository {
  FirebasePlaygroundThreadQueryRepository({
    required FirebaseFirestore firestore,
    FirebaseAuth? auth,
    FirebaseFunctions? functions,
  })  : _firestore = firestore,
        _auth = auth ?? FirebaseAuth.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;

  // ---- 游客代表性回复：受信服务端选择（BLOCK-03）----

  @override
  Future<GuestRepresentativeRepliesResult> getGuestRepresentativeReplies(
      GetGuestRepresentativeRepliesQuery query) async {
    try {
      // 只传业务参数（postId/limit/selectionPolicyVersion）；
      // cursor/page/sort 等任何额外参数不参与（反绕过由服务端忽略）。
      final params = <String, dynamic>{
        'postId': query.postId.value,
        'limit': query.limit,
        'selectionPolicyVersion': query.selectionPolicyVersion,
      };
      final result = await _functions
          .httpsCallable('getGuestRepresentativeReplies')
          .call<Map<String, dynamic>>(params);
      final data = result.data;

      return GuestRepresentativeRepliesResult(
        postId: PlaygroundPostId(data['postId'] as String? ?? query.postId.value),
        visibleReplies: _publicRepliesFromJson(data['visibleReplies']),
        totalReplyCount: data['totalReplyCount'] as int? ?? 0,
        hiddenReplyCount: data['hiddenReplyCount'] as int? ?? 0,
        selectionPolicyVersion: data['selectionPolicyVersion'] as int? ?? 1,
        registrationUnlock: _registrationUnlockFromJson(data['registrationUnlock']),
        outcomeFeedback: _feedbackFromJson(data['outcomeFeedback']),
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  // ---- 注册用户回复分页：直连 Firestore（Rules 认证可见）----

  @override
  Future<PlaygroundPage<PlaygroundReplyView>> getThreadReplies(
      GetRepliesQuery query) async {
    try {
      // 查询形状与 BLOCK-02 收敛的 getReplies 一致：post_id +
      // is_tombstoned==false + orderBy depth/created_at（Rules list 可证明可见）。
      var q = _firestore
          .collection(PlaygroundFirestoreSchema.replies)
          .where('post_id', isEqualTo: query.postId.value)
          .where('is_tombstoned', isEqualTo: false)
          .orderBy('depth', descending: false)
          .orderBy('created_at', descending: false)
          .limit(query.limit);

      if (query.cursor != null && query.cursor!.isNotEmpty) {
        final startDoc = FirebasePlaygroundCursor.toDocumentReference(
            query.cursor!, _firestore);
        if (startDoc != null) {
          final startSnap = await startDoc.get();
          q = q.startAfterDocument(startSnap);
        }
      }

      final snaps = await q.get();
      final views = <PlaygroundReplyView>[];
      for (final snap in snaps.docs) {
        final reply = _publicReplyFromDoc(snap.data(), snap.id);
        views.add(reply.depth == 0
            ? PlaygroundRootReplyView(reply: reply)
            : PlaygroundDiscussionReplyView(reply: reply));
      }

      final nextCursor = snaps.docs.isNotEmpty && snaps.docs.length == query.limit
          ? FirebasePlaygroundCursor.fromQueryDocument(snaps.docs.last)
          : null;

      return PlaygroundPage<PlaygroundReplyView>(
        items: views,
        nextCursor: nextCursor,
        hasMore: nextCursor != null,
        totalCount: -1,
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  // ---- 注册用户完整详情聚合（bounded-query-cost，禁 N+1）----

  @override
  Future<PlaygroundRegisteredThreadDetail> getRegisteredThreadDetail(
      PlaygroundRegisteredThreadDetailQuery query) async {
    try {
      final postId = query.postId.value;
      var aggregateReadCount = 0;

      final postSnap = await _firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .doc(postId)
          .get();
      aggregateReadCount++;
      if (!postSnap.exists) {
        throw FirebasePlaygroundErrorMapper.map(
          FirebaseException(
            plugin: 'firestore',
            code: 'not-found',
            message: '帖子不存在',
          ),
        );
      }
      final postData = postSnap.data() ?? const <String, dynamic>{};

      final rootsSnap = await _firestore
          .collection(PlaygroundFirestoreSchema.replies)
          .where('post_id', isEqualTo: postId)
          .where('is_tombstoned', isEqualTo: false)
          .where('depth', isEqualTo: 0)
          .orderBy('created_at', descending: false)
          .get();
      aggregateReadCount++;

      final discussionSnap = await _firestore
          .collection(PlaygroundFirestoreSchema.replies)
          .where('post_id', isEqualTo: postId)
          .where('is_tombstoned', isEqualTo: false)
          .where('depth', isEqualTo: 1)
          .orderBy('created_at', descending: false)
          .get();
      aggregateReadCount++;

      final feedbackSnap = await _firestore
          .collection(PlaygroundFirestoreSchema.outcomeFeedback)
          .where('post_id', isEqualTo: postId)
          .where('deleted_at', isNull: true)
          .limit(1)
          .get();
      aggregateReadCount++;

      final likesSnap = await _firestore
          .collection(PlaygroundFirestoreSchema.likes)
          .where('post_id', isEqualTo: postId)
          .get();
      aggregateReadCount++;

      final verificationsSnap = await _firestore
          .collection(PlaygroundFirestoreSchema.verifications)
          .where('post_id', isEqualTo: postId)
          .where('revoked_at', isNull: true)
          .get();
      aggregateReadCount++;

      final currentUser = _auth.currentUser;
      final viewerState = await _viewerStateForPost(postId, postData, currentUser);
      aggregateReadCount += viewerState.$2;

      final views = <PlaygroundReplyView>[];
      for (final snap in rootsSnap.docs) {
        final reply = _publicReplyFromDoc(snap.data(), snap.id);
        views.add(PlaygroundRootReplyView(reply: reply));
      }
      for (final snap in discussionSnap.docs) {
        final reply = _publicReplyFromDoc(snap.data(), snap.id);
        views.add(PlaygroundDiscussionReplyView(reply: reply));
      }

      final verifiedRootCount = rootsSnap.docs
          .where((d) => d.data()['verification'] != null)
          .length;

      return PlaygroundRegisteredThreadDetail(
        post: _publicPostFromDoc(postId, postData,
            replyCount: rootsSnap.docs.length + discussionSnap.docs.length,
            likeCount: likesSnap.docs.length,
            verificationCount: verificationsSnap.docs.length,
            viewerState: viewerState.$1,
            outcomeFeedback: feedbackSnap.docs.isEmpty
                ? null
                : _feedbackFromDoc(feedbackSnap.docs.first.data())),
        replies: views,
        counts: PlaygroundThreadCounts(
          replyCount: rootsSnap.docs.length + discussionSnap.docs.length,
          verifiedRootReplyCount: verifiedRootCount,
        ),
        viewerState: viewerState.$1,
        aggregateReadCount: aggregateReadCount,
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  Future<(PlaygroundPostViewerState, int)> _viewerStateForPost(
    String postId,
    Map<String, dynamic> postData,
    User? currentUser,
  ) async {
    var reads = 0;
    if (currentUser == null) {
      return (const PlaygroundPostViewerState(), reads);
    }
    final uid = currentUser.uid;
    final likeSnap = await _firestore
        .collection(PlaygroundFirestoreSchema.likes)
        .doc('like_post_${uid}_$postId')
        .get();
    reads++;
    final bookmarkSnap = await _firestore
        .collection(PlaygroundFirestoreSchema.bookmarks)
        .where('post_id', isEqualTo: postId)
        .where('user_provider_uid', isEqualTo: uid)
        .limit(1)
        .get();
    reads++;
    return (
      PlaygroundPostViewerState(
        isLiked: likeSnap.exists,
        isBookmarked: bookmarkSnap.docs.isNotEmpty,
        canVerify: postData['author_provider_uid'] != uid,
      ),
      reads,
    );
  }

  // ---- JSON（Functions callable）→ DTO ----

  List<PublicReply> _publicRepliesFromJson(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((r) => _publicReplyFromJson(r as Map<String, dynamic>))
        .toList();
  }

  PublicReply _publicReplyFromJson(Map<String, dynamic> json) {
    return PublicReply(
      publicReplyId:
          PlaygroundReplyId(json['publicReplyId'] as String? ?? ''),
      postId: PlaygroundPostId(json['postId'] as String? ?? ''),
      body: json['body'] as String?,
      techniqueTags: (json['techniqueTags'] as List<dynamic>?)
              ?.cast<String>() ??
          const [],
      chart: _chartFromJson(json['chart']),
      mediaAttachments: _mediaListFromJson(json['mediaAttachments']),
      author: _authorFromJson(json['author']),
      depth: json['depth'] as int? ?? 0,
      rootReplyId: json['rootReplyId'] != null
          ? PlaygroundReplyId(json['rootReplyId'] as String)
          : null,
      replyToReplyId: json['replyToReplyId'] != null
          ? PlaygroundReplyId(json['replyToReplyId'] as String)
          : null,
      isVerified: json['isVerified'] == true,
      isTombstoned: json['isTombstoned'] == true,
      presentationMode: _modeFromString(json['presentationMode'] as String?),
      createdAt: DateTime.parse(
          json['createdAt'] as String? ?? '1970-01-01T00:00:00.000Z'),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      latestRevision:
          json['latestRevision'] != null && json['latestRevision'] is Map
              ? _revisionFromJson(
                  json['latestRevision'] as Map<String, dynamic>)
              : null,
    );
  }

  PublicXuanChartAttachment? _chartFromJson(dynamic raw) {
    if (raw is! Map) return null;
    final m = raw.cast<String, dynamic>();
    return PublicXuanChartAttachment(
      techniqueId: m['techniqueId'] as String? ?? 'unknown',
      schoolId: m['schoolId'] as String?,
      publicChartSnapshot: m['publicChartSnapshot'] as String? ?? '',
      rendererSchemaVersion: m['rendererSchemaVersion'] as int? ?? 1,
      source: PlaygroundChartSource.values.byName(
          m['source'] as String? ?? 'createdInPlayground'),
    );
  }

  List<PublicMediaAttachment> _mediaListFromJson(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((m) {
      final mm = m.cast<String, dynamic>();
      return PublicMediaAttachment(
        type: PlaygroundAttachmentType.values.byName(
            mm['type'] as String? ?? 'image'),
        mediaObjectId:
            PlaygroundAttachmentId(mm['mediaObjectId'] as String? ?? ''),
        mimeType: mm['mimeType'] as String? ?? '',
        width: mm['width'] as int?,
        height: mm['height'] as int?,
        durationSeconds: mm['durationSeconds'] as int?,
        secureUrl: mm['secureUrl'] as String? ?? '',
      );
    }).toList();
  }

  PublicAuthor _authorFromJson(dynamic raw) {
    final m = (raw as Map?)?.cast<String, dynamic>() ?? const {};
    return PublicAuthor(
      publicPresentationUserId:
          PlaygroundUserId(m['publicPresentationUserId'] as String? ?? ''),
      displayAlias: m['displayAlias'] as String? ?? '',
      avatarUrl: m['avatarUrl'] as String?,
      publicProfileRef: m['publicProfileRef'] as String?,
    );
  }

  PlaygroundRegistrationUnlockMetadata _registrationUnlockFromJson(dynamic raw) {
    if (raw is! Map) return const PlaygroundRegistrationUnlockMetadata();
    final m = raw.cast<String, dynamic>();
    return PlaygroundRegistrationUnlockMetadata(
      requiresRegistration: m['requiresRegistration'] != false,
      ctaMessageKey: m['ctaMessageKey'] as String?,
      unlockRoute: m['unlockRoute'] as String?,
    );
  }

  PublicFeedbackSummary? _feedbackFromJson(dynamic raw) {
    if (raw is! Map) return null;
    final m = raw.cast<String, dynamic>();
    return PublicFeedbackSummary(
      body: m['body'] as String? ?? '',
      isEdited: m['isEdited'] == true,
      publishedAt: DateTime.parse(
          m['publishedAt'] as String? ?? '1970-01-01T00:00:00.000Z'),
      updatedAt: m['updatedAt'] != null
          ? DateTime.parse(m['updatedAt'] as String)
          : null,
    );
  }

  PlaygroundRevisionSummary _revisionFromJson(Map<String, dynamic> m) {
    return PlaygroundRevisionSummary(
      editedByAlias: m['editedByAlias'] as String? ?? '',
      editedAt: DateTime.parse(
          m['editedAt'] as String? ?? '1970-01-01T00:00:00.000Z'),
      changeDescription: m['changeDescription'] as String?,
    );
  }

  // ---- Firestore doc（snake_case）→ DTO（直连查询路径）----

  PublicReply _publicReplyFromDoc(Map<String, dynamic> d, String docId) {
    return PublicReply(
      publicReplyId: PlaygroundReplyId(docId),
      postId: PlaygroundPostId(d['post_id'] as String? ?? ''),
      body: d['body'] as String?,
      techniqueTags:
          (d['technique_tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      chart: _chartFromDoc(d['chart_attachment']),
      mediaAttachments: _mediaListFromDoc(d['media_attachments']),
      author: _authorFromDoc(d),
      depth: d['depth'] as int? ?? 0,
      rootReplyId: d['root_reply_id'] != null
          ? PlaygroundReplyId(d['root_reply_id'] as String)
          : null,
      replyToReplyId: d['reply_to_reply_id'] != null
          ? PlaygroundReplyId(d['reply_to_reply_id'] as String)
          : null,
      isVerified: d['verification'] != null,
      isTombstoned: d['is_tombstoned'] == true,
      presentationMode: PlaygroundPresentationMode.stableAlias,
      createdAt: _toDateTime(d['created_at']) ?? DateTime.now(),
      updatedAt: _toDateTime(d['updated_at']),
      latestRevision: _revisionFromDoc(d['revisions']),
    );
  }

  PublicXuanChartAttachment? _chartFromDoc(dynamic raw) {
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

  List<PublicMediaAttachment> _mediaListFromDoc(dynamic raw) {
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

  PublicAuthor _authorFromDoc(Map<String, dynamic> d) {
    final presentationId = d['presentation_identity_id'] as String? ?? '';
    final resolved = presentationId.isNotEmpty
        ? presentationId
        : _derivePresentationId(d['author_provider_uid'] as String? ?? '');
    return PublicAuthor(
      publicPresentationUserId: PlaygroundUserId(resolved),
      displayAlias: '盘友${resolved.length > 6 ? resolved.substring(resolved.length - 6) : resolved}',
      avatarUrl: null,
      publicProfileRef: null,
    );
  }

  PlaygroundRevisionSummary? _revisionFromDoc(dynamic raw) {
    if (raw is! List || raw.isEmpty) return null;
    final last = raw.last;
    if (last is! Map) return null;
    final m = last.cast<String, dynamic>();
    return PlaygroundRevisionSummary(
      editedByAlias: m['edited_by'] as String? ?? '',
      editedAt: _toDateTime(m['edited_at']) ?? DateTime.now(),
      changeDescription: m['change_description'] as String?,
    );
  }

  PublicPost _publicPostFromDoc(
    String postId,
    Map<String, dynamic> d, {
    required int replyCount,
    required int likeCount,
    required int verificationCount,
    required PlaygroundPostViewerState viewerState,
    required PublicFeedbackSummary? outcomeFeedback,
  }) {
    final status = d['status'] as String? ?? 'unavailable';
    return PublicPost(
      publicPostId: PlaygroundPostId(postId),
      body: status == 'active' ? d['text'] as String? : null,
      attachments: _attachmentsFromDoc(d['attachments']),
      author: _authorFromDoc(d),
      replyCount: replyCount,
      likeCount: likeCount,
      verificationCount: verificationCount,
      viewerState: viewerState,
      outcomeFeedback: outcomeFeedback,
      displayStatus: switch (status) {
        'active' => PublicPostDisplayStatus.active,
        'tombstoned' => PublicPostDisplayStatus.tombstoned,
        _ => PublicPostDisplayStatus.unavailable,
      },
      latestRevision: _revisionFromDoc(d['revisions']),
      createdAt: _toDateTime(d['created_at']) ?? DateTime.now(),
      updatedAt: _toDateTime(d['updated_at']),
    );
  }

  List<PublicAttachment> _attachmentsFromDoc(dynamic raw) {
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
          type: PlaygroundAttachmentType.values.byName(
              type ?? 'image'),
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

  PublicFeedbackSummary _feedbackFromDoc(Map<String, dynamic> d) {
    final publishedAt = _toDateTime(d['created_at']) ?? DateTime.now();
    final updatedAt = _toDateTime(d['updated_at']);
    return PublicFeedbackSummary(
      body: (d['outcome_description'] as String?) ?? d['body'] as String? ?? '',
      isEdited: updatedAt != null && updatedAt != publishedAt,
      publishedAt: publishedAt,
      updatedAt: updatedAt,
    );
  }

  // ---- helpers ----

  static PlaygroundPresentationMode? _modeFromString(String? mode) {
    if (mode == null) return null;
    for (final m in PlaygroundPresentationMode.values) {
      if (m.name == mode) return m;
    }
    return null;
  }

  static DateTime? _toDateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  static String _derivePresentationId(String providerUid) {
    final raw = providerUid.isEmpty ? 'anonymous' : providerUid;
    final hash = sha256.convert(utf8.encode(raw)).toString();
    return 'anon_${hash.substring(0, 8)}';
  }
}
