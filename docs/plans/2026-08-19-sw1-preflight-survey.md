# SW1 scope 隔离前置调研（SW1-0 preflight survey）

> 调研时间：2026-08-19
> 调研范围：仅调研，不产生任何代码 / schema / 迁移改动。
> 依据：`2026-08-19-scope-isolation-decision.md`（裁决书，唯一方案依据；与审计文档冲突以本文为准）
> 与 `2026-08-19-scope-column-audit.md`（59 表审计；已知错误见裁决书 §1.6）。
> 约定：每个结论附 `文件:行号`；无法定位写「未找到」；不确定处标 `?`；C 区只给选项不作裁决。

---

## 一、C 区：AccountDatabase 与 scope 分文件的循环依赖

### C1. 应用启动时数据库在哪一步被打开？

启动链路（xuan-shell 生产装配，`xuan-shell/lib/app/xuan_shell_dependencies.dart`）：

1. `XuanShellDependencies.create()`（`xuan_shell_dependencies.dart:97`）
2. `ShellStorageLifecycle.create()`（`xuan_shell_dependencies.dart:104`）：
   - `persistenceDb`（主库）：`shell_storage_bootstrap.dart:56-67`，`driftDatabase(name: 'persistence', ...)`
   - `accountDb`：`shell_storage_bootstrap.dart:68-79`，`driftDatabase(name: 'account', ...)`
   - qizheng `AppDatabase`：`shell_storage_bootstrap.dart:51`（`AppDatabase.new` 生产默认）
3. `ShellAccountBootstrap.create(prefs, accountDb: lifecycle.accountDb)`（`xuan_shell_dependencies.dart:111-114`）
4. `DriftAccountIdentityLinkRepository(lifecycle.accountDb)`（`xuan_shell_dependencies.dart:117`）
5. `DriftScopeBootstrapStore(lifecycle.persistenceDb)`（`xuan_shell_dependencies.dart:118`，ghost scope 存主库 `t_scope_alias`，见 `drift/lib/scope/scope_bootstrap_store.dart:39`）
6. `DriftScopeLedger(db: lifecycle.persistenceDb, bootstrapStore: ...)`（`xuan_shell_dependencies.dart:119-122`）
7. `DriftScopeHandoverService(...)`（`xuan_shell_dependencies.dart:127-135`，含 `DriftSqliteFileBackupService`，`drift/lib/scope/scope_backup.dart`）
8. `ScopeResolver(sessionRepository, identityLinkRepository, ledger, handoverService)`（`xuan_shell_dependencies.dart:136-141`）
9. `ShellAccountController(deps, scopeResolver)`（`xuan_shell_dependencies.dart:143-146`）
10. **`await accountController.initialize()`**（`xuan_shell_dependencies.dart:196`）→ 触发 `ScopeResolver.resolve()`
11. 首次 scope 构建 `_onAccountChanged()`（`xuan_shell_dependencies.dart:198`）；之后 `accountController.addListener`（`xuan_shell_dependencies.dart:209` 起）响应登录态变更

**结论**：`AccountDatabase` 在启动早期（第 2 步 `ShellStorageLifecycle.create()`）即被打开，**先于** scope 解析（第 10 步）。`ScopeResolver.resolve()` 在判定身份归属时要读 `AccountDatabase`（见下 C2）。

### C2. AccountDatabase 的职责与内容

- 仅含一张表：`AccountIdentityLinks`（`drift/lib/account/account_database.dart:7`，`@DriftDatabase(tables: [AccountIdentityLinks])`；schemaVersion = 1，`account_database.dart:12`）。
- 表定义：`drift/lib/account/account_identity_links_table.dart:9`。
- `ShellStorageLifecycle` 类文档：「App-lifecycle singletons: databases that must not be rebuilt on scope switch.」（`shell_storage_bootstrap.dart:25`）——accountDb 被明确设计为「切 scope 不重建」的生命周期单例。

### C3. scope 解析时如何读 AccountDatabase？

`ScopeResolver.resolve()`（`drift/lib/scope/scope_resolver.dart:49-133`）五步判定：

1. 无 session → device scope（`scope_resolver.dart:53-59`）
2. session.appUserId 为空 → 抛错（`scope_resolver.dart:63-70`）
3. 查 `t_scope_alias` 别名命中 → 返回（`scope_resolver.dart:76-83`）
4. device scope 未被占用 → 直接 bind（`scope_resolver.dart:89-97`）
5. device scope 已被占用 → `_canLinkBack()`（`scope_resolver.dart:100-124`）：
   - 匿名占用者：`_identityLinkRepository.getByAnonymousUserId(...)`（`scope_resolver.dart:142-149`）
   - 注册占用者：`_identityLinkRepository.getByRegisteredUserId(...)`（`scope_resolver.dart:150-157`）
   - 命中 → 升级（铸新 scope + handover，`scope_resolver.dart:105-123`）
   - 未命中 → 真冲突（mint 新 scope，`scope_resolver.dart:127-132`）

即：**AccountDatabase 是 scope 判定的输入之一**（决定「能否链回 / 升级还是冲突」）。这正是裁决书 §四.3 指出的循环依赖：判定 scope 的记录（AccountIdentityLinks）若按 scope 分文件，启动时无从知道该读哪个文件。

### C 区结论（选项，不作裁决）

`AccountDatabase` 不能按 scope 分文件。两个方向：

- **方案 A（推荐倾向）**：`AccountDatabase` 保持「全局单库」豁免。它是 App 生命周期单例（`shell_storage_bootstrap.dart:25`），启动时先于 scope 解析打开，且是 scope 判定依据 → 分文件会造成「先有鸡还是先有蛋」。豁免方式可与裁决一做法并存：把 `AccountIdentityLinks` 视为「设备级/全局」数据，随设备不随用户。
- **方案 B**：把 `AccountIdentityLinks` 从 `AccountDatabase` 迁入主库 `t_scope_alias` 或独立「全局库」，`AccountDatabase` 退役。代价：schema 变更 + 迁移 + 与裁决一「不加 scope 列」的约束冲突，成本最高。

> 无论选哪个，`kScopeMigratableTables`（`drift/lib/scope/scope_handover.dart:46-55`）都**不应**加入 `t_account_identity_links`——该表是 scope 判定依据而非被判定数据。审计文档第 12 行已对 `AccountIdentityLinks` 标注「加列可能形成循环依赖，待架构裁决」，与本文一致。

---

## 二、A 区：7 个独立 Drift 库逐一核实

### 通用事实（决策文档 §1.3-1.4 已核实）

- 7 个独立库全部不参与 P2P 同步（裁决书 §1.4），scope 对它们是「本机换主人」隔离问题，非同步正确性问题。
- 物理文件名带 scope（`ai_database_<scope>.db`）只对**含 U 类表**的库做；纯 G 类库（字典）应豁免（裁决书 §二「必须处理的三件事」）。

### A1. AiDatabase

- 定义：`drift/lib/ai/ai_database.dart:29`；构造 `AiDatabase([QueryExecutor? e])`（`:73`），默认 `driftDatabase(name: 'ai_database', databaseDirectory: getApplicationSupportDirectory)`（`:73-96`）。
- 物理文件：`ai_database.db`。
- 生产使用：**xuan-shell 未使用**（全仓未找到引用）。使用者：
  - `xuan-qizhengsiyu/companion_system/lib/providers/ai_chat_controller.dart:32`：`final AiDatabase aiDb = AiDatabase();`
  - 示例：`xuan-ai/example/lib/service_locator.dart:31`、`xuan-ai-migration/example/lib/service_locator.dart:31`
- 分类：**非纯 G**（含 AiChatSessions/AiChatMessages/AiPersonas/AiUsageAudits 等 U 类表，见 `ai/tables/tables.dart`）。
- 归档时机：`AiDatabase` 构造即开库，无独立延迟。xuan-shell 内无此库，分文件改造需先在宿主装配处找到它的构造点（当前在 xuan-qizhengsiyu 的 provider）。

### A2. FourZhuDatabase（AppDatabase）

- 定义：`drift/lib/four_zhu_card_templates/app_database.dart:19`；构造 `AppDatabase([QueryExecutor? e, bool loadInitialData = true])`（`:37`）。
- **关键发现**：xuan-shell 生产装配 `xuan_shell_dependencies.dart:166`：
  `final appDb = AppDatabase(lifecycle.persistenceDb.executor);`
  —— 即生产环境 FourZhuDatabase **复用主库 executor**，四柱卡片表物理上落在主库 `persistence.db` 中，而不是独立的 `app_database.db`！
- 决策文档 §1.3 写物理文件 `app_database` 是**未区分生产装配的默认情况**；生产实际共享主库文件，此点与裁决书 §1.3 的表需要修正对齐。
- 生产使用：仅 xuan-shell 装配点（`xuan_shell_dependencies.dart:166-174` 驱动 `FourZhuEditorDependenciesFactory`）。示例/测试另有构造，非生产路径。
- 分类：含 U 类表（LayoutTemplates/CardTemplateMetas/CardTemplateSettings/CardTemplateSkillUsages/MarketTemplateInstalls 等，`app_database.dart:20-28`）。**DaYunRecords/TaiYuanRecords 双库共用问题见 D 区。**

### A3. MeiHuaDatabase

- 定义：`drift/lib/meihuayishu/meihua_database.dart:12`；构造 `MeiHuaDatabase([QueryExecutor? executor])`（`:16`），默认 `createMeihuaConnection()`。
- 默认连接：`drift/lib/meihuayishu/meihua_database_connection_native.dart:8-14` → `NativeDatabase.createInBackground(file)`，文件名 `meihua_divination.sqlite`，目录 `getApplicationDocumentsDirectory`。
- 生产使用：**xuan-shell 未使用**（旧记录已迁 record-backed）。梅花占测记录生产走 `RecordBackedMeiHuaRepository`（`drift/lib/meihuayishu/record_backed_meihua_repository.dart:5-24`，写入主库 `t_record_meta`），装配于 `shell_scoped_storage_runtime.dart:459-462`。
- `MeiHuaDatabase` 仅用于迁移工具 `meihua_record_migration.dart`（读取旧表搬到 record-backed）与示例。
- 分类：含 U 类表（MeiHuaGuaInfos 等）。生产已不再由本库承载数据 → 分文件改造的「存量数据」主要是历史遗留，可并入迁移工具路径。

### A4. DictionaryDatabase

- 定义：`drift/lib/meihuayishu/dictionary_database.dart:11`；构造 `DictionaryDatabase([QueryExecutor? executor])`（`:13`），默认 `createDictionaryConnection()`（`dictionary_database_connection_native.dart:16` → 文件字典，生产已 deprecated）。
- **生产装配是内存库**：`xuan-shell/lib/app/meihua_dictionary_executor_native.dart:8-10`：`createMeihuaDictionaryExecutor()` 返回 `NativeDatabase.memory()`；装配于 `shell_scoped_storage_runtime.dart:353`（`DictionaryDatabase(await createMeihuaDictionaryExecutor())`，`_MeihuaXrapSingleton`）。
- 分类：**纯 G**（Characters/Pinyins/Etymologies/MeihuaDatasetGenerations，`dictionary_tables.dart:5,19,31,43`）→ 按裁决书 §二应**豁免**分文件（内存库本就无持久化；若改为文件库也是全局共享）。
- 归档时机：无持久化文件，无归档需求。

### A5. ThemeDatabase

- 定义：`drift/lib/theme/theme_database.dart:34`；构造 `ThemeDatabase(super.e)`（`:38`），**无默认 executor**（必须注入）。
- 生产使用：**未找到任何生产构造点**。全仓 `ThemeDatabase(` 仅测试引用。
- 关联 store（`drift_theme_token_store`/`drift_theme_resource_store`/`drift_theme_local_reader`/`drift_dataset_generation_store`/`theme_assembly_drift`）仅存在于 `drift/lib/theme/` 内部。
- 生产主题走**内存 ShellThemeController**（`xuan-shell/lib/theme/shell_theme_controller.dart`）+ 从 yaml 资源加载（`ShellThemeLoader`）。
- 分类：**非纯 G**（表集 `[ThemeTokens, ThemeOverrides, ThemeSelections, ThemeDatasetGenerations]`，`theme_database.dart:35`；ThemeOverrides/ThemeSelections 为 U 类）。但**当前无生产消费者** → 分文件改造是「未来项」，本轮无存量数据与归档问题。

### A6. TaiYiDatabase

- 定义：`drift/lib/taiyishenshu/taiyi_database.dart:31`；无参构造 `TaiYiDatabase()`（`:33`）硬编码 `driftDatabase(name: 'taiyi_database', databaseDirectory: getApplicationSupportDirectory)`（`:33-55`）。
- 物理文件：`taiyi_database.db`。
- 生产使用：`shell_scoped_storage_runtime.dart:488` `final taiyiDb = TaiYiDatabase();`，在 `rebuildForScope` 内**随 scope 重建**。
- ⚠ 已知隐患：`xuan_shell_dependencies.dart:202-208` 注释明确「listener 提前注册会并发触发两次 rebuildForScope → TaiYiDatabase 被构造两次（multiple database instances 警告 + 并发竞态）」。
- 分类：含 U 类表（UserSchools/UserDeities，`taiyi_database.dart:11,21`）。
- 归档时机：随 scope 重建 → 分文件改造最自然；但需同时解决「双构造」竞态。

### A7. AccountDatabase（见 C 区，此处只列库级事实）

- 定义：`drift/lib/account/account_database.dart:7`；构造需注入 executor（`:9`）。
- 生产装配：`shell_storage_bootstrap.dart:68-79`，`driftDatabase(name: 'account', ...)`；持有于 `ShellStorageLifecycle.accountDb`（`:28`）。
- 仅 1 表 `AccountIdentityLinks`，**裁决一对其不适用**（裁决书 §四.3；详见本文 C 区）。

### A 区小结

| 库 | 生产装配 | 物理文件 | 分类 | 分文件适用性 |
|---|---|---|---|---|
| AiDatabase | 不在 xuan-shell，见 xuan-qizhengsiyu provider:32 | `ai_database.db` | 非纯 G | 适用，存量归档：改名前备份 |
| FourZhuDatabase | 复用主库 executor（xuan_shell_dependencies.dart:166） | **共享 persistence.db** | 非纯 G | ⚠ 已共享主库文件，需先与裁决书 §1.3 对齐 |
| MeiHuaDatabase | 不在 xuan-shell（record-backed 接管） | `meihua_divination.sqlite` | 非纯 G | 存量已迁 record-backed，仅迁移工具用 |
| DictionaryDatabase | 内存库（meihua_dictionary_executor_native.dart:8-10） | 无（内存） | **纯 G** | 豁免（裁决书 §二） |
| ThemeDatabase | 未找到生产构造点 | — | 非纯 G（无消费者） | 未来项，本轮无归档 |
| TaiYiDatabase | shell_scoped_storage_runtime.dart:488 | `taiyi_database.db` | 非纯 G | 适用；需先解「双构造」竞态 |
| AccountDatabase | shell_storage_bootstrap.dart:68-79 | `account.db` | U（仅 1 表） | **裁决一不适用**（C 区） |

---

## 三、B 区：主库 16 张明细表逐表退场进度

> 方法：对每张表找 DAO / Repository 及**生产读写路径**（排除 test/example/pub-cache）。判定「仍在用」的标准：存在 xuan-shell 或宿主装配直接引用并能执行写操作。

### 已标 `@Deprecated`（裁决书 §1.5 已知）

| 表 | 表级标记 | 证据 | DAO 调用方 | 结论 |
|---|---|---|---|---|
| Seekers | `tables/seekers_table.dart:8` 整表 | 迁移工具 `drift/lib/seeker/seeker_migration.dart:14`（读旧表迁 `t_record_meta` module='seeker'） | `SeekersDao` 仅迁移工具用（`seeker_migration.dart:7`） | **已退场**。生产读走 `RecordBackedSeekerRepository`（`creation_launch_page.dart:98` `seekerRepo.getAllSeekers()`，装配 `xuan_shell_app.dart:184`） |
| SeekerDivinationMappers | `tables/seeker_divination_mappers_table.dart:7` 整表 | DAO 类同名 deprecated（`daos/seeker_divination_mappers_dao.dart:8`） | 未找到生产调用 | **已退场** |
| Divinations（部分列） | 非整表；`divinations_table.dart:24,31` 仅 `ownerSeekerUuid`/`seekerName` 列 deprecated | — | `DivinationsDao` 未找到生产调用 | **已退场**（表体保留，列级标记；无活跃读写） |

### 无标记但无生产读写

| 表 | DAO / Repository | 生产调用方 | 结论 |
|---|---|---|---|
| DivinationPanelMappers | `daos/divination_panel_mappers_dao.dart` | 未找到 | 已退场 |
| DivinationSubDivinationTypeMappers | `daos/divination_sub_divination_type_mappers_dao.dart` | 未找到 | 已退场 |
| PanelSkillClassMappers | `daos/panel_skill_class_mappers_dao.dart` | 未找到 | 已退场 |
| Panels | `daos/panels_dao.dart` | 未找到（`db.panels` 全仓无生产访问） | **已退场**（⚠ 与裁决书 §三「仍在用」表述冲突，见下） |
| DivinationCalendars | `daos/divination_calendars_dao.dart` → `repositories/divination_calendar_repository.dart` | 未找到（`DivinationCalendarRepository` 无生产调用） | 已退场 |
| TimingDivinations | `daos/timing_divinations_dao.dart` | 未找到 | 已退场 |
| CombinedDivinations | `daos/combined_divinations_dao.dart` | 未找到 | 已退场 |

> ⚠ **Panels 与裁决书 §三的冲突**：裁决书 §三把 `Panels` 列入「仍在用 → 加 scope_uid」。但本次全仓搜索 `db.panels` / `PanelsDao` / `PanelsCompanion` 均无生产访问（仅 daos 内自引用 + `persistence_drift.dart` 注册）。**结论：Panels 已退场**。建议 SW1 派发时与负责人核对，若确认退场则按「退场路线」（不加 scope 列）处理，避免「给将死的表做会被丢弃的迁移」（裁决书 §三理由的初衷）。

### 仍在用（创建流 6 表，宿主装配于 `xuan_shell_app.dart:239-252`）

| 表 | 生产写路径 | 生产读路径 | 结论 |
|---|---|---|---|
| DivinationCases | `drift/lib/divination_case/drift_divination_case_repository.dart:40` `saveCase`（经 `CreationCaseService`，`creation_case_service.dart:41`） | `creation_workspace_page.dart:52` `derivePayload` | **仍在用** |
| DivinationWorkItems | `drift_divination_case_repository.dart:158` `saveWorkItem` | 同上 | **仍在用** |
| CaseParticipants | `drift_divination_case_repository.dart:203` `saveParticipant` | 同上 | **仍在用** |
| PanelRefs | `drift_divination_case_repository.dart:248` `savePanelRef` | 同上 | **仍在用** |
| WorkItemPanelRefs | `drift_divination_case_repository.dart:261` `attachPanelRefToWorkItem` | 同上 | **仍在用** |
| CreationAuditLogs | `creation_audit_service.dart:22-32` `recordChanges`（`CreationAuditLogsDao.insertAuditLog`）；另 `drift/lib/xiang/xiang_delete_media_handler.dart:51-63` | `creation_audit_service.dart:37-52` | **仍在用** |

装配证据：`xuan_shell_app.dart:239-252` ——
```
caseRepo = DriftDivinationCaseRepository(persistenceDb)
auditDao = CreationAuditLogsDao(persistenceDb)
auditService = CreationAuditService(auditDao: auditDao)
caseService = CreationCaseService(caseRepo/recordRepo/workItemRepo/panelRefRepo)
```
> 注：`DriftDivinationCaseRepository` 的记录层（`saveRecord`）已走 `t_record_meta`（`drift_divination_case_repository.dart:90-123`，写 `scopeUid='default'` 常量占位，`:109`），但案卷/工作项/参与者/盘引用/审计日志 6 表仍直接写主库无 scope 表。

### B 区小结

- **已退场（9 张）**：Seekers、SeekerDivinationMappers、Divinations、DivinationPanelMappers、DivinationSubDivinationTypeMappers、Panels、PanelSkillClassMappers、DivinationCalendars、TimingDivinations、CombinedDivinations —— 实为 **10 张**（含 Panels）。
- **仍在用（6 张）**：DivinationCases、DivinationWorkItems、CaseParticipants、PanelRefs、WorkItemPanelRefs、CreationAuditLogs。
- 裁决书 §三「仍在用的（Panels、DivinationCases、DivinationWorkItems 等）」：`DivinationCases`/`DivinationWorkItems` 确认仍在用，**`Panels` 需修正为已退场**。

---

## 四、D 区：DaYunRecords / TaiYuanRecords 双库共用

### 事实

- 主库定义：`drift/lib/tables/da_yun_records_table.dart`（`t_da_yun_records`）、`drift/lib/tables/tai_yuan_records_table.dart`（`t_tai_yuan_records`）；注册于 `persistence_drift.dart:916-917`；DAO `daos/da_yun_records_dao.dart`、`daos/tai_yuan_records_dao.dart`（注册 `persistence_drift.dart:951-952`）。
- FourZhu 库定义：`drift/lib/four_zhu_card_templates/four_zhu_tables.dart:12`（`DaYunRecords`，`t_da_yun_records`）、`:33`（`TaiYuanRecords`，`t_tai_yuan_records`）；注册于 `app_database.dart:21-22`。
- 两处是**独立 Table 类**（同名同物理表名），各生成一份 schema。
- 生产装配：xuan-shell 中 `AppDatabase(lifecycle.persistenceDb.executor)`（`xuan_shell_dependencies.dart:166`）→ **两份表都物化在同一个物理文件 `persistence.db` 内**（主库 schema 与 four_zhu schema 各建同名表于同一文件）。

### 活性判定

- `DaYunRecordsDao` / `TaiYuanRecordsDao`：**无任何生产调用**（全仓搜索无 test 外引用）。
- `repositories/da_yun_record_repository.dart` / `repositories/tai_yuan_record_repository.dart`：未找到生产调用。
- xuan-bazi 的大运/流年走内存计算管线（`yunliu_calculator.dart` 等），不落这两张表。

### 结论

**两份都是死表**：主库一份无生产读写，four_zhu 一份同样无生产读写。裁决书 §1.6 的待确认项「哪一份是活的」可答复：**都不是**。SW1 可按退场处理；若要保留供未来迁移/接盘，应确认到底以哪一份为准（建议统一保留主库一份，删除 four_zhu 副本，或反之——不作裁决）。

---

## 五、0 区：git 分支与工作区状态（只报告，不处置）

### 分支与 interleave

- 当前分支：`wip/anon-scope-handover`（非 main/master）。
- `git log --oneline 68edaa8..HEAD` 显示 **scope 提交与 faas-py 提交交错**（interleave）仍在：
  - scope 提交：`1e14c94`（匿名转正铸新 scope）、`4f1ab4a`（handover 失败回滚绑定）
  - faas-py 提交：`ab168d0`、`1718910`、`63f6e41`、`d110856`、`9bb59f2`、`4dbe09e`、`4fe81e2`、`21e4f2e`、`c9f3924`
  - 顺序（新→旧）：c9f3924(影子比对) → ab168d0 → 1718910 → 63f6e41 → d110856 → 9bb59f2 → **4f1ab4a(scope)** → 4dbe09e → 4fe81e2 → 21e4f2e → **1e14c94(scope)**
- 即 scope 改动夹在 faas-py 改动中间，未与其它分支交叉；`68edaa8` 为此前里程碑点。

### 工作区未提交内容

- 已修改（unstaged）：`.reasonix/desktop-topic-title-sources.json`、`.reasonix/desktop-topic-titles.json`、`reasonix.toml`
- 未跟踪（untracked，大量 docs/tasks）：`docs/TODO-PENDING.md`、`docs/_archived-worktree-residue/`、`docs/dispatch/2026-08-07-coordinator-round/`、`docs/plans/2026-08-19-m4-package-inventory.md`、`docs/plans/2026-08-19-scope-column-audit.md`、`docs/plans/2026-08-19-scope-isolation-decision.md`、`docs/reviews/*`、`docs/storage-*/`、`tasks/PLAN-storage-s1c-full-reconciliation.md`、`firebase/infrastructure/functions-py/tests/test_shadow_compare.py`

### 处置建议（仅报告，不执行）

- 本调研未做任何 cherry-pick / rebase / force-push / stash。
- 如需理顺 interleave，应由负责人决定历史整理时机；SW1 实现前如需基于干净历史工作，可另建功能分支。

---

## 附：调研过程中的已知不确定项

1. **FourZhuDatabase 生产共享主库 executor**：`xuan_shell_dependencies.dart:166` 与裁决书 §1.3 的物理文件表不符。若 SW1 对 four_zhu 做分文件，需先决策「是否继续共享主库 executor」，这影响它到底算「独立库」还是「主库附属」。
2. **Panels 退场判定与裁决书 §三冲突**（见 B 区），需负责人确认。
3. **DaYunRecords/TaiYuanRecords 两份均死**，保留哪份需负责人拍板。
4. TaiYiDatabase 的「双构造」竞态（`xuan_shell_dependencies.dart:202-208`）与分文件改造耦合，需一并设计。
5. `t_record_meta` 无 `divination_uuid` 列（裁决书 §1.6），审计文档中 `→ t_record_meta.divination_uuid` 的引用均无效；但「反查字段」列中 `→ t_record_meta.uuid` 的引用有效。