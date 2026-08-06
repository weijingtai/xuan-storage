# S5a ACT 返工 · 未完成 handoff 信封（2026-08-05）

> 接手者：你没有任何前情记忆。读本文件 + REACT 报告即可继续，无需重读全部 ACT。

## 上下文（30 秒）

- **任务**：按 `~/Downloads/storage_refactor/REACT-S5a-ACT.md`（REACT 闸门报告，判定 REVISE-FIRST，15 条返工项 R1-R15）修复 S5a 的 ACT 文档。
- **worktree**：`/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme`
- **分支**：`worktree-mimo-storage-s5a-theme`
- **上一提交**：`80b7190`（完成了 R1-R7、R11-R14 的部分子项）
- **REACT 报告位置**：`~/Downloads/storage_refactor/REACT-S5a-ACT.md`（只读，不要改）

## 已完成（不要重做）

| 项 | ACT 文件 | 内容 |
|---|---|---|
| R1 | act/05b.yaml（新建） | 探针/fixture 文件归属，含三探针 + ThemeBenchFixture 完整 SIGNATURE |
| R2 | act/02.yaml | A6 SIGNATURE 两方法 dartdoc 各补「只作用于用户覆盖层」+ VERIFICATION 改逐方法 awk |
| R3 | act/03.yaml | _registered EXPECT_STDOUT 3->4 |
| R4 | act/05.yaml | A20⑤ SIGNATURE 注释去 sha256 + oracle 改 import 集合断言 + VERIFICATION 改 grep package:crypto |
| R5 | act/06.yaml | P3-a2 ALLOWED 6->7（加 dart:async）+ CONSTRAINTS 说明 |
| R6 | act/07.yaml | analyze gate 占位符 -> 可照抄全文（三重检查 + 显式文件数组 + BASELINE 占位） |
| R7 | act/07.yaml | A4 改 .a4-baseline 快照比对；A17 收窄 lib/painter/；加 PREREQUISITES |
| R11 | act/07.yaml | A18 dartdoc 计数 >= 60（显式文件数组） |
| R12 | act/07.yaml | A2 加 --reporter json 逐文件计数 + 豁免 bench/2 support |
| R13 | act/04.yaml | DEPENDS_ON 补 02 |
| R14-⑥ | act/04.yaml | 两条 grep -c 改 test -ge 1 下限 |
| R14-⑦ | act/07.yaml | A3 覆盖下限 ls glob -> 显式文件数组 + [ -f ] |
| R14-⑧ | act/05.yaml | A20④「等方法/或」-> 写死六方法名 + 指定源码扫描 |

## 未完成（你要做的）

### 🔴 必做（阻断级，不做 ACT 仍不可开工）

**U1. R8/R9/R10 — ACT06 缺 A10/A11/A12 用例 + A13③**
- 位置：`docs/storage-s5a-theme/act/06.yaml` 的 `TESTS_FIRST.CASES`，在 `P1_merge_bench_under_5ms` 之前插入。
- REACT 报告 §10 R8/R9/R10 给了精确的修正标准与可验证判据，照写：
  - **R8 (A10)**：同一 override 集合下，先 packageTokens=A 解析、再换 B 解析，断言被 override 的 key 值不变；再 packageTokens=null（卸载），override 仍生效。`COVERS: [A10]`
  - **R9 (A11)**：①先 apply {k1,k2}，再 apply {k1'}，断言 k2 仍在且值不变；②apply 含非法条目的 patch，断言抛错**且** `listOverrides()` 与调用前逐 key 相等（原子回滚）。`COVERS: [A11]`
  - **R10 (A12)**：removeOverrides({k1}) 后 resolve() 中 k1 == package 层值；removeOverrides({不存在的 key}) 不抛。**另补 A13③**：orphan key 在 `listOverrides()` 中仍存在。`COVERS: [A12, A13]`
- 验证：`grep -rn "COVERS: \[.*A1[0-3]" docs/storage-s5a-theme/act/06.yaml` 应有 A10/A11/A12/A13 各 ≥1 命中。
- 注意：A10/A11/A12 测的是 store 行为（涉及换包/卸载/写覆盖），必须在 ACT06（store 层），不是 ACT04（纯合并函数）。但 ACT04 的 `mergeThemeTokens` 是无状态的，换包/卸载用例需要 store 持有状态——确认 BEHAVIOR 写明经 `store.resolve()` 驱动而非直接调 merger。

**U2. R14-②③ — READ 缺类型来源文件**
- `act/03.yaml` SCOPE.READ 补 `core/lib/model/dataset/dataset_materializer.dart`（CASE1 要求手写 fake materializer，需看 materialize 四参数 + MaterializeOutcome 默认构造器）。
- `act/06.yaml` SCOPE.READ 补 `core/lib/model/dataset/dataset_registry.dart`（P4 CASE 调 `DatasetRegistry.clearForTesting()`）。

**U3. R14-④ — ACT03 kThemeBundledManifest 占位规格不全**
- `act/03.yaml` SIGNATURE 的 `theme_dataset.dart` 块，`kThemeBundledManifest` 占位只给了 4 字段，缺 3 个 required：`contentVersion` / `minimumAppSchemaRevision` / `publishedAtUtc`。
- 且 `publishedAtUtc` 是 `DateTime`，**无 const 构造器**，所以 `const kThemeBundledManifest` 编译不过——改 `final`，并在 CONSTRAINTS 写明。
- 补齐示例：`contentVersion: '0.0.0-placeholder'`、`minimumAppSchemaRevision: 1`、`publishedAtUtc: DateTime.utc(2026, 1, 1)`（注意 `DateTime.utc` 不是 const，故用 `final`）。

### 🟡 应做（纪律/一致性，不阻断但 REACT 点名）

**U4. R14-① — 7 个 ACT 缺 ON_FAIL 段**
- 照 `docs/storage-s1b-multipeer/act/01.yaml:281` 形制（s1b 是已成功执行基准，11 个 ACT 全有）。
- 给 `act/01..07.yaml` + `05b.yaml` 每个 ACT 顶层加 `ON_FAIL:` 段，至少区分：RED 未红 / 实现验证失败 / 基线失败 / 预期中间态 / 自检残留。
- 验证：`grep -c "^ON_FAIL:" docs/storage-s5a-theme/act/*.yaml` 每文件 == 1。

**U5. R14-⑤ — DONE_WHEN 与扩充测试文件冲突**
- `act/02.yaml` 与 `act/06.yaml` 的 DONE_WHEN 写「不修改既有文件」，但它们要扩充 ACT01 建的 `theme_resource_store_contract_test.dart`。
- 改为：「不修改既有文件，**本任务链内先前 ACT 新建的测试文件除外**」。

**U6. R15 — HANDOFF §6 s1b gate drift 说明**
- `docs/storage-s5a-theme/HANDOFF.md` §6 的执行门禁要求 `run_s1b_analyze_gate.sh` EXIT 0，但本 worktree 因 `drift/pubspec.yaml` 三条 `../../` sibling 路径（行 77/79/81）的 `path_does_not_exist` 恒红（149 vs 基线 146），与 S5a 无关。
- HANDOFF §6 改为：「`run_s1b_analyze_gate.sh` 允许且仅允许 drift 包因 3 条 path_does_not_exist 超基线 146->149；其余任何超出即停」。

**U7. 连带 — ACT06 DEPENDS_ON + HANDOFF §4 表同步 05b**
- `act/06.yaml` DEPENDS_ON 加 `mimo-storage-s5a-theme/05b`（它的 CASE 用 CountingDatasetInstaller/ThemeBenchFixture）。
- `act/07.yaml` DEPENDS_ON 加 `05b`（残留门禁扫 05b 的两个文件）。
- `HANDOFF.md` §4 的 ACT 切分表加一行 05b，并把 04 的 DEPENDS_ON 改 `[01,02]`、06 的改 `[02,04,05,05b]`、07 的加 05b。

## 下一轮启动位置

1. `cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme`
2. `git log --oneline -3` 确认 HEAD 是 `80b7190`。
3. 读本文件「未完成」段，按 U1->U7 顺序做（U1/U2/U3 是阻断级，先做）。
4. 每条做完 `git commit`，commit message 引用 REACT 的 R 编号。
5. 全部做完后，跑一遍 REACT 报告 §10 的可验证判据自检，再请跨模型闸门复审（`wjt-react` 第二轮）。

## 不要做

- 不要改 REACT 报告本身（`~/Downloads/storage_refactor/REACT-S5a-ACT.md`，只读）。
- 不要改设计稿 / 纪要 / XRAP 契约（本轮只改 ACT 文档 + HANDOFF）。
- 不要重新设计 ACT 切分——REACT 已确认骨架对、只补漏。
- 不要用 `grep -c` 数 `ThemeMaterializer`（会把 `InMemoryThemeMaterializer` 一起数）。
