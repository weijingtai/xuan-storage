# Storage 分层隔离存储架构 · 设计总纲

- 日期：2026-07-31
- 状态：已通过讨论评审，待拆分为各子系统详细设计
- 范围：xuan-storage 全仓库（core / drift / firebase / supabase / preferences / assets）；并划定与 `xuan_config` 包的控制平面边界
- 前置文档：
  - [2026-05-27 xuan-common 存储迁移设计](../../../../docs/superpowers/specs/2026-05-27-xuan-common-storage-migration-design.md)
  - `xuan_config/docs/deferred-source-requirements.md`（远端配置源的既有约束）

---

## 0. 本文档的定位

本文档是**总纲**，不是可直接实施的详细设计。它确定的是：

1. 数据如何分类（四个正交维度），以及分类如何强制约束存储与传输行为；
2. 端口分层与可替换边界（换本地库、换云厂商、加通道各自要动哪里）；
3. 同步模型的形态；
4. 控制平面（`xuan_config`）与数据平面（`xuan-storage`）的分工；
5. 各子系统的划分、依赖与建议排期。

每个子系统（S1–S6，其中 S3 分 a/b/c、S5 分 a/b/c）需各自产出独立的详细设计与实施计划。本文档定的是它们共同遵守的地基。

---

## 1. 背景：现状盘点

### 1.1 已有资产

| 子包 | 已有能力 | 在本设计中的角色 |
|---|---|---|
| `core` | 端口契约（`OutboxStore` / `SyncStateStore` / `RemoteGateway` / `LocalApplier` / `AuthScopeProvider` / `ISharedPathProvider`）；`SyncCoordinator`(471行)；`SyncRuntime`(769行)；`Region` 双线路由 | 本地优先同步引擎，**保留并泛化** |
| `drift` | 本地 SQLite；各业务模块 record repository；`scopeUid` 隔离 | LocalDataSource 的 row 面实现 |
| `firebase` | `FirestoreRemoteGateway`；Rules / Indexes / Functions / Storage；部署脚本；`playground/` 社交模块 repository | RemoteDataSource 实现之一 |
| `supabase` | 占位包（大陆区 slot） | RemoteDataSource 实现之二 |
| `preferences` | SharedPreferences；账号会话 + 模块偏好，已按 scopeUid 隔离 | 配置类数据的本地面 |
| `assets` | 只读官方静态资源（编译进 bundle） | 样式与数据资源的 `bundled` 形态，S5a / S5b 将改造 |

关键既有事实：业务 Repository 依赖的是 `ScopedRecordStore` 端口（定义在 `repository-interface-record`），**不直接依赖 Drift**。例如 `drift/lib/xiang/xiang_reading_repository_impl.dart` 全文没有一行 Drift 代码。因此「换掉 Drift」的成本是换一个 `ScopedRecordStore` 实现，20+ 个业务 Repository 不受影响。

### 1.2 能力缺口

需求要求的能力，只有一项现成：

| 能力 | 状态 |
|---|---|
| 私有数据「本地 + 云端同步」 | ✅ 现有 outbox / cursor 引擎覆盖 |
| 数据分类的强制隔离 | ❌ 无 classification 概念，所有实体走同一条 `RemoteGateway` |
| 去中心化传输 | ❌ `core/lib/ipc/` 下仅有匿名身份，零传输能力 |
| 公开分享读路径 | ❌ 现有 Firestore 全按 `scopeUid` 隔离，无「其他用户可读」模型 |
| 样式资源分发（官方主题） | ❌ 现为内置 bundle，无下载安装机制 |
| 数据资源按需下载（拆书内容） | ❌ 现为内置 CSV，全量编译进包 |
| 官方控制下发（开关 / 服务器地址） | ❌ 完全不存在；`xuan_config` 已预留槽位但未实现（见 §8） |
| UGC 资源上架 | ⏸ **当前阶段不做**（见 §9.1） |

此外，需求文档未点名但工作量可能最大的一块：**blob 层完全空白**。现有 `SyncCoordinator` + `SyncRuntime` 只解决了 row 的同步。

---

## 2. 数据分类模型

### 2.1 四个正交维度

需求文档给出的四类只是**可见性**一个维度。讨论中陆续浮现出另外三个：

```dart
enum Visibility { private, shared, resource, control }
enum Publisher  { official, user }
enum Carrier    { row, blob }
enum Source     { bundled, officialRemote, marketplace }
```

**`official` 不是可见性，是发布者身份。** 官方主题（中国红、天青色）与用户自制主题的可见性完全相同 —— 都是公开只读的资源，都只走云端。区别只在于谁发布，而发布者决定的是信任级别与是否需要审核，不是存储策略。

**`Carrier` 的依据**：`repository-interface-media` 已定义 `MediaReference{refId, version, role, mimeType, durationMs}` —— 记录里存的是引用，真正的字节在别处。row 与 blob 的同步机制没有共用面：row 靠 operation log + LWW 仲裁 + 游标增量；blob 靠内容寻址、分块、断点续传、引用计数 GC。二者必须是两套端口，不可塞进同一个 `RemoteGateway`。

**`Source` 会随时间演进**，而 Repository 必须对来源无感 —— 同一个 `ThemeRepository.get(id)`，今天从 bundled assets 读、明天从官方远端下载、后天从 Marketplace 取，业务层一行不改。

### 2.1.1 全量对照表

| 东西 | Visibility | Publisher | Carrier | Source（当前 → 未来） |
|---|---|---|---|---|
| 占卦记录 | private | user | row | 本地 |
| 相的图片 / 视频 | private | user | blob | 本地 |
| 帖子草稿 | shared | user | row + blob | 云端 |
| 已发布帖子 | shared | user | row + blob | 云端 |
| 用户自制主题 | resource | user | row + blob | *（当前阶段不开放，见 §9.1）* |
| **官方主题**（中国红 / 天青色） | resource | **official** | row + blob | `bundled` → `marketplace` |
| **数据资源**（拆书：格局原文与讲解） | resource | **official** | **row** | `bundled` → `marketplace` |
| **控制下发**（功能开关 / 服务器地址 / 默认主题 id） | **control** | **official** | row | **只能 `officialRemote`** |

### 2.1.2 三类官方资源的差异

原总纲把它们笼统归为「官方 Assets」是错的 —— 三者在体量、检索需求、更新要求、失败后果上完全不同：

| | 样式资源 | 数据资源 | 控制下发 |
|---|---|---|---|
| **本质** | 可选项集合，用户选一 | 只读知识库 | **控制平面，不是数据** |
| **体量** | 每个数 MB（图 / 字体） | 大，需分批 | KB 级 |
| **落地载体** | blob 为主 + row 元数据 | **row 为主**（要能查） | row，极小 |
| **检索需求** | 无，按 id 取 | **有**，按格局查讲解 | 无，按 key 取 |
| **获取时机** | 用户选了才下 | 用到哪本下哪本 | 启动时拉 |
| **更新要求** | 随版本，低频 | 增补，低频 | **必须能快速生效** |
| **拿不到时** | 回退默认主题 | 该功能不可用 | **用内置默认值，不得阻塞启动** |
| **未来来源** | Marketplace | Marketplace | **永不 Marketplace** |

一条容易漏掉的关键点：**数据资源虽然从远端下载，但落地后是 row 不是 blob**。拆书内容要支持「按格局查讲解」，因此下载后必须进本地可查询存储（drift），不能当成一个文件扔进文件系统。这与主题包（下载后就是一坨字节）完全不同。

现状印证：`assets/lib/tiebanshenshu/assets_tiao_wen_repository.dart` 现在从打包的 CSV 读条文，靠静态缓存 + `Completer` 控并发 —— 这就是数据资源的 `bundled` 形态。

### 2.2 派生规则

以下属性由 `visibility` 推导，**不可手写覆盖**：

| Visibility | 加密 | 允许通道 | 允许 Source | 允许 Publisher |
|---|---|---|---|---|
| `private` | 客户端 E2EE + 桶级 SSE | cloud / lan / webrtc / manualExport | — | user |
| `shared` | 仅 SSE | 仅 cloud | — | user |
| `resource` | 仅 SSE | 仅 cloud | bundled / officialRemote / marketplace | official（当前）/ user（后续开放） |
| `control` | 仅 SSE + 传输层 TLS | 仅 cloud | **仅 officialRemote** | **仅 official** |

**「真相源在哪」不由 `visibility` 决定**，而由「本人能不能改这份数据」决定 —— 见 §4.1。二者正交：本人的帖子草稿属于 `shared`（因此仅云端通道），但它可写，因此真相源在本地。

**加密形态即可见性的技术强制。** 私有数据 E2EE 后，云端只是一条看不懂内容的哑管道 —— 这正是「私密数据可以存在云端」在隐私上成立的前提。分享数据必然不能 E2EE：别人要能读，服务端就得能读（审核、缩略图、检索）。

E2EE 与 SSE 是**纵深防御叠加**，不是二选一：私有数据在客户端加密后，存入本身已开启 SSE 的桶。SSE 是 Firebase / Supabase Storage 的桶级配置，默认开启、零成本；工程量全在 E2EE 层。

### 2.3 「防混用」的实现机制

Dart 没有编译期约束求解，因此不依赖检查或断言，而是**让非法状态无法表达** —— 靠限制构造器：

```dart
sealed class StoragePolicy {
  const StoragePolicy._();

  Set<Channel> get channels;
  Encryption get encryption;
  Set<Carrier> get carriers;

  /// 私有：E2EE + SSE，四条通道可选（默认全开）。
  const factory StoragePolicy.private({
    required Set<Carrier> carriers,
    Set<Channel> channels,
  }) = PrivatePolicy;

  /// 可分享：构造器不接受 channels 参数。
  const factory StoragePolicy.shared({
    required Set<Carrier> carriers,
  }) = SharedPolicy;

  /// 资源（样式 / 数据）：可跨 Source 演进，Publisher 当前限 official。
  const factory StoragePolicy.resource({
    required Set<Carrier> carriers,
    required Set<Source> sources,
    Publisher publisher,          // 默认 official；开放 UGC 时才传 user
  }) = ResourcePolicy;

  /// 控制下发：不接受 channels / sources / publisher 任何一个参数，全部写死。
  const factory StoragePolicy.control() = ControlPolicy;
}

final class ControlPolicy extends StoragePolicy {
  const ControlPolicy() : super._();

  @override
  Set<Carrier> get carriers => const {Carrier.row};

  @override
  Set<Channel> get channels => const {Channel.cloud};

  @override
  Set<Source> get sources => const {Source.officialRemote};

  @override
  Publisher get publisher => Publisher.official;

  @override
  Encryption get encryption => Encryption.sseOnly;
}

final class SharedPolicy extends StoragePolicy {
  const SharedPolicy({required this.carriers}) : super._();

  @override
  final Set<Carrier> carriers;

  @override
  Set<Channel> get channels => const {Channel.cloud};

  @override
  Encryption get encryption => Encryption.sseOnly;
}
```

两行写不出来的代码：

- 「给分享数据配置 P2P 通道」—— `StoragePolicy.shared` 没有 `channels` 参数
- 「让用户发布功能开关 / 服务器地址」—— `StoragePolicy.control` 没有 `publisher` 参数

不是被检查拦住，是语法上不存在。

兜底：一组遍历全局策略注册表的契约测试，断言不变式（例如「任何 `shared` 策略的 channels 必须恰为 `{cloud}`」「任何 `private` 策略的 encryption 必须含 E2EE」「任何 `control` 策略的 publisher 必须为 official 且 sources 必须恰为 `{officialRemote}`」）。

### 2.4 使用形态

```dart
const xiangReadingPolicy = StoragePolicy.private(
  carriers: {Carrier.row, Carrier.blob},
);   // 通道与加密无需书写，由 private 推导

const playgroundPostPolicy = StoragePolicy.shared(
  carriers: {Carrier.row, Carrier.blob},
);

const officialThemePolicy = StoragePolicy.resource(
  carriers: {Carrier.row, Carrier.blob},
  sources: {Source.bundled, Source.marketplace},
);

const tiaoWenPolicy = StoragePolicy.resource(
  carriers: {Carrier.row},               // 数据资源落地为 row，可检索
  sources: {Source.bundled, Source.marketplace},
);

const remoteControlPolicy = StoragePolicy.control();   // 无参数可传
```

某模块从私有改为可分享，改动量是一行策略声明；Repository 代码不动。资源从 `bundled` 演进到 `marketplace`，改动是 `sources` 集合加一个值。

---

## 3. 端口分层与可替换性

### 3.1 三组端口

```
LocalDataSource
  ├─ ScopedRecordStore   （已有，repository-interface-record）  row 面
  └─ LocalBlobStore      （新增）                                blob 面
       实现：drift / 文件系统 → 未来任意本地库

RemoteDataSource
  ├─ SyncPeer            （由现有 RemoteGateway 泛化）           row 面
  └─ BlobGateway         （新增）                                blob 面
       实现：firebase / supabase / 国产 SaaS / 自建 REST / 自建 gRPC

Transport
  └─ 实现：LAN / WebRTC / manualExport
```

装配在 DI 层完成，业务 Repository 只认端口，不认实现。

**`ConfigSource` 不在此列** —— 它属于 `xuan_config` 包的控制平面端口，不是 xuan-storage 的数据平面端口。xuan-storage 从 `xuan_config` 消费下发的指针（endpoint、`defaultThemeId`、功能开关），据此驱动上述三组端口。边界详见 §8。

### 3.2 `LocalBlobStore` 端口草案

```dart
/// 本地二进制对象数据源（LocalDataSource 的 blob 面）。
///
/// 与 [ScopedRecordStore] 并列：前者管结构化记录，后者管字节。
/// 实现可以是 文件系统 / drift BLOB / 未来任意存储，业务侧只认此端口。
abstract interface class LocalBlobStore {
  String get scopeUid;

  /// 写入字节，返回内容寻址句柄（sha256）。
  /// 幂等：同内容重复写入返回同一 handle。
  Future<BlobHandle> put(Stream<List<int>> bytes, {required String mimeType});

  /// 按句柄读取。本地缺失返回 null（不抛异常，由调用方决定是否触发获取）。
  Future<Stream<List<int>>?> openRead(BlobHandle handle);

  /// 本地是否已就绪（供 UI 显示「未下载」态）。
  Future<bool> isPresent(BlobHandle handle);

  /// 引用计数 +1 / -1。计数归零由 GC 回收，业务侧不直接删字节。
  Future<void> retain(BlobHandle handle, {required String ownerRecordUuid});
  Future<void> release(BlobHandle handle, {required String ownerRecordUuid});
}
```

### 3.3 可替换点矩阵

| 换什么 | 动哪里 | 不动哪里 |
|---|---|---|
| Drift → 其他本地库 | `ScopedRecordStore` / `LocalBlobStore` 的实现 | 20+ 业务 Repository、同步引擎 |
| Firebase → Supabase / 国产 SaaS | `SyncPeer` / `BlobGateway` / `*RemoteDataSource` 实现 + `Region` 加枚举值 | `RemoteGatewayRouter`、组合者、业务层 |
| 加自建 REST / gRPC 后端 | 同上，多一个实现类 | 同上 |
| 加一条去中心化通道 | `Transport` 加一个实现 | `StoragePolicy` 声明、Repository |
| 某模块改变可见性 | 一行 `StoragePolicy` 声明 | Repository 代码 |

---

## 4. Repository 双模式（按数据类分派）

### 4.1 判据

**这份数据我能不能改？** 能改 → 本地是真相源，走旁路同步；只能读 → 远端是真相源，走组合缓存。

| 数据类 | 真相源 | 模式 |
|---|---|---|
| private（占卦记录、相的图片视频） | 本地 | 旁路同步 |
| shared · 本人草稿（未发布） | 本地 | 旁路同步（peer 集合仅含云端） |
| shared · 本人已发布原件 | 本地 | 旁路同步（peer 集合仅含云端） |
| shared · 他人内容（帖子流） | 远端 | 组合缓存 |
| resource（下载他人主题） | 远端 | 组合缓存 |
| official（Assets） | 远端 / 内置 | 组合缓存 |

注意：**Repository 模式**（由「能不能改」决定）与 **允许通道**（由 `visibility` 决定）是两个正交维度。草稿是可写的，因此走旁路同步模式；但它属于 `shared` 类，因此它的 peer 集合只有云端 peer，没有设备 peer。

### 4.2 模式一 · 旁路同步

Repository 只依赖本地端口，**远端不出现在它的构造器里**：

```dart
final class XiangReadingRepositoryImpl implements XiangReadingRepository {
  XiangReadingRepositoryImpl({
    required ScopedRecordStore store,   // LocalDataSource · row
    required LocalBlobStore blobs,      // LocalDataSource · blob
    required RecordModuleCodec<XiangReading> codec,
  });
  // 无 RemoteDataSource。save() 写完本地即返回，离线可用。
}
```

远端由同步引擎旁路消费 outbox，Repository 不感知。

代价（已知并接受）：「这条记录同步到别的设备了吗」这类状态，Repository 答不出来，UI 需另行询问同步引擎。

### 4.3 模式二 · 组合缓存

现有 `FirebasePlaygroundFeedRepository` 只改一行 —— `implements PlaygroundFeedRepository` 改为 `implements PlaygroundFeedRemoteDataSource`，内部 Firestore 查询逻辑不动。

```dart
abstract interface class PlaygroundFeedRemoteDataSource {
  Future<PlaygroundPage<PlaygroundPost>> fetchFeed(GetFeedQuery query);
}

abstract interface class PlaygroundFeedLocalDataSource {
  Future<PlaygroundPage<PlaygroundPost>?> readCached(GetFeedQuery query);
  Future<void> writeCache(GetFeedQuery q, PlaygroundPage<PlaygroundPost> page);
}

/// 组合者：唯一实现，与后端无关。
final class CachedPlaygroundFeedRepository implements PlaygroundFeedRepository {
  CachedPlaygroundFeedRepository({
    required PlaygroundFeedRemoteDataSource remote,
    required PlaygroundFeedLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final PlaygroundFeedRemoteDataSource _remote;
  final PlaygroundFeedLocalDataSource _local;

  @override
  Future<PlaygroundPage<PlaygroundPost>> getFeed(GetFeedQuery query) async {
    try {
      final page = await _remote.fetchFeed(query);
      await _local.writeCache(query, page);
      return page;
    } on NetworkUnavailable {
      final cached = await _local.readCached(query);
      if (cached != null) return cached;
      rethrow;
    }
  }
}
```

换云厂商只换 `_remote` 的实现类，组合者与上层业务不动。

**缓存分级**（S2 详细设计中落实）：帖子正文与媒体缓存（值钱、变化慢）；点赞数 / 收藏态不缓存（变化快，缓存反而产生错误显示）。

---

## 5. 同步模型

### 5.1 触发方式：用户主动发起的配对会话

不做后台自动持续同步。依据：**用户在线即表示同步意愿** —— 用户之所以打开 app，正是因为他想同步。

此决定砍掉的设计负担：

- 加密中继信箱（云端暂存密文、取走即删）—— 不需要
- 静默推送唤醒对端（FCM / APNs）—— 不需要
- iOS 后台执行时长限制的规避 —— 绕开，前台传输不受限
- 「设备不在线时数据去哪」的整套设计 —— 问题消失

### 5.2 `RemoteGateway` 泛化为 `SyncPeer`

现有签名本身即是传输无关的：

```dart
Future<SyncError?> push(OutboxRecord record);
Future<RemoteChangesPage> listChanges({scopeUid, entityType, sinceCursor, limit});
```

「把我的操作日志推给对端 / 从对端游标拉取变更」—— 对端是 Firestore 还是同一局域网里的另一台平板，语义完全一致。

```dart
/// 同步对端。云端是一个 peer，本人的另一台设备也是一个 peer。
abstract interface class SyncPeer {
  Future<SyncError?> push(OutboxRecord record);
  Future<RemoteChangesPage> listChanges({
    required String scopeUid,
    required String entityType,
    required PullCursor? sinceCursor,
    required int limit,
  });
  Future<PeerCapabilities> getCapabilities();
}

final class FirestoreRemoteGateway implements SyncPeer { /* 既有实现不改 */ }
final class LanPeerGateway       implements SyncPeer { /* mDNS + socket */ }
final class WebRtcPeerGateway    implements SyncPeer { /* 信令 + DataChannel */ }
final class ExportBundleGateway  implements SyncPeer { /* 导出文件 = 离线 peer */ }
```

`SyncCoordinator`(471行) 与 `SyncRuntime`(769行) 不动，只是从「有一个 gateway」变为「有一组 peer」。现有 `RemoteGatewayRouter` 的分派逻辑扩为 fan-out 即可。

**手动导出导入不需要独立的合并逻辑** —— 导出文件是把 oplog 序列化成加密包，对端导入时当作一次 `listChanges` 消费，走同一套 LWW 仲裁。

### 5.3 会话式同步的两个必然附带（必须做）

**冲突可见化。** 后台自动同步时两台设备差异极小；会话式可能两周才同步一次，期间双方各改了一批。LWW 在这种场景下会**静默丢数据** —— 用户在平板上改的内容被手机上更晚的版本覆盖，且他不知情。要求：冲突时保留被覆盖的版本，并使其对用户可见可回溯。

**oplog compaction。** 长期不同步会导致本地 oplog 持续增长。需要压缩策略（例如「所有已知 peer 均已确认收到的操作可合并压缩」），否则首次同步一台久未使用的设备需重放数万条操作。

### 5.4 传输边界的双重保障

**第一道 · 拓扑不可达。** 去中心化通道的对端集合 = **本人已授信设备集合**。其他用户根本不在这张拓扑里。「禁止去中心化分享」不是策略禁止，是拓扑上无法到达。

**第二道 · 密码学。** E2EE 密钥只在本人设备。手动导出的文件即使被转发给他人，对方也无法解密。

两道锁方向不同：第一道防「自动分发到他人」，第二道防「人工转发」。

---

## 6. Blob 层

### 6.1 内容寻址 + 分块

`blob = 一组 chunk`，每个 chunk 独立 sha256。

这让三级降级的断点续传天然成立：局域网传了 60%，切换到云端接着传剩余 40% —— 因为每块可独立校验、独立获取，通道之间无状态耦合。

### 6.2 传输优先级：三级降级

**局域网直连 > WebRTC > 云端 E2EE**

| 级别 | 成本 | 适用 |
|---|---|---|
| 局域网直连 | 零 | 同网段，最快，大文件首选 |
| WebRTC | TURN 带宽费（仅 10–20% 连接会走中继） | 跨网段，两端同时在线 |
| 云端 E2EE | 存储费 + 双向带宽费 | 兜底，同时充当备份（设备全丢可恢复） |

**P2P 的价值定位是省钱与速度，不是隐私** —— 隐私已由 E2EE 在加密层解决完毕，云端反正看不懂内容。局域网直传 500MB 视频库零流量费、跑满网卡；走云端要付存储费加双向带宽费。

### 6.3 WebRTC 的成本与安全事实

- **NAT 穿透成功率不低**：STUN 直连约 80–90%（对称型 NAT 打不通），TURN 兜底后接近 99%。
- **信令零新增基础设施**：复用现有 Firestore，一个 collection 交换 SDP / ICE candidate。
- **STUN 免费**：公共服务即可。
- **TURN 用托管服务**（Cloudflare / Twilio / Xirsys）：DTLS 握手在两个 peer 之间完成，TURN 只转发已加密的 UDP 包，**连密钥交换都参与不了**。因此托管 TURN 在隐私上不是降级，与自建 coturn 安全性相同。唯一成本是带宽账单。

两条诚实的限制：

1. **TURN 可见元数据** —— IP 地址、包大小、传输时序。看不到内容，但知道「这两个 IP 在某时刻传了 200MB」。
2. **信令通道完整性是前提** —— 被攻破的信令通道理论上可替换 DTLS 指纹实施中间人。防护手段是设备配对时的**带外验证**：两台设备各自显示公钥指纹，用户肉眼比对或扫二维码。此项归入 S6，本就必须做。

**WebRTC 只为 blob 而建。** row（oplog，KB 级）数据量小到不值得为它做 P2P，走云端更省事更可靠。

### 6.4 生命周期

引用计数 GC。业务侧调用 `retain` / `release`，不直接删除字节。计数归零后由 GC 回收。

选择理由：同一张图可能被多条记录引用，「blob 生命周期跟随 record」会导致误删。代价是 retain / release 必须配对，写错会造成泄漏或早删 —— 需配套契约测试。

---

## 7. 发布与分享

### 7.1 发布是单向快照

```
草稿实体（shared，仅云端通道，跨设备续写靠云端同步）
   │
   │  发布 = 单向快照：脱敏 → 生成独立明文实体
   ▼
帖子实体（shared，仅云端，独立 id，云端为真相源）

本地 published_from 映射表（仅本人可见，绝不上云）
```

草稿虽未公开，但它属于 `shared` 类，因此**不走去中心化传输**（需求硬性约束：可分享数据不支持去中心化信息传输）。跨设备续写草稿依托云端同步实现。

草稿与已发布帖子同为 `shared` 类，仅 SSE 加密，不做 E2EE —— 因此「解密」一步不存在，发布只需脱敏与快照。

### 7.2 关键约束

**`published_from` 不上云。** 若云端帖子文档携带私有记录 id，他人虽读不到内容，却能看出「这些帖子出自同一批私有档案」—— 关联关系本身即隐私泄露。因此它是本地 drift 的一张映射表，不是帖子实体上的字段。

**已发布内容不可密码学回收。** 别人已经看到了。UI 上的「删除」只能是撤下展示，不能承诺回收。

### 7.3 帖子全生命周期均不走去中心化同步

| 阶段 | 分类 | 真相源 | 去中心化同步 |
|---|---|---|---|
| 草稿（未发布） | shared | 本地 | ❌ **禁止**。需求硬性约束。跨设备续写走云端同步 |
| 已发布 · 本人的 | shared | **云端** | ❌ 禁止，且无收益。云端已有权威副本，任何设备直接拉取即可；走 P2P 更慢且产生「两个权威副本谁新」的仲裁问题 |
| 已发布 · 他人的 | shared | 云端 | ❌ 禁止。缓存而已，丢失重新拉取 |

两层理由叠加：

1. **约束层** —— 需求规定可分享数据不支持去中心化信息传输。草稿虽未公开，但它是可分享数据的未发布态，归属同一类别，不开例外口子。
2. **技术层** —— 发布这个动作的本质是把真相源从本地交给云端。交出后再去 P2P 同步它，等于同一份数据存在两个权威来源。

「Drift 存储的数据都应该可以被去中心化同步」这条原则因此需要精确表述为：**Drift 中属于 `private` 类的数据均可去中心化同步**。Drift 里的帖子相关数据（草稿、本地缓存、已发布原件镜像）全部属于 `shared` 类，一律不参与去中心化同步。

---

## 8. 控制平面：`xuan_config` 与 `xuan-storage` 的边界

### 8.1 核心分工：一个管指针，一个管字节

```
xuan_config（控制平面）              xuan-storage（数据平面）
──────────────────────              ──────────────────────
defaultThemeId: "cny-2027"    ──→   ThemeRepository.get("cny-2027")
featureFlags: {...}                   → 本地有？用本地
serverEndpoints: [...]                → 没有？按 endpoint 下载
marketplaceUrl: "..."                 → 落 blob + 元数据 row
```

**`xuan_config` 下发的永远是「指针和开关」，不是内容本身。** 内容的获取、缓存、校验、GC 全部归 `xuan-storage`。

驱动需求：**不重新打包上架，就能改变客户端行为。**

- 场景 A（春节主题）：Console 改 `defaultThemeId` → 客户端拉到新值 → `ThemeRepository` 按 id 取包（本地有就用，没有就下载）→ 应用主题。
- 场景 B（服务器一个变多个）：Console 增加几个 endpoint 字段，客户端下次拉配置即生效。

这条边界的额外收益：**Marketplace 上线时 `xuan_config` 一行不改** —— 它下发的仍是同一个 `themeId`，只是 `xuan-storage` 的来源链里多了一个 marketplace 源。

### 8.2 `xuan_config` 现状：槽位已预留

包已存在并有骨架：

```dart
// xuan_config/lib/src/config_source.dart
abstract class ConfigSource {
  Future<String?> loadRaw(String path);
  String get sourceId;
}
```

已有实现：`memory` / `file` / `asset`。`xuan_config/docs/deferred-source-requirements.md` 中已明确列出 `Firebase Hosting | Static YAML/JSON documents hosted on Firebase Hosting | Deferred`，并预先写好了本设计需要的四条约束：source 优先级排序、offline-first 本地缓存 + 后台同步、离线降级、schema 版本与回滚。

**因此这不是新建，是填上已预留的 Deferred 槽位。**

⚠️ 该文档中的硬规则必须遵守：

> No future source category may be introduced into the current theme-token phases (1-6) without a separate OpenSpec change and independent review.

引入 Firebase Hosting source 需单独走一次 OpenSpec change，不得并入本次存储改造。

### 8.3 分层：哪些必须 Hosting，哪些可以 Firestore

二者能力不同，且有一条不能选错：

| | Firebase Hosting | Firestore |
|---|---|---|
| 改法 | 改 JSON/YAML 文件 → deploy | Console 直接改字段 |
| 生效 | CDN 缓存 TTL 后（可设短） | 立即 |
| 计费 | 无读取计费 | 按读次数 |
| 灰度分组 | ❌ 全量统一 | ✅ 可按用户分组查询 |
| **需要 SDK 初始化** | ❌ **纯 HTTP GET** | ✅ 需要 |

最后一行是关键。**服务器地址属于引导配置** —— 它决定客户端连哪个后端，而 Firestore 本身就是后端之一。要从 Firestore 读服务器地址，必须先初始化 Firebase SDK，而初始化需要知道连哪个项目：鸡生蛋。纯 HTTP GET 一个静态文件是唯一能在任何 SDK 初始化之前完成的动作。

| 层 | 内容 | 载体 | 理由 |
|---|---|---|---|
| **L0 引导** | 服务器地址列表、Firebase 项目配置、各资源源 endpoint | **必须 Hosting** | 要在 SDK 初始化前拿到 |
| **L1 运行时** | 功能开关、`defaultThemeId`、Marketplace 开关 | Hosting 或 Firestore | 稍慢生效可接受 |
| **L2 灰度** | 按用户分组下发 | 只能 Firestore | 可选，后期 |

场景 B（服务器一个变多个）落在 L0；场景 A（春节主题）落在 L1。

### 8.4 来源链优先级：顺序不能反

```
已成功拉取并缓存的 remote  >  bundled asset  >  代码内置默认值
```

是**「已缓存的 remote」优先，不是「remote 优先」**。启动时直接用上次缓存的配置（零延迟、离线可用），后台再刷新，下次启动生效。

若写成「remote 优先」，每次冷启动都要等一个网络请求，弱网下 app 卡在启动画面 —— 而配置拉取失败是常态而非异常。这正是 deferred 文档中 "Offline-first with local cache, background sync" 的含义。

### 8.5 安全：内置域名白名单

服务器地址由远程下发，最坏情况是**攻击者把所有用户导向他的服务器** —— 之后所有云端同步、分享、资源下载全部经过他。这不是普通的配置读取错误，是整个系统的信任根被替换。

三条硬要求：

1. **内置引导地址** —— app 包内硬编码官方地址，作为拉配置的起点
2. **内置域名白名单** —— 下发的任何 endpoint 必须匹配包内硬编码的域名后缀列表，不匹配则丢弃并沿用上次配置
3. **失败不阻塞启动** —— 拿不到配置时用内置默认值，app 照常可用

白名单是对个人维护者的务实取舍：即使 Firebase 账号被攻破、配置被篡改，攻击者也只能在**自有域名范围内**改地址，无法导向外部。叠加 Hosting 自带的 HTTPS/TLS，已堵住最严重的洞。完整签名体系（内置公钥 + 配置签名验证）留待后期，不在当前范围。

### 8.6 与现有 `SyncConfiguration` 的区分

`core/lib/configuration/sync_configuration_manager.dart`(653行) 中的 `SyncConfiguration` 是**同步引擎的本地配置**（YAML / 文件存储），不是远程下发系统。两者不可混用，本节所述是新建能力。

---

## 9. 子系统拆分与建议排期

```
S1 分类与端口契约层  ←── 地基，全员依赖
   │        │
   │        ├──> S5c 官方控制下发（xuan_config）  ←── 其余子系统靠它找后端，建议提前
   │        │
   │        └──> S6 E2EE 密钥管理 + 设备配对      ←── 第二块地基
   │                  │
   ├──> S2  云端公开分享                          ← 不依赖 S6
   ├──> S3  去中心化传输（a/b/c 三个实现）        ← 依赖 S6
   ├──> S5a 样式资源分发（含官方主题）            ← 不依赖 S6
   ├──> S5b 数据资源按需下载                      ← 不依赖 S6
   └──> S4  用户资源上架（UGC）                   ← 当前阶段不做
```

| 编号 | 子系统 | 依赖 | 规模与备注 |
|---|---|---|---|
| **S1** | 分类与端口契约层 | — | **薄契约，零实现**：四个 enum、`StoragePolicy` sealed 类族、`LocalBlobStore` / `SyncPeer` / `BlobGateway` / `Transport` 端口签名、契约测试。一周内可落地 |
| **S5c** | 官方控制下发 | S1 | 对接 `xuan_config` 的 Firebase Hosting source；引导地址 + 域名白名单 + 安全默认值。**需单独走 OpenSpec change**（见 §8.2）。**建议提前** —— S2/S3/S5a/S5b 都要靠它找后端，它晚到就得先硬编码地址、之后返工 |
| **S6** | E2EE 密钥管理 + 设备配对 | S1 | 第二块地基，含带外指纹验证。私有数据的任何跨设备能力都卡在这 |
| **S3a** | 手动导出导入 | S1 + S6 | 零基础设施，可最先交付 |
| **S3b** | 局域网直连 | S1 + S6 | mDNS + socket，Dart 生态成熟 |
| **S3c** | WebRTC | S1 + S6 | **只为 blob 而建**；信令复用 Firestore，TURN 用托管服务 |
| **S2** | 云端公开分享 | S1 | 复用现有 `firebase/lib/playground/`，主要工作是降级为 RemoteDataSource + 加缓存层 |
| **S5a** | 样式资源分发 | S1 + S5c | 主题包下载安装；来源链 `bundled → marketplace`。官方与用户主题**同构**，同一套仓库 |
| **S5b** | 数据资源按需下载 | S1 + S5c | 拆书内容按需取；**下载后落 drift 可检索**。可显著降低 app 体积 |
| **S4** | 用户资源上架（UGC） | S1 + S5a | **当前阶段不做**。见下方范围说明 |

### 9.1 当前阶段范围收窄：Marketplace 仅官方可上架

需求原文第 3 条为「风格化资源文件：支持用户发布、互相分享、下载」。**当前大阶段收窄为：只允许官方通过市场发布分发，不允许用户上架。**

架构影响（全是简化）：

- `resource` 类的 `Publisher` 当前恒为 `official`
- **审核机制、UGC 举报、内容安全全部不在当前范围** —— S4 的主要成本正在这里
- S5a 的主题仓库与安装逻辑照常建设，因为它与将来的用户主题**同构**

但端口必须预留 `Publisher.user`：`StoragePolicy.resource` 保留 `publisher` 参数（默认 `official`），将来开放 UGC 时改的是策略声明与审核流程，不改契约。

### 9.2 落地路线：薄契约 + 垂直切片验证

S1 只交付最小可执行契约（零实现）+ 一组证明违规组合无法通过的契约测试，随即用一个垂直切片把契约压在真实场景上验证。

理由：本仓库已经证明端口抽象这条路走得通 —— `core/lib/model/ports.dart` 那套 `OutboxStore` / `RemoteGateway` 端口撑起了 drift + firebase 双实现。同样手法复制到 blob 与 transport 上，风险低且与现有代码风格一致。

替代方案「契约先行（S1 + S6 全部做完再挂子系统）」被否决：S6 独自即可吃掉数周，会把所有产出堵在后面。
替代方案「纯垂直切片（契约事后补）」被否决：本仓库有 20+ 个业务模块消费存储层，契约晚到一天就多一天的错误调用要清理。

### 9.3 第一个垂直切片

**「相」的私有图片 → 局域网直连同步。**

一次打通 S1 契约 + S6 配对 + S3b 通道 + blob 分块，且零云端成本即可验证全链路。

---

## 10. 待决事项

以下不阻塞本总纲，各归子系统详细设计解决：

| 事项 | 归属 |
|---|---|
| E2EE 密钥派生形态（助记词 / 账号密码派生 / 设备互签）、密钥丢失的处置 | S6 |
| 冲突仲裁的具体 UX（如何呈现被覆盖版本） | S1 定接口，UI 层实现 |
| 组合模式的缓存分级与失效策略 | S2 |
| oplog compaction 的具体算法与触发时机 | S1 定接口，S3 实现 |
| 配置 schema 的版本、迁移与回滚策略 | S5c（`xuan_config` deferred 文档已列为约束） |
| 域名白名单的具体形式（后缀列表 / 完整域名 / 是否含端口） | S5c |
| 数据资源下载后的 drift 表结构与检索索引设计 | S5b |
| 主题包的格式、版本兼容与安装/卸载语义 | S5a |
| UGC 开放后的审核机制、举报、是否收费 | S4（当前阶段不做） |

---

## 11. 决策记录（含被否决方案）

| 决策 | 结论 | 被否决的替代方案与理由 |
|---|---|---|
| 分类维度 | 四个正交维度 `Visibility × Publisher × Carrier × Source` | 一维四类 —— 无法表达 blob 与 row 的机制差异，也无法表达来源演进 |
| `official` 的位置 | **降为 `Publisher`，不是 `Visibility`** | 保留为 Visibility —— 官方主题与用户主题可见性完全相同，区别只在发布者，硬分两类会导致 S4/S5 写两套同构逻辑 |
| `control` 的引入 | 新增第四个 `Visibility` | 归入 `official` Assets —— 控制下发是控制平面不是数据平面，体量、生效速度、失败后果、安全要求全都不同 |
| 控制平面与数据平面 | `xuan_config` 管指针与开关，`xuan-storage` 管字节 | 由 xuan-storage 直接读远程配置 —— 会让 Marketplace 上线时两边都要改 |
| 引导配置载体 | **必须 Firebase Hosting（纯 HTTP GET）** | Firestore —— 需先初始化 SDK，而 SDK 要知道连哪个后端，鸡生蛋 |
| 配置来源链顺序 | 已缓存 remote > bundled > 内置默认 | remote 优先 —— 每次冷启动等网络请求，弱网卡启动画面 |
| 控制下发的安全 | 内置引导地址 + 内置域名白名单 + 安全默认值 | 完整签名体系 —— 对个人维护者成本过高，白名单已堵住「导向外部服务器」这个要害；签名留待后期 |
| 数据资源的落地形态 | 远端下载，但**落地为 row 进 drift** | 当 blob 存文件系统 —— 拆书内容要「按格局查讲解」，必须可检索 |
| Marketplace 上架权限 | **当前阶段仅官方**，端口预留 `Publisher.user` | 立即开放 UGC —— 审核、举报、内容安全是 S4 主要成本，当前阶段不承担 |
| 防混用机制 | sealed class + 限制构造器 | 运行时断言 / lint 规则 —— 拦不住已写出的错误调用 |
| Repository 模式 | 按数据类分派（旁路 + 组合） | 全部统一为组合模式 —— 离线冲突逻辑要在 20+ 模块重复实现，且作废现有同步引擎 |
| 同步触发 | 用户主动发起的配对会话 | 后台自动同步 —— 需要静默推送唤醒，iOS 限制大，且引入中继信箱 |
| 跨网段不同时在线 | 不解（由「在线即有同步意愿」承接） | L3 加密中继信箱 —— 引入云端持久组件，与会话式模型下的收益不匹配 |
| 私有数据加密 | E2EE + SSE 纵深叠加 | 仅 SSE —— 云端技术上可读，「敏感数据」承诺只能做到合规级别 |
| TURN | 托管服务 | 自建 coturn —— DTLS 使二者安全性等同，托管无运维负担 |
| blob 传输 | 三级降级（LAN > WebRTC > 云端） | 全部上云 —— 存储与带宽成本高；纯 P2P 不上云 —— 设备全丢无法恢复 |
| blob 生命周期 | 内容寻址 + 引用计数 GC | 跟随 record 生命周期 —— 同图被多记录引用时会误删 |
| 发布语义 | 单向快照 + 本地反向溯源 | 原地提升可见性 —— 需就地改变加密体制，且无法回收 |
| 帖子的去中心化同步 | **全生命周期均不做，草稿也不做** | 「草稿归 private 因而可去中心化」—— 讨论中曾提出，被否决：草稿是可分享数据的未发布态，开例外口子会削弱「shared 一律不去中心化」这条约束的完整性 |

---

## 附录 · 术语表

| 术语 | 含义 |
|---|---|
| **row** | 结构化记录，走 operation log + LWW 仲裁 + 游标增量同步 |
| **blob** | 二进制对象，走内容寻址、分块、断点续传、引用计数 GC |
| **E2EE** | 端到端加密，密钥仅在本人设备，服务端无法解密 |
| **SSE** | 服务端加密，云厂商持有密钥，桶级配置 |
| **oplog** | 操作日志，同步的传输单元 |
| **LWW** | Last-Write-Wins，最后写入者赢的冲突仲裁策略 |
| **peer** | 同步对端。云端是一个 peer，本人另一台设备也是一个 peer |
| **scopeUid** | 多账号隔离的最小单位，通常等同于当前登录用户 uid |
| **STUN / TURN** | NAT 穿透探测服务 / 中继转发服务 |
| **带外验证** | 通过传输通道之外的途径（肉眼比对指纹、扫二维码）确认对端身份 |
| **控制平面 / 数据平面** | 前者下发指针与开关（`xuan_config`），后者搬运实际字节（`xuan-storage`） |
| **引导配置** | 决定客户端连哪个后端的最小配置，必须在任何 SDK 初始化之前拿到 |
| **来源链** | 同一份资源按优先级从多个 `Source` 依次回退获取的顺序 |
