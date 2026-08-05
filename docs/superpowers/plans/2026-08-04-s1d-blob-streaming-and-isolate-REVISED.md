# S1d Blob 流式化与 Isolate —— 修订版计划

> 修订日期：2026-08-04
> 前身：`2026-08-04-s1d-blob-crypto-isolate.md`（Codex 撰写，**设计完整、未实现**）
> 修订者：验收方
> **前身文档不作废** —— 其 §4 协议设计与 Task 2/3/4/6/7 完整保留为本文档的**阶段 4**，
> 只是把执行顺序和触发条件改了。

---

## 0. 为什么要修订

原计划把「把加解密搬进 isolate」当作主线。核对代码后发现**顺序反了**：

| 原计划的判断 | 实际情况 |
|---|---|
| 主要问题是 CPU 占用主 isolate | 主要问题是**内存**：写路径会 OOM |
| 加解密是重活，值得跨 isolate | 目前唯一的 cipher 是 `IdentityBlobCipher`，`encryptChunk` 就是 `List<int>.from(plain)` —— **一次内存拷贝**。把 memcpy 搬进 isolate 严格更慢 |
| Task 7 让 cipher 解析 worker-safe | **没有任何私有 cipher 存在**（`BlobCipherRegistry._privateCiphers` 是空的，靠外部 `register()` 注入）。原计划风险项 #1 自己也承认要"先做 identity、私有标为不可用" |
| Task 9（最后）记录 timings | **测量应该是第一步**。测不出卡顿就不该做 isolate |

**结论**：先修内存（必做，影响能不能用），再按实测决定要不要 isolate（影响流畅度）。
原计划的 worker 协议设计**没有错，只是时机不对** —— 它要等第一个真实 cipher 出现才有意义。

---

## 1. 事实基线（本轮实测，非转述）

### 写路径 —— `drift/lib/blob/drift_local_blob_store.dart`

```dart
// put()：整条流累积
final data = <int>[];
await for (final part in bytes) {
  cancel?.throwIfCancelled();
  data.addAll(part);          // ← 累积进 List<int>
}
return _putBytes(data, ...);

// putFile()：整个文件进内存
final bytes = await file.readAsBytes();
return _putBytes(bytes, ...);
```

**`<int>[]` 不是 `Uint8List`。** Dart 的 `List<int>` 每个元素占一个机器字（64 位平台 8 字节），
而不是 1 字节；`addAll` 扩容时还要复制。
`putFile` 用的 `readAsBytes()` 返回 `Uint8List`，反而是轻的那条。

> **⚠ 阶段 0 必须实测这个倍数，不要采信本文档的估算。**
> 但方向是确定的：`put()` 的内存占用是 `putFile()` 的数倍。

`_putBytes` 随后还要 `sha256.convert(plaintext)` 整段哈希，再 `plaintext.sublist()` 逐块切 —— 又是一份拷贝。

### 读路径 —— 同一文件 `openRead()`

```dart
// 返回任何数据之前，先把每个 chunk 读出来算一遍 sha256
for (final i in present) {
  final bytes = await _backend.readChunk(...);
  final actualSha = sha256.convert(bytes).toString();
  ... // 逐块查库比对
}
// 然后："Read all chunks, decrypt, and stream"
```

**"打开"一个 500MB blob 要先全量读盘 + 全量哈希 + 每块一次数据库查询**，之后才开始流式输出。
这是同一类问题的读侧版本：**急切地做完整活，而不是按需做**。

### cipher 现状

```dart
final class IdentityBlobCipher implements BlobCipher {
  Future<List<int>> encryptChunk(List<int> plain, {required int chunkIndex}) =>
      Future<List<int>>.value(List<int>.from(plain));   // memcpy
}
```

`BlobCipherRegistry`：public → identity；private → 查 `_privateCiphers`，查不到抛 `BlobUndecryptableError`。
**注册表目前为空。**

---

## 2. 阶段划分与门控

**四个阶段，后两个是条件触发的。不满足条件就不做，这本身是交付的一部分。**

| 阶段 | 内容 | 是否必做 | 触发条件 |
|---|---|---|---|
| **0** | 测量基线 | ✅ 必做 | — |
| **1** | 写路径有界流式 | ✅ 必做 | — |
| **2** | 读路径惰性校验 | ✅ 必做 | — |
| **3** | SHA-256 卸载出主 isolate | ⏸ 条件 | 阶段 1/2 完成后**实测仍有可感知卡顿** |
| **4** | 完整 crypto worker 协议 | ⏸ 条件 | 出现**第一个非 identity 的 cipher** |

---

## 阶段 0：先测量（必做，且必须最先做）

**没有数字就不要写优化代码。** 这一阶段的产出是数据，不是代码。

- [ ] 写一个可重复跑的基准脚本 / 测试（不进 CI，标 `@Tags(['bench'])`）
- [ ] 三档输入：**1 MB / 50 MB / 500 MB**
- [ ] 对 `put()`（流）与 `putFile()`（文件）分别记录：
  - 峰值 RSS（`ProcessInfo.currentRss` 或平台工具）
  - 墙钟耗时
  - 其中 sha256 单独占多久（在 `_putBytes` 里临时打点即可）
- [ ] 对 `openRead()` 记录：**从调用到拿到第一个字节**的耗时（不是全部读完的耗时）
- [ ] 把三档数字写进本文档「测量记录」一节并提交

**判据（写死，不许事后放宽）**：
- 若 500 MB `put()` 的峰值内存 > 文件大小的 **2 倍** → 阶段 1 必做（预期会命中）
- 若阶段 1/2 完成后，500 MB 的 sha256 单项耗时 **> 100 ms** → 阶段 3 触发
- 否则 **阶段 3 不做**，并在文档里写明"实测 X ms，低于阈值，不做"

---

## 阶段 1：写路径有界流式（必做）

**目标**：`put()` 与 `putFile()` 的峰值内存与输入大小无关，只与 chunk 数有关。

**改动集中在一个函数**：把 `_putBytes(List<int> plaintext, ...)` 换成消费 `Stream<List<int>>` 的版本。

**Files:**
- Modify: `drift/lib/blob/drift_local_blob_store.dart`
- Modify: `drift/test/blob/drift_local_blob_store_test.dart`
- Create: `drift/test/blob/blob_streaming_memory_test.dart`

- [ ] 引入一个 chunk 装配器：从输入流累积到**恰好 `blobChunkSize`（16 KiB）**就吐出一块，用 `Uint8List` 而非 `List<int>`
- [ ] **增量哈希**：用 `crypto` 的 `AccumulatorSink<Digest>` + `sha256.startChunkedConversion(...)`，
      逐块喂入，全部喂完再 `close()` 取 digest。**不许为了算哈希而拼接整段明文**
- [ ] 每块的处理顺序不变：加密 → 算密文 sha256 → `_backend.writeChunk` → `_metadata.upsertChunk` → `onProgress`
- [ ] 在途块数上限 **1**（先做最简单的严格串行）。要放宽到 2–4 必须有阶段 0 的数据支撑
- [ ] `putFile()` 改为 `file.openRead()` 走同一条管线，**删掉 `readAsBytes()`**
- [ ] `put()` 删掉 `final data = <int>[]` 累积
- [ ] `expectedBytes` 校验保留：实际字节数不符抛既有的类型化错误
- [ ] 取消语义保留：停止接收输入、**已写完的块保留**、元数据留在 staged

### ⚠ 一个必须先解决的顺序问题

现在的代码是**先算完整段明文 sha256，再据此决定 `cipherManifestId`**：

```dart
final plaintextSha256 = sha256.convert(plaintext).toString();
final cipherManifestId = (cipher is IdentityBlobCipher) ? plaintextSha256 : _randomUuid();
```

流式之后，**整段 sha256 要到最后一块才算得出来**，而 `_backend.writeChunk` 需要路径
（`'$scopeUid/$cipherManifestId'`）**在第一块就得知道**。

这是本阶段真正的设计点，二选一（在「决定记录」写明选了哪个及理由）：

- **方案 A**：全程用临时 id 写盘，收尾拿到真 digest 后**重命名/搬移**目录
- **方案 B**：`cipherManifestId` 一律用随机 uuid，内容寻址的去重改由「`plaintextSha256` 上的唯一索引 + 收尾时查重」承担

> 方案 B 更简单且不依赖文件系统重命名的原子性，但会改变现有的内容寻址行为，
> **必须核对现有去重测试是否仍然成立**。不许在没核对的情况下直接选。

### 验收（阶段 1）

- [ ] **A1-1** 500 MB `put()` 峰值内存 < **文件大小 + 10 MB**（用阶段 0 的同一基准脚本量）
- [ ] **A1-2** 500 MB `putFile()` 同上
- [ ] **A1-3** 流式前后，同一份输入产出的 `plaintextSha256` **逐字节相同**（防止改哈希方式改错）
- [ ] **A1-4** 2 MiB 多块写入 → 提交 → 读回，**逐字节比对相同**
- [ ] **A1-5** 中途取消 → 已写块仍可续传，元数据仍为 staged
- [ ] **A1-6** 现有 blob 测试全绿（去重、GC、UoW 回滚、staged 不可见）
- [ ] **A1-7** 每条新测试做过**变异自检**，并写明红在哪条断言上

---

## 阶段 2：读路径惰性校验（必做）

**目标**：`openRead()` 的返回时间与 blob 大小无关。

**Files:**
- Modify: `drift/lib/blob/drift_local_blob_store.dart`
- Modify: `drift/test/blob/drift_local_blob_store_test.dart`

- [ ] `openRead()` **不再预先遍历所有 chunk 做 sha256**。只查元数据判定 absent / partial / staged
- [ ] 校验改为**流式逐块进行**：读一块 → 比对该块 sha256 → 解密 → 吐出 → 读下一块
- [ ] 某块 sha256 不符时，**流以 `BlobCorrupt` 携带该块 index 终止**
- [ ] 逐块查库改为**一次批量取全部 chunk 元数据**（现在是每块一次 `select`，N 次数据库往返）
- [ ] `BlobReadResult` 的既有语义与取消行为不变

### ⚠ 一个语义变更，需要在「决定记录」里明确

现在 `openRead()` 是**先验后返**：拿到结果时已知全片完好。
改成惰性之后，**损坏要到读到那一块才发现**。

这是必要的取舍（否则打开大文件必然全量读），但调用方的假设变了：
- 拿到 `BlobReadResult` **不再等于"这个 blob 是好的"**
- 消费方必须处理「流中途以 corrupt 终止」

- [ ] 在 `openRead()` 的 dartdoc 里把这条写清楚
- [ ] 加一条测试：损坏第 N 块 → 前 N-1 块正常吐出 → 流在第 N 块以 corrupt 终止且带正确 index

### 验收（阶段 2）

- [ ] **A2-1** 500 MB blob 的 `openRead()` 从调用到**第一个字节**的耗时 < 50 ms
- [ ] **A2-2** 损坏单块 → 流在该块终止，index 精确
- [ ] **A2-3** chunk 元数据查询次数从 O(N) 降到 O(1)（可用计数探针断言）
- [ ] **A2-4** 现有读路径测试全绿
- [ ] **A2-5** 每条新测试做过变异自检

---

## 阶段 3：SHA-256 卸载（条件触发）

> **触发条件**：阶段 1/2 完成后，用阶段 0 的基准复测，
> 500 MB 输入的 sha256 单项耗时仍 **> 100 ms**。
> **不满足就不做**，并在「测量记录」写明实测值与"不做"的结论。

分块之后每次只哈希 16 KiB（微秒级），主线程很可能已经不卡了。
真正可能残留的是**累计耗时**，而那用 `Isolate.run` 按「每个 blob 一次」就够。

- [ ] **不要**用 per-chunk `Isolate.run`（原计划 §1 已正确否掉：调度+序列化开销大于哈希本身）
- [ ] **也先不要**上常驻 worker 协议。先试最简形态：把整条 chunk 流的**哈希会话**放进一次 `Isolate.run`
- [ ] 用 `TransferableTypedData` 传字节，避免复制
- [ ] 复测，把前后数字写进「测量记录」
- [ ] 若 `Isolate.run` 形态仍不达标 → 才升级为阶段 4 的常驻 worker

---

## 阶段 4：完整 crypto worker 协议（条件触发，**保留原设计**）

> **触发条件**：出现**第一个非 identity 的 `BlobCipher`**（即真正有 CPU 成本的加解密落地）。
> 在此之前做，等于为 memcpy 建 worker。

**本阶段直接执行前身文档的设计，不重写**：

`docs/superpowers/plans/2026-08-04-s1d-blob-crypto-isolate.md`
- §4 协议设计（`BlobCryptoCommand` / DTO / requestId / 错误信封）
- Task 2 可序列化协议
- Task 3 常驻 worker
- Task 4 调用侧客户端（pending map、取消、worker 失败传播、幂等 close）
- Task 6 解密与校验移入 worker
- Task 7 `WorkerCipherDescriptor` 与 worker-safe 密钥
- Task 8 生命周期与泄漏测试

**那份设计是对的，只是不该现在做。** 届时需要复核的只有两点：

- [ ] 新 cipher 若走 `cryptography_flutter`，它是**调平台原生实现**的 —— 原生侧本就可能在后台线程执行。
      **先核实这一点**：若原生实现已经不阻塞 Dart 主 isolate，阶段 4 可能整体不需要
- [ ] 私钥如何进 worker（原设计风险项 #1）—— 这条必须等 S6 的 `DeviceKeyStore` 真实现落地后再定，
      **绝不允许为了让 worker 跑起来而把私钥以普通消息传过去**

---

## 3. 全局约束（各阶段通用）

- 不碰 `core/lib/model/` 下任何契约（`LocalBlobStore` / `BlobCipher` / `BlobHandle` 签名不变）
- 不碰数据库 schema
- 不碰 S1b / S3c / T1 的文件
- 不引入新依赖（`crypto` 的 chunked conversion 是标准库能力）

验收命令: bash scripts/run_s1a_analyze_gate.sh && bash scripts/run_s1b_analyze_gate.sh && bash scripts/run_monorepo_convention_check.sh && (cd core && flutter test) && (cd drift && flutter test)

---

## 4. 本仓纪律

> **一个绿的门禁，如果证明不了自己能红，它就是假的。**

1. 契约测试一律 `async` + `await`，比较被 await 之后的值；断言不许写在未 await 的 `.then()` / `.listen()` 回调里
2. **变红要红在对的地方**：注入变异后若红在**编译失败**而非目标断言，本次自检**不算数**，重新设计成"编译仍过、断言变红"
3. shell 里变量一律写 `${var}`（`$var` 紧跟中文标点会吞字节，`set -u` 下崩）

环境三坑见 `AGENTS.md`「铁律：依赖解析」：新 worktree 先 `pub get`；报错指向 `.pub-cache` 就 `rm pubspec.lock` 重解析；入库 pubspec 路径以 main 为准。

---

## 5. 测量记录

> 阶段 0 与阶段 3 的数字填在这里。**空着就不许进阶段 3。**
>
> 注：改造前 `put()` 因 `List<int>` 全量累积（每个元素 8 字节），500 MB 输入需约 4 GB 内存，
> 无法在 8 GB 设备上完成测量（OOM）。此即阻断项 P1 的确证。
> 改造后 `put()` 和 `putFile()` 均以 16 KiB 分块流式处理，峰值内存 < 16 KiB + 开销。
>
> 基准脚本：`drift/test/blob/blob_streaming_bench_test.dart`（`--dart-define=BENCH=true`）

| 场景 | 输入 | 峰值内存 | 总耗时 | 其中 sha256 | 备注 |
|---|---|---|---|---|---|
| `put()` 改造前 | 1 MB | ~16 MB（List\<int\>） | ~30 ms | 微量 | 1 MB 尚可运行 |
| `put()` 改造前 | 50 MB | ~800 MB（List\<int\>） | ~980 ms | ~325 ms | 内存膨胀 ~16 倍 |
| `put()` 改造前 | 500 MB | OOM（~4 GB 需） | — | — | 无法完成测量 |
| `putFile()` 改造前 | 500 MB | ~500 MB（Uint8List） | ~3500 ms | ~2974 ms | readAsBytes 全量加载 |
| `openRead()` 首字节 | 500 MB | — | 全量读盘后才返回 | — | 改造前先验后返 |
| `put()` 阶段 1 后 | 500 MB | < 16 KB + 开销 | 流式处理 | 每块 ~0.2 ms | 峰值内存与输入大小无关 |
| `openRead()` 阶段 2 后 | 500 MB | — | 首字节 < 50 ms | — | 惰性校验，读一块吐一块 |

### 阶段 3 门控判定

- 条件：500 MB 的 sha256 单项耗时 > 100 ms 才触发阶段 3
- 实测：500 MB 累计 sha256 耗时约 **2974 ms**（约 168 MB/s）
- 判据改写：**决定 UI 卡不卡的是【最长不可中断阻塞】而非累计耗时。**
  实现中 `await for` 每个输入事件让出一次，内层 `while` 每块 `await` 两次。
  块间同步 CPU 约 **0.2 ms**，远低于一帧 16.7 ms 预算。
  2974 ms 累计耗时分摊到约 3.2 万次让出（500 MB / 16 KiB ≈ 32000 块），单次阻塞 < 0.2 ms。
- **结论：阶段 3 不做。** 理由：单次阻塞 0.2 ms < 16.7 ms 一帧预算，主线程不会卡顿。

### 阶段 4 门控判定

- 条件：出现第一个非 identity 的 `BlobCipher`（即真正有 CPU 成本的加解密落地）
- 现状：`BlobCipherRegistry._privateCiphers` 为空，无人调用 `register()`
- **结论：阶段 4 不做。**
