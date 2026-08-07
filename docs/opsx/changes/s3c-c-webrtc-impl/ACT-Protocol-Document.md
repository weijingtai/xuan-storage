# S3c-c WebRTC Transport 真实现 · 细化 ACT 协议文档（供审核）

> 协调方框架计划：`~/Downloads/storage_refactor/PLAN-S3c-c-WEBRTC-IMPL.md`（2026-08-07）
> 本文件性质：执行 AI 按框架计划 §四/§五 细化的 ACT 协议文档 —— 逐步门禁 + 变异自检 + 停止条件
> 基线：`main c28de62` ｜ 工作分支：`feat/s3c-c-webrtc-impl` ｜ 日期：2026-08-07
> 状态：**草案待审核**（其他 AI agents 审核通过后才进入实现）

## 〇、一句话

在 `feat/s3c-c-webrtc-impl` 分支上实现 `WebRtcTransport implements Transport`（落 `p2p/lib/`），
经信令协商 + DTLS 加密建立**已认证**的 `PeerSession`；**先派 DTLS 指纹探路子任务**（最大未知数），
再按步骤 1→2→3→4 实现；步骤 3 在真 WebRTC 握手内调用 `enforceChannelBindingMatches`，
使 S6 的 MITM 防护真正生效；不交出未认证的 PeerSession、不动契约、不动 main。

## 一、输入文档清单（§三 全部已读完，要点已核录）

| # | 文档 | 关键要点（核录） |
|---|---|---|
| 1 | 本框架计划 | 四步实施 + 探路先行 + 禁止动作 + 输出契约（见 §二~§十） |
| 2 | 裁定丙原文 `~/Downloads/storage_refactor/HANDOFF-COORDINATOR-2026-08-05.md` §四裁定一 | 三条硬事实：① `connect` 必填 `DeviceKeyStore keys` ② channel binding 写在 `connect` dartdoc（握手必须完成认证密钥交换并绑定指纹）③ `PeerSession` = 已认证连接上的多路复用会话。乙（dev-only A 层）违反契约被否决；S6 需第四次 S1a 契约变更暴露 DTLS 指纹口子（即本任务探路的来源）；附带 P2：设计稿 :793 仍写 `DeviceKeyPair localKeys`（过时，勿照抄） |
| 3 | `core/lib/model/transport.dart` | `Transport`/`PeerSession`/`PeerStream`/`ChannelBinding`/`DeviceKeyStore` 全部接口签名，见 §三.1 |
| 4 | `p2p/lib/device_pairing.dart:451-464` | `enforceChannelBindingMatches({peerDeclaredCertificateFingerprint, observedPeerCertificateFingerprint})`，不等抛 `PairingBindingMismatchError`；**目前全仓零生产调用点** |
| 5 | 裁定二 Q3 v2（同上 HANDOFF §四裁定二 Q3） | 三条钉死：签**本端自己证书的指纹**、验证侧拿声明比自己这一腿观测、删 `algorithm` 字段（算法名内联进字符串）；配对与 channel binding 分开（配对跑信令层、先于传输握手；强制绑定在 `connect` 内部） |
| 6 | `core/lib/model/ice_server.dart:96` | `IceServerProvider.iceServers()` 返回 `Future<List<IceServer>>`；凭证异步获取 + `expiresAt` 时效性（preflight P3 交付） |
| 7 | `core/lib/test_support/fake_transport.dart` + `peer_stream_contract_suite.dart` | A 层样板：`runPeerStreamContractSuite(topologyName, makeSession)`；`FakeDeviceKeyStore` 可复用 |
| 8 | `core/lib/model/signaling.dart` + `p2p/lib/local_signaling.dart` | `SignalingChannel.open(rendezvous)` → `SignalingSession`（信封：`SessionDescriptionEnvelope`/`IceCandidateEnvelope`/`ByeEnvelope`）；`LocalSignaling` 已落地（S3c-b，ServerSocket + bonsoir） |
| 9 | `docs/superpowers/specs/2026-08-03-s3b-s3c-s6-boundary-handoff.md` | 字段数据与二进制**共用一条 WebRTC 连接**（`StreamKind` 区分流）；channel binding 只做一次；不用裸 WebSocket 传字段数据；DataChannel 16KB 安全线 / 256KB 绝对上限 |
| 10 | `docs/superpowers/specs/2026-08-05-s3c-c-preflight-turn-selection.md` | 首选 Cloudflare Calls（免费层 1000GB/月），备选 Twilio；凭证短期 24h；**本轮只接端口不部署** |
| 11 | `docs/dispatch/2026-08-05-s3c-c-preflight-platform-config-report.md` | **本仓零命中**：AndroidManifest / Info.plist / entitlements 全在消费方 `xuan-qizhengsiyu`；只报告不跨仓改 |
| 12 | `docs/opsx/changes/s3c-c-preflight/ACT-Protocol-Document.md` + `HANDOFF.md` | P0–P7 完成；**P8 收口未完成**（tasks 纪要当前状态、四条门禁、四包测试、S1a 57 冻结基线核对、dartdoc 下限 155→实测 165 需抬高） |
| 13 | `docs/superpowers/specs/2026-07-31-storage-architecture-design.md` §3.5 (:730) | `Transport` 在下，`SyncPeer`/`BlobGateway` 是它之上的两个协议消费者，由 `PeerSession` 持有连接做多路复用 |

## 二、背景与边界

### 2.1 这是什么

`xuan-storage` 的 P2P 传输层 B 层实现。A 层（`FakeTransport` 内存/loopback + `PeerStream` 背压契约
+ `IceServerProvider` 端口 + TURN 选型）已在 preflight 交付。本任务做真 WebRTC Transport。

### 2.2 裁定丙约束（不可违反）

1. `connect()` 必填 `DeviceKeyStore keys`（S6 交付物，已落地）
2. channel binding 写在 `connect` 的 dartdoc 里 —— 握手必须完成认证密钥交换并绑定指纹
3. `PeerSession` 定义是「一条**已认证**连接上的多路复用会话」

**结论：任何不接 channel binding 的实现都违反契约；不准交出未认证的 PeerSession。**

### 2.3 明确排除（不在本任务范围）

- ❌ 不改 `Transport`/`PeerSession`/`PeerStream`/`ChannelBinding` 契约（S1a 已冻死，S6 已加 `ChannelBinding` 值类）
- ❌ 不改 `enforceChannelBindingMatches` 的实现（只调用）
- ❌ 不改 `repository-interface-*` 任何接口
- ❌ 不做 TURN 服务部署/签约（需人类，仅步骤 4 前置）
- ❌ 不碰 S2 / S5b / 其他模块
- ❌ 不跨仓改平台配置文件（`xuan-qizhengsiyu` 仓，见 §三.4）

## 三、关键事实核录（读码/读文档后钉死的事实，实现时以此为准）

### 3.1 Transport 契约现状（`core/lib/model/transport.dart`）

- `abstract interface class Transport`：`channel` / `discover({Duration? timeout})` /
  `connect(DiscoveredPeer peer, {required DeviceKeyStore keys, CancellationToken? cancel})` /
  `advertise({required DeviceKeyStore keys, CancellationToken? cancel})` / `stopAdvertising()` /
  `incoming`（`Stream<PeerSession>`，**只投递已认证会话**）/ `dispose()`
- `abstract interface class PeerSession`：`remote`（`PeerIdentity`，握手认证后绑定）/
  `channelBinding`（`ChannelBinding`，**展示/审计口**，强制绑定在握手内部）/ `state` /
  `openStream(StreamKind kind)` / `incomingStreams` / `close()`
- `final class ChannelBinding`：**单字段** `localCertificateFingerprint`，SDP `a=fingerprint`
  格式 `'sha-256 AA:BB:...'`，算法名内联（Q3 v2 已删 algorithm 字段）
- `abstract interface class PeerStream`：`incoming` / `maxBufferedAmount` / `bufferedAmount` /
  `overflowPolicy`（`OverflowPolicy.wait|fail`，生命周期内不得改变）/ `send(List<int>)` / `close()`
- `abstract interface class DeviceKeyStore`：`localIdentity` / `sign(payload)` / `verify({payload, signature, peerPublicKeyPem})`；
  **私钥永不出现**（`transport_contract_test.dart` 有源码扫描守卫 `privateKey`/`DeviceKeyPair` 违禁）
- `StreamKind`：`oplog` / `blobChunk` / `reconciliation`（三值已冻结，测试断言 hasLength(3)）

### 3.2 S6 已交付物（本任务只调用不修改）

- `p2p/lib/device_pairing.dart:451-464`：`enforceChannelBindingMatches` —— 声明指纹 vs 观测指纹，
  不等抛 `PairingBindingMismatchError`（message/reason/suggestion 四段齐备）
- `PairingResult.peerDeclaredCertificateFingerprint`：配对验签通过后产出的**对端声明**证书指纹
  （Q3 v2：签本端自己证书的指纹；验证侧拿声明比自己这一腿观测）
- `DevicePairingProtocol` / `PairingChannel` / `PairingEnvelope`（`core/lib/model/pairing.dart`）：
  配对跑信令层、先于传输握手；签名对象 `nonce ‖ localCertificateFingerprint ‖ localPublicKeyFingerprint ‖ peerPublicKeyFingerprint`
- `PersistentDeviceKeyStore`（`p2p/lib/device_key_store.dart`）：同时满足 `DeviceKeyStore` 与 `PairingIdentityProvider`

### 3.3 A7 守卫 ——「全仓零 Transport 实现」（P1 遗留，必须先处理）

`core/test/transport_contract_test.dart:198-243`（group「A7 · 全仓仍零 Transport 实现」）：

- 遍历仓库根下**所有包的 `lib/`**（跳过 `test_support/`），正则 `implements\s+Transport\b` 扫描，
  断言 `hits` 为空
- **影响**：`WebRtcTransport` 落在 `p2p/lib/` 会**必然命中该守卫 → 测试红**。
  框架计划 §步骤1 已指出：这是 preflight 遗留 P1，「开工前先核实守卫预期行为，若需收窄先改守卫」
- **处置（本 ACT 定稿）**：A7 守卫的语义是「本轮零实现、只允许 test_support 下的 test-only fake」。
  本任务交付**第一个生产实现**，守卫必须**收窄**为「只允许白名单内的生产实现 + test_support」：
  - 方案：把扫描改为**白名单排除** `p2p/lib/web_rtc_transport.dart`（以及后续真实现文件），
    其余包 `lib/` 仍零实现
  - 守卫语义从「零实现」变为「唯一生产实现 + 其余零实现」，这**不是加豁免**，是守卫随交付演进
  - ⚠ 改动的是**测试文件**（`core/test/transport_contract_test.dart`），不是契约；需在验收报告里
    单独写明「改了什么、为什么、变异自检证据」

### 3.4 平台配置（只报告不跨仓改）

- 本仓**零命中** `AndroidManifest.xml` / `Info.plist` / `*.entitlements`，全在 `xuan-qizhengsiyu`
- Android 缺 `ACCESS_NETWORK_STATE` / `ACCESS_WIFI_STATE` / `CHANGE_WIFI_MULTICAST_STATE`
- iOS 缺 `NSLocalNetworkUsageDescription` / `NSBonjourServices` / ATS `NSAllowsLocalNetworking`
- macOS `example/macos/Runner/Release.entitlements` 缺 `com.apple.security.network.server`
- **本任务只在上报文档复述此缺口，不跨仓改**；步骤 1-3 的测试若被平台权限挡住，属预期，走停止条件报告

### 3.5 TURN 选型与 IceServerProvider

- 选型结论：首选 Cloudflare Calls（免费层覆盖典型场景），备选 Twilio；凭证短期（24h 级）
- `IceServerProvider.iceServers()` → `Future<List<IceServer>>`；`IceServer` 含 `urls`/`username`/
  `credential`（`Future<String> Function()`）/`expiresAt`；`isValidCredentialExpiry` 是运行期守卫
- 步骤 4 前**无 TURN 服务可配**：局域网（步骤 1-3）不需要 TURN，步骤 4 可延后

### 3.6 信令层现状

- `SignalingChannel.open(rendezvous, {cancel})` → `SignalingSession`（**不阻塞等待对端**，
  经 `peerPresence` 观测 `awaiting/present/departed`）；信封封闭类型三种变体
- `LocalSignaling`（`p2p/lib/local_signaling.dart`，S3c-b 已交付）：ServerSocket(loopbackIPv4:0) +
  bonsoir 广播（TXT 含 rendezvous）+ 连接方向仲裁（transient id 大者主动 connect）
- 云端实现 `rtdb_rendezvous_backend.dart`（S3c-d，firebase 包）—— 本任务在 `p2p` 包实现，
  **p2p 不得依赖 firebase**（`p2p/test/s3c_no_firebase_guard_test.dart` 源码扫描守卫）：
  WebRTC Transport 只依赖 `SignalingChannel` 端口，不 import firebase 包

### 3.7 A 层样板与契约套件

- `runPeerStreamContractSuite({topologyName, makeSession})`（`core/lib/test_support/`）：
  背压契约 A5（pause 传导）/ A6（多流隔离）/ R4（策略不变）/ R5（并发有界）等
- `runSignalingContractSuite({topologyName, makePair, simulateAbruptDisconnect, negativeAssertionGrace})`：
  11 条契约，正断言 await 真实可观测量 + 显式 timeout，负断言有界宽限期（按拓扑注入）
- `FakeDeviceKeyStore`（`fake_transport.dart`）：`sign` 追加 0xFF、`verify` 恒 true ——
  步骤 1-2 测试可用；步骤 3 的 MITM 测试需要能**控制声明指纹**的 fake（见 §五.步骤3）

## 四、前置任务（先做这两件，再写实现代码）

### 4.1 前置①：DTLS 指纹探路子任务（最大未知数，步骤 3 成败关键）

**依据**：框架计划 §五。S6 验收时确认「需要第四次 S1a 契约变更暴露 DTLS 指纹口子」，
但 flutter_webrtc 是否暴露**观测指纹** API（DTLS 握手完成后的对端证书指纹，非 SDP 声明值）
是未知数 —— 取不到 ③ 则步骤 3 阻断，必须上报人类。

**任务卡（派独立子任务执行，本任务只探路不实现 Transport、不动契约）**：

| 项 | 内容 |
|---|---|
| 目标 | 在 `p2p` 包加 `flutter_webrtc` 依赖（**最新稳定版，开工前实跑核实，禁照抄 1.5.2**），写最简 spike：建两条 `RTCPeerConnection`，完成 offer/answer，确认能从 API 取到 ① 本端 DTLS 证书指纹（SDP `a=fingerprint`）② 对端声明的指纹 ③ **DTLS 握手完成后观测到的对端证书指纹** |
| 探路内容 | API 签名 + 取值时机（SDP 阶段 vs 握手完成阶段）+ 是否需要 platform channel + 版本号与平台支持（Web/Android/iOS/macOS factory 差异，见边界 handoff §174） |
| 产出 | `docs/opsx/changes/s3c-c-webrtc-impl/DTLS-FINGERPRINT-SPIKE.md`（API 签名 + 取值时机 + 结论） |
| 门禁 | ③ 可得 → 记录 API 与时机，继续步骤 3；③ 不可得 → **停，上报人类**（可能方案：flutter_webrtc 上游 PR / 换 dart_webrtc / 降级只验 SDP 声明指纹但承认防不住 MITM） |
| 禁止 | 改契约、改 `enforceChannelBindingMatches`、提交到 main、顺手实现 Transport |

### 4.2 前置②：本 ACT 协议文档（即本文，已落盘待审核）

框架计划 §十输出契约 1：细化 ACT 文档落盘 `docs/opsx/changes/s3c-c-webrtc-impl/ACT-Protocol-Document.md`
+ `HANDOFF.md`（逐步门禁 + 变异自检 + 停止条件）。本文即前置② 的交付物，审核通过后开工。

## 五、实施步骤（细化框架计划 §四，每步含门禁 + 变异自检 + 停止条件）

### 步骤 1 · 依赖与连通骨架（让 WebRTC 能握手）

**目标**：`flutter_webrtc` 重锁（实跑核实最新稳定版）+ 最简 `WebRtcTransport` 能经
`RTCPeerConnection` 完成 offer/answer/ICE 候选交换，经 FakeSignaling 建立第一条 DataChannel。

**关键动作**：
- `p2p/pubspec.yaml` 加 `flutter_webrtc`（版本以探路实测为准）；每个包 `flutter pub get`
- 新建 `p2p/lib/web_rtc_transport.dart`：`class WebRtcTransport implements Transport`
  - 构造注入 `SignalingChannel`（依赖端口，不 import firebase）+ 可选 `IceServerProvider`（步骤 4 用）
  - 最简 SDP 交换路径：`discover` → `connect` → 建 `RTCPeerConnection` → offer/answer 经
    `SignalingChannel` 的信封传 → ICE candidate 交换（`IceCandidateEnvelope`）→ DataChannel 建立
  - `connect` 的 `keys` 先收下不使用（或注入 fake），避免编译报错；**此步不接认证**
- 处理 A7 守卫（§3.3）：收窄 `core/test/transport_contract_test.dart` 守卫为白名单排除
  `p2p/lib/web_rtc_transport.dart`，变异自检（临时删白名单 → 红）

**关键验证（门禁）**：
- 两个内存端点经 FakeSignaling 建立 DataChannel，互发一条消息（集成测试可默认跳过、人工可触发）
- `transport_contract_test.dart` 全绿（含收窄后的 A7 守卫）

**关键风险**：flutter_webrtc 平台兼容（factory 差异）；ICE 候选协商时序（trickle vs 非 trickle）

**停止条件**：DataChannel 建立失败且非代码问题（插件不支持当前平台）→ 停，报告

### 步骤 2 · 接入真信令后端（让跨设备能握手）

**目标**：把步骤 1 的 `WebRtcTransport` 接到已落地的 `LocalSignaling`（S3c-b）与
`CloudSignaling`（S3c-d，RTDB presence）。

**关键动作**：
- `discover`/`advertise` 走 `SignalingChannel` 注册/发现（SDP/ICE 封装进信封类型）
- 处理信令消息时序：offer 先于 answer、ICE 可 trickle；`PeerPresence.departed` → 连接失败
- 与 `LocalSignaling` 的 socket 断开 vs WebRTC 连接还活着的状态机对齐

**关键验证（门禁）**：
- `signaling_contract_suite.dart` 11 条契约对真 `WebRtcTransport` 仍绿（三拓扑同套约束）
- 真机/模拟器经 `LocalSignaling` 建立 WebRTC 连接（`@Tags(['integration'])` 默认跳过，人工触发）

**关键风险**：信令消息在 RTDB 的序列化（SDP 字符串大，注意写入限制）；socket 断开状态机

**停止条件**：信令契约套件对真 transport 红 → 停，报告（transport 没满足信令契约某条假设）

### 步骤 3 · 接 channel binding（让 MITM 防护真正生效）—— 整个任务的灵魂

**目标**：在 `Transport.connect`/`advertise` 握手内部，DTLS 握手完成后调用
`enforceChannelBindingMatches`（`device_pairing.dart:451-464`），拿**观测到的对端证书指纹**
vs **声明指纹**比对，不等抛 `PairingBindingMismatchError`。

**关键动作**：
- 取本端 DTLS 证书指纹（SDP `a=fingerprint` 行）→ 填 `ChannelBinding.localCertificateFingerprint`
- 取对端**声明的**证书指纹（对端 answer 的 SDP `a=fingerprint`）
- 握手完成后取**观测到的**对端证书指纹（DTLS 握手产物，**不是 SDP 声明值** —— 防 MITM 关键：
  攻击者能改 SDP，但改不了 DTLS 实际协商的证书）
- 调用 `enforceChannelBindingMatches(peerDeclaredCertificateFingerprint, observedPeerCertificateFingerprint)`
- `PeerSession.remote` 在比对通过后才绑定（呼应契约「握手认证后绑定」）；失败 → 会话不产出、抛错

**关键验证（门禁，必做变异自检）**：
- A5 MITM 负向测试用**真 WebRTC 路径**跑通：攻击者在信令上把声明证书指纹换成攻击者的、
  跑完整 `pair()`，bob 抛 `PairingBindingMismatchError`、alice 超时
- **变异自检**：注释掉 `enforceChannelBindingMatches` 调用 → MITM 测试必须红（攻击成功而门禁不响）；
  恢复后绿。红在断言非编译失败
- `ChannelBinding.localCertificateFingerprint` 是 SDP `a=fingerprint` 格式（`sha-256 AA:BB:...`，算法名内联）
- grep 命中 `enforceChannelBindingMatches` 的生产调用点（`p2p/lib/web_rtc_transport.dart`）

**前置依赖**：探路 ③ 必须已确认可得（否则此步阻断，见 §4.1）

**停止条件**：flutter_webrtc 不暴露观测指纹 API → 停，报告（阻断项，可能需人类决策换方案）；
MITM 测试无法用真路径复现 → 停，报告

### 步骤 4 · TURN 兜底 + 跨网络联调（让非局域网能通）

**目标**：接 `IceServerProvider`（preflight 端口），配 TURN 凭证，跑通跨网络 NAT 穿透。

**前置依赖**：**TURN 服务部署/签约（需人类）**。目前零部署零签约。局域网（步骤 1-3）不需要
TURN，本步骤可延后。

**关键动作**：
- `WebRtcTransport` 构造注入 `IceServerProvider`，建连前 `iceServers()` 取列表配进 `RTCConfiguration`
- 凭证过期重新索取（端口契约：不依赖缓存）

**关键验证**：跨网络连接成功 + 步骤 3 的 MITM 测试在 TURN 路径下仍红（变异自检仍有效）

**停止条件**：无 TURN 服务（等人类）→ 本步骤阻塞，步骤 1-3 可先行验收

## 六、验收标准（逐条机器输出为证）

- [ ] `WebRtcTransport implements Transport` 落在 `p2p/lib/`，跑通 `transport_contract_test.dart`
      + `peer_stream_contract_suite.dart` + `signaling_contract_suite.dart` 三套契约
- [ ] 步骤 1：经 FakeSignaling 建立 DataChannel 互发消息（集成测试可默认跳过但人工可触发）
- [ ] 步骤 2：经 LocalSignaling + CloudSignaling 各跑通一次真连接
- [ ] **步骤 3（最关键）**：`enforceChannelBindingMatches` 在 `connect`/`advertise` 握手内被调用
      （grep 命中生产调用点）；A5 MITM 测试用真 WebRTC 路径跑通，攻击者换指纹 -> 抛
      `PairingBindingMismatchError`；变异自检（注释掉调用）红在断言
- [ ] `ChannelBinding.localCertificateFingerprint` 是 SDP `a=fingerprint` 格式
- [ ] A7 守卫收窄正确：白名单外新增任何 `implements Transport` 的实现仍红（变异自检）
- [ ] 三条 analyze 门禁全绿（`run_s1a_analyze_gate.sh` / `run_s1b_analyze_gate.sh` /
      `run_monorepo_convention_check.sh`）+ core/p2p/firebase 测试全绿
- [ ] flutter_webrtc 版本是开工前实跑核实过的最新稳定版（不是照抄文档的 1.5.2）
- [ ] `p2p` 零 firebase 依赖（`s3c_no_firebase_guard_test.dart` 仍绿）
- [ ] 探路报告 `DTLS-FINGERPRINT-SPIKE.md` 落盘，含 API 签名 + 取值时机 + 结论

## 七、禁止动作（违反即判废）

1. ❌ 禁止改 `Transport`/`PeerSession`/`PeerStream`/`ChannelBinding` 契约（S1a/S6 已冻死）
2. ❌ 禁止改 `enforceChannelBindingMatches` 的实现（只调用，S6 已定）
3. ❌ 禁止改 `repository-interface-*` 接口
4. ❌ 禁止在 main 上改，所有改动走新分支 `feat/s3c-c-webrtc-impl`
5. ❌ 禁止跳过 §四.1 的 DTLS 指纹探路直接写步骤 3（最大未知数必须先探明）
6. ❌ 禁止照抄文档里的 flutter_webrtc 1.5.2 版本号（已过期，实跑核实）
7. ❌ 禁止跨仓改平台配置文件（AndroidManifest/Info.plist/entitlements 在 xuan-qizhengsiyu）
8. ❌ 禁止交出未认证的 PeerSession（裁定丙硬约束）
9. ❌ 禁止用 `git push --force`、`git stash drop` 等破坏性操作
10. ❌ 禁止顺手改门禁基线/加豁免/调下限（A7 守卫收窄是本任务交付的必要演进，须单独写清理由与变异证据）

## 八、停止条件汇总

- flutter_webrtc DTLS 指纹 API 不可得（步骤 3 阻断）-> 停，上报人类
- flutter_webrtc 不支持目标平台 -> 停，报告
- 信令契约套件对真 transport 红 -> 停，报告
- 守卫收窄后语义与预期不符且需改契约 -> 停，报告
- TURN 服务未部署（仅步骤 4 阻塞，不阻塞 1-3）-> 步骤 4 延后
- 任何门禁红且非本次引入 -> 停，报告

## 九、环境铁律

1. 进 worktree 先对每个包 `flutter pub get`（core/p2p/firebase 都要），否则 500+ 假 issue
2. 报错指向 `.pub-cache` 类型不匹配 -> 陈旧 lock，`rm pubspec.lock && flutter pub get`（先判断方向）
3. 入库 pubspec 相对路径以 main 位置为准，worktree 深度差走 gitignored `pubspec_overrides.yaml`
4. `pubspec_overrides.yaml` 整体取代 `dependency_overrides`，新建时抄全原有条目
5. 不在 main 工作区直接改文件（本任务全程在 `feat/s3c-c-webrtc-impl` 分支）
6. 验收命令行不加 markdown 反引号

## 十、输出契约

1. 本 ACT 协议文档 + `HANDOFF.md`（已落盘 `docs/opsx/changes/s3c-c-webrtc-impl/`，先细化再实现）
2. DTLS 指纹探路报告 `docs/opsx/changes/s3c-c-webrtc-impl/DTLS-FINGERPRINT-SPIKE.md`
3. 任务纪要 `tasks/<agent>-s3c-c-webrtc-impl.md`
4. 完成交接报告 `~/Downloads/storage_refactor/IMPL-S3c-c-WEBRTC-REPORT.md`
   （每步命令输出 + exit code + git diff --stat + 验收逐条证据 + 变异自检报错原文 + 未决问题）

## 十一、待审核决策点（给审核 agents 的重点）

1. **A7 守卫收窄方案**（§3.3）：白名单排除 `p2p/lib/web_rtc_transport.dart` 是否可接受？
   是否有更优写法（如按 `Channel` 值白名单）？
2. **步骤 3 的声明指纹来源**：框架计划要求「从对端 SDP 取声明指纹、握手后取观测指纹」，
   但 S6 语义是「声明指纹来自配对验签结果（`PairingResult.peerDeclaredCertificateFingerprint`）」。
   本 ACT 按框架计划字面写「对端 answer 的 SDP a=fingerprint 为声明值」——**请审核确认**：
   声明值取 SDP 还是配对结果？若取配对结果，`connect`/`advertise` 签名无配对结果入参，
   需在握手内部先跑配对（`DevicePairingProtocol`）拿 `PairingResult`，是否超出本任务范围？
3. **步骤 1 是否接认证**：框架计划 §步骤1 明写「此步不接认证，connect 的 keys 先收下不使用」，
   但裁定丙禁止交出未认证 PeerSession —— 步骤 1 若 connect 返回 PeerSession 即违反。
   本 ACT 的读法：步骤 1 只验证「管道通」（DataChannel 建立），**不产出 PeerSession**，
   或产出的会话仅用于内部联调、不对外暴露 —— 请审核该读法是否合规，或要求步骤 1 即含最小认证。
4. **变异自检强度**：A5 MITM 的「红在断言」是否满足验收方口径（红在编译失败不算数）？

---

*（本文件为执行前的细化 ACT，审核通过后按 §四→§五 顺序开工；所有改动在 `feat/s3c-c-webrtc-impl` 分支。）*
