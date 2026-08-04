# S1d · blob 落地层设计（`LocalBlobStore` + `BlobGateway` 实现）

> 状态：**Q1–Q7 已获人类确认（2026-08-03）**，可以开始实现。
> 四项拍板结论见 §0.1。
>
> 作者：S1d 承接方　日期：2026-08-03
> 基线：`main` @ `16987fe`（`schemaVersion => 6`）
> 工作树：`.worktrees/mimo-storage-s1d-blobstore`　分支：`agent/mimo/storage-s1d-blobstore`

---

## 0.1 ⚠ 人类裁定（2026-08-03，具约束力）

以下四条已由人类拍板，**实现必须遵守，不得自行更改**：

| # | 事项 | 裁定 | 对实现的影响 |
|---|---|---|---|
| **1** | schema 版本号 | **S1b 先合并，S1d 用 v8** | blob 迁移写 **v8**，`onUpgrade` 加 `if (from < 8)` 分支。**我需 rebase 到含 S1b 的 main 后再合并**。派工单 §1 的「先按 v7 写 + 标注待定」处置**作废**，直接写 v8 |
| **2** | Web 端 blob | **本期不交付** | `web.dart` / `unsupported.dart` 分支全部方法抛明确的「Web 本期不支持」错误。援引 S6 D18 先例 |
| **3** | P1 / P2 平台缺口 | **都不修，只在文档记录** | **不动 `xuan-shell` 仓库**。P1（Android `allowBackup`）与 P2（macOS Release entitlements）的风险记录于 §11，留待后续子系统处置。⚠ 这意味着本设计的落盘保护在 Android 上仍会被 Auto Backup 绕过 —— 是已知且已被接受的残余风险 |
| **4** | GC 对 sourceOfTruth 的收紧 | **采纳** | `tier == sourceOfTruth` 且 `refCount == 0` → 转 `orphaned` 标记，**不自动删字节**，等用户显式操作。见 §5 |

---

## 0. 一页纸摘要

| 问题 | 我的结论 | 状态 |
|---|---|---|
| Q1 | 字节存哪 | **混合**：字节走文件系统，元数据/引用计数走 drift | ✅ 通过 |
| Q2 | 目录布局 | `getApplicationSupportDirectory()/blobs/<scopeUid>/<tier>/<aa>/<manifestId>/<index>.bin` | ✅ 通过 |
| Q3 | chunk 大小 | **对齐 16KB**，与 S6 的 DataChannel 值一致 | ✅ 通过 |
| Q4 | staged 状态机 | staged →(reconcileRefs)→ committed；TTL 24h；GC 三条规则 | ✅ 通过 |
| Q5 | drift 表设计 | 3 张表：`t_blob_meta` / `t_blob_chunk` / `t_blob_ref` | ✅ 通过 |
| Q6 | Web 端 | **本期不交付 Web blob** | ✅ **已裁定** |
| Q7 | `dart:io` | 条件导入，照抄仓库既有三文件模式 | ✅ 通过 |
| 附 A | schema 版本号 | **v8**（S1b 先合并） | ✅ **已裁定** |
| 附 B | P1/P2 平台缺口 | **不修，只记录** | ✅ **已裁定** |
| 附 C | GC 收紧 | sourceOfTruth 归零不自动删 | ✅ **已裁定** |

---

## 1. 事实基线（全部为本轮实测，非转述）

开工前我逐条核实了派工单里的断言。**结论：全部属实，但有两条需要修正范围。**

| # | 派工单断言 | 实测结果 | 证据 |
|---|---|---|---|
| 1 | main 上 `schemaVersion => 6` | ✅ 属实 | `git show main:drift/lib/persistence_drift.dart` → `541: int get schemaVersion => 6;` |
| 2 | S1b 尚未合并进 main | ✅ 属实 | `git log --oneline main` 最新为 `16987fe`，S1b 的 ACT 01/02 提交 `6e78fd9`/`fcd5612` 只在 `agent/mimo/storage-s1b-multipeer` 分支上 |
| 3 | 6 个 blob 契约零实现 | ✅ 属实 | 6 文件共 709 行（含 `cancellation_token.dart` 则 7 文件），全部 `abstract interface class` 或值类型 |
| 4 | 契约已在 barrel 导出 | ✅ 属实（派工单未提，对我有利） | `core/lib/persistence_core.dart:29,32-36` 六行 export 齐备 |
| 5 | **P1** Android 缺 `allowBackup="false"` | ✅ 属实 | `xuan-shell/android/app/src/main/AndroidManifest.xml:2-5` 的 `<application>` 只有 label/name/icon；`grep -rn "allowBackup\|fullBackupContent" android/` → **0 命中** |
| 6 | **P2** macOS Release 缺网络权限 | ✅ 属实 | `Release.entitlements` 只有 `app-sandbox`；`DebugProfile.entitlements` 另有 `network.client` + `network.server` |
| 7 | **P3** `persistence_core` 2 处 `dart:io` | ✅ 属实 | `core/lib/configuration/yaml_file_loader.dart:1`、`sync_configuration_manager.dart:3`（`:245` 自注「仅适用于具备 IO 能力的平台（非 Web）」） |
| 8 | Web 是活的交付目标 | ✅ 属实 | `xuan-shell/web/` 含 `sqlite3.wasm`(689.8K) + `drift_worker.js`(350.8K) |

### ⚠ 需要修正的两条范围

**修正 1：P1/P2 不在本仓库，S1d「在内」修不了。**

派工单 §6 写「**建议你在 S1d 内修掉它**（P1），因为落盘是你的领域」。
但实测 `xuan-shell` 是**独立 Git 仓库**（`git rev-parse --show-toplevel` →
`/Users/jingtaiwei/Git/Public/xuan-migration/xuan-shell`），
不是 `xuan-storage` 的子目录。**S1d 的 PR 无法包含它的改动。**

这不是推诿。P1 是真实且严重的缺口（私有 blob 会静默上传到用户 Google Drive，
与「私有数据只在本人设备」的整个前提冲突）。但它需要**第二个仓库的第二个 PR**。
处置建议见 §11。

**修正 2：Q3 的前提在 S6 文档里已经有更强的表述。**

派工单 Q3 问「本地 chunk 是否必须与 P2P 的 16KB 相同」。
S6 文档 `:1239` D11 已记「建议固定 16KB。可协商会引入跨端不一致的调试成本」，
且 `:371-373` 写死「chunk 大小取 **16KB**（DataChannel 安全值）。
**不要用 256KB** —— 上限受两端协商影响，跨浏览器不可靠」。
即：P2P 侧的 16KB 不是建议而是已决策项。详见 §4。

---

## 2. Q1 · 字节存哪：文件系统 + drift 混合

### 结论

**字节存文件系统，元数据与引用计数存 drift。**

### 论证

设计稿 §3.2 只说「实现可以是 文件系统 / drift BLOB」，把选择权留给了实现者。
四条理由指向文件系统：

**① SQLite 存大 BLOB 会让 db 文件不可逆膨胀。**
SQLite 删除行后页面进入 freelist，**文件大小不会自动缩小**；要真正回收必须
`VACUUM`，而 `VACUUM` 需要与原库等大的临时空间且全程持写锁。
一个存了 500MB 视频的库，删掉视频后 db 文件仍是 500MB+，
在移动端做 `VACUUM` 意味着瞬时占用 1GB 磁盘并冻结全部数据库写入。
**这与 §6.4 的 GC 语义直接冲突** —— GC 是常规操作，不能每次都触发 `VACUUM`。

**② 本项目的 blob 是流式消费的，drift BLOB 不是。**
`BlobReadResult.ok(Stream<List<int>> plaintext)` 要求产出**流**。
drift 的 BLOB 列读取会把整列物化为 `Uint8List` 进内存——
2GB 视频需要 2GB 连续堆内存，移动端直接 OOM。
这与 S6 文档 `:248-250` 拒绝「整文件 `send()`」的理由是同一条。

**③ chunk 级并发写在文件系统上是天然的，在单表行上是争用的。**
契约 `local_blob_store.dart:76` 要求「同一 `BlobHandle` 的并发 `putChunk`
必须安全（按 index 分片写）」。一 chunk 一文件时，不同 index 写不同 inode，
零锁争用；存 drift 则是同表并发写，SQLite 的库级写锁会把并发退化为串行。

**④ 已有实测结论：pub.dev 无现成内容寻址 blob store 包。**
体检报告 BL-4 记「调研已确认 pub.dev **无内容寻址 blob store 现成包**
（13 个关键词检索，S6 文档 `:1196`），**必须自建于 drift + 文件系统**」。
即「drift + 文件系统」这个组合本身已是上游调研的结论，我的论证与之一致。

### 为什么元数据仍走 drift（而不是也放文件系统）

- 引用计数要与记录写入**同事务**提交（契约 `record_blob_unit_of_work.dart:21`
  「任一步失败则整体回滚」）。文件系统没有事务，drift 有 `db.transaction()`。
- `list({required BlobTier tier})` 要按 tier 过滤并按 `lastAccessAtUtc` 排序
  （LRU），这是索引查询，SQL 天然胜任；遍历目录做排序则是 O(n) 全扫。
- `presentChunks` 返回 `Set<int>` 且要高效算差集，SQL 的 `WHERE blob_id=? `
  + 索引扫描远优于 `readdir` 后解析文件名。

### 边界：字节与元数据可能不一致

文件系统写入与 drift 事务**不是同一个原子域**。可能出现：
文件已落盘但 drift 未记录（崩溃在两者之间），或反之。

**处置**：以 **drift 为准**（drift 是真相源，文件系统是内容存储）。
- drift 有记录、文件缺失 → `statusOf` 返回 `corrupt`，走重下路径。
- 文件存在、drift 无记录 → 属孤儿文件，由 GC 扫描回收（见 §5）。
- **写入顺序固定为「先落文件，后写 drift」**：这样崩溃窗口只产生孤儿文件
  （可回收），而不会产生「drift 声称有、实际没有」的幽灵记录。

---

## 3. Q2 · 目录布局与路径规则

### 结论

```
<app-support>/blobs/<scopeUid>/<tier>/<manifestId 前2位>/<manifestId>/<index>.bin
                                                                      /_meta.json（可选，仅诊断）
```

其中 `<app-support>` = `getApplicationSupportDirectory()`（`path_provider`）。

### 必须满足的三条硬约束（S6 文档 §4.3，`:647-658`）

| # | 约束原文 | 本设计如何满足 |
|---|---|---|
| 1 | 只落 **app-specific 目录**，禁 external storage / sdcard | 用 `getApplicationSupportDirectory()`。Android 落在 `/data/data/<pkg>/`，**不是** external storage（S6 文档 `:647` 原文点名此 API） |
| 2 | **禁写** `MediaStore` / `PHPhotoLibrary` | 本设计全程只用 `dart:io` 的 `File`/`Directory`，不引入任何相册 API。配静态门禁（见 §8 验收项 12） |
| 3 | Android `allowBackup="false"` | ⚠ **本设计满足不了** —— 在 `xuan-shell` 仓库。见 §11 |

### 各段的理由

- **`<scopeUid>`**：契约 `local_blob_store.dart:22` 有 `String get scopeUid`。
  按 scope 分目录使「注销账号 → 全删」（§7.4.5）退化为删一个目录，
  且天然防止多账号数据串区。
- **`<tier>`**：`sourceOfTruth` / `cache` 分两棵子树。
  这样 `evictCache` 的实现是「**只在 cache 子树下操作**」——
  把「绝不触碰 sourceOfTruth」从运行时判断降级为**路径层面的物理隔离**。
  这是本设计最重要的一条防御：派工单 §2.1 明示违反后果是「删用户照片」。
- **`<manifestId 前2位>`**：分片目录，避免单目录下数万子目录导致的
  文件系统性能塌陷（ext4/APFS 均如此）。
- **`<manifestId>` 而非 `plaintextSha256`**：⚠ **关键**。
  契约 `blob_types.dart:22` 写死 `plaintextSha256`「**永不作为远端对象名**」。
  本地路径虽不出设备，但用 `cipherManifestId` 作目录名有额外好处：
  私有 blob 的 manifestId 是随机 UUID，**即使设备被取证、目录名也不泄露内容哈希**，
  与 §7.4.3 的防「已知明文攻击」思路一致。代价为零（本地索引仍走 drift 的
  `plaintextSha256` 列做去重）。
- **`<index>.bin` 一 chunk 一文件**：支撑 Q1 论证③的并发写，
  且 `presentChunks` 在极端情况下（drift 损坏）可从文件系统重建。

---

## 4. Q3 · chunk 大小：对齐 16KB

### 结论

**本地存储 chunk 大小 = 16KB = 16384 字节，与 S6 的 P2P 侧完全一致。**
定义为单一常量 `kBlobChunkBytes`，两侧共享，不做可配置。

### 论证

**① 不对齐会让续传语义错位——这是决定性理由。**
契约 `blob_types.dart:190` 的 `BlobPartial(Set<int> presentChunks)` 是
**跨传输通道共享的续传状态**。设计稿 §6.2 的场景原文是
「局域网传了 60%，切云端接着传剩余 40%」。
若本地 chunk 是 1MB 而 P2P 是 16KB，那么「已收到 P2P chunk #0..#63」
无法直接翻译成「本地 chunk #0 完整」——**每次通道切换都要做一次分块重映射**，
而重映射在部分接收（收到 #0..#40，不足一个本地 chunk）时**无法表达**：
本地 chunk #0 既不是 present 也不是 absent。
`Set<int>` 这个类型本身就承载不了「部分持有一个 chunk」的语义。
**结论：不对齐会使已交付的契约类型不足以表达真实状态。**

**② S6 侧的 16KB 不是建议，是已决策项。**
S6 文档 `:371-373`：「chunk 大小取 **16KB**（DataChannel 安全值）。
**不要用 256KB** —— 上限受两端协商影响，跨浏览器不可靠。」
`:1239` D11：「建议固定 16KB。可协商会引入跨端不一致的调试成本，收益有限。」
即上游已经把这个数字钉死，S1d 若另选一个数字，等于单方面推翻 S6 的决策。

**③ 16KB 的代价可接受，且可被缓解。**
代价是元数据行数多：1GB 文件 = 65536 个 chunk 行 + 65536 个文件。
- drift 侧：`t_blob_chunk` 每行约 40 字节，65536 行 ≈ 2.6MB，可接受。
- 文件系统侧：65536 个 16KB 小文件在 APFS/ext4 上会有块对齐浪费
  （4KB 块 → 16KB 正好 4 块，**无浪费**；这正是 16KB 优于 5KB 之类怪数值的地方）。
- inode 消耗是真实代价。**缓解**：见下方「物理布局与逻辑分块解耦」。

### 物理布局与逻辑分块解耦（对 ① 的加固）

为兼顾 inode 消耗，实现上允许**物理上多个 chunk 合并存一个文件**，
但**逻辑 chunk 编号严格 16KB 对齐**。即：
- 逻辑层（契约面向的 `presentChunks`、`putChunk(index)`）：恒为 16KB 粒度。
- 物理层（磁盘布局）：可以是「一 chunk 一文件」或「64 chunk 一个 1MB 段文件」。

**S1d 首版取「一 chunk 一文件」**（实现最简、并发最安全），
物理布局的优化留作后续，**且因为逻辑层已解耦，后续优化不改契约、不改迁移**。

---

## 5. Q4 · staged → committed 状态机与 GC

### 状态机

```
        putFile / put / putChunk
                 │
                 ▼
          ┌─────────────┐
          │   staged    │  ← 带 stagedAtUtc，TTL 24h
          └──────┬──────┘
                 │  reconcileRefs 把它纳入某条记录的引用集
                 │  （契约 local_blob_store.dart:129：
                 │    「是 handle 从 staged 转正的唯一途径」）
                 ▼
          ┌─────────────┐
          │  committed  │  ← 受引用计数保护
          └──────┬──────┘
                 │  reconcileRefs 把它移出全部记录 → refCount 归 0
                 ▼
          ┌─────────────┐
          │ collectable │  ← GC 可回收
          └─────────────┘
```

### GC 的三条规则（设计稿 §6.4 原文 + 本设计补充）

设计稿 §6.4 原文：「GC 只回收「staged 且超时」或「已对账且引用数为 0」的 blob，
堵住 put 与对账之间的崩溃窗口」。

| # | 回收条件 | 依据 | 补充说明 |
|---|---|---|---|
| **G1** | `status == staged` 且 `now - stagedAtUtc > 24h` | §6.4 原文 | TTL 取 24h（§6.4「建议 24h」）。**必须可注入时钟**，否则验收项 10 无法测 |
| **G2** | `status == committed` 且 `refCount == 0` | §6.4 原文 | ⚠ 见下方「tier 的关键差异」 |
| **G3** | 文件系统上存在、drift 中无对应记录（孤儿文件） | 本设计补充（Q1 边界） | 由 §2「先落文件后写 drift」的顺序产生，必须回收否则空间泄漏 |

### ⚠ tier 的关键差异（本设计对 G2 的收紧）

**`sourceOfTruth` 的 refCount 归零，不等于可以删字节。**

理由：§7.4.6 原文「真相源区……**清了就没了**（除非云端有备份）」，
而 §7.4.5「删除私有原图 → 删」说的是**用户主动删除**，不是 GC。
若 GC 对 `sourceOfTruth` 执行 G2，则一次 `reconcileRefs` 的 bug
（例如业务侧漏传了一个 handle）会**立即且不可逆地删掉用户的私人照片**。

**处置**：
- `tier == cache` 且 `refCount == 0` → G2 直接回收（清了可重新下载）。
- `tier == sourceOfTruth` 且 `refCount == 0` → **不自动回收**，
  转入 `orphaned` 标记状态，仅由**用户显式操作**或**独立的、带确认的清理流程**删除。
  在 `BlobEntry` 上通过 `refCount == 0 && tier == sourceOfTruth` 即可被 UI 识别。

这是我对设计稿 §6.4 的一处**收紧**（不是违反：§6.4 说 GC「只回收」这两类，
是回收范围的上界，我在其内进一步收紧）。
✅ **人类 2026-08-03 已裁定采纳这处收紧。**

### 跨设备引用计数不收敛

派工单 §3 明示「**不要试图解决它**，按单设备语义实现即可，遇到就在文档里记一笔」。
设计稿 §6.4 末原文：「设备 A 上引用归零删字节，设备 B 仍在引用。见 §10 待决」。

**本设计的处置**：全部引用计数为**单设备本地语义**，不做任何跨设备协商。
`t_blob_ref` 表不含 peerId/deviceId 维度。
⚠ 上述 §5「sourceOfTruth 不自动回收」的收紧**恰好也缓解了这个问题的最坏后果**
（跨设备不收敛导致的误删，在私有数据上不会自动发生）——但这是副作用，不是解法。

---

## 6. Q5 · drift 表设计

三张表。命名沿用仓库既有 `t_` 前缀惯例。

### 6.1 `t_blob_meta` — blob 元数据

| 列 | 类型 | 说明 |
|---|---|---|
| `cipher_manifest_id` | TEXT **PK** | 主键。私有=随机 UUID，公开=plaintextSha256 |
| `scope_uid` | TEXT | 作用域隔离 |
| `plaintext_sha256` | TEXT | 本地去重索引。**永不作远端对象名** |
| `cipher_id` | TEXT | 定位解密实现 |
| `key_version` | INT | 支持密钥轮换 |
| `total_bytes` | INT | 明文总字节 |
| `chunk_count` | INT | chunk 总数 |
| `mime_type` | TEXT | MIME |
| `tier` | INT | 0=sourceOfTruth, 1=cache |
| `visibility` | INT | 0=private, 1=public |
| `status` | INT | 0=staged, 1=committed, 2=orphaned |
| `staged_at_utc` | INT | TTL 计时起点（G1） |
| `last_access_at_utc` | INT | LRU 排序依据（`BlobEntry.lastAccessAtUtc`） |
| `external_id` | TEXT? | 业务外部 id，`evictByExternalId` 用 |

索引：`(scope_uid, tier, last_access_at_utc)` — 服务 `list()` + LRU 逐出；
`(plaintext_sha256)` — 服务本地去重；`(status, staged_at_utc)` — 服务 G1；
`(external_id)` — 服务紧急下架。

### 6.2 `t_blob_chunk` — chunk 持有集合

| 列 | 类型 | 说明 |
|---|---|---|
| `cipher_manifest_id` | TEXT | 复合 PK 之一 |
| `chunk_index` | INT | 复合 PK 之二 |
| `cipher_bytes_len` | INT | 密文长度，校验用 |
| `chunk_sha256` | TEXT | 每 chunk 独立 sha256（§6.1 + S6 `:376`） |

**主键 `(cipher_manifest_id, chunk_index)`。**
`presentChunks` = `SELECT chunk_index WHERE cipher_manifest_id=?`，走主键前缀扫描。
**「存在即持有」**：行存在 = 该 chunk 已落盘且校验通过。这样差集计算是
`{0..chunkCount-1} - present`，O(持有数)。

> 为什么不用位图列：位图在「算差集」上确实更快，但**无法表达每 chunk 的 sha256**，
> 而 §6.1 与 S6 `:376` 都要求每 chunk 独立 sha256 以支撑损坏定位
> （`BlobCorrupt(Set<int> badChunks)` 要能指出**哪些** chunk 坏了）。
> 行式存储同时满足两者。

### 6.3 `t_blob_ref` — 引用计数

| 列 | 类型 | 说明 |
|---|---|---|
| `owner_record_uuid` | TEXT | 复合 PK 之一 |
| `cipher_manifest_id` | TEXT | 复合 PK 之二 |

**主键 `(owner_record_uuid, cipher_manifest_id)`。**
这个形状使 `reconcileRefs` 的**幂等性是结构性的**而非靠实现小心：
- 全量声明 = 「把 `owner_record_uuid` 的行集合**替换**为 `handles`」
- 实现 = 单事务内 `DELETE WHERE owner=?` + `INSERT` 全量
- 连调两次结果必然相同（验收项 7 天然成立）

`refCount` **不冗余存储**，实时由 `SELECT COUNT(*) WHERE cipher_manifest_id=?` 得出。
理由：冗余计数器是引用计数错乱的头号来源（派工单 §2.1「引用计数错乱 → 误删」）。
索引 `(cipher_manifest_id)` 保证该查询走索引。

### 6.4 迁移

新增 3 张表，**不改动任何既有表**——因此迁移是纯 `create` 操作，
对既有数据零影响。这也使「逐字段比对旧数据未丢」的验收项 13 容易通过。

**目标版本号：v8**（人类已裁定，见 §10）。

---

## 7. Q6 · Web 端 / Q7 · `dart:io`

### Q6 结论：⚠ 建议本期不交付 Web 端 blob，**需人类确认**

**援引先例**：S6 文档 `:1182` D18「Web 端的落盘加密方案 → **已决：本期不考虑**
（人类 2026-08-03）。Web 端 S6 能力本期不交付」。

**理由**：
1. blob 的价值负载几乎全部来自 S6（P2P 传输）与 S2/S3a。
   S6 已决 Web 不交付，则 Web 端有 blob 落地层也无字节可收。
2. Web 无文件系统。可选项 OPFS（Origin Private File System）虽可用，
   但它与 IndexedDB 的配额、持久化保证（`navigator.storage.persist()`）、
   跨浏览器行为差异，是一个**独立的调研工作量**，
   放进 S1d 会让本任务的范围翻倍。
3. Web 端 `sqlite3.wasm` 已存在，**元数据表在 Web 上本来就能跑**——
   即本设计的 drift 部分天然 Web 兼容，缺的只是字节存储。
   这意味着**后续补 Web 的成本低**（只需替换字节后端），不是不可逆决策。

**若人类要求本期交付 Web**：建议选 **OPFS**（有真实文件语义、支持流式读写、
配额远大于 IndexedDB），我会追加一轮调研并重估工期。

### Q7 结论：条件导入，照抄仓库既有模式

**不需要发明新方案**——仓库已有成熟的三文件条件导入先例，实测至少 5 处：

```dart
// drift/lib/ai/connection.dart:1-3（原文）
export 'unsupported.dart'
    if (dart.library.js_interop) 'web.dart'
    if (dart.library.ffi) 'native.dart';
```

同款先例：`drift/lib/four_zhu_card_templates/connection.dart:2-3`、
`drift/lib/meihuayishu/dictionary_database.dart:4`、
`drift/lib/meihuayishu/meihua_database.dart:4`、
`drift/lib/taiyishenshu/taiyi_database.dart:7`。

**本设计据此**：blob 的字节后端定义为 `BlobByteBackend` 抽象，
经 `blob_byte_backend.dart` 条件导出：
- `native.dart` → `FileSystemBlobByteBackend`（`dart:io`）
- `web.dart` → `UnsupportedBlobByteBackend`（全部方法抛明确的「Web 本期不支持」错误）
- `unsupported.dart` → 同上

**这样 `dart:io` 被隔离在 `native.dart` 一个文件内，drift 包保持 Web 可编译。**

**关于 P3（`persistence_core` 既有 2 处 `dart:io`）**：那是 S1d 之外的既有缺口，
且与 blob 无关（是配置加载）。**我不在 S1d 内修**——修它属于范围外，
且会与其他子系统的文件产生冲突。仅在此记录。

---

## 8. 验收标准

派工单 §5 是本项目最看重的一节，理由是**已实证的前车之鉴**：
`core/test/transport_contract_test.dart:22-28` 把断言写在**未 await 的 `.then()`**
回调里导致恒绿，隔离工程实测写入 `expect(1, 999)` 仍输出 `All tests passed!`。

**本设计的应对：每条测试都必须通过「变异验证」。**
即在提交前，对每条验收项**故意植入一个错误实现，确认测试变红，再改回**。
我会在 PR 描述中逐条记录变异验证的结果——**不是声称做了，而是列出每条变异的具体内容**。

| # | 判据 | 测试形态 | 变异验证方式（故意写错什么） |
|---|---|---|---|
| 1 | `BlobReadResult` 五分支穷尽 | 5 个独立单测 | 让 corrupt 分支返回 absent |
| 2 | `BlobStatus` 五态可达 | 5 个独立单测 | 让 partial 永远返回 complete |
| 3 | 断点续传：写 60%→中断→续传→逐字节一致 | 往返比对 | 续传时跳过一个 chunk |
| 4 | `presentChunks` 差集正确 | 单测 | 返回全集 |
| 5 | 并发 `putChunk` 安全 | 并发单测 | 去掉按 index 分片，共用一个文件句柄 |
| 6 | 同 `ownerRecordUuid` 并发 `reconcileRefs` 串行化 | 并发单测 | 去掉串行化锁 |
| 7 | `reconcileRefs` 幂等 | 单测 | 改 INSERT 为累加而非替换 |
| 8 | ⚠ `evictCache` 绝不动 `sourceOfTruth` | **负测试** | **让 evictCache 遍历全部 tier** ← 最重要的一条 |
| 9 | `RecordBlobUnitOfWork` 事务性 | 注入失败单测 | 去掉 transaction 包裹 |
| 10 | staged TTL 与 GC | 可注入时钟 | 让 TTL 判断用 `>=` 变 `<=` |
| 11 | 主 isolate 不阻塞 > 16ms | 大文件哈希时测主 isolate 响应 | 把哈希搬回主 isolate |
| 12 | 落盘路径约束静态门禁 | grep 断言 | 在源码里插入 `getExternalStorageDirectory` |
| 13 | 迁移：逐字段比对旧数据未丢 | 照抄既有体例 | 迁移里 DROP 一张旧表 |

**验收命令**（一条命令 + 一个期望退出码）：

```bash
cd core     && dart analyze --fatal-infos && flutter test
cd drift    && dart analyze --fatal-infos && flutter test
cd firebase && dart analyze --fatal-infos && flutter test
```

期望：analyze 零 issue，test 全绿，退出码 0。

---

## 9. 交付物与实现顺序

| 阶段 | 内容 | 落点包 |
|---|---|---|
| A | 3 张 drift 表 + 迁移 + 迁移测试 | `persistence_drift` |
| B | `BlobByteBackend` 条件导入骨架 + 文件系统实现 | `persistence_drift` |
| C | `BlobCipherResolver` 装配 + identity cipher + private 占位（抛「S6 未交付」） | `persistence_drift` |
| D | `LocalBlobStore` 真实现（含 isolate 哈希） | `persistence_drift` |
| E | `RecordBlobUnitOfWork` drift 实现 + 内存 fake | `persistence_drift` / `persistence_core` |
| F | `BlobGateway` Firebase 实现 | `persistence_firebase` |
| G | 13 条验收测试 + 逐条变异验证 | 各包 test/ |

**不做**（派工单 §3 ❌ 表，越界即失败）：
真 E2EE 加密与密钥派生（S6）、P2P 传输（S6）、oplog/游标/仲裁（S1b）、
全量对齐（S1c）、导出导入包格式（S3a）、云端分享业务逻辑（S2）、
业务侧 Repository 改造。

---

## 10. schema 版本号：**v8**（已裁定）

**人类裁定（2026-08-03）：S1b 先合并，S1d 用 v8。**

**事实基线**：
- `main` 当前 `schemaVersion => 6`（实测 `persistence_drift.dart:541`）
- S1b 工作树已改到 `=> 7`（新增 `t_outbox_peer_ack` + `t_sync_state` 主键加 peerId）
- S1b **尚未合并** main（实测）

**因此本实现**：
1. blob 迁移写 **v8**，`onUpgrade` 中新增 `if (from < 8) { ... }` 分支。
2. **合并前必须 rebase 到已含 S1b（v7）的 main。** 在 S1b 合并前，
   本分支的迁移测试需要以「v7 已存在」为前提编写。
3. 派工单 §1 原写的「先按 v7 写 + 在注释里标注版本号待定」的处置**已作废**。

⚠ **对我的实际约束**：我基于 `main`(v6) 开工，但要写 v8 迁移。
这意味着 `onUpgrade` 里会出现一个「从 7 升到 8」的分支，而 v7 本身在我的
基线里不存在。**处置**：迁移代码按目标形态写（v8 分支），
迁移测试在 rebase 前以 v6→v8 验证建表正确性，**rebase 后补 v7→v8 的完整链路测试**。
这一条会写进 PR 描述。

---

## 11. P1 / P2 平台缺口：不修，仅记录（已裁定）

**人类裁定（2026-08-03）：都不修，只在文档记录。不动 `xuan-shell` 仓库。**

如 §1「修正 1」，`xuan-shell` 是**独立 Git 仓库**
（`git rev-parse --show-toplevel` → `/Users/jingtaiwei/Git/Public/xuan-migration/xuan-shell`），
S1d 的 PR 无法包含其改动。派工单 §6 建议的「在 S1d 内修掉」在仓库结构上不成立。

### 已知且已被接受的残余风险

| 缺口 | 实测证据 | 后果 | 状态 |
|---|---|---|---|
| **P1** Android 缺 `allowBackup="false"` | `xuan-shell/android/app/src/main/AndroidManifest.xml:2-5` 的 `<application>` 只有 label/name/icon；`grep -rn "allowBackup\|fullBackupContent" android/` → **0 命中**，即取默认值 `true` | ⚠ **私有 blob 会被 Android Auto Backup 静默传到用户 Google Drive。** 这使本设计 §3 的落盘保护在 Android 上被绕过 —— 字节确实落在 app-specific 目录，但该目录**正是 Auto Backup 的备份范围** | **已知未修**，人类 2026-08-03 接受 |
| **P2** macOS `Release.entitlements` 缺网络权限 | `Release.entitlements` 只有 `com.apple.security.app-sandbox`；`DebugProfile.entitlements` 另有 `network.client` + `network.server` | `BlobGateway` 在 macOS Release 包中联网会**静默失败**（开发期全绿、发版即死） | **已知未修**，人类 2026-08-03 接受 |

**两者的共同特征是静默失败** —— 不报错、不崩溃，只是行为与设计意图相反，
**无法靠功能测试发现**。留待 S6 或专门的平台配置任务处置。

> 本节的作用是让后续承接方不必重新发现这两个缺口。
> S6 文档 §7.1b 已将其列为 P1/P2 前置修复项（`:1225-1226`）。

---

## 12. 实现启动条件：已满足

| # | 事项 | 状态 |
|---|---|---|
| 1 | Q1–Q5、Q7 的设计结论 | ✅ 通过 |
| 2 | Q6 Web 端本期不交付 | ✅ 已裁定 |
| 3 | schema 版本号 = v8 | ✅ 已裁定 |
| 4 | P1/P2 不修，仅记录 | ✅ 已裁定 |
| 5 | GC 对 sourceOfTruth 的收紧 | ✅ 已采纳 |

**可以开始按 §9 的阶段 A–G 实现。**

---

## 附录 · 本文档的证据索引

全部结论的一手证据（便于复核）：

- 契约原文：`core/lib/model/{blob_types,local_blob_store,blob_gateway,blob_cipher,blob_error,record_blob_unit_of_work}.dart`、`cancellation_token.dart`
- 设计稿：`docs/superpowers/specs/2026-07-31-storage-architecture-design.md` §3.2 / §3.6 / §6.1 / §6.2 / §6.4 / §7.4.3 / §7.4.5 / §7.4.6 / §7.5.1
- S6 文档（位于 S1b 分支 `agent/mimo/storage-s1b-multipeer`）：§4.3（`:611-682`）、§7.1 D11/D18/D19（`:1182-1183`、`:1239`）、chunk 16KB（`:371-373`）
- 体检报告 BL-4（位于 S1b 工作树 untracked 文件）：`docs/dispatch/2026-08-03-s3bc-readiness-report.md:47`
- 条件导入先例：`drift/lib/ai/connection.dart:1-3` 等 5 处
- 平台缺口实测：`xuan-shell/android/app/src/main/AndroidManifest.xml:2-5`、`xuan-shell/macos/Runner/{Release,DebugProfile}.entitlements`
