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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // 版本迁移逻辑
      },
    );
  }
}
