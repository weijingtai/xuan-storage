import 'package:drift/drift.dart';

import 'meihua_database.dart';
import 'meihua_gua_infos.dart';

part 'meihua_divinations_dao.g.dart';

/// 梅花易数起卦记录 DAO
@DriftAccessor(tables: [MeiHuaGuaInfos])
class MeiHuaDivinationsDao extends DatabaseAccessor<MeiHuaDatabase>
    with _$MeiHuaDivinationsDaoMixin {
  final String? scopeUid;
  MeiHuaDivinationsDao(super.db, {this.scopeUid});

  /// 获取所有起卦记录
  Future<List<MeiHuaGuaInfo>> getAllRecords({String? scopeUid}) {
    final effectiveScope = scopeUid ?? this.scopeUid;
    final query = select(db.meiHuaGuaInfos)..where((t) => t.deletedAt.isNull());
    if (effectiveScope != null) {
      query.where((t) => t.scopeUid.equals(effectiveScope));
    }
    return (query..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  }

  /// 监听起卦记录变化
  Stream<List<MeiHuaGuaInfo>> watchAllRecords({String? scopeUid}) {
    final effectiveScope = scopeUid ?? this.scopeUid;
    final query = select(db.meiHuaGuaInfos)..where((t) => t.deletedAt.isNull());
    if (effectiveScope != null) {
      query.where((t) => t.scopeUid.equals(effectiveScope));
    }
    return (query..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  /// 根据 UUID 获取起卦记录
  Future<MeiHuaGuaInfo?> getRecordByUuid(String uuid, {String? scopeUid}) {
    final effectiveScope = scopeUid ?? this.scopeUid;
    final query = select(db.meiHuaGuaInfos)..where((t) => t.uuid.equals(uuid));
    if (effectiveScope != null) {
      query.where((t) => t.scopeUid.equals(effectiveScope));
    }
    return query.getSingleOrNull();
  }

  /// 根据占卜 UUID 获取起卦记录
  Future<MeiHuaGuaInfo?> getRecordByDivinationUuid(
    String divinationUuid, {
    String? scopeUid,
  }) {
    final effectiveScope = scopeUid ?? this.scopeUid;
    final query = select(db.meiHuaGuaInfos)
      ..where((t) => t.divinationUuid.equals(divinationUuid))
      ..where((t) => t.deletedAt.isNull());
    if (effectiveScope != null) {
      query.where((t) => t.scopeUid.equals(effectiveScope));
    }
    return query.getSingleOrNull();
  }

  /// 插入起卦记录
  Future<int> insertRecord(MeiHuaGuaInfosCompanion companion) {
    if (scopeUid != null && !companion.scopeUid.present) {
      companion = companion.copyWith(scopeUid: Value(scopeUid));
    }
    return into(db.meiHuaGuaInfos).insert(companion);
  }

  /// 更新起卦记录
  Future<bool> updateRecord(
    String uuid,
    MeiHuaGuaInfosCompanion companion, {
    String? scopeUid,
  }) {
    final effectiveScope = scopeUid ?? this.scopeUid;
    final query = update(db.meiHuaGuaInfos)..where((t) => t.uuid.equals(uuid));
    if (effectiveScope != null) {
      query.where((t) => t.scopeUid.equals(effectiveScope));
    }
    return query.write(companion).then((count) => count > 0);
  }

  /// 软删除起卦记录
  Future<int> softDeleteRecord(String uuid, {String? scopeUid}) {
    final effectiveScope = scopeUid ?? this.scopeUid;
    final query = update(db.meiHuaGuaInfos)..where((t) => t.uuid.equals(uuid));
    if (effectiveScope != null) {
      query.where((t) => t.scopeUid.equals(effectiveScope));
    }
    return query.write(
      MeiHuaGuaInfosCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  /// 监听指定记录变化
  Stream<MeiHuaGuaInfo?> watchRecordByDivinationUuid(
    String divinationUuid, {
    String? scopeUid,
  }) {
    final effectiveScope = scopeUid ?? this.scopeUid;
    final query = select(db.meiHuaGuaInfos)
      ..where((t) => t.divinationUuid.equals(divinationUuid))
      ..where((t) => t.deletedAt.isNull());
    if (effectiveScope != null) {
      query.where((t) => t.scopeUid.equals(effectiveScope));
    }
    return query.watchSingleOrNull();
  }
}
