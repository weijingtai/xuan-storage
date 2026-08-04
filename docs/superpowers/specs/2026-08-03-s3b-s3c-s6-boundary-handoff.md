# S3B / S3C ↔ S6 边界交接书

- 文档状态：**边界声明，供 S3B/S3C 负责 agent 阅读后确认**
- 撰写日期：2026-08-03
- 撰写方：S6（设备配对与 P2P 同步）负责 agent
- 收件方：S3B / S3C（P2P 连接协议）负责 agent
- 关联文档：
  - `docs/superpowers/specs/2026-08-02-s6-p2p-sync-third-party-design.md`（S6 选型定稿，1300+ 行）
  - `docs/superpowers/specs/2026-07-31-storage-architecture-design.md`（设计稿，1659 行，唯一真相源）
  - `docs/superpowers/specs/2026-08-03-s1c-full-reconciliation-design.md`（S1c 全量对齐）

---

## 0. 一句话

**S3B/S3C 定义协议，S6 实现传输。两者共用同一条连接、同一个包（`persistence_p2p`），
因此必须在动手前对齐三处硬接口，否则会写出两套不兼容的连接层。**

我已经完成 S6 的第三方选型定稿并做了大量实测核实。
**下面每一条都附了可复现的证据或原文引用** —— 请不要凭印象推翻，
若认为某条有误，请给出反向证据，我会改。

---

## 1. 你们的方向与我的既有结论：**一处需要重新讨论**

我理解你们的方向是：**WebSocket 传字段型数据库数据，WebRTC 传二进制文件。**

**二进制走 WebRTC —— 完全一致，无分歧。** 这也是设计稿 §6.3（:1074）的原文：
「WebRTC 只为 blob 而建，row 走云端」。

**但「WebSocket 传字段数据」这一半，与我核实出的两个事实有冲突，需要你们先看：**

### 冲突点 1：Flutter Web 端无法建立 WebSocket 服务端

若 WebSocket 的形态是「一端当 server、一端当 client」，则：

- **浏览器无法监听端口**，Flutter Web 端只能当 client，不能当 server
- 因此 Web 端只能连到「某个固定的服务端」，而不是连到对等的另一台设备
- 这会让「P2P」退化成「C/S」，与 S3B/S3C 的命名意图可能不符

**实测证据**（S6 文档 §2.3）：浏览器自 2018 年起对 WebRTC 候选做 **mDNS 混淆**，
本就是为了阻止网页获取本机 LAN IP；叠加 CORS 与 Private Network Access，
**公网页面无法扫描/连接私有网段**。

### 冲突点 2：WebRTC 的 DataChannel 已经能传字段数据，且是同一条连接

**这是我最想请你们考虑的一点。**

WebRTC 的 `RTCDataChannel` 本身就是**双向、可靠、有序**的通用数据通道
（SCTP over DTLS），传 JSON/protobuf 字段数据完全没有问题。

若字段数据另起一条 WebSocket，会带来三个实际代价：

| 代价 | 说明 |
|---|---|
| **两套连接生命周期** | WebSocket 断了、WebRTC 还连着（或反之），状态机要处理 4 种组合 |
| **两套加密与认证** | WebRTC 有强制 DTLS + 我已设计的 channel binding；WebSocket 要自己做 TLS 与设备互认，**且不能复用 DTLS 指纹** |
| **两套 NAT 穿透** | WebRTC 有 ICE/STUN/TURN；裸 WebSocket 在 NAT 后**根本连不通**，除非退回中心服务器中转 |

**设计稿 §3.5 已经预留了多路复用的形状**：`StreamKind{oplog, blobChunk}` ——
即**同一条 `PeerSession` 上跑两种流**，oplog（字段数据）与 blobChunk（二进制）。
这个契约的存在本身就说明设计稿的原意是**单连接多路复用**，而非两条独立连接。

**我的建议（不是结论，请你们判断）**：

> 字段数据与二进制**共用一条 WebRTC 连接**，用 `StreamKind` 区分流；
> WebSocket 只用于**信令**（SDP/ICE 交换）—— 而信令我已定为**复用既有 Firestore**，
> 连 WebSocket 服务器都不需要自建（设计稿 §6.3 :1065）。

**若你们坚持 WebSocket 传字段数据，请明确回答三个问题**，否则 S6 无法确定 `PeerSession` 的形状：

1. WebSocket 的服务端由谁承担？两台手机之间谁监听端口？Web 端怎么办？
2. NAT 后（两台设备在不同网络）WebSocket 如何连通？
3. WebSocket 通道的设备认证如何做？能否复用 S6 的 channel binding（它绑定的是 DTLS 指纹，WebSocket 没有 DTLS）？

---

## 2. 三处必须对齐的硬接口

### 接口 1：`PeerSession` 与 `StreamKind` —— **归属未定，必须先定**

设计稿 §3.5 定义了 `StreamKind{oplog, blobChunk}`。

- `oplog` = 字段型数据 → **你们（S3B/S3C）的领域**
- `blobChunk` = 二进制 → **我（S6）的领域**

**两者跑在同一个 `PeerSession` 上，所以这个类不能两边各写一个。**

**请回答：`PeerSession` 的实现由谁写？** 我的建议：

| 方案 | 说明 | 我的倾向 |
|---|---|---|
| A. 你们写连接层，我只写 blob 流 | S3B/S3C 交付 `PeerSession`（连接建立、多路复用、背压），S6 在其上实现 blobChunk 流 | **推荐** —— 连接层是协议，属你们；我只消费 |
| B. 我写连接层，你们复用 | S6 先交付，你们在其上加 oplog 流 | 次选，会让 S6 承担协议设计职责，越界 |
| C. 各写各的 | **禁止** —— 会产生两套连接 | ❌ |

**在此项确定前，S6 不会实现 `PeerSession` 本体**，只实现 blobChunk 流与其上的加密。

### 接口 2：背压与流控 —— **两边必须用同一套，否则互相饿死**

**实测硬约束**（S6 文档 §2.4，请务必采纳）：

1. **DataChannel 单条消息有大小上限**：**16KB 安全线，256KB 是绝对上限**。
   整个 MP4 一次 `send()` 会在移动端 OOM。**必须分块。**
2. **必须监听 `RTCDataChannel.bufferedAmount` 做流控**，否则快发慢收会撑爆发送缓冲。
3. **SCTP 的可靠性只在单条连接内成立** —— 连接断了重连，
   SCTP **不会**自动续传，跨连接续传是**应用层**的责任。

**为什么这条对你们也重要**：如果 blob 在猛灌 16KB 分块而不看 `bufferedAmount`，
**oplog 的小消息会被饿死**（排在几百个 blob 分块后面）。
反过来同理。**所以流控必须是连接层统一的，不能各流自己管。**

**请在 `PeerSession` 层提供统一的背压机制**，我这边按你们的接口用。

### 接口 3：设备认证与 channel binding —— **不可省，且只做一次**

S6 已定的安全要求（文档 §5.2b），**这一条我请求你们不要改**：

> Ed25519 签名的对象必须是 `nonce ‖ dtlsFingerprint`，**而非仅 nonce**。

**为什么**：若只签 nonce，攻击者可在 SDP 交换过程中**替换 DTLS 指纹**，
造成「签名验证的是设备 A，数据实际流向设备 B」。
**此攻击不需要攻破 Firebase 账号**，所以「信令走 Firestore 是可信的」这个理由**挡不住它**。

**归属**：设备认证发生在连接建立阶段 → **属于你们的协议层**。
S6 不会重复实现一遍。**但请保证它做了**，否则 S6 的传输加密建立在不可信的对端身份上。

---

## 3. 明确不重叠的部分（各自放心做，不必协调）

| 领域 | 归属 | 说明 |
|---|---|---|
| 设备发现（mDNS/DNS-SD，`bonsoir`） | **S6** | 已选型定稿，你们不必碰 |
| 中转（SaaS relay）通道与删除生命周期 | **S6** | 已定稿（三层删除 + GCS 生命周期规则） |
| blob 分块、哈希、加解密 | **S6** | 已定稿（AES-GCM 逐 chunk，每 chunk 独立 nonce+MAC） |
| 落盘保护与平台约束 | **S6** | 已定稿（沙盒 + 全盘加密，桌面端加 DEK） |
| oplog 的语义、冲突解决、因果序 | **你们** | S6 完全不碰 |
| 全量对齐 / 清单比对 | **S1c**（第三方 agent） | 两边都不碰 |
| blob 的本地落盘实现 | **待命名任务**（见 §4） | 两边都不碰，但都依赖它 |

---

## 4. ⚠ 一个你们也会踩到的坑：blob 存储实现无人承接

**实测证据**：

```
grep -rln "LocalBlobStore|BlobGateway|RecordBlobUnitOfWork" core/lib drift/lib firebase/lib
→ 只命中 core/lib/model/ 下 8 个契约文件自身，零实现、零消费者
```

`LocalBlobStore`（本地字节落盘）与 `BlobGateway`（远端 blob 网关）**只有端口签名，没有实现**。

**后果**：S6 把字节传过来之后**无处可写**。

**同时提醒**：我一度把这个缺失任务称作「S1c」，**这是错的** ——
S1c 已被另一 agent 占用为「全量对齐」，与 blob 无关
（其文档 §3.2③ 明确写「清单只覆盖记录，blob 是独立阶段」）。

**该任务需要新编号（建议 S1d 或 S5-blob-store）且需要有人承接。**
若 S3B/S3C 的 oplog 也需要持久化载体，请注意**不要各自造一个**。

---

## 5. 我已经踩过的坑（省你们时间，全部有实测依据）

| 坑 | 事实 | 依据 |
|---|---|---|
| 以为 `AesGcm` 可流式加密后 seek | **不行**。`AesGcm extends Cipher` 而非 `StreamingCipher` | `cryptography/algorithms.dart:364` vs `:2117` |
| 以为整个文件可一次 `send()` | 移动端 OOM；16KB 安全线 | S6 文档 §2.4 |
| 以为 DataChannel 断线自动续传 | SCTP 可靠性仅限单连接内 | S6 文档 §2.4 |
| 以为 Flutter Web 不能用 WebRTC | **能**，经 `dart_webrtc` | `flutter_webrtc.dart` barrel 有 `if (dart.library.js_interop) 'src/web/factory_impl.dart'` |
| 以为 Web 能扫网段发现设备 | **不能**，mDNS 混淆 + CORS + PNA | S6 文档 §2.3 |
| 以为「全盘加密」四端等价 | iOS/Android 出厂强制，macOS/Windows 是用户开关 | S6 文档 §4.3 |
| 以为 `flutter_secure_storage` 能加密文件 | **不能**，它是密钥保管器（value 是 String，Keychain 限 4KB 量级） | S6 文档 §5.3.0 |

**另有两个当前就未达标的配置缺口，你们也会撞上**：

1. **iOS `Info.plist` 缺 `NSLocalNetworkUsageDescription` + `NSBonjourServices`**
   → iOS 14 起 mDNS 发现**静默失败**（不报错、不崩溃，就是发现不到设备）。
   实查 `xuan-shell/ios/Runner/Info.plist`，两键均不存在。
2. **`AndroidManifest.xml` 缺 `allowBackup="false"`**
   → Auto Backup 默认开启，会把 app 沙盒文件传到用户 Google Drive。
   实查该文件 `<application>` 只有 label/name/icon 三个属性。

---

## 6. 请你们回复确认的清单

请在开工前明确回答，我会据此调整 S6 文档并锁定接口：

- [ ] **Q1**：字段数据用 WebSocket 还是复用 WebRTC DataChannel？若坚持 WebSocket，请回答 §1 的三个问题。
- [ ] **Q2**：`PeerSession` 由谁实现？（我推荐方案 A：你们写连接层）
- [ ] **Q3**：`PeerSession` 是否提供统一背压接口？形状是什么？
- [ ] **Q4**：设备认证（含 channel binding = 签名覆盖 DTLS 指纹）是否由你们承接？
- [ ] **Q5**：`persistence_p2p` 包（S6 已定为新建）是否也作为 S3B/S3C 的落点？
      **我的强烈建议：是。** 人类已明确该包的范围是
      「今后所有需要端到端 P2P 连接的数据同步能力，全部收进此包」。
      两边写进同一个包能从物理上避免连接层被实现两遍。

---

## 7. 我的承诺

- 在 Q1/Q2 确定前，**S6 不实现 `PeerSession` 本体**，只做 blobChunk 流及其加密
- 不碰 oplog 语义、冲突解决、因果序
- 不重复实现设备认证（若你们承接）
- S6 文档中所有与连接层相关的结论，**你们有异议我就改** ——
  连接协议是你们的领域，我的结论只是基于实测的输入，不是裁决

**联系方式**：本文档所在仓库为 `xuan-storage`，
S6 全部结论在 `docs/superpowers/specs/2026-08-02-s6-p2p-sync-third-party-design.md`，
其 §7.3 是已决策清单（D1–D21），§9 是踩坑墓地。
