# INVENTORY · M4 ziwei（紫微斗数）资源迁移盘点清单

> 步骤 0 盘点产物｜2026-08-11｜执行 agent：pi（当前会话）
> 复核基准：源仓 `xuan-ziweidoushu` main HEAD `fb9cec5`（**工作区 72 处未提交改动 = 100% `.android/` + `.ios/` 平台目录删除，与资源文件零重叠**，git rm 指定目标文件不卷入）；storage main HEAD `b1daf71`（含 M3 taiyishenshu）
> 依据：`docs/assets-migration/PLAN-REMAINING-MODULES-ASSETS-MIGRATION.md` §四 M4 预盘点（已逐项复核，有修正见 §五）

---

## 一、源仓资源全量清单（`xuan-ziweidoushu/assets/`，共 104KB）

### 1.1 stars.csv（星表，唯一被代码消费的源资源）

| 项 | 值 |
|---|---|
| 路径 | `assets/stars.csv`（10.8KB，108 行 × 9 列） |
| 列结构 | `id(英文), name(中文), description, type(main/lucky/evil/misc), fixed, 排布规则, ?, schools, ?` |
| type 值集合 | `main` / `lucky` / `evil` / `misc` |
| 消费方 | ① 源仓 `lib/main.dart` demo `rootBundle.loadString('assets/stars.csv')`；② `lib/presentation/views/chart_demo/multischool_demo_page.dart` `packages/ziwei/assets/stars.csv`；③ 测试 4 处 `File('assets/stars.csv')`；④ **shell** `AssetsStarCatalogRepository().loadStarCatalogCsv()`（旧桩，读 `packages/ziwei/assets/stars.csv` → `StarCatalog.parse`） |
| 归类 | **迁 + 注册**（`ziwei.star_catalog`，契约 ZiweiStarRepository 数据源） |

### 1.2 assets/data/（6 JSON + .gitkeep）

| 文件 | 字节 | 消费方 | 归类 |
|---|---|---|---|
| `ziwei_stars_main.json` | 8783 | 源仓无代码引用（仅仓库数据）；契约 ZiweiStarRepository.getAllMainStars 潜在数据源（`category: main`，14 主星，含 five_elements/yin_yang/nature/traits/four_transformations/school_comparison） | **迁 + 注册**（`ziwei.star_metadata`） |
| `ziwei_stars_minor.json` | 12810 | 源仓无代码引用；契约 getAllAuxiliaryStars 潜在数据源（`category: minor_auspicious/baleful/miscellaneous`） | **迁 + 注册**（并入 `ziwei.star_metadata`） |
| `ziwei_four_transformations.json` | 4095 | 源仓无代码引用；契约 ZiweiStarRepository.getFourTransformations 数据源（schools: sanhe/feixing/yinpan 三派，sanhe.table 10 天干 × 4 化） | **迁 + 注册**（`ziwei.four_transformations`） |
| `ziwei_star_brightness.json` | 3398 | 源仓无代码引用；**无契约端口**（brightness_map 星曜×十二地支，2D 表；契约 ZiweiStar.brightness 是单值 String?，无 2D 端口） | **D4：物理迁入不注册**（待裁定） |
| `ziwei_palaces.json` | 3486 | 源仓无代码引用；**无契约端口**（契约只有 ZiweiStarRepository 4 方法，无 PalaceRepository；契约有 ZiweiPalace 模型但无读端口） | **D4：物理迁入不注册**（待裁定） |
| `ziwei_charting_algorithm.json` | 7009 | 源仓无代码引用 | **疑似算法配置非数据资源，倾向不迁**（待裁定） |
| `.gitkeep` | 78 | 占位 | 保留（目录需留） |

### 1.3 assets/fixtures/（5 文件，测试证据）

| 文件 | 字节 | 消费方 |
|---|---|---|
| `evidence_manifest.json` | 817 | 源仓 `test/domain/fixture_evidence_test.dart` 直读 |
| `feixing.json` / `heluo.json` / `qintian.json` / `sanhe.json` | 5-11KB | 同上（遍历 `assets/fixtures` 验证证据完整） |

**归类：倾向不迁**（测试证据，非运行时数据资源；但源仓测试 `fixture_evidence_test.dart` 引用它，迁走会让源仓该测试挂——记录待裁定）

---

## 二、storage 现状

- 旧桩 `assets/lib/ziwei/assets_star_catalog_repository.dart`：独立类 `AssetsStarCatalogRepository`，只 `loadStarCatalogCsv()` 返回 CSV 原文（默认 path `packages/ziwei/assets/stars.csv`），**不实现** `ZiweiStarRepository`；barrel 已 export
- 无 drift 表、无 datasets、无 build 脚本、无测试

## 三、接口契约（`repository-interface-ziweidoushu`）

- `ZiweiStarRepository`（`lib/src/ports/ziwei_star_repository.dart`）4 方法：
  - `getAllMainStars()` → `List<ZiweiStar>`
  - `getAllAuxiliaryStars()` → `List<ZiweiStar>`
  - `getStarByName(String name)` → `ZiweiStar?`
  - `getFourTransformations(int tianGanIndex)` → `ZiweiFourTransformations?`（0=甲 … 9=癸）
- 模型：`ZiweiStar{name, category(StarCategory: mainStar/auxiliaryStar/transformationStar/miscellaneousStar), element(StarElement: metal/wood/water/fire/earth), yinYang(StarYinYang: yin/yang), brightness(String?)}`；`ZiweiFourTransformations{tianGanIndex, entries: List<FourTransformationEntry{starName, type(TransformationType: lu/quan/ke/ji)}>}`
- **契约模型无 fromJson**（手写 Equatable，非 freezed）→ Xrap 实现需自行映射 JSON 字段到契约枚举/模型

## 四、shell 消费方现状（`xuan-shell`）

- `lib/storage/shell_scoped_storage_runtime.dart`：`ziweiStarCatalogCsv: await const AssetsStarCatalogRepository().loadStarCatalogCsv()`（旧桩，读 `packages/ziwei/assets/stars.csv`）→ `ModuleManifest.ziweiStarCatalogCsv`（String）
- `lib/modules/ziwei_module_entry_patches.dart`：`createDummyZiweiDependencies` 用 `host.storage.ziweiStarCatalogCsv ?? ''` → `StarCatalog.parse(csv)`（ziwei 自有领域模型）→ 排盘/多派演示
- `ziweidoushu`（ZiweiRecordRepository）已走 persistence_drift，**不在本任务范围**
- **迁移后 stars.csv 从 ziwei 源仓移除 → 旧桩 rootBundle 路径失效 → shell 必须切换新链路**（照 taiyishenshu `_TaiyiXrapSingleton` 模式：`_ZiweiXrapSingleton` + executor 三分文件）

---

## 五、修正与裁定草案（对照 PLAN M4 预盘点）

1. **前置阻塞已消除**：72 处改动全部为 `.android/` + `.ios/` 平台目录删除（未暂存、非资源），git rm 指定目标文件可安全开工，无需人类清理
2. **预盘点遗漏**：`assets/data/ziwei_star_brightness.json` 与 `ziwei_palaces.json` **均无契约端口**（PLAN 草案列为 dataset「待端口确认」→ 实测确认无端口）→ 裁定 **D4 物理迁入不注册**
3. **预盘点待确认项**：`ziwei_charting_algorithm.json`（算法配置）与 `fixtures/`（测试证据）**倾向不迁**，但源仓 `fixture_evidence_test.dart` 引用 fixtures → 保留在源仓可让源仓测试继续绿（待人类裁定）
4. **契约映射**：ZiweiStar category 映射 main→mainStar、minor_auspicious→auxiliaryStar、baleful→auxiliaryStar、miscellaneous→miscellaneousStar；five_elements 金木水火土→metal/wood/water/fire/earth；yin_yang 阴/阳→yin/yang；brightness 单值 → 从 brightness_map 2D 表无单值源，**契约 ZiweiStar.brightness 保持 null**（契约可空）
5. **四化映射**：getFourTransformations(tianGanIndex) 用 sanhe 派表（最通用标准），天干字 `['甲','乙','丙','丁','戊','己','庚','辛','壬','癸'][tianGanIndex]` → `{化禄:lu, 化权:quan, 化科:ke, 化忌:ji}` → 4 条 entries
6. **payloadFormat 裁定**：协议强制内置 payloadFormat 必须 prebuilt（rawText 会被 DatasetRegistry 拒绝，照 taiyishenshu §M3）→ 全部数据集以 **JSON 文档表**（file_name + payload_json）落地：
   - `ziwei.star_catalog`：stars.csv 原文 1 行（payload_json 存 CSV 文本）
   - `ziwei.star_metadata`：stars_main.json + stars_minor.json 2 行
   - `ziwei.four_transformations`：four_transformations.json 1 行
   - palaces / brightness：无端口 → D4 物理迁入 `assets/palaces/`、`assets/brightness/` 不注册

## 六、任务拆分（照 GUIDE 7 步）

| 步骤 | 内容 | 落点 |
|---|---|---|
| 0 | 本盘点 | `docs/storage-ziwei-assets-migration/INVENTORY.md` |
| 1 | 物理迁移 5 文件 + pubspec 注册 | 源仓 git rm + storage assets 物理文件 |
| 2 | build_ziwei_sql.py + 3 SQL 载荷 | storage `assets/tool/` + `assets/lib/ziwei/assets/` |
| 3 | XRAP 注册（manifest + registerZiweiDatasets + materializer） | `assets/lib/ziwei/ziwei_datasets.dart` + drift 三件套 |
| 4 | 注册测试 + 不变式门禁（A1/A2 + XRAP 9 条 + analyze） | `assets/test/ziwei/` |
| 5 | 旧桩收尾：@Deprecated + 新建 `XrapZiweiStarRepository` | `assets/lib/ziwei/xrap_ziwei_repositories.dart` |
| 6 | 跨仓消费方切换（shell `_ZiweiXrapSingleton` + executor 三分文件） | shell worktree |
| 7 | Web 运行时验证 | 人类执行 |

---

## 七、禁止事项（铁律复核）

- 不碰 `.android/` / `.ios/` 工作区删除（git rm 只指定目标资源文件）
- 不改 `repository-interface-ziweidoushu` 契约
- 不碰已迁模块（geo/qizhengsiyu/daliuren/tiebanshenshu/meihuayishu/taiyishenshu）
- fixtures/ 与 charting_algorithm.json 不迁（除非人类裁定）
- 禁止 push（由人类决定）；一切在独立 worktree 分支
