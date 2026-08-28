# HANDOFF: storage-s2b-blob-media-reader（Wave 1B 返工交付）

## Task S2b: Media Reference Reader 接口对齐与流消费异常可观察性（2026-08-27）

- 当前分支/worktree: `feature/storage-s2b-blob-media-reader` (`wave2-xiang-s2b`)
- 上游/基线 Commit SHA: `df6ddc208ebac30abdaf9110e1e32acd373d09ff`
- 变更范围:
  - `drift/lib/media/drift_media_reference_reader.dart`: 实现 `MediaReferenceReader` 契约（`statusOf`、`openRead`），委托 `BlobMetadataRepository` 与 `DriftLocalBlobStore`；保留 `statusOf` 元数据三态语义（不全量读盘）；`openRead` 前置 `BlobCorruptError`/`BlobUndecryptableError` 映射为对应 `MediaReadResult`，流消费期异常通过 `_mapStreamErrors` 转换为 `BlobCorruptError` 保证错误可观察。
  - `drift/test/media/drift_media_reference_reader_test.dart`: 增加/保留硬断言覆盖 `absent`、`partial`、`complete`、`corrupt`、`undecryptable` 全部 5 种状态；包含 byte stream 消费期抛出 `BlobCorruptError` 的端到端测试。
- 执行命令与退出码:
  - 依赖更新: `(cd drift && flutter pub get)` -> Exit code 0
  - 定向 reader 测试: `(cd drift && flutter test test/media/drift_media_reference_reader_test.dart)` -> Exit code 0 (9/9 passed)
  - 全量 media 测试: `(cd drift && flutter test test/media/)` -> Exit code 0 (13/13 passed)
  - 相关 blob 测试: `(cd drift && flutter test test/media/ test/blob/)` -> Exit code 0 (99/99 passed)
  - Core 回归测试: `(cd core && flutter test)` -> Exit code 0 (295/295 passed)
  - 静态分析: `(cd drift && flutter analyze lib/media test/media lib/blob test/blob)` -> Exit code 0 (0 issues)
  - 格式/检查: `git diff --check` -> Exit code 0
- 未运行项: 跨平台真机 UI 媒体渲染（超出纯 Dart reader 契约与 S2b 范围）
- 残余风险: 无。已通过直接依赖与 stream 消费双向验证。
- 人类合并/发布顺序: S2b feature 分支在人类验收后合并至 xuan-storage main。

---

# HANDOFF: storage-record-module-check（Task Kanyu R2）

## Task Kanyu R2: Record 读取补 module 校验（2026-08-25）

- 当前分支/worktree: `feature/kanyu-r2-record-module-check` (`wave1-kanyu-r2`)
- Commit SHA: `a750a059fcdeb198e11a299e418ec3586cffe674`
- 变更范围:
  - `drift/lib/record/local_record_repository.dart`: `getRecord` 增加 `record.module == module` 校验，mismatch 返回 `null`。
  - `drift/test/record/local_record_repository_test.dart`: 增加 TDD RED/GREEN 测试 `getRecord returns record only when module matches`。
- 执行命令与退出码:
  - RED test: `flutter test --no-pub test/record/local_record_repository_test.dart` -> Exit code 1 (Failed as expected)
  - GREEN test: `flutter test --no-pub test/record/local_record_repository_test.dart` -> Exit code 0 (Passed, 2/2 tests)
  - Static analysis: `flutter analyze --no-pub lib/record/local_record_repository.dart test/record/local_record_repository_test.dart` -> Exit code 0 (0 issues)

---

# HANDOFF: Storage UoW Agent (S4) - Section 9.7 Wave 1C Rework

## Status Overview
- **Worktree**: `/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/wave2-xiang-s4`
- **Branch**: `feature/xiang-s4-uow-search-restore`
- **Scope**: Section 9.1 & 9.7 Storage UoW atomic transactions, search indexing, blob refs reconcile, soft-delete, file restart, and restore semantics across Drift and InMemory fake.
- **Verification**: ALL tests in drift (539 tests) pass, all target tests pass, `flutter analyze` on target files 0 issues, `git diff --check` passes.

## Implementation Details

1. **Contract Interface**:
   - `RecordBlobUnitOfWork.restoreWithBlobs`: Added contract method to restore record, search tags, blob refs, and outbox atomically.

2. **Drift Implementation (`DriftRecordBlobUnitOfWork`)**:
   - Enclosed all operations for `saveWithBlobs`, `deleteWithBlobs`, and `restoreWithBlobs` inside a single Drift SQLite transaction boundary (`_db.transaction(...)`).
   - Integrated `outboxStore` directly within the transaction (no after-transaction enqueue or swallowed exceptions).
   - Injected fault hooks: `injectFailureAfterRecord`, `injectFailureAfterBlobRefs`, `injectFailureAfterOutbox`, and legacy `injectFailureAfterSave`.

3. **In-Memory Parity Fake (`InMemoryRecordBlobUnitOfWork`)**:
   - Synchronized full transactional semantics with snapshot rollback on exceptions.
   - Maintained state maps for `_records`, `_refs`, `_searchTags`, and outbox records with parity getters (`records`, `refs`, `searchTags`).

4. **Unified Local Repository (`LocalRecordRepository`)**:
   - Atomic Drift transaction boundaries for `saveRecord`, `softDeleteRecord`, and `restoreRecord` ensuring outbox failures roll back records and search tags cleanly.

5. **Test Coverage & Verification**:
   - `drift/test/blob/record_blob_unit_of_work_fault_injection_test.dart`: Multi-stage fault injection for `saveWithBlobs`, `deleteWithBlobs`, `restoreWithBlobs`, `LocalRecordRepository`, and `InMemoryRecordBlobUnitOfWork`.
   - `drift/test/blob/record_blob_restart_test.dart`: File-backed Drift DB restart across save -> soft-delete -> restore cycles validating records, moduleData, search tags, blob refs, outbox queue, and byte persistence.
   - `drift/test/blob/record_blob_unit_of_work_test.dart`: Unit of work tests including search tag extraction and soft-delete/restore parity.

## Verification Summary
```bash
# Targeted UoW tests:
flutter test test/blob/record_blob_unit_of_work_test.dart test/record/local_record_repository_test.dart test/blob/record_blob_unit_of_work_fault_injection_test.dart test/blob/record_blob_restart_test.dart (21 tests passed)

# Full Drift suite:
flutter test (539 tests passed)

# Target static analysis:
flutter analyze test/blob/record_blob_unit_of_work_fault_injection_test.dart test/blob/record_blob_restart_test.dart test/blob/record_blob_unit_of_work_test.dart test/record/local_record_repository_test.dart lib/blob/drift_record_blob_unit_of_work.dart lib/blob/in_memory_record_blob_unit_of_work.dart lib/record/local_record_repository.dart (0 issues)

# Git check:
git diff --check (0 errors)
```
