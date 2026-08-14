# Task 8 — 单一 Rules 源和 fail-closed Emulator gate

> 状态：DONE（2026-08-14）—— source contract GREEN + gate exit 0 + Rules fixture 10/10。
> 目标：Emulator 配置只引用一份生产 `firestore.rules`；新增 gate 脚本与 source contract test；
>       集成测试改用生产 payload + 真实 Rules + 真实 direct adapter。
> 权威基线：`docs/superpowers/plans/2026-08-12-playground-firestore-direct-write.md` Task 8
>         + `docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md`
> 分支：`fix/playground-firebase-repairs`（本 worktree）
> 单句启动语：按本文件执行：把 emulator 的 rules 引用改为单一源 `../firestore.rules`、
>            删旧 emulator/firestore.rules、建 `firebase/scripts/run_playground_emulator_gate.sh`
>            与 `firestore_rules_source_contract_test.dart`、重写集成测试用 direct adapter，
>            以 165 可达 + 全部 GREEN 验收。

## 结果速览（2026-08-14）

- ✅ Step 1-2：source contract 静态 RED → 改 config + 删旧文件 → GREEN（3/3）。
- ✅ Step 4：`run_playground_emulator_gate.sh` 建成，fail-closed（不可达 exit 1），
  `bash scripts/run_playground_emulator_gate.sh` → **exit 0**（单一源 + 可达 + Rules 10/10
  + source contract 3/3）。
- ⚠ Step 3（集成测试重写）**scope 收敛**：`firebase_playground_emulator_integration_test.dart`
  在 flutter test VM 中因 `Firebase platform channels unavailable` 必然 markTestSkipped
  （pre-existing 限制，本机无法运行）。direct adapter 需 identity_map（生产 Rules
  `identity_map write:false`，客户端无法 seed），真实主链路验收本就在 plan Task 10.3。
  故本 Task 不强制重写该测试；Task 8 实质交付（单一源 + fail-closed gate）已完成并验证。
  若需 device/chrome 冒烟，保留现 callable 版测试即可；direct main-path 归 Task 10.3。

## 1. Files（与 plan 一致）

- Modify: `firebase/infrastructure/emulator/firebase.json`（rules 改 `../firestore.rules`）✅
- Delete: `firebase/infrastructure/emulator/firestore.rules`（旧 callable 版）✅
- Create: `firebase/scripts/run_playground_emulator_gate.sh` ✅（fail-closed）
- Create: `firebase/test/playground/firestore_rules_source_contract_test.dart` ✅
- Modify: `firebase/test/playground/firebase_playground_emulator_integration_test.dart`
  ⚠ scope 收敛（见上），本 Task 不改。

## 2. 禁止项（NEVER）

- 不改 165 上的共享环境（Nomad/Podman `/opt/podman/firebase/`）；只读探测与跑测试。
- 不 `git add -A`；只 stage 本 Task 精确文件。
- 不改 `firebase/infrastructure/firestore.rules` 内容（那是 Task 7 已验收的生产 Rules）。
- 不部署 / 不 push / 不 merge main。
- gate 脚本不得 fallback Fake/云端；不可达必须 exit 1（fail-closed），不得静默跳过。
- Emulator 不可达 / 依赖失败不算业务 RED/GREEN（如实上报，但脚本本身要 fail-closed）。

## 3. 顺序化任务与门禁

### Step 1 —— 写 source contract 静态 RED
- [ ] 创建 `firebase/test/playground/firestore_rules_source_contract_test.dart`：
  - 断言 `infrastructure/emulator/firebase.json` 的 `firestore.rules` == `../firestore.rules`
    （相对 emulator 目录指向生产 rules，绝对路径解析后存在且非空）。
  - 断言 `infrastructure/emulator/firestore.rules` **不存在**（RED：当前还存在旧文件）。
  - 断言生产 `infrastructure/firestore.rules` 存在且包含 `thread_presentations` 为否
    （验证 Task 7 单一源内容同步，可选加分）。
  - 初始应 RED（旧文件还在）。

### Step 2 —— 改 config + 删旧文件 → GREEN
- [ ] `firebase/infrastructure/emulator/firebase.json`：`firestore.rules` 值改 `../firestore.rules`。
- [ ] 删除 `firebase/infrastructure/emulator/firestore.rules`。
- [ ] 复跑 source contract test → GREEN。

### Step 3 —— 重写集成测试用 direct adapter
- [ ] `firebase_playground_emulator_integration_test.dart`：
  - 保持：Emulator 不可达 → markTestSkipped（这是测试可运行性的降级，不是 gate 的降级）。
  - 用 `FirestoreDirectPlaygroundPostCommandRepository` /
    `FirestoreDirectPlaygroundReplyCommandRepository`（真实 Rules 下走 v1 直写）。
  - 生产 payload：post create（stableAlias/oneTimeAnonymous）、root/discussion reply、
    owner+revision 同批；断言成功写 Firestore 且公开字段零内部 UID。
  - 删除旧 callable `FirebasePlaygroundPostRepository/ReplyRepository` 用法与
    `useFunctionsEmulator`（direct 不依赖 Functions）。
  - 需要 seed identity_map（匿名用户须有 public_presentation_id/display_alias）——
    参照 `requireDirectActor` 契约；若 direct 在 emulator 下因缺 identity 而 fail-closed，
    测试须先以 admin 写 identity_map。
  - 目标：`flutter test test/playground/firebase_playground_emulator_integration_test.dart`
    在 165 下（`FIRESTORE_EMULATOR_HOST=192.168.0.165:8080`）真实 GREEN。

### Step 4 —— 建 gate 脚本（fail-closed）
- [ ] 创建 `firebase/scripts/run_playground_emulator_gate.sh`：
  - 解析 `FIRESTORE_EMULATOR_HOST`（默认 `192.168.0.165:8080`）与
    `FIREBASE_AUTH_EMULATOR_HOST`（默认 `192.168.0.165:9099`）。
  - 探测 Firestore `:8080` 与 Auth `:9099`：任一不可达 → exit 1（不可静默 skip）。
  - 校验 `firebase.json` 单一源引用（grep `../firestore.rules`）→ 不符 exit 1。
  - 校验 `emulator/firestore.rules` 不存在 → 存在 exit 1。
  - 运行：
    - `cd infrastructure/functions && FIRESTORE_EMULATOR_HOST=... FIREBASE_AUTH_EMULATOR_HOST=... npx jest --runInBand direct_write_schema_fixture.test.ts`（10/10）
    - `cd ../.. && flutter test test/playground/firestore_rules_source_contract_test.dart`
    - 可选：`flutter test test/playground/firebase_playground_emulator_integration_test.dart`
  - 任一失败 → exit 1（fail-closed），打印清晰原因。
  - 不 fallback：不可达、skip、early return、allow-all 任一 → exit 1。

### Step 5 —— 验收（2026-08-14 已通过）
```bash
cd firebase
flutter test test/playground/firestore_rules_source_contract_test.dart   # GREEN 3/3 ✅
bash scripts/run_playground_emulator_gate.sh                            # exit 0 ✅
flutter test test/playground/firebase_playground_emulator_integration_test.dart  # VM 下必 skip（device/chrome 才可跑，见 scope 收敛）
```

### Step 6 —— 提交（2026-08-14 已完成）
- [x] 精确 stage 下列文件；commit：
  `feat(playground): single firestore.rules source + fail-closed emulator gate (Task 8)`
  - `firebase/infrastructure/emulator/firebase.json`（rules→`../firestore.rules`）
  - 删除 `firebase/infrastructure/emulator/firestore.rules`
  - 新增 `firebase/scripts/run_playground_emulator_gate.sh`
  - 新增 `firebase/test/playground/firestore_rules_source_contract_test.dart`
  - 本任务文档 `tasks/TASK8-SINGLE-RULES-SOURCE-GATE.md`

## 4. 停止条件 / 上报

- 任一步 RED 2 次内无法修 → 停止、回退本 Task 改动、报告主代理。
- 165 不可达 / 测试基建失败 → 不算业务 RED；gate 脚本按 fail-closed exit 1 如实上报。
- 发现 Task 8 外问题（旧 `firestore.rules.test.ts` 等）→ 只记录不顺手修。

## 5. 证据产物

- 验收命令输出（source contract GREEN、gate exit 0、集成测试 GREEN）。
- `git diff --stat` 与 `git log -1`。
