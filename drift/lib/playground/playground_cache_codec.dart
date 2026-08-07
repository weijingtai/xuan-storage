/// playground 缓存层的 DTO ↔ JSON 序列化（S2）。
///
/// 与 firebase 侧 `_attachmentToMap` / `_mapToAttachment` 同构，但本文件为
/// 纯 Dart（drift 包不依赖 cloud_firestore），供两张缓存表读写时重建
/// [PlaygroundPost] / [PlaygroundRootReply] / [PlaygroundDiscussionReply]。
library;

import 'dart:convert';

import 'package:repository_interface_playground/repository_interface_playground.dart';

/// 把附件列表序列化为 JSON 字符串。
String encodeAttachments(List<PlaygroundAttachment> attachments) {
  return jsonEncode(attachments.map(attachmentToMap).toList());
}

/// 从 JSON 字符串解析附件列表；null/空串 → 空列表。
List<PlaygroundAttachment> decodeAttachments(String? json) {
  if (json == null || json.isEmpty) return const [];
  final raw = jsonDecode(json);
  if (raw is! List) return const [];
  return raw
      .map((e) => mapToAttachment(e as Map<String, dynamic>))
      .toList();
}

/// 把单个附件序列化为 JSON 字符串；null → null。
String? encodeAttachment(PlaygroundAttachment? attachment) {
  if (attachment == null) return null;
  return jsonEncode(attachmentToMap(attachment));
}

/// 从 JSON 字符串解析单个附件；null/空串 → null。
PlaygroundAttachment? decodeAttachment(String? json) {
  if (json == null || json.isEmpty) return null;
  return mapToAttachment(jsonDecode(json) as Map<String, dynamic>);
}

/// 把修订历史序列化为 JSON 字符串。
String encodeRevisions(List<PlaygroundRevision> revisions) {
  return jsonEncode(revisions.map(revisionToMap).toList());
}

/// 从 JSON 字符串解析修订历史；null/空串 → 空列表。
List<PlaygroundRevision> decodeRevisions(String? json) {
  if (json == null || json.isEmpty) return const [];
  final raw = jsonDecode(json);
  if (raw is! List) return const [];
  return raw.map((e) => mapToRevision(e as Map<String, dynamic>)).toList();
}

/// 把字符串列表（如技法 id）序列化为 JSON 字符串。
String encodeStringList(List<String> values) => jsonEncode(values);

/// 从 JSON 字符串解析字符串列表；null/空串 → 空列表。
List<String> decodeStringList(String? json) {
  if (json == null || json.isEmpty) return const [];
  final raw = jsonDecode(json);
  if (raw is! List) return const [];
  return raw.cast<String>();
}

/// [PlaygroundAttachment] → Map（字段约定与 firebase `_attachmentToMap` 一致）。
Map<String, dynamic> attachmentToMap(PlaygroundAttachment a) {
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

/// Map → [PlaygroundAttachment]（判别联合，与 firebase `_mapToAttachment` 一致）。
PlaygroundAttachment mapToAttachment(Map<String, dynamic> m) {
  final typeStr = m['type'] as String? ?? 'image';
  final type = PlaygroundAttachmentType.values.byName(typeStr);
  final mediaIdStr = m['media_object_id'] as String?;
  final moderationStr = m['moderation_state'] as String?;
  final moderationState = moderationStr != null
      ? PlaygroundModerationState.values.byName(moderationStr)
      : PlaygroundModerationState.pending;

  switch (type) {
    case PlaygroundAttachmentType.xuanChart:
      final chartSourceStr =
          m['chart_source'] as String? ?? 'createdInPlayground';
      return PlaygroundAttachment.xuanChart(
        techniqueId: m['technique_id'] as String? ?? '',
        schoolId: m['school_id'] as String?,
        publicChartSnapshot: m['public_chart_snapshot'] as String? ?? '',
        rendererSchemaVersion: m['renderer_schema_version'] as int? ?? 1,
        source: PlaygroundChartSource.values.byName(chartSourceStr),
      );
    case PlaygroundAttachmentType.image:
      return PlaygroundAttachment.image(
        mediaObjectId: PlaygroundAttachmentId(mediaIdStr ?? ''),
        mimeType: m['mime_type'] as String? ?? 'image/png',
        width: m['width'] as int?,
        height: m['height'] as int?,
        moderationState: moderationState,
      );
    case PlaygroundAttachmentType.video:
      return PlaygroundAttachment.video(
        mediaObjectId: PlaygroundAttachmentId(mediaIdStr ?? ''),
        mimeType: m['mime_type'] as String? ?? 'video/mp4',
        width: m['width'] as int?,
        height: m['height'] as int?,
        durationSeconds: m['duration_seconds'] as int?,
        moderationState: moderationState,
      );
  }
}

/// [PlaygroundRevision] → Map。
Map<String, dynamic> revisionToMap(PlaygroundRevision r) {
  return {
    'body': r.body,
    'edited_by': r.editedBy,
    'edited_at': r.editedAt.millisecondsSinceEpoch,
    'change_description': r.changeDescription,
  };
}

/// Map → [PlaygroundRevision]。
PlaygroundRevision mapToRevision(Map<String, dynamic> m) {
  final editedAtRaw = m['edited_at'];
  return PlaygroundRevision(
    body: m['body'] as String? ?? '',
    editedBy: m['edited_by'] as String? ?? '',
    editedAt: editedAtRaw is int
        ? DateTime.fromMillisecondsSinceEpoch(editedAtRaw)
        : DateTime.now(),
    changeDescription: m['change_description'] as String?,
  );
}
