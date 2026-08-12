# pi-ziwei-assets.md · ziwei（紫微斗数）资源 XRAP 迁移任务书

> 2026-08-11｜执行 agent：pi（当前会话）
> 阅读顺序：本文件 → `docs/storage-ziwei-assets-migration/INVENTORY.md` → `docs/assets-migration/PLAN-REMAINING-MODULES-ASSETS-MIGRATION.md` §四 M4 → `docs/assets-migration/GUIDE-ASSETS-MIGRATION.md`
> 样板：M3 taiyishenshu（同构：JSON 文档表 + 契约零模型耦合 + shell 切换）

## 一、目标

把 `xuan-ziweidoushu/assets/` 的数据资源迁入 `xuan-storage/assets/lib/ziwei/`，按 XRAP 协议注册数据集，新建 `XrapZiweiStarRepository implements ZiweiStarRepository`，shell 消费方切换新链路。

## 二、权威基线

- 源仓 `xuan-ziweidoushu` main `fb9cec5`（工作区 72 处改动 = .android/.ios 删除，**不卷入**）
- storage main `b1daf71`（M3 已合入）
- 契约 `repository-interface-ziweidoushu`：`ZiweiStarRepository` 4 方法（main/auxiliary/byName/fourTransformations），模型手写 Equatable **无 fromJson**

## 三、范围

**迁 + 注册 3 数据集**（全部 JSON 文档表 prebuilt）：
- `ziwei.star_catalog`（stars.csv 原文 1 行）
- `ziwei.star_metadata`（stars_main + stars_minor 2 行）
- `ziwei.four_transformations`（four_transformations.json 1 行）

**D4 物理迁入不注册**：`ziwei_star_brightness.json` → `assets/brightness/`；`ziwei_palaces.json` → `assets/palaces/`

**不迁**（待人类裁定）：`ziwei_charting_algorithm.json`（算法配置）、`assets/fixtures/` ×5（测试证据，源仓测试依赖）

**新建**：`XrapZiweiStarRepository implements ZiweiStarRepository`（4 方法全实现，读文档表 + 契约模型映射，零模型耦合）

**旧桩**：`AssetsStarCatalogRepository` @Deprecated（shell 迁移后不再使用）

## 四、禁止项

- 禁止 push（人类决定）；禁止改契约；禁止碰 .android/.ios 工作区改动（git rm/add 只指定目标文件，**绝不用 `git add -A` / `git commit -am`**）
- 禁止碰已迁模块（geo/qizhengsiyu/daliuren/tiebanshenshu/meihuayishu/taiyishenshu）
- 禁止动 fixtures/ 与 charting_algorithm.json
- 禁止把源仓测试对 stars.csv 的引用改掉（源仓测试不在本任务范围；迁移后源仓相关测试挂属预期，记录报告）

## 五、顺序化任务

1. **worktree**：源仓 `pi-ziwei-assets-rm`（分支 `feat/ziwei-assets-xrap`）+ storage `pi-ziwei-assets`
2. **源仓**：git rm 6 文件（stars.csv + 5 data JSON 除 charting_algorithm）+ 移除 pubspec flutter.assets 3 行注册（assets/stars.csv、assets/data/ 保留 .gitkeep 与 charting_algorithm 需单独列）→ commit
3. **storage 物理**：`assets/lib/ziwei/assets/` 放 stars.csv + stars_main + stars_minor + four_transformations + brightness/ + palaces/
4. **构建脚本**：`assets/tool/build_ziwei_sql.py` → 3 SQL 载荷 + BUILD-REPORT.md
5. **drift 三件套**：`drift/document_tables.dart`（ZiweiDocument 表 3 个：star_catalog/star_metadata/four_transformations）+ `drift/ziwei_database.dart` + `drift/dataset_generations_table.dart` + build_runner 生成 .g.dart
6. **XRAP 注册**：`ziwei_datasets.dart`（_ZiweiManifests + registerZiweiDatasets + ZiweiSqlMaterializer）
7. **Repository**：`xrap_ziwei_repositories.dart`（XrapZiweiStarRepository，4 方法 + CSV 读取辅助供 shell 用）
8. **旧桩**：`assets_star_catalog_repository.dart` @Deprecated（保留但标注）
9. **barrel**：`persistence_assets.dart` 补 export
10. **pubspec**：storage assets pubspec 加 `repository_interface_ziweidoushu` 依赖 + flutter.assets 注册 `lib/ziwei/assets/`
11. **测试**：`test/ziwei/` 注册测试（manifest 真值/重复注册/门禁）+ repository diff 测试（与旧桩 CSV 对比 star 数）
12. **shell 切换**：`_ZiweiXrapSingleton` + executor 三分文件 + shell_scoped_storage_runtime 换用 Xrap 数据（ziweiStarCatalogCsv 改为从 XrapZiweiStarRepository 读 CSV 原文，保持 String 接口不变）
13. **验收**：taiyishenshu 式门禁（A1/A2 + analyze + core + convention）+ 文档更新

## 六、逐步门禁

- 每步 red 就停，向主代理报告
- 源仓 commit 前：`git status` 确认只暂存目标文件（.android/.ios 不出现）
- storage commit 前：`flutter analyze` 无新增 error + 测试绿

## 七、停止条件

- 契约端口不足（如 brightness/palaces 需要读端口）→ 停下报告，不自行扩契约
- 源仓出现资源外改动卷入 → 停下

## 八、最终证据

- 三仓 worktree 分支 commit 号 + `git diff main..feat/ziwei-assets-xrap` 文件清单
- storage `flutter test test/ziwei/` 全绿输出
- shell `flutter analyze` 无新增 error
- INVENTORY.md 已更新裁定结果

## 九、一句话启动语

读 `docs/storage-ziwei-assets-migration/INVENTORY.md` 后按 §五 顺序执行，每步 commit，禁止 push，禁止 `git add -A`。
