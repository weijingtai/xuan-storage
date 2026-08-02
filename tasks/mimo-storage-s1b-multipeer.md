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
- [ ] ACT 01b: **RemoteGateway → SyncPeer 全量迁移**（14 个文件；顺带修掉 firebase 两个
  既有 ERROR：两个 gateway 从未实现 `getCapabilities`，一直靠编译 Gitea 旧 core 藏着）
  -> `act/01b.yaml`
- [ ] ACT 02: `OutboxStore` / `SyncStateStore` 全部方法加 `peerId` —— 端口 + 既有 fake 同步改（§5.2.2 阻断点 3）-> `act/02.yaml`
- [ ] ACT 03: **drift v7 迁移（STRONG_MODEL_ONLY）**：新表 `t_outbox_peer_ack`（operationId+peerId 联合主键，status/attempt/ackedAtUtc，兼 §5.3 compaction 水位表）+ `t_sync_state` 主键加 peerId + 既有行回填（建议 'cloud'）+ 迁移测试（§5.2.2）-> `act/03.yaml`
- [ ] ACT 04: **drift 侧实现改造（STRONG_MODEL_ONLY）**：`OutboxRecordsDao` / `SyncStatesDao` / `DriftOutboxStore` / `DriftSyncStateStore` 加 peerId + per-peer ack 语义（一个 peer success 不影响另一 peer 的该行）-> `act/04.yaml`
- [ ] ACT 05: `RemoteGatewayRouter` 从 1-of-N 改造成 fan-out；`PeerFanoutPusher` 实现（`pushToAll` 对 N 个 peer 各返回一个结果，一个失败不影响其余，§5.2.2 阻断点 4/5）-> `act/05.yaml`
- [ ] ACT 06: `SyncRuntime` per-peer 退避改造（`_pushFailureCount` / `_nextPullNotBeforeUtcByEntityType` 加 peer 维度，§5.2.2：不可达 LAN peer 不得拖垮云端 push 调度）-> `act/06.yaml`
- [ ] ACT 06b: **HLC 接线 + 属性测试**（引入 `hlc_dart`；时钟跨重启持久化；
  戳存 drift 边表【Data class 零改动】；`RemoteChange` 加可空 hlc/deviceId；
  3 节点仿真属性测试压单调性/因果性/收敛性）-> `act/06b.yaml`
- [ ] ACT 07: `ConflictArbiter` + **`(hlc, deviceId)` 定序**（复用 `DeviceIdentity`，不新建）+ `ChangeApplyOutcome` 增加被覆盖 payload 字段（§5.2.3 / §5.3 冲突可见化）-> `act/07.yaml`
- [ ] ACT 08: 修 `canAdvanceCursor` 恒真（`record_local_applier.dart:60-61`）—— 应用失败不推进游标 + 回归测试（§5.2.3）-> `act/08.yaml`
- [ ] ACT 09: `peekBatch` 按 channel 策略过滤（照 `policy_channel_filter_test.dart` 语义：lookup 返回 null 时 fail closed，§5.4 第一道锁）-> `act/09.yaml`
- [ ] ACT 10: **HLC 线上格式规格 + 黄金用例**（A14）+ barrel 导出 + 架构守卫测试（含中文 dartdoc 覆盖计数下限，通用式正则，S1a 教训）+ 创建 `scripts/run_s1b_analyze_gate.sh`（照 run_s1a_analyze_gate.sh 范本，core 基线 58 / drift 基线 162，三条注入负测试证明能变红）-> `act/10.yaml`

DEPENDS_ON 线性：01 → 01b → 02 → 03 → 04 → 05 → 06 → 06b → 07 → 08 → 09 → 10（无环）。
STRONG_MODEL_ONLY：03（schema 迁移）/ 04（per-peer ack 判定）/ 06（退避时序）/ 07（Lamport 定序）。
合计 71 测试用例 / 118 验证命令 / 63 条自检。

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
- [ ] A8 定序用 **HLC（Hybrid Logical Clock）+ deviceId 决胜**，不是墙上时钟、不是自造 rev。
      三条不变式各须有【属性测试】守着（3 节点仿真、随机时钟偏移、≥1000 事件）：
      ① 单调性：同一节点连续写入严格递增
      ② **因果性：若 B 收到过 A，则 B > A**（注释掉 `receiveEvent` → 必须变红）
      ③ 收敛性：任意两节点重放同一组事件，对每对版本得出同一胜负
      HLC 相等（`isConcurrentWith`）时按 `deviceId` 字典序决胜，结果确定且与两端时钟无关
- [ ] A9 冲突时被覆盖的 payload 可从 `ChangeApplyOutcome` 取回（字段被优化掉 / 只存 flag → 必须变红）
- [ ] A10 change 应用**失败**时游标**不得**推进（`canAdvanceCursor` 恒真 → 必须变红）
- [ ] A11 `PeerFanoutPusher.pushToAll` 对 N 个 peer 各返回一个结果，一个失败**不影响**其余
      （fan-out 退化成 1-of-N → 必须变红）
- [ ] A12 所有新增公开声明有中文 dartdoc，且**覆盖计数有写死下限**（正则被改窄 → 必须变红）
- [ ] A13 HLC 时钟**跨重启持久化**，且戳与记录**同事务写入**
      （重启后从物理时间重来 → 单调性变红；戳与记录分事务 → 门禁变红）
- [ ] A14 存在一份**语言中立的 HLC 线上格式规格**（48 位 l + 16 位 c 的位布局、字节序、
      deviceId 决胜规则、时钟漂移阈值）+ 一组黄金用例，供将来 Web / Rust 客户端对表

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

- 2026-08-02（转译）: ACT 01 拆为 01（契约，零破坏）+ 01b（全量迁移）。理由: 迁移要动
  core 与 firebase 两个包共 14 个文件，且顺带要修 firebase 两个既有 ERROR，
  单个 ACT 超出 30–60 分钟粒度；拆开后「新增契约」与「破坏性变更」的 diff 不混淆。
- 2026-08-02（转译，**推翻原决定**）: `t_sync_state` 既有行的 peerId 回填值由 'cloud'
  改为 **'firestore'**。理由: 必须与 ACT 01b 钉死的 `FirestoreRemoteGateway.peerId
  = PeerId('firestore')` 逐字一致，对不上则历史游标全部查不到→全量重拉。
  'cloud' 是 Channel 的名字不是 peerId。ACT 03 有跨文件比对测试守着。
- 2026-08-02（转译）: 新增 ACT 06b。理由: `RemoteChange`(types.dart:232) 只有
  operationId/entityType/entityId/opType/cursor/payloadJson/serverTimeUtc，
  **没有 rev 也没有 deviceId**，Lamport 序无处取数；而给它加字段是跨 core/firebase
  的端口变更，不应混进 ACT 07 的定序逻辑里。人类 2026-08-02 裁定走此方案。
- 2026-08-02（转译）: **Firestore 侧 `rev` 恒为 null，有意为之**。理由:
  FirestoreRemoteGateway 走 TimestampCursor 没有 revision；用 serverUpdatedAt 毫秒数
  填 rev 等于把墙上时钟改名塞进去（§5.2.3 已判定墙上时钟不可用）；新建 Firestore
  revision 分配器属于后端能力改造，超出 S1b。代价: Firestore 来源的变更只能靠
  deviceId 决胜，定序弱于 RTDB。ACT 06b 有测试钉死这个决定。
- 2026-08-02（转译）: 覆盖对照 v1（A1–A12 → ACT）:
  A1->ACT10(门禁脚本)+各 ACT 的 analyze; A2->全部 ACT 的 flutter test;
  A3->ACT03; A4->ACT02,04,05,09; A5->ACT02,04,05; A6->ACT06;
  A7->ACT09(+ACT10 包级守卫); A8->ACT06b,07(+ACT10 包级守卫);
  A9->ACT07,08; A10->ACT08; A11->ACT01,01b,05; A12->ACT10(+各 ACT 自身 dartdoc 要求)。
  每条验收标准至少有一个 ACT 的 TESTS_FIRST 覆盖，且均含非 happy-path 用例。

- 2026-08-02（**转译审查 R1: 返工**）: Codex 跨模型闸门判定不可开工，25 项必须返工。
  全文见 `docs/storage-s1b-multipeer/REACT-R1-CODEX.md`。转译者已独立复核 4 条关键指控，全部属实：
  · **P0-1 channel 过滤被 pushToAll 架空**：ACT09 只在 peekBatch 内按 channel 过滤，
    ACT05 的 `pushToAll(record)` 仍扇出给全部 peer → shared 记录照样泄漏到 LAN。
    两个 ACT 各自的测试都会绿，没有测试覆盖 coordinator→peekBatch→pusher 真实链路。
  · **P0-3 ACT06b 取错字段**：listChanges 读的是【实体文档】，其中写的是 `lastDeviceId`
    (persistence_firebase.dart:222/741/757)；ACT06b 指向的 `'deviceId'`(:644) 在
    `_deviceToMap()` 里、只进【oplog】。按 ACT 造假数据测试会绿，生产环境 deviceId 恒 null。
  · **P0-4/5 Lamport 不在同一时钟域**：RTDB 的 `_revisionRef(scopeUid, entityType)` 是
    【集合级】计数器，不是实体级版本；且本地 drift schema 【根本没有 rev 列】。
    Firestore rev null→0 遇本地 rev≥1 恒 keepLocal（Firestore 变更永不生效），
    而 ACT08 的"拿不到本地 stamp 就 takeRemote"降级又退回 RWW —— 两头都不成立。
  · **P1-18 26 条 grep -c 缺双 EXPECT**：实测确为 26 条、涉及 11 个 ACT
    （仅 ACT01 幸免）。转译者在 ACT10 里写下这条规则，却在其余 ACT 里违反了它。
  其余待人类裁定项：ACT05 router 职责与纪要计划自相矛盾（计划说改 fan-out，
  ACT 却守卫它保持 1-of-N）；ACT09 给 backlog/watch/dead 三方法扩 channel 属计划外扩张。

- 2026-08-02（**人类设计裁定，推翻转译 v1**）: 冲突定序改用 **HLC + deviceId**，
  弃用转译者自造的 `(rev, deviceId)`。选型经过：`drift_crdt`（**装不上** ——
  依赖 sql_crdt/sqlite_crdt ^4.0.0，pub.dev 最高只到 3.x，实跑求解失败）；
  `Ditto`（闭源商业，初始化就要 Portal 账号与 Playground Token，纯离线 SharedKey
  需 support@ditto.com 申请许可，文档型数据库）；`sql_crdt`（抽象层可用 drift 后端，
  但 200 个写调用点要改裸 SQL + 全局软删）；`crdt_lf`+`crdt_lf_drift`（工程质量最高，
  160/160，但为协同文档编辑而生，需双写架构，且要求 drift ^2.34.0 而本仓是 2.31.0）。
  **选 `hlc_dart` 1.1.0+2**（160/160，零第三方依赖）：只取 HLC，不碰数据模型。
- 2026-08-02（澄清）: **HLC 单独不构成全序** —— `HybridLogicalClock` 只有 (l, c)
  没有 nodeId，两台设备同毫秒写会 `isConcurrentWith`。故定序是 **(hlc, deviceId)**。
  HLC 的价值是消灭【因果倒置】（B 收到过 A 则 B 必 > A），把"随机丢数据"
  降级为"并发时按固定规则选一个"；真并发谁更晚物理上不可判定，由 §5.3 冲突可见化兜底。
- 2026-08-02（放置决定）: HLC 戳存 **drift 边表**，键 (entityType, entityId)，
  **`RecordMeta` 与所有 Data class 零改动**、不跨仓库。代价：戳与记录不同行，
  必须同事务写（A13 门禁守）。否决放 RecordMeta（跨 repository-interface-record 仓库）
  与只放同步信封（本地无戳可比，不成立）。
- 2026-08-02（跨语言）: 选 HLC 的最强理由是**协议自主**。`hlc_dart` 的序列化是
  显式可移植的（toInt64 = (l<<16)|c；toUint8List = 8 字节大端），任何语言几十行可复现。
  crdt_lf/sql_crdt 的二进制格式归包作者所有，换包等于换协议。故新增 A14：
  必须产出语言中立规格 + 黄金用例，为将来 Web/Rust 客户端留门。
- 2026-08-02（**验收标准区变更，人类授权**）: A8 由「Lamport (rev, deviceId)」
  改写为「HLC + deviceId + 三条属性测试不变式」；新增 A13（时钟持久化 + 同事务）
  与 A14（线上格式规格）。转译者本无权改验收标准区，本次依人类当次设计裁定执行并留痕。
- 2026-08-02（router 职责，人类确认）: `RemoteGatewayRouter` **保持 1-of-N**
  （区域轴：大陆 Supabase / 海外 Firebase，用户 VPN 切换或出国才用，一年可能一次，冷路径），
  它作为「云」这一个对端参与扇出。纪要原计划「router 改造成 fan-out」措辞不精确，
  按字面执行会变成同时写两个云 —— 那是 bug 不是需求。对端轴的扇出由 PeerFanoutPusher 承担。

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
