## Context

S5a 交付的主题存储是 `InMemoryThemeResourceStore`，主题存在内存 Map 里，进程一退即失。本变更把同样的行为落到 drift (SQLite)，使主题重启后仍在（验收 A7）。内存版作为 reference 实现与测试 fake 原样保留。

T1（地理资产）已为"XRAP 资源落哪里"立了先例：独立库 `GeoDatabase`（`schemaVersion => 1`），不进主库，主库版本号不动。本变更沿用同一模式。

## Goals / Non-Goals

**Goals**
- 主题 token / 覆盖 / 选择落独立 drift 库，重启后 `resolve` 结果不变（A7）。
- drift 版跑通与内存版**同一套契约测试**，全绿（A2）。
- 三条内存版天然成立、drift 易退化的行为各要有变异自检：
  - 单条缓存 `identical`（A3，变异：拆缓存必红，**不许把断言改成 `==`**）
  - 30ms 超时降级（A4，变异：拆超时必红）
  - 原子 `applyOverrides`（A5，变异：改逐条写必红）
- `watchResolved` 写入后推送新值（A6）。
- 既有门禁全绿，S1a 57 条冻结基线未抬高，dartdoc 下限未被调低（A9）。
- 四包测试只增不减；内存版测试一条不少（A10）。

**Non-Goals**
- 不改 `core/lib/model/dataset/*`（XRAP 契约，T1 已交付在用）。
- 不删 / 不改 `core/lib/reference/in_memory_*` 的行为（reference 与 fake）。
- 不动 `drift/lib/persistence_drift.dart` 主库的 schemaVersion（保持 9）与 tables 列表。
- 不做 BUILD-THEME（构建脚本，另有派工）。
- 不做远端下发。
- 不做主题与业务数据的跨表事务（见 Decisions D1）。

## Decisions

### D1（§四 裁定）：独立库，不进主库 -- 已由人类确认（2026-08-06）

**裁定：选 A -- 独立库 `ThemeDatabase`（照 T1 的 `GeoDatabase`），主库 schemaVersion 保持 9 不动。**

依据：

1. **派工文档给的唯一反证条件不成立。** 文档原话：「若主题需要与业务数据在同一事务里读写，那 A 不成立。」实测主题全部写路径：`applyOverrides`（用户覆盖差量）是独立写，`resolve` 是只读三层合并，与占卜/案例记录无跨表事务需求。唯一让 A 不成立的条件不成立 -> A 成立。

2. **T1 已为同类资源立先例并写明理由。** `assets/lib/geo/drift/geo_database.dart` 注释原话：「geo 域资源数据库（XRAP §9.1 -- 资源落在独立数据库，不进主库）」。`GeoDatabase.schemaVersion => 1`，主库 `PersistenceDriftDatabase` 的 tables 列表不含它。主题是同类（可整体替换的 XRAP 世代化资源），无本质不同，应保持仓内一致。

3. **主库迁移风险/收益不对称。** 进主库 = v9 -> v10，要写迁移 + 迁移测试，给全体用户的生产库加一条迁移分支，且 v8/v9 已被 S1b/S1d 占用不能碰。换来的"同库"能力第 1 条已证明用不上。付全体用户迁移风险买一个用不上的能力，不划算。

4. **独立库不削弱任何验收点。** A7 靠"库文件持久化"，独立库是单独 `.sqlite`，进程退出文件还在、重开即恢复。A3/A4/A5 是 store 实现层的事，与"建在哪个库"无关。

5. **独立库最不与另一个 Theme agent 撞车。** 独立库方案只新增 `drift/lib/theme/*`，完全不碰 `core/lib/reference/`（内存版）和 `core/lib/model/`（XRAP 契约）-- 这两处是另一个 agent 最可能动的面。进主库则必须改 `persistence_drift.dart` 的 tables 列表（多 agent 共享高风险文件）。

### D2：独立库 schemaVersion 从 1 起

照 T1。独立库与主库版本号空间无关；`ThemeDatabase.schemaVersion => 1`。未来主题落地结构升级时递增本库版本，与主库无关。

### D3：token 表按世代分片，覆盖/选择表是单行状态

照内存版语义：
- token 表：`(dataset_id, generation, token_key)` -> `token_value`，一代一批，世代翻转时旧代整体丢弃（可整体替换的资源语义）。
- 覆盖表：`(scope_uid, token_key)` -> `(value, origin, updated_at_utc)`，用户覆盖差量。
- 选择表：`(scope_uid)` 单行 -> `selected_theme_id`（nullable）。

### D4：identical 缓存层显式建在 store 内

内存版天然 identical（同一 Map 取同一对象）。drift 每次查询造新对象，必须在 `DriftThemeResourceStore` 内显式维护 `ThemeTokenSet? _cache` + 三元组键 `(activeThemeId, packageVersion, overridesRevision)`，键命中返回同一实例。**断言保持 `identical`，不许降级为 `==`。**

### D5：原子 applyOverrides 用 drift 事务

`applyOverrides` 先整批校验（Map 值不得为 Map），再在单个 `db.transaction(() {...})` 里写入全部覆盖 + 自增 revision。中途失败整批回滚。**变异自检：把事务改成逐条写，注入中途异常，必须红在"留下半套"断言上。**

### D6：契约套件提取到 `core/lib/test_support/`

照 `signaling_contract_suite.dart`。`test/` 目录不可跨包引用，提取到 `lib/test_support/` 后内存版（`core/test/`）与 drift 版（`drift/test/`）跑同一套。barrel 不含 test_support（既有架构断言守着）。

### D7：装配入口并存，不替换

新增 `assembleThemeStoreDrift(...)` 与内存版 `assembleThemeStore(...)` 并存。内存版是 reference 与 fake 的装配，保留不动。生产装配（xuan-shell DI bootstrap）未来切到 drift 版，但那不在本变更范围（本变更只交付 drift 装配函数本身 + 测试）。

### D8：overrides revision 从覆盖表派生（选 b，不维护计数器列）

**选择 (b)**：缓存键的 `overridesRevision` 不落库维护，而是每次从 t_theme_override 派生 =「该 scope_uid 的行数 + 最大 updated_at_utc（毫秒）」。

依据：

1. **§1.1 硬约束冲突**：选项 (a) 需要在 T1 已交付的 `theme_selection_table.dart` 加列并全量重跑 build_runner（43 个 .g.dart），而 §1.1「不碰 S1b/S1d/S3c/S6/T1 的任何文件」是「违反即打回」级约束。EXECUTION-T3-T7.md §4.1 虽「推荐 (a)」，但同时把决定权交给执行 agent。
2. **(b) 行为等价**：`_refreshAndNotify` 在每次写操作后显式失效缓存并重算（照内存版），revision 比较只承担「未写路径上的缓存命中」——重复 resolve 无写时行数与 max(updated_at_utc) 恒等 → identical 命中（A3 语义不变）；写操作后的新鲜度由失效+重算保证，不依赖 revision 递增。
3. **(b) 反而更强**：revision 直接反映覆盖表真值，外部对表的任何变更（未来多 store 实例 / 多进程）都会改变派生值，比进程内计数器更接近「缓存键 = 数据状态」。
4. **零撞车面**：不碰任何已交付文件、不需要 build_runner、不影响其他包。

已知边界：drift 的 `dateTime()` 默认按秒存，同一秒内两次写且行数不变时派生值相同——由第 2 条「写后必失效重算」兜住，不产生陈旧结果。

### D9（REVISE-FIRST 顺带 P2，决定不修，各留一行依据）

1. **store 无 dispose 入口，`_controller.isClosed` 分支不可达** —— 不修。理由：与内存版 InMemoryThemeResourceStore 保持一致（它同样无 dispose，`isClosed` 分支是防御性写法，照抄语义）；端口 `ThemeResourceStore` 无 dispose 契约，加 dispose 属接口扩展、超出本变更范围；store 生命周期由装配层（xuan-shell DI）管理，本任务不交付装配接线。
2. **assets 包在深层 worktree `flutter pub get` 失败** —— 不修。理由：既有环境噪音（worktree 比主目录深两层，assets 的入库相对路径按 main 位置解析），不在 T7 验收命令 8 条之内；AGENTS.md 铁律「依赖解析」已归因此类问题，处置是 gitignored 的 `pubspec_overrides.yaml`，与主题库无关。

### D10：A6 watchResolved 推送测试与变异自检（REVISE-FIRST 补独立编号）

A6 的测试与变异注入点独立编号记录（评审 finding：D9 只记了两条 P2「决定不修」，与 A6 变异不是同一件事，此处补独立 D 编号）：

- **测试位置**：契约套件 `core/lib/test_support/theme_resource_store_contract_suite.dart` 的 `A6_watchResolved_写操作后推送新值`，core（InMemory）与 drift 两个入口各调一次，实测两侧都跑到。
- **断言方式**：`expectLater(stream, emitsInOrder([...]))` 结构性等待两个按序事件（applyOverrides 推覆盖 o1 生效、removeOverrides 推回落 bundled `#8B0000`），**不依赖时序 flush**。F1 修复：原 `Future.delayed(Duration.zero)` 靠时序巧合，将来多一跳异步会退化成假绿；emitsInOrder 在事件到达前挂起，等待本身即结构（对照 signaling 套件的「等事件而非等时间」）。
- **变异注入点**：两版 store `_refreshAndNotify` 里的 `_controller.add(await resolve())` —— `drift/lib/theme/drift_theme_resource_store.dart` :237、`core/lib/reference/in_memory_theme_resource_store.dart` :252。注释掉后流无事件、匹配永不完成，由测试的显式 timeout 兜底抛 `TestFailure`（**断言失败**，非 `TimeoutException`、非编译失败）。
- **验收记录**：注入后红在断言（`Expected: non-empty / Actual: []` 的等价物，用时 <1s）；恢复后绿。该变异自检随契约套件被 core 与 drift 同时覆盖。

## Risks / Trade-offs

- **[identical 在 drift 上易退化]** -> D4 显式缓存层 + A3 变异自检（拆缓存必红，断言不许降级）。
- **[30ms 超时在内存版无意义，drift 才第一次有意义]** -> 用 `SlowLocalReader` 手法（S5a 探针）造真慢查询，A4 变异自检（拆超时必红）。
- **[applyOverrides 原子性靠事务，易写成逐条]** -> D5 真事务 + A5 变异自检（逐条写必红）。
- **[契约套件提取可能漏带内存版的某条断言]** -> 提取后内存版原测试文件改为调套件函数，断言条数对齐（A10 内存版测试一条不少）。
- **[独立库与主库多一个 .sqlite 文件]** -> 代价可接受：换零主库迁移风险 + 与 T1 一致 + 不撞车（D1）。

## Migration Plan

1. 独立库 fresh 建表即可，无历史数据迁移（新库）。
2. 内存版零改动，既有测试零改动（契约套件提取是无行为变化的 refactor）。
3. 代码生成：改 schema 后跑 build_runner，`.g.dart` 一并提交。

## Open Questions

无。D1 已由人类确认。
