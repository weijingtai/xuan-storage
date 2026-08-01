# 任务: storage-s1a-contracts
负责: mimo ｜ 分支: agent/mimo/storage-s1a-contracts ｜ 开工: 2026-08-01
状态: 蓝图

## 目标
在 `persistence_core` 包内交付存储分层架构的分类契约与全部端口签名（零实现），并用契约测试证明策略的结构性不变式不可被违反。

## 规格来源
`docs/superpowers/specs/2026-07-31-storage-architecture-design.md`（1659 行，已过 /autoplan 三阶段评审 + Codex 跨模型验证）。
**§ 号在下方每个子任务里给出，执行时按 § 号定位原文，不要凭记忆写。**

## 计划

- [ ] T1 建立文件骨架：在 `core/lib/model/` 下新建 `storage_classification.dart` / `storage_policy.dart` / `storage_policy_registry.dart` / `blob_types.dart` / `blob_cipher.dart` / `blob_gateway.dart` / `transport.dart` / `export_bundle.dart` / `record_blob_unit_of_work.dart`，并加入 `core/lib/persistence_core.dart` 的 export 列表。（§0.1：真实包名是 `persistence_core`，不是目录名 `core`）
- [ ] T2 六个 enum（§2.1）：`DataVisibility` / `Publisher` / `Carrier` / `Source` / `Channel` / `Encryption`。**注意叫 `DataVisibility` 不叫 `Visibility`** —— `persistence_core` 依赖 flutter，裸名会与 Flutter 的 `Visibility` widget 冲突。
- [ ] T3 `StoragePolicy` sealed 类族（§2.3）：基类 6 个事实 getter + 4 个命名工厂；`PrivatePolicy` / `SharedPolicy` / `ResourcePolicy` / `ControlPolicy` 四个子类，**构造器一律私有（`._`）**。`private` 工厂不接受 `cloud`，只接受 `lan` / `webrtc` / `manualExport` 三个 bool。
- [ ] T4 `StoragePolicyRegistry`（§2.3.1）：`register` / `lookup` / `all`。`register` 必须校验不变式 4 与 5 并抛 `StateError`；`lookup` 未注册返回 null（调用方 fail closed）。
- [ ] T5 blob 值类型（§3.2）：`BlobHandle`（含 `plaintextSha256` / `cipherManifestId` / `cipherId` / `keyVersion` / `totalBytes` / `chunkCount` / `mimeType`）、`BlobStatus` 五态、`BlobReadResult` sealed 五分支、`BlobTier` 两态、`BlobEntry`、`BlobVisibility`。
- [ ] T6 `LocalBlobStore` 端口（§3.2）：`putFile` / `put` / `putChunk` / `readCipherChunk` / `openRead` / `statusOf` / `presentChunks` / `sizeOf` / `list` / `reconcileRefs` / `evictByExternalId` / `evictCache`。**`evictCache` 返回 record 类型 `({int freed, int unreclaimable})`。**
- [ ] T7 `BlobCipher` + `BlobCipherResolver`（§3.2.4）：`encryptChunk` / `decryptChunk` / `id` / `currentKeyVersion` / `resolve`。**调用方不传密钥**，密钥由 resolver 内部持有。
- [ ] T8 `RecordBlobUnitOfWork`（§3.2.3）：`saveWithBlobs` / `deleteWithBlobs`。这是「记录写入与引用对账同事务」的唯一契约表达。
- [ ] T9 `BlobGateway`（§3.4）：`beginUpload` / `putChunk` / `completeUpload` / `remoteChunks` / `getDownloadTicket` / `deleteObject` / `getCapabilities`，外加 `BlobUploadTicket` / `BlobDownloadTicket` / `BlobGatewayCapabilities` 三个值类型。
- [ ] T10 `Transport` + `PeerSession`（§3.5）：`Transport.discover` / `connect` / `dispose`；`PeerSession.openStream` / `state` / `close`；配套 `StreamKind` / `DiscoveredPeer` / `PeerIdentity` / `PeerSessionState` / `PeerStream` / `DeviceKeyPair`。**不要建 `ExportFileTransport`** —— 见踩坑墓地。
- [ ] T11 `ExportBundleWriter` / `ExportBundleReader`（§3.5）：`write` / `inspect` / `readChanges`。`readChanges` 返回 `Stream<RemoteChangesPage>`，复用 `core/lib/model/types.dart` 里已有的 `RemoteChangesPage`，不要重新定义。
- [ ] T12 端口通用约定（§3.6）：定义 `CancellationToken`；所有可能超过 1 秒的方法接受 `CancellationToken?`；错误一律用 `core/lib/model/storage_error.dart` 的 `StorageError` 体系，**不要新建 `NetworkUnavailable`**（§4.3 示例里那个名字是错的）。每个新端口的 dartdoc 写明 isolate 要求与超时要求。
- [ ] T13 契约测试 `core/test/model/storage_policy_test.dart`：遍历 `StoragePolicyRegistry.all` 断言 §2.3.2 的 5 条不变式。
- [ ] T14 契约测试 `core/test/model/blob_types_test.dart`：`BlobHandle` 双 hash 语义；`BlobReadResult` 五分支穷尽（用 switch 表达式，缺分支应编译失败）。
- [ ] T15 契约测试 `core/test/model/policy_channel_filter_test.dart`：两个 fake `SyncPeer`（channel 分别 cloud / lan），断言按 policy 过滤后 lan peer 收到的记录中**无** `shared` 类 entityType。**这是「防混用」的真正验收项。**
- [ ] T16 **analyzer 负测试**（§2.3.2）：见下方专项说明。这一项转译难度最高，单独做，做完自查一遍方向有没有反。

### T16 专项说明（读三遍再动手）

这一项**不是**「写测试让它变绿」，而是**证明某些代码写不出来**。方向反了就是没做对。

建独立 fixture 工程 `core/test/model/storage_policy_analyzer_test/`：

1. 自己的 `pubspec.yaml`（name 如 `policy_negative_fixture`），通过 `path: ../../../..` 依赖 `persistence_core`
2. `lib/violations.dart`，写**故意违规**的代码：
   ```dart
   // 期望编译失败：shared 没有 channels 参数
   const a = StoragePolicy.shared(carriers: {Carrier.row}, channels: {Channel.lan});
   // 期望编译失败：control 没有 publisher 参数
   const b = StoragePolicy.control(publisher: Publisher.user);
   // 期望编译失败：private 没有 cloud 参数
   const c = StoragePolicy.private(carriers: {Carrier.row}, cloud: false);
   // 期望编译失败：子类构造器私有，跨库不可见
   const d = PrivatePolicy(carriers: {Carrier.row});
   ```
3. 脚本 `run_negative_check.sh`：在 fixture 目录跑 `dart analyze`，**期望退出码非 0**；若退出码为 0，脚本自身以非 0 退出并打印「负测试失败：违规代码竟然编译通过」

判定：`dart analyze` 在 fixture 里**必须报错**，脚本才算通过。

## 验收标准

- [ ] A1 `cd core && dart analyze --fatal-infos` 零 issue
- [ ] A2 `cd core && flutter test` 全绿，且 T13/T14/T15 三个测试文件存在且被执行
- [ ] A3 T16 的负测试脚本执行后退出码为 0（即 fixture 内 `dart analyze` 确实报错了）
- [ ] A4 `grep -rn "class .*Impl\|UnimplementedError" core/lib/model/` 无输出 —— **S1a 是零实现，出现任何具体实现类即不合格**
- [ ] A5 `grep -rn "enum Visibility " core/lib/` 无输出 —— 必须叫 `DataVisibility`
- [ ] A6 `grep -rn "ExportFileTransport\|class NetworkUnavailable" core/lib/` 无输出 —— 这两个名字已被明确否决
- [ ] A7 `StoragePolicy.private` 参数表不含 `cloud` / `channels`；`StoragePolicy.shared` 不含 `channels`；`StoragePolicy.control` 无任何参数
- [ ] A8 四个 `*Policy` 子类构造器均为私有（`._`）
- [ ] A9 新增端口全部出现在 `core/lib/persistence_core.dart` 的 export 列表
- [ ] A10 每个新端口的 dartdoc 中文注释齐全（仓库惯例，见既有 `ports.dart`）

验收命令: `cd core && dart analyze --fatal-infos && flutter test && bash test/model/storage_policy_analyzer_test/run_negative_check.sh`

## 当前状态
蓝图已就绪，未开工。

## 决定记录
- 2026-08-01: S1 拆为 S1a(契约) + S1b(引擎多 peer 化)。理由: 核实发现 `t_outbox` 主键 `{operationId}`、`t_sync_state` 主键 `{scopeUid,entityType}`、`markSuccess` 签名均无 peerId，多 peer 需两次 schema 迁移，不属契约层。原文档「SyncCoordinator/SyncRuntime 零改动」经核实为假。
- 2026-08-01: `private` 策略的 `cloud` 从参数表移除，改为结构上不可关闭。理由: 上一版用 `Set<Channel>` 自由传入，`StoragePolicy.private(channels: {Channel.lan})` 可构造，直接违反「private 必含 cloud」不变式。Codex 跨模型评审发现。
- 2026-08-01: 四个 Policy 子类构造器改私有。理由: public 构造器可绕过命名工厂的参数表约束。
- 2026-08-01: 不变式分「结构性」与「注册期」两级，不再统一宣称编译期。理由: 实测 Dart const 构造器无法用 assert 判定集合成员。
- 2026-08-01: 加密由独立 `BlobCipher` 端口承担，`LocalBlobStore` 存密文且不是密码学组件。理由: 若在 put 之外加密，本地磁盘裸存私人照片，与「客户端 E2EE」的声称矛盾。
- 2026-08-01: 新增 `readCipherChunk`。理由: 原设计只有写密文 chunk 与读明文，本地密文取不出来上传，而 `BlobGateway.putChunk` 要密文，上传链是断的。Codex 发现。
- 2026-08-01: 新增 `RecordBlobUnitOfWork` 聚合端口。理由: 原文只写「reconcileRefs 必须与记录写入同事务」，但两个端口都无事务令牌，调用方实现不了。
- 2026-08-01: `enum Visibility` 改名 `DataVisibility`。理由: `persistence_core` 依赖 flutter，与 `Visibility` widget 冲突。

## 踩坑墓地
- 2026-08-01: 尝试用 const 构造器的 `assert(channels.contains(Channel.cloud))` 把不变式做成编译错误，失败。原因: `Set.contains` 是方法调用，const 表达式禁止，报 `const_eval_method_invocation`。结论: 别再试 assert 路线，用「把参数从参数表移除」的结构化手法。
- 2026-08-01: Codex 评审主张「重定向工厂的可选非空参数必须在工厂声明自身写默认值，写在目标构造器上编译不过」。实测证伪: `dart analyze` 零 issue，Dart 允许默认值写在目标构造器。结论: 该主张不成立，别按它改。
- 2026-08-01: 曾把 `ExportFileTransport` 设计为 `Transport` 的实现。否决。原因: 文件不是持续连接，没有握手/心跳/双向并发流/实时多路复用，而这四样正是 `PeerSession` 的契约，硬套会得到一堆 `UnsupportedError`。结论: 导出导入走独立的 `ExportBundleWriter/Reader`，只复用 `RemoteChangesPage` 数据形状，不复用连接抽象。
- 2026-08-01: 曾声称「禁止去中心化分享是拓扑上无法到达」。否决。原因: `peekBatch({scopeUid, limit})` 无 policy 过滤，shared 草稿照样会被 fan-out 到本人 LAN peer。结论: 必须有主动的 channel 过滤（S1b 交付），拓扑不构成保护。
- 2026-08-01: 曾把 `Transport` 与 `SyncPeer` / `BlobGateway` 并列画成「三组端口」。否决。原因: LAN peer 的 oplog 流与 blob chunk 流共用同一条物理连接，并列画法导致连接建立/握手/心跳/重连/流控无归属。结论: `Transport` 在下层，由 `PeerSession` 持有并多路复用。

## 冷冻快照
<搁置时由 /hibernate 填写>
