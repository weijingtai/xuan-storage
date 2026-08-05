# storage-s3c-local-signaling 冷启动执行 Prompt（从零开始）

> 生成于 2026-08-04，基于 HEAD `189afde`。
> 用法：在下列 worktree 根目录启动具备终端与文件编辑能力的强模型 Agent，
> 一次性投喂本文件中 `---` 之间的全文。
>
> ```bash
> cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/claude-storage-s3c-local-signaling
> ```
>
> ⚠ 本任务**生产代码一行未写**，只有蓝图。执行者从 P0 做到 P10。

---

你是 `storage-s3c-local-signaling` 任务的实现执行者。你是冷启动的，对这个项目和之前发生的事
一无所知 —— 所以下面把你需要知道的全部状态都写死了，**它比你自己去 `git log` 推断更准确**。

不要只给计划、摘要或建议；直接读文件、写代码、跑测试、修问题、提交。
本 Prompt 一次性授权你从 P0 做到 P10，**不授权**切分支、合并、推送、改主工作区、扩大范围。

**必须用中文交流，产出的文档以中文为主，源码注释也用中文。** 只有源码标识符、
目录路径、命令这些"说英文才讲得清"的东西才用英文。

## 0. 三十秒摘要

用 `bonsoir` 在局域网发现对端，直连 socket 把几 KB 的 SDP / ICE 文本交换掉 —— **全程零外网**。
这样完全断网的局域网也能同步。你要实现的是 `LocalSignaling`，它是既有契约
`SignalingChannel` 的第一个真实实现。

同时你要把上一轮写死在 `core/test/` 里的 11 条契约测试**提取成跨包可复用的共享套件**，
让你的 `LocalSignaling` 和以后的 `CloudSignaling` 都被同一套约束住。

## 1. 唯一工作目录

```
/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/claude-storage-s3c-local-signaling
```

只能在该 worktree 内工作。**不得进入或修改主工作区**
（`/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage`，它在 `main` 分支上）。

⚠ 这不是假想风险：本仓已有 agent 误把文件改到主工作区的 `main` 上，事后靠 `git checkout --` 回滚。
**每次改文件前确认路径以 `.worktrees/claude-storage-s3c-local-signaling/` 开头。**

主工作区当前有一处**属于别的任务**的未提交改动（`firebase/infrastructure/emulator/firestore.rules`）。
**别碰它，别提交它，别问它是什么。**

## 2. 你接手时的真实状态（已核实，不要自己猜）

### 2.1 分支与提交

```
分支: agent/claude/storage-s3c-local-signaling
基线: main = bc6b068
HEAD: 189afde  plan(s3c-b): 落盘人类四条裁定 —— A1 口径放宽, 新增 A10/A11 两道围栏
      af2cc7a  plan(s3c-b): LocalSignaling 立项 —— 纪要 + 原始派工书 + 收编 p2p 脚手架
      cee2162  plan: 开工 agent/claude/storage-s3c-local-signaling, 建立任务纪要
```

**三个提交全部只碰 `tasks/` 与 `docs/` 加一份未改造的脚手架。生产代码一行未写。**
工作区干净（`git status --porcelain` 为空）。

### 2.2 这是个多包 Dart/Flutter 工作区

| 目录 | 包名 | 职责 | 本轮你要碰吗 |
|---|---|---|---|
| `core/` | `persistence_core` | 契约 + 后端无关的编排逻辑 | **要**（提取共享套件、改 pubspec） |
| `drift/` | `persistence_drift` | SQLite 实现 | 不碰 |
| `firebase/` | `persistence_firebase` | 云端实现 | 不碰 |
| `assets/` | `persistence_assets` | 内置资源 | 不碰 |
| `preferences/` | `persistence_preferences` | 偏好设置 | 不碰 |
| `supabase/` | `persistence_supabase` | Supabase 实现 | 不碰 |
| **`p2p/`** | **`persistence_p2p`** | **P2P，本轮由你建成** | **要**（主战场） |

多个 AI agent 在各自独立的 worktree 上并行工作。**不碰 S1b / S1d / T1 的任何文件。**

### 2.3 `p2p/` 里现在有什么（是脚手架，不是实现）

已入库 10 个文件，是 `flutter create` 的产物加一份人类手写的草稿：

```
p2p/pubspec.yaml            name: p2p  ← 错的，要改成 persistence_p2p
                            依赖已填好: bonsoir 7.1.4 + persistence_core (path: ../core)
p2p/lib/p2p.dart            一个 Calculator 样板类 ← 删掉
p2p/lib/local_signaling.dart 只有壳子的草稿, _LanSession 里写着"省略实现，待完成" ← 重写
p2p/test/p2p_test.dart      测 Calculator 加一 ← 删掉
p2p/{LICENSE,CHANGELOG.md,README.md,.metadata,.gitignore,analysis_options.yaml}
```

生成物（`build/`、`.dart_tool/`、`.idea/`、`*.iml`、`pubspec.lock`、
`.flutter-plugins-dependencies`）已在入库前剔除干净，**别把它们加回去**（门禁会拦，见 §6）。

`local_signaling.dart` 那份草稿**不是需求，是人类随手比划的形状**。它写的
`_advertisement.start()` / `_discovery.start()` 都是不存在的类。你按 §5 的设计重写，
不要试图"补全"它。

## 3. 必读文件（按这个顺序，别跳）

1. **`tasks/claude-storage-s3c-local-signaling.md`** —— 任务纪要。计划 P0–P10、验收 A1–A11、
   决定记录 D1–D11。**这是你的主文档，本 Prompt 只是它的导读。**
   尤其「决定记录」，里面每一条都是已经吵完的架，**不要再吵一遍**。
2. **`core/lib/model/signaling.dart`** —— 你要实现的契约，270 行，注释比代码多。
   **一个字都不许改**（见 §4 铁律）。有异议写进纪要「决定记录」上报人类。
3. **`core/test/signaling_contract_test.dart`** —— 你要提取的那 11 条测试，752 行。
   连同两个内存 fake（`_LanFabricSignaling` / `_CloudRendezvousSignaling`）一起读。
4. **`AGENTS.md`** —— 尤其「铁律：依赖解析」三条。不读会浪费你半小时，见 §6。
5. **`core/lib/model/transport.dart` 的 `AdvertisementHandle`**（约 108–127 行）——
   定义了广播的隐私约定，你的 mDNS service name 要遵守它。
6. **`scripts/run_s1a_analyze_gate.sh`** —— 读注释就够。它是你最容易撞的门禁，见 §7。
7. `docs/storage-s3c-local-signaling/DISPATCH.md` —— 人类的原始派工书，逐字留存。
   **注意它头部标了三处已被后续裁定修订**，读时对照纪要。
8. `docs/superpowers/specs/2026-07-31-storage-architecture-design.md` §9.5 —— 裁定 C2 的
   完整论证与第三方选型表。想知道"为什么是这个架构"就读它。

## 4. 铁律与已裁定事项（不许推翻，不许重新论证）

| 编号 | 内容 |
|---|---|
| 铁律 | **绝对禁止在 `main` 上改代码。** 只在本 worktree 的分支上工作 |
| 铁律 | 程序标识符里禁止 `xuan-` / `xuan_` 前缀（pubspec name、library 声明、import 路径、依赖 key）。目录名和 Git URL 例外 |
| 铁律 | 仓内子包互引一律 `path: ../<子包>`，不得用 git URL 指回本仓（`run_monorepo_convention_check.sh` 会拦） |
| 裁定 C2 | S3b（局域网直连）不是独立子系统，就是这个 `LocalSignaling` |
| 裁定 C3 | 信令走 `SignalingChannel` 接口；**`p2p` 包不得依赖任何 firebase** |
| — | 局域网发现锁死 **`bonsoir 7.1.4`**。**`multicast_dns` 只能查不能播，选它是死路**（其源码留有 `// TODO(dnfield): Support queries coming in for published entries.`）。别再评估它 |
| — | NAT 打洞是 `flutter_webrtc` 内建的 ICE，**归 S3c-c，不是你这轮的事** |
| — | **不碰 `core/lib/model/signaling.dart` 与 `transport.dart` 一个字。** 改了会同时打红 S1a 门禁的「S1a 自有文件零 issue」与信令契约测试的架构守卫组 |

### 人类在立项后追加的四条裁定（比派工书更新，以这里为准）

- **D1** 共享套件签名不是派工书写的 `makeChannel`，而是
  `runSignalingContractSuite({required String topologyName, required FutureOr<SignalingChannelPair> Function() makePair, required FutureOr<void> Function(SignalingSession) simulateAbruptDisconnect})`，
  其中 `SignalingChannelPair = ({SignalingChannel alice, SignalingChannel bob})`。
  **加严**：`simulateAbruptDisconnect` 对真实 `LocalSignaling` 必须真的 `destroy()` socket，
  且**另有一条测试证明它真断**。
- **D2 + D2b** `flutter_test` 从 `core` 的 `dev_dependencies` 提到 `dependencies`（理由见 §7），
  **同时**加围栏：`core/lib/` 下只有 `test_support/` 允许 import `flutter_test`（验收 A10）。
- **D3** 共享套件**不许进 barrel**。`core/test/s1b_architecture_guard_test.dart:53` 已断言
  barrel 不得含 `test_support`。派工书「新增公开 API 必须进 barrel」那条**只约束产品 API**。
- **D5 + D5b** 共享套件里**全面禁用 `pumpEventQueue()`**（验收 A11），做法见 §5.3。
  同时 A1「提取无损」口径放宽为「两个内存 fake 仍全绿」，**不要求逐字保留原写法**。

## 5. 本轮要做什么

完整的 11 项计划在纪要的「计划」区，这里只讲三个你最容易做错的地方。

### 5.1 提取共享契约套件（P2）

`core/test/signaling_contract_test.dart` 现在有三组测试：

| 组 | 条数 | 提取后去哪 |
|---|---|---|
| `契约 · <拓扑名>` | **11 条 × 2 个拓扑 = 22** | **搬进** `core/lib/test_support/signaling_contract_suite.dart` |
| `架构守卫（源码扫描）` | 5 条 | **留在原地不动** |
| `barrel 可消费` | 2 条 | **留在原地不动** |

后两组读 `lib/model/signaling.dart` 和 `lib/persistence_core.dart` 的**相对路径**，
只有 `core` 包跑得到，搬进套件会在 `p2p` 里直接崩。

11 条契约测试是：相遇并双向收发 / 不回显自己发的 / trickle ICE 多条按序 /
awaiting→present / 对端 close 后 departed / 非正常断开也 departed /
departed 后 send 抛错 / close 幂等 / 不同会合标识不串扰 / rendezvous 如实回报 /
信封载荷不含身份信息。

**为什么必须是 `makePair` 而不是 `makeChannel`**：11 条里有 9 条要**两端在同一"织物"上相遇**
（内存 LAN fake 共享一个 `_LanFabric`；真实 `LocalSignaling` 共享发现表与 loopback 网段）。
单个工厂调两次拿到的是两个互不相干的实例，「两端在同一会合标识下相遇」这条根本写不出来。

**`_CrashableSession` 怎么办**：它现在是 `core/test/` 里的 test-private 接口，靠 cast 使用。
提到 `core/lib/` 后不能再用 `_` 私有名，而且真实实现的"崩溃"是 `socket.destroy()` 而非一次
方法调用。所以它变成套件的注入参数 `simulateAbruptDisconnect`。

### 5.2 `LanDiscovery` 窄端口 —— 为什么不能直接对着 bonsoir 写（P5）

真实 mDNS 依赖组播，CI / 沙箱里常常不通；但**只对着 fake 测，等于没测你自己写的那部分**。

所以把「发现」关进一个包内窄端口（只管 `advertise` / `discover`），两个实现：

- `FakeLanDiscovery`（内存）→ **单元测试用**，配**真实 loopback socket**
- `BonsoirLanDiscovery`（真 mDNS）→ **只进集成测试**，标 `@Tags(['integration'])` 默认不跑

这样切法的意义：你本轮真正手写的东西是「socket 上的信封交换 + presence 语义」，
它被真实 IO 覆盖；只有 mDNS 那一层是可选的。

⚠ **本仓目前没有任何 `dart_test.yaml`，也没有任何 `@Tags` 用法 —— 你是第一个引入的。**
所以要在纪要里写清楚人工触发集成测试的确切命令，别让后人猜。

**A7 隐私的抓手**：`FakeLanDiscovery` 必须记下**实际广播出去的 service name 与 TXT 记录**
并可读回，测试断言其不含 scopeUid / 用户名 / 设备名。
把隐私约定从注释变成**可断言的返回值** —— 这是 `AdvertisementHandle` 用过的同一手法，
上一轮就是靠这个才真的管住的。

### 5.3 `pumpEventQueue()` 为什么必须死（P3）

现有 11 条全部靠 `await pumpEventQueue()` 等传播。它的语义是"把事件队列转若干圈"——
对同步 `StreamController` 碰巧成立，**对任何真实 I/O 都不成立**（字节要过内核）。

这不是"内存 fake 与 socket 的矛盾"，是**等时间 vs 等事件**的区别。裁定的做法：

| 断言类型 | 做法 |
|---|---|
| **正向**（断言某事会发生） | `await` 真实可观测量本身 + 显式 timeout。如 `await session.incoming.first.timeout(d)`、`await session.peerPresence.firstWhere((p) => p == PeerPresence.departed).timeout(d)` |
| **负向**（断言什么都不发生） | 有界宽限期 + **显式命名常量**，且该常量**由拓扑注入**（内存 fake 给几毫秒，socket 给几百毫秒） |

负向断言是唯一真要等时间的地方，把它显式化、可按拓扑调，比全局 `pumpEventQueue` 既准确又诚实。

## 6. 环境（三个坑，都咬过人，AGENTS.md 有详细版）

**开工第一件事**：对 `core` 和 `p2p` 各跑 `flutter pub get`。

1. **新 worktree 必须先 `flutter pub get`** —— 否则 `dart analyze` 报 500+ 条
   `uri_does_not_exist`，每条 `package:` import 都红。那不是回归，是环境没装好。
   `scripts/run_s1a_analyze_gate.sh` 有前置断言会拦下（exit 2），照它给的命令做即可。
2. **报错指向 `.pub-cache` 里某包的类型不匹配 / 同名类重复定义**（典型如
   `X/*1*/ can't be assigned to X/*2*/`、`Y is imported from both ...`）→ 是**陈旧 lock**，
   **`rm pubspec.lock && flutter pub get`**。
   ⚠ `flutter pub get` 和 `flutter pub upgrade <单包>` **都顶不掉** —— 前者会尽量沿用现有
   lock，后者常常回一句 "No dependencies changed"。**必须删掉 lock 整体重解析。**
   判据：只要"同一 commit 在两个目录里结果不同"，就是这一条。2026-08-04 一天内出现三次。
3. **入库 pubspec 的相对路径以 `main` 的位置为准**（`path: ../core`）。worktree 比主目录深两层，
   这个深度差**只许**由 gitignored 的 `pubspec_overrides.yaml` 承担，**不许改入库文件**。
   ⚠ `pubspec_overrides.yaml` 会**整体取代**而非合并 `dependency_overrides` 段 ——
   新建时必须把原有条目一并抄来。

**别把生成物加进 git**：`build/`、`.dart_tool/`、`.idea/`、`*.iml`、`pubspec.lock`、
`.flutter-plugins-dependencies`。`run_monorepo_convention_check.sh` 的检查 2 会拦
`.flutter-plugins*`，其余靠你自己。提交前跑一次 `git status --porcelain` 扫一眼。

## 7. 门禁地形图 —— `run_s1a_analyze_gate.sh` 是你最容易撞的

它做三件事：

1. **S1a 自有的 20 个文件必须零 issue**（含 INFO，等价 `--fatal-infos`）。
   其中包括 `lib/model/signaling.dart` 和 **`test/signaling_contract_test.dart`** ——
   **后者你要改写（P2），改完必须仍然零 issue。**
2. **有 issue 的文件集合必须是冻结白名单的子集** —— 防止把断点挪到新文件。
   ⚠ **这条是陷阱所在**：你新建的 `core/lib/test_support/signaling_contract_suite.dart`
   不在白名单里，所以它必须**零 issue**。
3. **全包 issue 总数不得超过冻结基线 `BASELINE_TOTAL=57`**。

### 立项期已实测的一个坑（别再撞一次）

在 `core/lib/` 下 import `package:flutter_test/flutter_test.dart`，跑
`dart analyze --fatal-infos` 会得到：

```
info - The imported package 'flutter_test' isn't a dependency of the importing package.
     - depend_on_referenced_packages          退出码 1
```

因为 `flutter_test` 在 `core/pubspec.yaml` 里只是 **dev_dependency**，而 dev_dependencies
对 `lib/` 下的文件不算数。于是上面的检查 2 直接红。

**别以为 `core/lib/test_support/in_memory_stores.dart` 这个先例能保你过关 —— 它压根不 import
`flutter_test`。** 处置：把 `flutter_test` 提到 `core` 的正式 `dependencies`（人类已批准，D2），
同时建围栏（D2b / A10）。

顺带说清楚这不只是为了骗过 lint：`p2p` 作为 root 包时，`persistence_core` 的
dev_dependencies **根本不参与解析**，套件对不声明 `flutter_test` 的消费方会 import 不到。

### 四条门禁（验收命令的前三条 + 测试）

```bash
bash scripts/run_s1a_analyze_gate.sh
bash scripts/run_s1b_analyze_gate.sh
bash scripts/run_monorepo_convention_check.sh
(cd core && flutter test)
(cd p2p && flutter test)
```

**P0 就把这五条全跑一遍，把"动手前"的红绿数字记进纪要的「当前状态」。**
不记基线，你后面分不清哪条红是你弄的、哪条是本来就红的。

## 8. 纪律（违反即打回）

> **一个绿的门禁，如果证明不了自己能红，它就是假的。**

已抓到过的真实陷阱，逐条避开：

1. **恒绿断言**：契约测试一律 `async` + `await`，比较**被 await 之后的值**。断言**不许**写在
   未 await 的 `.then()` / `.listen()` 回调里 —— 回调在测试结束后才跑，不参与判定。
2. **变红要红在对的地方**：注入变异后若红在**编译失败**而非目标断言，这次自检**不算数**。
   编译失败说明你根本没验到那条断言的抓手。重新设计成「编译仍过、断言变红」。
   （上一轮的 M10 就栽在这。）
3. **契约交付了但消费不到 = 没交付**：上一轮初版把 `signaling.dart` 写完、27 条测试全绿，
   却漏掉 barrel 的一行 export，消费方从包入口根本拿不到 `SignalingChannel`。
   ⚠ 但**本轮的共享套件是例外，明令不进 barrel**（D3）。
4. **`$var` 后紧跟中文标点会吞字节**：shell 里一律写 `${var}`，否则 `set -u` 下崩在
   莫名其妙的地方。

### A8 变异自检怎么做才算数

每条测试都要：**注入违规 → 确认变红 → 复原**，并在纪要「决定记录」里逐条写明
**注入了什么、红在哪条断言上**。只写"已自检"不算数。

举例（`peerPresence` 那条）：把 `LocalSignaling` 里 socket `onDone` 时发 `departed` 的那行
注释掉 → 测试必须红在「对端崩溃/断网时后端必须判定 departed」这条断言的 reason 上，
而不是红在超时框架或编译错误上。

## 9. 验收标准（A1–A11，全在纪要里，这里是速查）

- **A1** 提取后原 11 条对两个内存 fake 仍全绿（口径已放宽，不要求逐字保留写法）
- **A2** 同一套件对真实 `LocalSignaling` 全绿，底层是**真实 loopback socket**
- **A3** `departed` 不靠超时；`simulateAbruptDisconnect` 真 `destroy()`，且**另有测试证明真断**
- **A4** `close()` 发 `ByeEnvelope`，对端立即 `departed`；重复 `close()` 不抛错
- **A5** 对端 `departed` 后 `send()` 抛错（`StorageError` 子类），不静默丢弃
- **A6** `p2p/pubspec.yaml` 零 firebase 依赖（源码扫描守卫）
- **A7** 广播内容不含 scopeUid / 用户名 / 设备名，**建立在可读回的返回值上**
- **A8** 每条测试做过变异自检，逐条写明注入了什么、红在哪
- **A9** 四条既有门禁全绿，S1a 的 57 条冻结基线未被抬高
- **A10** `flutter_test` 围栏：`core/lib/` 下只有 `test_support/` 可 import，围栏自身也要自检
- **A11** 套件内零 `pumpEventQueue`；正向 `await` + timeout，负向用拓扑注入的具名常量

验收命令（纪要里那行**不要加反引号**，`aiwt` 用 `eval` 执行它）：

```bash
bash scripts/run_s1a_analyze_gate.sh && bash scripts/run_s1b_analyze_gate.sh && bash scripts/run_monorepo_convention_check.sh && (cd core && flutter test) && (cd p2p && flutter test)
```

## 10. 不做什么

- ❌ **WebRTC / `Transport` 实现** —— 那是 S3c-c
- ❌ **`CloudSignaling` / RTDB** —— 那是 S3c-d
- ❌ 改 `core/lib/model/signaling.dart` 或 `transport.dart`
- ❌ 碰 S1b / S1d / T1 的任何文件
- ❌ 实现 `DeviceKeyStore`（那是 S6）
- ❌ 背压（`PeerStream` 的事，归 S3c-c）
- ❌ 切分支 / 合并 / 推送 / 改主工作区

## 11. 交付方式

- **每完成一项计划（P0…P10）就提交一次**，提交信息写清楚这一项干了什么、
  为什么这么干。别攒一个大提交。
- **每完成一项就回写纪要**：「当前状态」覆盖重写（≤12 行），
  「决定记录」只追加不删改，失败的尝试进「踩坑墓地」。
  别等会话结束才落盘 —— 你随时可能被中断。
- 计划项和验收标准的 `- [ ]` 复选框，**完成一项勾一项**。
  `aiwt check` 会拿未勾选项数当闸门。
- 遇到与纪要「决定记录」冲突的情况：**先在纪要里记下冲突和你的理由，
  然后停下来问人类**，不要自行推翻已裁定事项。
- 全部做完后跑一遍完整验收命令，把输出贴给人类。**不要自己声称"全绿"而不给证据。**

## 12. 开工第一步

```bash
cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/claude-storage-s3c-local-signaling
git branch --show-current      # 必须是 agent/claude/storage-s3c-local-signaling
cat tasks/claude-storage-s3c-local-signaling.md
```

然后执行 P0：`(cd core && flutter pub get)`、`(cd p2p && flutter pub get)`，
跑五条验收命令拿基线，记进纪要「当前状态」，提交。
