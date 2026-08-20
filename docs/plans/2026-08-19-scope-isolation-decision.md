# scope 隔离方案裁决书（SW1 前置）

> 裁决时间：2026-08-19
> 裁决人：项目负责人
> 输入：`2026-08-19-scope-column-audit.md`（59 张无 scope 列表全量审计）+ 本文事实核查
> 效力：本文为 SW1/SW2 派发的唯一方案依据；与审计文档冲突处以本文为准

---

## 一、事实基线（已核实，勿再重查）

### 1.1 handover 已实现，但只覆盖元数据层
`drift/lib/scope/scope_handover.dart` 已有 `DriftScopeHandoverService`：
文件备份 → blob 目录复制 → 主库单事务 UPDATE → 槽位腾空，失败整体回滚。

覆盖表 = `kScopeMigratableTables` 共 8 张，**全是元数据层**：
`t_outbox` / `t_sync_state` / `t_entity_stamp` / `t_record_meta` /
`t_record_search_index` / `t_decision_links` / `t_divination_tags` / `t_blob_meta`

业务明细表一张都搬不了。该文件自身已列 TODO 缺口清单。

### 1.2 待处理的 34 张表分两批，性质不同
| 批次 | 数量 | 能否 JOIN `t_record_meta` 回填 |
|---|---|---|
| 主库内 | ~11 | 能（同库） |
| 独立库 | ~23 | **不能**（跨 SQLite 物理文件） |

### 1.3 共 8 个 Drift 库（1 主 + 7 独立）
| 库 | 定义位置 | 物理文件 |
|---|---|---|
| `PersistenceDriftDatabase`（主） | `persistence_drift.dart:896` | 主库，37 张表，含 `t_record_meta` |
| `AiDatabase` | `ai/ai_database.dart:29` | `ai_database` |
| `FourZhuDatabase` | `four_zhu_card_templates/app_database.dart:19` | ⚠ **生产复用主库 executor**，表落在 `persistence.db`（见 §1.7） |
| `MeiHuaDatabase` | `meihuayishu/meihua_database.dart:12` | — |
| `DictionaryDatabase` | `meihuayishu/dictionary_database.dart:11` | — |
| `ThemeDatabase` | `theme/theme_database.dart:34` | — |
| `TaiYiDatabase` | `taiyishenshu/taiyi_database.dart:31` | `taiyi_database` |
| `AccountDatabase` | `account/account_database.dart:7` | — |

### 1.4 ★ 独立库全部不参与 P2P 同步（已证，无例外）
`outbox` 引用数：ai=0 / meihua=0 / taiyi=0 / account=0 / theme=0。
`four_zhu app_database` 的 4 处 `outbox` 经查是**模板资源文件名**
（`outbox_payload_ink_minimal.json` 等，app_database.dart:132-135），
与同步机制无关。

**推论**：scope 对独立库不是同步正确性问题，仅是「同一台手机换主人」的本机隔离问题。
这是裁决一成立的前提。

### 1.5 部分主库明细表已废弃
- `tables/seekers_table.dart:8`：整表 `@Deprecated: 已迁移至 t_record_meta (module='seeker')`，
  迁移工具 `seeker/seeker_migration.dart`
- `tables/seeker_divination_mappers_table.dart:7`：同上
- `tables/divinations_table.dart:24,31`：部分列 deprecated（非整表）

### 1.6 审计文档已知错误（引用时注意）
- `t_record_meta` **无 `divination_uuid` 列**，只有 `uuid`（`tables/record_meta_table.dart:7`）。
  审计文档 2 处写 `→ t_record_meta.divination_uuid` 无效
- §四 标题「18 张」实际列 20 条；子标题「11 张」实际列 13 条
- §四「独立库表（2 张）」严重低估，实为 ~23 张
- `DaYunRecords` / `TaiYuanRecords` 被主库与 FourZhuDatabase **两库共用**，
  各生成一份物理表，需单独确认哪一份是活的

### 1.7 ★ 本裁决书自身的勘误（据 SW1-0 调研订正）

调研文档 `2026-08-19-sw1-preflight-survey.md` 推翻了本文两处记载，已在上方就地订正：

1. **§1.3 FourZhuDatabase 物理文件写错**：生产装配为
   `AppDatabase(lifecycle.persistenceDb.executor)`（xuan-shell `lib/app/xuan_shell_dependencies.dart:166`），
   即复用主库 executor，四柱卡片表物理上就在 `persistence.db` 里，不是独立的 `app_database.db`。
   **后果**：它归裁决二（同库可 JOIN，加 scope 列），不归裁决一（分文件）。

2. **§三 `Panels` 判为「仍在用」错误**：全仓搜索 `db.panels` / `PanelsDao` / `PanelsCompanion`
   在 shell 侧零引用，`Panels` 已退场，不加 scope 列。

**另据调研，裁决一实际适用面远小于原估**：
- `DictionaryDatabase` 生产是内存库（xuan-shell `lib/app/meihua_dictionary_executor_native.dart:8-10`），纯 G 类，豁免
- `ThemeDatabase` 无任何生产构造点，本轮无存量，属未来项
- `MeiHuaDatabase` 生产已由 `RecordBackedMeiHuaRepository` 接管，仅迁移工具在用
- `TaiYiDatabase` **已随 scope 重建**（在 `rebuildForScope` 内，xuan-shell `lib/storage/shell_scoped_storage_runtime.dart:488`），分文件改造成本最低，但需先解「双构造」竞态
- `AccountDatabase` 裁决一不适用（§四.3）

→ **裁决一真正需要改造的只有 `AiDatabase` 与 `TaiYiDatabase`**。

**主库明细表（裁决二）范围也已收窄**：16 张里 10 张已退场，仍在用的只有案卷创建流 6 张。

---

## 二、裁决一：独立库 → 按 scope 分库文件

**适用范围**：全部 7 个独立库（无例外，依据 §1.4）

**做法**：物理文件名带 scope，如 `ai_database_<scopeUid>.db`。
不加任何 `scope_uid` 列、不改 schema、不写回填脚本。切 scope 即切文件。

**理由**：
- 这批库不参与同步，隔离只需本机生效
- 回填是这批表最大的风险点（跨库无法 JOIN，只能兜底，必然误归），分文件把回填问题整体消除
- schema 零改动，不触碰 7 套独立的版本号与迁移链

**代价（已知并接受）**：
- 同一用户多 scope 时磁盘占用上升
- 纯字典库（`DictionaryDatabase` / `ThemeDatabase` 的 G 类表）按 scope 分文件会重复存储，
  **实现时应豁免纯 G 类库，仅对含 U 类表的库分文件**

**必须处理的三件事**：
1. **已有数据归档**：首次升级时把现存 `ai_database.db` 等改名为
   `<name>_<当前活跃scope>.db`，不得丢弃。改名前必须备份
2. **连接重开**：切换 scope 时需关闭旧连接、按新文件名重开。
   各库当前的构造/注入方式未调研，是 SW1 的首要调研项
3. **`DaYunRecords`/`TaiYuanRecords` 双库共用**：先确认活的是哪一份再动

---

## 三、裁决二：主库 11 张明细表 → 分治

**做法**：
- **已标 `@Deprecated` 的**（`Seekers`、`SeekerDivinationMappers`，及经确认的其他）
  → 走退场路线，**不加 scope 列**。数据已在 `t_record_meta`，而后者已带 `scope_uid` 且已纳入 handover
- **仍在用的**（`DivinationCases`、`DivinationWorkItems`、`CaseParticipants`、`PanelRefs`、`WorkItemPanelRefs`、`CreationAuditLogs` 共 6 张，见 §1.7）
  → 加 `scope_uid` 列，回填后纳入 `kScopeMigratableTables`

**理由**：不给将死的表做会被丢弃的迁移；同时避免「全部退场」阻塞 SW1
（`DivinationCases` 等能否被 `t_record_meta` 完全承载尚未验证）。

⚠ **`Panels` 已订正为「已退场」**：SW1-0 调研全仓搜索确认 shell 侧零引用，不加 scope 列。

**前置（SW1 必须先做）**：逐表确认退场进度——
`@Deprecated` 只是标记，需查实际读写路径是否已切到 record-backed 实现。
标了但仍有活跃写入的表，本轮按「仍在用」处理。

---

## 四、遗留未决

1. 各独立库的连接构造/注入方式未调研 → 裁决一实现前必须补
2. 主库 11 张表的逐表退场进度未确认 → 裁决二实现前必须补
3. `AccountIdentityLinks` 循环依赖存疑：该表在 `AccountDatabase`，
   本身是 scope 判定依据。按裁决一它随库分文件——但决定 scope 的记录若按 scope 分文件，
   启动时无从知道该读哪个文件。**此项裁决一不适用，需单独设计**
4. `AiPersonas` / `LayoutTemplates` / `LlmProviders` / `PromptTemplates` 四张混合表
   （系统内置 + 用户自定义共表）：按裁决一分文件后，内置数据会在每个 scope 文件里重复一份。
   可接受，但 `PromptTemplates` 有 `isBuiltin` 列，可考虑内置部分留在共享库

---

## 五、对 SW1/SW2 的影响

- **SW2 的 JOIN 回填策略只对主库有效**，独立库整体不再需要回填（裁决一消除了该需求）
- 审计文档 §四「无反查字段需单独裁决」的 20 条中，独立库部分已由裁决一解决，
  主库部分由裁决二的分治处理
- `kScopeMigratableTables` 扩充范围 = 裁决二判定为「仍在用」的表
