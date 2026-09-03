# 工作令 A — xuan-storage 数据集 manifest sha256 全面对齐（4 个域，14 个错值）

> **你是执行者。直接执行本文件，不要把它当参考资料。你自己的记忆/偏好一律让位于本工作令。**
> 读完即开工；只有命中「停止条件」时才停下并汇报。

签发：2026-09-03 ｜ 签发人：编排层（Claude Code）｜ 目标仓：`xuan-storage`（独立 git 仓）

---

## 0. ★用户已裁决的方向（不要再问，也不许反向操作）

> **以仓库里现存的 `.sql` 载荷文件为唯一真值，改 manifest 去对齐文件。**

- ✅ 允许：读 `.sql` 算出真实 sha256 / 字节数 / 行数，写回 manifest。
- ❌ **严禁**：重跑 `assets/tool/build_*.py` 构建脚本、重新生成 `.sql`、修改任何 `.sql` 内容。
- 理由：当前跑绿的模块（大六壬 / 铁板 / 太乙 起盘 E2E 全绿）用的就是仓库里这份 `.sql`。改清单是零风险；重跑脚本会换掉数据内容，反而可能把现在绿的弄红。

---

## 1. 目标

把 4 个域共 14 个 `DatasetManifest` 的 `payloadSha256` / `payloadBytes` / `declaredRowCount` 改成与仓库现存 `.sql` 载荷**完全一致**，并加一道**防再犯的门禁测试**。

---

## 2. 权威基线（编排层已实测核实，可直接采信）

### 2.1 错值分布（28 个载荷中 14 个对不上）

| 域 | 载荷文件数 | 对不上 |
|---|---|---|
| `assets/lib/daliuren/` | 4 | **4**（keti / official_data / school_dataset / shen_sha） |
| `assets/lib/kanyu/` | 3 | **3**（rules / schema / static_data） |
| `assets/lib/taiyishenshu/` | 3 | **3**（deities / minggua / schools） |
| `assets/lib/tiebanshenshu/` | 4 | **4**（formulas / kao_ke / shaozishu / 等） |

已经是对的、**不要动**：`qizhengsiyu`(8)、`ziwei`(3)、`four_zhu_card`(3)。
★特别注意：`qizhengsiyu` 的 8 个值已在分支 `wip/qizheng-manifest-fix`（commit `ee706d9`）修好，**本令不要碰 qizhengsiyu**，避免与那条分支冲突。

### 2.2 错值是怎么来的（已查清，别重复排查）

- 罪魁是 `c3b5cad`（2026-08-19，标题 "update SQL dataset SHA256 hashes and byte lengths for six domains"）。
- 实证：daliuren 在 `9eabd2c`（2026-08-10）时的值 **正好等于今天文件的真值**；`c3b5cad` 把它们改成了另一组值，而 daliuren 的 `.sql` 从那以后**再没动过**。
- 推断（字节数佐证）：那次是跑了构建脚本、把**脚本新生成**的 `.sql` 的 hash 写进清单，但**没把重新生成的 `.sql` 一起提交**。例：official_data 字节数被从 7228363 改成 7502429，而仓库里的文件至今仍是 7228363。

### 2.3 为什么这个错会「静默」（这是真病根，先了解再动手）

1. `core/lib/model/dataset/in_memory_dataset_installer.dart:176` 有 sha256 校验；
2. 失配返回 `InstallOutcome.integrityFailed`，**不抛异常**；
3. 上层 `_DatasetEnsurer.ensure()` **忽略这个返回值**，照样标记「已安装」；
4. 结果：表是空的但系统以为装好了，错误要到起盘查询时才以「资源不存在」冒出来，离现场极远。

---

## 3. 开工前置检查（PREFLIGHT，四条，缺一不可）

1. `git fetch --all --prune`（Gitea `192.168.0.165:3000` 不可达 → 见停止条件 #1）。
2. `git branch -a --sort=-committerdate | head -30`，关键词扫 `manifest`、`sha`、`assets`，**看有没有别人已经在修**。特别注意已存在 `fix/assets-ziwei-manifest-sha`（ziwei 那次的同类修复，可参考做法）。
3. 全分支搜是否已有人写过真值，例如：
   `git log --all --oneline -S "$(shasum -a 256 assets/lib/daliuren/assets/keti_document.sql | cut -c1-64)"`
   **搜到就先读那个提交，别重造。**
4. 亲自复现基线：跑一遍 §4.1 的扫描脚本，**确认确实是 14 个对不上**。对不上就先停下汇报。

---

## 4. 任务（顺序执行）

### 4.1 先扫描，产出真值表

写一个一次性脚本（放 `scripts/` 或临时目录皆可），对**全部 7 个域**遍历 `assets/lib/<domain>/assets/*.sql`，输出每个文件的：
- `sha256`（`shasum -a 256`）
- 字节数（`wc -c`）
- INSERT 行数（`LC_ALL=C grep -c '^INSERT'`）

★ macOS 坑（必须遵守，否则会得到假结果）：一律 `LC_ALL=C` + `grep -E`；不要用 `uniq` 去重 CJK（会按 locale 折叠出假重复）；BSD 的基本正则不支持 `\|`。

把扫描结果原样落盘为证据。

### 4.2 改 manifest（只改 4 个域）

对 `daliuren` / `kanyu` / `taiyishenshu` / `tiebanshenshu` 四个域：
1. `assets/lib/<domain>/<domain>_datasets.dart`：`payloadSha256`、`payloadBytes` 改为真值；`declaredRowCount` 与 INSERT 行数不符的也一并改对。
2. 同步文件头注释里的行数说明、`drift/*.dart` 里的行数注释（**只改注释，不许动 schema**）。
3. 同步 `assets/lib/<domain>/assets/BUILD-REPORT.md` 对应行。
4. 同步 `assets/test/<domain>/<domain>_datasets_test.dart` 里的 `_kTruth`（如果该域有这个测试）。

### 4.3 ★加防再犯门禁（本令的核心价值，不许省）

新增一个测试，**遍历全部 7 个域的所有载荷**，对每个数据集断言：
- manifest 的 `payloadSha256` == 该 `.sql` 文件实际 sha256；
- `payloadBytes` == 实际字节数；
- `declaredRowCount` == 实际 INSERT 行数。

要求：
- 断言必须**逐个数据集独立报错**并带上 datasetId + 期望值 + 实际值，不许一个 `expect` 把 28 个揉一起；
- 这个测试必须**能因值写错而变红**——先故意改坏一个值跑一次确认真红（留日志），再改回来跑绿（留日志）。

### 4.4 病根汇报（只汇报，★不许自己改）

`_DatasetEnsurer.ensure()` 吞掉 `integrityFailed` 是真病根。**本令不改它**（改成硬失败可能让启动路径炸，影响面要评估）。
你只需要：定位到具体文件行号，写一段说明放进交付报告 —— 影响哪些调用方、若改成 fail-fast 会有什么后果。**一行代码都不许动。**

---

## 5. 工作区与分支纪律

- **必须开独立 worktree**，不要污染 `xuan-storage` 主工作区（它当前 checkout 在 `wip/qizheng-manifest-fix`）：

```bash
cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage
git worktree add .worktrees/assets-manifest-sha -b wip/assets-manifest-sha-realign main
```

- **从 `main` 开分支**（不是从 `wip/qizheng-manifest-fix`），范围严格限定 4 个域 → 与那条分支零重叠、零冲突。
- 分支前缀规约见【引用】：根记忆《分支治理三前缀规约》（`wip/` / `rev/` / `keep/`，同模块只准一个 `wip/`）。
- ★**写完立刻 commit，不要攒着**——本机多会话并发，未提交文件被别的会话 `stash -u` 吞掉过（真实事故）。
- **禁止 `push` / `merge` / `rebase` 主分支。** 合并由人类执行。
- 若需动依赖：**只用 Gitea git URL**（`http://192.168.0.165:3000/xuan/<repo>.git`），**严禁相对 path**，新增 git 依赖**不写 `ref:`**。
- `pubspec.lock` 冲突按可再生噪音处理，**不作为阻断项**。

---

## 6. 禁止项（违反即作废重来）

- ❌ 重跑构建脚本 / 重新生成或修改任何 `.sql` 载荷内容（§0 已裁决）。
- ❌ 碰 `qizhengsiyu` / `ziwei` / `four_zhu_card` 三个域（它们已经是对的）。
- ❌ 改 `_DatasetEnsurer.ensure()` 或任何 installer 行为（§4.4 只汇报）。
- ❌ 改 drift schema（只许改注释）。
- ❌ 用 `echo` 回显冒充验收输出；验收必须是真实命令的真实 stdout + 真实退出码。
- ❌ 空测试体 / `markTestSkipped` / `skip: true` / 硬编码期望值绕过比对。
- ❌ 动 `xuan-shell` 或任何其它仓。

---

## 7. 停止条件（命中任一 → 停手汇报，不硬闯）

1. Gitea `192.168.0.165:3000` 不可达导致 `flutter pub get` 失败（**当前已知就是这个状态**，exit 69）→ **不要卡死在这里**：manifest 改值和扫描脚本**不需要** pub get，照做；只有跑 dart 测试需要。这种情况下：
   - 先完成 §4.1 / §4.2 / §4.3 的**代码与脚本产出**；
   - 用扫描脚本的原始输出作为「值已对齐」的证据；
   - 在报告里明确写「§4.3 门禁测试因 Gitea 不可达未运行，待恢复后补跑」，**不许假称跑绿**。
2. 扫描结果与 §2.1 的 14 个对不上 → 停，汇报差异。
3. 发现某个 `.sql` 本身损坏/为空 → 停，如实汇报，**不要自己造数据**。
4. 任何问题尝试一轮（3-5 个工具调用）仍无进展 → 停，汇报卡点 + 已试过什么 + 需要什么决策。

---

## 8. 最终证据（缺一不算完成）

- worktree 路径 + 分支名 + 全部 commit SHA。
- §4.1 扫描脚本的**原始输出**（改之前 + 改之后各一份，改后必须 28/28 全对）。
- §4.3 门禁测试的**故意改坏→真红**日志 + **改回→真绿**日志（若因 Gitea 不可达跑不了，如实说明并附扫描输出替代）。
- §4.4 病根定位说明（文件:行号 + 影响面分析）。
- `git diff --stat` + `git diff --check`。
- 一句话结论：4 个域 14 个值现在全部与载荷一致了吗？

---

## 9. 一句话启动语

> 读 `xuan-storage/docs/orders/ORDER-A-ASSETS-MANIFEST-SHA.md`，按 §5 开独立 worktree（从 main 开 `wip/assets-manifest-sha-realign`），做 §3 PREFLIGHT 后按 §4 顺序执行。方向已裁决：**以仓库现存 .sql 为真值改清单，严禁重跑构建脚本或改 .sql**。禁止 push/merge。
