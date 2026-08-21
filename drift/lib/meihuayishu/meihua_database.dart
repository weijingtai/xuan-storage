import 'package:drift/drift.dart';

import 'meihua_database_connection_stub.dart'
    if (dart.library.ffi) 'meihua_database_connection_native.dart';

import 'meihua_gua_infos.dart';

part 'meihua_database.g.dart';

/// 梅花易数数据库
/// 只包含梅花易数专用表
@DriftDatabase(tables: [
  MeiHuaGuaInfos,
])
class MeiHuaDatabase extends _$MeiHuaDatabase {
  MeiHuaDatabase([QueryExecutor? executor]) : super(executor ?? createMeihuaConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _createIndices();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          final cols = await customSelect(
            'SELECT name FROM pragma_table_info("t_meihua_gua_info")',
          ).get();
          if (!cols.any((r) => r.read<String>('name') == 'scope_uid')) {
            await m.addColumn(meiHuaGuaInfos, (meiHuaGuaInfos as $MeiHuaGuaInfosTable).scopeUid);
          }
          await _createIndices();
        }
      },
    );
  }

  Future<void> _createIndices() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_meihua_gua_info_scope ON t_meihua_gua_info(scope_uid)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_meihua_gua_info_divination ON t_meihua_gua_info(divination_uuid)',
    );
  }
}
