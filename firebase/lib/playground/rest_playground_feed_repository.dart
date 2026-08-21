import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';

/// 游标失效或跨适配器不兼容异常（§6.2 RFC 9457）。
final class PlaygroundStaleCursorException implements Exception {
  const PlaygroundStaleCursorException({
    required this.message,
    this.reason = 'CURSOR_INVALID_OR_STALE',
    this.problemDetails,
  });

  final String message;
  final String reason;
  final Map<String, dynamic>? problemDetails;

  @override
  String toString() => 'PlaygroundStaleCursorException: $message ($reason)';
}

/// 基于 REST + ETag 条件请求的广场 Feed RemoteDataSource 实现（路线 2 专用端点）。
final class RestPlaygroundFeedRemoteDataSource
    implements PlaygroundFeedRemoteDataSource {
  RestPlaygroundFeedRemoteDataSource({
    required this.baseUrl,
    http.Client? client,
    Map<String, String>? initialEtagCache,
    Map<String, PlaygroundPage<PlaygroundPost>>? initialSnapshotCache,
  })  : _client = client ?? http.Client(),
        _etagCache = initialEtagCache != null
            ? Map.of(initialEtagCache)
            : <String, String>{},
        _snapshotCache = initialSnapshotCache != null
            ? Map.of(initialSnapshotCache)
            : <String, PlaygroundPage<PlaygroundPost>>{};

  final Uri baseUrl;
  final http.Client _client;
  final Map<String, String> _etagCache;
  final Map<String, PlaygroundPage<PlaygroundPost>> _snapshotCache;

  Uri _buildUri(String path, [Map<String, String>? queryParameters]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return baseUrl.replace(
      path: '${baseUrl.path.replaceAll(RegExp(r'/+$'), '')}$normalizedPath',
      queryParameters:
          queryParameters?.isEmpty ?? true ? null : queryParameters,
    );
  }

  @override
  Future<PlaygroundPage<PlaygroundPost>> getFeed(GetFeedQuery query) {
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
    return _queryFeed(GetFeedQuery(
      tab: PlaygroundFeedTab.recommended,
      filter: query.filter,
      cursor: query.cursor,
      limit: query.limit,
    ));
  }

  @override
  Future<PlaygroundPage<PlaygroundPost>> getPendingDivinationFeed(
      GetFeedQuery query) async {
    return _queryFeed(GetFeedQuery(
      tab: PlaygroundFeedTab.pendingDivination,
      filter: query.filter,
      cursor: query.cursor,
      limit: query.limit,
    ));
  }

  @override
  Future<PlaygroundPage<PlaygroundPost>> getLatestFeed(
      GetFeedQuery query) async {
    return _queryFeed(GetFeedQuery(
      tab: PlaygroundFeedTab.latest,
      filter: query.filter,
      cursor: query.cursor,
      limit: query.limit,
    ));
  }

  Future<PlaygroundPage<PlaygroundPost>> _queryFeed(GetFeedQuery query) async {
    final queryParams = <String, String>{
      'tab': query.tab.name,
      'limit': '${query.limit}',
      if (query.cursor != null && query.cursor!.isNotEmpty)
        'cursor': query.cursor!.token,
      if (query.filter.contentType != null)
        'contentType': query.filter.contentType!,
      if (query.filter.replyStatus != null)
        'replyStatus': query.filter.replyStatus!,
      if (query.filter.feedbackStatus != null)
        'feedbackStatus': query.filter.feedbackStatus!,
      if (query.filter.techniqueIds.isNotEmpty)
        'techniqueIds': query.filter.techniqueIds.take(10).join(','),
    };

    final cacheKey = '${query.tab.name}_${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    final uri = _buildUri('/playground/feed', queryParams);

    final cachedEtag = _etagCache[cacheKey] ?? _etagCache[query.tab.name];
    final headers = <String, String>{
      'accept': 'application/json',
      if (cachedEtag != null) 'if-none-match': cachedEtag,
    };

    final response = await _client.get(uri, headers: headers);

    if (response.statusCode == 304) {
      // 304 Not Modified: 命中 ETag，返回本地快照
      final cachedSnapshot = _snapshotCache[cacheKey] ?? _snapshotCache[query.tab.name];
      if (cachedSnapshot != null) {
        return cachedSnapshot;
      }
    }

    if (response.statusCode == 400) {
      Map<String, dynamic>? problem;
      try {
        problem = jsonDecode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>?;
      } catch (_) {}

      final reason = problem?['reason'] as String?;
      final detail = problem?['detail'] as String?;
      if (reason == 'CURSOR_INVALID_OR_STALE' ||
          (detail != null && detail.contains('cursor'))) {
        throw PlaygroundStaleCursorException(
          message: detail ?? 'Cursor invalid or stale',
          reason: reason ?? 'CURSOR_INVALID_OR_STALE',
          problemDetails: problem,
        );
      }
      throw Exception('REST 400 Bad Request: ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final etag = response.headers['etag'];
      if (etag != null) {
        _etagCache[cacheKey] = etag;
      }

      final json = jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
      final rawItems = json['items'] as List<dynamic>? ?? const [];
      final items = rawItems
          .whereType<Map<String, dynamic>>()
          .map(parsePostFromJson)
          .toList();

      final nextCursorStr = json['nextCursor'] as String?;
      final hasMore = json['hasMore'] as bool? ?? (nextCursorStr != null);
      final totalCount = json['totalCount'] as int? ?? -1;

      final page = PlaygroundPage(
        items: items,
        nextCursor: nextCursorStr != null && nextCursorStr.isNotEmpty
            ? PlaygroundCursor(nextCursorStr)
            : null,
        hasMore: hasMore,
        totalCount: totalCount,
      );

      _snapshotCache[cacheKey] = page;
      return page;
    }

    throw Exception('REST Feed request failed: HTTP ${response.statusCode}');
  }

  static PlaygroundPost parsePostFromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'active';
    final createdStr = json['createdAt'] as String? ?? json['created_at'];
    final updatedStr = json['updatedAt'] as String? ?? json['updated_at'];
    final appUserId = json['authorUserId'] as String? ??
        json['author_user_id'] as String? ??
        json['author_app_user_id'] as String? ??
        json['author_provider_uid'] as String? ??
        '';

    return PlaygroundPost(
      id: PlaygroundPostId(json['id'] as String? ?? ''),
      text: json['text'] as String? ?? '',
      authorUserId: PlaygroundUserId(appUserId),
      status: PlaygroundPostStatus.values.byName(statusStr),
      allowedChartTechniqueIds: (json['allowedChartTechniqueIds'] as List? ??
              json['allowed_chart_technique_ids'] as List?)
          ?.cast<String>() ??
          const <String>[],
      attachments: _parseAttachments(json['attachments']),
      revisions: _parseRevisions(json['revisions']),
      createdAt: createdStr != null
          ? DateTime.parse(createdStr)
          : DateTime.now(),
      updatedAt: updatedStr != null ? DateTime.parse(updatedStr) : null,
      hasOutcomeFeedback: json['hasOutcomeFeedback'] as bool? ??
          json['has_outcome_feedback'] as bool? ??
          false,
    );
  }

  static List<PlaygroundAttachment> _parseAttachments(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().map((m) {
      final typeStr = m['type'] as String? ?? 'image';
      final type = PlaygroundAttachmentType.values.byName(typeStr);
      final mediaIdStr = m['mediaObjectId'] as String? ??
          m['media_object_id'] as String?;
      final moderationStr = m['moderationState'] as String? ??
          m['moderation_state'] as String?;
      final moderationState = moderationStr != null
          ? PlaygroundModerationState.values.byName(moderationStr)
          : PlaygroundModerationState.pending;

      switch (type) {
        case PlaygroundAttachmentType.xuanChart:
          final chartSourceStr = m['chartSource'] as String? ??
              m['chart_source'] as String? ??
              'createdInPlayground';
          return PlaygroundAttachment.xuanChart(
            techniqueId: m['techniqueId'] as String? ??
                m['technique_id'] as String? ??
                '',
            schoolId: m['schoolId'] as String? ?? m['school_id'] as String?,
            publicChartSnapshot: m['publicChartSnapshot'] as String? ??
                m['public_chart_snapshot'] as String? ??
                '',
            rendererSchemaVersion: m['rendererSchemaVersion'] as int? ??
                m['renderer_schema_version'] as int? ??
                1,
            source: PlaygroundChartSource.values.byName(chartSourceStr),
          );
        case PlaygroundAttachmentType.image:
          return PlaygroundAttachment.image(
            mediaObjectId: PlaygroundAttachmentId(mediaIdStr ?? ''),
            mimeType: m['mimeType'] as String? ??
                m['mime_type'] as String? ??
                'image/png',
            width: m['width'] as int?,
            height: m['height'] as int?,
            moderationState: moderationState,
          );
        case PlaygroundAttachmentType.video:
          return PlaygroundAttachment.video(
            mediaObjectId: PlaygroundAttachmentId(mediaIdStr ?? ''),
            mimeType: m['mimeType'] as String? ??
                m['mime_type'] as String? ??
                'video/mp4',
            width: m['width'] as int?,
            height: m['height'] as int?,
            durationSeconds: m['durationSeconds'] as int? ??
                m['duration_seconds'] as int?,
            moderationState: moderationState,
          );
      }
    }).toList();
  }

  static List<PlaygroundRevision> _parseRevisions(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().map((rm) {
      final editedAtStr =
          rm['editedAt'] as String? ?? rm['edited_at'] as String?;
      return PlaygroundRevision(
        body: rm['body'] as String? ?? '',
        editedBy: rm['editedBy'] as String? ??
            rm['edited_by'] as String? ??
            '',
        editedAt: editedAtStr != null
            ? DateTime.parse(editedAtStr)
            : DateTime.now(),
        changeDescription: rm['changeDescription'] as String? ??
            rm['change_description'] as String?,
      );
    }).toList();
  }
}
