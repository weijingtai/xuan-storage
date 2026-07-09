# F0: t_decision_links 表结构扩展 — 影响分析报告

> **日期**: 2026-06-29
> **计划源**: `docs/superpowers/plans/2026-06-29-fork-link-merge-act-plan.md`
> **分析范围**: `drift/lib/` + `core/lib/` 下引用 `decision_links` / `DecisionLink` / `decisionLinks` / `IDecisionRepository` 的所有 `.dart` 文件（排除 `.g.dart`）

---

## 1. 当前 t_decision_links 表结构

**定义文件**: `drift/lib/tables/decision_links_table.dart`

| 字段 | Drift 类型 | SQL 类型 | 约束 |
|------|-----------|----------|------|
| `id` | `text()()` | TEXT | PK, NOT NULL |
| `source_uuid` | `text().named('source_uuid')()` | TEXT | NOT NULL |
| `target_uuid` | `text().named('target_uuid')()` | TEXT | NOT NULL |
| `intent` | `text()()` | TEXT | NOT NULL |
| `context_snapshot_json` | `text().named('context_snapshot_json').nullable()()` | TEXT | NULLABLE |
| `created_at_ms` | `integer().named('created_at_ms')()` | INTEGER | NOT NULL |
| `updated_at_ms` | `integer().named('updated_at_ms')()` | INTEGER | NOT NULL |
| `deleted_at_ms` | `integer().named('deleted_at_ms').nullable()()` | INTEGER | NULLABLE |
| `scope_uid` | `text().named('scope_uid')()` | TEXT | NOT NULL |
| `unknown_fields` | `text().named('unknown_fields').nullable()()` | TEXT | NULLABLE |

表名: `t_decision_links`

---

## 2. 当前 DecisionLinksDao 方法

**定义文件**: `drift/lib/daos/decision_links_dao.dart`

| 方法 | 签名 | 用途 |
|------|------|------|
| `upsert` | `Future<int> upsert(DecisionLinksCompanion record)` | 插入或冲突时更新 |
| `getById` | `Future<DecisionLinkRow?> getById(String id, String scopeUid)` | 按 ID + scope 查找 |
| `listBySource` | `Future<List<DecisionLinkRow>> listBySource(String sourceUuid, String scopeUid)` | 按源 UUID 列出, 按 created_at_ms 正序 |

---

## 3. 波及文件清单

### 3.1 drift/lib/（数据库层）

| 文件 | 当前关联 | 修改建议 |
|------|----------|----------|
| `tables/decision_links_table.dart` | 表定义（10 列） | **F1**: 新增 4 列定义, 添加 index |
| `daos/decision_links_dao.dart` | DAO（3 个方法） | **F2**: 新增 5+ 方法 |
| `daos/decision_links_dao.g.dart` | 自动生成 | **F1/F2**: 重新 build_runner 生成 |
| `persistence_drift.dart` | import/export tables + daos, line 473/503 注册 DecisionLinks/DecisionLinksDao | **F1**: 新增 DAO 注册（若有新类）; **F3-F6**: 新增 engine 文件需导出 |
| `persistence_drift.g.dart` | 自动生成 | **F1**: 重新 build_runner 生成 |
| `divination_case/drift_divination_case_repository.dart` | 未引用 decision_links | **F8**: 添加 getWorkItemForks 等方法 |

### 3.2 core/lib/（领域模型层）

| 文件 | 当前关联 | 修改建议 |
|------|----------|----------|
| `model/decision_link.dart` | `DecisionLink` 模型 + `IDecisionRepository` 接口 | 新增 linkType / sessionId / mergeTargetUuid / inferenceMeta 字段; `getDecisionChain` 签名需适配 |

### 3.3 测试文件

| 文件 | 当前关联 | 修改建议 |
|------|----------|----------|
| `drift/test/decision_links_dao_test.dart` | 2 个测试（upsert / listBySource） | **F2**: 扩展现有 DAO 测试或新建测试文件 |
| `core/test/decision_chain_test.dart` | 蓝图 Mock（含 duplicate IDecisionRepository） | **F3/F6**: 更新 Mock 匹配新模型字段 |

### 3.4 新增文件（计划中）

| 新文件 | 所属任务 |
|--------|----------|
| `drift/lib/decision_links/inference_engine.dart` | F3 |
| `drift/lib/decision_links/fork_engine.dart` | F4 |
| `drift/lib/decision_links/merge_engine.dart` | F5 |
| `drift/lib/decision_links/decision_chain_traverser.dart` | F6 |
| `drift/test/decision_links/decision_links_schema_test.dart` | F1 |
| `drift/test/decision_links/decision_links_dao_test.dart`（或在同一目录拆分） | F2 |
| `drift/test/decision_links/inference_engine_test.dart` | F3 |
| `drift/test/decision_links/fork_engine_test.dart` | F4 |
| `drift/test/decision_links/merge_engine_test.dart` | F5 |
| `drift/test/decision_links/chain_traverser_test.dart` | F6 |
| `drift/test/decision_links/integration_test.dart` | F7 |

---

## 4. 新增字段设计

### 4.1 link_type（决策链类型）

| 属性 | 值 |
|------|-----|
| 类型 | `TEXT NOT NULL` |
| 默认值 | `'sequential'` |
| 枚举值 | `'fork'` / `'sequential'` / `'merge'` / `'inference'` / `'inference_ambiguous'` |
| Drift 定义 | `text().withDefault(const Constant('sequential')).named('link_type')()` |
| 迁移 SQL | `ALTER TABLE t_decision_links ADD COLUMN link_type TEXT NOT NULL DEFAULT 'sequential'` |
| 说明 | 所有现有行的 link_type 自动变为 `'sequential'`, 保证向后兼容 |

### 4.2 session_id（推断会话分组）

| 属性 | 值 |
|------|-----|
| 类型 | `TEXT NULLABLE` |
| 默认值 | `NULL` |
| Drift 定义 | `text().named('session_id').nullable()()` |
| 迁移 SQL | `ALTER TABLE t_decision_links ADD COLUMN session_id TEXT` |
| 说明 | 同一推断会话创建的 link 共享此 ID, 用于原子 undo。目前不存在的数据不受影响 |

### 4.3 merge_target_uuid（合并目标）

| 属性 | 值 |
|------|-----|
| 类型 | `TEXT NULLABLE` |
| 默认值 | `NULL` |
| Drift 定义 | `text().named('merge_target_uuid').nullable()()` |
| 迁移 SQL | `ALTER TABLE t_decision_links ADD COLUMN merge_target_uuid TEXT` |
| 说明 | Merge 操作时填写, 指向最终合并后的记录 UUID。仅 merge 类型的 link 使用 |

### 4.4 inference_meta_json（推断元数据）

| 属性 | 值 |
|------|-----|
| 类型 | `TEXT NULLABLE` |
| 默认值 | `NULL` |
| Drift 定义 | `text().named('inference_meta_json').nullable()()` |
| 迁移 SQL | `ALTER TABLE t_decision_links ADD COLUMN inference_meta_json TEXT` |
| 说明 | JSON 格式, 包含模型名、置信度、推断时间戳等。仅 inference / inference_ambiguous 类型的 link 使用 |

---

## 5. 迁移策略

### 5.1 当前迁移基础设施

定义在 `drift/lib/persistence_drift.dart:518-535`:

```dart
int get schemaVersion => 2;

MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) async {
    await m.createAll();
    await _createRecordIndices();
  },
  onUpgrade: (m, from, to) async {
    if (from < 2) {
      await m.createTable(tRecordMeta);
      await m.createTable(tRecordSearchIndex);
      await m.createTable(tScopeAlias);
      await _createRecordIndices();
    }
  },
);
```

### 5.2 迁移方案

| 步骤 | 内容 |
|------|------|
| 1 | `schemaVersion` 从 2 → **3** |
| 2 | `onUpgrade` 中添加 `if (from < 3)` 分支, 执行 4 条 `ALTER TABLE ADD COLUMN` |
| 3 | 修改 `DecisionLinks` 表定义, 新增 4 列 |
| 4 | 运行 `dart run build_runner build --delete-conflicting-outputs` 重新生成 `.g.dart` |

迁移代码模板:

```dart
if (from < 3) {
  await m.addColumn(tDecisionLinks, tDecisionLinks.linkType);
  await m.addColumn(tDecisionLinks, tDecisionLinks.sessionId);
  await m.addColumn(tDecisionLinks, tDecisionLinks.mergeTargetUuid);
  await m.addColumn(tDecisionLinks, tDecisionLinks.inferenceMetaJson);
}
```

注意: `m.addColumn` 是 Drift 的内置迁移 API, 会在 SQLite 层执行 `ALTER TABLE ADD COLUMN`。新建列为 nullable 或带默认值, 现有行不受影响。

---

## 6. 兼容性分析

| 维度 | 分析结论 |
|------|----------|
| 现有数据 | **完全兼容**。所有新增列均为 nullable 或带默认值, 现有行的 `link_type` 自动为 `'sequential'` |
| 现有查询 | **完全兼容**。DAO 查询未修改现有方法签名, 现有代码无需改动 |
| 现有 Companion | **兼容但需注意**。`insert()` 和 `copyWith()` 自动包含新列（nullable）, 需传入或使用默认值 |
| 现有代码导入 | **部分兼容**。新文件导入路径可能需要调整 `export` 声明 |
| 行锁/约束 | 无影响。未添加 UNIQUE / FOREIGN KEY / CHECK 约束 |

---

## 7. 风险与注意事项

1. **Drift 的 `m.addColumn`** 要求 Drift 版本 ≥ 2.x。确认当前 Drift 版本是否支持。
2. **build_runner 冲突**: 多个开发者同时生成可能产生 `.g.dart` 冲突, 建议在锁定分支上执行。
3. **unknown_fields 字段**: 规划中新增的 `inference_meta_json` 可能覆盖部分原本存在 `unknown_fields` 中的数据。如 `unknown_fields` 已有数据, 需确认迁移时不丢失。
4. **`IDecisionRepository` 接口签名变更**: `getDecisionChain(String rootId)` 返回类型从 `List<DecisionLink>` 可能需要新增分页/过滤参数, 涉及 `core/lib` 和 `core/test` 两处。

---

## 8. 执行顺序建议

```
F1 表结构扩展
 ├─ 修改 decision_links_table.dart
 ├─ 添加 persistence_drift.dart migration
 ├─ build_runner 生成
 └─ schema 测试
F2 DAO 扩展
 ├─ 新增 DAO 方法
 ├─ build_runner 生成
 └─ DAO 测试
F3-F6 引擎实现
 └─ 依赖 F1+F2 完成
F7 集成测试
F8 Case 适配
```
