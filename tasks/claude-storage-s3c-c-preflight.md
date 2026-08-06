# 任务: storage-s3c-c-preflight
负责: claude ｜ 分支: agent/claude/storage-s3c-c-preflight ｜ 开工: 2026-08-05
状态: 进行中

## 目标

S3c-c（WebRTC Transport 实现）依赖 S6，S6 刚重启。本轮不等 S6，做 S6 交付那天 S3c-c 能立刻开工
所需要的全部前置：三件事（拆分裁定、TURN 选型、平台配置定位），全部与 S6 无依赖，可并行。

> 派工书逐字留存于 `../../Downloads/storage_refactor/DISPATCH-S3c-c-preflight.md`。
> 与本纪要冲突时以「决定记录」为准。

## 决定记录

### 2026-08-05: D1 · 任务 A 裁定：丙

**裁定：丙** —— 拆，但 A 层只做到「契约测试全绿的内存/loopback 实现」，真 WebRTC 等 S6。

**论证**（三条硬事实，每条带 `transport.dart` 行号）：

1. **`connect` 的入口参数就是 S6 的交付物。** `core/lib/model/transport.dart:232`：
   `required DeviceKeyStore keys` —— S6 的东西，required。内存 fake 注入一个
   test-only 的 fake `DeviceKeyStore` 就能跑通，但真 WebRTC 实现必须等 S6 交付真实现。

2. **channel binding 写在 `connect` 的 dartdoc 里，不是写在某个后续步骤上。**
   `transport.dart:225-226`：「握手**必须**完成认证密钥交换并把指纹绑定到会话
   （channel binding），否则带外指纹比对对主动 MITM 无效。规格见 S6。」—— 不在
   `connect` 里做 channel binding 的 `Transport` 实现是**违反契约**的，不是「功能
   不完整」。乙方案（A 层无认证）要交出 `PeerSession`，只有两条路：编造一个
   `remote`（直接违反「握手认证后绑定」），或者改契约。它不是在契约允许的空间
   里做取舍，它是在契约外面。

3. **`PeerSession` 的定义是「一条已认证连接上的多路复用会话」。** `transport.dart:174`
   `remote` 的 dartdoc：「对端身份（**握手认证后**绑定）」。`PeerIdentity.publicKeyFingerprint`
   明写「用于带外比对（channel binding）」。`PeerSession` 本身就是已认证的会话，
   不存在「无认证的 PeerSession」。

**丙的 A 层要做的**：写一个内存/loopback 的 `Transport` 实现（`FakeTransport`），接受
`DeviceKeyStore` 但注入的只是 test-only fake `DeviceKeyStore`。跑通 `peer_stream_contract_suite`
与 `signaling_contract_suite`。**不写任何真 WebRTC 代码，不引 `flutter_webrtc`。**

**这才是唯一契约合规的路径。**

### 2026-08-05: D2 · 上报项 1：channel binding 材料的契约口子

S6 很可能需要第四次 S1a 契约变更。设计稿 `:1078` 说防护手段是「两台设备各自显示**公钥指纹**，
用户肉眼比对」。但只比公钥指纹挡不住「信令通道被攻破、DTLS 指纹被替换」的攻击——
比对公钥指纹只能证明「我和持有那把钥匙的人说过话」，不能证明「这条信道就是和他的」。

**channel binding 才是把身份钉死在**这一条** DTLS 信道上的东西**：把 DTLS 证书指纹放进
挑战-应答的签名内容里（`nonce || dtlsFingerprint`）。要拿到 DTLS 指纹，就得拿到信道级材料。

**`Transport` 现在没有这个口子**：`PeerIdentity` 只有 `deviceId` + `publicKeyFingerprint`
（`transport.dart:26-43`），没有任何信道绑定材料的位置。

**精确签名提案**（上报人类，走 S1a 评审，不许自己改）：

```dart
/// 对端身份：认证握手后绑定到会话的身份信息。
///
/// 字段约定：
/// - [deviceId]：设备唯一标识。
/// - [publicKeyFingerprint]：对端公钥指纹，用于带外比对（channel binding）。
/// - [channelBindingMaterial]：**本次连接的 DTLS 指纹**（S6 channel binding 必需）。
///   不被包含在 [PeerIdentity] 中，而是作为 [connect] 与 [incoming] 交付的
///   [PeerSession] 上的独立字段，因为它的生命周期绑定于**本次连接**，而非对端设备。
final class PeerIdentity {
  final String deviceId;
  final String publicKeyFingerprint;
  const PeerIdentity({required this.deviceId, required this.publicKeyFingerprint});
}

// 建议新增（在 PeerSession 上）：
//   /// 本次连接的 DTLS 证书指纹（channel binding 材料）。
//   ///
//   /// 两端各有一个值（本端 vs 远端），S6 的 channel binding 需要把远端 DTLS 指纹
//   /// 放进 Ed25519 挑战-应答的签名内容里，使「签名验过的 peer」和「正在传数据的那条
//   /// DTLS 信道」绑定在一起。规格见 S6 §5.2b。
//   String? get channelBindingFingerprint; // 认证完成前为 null，认证后绑定
```

**上报**：此条同时抄送 S6，别让两边各自发现一遍。

### 2026-08-05: D3 · 上报项 2：设计稿 `:793` 类型漂移

设计稿 2026-07-31-storage-architecture-design.md `:793` 写的还是 `required DeviceKeyPair localKeys`，
而 main 的代码是 `required DeviceKeyStore keys`（C3 改名后设计稿没跟上）。照着设计稿写
的执行者会发明一个不存在的类型。**记 P2**，建议与 D2 同批处理。

### 2026-08-05: D4 · P3–P7 变异自检记录（A8 逐条实做）

按 ACT `docs/opsx/changes/s3c-c-preflight/ACT-Protocol-Document.md` P7 执行，
每条新测试/改动注入违规 → 确认红 → 复原。**全部红在断言上，无一条红在编译失败。**

| # | 变异对象 | 注入了什么 | 红在哪条断言 | 复原后 |
|---|---|---|---|---|
| V1 | P4 A6 扫描守卫 | `ice_server.dart:4` 库注释加 `（Cloudflare）` | A6 守卫：`Expected: empty / Actual: ['lib/model/ice_server.dart 含 "Cloudflare"']` | ✅ 守卫测试 2 条全绿 |
| V2 | P6 R5 并发契约 | `fake_transport.dart` `send()` 删除挂起检查（并发水位无界上涨） | FakeTransport 全路径 R5：`Expected: ≤8256 / Actual: 9216`（wait 策略挂起阶段水位） | ✅ `transport_contract_test.dart` 30 条全绿 |
| V3 | P3 dartdoc 下限 | 删除 `IceServer.urls` 的 `///` 注释块 | dartdoc 测试：`lib/model/ice_server.dart:23: final String urls;` 缺中文 dartdoc | ✅ dartdoc + 守卫 3 条全绿 |

> 注：P4 barrel 可消费探针是**编译期**守卫（删 barrel export 会红在编译失败），
> 按纪律「红在编译失败不算数」，该条不以编译失败为有效变异 —— 其有效性由
> V1 的扫描守卫变异间接覆盖（同一文件同一批新增）。

## 计划

- [ ] **P0 环境准备（30min）**：对 `core`、`p2p`、`drift`、`firebase` 各跑 `flutter pub get`；
  跑通四条门禁；记录基线红绿数字进「当前状态」
- [ ] **P1 任务 A 落地：`FakeTransport` 内存/loopback 实现（90min）**：写 `core/lib/test_support/fake_transport.dart`
  的 `FakeTransport`，实现 `Transport` 接口。注入 test-only `FakeDeviceKeyStore`（`sign` /
  `verify` 做内存签名）。跑通 `peer_stream_contract_suite` 与 `signaling_contract_suite`。
  **不引 `flutter_webrtc`，不写真 WebRTC。**
- [ ] **P2 任务 B：TURN 选型文档（60min）**：≥3 个候选（Cloudflare Calls / Twilio / Xirsys），
  判据含可见元数据风险（`:1077`）与成本（`:1057` 仅 10–20% 走中继）。落
  `docs/superpowers/specs/2026-08-05-s3c-c-preflight-turn-selection.md`
- [ ] **P3 任务 B：`IceServerProvider` 端口（45min）**：落 `core/lib/model/ice_server.dart`，
  签名体现凭证时效性（不是常量字符串）。服务商名**零出现在 `core` 的契约与注释里**。
  加 dartdoc + 同步抬高 `s1a_dartdoc_coverage_test.dart` 下限。
- [ ] **P4 任务 B：A5 源码扫描守卫（30min）**：`core/test/` 加一条测试扫 `core/lib/model/ice_server.dart`
  与 `core/lib/model/transport.dart` 与 `core/lib/model/signaling.dart`，出现 Cloudflare /
  Twilio / Xirsys 等字样即红。照抄 `signaling_contract_test.dart` 的「A2 · 后端无关」手法。
- [ ] **P5 任务 C：平台配置定位 + 上报（30min）**：`find` 在本仓查 `AndroidManifest.xml`、
  `Info.plist`、`*.entitlements` —— 零命中。三处配置全在消费方 app 仓 `xuan-qizhengsiyu`
  （即 `xuan-shell`）。**不跨仓改**，写清楚「哪个文件、哪个仓、缺哪一条」作为跨仓任务上报。
- [ ] **P6 遗留 P2（R5 并发变异自检）**：`peer_stream_contract_suite.dart` 的 R5 并发测试
  没有任何变异自检。S3c-c-pre 合并时登记为 P2。本轮注入一个真的并发违规（比如让 `send`
  在并发下水位无界上涨），确认它红。
- [ ] **P7 A8 逐条变异自检（60min）**：每条新测试注入违规 → 确认变红 → 复原。
  **红在编译失败不算数**（纪律第 2 条）。逐条把「注入了什么、红在哪条断言上」写进决定记录。
- [ ] **P8 收口（30min）**：四条门禁 + `core` 测试 + `p2p` 测试 + `drift` 测试 + `firebase`
  测试全绿；核对 S1a 门禁 57 条冻结基线未被抬高；dartdoc 下限已同步抬高；手册「决定记录」收口。

## 验收标准

- [ ] **A1** 任务 A 裁定为丙，论证基于三条硬事实（每条带 `transport.dart` 行号）
- [ ] **A2** `FakeTransport` 跑通 `peer_stream_contract_suite` 全部断言（A4/A5/A6/R4/R5 + 结构守卫）
- [ ] **A3** `FakeTransport` 跑通 `signaling_contract_suite` 全部 11 条
- [ ] **A4** TURN 选型文档：≥3 个候选，判据含可见元数据风险与成本
- [ ] **A5** `IceServerProvider` 端口签名落地，凭证时效性在签名里体现（不是常量字符串）
- [ ] **A6** 服务商名零出现在 `core` 的契约与注释里 —— 源码扫描守卫
- [ ] **A7** 任务 C：三处配置的真实位置已查明（均不在本仓，在 `xuan-qizhengsiyu`），给出结论
- [ ] **A8** 每条新测试做过变异自检（注入违规 → 确认变红 → 复原），逐条写明注入了什么、红在哪
- [ ] **A9** 四条既有门禁全绿，S1a 的 57 条冻结基线未被抬高
- [ ] **A10** 四包测试只增不减

验收命令: bash scripts/run_s1a_analyze_gate.sh && bash scripts/run_s1b_analyze_gate.sh && bash scripts/run_monorepo_convention_check.sh && (cd core && flutter test) && (cd drift && flutter test) && (cd p2p && flutter test) && (cd firebase && flutter test)

## 当前状态

**P0–P8 全部完成。** 四条门禁全绿，四包测试全绿，57 冻结基线未抬高。

| 门禁 | 结果 |
|---|---|
| `run_s1a_analyze_gate.sh` | ✅ 检查1/2/3 全过，57 = 冻结基线 57 |
| `run_s1b_analyze_gate.sh` | ✅ core 57/57、drift 145/146、firebase 20/20 |
| `run_monorepo_convention_check.sh` | ✅ 检查1/2 全过 |
| `core flutter test` | ✅ 213 All tests passed（基线 211，+2 ice_server 守卫） |
| `p2p flutter test` | ✅ 18 passed + 1 skipped (integration) |
| `drift flutter test` | ✅ 391 All tests passed |
| `firebase flutter test` | ✅ 131 passed + 4 skipped |

**dartdoc 下限**：165（实测值），下限 155（`s1a_dartdoc_coverage_test.dart`）。

**已变更文件（本轮 P3–P7）**：
- `core/lib/model/ice_server.dart`（新增，IceServer + IceServerProvider，凭证时效性进签名）
- `core/test/ice_server_provider_guard_test.dart`（新增，A6 供应商无关扫描 + barrel 可消费）
- `core/lib/persistence_core.dart`（+1 export ice_server.dart）
- `core/test/s1a_dartdoc_coverage_test.dart`（+ice_server.dart 进 files，下限 151→155）
- `docs/dispatch/2026-08-05-s3c-c-preflight-platform-config-report.md`（新增，P5 跨仓上报）
- `docs/opsx/changes/s3c-c-preflight/ACT-Protocol-Document.md`（新增，ACT 协议文档）
- `tasks/claude-storage-s3c-c-preflight.md`（D4 变异自检记录，3 条全红在断言）

**P1 完成细节**：
- `makeFakeTransportSessionPair()` 走 advertise → discover → connect → incoming 全路径
- `StreamController.broadcast(sync: true)` 确保内存 fake 同步投递（不需要 pumpEventQueue）
- 6 条 PeerStream 契约测试（A4/A5/A6/overflowPolicy/R4/R5）全部通过

## 踩坑墓地