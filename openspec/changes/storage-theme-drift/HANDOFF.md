# HANDOFF（incomplete）-- storage-theme-drift

> 2026-08-06 ｜ worktree `.worktrees/claude-storage-theme-drift` ｜ 分支 `agent/claude/storage-theme-drift` ｜ 基于 main `62a1e4c`
> 派工原文：`~/Downloads/storage_refactor/DISPATCH-THEME-DRIFT.md`
> 立项纪要：`openspec/changes/storage-theme-drift/{proposal,design,tasks}.md`

## 一句话状态

THEME-DRIFT 已立项（§四裁定选 A 独立库，已人类确认），T0/T1/T2 完成并提交，drift 版独立库 schema + token store + materializer + generation store 全绿（analyze 0 issue，drift 全包 146 = main 基线未抬高）；**T3-T7 未开始**，核心 store 实现（含三条变异自检）尚未写。

## 已完成（Done）

- **T0 立项与环境**
  - worktree `agent/claude/storage-theme-drift` 从 main `62a1e4c` 建
  - §四裁定落盘 `design.md` D1（选 A 独立库，依据 5 条，已人类确认 2026-08-06）
  - core/drift `flutter pub get` 完成；analyze 基线确认（drift 146、core 57，与 main 一致，无陈旧 lock）
- **T1 独立库 schema + 代码生成**（commit）
  - `drift/lib/theme/tables/`：theme_tokens / theme_overrides / theme_selection / theme_dataset_generations 四张表
  - `drift/lib/theme/theme_database.dart`：`ThemeDatabase` 独立库 `schemaVersion=1`，不进主库，主库保持 v9
  - `theme_database.g.dart` 已 build_runner 生成并入库
  - analyze：theme 0 issue，drift 全包 146
- **T2 drift 版 token store + materializer + generation store**（commit）
  - `drift_theme_token_store.dart`：对应 `InMemoryThemeTokenStore`，按世代读写 t_theme_token，value JSON 编码，putGeneration 整代覆盖写、dropGeneration 幂等、tokensOf 返回 unmodifiable
  - `drift_theme_materializer.dart`：对应 `InMemoryThemeMaterializer`，消费 JSON Lines 整代写 drift；v 为 Map 抛 StateError、世代号取入参、不校验完整性、不改活跃指针
  - `drift_dataset_generation_store.dart`：照 T1，世代状态落 t_theme_dataset_generation，活跃指针由 status=ready 隐式表达，翻转单事务；`DriftThemeDatasetInstaller extends DatasetInstallerBase`
  - analyze：theme 0 issue，drift 全包 146

## 未完成（Remaining）-- 按派工 §五/§六/§七

### T3 -- drift 版 ThemeLocalReader（未开始）
- `drift/lib/theme/drift_theme_local_reader.dart`：`implements ThemeLocalReader`
  - `readBundledTokens()`：generation 0 token，null 抛 StateError（fail closed，照 `XrapThemeLocalReader`）
  - `readActiveThemeTokens(themeId)`：六步无分支，照 `XrapThemeLocalReader`，数据源换成 DriftThemeTokenStore + DriftThemeDatasetInstaller.active()
  - `readOverrides()`：查 t_theme_override 表（含 OverrideOrigin 三字段还原）

### T4 -- drift 版 ThemeResourceStore（核心，三条变异自检都在这）（未开始）
- `drift/lib/theme/drift_theme_resource_store.dart`：`implements ThemeResourceStore`
  - `resolve()`：三层合并，**D4 显式缓存层保 identical**（三元组键 activeThemeId/packageVersion/overridesRevision）
  - `_readActiveWithTimeout`：30ms 超时降级（D5/P6）
  - `applyOverrides`：**D5 单事务原子**，先校验（v 不得为 Map）再整批写 t_theme_override + revision++
  - `removeOverrides`/`selectTheme`/`clearThemeSelection`/`listOverrides`/`listLocalThemes`/`watchResolved`
- **A3 变异自检**：拆缓存 -> identical 断言必红（**断言不许降级成 ==**）
- **A4 变异自检**：拆超时 -> 慢查询降级测试必红
- **A5 变异自检**：事务改逐条写 + 中途异常 -> "不留半套"断言必红

### T5 -- 契约套件提取（refactor，无行为变化）（未开始）
- `core/lib/test_support/theme_resource_store_contract_suite.dart`：照 `signaling_contract_suite.dart`，把 `core/test/theme_resource_store_contract_test.dart` 断言参数化成 `runThemeResourceStoreContractSuite(...)`
- `core/test/theme_resource_store_contract_test.dart` 改调套件，断言条数对齐（A10 内存版一条不少）
- 参考：`core/lib/test_support/signaling_contract_suite.dart`（提取手法样板）

### T6 -- drift 版契约测试 + A7 重启测试（未开始）
- `drift/test/theme/theme_resource_store_contract_test.dart`：调套件函数
- `drift/test/theme/theme_restart_test.dart`：A7 关库重开 resolve 不变
- `drift/test/theme/theme_materializer_test.dart`：drift materializer 落地 .jsonl
- drift 装配入口 `assembleThemeStoreDrift` + 测试（与内存版 assembleThemeStore 并存，不替换，design.md D7）

### T7 -- 全门禁验收（未开始）
验收命令（派工 §七，不加反引号）：
bash scripts/run_s1a_analyze_gate.sh && bash scripts/run_s1b_analyze_gate.sh && bash scripts/run_monorepo_convention_check.sh && bash scripts/run_s5a_analyze_gate.sh && bash scripts/run_s5a_residue_gate.sh && (cd core && flutter test) && (cd drift && flutter test) && (cd p2p && flutter test) && (cd firebase && flutter test)
基线（只增不减）：core 256 / drift 401 / p2p 62+1skip / firebase 131+4skip / S1a 全包 issue 57 / dartdoc 下限 161
⚠ run_s1b 的 drift 基线 146 在深层 worktree 恒红 149，main 同深度也是 149，与己无关，别改基线

## 下一个 agent 的起始位置

1. **进入 worktree**：`cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/claude-storage-theme-drift`，确认分支 `agent/claude/storage-theme-drift`。
2. **读派工**：`~/Downloads/storage_refactor/DISPATCH-THEME-DRIFT.md`（§五范围、§六三条易做假、§七验收、§八纪律）。
3. **读立项纪要**：`openspec/changes/storage-theme-drift/{proposal,design,tasks}.md`（D1-D7 决策已固化）。
4. **从 T3 开始**：写 `drift/lib/theme/drift_theme_local_reader.dart`。参考内存版 `core/lib/reference/theme_assembly.dart` 的 `XrapThemeLocalReader`（六步无分支）。
5. **必读样板**：`assets/lib/geo/drift_dataset_installer.dart`（T1 的 drift 世代 store 写法）、`core/lib/reference/in_memory_theme_resource_store.dart`（store 行为本体）、`core/lib/test_support/signaling_contract_suite.dart`（套件提取手法）。
6. **环境**：worktree 已 pub get，analyze 基线已确认干净。改 schema 后要 `cd drift && dart run build_runner build`（**不要用 `--build-filter`，会误删其他 .g.dart**；全量生成）。
7. **纪律**：不改 `core/lib/model/dataset/*`、不删/不改 `core/lib/reference/in_memory_*`、不动主库 schemaVersion、不碰 S1b/S1d/S3c/S6/T1 文件。每条新测试做变异自检并写明「注入了什么、红在哪条断言」。每完成一个子任务就提交。

## 铁律提醒

- 另一个 AI agent 也在处理 Theme 相关问题：只新增 `drift/lib/theme/*` 与 `drift/test/theme/*`，不碰 `core/lib/reference/`（内存版）和 `core/lib/model/`（XRAP 契约）这两处撞车面。
- 「一个绿的门禁，如果证明不了自己能红，它就是假的。」（§八）
- 不许为了让断言绿而改断言（identical -> == 是最典型的作弊面）。
- 汇报一律贴机器输出，查不出来写「未验证」，不许推测当结论。
