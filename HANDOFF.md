# HANDOFF — S1d Blob Store Coding Plan

## 状态：Task 1 完成，Task 2 待启动

## 已完成

### Task 0（前期已完成，本 agent 确认）
- D1/D2 裁定已记录在 `tasks/codex-storage-s1d-blobstore.md`
- OpenSpec 已通过 validate

### Task 1：清理生成代码基线（✅ 已完成）
- 恢复了被 build_runner 误删的 `assets/lib/geo/drift/geo_database.g.dart`（2482 行）
- 运行 build_runner 重新生成 `persistence_drift.g.dart`（含 blob 三表 class）
- 验证：`git diff main -- '*.g.dart' | rg '^-.+REFERENCES'` 无输出（exit 1）
- 只有 `persistence_drift.g.dart` 有变更（7593 insertions, 5393 deletions），其他 `.g.dart` 零变更
- 已提交：`21bae2d chore: restore generated code baseline, isolate blob generated code`

### 环境准备
- `core/` 和 `drift/` 均已执行 `flutter pub get`，依赖解析成功

## 待执行

从 Implementation Plan Task 2 开始，按顺序执行 Task 2→12：

### Task 2: Finalize Scoped v9 Schema and Migration Chain
- 文件：`drift/test/blob/blob_schema_v9_migration_test.dart`（已有）、`drift/test/blob/blob_schema_v1_to_v9_test.dart`（需创建）
- 当前 blob 表已存在但需要验证 scope 复合主键和 v1→v9 链路
- 关键：只改 `if (from < 9)` 分支，不改 v8 及以前

### Task 3-12: 按 Implementation Plan 机械执行
- 每个任务 RED→GREEN→变异→GREEN→提交
- 变异证据追加到 `docs/storage-s1d-blobstore/mutation-evidence.md`

## 高风险门禁（每个提交前必须检查）

1. schema 只能用 v9，不修改 v8 及以前分支
2. `git diff main -- '*.g.dart' | rg '^-.+REFERENCES'` 预期无输出
3. UTC 只修 blob 三张新表，不统一修改全仓

## 启动命令

```bash
# 第一步：运行现有测试确认基线
cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/codex-storage-s1d-blobstore/drift
flutter test test/blob/blob_schema_v9_migration_test.dart test/blob/identity_blob_cipher_test.dart test/blob/in_memory_blob_store_test.dart

# 然后从 Task 2 开始执行
```

## 关键文件路径

- 分支：`agent/codex/storage-s1d-blobstore`
- Worktree：`/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/codex-storage-s1d-blobstore`
- 任务纪要：`tasks/codex-storage-s1d-blobstore.md`
- 机械执行计划：`docs/superpowers/plans/2026-08-04-storage-s1d-blobstore-implementation-plan.md`
- 设计文档：`docs/superpowers/specs/2026-07-31-storage-architecture-design.md`
- OpenSpec：`openspec/changes/storage-s1d-blobstore/`
- 变异证据（待创建）：`docs/storage-s1d-blobstore/mutation-evidence.md`