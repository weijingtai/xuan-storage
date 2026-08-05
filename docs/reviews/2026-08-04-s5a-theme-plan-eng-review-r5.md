# S5a Theme v6 plan-eng-review（HEAD `5224608`）— Round 5

> **审稿模型声明**：本审稿由 **Claude（Anthropic）** 执行。前四轮 R1–R4 均为 Codex（OpenAI）gStack `plan-eng-review`。
> 跨模型纪律满足：本仓「自己审自己等于没审」，本轮与 v6 修订者不同厂商。
>
> **v6 审稿对象**（`git log --oneline fe294fe..HEAD`，4 个提交，均纯文档、未触 `core/lib/`）：
> - `afb5bf5` v6 闭 R4 的 P2-9 / P2-8 / P1-5（replacement char / A3 计数 / ConfigBootstrap 矛盾）
> - `e45d675` v6 闭 R4 的 P1-3 / P1-1 / P1-6（数据流闭合 / theme_assembly 进交付表 / ThemeMaterializer 残留）
> - `5d9d47a` v6 闭 R4 的 P1-2 / P1-4 / P1-7（探针完整定义 / P3-a oracle 重写 / 残留门禁进交付表）
> - `5224608` v6 一致性收口（版本号/状态/§7.5 P3P4 同步 + 验收命令去反引号）
>
> ⚠️ **本轮只读**：未改任何设计稿、纪要、代码或 XRAP 契约（验证：`git diff --stat fe294fe..HEAD` 仅 2 文件，均 `.md`；`core/lib/model/dataset/` 零改动）。
> 唯一新增的本地文件是 `drift/pubspec_overrides.yaml`，该文件已被 `.gitignore`（`**/pubspec_overrides.yaml`）忽略，属 worktree 深度环境补丁（见下方「未完成项」），不入库、非代码变更。

## 结论

**PASS-WITH-REVISIONS**（有条件进 `wjt-act`）

- **任务① v6 验收**：R4 的 9 条 **全部闭合**（9 闭合 / 0 部分 / 0 未闭），R4-P0 亦确认未被 v6 改回。
- **任务② R5 文档评审**：未发现 P0；新增 **0 条 P1 / 2 条 P2** Findings（均文字级、不影响机械执行）。
- **唯一未完成项**（阻塞「无条件 PASS」）：派工书 §九 要求的「`git merge main` 没弄坏东西」验收命令串仅跑到 `run_s1a_analyze_gate.sh`（PASS）即因审稿 token/迭代预算耗尽而中断，`run_s1b_analyze_gate.sh` 与 `(cd core && flutter test)` / `(cd drift && flutter test)` / `(cd p2p && flutter test)` **尚未跑完**。`p2p/` 包确实存在（证明 v6 已 merge main），但「测试是否绿」未验证。
- **进 `wjt-act` 的条件**：由下一轮（或人类）补跑上述命令串确认全绿后即可放行。若任一包测试红，按派工书 §九「两种红」判：merge-main 引入的回归红 -> 本结论降为 REVISE-FIRST；环境红（如 worktree 缺 `pubspec_overrides.yaml`）-> 不影响 v6 判定。

> 本轮不判 PASS 的唯一原因：派工书 §十硬约束 #1/#3 要求「报告文件已 commit」且「数字自洽」，而验收命令串未跑完前我不能自洽地声明「合并 main 没弄坏东西」。任务① 的 9 条结论与 §六的文档 Findings 已完整且自洽，可独立采信。

---

## 任务① v6 验收结果

| # | R4 原条目 | 结论 | 证据（file:line + 原文片段） |
|---|---|---|---|
| 1 | reference 实现 3→4，`theme_assembly.dart` 未进 §11.2 交付表 | **闭合** | 设计 `...design.md:1810` §11.2 表含该行：`\| core/lib/reference/theme_assembly.dart \| XrapThemeLocalReader implements ThemeLocalReader ... + Future<ThemeResourceStore> assembleThemeStore({required String scopeUid, required DatasetInstaller installer, required Map<String, OverrideEntry> initialOverrides}) \| §4.5 \| A21, P4 \|`；签名出处、验收编号齐全；设计 `:1812`「reference 实现层共 4 个文件」；纪要 `tasks/...:46`「reference 实现 **4** 个文件 ... + 装配入口 `theme_assembly.dart`」；设计 `:1815-1817` 有「不可省」说明 |
| 2 | `CountingDatasetInstaller` 探针定义不全，照抄写不出可编译 fake | **闭合** | 设计 `:1058-1138` 给出完整定义：构造器 `CountingDatasetInstaller({required Stream<List<int>> Function() bundledPayload})`；六个计数字段初值 `= 0`；`final List<String> calledDatasetIds = <String>[]`；`resetCounts()`；六个抽象方法逐个写死 fake 返回（`ensureInstalled` 真调 `descriptor.materializer().materialize(...)`；`checkForUpdate` 恒返 `sourceUnavailable`；`active` 返 `_record`；`generations` 返 `[_record!]`；`rollbackTo` 返 `alreadyCurrent` 或抛 `StateError`；`collectGarbage` 恒返 0）。**实测 XRAP 契约 `core/lib/model/dataset/dataset_installer.dart:210-256` 抽象方法恰六个，与「没有 `install` 方法」一致**；设计 `:1824` §11.3 `theme_probes.dart` 行已含 `CountingDatasetInstaller` |
| 3 | **数据流不闭合**（materializer 实例私有状态 vs 工厂新建实例 vs reader 读不到） | **闭合** | 设计 `:532-643` §4.5「装配数据流」五步链闭合：方案 A（工厂闭包捕获外部共享 `InMemoryThemeTokenStore`，`:554-555`）+ 方案 C（世代号取自 `installer.active()`，`:557`）。`assembleThemeStore` 四步精确签名 `:629-633`；`XrapThemeLocalReader` 构造器与 `readActiveThemeTokens` 六步无分支流程 `:576-608`。方案 B（改单例）排除理由正确（`dataset_descriptor.dart:44` 实测为 `final DatasetMaterializer Function() materializer;` 工厂）；单独 C 不足理由正确（`DatasetRegistry`/`DatasetInstaller` 仅记世代元数据，实测 `dataset_installer.dart:33-89` `InstalledDataset` 确无落地物字段）。**回归守卫**：P4 断言 `tokenStore.generations.contains(0)` + 三条变红自检 `:1254-1264`。**不改任何 XRAP 契约**（`git diff --stat fe294fe..HEAD -- core/lib/model/dataset/` 为空）。判据 1/2 均满足，无「需人类裁定」项 |
| 4 | P3-a oracle 数拼写次数而非依赖图 | **闭合** | 设计 `:1140-1214` 重写为两条结构性断言：P3-a1 构造器 tear-off 函数类型断言（`:1155-1162` `final Object ctor = InMemoryThemeResourceStore.new; expect(ctor, isA<... Function({required String scopeUid, required ThemeLocalReader localReader})>())`）；P3-a2 import 集合白名单（`:1180-1194`，6 条 ALLOWED，断言 1 负向 `⊆ ALLOWED` + 断言 2 正向 `⊇ 必需两条`防空集静默全绿 + 断言 3 禁 `^(export\|part\|part of)\s`）。**「新增网络依赖 -> 变红」自检手法写死**：`:1198`「临时加 `import 'dart:io';` -> 断言 1 红」；`:1199`「把 import 正则改成永不匹配 -> 断言 2 红」。v5 文本计数法已显式作废 `:1142-1145`；纪要 `:202-203` 同步 |
| 5 | ConfigBootstrap 自相矛盾（§144「前置阻塞项」vs 后文「与 S5a 无关」） | **闭合** | 全文单一口径「不是 S5a 的阻塞项」（裁定 4）。设计 `:33` §0.0 裁定 4；`:147` §1.6「这不是 S5a 的阻塞项...全文唯一口径...不得写入 S5a 的 stop conditions」；`:1759` §9.2「已知非阻塞背景...不构成 S5a 的 stop gate」；纪要 `:76`「不是本任务的阻塞项」；纪要 `:265-268` stop conditions 段显式「ConfigBootstrap 三占位符不是 stop condition...v6 已删除」原第 4 条「需要真实网络下载」。§11.4 五条 stop conditions（设计 `:1837-1847`）均不含 ConfigBootstrap；纪要 `:255-263` 与设计逐条同构 |
| 6 | `ThemeMaterializer` 残留 15 处未标注 supersede | **闭合** | 用派工书指定的 `grep -nE '(^\|[^a-zA-Z])ThemeMaterializer'` 复核：所有裸命中均已删除或标注 supersede。设计 `:337-345` §4.2「v5 修正...已删除」并给出历史定义仅作说明；`:40`「不另包 `ThemeMaterializer` 子接口」为指导性表述；纪要 `:10-16`「不存在 `ThemeMaterializer` 这个类型...所有裸 `ThemeMaterializer` 字样均为历史记录...转 ACT 时不得据此创建」；纪要 `:451-453` v4 决定记录 ⛔ 标注「已被 v5 supersede」。`grep -c ThemeMaterializer` 计数非零（设计 16 / 纪要 23）属预期——`InMemoryThemeMaterializer` 含该子串是当前正确类名（纪要 `:381-384` 已说明）。契约层计数 8（`ls core/lib/model/theme_*.dart` 现 0 因 v6 纯文档未建文件，设计 §11.1 列 8 行 / A3 `== 8` / §11.0 总表 8）一致 |
| 7 | `run_s5a_residue_gate.sh` 不在交付表、仓里不存在；用 `ls` glob | **闭合** | 设计 `:1779` §11.0 总表「门禁脚本 **2**」明确点名 `scripts/run_s5a_analyze_gate.sh` + `scripts/run_s5a_residue_gate.sh`；`:1786`「两个脚本都必须由本 ACT 创建 -- 仓里现在都不存在」。脚本全文 `:1877-1954` §11.6 用**显式文件数组**（`CONTRACT_FILES=` / `REFERENCE_FILES=` / `TEST_FILES=` / `ALL_FILES=`，共 8+4+8=20 条，与 §11.1/11.2/11.3 逐条一致），逐个 `[ ! -f ]` 断言缺文件 `exit 2`（`MISSING_FILE:`），数组下限 `SCANNED < 20` `exit 2`（`SCAN_TOO_NARROW:`），grep 三种退出码显式处理无 `\|\| true`，三条变红自检 `:1958-1962`。无 `ls` glob |
| 8 | 纪要门禁纪律「A3 文件数 == 6」与验收 8 打架 | **闭合** | 纪要 `:107` A3「`== 8`」；`:237` 门禁写作纪律第 3 条「A3 的契约层文件数 == 8」；`:239-240` 手法已从 `ls` glob 改为「显式文件数组 + 逐个 `[ -f ]` 存在性断言」。旧 `== 6` 已删（v6 记录 `:389-392`）。设计 §11.1「共 8 个文件」、§11.0 总表 8、A3 `== 8` 三处一致 |
| 9 | 设计稿 §13、§74 有 4 个 UTF-8 replacement character | **闭合（字面判据）** | 设计稿 U+FFFD 计数 = 0（`grep -c $'\xEF\xBF\xBD'` = 0，python3 复核 = 0）。R4-P2-9 范围为「设计稿」，v6 已清零。**但纪要仍有残留**，见下方 Finding F1 |

> R4-P0（载荷行 schema 删 `g` 字段）：已由 `ebad8af` 闭合。v6 未改回——设计 `:380-384` §4.3 仍明写「不含 `g`（generation）字段」并给出 R4-P0 的理由；`:409` `tokens[j['k'] as String] = j['v'];` 注释「只读 k/v/t，载荷里没有 g」；`:417-421` 三处易错点写死「载荷行没有 `g` 字段，不得写 `g != generation` 即抛」。A20 验收⑥（纪要 `:158-159`）「同一份载荷用两个不同 generation 各落地一次」回归守卫在位。**确认未被 v6 改回。**

---

## 任务② R5 Findings

| 级别 | 位置（file:line） | 问题 + 修正标准（可验证） |
|---|---|---|
| P2 | `tasks/mimo-storage-s5a-theme.md:59` | 纪要「不做」段 `主题包 zip ���式 / manifest.yaml 定义 ...` 仍有 1 处 UTF-8 replacement character（python3 复核 U+FFFD 计数 = 3，实为 `格式` 二字的「格」被乱码）。**预存在**（`fe294fe`、`ebad8af` 均有，非 v6 引入），且超出 R4-P2-9 的字面范围（R4 只点名「设计稿」），故任务① 仍判闭合。但纪要是 ACT 转译器会读的文档，乱码在「主题包格式」这一关键名词上，机械执行者可能误读。 ｜ 修正标准: `grep -c $'\xEF\xBF\xBD' tasks/mimo-storage-s5a-theme.md` == 0；`sed -n '59p'` 该词显示为 `格式` |
| P2 | `docs/superpowers/specs/...design.md:1859-1861`（§11.5 BUILD-THEME 段）+ `tasks/mimo-storage-s5a-theme.md:332-340` | §11.5 写「转 ACT 时须同时创建它的占位纪要（哪怕只有目标 + 那三条 SHALL）」，但**该占位纪要至今不存在**（`xuan-storage/tasks/` 下无 `build-theme` 任务文件，全仓 `BUILD-THEME` 仅在 S5a 自身文档与 R4 评审中出现）。设计稿自己点名的「否则这三条 SHALL 会在移交中悄悄丢失」风险仍未落地为「不会被忽略的动作」——目前只是一句指令，转 ACT 时若执行者忘记就丢了。 ｜ 修正标准: 进 `wjt-act` 前，在 `xuan-storage/tasks/` 下创建 `mimo-storage-build-theme.md`（或等价占位），含目标 + 三条 SHALL（spec.md :60 / :86 / 第二轮评审 #5）+ 指向设计 §4.3/§11.5；或在 `wjt-act` 转译产物的任务清单中显式列出该占位为必产生物。**本条不阻塞 v6 验收**（R4 未要求），但阻塞「干净移交」 |

### R5 已确认的正向事实（独立复核，非采信自述）

- **XRAP 契约逐条核对**（派工书要求「设计稿凡是提到 XRAP 签名的地方都要打开真文件核对」）：
  - `dataset_descriptor.dart:44` = `final DatasetMaterializer Function() materializer;`（工厂）——方案 B 排除正确 ✓
  - `dataset_descriptor.dart:33-37` bundledManifest 恒存在 + generation 0 + prebuilt 强制 ✓
  - `dataset_descriptor.dart:59-61` `supports()` 只比大小 ✓
  - `dataset_materializer.dart:50-56` materialize 签名含 `Stream<List<int>> payload` + `int generation` ✓
  - `dataset_materializer.dart:23-26` `MaterializeOutcome` 默认构造器 `({required rowCount, required bytesOnDisk})`，无 `.success` ✓
  - `dataset_materializer.dart:34-36` 只写入参 generation、不改活跃指针、dropGeneration 幂等 ✓
  - `dataset_installer.dart:210-256` `DatasetInstaller` 抽象方法**恰好六个**（ensureInstalled/checkForUpdate/active/generations/rollbackTo/collectGarbage），无 `install` ✓
  - `dataset_registry.dart:55-67` visibility 必须 resource + publisher 必须 official（裁定 2）✓
  - `dataset_source.dart:61` `endpointFor`「未配置返回 null」（裁定 4）✓
  - `dataset_manifest.dart:84` `declaredRowCount`「纯 blob 数据集为 null」（裁定 1）✓
- **v6 未触任何契约**：`git diff --stat fe294fe..HEAD -- core/lib/model/dataset/` 空；`-- core/lib/` 空；`-- core/test/ scripts/` 空。仅 2 个 `.md` 文件变更（设计稿 +665/-？、纪要 +250/-？）。
- **跨模型**：v6 提交者 `wjt <wjt199015@gmail.com>`，无模型 trailer；R1–R4 为 Codex，本轮 Claude，不同厂商 ✓。

### 派工书 §六「前四轮回潮抽查」

- **R3-P0**（`InstalledTheme` 类残留）：仅出现在 §11.6 `FORBIDDEN` 定义（`:1884`，门禁本体正当）、自检示例（`:1960`）、历史决定记录（纪要 `:412-414`）。无当前类定义或值类型使用。**未回潮** ✓
- **R3-P1**（§6.6 第 1 步仍写扁平化）：设计 `:1519`「第 1 步 · 输入校验（不做扁平化）」，运行时不扁平化，构建期已移交。**未回潮** ✓
- **R3-P1**（载荷格式含糊）：设计 `:365`「格式定为 JSON Lines（`.jsonl`），UTF-8，LF 换行」，唯一答案。**未回潮** ✓
- **R2-P1-1**（A14 归属）：A14c+A19 留 S5a，A14b→XRAP，A14a/d/e→BUILD-THEME，§8.1 映射在位，§11.5 唯一 ID。**未回潮** ✓

### 派工书 §六「必查清单」

1. 回潮抽查：见上，全过。
2. 交付清单可机械执行：§11.1（8）+§11.2（4）+§11.3（8）+门禁脚本（2）= 22，§11.6 脚本数组 20 条与 §11.1/11.2/11.3 逐条核对零差异（contract 8/reference 4/test 8）。**自数一遍一致**。
3. 每条验收标准有对应交付物：A1↔analyze_gate、A2↔8 测试文件、A3↔8 契约、A4↔theme git、A5a/b↔pubspec、A6/A7↔theme_resource_store、A8↔module_registry、A9–A13/A14c/A19↔theme_token_merger、A15/A16↔contract_test、A17↔painter git、A18↔dartdoc、A20↔materializer_test、A21/P3–P6↔startup_path_test、P1↔merge_bench_test、P7↔merger。**逐条可定位**。
4. 模糊词扫描：`适当/优雅/合理地/必要时/视情况`——仅 `优雅降级` 2 处（设计 `:1274`、纪要 `:216`），**非指令性模糊词**，是 P6 已具体化行为（`<50ms` + 结果来自 bundled + 不抛异常）的描述性修饰。判：非毒药，不列返工。
5. oracle 可红性：P3-a1/a2 各有变红自检；P4 三条变红自检（`:1254-1264`）；A21 变红手法（纪要 `:171-172`）；残留门禁三条变红自检（`:1958-1962`）。**每条门禁都能红**。
6. Stop conditions 自洽：设计 §11.4 五条与纪要五条逐条同构，无「与 S5a 无关」与「等人类」并存，ConfigBootstrap 显式排除。**自洽** ✓
7. `git merge main` 后没弄坏东西：`p2p/` 存在（已 merge main）；`run_monorepo_convention_check.sh` PASS；`run_s1a_analyze_gate.sh` PASS（基线 57）；`run_s1b_analyze_gate.sh` **未跑完**（token 耗尽中断）；`(cd core && flutter test)` / `(cd drift && flutter test)` / `(cd p2p && flutter test)` **未跑**。**此项未完成**，见下方「未完成项」。

### 派工书 §六「三个生产可用性」判断

| 事实（已实查） | R5 判 |
|---|---|
| 全仓 `implements DatasetSource` 仅 `BundledDatasetSource`（`core/lib/model/dataset/bundled_dataset_source.dart:22`）；ConfigBootstrap 不在本仓 | **计划标注不够醒目**。设计稿未在任何处明确声明「S5a 落地后只能分发内置世代主题，不发版就换不了主题」这一产品后果。§0.0 裁定 4 / §9.2 只说了「ConfigBootstrap 不是阻塞项」，但没把「因此 S5a 首批不能远程下发主题」作为产品边界写出来。**不阻塞 v6 验收**（范围由人类裁定），但建议在 §0.1 或 §9.2 加一句产品边界声明。未列 Finding（因属建议性，非机械执行缺口） |
| §11.2 reference 全是 `InMemory*`；§11.5 THEME-DRIFT「生产需建表」 | **标注足够醒目**。§4.4 `:484-487` 明写「生产实现（drift 表）不在本设计决定...属后续任务 `THEME-DRIFT`」；§11.5 给唯一 ID `THEME-DRIFT` 并指明「与 S1d/S5b 协调 schemaVersion」。承接 ID 唯一不会丢。**过** |
| §11.5 BUILD-THEME 未立项，三条 SHALL 挂名下；设计稿写「转 ACT 时须同时创建占位纪要」 | **未落成不会被忽略的动作**。占位纪要至今不存在，仅一句指令。见 Finding F2（P2）。**需补** |

---

## 已确认关闭的 R4 项

- R4-P0（载荷行 schema 删 `g`）：`ebad8af` 闭合，v6 未改回 ✓
- R4-P1-1（theme_assembly 进交付表）：闭合 ✓
- R4-P1-2（CountingDatasetInstaller 完整定义）：闭合 ✓
- R4-P1-3（数据流闭合）：闭合，方案 A+C，不改契约 ✓
- R4-P1-4（P3-a oracle 结构化）：闭合 ✓
- R4-P1-5（ConfigBootstrap 单一口径）：闭合 ✓
- R4-P1-6（ThemeMaterializer 残留）：闭合 ✓
- R4-P1-7（residue gate 进交付表 + 用文件数组）：闭合 ✓
- R4-P2-8（A3 文件数 8）：闭合 ✓
- R4-P2-9（设计稿 replacement char 清零）：闭合（字面判据；纪要残留见 F1）✓

---

## 进入 `/wjt-act` 前必须完成的修订

1. **【未完成项 / 阻塞无条件 PASS】** 补跑派工书 §九验收命令串的后半段并记录结果：
   `bash scripts/run_s1b_analyze_gate.sh && (cd core && flutter test) && (cd drift && flutter test) && (cd p2p && flutter test)`。
   环境注意：本 worktree（`.claude/worktrees/mimo-storage-s5a-theme/`）比 `.worktrees/<name>/` 深一级，`drift/pubspec_overrides.yaml` 中 sibling-repo 路径需用 `../../../../../`（5 级 `../`）而非 s1d 模板的 `../../../../`（4 级）。本轮已建好该 gitignored 文件并跑通 `drift flutter pub get`，下一轮可直接复用。core/p2p 已 `pub get` 成功。
   - 全绿 -> 本结论升级为 PASS，可进 `wjt-act`
   - 任一包测试红 -> 按派工书 §九「两种红」判：merge-main 回归红（v6 弄坏的）-> 降为 REVISE-FIRST；环境红 -> 不影响 v6 判定，修环境后重跑
2. **【P2 / 不阻塞但建议转 ACT 前做】** 清纪要 `:59` 的 `主题包 zip ���式` 乱码为 `格式`（`grep -c $'\xEF\xBF\xBD' tasks/mimo-storage-s5a-theme.md` == 0）
3. **【P2 / 不阻塞但建议转 ACT 前做】** 落实 §11.5「BUILD-THEME 占位纪要」为一个真实存在的任务文件或 `wjt-act` 转译产物的必产生物条目，防三条 SHALL 丢失

> 第 1 项是「能否进 wjt-act」的硬门禁（派工书 §九明写「两种红都要在报告里如实写」），第 2/3 项是文字级，改完不必再评审。

---

## 未完成项（handoff 说明）

本轮因迭代预算耗尽，派工书 §九验收命令串的后半段未跑完。**任务① 9 条 + 任务② 文档评审 + §六清单 + 三生产可用性判断已全部完成**，结论可独立采信。下一轮**只需跑下面的命令并回填结果**，无需重读设计稿/纪要/契约（本轮已逐条核对并存证于本报告）。

### 一、当前环境状态（本轮已就绪，下一轮可直接复用）

| 项 | 状态 | 说明 |
|---|---|---|
| worktree 路径 | `/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme` | 注意：比 `.worktrees/<name>/` **深一级**，这是 sibling-repo 路径要用 5 级 `../` 的根因 |
| `core/.dart_tool/package_config.json` | ✅ 已 `flutter pub get`（114 deps） | 可直接 `flutter test` |
| `p2p/.dart_tool/package_config.json` | ✅ 已 `flutter pub get`（84 deps） | 可直接 `flutter test` |
| `drift/.dart_tool/package_config.json` | ✅ 已 `flutter pub get`（152 deps） | **前提**：`drift/pubspec_overrides.yaml` 必须存在（见下方坑） |
| `drift/pubspec_overrides.yaml` | ✅ 已建好（gitignored，`git status` 不显示） | 路径已修正为 5 级 `../`，**不要动**；若被删需按下方"坑"重建 |
| `p2p/` 包存在 | ✅ | 证明 v6 已 `git merge main`（102 commits） |

### 二、待跑命令（按顺序，逐条记录退出码与末尾输出）

> 全部从 worktree 根目录执行。每条跑完把 `EXIT=?` 和末尾几行贴进本报告的「四、结果回填」表。

```bash
cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme

# 1) S1b 分析门禁（派工书 §九命令串第 2 段）
bash scripts/run_s1b_analyze_gate.sh
echo "EXIT_S1B=$?"

# 2) core 全量测试
(cd core && flutter test)
echo "EXIT_CORE_TEST=$?"

# 3) drift 全量测试
(cd drift && flutter test)
echo "EXIT_DRIFT_TEST=$?"

# 4) p2p 全量测试
(cd p2p && flutter test)
echo "EXIT_P2P_TEST=$?"
```

### 三、判据与结论升级路径

把四条结果按下表判定，然后更新本报告顶部的「结论」段与末尾的收尾汇报行：

| 四条命令结果 | 含义 | 结论升级为 | 动作 |
|---|---|---|---|
| **全部 EXIT=0** | v6 合并 main 没弄坏任何东西 | **PASS** | 在报告顶部把结论改为 `PASS（可直接进 wjt-act）`，删除"唯一未完成项"段；向人类回报可进 wjt-act |
| 某条 EXIT≠0，且**红在测试断言**（不是 `uri_does_not_exist` / 不是 `pub get` 失败 / 不是 "No such file or directory"） | v6 merge main 引入回归 | **REVISE-FIRST** | 查是哪个包哪条测试，按派工书 §九「两种红」判为"v6 弄坏了东西"；列 Finding 并降级结论；建议上报人类 |
| 某条 EXIT≠0，但**红在环境**（`uri_does_not_exist` / `pub get` 失败 / 找不到 `repository-interface-*` / lockfile 陈旧） | 环境问题，非 v6 回归 | **维持 PASS-WITH-REVISIONS** | 按下方"已知环境坑"修环境后重跑；**不降级结论**，v6 本身无问题 |
| `p2p/` 不存在 | v6 根本没 merge main | **REVISE-FIRST**（新增 Finding） | 但本轮已确认 `p2p/` 存在，此分支不会触发；若触发说明 worktree 被重置 |

### 四、结果回填表（下一轮跑完填这里）

| 命令 | 退出码 | 末尾输出摘要 | 判定 |
|---|---|---|---|
| `run_s1b_analyze_gate.sh` | _EXIT=?_ | _待填_ | _待填_ |
| `core && flutter test` | _EXIT=?_ | _待填_ | _待填_ |
| `drift && flutter test` | _EXIT=?_ | _待填_ | _待填_ |
| `p2p && flutter test` | _EXIT=?_ | _待填_ | _待填_ |
| **综合** | -- | -- | _PASS / REVISE-FIRST / 维持 PASS-WITH-REVISIONS_ |

### 五、已知环境坑（若卡住按此排查）

1. **drift `pub get` 失败、报 `repository_interface_media from path which doesn't exist`**：
   - 根因：本 worktree 在 `.claude/worktrees/<name>/drift/`，比 s1d 模板的 `.worktrees/<name>/drift/` 深一级，sibling-repo 相对路径需 5 级 `../`。
   - 修复：确认 `drift/pubspec_overrides.yaml` 存在，且 `repository_interface_*` 行的 `path:` 是 `../../../../../repository-interface-*`（5 级），不是 `../../../../`（4 级）。`../core` 与 Gitea URL 行**不要动**。
   - 验证：`grep "path:" drift/pubspec_overrides.yaml` 应看到 5 级 `../` 指向 `repository-interface-record/-xiang/-divination-tag/-media`。
   - 本文件已被 `.gitignore`（`**/pubspec_overrides.yaml`），改它不入库、不违反本轮只读约束。

2. **`dart analyze` 报 500+ 条 `uri_does_not_exist`**：
   - 根因：该包没跑过 `flutter pub get`。
   - 修复：进对应包 `flutter pub get`。本轮 core/drift/p2p 均已 get 过，除非 `.dart_tool/` 被清。

3. **报错指向 `.pub-cache` 里某包类型不匹配 / 同名类重复定义**（如 `EnumDatetimeType` 从两个包 import）：
   - 根因：陈旧 `pubspec.lock`，两个不同 commit 的 `metaphysics_core` 被同时解析（assets 包踩过）。
   - 修复：`rm <pkg>/pubspec.lock && (cd <pkg> && flutter pub get)`。`pub upgrade <单包>` 顶不掉。**注意**：仅对出问题的包做，不要批量删 lock。

4. **`(cd p2p && flutter test)` 报 "No such file or directory" 或 "p2p 不在"**：
   - 这不是环境问题，是 v6 没 merge main（派工书 §九明写）。本轮已确认 `p2p/` 存在，若下一轮不存在说明 worktree 被重置到 merge 之前--直接判 REVISE-FIRST 并上报。

### 六、已跑通的命令（供对照，不用重跑）

- `git log --oneline fe294fe..HEAD` → 4 个 v6 提交（硬前置满足）
- `git diff --stat fe294fe..HEAD -- core/lib/model/dataset/` → 空（v6 未触 XRAP 契约）
- `ls -d p2p/` → 存在（已 merge main）
- `bash scripts/run_monorepo_convention_check.sh` → EXIT 0（✅ 三项检查全过）
- `bash scripts/run_s1a_analyze_gate.sh` → EXIT 0（✅ 基线 57，三项制全过）
- core / p2p / drift `flutter pub get` → 全部成功
