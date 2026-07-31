import 'dart:convert';

import 'package:repository_interface_divination_tag/repository_interface_divination_tag.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:repository_interface_xiang/repository_interface_xiang.dart';

/// Codec mapping the unified [XiangReading] aggregate to the shared
/// [RecordMeta] storage model (TDD-XG-07, unified History only).
///
/// One codec serves every Xiang method: `module=xiang`,
/// `category=divination`, and the per-record `divinationType=methodId`.
/// This codec deliberately does not know any methodId at construction
/// time — encode stamps `methodId` onto the record and decode always
/// rebuilds the aggregate generically, so an unknown future methodId
/// still decodes without a private fallback.
class XiangRecordCodec implements RecordModuleCodec<XiangReading> {
  @override
  String get module => 'xiang';

  @override
  String get category => 'divination';

  /// Xiang's `divinationType` is dynamic: it equals the `methodId` of each
  /// record. The codec is shared by all methods, so no single value exists
  /// here; the actual value is written onto every [RecordMeta] in [encode].
  @override
  String get divinationType => '';

  @override
  String uuidOf(XiangReading reading) => reading.uuid;

  @override
  XiangReading withUuid(XiangReading reading, String uuid) =>
      reading.copyWith(uuid: uuid);

  @override
  EncodedRecord encode(XiangReading reading, {required String scopeUid}) {
    final occurredAtUtc = reading.occurredAt.toUtc();
    final data = <String, dynamic>{
      'uuid': reading.uuid,
      'methodId': reading.methodId,
      'methodVersion': reading.methodVersion,
      'occurredAt': occurredAtUtc.toIso8601String(),
      'evidence': reading.evidence.map((e) => e.toJson()).toList(),
      'observations': reading.observations.map((o) => o.toJson()).toList(),
      'transforms': _transformsOf(reading),
      'tagSelections': reading.tagSelections.map((t) => t.toJson()).toList(),
      'judgments': <String, dynamic>{
        if (reading.shortJudgment != null)
          'short': reading.shortJudgment!.toJson(),
        if (reading.detailedJudgment != null)
          'detailed': reading.detailedJudgment!.toJson(),
      },
      'readingSchemaVersion': reading.readingSchemaVersion,
      'snapshots': reading.renderingSnapshots,
    };

    // The unified RecordMeta carries a searchable public projection
    // (question/detail/tag/directPredict/caseUuid/seekerUuid). The Xiang
    // aggregate does not model those fields yet, so they stay null here and
    // the codec maps only what the aggregate owns.
    final meta = RecordMeta(
      uuid: reading.uuid,
      scopeUid: scopeUid,
      module: module,
      category: category,
      divinationType: reading.methodId,
      occurredAtUtc: occurredAtUtc,
      moduleDataJson: jsonEncode(data),
      navParamsJson: jsonEncode({'recordUuid': reading.uuid}),
      createdAt: occurredAtUtc,
      rev: 1,
    );
    return (meta: meta, moduleData: data);
  }

  @override
  XiangReading decode(RecordMeta meta, Map<String, dynamic>? moduleData) {
    if (meta.module != module) {
      throw RecordCodecMismatch(
          message: 'module mismatch: expected $module but got ${meta.module}');
    }
    final d = moduleData ??
        (meta.moduleDataJson != null
            ? jsonDecode(meta.moduleDataJson!)
            : null);
    if (d is! Map<String, dynamic>) {
      throw const FormatException(
          'xiang moduleData is missing or not a JSON object');
    }

    final judgments =
        (d['judgments'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final snapshots = d['snapshots'] as Map<String, dynamic>?;

    return XiangReading(
      uuid: meta.uuid,
      methodId: meta.divinationType.isNotEmpty
          ? meta.divinationType
          : (d['methodId'] as String? ?? ''),
      methodVersion: d['methodVersion'] as int? ?? 1,
      occurredAt: (meta.occurredAtUtc ??
              DateTime.parse(d['occurredAt'] as String))
          .toUtc(),
      evidence: (d['evidence'] as List<dynamic>? ?? const [])
          .map((e) => XiangEvidence.fromJson(e as Map<String, dynamic>))
          .toList(),
      observations: (d['observations'] as List<dynamic>? ?? const [])
          .map((o) => XiangObservation.fromJson(o as Map<String, dynamic>))
          .toList(),
      tagSelections: (d['tagSelections'] as List<dynamic>? ?? const [])
          .map((t) => TagSelectionSnapshot.fromJson(t as Map<String, dynamic>))
          .toList(),
      shortJudgment: judgments['short'] == null
          ? null
          : XiangJudgment.fromJson(judgments['short'] as Map<String, dynamic>),
      detailedJudgment: judgments['detailed'] == null
          ? null
          : XiangJudgment.fromJson(
              judgments['detailed'] as Map<String, dynamic>),
      readingSchemaVersion: d['readingSchemaVersion'] as int? ?? 1,
      renderingSnapshots: snapshots,
    );
  }

  @override
  List<SearchTag> extractSearchTags(
      RecordMeta meta, Map<String, dynamic>? moduleData) {
    final d = moduleData ??
        (meta.moduleDataJson != null
            ? jsonDecode(meta.moduleDataJson!)
            : null);
    if (d is! Map<String, dynamic>) return const <SearchTag>[];

    final tags = <SearchTag>[];
    final selections = d['tagSelections'] as List<dynamic>? ?? const [];
    for (final selection in selections) {
      if (selection is! Map<String, dynamic>) continue;
      final dimensionId = selection['dimensionId'] as String?;
      final selected = selection['selectedTags'] as List<dynamic>? ?? const [];
      for (final tag in selected) {
        if (tag is! Map<String, dynamic>) continue;
        final tagId = tag['tagId'] as String?;
        if (dimensionId != null && tagId != null) {
          tags.add(SearchTag(dimensionId, tagId));
        }
      }
    }
    return tags;
  }

  /// Extracts the media calibration transforms carried by [reading] so the
  /// moduleData keeps an explicit `transforms` projection of the rendering
  /// snapshots (overlay geometry and calibrated video observation).
  Map<String, dynamic>? _transformsOf(XiangReading reading) {
    final snapshots = reading.renderingSnapshots;
    if (snapshots == null || snapshots.isEmpty) return null;
    return <String, dynamic>{
      if (snapshots['overlay'] != null) 'overlay': snapshots['overlay'],
      if (snapshots['videoObservation'] != null)
        'videoObservation': snapshots['videoObservation'],
    };
  }
}
