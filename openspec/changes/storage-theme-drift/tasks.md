# Tasks -- storage-theme-drift

> 顺序化任务，逐步门禁。每完成一个子任务就 handoff 落盘一次。
> 每条新测试必须做变异自检并逐条写明「注入了什么、红在哪条断言上」（A8）。

## T0 -- 立项与环境（本任务已完成立项）

- [x] 确认 main 基线 `62a1e4c`，建独立 worktree `agent/claude/storage-theme-drift`
- [x] §四裁定落盘（design.md D1：选 A 独立库，已人类确认）
- [ ] 进 worktree 对每个用到的包 `flutter pub get`（core / drift / assets 都要，门禁前置断言会拦）

## T1 -- 独立库 schema + 代码生成

- [ ] `drift/lib/theme/tables/`：token 表（按世代分片）、覆盖表、选择表、dataset_generation 表（照 T1）
- [ ] `drift/lib/theme/theme_database.dart`：`ThemeDatabase extends _$ThemeDatabase`，`schemaVersion => 1`，`onCreate` 建表 + 索引
- [ ] 跑 `dart run build_runner build` 生成 `.g.dart`，确认编译通过
- [ ] 门禁：`dart analyze` drift 包零新增 issue

## T2 -- drift 版 token store + materializer + generation store

- [ ] `drift_theme_token_store.dart`：对应 `InMemoryThemeTokenStore`，按世代读写 token（`tokensOf(generation)` / `putGeneration` / `dropGeneration`）
- [ ] `drift_theme_materializer.dart`：`implements DatasetMaterializer`，消费 `.jsonl` 写 token 表（照 `InMemoryThemeMaterializer`，v 为 Map 抛 StateError、世代号取入参）
- [ ] `drift_dataset_generation_store.dart`：照 T1 `DriftDatasetGenerationStore`，世代状态落 `dataset_generation` 表；`DriftDatasetInstaller extends DatasetInstallerBase`

## T3 -- drift 版 ThemeLocalReader

- [ ] `drift_theme_local_reader.dart`：`implements ThemeLocalReader`
  - `readBundledTokens()`：generation 0 的 token，null 抛 StateError（fail closed，照 `XrapThemeLocalReader`）
  - `readActiveThemeTokens(themeId)`：六步无分支，照 `XrapThemeLocalReader`，数据源换成 drift token store + drift 世代 store
  - `readOverrides()`：查 drift 覆盖表

## T4 -- drift 版 ThemeResourceStore（核心，三条变异自检都在这）

- [ ] `drift_theme_resource_store.dart`：`implements ThemeResourceStore`
  - `resolve()`：三层合并，**D4 显式缓存层保 identical**（三元组键）
  - `_readActiveWithTimeout`：30ms 超时降级（D5/P6）
  - `applyOverrides`：**D5 单事务原子**，先校验再整批写 + revision++
  - `removeOverrides` / `selectTheme` / `clearThemeSelection` / `listOverrides` / `listLocalThemes`
  - `watchResolved`：StreamController 广播，写操作后推送
- [ ] **A3 变异自检**：拆掉缓存层 -> `identical` 断言必红（断言不许降级成 `==`）；恢复后绿
- [ ] **A4 变异自检**：拆掉超时 -> 慢查询降级测试必红；恢复后绿
- [ ] **A5 变异自检**：事务改逐条写 + 中途异常 -> "不留半套"断言必红；恢复后绿

## T5 -- 契约套件提取（refactor，无行为变化）

- [ ] `core/lib/test_support/theme_resource_store_contract_suite.dart`：照 `signaling_contract_suite.dart`，把 `core/test/theme_resource_store_contract_test.dart` 的断言参数化成 `runThemeResourceStoreContractSuite({storeFactory, ...})`
- [ ] `core/test/theme_resource_store_contract_test.dart` 改为调套件函数，**断言条数对齐**（A10 内存版一条不少）
- [ ] 门禁：core 包测试全绿，条数不降

## T6 -- drift 版契约测试 + A7 重启测试

- [ ] `drift/test/theme/theme_resource_store_contract_test.dart`：调套件函数，drift 版跑同一套
- [ ] `drift/test/theme/theme_restart_test.dart`：A7 关库重开，`resolve` 结果不变
- [ ] `drift/test/theme/theme_materializer_test.dart`：drift materializer 落地 `.jsonl`
- [ ] drift 装配入口 `assembleThemeStoreDrift` + 测试

## T7 -- 全门禁验收

- [ ] `bash scripts/run_s1a_analyze_gate.sh`
- [ ] `bash scripts/run_s1b_analyze_gate.sh`（注意：drift 基线 146 在深层 worktree 恒红 149，与己无关，别改基线）
- [ ] `bash scripts/run_monorepo_convention_check.sh`
- [ ] `bash scripts/run_s5a_analyze_gate.sh`
- [ ] `bash scripts/run_s5a_residue_gate.sh`
- [ ] `(cd core && flutter test)` -- 基线 256，只增不减
- [ ] `(cd drift && flutter test)` -- 基线 401，只增不减
- [ ] `(cd p2p && flutter test)` -- 基线 62+1skip
- [ ] `(cd firebase && flutter test)` -- 基线 131+4skip
- [ ] S1a 全包 issue 57 未抬高，dartdoc 下限 161 未调低
- [ ] 提交 + handoff 落盘
