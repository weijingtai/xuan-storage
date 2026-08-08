# 交接信封 —— storage-s3c-c-webrtc-impl（执行阶段）

> 生成 2026-08-07 ｜ 执行中：**步骤 3（灵魂：channel binding）已完成**。
> 下一步：步骤 4（TURN 兜底，无服务则标记延后）。每完成一个阶段更新本 HANDOFF，不停下询问。

## 当前分支与提交

- 分支：`feat/s3c-c-webrtc-impl`（自 `main c28de62` 创建）
- 已有提交：
  - `7119722` 细化 ACT 协议文档 + 交接信封（计划阶段）
  - `4de6b5b` 按人类裁定钉死步骤3声明指纹来源 + 记录任务分工
  - `dca9b84` 前置① DTLS 指纹探路完成（③ 观测指纹实测可得）
  - `1502585` 步骤1 完成（WebRtcTransport 骨架 + A7 守卫收窄 + DataChannel 集成测试）
  - `d86a23a` 步骤2 完成（advertise 信令注册 + LocalSignaling 集成测试）
  - 本批（步骤3）：SocketPairingChannel 生产承载 + WebRtcPeerSession/PeerStream + 握手内嵌配对 + enforceChannelBindingMatches + A5 MITM 测试

## 任务分工（人类 2026-08-07 指定，详见 ACT 头部）

| 环节 | 承担者 |
|---|---|
| 制定计划 / 编写计划 | ClaudeCode、Codex |
| 计划拆分细化 / 评审 / 验收 | GLM、Kimi、DeepseekV4Pro |
| 执行 | DeepseekV4Flash0731（不需要 ACT 协议，按 ACT 执行即可） |

## 已完成的输入工作（执行者不必重读全部，但建议核对）

- [x] 通读框架计划 `~/Downloads/storage_refactor/PLAN-S3c-c-WEBRTC-IMPL.md` 全文
- [x] 读完框架计划 §三 清单全部 13 项参考文档/代码
- [x] 细化 ACT 协议文档落盘（含逐步门禁 + 变异自检 + 停止条件 + 待审核决策点）
- [x] 步骤 3 声明指纹来源人类裁定已写入 ACT（取配对验签结果，不取 SDP 明文）
- [x] **前置① DTLS 指纹探路完成（实测）**：flutter_webrtc 1.6.0（最新稳定版）已锁进
      p2p/pubspec.yaml；spike 在 Chrome 平台实测取到 ①②③ 三个指纹（③ 观测指纹 =
      getStats → transport.remoteCertificateId → certificate.fingerprint，须在
      connectionState==connected 后取，且 stats 的 fingerprint 不带算法名、需拼上
      `fingerprintAlgorithm` 前缀才符合契约格式）。报告：
      `docs/opsx/changes/s3c-c-webrtc-impl/DTLS-FINGERPRINT-SPIKE.md`；
      spike 测试：`p2p/test/dtls_fingerprint_spike_test.dart`（integration tag 默认跳过）
- [x] **步骤 1（依赖与连通骨架）完成（实测）**：
      - `p2p/lib/web_rtc_transport.dart`：`WebRtcTransport implements Transport`
        （Channel.webrtc；构造注入 SignalingChannel + 可选 IceServerProvider），
        握手管道 `establishDataChannel`（SDP/ICE 经 SignalingChannel 信封交换，
        trickle ICE；不产出 PeerSession）
      - `connect`/`advertise` 在认证接入前抛 `AuthNotWiredError`（裁定丙防线，
        绝不交出未认证 PeerSession）
      - A7 守卫收窄（`core/test/transport_contract_test.dart` 白名单
        `p2p/lib/web_rtc_transport.dart`），变异自检通过（删白名单 → 红，恢复 → 绿）
      - 集成测试 `p2p/test/web_rtc_transport_integration_test.dart`：
        两个内存端点经 FakeSignaling 建立 DataChannel 互发两条消息（Chrome 实测全绿）
      - p2p `flutter analyze` 全绿；core `transport_contract_test.dart` 30 条全绿
- [x] **步骤 2（接 LocalSignaling 真信令后端）完成**：
      - `advertise` 经信令注册：打开以随机 transientServiceId 为会合标识的
        `SignalingChannel` 监听会话（隐私约定不变：广播只含随机 id）；
        `stopAdvertising`/`dispose` 关闭会话；幂等
      - `discover` 语义钉死：发现经信令后端自身发现通道（bonsoir/RTDB
        presence）承载，本方法不重复枚举（框架计划 §步骤2），返回空流
      - 集成测试 `p2p/test/web_rtc_transport_local_signaling_integration_test.dart`：
        WebRtcTransport × 真 LocalSignaling（FakeLanDiscovery 内存发现 +
        真实 loopback socket）建立 DataChannel 互发消息 —— 需 macOS 桌面/
        真机跑（LocalSignaling 用 dart:io，不能跑 Chrome），默认跳过人工触发
      - 验证：p2p `flutter analyze` 全绿；p2p 全量测试 62+4 全绿（含
        `local_signaling_contract_test.dart` 契约套件 12 条）；
        步骤1 Chrome 集成测试无回归（DataChannel 互发仍绿）
- [x] **步骤 3（灵魂：channel binding）完成（Chrome 实测全绿）**：
      - `p2p/lib/socket_pairing_channel.dart`：补齐 `PairingChannel` 生产承载
        （socket 直连，结构同 LocalSignaling：ServerSocket + LanDiscovery +
        方向仲裁 + 行分隔 JSON 交换 PairingEnvelope；配对/信令 fabric 用
        `kind=pairing` 标记隔离）—— 承载缺口已补，非契约变更
      - `p2p/lib/web_rtc_peer_session.dart`：`WebRtcPeerSession`/`WebRtcPeerStream`
        （一条会话 = 一条 RTCPeerConnection；每条逻辑流 = 一条 RTCDataChannel，
        天然背压隔离；send 分块 16KB 安全线、wait 策略挂起）
      - `web_rtc_transport.dart` 握手内嵌认证（人类裁定落地）：
        `connect`/`advertise` 内部先跑 `DevicePairingProtocol` 拿
        `PairingResult`，声明指纹取 `peerDeclaredCertificateFingerprint`
        （配对验签结果，**不取** SDP 明文），DTLS 完成后取观测指纹
        （getStats → transport.remoteCertificateId → certificate.fingerprint
        + 拼 fingerprintAlgorithm 前缀），一并传入
        `enforceChannelBindingMatches` —— 通过才产出已认证 PeerSession
      - A5 MITM 集成测试 `web_rtc_channel_binding_integration_test.dart`
        （Chrome 真 WebRTC 路径）：
        - 正向：握手内跑配对 + channel binding，产出已认证 PeerSession
          （remote 绑定 + channelBinding 就位）
        - 负向：攻击者替换传输层证书（双方观测指纹被换为攻击者指纹）
          → bob 抛 `PairingBindingMismatchError`、接听侧不产出会话
        - **变异自检通过**：注释掉 `enforceChannelBindingMatches` 调用 →
          MITM 测试红在断言（Expected throws PairingBindingMismatchError,
          Actual _Future<PeerSession>）；恢复后绿
      - 验证：p2p `flutter analyze` 全绿；A5 集成测试 `+2` 全绿

## 下一步（步骤 4 · TURN 兜底）

## 待审核决策点（已在 ACT §十一，审核重点）

1. A7 守卫收窄方案（白名单排除 `p2p/lib/web_rtc_transport.dart`）
2. ~~步骤 3 声明指纹来源~~ **✅ 已裁定（人类 2026-08-07）**：取配对验签结果，不取 SDP 明文
3. 步骤 1「不接认证」与裁定丙「不交出未认证 PeerSession」的读法
4. 变异自检「红在断言」口径

## 注意（环境铁律，AGENTS.md 详细版）

- 进 worktree 先对每个包 `flutter pub get`（core/p2p/firebase 都要）
- 陈旧 lock 报错 → `rm pubspec.lock && flutter pub get`
- 入库 pubspec 相对路径以 main 位置为准；worktree 深度差走 gitignored `pubspec_overrides.yaml`
- 全部改动在 `feat/s3c-c-webrtc-impl`，禁止 main 上改、禁止跨仓改平台配置、禁止破坏性 git 操作
