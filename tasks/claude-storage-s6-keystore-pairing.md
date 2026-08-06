# 任务: storage-s6-keystore-pairing
负责: claude ｜ 分支: agent/claude/storage-s6-keystore-pairing ｜ 开工: 2026-08-05
状态: ⏸ 蓝图（决定记录待人类确认，未开工）

## 目标
交付 S6 第二块地基：`DeviceKeyStore` 真实现 + 设备配对流程（跑在已交付的 `SignalingChannel` 上）+ channel binding 规格 + `BlobCipher` 密钥派生实现 + 可复用契约套件 + MITM 负向测试。私有数据的任何跨设备能力都卡在这。

## ⏸ 停下点：三个架构问题已答，等人类确认后开工

> 派工 §五 要求：三个问题的答案先写进决定记录，**等人类确认后再开工**。
> 上一任就是没等确认、选型做了一大半才发现契约不通。本轮严格遵守。
> 开工前 **不要** 写任何实现代码。

详见下方「决定记录」Q1/Q2/Q3。一句话摘要：
- **Q1**：`DeviceKeyStore` 实现落 **`p2p` 包**（与传输同层，纯 Dart 密码学，无平台依赖）。不在 `core`（避免污染纯契约包）。
- **Q2**：私钥**落盘**用 `cryptography` 包的 Ed25519 密钥对，序列化为加密的 PEM/字节，存 app-private 目录；桌面端**叠加** `flutter_secure_storage` 存 DEK；移动端靠沙盒+全盘加密。**核实结论：派工转述的「D16 不引入 flutter_secure_storage」不准确**——见决定记录 Q2 核实。
- **Q3**：channel binding 绑 **`nonce ‖ dtlsFingerprint ‖ 双方公钥指纹`**。`Transport` 契约**需新增一个口子**暴露 DTLS 指纹——**走评审路径上报人类，本轮不自己改 transport.dart**。

## 计划

> ⚠ 计划在人类确认 Q1/Q2/Q3 后再细化成 ACT。下面是**按依赖顺序**的子任务骨架，
> 每个子任务完成后立即 `/wjt-handoff`（aiwt save）落盘一次。

- [ ] **ACT 0 · 评审与规格落盘**（本轮已完成一半）
  - [x] 通读契约 + 连通性思想实验
  - [x] 回答 Q1/Q2/Q3，写进决定记录
  - [ ] 人类确认 Q3 的 transport.dart 改动提案 → 才进 ACT 1
- [ ] **ACT 1 · `DeviceKeyStore` 实现**（落 `p2p` 包，纯 Dart）
  - Ed25519 密钥生成（`cryptography` 包）
  - `localIdentity`：deviceId（随机 UUID）+ publicKeyFingerprint（SHA-256 of DER public key，hex，分组显示）
  - `sign()`/`verify()`：私钥不出实现
  - 持久化：app-private 目录文件（PEM），桌面端叠加 flutter_secure_storage 守 DEK
  - 私钥无任何导出路径（A2 守卫：源码扫描测试）
- [ ] **ACT 2 · 设备配对流程**（跑在 `SignalingChannel` 上）
  - 配对信封：用现有 `SignalingEnvelope` 的封闭类型？**不行**——它是 SDP/ICE 专用。
    需在**配对层**定义自己的配对消息（offer/answer 信封在 S6 自己的类里，不碰 signaling.dart 契约）。
  - 流程：双方 open(同一 rendezvous) → 交换公钥（经信令）→ 挑战-应答（签名覆盖 nonce‖dtlsFingerprint‖双方公钥指纹）→ 各自算出**相同**的带外指纹
- [ ] **ACT 3 · channel binding 规格**（Q3 的答案落地为可测形式）
  - 规格文档 + 签名对象定义
  - 若 Q3 改 transport.dart 获批：补 DTLS 指纹暴露口子 + 契约测试
  - 若不获批：用配对层注入的「承诺指纹」做退化 channel binding，并在规格里写明限制
- [ ] **ACT 4 · `BlobCipher` 密钥派生实现**（填 S1a 已定死的端口形状）
  - AES-GCM 逐 chunk 加密，nonce 内联头部，per-chunk nonce 由 chunkIndex 派生
  - 落 `p2p` 包或 `drift` 包？**倾向 `drift`**——`BlobCipherRegistry` 已在 drift，且 LocalBlobStore 实现在 drift。见决定记录 Q1-补充。
  - 接到 `BlobCipherRegistry.register()`，让 `LocalBlobStore` 的私有 blob 加解密路径真走到它（A7 变异自检）
- [ ] **ACT 5 · 契约套件提取**（手法照 `signaling_contract_suite.dart`）
  - `core/lib/test_support/keystore_contract_suite.dart` + `pairing_contract_suite.dart`
  - 不进 barrel（守卫 `s1b_architecture_guard_test.dart:53`）
  - 两个结构迥异的 fake 各跑一遍
- [ ] **ACT 6 · MITM 负向测试**（A5，最重要）
  - 真注入：信令通道被攻破，DTLS 指纹被替换 → 签名验不过 → 指纹比对发现
  - 不许是「构造不同指纹然后断言 !=」
- [ ] **ACT 7 · 变异自检 + 门禁**
  - 每条新测试逐条变异（注入违规→红在目标断言→复原），决定记录写明
  - 验收命令三段全绿，57 条冻结基线不抬高

## 验收标准
- [ ] A1 `DeviceKeyStore` 真实现，sign() 产出的签名 verify() 验过，换 key 验不过
- [ ] A2 私钥无任何导出路径——源码扫描守卫：实现类无返回私钥字节的 public 成员
- [ ] A3 配对流程跑通：两端经 `SignalingChannel` 完成配对，各自算出**相同**带外指纹
- [ ] A4 换一端身份 → 指纹不同（正向对照）
- [ ] A5 ⚠ MITM 负向测试：信令通道被攻破、DTLS 指纹被替换 → 指纹比对**必须发现**。真注入攻击，不许注释声称
- [ ] A6 S6 契约提取为可复用套件（手法与 `signaling_contract_suite.dart` 一致）
- [ ] A7 `BlobCipher` 密钥派生落地，`LocalBlobStore` 加解密路径**真的走到它**（变异自检证明）
- [ ] A8 每条新测试做过变异自检（注入违规→红在目标断言→复原），逐条在决定记录写明注入了什么、红在哪条断言
- [ ] A9 三条既有门禁全绿，S1a 的 57 条冻结基线未被抬高
- [ ] A10 core/drift/firebase/p2p 四包测试只增不减
验收命令: bash scripts/run_s1a_analyze_gate.sh && bash scripts/run_s1b_analyze_gate.sh && bash scripts/run_monorepo_convention_check.sh && (cd core && flutter test) && (cd drift && flutter test) && (cd p2p && flutter test) && (cd firebase && flutter test)

## 当前状态
蓝图阶段。刚完成契约通读 + 三问作答，已写进决定记录。**下一步：等人类确认 Q3（transport.dart 改动提案）后进 ACT 1**。在此之前不写实现代码。

## 决定记录

### 2026-08-05 · Q1：`DeviceKeyStore` 实现落哪个包？

**答案：落 `p2p` 包（`persistence_p2p`）。**

判据是派工给的：「哪个选择让 drift / firebase / assets 都不需要新增密码学依赖」。
- `core` 是纯契约包（`persistence_core`，纯 Dart 契约 + 后端无关编排）。把 Ed25519/AES-GCM 实现放进去会污染纯契约包，且 `core/pubspec.yaml` 目前只有 `crypto`（sha256），加 `cryptography` 会让所有下游包被动引入密码学实现依赖。**排除。**
- `p2p` 已是传输层落点（`LocalSignaling`/`CloudSignaling` 在这层），`DeviceKeyStore` 与设备配对/传输同生共死，放这里自然。`p2p` 已依赖 `bonsoir`+`persistence_core`，加 `cryptography` 是合理增量。
- `drift`/`firebase`/`assets` 都不碰——它们是存储/云适配器，与设备身份密钥无关。

**Q1-补充（待人类一并确认）**：`BlobCipher` 的 AES-GCM 实现落哪？
- 倾向 `drift`：`BlobCipherRegistry` + `IdentityBlobCipher` + `DefaultBlobCipherResolver` 已在 `drift/lib/blob/`，`LocalBlobStore` 的 drift 实现也在那。AES-GCM cipher 作为 `BlobCipherRegistry.register()` 的入参，自然落在 drift。
- 这样 `DeviceKeyStore`（身份/配对）在 `p2p`，`BlobCipher`（落盘加密）在 `drift`，各归其位。**但 AES-GCM 密钥（DEK）的来源/派生仍是 S6 的活**——见 Q2。

### 2026-08-05 · Q2：私钥存在哪？（核实 D16）

**先说核实结论：派工转述的「D16 已裁定不引入 `flutter_secure_storage`」不准确，不要信这句转述。**

核实过程（按派工要求读了原文）：
- D16 不在设计稿 `2026-07-31-storage-architecture-design.md`，而在上一任被打回的 `2026-08-02-s6-p2p-sync-third-party-design.md:1308`。
- D16 原文：「**移动端（iOS/Android）不做应用层落盘加密**，理由是全盘加密出厂强制开启且关不掉」。
- D15（同页）：「**推翻 D12，加回 `flutter_secure_storage` 10.3.1，但只在桌面端启用、只用于存 DEK**」——人类原话：「不行就把那个刚才去除的 `Flutter_Secure_*` 加回到文档里面，它用来负责 Windows 或者是 Linux 的加密以及 Web 的」。
- 设计稿 §6.3:1627 也明确列了 `flutter_secure_storage 10.3.1` 用于「设备私钥存储（仅存身份私钥，不用于业务数据落盘）」。
- `transport.dart:73-75` 契约注释：「设备私钥走安全存储，与 D16「业务数据不做应用层落盘加密」不冲突——私钥不是数据，是身份凭证」。

**所以真相是**：D16 禁的是「移动端**业务数据**应用层落盘加密」，**不是**禁 `flutter_secure_storage`。D15 反而**加回了**它，但**只在桌面端**用于存 DEK。分界线是「系统全盘加密是否出厂强制」：iOS/Android 出厂强制（不补），macOS/Windows 是用户开关（桌面端必须应用层补）。

**D16 不需要被推翻。本轮按 D15/D16/D17 原样落地，不自行改判。**

**私钥存储方案（按 D15/D16/D17）：**
- **移动端（iOS/Android）**：Ed25519 私钥序列化后存 app-private 目录（沙盒隔离 + 出厂全盘加密双层）。不引入 flutter_secure_storage（D16：移动端不补应用层加密）。
- **桌面端（macOS/Windows/Linux）**：同上存 app-private 目录，**叠加** `flutter_secure_storage` 存那把 32 字节 DEK（D15），DEK 加密私钥落盘文件。理由：桌面全盘加密是用户开关，可能没开，必须应用层补。
- **Web**：D18 本期不交付 S6 能力，留空。
- **私钥永不出 `DeviceKeyStore`**：契约的 `sign()`/`verify()` 形状已保证，实现不提供任何导出私钥的方法（A2 守卫）。
- **D17**：每设备一把独立 DEK，严禁跨设备共享落盘密钥（否则容灾模型失效）。

**版本核实（派工 §十.6 要求重跑）**：
- `cryptography`：上一任锁 2.9.0。实查 pub-cache 缓存的是 2.9.0，pub.dev 最新亦为 2.9.0（核实）。**沿用 2.9.0**。
- `flutter_secure_storage`：上一任锁 10.3.1。**待 ACT 1 开工前再实查 pub.dev 确认是否有新版**（不照抄）。

### 2026-08-05 · Q3：channel binding 具体绑什么？

**答案：带外指纹 = SHA-256(`本端公钥DER ‖ 对端公钥DER ‖ dtlsFingerprint ‖ nonce`)，hex 分组显示。签名对象 = `nonce ‖ dtlsFingerprint ‖ 双方公钥指纹`。**

为什么这样定：
1. **只绑设备公钥 → 挡不住**信令通道被攻破后替换 DTLS 指纹（设计稿 :1078 点名的攻击）。上一任文档 §5.2b 已论证。
2. **绑 DTLS 指纹 → 能挡**：攻击者替换 SDP 里的 DTLS 指纹 → 签名对象变了 → 验签失败。这是设计稿 :794「规格见 S6」要的东西。
3. **加双方公钥指纹进签名对象**：防止「签名验的是 A、数据流向 B」的身份错配。指纹本身含双方身份，带外比对时一眼可见对端是谁。

**⚠ 本轮要面对的契约缺口（必须走评审路径，不许自己改）：**

`Transport` 契约（`core/lib/model/transport.dart`）目前**没有暴露 DTLS 指纹的口子**。`connect()`/`advertise()` 拿到 `DeviceKeyStore keys`，但握手产出的 DTLS 指纹无处可取——而 channel binding 的签名对象必须含它。

上一任 C1/C2/C3 三条契约缺口最后都走「写进决定记录→给签名提案→停下上报人类→评审通过后补进 transport.dart」这条路，**且都成功了**。本轮 Q3 走同一条路：

**transport.dart 改动提案（待人类批准）：**

```dart
// 在 PeerIdentity 旁新增一个握手产物值类（不改 PeerIdentity 既有字段）：
/// 一次握手的 channel-binding 产物：已认证绑定到本会话的传输层指纹。
/// 由 Transport 实现在握手完成时产出，供 S6 配对层做带外比对与签名。
final class ChannelBinding {
  /// DTLS 证书指纹（WebRTC 路径）或 TLS 证书指纹（LAN socket 路径）。
  /// 形如 'sha-256 AA:BB:...'（SDP a=fingerprint 格式）。
  final String transportFingerprint;

  /// 指纹算法，如 'sha-256'。
  final String algorithm;

  const ChannelBinding({required this.transportFingerprint, required this.algorithm});
}

// PeerSession 增加一个只读 getter（不改既有成员）：
abstract interface class PeerSession {
  ... // 既有成员不动

  /// 握手认证后绑定的传输层指纹（channel binding）。
  /// 未完成认证的会话访问它应抛 StateError。
  ChannelBinding get channelBinding;
}
```

**为什么是 `PeerSession.channelBinding` 而不是 `Transport.xxx`**：DTLS 指纹是**每条会话**的握手产物（每条连接 ECDHE 临时协商），不是 transport 级别的常量。放 PeerSession 上，S6 配对层从已认证会话取它、塞进签名对象。

**影响范围（供评审）：**
- 只新增一个值类 `ChannelBinding` + 一个 getter，不改既有任何成员/签名。
- `transport_contract_test.dart` 里的 `_FakePeerSession` 需补 `channelBinding` 实现（测试 fake，非交付物）。
- `peer_stream_contract_suite.dart` 的 fake session 也需补（它实现 PeerSession）。
- 不影响 S1a 的 57 条冻结基线（新文件/新成员，不增既有 issue）。
- S3c-c（WebRTC Transport 实现）将来要在握手后填这个 getter——这是它的合理职责。

**如果人类不批准改 transport.dart**：退化方案是 S6 配对层用一个「承诺指纹」（双方在配对信封里各自声明自己的传输指纹并签名），但**这挡不住信令通道 MITM**（攻击者可两边各替换）。规格会写明这个限制，A5 的 MITM 测试就只能测「信令完整时的身份错配」而非「DTLS 替换」。**不推荐**——会让 A5 的重要一半失守。

**推荐：批准上面的 transport.dart 改动。**

## 踩坑墓地
<只追加不删改。每次失败的尝试必须入墓>

## 冷冻快照
<仅在搁置时由 /hibernate 填写>
