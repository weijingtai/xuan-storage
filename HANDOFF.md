# INCOMPLETE HANDOFF — S1d Blob Store Coding Plan

## 状态：Task 2 完成，Task 3 部分完成，Task 4-12 待启动

## 已完成

### Task 1: 生成代码基线恢复 ✅
- 恢复被 build_runner 误删的 `assets/lib/geo/drift/geo_database.g.dart`（2482 行）
- 重新生成 `persistence_drift.g.dart`（含 blob 三表）
- `REFERENCES` 删除检查通过（无输出）
- 提交：`21bae2d`

### Task 2: 最终确定 v9 Schema 和迁移链 ✅
- 创建 `blob_schema_v1_to_v9_test.dart`（3 项测试：v8→v9 迁移后旧数据存活、UTC 往返、主键冲突）
- 现有 `blob_schema_v9_migration_test.dart`（4 项测试）全部通过
- 突变验证：`if (from < 9)` → `if (from < 8)` → 2 项测试变红 ✓
- 恢复正确实现后全部 11 项 blob 测试通过
- 变异证据记录在 `docs/storage-s1d-blobstore/mutation-evidence.md`
- 提交：`81c3d3f`

### Task 3: 条件字节后端（部分完成 — 已创建文件，测试待写）
- Create: `drift/lib/blob/blob_byte_backend.dart` — 条件导出入口
- Create: `drift/lib/blob/native.dart` — `FileSystemBlobByteBackend`（含 temp-write/rename/read/delete/orphan scan）
- Create: `drift/lib/blob/web.dart` — `WebBlobByteBackend`（抛出命名 unsupported 错误）
- Create: `drift/lib/blob/unsupported.dart` — `UnsupportedBlobByteBackend`
- 测试文件已创建但未完成：`blob_platform_boundary_test.dart`
- 提交：`7447e74`

## 待执行

### Task 3 剩余工作
- 完成 `blob_platform_boundary_test.dart`，运行 RED→GREEN
- 完成突变（添加 `getExternalStorageDirectory` 后测试应变红）

### Task 4: 原子文件系统实现
- 完成 `file_system_blob_byte_backend.dart`（已有 native.dart 中）
- 创建 `file_system_blob_byte_backend_test.dart`

### Task 5-12: 按 Implementation Plan 顺序执行

## 关键检查点

### 三项门禁（每提交前检查）
1. schema 只用 v9，不修改 v8 及以前分支
2. `git diff main -- '*.g.dart' | rg '^-.+REFERENCES'` 预期无输出
3. UTC 只修 blob 三张新表

### 启动命令
```bash
cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/codex-storage-s1d-blobstore/drift
flutter test test/blob/
```

## 当前文件路径
- 分支：`agent/codex/storage-s1d-blobstore`
- 任务纪要：`tasks/codex-storage-s1d-blobstore.md`
- 机械执行计划：`docs/superpowers/plans/2026-08-04-storage-s1d-blobstore-implementation-plan.md`
- 变异证据：`docs/storage-s1d-blobstore/mutation-evidence.md`
- 已有 WIP blob 文件：`drift/lib/blob/`（6 个文件）
- 已有测试：`drift/test/blob/`（5 个文件，4 个测试文件）