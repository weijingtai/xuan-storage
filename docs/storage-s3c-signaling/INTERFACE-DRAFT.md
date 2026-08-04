# S3c-a 接口草案（P1 产出，写码前的思考留痕）

> 2026-08-04 ｜ 基线 main `6ae98d5`
> 本文件是设计推演，不是交付物。交付物是 `core/lib/model/signaling.dart` 与其契约测试。

---

## 一、难点一：两种拓扑的最大公约数是什么

### 差异是真实的，不能假装它们一样

| | LocalSignaling（LAN） | CloudSignaling（RTDB 等） |
|---|---|---|
| 建连前我知道什么 | 对端的 `IP:port`（bonsoir 给的） | 什么都不知道，只知道会合点在哪 |
| 谁在中间 | **没有中间人**，我直接连它 | 第三方会合点转发 |
| 会话怎么开始 | 我拨过去，它接 | 双方各自连到会合点，在同一个键下读写 |
| 断网可用 | ✅ 全程零外网 | ❌ |

**如果接口写成「发给某个地址」→ 云端塞不进去（云端建连前没有地址）。**
**如果接口写成「进入某个房间」→ LAN 也能塞进去，但会强迫 LAN 实现造一个假房间。**

### 我的解法：会合标识 (rendezvous key) 是唯一的公共输入

两种拓扑真正的共同点不是「地址」也不是「房间」，而是：

> **双方事先各自知道同一个标识符，此后在这个标识符下双向收发信封。**

- LAN：标识符 = mDNS 广播里那个 `transientServiceId`（`AdvertisementHandle` 已经有了）
- 云端：标识符 = 设备配对时约定的会合 id

「这个标识符怎么变成一条真实链路」是**实现的事**，不是接口的事。LAN 实现拿它去
`_fabric.resolve(id)` 找到对端直连；云端实现拿它当 RTDB 的路径键。接口一个字不用改。

于是接口只需要两个动作 + 一条流：

```
open(rendezvous)  → 得到一条双向信令会话
  session.send(envelope)     发一个信封
  session.incoming           收对端的信封
  session.peerPresence       对端存活状态（难点二）
  session.close()
```

**验证这个抽象是否成立的方法**：A3 要求同一套契约测试对两个 fake 各跑一遍。
LAN fake 用 `_FakeLanFabric` 式的「登记—查找—直连」；云 fake 用一个共享 `Map`
当会合点、双方各自读写同一个键。**如果我的抽象漏了什么，云 fake 会写不出来。**

### 被否的方案

- ❌ **`connect(address)`** —— 云端建连前没有地址。塞不进去。
- ❌ **`join(roomId)` 并要求 LAN 造假房间** —— LAN 明明有直接地址，逼它绕一圈；
  且「房间」暗示有第三方持有状态，与 LAN 的零外网事实矛盾。
- ❌ **两个接口（`DirectSignaling` / `RelaySignaling`）** —— 那 `Transport` 就要
  同时依赖两个接口并自己分支，C3 想避免的「传输实现依赖具体后端」原样复现。

---

## 二、难点二：对端存活语义怎么表达

### 为什么必须在接口里

C3 选 RTDB 的**唯一技术理由**是 `onDisconnect()`——掉线时服务端自动摘除信令节点。
若接口不暴露这个语义：
1. 优势体现不出来（等于白选）；
2. **换后端时后人不知道新后端必须具备这个能力**——这才是真正的损失。

### 我的解法：`peerPresence` 是流，不是布尔值

写成 `bool get isPeerOnline` 是错的：掉线是**事件**，调用方要的是「它刚掉了」这个时刻，
而不是轮询一个瞬时值。

```dart
Stream<PeerPresence> get peerPresence;
```

`PeerPresence` 取值要能区分三件不同的事——这三件在实现上后果不同：

| 取值 | 含义 | 调用方该做什么 |
|---|---|---|
| `awaiting` | 还没见过对端（刚 open，对端尚未出现） | 继续等 |
| `present` | 对端在线 | 可以发信封 |
| `departed` | 对端**已确认离开**（RTDB `onDisconnect` 摘除 / LAN 连接断开） | 停止等待，别再往这条会合标识发 |

**`awaiting` 与 `departed` 必须分开**：二者都是「现在没有对端」，但前者该继续等、
后者该放弃。合并成一个 `absent` 会让调用方无法决定是等还是放弃，
于是它只能用超时来猜——那正好把 `onDisconnect()` 的价值抹掉了。

### 后端能力要求要写成契约文字

在 `peerPresence` 的 dartdoc 里写死：**实现必须在对端非正常断开时产出 `departed`，
不得依赖调用方超时推断。** 这样换后端的人读到这句话，就知道新后端必须具备
「服务端可感知客户端断开」的能力（RTDB 的 `onDisconnect`、或自建服务的连接生命周期）。

---

## 三、难点三：怎么让「不传用户数据」成为结构性事实

### 只有 A5 断言是不够的

A5 要求「信令载荷不含 scopeUid / 用户名 / 设备名」，是测试断言。但如果信封长这样：

```dart
final class SignalingEnvelope {
  final Map<String, dynamic> payload;   // ❌ 敞口
}
```

那 A5 只能断言「**当前**这份载荷里没有 scopeUid」。后人往 `payload` 里塞什么都照样过测试。
测试抓的是样本，不是规则。

### 我的解法：信封是封闭类型（sealed）

```dart
sealed class SignalingEnvelope { }
  final class SessionDescriptionEnvelope  —— offer / answer 的 SDP 文本
  final class IceCandidateEnvelope        —— 一条 ICE candidate
  final class ByeEnvelope                 —— 主动告别
```

**穷尽三个变体，每个变体的字段都是定死的具名字段，没有任何 `Map` / `dynamic` 口子。**
于是「塞不进用户数据」不是承诺，是**类型系统的事实**：想塞就必须加一个新变体，
而加变体会让 `switch` 穷尽性检查在所有消费点变红，改动无法悄悄发生。

这就是 `AdvertisementHandle` 那条先例的同一手法——把约定从注释变成可断言的结构。

### 配套断言（A5 的两层）

1. **结构层**：源码扫描断言 `signaling.dart` 里不出现 `Map<String, dynamic>` / `dynamic`
2. **样本层**：契约测试构造完整握手，断言全部信封的序列化文本不含 scopeUid / 设备名

---

## 四、SDP 与 ICE 为什么分成两个变体

它们的时序不同，合并会丢掉这个事实：

- SDP：一次 offer、一次 answer，**各一条**
- ICE candidate：**陆续到达、条数不定**（trickle ICE），可能十几条

写成一个「万能消息」会让实现无法表达「offer 只该有一条」。分开之后，
`SessionDescriptionEnvelope` 带一个 `isOffer` 区分方向即可。

---

## 五、待确认的开放问题（写码时定，不上报）

1. `open()` 是否需要 `CancellationToken?` —— §3.6 说「超过 1 秒的方法」都要。
   信令等待对端可能很久，**要加**。
2. 是否需要 `SignalingError` 子类 —— §3.6 要求 `code + context + fix` 三段。
   本轮零实现，但**契约里声明会抛什么**是契约的一部分，照 `blob_error.dart` 加。
3. 会合标识是否要有类型（`typedef RendezvousKey = String`）—— 加，与
   `CipherId` 的先例一致，且让签名自我说明。
