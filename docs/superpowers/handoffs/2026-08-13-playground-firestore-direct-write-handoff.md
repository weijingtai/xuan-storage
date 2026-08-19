# Handoff Envelope — Playground Firestore Direct Write (interrupted mid-run)

> Status: **IN PROGRESS — handoff due to agent tool-iteration budget** (not a failure).
> Plan: `docs/superpowers/plans/2026-08-12-playground-firestore-direct-write.md`
> Design: `docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md`
> Worktree: `xuan-storage/.worktrees/playground-firebase-repairs` on `fix/playground-firebase-repairs`

## What is DONE (committed to `fix/playground-firebase-repairs`)

- **Task 0** (prior session): RI merged to remote main `0841e19`; storage/shell pinned same ref.
- **Task 1** (prior session): identity schema convergence — snake_case + public_presentation_id/display_alias.
- **Task 1 cleanup** (`3d8281d`): fixed 4 legacy tests broken by the resolver signature change
  (dropped `functions:` param; seeded identity_map presentation fields where resolveActor runs).
  This was the blocker that stalled the prior session. All test/playground now compiles.
- **Task 2** (`f1fc2d5`): direct-write command support.
  - `firebase/test/playground/fixtures/direct_write_schema_v1.json` (schema single source of truth)
  - `firebase/lib/playground/firestore_direct_playground_command_support.dart`
    (`requireDirectActor`, `canonicalJsonHash`, `deterministicCreateId`, `directPlaygroundError`,
    owner/presentation payload split, oneTimeAnonymous presentation payload)
  - `firebase/test/playground/firestore_direct_playground_command_support_test.dart` — **11 tests GREEN**;
    `firebase_playground_idempotency_test.dart` regression GREEN; `dart analyze` on support file clean.

## What REMAINS (next agent starting point: **Task 3**)

Follow plan strictly, TDD (RED → GREEN per slice), keep commits per task/repo.

- **Task 3**: `firestore_direct_playground_post_command_repository.dart` (+ test) —
  transaction creates `playground_posts/{id}` + `playground_post_owners/{id}` + `revisions/r0000000001`;
  edit appends contiguous revision; tombstone appends final revision then clears text/attachments/techniques.
  Modify `firebase_playground_reply_post_payload_contract_test.dart`.
  Do NOT import `cloud_functions`. Replay idempotency + conflict + privacy fail-closed.
- **Task 4**: `firestore_direct_playground_reply_command_repository.dart` (+ test) — root/discussion,
  depth 0/1, thread-presentation one-time mapping (`{postId}__{uid}` random 128-bit), cross-post/cross-root/
  negative depth/3rd-level/tombstone-target rejection.
- **Task 5**: engagement (`like`/`bookmark`), verification, outcome-feedback repositories (+ tests).
  Verify→revoke→reverify; feedback publish→edit→revoke→republish; Poster-only; zero outbox/notification/callable.
- **Task 6**: update feed/thread query repositories to read v1 schema; real detail counts (replyCount=2,
  likeCount=3, verificationCount=1, aggregateReadCount=3); Feed placeholder counts NOT rendered; create
  Shell tests `feed_count_visibility_test.dart` + `post_detail_viewer_capability_test.dart`.
- **Task 7**: production `firestore.rules` + `firestore.indexes.json` (delete old likes composite;
  6 current-phase composites) + rules/fixture tests + mutation validation.
- **Task 8**: single Rules source (emulator firebase.json → ../firestore.rules, delete old emulator
  firestore.rules) + `run_playground_emulator_gate.sh` + rules-source contract test.
- **Task 9**: export from `playground.dart`; Shell bootstrap + `PostDetailViewModel` capability
  (`detail.viewerState.isOwner` only, buttons by canEdit/canDelete/canSetFeedback/canVerify).
- **Task 10**: full gates (storage test/analyze, shell focused, dependency resolved-ref, real main path
  in production-Rules Emulator, zero skip/allow-all).

## Key design constraints (do not violate)

- Public post/reply docs: NO provider_uid/app_user_id/author_* keys (fixture asserts this).
- Owner/thread-presentation deny-by-default; owner get-only, no list.
- revision IDs `r0000000001`+; append-only; tombstone clears public body.
- create IDs: `sha256(v1|op|authUid|key)`; payload hash canonical (order-independent), no time fields.
- Errors: stable machineCode per Design §9 table (e.g. `idempotency/payload-conflict` → `conflict`).
- Privacy fields non-empty → `privacy/storage-unavailable` BEFORE any Firestore call.
- Callable source stays, but direct adapters MUST NOT import/use `cloud_functions`.
- Emulator unreachable / dependency-resolve failures are NOT business RED/GREEN.
- Current branch is correct: `fix/playground-firebase-repairs` (never edit main).

## Key files to reference

- `firebase/lib/playground/firestore_direct_playground_command_support.dart` (helpers ready for Task 3-5)
- `firebase/test/playground/firestore_direct_playground_command_support_test.dart` (pattern for support tests)
- RI ports under `repository-interface-playground/.worktrees/playground-ri-completion/lib/src/`
  (PublicPost, PublicReply, viewerState, errors, typed IDs — read via `bash cat`, read tool is cwd-restricted)
- `firebase/test/playground/firebase_playground_reply_post_payload_contract_test.dart` (Task 3 modify target)

## Git state

- storage worktree: `fix/playground-firebase-repairs`, clean (all committed).
- Shell worktree has user dirty files — NEVER `git add -A`; stage only exact Task files.
- Each repo commits independently; do NOT merge/push main or deploy.
