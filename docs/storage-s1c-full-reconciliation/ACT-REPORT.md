# S1c 全量对齐 · ACT 转译报告（返工项 2 补录）

> 补录日期：2026-08-06｜编制：opencode（编码 AI）
> 背景：G4 转译闸门被人类豁免——「人类决定不转 ACT，直接由编码 AI 依据定稿设计稿编码（2026-08-06）。无 act/*.yaml」（见 `GATES-REMAINING-AND-FIX-PATH.md` G4）。
> 本报告按验收报告 §11 返工项 2「另落盘 ACT + REACT 报告」补录：记录 ACT-A~G 拆分方向（计划 §3.2 参考方向）与最终实现的对应关系，作为无 act/*.yaml 情形下的转译留痕。

## 1. 转译结论

定稿设计稿（worktree `agent/pi/storage-s1c-full-reconciliation` commit `9506754`）已定死
否决载体（`RemoteChangesResult` + `IncrementalUnavailable`）、四阶段消息线序、单戳墓碑模型
（`is_deleted` 列）、§5 待决逐条。编码 AI 依据定稿直接编码，实现映射如下：

| ACT 方向（计划 §3.2，非定稿） | 对应实现文件 | 状态 |
|---|---|---|
| ACT-A 契约层（core 零实现；listChanges 收窄为 RemoteChangesResult） | `core/lib/model/reconciliation.dart`、`reconciliation_ports.dart`、`sync_peer.dart`（listChanges 收窄，人类已批准）、`transport.dart`、`types.dart`、`remote_gateway_router.dart` 适配 | ✅ |
| ACT-B 墓碑 schema（t_entity_stamp 加 is_deleted + v10 迁移） | `drift/lib/persistence_drift.dart`（`:284` is_deleted 列、`:1023-1042` v10 迁移幂等跳 addColumn）+ `.g.dart` | ✅ |
| ACT-C 清单交换与分片续传 | `core/lib/sync/manifest_comparator.dart`、`drift/lib/sync/entity_stamp_manifest_source.dart` | ✅ |
| ACT-D 四阶段对齐编排（发起→应答→终态→确认） | `core/lib/core/reconciliation_coordinator.dart`、`drift/lib/sync/record_reconciliation_applier.dart`、`core/lib/persistence_core.dart` | ✅ |
| ACT-E 触发判定 + 对端否决（90 天阈值 + IncrementalUnavailable） | `core/lib/sync/reconciliation_trigger.dart`、`core/test/s1c_peer_denial_test.dart` | ✅ |
| ACT-F 契约测试套件提取（两个结构迥异 fake 各跑一遍） | `core/lib/test_support/reconciliation_contract_suite.dart`（runReconciliationContractSuite，`:67` 守卫两端非同一对象）、`core/test/s1c_reconciliation_coordinator_test.dart` | ✅ |
| ACT-G 门禁（run_s1c_analyze_gate.sh 三段式冻结） | `scripts/run_s1c_analyze_gate.sh` + `scripts/test_s1c_analyze_gate.sh`（负测试 M1/M2 注入必红） | ✅ |

## 2. 人类批准的两处签名/结构变更（转译前提，2026-08-06）

1. `SyncPeer.listChanges` 返回类型收窄为 `RemoteChangesResult`（`RemoteChangesPage | IncrementalUnavailable`）——S1a 契约签名变更，人类批准（见 `tasks/opencode-storage-s1c-full-reconciliation.md` 批准落盘）。
2. `t_entity_stamp` 加 `is_deleted` 列（bool，默认 false）——只加列、不触既有列语义，人类批准。

## 3. 与 G4 的衔接

G4 原文要求「/wjt-act 转译 ACT + /wjt-react 换人转译闸门」，人类决定跳过（2026-08-06）。
本报告与 `REACT-REPORT.md` 即该豁免的补录留痕：ACT 对应关系见上表，闸门复核见 REACT 报告。
