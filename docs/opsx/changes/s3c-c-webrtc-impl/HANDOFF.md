# 交接信封 —— storage-s3c-c-webrtc-impl（执行阶段）

> 生成 2026-08-07 ｜ 执行中：**前置① 探路已完成**（最大未知数探明：③ 观测指纹可得，步骤 3 不阻断）。
> 下一步：步骤 1（依赖与连通骨架）。每完成一个阶段更新本 HANDOFF，不停下询问。

## 当前分支与提交

- 分支：`feat/s3c-c-webrtc-impl`（自 `main c28de62` 创建）
- 已有提交：
  - `7119722` 细化 ACT 协议文档 + 交接信封（计划阶段）
  - `4de6b5b` 按人类裁定钉死步骤3声明指纹来源 + 记录任务分工
  - 本批（探路）：flutter_webrtc 1.6.0 依赖 + spike 测试 + DTLS-FINGERPRINT-SPIKE.md

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

## 下一步（步骤 1）

1. `WebRtcTransport implements Transport` 落 `p2p/lib/web_rtc_transport.dart`（构造注入
   `SignalingChannel` + 可选 `IceServerProvider`），最简 SDP 交换路径经 FakeSignaling
   建立 DataChannel 互发消息（此步不接认证、不产出 PeerSession）
2. 收窄 A7 守卫（`core/test/transport_contract_test.dart`）为白名单排除
   `p2p/lib/web_rtc_transport.dart`，变异自检（临时删白名单 → 红）
3. 步骤 2：接 LocalSignaling（信令契约套件对真 transport 绿）
4. 步骤 3（灵魂）：握手内先跑 `DevicePairingProtocol` → `enforceChannelBindingMatches`
   （声明指纹取配对验签结果 + DTLS 观测指纹）→ A5 MITM 真路径 + 变异自检
5. 步骤 4：IceServerProvider 接入（无 TURN 服务则延后）
6. 完成交接报告 `~/Downloads/storage_refactor/IMPL-S3c-c-WEBRTC-REPORT.md`

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
