import 'package:sqlite3/sqlite3.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';

// schema v4 → v5 迁移测试（T1 裁定：案例表增 extras_json 扩展位）
void main() {
  test('schema v4 opens as v5 with extras_json column', () async {
    final sqliteDb = sqlite3.openInMemory();
    // v4 版案例表（无 extras_json 列）
    sqliteDb.execute('''
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
      PRAGMA user_version = 4;
    ''');
    // 旧数据一行（extras_json 出现之前的案例）
    sqliteDb.execute(
      "INSERT INTO t_divination_cases "
      "(uuid, title, main_question, status, created_at, updated_at) "
      "VALUES ('c1', '旧案例', '测事', 'open', 1, 1)",
    );

    final driftDb = PersistenceDriftDatabase(NativeDatabase.opened(sqliteDb));
    addTearDown(driftDb.close);

    // 触发迁移：v4 → v5 应 addColumn，旧数据保留且新列为 null
    final cases = await driftDb.select(driftDb.divinationCases).get();
    expect(cases.length, 1);
    expect(cases.single.uuid, 'c1');
    expect(cases.single.extrasJson, isNull);

    // 新列可写读 round-trip
    await (driftDb.update(driftDb.divinationCases)
          ..where((t) => t.uuid.equals('c1')))
        .write(
      const DivinationCasesCompanion(
        extrasJson: Value('{"historyCaseExtras":{}}'),
      ),
    );
    final updated = await driftDb.select(driftDb.divinationCases).getSingle();
    expect(updated.extrasJson, '{"historyCaseExtras":{}}');
  });
}
