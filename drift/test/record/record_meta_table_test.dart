import 'package:drift/native.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fresh db has t_record_meta and indices', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.customStatement(
      "INSERT INTO t_record_meta(uuid,scope_uid,module,category,"
      "divination_type,created_at,rev) "
      "VALUES('r1','s1','meihua','divination','mei_hua',0,1)");
    final rows = await db.customSelect(
        "SELECT uuid FROM t_record_meta WHERE scope_uid='s1'").get();
    expect(rows.single.read<String>('uuid'), 'r1');
    final idx = await db.customSelect(
        "SELECT name FROM sqlite_master WHERE type='index' "
        "AND name='idx_record_meta_scope_created'").get();
    expect(idx, isNotEmpty);
  });
}
