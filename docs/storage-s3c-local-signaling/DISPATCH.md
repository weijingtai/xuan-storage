# 派工：S3c-b —— LocalSignaling（局域网信令实现）

> 2026-08-04 ｜ 基线 main = `bc6b068` ｜ 冷启动接手，假设你对本项目一无所知
>
> 本文是人类下发的原始派工书，**逐字留存**。蒸馏后的可执行版本见
> `tasks/claude-storage-s3c-local-signaling.md`；二者冲突时以任务纪要的
> 「决定记录」为准（那里记了偏离原文的理由）。
>
> ⚠ **2026-08-04 人类追加裁定，修订了本文以下三处，读本文时务必对照任务纪要**：
> - **§5** 的套件签名 `makeChannel` → 实为 `makePair` + 注入 `simulateAbruptDisconnect`（D1）
> - **§8 A1**「提取无损」口径放宽：不再要求逐字保留原写法，只要求两个内存 fake 仍全绿（D5b）
> - **§9 纪律第 3 条**「新增公开 API 必须进 barrel」**只约束产品 API，不约束 test_support**（D3）
>
> 另新增两条验收：A10（`flutter_test` 围栏）、A11（套件内禁用 `pumpEventQueue`）。

---

## 一、你在哪儿

**仓库**：`/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage`

Dart/Flutter **多包工作区**：

| 目录 | 包名 | 职责 |
|---|---|---|
| `core/` | `persistence_core` | 契约 + 后端无关的编排逻辑 |
| `drift/` | `persistence_drift` | SQLite 实现 |
| `firebase/` | `persistence_firebase` | 云端实现 |
| `assets/` | `persistence_assets` | 内置资源 |
| **`p2p/`** | **`persistence_p2p`** | **本轮由你新建** |

多个 AI agent 并行，各自独立 git worktree。**不要在主工作区改代码。**

---

## 二、本轮做什么

实现 **`LocalSignaling`** —— `SignalingChannel` 的局域网实现：**用 bonsoir 发现对端，直连交换 SDP，全程零外网。**

这是裁定 C2 的落地：完全离线的局域网也能同步，靠的就是「信令不走云」。

---

## 三、必读

1. **`core/lib/model/signaling.dart`** —— 你要实现的契约。**一个字都不许改**，有异议写进「决定记录」上报人类
2. **`core/test/signaling_contract_test.dart`** —— 上一轮的契约测试，**你要复用它**（见 §5）
3. **`docs/superpowers/specs/2026-07-31-storage-architecture-design.md` §9.5** —— 裁定 C2 的完整论证与第三方选型表
4. **`core/lib/model/transport.dart`** —— 里面的 `AdvertisementHandle` 定义了广播的隐私约定，你要遵守
5. **`AGENTS.md`** —— 尤其「铁律：依赖解析」三条，不读会浪费你半小时

---

## 四、已裁定，不许推翻

| 裁定 | 内容 |
|---|---|
| C2 | S3b 不是独立子系统，就是这个 `LocalSignaling` |
| C3 | 信令走 `SignalingChannel` 接口；**`p2p` 包不得依赖任何 firebase** |
| — | 局域网发现用 **`bonsoir 7.1.4`**。**`multicast_dns` 只能查不能播，选它是死路**（其源码留有 `// TODO(dnfield): Support queries coming in for published entries.`） |
| — | NAT 打洞是 `flutter_webrtc` 内建 ICE，**不是你这轮的事** |

---

## 五、⚠ 本轮最重要的一条：复用上一轮的契约测试

上一轮（S3c-a）交付了 **11 条共享契约测试**，并对两个内存 fake 各跑了一遍。
**你的 `LocalSignaling` 必须跑通同一套。**

但那套测试现在写死在 `core/test/signaling_contract_test.dart` 里，
`p2p/test/` **导入不到**（Dart 的 `test/` 目录不可跨包引用）。

**所以本轮第一步是：把那套共享契约提取到 `core/lib/test_support/signaling_contract_suite.dart`**，
导出一个形如 `void runSignalingContractSuite({required String topologyName, required SignalingChannel Function() makeChannel})` 的函数。

- 仓库已有先例：`core/lib/test_support/in_memory_stores.dart`
- 提取后 `core/test/signaling_contract_test.dart` 改为调用它，**原 11 条对两个 fake 仍须全绿**（这是提取无损的证明）
- 然后 `p2p/test/` 对真实 `LocalSignaling` 调同一个函数

**这条的价值**：以后 S3c-d（CloudSignaling）和任何新后端，都自动被同一套 11 条约束住，不会各写各的。

---

## 六、范围

### 做

1. **提取共享契约套件**到 `core/lib/test_support/`（见 §5）
2. **新建 `p2p` 包**（包名 `persistence_p2p`），依赖 `persistence_core`（用 `path: ../core`）+ `bonsoir ^7.1.4`
3. **`LocalSignaling implements SignalingChannel`**：
   - `open(rendezvous)` → 用 bonsoir 广播自己 + 发现对端
   - 发现对端 `IP:port` 后**直连 socket**，交换 `SignalingEnvelope`（SDP/ICE，共几 KB）
   - 先到者等待、后到者直连（不需要中间人）
4. **`peerPresence` 必须在 socket 断开时立刻产出 `departed`**，不许靠超时推断（契约注释里写死了这条）
5. **`close()` 前尽力发 `ByeEnvelope`**，且幂等
6. **架构守卫测试**：`p2p/pubspec.yaml` 不含任何 firebase 字样 —— 这是裁定 C3 从一句话变成可自动检查的事实

### 不做

- ❌ **WebRTC / `Transport` 实现** —— 那是 S3c-c
- ❌ **`CloudSignaling` / RTDB** —— 那是 S3c-d
- ❌ **不碰 `core/lib/model/signaling.dart`** 与 `transport.dart`
- ❌ **不碰** S1b / S1d / T1 的任何文件
- ❌ 不实现 `DeviceKeyStore`（那是 S6）
- ❌ 背压不在本轮（`PeerStream` 的事，归 S3c-c）

---

## 七、两个你会撞上的设计问题，先想清楚

### 1. mDNS 在测试环境不可靠，但你不能因此只测 fake

真实 mDNS 依赖组播，CI/沙箱里常常不通；但**只对着 fake 测，等于没测你自己写的那部分**。

建议（可提更好方案，写进「决定记录」）：把「发现」抽成一个包内窄端口
（如 `LanDiscovery`，只管 `advertise` / `discover`），
- **单元测试**注入内存 fake discovery + **真实 loopback socket** → 契约套件 11 条在这上面跑
- **集成测试**用真 bonsoir，标 `@Tags(['integration'])` 默认不跑，人工按需触发

这样你自己写的「socket 上的信封交换 + presence 语义」被真实覆盖，只有 mDNS 那一层是可选的。

### 2. RendezvousKey 不能泄露身份

S1a 的 `AdvertisementHandle` 已经定了：广播内容**只含随机 service id，不含 scopeUid / 用户名 / 设备名**，且有 `rotateAfter` 轮换周期。

你的 mDNS service name 里放什么，必须遵守这条，并且**写成可断言的测试**（上一轮就是把这条从注释变成了返回值才管住的）。

---

## 八、验收标准

- **A1** 共享契约套件提取后，`core/test/signaling_contract_test.dart` 对两个内存 fake 仍 **11 条全绿**（提取无损）
- **A2** 同一套件对真实 `LocalSignaling` 全绿（真实 loopback socket，非纯 fake）
- **A3** `peerPresence`：对端进程消失 → 观测到 `departed`。**测试必须真的关掉 socket，不许模拟**
- **A4** `close()` 发 `ByeEnvelope`，对端立即 `departed`；重复 `close()` 不抛错
- **A5** 对端 `departed` 后 `send()` 抛错，不静默丢弃
- **A6** `p2p/pubspec.yaml` 零 firebase 依赖（架构守卫测试，源码扫描）
- **A7** 广播内容不含 scopeUid / 用户名 / 设备名（可断言，非注释）
- **A8** 每条测试做过**变异自检**（注入违规 → 确认变红 → 复原），逐条在「决定记录」写明**注入了什么、红在哪条断言上**
- **A9** 四条既有门禁全绿

验收命令: bash scripts/run_s1a_analyze_gate.sh && bash scripts/run_s1b_analyze_gate.sh && bash scripts/run_monorepo_convention_check.sh && (cd core && flutter test) && (cd p2p && flutter test)

> ⚠ 纪要「验收命令:」那行**不要加 markdown 反引号** —— `aiwt` 用 `eval` 执行它。

---

## 九、本仓纪律（违反即打回）

> **一个绿的门禁，如果证明不了自己能红，它就是假的。**

已抓到过的真实陷阱，逐条避开：

1. **恒绿断言**：契约测试一律 `async` + `await`，比较**被 await 之后的值**。断言不许写在未 await 的 `.then()` / `.listen()` 回调里 —— 回调在测试结束后才跑，不参与判定。
2. **变红要红在对的地方**（上一轮 M10 的教训）：注入变异后若红在**编译失败**而非目标断言，这次自检**不算数**。编译失败说明你根本没验到那条断言的抓手。重新设计成「编译仍过、断言变红」。
3. **契约交付了但消费不到 = 没交付**（上一轮的真实缺陷）：新增公开 API 必须进 barrel，且要有测试能抓到漏 export。
4. **`$var` 后紧跟中文标点会吞字节**：shell 里一律写 `${var}`，否则 `set -u` 下崩在莫名其妙的地方。

---

## 十、环境（三个坑，都咬过人，AGENTS.md 有详细版）

1. **进 worktree 先对每个包 `flutter pub get`** —— 否则 analyze 报 500+ 条 `uri_does_not_exist` 假 issue
2. **报错指向 `.pub-cache` 里某包的类型不匹配 / 同名类重复定义** → 陈旧 lock，**`rm pubspec.lock && flutter pub get`**。`pub get` 和 `pub upgrade <单包>` 都顶不掉
3. **入库 pubspec 的相对路径以 main 的位置为准**（`path: ../core`）。worktree 差两层的问题交给 gitignored 的 `pubspec_overrides.yaml`，**不许改入库文件**。注意该文件**整体取代**而非合并 `dependency_overrides` 段

分支从 **main** 起（`bc6b068`）。

---

## 十一、开工方式

`/wjt-plan` 立项，任务短名 `storage-s3c-local-signaling`，类型 feat。
立项后**不要自己开工**，等人类说"开工"。
