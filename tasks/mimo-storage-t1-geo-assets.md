# 任务: storage-t1-geo-assets
负责: mimo ｜ 分支: agent/mimo/storage-t1-geo-assets ｜ 开工: 2026-08-03
状态: 进行中

## 目标
把分散在 xuan-qizhengsiyu / 奇门遁甲 各处的时间、时区、地址、经纬度数据去重后，
统一收进 xuan-storage 的 `persistence_assets`，并按 XRAP 协议注册为数据集。

## 计划
- [x] 第一步：3 个 JSON 迁入 `assets/lib/geo/` + pubspec 注册（三仓已 commit）
- [x] XRAP 首个接入样板（main `6cd7a66`）：`build_geo_sql.py` + 3 个 *.sql 载荷
      + `geo_datasets.dart` 注册 3 个 DatasetDescriptor + `_GeoSqlMaterializer` 最小实现
- [ ] 注册测试：`registerGeoDatasets` → lookup 验证三个 id 都能查到
- [ ] `_GeoSqlMaterializer` 接真实 drift 落位（当前只消费字节流，不落库）
- [ ] `*.sql` 载荷注册进 `assets/pubspec.yaml` 的 `flutter.assets`
      —— **当前只有 .dart 里引用了 asset path，运行期加载不到**（自报）
- [ ] 领域查询接口抽到 `repository-interface-*` 包
- [ ] 差分测试 / 删旧直读代码的门禁
- [ ] 三个仓库 push

## 验收标准
- [ ] A1 `registerGeoDatasets()` 后三个 id 均可 lookup，manifest 的 sha256/bytes/rowCount 与实际载荷一致
- [ ] A2 `*.sql` 载荷在运行期真的能被加载（不只是 .dart 里写了路径）
- [ ] A3 XRAP 协议一致性门禁 9 条保持绿
- [ ] A4 analyze 门禁三项全绿、core 测试全绿
- [ ] A5 旧的直读代码删除后，七政四余 / 奇门遁甲 两仓仍能跑通

验收命令: bash scripts/run_s1a_analyze_gate.sh && (cd core && flutter test) && bash scripts/run_policy_negative_check.sh

## 当前状态
- 2026-08-04 从 main 工作区迁入本 worktree。迁入时 main 已含 `6cd7a66`，本分支自该提交起。
- 依赖已装（core / assets 均已 `flutter pub get`），三条门禁在本 worktree 内实测可跑。

## 决定记录
- 2026-08-04 人类授权本任务：把七政四余与奇门遁甲里分散的 time / 时区 / 地址 / 经纬度信息去重后集中到 storage 的资源文件。
- 2026-08-04 迁出 main 工作区。理由: 在 main 工作区直接改文件会让 `aiwt done` 的"工作区干净"判定永远为假，从而卡住**所有其他任务**的合并（本轮已因此改用手工合并三次）。已落 main 的 `6cd7a66` 保留不动（门禁实测绿），后续工作一律在本分支。
- 2026-08-04 `assets/pubspec.yaml` 的 `dependency_overrides.persistence_core` 由 git URL 改为 `path: ../core`。影响面有限：`dependency_overrides` 只在该包作为根包时生效，外部仓库消费 assets 时不受影响；且在 worktree 内 `../core` 正确指向本 worktree 的 core，是开发期更合理的解析方式。

## 踩坑墓地
- 2026-08-04: 新建的 worktree 不自带 `.dart_tool/`，此时跑 `dart analyze` 会把每条 `package:` import 报成 `uri_does_not_exist`，产出 500+ 条假 issue。**进 worktree 第一件事是 `flutter pub get`**。门禁脚本已加前置断言会直接拦下（exit 2）。
- 2026-08-04: 任务纪要的「验收命令:」行**不要加 markdown 反引号**。`aiwt` 用 `eval` 执行该行，反引号会被当成命令替换先跑掉。（工具侧已修，但保持无反引号仍是好习惯。）

## 冷冻快照
<仅在搁置时由 /hibernate 填写>
