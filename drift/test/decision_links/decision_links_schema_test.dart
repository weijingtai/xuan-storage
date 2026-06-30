import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';

void main() {
  late PersistenceDriftDatabase db;
  setUp(() {
    db = PersistenceDriftDatabase(NativeDatabase.memory());
  });
  tearDown(() async => await db.close());

  test('link_type defaults to sequential', () async {
    await db.decisionLinksDao.upsert(DecisionLinksCompanion.insert(
      id: 'schema-test-1',
      sourceUuid: 'src',
      targetUuid: 'tgt',
      intent: 'test',
      createdAtMs: 1000,
      updatedAtMs: 1000,
      scopeUid: 'scope',
    ));
    final got = await db.decisionLinksDao.getById('schema-test-1', 'scope');
    expect(got?.linkType, equals('sequential'));
  });

  test('session_id is nullable', () async {
    await db.decisionLinksDao.upsert(DecisionLinksCompanion.insert(
      id: 'schema-test-2',
      sourceUuid: 'src',
      targetUuid: 'tgt',
      intent: 'test',
      createdAtMs: 1000,
      updatedAtMs: 1000,
      scopeUid: 'scope',
    ));
    final got = await db.decisionLinksDao.getById('schema-test-2', 'scope');
    expect(got?.sessionId, isNull);
  });

  test('merge_target_uuid is nullable', () async {
    await db.decisionLinksDao.upsert(DecisionLinksCompanion.insert(
      id: 'schema-test-3',
      sourceUuid: 'src',
      targetUuid: 'tgt',
      intent: 'test',
      createdAtMs: 1000,
      updatedAtMs: 1000,
      scopeUid: 'scope',
    ));
    final got = await db.decisionLinksDao.getById('schema-test-3', 'scope');
    expect(got?.mergeTargetUuid, isNull);
  });

  test('inference_meta_json is nullable', () async {
    await db.decisionLinksDao.upsert(DecisionLinksCompanion.insert(
      id: 'schema-test-4',
      sourceUuid: 'src',
      targetUuid: 'tgt',
      intent: 'test',
      createdAtMs: 1000,
      updatedAtMs: 1000,
      scopeUid: 'scope',
    ));
    final got = await db.decisionLinksDao.getById('schema-test-4', 'scope');
    expect(got?.inferenceMetaJson, isNull);
  });

  test('existing data migration preserves old rows', () async {
    await db.decisionLinksDao.upsert(DecisionLinksCompanion.insert(
      id: 'schema-test-5',
      sourceUuid: 'src',
      targetUuid: 'tgt',
      intent: 'legacy',
      contextSnapshotJson: Value('{"old":"data"}'),
      createdAtMs: 500,
      updatedAtMs: 500,
      scopeUid: 'scope',
    ));
    final got = await db.decisionLinksDao.getById('schema-test-5', 'scope');
    expect(got?.id, equals('schema-test-5'));
    expect(got?.intent, equals('legacy'));
    expect(got?.contextSnapshotJson, equals('{"old":"data"}'));
  });
}
