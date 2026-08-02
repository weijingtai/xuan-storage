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

## 未完成（下一步从这里继续）

### 关键阻塞：drift 包在 worktree 内无法 pub get

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

### 待办（环境修好后）
1. 填任务纪要 `tasks/mimo-storage-s1b-multipeer.md`：目标（一句话）/
   计划（按 dispatch §5 的 ACT 01–10 蒸馏）/ 验收标准（A1–A11 骨架，§4 的五条纪律：
   可机械执行 / 必须能变红 / spy 用计数不用 fail() / 非 happy-path 必须覆盖 /
   覆盖类门禁有写死下限）。
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
