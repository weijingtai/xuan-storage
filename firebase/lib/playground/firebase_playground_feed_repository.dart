import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';
import 'package:persistence_core/persistence_core.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_error_mapper.dart';
import 'firebase_playground_cursor.dart';

final class FirebasePlaygroundFeedRepository
    implements PlaygroundFeedRemoteDataSource {
  FirebasePlaygroundFeedRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<PlaygroundPage<PlaygroundPost>> getFeed(GetFeedQuery query) async {
    switch (query.tab) {
      case PlaygroundFeedTab.recommended:
        return getRecommendedFeed(query);
      case PlaygroundFeedTab.pendingDivination:
        return getPendingDivinationFeed(query);
      case PlaygroundFeedTab.latest:
        return getLatestFeed(query);
    }
  }

  @override
  Future<PlaygroundPage<PlaygroundPost>> getRecommendedFeed(
      GetFeedQuery query) async {
    return _queryFeed(query, orderByField: 'recommendation_score',
        descending: true);
  }

  @override
  Future<PlaygroundPage<PlaygroundPost>> getPendingDivinationFeed(
      GetFeedQuery query) async {
    return _queryFeed(query, orderByField: 'created_at', descending: false,
        extraWhere: (q) => q.where('reply_status', isEqualTo: 'pending'),
    );
  }

  @override
  Future<PlaygroundPage<PlaygroundPost>> getLatestFeed(
      GetFeedQuery query) async {
    return _queryFeed(query, orderByField: 'created_at', descending: true);
  }

  Future<PlaygroundPage<PlaygroundPost>> _queryFeed(
    GetFeedQuery query, {
    required String orderByField,
    required bool descending,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>>)?
        extraWhere,
  }) async {
    try {
      var q = _firestore
          .collection(PlaygroundFirestoreSchema.posts)
          .where('status', isEqualTo: PlaygroundPostStatus.active.name);

      if (query.filter.contentType != null) {
        q = q.where('content_type', isEqualTo: query.filter.contentType);
      }
      if (query.filter.replyStatus != null) {
        q = q.where('reply_status', isEqualTo: query.filter.replyStatus);
      }
      if (query.filter.feedbackStatus != null) {
        q = q.where('feedback_status',
            isEqualTo: query.filter.feedbackStatus);
      }
      if (query.filter.techniqueIds.isNotEmpty) {
        final ids = query.filter.techniqueIds.take(10).toList();
        q = q.where('allowed_chart_technique_ids', arrayContainsAny: ids);
      }

      if (extraWhere != null) {
        q = extraWhere(q);
      }

      q = q.orderBy(orderByField, descending: descending).limit(query.limit);

      if (query.cursor != null && query.cursor!.isNotEmpty) {
        final startDoc = FirebasePlaygroundCursor.toDocumentReference(
            query.cursor!, _firestore);
        if (startDoc != null) {
          final startSnap = await startDoc.get();
          q = q.startAfterDocument(startSnap);
        }
      }

      final snaps = await q.get();
      final items = snaps.docs.map((doc) {
        return _docToPost(doc.data(), doc.id);
      }).toList();

      final nextCursor = snaps.docs.isNotEmpty && snaps.docs.length == query.limit
          ? FirebasePlaygroundCursor.fromQueryDocument(snaps.docs.last)
          : null;

      return PlaygroundPage(
        items: items,
        nextCursor: nextCursor,
        hasMore: nextCursor != null,
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  static PlaygroundPost _docToPost(Map<String, dynamic> d, String docId) {
    final statusStr = d['status'] as String? ?? PlaygroundPostStatus.active.name;
    final timestamp = d['created_at'] as Timestamp?;
    final updatedTs = d['updated_at'] as Timestamp?;
    final appUserId =
        d['author_app_user_id'] as String? ?? d['author_provider_uid'] as String? ?? '';

    return PlaygroundPost(
      id: PlaygroundPostId(docId),
      text: d['text'] as String? ?? '',
      authorUserId: PlaygroundUserId(appUserId),
      status: PlaygroundPostStatus.values.byName(statusStr),
      allowedChartTechniqueIds:
          (d['allowed_chart_technique_ids'] as List<dynamic>?)
                  ?.cast<String>() ??
              const <String>[],
      attachments: const [],
      revisions: const [],
      createdAt: timestamp?.toDate() ?? DateTime.now(),
      updatedAt: updatedTs?.toDate(),
      hasOutcomeFeedback: d['has_outcome_feedback'] as bool? ?? false,
    );
  }
}
