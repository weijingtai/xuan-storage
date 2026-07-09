# S0 影响分析报告 — Seeker 解耦

> **日期**: 2026-06-29
> **任务**: `seeker-decoupling-s0-impact`
> **模式**: 只读分析
> **范围**: `xuan-storage/drift/lib/`（排除 `.g.dart`）

---

## 波及文件总览

| # | 文件 | 引用符号 | 修改必要性 |
|---|------|----------|-----------|
| 1 | `tables/seekers_table.dart` | `Seekers`, `SeekerModel`, `divinationUuid`, `t_seekers` | **S5** 标记 deprecated |
| 2 | `daos/seekers_dao.dart` | `SeekersDao`, `SeekerModel`, `divinationUuid` | **S5** 标记 deprecated + **S7** 清理 divinationUuid 查询 |
| 3 | `tables/seeker_divination_mappers_table.dart` | `divinationUuid`, `seekerUuid` (reference `Seekers`) | **S5** 标记 deprecated |
| 4 | `daos/seeker_divination_mappers_dao.dart` | `SeekerDivinationMappersDao`, `divinationUuid`, `seekerUuid` | **S5** 标记 deprecated |
| 5 | `tables/divinations_table.dart` | `ownerSeekerUuid` (references `Seekers`), `seekerName` | **S7** 标记 deprecated 字段 |
| 6 | `divination_case/case_participants_table.dart` | `seekerUuid` | **S3** 更新语义指向 t_record_meta |
| 7 | `divination_case/drift_divination_case_repository.dart` | `seekerUuid` (读写) | **S3** 修改读取路径 |
| 8 | `record/drift_record_data_source.dart` | `seekerUuid` (字段传递) | **否** — 已是 t_record_meta 字段 |
| 9 | `tables/record_meta_table.dart` | `seekerUuid` | **否** — 目标表，字段已就绪 |
| 10 | `persistence_drift.dart` | `Seekers`, `SeekerDivinationMappers`, `SeekersDao`, `SeekerDivinationMappersDao` | **S5** 配合标记 deprecated（export 可保留） |

---

## 逐文件详细分析

### 1. `tables/seekers_table.dart` — 核心表定义

| 行号 | 引用方式 | 符号 | 是否需要修改 | 建议方案 |
|------|----------|------|-------------|----------|
| 7 | import | `seeker_model.dart` | 是（S5） | 保留（SeekerModel 将继续使用，仅表 deprecated） |
| 10 | 注解 | `@UseRowClass(SeekerModel)` | 否 | 行类不修改，仅表标记 deprecated |
| 11 | 类定义 | `class Seekers extends Table` | 是（S5） | 添加 `// @Deprecated` 注释块 |
| 13 | tableName | `"t_seekers"` | 否 | 表名不修改 |
| 45 | 列定义 | `divinationUuid` | 是（S7） | 添加 `// @Deprecated` 注释：已迁移至 t_record_meta (module='seeker') |

**风险**: 低 — 只加注释不删字段

---

### 2. `daos/seekers_dao.dart` — 核心 DAO

| 行号 | 引用方式 | 符号 | 是否需要修改 | 建议方案 |
|------|----------|------|-------------|----------|
| 2 | import | `seeker_model.dart` | 否 | import 保留（行类不变） |
| 7 | 注解 | `@DriftAccessor(tables: [Seekers])` | 是（S5） | 类加 `@Deprecated('Migrated to t_record_meta. See SeekerMigration.')` |
| 8 | 类定义 | `class SeekersDao` | 是（S5） | 同上 |
| 12 | 返回类型 | `SeekerModel` | 否 | 行类保留不变 |
| 15 | 方法 | `getAllSeekers()` | 是（S5） | 加 `@Deprecated`，引导使用 `RecordBackedSeekerRepository` |
| 19 | 方法 | `getSeekerByUuid()` | 是（S5） | 同上 |
| 25 | 方法 | `getSeekersByDivinationUuid()` | 是（S7） | 加 `@Deprecated`，引导使用 `RecordModuleRegistry` |
| 25-28 | 参数/查询 | `divinationUuid` | 是（S7） | 方法 deprecated 后参数自然 deprecated |
| 32 | 方法 | `insertSeeker()` | 是（S5） | 加 `@Deprecated` |
| 36 | 方法 | `updateSeeker()` | 是（S5） | 加 `@Deprecated` |
| 40 | 方法 | `softDeleteSeeker()` | 是（S5） | 加 `@Deprecated` |

**风险**: 中 — 可能有外部调用方，需确认无未覆盖的引用

---

### 3. `tables/seeker_divination_mappers_table.dart` — 多对多映射表

| 行号 | 引用方式 | 符号 | 是否需要修改 | 建议方案 |
|------|----------|------|-------------|----------|
| 3 | import | `seekers_table.dart` | 是（S5） | import 保留（Drift 需要），表标记 deprecated |
| 8 | 类定义 | `class SeekerDivinationMappers` | 是（S5） | 添加 `// @Deprecated` 注释块 |
| 18-19 | 列定义 | `divinationUuid` references `Divinations` | 是（S7） | 加 deprecated 注释 |
| 20-21 | 列定义 | `seekerUuid` references `Seekers` | 是（S5） | 加 deprecated 注释 |

**风险**: 低

---

### 4. `daos/seeker_divination_mappers_dao.dart` — 映射 DAO

| 行号 | 引用方式 | 符号 | 是否需要修改 | 建议方案 |
|------|----------|------|-------------|----------|
| 7 | 类定义 | `class SeekerDivinationMappersDao` | 是（S5） | 加 `@Deprecated` |
| 15 | 方法 | `getAllSeekerDivinationMappers()` | 是（S5） | 加 `@Deprecated` |
| 19 | 方法 | `getSeekerDivinationMapperBySeekerUuid()` | 是（S5） | 加 `@Deprecated` |
| 26 | 方法 | `insertSeekerDivinationMapper()` | 是（S5） | 加 `@Deprecated` |
| 31 | 方法 | `updateSeekerDivinationMapper()` | 是（S5） | 加 `@Deprecated` |
| 36 | 方法 | `softDeleteSeekerDivinationMapperBySeekerUuid()` | 是（S5） | 加 `@Deprecated` |
| 43 | 方法 | `softDeleteSeekerDivinationMapperByDivinationUuid()` | 是（S7） | 加 `@Deprecated` |

**风险**: 低

---

### 5. `tables/divinations_table.dart` — 占卜表

| 行号 | 引用方式 | 符号 | 是否需要修改 | 建议方案 |
|------|----------|------|-------------|----------|
| 3 | import | `seekers_table.dart` | 是（S7） | 表标记 deprecated 后 import 仍保留（外键需要） |
| 25-26 | 列定义 | `ownerSeekerUuid` references `Seekers` | 是（S7） | 加 deprecated 注释 `// Migrated to t_record_meta (module='seeker')` |
| 30 | 列定义 | `seekerName` | 是（S7） | 加 deprecated 注释 |

**关键**: `ownerSeekerUuid` 的外键约束指向 `Seekers` 表，解耦后外键不再适用。方案：保留字段但移除 FOREIGN KEY 约束（需 Drift 迁移脚本）。但根据 **S7 协议"不删除字段，只标记 deprecated"**，可暂不修改外键。

**风险**: 中 — 外键约束是强耦合，长期应考虑移除

---

### 6. `divination_case/case_participants_table.dart`

| 行号 | 引用方式 | 符号 | 是否需要修改 | 建议方案 |
|------|----------|------|-------------|----------|
| 12 | 列定义 | `seekerUuid` | 是（S3） | 语义指向改为 t_record_meta，但 S3 策略是不改表结构，只改 repository 读取路径 |

**注意**: 该列目前无外键约束，仅字段名暗示指向 seeker。S3 任务中不改表。

**风险**: 低

---

### 7. `divination_case/drift_divination_case_repository.dart`

| 行号 | 引用方式 | 符号 | 是否需要修改 | 建议方案 |
|------|----------|------|-------------|----------|
| 165 | 字段读取 | `row.seekerUuid` | 是（S3） | 从 CaseParticipant 读取 seekerUuid 值不变，保持向后兼容 |
| 176 | 字段写入 | `seekerUuid: Value(model.seekerUuid)` | 否 | 写入方式不变，只是存储的值指向 t_record_meta.uuid |

**风险**: 低 — 值不变，仅语义变化

---

### 8. `record/drift_record_data_source.dart`

| 行号 | 引用方式 | 符号 | 是否需要修改 | 建议方案 |
|------|----------|------|-------------|----------|
| 14 | 字段传递 | `seekerUuid` 值 | **否** | `t_record_meta` 已有 `seekerUuid` 字段，正常传递 |
| 29 | 字段读取 | `row.seekerUuid` | **否** | 同上 |

**风险**: 无

---

### 9. `tables/record_meta_table.dart`

| 行号 | 引用方式 | 符号 | 是否需要修改 | 建议方案 |
|------|----------|------|-------------|----------|
| 14 | 列定义 | `seekerUuid` | **否** | 字段已存在，seeker 数据将写入此字段 |

**风险**: 无 — 目标表，字段已就绪

---

### 10. `persistence_drift.dart` — 数据库注册中心

| 行号 | 引用方式 | 符号 | 是否需要修改 | 建议方案 |
|------|----------|------|-------------|----------|
| 15 | import | `seeker_model.dart` | **否** | 其他 codec 可能需要 |
| 19 | import | `seekers_dao.dart` | 是（S5） | 保留导入（旧代码仍需编译），export 可保留 |
| 21 | import | `seeker_divination_mappers_dao.dart` | 是（S5） | 同上 |
| 27 | import | `seekers_table.dart` | 是（S5） | 同上 |
| 29 | import | `seeker_divination_mappers_table.dart` | 是（S5） | 同上 |
| 74 | export | `seekers_dao.dart` | 条件 | 外部 package 若仍引用则保留，否则移除 |
| 76 | export | `seeker_divination_mappers_dao.dart` | 条件 | 同上 |
| 82 | export | `seekers_table.dart` | 条件 | 同上 |
| 84 | export | `seeker_divination_mappers_table.dart` | 条件 | 同上 |
| 469 | 表注册 | `Seekers` | **否** | Drift 数据库必须注册所有表 |
| 471 | 表注册 | `SeekerDivinationMappers` | **否** | 同上 |
| 499 | DAO 注册 | `SeekersDao` | **否** | Drift DAO 必须注册 |
| 501 | DAO 注册 | `SeekerDivinationMappersDao` | **否** | 同上 |

**注意**: Drift 数据库注册（lines 469-501）不能移除——即使表标记 deprecated，数据库 schema 仍包含这些表。只有实际删除表时才能移除。export（lines 74-84）可选择性移除以引导新代码使用新接口。

**风险**: 低 — export 移除可能导致外部 package 编译失败，需协调发布

---

## ⚠️ 风险点

### 1. 外键约束耦合（高风险）
`divinations_table.dart:26` 的 `ownerSeekerUuid` 列有 `REFERENCES Seekers(#uuid)` 外键约束。解耦后外键指向将被废弃的旧表。有两种策略：
- **短期**: 不做任何 schema 变更，数据写入时不验证外键（Drift 的 `foreignKeys` 需要在 database 级别启用/禁用，默认可能是关闭的）
- **长期**: 移除外键约束（需 Drift 迁移脚本 `ALTER TABLE t_divinations DROP CONSTRAINT ...`，SQLite 有限支持）

### 2. Export 兼容性（中风险）
`persistence_drift.dart` 通过 export 暴露的 `seekers_dao.dart` 和 `tables/seekers_table.dart` 可能被外部 package（如 `xuan-ai`）引用。标记 deprecated 后需通知下游 package 迁移。

### 3. DRF 模型关联（中风险）
当前分析限于 `drift/lib/`。`SeekerModel` 定义在 `metaphysics_core` 中，`divinationUuid` 字段在 `SeekerModel` 的数据类中可能存在。解耦后 SeekerModel 不再需要 `divinationUuid`。**但本任务范围不包含修改 metaphysics_core**。

### 4. 迁移幂等性（低风险）
`t_record_meta` 中 `module='seeker'` 的记录必须有唯一性约束（或业务层幂等）。S2 迁移脚本需确保重复运行不产生重复记录。建议在 `t_record_meta` 的 `uuid` 上使用 `ON CONFLICT REPLACE`（DataSource 已用 `insertOnConflictUpdate`）。

---

## 回滚策略

| 场景 | 操作 | 影响范围 |
|------|------|----------|
| 标记 deprecated 后发现问题 | 移除 `@Deprecated` 注解和注释 | 无数据影响 |
| 迁移脚本出错 | 删除 `t_record_meta` 中 `module='seeker'` 的记录 | 仅影响 t_record_meta |
| 新 repository 有 bug | 回退使用旧 `SeekersDao` | 临时恢复旧调用路径 |
| 误解耦（需恢复耦合） | 回退 S3 修改，恢复旧表引用 | 全量回退 |
| Drift 迁移冲突 | `flutter clean` + 重建数据库 | 开发环境 |

---

## 修改任务分配矩阵

| 文件 | S1 | S2 | S3 | S4 | S5 | S6 | S7 |
|------|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| `tables/seekers_table.dart` | | | | | ✅ | | ✅ |
| `daos/seekers_dao.dart` | | | | | ✅ | | ✅ |
| `tables/seeker_divination_mappers_table.dart` | | | | | ✅ | | |
| `daos/seeker_divination_mappers_dao.dart` | | | | | ✅ | | |
| `tables/divinations_table.dart` | | | | | | | ✅ |
| `divination_case/case_participants_table.dart` | | | ✅ | | | | |
| `divination_case/drift_divination_case_repository.dart` | | | ✅ | | | | |
| `persistence_drift.dart` | | | | | ✅(export) | | |
| `record/record_module_registry.dart` | ✅ | | | | | | |
| `record/drift_record_data_source.dart` | ✅(使用) | ✅(使用) | | | | | |
| `tables/record_meta_table.dart` | ✅(使用) | ✅(使用) | | | | | |

**说明**: S1 创建新文件 `seeker/` 目录下的 codec/registry/repo，不修改上述列出的旧文件。S2 使用旧 DAO 读旧表 + 新 codec/store 写新表。

---

## 附录: 所有引用位置汇总

```
tables/seekers_table.dart:7       import SeekerModel
tables/seekers_table.dart:10      @UseRowClass(SeekerModel)
tables/seekers_table.dart:11      class Seekers extends Table
tables/seekers_table.dart:13      tableName = "t_seekers"
tables/seekers_table.dart:45      TextColumn divinationUuid

daos/seekers_dao.dart:2           import SeekerModel
daos/seekers_dao.dart:7           @DriftAccessor(tables: [Seekers])
daos/seekers_dao.dart:8           class SeekersDao
daos/seekers_dao.dart:12-29       SeekerModel 返回类型
daos/seekers_dao.dart:25-29       getSeekersByDivinationUuid()

tables/seeker_divination_mappers_table.dart:3  import seekers_table
tables/seeker_divination_mappers_table.dart:8  class SeekerDivinationMappers
tables/seeker_divination_mappers_table.dart:18-19  TextColumn divinationUuid
tables/seeker_divination_mappers_table.dart:20-21  TextColumn seekerUuid -> Seekers

daos/seeker_divination_mappers_dao.dart:7   class SeekerDivinationMappersDao
daos/seeker_divination_mappers_dao.dart:22   seekerUuid 查询
daos/seeker_divination_mappers_dao.dart:45   divinationUuid 查询

tables/divinations_table.dart:3     import seekers_table
tables/divinations_table.dart:25-26 TextColumn ownerSeekerUuid -> Seekers
tables/divinations_table.dart:30    TextColumn seekerName

divination_case/case_participants_table.dart:12  TextColumn seekerUuid

divination_case/drift_divination_case_repository.dart:165  row.seekerUuid (读)
divination_case/drift_divination_case_repository.dart:176  model.seekerUuid (写)

record/drift_record_data_source.dart:14   seekerUuid: Value(r.seekerUuid)
record/drift_record_data_source.dart:29   row.seekerUuid

tables/record_meta_table.dart:14    TextColumn seekerUuid

persistence_drift.dart:15   import SeekerModel
persistence_drift.dart:19   import seekers_dao
persistence_drift.dart:21   import seeker_divination_mappers_dao
persistence_drift.dart:27   import seekers_table
persistence_drift.dart:29   import seeker_divination_mappers_table
persistence_drift.dart:74   export seekers_dao
persistence_drift.dart:76   export seeker_divination_mappers_dao
persistence_drift.dart:82   export seekers_table
persistence_drift.dart:84   export seeker_divination_mappers_table
persistence_drift.dart:469  Seekers 表注册
persistence_drift.dart:471  SeekerDivinationMappers 表注册
persistence_drift.dart:499  SeekersDao 注册
persistence_drift.dart:501  SeekerDivinationMappersDao 注册
```

---

*报告结束。下一步执行 S1: 创建 Seeker codec + registry + repository。*
