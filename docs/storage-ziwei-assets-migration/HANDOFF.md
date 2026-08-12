# HANDOFF · M4 ziwei 资源迁移（未完成交接 #2）

> 2026-08-11｜交接 agent：pi（预算耗尽触发迭代内交接协议）
> 状态：**storage 迁移代码已基本完成并 commit（2709db0），1 个 analyze error 待修，测试未写，shell 未切换**

## 已完成（本轮）

### 源仓 worktree `xuan-ziweidoushu/.worktrees/pi-ziwei-assets-rm`（分支 feat/ziwei-assets-xrap）
- commit `b7445b0`：git rm 6 文件（stars.csv + 5 data JSON 除 charting_algorithm）+ pubspec 移除 stars.csv 注册
- 保留：charting_algorithm.json + .gitkeep + fixtures/（测试证据）；.android/.ios 72 处工作区删除未卷入 ✓

### storage worktree `xuan-storage/.worktrees/pi-ziwei-assets`（分支 feat/ziwei-assets-xrap）
- commit `2709db0`：完整 XRAP 接入
  - 物理：`assets/lib/ziwei/assets/`（stars.csv、main/minor、four_transformations、brightness/(D4)、palaces/(D4)）
  - `tool/build_ziwei_sql.py` → 3 SQL（star_catalog 11013B/1行、star_metadata 21947B/2行、four_transformations 4390B/1行）+ BUILD-REPORT.md
  - drift 三件套 + `.g.dart`（build_runner 已跑通）
  - `ziwei_datasets.dart`（manifest 真值 sha256：612e61…/8b8a1f…/099d10…，字节/行数见 BUILD-REPORT）
  - `xrap_ziwei_repositories.dart`（XrapZiweiStarRepository 4 方法 + loadStarCatalogCsv）
  - 旧桩 @Deprecated；barrel 4 行 export；pubspec 加 repository_interface_ziweidoushu 依赖 + lib/ziwei/assets/ 注册
- worktree 专属 `assets/pubspec_overrides.yaml`（gitignored，已修 4 级 path：`../../../../xuan-time-location`），`flutter pub get` ✓

## 待办（下一步从这开始）

1. **修 analyze error（阻塞）**：`lib/ziwei/xrap_ziwei_repositories.dart:133` `NotFound` 类不存在（persistence_core 无此类，daliuren 的同名引用来源未证实）。**建议**：改用契约仓 `repository_interface_ziweidoushu` 的 `ZiweiRepositoryError`（code: starNotFound/fourTransformationNotFound，见 lib/src/errors/ziwei_repository_error.dart），替换 2 处 `throw const NotFound('stars.csv')`（133 行）
2. **写测试** `assets/test/ziwei/`（照 taiyishenshu 测试样板）：
   - A1 注册测试：registerZiweiDatasets 后 3 id lookup + manifest sha256/bytes/rowCount 与 BUILD-REPORT 一致 + 重复注册抛 DatasetRegistrationError + fail closed
   - A2 差分：XrapZiweiStarRepository.loadStarCatalogCsv() 输出 == 源 stars.csv 原文（逐字节）；getAllMainStars 14 个、getAllAuxiliaryStars 数量、getFourTransformations(0) 甲 4 条 entries（廉贞/破军/武曲/太阳，lu/quan/ke/ji）
3. **storage 门禁**：`flutter analyze` 无新增 error + `flutter test test/ziwei/` 全绿 → storage commit
4. **shell 切换**（照 taiyishenshu `_TaiyiXrapSingleton` 样板，模板文件在 xuan-shell/lib/app/）：
   - `lib/app/ziwei_database_executor{,_native,_web}.dart`（条件导入，native=NativeDatabase.memory，web=WasmDatabase.inMemory + registerVirtualFileSystem）
   - `lib/storage/shell_scoped_storage_runtime.dart`：`ziweiStarCatalogCsv: await const AssetsStarCatalogRepository().loadStarCatalogCsv()` → 改为 `_ZiweiXrapSingleton` 的 `XrapZiweiStarRepository.loadStarCatalogCsv()`（保持 String 接口不变，StarCatalog.parse 消费不变）
   - shell worktree pubspec_overrides.yaml 指向两个 worktree path（照 M3 模式）
5. **验收**：shell worktree `flutter run -d chrome` 用户自己跑；全绿后人类授权三仓合并（ziweidoushu 1 commit、storage 1 commit、shell 1 commit）+ push + 清理 worktree + Todo.md 勾选

## 关键决策（已核实）

- ziweidoushu 默认分支 **master**（非 main），HEAD detached fb9cec5
- 契约模型手写 Equatable **无 fromJson** → 手写映射（_mapStar/_elementOf/_yinYangOf/_categoryOf）
- category：main→mainStar、minor_auspicious/baleful→auxiliaryStar、misc→miscellaneousStar
- 四化：sanhe 派表，`['甲'..'癸'][tianGanIndex]`，化禄/权/科/忌→lu/quan/ke/ji（4 条 entries）
- **ZiweiStar.brightness 恒 null**（源 brightness_map 是 2D 表，契约单值无端口，D4）
- star_metadata 文档表 2 行（main/minor 各一行），getAllMainStars 过滤 category=='main'，getAllAuxiliaryStars 过滤 minor_auspicious/baleful
- storage worktree 深度差 4 级：assets → ../../../../xuan-time-location

## 禁止

- push（人类决定）；改契约；碰已迁模块；git add -A 于源仓（.android/.ios 会卷入）；动 fixtures/charting_algorithm
