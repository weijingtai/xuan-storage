# Channel Binding 规格（S6 / ACT 3）

- 状态：**已落地（真形态，Q3 v2 已批准）**
- 关联：`core/lib/model/transport.dart`（`ChannelBinding` + `PeerSession.channelBinding`）、
  `core/lib/model/pairing.dart`（契约）、`p2p/lib/device_pairing.dart`
  （配对流程 + `enforceChannelBindingMatches` 握手强制）、任务纪要决定记录 Q3 v2
- 撰写：2026-08-05

## 1. 目的

把「验过签的那个 peer」和「正在传数据的那个 peer」绑定为同一个，防止
**信令被攻破后攻击者替换传输层证书（DTLS/SDP 指纹）** 导致数据流向错误
的对端（设计稿 §5.2b 点名的攻击）。

## 2. 签名对象（钉死）

```
签名对象 = nonce ‖ localCertificateFingerprint
         ‖ localPublicKeyFingerprint ‖ peerPublicKeyFingerprint
```

- 编码：UTF-8，字段间以 `|` 分隔（各字段为 hex 指纹 / hex nonce，不含 `|`）。
- 归属：**签本端自己证书的指纹**（Q3 v2 洞一方案 A）—— 本端证书指纹在
  握手中由本端生成、本端确定，两个后端（WebRTC / LAN socket）都能在同一
  时刻、同一来源产出，互操作性最稳。
- 不对称：两端各自签自己的签名对象，不签对方的。
- 每个配对流程一次：challenge（挑战方）与 answer（应答方）各一条，
  同一 nonce。

## 3. 验证顺序

配对层 `DevicePairingProtocol._verifyBindingEnvelope` 负责信令层可验的三步
（1/2/4）；第 3 步「声明 vs 观测」由握手强制 `enforceChannelBindingMatches`
负责 —— 观测值来自传输层握手，配对跑在信令层、先于传输握手，拿不到：

1. **nonce 一致性**：应答必须原样回传挑战 nonce（防重放/篡改）。
2. **验签**：用对端 offer 里的公钥 PEM 验签名对象 —— 签名覆盖证书指纹，
   攻击者改签名对象必被此步发现（`PairingSignatureError`）。
3. **指纹比对（握手内部，`enforceChannelBindingMatches`）**：对端签名声明的
   证书指纹 ≠ 本端这一腿观测到的对端证书指纹 → `PairingBindingMismatchError`
   （**MITM 发现路径**）。
4. **本端指纹核对**：对端签名对象里的 `peerPublicKeyFingerprint` 必须等于
   本端真实指纹（防对端拿错公钥）。

## 4. 与带外配对指纹的区别（Q3 v2 洞二）

| | channel binding 签名对象 | 带外配对指纹 |
|---|---|---|
| 目的 | 防 MITM 替换传输层证书 | 首次配对供用户肉眼/扫码比对 |
| 频次 | 每连接、每次配对 | 首次配对 |
| 对称性 | 不对称（各自签自己的） | **对称**（两端算出相同值） |
| 内容 | nonce ‖ 本端证书指纹 ‖ 双方公钥指纹 | `SHA-256(sort([localPubFp, peerPubFp]))` |
| 含证书指纹 | 含 | **不含**（两端证书指纹不同，含进去算不出相同值） |

## 5. 本轮落地形态：真 channel binding（Q3 v2 已批准落地）

`Transport` 契约已新增 `ChannelBinding` 值类与 `PeerSession.channelBinding`
getter（`core/lib/model/transport.dart`，本轮改动，既有成员未动）。

- **本端指纹来源**：配对层构造注入 `ChannelBinding`（`localCertificateFingerprint`
  字段，`sha-256 AA:BB:...` 格式）—— 生产实现取 `PeerSession.channelBinding`
  （S3c-c 握手后填充），该指纹进入签名对象并被本端私钥签名。
- **验证侧（怎么验）**：`enforceChannelBindingMatches()`（`p2p/lib/device_pairing.dart`）
  把配对产出的对端声明指纹（`PairingResult.peerDeclaredCertificateFingerprint`，
  验签后可信）与本端这一腿**观测到**的对端证书指纹比对 —— 不等抛
  `PairingBindingMismatchError`（MITM 发现路径）。
- **强制位置**：`Transport.connect/advertise` 握手**内部**调用
  `enforceChannelBindingMatches`（Q3 v2 洞三：握手必须验证「对端声明的证书
  指纹 == 本端这一腿观测到的对端证书指纹」，否则会话不产出）。这是 S3c-c
  的职责（任务纪要 Q3 v2「影响范围」）；比对函数本体在 S6 交付并有测试守着。
- **遗留**：S3c-c 实现 `connect/advertise` 时从自己握手的证书观测值调用本函数，
  配对层不需要任何「承诺指纹」注入。

## 6. MITM 攻击面与检测（ACT 6 / A5）

攻击者 M 站在 A 与 B 之间，替换传输层证书：

- M 给 B 的腿发**自己的证书** → B 观测到 fp(M_self)；A 声明 fp(A_self)。
- B 第 3 步比对：fp(A_self) ≠ fp(M_self) → `PairingBindingMismatchError`。
- 攻击者若改签名对象 → 第 2 步验签失败 → `PairingSignatureError`。

两条路径都在 `p2p/test/device_pairing_test.dart` 以**真注入**方式覆盖
（A5 走真路径：完整配对 + 传输层观测被替换 + 握手强制发现；篡改 nonce 走
信封篡改路径），不许「构造不同指纹断言 !=」。

## 7. 测试覆盖

| 场景 | 测试 |
|---|---|
| 声明与观测一致 → 绑定通过 | `完整配对成功：两端各自产出对端声明指纹，声明与观测一致 → 绑定通过` |
| 声明 ≠ 观测 → 发现 | `声明 ≠ 观测 → enforceChannelBindingMatches 抛 PairingBindingMismatchError` |
| 篡改签名对象 → 验签失败 | `篡改签名对象（nonce）→ 应答方 PairingSignatureError` |
| MITM 真注入 → 发现 | A5 · MITM 负向测试（真注入，真路径） |
