import 'package:repository_contract_kernel/repository_contract_kernel.dart';

/// record 资源在 L0 契约内核上的 [EntityDescriptor] 工厂。
///
/// 行形态与 [RecordRowMapper] 一致：snake_case 扁平行，`id` 为主键，
/// `_rev` 由 driver 维护。codec 采用恒等映射 —— 行就是实体，
/// 契约套件（C1–C10）与 Base 仓储直接操作行，不再需要第二套编解码。
///
/// [module] 即 L0 的资源名（record 的存储天然按 module 分区），
/// 每个模块（liuyao / meihua / ...）装配各自的 descriptor。
EntityDescriptor<Map<String, Object?>, String> recordEntityDescriptor({
  required String module,
}) {
  return EntityDescriptor<Map<String, Object?>, String>(
    resource: module,
    idOf: (row) => row['id'] as String,
    withId: (row, id) => {...row, 'id': id},
    codec: const _RowCodec(),
    // uuid 主键天然唯一，作为稳定分页的末位排序键。
    indexes: const [
      IndexSpec('id', unique: true),
      IndexSpec('category'),
      IndexSpec('case_uuid'),
      IndexSpec('divination_uuid'),
      IndexSpec('original_gua_id'),
      IndexSpec('changed_gua_id'),
      IndexSpec('upper_gua'),
      IndexSpec('lower_gua'),
      IndexSpec('changing_yao'),
      IndexSpec('school_id'),
      IndexSpec('reading_uuid'),
      IndexSpec('seeker_name'),
      IndexSpec('gender'),
      IndexSpec('lunar_month'),
      IndexSpec('pan_style'),
      IndexSpec('tiaowen_id'),
      IndexSpec('year_pillar'),
      IndexSpec('month_pillar'),
      IndexSpec('day_pillar'),
      IndexSpec('hour_pillar'),
      IndexSpec('divination_type'),
      IndexSpec('tag'),
    ],
    // 与既有 record 语义一致：created_at 降序（新在前），id 升序兜底。
    defaultSort: const SortSpec([
      SortKey('created_at', desc: true),
      SortKey('id'),
    ]),
    residency: DataResidency.local,
    softDelete: const SoftDeletePolicy(
      enabled: true,
      deletedAtField: 'deleted_at',
    ),
  );
}

/// 恒等编解码：L0 行即实体，避免「行 → 实体 → 行」的重复映射。
class _RowCodec implements EntityCodec<Map<String, Object?>> {
  const _RowCodec();

  @override
  Map<String, Object?> toMap(Map<String, Object?> entity) => entity;

  @override
  Map<String, Object?> fromMap(Map<String, Object?> map) => map;
}
