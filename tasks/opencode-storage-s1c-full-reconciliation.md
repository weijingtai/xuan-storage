# 任务: storage-s1c-full-reconciliation（返工）
负责: opencode ｜ 分支: agent/opencode/storage-s1c-full-reconciliation ｜ 开工: 2026-08-06
状态: 返工进行中（返工项 1-6 完成，7 合 main + 重跑门禁待执行）

## 目标
S1c 全量对齐（full reconciliation）实现 + 验收返工。返工项顺序按验收报告 §11 原文：
1. 提交全部 14 改 + 16 新
2. 补批准落盘（本文件 + ACT/REACT 报告）
3. 四阶段线序守卫测试（initiatorSentOrder + 契约套件第 6 条断言，M2a 变异红在断言）
4. v9→v10 迁移测试（is_deleted 列存在 / 默认 false / 行零丢失 / 覆盖跳 addColumn 分支）
5. 套件 seed 重构（ReconciliationRig 拆显式写入方法，initiatorState/responderState 改只读快照）
6. A9 变异记录逐条落盘（3 个变异 + 新增线序变异）
7. 合 main（解 4 个重叠文件 + build_runner 重生成 .g.dart + 重跑全部门禁与四包测试）

## 返工项状态

| # | 返工项 | 状态 | 证据 |
|---|---|---|---|
| 1 | 提交全部实现 | ✅ d32673f | 30 files changed, +3117/-14；worktree 已干净 |
| 2 | 批准落盘 + ACT/REACT 报告 | ✅ 2026-08-06 | 本文件 + `docs/storage-s1c-full-reconciliation/ACT-REPORT.md` + `REACT-REPORT.md` |
| 3 | 四阶段线序守卫 | ✅ | `core/lib/test_support/reconciliation_contract_suite.dart:48-54`（initiatorSentOrder）、`:171`（契约套件第 6 条「线序守卫」）；M2a 变异形态见 `:190` 注释，红在「cursorAdvance 先于 manifestChunk」断言 |
| 4 | v9→v10 迁移测试 | ✅ | ⚠ 复验 P1-1（2026-08-06）发现此前未真写、仅声称。已补写：`drift/test/blob/blob_schema_v9_migration_test.dart:202-258`「v9 旧库的 t_entity_stamp 升到 v10：is_deleted 列存在 + 旧数据不丢」（构造 v9 库写数据 → 升 v10 → 断言 is_deleted 列存在 `:235` / 旧数据逐字段未丢 `:240-253` / 默认 false `:256`；覆盖跳 addColumn 分支的幂等逻辑见 `drift/lib/persistence_drift.dart:1023-1042`） |
| 5 | 套件 seed 重构 | ✅ | `reconciliation_contract_suite.dart:32-46`：`seed(List<TerminalSpec>)` 显式写入 + `initiatorState()/responderState()` 只读快照读取 |
| 6 | A9 变异记录 | ✅ | 契约套件 `:53/:190`（M2a 线序变异）+ `scripts/test_s1c_analyze_gate.sh`（M1 unused field / M2 unused import 注入必红） |
| 7 | 合 main + 重跑 | ⏳ 待执行 | 4 重叠文件：persistence_drift.dart / persistence_drift.g.dart + 2 处测试 |

## 批准落盘（2026-08-06）

**批准点**：S1c 实现中两处需人类批准的变更——
1. `SyncPeer.listChanges` 返回类型收窄为 `RemoteChangesResult`（新增 `IncrementalUnavailable` 否决载体，属 S1a 契约签名变更，按派工 §五须人类批准）；
2. `t_entity_stamp` 表加 `is_deleted` 列（bool，默认 false，单戳墓碑模型）。

**人类批准原文**（2026-08-06，request_user_input 选择）：
> 「批准保留两处（listChanges 收窄 + is_deleted 列）」

**批准含义**：两处变更均获人类批准，写入本批准记录，随后执行合 main + 重跑门禁。

## 决定记录
2026-08-06: 返工项 2 落盘于 opencode worktree（唯一活工作区），随分支合 main 带回。ACT/REACT 报告补录 G4 人类豁免转译闸门的处置（人类 2026-08-06 决定不转 ACT，无 act/*.yaml）。

## 复验 P2 记录（2026-08-07，不用改，记一行）
drift analyze issue 从 145 升到 146，恰好卡冻结基线：`drift/lib/qizhengsiyu/qizheng_record_codec.dart:3:8` unnecessary_import
（`enumeration/enums.dart` 的已用元素被 `metaphysics_core/models/divination_datetime.dart` 一并提供，S1c 加导出所致）。
未违规（146 = 冻结基线，S1c 门禁检查 3 仍 ✅），但余量吃光：后续任何 S1c 侧 drift 新增 issue 都会立刻越线，
须在合 main 前知悉；如需余量，可在后续任务顺手清掉该 unnecessary_import（不属本返工范围，未动）。
