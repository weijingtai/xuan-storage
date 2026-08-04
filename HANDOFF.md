# HANDOFF — S1d Blob Store Coding Plan

## 状态：Task 7 完成，Task 8 部分完成（代码已写但测试有编译错误），Task 9-12 待启动

## 已完成

### Task 1 ✅ 生成代码基线恢复
恢复 `assets/lib/geo/drift/geo_database.g.dart`，重新生成 `persistence_drift.g.dart`，`REFERENCES` 删除检查通过。提交 `21bae2d`

### Task 2 ✅ 最终确定 v9 Schema 和迁移链
创建 `blob_schema_v1_to_v9_test.dart`（3 项测试），变异验证 `if (from < 9)` → `< 8` 变红。提交 `81c3d3f`

### Task 3 ✅ 条件字节后端
创建 `blob_byte_backend.dart`（条件导出）、`native.dart`（`FileSystemBlobByteBackend`）、`web.dart`、`unsupported.dart`，8 项测试。提交 `cb7202c`

### Task 4 ✅ 原子文件系统实现
`file_system_blob_byte_backend_test.dart` 6 项测试，变异验证（全部写入 `0.bin` 变红）。提交 `4f8c08d`

### Task 5 ✅ 加密解析
`BlobCipherRegistry` + 6 项 cipher 测试，变异验证（private 路由到 identity 变红）。提交 `c99f2ab`

### Task 6 ✅ 元数据仓库
`BlobMetadataRepository` + 7 项测试（scope 隔离、伪造声明拒绝等），2 项变异。提交 `4d98c6d`

### Task 7 ✅ DriftLocalBlobStore
实现 `put/putFile/putChunk/readCipherChunk`、staged 隔离（complete 前不可见），5 项测试。提交 `1458a47`

### Task 8 ⏳ 垃圾回收（部分完成）
- `blob_garbage_collector.dart` 已创建
- `blob_lifecycle_gc_test.dart` 已创建
- **测试有编译错误待修复**

## 待执行

### Task 8 修复
- 需要修复 `Variable.withString` / `isBefore` 等编译错误
- 运行 RED→GREEN→变异→GREEN→提交

### Task 9-12
- Task 9: RecordBlobUnitOfWork
- Task 10: In-Memory BlobGateway Fake
- Task 11: 变异证据汇总
- Task 12: 最终验收

## 最终验收命令
```bash
# 三项门禁
git diff main -- '*.g.dart' | rg '^-.+REFERENCES'  # 无输出
git diff --check  # exit 0
# 全部测试
cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/codex-storage-s1d-blobstore/drift
flutter test test/blob/
```

## 当前文件路径
- 分支：`agent/codex/storage-s1d-blobstore`
- 最新提交：`18d866a`
- 变异证据：`docs/storage-s1d-blobstore/mutation-evidence.md`
- 所有 blob 文件：`drift/lib/blob/`（9 个文件）
- 所有测试：`drift/test/blob/`（8 个测试文件）