# 任务: atomcode-qizhengsiyu-assets

负责: AtomCode ｜ 分支: feat/qizhengsiyu-assets-xrap ｜ 开工: 2026-08-07
状态: 步骤 0 盘点完成，等人类确认

## 目标

把七政四余的数据类资源（星历/星位/格局/神煞）从 `xuan-qizhengsiyu/example/assets/` 迁入
`xuan-storage/assets/lib/qizhengsiyu/`，按 XRAP 协议注册为数据集，使消费方走
DatasetRegistry -> DatasetInstaller -> drift 落库 -> 领域 Repository 取用，而非 rootBundle 直读。
照 T1 geo 样板（commit `6cd7a66` 之后的 `assets/lib/geo/`）执行。

## 计划（每个阶段带 hand-off，阶段完成即停手等人类确认/审阅）

- [x] 阶段 0a：读派工单 + 全部参考文档（XRAP 协议、T1 geo 样板代码、T1 纪要、T1 状态报告、接口契约、旧实现、pubspec）
- [x] 阶段 0b：全量盘点 `example/assets/`，归类决策草案，落盘 `docs/storage-qizhengsiyu-assets-migration/INVENTORY.md`
- [x] 阶段 0c：建分支 `feat/qizhengsiyu-assets-xrap`（xuan-storage，自 main c28de62），落盘本任务纪要
- [ ] **HAND-OFF 0**：人类确认盘点归类 + 6 项待裁定项（shen_sha 归类 / sqlite 双版本 / dataset 大文件 / ephe / backup / historical 缺失）后才允许进入阶段 1
- [ ] 阶段 1：物理迁移 + pubspec 注册（照 T1 第一步）——复制文件到 `assets/lib/qizhengsiyu/assets/`、源仓 git rm + commit（message 含禁令）、注册 pubspec、flutter pub get、最小 rootBundle 加载测试
- [ ] **HAND-OFF 1**：人类确认迁移清单与源仓删除 commit 后再进阶段 2
- [ ] 阶段 2：构建脚本 + *.sql 载荷（照 build_geo_sql.py）——表形数据 build_qizhengsiyu_sql.py；非表形数据按 XRAP §2 决策 raw/prebuilt；产出 BUILD-REPORT.md
- [ ] **HAND-OFF 2**：人类确认 payloadFormat 决策与 BUILD-REPORT 后再进阶段 3
- [ ] 阶段 3：XRAP 注册（照 geo_datasets.dart）——DatasetDescriptor/Manifest/Materializer + drift 表 + 安装器 + 领域 Repository 实现接口包端口
- [ ] **HAND-OFF 3**：人类确认注册代码后再进阶段 4
- [ ] 阶段 4：注册测试 + 不变式门禁（A1/A2 + XRAP 9 条 + analyze 三项 + core/assets 测试）
- [ ] **HAND-OFF 4**：人类确认验收 8 条逐条证据后再进阶段 5
- [ ] 阶段 5：旧实现收尾（删除或 deprecated 标注 + 消费方清单），写交接报告到 `~/Downloads/storage_refactor/MIGRATION-QIZHENGSIYU-ASSETS-REPORT.md`
- [ ] **HAND-OFF 5**：人类最终审阅，push 由人类决定

## 盘点清单（摘要，全文见 INVENTORY.md）

- A. 明确迁入：qizhengsiyu/ 顶层 21 JSON + ge_ju/rules 13 + ge_ju/content 13 + ge_ju_database.sqlite(v1)
- B. 待裁定：companion_system sqlite(v3) 与 v1 归一；ge_ju/backup 8 个无引用 JSON
- C. 待裁定：shen_sha/（74_shensha 6 + 74_huayao 3 有代码引用；6_shensha 9 等无引用）——派工单列为 UI 但代码证据是数据
- D. 待裁定：ephe/sefstars.txt（134KB 文本，疑似冗余副本，example/lib/main.dart 实际用 sweph 包自带）
- E. 判断不迁（待确认）：dataset/（geo 边界 2886 + data.min.json + combined-now.json 78MB + world_country.pro + world.sqlite3 + province/area.min.json）、sql/initial_data.sql
- F. 明确不迁：UI 五目录（planets/backgrounds/gifs/lotties/icons）、tmp/

## 数据源缺失（停止条件触发，已报告）

- `assets/historical_ephemeris/sun_speeds.json` 不存在（旧实现默认路径指向它）
- `assets/historical_definitions/` 目录不存在（system_definition_local_data_source.dart 引用）
- 影响：QiZhengHistoricalEphemerisRepository 端口无数据可迁。不擅自修源数据、不擅自加接口。

## 数据集规划（草案）

| datasetId | 载荷 | payloadFormat 草案 |
|---|---|---|
| qizheng.star_position_status | star_position_status.json | prebuilt（表形） |
| qizheng.zhou_tian | ecliptic_tropical_*.json ×3 | raw（非表形） |
| qizheng.ephemeris | 其余星历 JSON ×18 | raw（非表形） |
| qizheng.ge_ju | ge_ju_database.sqlite + rules/content | prebuilt（sqlite dump 成 SQL） |
| qizheng.shen_sha / qizheng.hua_yao | 74_shensha_*/74_huayao_*（若裁定迁） | raw |

## 决定记录

- 2026-08-07 派工单 + 参考文档读毕；盘点完成；分支已建；INVENTORY.md 落盘。
- 2026-08-07 人类裁定（4 项，均已写入 INVENTORY.md §3）：
  1. shen_sha/ 按数据资源迁入：只迁有代码引用的 74_shensha_* 6 个 + 74_huayao_* 3 个，注册 qizheng.shen_sha / qizheng.hua_yao；6_shensha_* 9 个等无引用文件不迁。
  2. 格局 SQLite 以 example v1（example/assets/qizhengsiyu/ge_ju/ge_ju_database.sqlite）为权威源迁入；companion_system v3 保留原位，其消费方切换记为阶段 5 待切项。
  3. 不迁项全部确认：dataset/（geo 边界 2886 + 6 大文件）、ephe/sefstars.txt、ge_ju/backup/ 8 JSON、sql/initial_data.sql 均保持原位。
  4. historical_ephemeris / historical_definitions 数据缺失：本期不注册该数据集；旧实现端口标注 deprecated，缺失记录入交接报告。
- 2026-08-07 待人类确认执行项（阶段 1 开工门禁）：源仓 xuan-qizhengsiyu 删除已迁文件需在哪个分支 commit（该仓当前在 main，且项目铁律要求主分支操作须人类下令）。
- 2026-08-07 人类裁定执行项：源仓也开新分支 `feat/qizhengsiyu-assets-xrap` 做删除 commit（已执行，commit 4f559f7）。
- 2026-08-07 HAND-OFF 1 确认：人类确认进入阶段 2，并授权回退误落分支。
- 2026-08-07 分支事故（已处置）：阶段 1 commit 曾误落 `feat/s3c-c-webrtc-impl`（共享工作区被并发任务切换所致），已 cherry-pick 归位到 `feat/qizhengsiyu-assets-xrap`（4ea6a36），误落 commit 经人类授权回退移除。此后改用独立 worktree `.worktrees/atomcode-qizhengsiyu-assets` 工作（派工单环境铁律 §八.5）。
- 2026-08-07 阶段 2 完成（commit 150930c）：payloadFormat 决策——
  - prebuilt：qizheng.star_position_status（97 行表）、qizheng.ge_ju（sqlite 5 表 1005 行导出 *.sql）
  - raw：qizheng.zhou_tian（ecliptic_tropical_*.json ×3）、qizheng.ephemeris（其余星历 JSON）、qizheng.shen_sha / qizheng.hua_yao（74_* ×9）、qizheng.ge_ju_rules / qizheng.ge_ju_content（rules/content JSON ×26，非表形）
  - 待阶段 5 判定：ge_ju 的 rules/content JSON（raw）与 sqlite（prebuilt）可能为同批数据的两种形态，消费方目前两者都读。
- 2026-08-07 阶段 2 修订（commit 0b37ea3）：人类裁定非表形数据以「JSON 文档表」落地（file_name + payload_json），满足协议 prebuilt 硬约束（DatasetRegistry 拒绝内置 rawText，dataset_protocol_test.dart:180-186 锁定）。6 个文档表统一 `_document` 后缀避免与 ge_ju.sql 表名冲突；8 个 *.sql 全部通过 sqlite3 重放 + 同库共存验证。
- 2026-08-07 阶段 3 完成（commit 97c9768）：XRAP 注册 8 个 DatasetDescriptor + QizhengSqlMaterializer；drift 13 表 + QizhengsiyuDatabase（schemaVersion 1）；DriftDatasetInstaller；XrapQiZheng*Repository 实现接口包 6 端口（StarPositionStatus / ZhouTian / EphemerisResource / ShenSha / HuaYao / GeJuBuiltInDataSource）。dart analyze lib/qizhengsiyu 零 issue。工作区切换独立 worktree 后需建 gitignored `assets/pubspec_overrides.yaml`（照 geo worktree 抄录，路径深度 +2）。

## 踩坑墓地

- 2026-08-07 盘点时发现派工单 §1.4 称 dataset/geo 已在 T1 迁走，但实际 `xuan-qizhengsiyu` git 仍跟踪 2886 个 geojson（52MB）——这些是 flutter_map 边界数据，非 T1 迁走的 4 个 JSON（province_city_area_lng_lat/regions/city.min/timezones）。判断：仍不属本任务范围，需人类确认。
- 2026-08-07 `example/assets/ephe/` 实际只有 sefstars.txt（文本非二进制），与派工单描述的「sweph .se 二进制大文件」不符；example/lib/main.dart 引用的是 sweph 包自带副本。

## 验收标准（照派工单 §五，阶段 4 逐条以机器输出为证）

- [ ] A1 registerQizhengDatasets() 后所有 id 可 lookup，manifest sha256/bytes/rowCount 与实际载荷一致
- [ ] A2 *.sql/JSON 载荷运行期真能被加载（rootBundle 测试通过）
- [ ] A3 XRAP 协议一致性门禁 9 条保持绿
- [ ] A4 analyze 门禁三项全绿、core + assets 测试全绿
- [ ] A5 旧直读代码删除/标注后，xuan-qizhengsiyu 仓仍能跑通（或明确列出消费方待切）
- [ ] A6 源仓已迁文件不再被 git 跟踪（git ls-files 0 条），commit message 含禁令
- [ ] A7 pubspec flutter.assets 已注册新目录
- [ ] A8 BUILD-REPORT.md 含每个产物 sha256/bytes/rowCount

验收命令: bash scripts/run_s1a_analyze_gate.sh && (cd core && flutter test) && (cd assets && flutter test) && bash scripts/run_monorepo_convention_check.sh

## 禁止动作（派工单 §六，违反即判废）

1. 禁止在 main 上改任何东西 2. 禁止碰 assets/lib/geo/ 3. 禁止碰 assets/lib/tiebanshenshu/、assets/lib/daliuren/ 等已迁模块
4. 禁止改 repository-interface-qizhengsiyu 契约 5. 禁止改 pubspec 依赖版本（只加 flutter.assets 注册项）
6. 禁止 push（本地 commit 即可）7. 禁止擅自处置 ephe/ 8. 禁止迁 UI 资源
9. 禁止改 xuan-storage 的 core/drift/firebase/p2p 包 10. 禁止 git push --force / stash drop / 破坏性操作
