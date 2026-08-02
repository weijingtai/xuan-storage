# 任务: storage-s1b-multipeer
负责: mimo ｜ 分支: agent/mimo/storage-s1b-multipeer ｜ 开工: 2026-08-02
状态: 蓝图

## 目标
把同步引擎从单 peer（云端）改造成多 peer：两次 drift schema 迁移 + 三个端口签名变更 + fan-out 推送 + per-peer 退避 + Lamport 冲突仲裁，并修 `canAdvanceCursor` 恒真（S1b，任何 peer 实现开工前必须完成）。

## 规格来源
`docs/superpowers/specs/2026-07-31-storage-architecture-design.md`（1659 行，已过 /autoplan 三阶段评审 + Codex 跨模型验证）。
**§ 号在下方每个子任务里给出，执行时按 § 号定位原文，不要凭记忆写。** S1b 全部依据：§5.2.1 / §5.2.2 / §5.2.3 / §5.3 / §5.4 / §9 排期表。
下发单：`docs/dispatch/2026-08-02-s1b-dispatch-prompt.md`（工作方式 / 范围 / 验收纪律）。

本仓库既有约束（必须先读）：
- `core/test/policy_channel_filter_test.dart` —— 推送过滤的**可执行规格**（fail closed 语义已写死），S1b 把它落进 peekBatch
- `tasks/mimo-storage-s1a-contracts.md` —— S1a 纪要（验收标准写法 / 决定记录 / A10 门禁返工教训）
- `scripts/run_s1a_analyze_gate.sh` —— A1 三段式冻结门禁范本

## 计划

已转译为 ACT，按 ORDER 顺序执行，每个 ACT 内含 SCOPE / SIGNATURE / TESTS_FIRST / VERIFICATION / SELF_CHECK（临时改坏 → 确认变红 → 改回）。

- [ ] ACT 01: `PeerCapabilities` / `PeerId` / `SyncPeer` 端口签名 + `PeerFanoutPusher` 契约（零实现，§5.2.2）-> `docs/storage-s1b-multipeer/act/01.yaml`
- [ ] ACT 02: `OutboxStore` / `SyncStateStore` 全部方法加 `peerId` —— 端口 + 既有 fake 同步改（§5.2.2 阻断点 3）-> `act/02.yaml`
- [ ] ACT 03: **drift v7 迁移（STRONG_MODEL_ONLY）**：新表 `t_outbox_peer_ack`（operationId+peerId 联合主键，status/attempt/ackedAtUtc，兼 §5.3 compaction 水位表）+ `t_sync_state` 主键加 peerId + 既有行回填（建议 'cloud'）+ 迁移测试（§5.2.2）-> `act/03.yaml`
- [ ] ACT 04: **drift 侧实现改造（STRONG_MODEL_ONLY）**：`OutboxRecordsDao` / `SyncStatesDao` / `DriftOutboxStore` / `DriftSyncStateStore` 加 peerId + per-peer ack 语义（一个 peer success 不影响另一 peer 的该行）-> `act/04.yaml`
- [ ] ACT 05: `RemoteGatewayRouter` 从 1-of-N 改造成 fan-out；`PeerFanoutPusher` 实现（`pushToAll` 对 N 个 peer 各返回一个结果，一个失败不影响其余，§5.2.2 阻断点 4/5）-> `act/05.yaml`
- [ ] ACT 06: `SyncRuntime` per-peer 退避改造（`_pushFailureCount` / `_nextPullNotBeforeUtcByEntityType` 加 peer 维度，§5.2.2：不可达 LAN peer 不得拖垮云端 push 调度）-> `act/06.yaml`
- [ ] ACT 07: `ConflictArbiter` + Lamport 序 `(rev, deviceId)`（复用 `DeviceIdentity`，不新建）+ `ChangeApplyOutcome` 增加被覆盖 payload 字段（§5.2.3 / §5.3 冲突可见化）-> `act/07.yaml`
- [ ] ACT 08: 修 `canAdvanceCursor` 恒真（`record_local_applier.dart:60-61`）—— 应用失败不推进游标 + 回归测试（§5.2.3）-> `act/08.yaml`
- [ ] ACT 09: `peekBatch` 按 channel 策略过滤（照 `policy_channel_filter_test.dart` 语义：lookup 返回 null 时 fail closed，§5.4 第一道锁）-> `act/09.yaml`
- [ ] ACT 10: barrel 导出 + 架构守卫测试（含中文 dartdoc 覆盖计数下限，通用式正则，S1a 教训）+ 创建 `scripts/run_s1b_analyze_gate.sh`（照 run_s1a_analyze_gate.sh 范本，core 基线 58 / drift 基线 162，三条注入负测试证明能变红）-> `act/10.yaml`

DEPENDS_ON 线性：01 → 02 → 03 → 04 → 05 → 06 → 07 → 08 → 09 → 10。
03/04 是全任务风险最高的两块（schema 迁移写错不报错但静默丢历史游标）。

## 验收标准

- [ ] A1 `bash scripts/run_s1b_analyze_gate.sh` 退出码 0 —— 三段式冻结门禁（照 S1a 范本），
      core 基线 **58**、drift 基线 **162**（2026-08-02 已实测，见决定记录）。**不得**写成
      「全包 `--fatal-infos` = 0」（开工前基线就是红的，S1a 同理）
- [ ] A2 `(cd core && flutter test) && (cd drift && flutter test)` 全绿，且
      drift 既有 **276** 个测试一个都不能少（新增只准加，不准改既有断言）；core 既有
      S1a 测试（64 绿）同样不能少
- [ ] A3 v6→v7 迁移测试：造一个 v6 库，升级后 `t_sync_state` 有 peerId 且**历史游标未丢**
      （回填值写错 / 建新表忘搬数据 → 必须变红）
- [ ] A4 一个 peer 标 success 后，另一个离线 peer 的该条 outbox 行仍在 `peekBatch` 里
      （ack 写回退化成全局 success → 必须变红，§5.2.1 二选一之一）
- [ ] A5 一个 peer 连续失败 10 次后**不得**把其他 peer 的同一条记录推成 dead
      （attempt 计数不 per-peer → 必须变红）
- [ ] A6 不可达 peer 的退避**不得**波及云端 push 的下次调度时间
      （`_pushFailureCount` 不 per-peer → 必须变红）
- [ ] A7 `shared` 类记录不出现在非 cloud peer 的 `peekBatch` 结果里；`lookup` 返回 null 时
      **fail closed**（过滤写成 fail-open / 直接放行 → 必须变红）
- [ ] A8 Lamport 序：`rev` 相同时按 `deviceId` 决胜，结果**确定且与两端时钟无关**
      （退化成墙上时钟 LWW → 必须变红）
- [ ] A9 冲突时被覆盖的 payload 可从 `ChangeApplyOutcome` 取回（字段被优化掉 / 只存 flag → 必须变红）
- [ ] A10 change 应用**失败**时游标**不得**推进（`canAdvanceCursor` 恒真 → 必须变红）
- [ ] A11 `PeerFanoutPusher.pushToAll` 对 N 个 peer 各返回一个结果，一个失败**不影响**其余
      （fan-out 退化成 1-of-N → 必须变红）
- [ ] A12 所有新增公开声明有中文 dartdoc，且**覆盖计数有写死下限**（正则被改窄 → 必须变红）

验收命令: `bash scripts/run_s1b_analyze_gate.sh && (cd core && flutter test) && (cd drift && flutter test)`

## 当前状态
<每完成一个子任务【覆盖重写】本节，≤12行>

## 决定记录
- 2026-08-02: A1 改三段式冻结门禁，基线 core=58 / drift=162。理由: 开工前基线就是红的
  （core 58 全为 main 分支既有断点，drift 162 全为 WARNING/INFO 级既有问题），照 S1a
  已验证的口径执行，不降低严格度（scoped analyze 必须 0 + 白名单子集 + 总数不超基线）。
- 2026-08-02: 既有 `t_sync_state` 行的 peerId 回填值定 **'cloud'**（现有唯一 peer）。
  理由: 回填错了等于所有历史游标失效、全量重拉。设计稿 §5.2.2 要求显式决定并记录。
- 2026-08-02: 转译 v1 覆盖对照（立项时定，转译后复核）:
  A1->ACT01..10(全部)+门禁脚本; A2->全部 ACT 的 flutter test; A3->ACT03; A4->ACT04;
  A5->ACT04; A6->ACT06; A7->ACT09(+ACT05 的 pushToAll 过滤入口); A8->ACT07;
  A9->ACT07; A10->ACT08; A11->ACT05; A12->ACT10。线性 01→10 无环。
- 2026-08-02: 02 端口签名变更与 03 schema 迁移拆分两个 ACT（一个管端口+fake，一个管 drift 迁移）。
  理由: schema 迁移是全任务风险最高块，STRONG_MODEL_ONLY 单独成 ACT 便于跨模型审查聚焦。

## 踩坑墓地
- 2026-08-02（环境）: drift worktree `pubspec_overrides.yaml` 只写 4 条 path 覆盖是错的——
  `dependency_overrides` 整块【替换】pubspec.yaml 同名块（不是合并），会抹掉原有 15 条
  git 覆盖，导致 `xuan_four_zhu_card` 去 pub.dev 找 `persistence_core` 冲突报错。
  正确做法: 把 pubspec.yaml 的 dependency_overrides 整块拷入 overrides 文件，只改 4 条
  `path: ../../` 为绝对路径。已由验收方修复（19 条全量覆盖），详见 S1B-PLANNING-HANDOFF.md。
- 2026-08-02（纪律，转译时必读）: S1a/S5c 各返工过一轮，两次缺陷都是「门禁恒绿抓不到
  被设计来抓的突变」。四类反面教材: `expect(SomeType, isNotNull)` 恒真 / spy 里 `fail()`
  被 catch-all 吞 / 正则手工枚举形态白名单 / happy-path 测试永远走不到失败分支。
  每一条 ACT 的 SELF_CHECK 必须真注入突变并确认变红，不做不算完成。

## 冷冻快照
<仅在搁置时由 /hibernate 填写>
