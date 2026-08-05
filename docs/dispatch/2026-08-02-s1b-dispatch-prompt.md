# S1b 下发 Prompt —— 同步引擎多 peer 化

> 生成于 2026-08-02。本文件是**冷启动可用**的下发单：接手者不需要任何历史会话上下文。
> 用法：把本文件全文（或本文件路径）交给执行 Agent。

---

## 0. 你是谁、在哪、干什么

你接手 **S1b：同步引擎多 peer 化**。这是存储架构重构的第二个子系统。

**主仓库**：`/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage`（独立 git 仓库，当前分支 `main`）

⚠ `xuan-migration` 是容器目录（monorepo workspace），**不是 git 仓库、也不是 submodule 集合**，它下面是 55 个各自独立的 git 仓库。**不要在 `xuan-migration` 根目录执行 git 命令。**

**规格来源（唯一真相）**：
```
docs/superpowers/specs/2026-07-31-storage-architecture-design.md
```
1659 行，已过 `/autoplan` 三阶段评审 + Codex 跨模型验证。**S1b 的全部依据在 §5.2.1 / §5.2.2 / §5.2.3 / §5.3 / §5.4 与 §9 的排期表。按 § 号定位原文，不要凭记忆写。**

**语言要求**：与人类对话用中文；产出文档以中文为主；**源代码注释必须中文**。只有源码路径、类名、命令这类说英文才准确的东西才用英文。

---

## 1. 前置状态（已核实，你可以直接信任）

### S1a 已完成并合入 main
契约层已在 `core/lib/model/` 落地，S1b 直接消费，**不要重新发明**：

| 文件 | 提供什么 |
|---|---|
| `core/lib/model/storage_classification.dart` | `enum Channel { cloud, lan, webrtc, manualExport }` 等六个分类 enum |
| `core/lib/model/storage_policy.dart` | `StoragePolicy` sealed 类族；`channels` getter（`cloud` 结构性恒在） |
| `core/lib/model/storage_policy_registry.dart` | `StoragePolicyRegistry.lookup(entityType)` / `.all` |
| `core/lib/model/transport.dart` | `Transport` / `PeerIdentity` / `PeerSession` 端口签名 |
| `core/lib/model/cancellation_token.dart`、`blob_*.dart`、`export_bundle.dart` | blob 与导出契约 |

`core/test/policy_channel_filter_test.dart` 是 **S1b 推送过滤语义的可执行规格** —— 它已经写好了 `filterForChannel` 的正确形状（`lookup` 返回 null 时 **fail closed**）。S1b 要把这个语义落进 `peekBatch`。**先读它。**

### S5c 已完成（另一个仓库，与 S1b 无代码耦合）
`xuan_config` 的远端配置下发已交付。S1b 不依赖它。

### 六个硬阻断点（设计稿 §5.2.1，我已逐条核实路径与行号仍然准确）

| # | 阻断点 | 位置（已核实存在） |
|---|---|---|
| 1 | `t_outbox` 主键只有 `{operationId}`，无 peerId | `drift/lib/persistence_drift.dart:179` |
| 2 | `t_sync_state` 主键只有 `{scopeUid, entityType}`，无 peerId | `drift/lib/persistence_drift.dart:215` |
| 3 | `markSuccess({operationId, atUtc})` 无 peerId | `core/lib/model/ports.dart:57` |
| 4 | `RemoteGateway.push` 返回单个 `SyncError?`，N 个结果压不成一个 | `core/lib/model/ports.dart:183` |
| 5 | `RemoteGatewayRouter` 是 1-of-N 选择器，不是 fan-out | `core/lib/routing/remote_gateway_router.dart`（51 行） |
| 6 | `getCapabilities()` 返回 `RegionCapabilities`，不是 `PeerCapabilities` | `core/lib/model/ports.dart:206` |

**当前 drift `schemaVersion = 6`**（`drift/lib/persistence_drift.dart:541`），`onUpgrade` 已有 `from < 2..6` 五段。S1b 要加的是 **v7**。

### 影响面（我已实测，这条很重要）
```
下游 12 个业务仓库（calendar / xuan-ai / xuan-bazi / xuan-daliuren / xuan-four-zhu-card /
xuan-liuyao / xuan-meihuayishu / xuan-qimendunjia / xuan-qizhengsiyu / xuan-taiyishenshu /
xuan-tiebanshenshu / xuan-ziweidoushu）没有任何一处直接引用
OutboxStore / SyncStateStore / markSuccess / peekBatch。
```
**结论：S1b 的破坏性签名变更被完全关在 `xuan-storage` 内部。** 调用点只有：
- `core/lib/core/sync_coordinator.dart:57, 74`
- `core/lib/sync/sync_runtime.dart`（769 行，退避计数在这）
- `drift/` 的实现与测试、`core/test/persistence_core_test.dart` 的 fake

**不要**以「怕影响下游」为理由把签名变更做成兼容式重载。可以直接改。

---

## 2. 工作方式：wjt 协议链

本项目用固定协议，**不要跳步**：

1. **`/wjt-plan`** —— 立项。产出 worktree + 任务纪要（目标 / 计划 / 验收标准 + 验收命令 / 决定记录）。
   - 任务短名：`storage-s1b-multipeer`
   - 执行者：按人类指示（历史上用 `mimo` 免费通道跑便宜活）
   - 类型：`feat`
   - 用 `aiwt new <执行者> <任务名>` 建 worktree（主工作区 `git status` 干净时）。
2. **`/wjt-act`** —— 把计划区转译为 ACT 机械执行文档（`docs/storage-s1b-multipeer/act/NN.yaml`）。转译**不得**改动「验收标准」区。
3. **`/wjt-react`** —— 转译闸门，由**不同厂商**的模型（Codex）跨模型审查 ACT 是否忠实、覆盖是否完整、便宜模型能否直接开工。≤2 轮。
4. 派发执行体逐个 ACT 执行。
5. 人类验收。

**铁律**：AI 不得自行合并到 main、不得 push 到远端，除非人类当次明确授权（授权只对当次有效，不延续）。`aiwt done/drop/freeze` 只能由人类发起。

---

## 3. S1b 的范围（照 §5.2.2 / §5.2.3，不要扩，不要缩）

### 3.1 两次 drift schema 迁移 —— **STRONG_MODEL_ONLY**

**新表 `t_outbox_peer_ack`**（同时是 §5.3 oplog compaction 的水位表 —— 因此 compaction 的数据模型不能列为「待决」，它决定 schema）：
```dart
class OutboxPeerAcks extends Table {
  TextColumn get operationId => text()();
  TextColumn get peerId => text()();
  TextColumn get status => text()();          // pending/success/failed/dead
  IntColumn  get attempt => integer()();
  DateTimeColumn get ackedAtUtc => dateTime().nullable()();
  @override Set<Column> get primaryKey => {operationId, peerId};
}
```

**`t_sync_state` 主键加 peerId**：`{scopeUid, entityType}` → `{scopeUid, peerId, entityType}`。

迁移到 **v7**，`onUpgrade` 加 `if (from < 7)` 分支。
- 主键变更在 SQLite 上不是 `ALTER TABLE` 能做的，必须走 drift 的 `TableMigration` / 建新表+搬数据+改名。**照 §5.2.2 与 drift 官方迁移文档做，不要自创。**
- 既有行的 `peerId` 回填值必须显式决定并写进决定记录（建议 `'cloud'`，即现有唯一 peer）。**回填错了等于所有历史游标失效、全量重拉。**

### 3.2 三个端口签名变更
- `OutboxStore` 全部方法加 `peerId`（`peekBatch` / `markSuccess` / `markFailed` / `backlogCount` / `watchBacklogCount` / `deadCount`）。
- `SyncStateStore` 全部方法加 `peerId`。
- `SyncPeer`：`getCapabilities()` 返回 `PeerCapabilities` 而非 `RegionCapabilities`。接口叫 `SyncPeer`，**实现类名仍叫 `*Gateway` 不改**（§5.2 命名说明）。

### 3.3 `PeerFanoutPusher`
```dart
abstract interface class PeerFanoutPusher {
  Future<Map<PeerId, SyncError?>> pushToAll(OutboxRecord record);
}
```
取代 `OutboxPusher`。`RemoteGatewayRouter` 从 1-of-N 选择器改造为 fan-out（或新增 fan-out 路径，保留 router 作路由）。

### 3.4 per-peer 退避
`SyncRuntime` 的 `_pushFailureCount` 与 `_nextPullNotBeforeUtcByEntityType` 必须 per-peer。
**理由（写进 ACT，防止执行体简化掉）**：不 per-peer 的话，一个不可达的 LAN peer 会把云端 push 一起拖进 2 分钟退避。

### 3.5 `ConflictArbiter` + Lamport 序
- Lamport 序 = `(rev, deviceId)`。`DeviceIdentity` 已存在于 `core/lib/model/ports.dart:240`，**复用它，不要新建**。
- 纯墙上时钟 LWW 在多 peer 下不可用（两台设备差 30 秒就能让两周编辑量归属随机）—— §5.2.3 原文。
- `ChangeApplyOutcome` 增加承载**被覆盖 payload** 的字段（§5.3「冲突可见化」在现有端口上无处安放）。

### 3.6 修 `canAdvanceCursor` 恒真
`drift/lib/sync/record_local_applier.dart:60-61` 成功路径 `canAdvanceCursor: true` 恒为真，全文件对 `updatedAt`/`rev` 只有 2 处匹配、**无任何比较逻辑**。后果：某条 change 应用失败被记 failed 时游标照常推进，**那条变更永久丢失**。

### 3.7 推送侧策略过滤（§5.4 第一道锁）
`peekBatch` 按 `channel` 过滤，`shared` 类记录不派发给非 cloud peer。
**语义已由 `core/test/policy_channel_filter_test.dart` 写死：`StoragePolicyRegistry.lookup` 返回 null 时 fail closed（不派发）。照抄这个语义。**

> ⚠ 设计稿明确删除了上一版「拓扑上无法到达」的说法 —— 那是假的。过滤是**主动**的，没有它草稿 oplog 照样会 fan-out 到本人的 LAN peer。

### 3.8 明确**不在** S1b 范围
- 任何 peer 的**实现**（LAN / WebRTC / 导出导入）—— 那是 S3a/b/c，还依赖 S6。
- E2EE 密钥管理 —— S6。
- oplog compaction 的**算法**（只需把水位表 schema 定死，压缩策略本身可留到后续）。

---

## 4. 验收标准的写法要求（本项目最重要的一条纪律）

S1a 与 S5c 各返工过一轮，**两次的缺陷都不是生产代码写错，而是「门禁恒绿、抓不到它被设计来抓的突变」**。血泪清单：

| 反面教材 | 为什么恒绿 |
|---|---|
| `expect(SomeType, isNotNull)` | Type 对象永不为 null，**永远不可能变红** |
| spy 源里用 `fail('不该被调用')` | 被调用方的 `catch (e)` catch-all 吞掉 `TestFailure`，源被真调了测试照样绿 |
| 门禁正则手工枚举声明形态白名单 | 少列一种形态就静默漏掉，且没人会发现 |
| 「过期缓存降级」测试里放了一个会成功的兜底源 | 「全部失败」那条分支从未被走到 |

**因此 S1b 的每一条验收标准都必须满足：**

1. **可机械执行**：一条命令 + 一个期望退出码。
2. **必须能变红**：写完之后，**亲手把实现改坏**，确认对应测试变红，再改回。这一步写进 ACT 的 `SELF_CHECK`，不做不算完成。
3. **spy 用计数，不用 `fail()`**：记录调用次数，在被测方法返回**之后**由测试主体显式断言。
4. **非 happy-path 必须覆盖**：只测成功路径的 ACT 不合格。
5. **覆盖类门禁必须有写死的数量下限**：断言 `count >= N`，否则正则被改窄后门禁静默失效。

### 建议的 S1b 验收标准骨架（立项时细化，此处给形状）

| # | 标准 | 必须能被哪个突变打红 |
|---|---|---|
| A1 | `cd core && dart analyze --fatal-infos` 与 `flutter test` 全绿；drift 同 | — |
| A2 | v6→v7 迁移测试：造一个 v6 库，升级后 `t_sync_state` 有 peerId 且**历史游标未丢** | 回填值写错 / 建新表忘搬数据 |
| A3 | 一个 peer 标 success 后，**另一个离线 peer 的该条 outbox 行仍在 `peekBatch` 里** | 把 ack 写回退化成全局 success（§5.2.1 的「二选一都不可接受」之一） |
| A4 | 一个 peer 连续失败 10 次后**不得**把其他 peer 的同一条记录推成 dead | attempt 计数不 per-peer |
| A5 | 不可达 peer 的退避**不得**波及云端 push 的下次调度时间 | `_pushFailureCount` 不 per-peer |
| A6 | `shared` 类记录不出现在非 cloud peer 的 `peekBatch` 结果里；`lookup` 返回 null 时 **fail closed** | 过滤写成 fail-open / 直接放行 |
| A7 | Lamport 序：`rev` 相同时按 `deviceId` 决胜，结果**确定且与两端时钟无关** | 退化成墙上时钟 LWW |
| A8 | 冲突时被覆盖的 payload 可从 `ChangeApplyOutcome` 取回 | 字段被优化掉 / 只存了 flag |
| A9 | change 应用**失败**时游标**不得**推进 | `canAdvanceCursor` 恒真（当前就是这个 bug） |
| A10 | `PeerFanoutPusher.pushToAll` 对 N 个 peer 各返回一个结果，一个失败**不影响**其余 | fan-out 退化成 1-of-N |
| A11 | 所有新增公开声明有中文 dartdoc，且**覆盖计数有写死下限** | 正则被改窄 |

---

## 5. 分工建议（立项时定，供参考）

| ACT | 内容 | STRONG_MODEL_ONLY |
|---|---|---|
| 01 | `PeerCapabilities` / `PeerId` / `SyncPeer` 端口签名 + `PeerFanoutPusher` 契约（零实现） | ❌ |
| 02 | `OutboxStore` / `SyncStateStore` 加 peerId —— 端口 + fake 同步改 | ❌ |
| 03 | **drift v7 迁移**：`t_outbox_peer_ack` 新表 + `t_sync_state` 主键 + 回填 + 迁移测试 | ✅ **必须** |
| 04 | drift 侧 `OutboxStore`/`SyncStateStore` 实现改造 + per-peer ack 语义 | ✅ **必须** |
| 05 | `RemoteGatewayRouter` → fan-out；`PeerFanoutPusher` 实现 | ❌ |
| 06 | `SyncRuntime` per-peer 退避改造 | ✅ |
| 07 | `ConflictArbiter` + Lamport 序 + `ChangeApplyOutcome` 扩展 | ✅ |
| 08 | 修 `canAdvanceCursor` 恒真 + 失败不推进游标的回归测试 | ❌ |
| 09 | `peekBatch` 策略过滤（照 `policy_channel_filter_test.dart` 语义） | ❌ |
| 10 | barrel 导出 + 架构守卫测试（含 dartdoc 覆盖下限） | ❌ |

`DEPENDS_ON` 线性：01 → 02 → 03 → 04 → 05 → 06 → 07 → 08 → 09 → 10。
03/04 是全任务风险最高的两块（schema 迁移写错不会报错，但会静默丢历史游标）。

---

## 6. 开工前必须先读的文件（不要跳过，S1a 就是因为漏给 READ 导致执行体自己发明接口）

```
docs/superpowers/specs/2026-07-31-storage-architecture-design.md   # §5.2.1–5.2.3, §5.3, §5.4, §9
core/lib/model/ports.dart                                          # OutboxStore/SyncStateStore/RemoteGateway/DeviceIdentity 现状
core/lib/model/transport.dart                                      # S1a 交付的 Transport/PeerIdentity/PeerSession
core/lib/model/storage_classification.dart                         # Channel enum
core/lib/model/storage_policy_registry.dart                        # lookup/all
core/test/policy_channel_filter_test.dart                          # 推送过滤的可执行规格
core/lib/core/sync_coordinator.dart                                # peekBatch/markSuccess 的唯一业务调用点
core/lib/sync/sync_runtime.dart                                    # 退避计数所在（769 行）
core/lib/routing/remote_gateway_router.dart                        # 要改造成 fan-out 的 1-of-N 选择器
drift/lib/persistence_drift.dart                                   # 表定义 179/215、schemaVersion 541、onUpgrade 550
drift/lib/sync/record_local_applier.dart                           # canAdvanceCursor 恒真 bug 在 60-61
tasks/mimo-storage-s1a-contracts.md                                # S1a 纪要，看验收标准与决定记录怎么写
```

---

## 7. 主工作区当前有两处未提交改动（不是你的，别动）

```
 M firebase/infrastructure/emulator/firestore.rules   # 放宽了 identity_map 的 allow write
?? .codegraph/daemon.pid
```
立项建 worktree 前若 `aiwt new` 因工作区不干净而拒绝，**上报人类**，不要自作主张 stash 或提交。

---

## 8. 第一步做什么

不要直接写代码。按顺序：

1. 读完第 6 节列的全部文件（尤其设计稿 §5.2.1–§5.2.3 原文）。
2. 核对我在第 1 节列的六个阻断点行号是否仍准确（我在 2026-08-02 核实过，但你要自己再看一眼）。
3. 执行 `/wjt-plan`，任务短名 `storage-s1b-multipeer`，把第 3 节的范围与第 4 节的验收标准骨架蒸馏进任务纪要。
4. 立项完成后**停下来**汇报一行：worktree 路径 / 计划 N 项 / 验收命令，等人类说「开工」或指派执行体。

**发现设计稿本身有漏洞或歧义**：在纪要「决定记录」提异议并停下上报，**不许擅自扩充范围**。
