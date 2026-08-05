# 决定记录 · S3c-d CloudSignaling（云端中转信令）

> 2026-08-05 ｜ 分支 `feat/storage-s3c-cloud-signaling`（基线 main `3e2f464`）
> 派工：`~/Downloads/storage_refactor/DISPATCH-S3c-d.md`

## 一句话

在 `firebase` 包实现 `CloudSignaling implements SignalingChannel`，用 RTDB 做会合点
中转 SDP/ICE，以 `RendezvousBackend` 窄端口隔离真实 `onDisconnect` 服务端行为，
跑通共享契约套件 11 条 + 3 条加严测试，全部全绿。

## D1 · 为什么抽 `RendezvousBackend` 窄端口（派工 §7 落地）

`onDisconnect` 是真实 RTDB 的**服务端行为**，本地 fake 通常不实现。把它收敛为
包内窄端口（`register` / `watch` / `onDisconnectRemove` / `remove` / `writeEnvelope`）：

- `RtdbRendezvousBackend`（`lib/signaling/rtdb_rendezvous_backend.dart`）是包内**唯一**
  依赖 `firebase_database` 的地方，直接封装 RTDB 语义（`onDisconnect().remove()`）；
- `MemoryRendezvousBackend`（`test/signaling/memory_rendezvous_backend.dart`）**真的
  实现**「断开时执行已登记的删除」：`onDisconnectRemove` 把删除动作登记进动作表，
  `triggerOnDisconnect(memberId)` 执行那条**已登记**的动作，而不是手动删节点。

派工 §7 的变异性抓手天然成立：`CloudSignaling.open()` 里若删掉
`onDisconnectRemove` 登记步骤，内存 backend 的 `triggerOnDisconnect` 无事可做，
成员节点保留 → 对端不 `departed` → A4 契约测试变红（见 A8 变异 1 实测）。

## D2 · presence 语义（awaiting vs departed 的区分）

- 成员在场 = 会合点下 `members/{memberId}` 节点存在；
- 会话记录 `_peerEverSeen`（是否曾见过对端成员）：
  - 从未见过对端 → `awaiting`（该继续等）；
  - 现在成员集合里有非本端成员 → `present`；
  - **曾见过对端**且现在没有对端成员 → `departed`（该放弃）。

「曾见过」是 key：对端没来是 awaiting，来过又消失才是 departed。这与契约
`PeerPresence` 的「awaiting 该等、departed 该放弃」完全对齐。

## D3 · 不回显与去重（云端共享存储的两个天然坑）

RTDB 是共享存储，`onValue` 每次推**全量**快照，天然会把自己写的读回来、天然会
重复投递。实现两处过滤：

1. **不回显**：`incoming` 只投递 `from != 本端` 的信封；
2. **去重**：信封带唯一 id（RTDB `push()` key / 内存 backend 递增 id），
   `_consumedEnvelopeIds` 记录已消费 id，只投递新 id。

变异 2 / 3 实测证明这两条缺一不可（见 A8）。

## D4 · 信封残留的取舍

`close()` 只发 Bye + 删除**本端成员节点**，不清理历史信封节点。理由：契约设计
中信令会话是短命的（数据通道建成即关闭），一次握手用一次会合标识，不复用；
契约套件 11 条也都用各自唯一的 rv 字符串，无串扰风险。若未来会合标识需复用，
须加「会话开始清空旧信封」机制 —— 暂不需要，不进范围。

## A8 · 变异自检逐条记录（派工 §八 A8 要求）

每条变异：注入违规 → 确认变红 → 复原。全部复原后 14 条全绿。

| # | 注入的变异 | 红在哪条断言 | 结论 |
|---|---|---|---|
| 1 | 删掉 `open()` 里的 `onDisconnectRemove` 登记步骤 | 「A4 · 对端非正常断开（未告别）也必须产出 departed」等 5s 超时变红 | `departed` 依赖服务端登记钩子，不是客户端猜测 ✓ |
| 2 | 去掉 `_onSnapshot` 的 `e.from == memberId` 回显过滤 | 「两端相遇并双向收发」与「incoming 不回显本端自己发出的信封」红 | 不回显是硬约束 ✓ |
| 3 | 去掉信封 id 去重 | 「trickle ICE：多条 candidate 按序全部送达」与「A5 隐私」红（重复投递超数） | 去重是硬约束 ✓ |
| 4 | `departed` 后 `send()` 不抛错、静默放行 | 「A4 · 对端已 departed 时 send 必须抛错」红 | send 抛 StorageError 子类是硬约束 ✓ |
| 5 | 二次 `close()` 抛错（反幂等） | 「close 幂等：重复调用不得抛错」红（连带 A4 依赖链） | close 幂等是硬约束 ✓ |

变异 1 还复用了常驻测试「A8 · 变异守卫：未登记 onDisconnect 时崩溃不产出 departed」
（负向断言，具名宽限期 300ms）—— 它是常驻守卫，未来实现被改坏会一直守。

## A3 加严（独立证据链）

测试「A3 · triggerOnDisconnect 执行的是已登记删除」用三件独立证据证明 departed
来自服务端 onDisconnect 机制：

1. `debugHasRegisteredDisconnect(bobId)` 为真（open 时登记过）；
2. `triggerOnDisconnect(bobId)` 后 `debugMemberIds` 不再含 bobId（登记的动作真的
   删了节点，不是假装断开）；
3. alice 观测到 `departed`。

## 集成测试（真 RTDB 模拟器，派工 §7）

`test/signaling/rtdb_rendezvous_backend_integration_test.dart`，标 `@Tags(['integration'])`，
`firebase/dart_test.yaml` 默认排除，`flutter test` 不带参数不跑。

人工触发：
```bash
cd firebase && flutter test --tags integration
```
需本地起 RTDB 模拟器（`firebase.json` 需配 `database` 段后）
`cd infrastructure/emulator && ./start_emulator.sh`；VM 平台通道不可用时自动 skip，
需真机或 Chrome。

真 `onDisconnect` 的服务端删除触发验证留人工：登记后调用
`FirebaseDatabase.goOffline()`（会断开该实例连接，服务端执行已登记删除），
再 `goOnline()` 恢复，观察对端 `departed`。因 `goOffline` 是进程级（双方都会断），
未写入自动测试。

## 验收结果

- A1 `runSignalingContractSuite` 对 `CloudSignaling` 11 条全绿 ✓
- A2 `core` 191 条 / `p2p` 18 条全绿，契约套件一字未改 ✓
- A3 departed 来自已登记 onDisconnect，变异 1 实测变红 ✓
- A4 close 发 Bye + 对端 departed + close 幂等（契约套件覆盖 + 变异 5）✓
- A5 departed 后 send 抛 `CloudPeerDepartedError`（`StorageError` 子类）✓
- A6 `core`（新增 `test/s3c_no_firebase_guard_test.dart`）与 `p2p`
  （既有守卫）零 firebase 依赖，两守卫测试通过 ✓
- A7 RTDB 路径与载荷不含 scopeUid/用户名/设备名（读回的
  `debugSerializedRoom` 断言）✓
- A8 见上表，5 条变异逐条实测变红后复原 ✓
- A9 S1a（57=基线）/ S1b（firebase 20=基线）/ monorepo 约定 三门禁全过 ✓

## 新增/改动文件

- 新增 `firebase/lib/signaling/rendezvous_backend.dart`（窄端口 + 信封编解码）
- 新增 `firebase/lib/signaling/rtdb_rendezvous_backend.dart`（真实 RTDB 后端）
- 新增 `firebase/lib/signaling/cloud_signaling.dart`（CloudSignaling + _CloudSession）
- 新增 `firebase/test/signaling/memory_rendezvous_backend.dart`（内存后端）
- 新增 `firebase/test/signaling/cloud_signaling_contract_test.dart`（契约 + 加严）
- 新增 `firebase/test/signaling/rtdb_rendezvous_backend_integration_test.dart`
- 新增 `firebase/dart_test.yaml`（排除 integration tag）
- 新增 `core/test/s3c_no_firebase_guard_test.dart`（core 零 firebase 守卫）

未改动：`core/lib/model/signaling.dart`、`core/lib/test_support/signaling_contract_suite.dart`
（契约文件零修改，逐字保持基线）。
