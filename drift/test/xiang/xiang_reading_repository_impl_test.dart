import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/xiang/xiang_record_codec.dart';
import 'package:persistence_drift/xiang/xiang_reading_repository_impl.dart';
import 'package:repository_interface_divination_tag/repository_interface_divination_tag.dart';
import 'package:repository_interface_media/repository_interface_media.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:repository_interface_xiang/repository_interface_xiang.dart';

const _scopeUid = 'scope-1';

// ── fixtures (mirror xiang_record_codec_test.dart) ──

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

XiangReading _reading(
  String uuid, {
  String methodId = 'face-reading',
  XiangJudgment? shortJudgment,
}) =>
    XiangReading(
      uuid: uuid,
      methodId: methodId,
      methodVersion: 2,
      occurredAt: DateTime.utc(2026, 1, 2, 12, 30),
      shortJudgment: shortJudgment,
    );

XiangReading _fullReading(String uuid) => XiangReading(
      uuid: uuid,
      methodId: 'face-reading',
      methodVersion: 2,
      occurredAt: DateTime.utc(2026, 1, 3, 8, 30),
      evidence: [_imageEvidence(0), _videoEvidence(1), _textEvidence(2)],
      observations: [_palaceObservation(), _questionnaireObservation()],
      tagSelections: [
        TagSelectionSnapshot(dimensionId: 'wu-xing', selectedTags: [
          TagSnapshot(
              tagId: 'tag.wu-xing.jin',
              dimensionId: 'wu-xing',
              text: '金',
              version: 1),
          TagSnapshot(
              tagId: 'tag.wu-xing.mu',
              dimensionId: 'wu-xing',
              text: '木',
              version: 1),
        ]),
      ],
      shortJudgment: _manualJudgment(),
      detailedJudgment: _aiJudgment(),
      renderingSnapshots: {'overlay': _overlay().toJson()},
    );

/// In-memory [XiangReadingRepository] used by the storage-adapter-replacement
/// test (TDD-XG-09): the same contract, a different implementation, must show
/// no behavioral difference.
class _InMemoryXiangReadingRepository implements XiangReadingRepository {
  final Map<String, XiangReading> _store = {};

  @override
  Future<XiangReading> save(XiangReading reading) async {
    _store[reading.uuid] = reading;
    return reading;
  }

  @override
  Future<XiangReading?> load(String uuid) async => _store[uuid];

  @override
  Future<void> softDelete(String uuid) async {
    _store.remove(uuid);
  }
}

/// Builds a real Drift in-memory repository against the unified record store.
({XiangReadingRepositoryImpl repo, LocalRecordRepository store}) _build() {
  final db = PersistenceDriftDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  final ds = DriftRecordDataSource(db, scopeUid: _scopeUid);
  final codec = XiangRecordCodec();
  final store = LocalRecordRepository(ds, RecordAdapterRegistry([codec]));
  final repo = XiangReadingRepositoryImpl(store: store, codec: codec);
  return (repo: repo, store: store);
}

void main() {
  test('save reading, load by uuid, verify full round-trip', () async {
    final r = _build();
    final reading = _reading('x-1');
    final saved = await r.repo.save(reading);
    expect(saved.uuid, 'x-1');
    final loaded = await r.repo.load('x-1');
    expect(loaded, isNotNull);
    expect(loaded, equals(reading));
    expect(loaded!.methodId, 'face-reading');
    expect(loaded.methodVersion, 2);
    expect(loaded.occurredAt, reading.occurredAt);
  });

  test(
      'save reading with evidence, observations, tags, transforms, judgments '
      'round-trips all semantics', () async {
    final r = _build();
    final reading = _fullReading('x-2');
    final saved = await r.repo.save(reading);
    expect(saved.uuid, 'x-2');
    final loaded = await r.repo.load('x-2');
    expect(loaded, isNotNull);
    // TagSnapshot/TagSelectionSnapshot are plain value types without value
    // equality, so assert full-aggregate fidelity via the JSON projection.
    expect(loaded!.toJson(), equals(reading.toJson()));
    expect(loaded.evidence.map((e) => e.role).toList(),
        ['image', 'video', 'text']);
    expect(loaded.observations.map((o) => o.type).toList(),
        ['palace', 'questionnaire']);
    expect(loaded.tagSelections, hasLength(1));
    expect(loaded.tagSelections.first.dimensionId, 'wu-xing');
    expect(
        loaded.tagSelections.first.selectedTags.map((t) => t.text).toList(),
        ['金', '木']);
    expect(loaded.shortJudgment?.provenance, 'manual');
    expect(loaded.shortJudgment?.isConfirmed, isTrue);
    expect(loaded.detailedJudgment?.provenance, 'ai');
    expect(loaded.detailedJudgment?.isConfirmed, isFalse);
    final overlayJson =
        loaded.renderingSnapshots!['overlay'] as Map<String, dynamic>;
    expect(overlayJson['overlayOpacity'], 0.75);
    expect(overlayJson['coordinateFormatVersion'], 1);
  });

  test('softDelete reading, verify load returns null', () async {
    final r = _build();
    await r.repo.save(_reading('x-3'));
    expect(await r.repo.load('x-3'), isNotNull);
    await r.repo.softDelete('x-3');
    expect(await r.repo.load('x-3'), isNull);
  });

  test('softDelete cascades media cleanup and records audit event (FA12)',
      () async {
    final r = _build();
    // _fullReading 携带 2 个媒体证据（image + video）与 1 个文本证据。
    await r.repo.save(_fullReading('x-fa12'));
    expect(await r.repo.load('x-fa12'), isNotNull);

    await r.repo.softDelete('x-fa12');

    // 级联：删除后不可再加载。
    expect(await r.repo.load('x-fa12'), isNull);
    // 审计：必须记录删除事件，含媒体引用计数（>0），且不记录敏感内容本身。
    expect(r.repo.auditLogs, isNotEmpty);
    final event = r.repo.auditLogs.last;
    expect(event.operation, 'reading.delete');
    expect(event.recordedAt, isNotNull);
    expect(event.operatorUid, 'scope-1');
    expect(event.mediaRefCount, 2,
        reason: '_fullReading 引用 2 个媒体（image+video），删除须级联清除');
  });

  test('listRecords with module=xiang shows all saved readings', () async {
    final r = _build();
    await r.repo.save(_reading('x-4a', methodId: 'face-reading'));
    await r.repo.save(_reading('x-4b', methodId: 'palm-reading'));
    await r.repo.save(_reading('x-4c', methodId: 'face-reading'));

    final metas = await r.store.listRecords(module: 'xiang', limit: 50);
    expect(metas.map((m) => m.uuid).toSet(), {'x-4a', 'x-4b', 'x-4c'});
    expect(metas.every((m) => m.module == 'xiang'), isTrue);
    expect(metas.every((m) => m.category == 'divination'), isTrue);
    for (final meta in metas) {
      expect(await r.repo.load(meta.uuid), isNotNull,
          reason: 'every record in the shared list must reopen through the repo');
    }
  });

  test('duplicate save with same uuid is idempotent (upsert)', () async {
    final r = _build();
    final first = _reading('x-5', shortJudgment: _manualJudgment(text: '第一版'));
    final second = _reading('x-5', shortJudgment: _manualJudgment(text: '第二版'));
    await r.repo.save(first);
    await r.repo.save(second);

    final metas = await r.store.listRecords(module: 'xiang', limit: 50);
    expect(metas, hasLength(1), reason: 'one uuid must map to one Record');
    final loaded = await r.repo.load('x-5');
    expect(loaded, isNotNull);
    expect(loaded!.shortJudgment?.text, '第二版');
  });

  test(
      'storage adapter replacement: same contract, different impl, '
      'no behavior change', () async {
    final r = _build();
    final inMemory = _InMemoryXiangReadingRepository();
    final reading = _fullReading('x-9');

    // The identical scenario must behave identically through the Drift adapter
    // and a different implementation of the same port (TDD-XG-09).
    for (final repo in <XiangReadingRepository>[r.repo, inMemory]) {
      final saved = await repo.save(reading);
      expect(saved.uuid, 'x-9');
      final loaded = await repo.load('x-9');
      expect(loaded, isNotNull);
      expect(loaded!.methodId, 'face-reading');
      expect(loaded.evidence, hasLength(3));
      expect(loaded.tagSelections.single.dimensionId, 'wu-xing');
      expect(loaded.shortJudgment?.isConfirmed, isTrue);
      await repo.softDelete('x-9');
      expect(await repo.load('x-9'), isNull);
    }

    // Compile-time contract proof: the concrete Drift adapter satisfies the port.
    expect(r.repo, isA<XiangReadingRepository>());
    expect(inMemory, isA<XiangReadingRepository>());
  });
}
