# S1d Blob Crypto Isolate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move blob hashing and cryptographic work out of the UI isolate while preserving streaming, cancellation, staged visibility, resumability, and transaction boundaries.

**Architecture:** Keep file I/O, Drift metadata, staged/committed state, and transaction orchestration in the caller isolate. Add a long-lived crypto worker isolate that receives serializable chunk commands and returns digests or encrypted/decrypted bytes. Use one worker per `DriftLocalBlobStore` (or an injectable pool later), with request IDs, typed errors, cancellation, and an explicit shutdown path.

**Tech Stack:** Dart isolates (`Isolate.spawn`, `SendPort`, `ReceivePort`), Flutter tests, `crypto`, existing `BlobCipher`/`BlobCipherResolver`, Drift, `CancellationToken`.

---

## 1. Background and problem statement

The current S1d implementation performs `readAsBytes()`, whole-input buffering, SHA-256, and cipher operations in the caller isolate. This is functionally correct for small blobs but violates the `LocalBlobStore` contract: large media can block UI scheduling and consume several copies of the plaintext/ciphertext in memory.

The fix must not move database handles, file handles, `BlobMetadataRepository`, or resolver instances across isolates. Those objects are not generally transferable and moving them would break Drift transaction ownership. The isolate boundary therefore belongs around pure CPU operations only.

The implementation must also avoid creating a new isolate for every 16 KiB chunk. Per-chunk `Isolate.run` calls would add scheduling and serialization overhead that can exceed the hashing/encryption work. A persistent worker protocol is the default design.

## 2. Scope and non-goals

### In scope

- SHA-256 calculation for plaintext and ciphertext chunks.
- `encryptChunk` and `decryptChunk` execution in a worker isolate.
- Bounded chunk pipeline so only a small number of chunks are buffered.
- Cancellation, worker failure propagation, and deterministic worker shutdown.
- Tests proving CPU work is delegated and blob behavior remains unchanged.

### Out of scope

- Moving Drift or filesystem I/O into an isolate.
- Changing `BlobHandle`, `BlobCipher`, `LocalBlobStore`, or database schema contracts.
- Implementing a Firebase/cloud gateway.
- Passing raw private keys through ordinary isolate messages.
- Building a general-purpose isolate pool before profiling demonstrates a need.

## 3. File map and responsibilities

### Files to create

- `drift/lib/blob/blob_crypto_protocol.dart`
  - Immutable serializable command/result DTOs.
  - Operation IDs, chunk indexes, key versions, and typed error envelopes.
- `drift/lib/blob/blob_crypto_worker.dart`
  - Top-level isolate entrypoint and command loop.
  - CPU-only SHA-256/encrypt/decrypt dispatch.
- `drift/lib/blob/blob_crypto_client.dart`
  - Caller-isolate client managing `ReceivePort`, pending requests, cancellation, and shutdown.
- `drift/test/blob/blob_crypto_worker_test.dart`
  - Worker protocol, delegation, error, cancellation, and lifecycle tests.
- `drift/test/blob/blob_crypto_large_input_test.dart`
  - Bounded-memory/chunk-pipeline behavior and large-input regression coverage.

### Files to modify

- `drift/lib/blob/drift_local_blob_store.dart`
  - Replace direct SHA-256/cipher calls with `BlobCryptoClient` calls.
  - Stream input into bounded chunks instead of buffering the entire input.
  - Keep backend writes and metadata updates in the caller isolate.
  - Dispose the crypto client when the store is closed or explicitly disposed.
- `drift/lib/blob/blob_cipher_registry.dart`
  - Expose a worker-safe cipher descriptor/factory, not a Drift-bound resolver.
  - Keep key lookup and private-key ownership inside the worker initialization path.
- `drift/lib/blob/identity_blob_cipher.dart`
  - Add worker-side identity operations through the protocol.
- `drift/lib/persistence_drift.dart`
  - Export the new public implementation types only if package consumers need them.
- `drift/test/blob/drift_local_blob_store_test.dart`
  - Add tests for cancellation during hashing/encryption and unchanged round trips.
- `drift/pubspec.yaml`
  - Only modify if a worker-safe crypto dependency is required; do not add a dependency for isolate orchestration.

## 4. Protocol design

Use explicit DTOs rather than sending closures or arbitrary cipher objects.

```dart
sealed class BlobCryptoCommand {
  const BlobCryptoCommand(this.requestId);
  final int requestId;
}

final class HashChunkCommand extends BlobCryptoCommand {
  const HashChunkCommand(super.requestId, this.bytes);
  final Uint8List bytes;
}

final class EncryptChunkCommand extends BlobCryptoCommand {
  const EncryptChunkCommand(
    super.requestId,
    this.bytes,
    this.chunkIndex,
    this.keyVersion,
    this.cipherDescriptor,
  );
  final Uint8List bytes;
  final int chunkIndex;
  final int keyVersion;
  final WorkerCipherDescriptor cipherDescriptor;
}
```

The actual code may use maps if Dart version constraints make sealed DTO transfer inconvenient, but every command must have a fixed `type`, `requestId`, and typed payload. Results must distinguish success, cancellation, and worker/cipher failure. No database object or `BlobCipherResolver` instance may cross the boundary.

For private ciphers, the worker receives a worker-safe descriptor or initializes a worker-local key provider. If the existing private cipher cannot be made worker-safe without exposing key material, keep private operations rejected with `BlobUndecryptableError` until a secure worker key provider is designed; never silently fall back to identity encryption.

## 5. Implementation tasks

### Task 1: Freeze current behavior with red tests

**Files:**
- Modify: `drift/test/blob/drift_local_blob_store_test.dart`
- Create: `drift/test/blob/blob_crypto_large_input_test.dart`

- [ ] Add a test that writes at least 2 MiB in multiple chunks, commits refs, reads it back, and compares every byte.
- [ ] Add a test that cancels during a multi-chunk operation and verifies already-written chunks remain resumable.
- [ ] Add a test seam (`BlobCryptoClient` factory/injection) that records whether worker requests were used.
- [ ] Run the tests before implementation and confirm the delegation test fails.

Run:

```bash
cd drift
flutter test test/blob/drift_local_blob_store_test.dart test/blob/blob_crypto_large_input_test.dart
```

### Task 2: Add the serializable protocol

**Files:**
- Create: `drift/lib/blob/blob_crypto_protocol.dart`
- Create: `drift/test/blob/blob_crypto_worker_test.dart`

- [ ] Define hash, encrypt, decrypt, cancel, and shutdown command shapes.
- [ ] Define success/error/cancel result shapes with request IDs.
- [ ] Add round-trip tests for all DTO fields, especially chunk index and key version.
- [ ] Add a test that malformed/unknown commands produce a typed protocol error rather than hanging.

### Task 3: Implement the long-lived worker

**Files:**
- Create: `drift/lib/blob/blob_crypto_worker.dart`
- Modify: `drift/lib/blob/identity_blob_cipher.dart`

- [ ] Implement a top-level `blobCryptoIsolateMain(SendPort bootstrapPort)` entrypoint.
- [ ] Process one command at a time and always return the same `requestId`.
- [ ] Implement SHA-256 in the worker.
- [ ] Implement identity encrypt/decrypt in the worker.
- [ ] Map cipher failures to serializable error envelopes.
- [ ] Ensure shutdown closes the command receive port and sends an acknowledgement.
- [ ] Add worker-only tests for hash equality, identity round trip, malformed command, and shutdown.

### Task 4: Implement the caller-isolate client

**Files:**
- Create: `drift/lib/blob/blob_crypto_client.dart`
- Modify: `drift/lib/blob/blob_crypto_protocol.dart`

- [ ] Spawn one worker lazily on the first request.
- [ ] Maintain `Map<int, Completer<BlobCryptoResult>> pending` keyed by request ID.
- [ ] Transfer `Uint8List` payloads using `TransferableTypedData` where supported; otherwise use immutable byte lists.
- [ ] On cancellation, send a cancel command and complete the pending request with the existing cancellation error.
- [ ] On worker exit/error, fail all pending requests and prevent new requests until a new client is created.
- [ ] Make `close()` idempotent and await worker shutdown.
- [ ] Add tests for concurrent requests, out-of-order replies, cancellation, worker error, and repeated close.

### Task 5: Add bounded streaming to `DriftLocalBlobStore`

**Files:**
- Modify: `drift/lib/blob/drift_local_blob_store.dart`
- Modify: `drift/test/blob/drift_local_blob_store_test.dart`

- [ ] Replace whole-stream accumulation in `put()` with a bounded chunk accumulator of `blobChunkSize`.
- [ ] Send each chunk to the crypto client, then write the returned ciphertext and metadata before reading the next chunk, or use a bounded in-flight window of 2–4 chunks after profiling.
- [ ] Compute the overall plaintext digest through the worker incrementally or through a worker-side digest session; do not concatenate the entire plaintext solely to hash it.
- [ ] Preserve cancellation semantics: stop accepting input, keep completed chunks, leave metadata staged.
- [ ] Preserve `expectedBytes` validation and throw a typed storage error on mismatch.
- [ ] Update `putFile()` to read through the same bounded pipeline rather than `readAsBytes()`.
- [ ] Keep filesystem and Drift writes in the caller isolate.

### Task 6: Move decrypt/verification into the worker

**Files:**
- Modify: `drift/lib/blob/drift_local_blob_store.dart`
- Modify: `drift/lib/blob/blob_cipher_registry.dart`
- Modify: `drift/test/blob/drift_local_blob_store_test.dart`

- [ ] Read each ciphertext chunk in the caller isolate and request hash/decrypt from the worker.
- [ ] Compare stored chunk SHA-256 against the worker-produced digest before decrypting or before yielding plaintext.
- [ ] Return `BlobCorrupt` with exact chunk indexes for mismatches.
- [ ] Keep `BlobReadResult` streaming behavior and cancellation unchanged.
- [ ] Add a test that corrupts one chunk and proves the worker path returns only that index.

### Task 7: Make cipher resolution worker-safe

**Files:**
- Modify: `drift/lib/blob/blob_cipher_registry.dart`
- Modify: `drift/lib/blob/blob_crypto_worker.dart`
- Modify: `drift/test/blob/blob_cipher_test.dart`

- [ ] Define a `WorkerCipherDescriptor` containing only serializable algorithm/key-version identifiers.
- [ ] Keep key retrieval inside worker initialization; do not send `BlobCipher` objects or database handles.
- [ ] For identity/public blobs, use a stateless descriptor.
- [ ] For private blobs, either provide a worker-local key provider or explicitly return `BlobUndecryptableError` with a documented capability check.
- [ ] Add a negative test proving private unavailable keys never degrade to identity.

### Task 8: Add lifecycle and leak tests

**Files:**
- Create/modify: `drift/test/blob/blob_crypto_worker_test.dart`
- Modify: `drift/test/blob/drift_local_blob_store_test.dart`

- [ ] Verify no pending request remains after success, cancellation, worker failure, or close.
- [ ] Verify a second operation after worker failure returns a deterministic error.
- [ ] Verify `close()` can be called twice.
- [ ] Verify repeated store construction/disposal does not leave worker ports alive.

### Task 9: Run the complete validation gates

- [ ] Run `dart format` on changed Dart files.
- [ ] Run `dart analyze --fatal-infos` for the new implementation files.
- [ ] Run all blob tests.
- [ ] Run core and drift test suites.
- [ ] Run repository analyze/convention gates.
- [ ] Run `git diff --check` and the generated-file `REFERENCES` deletion check.
- [ ] Record timings and peak-memory observations for a small input and a multi-megabyte input.

Expected final command set:

```bash
bash scripts/run_s1a_analyze_gate.sh
bash scripts/run_s1b_analyze_gate.sh
bash scripts/run_monorepo_convention_check.sh
(cd core && flutter test)
(cd drift && flutter test)
```

## 6. Acceptance criteria

- No SHA-256, encryption, or decryption for blob payloads executes in the caller/UI isolate.
- `putFile()` and `put()` do not load the full input into one `List<int>`.
- At most the configured bounded number of chunks is in flight.
- Cancellation preserves completed chunks and leaves the manifest staged.
- Worker failure fails all pending operations and never hangs a caller future.
- Blob round trips, corruption reporting, staged isolation, GC, and UoW rollback remain green.
- Private cipher failures remain undecryptable; no identity fallback is introduced.
- Worker lifecycle is leak-free under repeated create/use/close cycles.

## 7. Risks and decisions requiring confirmation

1. **Private-key handling:** If the current cipher implementation cannot be initialized inside an isolate without exposing key material, implement identity/public worker support first and keep private worker operations explicitly unavailable until a secure key-provider boundary is approved.
2. **Worker count:** Start with one worker per store. Introduce a shared pool only after profiling shows queue latency is material.
3. **TransferableTypedData:** Use it as an optimization, not a correctness dependency; provide a normal `Uint8List` fallback for supported Dart/Flutter targets.
4. **Web:** The current S1d scope excludes Web blob delivery. Keep the protocol platform-neutral, but do not claim Web support until a Web worker implementation is separately tested.

