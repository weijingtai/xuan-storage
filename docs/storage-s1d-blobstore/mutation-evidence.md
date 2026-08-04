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

## Task 5: Cipher Resolution

### Mutation 3: Route private unavailable to identity instead of undecryptable error
- **File**: `drift/lib/blob/blob_cipher_registry.dart`
- **Injected violation**: Changed private fallback to return `IdentityBlobCipher` instead of throwing `BlobUndecryptableError`.
- **Expected failure**: The "unavailable private key maps to BlobUndecryptableError" test must fail.
- **Command**: `flutter test test/blob/blob_cipher_test.dart`
- **Observed**: 1/6 tests failed:
  - `blob cipher resolution unavailable private key maps to BlobUndecryptableError` — expected exception but got identity cipher
- **Restored**: Private unavailable returns `BlobUndecryptableError` — all 6 tests pass.

## Task 6: Metadata Repository

### Mutation 4: Remove scopeUid filter from getMeta
- **File**: `drift/lib/blob/blob_metadata_repository.dart`
- **Injected violation**: Removed `t.scopeUid.equals(scopeUid)` from `getMeta` query.
- **Expected failure**: Scope isolation test must fail because scope-b can see scope-a's blob.
- **Command**: `flutter test test/blob/blob_metadata_repository_test.dart`
- **Observed**: 1/7 tests failed:
  - `scope isolation meta queries are constrained by scopeUid` — scope-b found scope-a's blob
- **Restored**: scopeUid filter — all 7 tests pass.

### Mutation 5: Trust peer visibility instead of registry
- **File**: `drift/lib/blob/blob_metadata_repository.dart`
- **Injected violation**: Used `peerVisibility`/`peerTier` instead of deriving from registry.
- **Expected failure**: Forged private→resource/cache rejection tests must fail.
- **Command**: `flutter test test/blob/blob_metadata_repository_test.dart`
- **Observed**: 2/7 tests failed:
  - `incoming staging rejects forged private→resource declaration`
  - `incoming staging rejects forged private→cache declaration`
- **Restored**: Registry-derived visibility/tier — all 7 tests pass.

## Task 8: Garbage Collection

### Mutation 6: Delete sourceOfTruth instead of orphaning
- **File**: `drift/lib/blob/blob_garbage_collector.dart`
- **Injected violation**: Changed sourceOfTruth handling to actually delete the blob and metadata instead of marking as orphaned.
- **Expected failure**: The "sourceOfTruth zero refs is orphaned but NOT deleted" test must fail.
- **Command**: `flutter test test/blob/blob_lifecycle_gc_test.dart`
- **Observed**: 1/5 tests failed:
  - `garbage collection sourceOfTruth zero refs is orphaned but NOT deleted` — meta was null (deleted)
- **Restored**: sourceOfTruth zero refs → orphaned(status=2) but NOT deleted — all 5 tests pass.