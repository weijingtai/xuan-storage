# S1c 全量对齐（Full Reconciliation）· 设计与实施计划

> 立项日期：2026-08-03
> 依赖：S1a（分类契约）+ S1b（同步引擎多 peer 化）+ S6（设备配对）
> **阻断：S3 实现 oplog compaction 前，本子系统必须已交付**
> 上游总纲：`2026-07-31-storage-architecture-design.md`（§5.2 / §5.3 / §9 / §10）

---

## 1. 为什么需要这个子系统

S1b 交付后，同步引擎具备完整的**增量**能力：per-peer ack、per-peer 游标、扇出推送、
`(hlc, deviceId)` 全序仲裁。但增量的前提是**游标可信** —— 游标声称
「我已拥有 T 之前的全部变更」，对端据此只发 T 之后的差异。

以下四种情况下这个前提不成立，而 S1b **没有任何机制**处理它们：

| # | 场景 | 两端实际状态 |
|---|---|---|
| 1 | 新设备首次入网 | 一端为空，另一端有全量 |
| 2 | 设备数据丢失（重置系统 / 误删 / 重装） | 一端为空，另一端有全量 |
| 3 | 久未上线（半年没开机） | 一端有子集，另一端有全量 |
| 4 | 对端压缩过 oplog（S3 实现 compaction 后） | 增量区间已不可重放 |

**这四者对同步引擎是同一个问题**：两端状态未知，水位不可信，必须先清点再补齐。
因此本子系统用**一套机制**覆盖全部四种情况。

### 1.1 不做的后果（按严重度）

**① compaction 上线即静默丢数据**（最严重）

总纲 §10 已把 compaction 的算法与触发时机指派给 **S3**。若 S3 在本子系统之前实现它：

```
电脑游标 = 半年前
手机把一个月前的 oplog 压掉了

电脑：给我半年前之后的变更
手机：只能给一个月内的（更早的已被压缩）
电脑：收下 → 游标推进到"现在"

→ 中间五个月的变更永久消失，全程零报错
```

电脑的游标从此在撒谎：它声称拥有半年来的全部数据，实际缺一大块。
**没有任何测试会红，没有任何日志会报错。**

**② 新设备无法入网**

`PeerRegistry.register(peer)`（S1b `act/07.yaml:70`）只是往集合里加一个元素，
**不触发任何握手**。一个游标为空的新 peer 会尝试拉「从时间零点起的全部变更」，
而 oplog 里并没有创世以来的所有操作。

**③ 久未上线的设备重放数万条操作**

总纲 §5.3 原文：「否则首次同步一台久未使用的设备需重放数万条操作。」
即使 oplog 完整（未压缩），逐条重放半年积累的操作也是错的成本模型 ——
一条实体被改过 200 次，重放 200 次，最终状态只有一个。

**④ compaction 永远不触发**

判据是「所有已知 peer 均已 success」。一台用过一次就再没用的设备永不 ack，
outbox 一行都删不掉，无限增长。

---

## 2. 核心决策

### 2.1 全量的语义是「全量比对」，不是「全量传输」

**必须先比对清单、逐条过仲裁器，不能无条件覆盖。**

```
纯全量拉取 = 对端把 500 条都发过来，本地照单收下
  → 离线期间本地改的东西被无条件覆盖
  → 总纲 §5.3 点名的静默丢数据（LWW 在会话式同步下的固有缺陷）
```

一旦比对了清单，跳过版本相同的条目是顺带的收益。所以「全量」指
**对齐范围是全量**，传输量取决于实际差异。

### 2.2 传终态，不重放 oplog

对齐时发送的是实体的**当前状态**，不是产生它的操作序列。

| | 重放 oplog | 传终态 |
|---|---|---|
| 一条实体被改 200 次 | 传 200 次 | 传 1 次 |
| 依赖 oplog 完整 | 是 | **否** |
| 与 compaction 兼容 | 否 | **是** |

这是本方案与「版本向量 + oplog 重放」路线的分水岭：后者要求 oplog 永不压缩，
而我们要做 compaction，前提自我否定。

### 2.3 清单直接建在 `t_entity_stamp` 上

S1b ACT 08 交付的边表：

```
t_entity_stamp (scope_uid, entity_type, entity_id) → (hlc_packed, device_id)
```

**这张表本身就是一份清单** —— 每条实体当前是哪个版本，一行一条。
清单交换直接读它，不需要新建表。

> 该表当初选边表方案是为了「业务 Data class 零改动」，与清点无关，属意外收获。

### 2.4 双向对齐

**必须双向。** 离线期间本地也可能写入过对端没有的东西，单向补齐会丢数据。

### 2.5 阈值 90 天，且对端有最终否决权

```
对端上线
   │
   ├─ 无游标 ───────────────────┐  场景 1、2
   ├─ 游标龄 > 阈值（默认 90 天）┤  场景 3
   ├─ 对端拒绝增量 ─────────────┤  场景 4
   │                            ▼
   │                       【全量对齐】
   └─ 其余 ────────────────→ 增量拉取（S1b 既有）
```

**第三条是关键**：阈值是本地的猜测，对端的 oplog 才是事实。
本地以为在 90 天内，但对端换过设备、重装过，oplog 只剩一周 ——
只有对端能判断。因此协议必须允许对端回复「你的游标早于我的保留水位，
增量给不了你」并强制全量。

**否决载体（定稿）**：否决不走异常、不走静默空页（空页会被当作「无变更」，游标照常推进，正是 §1.1① 的静默丢数据）。
挂载点为 `SyncPeer.listChanges`（`core/lib/model/sync_peer.dart:55`，返回 `Future<RemoteChangesPage>`，`RemoteChangesPage` 见 `core/lib/model/types.dart:287`）：

- 返回类型从 `Future<RemoteChangesPage>` 收窄为 `Future<RemoteChangesResult>`，
  其中 `RemoteChangesResult = RemoteChangesPage | IncrementalUnavailable`（sealed）。
- `IncrementalUnavailable` 携带：`PeerId peerId`、`String entityType`、`PullCursor? requesterCursor`（发起方游标）、
  `DateTime? peerRetentionFloorUtc`（对端保留水位，供发起方诊断/UX）、
  `IncrementalUnavailableReason reason`（枚举：`behindRetention` / `compactedAway` / `peerRefused`）。
- 发起方收到 `IncrementalUnavailable` 后**强制切全量对齐**，且**不得推进游标**。

⚠ **这是 S1a 契约签名变更**（`listChanges` 返回类型收窄）。按派工 §五「不改 core/lib/model/ 下任何 S1a 契约」：
本设计稿只定稿签名提案，写进「决定记录」（§6）；实现侧须**停下上报人类**，批准后才可在 ACT-A 实现。
ACT-A 在未获批准前不得自行收窄 `listChanges` 返回类型。

**受影响实现方清单（评审 R1 P1-2 补）**：`listChanges` 是多实现接口，收窄返回类型会波及以下全部实现方与调用方，须【同步适配】：
- 接口：`core/lib/model/sync_peer.dart:66`（`SyncPeer.listChanges`）
- 实现方 1：`core/lib/routing/remote_gateway_router.dart:15,50`（`RemoteGatewayRouter implements SyncPeer`，转发到 `_active`）
- 实现方 2：`firebase/lib/firebase_realtime_remote_gateway.dart:27`（`FirebaseRealtimeRemoteGateway implements SyncPeer`，属 S2 云端通道）
- 实现方 3：`firebase/lib/persistence_firebase.dart:21`（`FirestoreRemoteGateway implements SyncPeer`，属 S2 云端通道）
- 调用方：`core/lib/core/sync_coordinator.dart:407`（`pullGateway.listChanges`）
⚠ 实现方 2/3 属 S2 云端通道，不在 S1c 范围。签名收窄须全部实现方同步适配 -- 这是人类批准签名变更决策的一部分。
S1c 的 ACT-A 只负责【提案签名 + core 接口与路由实现方适配】；firebase 两个网关的适配归 S2 通道（或人类指定的协调方），S1c 不越界改 firebase。

**阈值取值理由**：

- 取 **90 天**（可配置），**不取 6 个月**；
- 硬约束：**阈值必须小于 oplog 保留窗口**，否则出现
  「本地认为可增量、对端已压缩」的空隙 —— 而那个空隙就是 §1.1① 的静默丢数据；
- 建议配比：阈值 90 天 / 保留窗口 180 天，留一倍安全余量。

### 2.6 oplog 保留窗口是数据的属性，不是对设备的猜测

早期讨论曾考虑「一台设备多久算失联该被遗忘」。**该提法已否决** ——
它在猜测设备行为，而设备可以离线三年后回来。

正确的表达是 oplog 保留窗口：

```
oplog 保留 N 天
游标落在窗口内 → 增量，便宜
游标落在窗口外 → 强制全量对齐
```

好处：设备离线多久都无所谓，回来自动走全量。且允许 ack 行在超过保留窗口后
被清理，compaction 不再被一台失联设备永久卡住 —— **无需「遗忘设备」这个动作**。

由此，早期两个待决策略只剩一条产品问题：**用户能否手动移除设备**（归 S6 的设备管理 UI）。

---

## 3. 全量对齐协议

### 3.1 四阶段

```
① 发起方 → 对端：清单分片
   [(entity_id, hlc_packed, device_id), ...]   按 (scope, entityType) 分片

② 对端【双遍历】比对：先遍历自己的清单，再遍历收到的清单，分五类：
   【遍历自己清单】
   本地有 / 对方无           -> 发终态给对方
   双方都有，本地版本更新    -> 发终态给对方
   双方都有，对方版本更新    -> 请对方发来
   版本相同                 -> 跳过
   【遍历收到清单】
   本地无 / 对方有           -> 请对方发来（EntityRequest）  ← 场景 1/2 新设备入网的核心路径

③ 双方各自把收到的终态过 ConflictArbiter，
   【同事务】写记录 + 写戳（S1b A13 门禁的既有要求）

④ 双方游标各自设为"现在"
```

**消息线序（定稿）**：四阶段是双向消息序列，线序为：

```
发起方                          对端
  │  ① 清单分片（ManifestChunk）   ->
  │                                 │ 双遍历比对（见② 五类）
  │  <- ②a 终态（EntityTerminal）   │  本地有/对方无 或 本地更新
  │  <- ②b 索求（EntityRequest）    │  对方更新 或 本地无/对方有，请对方发来
  │  ②b' 终态（EntityTerminal）  ->  │  回应索求
  │  ④ 游标确认（CursorAdvance） ->  │  双方各自③过仲裁器+同事务写后
  │                                 │  游标设为现在
```

消息类型：`ManifestChunk`、`EntityTerminal`、`EntityRequest`、`CursorAdvance`（皆为值类型，定义在 core 契约层）。

**承载流形态（定稿）**：新增 `StreamKind.reconciliation`（`core/lib/model/transport.dart:19` 现有 `oplog`/`blobChunk` 两种，新增第三种）。
全量对齐的四类消息复用同一条 `reconciliation` 逻辑流，靠消息类型字段区分（不每类开一流，避免多路复用碎片化）。
断点续传的分片 id = `(scopeUid, entityType, chunkSeq)`，`chunkSeq` 从 0 递增；中断后发起方在 `reconciliation` 流上重发未确认的 chunk。
⚠ 这是新增枚举值，不改 `oplog`/`blobChunk` 既有语义，符合派工 §五。
```

### 3.2 三个必须定死的细节

这三处是同类方案最常见的错误来源。

**① 删除必须能被表达 -- 否则已删数据复活**

设想：电脑离线期间手机删了 10 条。若清单只列活实体，那 10 条在电脑清单里、不在手机清单里 --
会被判成「手机缺失，从电脑补回来」，**用户删掉的数据自己回来了**。

**单戳墓碑模型（定稿）**：
- `t_entity_stamp` 加一列 `is_deleted`（bool，默认 false）。
  ⚠ 只加列，不触既有列语义（`hlcPacked`/`deviceId`/PK），符合派工 §五「不改 S1b 的 t_entity_stamp 既有列语义」。
- 删除事件发生时，`hlcPacked`/`deviceId` **更新为该删除事件的戳**（不是另存一套戳）--
  一行【只保留一套戳】，代表「该实体最近一次变更（可能是删除）的版本」。
  ⚠ 不存在「墓碑戳 vs 实体戳」双值--一行一套戳，删除只更新这套戳 + 置 `is_deleted=true`。
- **清单必须含 `is_deleted=true` 墓碑行**（定稿）：清单含全部未压缩的戳行，**含墓碑行**。
  「保留行」的语义就是「墓碑行也在清单里」--否则手机删的 10 条永远传不到电脑。
  （本节原「清单只列出存在的实体」已废，改为「清单含全部未压缩戳行，含墓碑」。）
- **墓碑保留期 ≥ 全量对齐阈值**（90 天）：墓碑早于阈值过期 ⇒ 同一个复活缺陷。
- **墓碑清理归属（评审 R1 P2-1 补）**：过期墓碑行的清理归 compaction 周期（与 oplog 保留窗口同步，归 S3，见 §4），S1c 自身不实现 compaction。S1c 只保证「清单含全部未过期墓碑行」；过期墓碑由 S3 的 compaction 在保留窗口外清理。清理判据 = 墓碑戳早于 oplog 保留窗口（180 天）且所有已知 peer 均已 ack 到该戳之后。

**裁决规则（沿用 S1b 三态，不新增第四态；单戳模型下就是纯全序比较）**：
- 比对单位是「一行的戳 `(hlcPacked, deviceId)` + `is_deleted` 位」。
- 两端各一行，按 `VersionStamp.compareTo`（`core/lib/model/conflict_arbiter.dart:27-88`，先比 hlc.dateTime、再比 counter、最后比 deviceId 的 UTF-8 字节序）全序比较戳：
  - 远端戳 > 本地戳 -> `takeRemote`（applier 按远端 `is_deleted` 决定写活记录还是墓碑）；
  - 远端戳 < 本地戳 -> `keepLocal`（本地版本更新，远端被丢弃）；
  - 戳相等 -> `identical`（同版本，无操作）。
- `is_deleted` **不参与定序**，它是 applier 在 `takeRemote` 后决定写形态的数据位。
  - 「本地活、对端墓碑且戳更大」-> `takeRemote` + 远端 `is_deleted=true` -> 本地变墓碑；
  - 「本地墓碑、对端活且戳更大」-> `takeRemote` + 远端 `is_deleted=false` -> 本地复活为活记录（含「删除后被重新创建」）。
- 「戳相等但 is_deleted 不同」不可能：戳含 deviceId + (dateTime,counter)，同一写操作要么删要么改，不会同戳异态；
  若出现属数据损坏，fail-safe 取 `keepLocal`（不静默改态）。
- **`ConflictArbiter` 零改动**：墓碑的「删/不删」是数据内容（`is_deleted` 列），不是仲裁决策。
  仲裁器仍只产 `takeRemote/keepLocal/identical` 三态；符合派工 §五「不改 S1b 的 ConflictArbiter」。

**② 清单必须分片，不能一次性交换**

按 `(scope_uid, entity_type)` 分片。三个理由：

- 单片可断点续传，网络中断不必从头重来；
- `entityType` 是**自由字符串**（不是枚举，实测 `core/lib/model/types.dart:253`），
  双方支持的集合可能因版本而不同，分片天然容忍差集；
- 内存可控。

**分片批大小（定稿）**：契约层参数形态定死为 `manifestPageSize`（int，
发起方在 `ManifestChunk` 里携带本次分片的 `chunkSeq` 与 `totalChunks`）。
具体数值不写死在设计稿（需实测，与内存和断点粒度权衡），但须由配置项注入，不得硬编码在代码里。
断点续传：分片 id = `(scopeUid, entityType, chunkSeq)`，中断后发起方重发未确认的 chunk。

**③ 清单只覆盖记录，blob 是独立阶段**

`BlobHandle` 有独立的 `plaintextSha256` 与密文清单 id
（`core/lib/model/blob_types.dart:21-25`），媒体走 `reconcileRefs` 引用计数，
**不在 `t_entity_stamp` 里**。

后果：全量对齐完成后**记录齐了但图片可能还没下载**。
这必须在 UX 上明确表达，否则用户看到一堆碎图会以为同步失败。
blob 补齐是独立阶段，可延后、可按需、可仅在 WiFi 下进行。

**blob 未就绪的协议层信号（定稿）**：全量对齐完成（④ 游标确认）后，发起方须能区分「记录齐了但 blob 没齐」。
协议层信号 = `CursorAdvance` 携带 `recordsReconciled: int` 与 `blobsPending: int` 两个计数。
`blobsPending > 0` 即「记录齐了但图片没齐」，UX 层据此显示占位。该信号是协议层契约，UX 呈现方式归 UX 层（见 §5）。

### 3.3 性能：瓶颈不在网络

用户提出「WiFi 环境下数据量同步会很快」—— 传输层确实不是瓶颈，但要点破真正的瓶颈：

| 环节 | 5000 条记录的量级 | 是否瓶颈 |
|---|---|---|
| 清单交换 | 5000 × ~60 字节 ≈ 300 KB | 否 |
| 终态传输 | 取决于差异量 | 否（WiFi） |
| **逐条过仲裁器 + 写库** | **5000 次事务** | **是** |
| **blob 下载** | 可能数百 MB | 是（且不在本机制内） |

因此设计必须包含：

- **批量事务** —— 移动端 5000 条单条事务写入会卡 UI；
- **进度可中断可续传** —— 用户可能中途切走或断网；
- **不得假设"WiFi 快所以随便写"**。

---

## 4. 与其它子系统的边界

| 子系统 | 关系 |
|---|---|
| **S1a** | 提供分类契约与端口签名 |
| **S1b** | 提供 `t_entity_stamp`、`ConflictArbiter`、per-peer 游标、per-peer ack。**S1c 不改 S1b 的表结构** |
| **S6** | 提供设备配对与身份验证 —— 全量对齐要知道「对端是谁、可信吗」，否则等于向任意 peer 摊开全部清单 |
| **S3** | **S3 实现 compaction 前 S1c 必须已交付**（见 §1.1①）。S3a 的导出文件本身是一个离线 peer，天然适合作为全量对齐的首个验证载体 |
| **S2** | 无关（云端公开分享不走 P2P 对齐） |

### 4.1 S1b 内的防御性约束（已落地）

S1b 的 `act/03.yaml` 已加入禁令：`t_outbox_peer_ack` 提供的是压缩的**判据**，
不是压缩的**许可**；S1b 内不得实现 compaction。

---

## 5. 待决事项

| 事项 | 处置结论（定稿） |
|---|---|
| oplog 保留窗口天数 | **180 天**（配置项注入，须 > 对齐阈值 90 天，留一倍安全余量）。做成可配置项，不硬编码 |
| 墓碑物理表示 | **单戳模型 + `is_deleted` 列**（见 §3.2①）。`t_entity_stamp` 加 `is_deleted` bool 列，删除时 `hlcPacked`/`deviceId` 更新为删除事件戳，一行一套戳。不采独立墓碑表（多一张表多一次 JOIN，且与戳分离后裁决要双值比较，自相矛盾） |
| 清单分片批大小 | 契约层参数 `manifestPageSize`（int，配置项注入）定死；具体数值**后实测**（与内存/断点粒度权衡），不在设计稿写死数字。断点续传分片 id = `(scopeUid, entityType, chunkSeq)`（见 §3.1/§3.2②） |
| 全量对齐 UX | **归 UX 层**，本任务不定 UI 细节；但协议层信号已定（§3.2③）：`CursorAdvance` 携带 `recordsReconciled`/`blobsPending` 计数，`blobsPending>0` 即「记录齐了 blob 没齐」。UX 层据此显占位 |
| 用户手动移除设备 | **归 S6**（设备管理 UI），本任务不定。oplog 保留窗口机制已使失联设备不再卡 compaction（§2.6），无需「遗忘设备」动作 |
| 冲突留档量级 | **须在 ACT 阶段评估**：半年差异一次性对齐可能产生大量冲突留档。**ACT-D 硬性条目（评审 R1 P2-2 补）**：须含一个「冲突留档计数」观测点（可观测、可计数）+ 折叠呈现的评估；A9 变异自检须覆盖「冲突留档被正确产出」场景。不在设计稿定折叠策略（属 UX），但定「必须可观测、可计数」 |

---

## 6. 决策记录

| 决策 | 结论 | 被否决的替代方案与理由 |
|---|---|---|
| 对齐单位 | **实体终态** | 重放 oplog —— 要求 oplog 永不压缩，与 compaction 目标自相矛盾；且一条实体改 200 次要传 200 次 |
| 游标形态 | **保持 S1b 的 per-peer 水位 + 全量对齐兜底** | 版本向量 `{设备: seq}` —— 交换量更小，但同样依赖 oplog 完整，遇 compaction 即静默丢数据 |
| 全局单调整数游标 | **否决** | client-server 模型的产物。P2P 下三台设备各有各的 id 序列互不可比；两设备且固定一台为主时**测起来是对的**，三设备交叉同步才暴露串数据 |
| 变更捕获方式 | **沿用 S1b 的显式 enqueue** | SQLite 触发器 —— 写不出 HLC 戳（需 Dart 层时钟状态）；要给几十张表逐个绑定，**漏绑不报错且不可 grep**，把可测的漏记换成不可测的漏绑 |
| 触发判定归属 | **本地阈值 + 对端否决权** | 仅本地阈值 —— 对端可能重装过，oplog 比本地以为的短 |
| 遗忘设备策略 | **否决，改用 oplog 保留窗口** | 「N 天未 ack 则移除设备」-- 在猜测设备行为；设备可离线三年后回归 |
| 否决消息载体 | **`SyncPeer.listChanges` 返回收窄为 `RemoteChangesResult`，新增 `IncrementalUnavailable`** | 抛异常 -- 异常代表失败，不代表「请改走全量」；静默空页 -- 空页被当作「无变更」，游标照常推进，正是 §1.1① 静默丢数据。⚠ 属 S1a 契约签名变更，须人类批准后才可实现（见 §2.5） |
| 墓碑物理表示 | **单戳模型 + `is_deleted` 列** | 独立墓碑表 -- 多一张表多一次 JOIN，且戳与墓碑分离后裁决要双值比较（墓碑戳 vs 实体戳），自相矛盾。单戳模型一行一套戳，裁决是纯 `VersionStamp.compareTo` 全序比较，仲裁器零改动 |
| 墓碑裁决语义 | **不新增仲裁第四态，`is_deleted` 是 applier 数据位** | 新增「deleteRemote」第四态 -- 要改 S1b 的 `ConflictArbiter`，违反派工 §五。删/不删是数据内容不是仲裁决策，三态足够 |
| 清单是否含墓碑 | **含全部未压缩戳行，含 `is_deleted=true` 墓碑行** | 只列活实体 -- 删除传不过去（手机删 10 条电脑永远不知道），正是 §3.2① 要防的复活缺陷的另一面 |
| 比对四类 vs 五类 | **五类（双遍历）** | 四类（只遍历自己清单）-- 漏「本地无/对方有->索求」，新设备入网永远拉不到数据（评审 R1 P1-1） |
| 否决载体扩散面 | **listChanges 收窄波及 4 实现方 + 1 调用方，须同步适配** | 只改接口一处 -- firebase 两个网关（S2）漏改会编译失败或静默不实现（评审 R1 P1-2） |
| 修订稿落盘位置 | **在 worktree 分支 `agent/pi/storage-s1c-full-reconciliation`（commit 771d8d4+），非 main** | 评审 R1 P1-3 指「设计稿文件未落盘」是因评审时看的是 main 旧版；修订稿实际已提交在 worktree 分支。G3 通过后由人类决定合并/引用方式 |
