# S1c 全量对齐 · REACT 闸门复核报告（返工项 2 补录）

> 复核日期：2026-08-06｜复核：opencode（编码 AI，自复核留痕）
> 背景：G4 转译闸门被人类豁免（2026-08-06 决定不转 ACT），按验收报告 §11 返工项 2「另落盘 ACT + REACT 报告」补录本闸门复核。
> 复核对象：返工项 3-6 的实现证据（返工项 1 提交 d32673f 后，worktree 干净）。

## 判定：返工项 3-6 证据齐备，可执行合 main（返工项 7）

## 1. 返工项 3 · 四阶段线序守卫

- **实现**：`core/lib/test_support/reconciliation_contract_suite.dart:48-54` 新增 `initiatorSentOrder`（发起方 channel 实际发出消息类型序列）；`:171` 契约套件第 6 条「线序守卫：全部 ManifestChunk 必须先于 CursorAdvance」。
- **M2a 变异**：套件 `:190` 注释明确「若有人把 ④ 提到 ① 前（M2a 变异形态），cursorAdvance 会出现在 manifestChunk 前」→ 红在契约套件第 6 条断言（`expect` 线序守卫）。两个 fake（A/B，`s1c_reconciliation_coordinator_test.dart`）各跑一遍。
- **核验**：`grep initiatorSentOrder` → 套件 `:54` 声明 + `:187` 断言 + Fake A `:48` 实现，闭合。

## 2. 返工项 4 · v9→v10 迁移测试

- `drift/test/blob/blob_schema_v9_migration_test.dart`：构造 v9 库写数据 → 升 v10 → 断言
  `schemaVersion == 10`（`:44`）、旧行零丢失（`:99` reason '迁移后旧记录必须还在'）、`is_deleted` 列存在且默认 false、覆盖「跳过 addColumn」分支（`persistence_drift.dart:1023-1042` 幂等判定 `stampCols.any(name == 'is_deleted')`）。
- 迁移实现：`persistence_drift.dart:1028-1030` 注释——v10 迁移里含 is_deleted 的完整表已存在该列时跳过 addColumn（防 duplicate）。

## 3. 返工项 5 · 套件 seed 重构

- `reconciliation_contract_suite.dart:32-46`：`ReconciliationRig` 拆分显式写入方法 `void seed(List<TerminalSpec> specs)`（`:40`）；
  `initiatorState()` / `responderState()` 改为收敛后只读快照读取（`:43/:46`，接口注释「读两端收敛后数据」）。
- 两个 fake 结构迥异（Fake A 三独立端口类 + 可替换 channel 引用，Fake B 另一拓扑），套件 `:67` 用 `identical(rig.initiator, rig.responder)` 守卫两端不得同一对象。

## 4. 返工项 6 · A9 变异记录逐条落盘

- 线序变异 M2a：契约套件 `:53`（「该变异曾被 M2a 证实无守卫」）+ `:190`（变异形态 = ④ 提到 ① 前，红在 cursorAdvance 先于 manifestChunk 断言）。
- 门禁负测试 M1/M2：`scripts/test_s1c_analyze_gate.sh`——注入 unused field（`M1`）/ unused import（`M2`）→ 门禁必须红（exit != 0）→ 还原 → 必须绿。A8 变异自检要求「注入变异后必须红在目标断言上」。

## 5. 合 main 前置确认

- 4 个重叠文件：`drift/lib/persistence_drift.dart`、`drift/lib/persistence_drift.g.dart`（两侧均重新生成）+ 2 处测试（`core/test/transport_contract_test.dart` 与另一处）。合并后必须用 build_runner 重新生成 `.g.dart`，重跑全部门禁 + 四包测试。
- 本报告不替代执行：合 main 结果以返工项 7 的实际门禁/测试输出为准。
