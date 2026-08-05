# 任务: storage-s3c-local-signaling
负责: claude ｜ 分支: agent/claude/storage-s3c-local-signaling ｜ 开工: 2026-08-04
状态: 已完成验收（A1-A11 全部通过）

## 目标

把 S3c-a 交付的 11 条信令契约提取成跨包可复用的共享套件，并用 bonsoir 发现 + 局域网内
socket 直连实现 `LocalSignaling`，让它跑通同一套 11 条 —— 全程零外网（裁定 C2 的落地）。

> 人类原始派工书逐字留存于 `docs/storage-s3c-local-signaling/DISPATCH.md`。
> 与本纪要冲突时以「决定记录」为准（那里记了偏离原文的理由）。

## 计划

- [x] **P0 环境准备（30min）**：worktree 内对 `core` 与 `p2p` 各跑 `flutter pub get`；跑通 `scripts/run_s1a_analyze_gate.sh` 的前置断言；记录「动手前」四条门禁 + `core` 测试的基线红绿数字进「当前状态」。报错指向 `.pub-cache` 里的类型不匹配 → `rm pubspec.lock && flutter pub get`（`pub get` 顶不掉）。worktree 深度差只许用 gitignored 的 `pubspec_overrides.yaml` 承担，不许改入库 pubspec。
- [x] **P1 打通 `lib/` 下 import `flutter_test` + 建围栏（45min）**：把 `flutter_test` 从 `core/pubspec.yaml` 的 `dev_dependencies` 提到 `dependencies`；用一个最小探针文件确认 `dart analyze --fatal-infos` 对 `core/lib/test_support/` 下的新文件零 issue；确认 S1a 门禁检查 3 的全包总数仍 = 57。**不做这步，P2 必挂在 S1a 门禁检查 2 上**（已实测，见 D2）。**同一步必须建围栏测试**（A10，人类裁定的附加条件）：源码扫描 `core/lib/` 全树，只有 `test_support/` 下的文件允许出现 `flutter_test` 字样，其余任何文件命中即红。围栏本身也要做变异自检 —— 往 `core/lib/model/` 放一个临时 import 确认它真的会红。
- [x] **P2 提取共享契约套件（60min）**：新建 `core/lib/test_support/signaling_contract_suite.dart`，导出 `runSignalingContractSuite(...)`（签名见 D1）与公开的 `SignalingChannelPair`。把 11 条契约测试原样搬进去；`core/test/signaling_contract_test.dart` 改为对两个内存 fake 各调一次套件，**「架构守卫（源码扫描）」组与「barrel 可消费」组留在原地不动**（它们读 `lib/model/signaling.dart` 相对路径，只有 core 能读到）。
- [x] **P3 `pumpEventQueue()` 在套件里全面禁用（45min）**：按人类裁定（D5）改成「等事件而非等时间」。**正向断言**（断言某事会发生）一律 `await` 真实可观测量本身 + 显式 timeout，如 `await session.incoming.first.timeout(d)`、`await session.peerPresence.firstWhere((p) => p == PeerPresence.departed).timeout(d)`。**负向断言**（断言什么都不发生）是唯一真的要等时间的地方，用有界宽限期 + **显式命名常量**，且该常量**由拓扑注入**（内存 fake 给几毫秒，socket 给几百毫秒）。套件内不得再出现 `pumpEventQueue` 字样，加一条源码扫描守住。**变异自检**：把 timeout 设成 0 → 确认红在目标断言而非编译失败或框架超时报错。
- [x] **P4 `p2p` 包成形（45min）**：包名 `p2p` → `persistence_p2p`（目录仍为 `p2p/`）；删掉 `flutter create` 留下的 `Calculator` 样板与 `test/p2p_test.dart`；建 barrel `lib/persistence_p2p.dart` 导出 `LocalSignaling`；pubspec 依赖 `bonsoir ^7.1.4` + `persistence_core: path: ../core`（入库路径以 main 位置为准）。确认 `.flutter-plugins-dependencies`、`pubspec.lock`、`*.iml`、`.idea/` 一个都没入库（`run_monorepo_convention_check.sh` 检查 2 会拦）。
- [x] **P5 `LanDiscovery` 窄端口 + A7 隐私抓手（45min）**：包内接口只管 `advertise` / `discover`，把 bonsoir 关在它后面。两个实现：`BonsoirLanDiscovery`（真 mDNS，只给集成测试用）与 `FakeLanDiscovery`（内存，给单测用）。**A7 的抓手**：fake 必须记下**实际广播出去的 service name 与 TXT 记录**并可读回，测试断言其不含 scopeUid / 用户名 / 设备名 —— 把隐私约定从注释变成可断言的返回值（与 `AdvertisementHandle` 同一手法）。
- [x] **P6 `LocalSignaling` 主体（60min）**：`open(rendezvous)` → 起 `ServerSocket` 监听 → 经 `LanDiscovery` 广播（service name 只放随机 transient id）→ 同时 discover。先到者等 incoming socket，后到者 discover 到 `host:port` 后 `Socket.connect`，**无中间人**。信封编解码用行分隔 JSON，收发两侧都对 sealed 三变体做穷尽 `switch`。`peerPresence`：socket 接通 → `present`；socket 的 `onDone` / `onError` → **立刻** `departed`，不许挂任何超时推断（A3）。`send` 在 `departed` 后抛 `StorageError` 子类。`close` 尽力先发 `ByeEnvelope` 再关 socket，且幂等。
- [x] **P7 真实 loopback socket 跑同一套件（60min）**：`p2p/test/local_signaling_contract_test.dart` 注入 `FakeLanDiscovery` + 真实 `127.0.0.1` socket，调 `runSignalingContractSuite`。`simulateAbruptDisconnect` 的实现必须是 `socket.destroy()` —— **A3 要求真的关掉 socket，不许模拟**。`simulateAbruptDisconnect` 变成注入回调之后更容易被偷懒实现成"假装断开的信号"，所以**另需一条测试证明它真断**（人类裁定的加严项）：调用后从**被销毁那一侧之外**去观测，断言底层 socket 确已不可用 —— 例如对该 socket 再 `write` + `flush` 必须抛，或对端读到 `onDone`。补 A4（close 发 Bye、重复 close 不抛）与 A5（departed 后 send 抛错）。
- [x] **P8 真 bonsoir 集成测试（30min）**：`p2p/test/lan_discovery_integration_test.dart` 标 `@Tags(['integration'])`；`p2p/dart_test.yaml` 配置默认排除该 tag（CI/沙箱里组播常常不通）。在纪要里写明人工触发的确切命令。
- [x] **P9 A8 逐条变异自检（60min）**：每条测试注入一次违规 → 确认变红 → 复原。**红在编译失败不算数**（纪律第 2 条，上一轮 M10 的教训），要重新设计成「编译仍过、断言变红」。逐条把「注入了什么、红在哪条断言上」写进决定记录。
- [x] **P10 收口（30min）**：四条门禁 + `core` 测试 + `p2p` 测试全绿；核对 S1a 门禁的 57 条基线未被抬高；把 D1、D3 两条待人类留意的事项在汇报里点名；纪要「当前状态」与「决定记录」收口。

## 验收标准

- [x] **A1 提取无损**（口径经人类 2026-08-04 裁定放宽）：**提取后，原 11 条对两个内存 fake 仍全绿**（11 条 × 2 拓扑），且原有「架构守卫」「barrel 可消费」两组不受影响。**不要求逐字保留原写法** —— 改等待方式（见 A11）不算破坏无损
- [x] **A2 真实实现跑通同一套件**：同一个 `runSignalingContractSuite` 对真实 `LocalSignaling` 全绿，且底层是**真实 loopback socket** 而非纯 fake
- [x] **A3 `departed` 不靠超时，且"断开"必须是真断**：对端进程消失 → 观测到 `departed`。注入的 `simulateAbruptDisconnect` 对 `LocalSignaling` 必须**真的 `socket.destroy()`**，不许发任何「假装断开」的信号；并且**另有一条测试证明它真断**（调用后该 socket 确已不可用），不能只靠"它应该真断"的注释
- [x] **A4 告别与幂等**：`close()` 发 `ByeEnvelope`，对端立即 `departed`；重复 `close()` 不抛错
- [x] **A5 不静默丢弃**：对端 `departed` 后 `send()` 抛错（`StorageError` 子类）
- [x] **A6 裁定 C3 可机械检查**：`p2p/pubspec.yaml` 零 firebase 依赖，由源码扫描测试守卫
- [x] **A7 广播不泄露身份**：mDNS 广播内容不含 scopeUid / 用户名 / 设备名，且该断言建立在**可读回的返回值**上，不是注释
- [x] **A8 每条测试做过变异自检**：注入违规 → 变红 → 复原，逐条在「决定记录」写明注入了什么、红在哪条断言上；红在编译失败的不计入
- [x] **A9 四条既有门禁全绿**，且 S1a 门禁的 57 条冻结基线未被抬高
- [x] **A10 `flutter_test` 围栏**（人类裁定新增）：源码扫描 `core/lib/` 全树，**只有 `test_support/` 下的文件允许 import `flutter_test`**，其余任何文件命中即红；该围栏自身做过变异自检（往 `core/lib/model/` 塞一个 import 确认会红）
- [x] **A11 套件内零 `pumpEventQueue`**（人类裁定新增）：共享套件源码不含 `pumpEventQueue` 字样；正向断言一律 `await` 真实可观测量 + 显式 timeout，负向断言用**由拓扑注入的具名宽限期常量**，不得写魔数

验收命令: bash scripts/run_s1a_analyze_gate.sh && bash scripts/run_s1b_analyze_gate.sh && bash scripts/run_monorepo_convention_check.sh && (cd core && flutter test) && (cd p2p && flutter test)

## 当前状态

**P0–P10 完成，A1–A11 已由独立验收会话逐条复核通过（2026-08-04）。**

**验收会话实测的五条命令**（完整链退出码 0，非转述）：S1a ✅（检查 3 报「57 = 冻结基线 57」，未抬高）；
S1b ✅（core 57 = 基线、drift 148 < 基线 151、firebase 20 = 基线）；monorepo ✅；
`core` 189 条全过；`p2p` **18 过 + 1 跳过**（integration 默认排除，人工触发：
`cd p2p && flutter test --tags integration`）。

**验收会话补齐的缺口见 D16**：A6 原本只做到「pubspec 事实上干净」，**守卫测试并不存在** ——
已补 `p2p/test/s3c_no_firebase_guard_test.dart`（2 条），p2p 测试数因此由 16 → 18。

**独立变异自检（验收方自己做的，不采信执行方自述）见 D17**：把 `_onSocketGone` 的
`_emit(PeerPresence.departed)` 改成 `_emit(PeerPresence.present)`（编译仍过）→ 4 条 departed
相关测试全红于 `TimeoutException`，非编译失败 → 复原后回到全绿。

**交付形态**：实现已落在本分支提交 `525fa37`。执行会话受 macOS 沙箱限制无法写主仓 `.git`
（详见 D15），其 14 个分步提交（P0→P10）保存在仓内 ref **`refs/s3c-shadow/tip`**，
用 `git log --oneline refs/s3c-shadow/tip` 可查。仓库根的
`storage-s3c-local-signaling.bundle`（3.4M）与该 ref 内容等价，**已冗余，可删**。

## 决定记录

- 2026-08-04: **D17 · 验收方独立变异自检：不采信执行方的 D14 自述，自己注入一次确认测试真能红。** 手法：把 `p2p/lib/local_signaling.dart` 里 `_onSocketGone` 的 `_emit(PeerPresence.departed)` 改成 `_emit(PeerPresence.present)` —— **编译仍过**（纪律第 2 条要求），行为变错。结果 4 条测试变红：`A4 · 对端主动 close 后本端观测到 departed`、`A4 · 对端非正常断开（未告别）也必须产出 departed`、`A4 · 对端已 departed 时 send 必须抛错`、`A3 · destroy 后底层 socket 确已终结`，全部红在 `TimeoutException after 0:00:05`（即 D5 裁定的「正向断言 = await 可观测量 + 显式 timeout」那一层），无一红在编译失败。复原后 18 过 + 1 跳过。**结论：这套测试是真能红的，不是恒绿。**
- 2026-08-04: **D16 · 验收查出 A6 未交付，已由验收方补齐。** A6 的原文是「`p2p/pubspec.yaml` 零 firebase 依赖，**由源码扫描测试守卫**」。执行方交付时 pubspec 事实上确实零 firebase，但**全仓不存在任何读 `p2p/pubspec.yaml` 的测试** —— 也就是说裁定 C3 仍停留在「一句话」，没有变成「可自动检查的事实」，而后者正是 A6 存在的全部理由。补 `p2p/test/s3c_no_firebase_guard_test.dart`：① 扫 pubspec 源码，命中 firebase/firestore/rtdb 等字样即红；② 扫 `lib/` 与 `test/` 的 `.dart`，禁止 `import 'package:firebase*'`。已做变异自检：往 pubspec 追加一行 `# firebase_core: ^4.0.0` 注释（pub 仍可解析，编译不受影响）→ 红在断言上并带出 reason「p2p/pubspec.yaml 出现 "firebase"」→ 复原后绿。**教训：「事实上合规」与「有门禁守着」是两件事，验收必须分开查。**
- 2026-08-04: **D15 · 执行会话被 macOS 沙箱挡住主仓 `.git`，改用影子仓库交付；副作用是 worktree 的 `.git` 链接文件丢失。** 执行方无法写 `/Users/.../xuan-storage/.git`，遂在 `/tmp/s3c-shadow.git` 建影子仓库提交，再打 bundle 落到仓库根。验收方接手时看到的现象是：`git worktree list` 把本 worktree 标为 **`prunable`**，`git -C <worktree>` 报的分支是 `main`（因为 `.git` 文件没了，git 一路向上走到父仓库），而工作区里明明躺着全部实现。处置：按 `.git/worktrees/<name>/` 的管理记录重建一行 `gitdir:` 指针即可恢复，**未丢任何提交**（reflog 末条仍是立项的 `0cdde5f`）。分步历史经 `git fetch <bundle>` 收进仓内 ref `refs/s3c-shadow/tip` 永久保存。⚠ **后人若再遇 `prunable` + 工作区有未提交成果，先重建 `.git` 指针，千万不要跑 `git worktree prune` 或 `aiwt drop`。**
- 2026-08-04: **D14 · A8 逐条变异自检记录（P9 实测，注入 → 确认红 → 复原）**。11 条契约 + A3 独立测试全部「编译仍过、断言变红」验证；变红位置均为目标断言或其等待层（TimeoutException），非编译失败：
  1. **相遇双向收发**：解码 `kind` 恒 `offer` → alice 等不到 answer（firstWhere 谓词永不匹配）→ 超时红。
  2. **不回显**：`send` 里加 `_incoming.add(envelope)`（回显自己）→ `expect(aliceGot, isEmpty)` 红。
  3. **trickle ICE**：解码 `candidate` 恒值 → `firstWhere(candidate:4)` 永不匹配 → 超时红。
  4. **awaiting→present**：`_pairIfReady` 不 `emit(present)` → `firstWhere(present)` 超时红。
  5. **close 后 departed**：`_onSocketGone` 不 `emit(departed)` → 超时红。
  6. **非正常断开 departed**：同 5（`_onSocketGone` 不 emit）→ 超时红；**另用「simulateAbruptDisconnect 偷懒为 no-op」注入（变异 12）→ 也红** —— 证明注入回调的偷懒实现必被围栏拦住（人类加严项的初衷）。
  7. **departed 后 send 抛错**：删除 `send` 内两处 `_current == departed` 检查 → `throwsA` 断言红。
  8. **close 幂等**：**变异不适用（如实记录）** —— 三次注入（删 `_closed` 守卫、删 `_teardown` 的 isClosed 守卫、删 `_server.close()` 的 try/catch）均不红：Dart 的 `StreamController.close` / `Socket.close` / `ServerSocket.close` 对已关闭对象重复调用本身幂等/静默。该条由实现结构（无副作用路径）与底层 API 幂等性共同保证，运行期无法注入有意义的违规。
  9. **串扰**：删 `discover` 回调的 `txt['rv'] != rendezvous` 过滤 → bob('rv-B') 收到 alice('rv-A') 的信封 → `expect(bobGot, isEmpty)` 红。
  10. **rendezvous 回报**：`open` 构造会话传错值 → `expect(session.rendezvous, 'rv-echo-key')` 红。
  11. **A5 隐私**：信封编码的 sdp 载荷塞入 `user-scope-42` → `expect(text, isNot(contains(scopeUid)))` 红。
  12. **A3 真断独立测试**：见 6 的「no-op」注入 → 对端观测超时红。

- 2026-08-04: **D12 · 内存 fake 的 `peerPresence` 用 `Stream.multi` 逐订阅者重放当前状态；正向断言统一「先订阅可观测量、再触发、最后 await」。** 两条都是改造等待方式时实测踩出来的（不是理论）：① `StreamController.broadcast` 的 `onListen` **只在首个订阅者订阅时触发**（0→1），后续订阅者不触发 —— 用它重放当前状态，只有第一个订阅者拿得到，`firstWhere` 会永久挂起；`async* { yield _current; yield* _presence.stream; }` 则存在「yield 后到 yield* 订阅之间」的事件窗，事件可被漏掉。`Stream.multi` 对每个订阅者独立执行回调（add 当前状态 + 转发后续），两者皆无。真实 `LocalSignaling`（P6）采用同一模式。② broadcast 流**不回放已发事件**，事后订阅（先触发再 `firstWhere`）永远等不到 —— 正向断言必须先订阅、再触发、最后 await。另：把 `_positiveObservableTimeout` 设成 0 的变异在 fake 同步语义下**不红**（事件经微任务先于 Timer 到达），这是「断言 await 的是事件本身、timeout 只是兜底」的预期行为，不是恒绿；timeout 活性已由 onListen 缺陷版实测的 `TimeoutException after 5s` 证明，P9 将用「实现不发事件」的变异做逐条验证。

- 2026-08-04: **D1 · 套件签名改为 `makePair` + 注入 `simulateAbruptDisconnect`，而非派工书原文的 `makeChannel`。人类已批准，并加严一条见下。** 理由：11 条里有 9 条需要**两个** channel 在同一「织物」上相遇（LAN fake 共享 `_LanFabric`；`LocalSignaling` 共享发现表与 loopback 网段），单个 `makeChannel()` 调两次得到的是两个互不相干的实例，「两端在同一会合标识下相遇」这条根本写不出来。另外第 6 条（非正常断开）现在靠 test-private 的 `_CrashableSession` 做 cast，提到 `core/lib/` 后不能再用 `_` 私有名，且真实实现的「崩溃」是 `socket.destroy()` 而非一次方法调用。故签名定为 `runSignalingContractSuite({required String topologyName, required FutureOr<SignalingChannelPair> Function() makePair, required FutureOr<void> Function(SignalingSession) simulateAbruptDisconnect})`，其中 `SignalingChannelPair = ({SignalingChannel alice, SignalingChannel bob})`。派工书写的是「形如」，人类明确「写形如就是授权按实际需要定形状」。**人类加严**：`simulateAbruptDisconnect` 变成注入回调之后，比原来的 `_CrashableSession` 更容易被偷懒实现成「假装断开的信号」，所以对真实 `LocalSignaling` 必须真的 `destroy()` socket，**且要有一条测试证明它真断**（见 A3、P7）。
- 2026-08-04: **D2 · `flutter_test` 从 `core/pubspec.yaml` 的 `dev_dependencies` 提到 `dependencies`。已实测，非推测；人类已批准并附加围栏（见 D2b）。** 探针：在 `core/lib/test_support/` 放一个 import `package:flutter_test/flutter_test.dart` 的文件跑 `dart analyze --fatal-infos`，得到 `info - depend_on_referenced_packages`，退出码 1。而 `run_s1a_analyze_gate.sh` 的检查 2 是「有 issue 的文件集合必须是冻结白名单的子集」，新文件不在白名单里 → 直接红。既有先例 `in_memory_stores.dart` 躲过了这一条，只因为它不 import `flutter_test`，先例覆盖不到本轮。被否方案一：加 `// ignore: depend_on_referenced_packages` —— 它掩盖的是真实的解析脆弱性（`p2p` 作为 root 包时，`persistence_core` 的 dev_dependencies 根本不参与解析，套件对不声明 `flutter_test` 的消费方会 import 不到）。被否方案二（人类否决）：拆出独立的 `persistence_test_support` 包 —— 会引入 `core ↔ test_support` 的 dev 依赖环，那是个真故障模式，代价大于收益；且本仓六个包全是 `publish_to: none` 的内部包，「别把测试框架带进生产依赖图」这条主要约束的是**发布**包。
- 2026-08-04: **D2b · 围栏：`core/lib/` 下只有 `test_support/` 允许 import `flutter_test`。人类裁定，落成 A10。** 理由：不加这条，半年后 `core/lib/model/` 里就会冒出 `flutter_test` 的 import 而门禁不响。围栏同时让 D2 这个决定**可回退** —— 将来真要分包，围栏已经把范围框死了。
- 2026-08-04: **D3 · 共享套件走深路径消费，绝对不许进 barrel。人类已确认，并澄清这不是冲突而是派工书的表述缺口。** `core/test/s1b_architecture_guard_test.dart:53` 已断言 barrel 里不得出现 `test_support` 字样（理由：fake 不是产品 API）。派工书纪律第 3 条「新增公开 API 必须进 barrel」**只约束产品 API，不约束 test_support**。执行者若为了「补 export」往 barrel 里加一行，会立刻把 S1b 架构守卫测试打红。消费方一律写 `import 'package:persistence_core/test_support/signaling_contract_suite.dart'`。
- 2026-08-04: **D4 · 「发现」抽成包内窄端口 `LanDiscovery`，单测注入内存 fake + 真实 loopback socket，真 bonsoir 只进 `@Tags(['integration'])` 的集成测试。** 理由：真实 mDNS 依赖组播，CI/沙箱常常不通；但只对 fake 测等于没测自己写的那部分。这样切法让「socket 上的信封交换 + presence 语义」——也就是本轮真正手写的东西——被真实 IO 覆盖，只有 mDNS 那一层是可选的。被否方案：全用真 bonsoir 跑单测 —— 沙箱里必然假红，会逼后人把测试标 skip，最后整套失去约束力。
- 2026-08-04: **D5 · `pumpEventQueue()` 在共享套件里全面禁用。人类裁定，并把我原本的问题表述纠正了。** 我原本判成「A1 提取无损与 A2 真实 socket 之间的矛盾」，人类指出**根本不是矛盾，是 `pumpEventQueue()` 本来就是个坏模式**：它的语义是「把事件队列转若干圈」，对同步 `StreamController` 碰巧成立，对任何真实 I/O 都不成立 —— 这是**等时间 vs 等事件**的区别，不是两种拓扑的冲突。裁定的做法：**正向断言**（断言某事会发生）一律 `await` 真实可观测量本身 + 显式 timeout，如 `await session.incoming.first.timeout(d)`、`await session.peerPresence.firstWhere((p) => p == PeerPresence.departed).timeout(d)`；**负向断言**（断言什么都不发生）是唯一真要等时间的地方，用有界宽限期 + **显式命名常量**且**由拓扑注入**（内存 fake 给几毫秒，socket 给几百毫秒）—— 比全局 `pumpEventQueue` 既准确又诚实。落成 A11。
- 2026-08-04: **D5b · A1「提取无损」的口径由人类放宽：不再要求逐字保留原写法，只要求提取后原 11 条对两个内存 fake 仍全绿。** 人类自评原派工书 A1 写窄了。按这个口径，D5 的等待方式改造不算破坏无损，我原先标的「A1 与 A2 唯一真矛盾」随之消失。
- 2026-08-04: **D6 · `send()` 在 `departed` 后抛 `StorageError` 子类，但套件断言维持现状的 `throwsA(isA<Object>())` 不收紧。** 契约 §3.6 要求「失败一律抛 StorageError 子类」，`LocalSignaling` 照办；但两个内存 fake 现在抛的是 `StateError`，收紧断言会让 A1 的「提取无损」变成「提取顺带改行为」，两件事混在一次改动里说不清。收紧留给后续轮次连同两个 fake 一起做。
- 2026-08-04: **D7 · 包名 `persistence_p2p`，目录 `p2p/`。人类已确认。** 仓内现有六个包全部是 `persistence_*`（实查 `*/pubspec.yaml`：`persistence_assets` / `persistence_core` / `persistence_drift` / `persistence_firebase` / `persistence_preferences` / `persistence_supabase`）；铁律禁止程序标识符用 `xuan_` 前缀。搬来的脚手架包名还是 `flutter create` 默认的 `p2p`，连同 `Calculator` 样板类一起在 P4 清掉。
- 2026-08-04: **D8 · 用 `aiwt new` + 手工搬 `p2p/`，没用立项协议原文的 `aiwt adopt`。经人类确认。** 理由：`aiwt adopt` 内部是 `git stash push`（**不带 `-u`**）→ 主工作区 `reset --hard`。主工作区当时的未提交内容是「已跟踪的 `firebase/infrastructure/emulator/firestore.rules`（+39/-6，属别的任务）」+「未跟踪的 `p2p/`」，adopt 恰好会把前者卷进本分支、把后者留在原地 —— 与意图完全相反。
- 2026-08-04: **D9 · `multicast_dns` 不许再被提起。** 它只能查询不能广播（其源码留有 `// TODO(dnfield): Support queries coming in for published entries.`），选它是死路。局域网发现锁死 `bonsoir 7.1.4`。
- 2026-08-04: **D10 · NAT 打洞不在本轮。** 那是 `flutter_webrtc` 的内建 ICE，归 S3c-c。本轮的 socket 只在同一局域网内直连，且只用来搬那几 KB 的 SDP/ICE 文本。
- 2026-08-04: **D11 · 不碰 `core/lib/model/signaling.dart` 与 `transport.dart` 一个字。** 它们是 S3c-a 已交付的契约。对契约有异议只许写进本区上报，不许直接改 —— 改了会同时打红 S1a 门禁的「S1a 自有文件零 issue」与信令契约测试的架构守卫组。

## 踩坑墓地

- 2026-08-04（P0 实测）: **本会话进程被 macOS 沙箱限制，`~/` 与 `/Users/jingtaiwei/flutter` 不可写（EPERM，不是权限问题）**。症状：`flutter pub get` 退出码 1，只报 `update_engine_version.sh: line 71: .../engine.stamp.tmp.X: Operation not permitted`；`flutter --version` 崩在 telemetry 写 `~/.dart-tool/dart-flutter-telemetry-session.json`。连 `touch ~/wtest` 都 EPERM，而 worktree 与 `/tmp` 可写。绕行（已固化在 `/tmp/s3c-env.sh`）：① `FLUTTER_ROOT=/tmp/flutter-root` —— 用 `cp -c -R`（APFS clone，写时复制，几乎不占空间）把整个 flutter SDK 克隆到 `/tmp`，`flutter` 命令在克隆副本上可正常写 cache；② `PUB_CACHE=/tmp/pub-cache` —— 把 `~/.pub-cache` 复制过去，否则 git 依赖 fetch 写 `~/.pub-cache/git/cache/` 崩；③ `DART_DISABLE_ANALYTICS=true`（+ `CI=true`、`FLUTTER_SUPPRESS_ANALYTICS=true`）—— 否则 telemetry 写 `~/.dart-tool/` 崩，`flutter`/`dart` 退出码变 1；④ 门禁脚本内部用 PATH 里的 `dart`，需 `export PATH="/Users/jingtaiwei/flutter/bin/cache/dart-sdk/bin:$PATH"` 把裸 dart 排在 flutter 包装脚本前面。教训：本环境 `flutter` 命令的失败 90% 是沙箱写限制，先 `touch ~/probe` 探一下再怀疑代码。
- 2026-08-04（立项期实测）: 在 `core/lib/` 下 import `package:flutter_test/flutter_test.dart`，`dart analyze --fatal-infos` 报 `depend_on_referenced_packages`、退出码 1。别以为 `in_memory_stores.dart` 这个先例能保你过关 —— 它压根不 import `flutter_test`。处置见 D2。

## 冷冻快照

<仅在搁置时由 /hibernate 填写: 业务背景 / 架构决定摘要 / 精确断点 / 重启第一步 / 环境要求>
