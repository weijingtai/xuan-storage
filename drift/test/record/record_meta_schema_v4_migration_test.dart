import 'package:sqlite3/sqlite3.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';

void main() {
  test('schema v4 rejects invalid record gender', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    // M should succeed
    await db.into(db.tRecordMeta).insert(
      TRecordMetaCompanion.insert(
        uuid: '1',
        scopeUid: 's1',
        module: 'm1',
        category: 'c1',
        divinationType: 'd1',
        createdAt: DateTime.now(),
        gender: const Value('M'),
      )
    );

    // null should succeed
    await db.into(db.tRecordMeta).insert(
      TRecordMetaCompanion.insert(
        uuid: '2',
        scopeUid: 's1',
        module: 'm1',
        category: 'c1',
        divinationType: 'd1',
        createdAt: DateTime.now(),
        gender: const Value(null),
      )
    );

    // X should fail
    expect(
      () => db.into(db.tRecordMeta).insert(
        TRecordMetaCompanion.insert(
          uuid: '3',
          scopeUid: 's1',
          module: 'm1',
          category: 'c1',
          divinationType: 'd1',
          createdAt: DateTime.now(),
          gender: const Value('X'),
        )
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('schema v3 opens as v4 with public columns', () async {
    final sqliteDb = sqlite3.openInMemory();
    sqliteDb.execute('''
      CREATE TABLE t_record_meta (
        uuid TEXT NOT NULL PRIMARY KEY,
        scope_uid TEXT NOT NULL,
        module TEXT NOT NULL,
        category TEXT NOT NULL,
        divination_type TEXT NOT NULL,
        case_uuid TEXT,
        work_item_uuid TEXT,
        seeker_uuid TEXT,
        question TEXT,
        detail TEXT,
        tag TEXT,
        direct_predict TEXT,
        verification_status TEXT,
        seeker_name TEXT,
        gender TEXT,
        fate_year TEXT,
        module_data_json TEXT,
        nav_params_json TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        deleted_at INTEGER,
        rev INTEGER NOT NULL DEFAULT 1
      );
      -- schema v5 起会 addColumn extras_json；真实 v3 库必有此表，
      -- 补建以便 from<5 迁移分支不因缺表失败。
      CREATE TABLE t_divination_cases (
        uuid TEXT NOT NULL PRIMARY KEY,
        title TEXT NOT NULL,
        main_question TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER,
        final_summary TEXT
      );
      PRAGMA user_version = 3;
    ''');

    final driftDb = PersistenceDriftDatabase(NativeDatabase.opened(sqliteDb));
    addTearDown(driftDb.close);

    // This will trigger the migration
    final records = await driftDb.select(driftDb.tRecordMeta).get();
    expect(records, isEmpty);

    // Verify we can insert using the new columns
    await driftDb.into(driftDb.tRecordMeta).insert(
      TRecordMetaCompanion.insert(
        uuid: 'uuid1',
        scopeUid: 'scope',
        module: 'm',
        category: 'c',
        divinationType: 'dt',
        createdAt: DateTime.now(),
        occurredAtUtc: Value(DateTime.now()),
        reckoningType: const Value('manual'),
        timezoneStr: const Value('Asia/Shanghai'),
        latitude: const Value(39.9),
        longitude: const Value(116.4),
        locationName: const Value('Beijing'),
        spacetimeJson: const Value('{}'),
      )
    );

    final inserted = await driftDb.select(driftDb.tRecordMeta).getSingle();
    expect(inserted.timezoneStr, 'Asia/Shanghai');
  });
}
