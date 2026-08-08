# 交接信封 —— storage-s3c-c-webrtc-impl（计划阶段）

> 生成 2026-08-07 ｜ 计划阶段交付：细化 ACT 协议文档已落盘，**待其他 AI agents 审核**。
> 审核通过后，下一位执行者按 ACT §四 → §五 顺序开工。

## 当前分支与提交

- 分支：`feat/s3c-c-webrtc-impl`（自 `main c28de62` 创建）
- 本批提交内容：`docs/opsx/changes/s3c-c-webrtc-impl/` 下的计划文档（ACT-Protocol-Document.md + HANDOFF.md）

## 任务分工（人类 2026-08-07 指定，详见 ACT 头部）

| 环节 | 承担者 |
|---|---|
| 制定计划 / 编写计划 | ClaudeCode、Codex |
| 计划拆分细化 / 评审 / 验收 | GLM、Kimi、DeepseekV4Pro |
| 执行 | DeepseekV4Flash0731（不需要 ACT 协议，按 ACT 执行即可） |

## 已完成的输入工作（执行者不必重读全部，但建议核对）

- [x] 通读框架计划 `~/Downloads/storage_refactor/PLAN-S3c-c-WEBRTC-IMPL.md` 全文
- [x] 读完框架计划 §三 清单全部 13 项参考文档/代码（裁定丙原文、Transport 契约、S6
      `enforceChannelBindingMatches`、IceServerProvider、A 层样板、信令层、边界 handoff、
      TURN 选型、平台配置报告、preflight ACT/HANDOFF、架构 §3.5）
- [x] 创建 `feat/s3c-c-webrtc-impl` 分支（未碰 main）
- [x] 细化 ACT 协议文档落盘 `docs/opsx/changes/s3c-c-webrtc-impl/ACT-Protocol-Document.md`
      （含逐步门禁 + 变异自检 + 停止条件 + 待审核决策点）
- [x] **步骤 3 声明指纹来源已由人类裁定并写入 ACT**：取 `PairingResult.peerDeclaredCertificateFingerprint`
      （配对验签结果），**不取** SDP `a=fingerprint`；`connect`/`advertise` 握手内部必须先跑
      `DevicePairingProtocol` 拿 `PairingResult`，再与 DTLS 观测指纹一并传入
      `enforceChannelBindingMatches`。此即 channel binding 落地形态，不超出本任务范围。

## 下一步（审核通过后）

1. **前置① DTLS 指纹探路子任务**（ACT §4.1）：`p2p` 加 flutter_webrtc（实跑核实最新稳定版），
   写最简 spike 确认 ① 本端指纹 ② 对端声明指纹 ③ 观测指纹 三个 API 可得；产出
   `DTLS-FINGERPRINT-SPIKE.md`。③ 不可得 → 停，上报人类。
2. 按 ACT §五 步骤 1→2→3→4 实现（步骤 3 是灵魂：握手内先跑 `DevicePairingProtocol`，
   `enforceChannelBindingMatches` 在真握手内被调用 + A5 MITM 真路径跑通 + 变异自检）。
3. 完成交接报告 `~/Downloads/storage_refactor/IMPL-S3c-c-WEBRTC-REPORT.md`。

## 待审核决策点（已在 ACT §十一，审核重点）

1. A7 守卫收窄方案（白名单排除 `p2p/lib/web_rtc_transport.dart`）
2. ~~步骤 3 声明指纹来源~~ **✅ 已裁定（人类 2026-08-07）**：取配对验签结果，不取 SDP 明文（见上）
3. 步骤 1「不接认证」与裁定丙「不交出未认证 PeerSession」的读法
4. 变异自检「红在断言」口径

## 注意（环境铁律，AGENTS.md 详细版）

- 进 worktree 先对每个包 `flutter pub get`（core/p2p/firebase 都要）
- 陈旧 lock 报错 → `rm pubspec.lock && flutter pub get`
- 入库 pubspec 相对路径以 main 位置为准；worktree 深度差走 gitignored `pubspec_overrides.yaml`
- 全部改动在 `feat/s3c-c-webrtc-impl`，禁止 main 上改、禁止跨仓改平台配置、禁止破坏性 git 操作
