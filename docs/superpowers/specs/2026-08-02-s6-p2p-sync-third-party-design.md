# S6 设备配对与 P2P 同步 —— 第三方方案选型与落地设计

- 文档状态：**选型定稿，待转译为 ACT**
- 撰写日期：2026-08-02，末次修订 2026-08-03
- 上游规格：`docs/superpowers/specs/2026-07-31-storage-architecture-design.md`（下称「设计稿」，1659 行）
- 本文关系：设计稿 §6 与 §10 把「E2EE 密钥派生形式」「LAN/WebRTC transport 实现」列为**待决**，本文档给出决议。
  本文档**不推翻**设计稿的分层与端口，只填实现选型。
- 前置阅读：§1 是全部判断的事实基线（实测），§2 是已否决路线（防止重复提出），
  §4.5 是本轮**不实现**但完整保留的两套未来方案。

---

## 0. 一句话结论

S6 全部能力可由**四个成熟 pub.dev 包**覆盖，**零原生代码、零自建服务器、零商业授权**：

| 能力 | 选定方案 | 实测评分 |
|---|---|---|
| 局域网设备发现 | `bonsoir` 7.1.4 | 160/160，MIT，5 平台（Web 除外） |
| 跨网段连接 + 大文件传输 | `flutter_webrtc` 1.5.2 + `dart_webrtc`(Web) | 150/160，MIT，月下载 22.1 万 |
| 信令交换 | 既有 Firestore（零新增基建） | — |
| 设备互认 + 中转加密 + 落盘加密 | `cryptography` 2.9.0 | 150/160，Apache-2.0，**唯一支持 Web 的全套方案** |
| 桌面端 DEK 保管 | `flutter_secure_storage` 10.3.1 | 150/160，BSD-3，**仅桌面端启用**（见 §5.3） |

**加密的最终形态 —— 三层各自解决，落盘层分平台：**

| 层 | 方案 | 代码量 |
|---|---|---|
| 传输（直连） | WebRTC 的 DTLS（强制，无法关闭，天然前向保密） | **零** |
| 传输（中转） | 一次一密的临时密钥包装（§4.2） | 少量 |
| 落盘 · iOS/Android | **App 沙盒隔离 + 系统全盘加密**（§4.3，含三条硬约束） | **零** |
| 落盘 · macOS/Win/Linux | 同上，**再加** AES-GCM 加密 + DEK 存系统密钥库（§5.3） | 少量 |
| 落盘 · Web | **【留空，待人类补】**（D18） | — |

> **落盘层为什么分平台**：iOS 的 Data Protection 与 Android 的 FBE **出厂强制开启且关不掉**；
> macOS 的 FileVault 与 Windows 的 BitLocker 是**用户开关，可能整个没开**。
> 桌面端的第二层可能不存在，必须由应用层补回来。
> **分界线是「系统全盘加密是否出厂强制」，不是「移动 vs 桌面」这个直觉。**

**不需要**的东西（曾被候选方案或设计稿要求，经核实为多余或已被决策移除）：
Rust 工具链、`axum`/`webrtc-rs`/`ed25519-dalek`、局域网 WebSocket Hub、自建 coturn、
Syncthing 原生集成、Ditto 商业授权、Master Key / Wrapped Key、恢复码、PBKDF2/Argon2id、
带外指纹人肉比对。

**本轮明确保留的三项安全硬要求**（不可省，否则方案有实质漏洞）：

1. **channel binding** —— Ed25519 签名对象必须包含 DTLS 指纹，而非仅 nonce（§5.2b）
2. **§4.3 的三条落盘约束** —— 只落 app-specific 目录、禁写系统相册、Android 关 Auto Backup
3. **每设备一把独立 DEK** —— 严禁跨设备共享落盘密钥（D17），否则容灾模型失效（§5.3.4）

**四项前置修复**（当前实查为未达标，见 §7.1b）：
Android `allowBackup="false"`（P1，不修则私有数据静默上 Google Drive）、
iOS 本地网络权限键（P2，不修则 LAN 发现静默失败）、
macOS `keychain-access-groups`（P3）、`persistence_core` 的 `dart:io`（P4，阻断 Web 编译）。

---

## 1. 核实基线：本项目的真实端侧构成

**本节全部为实测结果，是后续所有判断的依据。凡与本节冲突的方案一律作废。**

### 1.1 当前零 Rust，但 Rust 端是未来版本的规划目标

**当前状态**（实测）：

```
find . \( -name "Cargo.toml" -o -name "*.rs" \)   → 0 结果
find . -type d -name "src-tauri"                  → 0 结果
grep -rn "flutter_rust_bridge|rinf|tauri" pubspec  → 0 结果
```

唯一出现 "rust" 字样的位置是 `docs/superpowers/specs/2026-05-21-digital-twin-team-design-v1.5.md:42`
的多语言假设。

**未来规划**（人类于 2026-08-02 确认）：**Rust 端将在未来版本中加入。** 因此本文档
不能按「永远只有 Dart」来设计协议。

**这条更正带来一个真实的架构约束**（而非仅仅是收益）：

> **所有跨设备协议必须是线上可互操作的标准协议，不得依赖 Dart 特有的序列化或私有握手。**

具体含义：设备发现用 **mDNS/DNS-SD**（标准）、身份认证用 **Ed25519 签名**（RFC 8032）、
传输用 **WebRTC DataChannel**（W3C/IETF）、加密用 **AES-GCM / X25519 / HKDF**（NIST/RFC）。
这样未来的 Rust 端可用 `webrtc-rs` + `ed25519-dalek` + `ring` 直接按协议接入，
**不需要改动任何已交付的 Dart 端代码，也不需要写 FFI 绑定**。

候选方案主张「用三大国际标准以便将来接入异构端」这一点**因此成立**，本文档采纳。
（它给出的理由「避免写 FFI」表述不准确 —— 真正的价值是**协议层解耦**，
即两端各自用本语言的标准库实现同一份线上协议，而非通过 FFI 共享同一份实现。）

### 1.2 交付平台：4 个，不含 Windows / Linux

主应用是 `xuan-shell`（`xuan-shell/pubspec.yaml:1` `name: xuan_shell`，入口 `lib/main.dart`）。

| 平台 | 目录存在 | git tracked 文件数 |
|---|---|---|
| `web/` | 是 | 10 |
| `macos/` | 是 | 33 |
| `ios/` | 是 | 44 |
| `android/` | 是 | 20 |
| `windows/` | **否** | — |
| `linux/` | **否** | — |

`xuan-qizhengsiyu` 自身无平台目录（是库包 `name: qizhengsiyu`），平台目录只在其 `example/` 下。

另有一个**独立的非 Flutter Web 端** `xuan-web/`（uni-app / Vue，`package.json` 有 `build:h5`
及各家小程序脚本），与 Flutter 代码零共享，**不在本文档范围内**。

### 1.3 Flutter Web 是真实交付目标

支持证据：

- `xuan-shell/web/sqlite3.wasm`（689.8K）与 `web/drift_worker.js`（350.8K）**已 commit** —— drift on web 的真实运行时产物
- `xuan-shell/lib/storage/shell_storage_bootstrap.dart:50-51,62-63` 显式引用上述两个文件
- `xuan-shell/lib/firebase_options.dart:10` `if (kIsWeb) return web;` —— Web 有独立 Firebase 配置
- `xuan-shell/web/firebase.json` 有 Web 端 App ID
- `xuan-storage/drift/lib/{four_zhu_card_templates,ai}/connection.dart:2` 已就位 `if (dart.library.js_interop) 'web.dart'`

**但 Web 尚无 CI 门禁**：`xuan-shell/.github/workflows/ci.yml` 只跑 `tools/ci/check_a3_acceptance.sh`，
该脚本仅含 CJK scan / `flutter analyze` / `flutter test`，**无 `flutter build web`**。
该门禁曾被规划（`docs/launch-plan/fzc-tl/AUTOPLAN-REVIEW-2026-07-19.md:116` 的 N4 项）但未落地。

> **⚠ 遗留风险（不属 S6，但会绊倒 S6）**：`persistence_core` 有 2 处 `dart:io`，**会阻断 Web 编译** ——
> `core/lib/configuration/yaml_file_loader.dart:1` 与 `core/lib/configuration/sync_configuration_manager.dart:3`
> （后者 `:245` 自己写明「仅适用于具备 IO 能力的平台（非 Web）」）。
> S6 若要在 Web 上跑，必须先解决这两处的条件导入。**建议独立成一个前置修复任务，不塞进 S6。**

### 1.4 认证方式：只有匿名 + 邮箱密码，无任何 OAuth

唯一生产实现 `xuan-storage/firebase/lib/account/firebase_account_auth_gateway.dart` 实际调用：

| API | 行号 |
|---|---|
| `_auth.signInAnonymously()` | :27 |
| `_auth.signInWithEmailAndPassword(email:, password:)` | :47 |
| `_auth.createUserWithEmailAndPassword(email:, password:)` | :70 |
| `EmailAuthProvider.credential` + `user.linkWithCredential` | :93, :104 |
| `_auth.sendPasswordResetEmail(email:)` | :121 |
| `user.updatePassword(newPassword)` | :146 |
| `user.delete()` | :162 |

**0 命中**（在本项目非 build/ 源码中）：`GoogleAuthProvider`、`AppleAuthProvider`、
`verifyPhoneNumber`、`signInWithCustomToken`、`signInWithCredential`、`signInWithPopup`；
pubspec 中也无 `google_sign_in` / `sign_in_with_apple`。

端口契约同样只有这些：`repository-interface-account/lib/src/ports/account_auth_gateway.dart`。

UI 侧确实持有明文密码字符串：`xuan-account/lib/pages/auth_page.dart:263-265`、`:328-330`、`:386-387`。

**推论**：本轮方案**不使用密码派生密钥**（§4 一次一密），故本节事实对当前实现无约束。
但它是 §4.5 未来预留方案 A（Master Key）的技术前提，故记录在案：
注册用户客户端持有明文密码，可做 PBKDF2/Argon2id 派生；
**匿名用户没有密码，方案 A 对其不可用**（决策 D1 已定：匿名用户不启用同步与加密）。

### 1.5 既有 P2P 代码：只有端口契约，零实现

全部集中在 `xuan-storage/core`（S1a 产物）。全仓 grep
`DataChannel|RTCPeerConnection|signaling|bonjour|NSNetService|multicast_dns|_tcp.local`
（含 `.dart/.swift/.kt/.plist`）→ **0 命中**。

已存在的形状：

- `core/lib/model/storage_classification.dart:25` `enum Channel { cloud, lan, webrtc, manualExport }`
- `core/lib/model/transport.dart:143` `abstract interface class Transport`（`:11` 注明「本文件零实现」，
  `:147` 注明「LAN 走 mDNS；WebRTC 走信令」），含 `StreamKind{oplog, blobChunk}`、
  `PeerIdentity{deviceId, publicKeyFingerprint}`、`DiscoveredPeer`、`PeerSession`
- `grep "implements Transport|extends Transport"` 于全部 lib 目录 → **0 个实现**
- `core/lib/model/blob_cipher.dart:5` 注明「密钥【派生】属 S6，但密钥【上下文的端口形状】必须在 S1a 定死」

### 1.6 现有依赖缺口

| 包 | 直接 | 传递 | 备注 |
|---|---|---|---|
| `flutter_webrtc` | 无 | 无 | **需新增** |
| `bonsoir` | 无 | 无 | **需新增** |
| `cryptography` | 无 | 无 | **需新增** |
| `web_socket_channel` | 无 | 有 | 本方案不需要 |
| `dio` | 有（xuan-ai 等 4 处） | 有 | 本方案不需要 |
| `crypto` | 有（xuan-ai 2 处） | 广泛 | 只做 sha256，不做加密 |
| `pointycastle` | 无 | 有（`firebase/pubspec.lock:504-505`） | 备选，见 §4.4 |
| `flutter_secure_storage` | **仅 example** | 无 | `xuan-ai/example/pubspec.yaml:19`；主包与 shell 都没有 |
| `firebase_storage` | 无 | 无 | S2 需要（不属本文档） |
| `encrypt` / `cryptography_flutter` / `nsd` / `multicast_dns` | 无 | 无 | — |

---

## 2. 被否决的候选方案及理由

本节记录**已排除**的路线，防止后续重新提出。每条都有实测依据。

### 2.1 「Rust 桌面端当局域网 Hub」—— 架构上多余（与有无 Rust 无关）

该方案要求 Rust 端用 `axum` 开局域网 WebSocket 服务器，其余 Flutter 端全部作为客户端。

**否决理由不是「现在没有 Rust」**（§1.1 已更正：Rust 是未来目标），而是该架构**自相矛盾**：

方案自己承认跨网段场景**必须在公网部署信令服务器**。而一旦有了公网信令，
局域网再架一个 WebSocket Hub 就是**把同样的 SDP/ICE 交换实现两遍** ——
两套信令协议、两套重连逻辑、两套错误处理，且要处理「设备从 LAN 切到蜂窝时如何在两套信令间迁移」。

**这与是否引入 Rust 完全无关。** 即使将来有了 Rust 桌面端，也不应让它当 LAN Hub。

**结论：信令只有一套，走 Firestore（§3.2）。未来的 Rust 端同样作为对等 peer 接入，不承担中心角色。**

> **附带好处**：不设中心 Hub 意味着**没有单点故障** —— 桌面端没开机时，手机与平板之间仍可直连。

### 2.2 「Flutter Web 不能用 WebRTC」—— 事实相反

`flutter_webrtc` 的 `flutter.plugin.platforms` 实测确实**不含 web**（只有 android/ios/macos/windows/linux/elinux）。
但其 barrel 文件 `lib/flutter_webrtc.dart` 是条件导入：

```dart
export 'src/native/factory_impl.dart'
    if (dart.library.js_interop) 'src/web/factory_impl.dart';
```

Web 分支落到依赖包 `dart_webrtc`（pub.dev tags 实测 `platform:web`，月下载 274078）。
**浏览器原生就有 WebRTC 实现，不需要 Flutter 插件** —— Web 是 WebRTC 支持最好的平台，不是最差的。

浏览器真正的限制只有两条：**不能监听端口**、**不能发 UDP/mDNS**。
而 WebRTC 架构中**任何 peer 都不需要监听端口**（连接由 ICE + 信令建立），所以第一条限制不影响 WebRTC，
只影响 LAN 发现（见 §2.3）。

**结论：Web 参与 WebRTC，走 Firestore 信令。**（决策 D3）

### 2.3 「Flutter Web 扫网段发现设备」—— 技术上不可能

该方案称 Web 端可「通过前端 API 获取自己的局域网网段，然后 dio 并发扫描 254 个 IP」。

两处硬阻断：

1. **浏览器没有任何 API 能获取本机局域网 IP。** 历史上可通过 WebRTC 的 ICE candidate 泄露本地 IP，
   但主流浏览器自 2018 年起启用 **mDNS candidate 混淆** —— 本地 IP 被替换为随机 `xxxxxxxx.local`。
   这项措施的**设计目的正是阻止此类探测**。
2. 即使已知网段，浏览器的 **CORS + Private Network Access** 策略会拦下 public→private 请求
   （Chrome 已对此类请求要求预检）。

**结论：Web 端放弃 LAN 发现，只走 Firestore 信令。**（决策 D3）

### 2.4 「DataChannel 自动断点续传，整个 MP4 直接 send()」—— 两处会崩

**① 断点续传不会自动获得。** DataChannel 建在 SCTP 上，SCTP 提供有序可靠传输 + 分片 + 拥塞控制，
但**这些保证只在单次连接存活期间成立**。连接断开（切网、锁屏、进电梯）后已传字节全部作废，
重连必须从 0 开始。真正的跨连接续传必须由应用层记录「已收到哪些 chunk」——
**这正是设计稿 §6.1（:1046）的 chunk 独立 sha256 设计**，也正是 S1a 已交付的
`BlobStatus.partial` 与 `BlobPartial(Set<int> presentChunks)`（`core/lib/model/blob_types.dart:92,188`）存在的理由。

**② 整文件 `send()` 会 OOM。** DataChannel 单条消息有大小上限（实践安全值 16KB，
上限 256KB 且受两端协商影响）。把「几个 G 的 MP4 读成 `Uint8List`」在移动端会直接
内存溢出崩溃 —— 一个 2GB 文件需要 2GB 连续堆内存。

**结论：必须按 chunk 传输（§3.3），且续传逻辑属应用层。这一条把设计稿 §6.1 的必要性从「可选优化」升级为「硬要求」。**

### 2.4b 「Master Key + Wrapped Key」—— 设计本身正确，但本轮不需要

候选方案给出的 Master Key 设计**在密码学上是正确的**（即 1Password / Bitwarden 的通行做法），
且 §1.4 实测确认本项目登录走邮箱密码、客户端持有明文密码字符串，**技术前提也成立**。

**但它解决的问题在本方案中不存在。** Master Key 的全部价值来自「密文长期存储」这一前提；
人类决策把密文存活期压到 5 分钟以内（§4.1），该前提消失。完整论证见 §4.1，
方案本身与触发条件完整保留在 §4.5 供未来使用。

候选方案另有两处需要指出：

1. **一句话把 TOFU 问题藏起来了**：「用户登录时，云端已经相互备份了彼此的公钥」——
   能写云端的人就能替换公钥。本文档 §5.2 对此作显式判定，不回避。
2. **完全没有讨论三个真实边界**：匿名用户无密码（`signInAnonymously`，`:27`）、
   忘记密码等于丢数据（`sendPasswordResetEmail`，`:121`）、Web 端无安全存储。
   这三条在 §4.5 方案 A 的「代价」清单中逐条列明 —— 它们是采用该方案必须一并接受的成本。

### 2.5 参考内容可靠度评估

候选方案中 `stun:://google.com` 这一写法出现两次。**正确形式为 `stun:stun.l.google.com:19302`** ——
协议 scheme 后不应有 `//`，且 `google.com` 本身不是 STUN 服务器。这表明该内容未经实际运行验证。

因此其中「约 70% 打洞成功率」等数字不予采信。**本文档采用设计稿 §6.3（:1064）的口径：
STUN 直连约 80–90%（对称型 NAT 打不通），TURN 兜底后接近 99%。**

### 2.6 其他曾评估并排除的第三方整体方案

| 方案 | 排除理由（实测） |
|---|---|
| Syncthing sidecar | 功能完全匹配（MPL-2.0 免费、TLS 1.3 强制、块级续传），但 **pub.dev 零 Dart 绑定**，需 2–6 人周原生集成（Go/Swift/Kotlin），且不支持 Web |
| Ditto | 文件同步是一等公民且有进度回调，但 ① `privateKey` 默认 `null`，源码文档原文 "no encryption is used in transit" ② 即使纯离线 P2P 也需 `setOfflineOnlyLicenseToken` 商业授权 ③ likes 仅 15，专有二进制无源码 |
| Couchbase Lite | P2P 为 Enterprise 独占（源码 `enum EnterpriseFeature { ..., peerToPeerSync }` + `useEnterpriseFeature` 抛 `StateError`），Flutter 绑定社区维护（`cbl_flutter_ee` likes 1），近一年无发版 |
| `dart_libp2p` | 23 stars / 17 open issues / 5 个月无提交；依赖 `dcid`(likes 1) 与 5 年未更新的 `x25519` |
| LocalSend | 不是 pub 包（pub.dev 零结果，`packages/core/pubspec.yaml` 404）；其 HTTP server 与 mDNS 已用 Rust 重写 |
| Matrix / Signal 协议线 | 许可证污染：`vodozemac`/`flutter_vodozemac`/`matrix`/`flutter_olm` 为 **AGPL-3.0**，Signal 线为 **GPL-3.0**，与闭源移动分发冲突 |
| `sodium` | BSD-3 + ISC，160/160，本可用于 Native，但**含 FFI 因此不支持 Web**，与 §1.3 冲突 |

---

## 3. 选定架构

### 3.1 全景

```
              全端 Flutter（Android / iOS / macOS / Web；Rust 端为未来版本）
                    零原生开发 · 零自建服务器 · 零商业授权
              协议全部为标准协议，未来 Rust 端可直接互操作（§1.1）

  ┌─ 设备发现 ────────────────────────────────────────────────┐
  │  同网段  →  bonsoir (mDNS/DNS-SD)   【Native 三端】        │
  │  跨网段  →  Firestore 在线设备表     【全部四端，含 Web】   │
  │  Web     →  只走 Firestore（浏览器不可能做 mDNS，见 §2.3）  │
  │  ⚠ 无中心 Hub —— 桌面端没开机时手机与平板仍可直连（§2.1）    │
  └────────────────────────────────────────────────────────────┘
                              ↓
  ┌─ 设备互认（Ed25519 挑战-应答，RFC 8032）────────────────────┐
  │  cryptography 的 Ed25519；公钥存 Firestore + 安全规则限 uid │
  │  ✅ channel binding：签名对象 = nonce ‖ DTLS指纹（§5.2b 必做）│
  │  ❌ 不做带外指纹人肉比对（砍掉设计稿 §6.3 :1072，见 §5.2）    │
  └────────────────────────────────────────────────────────────┘
                              ↓
  ┌─ 传输 ─────────────────────────────────────────────────────┐
  │  信令   →  Firestore（一个 collection 换 SDP / ICE）        │
  │  连接   →  flutter_webrtc（Native）/ dart_webrtc（Web）     │
  │  加密   →  DTLS（强制，无法关闭，每次连接 ECDHE 前向保密）   │
  │  STUN   →  公共免费服务（stun:stun.l.google.com:19302 等）   │
  │  TURN   →  SaaS 中转兜底（§3.4；仅此路径需应用层加密）       │
  │  分块   →  16KB chunk + bufferedAmount 流控（§3.3 硬要求）   │
  │  续传   →  chunk 独立 sha256，复用 S1a BlobStatus.partial    │
  └────────────────────────────────────────────────────────────┘
                              ↓
  ┌─ 中转加密（仅当无法直连时，§4.2）──────────────────────────┐
  │  一次一密：随机 DEK 加密文件；X25519+HKDF 包装 DEK           │
  │  会话密钥临时生成、用完即弃 → 【不需要任何安全存储】         │
  │  中转 TTL ≤ 30 分钟强制过期（不依赖客户端主动删除）          │
  └────────────────────────────────────────────────────────────┘
                              ↓
  ┌─ 落盘保护（两层，§4.3）────────────────────────────────────┐
  │  第一层 App 沙盒隔离  → 防其他 App / 系统相册 / 第三方程序   │
  │    ① 只落 app-specific 目录（禁 external storage / sdcard） │
  │    ② 禁写 MediaStore / PHPhotoLibrary                      │
  │    ③ Android allowBackup="false"（否则自动上 Google Drive） │
  │  第二层 系统全盘加密  → 防设备关机后被物理取走               │
  │    iOS Data Protection / Android FBE / FileVault / BitLocker│
  │  ⚠ 应用层【不】加密、【不】持久保存任何密钥（理由见 §4.3）   │
  └────────────────────────────────────────────────────────────┘
```

### 3.2 设备发现

**Native 三端（Android / iOS / macOS）：`bonsoir` 7.1.4**

实测：160/160 分，MIT，51 个版本，2026-06-17 发布，likes 158，月下载 42642，
支持 android/ios/windows/linux/macos。

选它而非 `multicast_dns` 的理由：`multicast_dns` 虽为 flutter.dev 官方包，但**只能查询不能广播** ——
其源码含 `// TODO(dnfield): Support queries coming in for published entries.`。
设备互相发现要求双向，必须能广播。

备选 `nsd` 5.0.1（160/160，77 likes，月下载 64325）功能等价，但 `bonsoir` likes 更高且支持 linux。

**全部四端：Firestore 在线设备表**

每个设备登录后在 `users/{uid}/devices/{deviceId}` 写入
`{publicKey, lastSeenAt, platform}`，并订阅同路径下的兄弟文档。
这同时充当**跨网段发现**与**Web 端的唯一发现手段**。

零新增基建 —— 复用既有 Firestore（设计稿 §6.3 :1069 已作此判断）。

### 3.3 传输：chunk 是硬要求

**包**：`flutter_webrtc` 1.5.2（150/160，MIT，1347 likes，月下载 221173，
GitHub `flutter-webrtc/flutter-webrtc` 4479 stars / 685 open issues / 2026-08-02 有提交）。
Web 分支自动落到 `dart_webrtc`（`platform:web`）。

**必须自己实现的两件事**（§2.4 已论证）：

1. **切块**：chunk 大小取 **16KB**（DataChannel 安全值）。
   不要用 256KB —— 上限受两端协商影响，跨浏览器不可靠。
2. **续传状态**：每 chunk 独立 sha256（设计稿 §6.1 :1046），
   接收端持久化已收 chunk 集合，映射到 S1a 的
   `BlobStatus.partial` / `BlobPartial(Set<int> presentChunks)`。

**流控**：必须监听 `RTCDataChannel.bufferedAmount`，超过阈值（建议 1MB）暂停发送，
否则会在内存中堆积待发数据 —— 这是 SCTP 拥塞控制**不会**替你做的部分。

### 3.4 TURN 兜底：采纳「方案 A」，不自建 coturn

设计稿 §6.3（:1067）主张用托管 TURN（Cloudflare / Twilio / Xirsys），并给出一个正确论证：
**DTLS 握手在两个 peer 间完成，TURN 只转发已加密的 UDP 包，连密钥交换都参与不了** ——
因此托管 TURN 在隐私上不构成降级。

按你的指示，兜底采用**方案 A：Firebase / Supabase 等 SaaS 中转**，而非自建 coturn。
两者的隐私性质相同（都只看到密文与元数据），差别只在账单与运维。

**两条诚实的限制**（设计稿 §6.3 :1071-1072 原文，此处保留）：

1. **TURN 可见元数据** —— IP、包大小、时序。看不到内容，但知道「这两个 IP 在某时刻传了 200MB」。
2. **信令通道完整性是前提** —— 被攻破的信令通道理论上可替换 DTLS 指纹实施中间人。
   本文档对此的处理见 §5.2（判定为可接受，不做带外验证）。

> **⚠ 待决（D4）**：大文件是否限制「仅 Wi-Fi 传输，蜂窝网络只同步 row」。
> TURN 中继 MP4 的带宽费用可观，而设计稿 §6.2（:1052）已明确
> 「P2P 的价值定位是省钱与速度」。**建议默认开启此限制，但不阻塞 S6 开工。**

---

## 4. 加密方案

### 4.0 本轮结论：三层各自解决，移动端零密钥管理、桌面端轻量密钥管理

> **⚠ 本节于 2026-08-03 第二轮讨论后修订。** 前一版结论是「四端一律不做应用层落盘加密」，
> 已被人类推翻 —— 桌面端（macOS/Windows/Linux）要做，移动端（iOS/Android）不做。
> 详见 §5.3。

人类于 2026-08-02-03 的决策，把加密问题**压缩成了移动端零代码、桌面端少量代码**的形态。
先给结论表，再逐层展开：

| 层 | 保护什么 | 本轮方案 | 需要持久密钥？ | 代码量 |
|---|---|---|---|---|
| **传输层（直连）** | 链路上的窃听 | **WebRTC 的 DTLS**（强制，无法关闭） | 否（每次连接 ECDHE 临时协商） | **零** |
| **传输层（中转）** | 中转服务器读取内容 | 临时密钥包装（§4.2） | 否（一次一密，用完即弃） | 少量 |
| **落盘层 · iOS/Android** | 设备被物理取走 | **系统全盘加密**（§4.3） | 否（OS 与硬件安全芯片管理） | **零** |
| **落盘层 · macOS/Win/Linux** | 同上，但**全盘加密非默认开启** | AES-GCM 加密文件 + DEK 存系统密钥库（§5.3） | **是**（每设备一把独立 DEK） | 少量 |
| **落盘层 · Web** | — | **【留空，待人类补】** | — | — |

**分界线不是「移动 vs 桌面」，而是「系统全盘加密是否出厂强制开启」**：
iOS 的 Data Protection 与 Android 的 FBE 关不掉，桌面端的 FileVault / BitLocker 是用户开关。
桌面端必须由应用层把这一层补回来。

### 4.1 为什么不需要长期密钥：数据的生命周期变了

设计稿 §6.2（:1058）原本设想云端密文**长期存储并充当备份**。
人类决策改变了这个前提：

> 一个数据只有在同步的时候需要加密，同步完了之后那个数据就应该被删除。
> 如果是第三方中转的话，它在第三方服务器存储的时间不会超过 5 分钟。

**密文的存活期从「年」变成「分钟」**，这让整类密钥管理问题消失：

| 长期密文才有的问题 | 在本方案中 |
|---|---|
| 改密码后旧密文还要能解 | 不存在 —— 5 分钟前的密文已删除 |
| 忘记密码导致历史数据永久丢失 | 不存在 —— 没有长期密文 |
| 新设备要能解密历史数据 | 不存在 —— 没有历史密文 |
| 密钥轮换后的兼容 | 不存在 |

### 4.2 传输加密

**直连（LAN / WebRTC P2P）—— 零工作量**

WebRTC 的 DataChannel 强制运行在 **DTLS** 之上，**无法关闭**。
DTLS 每次连接执行 ECDHE 临时密钥协商，天然具备**前向保密**
（本次会话密钥泄露不影响历史会话）。

**这已经满足人类提出的「传输过程中的加密用 TLS 方案就行」这一要求，无需额外代码。**

**中转（SaaS relay，人类指定的「方案 A」）—— 一次一密**

当两端无法直连时，密文经 Firebase / Supabase 中转。此时需要应用层加密，
因为**中转服务器不参与 DTLS**，它看到的是落地的字节：

```
发送端：
  1. 随机生成 32 字节 DEK（Data Encryption Key），仅本次传输使用
  2. AES-GCM(文件, DEK) → 密文             ← 按 chunk 加密，见 §4.4
  3. X25519 ECDH(本次临时私钥, 接收端会话公钥) → HKDF → 包装密钥
  4. AES-GCM(DEK, 包装密钥) → 包装后的 DEK
  5. 上传 {密文, 包装后的DEK, 本次临时公钥} 到中转

接收端：
  6. 用自己的会话私钥 + 发送端临时公钥 → ECDH → HKDF → 包装密钥
  7. 解开 DEK → 解密文件 → 落盘
  8. 通知中转删除（TTL 兜底，见下）
```

**中转服务器持有的全部信息**：一段密文 + 一个它无法解开的包装 DEK。
它没有任何设备的私钥，**在密码学上无法解密**。

> **⚠ 这里的「会话公钥」是临时的，不是持久设备密钥。**
> 因为人类已决定「只允许双方在线（5 分钟内完成）」，双方在同一次会话中都在线，
> 会话密钥对可在连接建立时现场生成、断开即丢弃。**因此不需要任何安全存储。**
> 若将来要支持「接收方离线，密文在中转等待」，则必须引入持久设备密钥 —— 见 §4.5 预留方案 B。

#### 4.2.1 中转的完整流程（2026-08-03 人类定稿）

人类描述的流程（原话要点）：本地加密敏感资源 → 上传 SaaS 云端 →
发送 peer 告知接收 peer 去该处取 → 接收端下载并解密 → 删除远端暂存的密文；
服务端另有定期任务兜底删除 5~15 分钟前的残留。

**该流程完全正确，本节只优化其中的「删除」实现方式**（见 §4.2.2）。

```
① 发送端本地加密（AES-GCM，按 chunk）
       ↓
② 上传密文到 private/p2p/{uid}/{随机UUID}
       ↓
③ 经信令通道告知接收端：对象路径 + 包装后的 DEK + 临时公钥
       ↓
④ 接收端下载密文
       ↓
⑤ 接收端解 DEK → 解密 → 落盘（落盘保护见 §4.3）
       ↓
⑥ 接收端删除远端密文   ← 正常路径在此结束，实测应在数分钟内
```

#### 4.2.2 删除机制：三层，且**不需要自建定时任务**

> **人类原提案**：给每个上传对象附加一个「删除时间」字段，
> 服务端跑定期任务遍历所有用户的 private 目录，逐个比对时间戳后删除。
> **本节给出更简单的等效方案** —— 该定时任务不需要写。

**GCS（Firebase Storage 的底层）原生支持 Object Lifecycle Management**，
配置一条规则即可让服务端自动删除，**零代码、零定时任务、零服务器**：

```json
{
  "rule": [{
    "action": {"type": "Delete"},
    "condition": {
      "age": 1,
      "matchesPrefix": ["private/p2p/"]
    }
  }]
}
```

| 对比项 | 自建定时任务（原提案） | 生命周期规则（建议） |
|---|---|---|
| 代码量 | Cloud Function + 定时器 + 全目录遍历 | **零**（一次性配置） |
| 遍历所有用户目录 | 需要，用户越多越慢 | 不需要，GCS 内部处理 |
| 删除时间戳字段 | 需自己写入、自己比对 | **不需要**，GCS 用对象创建时间 |
| 漏删风险 | 任务挂掉即漏删，需自己监控 | 由云厂商保证 |
| 费用 | Function 调用 + 出流量 | **免费** |

> **⚠ 硬约束：生命周期规则的最小粒度是「天」，不是「分钟」。**
> `age: 1` 的语义是「创建满 1 天后删除」，**做不到「5 分钟后删除」**。
> 这不是配置问题，是 GCS / S3 / Supabase Storage 共同的产品限制。
> **因此它只能当兜底，不能当主删除手段。**

**正确形态是三层删除**：

| 层 | 执行者 | 时机 | 定位 |
|---|---|---|---|
| **① 主删除** | **接收端客户端** | 下载解密成功后**立即** | 正常路径，实测数分钟内完成，符合人类「5~15 分钟」的期望 |
| **② 兜底删除** | 发送端客户端 | 会话超时 / 用户取消时 | 覆盖「对端始终未来取」 |
| **③ 终极兜底** | **GCS 生命周期规则** | 满 1 天 | 覆盖「两端都崩溃 / 断网」，防垃圾堆积 |

**关键推论：正常情况下永远轮不到第③层。**
「5~15 分钟内删除」这一目标由第①层保证，而非服务端。
第③层的存在只是为了让「客户端全部失联」不至于产生永久残留。

**因此 D10（中转 TTL 取值）的语义需要修正**：
它不是「主删除时限」，而是「生命周期规则的 age 值」，取 1 天即可。

#### 4.2.3 远端目录结构与安全规则

```
private/p2p/{uid}/{随机UUID}
```

**三段各有其不可替换的理由**：

| 段 | 取值 | 理由 |
|---|---|---|
| `private/p2p/` | 固定前缀 | 生命周期规则按 `matchesPrefix` 匹配；public 分享（S2）走另一前缀，两者生命周期相反，**必须前缀隔离** |
| `{uid}` | Firebase Auth uid | Storage 安全规则要按 uid 判权，无此段无法写规则 |
| `{随机UUID}` | 随机，**不可用 sha256** | 见下 |

**为什么私有对象名必须随机、不能用内容哈希**：
`blob_gateway.dart:15-17` 的契约注释已定死此点：

> `objectName`：远端对象名。private → **随机 UUID**（§7.4.3）；public → 等于 plaintextSha256。

内容寻址会泄露「某用户是否持有某文件」—— 攻击者用已知文件算出 hash 去撞路径，
即可验证目标是否持有该文件，**无需解密即造成隐私泄露**。
公开分享（S2）不存在此问题，故可用 sha256 做去重。

对应的 Storage 安全规则：

```javascript
match /private/p2p/{uid}/{objectId} {
  // 只有本人可读写自己的中转目录
  allow read, write: if request.auth.uid == uid;
}
```

> **⚠ 注意**：接收端**不能**直接读发送端的 `{uid}` 目录（规则不允许）。
> 中转对象必须由**发送端上传到自己的目录**，再通过 §4.2.2 的
> `BlobDownloadTicket`（**短期签名 URL**）授权接收端下载。
> 签名 URL 是跨 SaaS 的通用形态，这一点也是端口不锁死供应商的原因（见 §4.2.4）。

#### 4.2.4 供应商可替换性：契约层已保证，无需额外设计

人类要求：Firebase Storage 只作为示例实现，
后续可能换 Supabase、其他 SaaS，或自建 RESTful 服务。

**这一点 S1a 的契约已经保证了**，`blob_gateway.dart:1-5` 文件头注释原文：

> 远端二进制对象网关（RemoteDataSource 的 blob 面，设计稿 §3.4）。
> **实现：firebase / supabase / 自建 REST / 自建 gRPC。**

因此：

- 换供应商 = 新增一个 `SupabaseBlobGateway implements BlobGateway`，**业务侧零改动**
- `BlobUploadTicket` / `BlobDownloadTicket` 用的是
  **对象名 + 短期签名 URL**（`blob_gateway.dart:15-45`），
  GCS / S3 / Supabase Storage / 自建 REST **全都能实现**，不是 Firebase 专有概念

**唯一与供应商绑定的是生命周期规则的配置形式**（GCS JSON vs S3 Lifecycle vs 自建 cron）。
但因为它只是第③层兜底（§4.2.2），**换供应商时即使这一层暂时缺失，
系统仍由第①②层保证正常删除** —— 影响面被限制在「垃圾清理」而非「功能可用性」。

> **实现约束**：生命周期规则的配置**不得写进 Dart 代码**，
> 它属于基础设施配置（`storage.rules` / 云控制台 / IaC），
> 否则会把供应商细节泄漏进 `persistence_p2p` 包，破坏上述可替换性。

### 4.3 落盘保护：沙盒隔离 + 系统全盘加密（两层，缺一不可）

人类决策（2026-08-03 修订）：**iOS/Android 不做应用层落盘加密，
macOS/Windows/Linux 做**（D15/D16，详见 §5.3）。本节讲的是四端共通的两层基础保护。

**必须澄清一个容易混淆的点**：保护落盘私有数据的实际上是**两个不同机制**，
它们防的是**不同的攻击者**。此前的表述只提了第二层，不完整：

| 层 | 机制 | 防谁 |
|---|---|---|
| **第一层** | **App 沙盒隔离** | **其他 App、系统相册、有存储权限的第三方程序** |
| **第二层** | 系统全盘加密 | 设备关机后被物理取走 |

**第一层是回答「其他 App 和系统相册能不能看到我的私密照片」的那一层，
而它的有效性取决于 S6 自己的落盘路径选择 —— 这是本方案唯一可能自己搞坏的地方。**

#### 第一层：App 沙盒隔离

| 平台 | 其他 App 可读？ | 系统相册会索引？ | 隔离机制 |
|---|---|---|---|
| iOS | **否** | **否** —— 相册只索引 Photo Library，不扫沙盒 | 沙盒强制隔离，无例外 |
| Android | **否** | **否** —— MediaStore 不扫 app-specific 目录 | SELinux + per-app UID |
| macOS | **否**（已实证，见下） | 不适用 | App Sandbox **已开启** |
| Windows | 同用户下的进程可读 | 不适用 | 仅靠文件系统 ACL，隔离最弱（且当前无该端，见 §1.2） |

> **macOS 一行的实证（2026-08-03 实查，纠正前一版的「视是否启用」保守写法）**：
> `xuan-shell/macos/Runner/Release.entitlements` 与 `DebugProfile.entitlements`
> **两个文件都含** `com.apple.security.app-sandbox = true`。
> `DebugProfile` 另有 `network.client` 与 `network.server`（正是 S6 需要的）。
> **结论：macOS 第一层与 iOS/Android 同级，不是弱项。**
> macOS 的真实弱点在**第二层** —— FileVault 非默认开启（见 §4.3 第二层与 §5.3.1）。

**三条硬约束（S6 必须交付，否则第一层被自己破坏）**：

1. **私有 blob 只能落在 app-specific 目录** ——
   iOS/macOS 用 `getApplicationSupportDirectory()`，
   Android 落在 `/data/data/<pkg>/`（即 `getApplicationSupportDirectory()`，**不是** external storage）。
   **禁止** `getExternalStorageDirectory()`、`/sdcard/`、任何公共目录 ——
   一旦落在那里，系统相册与所有有存储权限的 App **立即可见**。
2. **禁止把私有 blob 写入系统相册** —— 不得调用 Android `MediaStore` 插入或
   iOS `PHPhotoLibrary` 保存。这类 API 的语义就是「对全系统公开」。
   若产品需要「导出到相册」功能，必须是**用户显式触发的单次导出**，
   并在 UI 明示「导出后该图片将对其他 App 可见」。
3. **Android 必须关闭 Auto Backup** —— Android 的 Auto Backup 默认**对 app-specific 目录开启**，
   会自动把沙盒内文件上传到用户的 Google Drive，**直接违反「私有数据不上云」的设计意图**。
   必须在 `AndroidManifest.xml` 显式关闭：
   ```xml
   <application android:allowBackup="false" android:fullBackupContent="false">
   ```
   iOS 同理需评估 iCloud 备份：私有 blob 目录应设 `isExcludedFromBackup`，
   或落在 `Library/Caches` 之外但标记为不备份。

> **⚠ 约束 3 是本轮补入的疏漏项。** 若不处理，「弃用云端长期存储」这个决策会被
> 操作系统的默认备份行为在背后推翻 —— 数据仍然上了云，只是上的是 Google Drive / iCloud
> 而不是本项目的 Firebase。**S6 的验收标准必须包含这一项。**

#### 4.3 附：两项**当前即未达标**的配置缺口（2026-08-03 实查）

以下两项不是「将来要注意」，而是**现在就是红的**，S6 开工必须一并修：

**缺口 1：Android 的 `allowBackup="false"` 没写 —— 即约束 3 当前未满足。**

实查 `xuan-shell/android/app/src/main/AndroidManifest.xml`，`<application>` 标签只有三个属性：

```xml
<application
    android:label="xuan_shell"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
```

**既无 `allowBackup` 也无 `fullBackupContent`**，即取 Android 默认值 `allowBackup="true"`。
后果：私有 blob 一落盘，Auto Backup 就会把它上传到用户的 Google Drive。
**这直接违反本方案「私有数据不上云」的核心决策，且是静默发生的。**

**缺口 2：iOS 缺本地网络权限声明 —— S6 的 LAN 发现在 iOS 上会静默失败。**

实查 `xuan-shell/ios/Runner/Info.plist`，`NSLocalNetworkUsageDescription`
与 `NSBonjourServices` **两个键都不存在**。

iOS 14 起，mDNS 发现与访问局域网地址必须声明这两个键，否则**不报错、直接发现不到设备**。
这与 §5.3.3 的 macOS entitlement 陷阱是同一类型的坑：**测试期看不出问题，上线才炸**。
`bonsoir`（§3.2 选定的发现包）在 iOS 上必须依赖这两个键。

> 这两项与 §5.3 的桌面端加密是**互相独立的三件事**，不要混为一谈：
> 缺口 1 是「数据会不会被系统传上云」，缺口 2 是「LAN 发现能不能跑起来」，
> §5.3 是「设备被物理取走后文件能不能被读」。

#### 第二层：系统全盘加密

| 平台 | 机制 | 出厂默认开启？ | 密钥存放位置 |
|---|---|---|---|
| iOS | Data Protection | **是，且关不掉** | Secure Enclave |
| Android | File-Based Encryption | **是，且关不掉** | TEE / StrongBox |
| macOS | FileVault | **否 —— 用户开关** | Secure Enclave（Apple Silicon） |
| Windows | BitLocker / Device Encryption | **否（家庭版常未启用）** | TPM 2.0 |

> **「出厂默认开启」这一列是本轮桌面端改判的全部依据。**
> iOS/Android 的第二层由 OS 强制保证，应用再加一层是净损失（引入密钥丢失风险，换不到新防护）。
> macOS/Windows 的第二层**可能整个不存在**（用户没开 FileVault / BitLocker），
> 此时若不做应用层加密，「设备关机被物理取走」这一格是**裸的**。
> 这就是 §5.3.1 为什么让桌面端做、移动端不做。

**为什么这比应用层加密更好，而不只是更省事：**

应用层加密需要一把持久密钥，而应用能用的最安全存储也不过是 Keychain / Keystore /
Credential Manager —— 这些正是**操作系统全盘加密所依赖的同一套底层设施**。
自己再加一层，密钥反而只能放在**不比系统更安全的地方**，却引入了新的失败模式（密钥丢 = 数据变砖）。

**威胁模型对照**（这是选择的真实依据，不是托词）：

| 攻击场景 | 本方案（沙盒 + 全盘加密） | 若再加应用层加密（方案 A/B） |
|---|---|---|
| **其他 App 读取** | ✅ 挡住（沙盒，第一层） | ✅ 挡住（同样靠沙盒） |
| **系统相册索引到私密照片** | ✅ 挡住（沙盒 + 约束 1/2） | ✅ 挡住（同样靠沙盒 + 约束） |
| **系统自动备份上传到 Drive/iCloud** | ✅ 挡住（约束 3） | ✅ 挡住（即使上传也是密文，**此项确有增益**） |
| 设备关机后被物理取走 | ✅ 挡住（全盘加密，第二层） | ✅ 挡住 |
| 设备已解锁、攻击者在使用 | ❌ 挡不住 | ❌ **同样挡不住**（密钥已在内存） |
| root / 越狱后直接读文件 | ❌ 挡不住 | ⚠️ 略有增益（但内存可 dump） |
| 云端 / 中转服务器窥探 | ✅ 挡住（由 §4.2 解决） | ✅ 挡住 |

**结论**：应用层加密的真实增益只有两项 —— 「root 后直接拷文件」（可被内存 dump 抵消）
与「系统备份被误上传时仍是密文」（而后者已由约束 3 从源头解决）。
代价是一整套密钥生命周期管理，以及一个新的失败模式（密钥丢失 = 数据变砖）。
**判定：不值得。但前提是 §4.3 的三条硬约束必须落实 —— 它们不是可选项。**

### 4.4 算法选定与实测依据

包：`cryptography` 2.9.0（150/160，Apache-2.0，49 个版本，2025-11-21，
likes 311，月下载 520363，支持全部 6 平台**含 web**）。

实测该包 `lib/src/cryptography/algorithms.dart` 提供了全部所需算法：

| 用途 | 类 | 行号 | 本轮是否使用 |
|---|---|---|---|
| 设备/会话签名（含 channel binding） | `Ed25519` | :1184 | **是**（§5.2b） |
| 会话密钥交换 | `X25519` | :2199 | **是**（§4.2 中转） |
| 包装密钥派生 | `Hkdf` | :1280 | **是**（§4.2 中转） |
| 文件与 DEK 加密 | `AesGcm` | :364 | **是**（§4.2 中转） |
| 密码派生 | `Pbkdf2` | :1505 | 否 —— 预留方案 A |
| 密码派生（抗 GPU） | `Argon2id` | :502 | 否 —— 预留方案 A |

**流式加密可行**：`lib/src/cryptography/cipher.dart:358` `encryptStream` /
`:215` `decryptStream` 接受 `Stream<List<int>>`，且内部每 N 字节主动
`await Future.delayed(_pauseDuration)` 让出事件循环（`:71` 注释「do 1ms pauses every this many」），
**不会卡 UI**。

> **⚠ 实测发现的陷阱**：`AesGcm extends Cipher`（`:364`）而**不是** `StreamingCipher`（`:2117`）——
> AES-GCM **不支持 seek / 随机读取**。因此不能对整个大文件做单次流式加密后再随机取中段，
> **必须按 chunk 独立加密**（每 chunk 独立 nonce + MAC）。
> 这恰好与 §3.3 的传输分块、设计稿 §6.1 的 chunk 设计一致 —— **加密块与传输块取同一粒度**。
> 若确需 seek，可改用 `AesCtr`（`:213`，是 `StreamingCipher`）+ 独立 MAC，但会失去 AEAD 的一体性，不推荐。

**包的单点风险（须记录在案）**：`cryptography` 由 dint-dev **单人维护** ——
GitHub 185 stars / 36 open issues / 最后 push 2025-11-21。
其原生加速伴生包 `cryptography_flutter` 仅 37 likes，且**不支持 Web / Windows / Linux**。

替代品均不满足需求：`sodium`（BSD-3，160/160）含 FFI **不支持 Web**；
`pointycastle`（140/160，409 likes，月下载 282 万）更底层且无 Argon2id 一体化 API；
`encrypt` 的 GitHub 已归档且无 AEAD。

**缓解手段**：加密逻辑全部收敛在 `BlobCipher` 实现类内（S1a 已提供此端口），
更换底层包的代价被限制在单个实现类。**这是 S1a 把 `BlobCipher` 独立成端口的回报。**

`sqlcipher_flutter_libs` 最新版本号实测为 **`0.7.0+eol`**（作者已标记 End of Life），
**不得用于新工作**。数据库层继续用 `drift`（已在用）。

### 4.5 未来预留：两套长期密钥方案

**本轮不实现。** 但当触发条件出现时，必须从下面两套中选一套 —— 它们解决的问题不同，不可混用。

**触发条件**（任一出现即需重新评估）：

1. 要做**云端长期存储**（密文存活期从分钟变成年）
2. 要支持**接收方离线接收**（密文在中转等待数小时/数天）
3. 要提供**设备全丢后从云端恢复**的能力
4. 要支持**设备撤销**（手机丢失后禁止它继续解密新数据）

---

#### 方案 A：Master Key + Wrapped Key（信任锚点 = 密码）

即 1Password / Bitwarden 的通行做法。

```
Master Key    32 字节安全随机数，注册时生成一次，此后永不改变
                └─ 加密所有文件；明文形态只存在于内存

Password Key  Pbkdf2 或 Argon2id(password, salt = accountId)
                └─ 不存储，每次登录现场派生

Wrapped Key   AesGcm.encrypt(Master Key, key: Password Key)
                └─ 存 Firestore，服务端只见密文盲盒
```

**运转方式**：
- **多设备使用**：各端输密码 → 派生 Password Key → 下载盲盒 → 本地解开 → 得到同一个 Master Key
- **改密码**：用旧密码解开取出 Master Key → 用新密码重新包装 → 上传覆盖。**Master Key 不变，历史数据仍可解**
- **新设备加入**：输密码即可，**不需要老设备在场** ← 这是方案 A 相对 B 的核心优势

**解决**：触发条件 1、3。

**代价（必须一并接受，不可只取其一）**：

- ⚠ **必须配恢复码**。`sendPasswordResetEmail`（`firebase_account_auth_gateway.dart:121`）
  重置密码后旧盲盒永久打不开 → **全端加密数据同时变砖**。
  必须用一串高熵恢复码额外包装第二份 Master Key（Wrapped Key #2）。
- ⚠ **`updatePassword` 必须改造为原子操作**。当前 `:146` 只调了 `updatePassword`；
  方案 A 下必须「解开旧盲盒 → 重新包装 → 上传」与改密码同事务，
  否则中途崩溃将永久失去 Master Key。**这是 S6 唯一需要修改既有认证代码的地方。**
- ⚠ **匿名用户无法使用**（`signInAnonymously`，`:27` 是真实路径，无密码可派生）。
- ⚠ **每次冷启动都要输密码**（Web 端尤其明显，浏览器无安全存储）。
- ⚠ **与「单端丢失从另一端重新同步」的容灾模型冲突** —— Master Key 是全端共享的单点，
  一次密码重置就让所有端同时失效，**方向与该容灾模型相反**。

---

#### 方案 B：信封加密（Envelope Encryption，信任锚点 = 设备私钥）

即 Signal / iMessage 的做法。密码完全不参与。

```
每个文件随机生成一把 DEK
   ↓
用【每台已配对设备的公钥】分别包装这把 DEK
   ↓
存储 = 文件密文 + { 手机包装的DEK, 电脑包装的DEK, iPad包装的DEK }
   ↓
任一设备用【自己的私钥】解开属于自己的那份 → 得到 DEK → 解密文件
```

**解决**：触发条件 2、4。

**相对方案 A 的优势**：

- ✅ **密码重置完全无影响** —— 密码根本不参与加密
- ✅ **支持设备撤销** —— 手机丢失后，以后不再为它包装 DEK。
  **这是设计稿 §6 原本要求、而方案 A 做不到的能力**
- ✅ **与容灾模型天然契合** —— 每设备一把独立私钥，A 端密钥丢失只影响 A，从 B 重新同步即可，
  **不存在全端同时变砖的故障模式**

**代价**：

- ⚠ **需要持久保存设备私钥** → 必须重新引入安全存储（见下方风险）
- ⚠ **新设备必须与已有设备配对**才能拿到数据（不能只靠密码独立接入）
- ⚠ **设备全丢 = 数据不可恢复**（没有任何不依赖设备的密钥）

**若采用方案 B，须重新评估 `flutter_secure_storage` 10.3.1**（本轮已弃用，评估见 §5.3）。
届时需注意其 `useSecureEnclave` 选项的陷阱：README:285-287 明确说明
已用普通 Keychain 写入的条目**不会自动重新加密**，事后开启该选项读取会返回 `null`
（数据仍在但从 SE 路径不可见）。**该选项必须在首次落地时就定死，中途开启会丢数据。**

---

#### 选型建议（供未来决策时参考）

| 触发条件 | 推荐方案 |
|---|---|
| 只要云端长期备份、设备全丢可恢复 | A |
| 只要离线接收、设备撤销 | B |
| 两者都要 | A + B 组合：用 A 保管一把"账号根密钥"，用 B 做设备级分发（Matrix/Element 即此结构，复杂度显著上升） |

**当前（2026-08-03）判定：两套都不实现。** 理由是四项决策已使触发条件全部不成立。

---

## 5. 与设计稿的差异（逐条对账）

### 5.1 撤回：不删除 S1a 的加密契约

**先前的判断是错的，此处更正。** 曾建议在放弃 E2EE 后删除 `BlobCipher` / `BlobCipherResolver` /
`keyVersion` / `BlobReadResult.undecryptable`。**本方案仍然用得上它们**，只是用途与设计稿原意不同：

| S1a 契约 | 在本方案中的真实用途 |
|---|---|
| `BlobCipher` / `BlobCipherResolver` | **中转路径**的 per-transfer DEK 宿主（§4.2）；换底层加密包时的隔离边界（§4.4） |
| `BlobStatus.partial` / `BlobPartial`（`blob_types.dart:94`, `:188`） | WebRTC 断线续传的状态载体（§2.4 ①）—— **本方案中最实在的一个** |
| `BlobHandle.plaintextSha256`（`:23`） | chunk 完整性校验 + 跨通道续传对账（§3.3） |
| `BlobVisibility.public → identity cipher`（`:115-122`） | **直连路径**的落点 —— DTLS 已加密，应用层用 identity cipher（不再加密一次） |
| `BlobHandle.keyVersion`（`:32`） | 本轮**无实际用途**（一次一密，无轮换）。保留以备 §4.5 未来方案 |
| `BlobReadResult.undecryptable`（`:103`, `:169`） | 本轮**低频**：仅用于中转密文过期/DEK 丢失。保留以备 §4.5 |

**含义**：契约形状不需要改动，但**有两个字段在本轮是"预留位"而非活跃路径**。
转译 ACT 时不应为它们编造用途，也不应删除 —— 它们的成本为零（S1a 是零实现），
而 §4.5 任一方案落地时都会立刻用上。

**唯一需要改的 S1a 契约**：`BlobCipherResolver.resolve()` 当前是**同步返回**。
本方案中中转路径的 DEK 需要经 X25519 ECDH + HKDF 派生，**这是异步操作**。
**建议改为返回 `Future<BlobCipher>`。** 这是对已验收契约的修改，需走变更流程（D7）。

> **注**：先前给出的理由是「Master Key 首次解开盲盒必须 async」。该理由已随 Master Key
> 一同作废，但**结论不变** —— 新理由是 ECDH 密钥派生本身异步。

同理，`core/lib/model/transport.dart:66-71` 的 `DeviceKeyPair` 目前只有 `publicKeyPem`
（注释「仅占位形状，实现属 S6」），S6 需扩展它以承载 Ed25519 密钥对
（用于 §5.2b 的 channel binding 签名）。

### 5.2 砍掉：带外指纹验证（设计稿 §6.3 :1072）

设计稿要求「两台设备各自显示公钥指纹，用户肉眼比对或扫二维码」，并注明「此项归入 S6，本就必须做」。

**本方案判定为可省略。** 理由：

公钥存 Firestore 意味着**能写 Firestore 的人能替换公钥**。Ed25519 验签只能证明
「对方持有与此公钥配对的私钥」，不能证明「此公钥属于你的设备」——这是 TOFU 问题，真实存在。

但攻击者要替换公钥，**必须先攻破 Firebase 账号**。而一旦攻破账号，
他已经能直接读云端数据，**不需要伪造设备**。因此带外验证在此威胁模型下**不提供额外保护**。

**防护落在 Firestore 安全规则**：`users/{uid}/devices/**` 只允许 `request.auth.uid == uid` 写入。
这条规则是 S6 的硬交付项。

> **保留的残余风险**：Firebase 账号被攻破 = 全部设备互认失效。
> 这与「Firebase 账号被攻破 = 云端数据泄露」是同一个风险等级，未引入新的攻击面。

### 5.2b 保留：channel binding（砍掉的只是「人肉比对」这一步）

设计稿 §3.5（:794）与 S1a 已交付的 `core/lib/model/transport.dart:158` 都要求：

> 握手必须完成认证密钥交换并绑定指纹到会话（channel binding），否则带外指纹比对对主动 MITM 无效。规格见 S6。

**§5.2 砍掉的只是「用户肉眼比对指纹」这个交互动作，channel binding 本身必须保留。**
两者是不同的东西，容易混淆，此处明确区分：

| | 是什么 | 本方案 |
|---|---|---|
| 带外指纹比对 | 用户在两台设备上人肉核对指纹字符串 | **砍掉**（§5.2 论证） |
| channel binding | 把已验证的公钥指纹**绑定到本次 DTLS 会话**，确保「签名验过的那个 peer」和「正在传数据的那个 peer」是同一个 | **必须做** |

**不做 channel binding 的后果**：Ed25519 挑战-应答在信令层验过身份，
但攻击者可在 SDP 交换阶段替换 DTLS 指纹，使数据实际流向另一个 peer ——
**验签验的是 A，传数据传给了 B**。这个攻击不依赖攻破 Firebase 账号，
因此 §5.2 的论证（「攻击者需先攻破账号」）在这里**不适用**。

**具体做法**：把本次连接的 **DTLS 证书指纹**放进 Ed25519 挑战-应答的签名内容里
（即签名对象为 `nonce || dtlsFingerprint`，而非仅 `nonce`）。
这样攻击者替换 DTLS 指纹会导致验签失败。`flutter_webrtc` 可从
`RTCPeerConnection` 的本地/远端 SDP 中取出 `a=fingerprint:` 行。

> **⚠ 这是本方案中密码学上最容易做错的一步。** 候选方案的挑战-应答只签了 `nonce`，
> 若照抄会留下上述漏洞。ACT 转译时必须把「签名对象包含 DTLS 指纹」写成硬约束并配负测试。

### 5.3 有条件启用：`flutter_secure_storage` 作为**密钥保管器**（2026-08-03 改判）

> **⚠ 本节结论已于 2026-08-03 第二轮讨论中推翻前一版。**
> 前一版写的是「本轮不引入 `flutter_secure_storage`，不做应用层落盘加密」。
> 人类在同日复审时指出：落盘加密该做还是要做，做不了的端才降级 ——
> 「不行就把刚才去除的 `flutter_secure_*` 加回到文档里面，
> 它用来负责 Windows 或者是 Linux 的加密以及 Web 的」。
> 保留前一版的评估内容（四个问题依然成立），但**结论从「弃用」改为「有条件启用」**。

#### 5.3.0 首要区分：它是密钥保管器，不是文件加密器

**这是本节最容易搞错、且一旦搞错整个方案就不成立的一点。**

`flutter_secure_storage` 的 API 形状是 `Future<void> write({required String key, required String? value})` ——
**键值对，值是 String**。它的设计用途是存 token、密码、小配置。

| 它能做的 | 它**不能**做的 |
|---|---|
| 存一把 32 字节的 AES 密钥 | 加密一个 500MB 的 MP4 |
| 存设备私钥、设备 id | 流式加解密 |
| 存少量元数据 | 分块（chunk）处理 |

**把 blob 明文塞进它 = 方案立刻崩溃**：整文件 base64 进 String 会在移动端 OOM，
而且 Keychain / Keystore 对单条目大小有实际限制（Keychain 官方建议 < 4KB 量级）。

**所以正确的分工是两个包配合，各司其职**：

```
┌──────────────────────────────────────────────────────────┐
│ flutter_secure_storage  →  只存那把 32 字节的 DEK        │
│   （落点：Keychain / Keystore / Credential Manager /      │
│     libsecret，由 OS 的硬件安全设施保护）                 │
└────────────────────────┬─────────────────────────────────┘
                         │ 取出 DEK
                         ▼
┌──────────────────────────────────────────────────────────┐
│ cryptography (2.9.0) AES-GCM  →  真正加密 blob 文件      │
│   逐 chunk 加密，每 chunk 独立 nonce + MAC（见 §4.4）     │
└──────────────────────────────────────────────────────────┘
```

这个形状就是**信封加密的轻量版**（§4.5 方案 B 的单设备退化形态）：
密钥归 OS 的安全芯片管，数据归应用自己用 AES-GCM 管。
两者的边界正好落在 S1a 已定死的 `BlobCipher` 端口上（`blob_cipher.dart`），
**不需要改契约形状**。

#### 5.3.1 分平台落地口径（本轮定稿）

| 平台 | 落盘加密做法 | 密钥落点 | 理由 |
|---|---|---|---|
| **iOS** | **不做应用层加密** | — | Data Protection 出厂强制开启 + 沙盒无例外，增益不足以抵偿密钥丢失风险 |
| **Android** | **不做应用层加密** | — | FBE 出厂强制开启 + SELinux/per-app UID，同上 |
| **macOS** | **做**（`flutter_secure_storage` 存 DEK） | Keychain（可选 Secure Enclave） | 沙盒已开启（有实证，见 §4.3），但 **FileVault 非默认开启** —— 第二层有洞，需应用层补 |
| **Windows** | **做**（同上） | Credential Manager（DPAPI 链） | 平台目录当前不存在（§1.2），属**未来端**；届时沙盒隔离最弱，必须做 |
| **Linux** | **做**（同上） | libsecret / 系统 keyring | 同 Windows，属未来端 |
| **Web** | **【留空，待人类补】** | — | 人类 2026-08-03 明确指示暂不调研，回来自行确认 |

> **Web 一行为什么留空**：人类原话「你不用调研 Web，Web 这个回来留空，回来我去看」。
> 已知的既有事实仅记录如下，**不构成结论**：
> `flutter_secure_storage` 的 Web 实现 README 自称 **experimental**、
> 「Use at your own risk at this time」，密钥存 LocalStorage，
> 仅在 HTTPS/localhost 可用，且**跨浏览器/跨机器不可移植**。
> 该端的落盘方案由人类回来后决定。

**关键推论：iOS/Android 与桌面端的差异不在「能不能」，而在「第二层是否默认开启」。**
iOS/Android 的全盘加密关不掉，桌面端可以关（FileVault 是用户开关），
所以桌面端必须由应用层把这一层补回来 —— 这才是引入该包的真实依据，
而不是「桌面端更不安全」这种笼统印象。

#### 5.3.2 该包的实际能力（2026-08-03 核实，与早期印象不同）

版本已到 **10.3.1（2026-05-27）**，评分 150/160，BSD-3，likes 4468，月下载 338 万。
架构已拆为 federated 子包，各平台独立实现：

| 平台 | 底层机制（README 原文） | 密钥最终落点 |
|---|---|---|
| **iOS / macOS** | Keychain，`kSecUseDataProtectionKeychain` 默认启用（README:298）；新增 `useSecureEnclave` 选项（:285） | Secure Enclave（启用该选项时） |
| **Windows** | **混合方案**：AES-GCM 加密文件存 app support 目录，**AES 密钥存 Windows Credential Manager**；每 key 一个 `.secure` 文件含 nonce + 认证 tag | Credential Manager（DPAPI 链） |
| **Android** | AES/GCM/NoPadding，可选强生物识别绑定（README:150, :230） | Keystore / TEE |
| **Linux** | libsecret（需 `libsecret-1-dev` 构建、`libsecret-1-0` 运行） | 系统 keyring |

**结论：macOS 与 Windows 两个桌面方向都有可用的系统级密钥库，技术上不构成障碍。**
这一点更正了早期基于 9.x 版本形成的判断。

#### 5.3.3 该包的四个真实问题（改判后：从「弃用依据」变为「启用前必须处理的风险」）

**这四条内容不变，但性质变了** —— 前一版用它们论证「不要引入」，
本版承认要引入，因此它们成为**必须逐条给出对策的开工前提**。

1. **Windows 的密钥跟随 Windows 用户账号，不跟随硬件。**
   Credential Manager 凭据由 DPAPI 链保护，绑定登录态。
   **重装系统 / 换机 → 密钥消失 → 本地加密文件全部无法解开。**
   管理员强制重置用户密码也可能使 DPAPI 主密钥失效。
2. **macOS 未配 entitlement 会静默失败。** README:307 原文：
   > Failure to do so will result in values appearing to be written successfully but **never actually being written at all**

   必须在 `macos/Runner/DebugProfile.entitlements` **与** `Release.entitlements`
   **两个文件**都加 `keychain-access-groups`。这是一个「测试期看不出问题、上线后丢数据」的陷阱。
3. **`useSecureEnclave` 有单向陷阱。** README:285-287：已用普通 Keychain 写入的条目
   **不会自动重新加密**，事后以 `useSecureEnclave: true` 读取会返回 `null`
   （数据仍在但从 SE 路径不可见）。**该选项必须首次落地即定死，中途开启会丢数据。**
4. **Android 有升级迁移丢数据的历史 issue**：#1043 / #1079 / #1166 / #1208 均涉及
   secure storage 数据被删除；#38（StrongBox 支持）自 2019 年至今未实现。
   注：这些 issue 主要针对 9.x 及更早版本，10.x 的 federated 重写是否已解决**未经核实**。

**四条合起来指向同一个真实风险**：应用层加密引入了一个新的、非本项目可控的失败模式 ——
**密钥丢失即数据变砖**。

#### 5.3.4 逐条对策（本轮定稿，S6 必须实现）

改判后必须回答「密钥丢了怎么办」。答案是**把「密钥丢失」降级为「本端数据丢失」**，
而后者已有人类认可的容灾模型兜底：

| 风险 | 对策 |
|---|---|
| Windows 重装 → DPAPI 密钥消失 | 视为「本端数据全丢」，走容灾模型从其他端重新同步 |
| macOS entitlement 未配 → 静默失败 | **开工即在两个 entitlements 文件加 `keychain-access-groups`**，并加**启动自检**：写入后立即读回，不一致则直接报错而非静默降级 |
| `useSecureEnclave` 单向陷阱 | **首次落地即定死取值，永不中途变更**；写进 S6 验收标准 |
| Android 升级迁移丢数据 | iOS/Android **本就不启用该包**（见 §5.3.1），风险不适用 |

**「密钥丢失即数据变砖」在本项目里是可接受的**，因为：

> 如果多端之中的其中一个端的数据全部都丢了，还有另外的端可以做一次重新的同步
> ——（人类认可的容灾模型）

**每设备独立密钥 → 密钥丢失的影响域被限制在单设备内。**
A 端 Keychain 失效只影响 A，从 B 重新同步即可恢复。

**关键约束：绝不可让多设备共享同一把落盘密钥。**
一旦共享，就退化成 §4.5 方案 A 的形态 —— 制造全端共享单点，
一次失效让所有端同时变砖，此时「从另一端重新同步」救不了任何东西。
**这是本方案与方案 A 的根本分野，也是 §5.3 改判后仍然成立的原因。**

> **注意本节与 §4.5 方案 B 的关系**：本轮采用的正是方案 B 的**单设备退化形态**
> （每设备一把独立 DEK，不做跨设备信封包装）。
> 将来若要支持「设备撤销」，才需要升级到完整的方案 B（per-file DEK + 逐设备公钥包装）。

### 5.4 保留：设计稿的其余判断全部成立

- §6.1（:1046）chunk 独立 sha256 —— **必要性反而上升**（§2.4）
- §6.2（:1052）三级降级 局域网 > WebRTC > 云端 —— 成立
- §6.3（:1069）信令复用 Firestore、STUN 免费、托管 TURN 隐私不降级 —— 成立
- §6.3（:1078）「WebRTC 只为 blob 而建，row 走云端」—— 成立
- §6.4 引用计数 GC + `reconcileRefs` 幂等全量声明 —— 不受影响
- §5.1（:919）不做后台自动同步，「用户在线即表示同步意愿」—— 成立，且与 iOS 后台限制天然吻合

### 5.5 明确不在本文档范围

- **S2 云端公开分享**（含 `firebase_storage` 接入、post 配图）—— 独立任务
- **S1c blob 存储实现**：`grep -rln "LocalBlobStore|BlobGateway|RecordBlobUnitOfWork" core/lib drift/lib firebase/lib`
  实测**只命中 `core/lib/model/` 里那 8 个契约文件本身，零消费者**。
  设计稿 §3.2.3（:623）把 drift 实现派给 S1b，但 S1b 的 11 个 ACT **无任何 blob 工作**。
  S6 / S2 / S3a 都站在这块缺失的地板上。且调研确认 pub.dev **无内容寻址 blob store 包**（13 个关键词），
  必须自建于 drift + 文件系统。**建议独立立项为 S1c，优先于 S6。**
- **`persistence_core` 的 2 处 `dart:io`**（§1.3 ⚠）—— 建议独立前置修复
- **Web CI 门禁**（`flutter build web`）—— 建议独立补齐

---

## 6. 依赖新增清单

```yaml
# 目标包：persistence_p2p（新建，D6 已定稿）
dependencies:
  flutter_webrtc: 1.5.2           # MIT, 150/160, 月下载 221173
  bonsoir: 7.1.4                  # MIT, 160/160, 月下载 42642
  cryptography: 2.9.0             # Apache-2.0, 150/160, 月下载 520363
  flutter_secure_storage: 10.3.1  # BSD-3, 150/160, 月下载 338 万 —— 仅桌面端用，见 §5.3
```

#### 6.1 `persistence_p2p` 包的范围约定（D6，人类 2026-08-03 定稿）

> **人类原话**：「D6 放在 `persistence_p2p`。并且你在这个包说一下，
> **以后所有需要端到端 P2P 连接的数据同步的，全部放在这个包里边**。」

**这是一条长期归属规则，不只是本次 S6 的落点。** 该约定必须写入包的
`README.md` 与库文件头注释，使后续任何 agent 打开此包即可看到边界。

**属于本包**（今后一律收进来）：

- 设备发现（mDNS/DNS-SD）与配对
- P2P 连接建立：信令交换、ICE、NAT 穿透、TURN 兜底
- 端到端传输：DataChannel / WebSocket 之上的分块、背压、续传
- 传输层加密与设备互认（channel binding、DEK 包装）
- 中转（SaaS relay）通道及其删除生命周期
- **今后新增的任何 P2P 同步能力**（含 S3B/S3C 的连接层 ——
  边界见 `docs/superpowers/specs/2026-08-03-s3b-s3c-s6-boundary-handoff.md`）

**不属于本包**（明确排除，防止越界）：

| 不属于 | 归属 | 理由 |
|---|---|---|
| blob 的**本地落盘** | `LocalBlobStore` 实现（待命名任务，§7.1a） | 本包只管「传」，不管「存」 |
| 记录清单比对 / 全量对齐 | S1c | 那是记录层语义，不是连接层 |
| 云端**公开**分享 | S2 | 生命周期相反（长期公网可读 vs 5 分钟即删） |
| 业务侧 Repository / UseCase | 各业务模块 | 本包不含业务语义 |

**为什么必须独立成包而非并入 `persistence_core`**：

1. `flutter_webrtc` / `bonsoir` 带**原生依赖**，并入 core 会让所有依赖 core 的模块
   （含纯 Dart 测试、Web 构建）都背上这些原生库
2. `persistence_core` 已有 Web 兼容债（2 处 `dart:io`，§1.3），不宜再加平台耦合
3. 端口在 core（`transport.dart` 等契约），实现在 p2p —— 符合本仓既有的
   「契约与实现分包」惯例（如 `persistence_drift` / `persistence_firebase`）

版本按仓库惯例锁定精确版本（不用 `^`）。

许可证均为 MIT / Apache-2.0 / BSD-3，**无 GPL/AGPL 污染**，适用于闭源移动分发。

平台覆盖核对：`bonsoir` 不支持 web（符合 D3 —— Web 不做 LAN 发现）；
`flutter_webrtc` 经 `dart_webrtc` 支持 web；`cryptography` 原生支持 web。

> **`flutter_secure_storage` 于 2026-08-03 第二轮讨论后加回**（前一版曾移除）。
> **它只在 macOS/Windows/Linux 启用，iOS/Android 不用**（§5.3.1）。
> 用途是**只存那把 32 字节 DEK**，不碰 blob 文件本身（§5.3.0）——
> 真正的文件加密由 `cryptography` 的 AES-GCM 承担。
> **Web 端是否使用该包，留空待人类决定。**

---

## 7. 待决项汇总

### 7.1 阻塞开工（必须先定）

| 编号 | 事项 | 建议 |
|---|---|---|
| **D6** | ~~新代码放 `persistence_core` 还是新建包~~ → **已决：新建 `persistence_p2p`** | 见 §7.3 D6 |
| **D7** | `BlobCipherResolver.resolve()` 改 `Future` 的契约变更流程 | **已决：走 S1a 契约变更评审**（人类 2026-08-03 批准启动） |
| **D8** | ~~S1c 是否先于 S6~~ → **问题本身有误，见下方「命名冲突」** | 改为 **D19** |
| **D18** | Web 端的落盘加密方案 | **已决：本期不考虑**（人类 2026-08-03）。Web 端 S6 能力本期不交付 |
| **D19** | **blob 存储实现（`LocalBlobStore` + `BlobGateway`）由谁承接、编号叫什么** | **阻塞 S6** —— 详见下方专节 |

#### 7.1a ⚠ 编号冲突：S6 依赖的不是 S1c

**这是一个必须澄清的错误，前几版文档中我把它记成了「S1c」。**

实读 `docs/superpowers/specs/2026-08-03-s1c-full-reconciliation-design.md`（另一 AI agent 撰写）后确认：
**S1c = 全量对齐（Full Reconciliation），处理的是「记录清单比对」，与 blob 无关。**
该文档 §3.2③ 原文：

> **③ 清单只覆盖记录，blob 是独立阶段**
> `BlobHandle` 有独立的 `plaintextSha256` 与密文清单 id，媒体走 `reconcileRefs` 引用计数，
> **不在 `t_entity_stamp` 里**。
> 后果：全量对齐完成后**记录齐了但图片可能还没下载**。
> blob 补齐是独立阶段，可延后、可按需、可仅在 WiFi 下进行。

**结论：S1c 与 S6 在数据面上不重叠、不冲突。** S1c 管字段型记录的清单比对，S6 管字节传输。

**但 S6 真正的依赖仍然缺失且无人承接。** 实测证据：

```
grep -rln "LocalBlobStore|BlobGateway|RecordBlobUnitOfWork" core/lib drift/lib firebase/lib
→ 只命中 core/lib/model/ 下 8 个契约文件自身，零实现、零消费者
```

`LocalBlobStore`（本地字节落盘）与 `BlobGateway`（远端 blob 网关）**只有端口签名**。
**S6 把字节传过来之后无处可写。**

| 编号 | 名称 | 职责 | 状态 |
|---|---|---|---|
| S1c | 全量对齐 | `t_entity_stamp` 记录清单比对 | 已有文档，另一 agent 负责 |
| **【待命名】** | **blob 存储实现** | `LocalBlobStore` + `BlobGateway` 的 drift/文件系统/Firebase 实现 | **无文档、无人承接** |
| S6 | P2P 同步 | 字节的发现、连接、传输、加密 | 本文档，进行中 |

**建议编号为 S1d 或 S5-blob-store，避免与已被占用的 S1c 撞名。**
**该任务必须先于 S6 落地** —— 否则 S6 的接收端无处写入，无法收口。
调研已确认 pub.dev **无内容寻址 blob store 现成包**（13 个关键词检索），必须自建于 drift + 文件系统。

#### 7.1b 前置修复项（不属 S6 交付物，但会绊倒 S6）

| 编号 | 事项 | 当前状态 |
|---|---|---|
| **P1** | `AndroidManifest.xml` 加 `allowBackup="false" fullBackupContent="false"` | **未达标**（实查，§4.3 缺口 1）。不修则私有数据静默上 Google Drive |
| **P2** | iOS `Info.plist` 加 `NSLocalNetworkUsageDescription` + `NSBonjourServices` | **未达标**（实查，§4.3 缺口 2）。不修则 iOS LAN 发现静默失败 |
| **P3** | macOS 两个 entitlements 加 `keychain-access-groups` | 未配（§5.3.3 第 2 条）。不修则桌面端密钥「看似写入实际未写」 |
| **P4** | `persistence_core` 的 2 处 `dart:io` 条件导入 | 未修（§1.3）。阻断 Web 编译 |

**P1/P2 的共同特征是「静默失败」** —— 不报错、不崩溃，只是行为与设计意图相反。
这类缺口无法靠功能测试发现，只能靠门禁静态检查（已列入 §7.4 第 3、5 项）。

### 7.2 不阻塞开工

| 编号 | 事项 | 建议 |
|---|---|---|
| **D4** | 大文件是否限制仅 Wi-Fi 传输（蜂窝只同步 row） | 默认开启。TURN 中继 MP4 带宽费可观，且设计稿 §6.2（:1052）已定「P2P 的价值定位是省钱与速度」 |
| **D10** | ~~中转 TTL 具体取值~~ → **语义已修正** | 它不是「主删除时限」而是「GCS 生命周期规则的 age 值」，取 **1 天**。主删除由接收端客户端在解密后立即执行（§4.2.2 三层删除） |
| **D11** | chunk 大小是否可协商 | 建议固定 16KB。可协商会引入跨端不一致的调试成本，收益有限 |

### 7.3 已决策（本轮定稿，不再讨论）

| 编号 | 决策 | 日期 |
|---|---|---|
| **D1** | 匿名用户不启用同步与加密；`link` 邮箱后才启用，无迁移逻辑 | 2026-08-02 |
| **D2** | ~~加恢复码机制~~ → **作废**（随 Master Key 一同移除，见 §8） | 2026-08-03 |
| **D3** | Web 参与 WebRTC（Firestore 信令），不做 LAN 发现 | 2026-08-02 |
| **D9** | 接收方必须在线（5 分钟内完成）→ 会话密钥可全部临时生成 | 2026-08-03 |
| **D12** | ~~弃用 `flutter_secure_storage`，落盘靠沙盒 + 系统全盘加密~~ → **已被 D15 推翻** | 2026-08-03 |
| **D13** | 设备全丢 = 私有数据丢失（接受）；容灾模型为「单端丢失从另一端重新同步」 | 2026-08-03 |
| **D14** | Master Key 与信封加密两套方案本轮均不实现，完整保留为未来预留（§4.5） | 2026-08-03 |
| **D15** | **加回 `flutter_secure_storage` 10.3.1，但只在桌面端启用、只用于存 DEK**（推翻 D12） | 2026-08-03 |
| **D16** | **移动端（iOS/Android）不做应用层落盘加密**，理由是全盘加密出厂强制开启且关不掉 | 2026-08-03 |
| **D17** | **每设备一把独立 DEK，严禁跨设备共享落盘密钥** —— 这是 D13 容灾模型成立的前提 | 2026-08-03 |
| **D6** | **新建 `persistence_p2p` 包**。且约定：**今后所有需要端到端 P2P 连接的数据同步能力，全部收进此包** | 2026-08-03 |
| **D18** | **Web 端落盘加密本期不考虑** → Web 端不交付 S6 能力，相关约束留待后续 | 2026-08-03 |
| **D20** | **中转删除采用三层机制**，服务端兜底用 **GCS 生命周期规则**（零代码），**不自建定期扫描任务**（§4.2.2） | 2026-08-03 |
| **D21** | 中转目录固定为 `private/p2p/{uid}/{随机UUID}`，**私有对象名必须随机、禁用内容哈希**（§4.2.3） | 2026-08-03 |

### 7.4 S6 的验收标准必须包含（易被漏掉）

1. **channel binding 负测试** —— 构造一个「签名只覆盖 nonce、不覆盖 DTLS 指纹」的实现，
   证明它能被测试抓住（§5.2b）
2. **落盘路径断言** —— grep 全仓禁止 `getExternalStorageDirectory`、`MediaStore`、
   `PHPhotoLibrary` 出现在私有 blob 路径上（§4.3 约束 1/2）
3. **`allowBackup="false"` 门禁** —— 检查 `AndroidManifest.xml`（§4.3 约束 3）。
   **当前实查为未达标状态**（缺口 1），不是预防性检查而是待修项
4. **中转 TTL 生效验证** —— 不能只验证客户端删除逻辑（§4.2）
5. **iOS `Info.plist` 门禁**（本轮新增）—— 检查 `NSLocalNetworkUsageDescription`
   与 `NSBonjourServices` 存在。**当前实查为缺失**（缺口 2），否则 iOS LAN 发现静默失败
6. **macOS Keychain 写入自检**（本轮新增）—— 启动时写入后立即读回，
   不一致则**显式报错而非静默降级**。理由见 §5.3.3 第 2 条：
   未配 entitlement 时该包「看起来写成功了但根本没写」
7. **两个 entitlements 文件的 `keychain-access-groups` 门禁**（本轮新增）——
   `DebugProfile.entitlements` 与 `Release.entitlements` **都要检查**，
   只配一个是最常见的漏法
8. **平台分流断言**（本轮新增）—— 证明 iOS/Android 代码路径**不会**调用
   `flutter_secure_storage`，桌面端**必须**调用。防止分流写反或退化成全平台统一
9. **单设备独立 DEK 断言**（本轮新增）—— 证明落盘密钥**不跨设备传输、不跨设备共享**。
   这是 §5.3.4 「密钥丢失影响域限于单设备」成立的前提，一旦被违反就退化成 §4.5 方案 A

---

## 8. 决定记录

### 8.1 架构选型

- 2026-08-02: 否决「Rust 桌面端当 LAN Hub」。**理由于 2026-08-03 更正** —— 原写「实测全仓零 Rust」，
  但人类澄清 Rust 是未来版本目标。真实理由是**架构上多余**：该方案自己承认跨网段必须有公网信令，
  再加一套 LAN Hub 等于把 SDP/ICE 交换实现两遍，且要处理 LAN↔蜂窝切换时的信令迁移。
  与有无 Rust 无关。附带好处：无中心 Hub 即无单点故障。
- 2026-08-03: 因 Rust 端为未来目标，**新增架构约束**：所有跨设备协议必须是线上可互操作的标准协议
  （mDNS/DNS-SD、Ed25519/RFC 8032、WebRTC、AES-GCM/X25519/HKDF），
  不得依赖 Dart 特有序列化。这样未来 Rust 端用 `webrtc-rs`+`ed25519-dalek` 可直接接入，
  无需改动已交付 Dart 代码、无需 FFI 绑定。候选方案「用国际标准便于接入异构端」这一主张因此成立。
- 2026-08-02: 否决「Flutter Web 不能用 WebRTC」。理由：实测 `flutter_webrtc` barrel 有
  `if (dart.library.js_interop)` 条件导入至 `dart_webrtc`（`platform:web`，月下载 274078），
  浏览器原生支持 WebRTC。人类于 2026-08-03 确认此点为需求。
- 2026-08-02: 否决「Web 端扫网段发现设备」。理由：浏览器无 API 可获取本机 LAN IP
  （mDNS candidate 混淆自 2018 年起即为封堵此路而设计），且 CORS + Private Network Access 会拦截。
- 2026-08-02: 否决「DataChannel 自动断点续传 / 整文件 send()」。理由：SCTP 可靠性仅限单次连接存活期，
  跨连接续传属应用层；DataChannel 单消息上限使整文件 `Uint8List` 在移动端必然 OOM。
- 2026-08-02: 采信设计稿 §6.3（:1064）的 NAT 穿透数字（STUN 80–90%，TURN 后近 99%）而非候选方案的「70%」。
  理由：候选方案含 `stun:://google.com` 这一无法运行的写法（正确为 `stun:stun.l.google.com:19302`），
  表明其内容未经实际运行验证。
- 2026-08-02: 选定 `bonsoir` 而非 `multicast_dns`。理由：后者源码含
  `// TODO(dnfield): Support queries coming in for published entries.`，只能查询不能广播，
  而设备互相发现要求双向。
- 2026-08-02: 选定 `cryptography` 而非 `sodium`。理由：`sodium` 含 FFI 不支持 Web，
  与 Web 为真实交付目标（§1.3 实证）冲突。代价是接受单人维护风险，
  缓解手段为把加密收敛在 `BlobCipher` 实现类内。

### 8.2 安全设计

- 2026-08-02: 采纳 Ed25519 挑战-应答做设备互认，但**砍掉设计稿 §6.3（:1072）的带外指纹人肉比对**。
  理由：公钥存 Firestore 的 TOFU 风险需先攻破 Firebase 账号，而攻破账号者已能直读云端数据，
  带外验证不提供额外保护。防护改为 Firestore 安全规则限制 uid 写入路径。
- 2026-08-02: **保留 channel binding**（设计稿 §3.5 :794 与 `transport.dart:158` 的要求）。
  理由：它与带外比对是两件不同的事。不做 channel binding 时，攻击者可在 SDP 交换阶段替换
  DTLS 指纹，导致「验签验的是 A、传数据传给了 B」，且该攻击**不需要攻破 Firebase 账号** ——
  §5.2 的论证在此不适用。做法：签名对象为 `nonce ‖ dtlsFingerprint`。
- 2026-08-03 **【人类决定 D14】舍弃 Master Key + Wrapped Key，改为一次一密**。
  理由：人类澄清「数据只在同步时需要加密，同步完就该删除；中转存储不超过 5 分钟」。
  Master Key 的全部价值来自「密文长期存储」前提，该前提消失后其解决的四个问题
  （改密码后仍可解、新设备靠密码独立接入、设备全丢可恢复、无需持久密钥）
  有三个不再存在，第四个由「弃用应用层落盘加密」绕开。
- 2026-08-03 **D2（恢复码）作废**。理由：恢复码存在的唯一目的是防「密码重置导致 Master Key 永久丢失」，
  Master Key 移除后该故障模式不存在。
- 2026-08-03 **指出并由人类裁决的冲突**：共享 Master Key 与人类认可的容灾模型
  （「单端数据全丢，从另一端重新同步」）**互斥** —— 前者制造了一个全端共享单点，
  一次 `sendPasswordResetEmail`（`firebase_account_auth_gateway.dart:121`）就让所有端同时变砖，
  此时「从另一端重新同步」救不了任何东西。人类裁决：本轮不做，写入 §4.5 作为未来预留。
- 2026-08-03: **§4.5 同时保留两套方案而非只保留 Master Key**。理由：人类问及「除 Master Key
  还有哪种方案」，经辨析后确认信封加密（Envelope Encryption，信任锚点=设备私钥）是不同的东西，
  且**它与容灾模型不冲突、并额外提供设备撤销能力**（设计稿 §6 原本要求、Master Key 做不到）。
  两者解决的问题不同，不可混用，故并列记录并给出选型建议表。
- 2026-08-03 **【人类决定 D12】弃用 `flutter_secure_storage`**。评估过程记入 §5.3：
  该包已到 10.3.1（federated 重写），**macOS/Windows 桌面端均有可用系统密钥库，技术上不构成障碍** ——
  这更正了基于 9.x 形成的早期判断。弃用的真实理由是四个问题：
  ① Windows 密钥跟随用户账号不跟随硬件，重装系统即失效；
  ② macOS 未配 entitlement 会**静默失败**（README:307「appearing to be written successfully but never actually being written」）；
  ③ `useSecureEnclave` 中途开启会丢数据（README:285-287）；
  ④ Android 有升级迁移丢数据的历史 issue（#1043/#1079/#1166/#1208）。
  合起来引入了「密钥丢失 = 数据变砖」这一新失败模式，而增益仅限「root 后直接拷文件」。
- 2026-08-03 **补入 §4.3 的三条落盘硬约束（本轮疏漏项）**。起因：人类问「其他 App 和系统相册
  能不能看到存在本地的敏感照片」。核实后确认沙盒隔离在 iOS/Android 上有效，
  但**该有效性取决于 S6 自己的落盘路径选择**，故必须写成硬约束：
  ① 只落 app-specific 目录（落 external storage / `/sdcard/` 会立即对系统相册与所有有存储权限的 App 可见）；
  ② 禁写 `MediaStore` / `PHPhotoLibrary`；
  ③ **Android 必须 `allowBackup="false"`** —— Auto Backup 默认对 app-specific 目录开启，
  会自动上传到 Google Drive，**在背后推翻「私有数据不上云」这一决策**（数据仍上了云，只是上的是 Google Drive）。
- 2026-08-03: 澄清落盘保护是**两层**而非一层。此前表述只提「系统全盘加密」，不完整 ——
  防「其他 App / 系统相册」的是 App 沙盒隔离（第一层），防「设备被物理取走」的才是全盘加密（第二层）。
  两者防的是不同攻击者，且都不防 root。
- 2026-08-03 **【人类决定 D15/D16/D17】推翻 D12，加回 `flutter_secure_storage`，但改为分平台启用。**
  人类原话：「不行就把那个刚才去除的 `Flutter_Secure_*` 加回到文档里面，
  它用来负责 Windows 或者是 Linux 的加密以及 Web 的」。
  **改判的技术依据是一个此前未被明确的区分**：全盘加密在 iOS/Android 上**出厂强制开启且关不掉**，
  而 macOS 的 FileVault、Windows 的 BitLocker 是**用户开关，可能整个没开**。
  因此桌面端的「第二层」可能不存在，必须由应用层补回来；移动端补则是净损失。
  **分界线不是「移动 vs 桌面」这个直觉，而是「系统全盘加密是否出厂强制」这个事实。**
  D12 的四个问题（§5.3.3）依然成立，但性质从「弃用依据」变为「启用前必须逐条给对策」（§5.3.4）。
- 2026-08-03 **确立「密钥保管器 ≠ 文件加密器」的分工**（§5.3.0）。
  `flutter_secure_storage` 的 API 是 `write({key, value})`，**值是 String**，
  用途是存 token / 小配置，Keychain 单条目实际限制在 4KB 量级。
  **把 blob 明文塞进它会直接 OOM。** 正确形状是两包配合：
  该包只存那把 32 字节 DEK，`cryptography` 的 AES-GCM 逐 chunk 加密文件本身。
  这个形状恰好是 §4.5 方案 B（信封加密）的**单设备退化形态**，
  且边界正好落在 S1a 已定死的 `BlobCipher` 端口上，**不需要改契约形状**。
- 2026-08-03 **【D17】每设备一把独立 DEK，严禁跨设备共享落盘密钥。**
  这不是实现细节而是**架构约束**：一旦共享，就退化成 §4.5 方案 A 的形态 ——
  制造全端共享单点，一次失效让所有端同时变砖，
  此时 D13 的容灾模型（「从另一端重新同步」）救不了任何东西。
  独立 DEK 把「密钥丢失」的影响域限制在单设备内，从而使
  「密钥丢失 = 数据变砖」这一失败模式降级为「本端数据全丢」，落回 D13 已接受的范围。
  已列入 §7.4 第 9 项验收断言。
- 2026-08-03 **macOS 的 App Sandbox 经实证为已开启**，纠正 §4.3 表中原「视是否启用」的保守写法。
  实查 `xuan-shell/macos/Runner/{Release,DebugProfile}.entitlements` 两个文件
  **都含** `com.apple.security.app-sandbox = true`（`DebugProfile` 另有 network.client/server，
  正是 S6 所需）。**macOS 第一层与 iOS/Android 同级，真实弱点在第二层（FileVault 非默认）。**
- 2026-08-03 **实查发现两项当前即未达标的配置缺口**（§4.3 缺口 1/2，已列为 P1/P2）：
  ① `AndroidManifest.xml` 的 `<application>` 只有 label/name/icon 三个属性，
  **无 `allowBackup`** 即取默认 `true` —— §4.3 约束 3 当前是未满足状态，
  私有 blob 一落盘就会被 Auto Backup 上传 Google Drive；
  ② iOS `Info.plist` 中 `NSLocalNetworkUsageDescription` 与 `NSBonjourServices`
  **两键均不存在** —— iOS 14 起 mDNS 发现必须声明，否则 `bonsoir` 静默失败。
  **两者的共同特征是静默失败：不报错、不崩溃，只是行为与设计意图相反。**
- 2026-08-03 **【人类指示 D18】Web 端落盘方案留空。** 人类原话：
  「你不用调研 Web，Web 这个回来留空，回来我去看」。
  已记录的既有事实（不构成结论）：该包 Web 实现 README 自称 experimental、
  「Use at your own risk」，密钥存 LocalStorage，仅 HTTPS/localhost 可用，跨浏览器不可移植。
  **该端方案由人类决定，本文档不作推定。** 已列为阻塞项 D18（Web 是真实交付目标，不是可选端）。

### 8.3 契约与范围

- 2026-08-02 **撤回先前判断**：不删除 S1a 的 `BlobCipher`/`keyVersion`/`BlobStatus.partial` 等契约。
  理由：曾因误判「放弃 E2EE 则加密契约无用」而建议删除，实际上放弃的是「云端不可读」，不是「本地加密」。
  2026-08-03 进一步细化（§5.1）：本方案中 `BlobStatus.partial` 与 `plaintextSha256` 是活跃路径，
  而 `keyVersion` 与 `undecryptable` 在本轮是**预留位**（成本为零，§4.5 落地时即用上）——
  转译 ACT 时不应为预留位编造用途。
- 2026-08-03: `BlobCipherResolver.resolve()` 仍建议改 `Future<BlobCipher>`（D7），
  但**理由更新** —— 原理由「Master Key 首次解盲盒需 async」已随 Master Key 作废；
  新理由是中转路径的 DEK 需经 X25519 ECDH + HKDF 派生，该操作本身异步。
- 2026-08-02: `sqlcipher_flutter_libs` 版本号实测为 `0.7.0+eol`，作者已标记 End of Life，不用于新工作。

---

## 9. 踩坑墓地

- 2026-08-02: 曾把研究筛子设为「必须 E2EE」，导致过早排除 Ditto 与 Couchbase Lite P2P，
  且完全没查 Syncthing —— 而 Syncthing 恰是功能上最匹配的。
  **结论：选型的筛子必须先问人类要什么，不能从设计稿的既有前提反推。**
- 2026-08-02: 曾断言「放弃 E2EE 则 S1a 的加密契约成为死代码」。证伪：放弃的是「云端不可读」，
  不是「本地加密」，两者是不同的东西。
- 2026-08-02: 曾以为 `AesGcm` 可流式加密后随机 seek。实测证伪：
  `AesGcm extends Cipher`（`algorithms.dart:364`）而非 `StreamingCipher`（`:2117`），不支持 seek。
  **结论：必须按 chunk 独立加密（每 chunk 独立 nonce + MAC）。**
- 2026-08-03: 曾以「整个 monorepo 零 Rust」为由否决 LAN Hub 方案。**判断方式有误** ——
  把「当前没有」当成了「永远没有」。人类澄清 Rust 是未来版本目标。
  否决结论仍成立，但理由必须换成架构层面的（两套信令冗余），而非事实层面的。
  **结论：核实「当前不存在」时，必须同时确认「是否为未来规划」，两者结论可能不同。**
- 2026-08-03: 曾笼统建议「砍掉 Master Key」。**过于粗糙** —— Master Key 同时承担四项职责
  （改密码后仍可解 / 新设备靠密码独立接入 / 设备全丢可恢复 / 落盘加密无需持久密钥），
  人类的决策只废掉前三项，第四项当时仍然成立。
  **结论：否决一个方案前，先把它承担的职责逐项列清，再逐项判断是否失效。**
- 2026-08-03: 关于 `flutter_secure_storage` 的早期结论基于 9.x 版本，而实际最新为 10.3.1
  且已 federated 重写、桌面端能力完备。**结论：引用包的缺陷时必须核对当前版本，
  「我记得它有问题」在快速迭代的包上极易过期。**
- 2026-08-03: 曾只写「落盘靠系统全盘加密」，遗漏了 App 沙盒隔离这一层，
  也遗漏了 Android Auto Backup 会把沙盒文件自动上传 Google Drive 这一事实。
  后者若不处理，会让「私有数据不上云」的决策在背后失效。
  **结论：讲「依赖系统机制」时，必须同时列出该机制的默认行为中与本方案意图相反的部分。**
- 2026-08-03: 曾对四端一律建议「不做应用层落盘加密」。**判断颗粒度错了** ——
  把「iOS/Android 上加密是净损失」这个正确结论，错误地推广到了 macOS/Windows/Linux。
  遗漏的关键事实是：iOS/Android 的全盘加密**出厂强制且关不掉**，
  而 FileVault / BitLocker 是**用户开关，可能整个没开**。
  **结论：「依赖系统机制」的方案，必须逐平台核实该机制的默认启用状态，
  不能因为机制同名（都叫「全盘加密」）就假设保障等价。**
- 2026-08-03: 差点把 `flutter_secure_storage` 当成文件加密方案来用。
  它的 API 是 `write({key, value})` 且 value 是 String，Keychain 单条目限制 4KB 量级 ——
  **拿它加密 500MB 的 MP4 会直接 OOM**。它是密钥保管器，不是文件加密器。
  **结论：引入一个「安全存储」包之前，先看它的 API 形状能装多大的东西，
  「安全存储」这个名字不告诉你它的容量假设。**
- 2026-08-03: 曾把 Windows/Linux 列入「加密没办法的端」。**事实核实后否证** ——
  `xuan-shell` 根本没有 `windows/` 与 `linux/` 平台目录（git tracked 文件数为 0），
  这两个端**当前编译不出来**，属未来端而非待修端。
  同时真正薄弱的 Web 端反而被漏掉了（有已 commit 的 wasm 运行时产物，是真实交付目标）。
  **结论：讨论「哪些端有问题」之前，先确认「哪些端存在」—— 否则会给不存在的端记债，
  同时漏掉真实存在的端。**
