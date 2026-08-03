# 任务: storage-s1b-multipeer
负责: mimo ｜ 分支: agent/mimo/storage-s1b-multipeer ｜ 开工: 2026-08-02
状态: 蓝图

## 目标
把同步引擎从单 peer（云端）改造成多 peer：两次 drift schema 迁移 + 三个端口签名变更 + fan-out 推送 + per-peer 退避 + HLC 冲突仲裁，并修 `canAdvanceCursor` 恒真（S1b，任何 peer 实现开工前必须完成）。

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

- [ ] ACT 01: `SyncPeer` / `PeerCapabilities` / `PeerId` / `PeerFanoutPusher` 契约
  （零实现；`pushToAll` 带 **eligiblePeers**，堵住 §5.4 过滤被架空）-> `act/01.yaml`
- [ ] ACT 02: **RemoteGateway → SyncPeer 全量迁移**（14 文件，顺带修 firebase 两个既有 ERROR）-> `act/02.yaml`
- [ ] ACT 03: **drift schema 全量前置 v6→v7**（STRONG）：`t_outbox_peer_ack` 新表 +
  `t_sync_state` 加 peer_id 列（默认 'firestore'）+ 主键切三元组。
  **端口与 DAO/Store 一个字不动 ⇒ 整包全程编译绿、276 测试全绿** -> `act/03.yaml`
- [ ] ACT 04: **端口加 `peerId` + drift 实现跟进**（STRONG，本任务最大的 ACT）：
  `OutboxStore` / `SyncStateStore` **12 个方法**（enqueue 例外，新增 `attemptFor`）
  + 内存 fake 抽到 `lib/test_support/` + DAO/Store LEFT JOIN 改造 + 既有调用点。
  分四阶段推进，**红→绿在同一个 ACT 内闭环** -> `act/04.yaml`
- [ ] ACT 05: **策略过滤**：`PeerEligibility` 单一判定源 + peekBatch 按 channel 过滤（fail closed）-> `act/05.yaml`
- [ ] ACT 06: **fan-out**：`PeerFanoutPusher` 实现按 eligiblePeers 并发扇出 + coordinator 端到端接线
  （router 保持 1-of-N；attempt 走 `attemptFor` 端口）-> `act/06.yaml`
- [ ] ACT 07: **per-peer 调度接口 + 退避**（STRONG）：`PeerRegistry` / `PeerPushOutcome` /
  `pullOnce(peerId)` + 四个退避字段加 peer 维度 -> `act/07.yaml`
- [ ] ACT 08: **HLC 接线 + 属性测试**（STRONG）：`hlc_dart 1.1.0+2`（钉死）+ 时钟跨重启持久化
  + 戳存 drift 边表 `t_entity_stamp`（主键含 **scope_uid**，Data class 零改动）
  + `applyWithStamp` 同事务接口 + v8 迁移 + 3 节点仿真压单调性/因果性/收敛性 -> `act/08.yaml`
- [ ] ACT 09: **`ConflictArbiter`**（STRONG）：`(hlc, deviceId)` 全序（三路比较，禁减法）
  + 冲突**双向**留档 -> `act/09.yaml`
- [ ] ACT 10: 修 `canAdvanceCursor` 恒真 + 接入仲裁 + 畸形 payload 归 failed
  + 区分"本地无实体"与"本地有实体无戳" -> `act/10.yaml`
- [ ] ACT 11: **HLC 线上格式规格 + 黄金用例**（A14，含 signed int64 上限与 UTF-8 字节序）
  + barrel + 架构守卫 + `run_s1b_analyze_gate.sh` -> `act/11.yaml`

DEPENDS_ON 严格单链 01→02→…→11（无环）。
STRONG_MODEL_ONLY：03（schema 迁移）、04（端口+实现）、07（退避时序）、08（因果时钟）、09（定序）。
合计 **91 测试用例 / 163 验证命令 / 66 条自检注入**，11 个 ACT 全部有 ON_FAIL。

排序说明一：**策略过滤（05）刻意排在扇出（06）之前** —— 不知道谁有资格收，
就不该先建扇出。转译 v1 把过滤排在后面，导致 peekBatch 挑好的记录被
pushToAll 转头发给所有人（Codex R1 · P0-1）。

排序说明二（**方案 A，人类 2026-08-02 裁定**）：**schema 全部前置到 03，
端口变更与 drift 实现合并进 04**。
转译 v2 曾试图三步走（端口 → 加列 → 主键+实现）以保持每步可编译，但那做不到：
`DriftOutboxStore` / `DriftSyncStateStore` 直接 `implements` core 的端口，
端口一改它们立刻报 `NON_ABSTRACT_CLASS_INHERITS_ABSTRACT_MEMBER` ——
编译是被【端口变更】打断的，不是被 schema 打断的（Codex R2 实证）。
在静态类型 + 跨包 implements 下，"端口变更"与"实现跟进"无法拆到两个 ACT
而不产生不可编译的中间态。代价是 ACT 04 显著超粒度，用 STRONG + 四阶段
+ 九条自检补偿。

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

**转译 v3.1 已完成（回应 Codex R3 的 6 项），等待人类裁定是否需要 R4。代码一行未写。**

- 11 个 ACT 就位：`docs/storage-s1b-multipeer/act/01..11.yaml`
- R3 闸门：Codex 判返工 6 项 → 转译者逐条独立复核 → **采纳 6 项、驳回 1 项**（P2-1 重复 key 属误判）。
  复核与处置全文见 `docs/storage-s1b-multipeer/REACT-R3-REMEDIATION.md`
- 自检已跑（v3.1）：YAML 严格解析 11/11（含重复 key 检测）· 编号自洽 11/11 ·
  grep -c 缺双 EXPECT 0 条 · `<ACT_BASE>` 残留 0 · `|| true` 恒绿 0 ·
  验收标准 A1–A14 与 cd064c6 逐字一致
- **下一步**：人类裁定 —— 直接下发执行，或再走一轮 R4 验证本轮改动。
  ⚠ wjt-react 的 2 轮上限已被人类额外授权突破一次（R3 是那次兑现），
  **第 4 轮必须重新请示人类**。
- **冷启动接手请先读 `docs/storage-s1b-multipeer/HANDOFF.md`**（全景 + 环境坑 + 铁律）
- 遗留风险：本地 `main` 超前 `gitea/main` **27 个提交未推送**，S1b 全部工作建在这批未备份提交上。

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

- 2026-08-02（转译 v2，回应 Codex R1 的 25 项）: 结构性改动三处 ——
  ① **重排编号**：策略过滤由 ACT 09 提前到 ACT 06，扇出降到 07。根子在顺序：
     不知道谁有资格收就不该先建扇出。`pushToAll` 同时加 `required Set<PeerId>
     eligiblePeers`，并由 ACT 06 的 `PeerEligibility` 做【单一判定源】
     （peekBatch 与 coordinator 共用，有门禁数判定表达式出现次数）。P0-1 解除。
  ② **拆迁移解编译死锁**：ACT 04 改为纯加法（建新表 + 加带默认值的 peer_id 列，
     主键不动），drift 整包保持可编译、276 测试全绿，迁移测试因此能真跑；
     主键切换（v8）移到 ACT 05 与 DAO 改造同一 ACT 内从红到绿。HLC 迁移顺延 v9。P1-14 解除。
  ③ **接口先于状态**：ACT 08 先交付 `PeerRegistry` / `PeerPushOutcome` /
     `pullOnce(peerId)`，再改四个退避字段 —— 只改字段做不到"只跳过 LAN 继续推 cloud"。P0-2 解除。
  另：ACT 09/10/11 按 HLC 方案重写；冲突留档改为【双向】（keepLocal 也要留远端 loser，
  因为 skipped 不阻止游标推进，那条远端变更再也拉不到）；畸形 payload 归 failed 而非 skipped。
  全局：26 条 grep -c 补双 EXPECT（现为 0 条缺）、12 个 ACT 全部补 ON_FAIL、
  `HEAD~1` 改为不可变 `.act-base`、验收标准防篡改改为与基线提交 cd064c6 逐字比对。
  规模由 71/118/63 增至 **83 测试 / 135 验证 / 70 自检**。

- 2026-08-02（**转译审查 R2: 仍返工，wjt-react 2 轮上限用尽，已上报人类**）:
  全文见 `docs/storage-s1b-multipeer/REACT-R2-CODEX.md`。R1 那 25 项：
  修了 11 / 部分修 6 / 没修 5 / 因 HLC 方案取代而失效 4；Codex 另提 10 项新的必须返工。
  最要命的一条是转译者自己修错了地方并已实证：
  · **v2 的"拆迁移解编译死锁"救错了对象**。`DriftOutboxStore`(:614) /
    `DriftSyncStateStore`(:916) **直接 implements core 的端口**，端口一加
    `required peerId` 就必然报 `NON_ABSTRACT_CLASS_INHERITS_ABSTRACT_MEMBER` ——
    编译是被【端口变更】打断的，不是被 schema 打断的，加不加列都一样红。
    暴露的是**分解方式本身**：静态类型 + 跨包 implements 下，
    "端口变更"与"实现跟进"无法拆到两个 ACT 而不产生不可编译的中间态。
  · 另实测一条属规格缺口非现网 bug：`(l<<16)|c` 当前占 57 位，
    需 l ≥ 2^47（约公元 6440 年）才会撞 signed int64 符号位。实践安全，但规格必须写死上限。

- 2026-08-02（**方案 A，人类裁定；转译 v3**）: 合并 ACT，让端口与实现同生共死。
  人类在三个走法（A 合并 ACT / B 接受不可编译中间态改验收口径 / C 停下重新立项）中选 **A**。
  结构性改动：
  ① **schema 全部前置到 ACT 03**（v6→v7 一次做完：建 ack 表 + 加 peer_id 列 + 主键切三元组）。
     关键事实：改 `t_sync_state` 主键**不破坏编译** —— drift 的 `primaryKey` 只影响 DDL
     与 upsert 冲突目标，DAO 的 `where(列比较)` 照常编译；且此刻 peer_id 只有 'firestore'
     一个取值，三元组唯一性与二元组等价 ⇒ 行为零变化。所以 ACT 03 可以做到【全程整包绿】。
  ② **端口变更 + drift 实现合并进 ACT 04**，红→绿在单个 ACT 内闭环。
     代价：ACT 04 显著超粒度（Codex R1 · P2-25 的问题在这里被主动加重了）。
     补偿：STRONG_MODEL_ONLY + 四阶段推进（每阶段一次可验证的中间检查）+ 九条自检。
     **这是"粒度"与"可编译性"的二选一，人类明知代价后选了后者。**
  ③ ACT 05–11 整体前移一位；HLC 迁移由 v9 降为 **v8**（因为 v7/v8 合并了）。
  同时修掉 Codex R2 的其余 9 项：
  · ACT 06 实现侧 `pushToAll` 签名补 `required Set<PeerId> eligiblePeers`（v2 仍是旧签名）
  · `EntityStamps` 主键补 **scope_uid**（缺了会让两个账号下同名实体共用一行戳）
  · 新增 `HlcClockStates` 单行表结构 + `applyWithStamp(...)` **同事务生产接口**（A13 原先只有测试意图）
  · 属性测试③收敛性改为【两组独立实例、不同到达顺序】重放，不再是同一确定性函数自比
  · 新增 `compare_to_survives_extreme_magnitude` + 文本级 grep，专抓"用减法实现 compareTo"
  · ACT 10 区分"本地无实体"与"本地有实体但边表无戳"，后者必须留档
  · ACT 10 清掉 `LamportStamp` / `rev` / `overwritten*` 残留，`|| true` 恒绿门禁改为可红
  · `<ACT_BASE>` 占位符全部改为可执行的 `"$(cat .act-base)"`
  · `hlc_dart` 钉死 **1.1.0+2**；dartdoc 门禁扫描面由 3 个文件扩到 **8 个**并断言文件数
  · A14 规格补 signed int64 的 l 上限（`0 <= l < 2^47`）与 deviceId 的 **UTF-8 字节序**基准
  新增 `OutboxStore.attemptFor(operationId:, peerId:)` 读取端口（P1-15：没有它
  coordinator 只能退回 `record.attempt`，两个对端共用一个计数）；
  内存 fake 由 `core/test` 私有类抽到 `core/lib/test_support/in_memory_stores.dart`
  公开类（P1-15：跨包 import 不到私有测试类，drift 侧 parity 测试原本无从写起）。
  规模由 83/135/70 变为 **88 测试 / 158 验证 / 64 自检**，11 个 ACT 全部有 ON_FAIL。
  覆盖对照 v3（A1–A14 → ACT）:
  A1->ACT11(门禁脚本)+各 ACT 的 analyze; A2->全部 ACT 的 flutter test;
  A3->ACT03,08; A4->ACT04,05,06; A5->ACT04,06; A6->ACT07;
  A7->ACT05(+ACT06 端到端, ACT11 包级守卫); A8->ACT08,09,10(+ACT11 包级守卫);
  A9->ACT09,10; A10->ACT10; A11->ACT01,02,06; A12->ACT11(+各 ACT 自身 dartdoc 要求);
  A13->ACT08; A14->ACT09(打包往返),11(规格+黄金用例)。线性 01→11 无环。

- 2026-08-03（**转译审查 R3: 返工 6 项；转译者复核后采纳 6、驳回 1；产出 v3.1**）:
  Codex 报告 `docs/storage-s1b-multipeer/REACT-R3-CODEX.md`，
  转译者逐条复核与处置 `docs/storage-s1b-multipeer/REACT-R3-REMEDIATION.md`。
  **方案 A 成立性获 Codex 独立确认**（ACT 03「改主键不破坏编译」断言为真，
  转译者另行验证：`SyncStatesCompanion.insert` 两处调用点 :390/:420 均无 peerId 参数，
  新列带 withDefault ⇒ drift 不生成 required ⇒ 一字不改）。
  采纳并已改的 6 项：
  · **ACT 04 阶段 1** 补入 core 侧调用点迁移（sync_coordinator.dart:57/:74 +
    sync_runtime.dart）。端口一改调用点立刻编译不过，不跟进则该阶段检查
    `cd core && flutter test` 永远过不了 —— 原文只写"端口+fake+core测试"是自相矛盾的。
  · **P0-1 戳读取与构造点契约**：ACT 08 加 `getEntityStamp` 读取接口；
    ACT 10 新增两节 TASK_DETAIL 钉死 applier 构造签名（四个新增 required 回调：
    readLocalRecord / readLocalStamp / applyWithStamp / arbiter，**沿用现有回调注入风格**，
    scopeUid 不进构造参数）与全部 8 个既有构造点的迁移样板。
    **修正 Codex 的数字**：构造点是 8 处不是 7 处，且**全在 drift/test 内，
    生产 lib/ 下一处都没有**（已实测），迁移面比报告乐观，不牵动任何业务仓库。
  · **P0-2 收敛性测错性质**：HLC 的逻辑计数 c 本身就受 observe 到达顺序影响，
    要求"不同顺序重放后胜负相同"是在断言 HLC **没有承诺**的性质，实现正确也可能红。
    改法：属性测试收缩为两条不变式（单调性+因果性），
    收敛性独立成 `convergence_over_fixed_stamps` —— **先冻结一组已生成的戳**，
    再用两个独立归并器按不同到达顺序喂入。收敛性归属【归并/仲裁层】而非 HLC 生成层。
  · **P0-3 UTF-8 排序未落到 compareTo**：ACT 09 只说"字典序"，ACT 11 才提 UTF-16 分歧，
    执行者会直接用 `String.compareTo`，ASCII 测试全绿但跨语言客户端得出**相反胜负**。
    改法：契约明确要求 UTF-8 字节序 + 新增用例
    `device_id_compared_as_utf8_bytes_not_utf16`（用 U+10000 vs U+E000 这组
    UTF-8 与 UTF-16 结论相反的码点）+ 两道文本门禁（禁 deviceId.compareTo、须有 utf8.encode）。
  · **P1-1 减法自检的必红声明是假的**：A14 把合法 packed 值限定在 [0, 2^63)，
    **合法值域内相减不会符号翻转**，极端量级用例抓不到减法。
    改法：明确**禁止减法的权威门禁是文本 grep**，测试用例降级为兜底，
    并在 SELF_CHECK 里写明"不要声称那条用例一定会红"。
  · **P2-2 A1 无 TESTS_FIRST 覆盖**：A1 原先只有收工时一条 EXPECT_EXIT: 0，
    没有任何用例证明门禁能红。改法：ACT 11 新增
    `analyze_gate_catches_all_three_regressions`（COVERS: [A1]），
    要求写姊妹脚本 `scripts/test_s1b_analyze_gate.sh` 对门禁三段各做一次注入并断言必红。
  **驳回 1 项**：P2-1「重复 YAML key」为**误判**。用 PyYAML + 自定义 loader
  （对同 mapping 内重复 key 告警）扫描 11 个 ACT **零命中**；
  Codex 指的四处均为**不同 list item 的同名字段**（YAML 合法），
  且 `no_subtraction_in_compare_to` 全文件只出现 1 次。
  但采纳其修正标准后半段：严格校验器纳入常设自检流程（本轮它当场抓出了
  转译者自己引入的两处 YAML 语法错误 —— list item 以反引号开头）。
  规模由 88/158/64 变为 **91 测试 / 163 验证 / 66 自检注入**。

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
