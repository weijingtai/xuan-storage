# 铁板神数资源迁移 · 步骤 0 盘点清单（INVENTORY）

> 盘点时间：2026-08-09
> 盘点人：AtomCode（deepseek-v4-flash）
> 源仓：`xuan-tiebanshenshu`（main，HEAD `785556e`，工作区干净）
> 目标仓：`xuan-storage`（分支 `feat/tiebanshenshu-assets-xrap`，自 main `99ead53` 开出）
> 依据：`PLAN-REMAINING-MODULES-ASSETS-MIGRATION.md` §四 M6；本清单为「落盘后等人类确认」的门禁件。

---

## 0. 盘点范围与方法

- 范围：`xuan-tiebanshenshu/assets/` + `example/assets/` 全量（git 跟踪），另查 `lib/` 中 rootBundle 引用确定消费方。
- 方法：`git ls-files` + `ls -la` 核对；`cmp` 比对双副本与 storage 已迁副本；`wc`/`shasum` 取 CSV 统计；`grep` 全仓搜索 dart 引用确定消费方与端口归属。
- 约定：`端口` 列指 `repository-interface-tiebanshenshu` 接口包中的消费端口（`tiao_wen_repository.dart` / `tiao_wen_local_data_source.dart`）。

---

## 1. 源仓资源全量清单

### 1.1 `assets/` —— 铁板神数核心数据（待迁主体）

| 资源 | 大小 | 格式 | 用途（依据代码引用） | 端口 |
|---|---|---|---|---|
| all_tiao_wen_v1.csv | 570,680 B（12000 行） | CSV（无表头） | 条文全文库，`AssetsTiaoWenRepository` 直读 | `TiaoWenRepository`（11 方法） |
| kao_ke/（21 JSON） | 136 KB | JSON | 考课数据，`liu_du_table_repository.dart` 逐文件 rootBundle | ❌ 无端口（D4 不注册） |
| shaozishu/（12 txt） | 576 KB | TXT | 少子术条文，`shaozi_tiao_wen_repository.dart` 按地支逐文件读 | ❌ 无端口（D4 不注册） |
| formulas/（3 JSON） | 32 KB | JSON | 皇极公式，`huang_ji_formula_manager.dart` 逐文件读 | ❌ 无端口（D4 不注册） |
| icons/icon_list.json | 4.0 KB | JSON | 图标清单 —— **UI 资源，不迁** | - |

### 1.2 `example/assets/` —— 双副本

| 资源 | 与 assets/ 比对 | 与 storage 已迁副本比对 |
|---|---|---|
| all_tiao_wen_v1.csv | IDENTICAL | IDENTICAL |
| kao_ke/（21） | IDENTICAL | IDENTICAL |
| formulas/（3） | IDENTICAL | IDENTICAL |
| shaozishu/ | **example 下无此目录**（仅 assets/ 一份） | - |

> 全部 `cmp` 验证 IDENTICAL，无内容分歧 → 按 D2 任选一份为权威，两份都 `git rm`。

### 1.3 storage 已迁状态（37 文件已物理迁入，无 XRAP）

`xuan-storage/assets/lib/tiebanshenshu/`：
- `assets/all_tiao_wen_v1.csv`（570,680 B，sha256 `5f7031146c2dfdefaadec270f91167c9d9fcd7a92066813a38f4415d9707464c`）
- `assets/kao_ke/` 21、`assets/shaozishu/` 12、`assets/formulas/` 3
- pubspec 已注册 4 项：`lib/tiebanshenshu/assets/shaozishu/`、`kao_ke/`、`formulas/`、`all_tiao_wen_v1.csv`
- 旧桩 `assets_tiao_wen_repository.dart`（`AssetsTiaoWenRepository`），barrel 已 export
- ❌ 无 `*_datasets.dart` / 无 drift / 无 installer —— **本任务核心缺口**

---

## 2. CSV 结构与解析要点（差分硬骨头）

- 格式：`id,setName,content1,[ageSet1]`，无表头，每行一条。
- 列数分布：3 列 4905 行（无 ageSet），4 列 7095 行（ageSet 形如 `(47)` / `(21 22)`）。
- 示例：`1001,子,一树残花，有枝复茂。,(47)`、`1002,子,寄人廊庙，何如自立门户。`（无 ageSet）。
- 旧桩解析（`_splitCsvLine` + `_parseCsvLine`）：逗号切分 → `DiZhi.values.firstWhere(name == setNameStr || toString().contains(setNameStr))` 模糊匹配；ageSet 括号容错。
- **取舍（待人类确认）**：
  - 方案 A（完整）：CSV→drift 表，repository 用 SQL 实现 11 方法，差分对照旧桩。
  - 方案 B（务实）：CSV→drift 表存原始行，repository 读表后保留旧解析逻辑内存处理。PLAN 建议 B。

---

## 3. 数据集草案

| datasetId | 载荷 | payloadFormat | 落地形态 | 端口 |
|---|---|---|---|---|
| `tiebanshenshu.tiao_wen` | all_tiao_wen_v1.csv | prebuilt | CSV→表（逐行 INSERT，照 geo JSON→表 改 CSV 解析） | `TiaoWenRepository`（11 方法） |
| `tiebanshenshu.kao_ke` | kao_ke/21 | - | ❌ 不注册 dataset（D4 无端口），物理文件保留 | - |
| `tiebanshenshu.shaozishu` | shaozishu/12 | - | ❌ 不注册（D4），物理保留 | - |
| `tiebanshenshu.formulas` | formulas/3 | - | ❌ 不注册（D4），物理保留 | - |

---

## 4. 消费方清单（源仓）

| 消费方 | 读取路径 | 现状 |
|---|---|---|
| `lib/main.dart:29` | `AssetsTiaoWenRepository(dataPath: kDefaultTiaoWenAssetPath)` → `packages/persistence_assets/lib/tiebanshenshu/assets/all_tiao_wen_v1.csv` | **已指向 storage** |
| `lib/features/huang_ji_formula_manager.dart:33-35` | `packages/persistence_assets/lib/tiebanshenshu/assets/formulas/...` | **已指向 storage** |
| `lib/features/kao_ding_liu_qin/repositories/liu_du_table_repository.dart:127` | `assets/kao_ke/...` | 源仓相对路径，**待切** |
| `lib/shaozishu/repository/shaozi_tiao_wen_repository.dart:49` | `assets/shaozishu/...` | 源仓相对路径，**待切** |
| `test/tiao_wen_repository_test.dart` | `assets/all_tiao_wen_v1.csv` | 测试用源仓路径，**待切** |
| `example/lib/main.dart:47` | storage 路径 | 已指向 storage |

---

## 5. 接口契约（repository-interface-tiebanshenshu）

- `TiaoWenRepository`（abstract，11 方法）：getById / getByIdsWithPageRange / listAll / search / getCount / getAroundById / getByIntervalAroundId / getByIdRange / getByIdList / getTiaoWenContentByNumbers / getTiaoWenContentByNumber
- `TiaoWenLocalDataSource`（abstract，6 方法）：loadAll / getById / getByIdList / getByIdMap / search / getCount
- kao_ke / shaozishu / formulas **无对应端口** → 按 D4 **不注册 dataset**，在交接报告记录「待 repository-interface-tiebanshenshu 补端口后接入」，不擅自加接口。
- 数据模型 `TiaoWenDataModel`：id / setName(DiZhi) / content1 / content2? / ageSet1? / ageSet2?

---

## 6. 待人类裁定事项

1. **CSV 解析方案 A vs 方案 B**（PLAN 建议 B：先确保数据落 XRAP 表 + 注册，解析逻辑渐进迁移；但需人类确认）。
2. kao_ke / shaozishu / formulas 按 D4 不注册 dataset（物理保留）—— 请确认是否接受。
3. 源仓 git rm 范围：`assets/` + `example/assets/` 双副本全部删除（含 CSV/kao_ke/formulas/shaozishu，icon_list.json 保留），分支 `feat/tiebanshenshu-assets-xrap`，commit message 含禁令。

---

## 7. 后续步骤（确认后执行）

1. 步骤 1：源仓 git rm 双副本（worktree + feat 分支）；storage 侧 pubspec 已注册无需改
2. 步骤 2：`assets/tool/build_tiebanshenshu_sql.py`（CSV→SQL）+ BUILD-REPORT.md
3. 步骤 3：`tiebanshenshu_datasets.dart` + drift 表 + installer + `XrapTiaoWenRepository`（按方案 A/B 实现 11 方法）
4. 步骤 4：注册测试 + A1/A2 验收 + 门禁全绿
5. 步骤 5：旧桩 `@Deprecated` 标注 + 消费方切换清单
6. 输出：任务纪要 / INVENTORY / BUILD-REPORT / 交接报告
