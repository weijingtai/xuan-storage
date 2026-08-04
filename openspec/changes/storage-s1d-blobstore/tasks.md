## 0. Decision Gates

- [ ] 0.1 Resolve D1 incoming manifest registration before first `putChunk`
- [ ] 0.2 Resolve D2 Firebase upload-ticket server protocol

## 1. Database Safety

- [ ] 1.1 Restore generated files and prove zero deleted `REFERENCES`
- [ ] 1.2 Finalize scope-aware v9 tables and indexes
- [ ] 1.3 Add fresh, v8→v9, v1→v9, UTC and old-data migration tests

## 2. Local Byte Persistence

- [ ] 2.1 Add native/web/unsupported conditional byte backend
- [ ] 2.2 Implement atomic native chunk files and corruption checks
- [ ] 2.3 Implement scoped metadata repository and incoming registration
- [ ] 2.4 Implement all LocalBlobStore methods and five read outcomes

## 3. Cipher and Lifecycle

- [ ] 3.1 Implement async identity/private cipher registry behavior
- [ ] 3.2 Implement staged/committed/orphaned transitions and serialized refs
- [ ] 3.3 Implement tier-safe GC and filesystem orphan collection

## 4. Atomic Record Writes

- [ ] 4.1 Extract transaction-aware record write/delete primitives
- [ ] 4.2 Implement drift RecordBlobUnitOfWork and contract-equivalent fake
- [ ] 4.3 Prove rollback and idempotency with injected failures

## 5. Remote Gateway

- [ ] 5.1 Define D2-approved BlobGateway server client
- [ ] 5.2 Implement Firebase adapter, timeout, cancellation and error mapping
- [ ] 5.3 Prove resume, complete, fresh download tickets and deletion

## 6. Evidence and Gates

- [ ] 6.1 Complete per-test mutation ledger
- [ ] 6.2 Run core, drift and firebase fatal analysis/tests
- [ ] 6.3 Run repository gates and generated foreign-key protection check
