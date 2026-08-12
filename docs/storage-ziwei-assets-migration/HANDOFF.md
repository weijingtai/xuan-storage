# HANDOFF · M4 ziwei 资源迁移（未完成交接 #3）

> 2026-08-11｜交接 agent：pi（预算耗尽触发迭代内交接协议）
> 状态：**三仓全部完成：storage 19 测试全绿 + analyze 全绿；shell 切换完成（56e376c，analyze 0 error）；worktree overrides 已建（用户 flutter run 报 xuan_xiang path 错已修）。待用户 Chrome 验证 + 授权合并**

## 已完成

### 源仓 worktree `xuan-ziweidoushu/.worktrees/pi-ziwei-assets-rm`（feat/ziwei-assets-xrap）
- `b7445b0`：git rm 6 文件 + pubspec 移除 stars.csv 注册

### storage worktree `xuan-storage/.worktrees/pi-ziwei-assets`（feat/ziwei-assets-xrap）
- `2709db0`：XRAP 接入（物理迁入 + build_ziwei_sql.py + 3 SQL + drift 三件套 + ziwei_datasets + XrapZiweiStarRepository + 旧桩 Deprecated + barrel/pubspec）
- `372a439`：测试（A1 注册 + A2 差分 19 全绿）+ 修 NotFound→ZiweiRepositoryError + 修 installer import
- 后续小 commit：lint 清理（去 drift 未用 import）
- **storage analyze 全绿（65 issue 为基线）+ `flutter test test/ziwei/` 19 全绿 + `flutter test` 全量仅 qizhengsiyu ephemeris 3 失败（main 既有，M3 已记录）**

### shell worktree `xuan-shell/.worktrees/pi-ziwei-assets`（feat/ziwei-assets-xrap，main=7d0d26a 新建）
- commit（本交接）：`lib/app/ziwei_database_executor{,_native,_web}.dart` 三分文件（照 taiyishenshu 样板，createZiweiDatabaseExecutor）
- **未提交（工作区）**：`lib/storage/shell_scoped_storage_runtime.dart` 已加 4 行 import（ziwei datasets/database/installer/xrap + ziwei_database_executor）

## 待办（下一步从这开始）

1. **shell_scoped_storage_runtime.dart 补 `_ZiweiXrapSingleton`**（照 `_TaiyiXrapSingleton` 样板，插在 188 行 `_TaiyiXrapSingleton` 类结束后）：
   - static future + get() + _create()（catch 清 _future rethrow）
   - _create：`ZiweiDatabase(await createZiweiDatabaseExecutor())` + `ZiweiDriftDatasetInstaller(db:, bundledSource: BundledDatasetSource())` + `registerZiweiDatasets(db:)` + `XrapZiweiStarRepository(db:, installer:)`
2. **换 `ziweiStarCatalogCsv` 装配**（512-513 行）：
   - `ziweiStarCatalogCsv: await const AssetsStarCatalogRepository().loadStarCatalogCsv()` → `ziweiStarCatalogCsv: await (await _ZiweiXrapSingleton.get()).loadStarCatalogCsv()`
   - （ModuleStoragePorts.ziweiStarCatalogCsv 是 String，接口不变，StarCatalog.parse 消费不变；旧桩 AssetsStarCatalogRepository 源仓已删文件会挂，必须换）
   - 若 `_ziweiXrap` 还需存变量供别处用则加，但当前只有这一处消费
3. **shell worktree pubspec_overrides.yaml**（gitignored）指向两个 worktree path（照 M3 模式）：
   - `persistence_assets: path: ../../../xuan-storage/.worktrees/pi-ziwei-assets/assets`
   - `ziwei: path: ../../../xuan-ziweidoushu/.worktrees/pi-ziwei-assets-rm`（注意 shell pubspec 里 ziwei 依赖名可能是 `ziweidoushu` 或 `ziwei`，看 pubspec.yaml）
   - `xuan_xiang: path: ../../../xuan-xiang`（照 M3）
   - `flutter pub get`
4. **shell 编译验证**：`flutter analyze` 无新增 error（基线 87 issue）
5. **用户验证**：shell worktree 目录 `flutter run -d chrome`（**必须 worktree 目录**，主工作区 git URL 拿不到新代码）
6. 全绿后人类授权：三仓合并（ziweidoushu 1 commit → master；storage 2 commit → main；shell 2-3 commit → main）+ push（ziweidoushu/storage 双远端 gitea+github，shell 仅 gitea）+ 恢复 shell pubspec_overrides 为 git URL + 清理 3 个 worktree + 分支 + Todo.md 勾选 M4

## 关键决策（已核实）

- storage 全链路：star_catalog(1 行 CSV)/star_metadata(2 行)/four_transformations(1 行) 文档表；brightness/palaces D4 物理；charting_algorithm/fixtures 不迁
- XrapZiweiStarRepository 用契约 ZiweiRepositoryError（非 NotFound，那是 daliuren 契约的）
- ziwei 默认分支 master；契约模型手写 Equatable 无 fromJson（手写映射）
- shell pubspec 依赖名需确认：`grep ziwei pubspec.yaml`

## 禁止

- push（人类决定）；改契约；碰已迁模块；git add -A（源仓 .android/.ios 会卷入）；动 fixtures/charting_algorithm
