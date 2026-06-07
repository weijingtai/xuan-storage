import 'dart:convert';
import 'package:drift/drift.dart';
import 'taiyi_database.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:taiyishenshu/taiyi/taiyi.dart' show TaiYiSchool, DeityDefinition;
import 'drift_user_mapper.dart';

class DriftUserRepository implements SchoolRepository, UserSchoolRepository, DeityRepository {
  final TaiYiDatabase db;

  DriftUserRepository(this.db);

  @override
  Future<List<TaiYiSchoolContract>> loadAllSchools() async {
    final rows = await db.select(db.userSchools).get();
    return rows.map((row) => TaiYiSchool.fromJson(jsonDecode(row.contentJson)).toContract()).toList();
  }

  @override
  Future<List<TaiYiSchoolContract>> loadUserSchools() async => loadAllSchools();

  @override
  Future<TaiYiSchoolContract?> loadSchool(String id) async {
    final row = await (db.select(db.userSchools)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return TaiYiSchool.fromJson(jsonDecode(row.contentJson)).toContract();
  }

  @override
  Future<List<DeityDefinitionContract>> loadAllDeities() async {
    final rows = await db.select(db.userDeities).get();
    return rows.map((row) => DeityDefinition.fromJson(jsonDecode(row.contentJson)).toContract()).toList();
  }

  @override
  Future<List<DeityDefinitionContract>> loadUserDeities() async => loadAllDeities();

  @override
  Future<DeityDefinitionContract?> loadDeity(String id) async {
    final row = await (db.select(db.userDeities)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return DeityDefinition.fromJson(jsonDecode(row.contentJson)).toContract();
  }

  @override
  Future<void> saveSchool(TaiYiSchoolContract school) async {
    await db.into(db.userSchools).insertOnConflictUpdate(
      UserSchoolsCompanion(
        id: Value(school.id),
        name: Value(school.name),
        source: Value(school.source),
        contentJson: Value(jsonEncode(school.toModel().toJson())),
      ),
    );
  }

  @override
  Future<void> saveUserSchool(TaiYiSchoolContract school) async => saveSchool(school);

  @override
  Future<void> saveDeity(DeityDefinitionContract deity) async {
    await db.into(db.userDeities).insertOnConflictUpdate(
      UserDeitiesCompanion(
        id: Value(deity.id),
        name: Value(deity.name),
        source: Value(deity.source),
        contentJson: Value(jsonEncode(deity.toModel().toJson())),
      ),
    );
  }

  @override
  Future<void> saveUserDeity(DeityDefinitionContract deity) async => saveDeity(deity);

  @override
  Future<void> deleteSchool(String id) async {
    await (db.delete(db.userSchools)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> deleteUserSchool(String id) async => deleteSchool(id);

  @override
  Future<void> deleteDeity(String id) async {
    await (db.delete(db.userDeities)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> deleteUserDeity(String id) async => deleteDeity(id);
}
