# S5a Theme Plan Engineering Review, Round 2

- Review mode: gStack `plan-eng-review`
- Scope: `docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md` and `tasks/mimo-storage-s5a-theme.md`
- Review date: 2026-08-03
- Verdict: **PASS-WITH-REVISIONS**

## Executive Verdict

Round 1 blockers are substantially addressed: the plan now explicitly chooses contract plus reference implementation, closes the five pre-ACT decisions, adds a baseline stop condition, specifies the registry file/function/idempotence policy, defines a deterministic merge algorithm, hardens the grep/fixture gates, maps the OpenSpec SHALL clauses, corrects the 20-file and 203-byte facts, and separates S1b contract independence from later sync delivery.

The plan is close enough to translate into ACT, but four P1 issues remain. They do not invalidate the architecture, yet they leave mechanical executors to invent API signatures or to write tests that cannot drive the stated behavior. Resolve these before execution starts.

## Findings

| Severity | Location | Finding | Evidence and required revision |
|---|---|---|---|
| P1 | [design.md:1039-1040](/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:1039) and [tasks.md:120-125](/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/tasks/mimo-storage-s5a-theme.md:120) | A14c/A14d/A14e are not executable against the declared reference surface. | A14d says an invalid numeric value is passed through to `token_loader.dart:88`, but the S5a reference input is only flattened `Map<String,dynamic>` ([design.md:864-880](/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:864)); no parser adapter, diagnostics type, or `ConfigException` propagation API is specified. A14b likewise requires install-time version rejection, but `ThemeResourceStore.install()` is only a broad port signature ([design.md:564-584](/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:564)) and the reference algorithm §6.6 contains no manifest/version-validation procedure. Add an explicit reference validator/parser boundary, input type, failure/diagnostic oracle, and the exact test fixture for A14b/d/e, or narrow these standards to a later installer task. |
| P1 | [design.md:1022-1025](/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:1022) and [tasks.md:147-153](/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/tasks/mimo-storage-s5a-theme.md:147) | P3/P4/P6 name test doubles but do not define injectable port signatures or the state transition they observe. | `_CountingHttpClient`, `_CountingBlobStore`, `localTokenReadCount`, and the never-completing `install()` dependency are not types or members in §5.3/§11. The plan says reference is zero IO ([design.md:42-47](/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:42)), so a mechanical executor cannot know whether these are constructor arguments, callbacks, test-only ports, or unused spies. Add the exact constructor signature and a small test-only `ThemeLocalReader`/`ThemeDownloadProbe`/install-future hook, including which call increments each counter and how an in-flight install coexists with `resolve()`. |
| P1 | [design.md:1087](/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:1087) and [design.md:1109-1121](/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:1109) | The chosen signature scheme has no actual contract hook in the file-level deliverables. | §9.1 says the contract must retain a `verifySignature` hook, but the six contract files and two reference files listed in §11 contain no `ThemeSignatureVerifier`, signature result type, or method/field carrying that hook. The only concrete verifier lives in the external `xuan_config` worktree ([config_signature.dart:17-29](/Users/jingtaiwei/Git/Public/xuan-migration/xuan_config/.worktrees/mimo-config-s5c-remote-source/lib/src/bootstrap/config_signature.dart:17)). Add the exact S5a-owned adapter interface and its dependency direction, or explicitly defer the hook and remove “must retain” from the decision. |
| P1 | [design.md:1080-1088](/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:1080) and [tasks.md:38-46](/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/tasks/mimo-storage-s5a-theme.md:38) | “Bundled authority is `theme/config/presets/default.yaml`” is a decision, but the ACT scope simultaneously forbids the required cross-repository migration and gives the reference store no bundled-source input contract. | The task says all S5a outputs are core/reference and theme is untouched ([tasks.md:31-46](/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/tasks/mimo-storage-s5a-theme.md:31)); the design says the theme repository file is the sole authority while shell’s 203-byte asset is deprecated ([design.md:1084-1088](/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:1084)). Define the reference fixture/provider as an injected already-parsed bundled map and state that source migration is explicitly out of ACT, otherwise an executor may try to import or copy a file from another repository. |

## Checks Passed

### Prior P0/P1 Corrections

- Contract versus behavior scope is now explicit: contract files under `core/lib/model`, reference implementation under `core/lib/reference` ([design.md:27-51](/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:27)).
- The five formerly open decisions are closed: leaf-plus-atomic-group completion, independent light/dark keys, orphan retention, Ed25519 direction, and bundled authority ([design.md:1080-1088](/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:1080)).
- Baseline failure is converted to a first-step stop condition and the task names local `main` commit `16987fe` ([tasks.md:48-69](/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/tasks/mimo-storage-s5a-theme.md:48)).
- Registry registration now has a precise file, function, timing, constants, and idempotence rule ([design.md:735-781](/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:735)).
- A3 has a six-file coverage lower bound and excludes the reference directory ([tasks.md:84-87](/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/tasks/mimo-storage-s5a-theme.md:84)).
- P1 now has a non-empty fixture, warm-up, benchmark/non-blocking CI policy, and a 5 ms threshold ([design.md:1006-1021](/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:1006)).
- P3/P4 include positive controls; P6 has a concrete 50 ms budget ([design.md:1022-1026](/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:1022)).
- The OpenSpec mapping now includes missing-field fallback, numeric error handling, no direct YAML dependency, Canvas stop/ownership, and executable-plan gating ([design.md:1033-1047](/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:1033)).
- The `config_repository.dart:8` argument is now correctly labeled an architectural decision rather than source-proven fact ([design.md:1049-1065](/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:1049)).
- The S1b claim is now correctly split between contract/reference independence and later drift/outbox sync delivery ([design.md:179-189](/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:179)).
- The factual corrections are present: 20 theme Dart files and 203-byte shell YAML ([design.md:74-91](/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:74)).

### Independent Evidence Recheck

- The cited loader lines remain true: `token_loader.dart:11`, `:15`, `:24`, `:29`, `:32`, `:88`, `:289`, `:292`, and `:303` match the source.
- `xuan_theme_data.dart:20/:32`, `xuan_theme_scope.dart:25`, and `component_style.dart:102-106` remain true.
- `config_repository.dart:8/:10`, remote repository `:84-87`, and `shell_theme_loader.dart:41` remain true.
- The four preset component counts remain 16/14/15/15; the shell asset remains a 203-byte version-1 empty shell; `theme/lib` has 20 Dart files and the specified IO grep is empty.
- `preferences` still has no `OutboxStore|SyncPeer|RemoteGateway` matches, and `StoragePolicyRegistry` still has no production call site in the pre-S5a source.
- The cited architecture-outline lines 162, 167, 170, 586, 1080, 1302, 1507, 1513, and 1583 continue to support the stated upstream context.
- `ConfigBootstrap.endpoints`, `allowedHostSuffixes`, and `l0PublicKeyBase64` remain placeholders in S5c, so the “real download integration blocked, contract/reference not blocked” distinction is valid.

## Mechanical ACT Readiness

| Area | Result | Reason |
|---|---|---|
| Architecture and ownership | Pass | Scope, layer boundaries, stop conditions, and S1b distinction are now explicit. |
| Merge semantics | Pass with revision | §6.6 is sufficiently deterministic, including null-hit, orphan, atomic-group, ordering, cache-key, and immutability rules. |
| Acceptance oracle | Pass with revision | A3/A8/A15/A16 and most performance gates are materially stronger; A14 and P3/P4/P6 still need concrete injectable types and state transitions. |
| External contract alignment | Pass with revision | SHALL mapping is complete at the document level; signature hook is referenced but not represented in the deliverable API. |
| Baseline and dependencies | Pass | The target baseline prerequisite and ConfigBootstrap stop condition are explicit. |

## Required Revisions Before ACT

1. Add the exact reference validator/parser and diagnostics boundary for A14b/A14d/A14e, or move those cases to the later installer/parser task.
2. Add exact test-only interfaces/constructor parameters for the HTTP, blob, local-read, and pending-install probes used by P3/P4/P6.
3. Add the S5a signature-verifier adapter type and file, or remove the claim that the contract retains a `verifySignature` hook.
4. Define the bundled-map fixture/provider injected into the reference store and explicitly state that cross-repository source migration is out of ACT.

After these four edits, the plan is suitable for `wjt-act` translation. No code or plan documents were modified during this review.
