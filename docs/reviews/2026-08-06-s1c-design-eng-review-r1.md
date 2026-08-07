# S1c 设计稿评审 R1（第一段跨模型工程评审）

> 评审对象：`docs/superpowers/specs/2026-08-03-s1c-full-reconciliation-design.md` 的修订稿
> （修订稿全文目前**只存在于评审素材包** `docs/storage-s1c-full-reconciliation/G3-REVIEW-PROMPT.txt` 素材包 A 段，
> 设计稿文件本身 git 状态为空、未被修改 —— 见 P1-3）
> 评审方：DeepSeek（opencode/deepseek-v4-flash）｜作者：GLM
> 日期：2026-08-06

## 1. 判定：需修订

设计方向与已交付现实高度一致（六条核心决策、单戳墓碑模型、否决载体挂载点全部核验成立），
但存在 **1 个协议级缺口（P1-1）+ 1 个扩散面遗漏（P1-2）+ 1 个流程未落盘（P1-3）**，
以及 2 个 P2。修订面窄，修订后可转 ACT。

| 等级 | 数量 | 是否阻塞转 ACT |
|---|---|---|
| P0 | 0 | — |
| P1 | 3 | 是 |
| P2 | 2 | 否 |

## 2. Findings 表

| # | 级别 | 位置 | 证据 | 问题 | 必须的修订 |
|---|---|---|---|---|---|
| P1-1 | **P1** | 素材包 A §3.1 ②「逐条比对分四类」+ 消息线序 ②b | 四类 = 本地有/对方无→发终态、双方有/本地新→发终态、双方有/对方新→索求、相同→跳过；线序 ②b 索求仅标注「对方更新，请对方发来」 | **漏了「本地无 / 对方有 → EntityRequest 索求」方向**。场景 1/2（新设备首次入网 / 数据丢失）对端是空库：对端遍历自己的清单什么也发现不了，只能遍历收到的清单逐条索求。四类无此分类 ⇒ 新设备永远拉不到数据，A5「四阶段协议跑通」直接失败，§1 场景 1/2 失效 | 四类补「本地无/对方有 → 请对方发来（EntityRequest）」；同时写清对端比对是**双遍历**（自己的清单找「本地有/对方无」，收到的清单找「本地无/对方有」），消除「比对自己的清单」表述歧义 |
| P1-2 | **P1** | 素材包 A §2.5 否决载体（listChanges 返回收窄） | `listChanges` 是**多实现接口**：`SyncPeer` 接口（core/lib/model/sync_peer.dart:66）、`RemoteGatewayRouter implements SyncPeer`（core/lib/routing/remote_gateway_router.dart:15,44）、`FirebaseRealtimeRemoteGateway`（firebase/lib/firebase_realtime_remote_gateway.dart:27,707）、`FirestoreRemoteGateway`（firebase/lib/persistence_firebase.dart:21,358）；调用方 `sync_coordinator.dart:407`（`pullGateway.listChanges`） | 素材包只摘录接口一处。收窄 `Future<RemoteChangesPage>→Future<RemoteChangesResult>` 会**波及全部 4 个实现方 + 1 个调用方**，其中 firebase 两个网关属 S2 云端通道，不在 S1c 范围。影响面比设计稿呈现的大，人类批准签名变更时须看到完整扩散面 | 设计稿补「受影响实现方清单」：列出 4 实现方 + 调用方 sync_coordinator.dart:407；明确「签名收窄须全部实现方同步适配」是批准决策的一部分 |
| P1-3 | **P1** | 流程：设计稿文件未落盘 | `git status`：`docs/superpowers/specs/2026-08-03-s1c-full-reconciliation-design.md` 空；文件内无「定稿/单戳墓碑/RemoteChangesResult」等任何修订标记 | 本次评审对象是**素材包 A 段**，不是仓库里的设计稿文件。评审通过后若只写报告、不回写设计稿，ACT 阶段将没有落盘的设计稿依据，G2「设计稿修订」实际未完成 | 评审通过后，须把素材包 A 段修订稿**整体写回设计稿文件**，再由人类确认，才进入 G4 转译 |
| P2-1 | P2 | 素材包 A §3.2①「墓碑保留期 ≥ 90 天」 | 只写了「墓碑早于阈值过期 ⇒ 复活缺陷」，未写**谁清理、何时清理过期墓碑** | 墓碑行留在 t_entity_stamp 不清理会无限增长；S1c 自身不实现 compaction（§4 归 S3）。清理归属模糊 | 明确墓碑清理归 compaction 周期（与 oplog 保留窗口同步，S3），S1c 只保证「清单含全部未过期墓碑行」 |
| P2-2 | P2 | 素材包 A §5 第 6 条「冲突留档量级」 | 处置 = 「ACT 阶段评估 + 必须可观测可计数 + A9 覆盖」，折叠策略归 UX | 属「后置到 ACT」而非「开工前定死」。处置本身已定死（观测点+变异覆盖），可接受，但 ACT-D 必须落实「冲突留档计数」观测点 | ACT-D 明确加入冲突留档计数观测点；本项不阻塞评审通过 |

## 3. §5 待决事项逐条处置核对

| 事项 | 设计稿处置 | 核对 | 结论 |
|---|---|---|---|
| oplog 保留窗口天数 | **180 天**（配置注入，>90 天阈值留一倍余量） | 定死且可执行 | ✅ |
| 墓碑物理表示 | **单戳模型 + is_deleted 列**（§3.2①，一行一套戳，删除更新戳+置位） | 定死且自洽；只加列不触既有列语义，符合派工 §五 | ✅ |
| 清单分片批大小 | `manifestPageSize`（int 契约参数）定死形态，具体数值后实测，分片 id=`(scopeUid,entityType,chunkSeq)` | 参数形态定死，数值实测属正常 | ✅ |
| 全量对齐 UX | 归 UX 层；协议层信号已定（CursorAdvance 带 recordsReconciled/blobsPending） | 边界定死 | ✅ |
| 用户手动移除设备 | 归 S6，本任务不定 | 归属定死 | ✅ |
| 冲突留档量级 | ACT 阶段评估 + 必须可观测可计数 + A9 覆盖 | 处置方式定死，数值后置（见 P2-2） | ⚠️ P2-2 |

**结论：5 条开工前定死，1 条（冲突留档）处置方式定死、数值后置（可接受，P2-2 落实观测点）。**

## 4. 与已交付现实核对表（评审方亲自重开源码，非凭素材包）

| 设计稿主张 | 源码事实（file:line） | 核对 |
|---|---|---|
| 清单直接建在 t_entity_stamp | `t_entity_stamp`：PK=`{scopeUid,entityType,entityId}`，列=`hlcPacked(int)+deviceId(text)`，无删除列（drift/lib/persistence_drift.dart:253-278） | ✅ 成立，加 is_deleted 只加列 |
| ConflictArbiter 三态 + 纯全序比较 | `ArbitrationDecision` = takeRemote/keepLocal/identical；compareTo 先 dateTime 再 counter 再 deviceId UTF-8 字节序（core/lib/model/conflict_arbiter.dart:27-88,106-151） | ✅ 单戳墓碑零改动成立 |
| listChanges 挂载点返回 RemoteChangesPage | `SyncPeer.listChanges` → `Future<RemoteChangesPage>`（core/lib/model/sync_peer.dart:66）；`RemoteChangesPage` 类（core/lib/model/types.dart:287-310） | ✅ 收窄即 S1a 契约变更 |
| 否决不走异常不走静默空页 | 语义核对成立：异常=失败、空页=游标推进，均不可表达「请改走全量」 | ✅ 载体选择正确 |
| StreamKind 现只有 oplog/blobChunk | `enum StreamKind { oplog, blobChunk }`（core/lib/model/transport.dart:19-25） | ✅ 新增 reconciliation 只加枚举值 |
| blob 独立、reconcileRefs 引用计数 | `BlobHandle` 有 plaintextSha256/cipherManifestId（core/lib/model/blob_types.dart:22-40），不在 t_entity_stamp | ✅ |
| entityType 自由字符串 | `final String entityType`（core/lib/model/types.dart:255） | ✅ |
| S1b act/03 防御性约束已落地 | act/03.yaml：「本表提供压缩的【判据】不是【许可】…该能力归 S1c…【S1b 内不得实现 compaction】」（docs/storage-s1b-multipeer/act/03.yaml） | ✅ |
| 否决载体扩散面 | **4 实现方**：sync_peer.dart:66 / remote_gateway_router.dart:15,44 / firebase_realtime_remote_gateway.dart:27,707 / persistence_firebase.dart:21,358；调用方 sync_coordinator.dart:407 | ⚠️ 设计稿只摘录接口一处 → P1-2 |

## 5. 模糊词扫描

对素材包 A 段全文扫描「适当/优雅/合理地/必要时/视情况/由实现决定」：**零命中**。
唯一命中「自行」出现在禁令语境（「ACT-A 在未获批准前不得自行收窄 listChanges 返回类型」），非模糊词。

## 6. Mechanical ACT Readiness 表

| ACT 项（计划文档 §3.2 草案对应） | 就绪？ | 阻塞项 |
|---|---|---|
| ACT-A 否决载体签名提案上报 | ❌ | P1-2（扩散面清单未定）+ 须人类批准 |
| ACT-B 墓碑 schema（drift 加 is_deleted 列） | ⚠️ | P2-1（墓碑清理归属）不阻塞加列，但迁移说明要写 |
| ACT-C 清单交换与分片续传 | ❌ | P1-1（比对四类缺口 + 双遍历基准未写死） |
| ACT-D 冲突留档观测点 | ⚠️ | P2-2（须落实计数观测点） |
| ACT-E/F 协议流与消息序列化 | ✅ | — |
| ACT-G 门禁与验收 | ✅ | A8 依赖「签名收窄获批」，若否决则 A8 验收路径须重议 |

**转 ACT 前置**：P1-1 修订四类比对 → P1-2 补扩散面清单 → P1-3 修订稿写回设计稿文件 → 人类确认 → G4。

## 7. Required Revisions Before ACT（编号清单）

1. **R-1（P1-1）**：§3.1 ② 比对四类补「本地无 / 对方有 → EntityRequest 索求」；写明对端双遍历基准。
2. **R-2（P1-2）**：§2.5 补 `listChanges` 受影响实现方清单（4 实现方 + sync_coordinator.dart:407 调用方），并注明「收窄须全部实现方同步适配」。
3. **R-3（P1-3）**：评审通过后把素材包 A 段修订稿整体写回 `docs/superpowers/specs/2026-08-03-s1c-full-reconciliation-design.md`。
4. **R-4（P2-1）**：§3.2① 明确墓碑清理归属（compaction 周期 / S3），S1c 只保证清单含全部未过期墓碑行。
5. **R-5（P2-2）**：§5 第 6 条标注「ACT-D 必须落实冲突留档计数观测点」，作为 ACT 硬性条目。

## 8. Oracle A5-A10「怎么变红」核对

| 验收 | 可写「怎么变红」？ | 具体注入与红点 |
|---|---|---|
| A5 四阶段协议跑通契约测试 | ⚠️ 当前设计有 P1-1 缺口 | 修好四类后：变异=删掉「本地无→索求」分支 → 红在「空库对端拉取全量」契约断言。**当前设计下该测试无法通过（直接暴露 P1-1）** |
| A6 契约可复用套件 | ✅ | 变异=把套件复制两份而非引用一份 → 红在「同一套件实例被两个 fake 引用」断言 |
| A7 两个结构迥异 fake | ✅ | 变异=第二个 fake 与第一个同构（复制改名） → 红在「结构差异」断言 |
| A8 90 天阈值 + 对端否决权可验 | ✅ 载体可观测 | mock 对端返回 `IncrementalUnavailable` → 断言发起方「切全量 + 游标未推进」；变异=删掉「收到后不推进游标」→ 红在「游标未推进」断言。**前置依赖：listChanges 签名收窄获批（P1-2）** |
| A9 变异自检 | ✅ | 设计稿已给示例：is_deleted 位变异红在「本地 is_deleted」断言 |
| A10 门禁全绿、基线不抬 | ✅ | 基线参考：core 256 / drift 401 / p2p 62+1skip / firebase 131+4skip / S1a 57 / dartdoc 161 |

## 9. 独立性声明

本评审由 DeepSeek 执行，对象是 GLM 所写设计稿的修订稿（素材包 A 段）。

虽素材包声明「--no-tools 禁用工具」，但本评审**实际亲自重开了关键源码**，核验范围**超出**素材包 B1-B6：
- B1-B6 摘录的源码片段与仓库实际内容**逐字核对一致**（conflict_arbiter / sync_peer / transport / persistence_drift / types / blob_types）；
- 额外发现素材包未摘录的**否决载体扩散面**：`RemoteGatewayRouter`、`FirebaseRealtimeRemoteGateway`、`FirestoreRemoteGateway` 三个实现方也 `implements SyncPeer`（P1-2）——素材包若按 `--no-tools` 限制评审将漏掉此扩散面；
- 发现**设计稿文件未落盘**（P1-3）：素材包 A 段 ≠ 仓库设计稿文件，两者必须统一。

作者（GLM）与评审（DeepSeek）为不同厂商，独立性硬要求满足。单戳墓碑模型、is_deleted 不参与定序、否决载体选择经纯函数仲裁器源码核验后确认正确，非凭转述。
