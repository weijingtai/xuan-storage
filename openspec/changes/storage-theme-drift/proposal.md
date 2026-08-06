## Why

S5a 交付的主题存储实现叫 `InMemoryThemeResourceStore` -- 主题存在内存 Map 里，进程一退就没了。设计稿原文：「reference 用内存 Map，**生产需建表**」。本变更把那张表建出来，并让整条链从内存换到 drift，使主题在重启后仍然存在（验收 A7）。

## What Changes

- 新增**独立 drift 库** `drift/lib/theme/theme_database.dart`（`ThemeDatabase`，`schemaVersion => 1`），承载主题 token 世代表 + 覆盖表 + 选择表。**不进主库 `PersistenceDriftDatabase`，主库 schemaVersion 保持 9 不动。**
- 新增 `drift/lib/theme/drift_theme_token_store.dart`（对应内存版 `InMemoryThemeTokenStore`，按世代读写 token）。
- 新增 `drift/lib/theme/drift_theme_materializer.dart`（`implements DatasetMaterializer`，把 `.jsonl` 载荷写进 token 表，照 `InMemoryThemeMaterializer`）。
- 新增 `drift/lib/theme/drift_dataset_generation_store.dart`（照 T1 `assets/lib/geo/drift_dataset_installer.dart`，世代状态落独立库的 `dataset_generation` 表）。
- 新增 `drift/lib/theme/drift_theme_resource_store.dart`（`implements ThemeResourceStore`，落地三层合并 / **显式缓存层保 identical** / 30ms 超时降级 / **事务原子 applyOverrides** / `watchResolved` 推送）。
- 新增 `drift/lib/theme/drift_theme_local_reader.dart`（`implements ThemeLocalReader`，接 drift token 表 + drift 世代 store）。
- 新增 `drift/lib/theme/theme_assembly_drift.dart`（drift 版装配入口 `assembleThemeStoreDrift`，与内存版 `assembleThemeStore` **并存**，不替换后者）。
- 提取 `core/lib/test_support/theme_resource_store_contract_suite.dart`（照 `signaling_contract_suite.dart`，把契约测试参数化成可复用函数），内存版与 drift 版跑同一套。
- 新增 `drift/test/theme/` 契约测试 + 三条变异自检（拆缓存 / 拆超时 / 逐条写）+ A7 重启测试。

## Capabilities

### New Capabilities
- `theme-disk-persistence`: 主题 token / 覆盖 / 选择落独立 SQLite 库，重启后恢复。
- `theme-generation-store-drift`: 主题数据集的 XRAP 世代状态用 drift 持久化（照 T1）。

### Modified Capabilities
- `theme-resource-store-contract`: 契约测试提取为可复用套件函数，内存版与 drift 版共享同一套断言。

## Impact

主要影响 `drift/lib/theme/`（全新）、`drift/test/theme/`（全新）、`core/lib/test_support/theme_resource_store_contract_suite.dart`（新增提取）。

**不修改**：`core/lib/model/dataset/*`（XRAP 契约）、`core/lib/reference/in_memory_*`（内存版 reference 与 fake，原样保留）、`drift/lib/persistence_drift.dart`（主库 schemaVersion 与 tables 列表不动）、S1b/S1d/S3c/S6/T1 的任何文件。

schemaVersion 不抢占已用版本号（v8=HLC，v9=blob）-- 本变更用独立库，与主库版本号无关。内存版的测试一条不少。
