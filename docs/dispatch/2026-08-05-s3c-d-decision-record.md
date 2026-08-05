# 决定记录 · S3c-d CloudSignaling（云端中转信令）— 返工版 v2

> 2026-08-05 ｜ 分支 `agent/claude/storage-s3c-cloud-signaling`（返工）
> 基线 main `3e2f464` → 验收前基线 `96b77ac` → 返工逐项提交（`76dbeb3`…`599dc1c`）
> 派工：`~/Downloads/storage_refactor/DISPATCH-S3c-d.md`（A1–A9）
> 上游验收：`~/Downloads/storage_refactor/REVIEW-S3c-d.md`（REVISE-FIRST）
> 返工令：`~/Downloads/storage_refactor/REWORK-S3c-d.md`（R1–R10）

## 一句话

在 `firebase` 包实现 `CloudSignaling implements SignalingChannel`，用 RTDB 做会合点
中转 SDP/ICE，以 `RendezvousBackend` 窄端口隔离真实 `onDisconnect` 服务端行为，
跑通共享契约套件 11 条 + 6 条加严测试。返工修复了验收查出的**两处「证明不了
自己能红」的假门禁**（A7 路径侧、close 守卫行）与四处分级缺陷。

---

## 流程事故记录（R10 第 3 条）

**上一轮（首轮交付）**：
1. 在主工作区作业 —— 违反派工书 §一「多个 AI agent 并行，各自独立 worktree，
   不要在主工作区改代码」。
2. 主工作区被切到 `feat/storage-s3c-cloud-signaling` 分支，该分支**零提交**，
   全部成果是未跟踪文件 —— 物理上无从合入，别的 agent 若来主工作区会落在一个
   非 main 的分支上。
3. 决定记录把 A7 / A8 打 ✓，而这两条实测未达标 —— 把「测试绿了」当成
   「门禁有效」。这是本仓纪律要防的：**一个绿的门禁，如果证明不了自己能红，
   它就是假的**。

**本轮（返工）**：先建独立 worktree（从 main `3e2f464` 起），9 个文件搬入后
当场提交基线 `96b77ac`；主工作区切回 `main` 并删除零提交的 feat 分支，仅剩两笔
非本任务改动（`firestore.rules`、`.codegraph/daemon.pid`）+ 前人留下的
`docs/dispatch/2026-08-02-s1b-dispatch-prompt.md`。9 个返工项逐项修复、逐项提交。

---

## D1 · 为什么抽 `RendezvousBackend` 窄端口（派工 §7 落地）

`onDisconnect` 是真实 RTDB 的**服务端行为**，本地 fake 通常不实现。把它收敛为
包内窄端口（`register` / `watch` / `onDisconnectRemove` / `remove` / `writeEnvelope`
/ `pathOf`）：

- `RtdbRendezvousBackend`（`lib/signaling/rtdb_rendezvous_backend.dart`）是包内**唯一**
  依赖 `firebase_database` 的地方，直接封装 RTDB 语义（`onDisconnect().remove()`）；
- `MemoryRendezvousBackend`（`test/signaling/memory_rendezvous_backend.dart`）**真的
  实现**「断开时执行已登记的删除」：`onDisconnectRemove` 把删除动作登记进动作表，
  `triggerOnDisconnect(memberId)` 执行那条**已登记**的动作，而不是手动删节点。

派工 §7 的变异性抓手天然成立：删掉 `onDisconnectRemove` 登记步骤，内存 backend 的
`triggerOnDisconnect` 无事可做 → 成员节点保留 → 对端不 `departed` → A4 变红
（变异 1 实测）。

## D2 · presence 语义（awaiting vs departed 的区分）

- 成员在场 = 会合点下 `members/{memberId}` 节点存在；
- 会话记录 `_peerEverSeen`（是否曾见过对端成员）：
  - 从未见过对端 → `awaiting`（该继续等）；
  - 现在成员集合里有非本端成员 → `present`；
  - **曾见过对端**且现在没有对端成员 → `departed`（该放弃）。

「曾见过」是 key：对端没来是 awaiting，来过又消失才是 departed。覆盖情况如实
记录：该分支的变红由套件「不同会合标识互不串扰」撞到（验收 M5：`else` 变异红在
相邻断言），专测 awaiting 的套件条目因 `Stream.multi` 重放时序抓不到它 —— 属
「被覆盖」而非「无覆盖」，与验收报告 F5 结论一致，不单列为缺陷。

## D3 · 不回显与去重（云端共享存储的两个天然坑）

RTDB 是共享存储，`onValue` 每次推**全量**快照，天然会把自己写的读回来、天然会
重复投递。实现两处过滤：

1. **不回显**：`incoming` 只投递 `from != 本端` 的信封；
2. **去重**：信封带唯一 id（RTDB `push()` key / 内存 backend 递增 id），
   `_consumedEnvelopeIds` 记录已消费 id，只投递新 id。

## D4 · 信封残留与 rv 复用约束（R9）

`close()` 只发 Bye + 删除**本端成员节点**，不清理历史信封节点。

**显式约束（可被引用）**：**会合标识一次一用，不得复用。** 同一 `RendezvousKey`
只服务一次握手；复用会同时踩「历史信封残留」与「`_consumedEnvelopeIds` 残留」
两个坑（后者已由 `_teardown()` 清空缓解，前者靠本约束规避）。契约套件 11 条均用
各自唯一的 rv 字符串，无串扰风险。若未来真需要复用 rv，须先实现「会话开始清空
旧信封」机制 —— 不在本次范围。

## D5 · close 后 send 的语义裁定（R2，差异待人类拍板）

**裁定**：close 后 `send()` 抛 `StorageError` 子类（`CloudSessionClosedError`，
code `cloud.session_closed`）—— 比静默成功更符合 A5「不静默丢弃」的精神，也
满足契约 §3.6「失败一律抛 StorageError 子类」。

**与 `p2p` `LocalSignaling` 的差异**：`p2p/lib/local_signaling.dart:170-184`
同场景（close 后 send）是**静默成功**（`_waitForSocket()` 返回 null →
`if (s == null) return;`）。两个实现跑同一套契约却行为相反 —— 契约未约束
「close 后 send」，故双方都不违反契约，但语义不一致。派工书 §六「不碰 p2p 一个
字」，故本轮**只**在 firebase 侧改为抛 `StorageError` 子类并补测试
（`R2 · close 后 send 抛 StorageError 子类`），p2p 侧保持原状。**两端语义对齐
（统一抛错或统一静默）是待人类裁定的遗留项**：若裁定为统一抛错，需另行派工改
p2p 并补对称断言；若裁定为统一静默，firebase 侧改为 `return` 并删 `CloudSessionClosedError`。

---

## A8 · 变异自检完整表（含「变异后仍全绿」的分支）

每条变异：注入违规 → 确认变红（或全绿）→ 复原。复原后契约测试 17 条全绿。

### 上一轮已实证的 5 条（验收复核过，属实）

| # | 注入的变异 | 红在哪条断言 | 结论 |
|---|---|---|---|
| 1 | 删掉 `open()` 里的 `onDisconnectRemove` 登记步骤 | 「A4 · 对端非正常断开（未告别）也必须产出 departed」等 5s 超时变红 | `departed` 依赖服务端登记钩子，不是客户端猜测 ✓ |
| 2 | 去掉 `_onSnapshot` 的 `e.from == memberId` 回显过滤 | 「两端相遇并双向收发」与「incoming 不回显本端自己发出的信封」红 | 不回显是硬约束 ✓ |
| 3 | 去掉信封 id 去重 | 「trickle ICE：多条 candidate 按序全部送达」与「A5 隐私」红（重复投递超数） | 去重是硬约束 ✓ |
| 4 | `departed` 后 `send()` 不抛错、静默放行 | 「A4 · 对端已 departed 时 send 必须抛错」红 | send 抛 StorageError 子类是硬约束 ✓ |
| 5 | 二次 `close()` 抛错（反幂等） | 「close 幂等：重复调用不得抛错」红（连带 A4 依赖链） | close 幂等是硬约束 ✓ |

### 本轮（返工）新增/改动的分支各自变异结果

| # | 注入的变异 | 返工前 | 返工后 | 结论 |
|---|---|---|---|---|
| 6 | R1：`rtdb_rendezvous_backend.dart` 的 `rootPath` 改成 `'signaling/user-scope-42/alice-macbook'`（把 scopeUid + 设备名种进真实路径） | **全绿**（假门禁：A7 断言在复述内存 fake 硬编码的字面量） | **红在 A7**「`Expected: not contains 'user-scope-42'`」 | A7 路径侧绑定真实路径构造后成为真门禁 ✓ |
| 7 | R2：删掉 `send()` 的 `if (_closed) throw CloudSessionClosedError();` 一行 | **全绿**（零覆盖分支：删掉整行 14 条全绿） | **红在 R2**「close 后 send 抛 StorageError 子类」 | 零覆盖分支补齐测试后成为真门禁 ✓ |
| 8 | R5：去掉 `_emit` 的 `if (p == _current) return;` 同值去重 | 无此分支 | **红在 R5**「对端在场期间连发信封，present 只发射一次」 | present 去重是真门禁 ✓ |
| 9 | R6：去掉 `open()` 的 `await _sessions[rendezvous]?.close();` | 无此分支 | **红在 R6**「`Expected: 1 / Actual: 2`」 | 二次 open 关旧会话是真门禁 ✓ |
| 10 | R7：往 `core/lib/logging/sync_logger.dart` 追加 `import 'package:persistence_firebase/...'` | **不红**（守卫正则漏 `persistence_firebase` 分支） | **红在 A6 守卫**「core 源码不得 import 任何 firebase 包」 | 守卫正则补齐后成真门禁 ✓ |

**要点**：#6 #7 是「**变异后仍全绿的分支**」的实证 —— 返工前注入变异测试全绿，
证明那两处是假门禁；返工后同样变异变红，证明真门禁就位。这正是本仓纪律要的
「每个门禁都必须证明自己能红」。

### 常驻变异守卫（不删）

「A8 · 变异守卫：未登记 onDisconnect 时崩溃不产出 departed」（负向断言，具名
宽限期 300ms）常驻测试文件 —— 未来实现被改坏会一直守。

---

## A3 加严（独立证据链）

测试「A3 · triggerOnDisconnect 执行的是已登记删除」用三件独立证据证明 departed
来自服务端 onDisconnect 机制：

1. `debugHasRegisteredDisconnect(bobId)` 为真（open 时登记过）；
2. `triggerOnDisconnect(bobId)` 后 `debugMemberIds` 不再含 bobId（登记的动作真的
   删了节点，不是假装断开）；
3. alice 观测到 `departed`。

## 集成测试（真 RTDB 模拟器 —— **冒烟占位**，验收 R3/R4/R8）

`test/signaling/rtdb_rendezvous_backend_integration_test.dart`，标
`@Tags(['integration'])`，`firebase/dart_test.yaml` 默认排除。

**人工触发命令（实测可跑，已写入集成测试头注释）**：
```bash
cd firebase && flutter test --tags integration --run-skipped
```
注意：`firebase/dart_test.yaml` 用标签级 `skip:`，它优先于 `--tags` 选择，**必须加
`--run-skipped`** 才跑得起来。

**A3 的服务端事实由谁保证**：本集成测试是**冒烟占位** —— 只验证后端在真实 RTDB
上登记 / 读写不抛错，**不**声称验证「服务端断开删除」（那需要真实断连 + 第二连接
观察，超出单进程测试能力）。「服务端 onDisconnect 真的删成员节点 → 对端 departed」
这一环由**窄端口 + 内存 backend 的已登记删除语义** + 契约套件「A4 · 非正常断开
产出 departed」保证，不是靠本集成测试。无模拟器 / 平台通道不可用时两条报
**SKIPPED**（实测 `~2`），**不报 PASSED**。

**模拟器配置**：`firebase/infrastructure/emulator/firebase.json` 已补 `database` 段
（端口 9000）+ `database.rules`，`start_emulator.sh` 可起。VM 平台通道不可用，
真 RTDB 验证需真机 / Chrome（`--device=...`）。

---

## 验收结果（基于返工后真实状态）

- A1 `runSignalingContractSuite` 对 `CloudSignaling` 11 条全绿 ✓
- A2 `core` 191 条 / `p2p` 18 条全绿，契约套件一字未改（`git diff` 空）✓
- A3 departed 来自已登记 onDisconnect，变异 1 实测变红 ✓
- A4 close 发 Bye + 对端 departed + close 幂等（契约套件覆盖 + 变异 5）✓
- A5 departed 后 send 抛 `CloudPeerDepartedError`（`StorageError` 子类）✓
- A6 `core`（新增守卫）与 `p2p`（既有守卫）零 firebase 依赖，正则补
  `persistence_firebase` 分支，变异 10 实测变红 ✓
- A7 RTDB 路径与载荷不含身份：路径侧绑定真实 `rootPath` 构造（变异 6 实测变红），
  载荷 / 成员 id 侧读回 `debugSerializedRoom` 断言 ✓
- A8 变异自检完整表如上：上一轮 5 条 + 本轮 6 条，含「变异后仍全绿」的对照 ✓
- A9 S1a（57=基线）/ S1b（firebase 20=基线）/ monorepo 约定 三门禁全过 ✓

## 返工项对照（REWORK R1–R10）

| 项 | 修复 | 验证 |
|---|---|---|
| R1 | 端口加 `pathOf`，内存 fake 路径绑定 `RtdbRendezvousBackend.rootPath` | 变异 6 变红在 A7 |
| R2 | `CloudSessionClosedError extends StorageError` + 测试；裁定见 D5 | 变异 7 变红在 R2 |
| R3 | 集成测试跳过改 `markTestSkipped` | `--tags integration --run-skipped` 实测 `~2` |
| R4 | 命令改 `--run-skipped`（决定记录 + 头注释） | 命令可跑，测试名可见 |
| R5 | `_emit` 同值去重 + 测试 | 变异 8 变红在 R5 |
| R6 | `open` 先关旧会话 + 测试 | 变异 9 变红在 R6 |
| R7 | 守卫正则补 `persistence_firebase` | 变异 10 变红在 A6 |
| R8 | `firebase.json` 补 database 段 + rules；集成测试降级为冒烟占位 | 措辞无「A3 的最后一环」 |
| R9 | `_teardown()` 清空 `_consumedEnvelopeIds`；D4 写明 rv 不复用 | 本表 D4 |
| R10 | 本文件（变异全表 + ✓ 修正 + 流程事故） | — |

## 文件清单

- `firebase/lib/signaling/rendezvous_backend.dart`（窄端口 + `pathOf` + 信封编解码）
- `firebase/lib/signaling/rtdb_rendezvous_backend.dart`（真实 RTDB 后端）
- `firebase/lib/signaling/cloud_signaling.dart`（`CloudSignaling` + `_CloudSession`
  + `CloudPeerDepartedError` + `CloudSessionClosedError`）
- `firebase/test/signaling/memory_rendezvous_backend.dart`（内存后端，路径绑定真实构造）
- `firebase/test/signaling/cloud_signaling_contract_test.dart`（契约 + A3/A8/R2/R5/R6 + A7）
- `firebase/test/signaling/rtdb_rendezvous_backend_integration_test.dart`（冒烟占位）
- `firebase/dart_test.yaml`（排除 integration tag）
- `firebase/infrastructure/emulator/firebase.json`（补 database 段）+ `database.rules`
- `core/test/s3c_no_firebase_guard_test.dart`（core 零 firebase 守卫，正则含
  `persistence_firebase`）

未改动：`core/lib/model/signaling.dart`、`core/lib/test_support/signaling_contract_suite.dart`
（契约文件零修改，逐字保持基线）。`p2p` 一字未动（派工 §六），差异见 D5。
