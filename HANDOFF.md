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
