# S3c-c-pre 设计决定记录：`PeerStream` 背压契约

> 2026-08-05 ｜ 基线 main = `3e2f464` ｜ 派工 `DISPATCH-S3c-c-pre.md`
> 本文件是 P1 产出（写码前的思考留痕），交付物是 `core/lib/model/transport.dart`
> 与 `core/lib/test_support/peer_stream_contract_suite.dart` 及其契约测试。

---

## D1 背压做在哪个层级：选 **方案 C**（流级 + 契约写死「互不饿死」+ A6 断言验证）

### 三方案对比

| | 做法 | 对 WebRTC 的代价 | 对 LAN socket 的代价 |
|---|---|---|---|
| **A** | 只做流级，物理连接公平性交给实现 | 零（契约不管） | 零（契约不管） |
| **B** | 流级 + 会话级双层队列 | 高：RTCDataChannel 原生没有「会话」概念，要再造一个会话语义层（会话级队列 + 公平调度器） | 高：socket 之上自己再造一层调度 |
| **C** | 流级，契约写死「一条流的背压不得饿死另一条流」+ A6 测试 | 低：实现可用多个 RTCDataChannel（每流一条，SCTP 各自做拥塞控制），或单通道上自写公平调度 | 低：实现方一个 socket + 应用层帧，写个公平调度即可 |

### 论证（基于「两个后端都能实现」，不是「哪个更优雅」）

1. **B 在两个后端上都要造一个「会话语义层」**。WebRTC 里 `RTCDataChannel` 的
   bufferedAmount / onbufferedamountlow 是**通道级**的；SCTP 本身就对对端做端到端
   拥塞控制 —— 对端消费慢，SCTP 停发，数据在**通道缓冲**里排队。若再要一层「会话级
   队列」，等于在 SCTP 之上再造一套队列，与 SCTP 已有的缓冲重复，且没有新信息量。
2. **C 把「互不阻塞」变成会红的断言**。今天「不同 kind 的流必须互不阻塞」只是一句
   写在 `PeerSession.openStream` dartdoc 里的注释（transport.dart:186）。没有任何测试
   能证明它。方案 C 配一条 A6 测试真去验「blob 流压满时 oplog 流还能 send」，把注释
   变成门禁 —— 这正是派工 §六说的「代价最小而抓住了真问题」。
3. **两个后端都能满足 C 的承诺**：
   - WebRTC：多 RTCDataChannel 方案下，每条流独立拥塞，压住的流不阻塞另一条；
     单通道方案下，实现方自己的调度器保证公平（这是实现细节，契约只要求结果）。
   - LAN socket：一个 socket 多路复用帧时，发送侧本来就是实现方自己调度，公平性可控。
4. **B 相比 C 多出来的「会话级水位」信息，两个后端都拿不出准确的实现**：WebRTC
   SCTP 的缓冲在水位之下（内核态），会话级总量不是可靠的单调水位。契约要求实现方
   报告一个不可靠的数值，比不要求更糟。

> 结论：选 **C**。不改 `PeerSession` / `StreamKind` 的签名，`PeerStream` 是唯一改动面，
> 连带仅新增一个枚举与一个错误子类（见 D2/D5）。`PeerStream` 类级 dartdoc 增加
> 「多路复用隔离」承诺段，A6 契约测试落地验证。

---

## D2 发送侧有界：`bufferedAmount` / `maxBufferedAmount` / `overflowPolicy` 三件套

### 为什么不是别的形态

- **为什么不用 `StreamSink.addStream` / `done`**：派工 §五.1 提示「别照抄」。
  `addStream` 只解决「整段数据排队」，不解决「持续 chunk 发送时何时该停」——
  那正是 blob 几百 MB 的场景（一个巨大 ByteData 的 addStream 本身就是内存灾难）。
- **为什么不用「bool get canSend」瞬时布尔**：瞬时布尔在两个后端上都是谎言 ——
  WebRTC 的 bufferedAmount 是异步变化的，调用方读到一个 `true` 的瞬间它可能已经
  变 `false`。「能 await 到可以继续写为止」要求的是**事件**语义（何时转可写），
  不是瞬时快照。这也是为什么用 `bufferedAmount`（可轮询的水位）+ send 挂起/抛错
  （可 await 的事件），而不是一个布尔 getter。
- **为什么带 `maxBufferedAmount`（上限可查询）而不是常数**：上限与实现的内存
  预算绑定（WebRTC 默认通道缓冲、socket 缓冲区大小都随环境不同）。调用方
  （BlobGateway）需要知道上限才能决定 chunk 大小与重试节奏。上限是只读 getter，
  不由调用方设置（`RTCDataChannel.bufferedAmountLowThreshold` 是 setter，但那个
  阈值是给实现自用的，不属于两个后端的公约数，不进契约）。

### 签名（全部只读 getter + 既有 send 语义收紧）

```dart
enum OverflowPolicy {
  /// 缓冲已满后 [PeerStream.send] 挂起，直到水位降到可写才返回。
  wait,
  /// 缓冲已满后 [PeerStream.send] 抛 StorageError 子类（背压溢出）。
  fail,
}

// PeerStream 新增：
int get bufferedAmount;        // 已发出但尚未被对端消费确认的字节数（发送水位）
int get maxBufferedAmount;     // 背压上限（字节），达到后触发 overflowPolicy 行为
OverflowPolicy get overflowPolicy;  // 运行时自报的溢出策略
```

### send 的入口检查语义（写死在 dartdoc，防死锁）

> **`send` 在「入口时 `bufferedAmount >= maxBufferedAmount`」即按 [overflowPolicy] 行动
> （wait：挂起直到水位 `< maxBufferedAmount`；fail：抛背压溢出错误）。入口未满时接受
> 本包，接受后水位可短暂超过上限（单包越界，实现与 WebRTC 原生行为一致）。**

这条语义是防测试死锁的关键：调用方用 `while (bufferedAmount < max) { await send(chunk); }`
可以安全压满，不会因为「send 内部先检查是否越界」而挂死在循环里。

### 为什么 `overflowPolicy` 是运行时自报、且只允许两个值

派工 §五.1 第三点「二选一，写死，不许留『由实现决定』」与 §五.3「两个 fake 各展示
一种行为」必须同时满足。解法：**契约固定枚举的两个值，每个值的行为语义在契约里
写死**；实现**只能二选一，并在运行时通过 [overflowPolicy] 自报**。调用方拿到
`overflowPolicy` 就知道该 `await` 重试还是 catch 错误 —— 行为不再由实现自由决定，
而是契约规定的两种明文策略之一。这是对「不许由实现决定」最忠实的落实：不是
「行为随意」，而是「两种明文策略，实现声明选哪个」。
`overflowPolicy` 必须是 getter 而非 `const`：WebRTC 场景下实现可能随会话状态
（degraded）切换策略，运行时查询而非编译期写死。

---

## D3 接收侧可暂停且传导：`incoming` 的 dartdoc 契约 + A5 断言

`Stream<List<int>>` 的 subscription 原生有 `pause()` / `resume()`（派工 §五.1
第二点直接点名）。契约在 `incoming` 的 dartdoc 里写死传导义务：

> 实现必须实现订阅 pause 语义：订阅者 `pause()` 后，压力必须传导到对端发送侧 ——
> 对端连续 `send()` 时其 `bufferedAmount` 增长并在达到 `maxBufferedAmount` 后
> 触发其 `overflowPolicy` 行为，**不得在本端无限缓冲**。

- WebRTC：订阅方 pause 时实现方停读 / 停取 `RTCDataChannel` 消息，SCTP 拥塞控制
  自然让对端 bufferedAmount 涨 —— 传导是底层本来就有的。
- LAN socket：实现方 pause 时停止从 socket 读，socket 内核缓冲填满后 TCP 背压
  自然传导到对端。

A5 断言的就是「pause 后发送侧感知压力」（wait 策略：send 挂起；fail 策略：
send 抛错）+「resume 后恢复」。**「pause 后发送侧感知」不能靠对端线程调度碰运气**，
套件用 signaling 套件 D5 的「等事件 + 有界宽限期」手法：订阅 → send → pause →
持续 send 到水位触顶 → 断言行为发生。负向等待（断言 send 不完成）用拓扑注入的
`negativeAssertionGrace`。

---

## D4 契约套件形态（照抄 signaling_contract_suite.dart 手法）

```dart
typedef PeerSessionPair = ({PeerSession caller, PeerSession callee});

FutureOr<void> runPeerStreamContractSuite({
  required String topologyName,
  required FutureOr<PeerSessionPair> Function() makeSession,
  Duration negativeAssertionGrace = const Duration(milliseconds: 50),
}) { ... }
```

- **为什么注入 `makeSession` 而不是 `makeStream`**：A6（互不饿死）要求**两条流在
  同一会话上**。只注入「单流对」写不出 A6。信令套件注入 `makePair`（同一织物上
  相遇）是同因 —— 契约要求跨成员的关系时，注入就必须是「能产生这种关系的工厂」。
- **套件内部怎么取流**：`sender = await pair.caller.openStream(kind)`；
  `receiver = await pair.callee.incomingStreams` 按开流顺序取（多路复用帧在一条
  物理连接上天然保序，实现须 FIFO）。A4/A5 用单流对，A6 用双流对。
- **为什么不让套件拿到 fake 内部对象**：两个 fake 结构不同（D6），套件只依赖
  契约表面（PeerSession / PeerStream / 枚举），靠 `bufferedAmount` 水位与
  `send` 行为做断言 —— 这正是「换实现不换测试」的前提。

套件内置 4 条测试（按 `overflowPolicy` 分支断言）：
1. **A4-wait**：对端不消费，`while (bufferedAmount < max) send` 压满；再 send 一条
   → Future 在有界宽限期后未完成（挂起）；订阅接收侧开始消费 → 水位下降 →
   send 在正向超时内完成（能 await 到可写为止）。
2. **A4-fail**：对端不消费，持续 send → 在达到上限后 send 抛 `StorageError` 子类。
3. **A5**：订阅并消费 → send 正常；订阅者 `pause()` → 持续 send 到触顶 →
   按策略断言挂起/抛错；`resume()` → 恢复。
4. **A6**（方案 C 的核心）：同会话开 blob 流 + oplog 流；blob 压满（对端不消费）；
   oplog 流 send 必须在正向超时内完成 —— 证明「一条流的背压不得饿死另一条流」。

---

## D5 错误子类 `BackpressureOverflowError`（fail 策略专用）

放在 `transport.dart` 内（与 `PeerStream` 同文件，属于「直接连带」，不动
`storage_error.dart` 的既有类）。`code = 'storage.backpressure_overflow'`，
继承 `StorageError`（§3.6：失败一律抛 StorageError 子类）。

```dart
final class BackpressureOverflowError extends StorageError { ... }
```

- **为什么放 transport.dart 而不放 storage_error.dart**：派工 §四只授权
  `PeerStream` 一处及其直接连带。新增错误类是为 `fail` 策略服务的契约一部分，
  与 `PeerStream` 同文件让「连带」保持在单个文件内，最小化扩散。
- **为什么必须有专门子类、不能用裸 `StorageError`**：调用方（BlobGateway）需要对
  背压溢出做「等水位下降再重试」的专门处理，而 sync 冲突、vault 拒绝等不重试。
  专门的 code + 子类让 catch 精确（§3.6 的 code/message/reason/suggestion 四段齐备）。

---

## D6 两个形态迥异的 fake（各跑一遍套件）

> 实现定型：流对象**自配对**（`caller.openStream` 返回的对象原样进入对端
> `incomingStreams`，本流 send 的数据投递到本流自己的 incoming，消费确认由
> 本流 incoming 的订阅者是否活跃决定）。每条逻辑流**独立缓冲** —— 这正是
> A6 要的实现形态；「共享无界缓冲 / 复用同一流」是缺陷态（见 V4）。

| | Fake A —— `_WaitPeerSession`/`_WaitStream` | Fake B —— `_FailPeerSession`/`_FailStream` |
|---|---|---|
| 溢出策略 | `wait`（发送侧字节会计 `_buffered` + `Completer` 挂起，消费确认后释放） | `fail`（发送侧队列计数 `_queued`，入口 `>= max` 同步抛 `BackpressureOverflowError`） |
| 消费确认驱动 | `onListen/onPause/onResume/onCancel` 回调 + `_pending` 队列 + `_pump` 循环 | 同左（`onListen/onPause/onResume/onCancel` + `_pump`），但确认只减计数、无空间释放 |
| 触顶行为 | 挂起直到水位 `< maxBufferedAmount` | 立即抛错 |
| 结构差异 | **字节会计 + 挂起 + Completer**，无抛错路径 | **队列计数 + 同步抛错**，无挂起路径 |
| 目的 | 覆盖「等/挂起/恢复」路径 | 覆盖「抛错」路径 + 验证 `overflowPolicy` 自报 |

两者代码结构不同（一个会计+挂起，一个计数+抛错），满足 S3c-a「同构的两个
fake 等于只测了一遍」的规矩。fake 在 `transport_contract_test.dart` 里（测试
私有，不算 S1a 交付物），套件在 `test_support/`（不进 barrel，D7）。

---

## D7 barrel 与 dartdoc 门禁

- `transport.dart` 已在 barrel（persistence_core.dart:37）。新增顶层类型
  `OverflowPolicy` / `BackpressureOverflowError` 随该 export 自动进 barrel。
  `transport_contract_test.dart` 增加「barrel 可消费」组：用 `barrel.XXX` 编译期
  引用验证（照 signaling_contract_test.dart:157 组的手法），漏 export 即编译失败。
- `test_support/peer_stream_contract_suite.dart` **不进 barrel**
  （s1b_architecture_guard_test.dart:53 断言），消费方走深路径 import。
- 所有新增 public 成员带中文 dartdoc；`s1a_dartdoc_coverage_test.dart` 的
  `minMemberDeclarations` 下限随新增声明数同步**上调**（不许调低）。

---

## D8 被否的方案（与理由）

- ❌ **B：流级 + 会话级双层背压** —— 两个后端都要再造「会话语义层」，与 SCTP /
  socket 内核已有的缓冲重复，会话级水位不可靠。见 D1 论证。
- ❌ **发送侧只做 `bool get canSend`** —— 瞬时布尔是谎言（值在读取与使用之间
  已过期），且给不出「await 到可写」的事件语义。
- ❌ **`overflowPolicy` 用 `const` 字段** —— WebRTC 实现可能随会话降级切换策略，
  编译期写死会逼实现方扩字段或造假。
- ❌ **`maxBufferedAmount` 用常数** —— 上限与实现内存预算绑定，不能由契约定死。
- ❌ **错误类放 `storage_error.dart`** —— 超出派工 §四「直接连带」的授权面。
- ❌ **只做发送侧有界、不做接收侧 pause 传导** —— 派工 §五.1 第二点是硬性要求
  （订阅者 pause 必须能传导到对端），省略即不合规。

---

## D9 变异自检记录（A8，2026-08-05 执行）

> 全部 5 个变异均**红在目标断言**（非编译失败、非测试超时误报），复原后
> `transport_contract_test.dart` 20 条全绿。

| # | 注入的变异 | 期望红在哪条断言 | 结果 |
|---|---|---|---|
| V1 | `_WaitStream.send` 删除挂起逻辑（wait 实现成无界发送） | A4/Fake A「wait 策略：缓冲已满时 send 必须挂起」`expectLater(blocked.timeout, throwsA(TimeoutException))` → Expected throws TimeoutException, Actual Future | ✅ 红在目标断言 |
| V2 | `_FailStream.send` 删除入口抛错（fail 实现成无界接收） | A4/Fake B「fail 策略：缓冲已满时 send 必须抛 BackpressureOverflowError」→ Expected throws BackpressureOverflowError, Actual Future | ✅ 红在目标断言 |
| V3 | `_activeChanged` 忽略 `isPaused`（pause 不传导） | A5/Fake A「pause 后持续发送必须能把水位推上顶」→ Expected >= 8192, Actual 0 | ✅ 红在目标断言 |
| V4 | `openStream` 每次返回同一条流（两流彻底共享，互不隔离） | A6/Fake A「blob 流必须确实被压满」→ Expected >= 8192, Actual 0（共享流被 oplog 订阅消费，blob 压不满） | ✅ 红在目标断言 |
| V5 | `_confirm` 删除空间释放（挂起的 send 永不恢复） | A4/Fake A「对端消费后挂起的 send 恢复完成」→ `await blocked.timeout` 抛 TimeoutException: Future not completed | ✅ 红在目标断言 |

> 附：压满 helper `_pressureUntilFull` 带 10 万次兜底上限，防止异常实现
> 导致水位永不触顶时测试死锁（V3 曾验证此路径：若不加上限会挂死而非红在
> 目标断言）。
