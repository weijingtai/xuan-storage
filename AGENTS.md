> **注意**：本文件中的所有规则同等适用于从 `xuan-migration/` 根目录启动的 AI agents。详见根目录 AGENTS.md「启动约定」。

     1|     1|
     2|
     3|## 铁律：禁止在程序标识符中使用 xuan- / xuan_ 前缀
     4|
     5|`xuan-` / `xuan_` 前缀仅用于给人区分项目（目录名、仓库名），不得出现在程序标识符中。
     6|禁止：pubspec name、library 声明、import 文件名、依赖 key 中使用 `xuan_` 前缀。
     7|例外：`XuanLogger` 等功能品牌名、`tai_xuan` 等玄学术语、Git URL/目录名。
     8|详见根目录 AGENTS.md 铁律 #6。
     9|     2|
    10|     3|## 铁律：主分支代码保护
    11|     4|
    12|     5|**所有 AI agents 绝对禁止在主分支（main/master）上直接编写、修改、删除任何代码。**
    13|     6|
    14|     7|1. 禁止在 main/master 上执行任何代码变更
    15|     8|2. 所有代码修改必须在独立功能分支上进行（`feat/xxx`、`fix/xxx`、`refactor/xxx`）
    16|     9|3. 分支从 main/master 创建，最终通过 PR/MR 合并回 main/master
    17|    10|4. 合并操作由人类用户执行，AI agents 只负责创建分支、提交代码、发起 PR
    18|    11|
    19|    12|### 检查流程
    20|    13|1. `git branch --show-current` 确认当前分支
    21|    14|2. main/master → **立即停止**，提示用户创建分支
    22|    15|3. 功能分支 → 正常执行
    23|    16|
    24|    17|### 例外
    25|    18|- 只读操作（git log、git diff、cat、grep）允许在任何分支
    26|    19|- git pull / git fetch 等同步操作允许

## 铁律：依赖解析（本仓最高频的"假故障"来源）

本仓是多包工作区 + 多 worktree 并行开发，`pubspec.lock` 与 `pubspec_overrides.yaml`
都被 gitignore。**这意味着同一个 commit 在不同目录里可以有完全不同的依赖解析结果。**

**下面三条已各自咬过人，其中第 2 条在 2026-08-04 一天内出现三次。**
遇到"测试/分析报错但代码看着没问题"，先按此表排查，不要先怀疑代码。

### 1. 新 worktree 必须先 `flutter pub get`

| | |
|---|---|
| **症状** | `dart analyze` 报 500+ 条 `uri_does_not_exist`，每条 `package:` import 都红 |
| **误判** | "合并引入了大规模回归" |
| **真因** | 新建 worktree 不自带 `.dart_tool/`，analyzer 解析不了任何包 |
| **处置** | 进 worktree 第一件事就是对**每个用到的包**跑 `flutter pub get`（core / drift / firebase / assets 都要，漏一个就红一片） |

`scripts/run_s1a_analyze_gate.sh` 已加前置断言会拦下（exit 2），照它给的命令做即可。

### 2. 陈旧 `pubspec.lock` —— 同一份代码一边红一边绿

| | |
|---|---|
| **症状** | 报错指向 `.pub-cache` 里某个包的**类型不匹配 / 同名类重复定义 / 方法签名对不上**，而不是你自己的代码。典型如 `X/*1*/ can't be assigned to X/*2*/`、`Y is imported from both ... and ...` |
| **误判** | "这次合并把依赖弄坏了" |
| **真因** | lock 被 gitignore，各工作区独立解析。旧 lock 会把某个包钉在不兼容的旧版本 / 旧 git commit 上 |
| **处置** | **`rm pubspec.lock && flutter pub get`** |

> ⚠ **`flutter pub get` 和 `flutter pub upgrade <单个包>` 都顶不掉陈旧 lock** ——
> 前者会尽量沿用现有 lock，后者受其余约束牵制常常回一句 "No dependencies changed"。
> **必须删掉 lock 整体重解析。**

实测案例（2026-08-04，三次）：

- `firebase`：main 钉在 `fake_cloud_firestore 4.1.1`（与 `cloud_firestore 6.8.0` 不兼容），
  另一 worktree 是 4.2.0 → main 7 条编译失败、worktree 114 条全绿
- `assets`：main 与 worktree 解析到两个不同 commit 的 `metaphysics_core`
  → `EnumDatetimeType` 被从两个包同时导入
- 判据：**只要"同一 commit 在两个目录里结果不同"，就是这一条**

### 3. 入库的 pubspec 相对路径一律以 **main 的位置** 为准

worktree 比主目录深两层，同一条相对路径在两处指向不同地方。

**禁止**为了让 worktree 能跑而把入库的 `pubspec.yaml` 改深：

```yaml
# ❌ 在 worktree 里数着对，合进 main 就指到仓库外面去了
path: ../../../../repository-interface-xiang
# ✅ 以 main 的位置为准
path: ../../repository-interface-xiang
```

**worktree 的深度差由 gitignored 的 `pubspec_overrides.yaml` 承担，不许改入库文件。**

> ⚠ `pubspec_overrides.yaml` 会**整体取代** `pubspec.yaml` 的 `dependency_overrides` 段，
> 不是合并。新建该文件时必须把原有条目一并抄来，只改需要改的那几条，
> 否则会静默丢掉其余覆盖（典型表现：`... depends on X from git ... version solving failed`）。

另：仓内子包互相引用一律 `path: ../<子包>`，不得用 git URL 指回本仓
（`scripts/run_monorepo_convention_check.sh` 会拦）。

<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **xuan-storage** (5477 symbols, 10863 relationships, 300 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

> Index stale? Run `node .gitnexus/run.cjs analyze` from the project root — it auto-selects an available runner. No `.gitnexus/run.cjs` yet? `npx gitnexus analyze` (npm 11 crash → `npm i -g gitnexus`; #1939).

## Always Do

- **MUST run impact analysis before editing any symbol.** Before modifying a function, class, or method, run `impact({target: "symbolName", direction: "upstream"})` and report the blast radius (direct callers, affected processes, risk level) to the user.
- **MUST run `detect_changes()` before committing** to verify your changes only affect expected symbols and execution flows. For regression review, compare against the default branch: `detect_changes({scope: "compare", base_ref: "main"})`.
- **MUST warn the user** if impact analysis returns HIGH or CRITICAL risk before proceeding with edits.
- When exploring unfamiliar code, use `query({query: "concept"})` to find execution flows instead of grepping. It returns process-grouped results ranked by relevance.
- When you need full context on a specific symbol — callers, callees, which execution flows it participates in — use `context({name: "symbolName"})`.

## Never Do

- NEVER edit a function, class, or method without first running `impact` on it.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis.
- NEVER rename symbols with find-and-replace — use `rename` which understands the call graph.
- NEVER commit changes without running `detect_changes()` to check affected scope.

## Resources

| Resource | Use for |
|----------|---------|
| `gitnexus://repo/xuan-storage/context` | Codebase overview, check index freshness |
| `gitnexus://repo/xuan-storage/clusters` | All functional areas |
| `gitnexus://repo/xuan-storage/processes` | All execution flows |
| `gitnexus://repo/xuan-storage/process/{name}` | Step-by-step execution trace |

## CLI

| Task | Read this skill file |
|------|---------------------|
| Understand architecture / "How does X work?" | `.claude/skills/gitnexus/gitnexus-exploring/SKILL.md` |
| Blast radius / "What breaks if I change X?" | `.claude/skills/gitnexus/gitnexus-impact-analysis/SKILL.md` |
| Trace bugs / "Why is X failing?" | `.claude/skills/gitnexus/gitnexus-debugging/SKILL.md` |
| Rename / extract / split / refactor | `.claude/skills/gitnexus/gitnexus-refactoring/SKILL.md` |
| Tools, resources, schema reference | `.claude/skills/gitnexus/gitnexus-guide/SKILL.md` |
| Index, status, clean, wiki CLI commands | `.claude/skills/gitnexus/gitnexus-cli/SKILL.md` |

<!-- gitnexus:end -->
