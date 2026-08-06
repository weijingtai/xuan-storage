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
蓝图阶段。Q1/Q2 已批准，Q3 v2（三条歧义钉死）已写进决定记录待人类终批。main `53e5bb4` 全量门禁 + 四包测试已补验全绿（core 205 / drift 391 / p2p 18 / firebase 131，s1a 57=57 冻结基线）。**下一步：等人类终批 Q3 v2 后进 ACT 1。** 在此之前不写实现代码。

## 决定记录

### 2026-08-05 · Q1：`DeviceKeyStore` 实现落哪个包？

**答案：落 `p2p` 包（`persistence_p2p`）。**

判据是派工给的：「哪个选择让 drift / firebase / assets 都不需要新增密码学依赖」。
- `core` 是纯契约包（`persistence_core`，纯 Dart 契约 + 后端无关编排）。把 Ed25519/AES-GCM 实现放进去会污染纯契约包，且 `core/pubspec.yaml` 目前只有 `crypto`（sha256），加 `cryptography` 会让所有下游包被动引入密码学实现依赖。**排除。**
- `p2p` 已是传输层落点（`LocalSignaling`/`CloudSignaling` 在这层），`DeviceKeyStore` 与设备配对/传输同生共死，放这里自然。`p2p` 已依赖 `bonsoir`+`persistence_core`，加 `cryptography` 是合理增量。
- `drift`/`firebase`/`assets` 都不碰——它们是存储/云适配器，与设备身份密钥无关。

**Q1-补充（人类已批准，含追加约束）**：`BlobCipher` 的 AES-GCM 实现落 `drift`。`BlobCipherRegistry` + `IdentityBlobCipher` + `DefaultBlobCipherResolver` 已在 `drift/lib/blob/`，`LocalBlobStore` 的 drift 实现也在那。AES-GCM cipher 作为 `BlobCipherRegistry.register()` 的入参，自然落在 drift。
- **人类追加约束（写死）**：`drift` 不得因此依赖 `p2p`。DEK 从 `DeviceKeyStore`（在 p2p）流到 drift 的 cipher，走的必须是 core 已有的 `BlobCipherResolver` 端口 + app 组装根注入--即 app 层在启动时把 p2p 造好的 cipher 注册进 drift 的 `BlobCipherRegistry`，**不让 drift 反向 import p2p**。不写死这句，ACT 4 很容易顺手加一条 `drift -> p2p` 的包依赖。
- 这样 `DeviceKeyStore`（身份/配对）在 `p2p`，`BlobCipher`（落盘加密）在 `drift`，DEK 经 app 根注入跨过去，包依赖方向保持 `p2p/drift -> core` 单向。**但 AES-GCM 密钥（DEK）的来源/派生仍是 S6 的活**--见 Q2。

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
- **移动端（iOS/Android）**：Ed25519 私钥**也用 `flutter_secure_storage` 存**（Android Keystore / iOS Keychain，硬件背书，比 app-private 目录强、零额外成本）。
  - ⚠ 人类复核指出原论证自相矛盾：我本想「借 D16 的移动端不补应用层加密」来 justify 裸存 app-private，但 D16 管的是**业务数据落盘加密**、不管身份私钥（这点我已论证在先）。既如此，移动端没有理由不用硬件背书的 secure storage。**采纳人类意见：移动端也用上。**
  - 这与 D15「只在桌面端启用」不冲突：D15 说的是**业务 DEK**（落盘加密用），那条边界是「系统全盘加密是否出厂强制」。身份私钥是另一回事--它是身份凭证不是数据，硬件 Keystore/Keychain 对它本就是最佳归宿。
- **桌面端（macOS/Windows/Linux）**：私钥同样用 `flutter_secure_storage` 存（桌面端没有 D16 的「不补」理由，且全盘加密是用户开关，更需应用层补）。
- **Web**：D18 本期不交付 S6 能力，留空。
- **私钥永不出 `DeviceKeyStore`**：契约的 `sign()`/`verify()` 形状已保证，实现不提供任何导出私钥的方法（A2 守卫）。
- **D17**：每设备一把独立 DEK，严禁跨设备共享落盘密钥（否则容灾模型失效）。

**版本核实（派工 §十.6 要求重跑）**：
- `cryptography`：上一任锁 2.9.0。实查 pub-cache 缓存的是 2.9.0，pub.dev 最新亦为 2.9.0（核实）。**沿用 2.9.0**。
- `flutter_secure_storage`：上一任锁 10.3.1。**待 ACT 1 开工前再实查 pub.dev 确认是否有新版**（不照抄）。

### 2026-08-05 · Q3：channel binding 具体绑什么？（v2 -- 钉死三条歧义）

> v1 被人类打回三条歧义：①签名对象里的 dtlsFingerprint 是谁的没写死；②ChannelBinding 字段冗余/可能不够；③首次配对与每连接 channel binding 混在一起。v2 逐条钉死。

**先把两个目的分开（洞三的答案，先讲清才能讲洞一/二）：**

- **每连接 channel binding**（`Transport.connect`/`advertise` 握手**内部**，自动强制）：握手完成 = 已验证「对端**声明**的证书指纹 == 本端这一腿**观测到**的对端证书指纹」。这是 `connect()` dartdoc「握手必须完成认证密钥交换并绑定指纹到会话」的落地。**每条连接一次，不需用户参与。**
- **首次配对**（跑在 `SignalingChannel` 上，Transport **之前**）：双方交换公钥、Ed25519 挑战-应答、算出**对称**的带外配对指纹供用户肉眼/扫码比对。这是 ACT 2。
- 两者不矛盾：配对在信令层、channel binding 在传输层；但**必须分开写**，否则 A5 MITM 测试不知道测哪个。

**洞一钉死：签名对象签「本端自己证书的指纹」。（方案 A：签自己的）**

- 判据是「两个后端（WebRTC / LAN socket）实现一致」：本端自己的证书指纹是「握手中我方生成、我方确定」的，任何后端都能从自己的 `RTCCertificate.getFingerprints()` / 自己的 TLS socket 证书拿到，**不依赖对端行为、不依赖对端 SDP 何时到**。而「观测到的对端指纹」要等对端 SDP/证书到达，WebRTC trickle ICE 与 LAN 同步 TLS 握手在「何时算观测完成」上天然不同--签自己的让两个后端在**同一时刻、同一来源**产出签名对象，互操作性最稳。
- **MITM 检测机制（方案 A）**：本端签名声明「我的证书指纹是 fp(A_self)」，随公钥经信令发给对端。对端**不验签**这个声明（验签只保证声明未被改、确是 A 发的），而是拿 fp(A_self) 去比自己**这一腿观测到的对端证书指纹** fp(M_observed)：无 MITM 则等；MITM 替换则 M 给两端各发自己的证书，A 声明 fp(A_self)、B 观测到 fp(M_self)，不等 -> **带外比对发现**。这与人类描述的「签自己的 -> 对端拿签名声明的 fp(A) 去比自己观测到的 fp(M')，不等 -> 发现」一致。

**洞二钉死：签名对象 vs 带外配对指纹是两个东西，字段不能混。**

- **channel binding 签名对象**（防 MITM 替换 DTLS，**每连接、不对称**）：`nonce ‖ localCertificateFingerprint ‖ localPublicKeyFingerprint ‖ peerPublicKeyFingerprint`。含本端证书指纹（防替换）。两端各自签自己的、不对称。
- **带外配对指纹**（A3「两端算出**相同**值」，**首次配对、对称**）：`fingerprint = SHA-256( sort([localPubFp, peerPubFp]) )`。**只含双方公钥指纹、不含证书指纹**--因为证书指纹两端不同（每连接 ECDHE 临时协商），含进去就算不出相同值。两端排序后相同。
- 两个目的分开，不互相污染：A3/A4 测配对指纹（对称），A5 MITM 测 channel binding（不对称，靠带外比对发现证书指纹不符）。

**`ChannelBinding` 值类（按洞一/二定稿，删 `algorithm`）：**

```dart
/// 一次握手的 channel-binding 产物：本端在本次握手绑定的传输层证书指纹。
/// 由 Transport 实现在握手完成时产出，供 S6 配对层取本端证书指纹做
/// 带外比对与签名。只持本端指纹（对端指纹由对端自己签、经签名声明过来）。
final class ChannelBinding {
  /// 本端传输层证书指纹，SDP a=fingerprint 格式 'sha-256 AA:BB:...'。
  /// 算法名内联在字符串里，不再单列字段（避免两处不一致、单一来源）。
  final String localCertificateFingerprint;

  const ChannelBinding({required this.localCertificateFingerprint});
}
```

**洞三钉死：`channelBinding` getter 是展示/审计口，绑定强制在 `connect()` 内部。dartdoc 改写（去掉「未认证抛 StateError」--PeerSession 本身即已认证会话，无未认证形态）：**

```dart
abstract interface class PeerSession {
  ... // 既有成员不动

  /// 本端在本次握手时绑定的传输层证书指纹（channel binding）。
  ///
  /// 这是**展示/审计口**：绑定的强制发生在 [Transport.connect]/
  /// [Transport.advertise] 的握手内部（握手必须验证「对端声明的证书
  /// 指纹 == 本端这一腿观测到的对端证书指纹」，否则会话不产出）。本
  /// getter 供 S6 配对层取本端证书指纹做带外比对与签名。
  ///
  /// 因 [PeerSession] 本身即「一条已认证连接上的会话」，访问本 getter
  /// 时握手必然已完成，不存在未认证形态。
  ChannelBinding get channelBinding;
}
```

**A5 MITM 测试测哪个**：测**每连接 channel binding**这条。注入：信令通道被攻破、攻击者替换 SDP 里的 DTLS 指纹 -> 握手时本端观测到的对端证书指纹 ≠ 对端声明的 -> 握手认证失败/会话不产出 -> 配对层发现。这是设计稿 :1078 点名的攻击。首次配对带外比对（A3/A4）另测。

**影响范围（供评审）：**
- 只新增值类 `ChannelBinding`（1 字段）+ 一个只读 getter，不改既有任何成员/签名。
- `transport_contract_test.dart` 的 `_FakePeerSession` 需补 `channelBinding`（测试 fake，非交付物）。
- `peer_stream_contract_suite.dart` 的 fake session 也需补（它实现 PeerSession）。
- 不影响 S1a 的 57 条冻结基线（新成员，不增既有 issue）。
- S3c-c（WebRTC Transport 实现）将来在握手后填这个 getter--这是它的合理职责。

**与可能的 S3c-c preflight 工作的接壤**：本改动只给 S3c-c 留一个 getter 要填，不规定它怎么填（DTLS 指纹来源是它的实现细节）。S6 这边只在配对层用它的产出。若 S3c-c agent 已在做相关 preflight，本提案与之不冲突--它填 getter、我用 getter。

## 踩坑墓地
<只追加不删改。每次失败的尝试必须入墓>

## 冷冻快照
<仅在搁置时由 /hibernate 填写>
