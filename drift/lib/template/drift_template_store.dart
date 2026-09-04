import 'package:drift/drift.dart';
import '../persistence_drift.dart';

/// 起卦模板与使用统计 Drift 存储访问层（纯 SQL/Drift 交互，强 scope 隔离）。
class DriftTemplateStore {
  const DriftTemplateStore(this.db);

  final PersistenceDriftDatabase db;

  /// 插入新模板记录
  Future<void> insertTemplate({
    required String uuid,
    required String scopeUid,
    required String templateId,
    required String name,
    required String category,
    required String origin,
    String? derivedFrom,
    required int version,
    required String definitionJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) async {
    await db.into(db.divinationTemplates).insert(
          DivinationTemplatesCompanion.insert(
            uuid: uuid,
            scopeUid: scopeUid,
            templateId: templateId,
            name: name,
            category: category,
            origin: origin,
            derivedFrom: Value(derivedFrom),
            version: version,
            definitionJson: definitionJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: Value(deletedAt),
          ),
        );
  }

  /// 更新模板（仅当 scope_uid 匹配）
  Future<int> updateTemplate({
    required String uuid,
    required String scopeUid,
    required String name,
    required String category,
    required int version,
    required String definitionJson,
    required DateTime updatedAt,
  }) async {
    return (db.update(db.divinationTemplates)
          ..where((t) => t.uuid.equals(uuid) & t.scopeUid.equals(scopeUid)))
        .write(
      DivinationTemplatesCompanion(
        name: Value(name),
        category: Value(category),
        version: Value(version),
        definitionJson: Value(definitionJson),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  /// 软删除模板（写入 deleted_at）
  Future<int> softDeleteTemplate({
    required String uuid,
    required String scopeUid,
    required DateTime deletedAt,
  }) async {
    return (db.update(db.divinationTemplates)
          ..where((t) => t.uuid.equals(uuid) & t.scopeUid.equals(scopeUid)))
        .write(
      DivinationTemplatesCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(deletedAt),
      ),
    );
  }

  /// 恢复已软删除的模板（deleted_at 设为 NULL）
  Future<int> restoreTemplate({
    required String uuid,
    required String scopeUid,
    DateTime? updatedAt,
  }) async {
    return (db.update(db.divinationTemplates)
          ..where((t) => t.uuid.equals(uuid) & t.scopeUid.equals(scopeUid)))
        .write(
      DivinationTemplatesCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(updatedAt ?? DateTime.now().toUtc()),
      ),
    );
  }

  /// 获取单条模板（scope 隔离）
  Future<DivinationTemplateRow?> getTemplate({
    required String uuid,
    required String scopeUid,
    bool includeDeleted = false,
  }) async {
    final query = db.select(db.divinationTemplates)
      ..where((t) => t.uuid.equals(uuid) & t.scopeUid.equals(scopeUid));
    if (!includeDeleted) {
      query.where((t) => t.deletedAt.isNull());
    }
    return query.getSingleOrNull();
  }

  /// 按 template_id (即 schema id) 获取单条模板
  Future<DivinationTemplateRow?> getTemplateByTemplateId({
    required String templateId,
    required String scopeUid,
    bool includeDeleted = false,
  }) async {
    final query = db.select(db.divinationTemplates)
      ..where(
          (t) => t.templateId.equals(templateId) & t.scopeUid.equals(scopeUid));
    if (!includeDeleted) {
      query.where((t) => t.deletedAt.isNull());
    }
    return query.getSingleOrNull();
  }

  /// 列表查询（强制带 scope_uid，默认过滤 deleted_at）
  Future<List<DivinationTemplateRow>> listTemplates({
    required String scopeUid,
    bool includeDeleted = false,
    String? category,
    String? keyword,
  }) async {
    final query = db.select(db.divinationTemplates)
      ..where((t) => t.scopeUid.equals(scopeUid));
    if (!includeDeleted) {
      query.where((t) => t.deletedAt.isNull());
    }
    if (category != null && category.trim().isNotEmpty) {
      query.where((t) => t.category.equals(category.trim()));
    }
    if (keyword != null && keyword.trim().isNotEmpty) {
      final kw = '%${keyword.trim()}%';
      query.where((t) => t.name.like(kw) | t.templateId.like(kw));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    return query.get();
  }

  /// 检查同 scope 内是否存在重名（重名警告用）
  Future<bool> hasDuplicateName({
    required String name,
    required String scopeUid,
    String? excludeUuid,
  }) async {
    final query = db.select(db.divinationTemplates)
      ..where((t) =>
          t.scopeUid.equals(scopeUid) &
          t.name.equals(name.trim()) &
          t.deletedAt.isNull());
    if (excludeUuid != null) {
      query.where((t) => t.uuid.equals(excludeUuid).not());
    }
    final rows = await query.get();
    return rows.isNotEmpty;
  }

  /// 统计写入：若不存在插入 use_count=1，若已存在 use_count += 1
  Future<void> recordUsageStat({
    required String templateUuid,
    required String scopeUid,
    required DateTime usedAt,
  }) async {
    final existing = await (db.select(db.templateUsageStats)
          ..where((t) =>
              t.templateUuid.equals(templateUuid) &
              t.scopeUid.equals(scopeUid)))
        .getSingleOrNull();

    if (existing == null) {
      await db.into(db.templateUsageStats).insert(
            TemplateUsageStatsCompanion.insert(
              templateUuid: templateUuid,
              scopeUid: scopeUid,
              useCount: const Value(1),
              lastUsedAt: usedAt,
            ),
          );
    } else {
      await (db.update(db.templateUsageStats)
            ..where((t) =>
                t.templateUuid.equals(templateUuid) &
                t.scopeUid.equals(scopeUid)))
          .write(
        TemplateUsageStatsCompanion(
          useCount: Value(existing.useCount + 1),
          lastUsedAt: Value(usedAt),
        ),
      );
    }
  }

  /// 获取单条模板统计
  Future<TemplateUsageStatsRow?> getUsageStat({
    required String templateUuid,
    required String scopeUid,
  }) async {
    return (db.select(db.templateUsageStats)
          ..where((t) =>
              t.templateUuid.equals(templateUuid) &
              t.scopeUid.equals(scopeUid)))
        .getSingleOrNull();
  }

  /// 列表查询全部统计（scope 隔离）
  Future<List<TemplateUsageStatsRow>> listUsageStats({
    required String scopeUid,
  }) async {
    return (db.select(db.templateUsageStats)
          ..where((t) => t.scopeUid.equals(scopeUid))
          ..orderBy([
            (t) => OrderingTerm.desc(t.useCount),
            (t) => OrderingTerm.desc(t.lastUsedAt),
          ]))
        .get();
  }
}
