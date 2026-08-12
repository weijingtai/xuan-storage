# HANDOFF · M4 ziwei 资源迁移（未完成交接）

> 2026-08-11｜交接 agent：pi（预算耗尽触发迭代内交接协议）
> 状态：**步骤 0 盘点完成并落盘，worktree 已建，代码迁移未开工**

## 已完成

1. **盘点落盘**（storage main，commit `XXXX` 待确认 —— 实际提交信息 `docs(ziwei): M4 盘点落盘 INVENTORY + 任务书（待开工）`，含 2 文件）：
   - `xuan-storage/docs/storage-ziwei-assets-migration/INVENTORY.md`
   - `xuan-storage/tasks/pi-ziwei-assets.md`
2. **worktree 已建**（分支均 `feat/ziwei-assets-xrap`）：
   - 源仓 `xuan-ziweidoushu/.worktrees/pi-ziwei-assets-rm` @ `bee2af2`（注意：ziweidoushu 默认分支是 **master** 不是 main，HEAD 原 detached at fb9cec5 = master 前一个）
   - storage `xuan-storage/.worktrees/pi-ziwei-assets` @ `b1daf71`

## 关键结论（已核实，直接可开工）

- **前置阻塞已消除**：源仓 72 处未提交改动 = 100% `.android/` + `.ios/` 平台目录删除，与资源零重叠，git rm 指定文件安全
- **契约**：`ZiweiStarRepository` 4 方法（getAllMainStars/getAllAuxiliaryStars/getStarByName/getFourTransformations），模型手写 Equatable **无 fromJson** → Xrap 实现需手写 JSON→契约映射
- **3 数据集裁定**（全部 JSON 文档表 prebuilt，照 M3 taiyishenshu 样板）：
  - `ziwei.star_catalog`：stars.csv 原文 1 行（shell 旧桩 `AssetsStarCatalogRepository.loadStarCatalogCsv` 读 `packages/ziwei/assets/stars.csv` → 迁移后路径失效，shell 必须切换）
  - `ziwei.star_metadata`：stars_main.json + stars_minor.json 2 行
  - `ziwei.four_transformations`：four_transformations.json 1 行（用 sanhe 派表，天干 `['甲'..'癸'][index]`，化禄/权/科/忌 → lu/quan/ke/ji）
- **D4 物理迁入不注册**：`ziwei_star_brightness.json` → `assets/brightness/`；`ziwei_palaces.json` → `assets/palaces/`（均无契约端口）
- **不迁**：`ziwei_charting_algorithm.json`（算法配置）、`assets/fixtures/` ×5（源仓 `test/domain/fixture_evidence_test.dart` 依赖，保留可保源仓测试绿）
- **category 映射**：main→mainStar、minor_auspicious/baleful→auxiliaryStar、miscellaneous→miscellaneousStar；five_elements 金木水火土→metal/wood/water/fire/earth；yin_yang 阴/阳→yin/yang；**ZiweiStar.brightness 保持 null**（契约单值无 2D 端口源）

## 未完成（下一步执行序）

1. 源仓 worktree：`git rm` 6 文件（stars.csv + 5 data JSON 除 charting_algorithm，保留 .gitkeep）+ 移除 pubspec flutter.assets 注册（`assets/stars.csv` 与 `assets/data/` 两行，注意 data/ 目录还有 charting_algorithm 与 .gitkeep → 需改为只注册剩余文件或整体移除）→ commit
2. storage worktree 物理迁入 `assets/lib/ziwei/assets/`（stars.csv、stars_main/minor、four_transformations、brightness/、palaces/）
3. `tool/build_ziwei_sql.py` 照 `build_taiyishenshu_sql.py` → 3 SQL + BUILD-REPORT.md
4. drift 三件套（document_tables/database/generations）+ build_runner .g.dart
5. `ziwei_datasets.dart`（manifest sha256 从 BUILD-REPORT 取，三处真值同步：datasets/BUILD-REPORT/测试）
6. `xrap_ziwei_repositories.dart`（XrapZiweiStarRepository 4 方法 + 暴露 CSV 原文供 shell 复用，保持 shell `ziweiStarCatalogCsv: String` 接口）
7. 旧桩 @Deprecated + barrel export + pubspec（加 repository_interface_ziweidoushu 依赖 + `lib/ziwei/assets/` 注册）
8. 测试（A1 注册 + A2 差分 vs 旧桩 CSV 原文）
9. shell 切换（`_ZiweiXrapSingleton` + executor 三分文件照 taiyishenshu_database_executor 样板）
10. 门禁（analyze + storage flutter test + core + convention）+ 验收

## 停止条件

- 契约端口不足 → 停
- 源仓 git rm 卷入 .android/.ios → 停（绝不用 git add -A）

## 禁止

- push（人类决定）；改契约；碰已迁模块；动 fixtures/charting_algorithm
