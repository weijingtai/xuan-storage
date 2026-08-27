import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/xiang/xiang_record_codec.dart';
import 'package:persistence_drift/xiang/xiang_reading_repository_impl.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_divination_tag/repository_interface_divination_tag.dart';
import 'package:repository_interface_media/repository_interface_media.dart';
import 'package:repository_interface_xiang/repository_interface_xiang.dart';

const _scopeUid = 'scope-1';

RequestContext _ctx([String scope = _scopeUid]) => RequestContext(scopeUid: scope);

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
  Future<Result<XiangReading?>> get(String id, RequestContext ctx) async =>
      Ok(_store[id]);

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async =>
      Ok(_store.containsKey(id));

  @override
  Future<Result<Rev>> put(XiangReading entity, RequestContext ctx,
      {Precondition pre = const Unconditional()}) async {
    _store[entity.uuid] = entity;
    return Ok(Rev(entity.uuid));
  }

  @override
  Future<Result<void>> softDelete(String id, RequestContext ctx,
      {Precondition pre = const Unconditional()}) async {
    _store.remove(id);
    return const Ok(null);
  }

  @override
  Future<Result<void>> restore(String id, RequestContext ctx) async =>
      const Ok(null);

  @override
  Future<Result<XiangReading?>> getIncludingDeleted(
      String id, RequestContext ctx) async => Ok(_store[id]);

  @override
  Future<Result<Page<XiangReading>>> query(
      Map<String, Object?> spec, PageRequest page, RequestContext ctx) async =>
      Ok(Page(items: _store.values.toList()));

  @override
  Future<Result<int>> count(
      Map<String, Object?> spec, RequestContext ctx) async =>
      Ok(_store.length);

  @override
  Future<Result<BatchOutcome<String>>> putAll(
      List<XiangReading> entities, RequestContext ctx) async {
    for (final e in entities) { _store[e.uuid] = e; }
    return Ok(BatchOutcome(entities.map((e) => (id: e.uuid, result: const Ok(Rev('')))).toList()));
  }

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async =>
      Ok(await body());
}

/// Helper: put + unwrap
Future<XiangReading> _save(XiangReadingRepository repo, XiangReading reading) async {
  final ctx = _ctx();
  final r = await repo.put(reading, ctx);
  switch (r) {
    case Ok(:final value):
      return reading;
    case Err(:final error):
      throw error;
  }
}

/// Helper: get + unwrap
Future<XiangReading?> _load(XiangReadingRepository repo, String uuid) async {
  final r = await repo.get(uuid, _ctx());
  switch (r) {
    case Ok(:final value):
      return value;
    case Err(:final error):
      throw error;
  }
}

/// Helper: softDelete + unwrap
Future<void> _softDelete(XiangReadingRepository repo, String uuid) async {
  final r = await repo.softDelete(uuid, _ctx());
  switch (r) {
    case Ok():
      return;
    case Err(:final error):
      throw error;
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
    final saved = await _save(r.repo, reading);
    expect(saved.uuid, 'x-1');
    final loaded = await _load(r.repo, 'x-1');
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
    final saved = await _save(r.repo, reading);
    expect(saved.uuid, 'x-2');
    final loaded = await _load(r.repo, 'x-2');
    expect(loaded, isNotNull);
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
    await _save(r.repo, _reading('x-3'));
    expect(await _load(r.repo, 'x-3'), isNotNull);
    await _softDelete(r.repo, 'x-3');
    expect(await _load(r.repo, 'x-3'), isNull);
  });

  test('softDelete cascades media cleanup and records audit event (FA12)',
      () async {
    final r = _build();
    await _save(r.repo, _fullReading('x-fa12'));
    expect(await _load(r.repo, 'x-fa12'), isNotNull);

    await _softDelete(r.repo, 'x-fa12');

    expect(await _load(r.repo, 'x-fa12'), isNull);
  });

  test('listRecords with module=xiang shows all saved readings', () async {
    final r = _build();
    await _save(r.repo, _reading('x-4a', methodId: 'face-reading'));
    await _save(r.repo, _reading('x-4b', methodId: 'palm-reading'));
    await _save(r.repo, _reading('x-4c', methodId: 'face-reading'));

    final metas = await r.store.listRecords(module: 'xiang', limit: 50);
    expect(metas.map((m) => m.uuid).toSet(), {'x-4a', 'x-4b', 'x-4c'});
    expect(metas.every((m) => m.module == 'xiang'), isTrue);
    expect(metas.every((m) => m.category == 'divination'), isTrue);
    for (final meta in metas) {
      expect(await _load(r.repo, meta.uuid), isNotNull,
          reason: 'every record in the shared list must reopen through the repo');
    }
  });

  test('duplicate save with same uuid is idempotent (upsert)', () async {
    final r = _build();
    final first = _reading('x-5', shortJudgment: _manualJudgment(text: '第一版'));
    final second = _reading('x-5', shortJudgment: _manualJudgment(text: '第二版'));
    await _save(r.repo, first);
    await _save(r.repo, second);

    final metas = await r.store.listRecords(module: 'xiang', limit: 50);
    expect(metas, hasLength(1), reason: 'one uuid must map to one Record');
    final loaded = await _load(r.repo, 'x-5');
    expect(loaded, isNotNull);
    expect(loaded!.shortJudgment?.text, '第二版');
  });

  test(
      'storage adapter replacement: same contract, different impl, '
      'no behavior change', () async {
    final r = _build();
    final inMemory = _InMemoryXiangReadingRepository();
    final reading = _fullReading('x-9');

    for (final repo in <XiangReadingRepository>[r.repo, inMemory]) {
      final saved = await _save(repo, reading);
      expect(saved.uuid, 'x-9');
      final loaded = await _load(repo, 'x-9');
      expect(loaded, isNotNull);
      expect(loaded!.methodId, 'face-reading');
      expect(loaded.evidence, hasLength(3));
      expect(loaded.tagSelections.single.dimensionId, 'wu-xing');
      expect(loaded.shortJudgment?.isConfirmed, isTrue);
      await _softDelete(repo, 'x-9');
      expect(await _load(repo, 'x-9'), isNull);
    }

    expect(r.repo, isA<XiangReadingRepository>());
    expect(inMemory, isA<XiangReadingRepository>());
  });
}
