import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/xiang/xiang_record_codec.dart';
import 'package:repository_interface_divination_tag/repository_interface_divination_tag.dart';
import 'package:repository_interface_media/repository_interface_media.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:repository_interface_xiang/repository_interface_xiang.dart';

const _scopeUid = 'scope-1';

MediaReference _imageRef({String refId = 'img-1'}) => MediaReference(
      refId: refId,
      version: 3,
      role: MediaRole.evidenceImage,
      mimeType: 'image/jpeg',
      originalWidth: 1200,
      originalHeight: 1600,
      createdAtUtc: DateTime.utc(2026, 1, 2, 3, 4, 5),
    );

MediaReference _videoRef({String refId = 'vid-1'}) => MediaReference(
      refId: refId,
      version: 2,
      role: MediaRole.evidenceVideo,
      mimeType: 'video/mp4',
      originalWidth: 1920,
      originalHeight: 1080,
      durationMs: 45000,
      createdAtUtc: DateTime.utc(2026, 1, 3, 6, 7, 8),
    );

XiangEvidence _imageEvidence(int order, {String refId = 'img-1'}) =>
    XiangEvidence(order: order, role: 'image', mediaRef: _imageRef(refId: refId));

XiangEvidence _videoEvidence(int order) =>
    XiangEvidence(order: order, role: 'video', mediaRef: _videoRef());

XiangEvidence _textEvidence(int order) =>
    XiangEvidence(order: order, role: 'text', textContent: '姓名：张三');

XiangObservation _palaceObservation({String fieldId = 'p1', String text = '印堂明亮'}) =>
    XiangObservation(
        fieldId: fieldId, schemaVersion: 1, textSnapshot: text, type: 'palace');

XiangObservation _questionnaireObservation({String fieldId = 'q1'}) =>
    XiangObservation(
        fieldId: fieldId,
        schemaVersion: 1,
        textSnapshot: '答案',
        type: 'questionnaire');

XiangJudgment _manualJudgment({String text = '近期事业顺遂'}) => XiangJudgment(
    text: text,
    provenance: 'manual',
    isConfirmed: true,
    createdAt: DateTime.utc(2026, 1, 2, 8));

XiangJudgment _aiJudgment({String text = 'AI 草稿', bool isConfirmed = false}) =>
    XiangJudgment(
        text: text,
        provenance: 'ai',
        isConfirmed: isConfirmed,
        createdAt: DateTime.utc(2026, 1, 2, 9));

XiangOverlayTransform _overlay() => XiangOverlayTransform(
      imageTransform: const XiangTransform(
          translationX: 0.1,
          translationY: 0.2,
          scaleX: 1.25,
          scaleY: 1.5,
          rotation: 15.0),
      overlayTransform: const XiangTransform(
          translationX: 0.05,
          translationY: 0.06,
          scaleX: 0.9,
          scaleY: 0.9,
          rotation: 30.0),
      crop: const XiangNormalizedRect(x: 0.1, y: 0.1, width: 0.8, height: 0.8),
      viewport: const XiangNormalizedRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0),
      overlayOpacity: 0.75,
      overlayLockState: true,
      templateId: 'face-12-palace-v1',
      templateVersion: 2,
      originalMediaWidth: 1200,
      originalMediaHeight: 1600,
      coordinateFormatVersion: 1,
    );

KeyframeObservation _keyframe() => KeyframeObservation(
      sourceVideoRef: _videoRef(),
      positionMs: 12000,
      overlayTransform: _overlay(),
      observationText: '12 秒处纹路清晰',
    );

void main() {
  final codec = XiangRecordCodec();

  test('encode face-reading with image evidence, decode restores all fields',
      () {
    final reading = XiangReading(
      uuid: 'x-1',
      methodId: 'face-reading',
      methodVersion: 2,
      occurredAt: DateTime.utc(2026, 1, 2, 12, 30),
      evidence: [_imageEvidence(0), _textEvidence(1)],
      observations: [_palaceObservation(), _questionnaireObservation()],
      shortJudgment: _manualJudgment(),
    );
    final encoded = codec.encode(reading, scopeUid: _scopeUid);
    final decoded = codec.decode(encoded.meta, encoded.moduleData);
    expect(decoded, equals(reading));
    expect(decoded.evidence.map((e) => e.order).toList(), [0, 1]);
    expect(decoded.evidence.first.role, 'image');
    expect(decoded.evidence.first.mediaRef, equals(_imageRef()));
    expect(decoded.observations.map((o) => o.type).toList(),
        ['palace', 'questionnaire']);
  });

  test(
      'encode palm-reading with video evidence and keyframes, decode restores all',
      () {
    final reading = XiangReading(
      uuid: 'x-2',
      methodId: 'palm-reading',
      methodVersion: 1,
      occurredAt: DateTime.utc(2026, 1, 3),
      evidence: [_videoEvidence(0)],
      observations: [_palaceObservation(fieldId: 'palm-1', text: '生命线清晰')],
      renderingSnapshots: {
        'videoObservation': {
          'timeRangeStartMs': 0,
          'timeRangeEndMs': 45000,
          'keyframes': [_keyframe().toJson()],
        },
      },
    );
    final encoded = codec.encode(reading, scopeUid: _scopeUid);
    final decoded = codec.decode(encoded.meta, encoded.moduleData);
    expect(decoded, equals(reading));
    expect(decoded.evidence.single.role, 'video');
    expect(decoded.evidence.single.mediaRef?.role, MediaRole.evidenceVideo);
    expect(decoded.evidence.single.mediaRef?.durationMs, 45000);
    final videoSnapshot =
        decoded.renderingSnapshots!['videoObservation'] as Map<String, dynamic>;
    expect(videoSnapshot['keyframes'], equals([_keyframe().toJson()]));
  });

  test('encode reading with tagSelections, decode restores dimension grouping',
      () {
    final reading = XiangReading(
      uuid: 'x-3',
      methodId: 'face-reading',
      methodVersion: 1,
      occurredAt: DateTime.utc(2026, 1, 4),
      tagSelections: [
        TagSelectionSnapshot(dimensionId: 'fortune-palace', selectedTags: [
          TagSnapshot(
              tagId: 't-1',
              dimensionId: 'fortune-palace',
              text: '福禄',
              version: 3),
          TagSnapshot(
              tagId: 't-2',
              dimensionId: 'fortune-palace',
              text: '聚财',
              version: 1),
        ]),
        TagSelectionSnapshot(dimensionId: 'marriage-palace', selectedTags: [
          TagSnapshot(
              tagId: 't-5',
              dimensionId: 'marriage-palace',
              text: '桃花',
              version: 2),
        ]),
      ],
    );
    final encoded = codec.encode(reading, scopeUid: _scopeUid);
    final decoded = codec.decode(encoded.meta, encoded.moduleData);
    // TagSnapshot/TagSelectionSnapshot are plain value types without value
    // equality, so assert full-aggregate round-trip via the JSON projection
    // (deep value equality on plain maps) plus the field checks below.
    expect(decoded.toJson(), equals(reading.toJson()));
    expect(decoded.tagSelections, hasLength(2));
    expect(decoded.tagSelections.map((s) => s.dimensionId).toList(),
        ['fortune-palace', 'marriage-palace']);
    expect(decoded.tagSelections.first.selectedTags.map((t) => t.tagId).toList(),
        ['t-1', 't-2']);
    expect(decoded.tagSelections.first.selectedTags.first.text, '福禄');
    expect(decoded.tagSelections.first.selectedTags.first.version, 3);
  });

  test(
      'encode reading with overlay transforms, decode restores normalized params',
      () {
    final reading = XiangReading(
      uuid: 'x-4',
      methodId: 'face-reading',
      methodVersion: 1,
      occurredAt: DateTime.utc(2026, 1, 5),
      evidence: [_imageEvidence(0)],
      renderingSnapshots: {'overlay': _overlay().toJson()},
    );
    final encoded = codec.encode(reading, scopeUid: _scopeUid);
    final decoded = codec.decode(encoded.meta, encoded.moduleData);
    expect(decoded, equals(reading));
    final overlayJson =
        decoded.renderingSnapshots!['overlay'] as Map<String, dynamic>;
    expect((overlayJson['imageTransform'] as Map)['translationX'], 0.1);
    expect((overlayJson['imageTransform'] as Map)['scaleY'], 1.5);
    expect((overlayJson['overlayTransform'] as Map)['rotation'], 30.0);
    expect((overlayJson['crop'] as Map)['width'], 0.8);
    expect(overlayJson['overlayOpacity'], 0.75);
    expect(overlayJson['overlayLockState'], true);
    expect(overlayJson['originalMediaWidth'], 1200);
    expect(overlayJson['originalMediaHeight'], 1600);
    expect(overlayJson['coordinateFormatVersion'], 1);
  });

  test(
      'encode reading with AI judgment, decode restores provenance and '
      'confirmation state', () {
    final reading = XiangReading(
      uuid: 'x-5',
      methodId: 'face-reading',
      methodVersion: 1,
      occurredAt: DateTime.utc(2026, 1, 6),
      shortJudgment: _manualJudgment(),
      detailedJudgment: _aiJudgment(),
    );
    final encoded = codec.encode(reading, scopeUid: _scopeUid);
    final decoded = codec.decode(encoded.meta, encoded.moduleData);
    expect(decoded, equals(reading));
    expect(decoded.shortJudgment?.provenance, 'manual');
    expect(decoded.shortJudgment?.isConfirmed, isTrue);
    expect(decoded.detailedJudgment?.provenance, 'ai');
    expect(decoded.detailedJudgment?.isConfirmed, isFalse);
    expect(decoded.detailedJudgment?.createdAt, _aiJudgment().createdAt);
  });

  test('decode with unknown methodId degrades gracefully', () {
    final reading = XiangReading(
      uuid: 'x-6',
      methodId: 'future-method-9',
      methodVersion: 1,
      occurredAt: DateTime.utc(2026, 1, 7),
      evidence: [_textEvidence(0)],
    );
    final encoded = codec.encode(reading, scopeUid: _scopeUid);
    // A record whose divinationType is a methodId this build does not know
    // must still decode through the shared codec without crashing.
    final unknownMeta = RecordMeta(
      uuid: encoded.meta.uuid,
      scopeUid: encoded.meta.scopeUid,
      module: encoded.meta.module,
      category: encoded.meta.category,
      divinationType: 'not-yet-known-method',
      createdAt: encoded.meta.createdAt,
      occurredAtUtc: encoded.meta.occurredAtUtc,
      moduleDataJson: encoded.meta.moduleDataJson,
    );
    final decoded = codec.decode(unknownMeta, null);
    expect(decoded.methodId, 'not-yet-known-method');
    expect(decoded.evidence, hasLength(1));
    expect(decoded.evidence.first.role, 'text');
  });

  test('decode with corrupt moduleData raises a clear error', () {
    final corruptJson = RecordMeta(
      uuid: 'x-7',
      scopeUid: _scopeUid,
      module: 'xiang',
      category: 'divination',
      divinationType: 'face-reading',
      createdAt: DateTime.utc(2026, 1, 8),
      moduleDataJson: 'this is not json',
    );
    expect(() => codec.decode(corruptJson, null),
        throwsA(isA<FormatException>()));

    final corruptStructure = RecordMeta(
      uuid: 'x-7b',
      scopeUid: _scopeUid,
      module: 'xiang',
      category: 'divination',
      divinationType: 'face-reading',
      createdAt: DateTime.utc(2026, 1, 8),
      moduleDataJson: jsonEncode({
        'uuid': 'x-7b',
        'methodId': 'face-reading',
        'methodVersion': 1,
        'occurredAt': '2026-01-08T00:00:00.000Z',
        'evidence': 'not-a-list',
      }),
    );
    expect(() => codec.decode(corruptStructure, null), throwsA(anything));
  });

  test('record has module=xiang, category=divination, divinationType=methodId',
      () {
    final reading = XiangReading(
      uuid: 'x-8',
      methodId: 'palm-reading',
      methodVersion: 1,
      occurredAt: DateTime.utc(2026, 1, 9),
    );
    final encoded = codec.encode(reading, scopeUid: _scopeUid);
    expect(encoded.meta.module, 'xiang');
    expect(encoded.meta.category, 'divination');
    expect(encoded.meta.divinationType, 'palm-reading');
    expect(encoded.meta.uuid, 'x-8');
    expect(encoded.meta.scopeUid, _scopeUid);
    expect(encoded.meta.occurredAtUtc, reading.occurredAt.toUtc());
  });

  test('codec round-trip through real Drift database loses no semantics',
      () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final ds = DriftRecordDataSource(db, scopeUid: _scopeUid);
    final repo = LocalRecordRepository(ds, RecordAdapterRegistry([codec]));

    final reading = XiangReading(
      uuid: 'x-9',
      methodId: 'face-reading',
      methodVersion: 2,
      occurredAt: DateTime.utc(2026, 1, 10, 12),
      evidence: [_imageEvidence(0), _videoEvidence(1), _textEvidence(2)],
      observations: [_palaceObservation(), _questionnaireObservation()],
      tagSelections: [
        TagSelectionSnapshot(dimensionId: 'd1', selectedTags: [
          TagSnapshot(tagId: 't1', dimensionId: 'd1', text: '甲', version: 2),
        ]),
      ],
      shortJudgment: _manualJudgment(),
      detailedJudgment: _aiJudgment(),
      readingSchemaVersion: 2,
      renderingSnapshots: {'overlay': _overlay().toJson()},
    );

    final encoded = codec.encode(reading, scopeUid: _scopeUid);
    await repo.saveRecord(encoded.meta, moduleData: encoded.moduleData);

    final meta = await repo.getRecord('x-9', module: 'xiang');
    expect(meta, isNotNull);
    expect(meta!.module, 'xiang');
    expect(meta.category, 'divination');
    expect(meta.divinationType, 'face-reading');
    expect(meta.occurredAtUtc, reading.occurredAt.toUtc());

    // moduleDataJson round-trips through the real DB, so decode(meta, null)
    // restores the full aggregate. tagSelections are plain value types without
    // value equality, so compare via the JSON projection (deep value equality
    // on plain maps).
    final restored = codec.decode(meta, null);
    expect(restored.toJson(), equals(reading.toJson()));
  });

  test('uuidOf and withUuid manage the record uuid', () {
    final reading = XiangReading(
      uuid: 'x-a',
      methodId: 'face-reading',
      methodVersion: 1,
      occurredAt: DateTime.utc(2026, 1, 11),
    );
    expect(codec.uuidOf(reading), 'x-a');
    final updated = codec.withUuid(reading, 'x-b');
    expect(codec.uuidOf(updated), 'x-b');
    expect(updated.methodId, 'face-reading');
    expect(updated.evidence, isEmpty);
  });

  test('decode with mismatched module throws RecordCodecMismatch', () {
    final reading = XiangReading(
      uuid: 'x-c',
      methodId: 'face-reading',
      methodVersion: 1,
      occurredAt: DateTime.utc(2026, 1, 12),
    );
    final encoded = codec.encode(reading, scopeUid: _scopeUid);
    final badMeta = RecordMeta(
      uuid: encoded.meta.uuid,
      scopeUid: encoded.meta.scopeUid,
      module: 'liuyao',
      category: encoded.meta.category,
      divinationType: encoded.meta.divinationType,
      createdAt: encoded.meta.createdAt,
    );
    expect(() => codec.decode(badMeta, encoded.moduleData),
        throwsA(isA<RecordCodecMismatch>()));
  });

  test('extractSearchTags emits dimension/tag search tags', () {
    final reading = XiangReading(
      uuid: 'x-d',
      methodId: 'face-reading',
      methodVersion: 1,
      occurredAt: DateTime.utc(2026, 1, 13),
      tagSelections: [
        TagSelectionSnapshot(dimensionId: 'fortune-palace', selectedTags: [
          TagSnapshot(
              tagId: 't-1',
              dimensionId: 'fortune-palace',
              text: '福禄',
              version: 3),
        ]),
      ],
    );
    final encoded = codec.encode(reading, scopeUid: _scopeUid);
    final tags = codec.extractSearchTags(encoded.meta, encoded.moduleData);
    expect(tags, contains(const SearchTag('fortune-palace', 't-1')));
  });
}
