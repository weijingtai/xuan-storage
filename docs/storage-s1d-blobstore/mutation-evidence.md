# S1d Blob Store — Mutation Evidence Ledger

## Task 2: Schema v9 Migration Chain

### Mutation 1: `if (from < 9)` → `if (from < 8)`
- **File**: `drift/lib/persistence_drift.dart`
- **Injected violation**: Changed blob table creation from `if (from < 9)` to `if (from < 8)`.
- **Expected failure**: v8→v9 migration test must fail because blob tables are created in the wrong branch (v8 is occupied by S1b).
- **Command**: `flutter test test/blob/blob_schema_v9_migration_test.dart`
- **Observed**: 2/4 tests failed:
  - `schema v9 · blob 三表迁移 v8 旧库升到 v9：三张 blob 表可用` — table `t_blob_meta` doesn't exist
  - `schema v9 · blob 三表迁移 v8 旧库里的既有数据，升到 v9 后逐字段未丢` — same
- **Restored**: `if (from < 9)` — all 11 blob tests pass.

## Task 4: Atomic Native Chunk Files

### Mutation 2: All chunk indices write to `0.bin`
- **File**: `drift/lib/blob/native.dart`
- **Injected violation**: Changed `targetPath` to always use `0` instead of `$index`.
- **Expected failure**: Concurrent different-index writes test must fail because all writes overwrite the same file.
- **Command**: `flutter test test/blob/file_system_blob_byte_backend_test.dart`
- **Observed**: 1/6 tests failed:
  - `atomic chunk files concurrent different-index writes are safe` — PathNotFoundException on rename
- **Restored**: `$index` in targetPath — all 6 tests pass.