# 任务: storage-s3c-signaling
负责: claude ｜ 分支: agent/claude/storage-s3c-signaling ｜ 开工: 2026-08-04
状态: 待验收

## 目标
交付 `SignalingChannel` 端口及其配套值类型（零实现），使「局域网直连」与「云端中转」
两种拓扑能塞进同一套契约，且「对端掉线可感知」与「信令不含用户数据」两条约定
可被测试机械断言，而非只写在注释里。

## 计划
- [x] P1 通读材料并写下接口草案：设计稿 §9.5(C2) / §6.3(C3) / §6.3.1(C1) / §3.5，
      `core/lib/model/transport.dart` 全文，`dataset/dataset_registry.dart`（抄注册期
      强制不变式的形制），`core/test/transport_contract_test.dart`（抄 `_FakeLanFabric`
      内存网络与 async/await 写法），AGENTS.md。**先写草案再写码**
      → 产出 `docs/storage-s3c-signaling/INTERFACE-DRAFT.md`
- [x] P2 值类型：会话描述（offer/answer）、ICE candidate、信令信封、对端存活事件。
      信封必须是**封闭类型**（sealed / 有限枚举变体），使「塞不进用户数据」成为结构性
      事实而非承诺——见「难点三」
- [x] P3 `SignalingChannel` 端口本体，落 `core/lib/model/signaling.dart`。
      必须同时容纳 LAN 与云端两种拓扑——见「难点一」；必须暴露对端存活语义——见「难点二」
- [x] P4 契约测试之一：内存 LAN fabric fake（照抄 `_FakeLanFabric` 体例）
- [x] P5 契约测试之二：内存云会合点 fake。**同一套契约测试对两个 fake 各跑一遍**
- [x] P6 架构守卫测试（A1/A2/A5 的源码扫描）+ dartdoc 覆盖下限随新增公开声明上调
- [x] P7 逐条变红自检：每条契约测试注入违规 → 确认变红 → 复原，
      **逐条把「注入了什么、红在哪」写进「决定记录」** → 12/12 全部变红，零恒绿

## 验收标准
- [x] A1 零实现：`signaling.dart` 内无任何 `Impl` 类、无 `UnimplementedError`、无具体 SDK import
- [x] A2 后端无关可门禁：源码扫描断言 `signaling.dart` 不出现 firebase / rtdb / bonsoir / webrtc 任何字样
- [x] A3 双实现可塞入：同一套契约测试对两个形态迥异的 fake（LAN fabric / 云会合点）各跑一遍，全绿
- [x] A4 掉线可感知：契约测试断言对端消失时订阅方能观测到
- [x] A5 隐私约定可断言：信令载荷不含 scopeUid / 用户名 / 设备名，且是**测试断言**不是注释
- [x] A6 每条契约测试做过变红自检，且逐条在「决定记录」写明注入了什么、红在哪
- [x] A7 `bash scripts/run_s1a_analyze_gate.sh` 退出码 0
- [x] A8 `cd core && flutter test` 全绿
- [x] A9 `bash scripts/run_policy_negative_check.sh` 退出码 0
验收命令: bash scripts/run_s1a_analyze_gate.sh && (cd core && flutter test) && bash scripts/run_policy_negative_check.sh

## 当前状态
刚完成: P1–P7 全部完成，A1–A9 全部通过。契约层已交付。
半成品位置: 无。工作树干净（唯一未跟踪文件是 P7 的自检脚本 tmp_mutation_check.sh）。
下一步: 等人类验收。下一轮是 S3c-b（LocalSignaling，新建 p2p 包）。
微观意图: 无在途编辑。
验证方法: 验收命令三条全绿（A7 ✅ / 121 条测试全绿 / A9 ✅）；
P7 变红自检 12/12 全部变红。

## 三个真正的难点（不是填模板，本任务的价值全在这里）

### 难点一 · 接口必须同时容纳两种拓扑，否则它不是接口
- `LocalSignaling`：bonsoir 发现对端 `IP:port` → **直接连过去**换几 KB SDP → 全程零外网
- `CloudSignaling`：双方都连到一个**第三方会合点**，通过它中转

二者差异是真实的：LAN 有直接地址但没有共享房间；云端有共享房间但建连前没有地址。
**如果接口只有一种能塞进去，那它就不是接口。**
验收 A3 会强制：同一套契约测试对两个 fake 各跑一遍。

### 难点二 · 对端掉线必须在接口里可感知，不能漏
C3 选 RTDB 作首实现的**唯一技术理由**是 `onDisconnect()`——掉线时自动摘除信令节点
（Firestore 无原生等价物）。若接口不暴露「对端存活 / 已摘除」语义：
1. 这个优势体现不出来；
2. **换后端时会漏掉这条要求**，后人不知道新后端必须具备什么能力。

### 难点三 · 信令只传「怎么连」，不传任何用户数据
SDP + ICE candidate，连上后即失效。所以信令后端的隐私敏感度远低于数据通道。
**但这一点必须在契约上可验证。** 参考既有做法：`Transport.advertise()` 返回
`AdvertisementHandle`，把隐私约定从一句空话变成一条可断言的返回值
（见 `transport.dart` 该类的 dartdoc，与 `transport_contract_test.dart` 的
「广播的隐私约定（补丁前无处可验）」组）。

## 本轮不做（做了算越界）
- ❌ 不实现 `SignalingChannel` 的任何真实现（LocalSignaling / CloudSignaling 都是下一轮）
- ❌ 不实现 `Transport`（WebRTC 实现是 S3c-c）
- ❌ 不实现 `DeviceKeyStore` —— 属 **S6**（安全存储、设备配对）
- ❌ 不碰 `core/lib/model/transport.dart`。若认为它有缺口，写进「决定记录」上报人类，不要自己改
- ❌ 不碰 S1b 的任何文件（它正在 `-iso` 分支上活跃开发）
- ❌ 不建 `p2p` 包（下一轮建）

## 决定记录
- 2026-08-04: 继承裁定 C1（设计稿 §6.3.1）—— oplog 与 blob **共用**同一条 P2P 连接，
  不是两条。理由：若 oplog 只走云端，离线局域网能传 500MB 照片却传不了指向它的那条记录；
  且 `StreamKind.oplog` 会成为死代码。**不许推翻**
- 2026-08-04: 继承裁定 C2（设计稿 §9.5）—— S3b 不再是独立子系统，降级为 S3c 的
  `LocalSignaling`。否决「S3b 独立（mDNS + 裸 TCP/TLS socket）」：帧协议、心跳、多路复用、
  拥塞控制、分片重组全部要手写，而 DataChannel 免费提供。**不许推翻**
- 2026-08-04: 继承裁定 C3（设计稿 §6.3）—— 信令走 `SignalingChannel` 接口，RTDB 只是
  **第一个**实现。不得让 WebRTC 实现直接 import `firebase_database`。**不许推翻**
- 2026-08-04: NAT 打洞用 `flutter_webrtc 1.6.0` 内建 ICE（STUN 探映射 → 候选对打洞 →
  TURN 兜底），**不手搓**。否决手搓：ICE 是成熟规范，重写一遍无收益且必然有洞
- 2026-08-04: 局域网发现用 `bonsoir 7.1.4`。否决 `multicast_dns`：其源码留有
  `// TODO(dnfield): Support queries coming in for published entries.`，**只能查不能播**，
  选它是死路
- 2026-08-04: 设备私钥用 `flutter_secure_storage 10.3.1`，且契约上**不暴露私钥**
  （只有 sign/verify）。见 `transport.dart` 的 `DeviceKeyStore`。本轮不实现它
- 2026-08-04: D7（`BlobCipherResolver.resolve()` 改 `Future<BlobCipher>`）已在 main
  `bd2d7c9` 落地，**此事已了，不要再纠结**
- 2026-08-04: 分包本身就是 C3 的门禁 —— 下一轮 `p2p` 包的 pubspec 不含任何 firebase 依赖，
  于是「WebRTC 实现不得直接 import firebase_database」从一句话变成一条可自动检查的事实。
  本轮设计接口时按这个分层来
- 2026-08-04: 立项基线取 main `6ae98d5`（派工单写的 `6cd7a66` 期间已前进两笔：monorepo
  约定门禁 + 本任务登记）。已核实 D7 与 transport 被动侧在 `6ae98d5` 上均在
- 2026-08-04: **契约文件刻意不点名任何后端。** 首版 dartdoc 里写了 RTDB / Firestore /
  `firebase_database` / bonsoir / WebRTC，被 A2 守卫抓红。判断是**守卫对、契约错**：
  契约里出现后端名（哪怕只在注释里）会让后人以为绑定了它。改为只声明「**后端必须
  具备什么能力**」——服务端可感知客户端断开并自动摘除其信令节点——并补一句「若后端
  无此原生能力，必须自行实现心跳 + 超时清理，代价须计入选型评估」。这比点名 RTDB
  更有用：换后端的人读到的是**判据**，不是既成结论。具体选型留在设计稿与本纪要
- 2026-08-04: **A5 做成两层。** 样本层断言「当前载荷不含 scopeUid / 设备名」只抓样本；
  结构层断言 `signaling.dart` 无 `Map` / `dynamic` 且 envelope 是 `sealed`，才抓规则。
  只有后者挡得住「后人往自由载荷里塞东西」
- 2026-08-04: 门禁脚本里硬编码的「18 个文件」改为**动态统计**（`S1A_COUNT`）。
  理由：写死的数字会与白名单脱节，且每次加文件要改两处

### P7 变红自检逐条结果（A6，12/12 全部变红，零恒绿）

自检方法：逐条注入违规 → 只跑被它针对的那条测试 → 确认变红 → 复原。
脚本 `tmp_mutation_check.sh`（未跟踪，用后即弃）。

| # | 注入了什么 | 该抓它的测试 | 红在哪 |
|---|---|---|---|
| M1 | LAN fake 的 `send` 把信封回显给自己 | incoming 不回显本端发出的信封 | `Expected: empty` |
| M2 | 云端 hub 把信封回显给发送者 | 同上（云端拓扑） | `Expected: empty` |
| M3 | 把 `departed` 降级成 `awaiting`（合并两态） | 对端 close 后观测到 departed | `Expected: departed, Actual: awaiting` |
| M4 | 云端后端不具备断线感知能力（`simulateAbruptDisconnect` 空转） | 非正常断开也必须产出 departed | `Expected: departed, Actual: present` —— 红在「后端必须判定 departed，而不是让调用方靠超时去猜」 |
| M5 | LAN fake 在 departed 后静默丢弃而非抛错 | departed 时 send 必须抛错 | `returned a Future that emitted null` —— 红在「静默丢弃会让调用方以为发出去了」 |
| M6 | 云端 hub 无视会合标识，广播给所有房间 | 不同会合标识互不串扰 | `Expected: empty` |
| M7 | 云端 fake 只投递第一条 candidate | trickle ICE 多条按序全达 | `Expected: an object with length of <5>` |
| M8 | 契约 dartdoc 里点名 Firebase RTDB | A2 后端无关 | `Expected: false` |
| M9 | 给 `ByeEnvelope` 加 `Map<String, dynamic>? extra` 敞口 | A5 结构层无 Map/dynamic 敞口 | `Expected: false` |
| M10 | 契约 dartdoc 里提 `UnimplementedError` | A1 契约文件零实现 | `Expected: false`「契约层不得有占位实现」 |
| M11 | `PeerPresence` 多加一个取值 | 取值锁定 | `Expected: ['awaiting','present','departed']` |
| M12 | LAN fake 订阅后不立即给当前状态 | 对端尚未到场时是 awaiting | `Expected: non-empty` |

**M10 第一次注入不算数，已重做。** 首次注入的是「给 `SignalingChannel` 新增一个
`reset()` 占位方法」，结果红在**编译失败**（两个 fake 没实现新成员），而不是 A1 断言。
编译失败也是红，但它抓的不是 A1 想抓的东西——**A1 断言本身的抓手当时并未被验证**。
改为只在 dartdoc 里注入 `UnimplementedError` 文字（不改接口形状）后，A1 断言才真正
变红。教训：变红自检要确认**红在预期的那条断言上**，不能只看「是不是红了」。

## 踩坑墓地
- 2026-08-04（前车之鉴，非本任务失败）: 契约测试把断言写在**未 await 的 `.then()` /
  `.listen()` 回调**里 → 回调在测试结束后才跑，不参与判定 → **恒绿**。已实证：写入
  `expect(1, 999)` 必假断言，`dart test` 依然输出 `All tests passed!`。
  结论：契约测试一律 `async` + `await`，比较**被 await 之后的值**；断言不许写在
  未被 await 的回调里。本仓已抓到过两条这样的恒绿测试
- 2026-08-04（环境坑）: 进 worktree 不跑 `flutter pub get` 就 `dart analyze`，会把每条
  `package:` import 报成 `uri_does_not_exist`，产出 500+ 条假 issue。门禁脚本已加前置
  断言会拦下（exit 2）。结论：**进 worktree 第一件事是 `flutter pub get`**
- 2026-08-04（P7 自检脚本）: bash 里写 `"注入「$desc」"`，中文右引号 `」` 的首字节被
  当成变量名的一部分，`set -u` 下报 `desc\xe3: unbound variable`。结论：**变量后面
  紧跟中文标点时必须写 `${desc}`**，不能裸写 `$desc`
- 2026-08-04（P7 自检脚本）: `cd core && ...` 在本会话的 Bash 工具里会因工作目录已被
  重置而失败，导致**注入没生效、测试跑的是原文件**，自检假绿一次。结论：变红自检里
  必须先 `grep -c MUTATION` 确认注入真的落盘，再跑测试
- 2026-08-04（变红自检本身的陷阱）: 见「决定记录」M10 —— 注入后红了，但**红在编译
  失败而非目标断言**，等于没验证到那条断言。结论：**确认红在预期的那条断言上，
  不能只看是不是红了**

## 冷冻快照
<仅在搁置时由 /hibernate 填写: 业务背景 / 架构决定摘要 / 精确断点 / 重启第一步 / 环境要求>
