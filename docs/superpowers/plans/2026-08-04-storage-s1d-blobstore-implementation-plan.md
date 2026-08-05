# S1d Blob Store Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement local blob persistence, cipher resolution, atomic record/blob writes and a contract-complete in-memory BlobGateway fake, with schema v9, resumable verified chunks and tier-safe GC.

**Architecture:** Native bytes live in app-support files while drift owns scoped metadata, chunk manifests, references, and lifecycle state. Incoming manifests are staged through a drift-only API whose policy is derived from local `StoragePolicyRegistry`, never from peer declarations. Public data uses identity cipher; private cipher keys are injected. Record/blob writes share one drift transaction. Real cloud object storage is deferred to S2-blob.

**Tech Stack:** Dart 3.11, Flutter, Drift/SQLite, `dart:io` behind conditional exports, `crypto`, `flutter_test`.

---

## File Map

- `drift/lib/blob/blob_tables.dart`: v9 scoped table declarations only.
- `drift/lib/blob/blob_byte_backend.dart`, `native.dart`, `web.dart`, `unsupported.dart`: conditional byte-storage boundary.
- `drift/lib/blob/file_system_blob_byte_backend.dart`: temp-write/rename/read/delete/orphan scan.
- `drift/lib/blob/drift_local_blob_store.dart`: LocalBlobStore orchestration and five-state reads.
- `drift/lib/blob/blob_metadata_repository.dart`: transaction-aware metadata/chunk/ref queries.
- `drift/lib/blob/blob_garbage_collector.dart`: staged TTL, cache collection and orphan scan.
- `drift/lib/blob/identity_blob_cipher.dart`: public cipher and resolver assembly.
- `drift/lib/blob/drift_record_blob_unit_of_work.dart`: atomic record/ref adapter.
- `drift/lib/record/drift_record_data_source.dart`: extract transaction-aware record primitive without changing public semantics.
- `drift/test/blob/`: schema, byte backend, store, lifecycle, GC, cipher and UoW tests.
- `drift/test/support/in_memory_blob_gateway.dart`: contract-complete BlobGateway fake.
- `drift/test/blob/in_memory_blob_gateway_test.dart`: ticket, resume, complete gating and cancellation tests.
- `docs/superpowers/specs/2026-08-03-s1d-blob-store-design.md`: decision record updated for v9, UTC scope and residual risks.

## Task 0: Lock Human Decisions Into Tests

**Files:**
- Modify: `openspec/changes/storage-s1d-blobstore/design.md`
- Modify: `tasks/codex-storage-s1d-blobstore.md`

- [ ] Record D1 as final: transfer orchestration calls drift concrete `stageIncomingManifest`; core remains unchanged.
- [ ] Specify `stageIncomingManifest` inputs as trusted local `entityType`, handle and untrusted peer declaration. Derive actual visibility/tier/encryption from `StoragePolicyRegistry.lookup(entityType)` and require `Carrier.blob`.
- [ ] Add mandatory negative scenario: local private policy + peer resource/cache declaration is rejected before any DB/file write.
- [ ] Add mandatory isolation scenario: incomplete staged blobs are invisible to `openRead`, `statusOf`, `sizeOf` and `list`; only transfer recovery may call `presentChunks`.
- [ ] Record D2 as deferred: remove Firebase implementation from this change; S2-blob owns cloud storage and resumable SDK/protocol selection.
- [ ] Run `openspec validate storage-s1d-blobstore` after updating artifacts. Expected: exit 0.
- [ ] Commit: `git commit -am "docs: resolve S1d blob protocol decisions"`.
- [ ] Commit: `git commit -am "docs: lock S1d local-only scope"`.

## Task 1: Restore a Clean Generated-Code Baseline

**Files:**
- Modify: `drift/lib/persistence_drift.g.dart`
- Test: `drift/test/blob/blob_schema_v9_migration_test.dart`

- [ ] Save the intended blob-only generated sections, then restore every tracked `.g.dart` to `main` baseline.
- [ ] Run build runner from `drift/` with the repository-pinned dependency resolution.
- [ ] Inspect every hunk in `persistence_drift.g.dart`; retain only blob table/manager/database registration changes.
- [ ] Run `git diff main -- '*.g.dart' | rg '^-.+REFERENCES'`. Expected: no output and exit 1.
- [ ] Run `git diff --check`. Expected: exit 0.
- [ ] Mutation: delete one known existing `REFERENCES` line in a temporary patch; the command above MUST print it. Restore immediately and rerun to no output.
- [ ] Commit: `git commit -m "chore: isolate blob generated code"`.

## Task 2: Finalize Scoped v9 Schema and Migration Chain

**Files:**
- Modify: `drift/lib/blob/blob_tables.dart`
- Modify: `drift/lib/persistence_drift.dart`
- Test: `drift/test/blob/blob_schema_v9_migration_test.dart`
- Create: `drift/test/blob/blob_schema_v1_to_v9_test.dart`

- [ ] RED: add assertions that all blob keys and queries include `scope_uid`, v8→v9 creates five named indexes, UTC values preserve epoch and `isUtc`, and a v1 fixture upgrades through v9 without data loss.
- [ ] Run `flutter test test/blob/blob_schema_v9_migration_test.dart test/blob/blob_schema_v1_to_v9_test.dart`. Expected: FAIL on missing scoped composite keys/v1 chain.
- [ ] Implement composite keys `(scope_uid, cipher_manifest_id)` and `(scope_uid, owner_record_uuid, cipher_manifest_id)` without editing any `if (from < 8)` branch.
- [ ] GREEN: rerun the two tests. Expected: PASS.
- [ ] Mutation: change `if (from < 9)` to `< 8`; v8→v9 test MUST fail because tables are absent. Restore and rerun PASS.
- [ ] Commit: `git commit -m "feat: finalize scoped blob schema v9"`.

## Task 3: Define the Conditional Byte Backend

**Files:**
- Create: `drift/lib/blob/blob_byte_backend.dart`
- Create: `drift/lib/blob/native.dart`
- Create: `drift/lib/blob/web.dart`
- Create: `drift/lib/blob/unsupported.dart`
- Test: `drift/test/blob/blob_platform_boundary_test.dart`

- [ ] RED: add static tests proving public blob files do not import `dart:io`, native paths never mention external storage/MediaStore/PHPhotoLibrary, and Web throws a named unsupported error.
- [ ] Run `flutter test test/blob/blob_platform_boundary_test.dart`. Expected: FAIL because files do not exist.
- [ ] Add the minimal byte-backend interface and conditional export; isolate `dart:io` to native implementation files.
- [ ] GREEN: rerun test. Expected: PASS.
- [ ] Mutation: add `getExternalStorageDirectory` to native source fixture; static gate MUST fail. Restore.
- [ ] Commit: `git commit -m "feat: add blob byte backend boundary"`.

## Task 4: Implement Atomic Native Chunk Files

**Files:**
- Create: `drift/lib/blob/file_system_blob_byte_backend.dart`
- Test: `drift/test/blob/file_system_blob_byte_backend_test.dart`

- [ ] RED tests: scope/tier path layout; 16KB chunk path; concurrent different-index writes; repeated same-index write; temp file cleanup; file length/hash corruption; orphan enumeration.
- [ ] Run `flutter test test/blob/file_system_blob_byte_backend_test.dart`. Expected: FAIL because backend is absent.
- [ ] Implement temp file → flush → atomic rename, immutable copied bytes, read/delete/list APIs and injected root directory.
- [ ] GREEN: rerun test. Expected: PASS.
- [ ] Mutation: write all indexes to `0.bin`; concurrent test MUST fail. Restore.
- [ ] Commit: `git commit -m "feat: persist blob chunks atomically"`.

## Task 5: Implement Cipher Resolution

**Files:**
- Modify: `drift/lib/blob/identity_blob_cipher.dart`
- Create: `drift/lib/blob/blob_cipher_registry.dart`
- Test: `drift/test/blob/blob_cipher_test.dart`

- [ ] RED tests: await public resolver, copied byte lists, key version validation, private injected cipher, unavailable private key maps to `BlobUndecryptableError`.
- [ ] Run `flutter test test/blob/blob_cipher_test.dart`. Expected: FAIL on private resolution/error mapping.
- [ ] Implement registry-backed async resolver; keep default private path explicit failure, not identity fallback.
- [ ] GREEN: rerun. Expected: PASS.
- [ ] Mutation: route private to identity; private-unavailable test MUST fail. Restore.
- [ ] Commit: `git commit -m "feat: resolve blob ciphers asynchronously"`.

## Task 6: Implement Metadata Repository and Incoming Registration

**Files:**
- Create: `drift/lib/blob/blob_metadata_repository.dart`
- Test: `drift/test/blob/blob_metadata_repository_test.dart`

- [ ] RED tests: scope isolation; registry-derived manifest staging; unregistered/non-blob policy rejection; forged private→resource/cache declaration rejection with zero side effects; chunk upsert; present set; invalid index rejection; duplicate lookup constrained by scope/visibility/cipher/key/tier; last-access UTC.
- [ ] Run the test. Expected: FAIL because repository is absent.
- [ ] Implement transaction-aware CRUD methods with every query constrained by `scopeUid`.
- [ ] GREEN: rerun. Expected: PASS.
- [ ] Mutations: remove one scope predicate; trust peer visibility instead of registry. Cross-scope and forged-declaration tests MUST fail. Restore.
- [ ] Commit: `git commit -m "feat: persist scoped blob metadata"`.

## Task 7: Implement DriftLocalBlobStore

**Files:**
- Create: `drift/lib/blob/drift_local_blob_store.dart`
- Test: `drift/test/blob/drift_local_blob_store_test.dart`

- [ ] RED tests for all LocalBlobStore methods: `putFile`, `put`, `putChunk`, `readCipherChunk`, five completed-blob `openRead` outcomes, `statusOf`, `presentChunks`, `sizeOf`, `list`, `reconcileRefs`, `evictByExternalId`, `evictCache`.
- [ ] Add staged isolation tests: before complete, `openRead/statusOf/sizeOf/list` expose no consumable blob while `presentChunks` reports recovery progress; after complete the same handle becomes visible.
- [ ] Include exact round trip, cross-write dedup, 60% cancel/resume, progress, corrupt length/hash, final plaintext hash, undecryptable mapping and concurrent chunk writes.
- [ ] Run `flutter test test/blob/drift_local_blob_store_test.dart`. Expected: FAIL because adapter is absent.
- [ ] Implement orchestration using byte backend, metadata repository and resolver. Hash/encrypt/decrypt work MUST use `Isolate.run` per chunk/batch.
- [ ] GREEN: rerun. Expected: PASS.
- [ ] Mutations: skip one resumed chunk; expose staged blob to openRead; return complete for partial; map undecryptable to corrupt. Each targeted test MUST fail, then restore.
- [ ] Commit: `git commit -m "feat: implement local blob store"`.

## Task 8: Implement Lifecycle and Garbage Collection

**Files:**
- Create: `drift/lib/blob/blob_garbage_collector.dart`
- Test: `drift/test/blob/blob_lifecycle_gc_test.dart`

- [ ] RED tests: only reconcile promotes staged; idempotent refs; serialized same-owner reconcile; 24h boundary with injected clock; sourceOfTruth zero refs → orphaned and bytes retained; cache zero refs deleted; pinned cache counted unreclaimable; filesystem orphan removed; active temp write ignored.
- [ ] Run the test. Expected: FAIL.
- [ ] Implement serialized reconciliation and `DriftBlobGarbageCollector` with explicit `collect()` API.
- [ ] GREEN: rerun. Expected: PASS.
- [ ] Mutation: let GC scan all tiers; sourceOfTruth negative test MUST fail. Restore.
- [ ] Commit: `git commit -m "feat: add blob lifecycle and tier-safe gc"`.

## Task 9: Implement RecordBlobUnitOfWork

**Files:**
- Modify: `drift/lib/record/drift_record_data_source.dart`
- Create: `drift/lib/blob/drift_record_blob_unit_of_work.dart`
- Create: `drift/test/support/in_memory_record_blob_unit_of_work.dart`
- Test: `drift/test/blob/record_blob_unit_of_work_test.dart`

- [ ] RED tests: save record + search indexes + refs atomically; injected ref failure rolls all back; soft delete + release atomic; wrong scope rejected; fake follows same observable contract.
- [ ] Run the test. Expected: FAIL.
- [ ] Extract `_writeRecordInCurrentTransaction` and `_softDeleteInCurrentTransaction`; public data-source methods retain their existing transaction wrappers.
- [ ] Implement drift UoW with one outer `db.transaction`; do not add outbox behavior not present in current `DriftRecordDataSource`.
- [ ] GREEN: rerun. Expected: PASS.
- [ ] Mutation: remove outer transaction; rollback test MUST fail. Restore.
- [ ] Commit: `git commit -m "feat: commit records and blob refs atomically"`.

## Task 10: Implement In-Memory BlobGateway Fake

**Files:**
- Create: `drift/test/support/in_memory_blob_gateway.dart`
- Test: `drift/test/blob/in_memory_blob_gateway_test.dart`

- [ ] RED tests: begin ticket, random private/public hash object naming, UTC expiry,乱序/repeated chunk writes, `remoteChunks`, complete gating, incomplete upload not downloadable, fresh download ticket per call, delete, cancellation and capabilities.
- [ ] Run `flutter test test/blob/in_memory_blob_gateway_test.dart`. Expected: FAIL because fake is absent.
- [ ] Implement a deterministic in-memory fake with injectable clock/UUID and copied byte lists; no Firebase imports or server simulation beyond the frozen contract.
- [ ] GREEN: rerun. Expected: PASS.
- [ ] Mutations: allow download before complete and cache download tickets; respective tests MUST fail. Restore.
- [ ] Commit: `git commit -m "test: add in-memory blob gateway fake"`.

## Task 11: Mutation Ledger and Documentation

**Files:**
- Modify: `tasks/codex-storage-s1d-blobstore.md`
- Modify: `docs/superpowers/specs/2026-08-03-s1d-blob-store-design.md`
- Create: `docs/storage-s1d-blobstore/mutation-evidence.md`

- [ ] Record every test mutation with test name, injected violation, command, observed red assertion and restored green command.
- [ ] Record UTC scope limitation, Android Auto Backup and macOS entitlement residual risks.
- [ ] Confirm no assertion is inside an un-awaited `.then()` or `.listen()` callback: `rg -n "\.then\(|\.listen\(" core/test drift/test` and manually inspect blob matches.
- [ ] Commit: `git commit -m "test: document blob mutation evidence"`.

## Task 12: Final Verification

**Files:**
- Modify only if a gate exposes a scoped defect.

- [ ] Run `flutter pub get` in `core/` and `drift/`. If pub-cache type errors occur, remove only the ignored package lock for that package and resolve again.
- [ ] Run `(cd core && dart analyze --fatal-infos && flutter test)`.
- [ ] Run `(cd drift && dart analyze --fatal-infos && flutter test)`.
- [ ] Run the repository acceptance command exactly as recorded in the task memo.
- [ ] Run `git diff main -- '*.g.dart' | rg '^-.+REFERENCES'`. Expected: no output.
- [ ] Run `git diff --check`. Expected: exit 0.
- [ ] Update all acceptance checkboxes only from fresh evidence.
- [ ] Commit: `git commit -m "test: verify S1d blob store delivery"`.

## Coverage Map

- A1: Tasks 5, 7, 9, 10, 12; BlobGateway acceptance is satisfied by the explicit in-memory fake, not Firebase production storage.
- A2–A4: Tasks 1–2
- A5: Tasks 1 and 12
- A6: Tasks 3–7
- A7: Task 8
- A8: Task 5
- A9: every task mutation plus Task 11
- A10: Task 12
