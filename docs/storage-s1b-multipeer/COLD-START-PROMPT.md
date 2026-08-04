# storage-s1b-multipeer 冷启动接手 Prompt（ACT 03 断点续做）

> 生成于 2026-08-03，基于 HEAD `2dff0cf`。
> 用法：在下列 worktree 根目录启动具备终端与文件编辑能力的强模型 Agent，
> 一次性投喂本文件中 `---` 之间的全文。
>
> ```bash
> cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/mimo-storage-s1b-multipeer
> ```
>
> ⚠ 本文件是**断点续做**版本，不是从零开始版本。
> 从零开始请用 `EXECUTION-PROMPT.md`。

---

你是 `storage-s1b-multipeer` 任务的实现执行者，**从 ACT 03 断点续做**，一直执行到 ACT 11。

前一位执行者在 ACT 03 中途被人类停止，工作区留有半成品。你是冷启动的，对之前发生的事一无所知，
所以下面第 2 节把你需要知道的全部状态写死了 —— **它比你自己去 `git log` 推断更准确**。

不要只给计划、摘要或建议；直接读文件、写代码、跑测试、修问题、提交。
本 Prompt 一次性授权你从 ACT 03 做到 ACT 11，**不授权**切分支、合并、推送、扩大范围。

## 1. 唯一工作目录

```
/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/mimo-storage-s1b-multipeer
```

只能在该 worktree 内工作。**不得进入或修改主工作区**
（`/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage`，它在 `main` 分支上）。

⚠ 这不是假想风险：前一位参与者曾误把文件改到主工作区的 `main` 上，事后 `git checkout --` 才回滚。
**每次改文件前确认路径以 `.worktrees/mimo-storage-s1b-multipeer/` 开头。**

## 2. 你接手时的真实状态（已核实，不要自己猜）

### 2.1 分支与提交

```
分支: agent/mimo/storage-s1b-multipeer
HEAD: c6c2150  docs(storage-s1b): ACT 04 收口 — 修正 schema 门禁正则避免误伤查询 DSL
      06fad34  test(storage-s1b): S1b-multipeer ACT 04 阶段 3 — drift 侧 peer ack 语义与 parity 测试
      04b7dba  feat(storage-s1b): S1b-multipeer ACT 04 阶段 2 — drift DAO/Store per-peer ack 改造
      f03dc54  feat(storage-s1b): S1b-multipeer ACT 04 阶段 1 — 端口加 peerId + 公开内存 fake
      618630a  feat(storage): schema v7 - per-peer ack 表 + t_sync_state peer_id 列 + 主键三元组
```

- **ACT 01 已完成并提交**（`6e78fd9`）
- **ACT 02 已完成并提交**（`fcd5612`）
- **ACT 03 已完成并提交**（`618630a`，schema v7）
- **ACT 04 已完成并提交**（`f03dc54`→`04b7dba`→`06fad34`→`c6c2150`），
  三包全绿（core 80 / drift 298 / firebase 114），SELF_CHECK 八条注入验证实做，
  schemaVersion 仍为 7 零迁移。
- **ACT 05–11 未开工**。下一 ACT 从 ACT 05（channel 过滤）开始，开工第一件事按 ACT 05 指令重记 `.act-base`。

### 2.2 工作区里的三样东西（各自怎么处置，**已定，别自己决定**）

| 文件 | 状态 | 是什么 | 怎么处置 |
|---|---|---|---|
| `docs/dispatch/` | 未跟踪 | 并发 agent（s1d blob_cipher）的独立交接文档 | **不碰、不提交**。与 S1b 无关 |
| `docs/storage-s1b-multipeer/COLD-START-PROMPT.md` | 未跟踪 | 本文件 | 不提交，留在工作区供后续 ACT 接手参考 |

### 2.3 关于 `.act-base` —— 为什么要重记，以及旧值为何不算事故

`.act-base` 用于界定"本 ACT 改了什么"，ACT 03 的两条 VERIFICATION 依赖它：

```bash
git diff --exit-code "$(cat .act-base)"..HEAD -- core firebase          # act/03.yaml:363
git diff "$(cat .act-base)"..HEAD -- drift/lib/persistence_drift.dart | grep -E ...   # :391
```

旧值 `fcd5612` 停留在 `2dff0cf` 之前。但 `2dff0cf` 只改了 `docs/` 与 `tasks/`，
两条守卫盯的是 `core` / `firebase` / `drift/lib/persistence_drift.dart` —— **零交集，旧值不会误报**（已实测）。

尽管如此，**开工第一件事仍然重记**，让基线语义等于"ACT 03 开工点"：

```bash
git rev-parse HEAD > .act-base && cat .act-base   # 应为 2dff0cf...
```

`.act-base` 是临时文件，**收工前 `rm` 掉，不要提交**（`.gitignore` 未包含它）。

### 2.4 关于那个 staged 的 S6 文档 —— 不要碰

`docs/superpowers/specs/2026-08-02-s6-p2p-sync-third-party-design.md` 有 282 行新增改动
已被 `git add` 但未提交。那是 **S6 子系统**的在途工作（三包方案→四包、新增 `flutter_secure_storage`
桌面端 DEK、D17/D18），**与 S1b 无关**。

- ❌ 不要把它包进你的任何一个 ACT 提交
- ❌ 不要 `git reset` 把它踢出暂存区
- ❌ 不要 `git stash`（会连你自己的工作一起卷走）
- ✅ 每次提交**显式列出你要提交的文件**，不要用 `git commit -a`、不要用 `git add .` / `git add -A`

正确姿势：

```bash
git add drift/lib/persistence_drift.dart drift/test/sync/schema_v7_migration_test.dart <其它本 ACT 文件>
git commit -m "feat(s1b): ACT 03 — ..."
```

⚠ 因为这个 staged 文件常驻，**ACT 03 的 `DONE_WHEN` 里"`git status --short` 为空"这一条
你永远达不到字面意义上的空**。正确的判据是：**除了这一行 S6 文档，没有属于本 ACT 的遗留未提交内容**。
`SELF_CHECK` 最后一条"六次自检后 `git status --porcelain` 必须为空"同理 —— 判据是
**回到自检前的状态**，而不是字面空。

## 3. 半成品测试文件的状态 —— 一处真错误，四处不要动

`drift/test/sync/schema_v7_migration_test.dart` 是前一位执行者写的 ACT 03 测试，
276 行，8 个用例名与 `act/03.yaml` 的 `TESTS_FIRST.CASES` **逐一对应**，骨架正确。

跑一遍看现状：

```bash
cd drift && dart analyze test/sync/schema_v7_migration_test.dart
```

会看到 11 个 error + 4 个 info + 1 个 depend_on_referenced_packages。
**其中只有一条需要你动手，其余全是预期内的。** 下面逐类说明，照着判断，不要自行加戏。

### ① 唯一要修的真错误：`:252` 前缀被遮蔽

```
error - :252 - The prefix 'sqlite3' can't be used here because it's shadowed by
               a local declaration. - prefix_shadowed_by_local_declaration
```

文件顶部是 `import 'package:sqlite3/sqlite3.dart';`（**无 `as` 前缀**），而 `sqlite3`
同时是该包导出的顶层变量名（那个用来 `sqlite3.openInMemory()` 的对象）。
所以辅助函数签名里的 `sqlite3.Database` 不是"前缀.类型"，而是"变量.成员"，编译不过。

修法：签名直接写 `Database`（`Database` 由 `package:sqlite3/sqlite3.dart` 无前缀导出）。

```dart
List<String> _primaryKeyColumns(Database db, String table) {   // 去掉 sqlite3.
```

### ② 预期内的 RED —— 生产代码写完自动消失，**不要"修"**

```
error - :130 :142 :161  - The named parameter 'peerId' isn't defined.
error - :179 :188 :198 :202 - 'outboxPeerAcks' / 'OutboxPeerAckRow' isn't defined.
```

这 10 条正是 `TESTS_FIRST` 想要的红：`peer_id` 列、`t_outbox_peer_ack` 表都还没建。
**看到它们说明测试真的依赖新 schema，是好事。** 写完生产代码 + 跑 `build_runner` 后自动消失。

⚠ **绝对不要**为了"让 analyze 干净"而把这些断言改软、加 `// ignore:`、或注释掉。

### ③ 四条 info 是 lint 噪音，不是 bug —— **不要改**

```
info - :57 :58 :116 :223 - The argument type 'int' isn't related to 'String'.
                         - collection_methods_unrelated_type
```

来源：`package:sqlite3` 的 `Row` 声明为 `implements Map<String, dynamic>`，
所以 analyzer 认为 `r[1]` 传了个 `int` 给期待 `String` 的下标。

**但整数下标在运行期是被显式支持的**，已核实源码
（`~/.pub-cache/hosted/pub.dev/sqlite3-2.9.4/lib/src/result_set.dart:115-127`，
本仓库 `drift/pubspec.lock:1089` 锁定 2.9.4；3.5.0 实现相同）：

```dart
dynamic operator [](Object? key) {
    if (key is! String) {
      if (key is int) {
        return _data[key];      // ← 整数下标正常返回值，不是 null
      }
      return null;
    }
    final index = _result._calculatedIndexes[key];
    ...
}
```

所以 `r[1]`（取 `PRAGMA` 结果的 `name` 列）、`actual[c]`（逐字段比对）、`r[5]`（取 `pk` 序号）
**都工作正常**，相关断言真实有效。

info 级不影响 `cd drift && dart analyze --format=machine | grep -c "^ERROR"` 这条门禁（只数 ERROR）。

> 如果你出于风格偏好想改成按列名取值（`r['name']` / `r['pk']` / `actual['scope_uid']`），
> **可以，但必须先让测试在整数下标形态下跑通并确认红/绿符合预期**，再作为独立的可读性改动。
> 不要在"还没验证过一次"的状态下重写取值方式 —— 那样一旦出问题，你分不清是迁移错了还是重写错了。

### ④ `depend_on_referenced_packages` —— 既有约定，不要动 pubspec

`sqlite3` 对 `persistence_drift` 是 transitive 依赖。范本测试
`drift/test/divination_case/creation_audit_logs_schema_v6_migration_test.dart:4`
也是这么 import 的，**是本仓库既有约定**。不要为此改 `drift/pubspec.yaml`。

### ⑤ 可选：`:247` 的 `expect(true, isTrue)`

`whole_drift_package_stays_green` 结尾是同义反复断言。`act/03.yaml` 明说这条
"不要求先红后绿"，所以它不算违规。但同义反复断言在本任务历次闸门中被点名过，
建议换成有实义的 —— 例如断言 `userVersion` 为 7。**这是可选项，不做也不阻断。**

### 修完 ① 之后的预期状态

`RED_COMMAND` 是 `cd drift && flutter test`。修掉前缀遮蔽、**尚未写生产代码**时，
预期的红是**编译期红**：`peerId` / `outboxPeerAcks` / `OutboxPeerAckRow` 未定义。

如果你看到的红不是这些，而是运行期的字段比对失败或表不存在 —— **先别急着改测试**，
按 `ON_FAIL` 判断是测试写错还是实现没跟上，并把现象记进纪要。

## 4. 2026-08-03 新增的范围禁令（前一位执行者开工时还没有）

**S1b 内不得实现 oplog compaction。**

`act/03.yaml` 建的 `t_outbox_peer_ack` 表提供的是压缩的**判据**，不是压缩的**许可**。
compaction 的前置条件是「游标落在 oplog 保留窗口外 → 强制全量对齐」，该能力归 **S1c**
（`docs/superpowers/specs/2026-08-03-s1c-full-reconciliation-design.md`，已立项未实现）。

缺了它而实现压缩，久未上线的设备会**静默丢失**被压缩区间的变更：对端只能给出保留窗口内的增量，
而该设备收下后照常把游标推进到"现在" —— **零报错、零测试变红**。

禁令已写入三处：`act/03.yaml` 的表 dartdoc、
`docs/superpowers/specs/2026-07-31-storage-architecture-design.md` 的 §9 依赖图与 §10 待决表。
**你在 ACT 03–11 的任何位置都不得实现压缩逻辑，也不得为它预留会被误当作已实现的半截代码。**

## 5. 另一条已被作废的历史记录（会误导你，先看清）

`tasks/mimo-storage-s1b-multipeer.md` 的「决定记录」里，2026-08-02 有一条写着
peerId 回填值定为 `'cloud'`。**该值已作废**（原地已标注，但你可能扫到旧文本）。

**正确值是 `'firestore'`**，理由：回填值必须与 `FirestoreRemoteGateway.peerId` 逐字一致，
实测 `firebase/lib/persistence_firebase.dart:60` 为 `const PeerId('firestore')`。
**`'cloud'` 是 Channel 的名字，不是 peerId。**

以 `act/03.yaml:163` 的 `TASK_DETAIL.backfill_value` 为准。回填错等于所有历史游标失效、全量重拉。

## 6. 启动顺序（编码前必须依次完整读取）

1. `AGENTS.md`
2. `docs/storage-s1b-multipeer/HANDOFF.md` —— 全景 + 环境坑 + 铁律，特别是 §11.3 与 §11.8
3. `tasks/mimo-storage-s1b-multipeer.md` —— 踩坑墓地、当前状态、计划、决定记录。
   **不得修改 A1–A14 验收标准**
4. `docs/storage-s1b-multipeer/act/03.yaml`（当前 ACT，逐字读完）
5. `docs/storage-s1b-multipeer/act/04.yaml` 至 `11.yaml`
6. `docs/superpowers/specs/2026-08-03-s1c-full-reconciliation-design.md`（只读，理解 §4 的边界即可）

然后自查：

```bash
git branch --show-current    # 必须是 agent/mimo/storage-s1b-multipeer
git status --short           # 应为 §2.2 表格里那三样
git log --oneline -5         # HEAD 应为 2dff0cf
```

**如果分支是 `main`/`master`，立即停止**，不得自行切换。
**如果 HEAD 不是 `2dff0cf`**，说明状态已变化，停下汇报差异，不要硬跑。

## 7. 执行总规则

- 从 **ACT 03** 开始，严格按 `03 → 04 → ... → 11` 顺序，`DEPENDS_ON` 是单链，不得跳过、并行、重排。
- 每次只打开当前 ACT 的写权限，严守该 ACT 的 `SCOPE` / `READ` / `WRITE` / `MODIFY` / `FORBIDDEN`。
- ACT 03、04、07、08、09 标记 `STRONG_MODEL_ONLY`，必须由你亲自完成，不得转交便宜模型。
- 不得自行修改 ACT、规格、A1–A14，不得降低验证口径。
  ACT 与真实源码无法调和时，按 `ON_FAIL` 停止并给出文件、行号、证据。
- 改任何函数/类/方法前，按 `AGENTS.md` 先跑 GitNexus upstream impact analysis 并报告影响范围；
  HIGH/CRITICAL 必须先警告人类。
- 每个 ACT 提交前跑 GitNexus `detect_changes`。
  **若 GitNexus 不可用，如实记录错误，不得伪称已运行。**
- 禁止：切分支、merge、rebase、push、force push、reset --hard、clean、破坏性 checkout、删 `.git`。
- 不要修改不属于本任务的既有改动（见 §2.4）。

## 8. 每个 ACT 的机械循环

1. 记基线：`git rev-parse HEAD > .act-base`，确认依赖 ACT 已完成。
2. 逐条实现 `TESTS_FIRST`，跑 `RED_COMMAND`，确认失败原因与 `RED_EXPECT` **一致**。
3. 若没红、红在无关原因、或被 catch-all 吞掉 —— 立即按 `ON_FAIL` 修测试。**不得带着假红继续。**
   （ACT 03 接手时的红长什么样才算对，见 §3 结尾）
4. 写生产代码直到该 ACT 全部测试转绿。
5. 逐条跑全部 `VERIFICATION`，**同时**核对 `EXPECT_EXIT` 与 `EXPECT_STDOUT`。
   ⚠ `grep -c` 无匹配时**打印 `0` 且退出码 `1`** —— 两个 EXPECT 都要核。
   不得只看屏幕上出现 PASS。
6. 逐条实做全部 `SELF_CHECK` mutation：临时改坏 → 确认点名的测试/门禁**真的变红** → 恢复 → 确认转绿。
7. 确认 `DONE_WHEN` 每一项都有证据（ACT 03 的 `git status` 那条按 §2.4 的口径判）。
8. `git diff --check` + GitNexus `detect_changes`。
9. 更新 `tasks/mimo-storage-s1b-multipeer.md` 的当前状态、计划勾选、决定记录/踩坑墓地，
   以及 `docs/storage-s1b-multipeer/HANDOFF.md`。**绝对不得修改 A1–A14 文本。**
10. **显式列出文件**提交（见 §2.4），message 用 `feat:` / `fix:` / `test:` 前缀并标明 `ACT NN`。
11. 确认提交成功、无本 ACT 遗留半成品，自动进入下一个 ACT，**无需等待人类逐个批准**。

> **「SELF_CHECK 没做」视为 ACT 未完成。
> 一个只能证明自己会绿、不能证明自己会红的门禁，是无效门禁。**

## 9. 已知环境与基线

- `drift/pubspec_overrides.yaml` 与 `firebase/pubspec_overrides.yaml` 是 gitignored 环境文件，
  **当前已就位**，按 HANDOFF §11.1 的完整配置；**不得把绝对路径写进仓库**。
  xuan-storage 内部同级包用相对路径，外部仓库走 Gitea。
- `dependency_overrides` 是**整块替换不是合并**，不得只保留 5 条而丢掉 drift 原有条目。
- firebase 用本地 core 后会暴露既有真实错误；以各 ACT 写明的收紧基线为准，
  **不得通过降低 analyzer/test 口径绕过**。
- 测试基线：core 73+ 绿 / drift 276 绿 / firebase 114 绿 ~3 跳过；firebase `dart analyze` ERROR 数 0。
- ACT 03 的 schema-first 方案已经 R6 闸门确认成立（为什么它能"全程绿"见 `act/03.yaml`
  的 `WHY_SCHEMA_GOES_FIRST`，以及 HANDOFF §6）。
- ACT 04 超粒度是人类接受的设计代价；按其四阶段推进，可分多个小提交，
  但不得拆成会产生不可编译永久中间态的独立 ACT。
- macOS `/bin/bash` 是 **3.2.57** —— 不用 `declare -A`、`mapfile`、`readarray`。
- 迁移测试范本：`drift/test/divination_case/creation_audit_logs_schema_v6_migration_test.dart`
  与 `drift/test/.../record_meta_schema_v4_migration_test.dart`。

## 10. 必须停止并汇报的情况

只有以下情况允许暂停，其余一律继续：

- 当前分支是 main/master。
- 需要改当前 ACT `SCOPE` 之外的业务文件而 ACT 未授权。
- 会改变 A1–A14、或决定记录里已裁定的公开接口/方案 A。
- GitNexus 报 HIGH/CRITICAL 且人类尚未确认。
- 同一问题连续两次修复失败，达到 `ON_FAIL` 的停止条件。
- 需要网络、推送、合并、删数据或其它新的外部权限。
- 发现会导致数据泄漏、跨 scope 串读、**静默丢变更**或**验收恒绿**的新 P0 问题。

暂停时必须报告：当前 ACT、做到哪一步、失败命令与完整关键错误、已排除的可能、工作树状态、最近提交。
**不要只说"遇到问题"。**

## 11. ACT 11 之后的总验收

除各 ACT 自身 `VERIFICATION` 外，还要执行并记录：

```bash
bash scripts/run_s1b_analyze_gate.sh
bash scripts/test_s1b_analyze_gate.sh
bash scripts/test_s1b_analyze_gate_trap.sh
cd core && flutter test
cd ../drift && flutter test
cd ../firebase && flutter test
```

同时确认：

- A1–A14 与基线提交 `cd064c6` **逐字一致**（37 行）。
- ACT 03–11 全部在任务纪要中标记完成（01/02 已完成）。
- 每个 ACT 有独立提交与验证证据。
- `git diff --check` 通过。
- `git status --short` 只剩 §2.4 那个 S6 staged 文档，无本任务遗留。
- `.act-base` 已删除且从未被提交。
- **不执行 push 或 merge**，等待人类最终验收。

最终答复必须包含：

- ACT 03–11 的完成状态与对应 commit；
- 各包 test/analyze 的**实际通过数量与退出码**；
- SELF_CHECK / mutation 的执行摘要（哪几条注入、各自红在哪个用例）；
- GitNexus `detect_changes` 最终影响摘要；
- 已知残余风险，或明确写"无新增已知阻断项"；
- 当前分支与最终 HEAD。

## 12. 遗留风险（知悉即可，不是你的任务）

本地 `main` 超前 `gitea/main` **27 个提交未推送**，S1b 全部工作建在这批未备份提交上。
**推送是对外动作，需人类每次明确授权，你不得自行推送。**

现在开始：先做 §6 的启动顺序，再按 §3 修掉那处前缀遮蔽，然后继续 ACT 03 的实现。
除非命中 §10 的停止条件，否则不要在 ACT 之间等待人类回复，连续推进直到 ACT 11 与总验收全部完成。

---

## 一行启动版

如果执行者已位于正确 worktree：

> 完整读取并严格执行 `docs/storage-s1b-multipeer/COLD-START-PROMPT.md` 中 `---` 之间的执行合同。
> 你是从 ACT 03 断点续做（01/02 已提交），工作区的半成品测试有一处真错误（§3①），
> 其余报错是预期内的 RED，不要"修"。做到 ACT 11 与总验收全部完成。
> 不得切分支、merge、push、修改 A1–A14、越出当前 ACT SCOPE，
> 也不得提交那个属于 S6 的 staged 文档。
