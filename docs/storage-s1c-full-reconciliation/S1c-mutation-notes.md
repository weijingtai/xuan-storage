# S1c 变异自检记录（A9 逐条落盘）

> 编制：opencode（编码 AI）｜日期：2026-08-07
> 背景：复验 P1-3 指出原稿只有 3 条变异记录（M2a + 门禁 M1/M2），非逐条新测试、无落盘文件。
> 本文件按「对本轮新增的每条测试补变异自检」逐条落盘：注入什么 → 红在哪条断言 → 复原后全绿。
> 手法：备份文件 → python3 注入变异 → 跑对应测试文件 → 确认红在目标断言（非编译失败）→ 复原 → 门禁/测试复绿。
> 覆盖文件：s1c_manifest_comparator / s1c_reconciliation_trigger / s1c_reconciliation_coordinator（契约套件两 fake 各跑一遍）/ s1c_peer_denial / entity_stamp_manifest_source / record_reconciliation_applier。

## 总表

| # | 变异对象（注入文件） | 注入了什么 | 红在哪条断言（测试） | 复原后 |
|---|---|---|---|---|
| M1 | `core/lib/sync/manifest_comparator.dart` | `classifyLocalEntry` 里 `remote == null` 从发终态误判为索求（sendTerminal→requestTerminal） | `s1c_manifest_comparator_test.dart`「本地有 / 对方无 → sendTerminal」：Expected sendTerminal / Actual requestTerminal | ✅ 全绿 |
| M2 | 同上 | `_compareStamps` 的 `cmp > 0` 放宽为 `cmp >= 0`（同版本也发终态） | 同上「版本相同 → skip」：Expected skip / Actual sendTerminal | ✅ 全绿 |
| M3 | 同上 | `is_deleted` 混入定序比较（同戳一活一墓碑被判为不同） | 同上「同戳一活一墓碑 → 按戳比较，墓碑位不影响结论」：Expected skip / Actual sendTerminal 或 requestTerminal | ✅ 全绿 |
| M4 | `core/lib/sync/reconciliation_trigger.dart` | 删掉 `lastPullResult is IncrementalUnavailable → fullReconcile` 分支 | `s1c_reconciliation_trigger_test.dart`「peer_denies_incremental_forces_full」：Expected fullReconcile / Actual incremental | ✅ 全绿 |
| M5 | 同上 | `elapsed > interval` 放宽为 `elapsed >= interval`（边界当天也强制全量） | 同上「exactly_at_interval_boundary_uses_incremental」：Expected incremental / Actual fullReconcile | ✅ 全绿 |
| M6 | `core/lib/core/reconciliation_coordinator.dart` | ④ `sendCursorAdvance` 提前到 ① `sendManifestChunk` 之前（M2a 变异形态） | `s1c_reconciliation_coordinator_test.dart` 契约套件第 6 条「线序守卫：全部 ManifestChunk 必须先于 CursorAdvance」：Expected true / Actual false（Fake A、Fake B 各红一遍） | ✅ 全绿 |
| M7 | 同上 | 「遍历收到清单」的索求条件取反（本地已有也索求/本地无则不索求） | 契约套件「新设备入网 → 对端全量推来」：Expected true / Actual false | ✅ 全绿 |
| M8 | `drift/lib/sync/entity_stamp_manifest_source.dart` | 清单查询加 `is_deleted = false` 过滤（墓碑行不进清单） | `entity_stamp_manifest_source_test.dart`「single_page_includes_tombstone_rows」：Expected 3 行 / Actual 2 行；Expected [r1..r5] / Actual [r1..r4] | ✅ 全绿 |
| M9 | `drift/lib/sync/record_reconciliation_applier.dart` | 墓碑终态映射 `opDelete` 误写为 `opUpsert` | `record_reconciliation_applier_test.dart`「tombstone_terminal_writes_tombstone_marker」：Expected 1 / Actual 0 | ✅ 全绿 |
| M10 | `core/lib/core/sync_coordinator.dart` | 删掉 `if (lastError == null)` 守卫，否决后也调 `markPulledAt` | `s1c_peer_denial_test.dart`「否决后 markPulledAt 不得被调用（lastError != null 时不记成功）」：Expected 0 / Actual 1 | ✅ 全绿 |

## 逐条明细

### M1 · 本地有 / 对方无 → 必须发终态（s1c_manifest_comparator_test）

注入：`classifyLocalEntry` 的 `remote == null` 分支返回 `requestTerminal` 而非 `sendTerminal`。
红点：`Expected: ManifestComparatorDecision:<sendTerminal>` / `Actual: ManifestComparatorDecision:<requestTerminal>`，`+10 -1`。
意义：守卫「本地独有实体必须推给对方」，防双遍历比对把独有行误判为索求导致死锁。

### M2 · 版本相同 → 必须 skip（s1c_manifest_comparator_test）

注入：`_compareStamps` 首判 `cmp > 0` 放宽为 `cmp >= 0`。
红点：`Expected: skip` / `Actual: sendTerminal`（版本相同不再跳过）。
意义：守卫全序比较的 `identical` 分支，防同版本重复交换。

### M3 · is_deleted 不参与定序（s1c_manifest_comparator_test）

注入：`cmp` 计算结果混入 `isDeleted` 差异（`+ (isDeleted 不同 ? 1 : 0)`）。
红点：同戳一活一墓碑用例 `Expected: skip` / `Actual: sendTerminal`（或 requestTerminal）。
意义：守卫 S1c §3.2① 定稿「is_deleted 是 applier 数据位、不参与定序」，防墓碑位污染版本全序。

### M4 · 对端否决 → 必须强制全量（s1c_reconciliation_trigger_test）

注入：`lastPullResult is IncrementalUnavailable` 分支短路（永不进入）。
红点：`peer_denies_incremental_forces_full`：`Expected: fullReconcile` / `Actual: incremental`，`+5 -1`。
意义：守卫 A8 否决权主路径——否决不是「普通空页」，必须切全量。

### M5 · 边界当天 → 仍走增量（s1c_reconciliation_trigger_test）

注入：`elapsed > interval` 放宽为 `elapsed >= interval`。
红点：`exactly_at_interval_boundary_uses_incremental`：`Expected: incremental` / `Actual: fullReconcile`。
意义：守卫 90 天阈值边界语义（刚好到边界不强制全量）。

### M6 · 线序守卫：④ 不得早于 ①（契约套件第 6 条，Fake A + Fake B 各跑一遍）

注入：`reconcileAsInitiator` 在发清单分片前先发 `sendCursorAdvance`（M2a 变异形态）。
红点：契约套件「线序守卫：全部 ManifestChunk 必须先于 CursorAdvance」：`Expected: true` / `Actual: false`，`order` 中 cursorAdvance 出现在首个 manifestChunk 之前。
意义：守卫四阶段线序（发起→应答→终态→确认），防游标确认提前导致对端漏收清单。**M2a 变异红在断言，非编译失败**（复验 P1-3 要求的线序变异）。

### M7 · 新设备入网 → 对端全量推来（契约套件）

注入：`handleRemoteManifest`「遍历收到清单」的索求条件 `containsKey → continue` 取反。
红点：契约套件「新设备入网 → 对端全量推来」：`Expected: true` / `Actual: false`（新设备收不到 r1/r2）。
意义：守卫「本地无/对方有 → EntityRequest 索求」双遍历基准（新设备入网核心路径）。

### M8 · 清单必须含墓碑行（entity_stamp_manifest_source_test）

注入：`readManifestChunk` 查询加 `t.isDeleted.equals(false)` 过滤。
红点：`single_page_includes_tombstone_rows`：`Expected: an object with length of <3>` / `Actual: [2 行]`；`Expected: [r1..r5]` / `Actual: [r1..r4]`。
意义：守卫 S1c §3.2① 定稿「清单含全部未压缩戳行，含 is_deleted=true 墓碑行」——否则删除传不到对端、用户删掉的数据会在对端复活。

### M9 · 墓碑终态 → 必须写删除（record_reconciliation_applier_test）

注入：`applyTerminals` 的 `opType` 恒映射为 `opUpsert`（墓碑不再映射 `opDelete`）。
红点：`tombstone_terminal_writes_tombstone_marker`：`Expected: <1>` / `Actual: <0>`。
意义：守卫墓碑传播落库——远端墓碑到达本地必须真的写删除态。

### M10 · 否决后不得记成功（s1c_peer_denial_test）

注入：`pullOnce` 的 `if (lastError == null)` markPulledAt 守卫改恒真（否决后也记成功）。
红点：`否决后 markPulledAt 不得被调用（lastError != null 时不记成功）`：`Expected: <0>` / `Actual: <1>`。
意义：守卫 A8 否决权「游标不得推进 + 不记成功」——否决后记成功会把断点误记为已同步，静默丢数据。

## 复原验证

- 全部 10 个变异注入后 `git status --porcelain` 核心实现文件零残留（M1-M10 逐一 `cp` 备份复原）。
- 复原后对应测试文件全绿；S1c 门禁与契约套件（两 fake 各跑一遍）全过，见返工项 5 的门禁/测试输出。
