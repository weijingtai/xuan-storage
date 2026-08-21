import 'dart:convert';
import 'package:drift/drift.dart';
import 'taiyi_database.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import 'package:taiyishenshu/taiyi/taiyi.dart' show TaiYiSchool, DeityDefinition;
import 'drift_user_mapper.dart';

class DriftUserRepository implements SchoolRepository, UserSchoolRepository, DeityRepository {
  final TaiYiDatabase db;
  final String? scopeUid;

  DriftUserRepository(this.db, {this.scopeUid});

  @override
  Future<List<TaiYiSchoolContract>> loadAllSchools() async {
    final query = db.select(db.userSchools);
    if (scopeUid != null) {
      query.where((t) => t.scopeUid.equals(scopeUid!) | t.scopeUid.isNull());
    }
    final rows = await query.get();
    return rows.map((row) => TaiYiSchool.fromJson(jsonDecode(row.contentJson)).toContract()).toList();
  }

  @override
  Future<List<TaiYiSchoolContract>> loadUserSchools() async {
    final query = db.select(db.userSchools);
    if (scopeUid != null) {
      query.where((t) => t.scopeUid.equals(scopeUid!));
    }
    final rows = await query.get();
    return rows.map((row) => TaiYiSchool.fromJson(jsonDecode(row.contentJson)).toContract()).toList();
  }

  @override
  Future<TaiYiSchoolContract?> loadSchool(String id) async {
    final query = db.select(db.userSchools)..where((t) => t.id.equals(id));
    if (scopeUid != null) {
      query.where((t) => t.scopeUid.equals(scopeUid!) | t.scopeUid.isNull());
    }
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return TaiYiSchool.fromJson(jsonDecode(row.contentJson)).toContract();
  }

  @override
  Future<List<DeityDefinitionContract>> loadAllDeities() async {
    final query = db.select(db.userDeities);
    if (scopeUid != null) {
      query.where((t) => t.scopeUid.equals(scopeUid!) | t.scopeUid.isNull());
    }
    final rows = await query.get();
    return rows.map((row) => DeityDefinition.fromJson(jsonDecode(row.contentJson)).toContract()).toList();
  }

  @override
  Future<List<DeityDefinitionContract>> loadUserDeities() async {
    final query = db.select(db.userDeities);
    if (scopeUid != null) {
      query.where((t) => t.scopeUid.equals(scopeUid!));
    }
    final rows = await query.get();
    return rows.map((row) => DeityDefinition.fromJson(jsonDecode(row.contentJson)).toContract()).toList();
  }

  @override
  Future<DeityDefinitionContract?> loadDeity(String id) async {
    final query = db.select(db.userDeities)..where((t) => t.id.equals(id));
    if (scopeUid != null) {
      query.where((t) => t.scopeUid.equals(scopeUid!) | t.scopeUid.isNull());
    }
    final row = await query.getSingleOrNull();
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
        scopeUid: Value(scopeUid),
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
        scopeUid: Value(scopeUid),
      ),
    );
  }

  @override
  Future<void> saveUserDeity(DeityDefinitionContract deity) async => saveDeity(deity);

  @override
  Future<void> deleteSchool(String id) async {
    final query = db.delete(db.userSchools)..where((t) => t.id.equals(id));
    if (scopeUid != null) {
      query.where((t) => t.scopeUid.equals(scopeUid!));
    }
    await query.go();
  }

  @override
  Future<void> deleteUserSchool(String id) async => deleteSchool(id);

  @override
  Future<void> deleteDeity(String id) async {
    final query = db.delete(db.userDeities)..where((t) => t.id.equals(id));
    if (scopeUid != null) {
      query.where((t) => t.scopeUid.equals(scopeUid!));
    }
    await query.go();
  }

  @override
  Future<void> deleteUserDeity(String id) async => deleteDeity(id);
}
