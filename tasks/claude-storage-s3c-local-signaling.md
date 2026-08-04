# 任务: storage-s3c-local-signaling
负责: claude ｜ 分支: agent/claude/storage-s3c-local-signaling ｜ 开工: 2026-08-04
状态: 蓝图

## 目标

把 S3c-a 交付的 11 条信令契约提取成跨包可复用的共享套件，并用 bonsoir 发现 + 局域网内
socket 直连实现 `LocalSignaling`，让它跑通同一套 11 条 —— 全程零外网（裁定 C2 的落地）。

> 人类原始派工书逐字留存于 `docs/storage-s3c-local-signaling/DISPATCH.md`。
> 与本纪要冲突时以「决定记录」为准（那里记了偏离原文的理由）。

## 计划

- [ ] **P0 环境准备（30min）**：worktree 内对 `core` 与 `p2p` 各跑 `flutter pub get`；跑通 `scripts/run_s1a_analyze_gate.sh` 的前置断言；记录「动手前」四条门禁 + `core` 测试的基线红绿数字进「当前状态」。报错指向 `.pub-cache` 里的类型不匹配 → `rm pubspec.lock && flutter pub get`（`pub get` 顶不掉）。worktree 深度差只许用 gitignored 的 `pubspec_overrides.yaml` 承担，不许改入库 pubspec。
- [ ] **P1 打通 `lib/` 下 import `flutter_test`（30min）**：把 `flutter_test` 从 `core/pubspec.yaml` 的 `dev_dependencies` 提到 `dependencies`；用一个最小探针文件确认 `dart analyze --fatal-infos` 对 `core/lib/test_support/` 下的新文件零 issue；确认 S1a 门禁检查 3 的全包总数仍 = 57。**不做这步，P2 必挂在 S1a 门禁检查 2 上**（已实测，见决定记录 D2）。
- [ ] **P2 提取共享契约套件（60min）**：新建 `core/lib/test_support/signaling_contract_suite.dart`，导出 `runSignalingContractSuite(...)`（签名见 D1）与公开的 `SignalingChannelPair`。把 11 条契约测试原样搬进去；`core/test/signaling_contract_test.dart` 改为对两个内存 fake 各调一次套件，**「架构守卫（源码扫描）」组与「barrel 可消费」组留在原地不动**（它们读 `lib/model/signaling.dart` 相对路径，只有 core 能读到）。
- [ ] **P3 等待原语改造 —— A1 与 A2 的真正矛盾点（45min）**：现有 11 条全部靠 `await pumpEventQueue()` 等待传播，这对内存 fake（同步 `StreamController`）成立，对**真实 loopback socket 不成立**（字节要过内核，往返需要真实 IO 轮次）。改成套件内的有上限轮询等待，超时即让目标断言变红。**这一步必须先做变异自检**：把上限设成 0 → 确认红在目标断言而非编译失败或超时框架报错。
- [ ] **P4 `p2p` 包成形（45min）**：包名 `p2p` → `persistence_p2p`（目录仍为 `p2p/`）；删掉 `flutter create` 留下的 `Calculator` 样板与 `test/p2p_test.dart`；建 barrel `lib/persistence_p2p.dart` 导出 `LocalSignaling`；pubspec 依赖 `bonsoir ^7.1.4` + `persistence_core: path: ../core`（入库路径以 main 位置为准）。确认 `.flutter-plugins-dependencies`、`pubspec.lock`、`*.iml`、`.idea/` 一个都没入库（`run_monorepo_convention_check.sh` 检查 2 会拦）。
- [ ] **P5 `LanDiscovery` 窄端口 + A7 隐私抓手（45min）**：包内接口只管 `advertise` / `discover`，把 bonsoir 关在它后面。两个实现：`BonsoirLanDiscovery`（真 mDNS，只给集成测试用）与 `FakeLanDiscovery`（内存，给单测用）。**A7 的抓手**：fake 必须记下**实际广播出去的 service name 与 TXT 记录**并可读回，测试断言其不含 scopeUid / 用户名 / 设备名 —— 把隐私约定从注释变成可断言的返回值（与 `AdvertisementHandle` 同一手法）。
- [ ] **P6 `LocalSignaling` 主体（60min）**：`open(rendezvous)` → 起 `ServerSocket` 监听 → 经 `LanDiscovery` 广播（service name 只放随机 transient id）→ 同时 discover。先到者等 incoming socket，后到者 discover 到 `host:port` 后 `Socket.connect`，**无中间人**。信封编解码用行分隔 JSON，收发两侧都对 sealed 三变体做穷尽 `switch`。`peerPresence`：socket 接通 → `present`；socket 的 `onDone` / `onError` → **立刻** `departed`，不许挂任何超时推断（A3）。`send` 在 `departed` 后抛 `StorageError` 子类。`close` 尽力先发 `ByeEnvelope` 再关 socket，且幂等。
- [ ] **P7 真实 loopback socket 跑同一套件（60min）**：`p2p/test/local_signaling_contract_test.dart` 注入 `FakeLanDiscovery` + 真实 `127.0.0.1` socket，调 `runSignalingContractSuite`。`simulateAbruptDisconnect` 的实现必须是 `socket.destroy()` —— **A3 要求真的关掉 socket，不许模拟**。补 A4（close 发 Bye、重复 close 不抛）与 A5（departed 后 send 抛错）。
- [ ] **P8 真 bonsoir 集成测试（30min）**：`p2p/test/lan_discovery_integration_test.dart` 标 `@Tags(['integration'])`；`p2p/dart_test.yaml` 配置默认排除该 tag（CI/沙箱里组播常常不通）。在纪要里写明人工触发的确切命令。
- [ ] **P9 A8 逐条变异自检（60min）**：每条测试注入一次违规 → 确认变红 → 复原。**红在编译失败不算数**（纪律第 2 条，上一轮 M10 的教训），要重新设计成「编译仍过、断言变红」。逐条把「注入了什么、红在哪条断言上」写进决定记录。
- [ ] **P10 收口（30min）**：四条门禁 + `core` 测试 + `p2p` 测试全绿；核对 S1a 门禁的 57 条基线未被抬高；把 D1、D3 两条待人类留意的事项在汇报里点名；纪要「当前状态」与「决定记录」收口。

## 验收标准

- [ ] **A1 提取无损**：共享契约套件提取后，`core/test/signaling_contract_test.dart` 对两个内存 fake 仍 **11 条 × 2 拓扑全绿**，且原有「架构守卫」「barrel 可消费」两组不受影响
- [ ] **A2 真实实现跑通同一套件**：同一个 `runSignalingContractSuite` 对真实 `LocalSignaling` 全绿，且底层是**真实 loopback socket** 而非纯 fake
- [ ] **A3 `departed` 不靠超时**：对端进程消失 → 观测到 `departed`。测试必须**真的 `socket.destroy()`**，不许调用任何「模拟断开」的方法
- [ ] **A4 告别与幂等**：`close()` 发 `ByeEnvelope`，对端立即 `departed`；重复 `close()` 不抛错
- [ ] **A5 不静默丢弃**：对端 `departed` 后 `send()` 抛错（`StorageError` 子类）
- [ ] **A6 裁定 C3 可机械检查**：`p2p/pubspec.yaml` 零 firebase 依赖，由源码扫描测试守卫
- [ ] **A7 广播不泄露身份**：mDNS 广播内容不含 scopeUid / 用户名 / 设备名，且该断言建立在**可读回的返回值**上，不是注释
- [ ] **A8 每条测试做过变异自检**：注入违规 → 变红 → 复原，逐条在「决定记录」写明注入了什么、红在哪条断言上；红在编译失败的不计入
- [ ] **A9 四条既有门禁全绿**，且 S1a 门禁的 57 条冻结基线未被抬高

验收命令: bash scripts/run_s1a_analyze_gate.sh && bash scripts/run_s1b_analyze_gate.sh && bash scripts/run_monorepo_convention_check.sh && (cd core && flutter test) && (cd p2p && flutter test)

## 当前状态

蓝图已立，尚未开工。等人类说「开工」。

已就位：`p2p/` 脚手架已从主工作区搬入本 worktree（`flutter create` 产物，包名还是 `p2p`，
带一个 `Calculator` 样板和一份只有壳子的 `local_signaling.dart`），生成物
（`build/`、`.dart_tool/`、`.idea/`、`*.iml`、`pubspec.lock`、`.flutter-plugins-dependencies`）
已就地删除，主工作区已无 `p2p/`。

下一步：P0 环境准备。

## 决定记录

- 2026-08-04: **D1 · 套件签名改为 `makePair` + 注入 `simulateAbruptDisconnect`，而非派工书原文的 `makeChannel`。⚠ 偏离派工书原文，提请人类留意。** 理由：11 条里有 9 条需要**两个** channel 在同一「织物」上相遇（LAN fake 共享 `_LanFabric`；`LocalSignaling` 共享发现表与 loopback 网段），单个 `makeChannel()` 调两次得到的是两个互不相干的实例，「两端在同一会合标识下相遇」这条根本写不出来。另外第 6 条（非正常断开）现在靠 test-private 的 `_CrashableSession` 做 cast，提到 `core/lib/` 后不能再用 `_` 私有名，且真实实现的「崩溃」是 `socket.destroy()` 而非一次方法调用。故签名定为 `runSignalingContractSuite({required String topologyName, required FutureOr<SignalingChannelPair> Function() makePair, required FutureOr<void> Function(SignalingSession) simulateAbruptDisconnect})`，其中 `SignalingChannelPair = ({SignalingChannel alice, SignalingChannel bob})`。派工书写的是「形如」，本条按其字面授权落地。
- 2026-08-04: **D2 · `flutter_test` 必须从 `core/pubspec.yaml` 的 `dev_dependencies` 提到 `dependencies`。已实测，非推测。** 探针：在 `core/lib/test_support/` 放一个 import `package:flutter_test/flutter_test.dart` 的文件跑 `dart analyze --fatal-infos`，得到 `info - depend_on_referenced_packages`，退出码 1。而 `run_s1a_analyze_gate.sh` 的检查 2 是「有 issue 的文件集合必须是冻结白名单的子集」，新文件不在白名单里 → 直接红。既有先例 `in_memory_stores.dart` 躲过了这一条，只因为它不 import `flutter_test`，先例覆盖不到本轮。被否方案：加 `// ignore: depend_on_referenced_packages` —— 它掩盖的是真实的解析脆弱性（`p2p` 作为 root 包时，`persistence_core` 的 dev_dependencies 根本不参与解析，套件对不声明 `flutter_test` 的消费方会 import 不到）。
- 2026-08-04: **D3 · 共享套件走深路径消费，绝对不许进 barrel。⚠ 与本仓纪律第 3 条表面冲突，故写死在此。** `core/test/s1b_architecture_guard_test.dart:53` 已断言 barrel 里不得出现 `test_support` 字样（理由：fake 不是产品 API）。纪律第 3 条「新增公开 API 必须进 barrel」针对的是**契约**，不是测试支撑物。执行者若为了「补 export」往 barrel 里加一行，会立刻把 S1b 架构守卫测试打红。消费方一律写 `import 'package:persistence_core/test_support/signaling_contract_suite.dart'`。
- 2026-08-04: **D4 · 「发现」抽成包内窄端口 `LanDiscovery`，单测注入内存 fake + 真实 loopback socket，真 bonsoir 只进 `@Tags(['integration'])` 的集成测试。** 理由：真实 mDNS 依赖组播，CI/沙箱常常不通；但只对 fake 测等于没测自己写的那部分。这样切法让「socket 上的信封交换 + presence 语义」——也就是本轮真正手写的东西——被真实 IO 覆盖，只有 mDNS 那一层是可选的。被否方案：全用真 bonsoir 跑单测 —— 沙箱里必然假红，会逼后人把测试标 skip，最后整套失去约束力。
- 2026-08-04: **D5 · `pumpEventQueue()` 必须换成有上限的轮询等待。** 现有 11 条全靠它等传播，对内存 fake 成立（同步 `StreamController`），对真实 socket 不成立（字节要过内核）。这是 A1「提取无损」与 A2「真实 socket 全绿」之间唯一的真矛盾，也是最容易翻车处。改造后必须做变异自检确认超时真的能让**目标断言**变红 —— 否则就是纪律第 1 条点名的「恒绿断言」。
- 2026-08-04: **D6 · `send()` 在 `departed` 后抛 `StorageError` 子类，但套件断言维持现状的 `throwsA(isA<Object>())` 不收紧。** 契约 §3.6 要求「失败一律抛 StorageError 子类」，`LocalSignaling` 照办；但两个内存 fake 现在抛的是 `StateError`，收紧断言会让 A1 的「提取无损」变成「提取顺带改行为」，两件事混在一次改动里说不清。收紧留给后续轮次连同两个 fake 一起做。
- 2026-08-04: **D7 · 包名 `persistence_p2p`，目录 `p2p/`。** 与 `persistence_core` / `persistence_drift` / `persistence_firebase` / `persistence_assets` 一致；铁律禁止程序标识符用 `xuan_` 前缀。主工作区搬来的脚手架包名是 `flutter create` 默认的 `p2p`，P4 要改。
- 2026-08-04: **D8 · 用 `aiwt new` + 手工搬 `p2p/`，没用立项协议原文的 `aiwt adopt`。经人类确认。** 理由：`aiwt adopt` 内部是 `git stash push`（**不带 `-u`**）→ 主工作区 `reset --hard`。主工作区当时的未提交内容是「已跟踪的 `firebase/infrastructure/emulator/firestore.rules`（+39/-6，属别的任务）」+「未跟踪的 `p2p/`」，adopt 恰好会把前者卷进本分支、把后者留在原地 —— 与意图完全相反。
- 2026-08-04: **D9 · `multicast_dns` 不许再被提起。** 它只能查询不能广播（其源码留有 `// TODO(dnfield): Support queries coming in for published entries.`），选它是死路。局域网发现锁死 `bonsoir 7.1.4`。
- 2026-08-04: **D10 · NAT 打洞不在本轮。** 那是 `flutter_webrtc` 的内建 ICE，归 S3c-c。本轮的 socket 只在同一局域网内直连，且只用来搬那几 KB 的 SDP/ICE 文本。
- 2026-08-04: **D11 · 不碰 `core/lib/model/signaling.dart` 与 `transport.dart` 一个字。** 它们是 S3c-a 已交付的契约。对契约有异议只许写进本区上报，不许直接改 —— 改了会同时打红 S1a 门禁的「S1a 自有文件零 issue」与信令契约测试的架构守卫组。

## 踩坑墓地

- 2026-08-04（立项期实测）: 在 `core/lib/` 下 import `package:flutter_test/flutter_test.dart`，`dart analyze --fatal-infos` 报 `depend_on_referenced_packages`、退出码 1。别以为 `in_memory_stores.dart` 这个先例能保你过关 —— 它压根不 import `flutter_test`。处置见 D2。

## 冷冻快照

<仅在搁置时由 /hibernate 填写: 业务背景 / 架构决定摘要 / 精确断点 / 重启第一步 / 环境要求>
