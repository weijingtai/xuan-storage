# ⚠️ 未完成交接：S1b 立项进行中 —— drift 环境前置待修

> 交接时间：2026-08-02。执行体因工具迭代预算耗尽（40/50）触发优雅交接协议。
> 工作目录：`/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/mimo-storage-s1b-multipeer`
> 分支：`agent/mimo/storage-s1b-multipeer`（已确认非 main）。主工作区 `xuan-storage` 仍在 main。

## 任务背景
`docs/dispatch/2026-08-02-s1b-dispatch-prompt.md` —— S1b 同步引擎多 peer 化。
规格唯一真相：`docs/superpowers/specs/2026-07-31-storage-architecture-design.md` §5.2.1–5.2.3 / §5.3 / §5.4 / §9。
协议链：/wjt-plan → /wjt-act → /wjt-react → 派发执行 → 人类验收。**AI 不得自行合 main / push。**

## 已完成（本会话）

1. **六个阻断点行号全部核对准确**（dispatch 第 1 节所列全部属实）：
   - ① `t_outbox` 主键 `{operationId}` 无 peerId —— `drift/lib/persistence_drift.dart:179` ✅
   - ② `t_sync_state` 主键 `{scopeUid, entityType}` 无 peerId —— `drift/lib/persistence_drift.dart:215` ✅
   - ③ `markSuccess({operationId, atUtc})` 无 peerId —— `core/lib/model/ports.dart:57` ✅
   - ④ `push` 返回单个 `SyncError?` —— `core/lib/model/ports.dart:183` ✅
   - ⑤ `RemoteGatewayRouter` 1-of-N 选择器（51 行）—— `core/lib/routing/remote_gateway_router.dart` ✅
   - ⑥ `getCapabilities()` 返回 `RegionCapabilities` —— `core/lib/model/ports.dart:206`；定义在 `core/lib/model/types.dart:444` ✅
   - 另核实：`schemaVersion=6` 在 `drift/lib/persistence_drift.dart:541`，onUpgrade 有 from<2..6 五段 ✅
2. **第 6 节全部文件已读**：设计稿 §5.2.1–5.2.3/§5.3/§5.4/§9、ports.dart、transport.dart、storage_classification.dart、storage_policy_registry.dart、policy_channel_filter_test.dart、sync_coordinator.dart、sync_runtime.dart、remote_gateway_router.dart、persistence_drift.dart、record_local_applier.dart、tasks/mimo-storage-s1a-contracts.md。
3. **/wjt-plan 立项已执行**：`aiwt new mimo storage-s1b-multipeer` 成功，worktree 已建（主工作区 git status 虽不干净——firestore.rules 改动 + .codegraph/daemon.pid + docs/dispatch/——但 aiwt new 未拒绝，无需上报）。
4. **core 环境就绪**：`cd core && flutter pub get` 成功（内网 Gitea 可达）；`cd core && dart analyze --fatal-infos` = **58 issues**，与 S1a 冻结基线一致（42 条 four_zhu_card_templates 孤儿 + 8 条 SECURE_PUBSPEC_URLS + 既有，属 main 分支既有断点，S1b 沿用 S1a 的冻结白名单口径，见 S1a 纪要 A1 决定记录）。

## ✅ 阻塞已解除（2026-08-02，由验收方修复，无需再做）

`drift/pubspec_overrides.yaml` 已写好（绝对路径，19 条全量覆盖，gitignored 不入库）。实测结果：

```
cd drift && flutter pub get   → Changed 151 dependencies! ✅
cd core  && flutter pub get   → Got dependencies! ✅
cd drift && flutter test      → 276 tests, All tests passed! ✅
```

### ⚠️ 下面这段是踩坑记录，改这个文件前必读

交接文档原推荐的「只写 4 条 path 覆盖」**是错的，会换来另一个更难看懂的报错**：

```
Because every version of xuan_four_zhu_card from git depends on persistence_core from hosted
and persistence_drift depends on persistence_core from git, xuan_four_zhu_card from git is forbidden.
```

原因：**Dart 的语义是 `pubspec_overrides.yaml` 的 `dependency_overrides` 整块【替换】
`pubspec.yaml` 里的同名块，不是合并。** 而 `drift/pubspec.yaml` 本来就有一个 19 条的
`dependency_overrides` 块（其中 15 条把各 `repository_interface_*` 与 `persistence_core`
钉到内网 Gitea 的 git 源）。只写 4 条 path，等于把那 15 条 git 覆盖一起抹掉，
`xuan_four_zhu_card` 就会去 pub.dev 找 `persistence_core`，与本包的 git 源冲突。

**正确做法**：把 `drift/pubspec.yaml` 的 `dependency_overrides` 整块拷进
`pubspec_overrides.yaml`，只把其中 4 条 `path: ../../X` 改成绝对路径。文件头部已写了这段说明。

**维护提醒**：主工作区 `drift/pubspec.yaml` 的 `dependency_overrides` 一旦变动，
本 worktree 的 `pubspec_overrides.yaml` 需同步重新生成（它是 gitignored 的，不会自动跟着分支走）。

### 已测得的 analyze 基线（S1b 的 A1 直接用这两个数，不要重新猜）

| 包 | 退出码 | 总数 | 严重度分布 | 涉及文件 |
|---|---|---|---|---|
| `core` | 3（error） | **58** | 34 ERROR / 9 WARNING / 15 INFO | 9 |
| `drift` | 2（warning） | **162** | 0 ERROR / 70 WARNING / 92 INFO | 71 |

core 的 34 个 ERROR 全部是 main 分支既有断点，与 S1a 冻结基线**完全一致**：

```
21  lib/four_zhu_card_templates/layout_template_local_data_source.dart
10  lib/four_zhu_card_templates/layout_template_repository_impl.dart
 2  lib/model/calculation_strategy_config_data_model.dart
 1  lib/model/lunar_date_info_v2_data_model.dart
```

`four_zhu_card_templates/` 是从 persistence_drift 拷过来的孤儿模块，import 了 `package:drift/drift.dart`
与 `../database/app_database.dart`，而 core 既没有 drift 依赖也没有 `lib/database/` 目录。

**因此 S1b 的 A1【不能】写成「全包 `dart analyze --fatal-infos` = 0」——那在开工前就是红的。**
沿用 S1a 已验证过的三段式冻结门禁：`scripts/run_s1a_analyze_gate.sh`（本分支已有，5.1K）。
它做三件事：① 对本任务范围内的文件跑 scoped analyze 必须为 0；② 有问题的文件必须 ⊆ 冻结白名单；
③ 总数不得超过冻结基线。**S1b 需照抄一份 `run_s1b_analyze_gate.sh`，把 core 基线设 58、
drift 基线设 162，白名单按上表生成，并同样用「注入一个 unused import」的三条负测试证明它能变红。**

---

## 未完成（下一步从这里继续）

### ~~关键阻塞：drift 包在 worktree 内无法 pub get~~ 【已解除，保留原始分析供追溯】

- 症状：`cd drift && flutter pub get` 失败：`repository_interface_media` path 依赖
  `../../repository-interface-media` 解析不到（worktree 在 `.worktrees/<name>/` 下多一层，
  `../../` 指向 `xuan-storage/` 而非 `xuan-migration/`）。
- 已查证：
  - drift/pubspec.yaml 有 4 个 `path: ../../` 依赖（78/80/82 行 + 155/157/159/161 行，
    去重后 4 个仓库）：repository-interface-xiang / -divination-tag / -media / -record。
  - 这 4 个仓库全部存在于 `/Users/jingtaiwei/Git/Public/xuan-migration/<dir>` ✅（已逐一确认）。
  - `.gitignore` 含 `.worktrees` 与 `**/pubspec_overrides.yaml` —— **说明本项目预留给
    worktree 的覆盖机制就是 pubspec_overrides.yaml**（且主工作区 drift/.dart_tool 存在，
    主工作区 pub get 是通的）。
- **推荐修复（未执行）**：在 `drift/pubspec_overrides.yaml`（新文件，gitignored）写：
  ```yaml
  dependency_overrides:
    repository_interface_xiang:
      path: /Users/jingtaiwei/Git/Public/xuan-migration/repository-interface-xiang
    repository_interface_divination_tag:
      path: /Users/jingtaiwei/Git/Public/xuan-migration/repository-interface-divination-tag
    repository_interface_media:
      path: /Users/jingtaiwei/Git/Public/xuan-migration/repository-interface-media
    repository_interface_record:
      path: /Users/jingtaiwei/Git/Public/xuan-migration/repository-interface-record
  ```
  然后 `cd drift && flutter pub get`。**若这些 interface 包自身也有 path 依赖，可能还需要
  递归覆盖——先试跑看报错。** 若 absolute path 方案不可行，备选：把 4 个仓库 symlink 到
  `xuan-storage/repository-interface-*`（`../../` 会解析到 `xuan-storage/`）。但 symlink 进
  `xuan-storage/` 会污染仓库根（虽然仓库内没有这些目录，git status 会显示 ?? 未跟踪），
  优先 pubspec_overrides.yaml。
- 修复后验证：`cd drift && dart analyze --fatal-infos` 应回到既有基线（数量未知，
  需对比 main 分支同一命令。若 main 分支 drift 也 29120 那是没 pub get 的假象，
  pub get 后应大幅下降）。

### 待办（环境已就绪，从这里开始）
1. 填任务纪要 `tasks/mimo-storage-s1b-multipeer.md`：目标（一句话）/
   计划（按 dispatch §5 的 ACT 01–10 蒸馏）/ 验收标准（A1–A11 骨架，§4 的五条纪律：
   可机械执行 / 必须能变红 / spy 用计数不用 fail() / 非 happy-path 必须覆盖 /
   覆盖类门禁有写死下限）。
   - **A1 照上面「已测得的 analyze 基线」写冻结门禁，不要写成 `--fatal-infos = 0`。**
   - 验收命令建议：
     `bash scripts/run_s1b_analyze_gate.sh && (cd core && flutter test) && (cd drift && flutter test)`
   - drift 的 276 个既有测试是 A2 的基线：**一个都不能少，新增只准加不准改既有断言。**
2. 完成后按 dispatch §8 第 4 条**停下来汇报**：worktree 路径 / 计划 N 项 / 验收命令，
   等人类说「开工」或指派执行体。**不要直接开工。**

## 关键事实备忘（省得重踩）
- `RegionCapabilities` 在 `core/lib/model/types.dart:444`；`PeerCapabilities`/`SyncPeer`/`PeerId`
  目前**不存在**（需新建，S1b ACT01）。
- `RemoteGatewayRouter` 51 行，`_active` 按 `Region`（firebase/supabase）选一个，改造为 fan-out。
- `SyncRuntime` 769 行；退避字段 `_pushFailureCount`（:93）与
  `_nextPullNotBeforeUtcByEntityType`（:95，已是 Map<String,DateTime?> 按 entityType），
  需改为 per-peer（加 peer 维度）。
- `record_local_applier.dart:60-61` `canAdvanceCursor: true` 恒真确认存在；全文件对
  updatedAt/rev 无比较逻辑（:94/:96 只是解析字段）。
- `core/test/persistence_core_test.dart` 有 fake：`_InMemoryOutboxStore`(:7) /
  `_FakeRemoteGateway`(:107) / `_InMemorySyncStateStore`(:154) / `_FakeLocalApplier`(:216)，
  S1b 改端口签名时这些 fake 要同步改。
- `policy_channel_filter_test.dart` 里 `filterForChannel` 是**测试内定义的函数**（不是库代码），
  S1b 要把该语义落进 drift 的 peekBatch。fail closed 语义已写死。
- `SyncStateStore.setCursorIfNewer` 已有 tieBreaker 字段（`tie_breaker` 列，
  `types.dart:193-209` TimestampCursor），S1b 的 Lamport 序 (rev, deviceId) 可能复用/扩展它。
- S1a 纪要 `tasks/mimo-storage-s1a-contracts.md` 是格式范本（A10 门禁返工记录了
  member 正则去白名单的教训，S1b ACT10 要沿用通用式正则 + 写死下限）。
- 主工作区当前未提交：`M firebase/infrastructure/emulator/firestore.rules`、
  `?? .codegraph/daemon.pid`、`?? docs/dispatch/` —— 都不是 S1b 的，别动。
- 设计稿 §5.2.3 明确：纯墙上时钟 LWW 不可用，必须 Lamport 序 (rev, deviceId)；
  `DeviceIdentity` 已存在于 `ports.dart:240`（实际是 class，deviceId 字段），复用不新建。

## 纪律
- 铁律：不在 main 上写代码（当前 worktree 分支 OK）；AI 不得合 main / push。
- 不改 `core/lib/model/ports.dart` 既有语义之外的破坏（S1b 就是要改签名，但只在 worktree）。
- 验收标准区（A1–A11）执行体无权修改。
