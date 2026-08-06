# S5a-Theme ACT 执行冷启动 Prompt（2026-08-05）

> 用法：在下列 worktree 根目录启动具备终端与文件编辑能力的强模型 Agent，
> 一次性投喂本文件中 `---` 之间的全文。
>
> ```bash
> cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme
> ```
>
> 本任务是**从零开始执行**，不是断点续做。worktree 当前 HEAD 是 `1c9a8db`（ACT 文档已就绪，代码一行未写）。

---

你是 `storage-s5a-theme` 任务的**实现执行者**，从 ACT 01 做到 ACT 07，把设计稿 v6 落成代码。

你是冷启动的，对之前发生的事一无所知，所以下面把你需要知道的全部写死了。**先读 `docs/storage-s5a-theme/HANDOFF.md` 再动手**--它比你自己去 `git log` 推断更准确。然后按 `docs/storage-s5a-theme/act/01.yaml` .. `07.yaml` 顺序执行。

不要只给计划、摘要或建议；直接读文件、写代码、跑测试、修问题、提交。本 Prompt 一次性授权你从 ACT 01 做到 ACT 07，**不授权**切分支、合并、推送、扩大范围。

## 1. 唯一工作目录

```
/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme
```

只能在该 worktree 内工作。**不得进入或修改主工作区**
（`/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage`，它在 `main` 分支上）。
每次改文件前确认路径以 `.claude/worktrees/mimo-storage-s5a-theme/` 开头。

## 2. 开工第一件事：执行门禁（硬前置，不绿即停）

动手写任何代码前，先跑这条串确认基线健康（派工书 §九 + HANDOFF §6）：

```bash
bash scripts/run_s1b_analyze_gate.sh   # 允许 drift 超 146->149（见下），core/firebase 必须不超
(cd core && flutter test)              # EXIT 0
(cd drift && flutter test)             # EXIT 0  (前提: drift/pubspec_overrides.yaml 存在，已建好，gitignored 不要动)
(cd p2p && flutter test)               # EXIT 0
```

**已知偏差（不构成停机）**：`run_s1b_analyze_gate.sh` 的 drift 包会因 `pubspec.yaml` 行 77/79/81
三条 `../../repository-interface-*` 在 worktree 深度下解析不到，恒报 3 条 `path_does_not_exist`，
使 drift 全包 issue 数 = 149（基线 146 + 3）。**判定口径**：允许且仅允许 drift 超 146->149；
core / firebase / 任何其它包超基线即停。`flutter pub get` 与 `flutter test` 全绿是真健康指标
（pubspec_overrides.yaml 覆盖了那三个包，pub 解析没问题，只是 analyze 不看 overrides）。

- **全绿（按上述口径）** -> 开工 ACT 01。
- **任一测试红在断言** -> 基线本身有问题，**先上报人类**，不要开工。
- **红在 `uri_does_not_exist` / pub get 失败** -> 环境问题，按 HANDOFF §5 坑修（core/p2p/drift 各 `flutter pub get`；drift 需 `pubspec_overrides.yaml`，已建好）。

## 3. 执行顺序与依赖

严格按 `DEPENDS_ON` 串行（不要并行，测试文件有交集）：

```
01 -> 02 -> 03 -> 04 -> 05 -> 05b -> 06 -> 07
        \-> 04 也依赖 01,02          \-> 06 依赖 02,04,05,05b
                                          \-> 07 依赖 01-06,05b
```

每个 ACT 文件自包含：`SCOPE.READ`（动手前必读）/ `SCOPE.WRITE`（只新增这些）/ `SIGNATURE`（照抄不要优化）/ `CONSTRAINTS`（禁项）/ `TESTS_FIRST.CASES`（先写测试）/ `VERIFICATION`（完成判据）/ `DONE_WHEN`（收尾）/ `ON_FAIL`（撞墙怎么办）。

## 4. 每个 ACT 的执行节奏（逐字遵守）

1. **读** `SCOPE.READ` 列的每个文件（设计稿按 § 号定位，XRAP 契约打开真文件核对签名）。
2. **先写测试**（`TESTS_FIRST.CASES`）：把每个 CASE 的 `FILE` 建出来，按 `BEHAVIOR` 写测试。
   跑 `RED_COMMAND`，确认**红在编译失败**（`RED_EXPECT`），证明测试真依赖新类型/新行为。
   - 若写实现前测试就绿 -> 测试没真依赖新东西，停下重写（见该 ACT 的 `ON_FAIL`）。
3. **写实现**：照 `SIGNATURE` 逐字落盘，不要"优化"。遵守 `CONSTRAINTS` 的每条禁项。
4. **跑 `VERIFICATION`**：每条 `CMD` 必须按 `EXPECT_EXIT`（与 `EXPECT_STDOUT`，若有）通过。
   - `grep -c` 类命令：无匹配时打印 "0" 且退出码 1，`EXPECT_STDOUT` 与 `EXPECT_EXIT` **两个都要满足**。
5. **SELF_CHECK / 变红自检**：每个 ACT 的 `DONE_WHEN` 或 `CONSTRAINTS` 里点名要做的变红自检，逐条真做：
   临时改坏 -> 确认目标断言变红（红在断言不是编译失败）-> 改回 -> `git status --porcelain` 为空。
   一个绿的门禁证明不了自己能红就是假的（本仓门禁纪律第 8 条）。
6. **commit**：每个 ACT 完成后单独提交，commit message 引用 ACT 编号与覆盖的验收标准。
   - 记录不可变 base ref 给 ACT 07 的范围守卫用：开工 ACT 01 前先 `git rev-parse HEAD > .act-base`（已 gitignored）。

## 5. 铁律（违反即停）

- **不改 `core/lib/model/dataset/` 下任何文件**（XRAP 契约只读，stop condition #4）。
- **不碰 `theme` 包**（A4 门禁，stop condition #3）。`theme` 是独立仓库，开工前 ACT 07 会记录它的 porcelain 快照到 `.a4-baseline`（已 gitignored）。
- **不碰 `xuan-qizhengsiyu/lib/painter/**`**（A17，stop condition #5）。
- **不读 `theme/` 仓库**（stop condition #2）。测试用 bundled token 由 `ThemeBenchFixture` 内联常量提供。
- **不切分支、不合并、不推送、不开新 worktree**。
- **不修改既有文件**（除本任务链内先前 ACT 新建的测试文件，见各 ACT 的 `DONE_WHEN` 豁免条款）。
- **不自行做架构决定**：架构问题已在 R1–R5 + REACT 两轮闸门关闭。照 ACT 做，不推断。
- 发现需要在 `DatasetMaterializer` 之外新增扩展点 -> stop condition #4，停下上报。
- 连续两次修不好同一条 -> 在纪要「决定记录」写下现象与已排除的可能，停下上报，不要连续第三次尝试（见各 ACT `ON_FAIL`）。

## 6. 环境（HANDOFF §5 详版）

- worktree 路径比 s1a/s1b 的 `.worktrees/<name>/` 深一级，`drift/pubspec_overrides.yaml` 的 sibling-repo 路径用 **5 级 `../`**（`../../../../../repository-interface-*`），已建好，**不要动**。
- 开工前每个包 `flutter pub get`（core/p2p/drift 已 get 过，`.dart_tool/` 若被清需重 get）。
- macOS `/bin/bash` 是 3.2.57：脚本不用 `declare -A` / `mapfile`，只用普通数组。

## 7. 收尾（ACT 07）

ACT 07 完成后跑总验收命令串（全绿才算 S5a 整体交付）：

```
bash scripts/run_s5a_analyze_gate.sh && bash scripts/run_s5a_residue_gate.sh && (cd core && flutter test --exclude-tags benchmark)
```

并按 ACT 07 的 `DONE_WHEN` 创建 `tasks/mimo-storage-build-theme.md` 占位纪要（防三条 SHALL 丢失，REACT R1/F2 闭合点）。

## 8. 不要做

- 不要改设计稿 / 纪要 / R5 报告 / REACT 报告 / HANDOFF / ACT 文档本身（它们是规格，你是执行者）。
- 不要用 `grep -c` 数 `ThemeMaterializer`（会把 `InMemoryThemeMaterializer` 一起数）。裸名判定用 `grep -nE '(^|[^a-zA-Z])ThemeMaterializer'`。
- 不要把断言写进未 await的 `.then()` / `.listen()` 回调（恒绿陷阱）。
- 不要用 `fail()` 做断言（调用方 catch-all 会吞 `TestFailure`），用计数式 spy。
- 不要用 `|| true` 结尾的验证命令。
- 不要在 ACT 06 的 `watchResolved()` 用例里用裸 `.listen()` 观察推送--用 `expectLater(stream, emitsInOrder([...]))`。

---

**一句话启动语**（你开始工作时对自己说的第一句）：
"我先读 `docs/storage-s5a-theme/HANDOFF.md`，再跑 §6 执行门禁，全绿后从 `act/01.yaml` 开始，TESTS_FIRST，逐 ACT 提交。"
