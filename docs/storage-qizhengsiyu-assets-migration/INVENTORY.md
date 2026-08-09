# 七政四余资源迁移 · 步骤 0 盘点清单（INVENTORY）

> 盘点时间：2026-08-07
> 盘点人：AtomCode（deepseek-v4-flash）
> 源仓：`xuan-qizhengsiyu`（main，HEAD `898fa4e`）
> 目标仓：`xuan-storage`（分支 `feat/qizhengsiyu-assets-xrap`，自 main `c28de62` 开出）
> 依据：`DISPATCH-QIZHENGSIYU-ASSETS-MIGRATION.md` 步骤 0；本清单为「落盘后等人类确认」的门禁件。

---

## 0. 盘点范围与方法

- 范围：`xuan-qizhengsiyu/example/assets/` 全量（git 跟踪文件 2997 个），另查 `companion_system/assets/` 与代码引用。
- 方法：`git ls-files` + `ls -la` 逐个核对大小；`file` 判断格式；`sqlite3` 读 schema/行数；`grep` 全仓搜索 dart 引用确定消费方与端口归属。
- 约定：`端口` 列指 `repository-interface-qizhengsiyu` 接口包中的消费端口（`qizhengsiyu_official_asset_ports.dart` 4 端口 + `qizhengsiyu_ports.dart` 其他端口）。

---

## 1. 资源全量清单（按目录）

### 1.1 `example/assets/qizhengsiyu/` —— 七政四余核心数据（**待迁主体**，56 个 git 跟踪文件）

**顶层 JSON（21 个，星历/星位/黄道/赤道）**

| 文件 | 大小 | 格式 | 用途（依据代码引用） | 端口 |
|---|---|---|---|---|
| star_position_status.json | 13,786 B | JSON 数组 | 星位庙旺状态表（id/className/star/starPositionStatusType/positionList） | QiZhengStarPositionStatusRepository |
| ecliptic_tropical_morden.json | 2,857 B | JSON 对象 | 周天模型（今宿制/回归制），旧实现默认加载列表之一 | QiZhengZhouTianModelRepository |
| ecliptic_tropical_classical.json | 2,897 B | JSON 对象 | 周天模型（古宿制） | QiZhengZhouTianModelRepository |
| ecliptic_tropical_classical_adjusted.json | 2,904 B | JSON 对象 | 周天模型（古宿制校正版） | QiZhengZhouTianModelRepository |
| ecliptic_ancient_365.json | 924 B | JSON | 古黄道 365 度分度 | QiZhengEphemerisResourceRepository（前缀） |
| ecliptic_tuihuangdao.json | 1,040 B | JSON | 黄道退行数据 | 同上 |
| four_season.json | 15,942 B | JSON 数组 | 四季喜忌关系（star → 春/夏/秋/冬 → 喜/忌） | 同上 |
| han_chidao_hengxin.json | 1,285 B | JSON | 汉赤道恒星 | 同上 |
| han_chidao_hengxin.v2.json | 3,044 B | JSON | 汉赤道恒星 v2 | 同上 |
| yuan_chidao_hengxing.json | 1,221 B | JSON | 元赤道恒星 | 同上 |
| yuan_chidao_hengxing.v2.json | 3,047 B | JSON | 元赤道恒星 v2 | 同上 |
| yuan_shoushi_chidao_hengxin.json | 3,855 B | JSON | 元授时赤道恒星 | 同上 |
| yuan_sky_equatorial_sidereal.json | 2,345 B | JSON | 元天赤道恒星 | 同上 |
| ming_si_huangdao_hengxing.json | 1,427 B | JSON | 明四黄道恒星 | 同上 |
| ming_si_huangdao_hengxing.v2.json | 3,099 B | JSON | 明四黄道恒星 v2 | 同上 |
| song_sanchentongzai.json | 3,853 B | JSON | 宋三辰同载 | 同上 |
| huangdao_huigui_gu.json | 1,415 B | JSON | 黄道回归古度 | 同上 |
| huangdao_huigui_gu_corrected.json | 1,409 B | JSON | 黄道回归古度（校正） | 同上 |
| huangdao_huigui_gu_now.json | 1,397 B | JSON | 黄道回归古度（今） | 同上 |
| stars_four_relationship.json | 2,540 B | JSON | 星四关系 | 同上 |
| zheng_shi_xing_an.json | 2,814 B | JSON | 正史星案 | 同上 |

**ge_ju/ 格局数据（35 个）**

| 子目录 | 文件数 | 合计大小 | 说明 |
|---|---|---|---|
| ge_ju/rules/ | 13 | 约 245 KB | 格局规则 JSON（common/ge_ju_2/五行星/格总论等），代码逐文件 rootBundle 引用 |
| ge_ju/content/ | 13 | 约 336 KB | 格局内容 JSON（与 rules 一一对应），代码逐文件引用 |
| ge_ju/backup/ | 8 | 约 336 KB | 格局备份 JSON（五行星/灵台/十三不宜等），**无代码引用** |
| ge_ju/ge_ju_database.sqlite | 1 | 450,560 B | 格局 SQLite（user version 1；5 表：patterns 496 / schools 3 / categories 10 / rules 496 / versions 0），`ge_ju_builtin_database_connection_native.dart:15` 加载 |

### 1.2 `companion_system/assets/` —— 另一份格局库副本

| 文件 | 大小 | 说明 |
|---|---|---|
| ge_ju_database.sqlite | 440 KB（user version 3） | 与 1.1 的 sqlite **sha256 不同**但表结构与行数完全一致（patterns 496 / schools 3 / categories 10 / rules 496 / versions 0）；`companion_system/lib/database/drift_database.dart:23-29` 以 `assets/ge_ju_database.sqlite` 路径加载 |
| ge_ju_condition_spec.md | 文档 | 格局条件说明文档，非数据 |

> ⚠️ **待人类裁定**：同一份格局数据存在两份 sqlite（v1 / v3，sha256 不同），需确认以哪份为权威源，或比对内容后归一。

### 1.3 `example/assets/dataset/` —— 地理/时区域（**不属七政四余，判断不迁**）

| 文件 | 大小 | 格式 | 判断 |
|---|---|---|---|
| geo/（2886 个 .geojson） | 52 MB | GeoJSON 边界 | 行政区划边界（flutter_map 用），**geo 域**；T1 未迁走这些边界文件（git 仍跟踪），但非本任务范围 |
| data.min.json | 3,272,686 B | JSON 数组 | 城市数据（c/n/p/y/a/t 字段，与 T1 已迁的 city.min.json 同构）——geo 域 |
| combined-now.json | 78,602,083 B | JSON（FeatureCollection） | 时区边界（tzid）——**时区域**，78MB 超大 |
| world_country.pro | 5,961,028 B | protobuf | 国家数据（Afghanistan 等）——geo 域 |
| world.sqlite3 | 19,869,696 B | SQLite（cities/countries/regions/states/subregions） | 世界国家/城市库——geo 域 |
| province.min.json | 1,442 B | JSON | 省级精简数据——geo 域 |
| area.min.json | 195,733 B | JSON | 区级精简数据——geo 域 |

> 全仓 dart 代码中**无任何引用**这些 dataset 文件的语句（grep 0 命中）。它们与七政四余排盘无关，属于 geo/时区域，疑似历史遗留或地图渲染数据。**建议不迁**（含 dataset/geo/ 的 2886 个 geojson 边界），但需人类确认。

### 1.4 `example/assets/ephe/` —— 星历表（**禁止擅自处置，待裁定**）

| 文件 | 大小 | 格式 | 说明 |
|---|---|---|---|
| sefstars.txt | 134,207 B | ASCII 文本 | 固定星表（sweph 恒星名表）。⚠️ 注意：example/lib/main.dart:67 初始化的是 `packages/sweph/assets/ephe/sefstars.txt`（sweph 包自带），**未引用** example/assets/ephe/ 下的这份；本仓这份疑似冗余副本 |

> 派工单 §六.7 禁止擅自处置 ephe；实际盘点发现仅 1 个 134KB 文本文件（非二进制、非大文件）。**待人类裁定**：是否冗余可删 / 是否随迁。

### 1.5 `example/assets/shen_sha/` —— 神煞/化曜数据（**派工单列为 UI，代码证据是数据，待裁定**）

| 类别 | 文件数 | 说明 |
|---|---|---|
| 74_shensha_*.json | 6 | 神煞表（tiangan/dizhi_year/dizhi_month/ganzhi/bundle/others），`shen_sha_local_data_source.dart` 与旧实现 `AssetsQiZhengShenShaRepository` 逐文件 rootBundle 引用 |
| 74_huayao_*.json | 3 | 化曜表（tiangan/dizhi/others），`hua_yao_local_data_source.dart` 与 `AssetsQiZhengHuaYaoRepository` 引用 |
| 6_shensha_*.json | 9 | 另一套神煞数据（6 神煞），**无代码引用** |
| huayao_shensha.json | 1 | 化曜神煞合并，无代码引用 |
| incorrect.json | 1 | 疑似废弃，无代码引用 |
| tmp/extracted_names.txt | 1 | 中间产物，非数据 |

> ⚠️ **派工单 §1.4 把 shen_sha/ 归为「UI 资源不迁」，但代码证据表明 74_shensha_*/74_huayao_* 是神煞/化曜**规则数据**，由领域 Repository 消费，符合「数据资源」定义。**待人类裁定**：是否纳入迁移范围；6_shensha 系列与 incorrect.json 是否一并处置。

### 1.6 `example/assets/sql/` —— 初始数据 SQL（**判断不迁**）

| 文件 | 大小 | 说明 |
|---|---|---|
| initial_data.sql | 15,696 B | `t_divination_types` / `t_sub_divination_types` 等业务种子数据（占测类型表），**无代码引用**，属 companion_system 业务库 seed，非 XRAP 数据集 |

### 1.7 UI 资源（**明确不迁**，派工单 §六.8）

| 目录 | 文件数 | 大小 |
|---|---|---|
| planets/ | 18 | 72 KB |
| backgrounds/ | 1 | 448 KB |
| gifs/ | 1 | 5.6 MB |
| lotties/ | 5 | 192 KB |
| icons/ | 40 | 2.9 MB |

### 1.8 `example/assets/tmp/` —— 中间产物（**不迁**）

git 跟踪 1 个（ge_ju_1.txt），其余为未跟踪转换产物。

---

## 2. 数据源缺失报告（派工单 §七 停止条件触发）

1. **`assets/historical_ephemeris/sun_speeds.json` 不存在**：旧实现 `AssetsQiZhengHistoricalEphemerisRepository` 默认路径指向它，但源仓无此目录/文件（全仓 find 0 命中）。
2. **`assets/historical_definitions/` 目录不存在**：`system_definition_local_data_source.dart` 引用 `assets/historical_definitions/$fileName`，但目录不存在。
3. **影响**：`QiZhengHistoricalEphemerisRepository.loadHistoricalEphemeris()` 端口无对应数据可迁。**停下报告，不擅自修源数据、不擅自加接口。**

---

## 3. 归类决策（人类 2026-08-07 已裁定 ✅）

| 类别 | 内容 | 裁定 |
|---|---|---|
| A. 迁入（主体） | qizhengsiyu/ 顶层 21 JSON + ge_ju/rules 13 + ge_ju/content 13 + ge_ju_database.sqlite | 迁入 `assets/lib/qizhengsiyu/assets/`，XRAP 注册 |
| B. 格局库双版本 | example v1 vs companion_system v3 | **以 example v1 为权威源迁入**；companion_system v3 保留原位，其消费方切换记为阶段 5 待切项 |
| C. 迁入（神煞/化曜） | shen_sha/74_shensha_* 6 + 74_huayao_* 3（有代码引用） | **迁入**，注册 qizheng.shen_sha / qizheng.hua_yao；6_shensha_* 9、huayao_shensha.json、incorrect.json 无引用，不迁 |
| D. 不迁 | ge_ju/backup/ 8 JSON（无引用）、ephe/sefstars.txt、dataset/（geo 边界 2886 + 6 大文件）、sql/initial_data.sql | **全部不迁、保持原位**（人类确认） |
| E. 不迁 | UI 五目录、tmp/ | 派工单 §六.8 |
| F. 数据缺失 | historical_ephemeris/sun_speeds.json、historical_definitions/ 不存在 | **本期不注册该数据集**；端口保留旧实现并标注 deprecated，缺失记录入交接报告 |

---

## 4. 数据集规划（草案，待确认后细化）

| datasetId | 载荷来源 | payloadFormat（草案） | 备注 |
|---|---|---|---|
| qizheng.star_position_status | star_position_status.json | prebuilt（表形：id/star/status/positionList） | 对应 StarPositionStatus 端口 |
| qizheng.zhou_tian | ecliptic_tropical_*.json ×3 | raw（非表形：嵌套对象） | 对应 ZhouTianModel 端口 |
| qizheng.ephemeris | 其余星历 JSON（约 18 个） | raw（非表形）或 prebuilt | 对应 EphemerisResource 前缀端口 |
| qizheng.ge_ju | ge_ju_database.sqlite + rules/content JSON | prebuilt（sqlite dump 或逐表 SQL） | 对应 IGeJuRepository / GeJuBuiltInDataSource |
| qizheng.shen_sha / qizheng.hua_yao（若裁定迁） | 74_shensha_*/74_huayao_* | raw | 对应 ShenSha / HuaYao 端口 |

> 表形 vs 非表形、sqlite 走 `raw`(整库) 还是 dump 成 `*.sql`，均按 XRAP §2.2/§4.2 在步骤 2 决策，拿不准记入纪要。

---

## 5. 停止条件检查

- [x] 步骤 0 盘点完成，存在需人类裁定的重大歧义（shen_sha 归类、sqlite 双版本、ephe、dataset 大文件、historical 数据缺失）→ **停在步骤 0，等待人类确认**
- [x] 未动 main、未碰 geo/tiebanshenshu 等已迁模块、未处置 ephe、未迁 UI 资源
- [x] 分支 `feat/qizhengsiyu-assets-xrap` 已建（xuan-storage，自 main `c28de62`）
