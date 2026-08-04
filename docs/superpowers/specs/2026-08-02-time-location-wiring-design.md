# 时区地点功能接通 · 设计与施工

- 日期：2026-08-02
- 状态：草案，待人类拍板 Q1–Q4
- 范围：`xuan-shell` / `xuan-time-location` / `persistence_assets`
- 性质：**一次具体施工**，同时作为 XRAP 协议的首个接入样板
- 上位规格：
  - [XRAP 资源资产协议](2026-08-02-resource-asset-protocol.md)（下称《协议》）
  - [Storage 分层隔离存储架构设计总纲](2026-07-31-storage-architecture-design.md)（下称《总纲》）

---

## 0. 一句话结论

**功能不通的直接原因是一个文件不存在。**

```dart
// xuan-shell/lib/app/xuan_shell_app.dart:85
final geoRepo = GeoLocationRepository(path: 'assets/geo_data.json');
```

- `xuan-shell/assets/` 下**没有** `geo_data.json`（实查：只有 `ephe/` `qizhengsiyu/` `shen_sha/` `themes/`）；
- `xuan-shell/pubspec.yaml:211-216` 的 assets 声明里**也没有**它；
- 真实数据躺在 `xuan-qizhengsiyu/example/assets/dataset/province_city_area_lng_lat.json`（444K，3515 条）与 `xuan-qimendunjia/example/assets/dataset/`（同一份的第二个副本）。

因此运行时 `rootBundle.loadString` 抛异常 →
`GeoLocationRepository.loadLocationsFromAssets` 抛 `Exception('加载地理位置数据失败')`
（`xuan-time-location/lib/src/datasource/geo_location_repository.dart:69`）→ 地点选择不可用。

**DI 链路本身是通的，不需要新建。** 见 §1。

---

## 1. 现状核实（全部为实查，非推断）

### 1.1 DI 链路已经存在且完整

```
xuan_shell_app.dart:85          创建 GeoLocationRepository（注入点，已存在）
   │
   ▼
CreationLaunchPage.geoRepo      creation_launch_page.dart:19,29
   │
   ▼
CreationLaunchViewModel         creation_launch_viewmodel.dart:14,18,20
   │
   ▼
实际调用                         creation_launch_page.dart:363-364
                                 await _vm.geoRepo.loadLocationsFromAssets();
                                 final locations = await _vm.geoRepo.getAllLocations();
```

**修正一个此前的误判**：`GeoLocationRepository` 并非孤儿代码。它在 `xuan-time-location` 包内确实零使用，但 shell 侧有完整的注入与调用（上表）。此前只 grep 了 time-location 包内，结论有误，现更正。

### 1.2 `GeoLocationRepository` 的能力与数据是匹配的

`geo_location_repository.dart:52-59` 解析的字段：
`code` / `parentCode` / `level` / `name` / `latitude` / `longitude`

`province_city_area_lng_lat.json` 的实际字段：
`{"code":"110000","parentCode":"0","level":"1","name":"北京市","latitude":"39.90364","longitude":"116.4121"}`

**逐字段对得上。** 所以这份数据就是它要的数据，只是位置不对、且文件名不同（`geo_data.json` vs `province_city_area_lng_lat.json`）。

已有查询方法（`geo_location_repository.dart`）：
按级别列（:80）、按省列市（:86）、按市列县（:94）、按 code 取（:103）、
取子级（:109）、按名搜（:117）、取完整地址路径（:127）。

### 1.3 时区与地点是两条独立的线

`TimezoneLocationViewModel`（22.5K）**零处引用 `GeoLocation` / `GeoLocationRepository` / `rootBundle`**。它处理的是：

- `Location` —— 来自 `timezone` 包的**时区**类型（:105 `locationListNotifier`、:107 `myLocationNotifier`）
- `FlutterTimezone.getLocalTimezone()`（:183）—— 系统时区
- `SharedPreferences`（:189）—— 用户已选偏好

而 `GeoLocation`（行政区划，带经纬度）是另一套类型。

**两条线目前没有桥。** 用户选了「北京市朝阳区」之后，如何得到时区，这一步不存在。见 §4。

### 1.4 资源现状

| 文件 | 体积 | 位置 | 用途 |
|---|---|---|---|
| `province_city_area_lng_lat.json` | 444K / 3515 条 | qizhengsiyu + qimendunjia 的 example，**两份副本** | 国内省市县，`GeoLocationRepository` 消费 |
| `regions.json` | 4K / 6 条 | 同上 | **洲**（Africa/亚洲/…），对应 `RegionDataSet` |
| `city.min.json` | 20K / 337 条 | 同上 | 疑似 province_city_area 的子集，**待确认是否冗余** |
| `timezones.json` | 184K | 同上 | **已废弃**（人类确认），不迁移 |

`regions.json` 的字段 `{id, name, translations, wikiDataId}` 与 `wikiDataId` 的存在表明它来自
**`dr5hn/countries-states-cities-database`**（开源，ODbL）。这是 §4 选型的关键线索。

---

## 2. 施工分三阶段，各自可独立验收

阶段 A 立即解阻塞；B 做协议对齐；C 补齐国际时区能力。**A 不依赖 B/C**。

---

## 3. 阶段 A · 解阻塞（最小改动，今天可完成）

### A1 资源归位

把 `province_city_area_lng_lat.json` 与 `regions.json` 迁入 `persistence_assets`：

```
xuan-storage/assets/lib/geo/
  province_city_area_lng_lat.json
  regions.json
```

理由（《协议》§0.1）：资源的物理位置应与「谁拥有它」一致。它们不属于奇门或七政，是**跨模块共享的基础数据**，归 `persistence_assets` 统一持有。

### A2 shell 接线修正

```dart
// xuan_shell_app.dart:85 —— 改路径，指向 persistence_assets 的包内资源
final geoRepo = GeoLocationRepository(
  path: 'packages/persistence_assets/lib/geo/province_city_area_lng_lat.json',
);
```

路径形态参照既有惯例：
`assets/lib/tiebanshenshu/assets_tiao_wen_repository.dart:567` 的
`kDefaultTiaoWenAssetPath = 'packages/persistence_assets/lib/tiebanshenshu/assets/all_tiao_wen_v1.csv'`。

同时 `persistence_assets/pubspec.yaml` 需声明该 assets 目录。

### A3 删除旧副本

删除 qizhengsiyu 与 qimendunjia 的 `example/assets/dataset/` 下的对应文件。

⚠️ **前置确认**：这两个 example 是否真的在用它们。若 example 自身的演示需要，应改为依赖 `persistence_assets`，而不是保留副本。
> 依据：《协议》§3 第 7 项与 §3.2 —— 不带删除门禁的迁移只会制造第 N+1 份副本。

### A4 验收

| # | 判据 | 验证方式 |
|---|---|---|
| A-V1 | shell 启动 → 创建流程 → 地点选择可列出省市县 | 手动 + widget 测试 |
| A-V2 | `getAllLocations()` 返回 3515 条 | 单测 |
| A-V3 | 旧路径文件已删除 | `grep -rn "example/assets/dataset/province_city"` 期望零命中，**且须同时写 EXPECT_STDOUT 与 EXPECT_EXIT**（《协议》§8.2 纪律 1） |
| A-V4 | 全仓 `province_city_area_lng_lat.json` 恰好 1 份 | `find` 计数断言 == 1 |

---

## 4. 阶段 C · 国际时区（需要新数据，先说清缺什么）

> 顺序上 C 与 B 独立，此处先写是因为它决定数据形态。

### 4.1 缺的是国家表

人类已确认：**时区按所在国家选择即可**。

现有 `regions.json` 只有 6 个**洲**，不够。需要的是同一数据集的下一层：

**数据集**：`dr5hn/countries-states-cities-database`
**文件**：`countries.json`（约 250 条，1–2 MB）
**层级**：`regions(6) → countries(250) → states → cities`

关键字段：

```jsonc
{
  "id": 44,
  "name": "China",
  "iso2": "CN",
  "region_id": 3,                    // ← 与现有 regions.json 的 id 对应
  "translations": { "zh-CN": "中国", ... },   // ← 与 RegionDataSet 同构
  "timezones": [                     // ← 需要的就是这个
    { "zoneName": "Asia/Shanghai", "gmtOffset": 28800, "abbreviation": "CST" }
  ]
}
```

选它的理由：与现有 `regions.json` **同源**，`region_id` 天然衔接，`translations` 结构与既有 `RegionDataSet`（`regions.dart:3-51`）一致，中文名直接可用。

### 4.2 一个必须在 UI 上处理的分支

**多数国家只有 1 个时区，少数国家有多个。**
中国 `timezones` 数组只有 `Asia/Shanghai`（1 项）；美国、俄罗斯有多项。

因此选国家后：
- `timezones.length == 1` → 直接确定，不打扰用户；
- `timezones.length > 1` → 需要二次选择。

**这个分支必须在 UI 设计中体现，不能假设一国一时区。**

### 4.3 与国内省市县的关系

**两套体系不要混**：

| 体系 | 数据 | 用途 |
|---|---|---|
| 国际 | `regions` + `countries` | 选国家 → 得时区 |
| 国内 | `province_city_area_lng_lat` | 选省市县 → 得经纬度（真太阳时需要） |

国内选址得到的是**经纬度**，用于真太阳时修正；国际选国得到的是**时区**。二者用途不同，不是替代关系。

---

## 5. 阶段 B · 协议对齐（把 A 的临时形态变成协议形态）

阶段 A 让功能通了，但 `GeoLocationRepository` 有三个与《协议》冲突的地方，B 阶段修正。

### B1 抽出接口（当前它不可替换、不可测试）

```dart
// geo_location_repository.dart 现状
static GeoLocationRepository? _instance;              // :7  单例
static List<GeoLocation>? _cachedLocations;           // :8  静态缓存
final String jsonString = await rootBundle.loadString(geoLocationPath);  // :30 直接读 asset
```

三个问题：
1. **静态单例** —— 无法注入 fake，测试互相污染（与 `AssetsTiaoWenRepository` 同一个病）；
2. **直接读 rootBundle** —— 违反《协议》N1「模块自行读 asset」；
3. **具体类** —— 无法替换实现，将来接 XRAP 时要改所有调用点。

修正：抽出接口放**接口包**（不依赖 `persistence_core`，《总纲》§0.1:51），
`GeoLocationRepository` 降级为该接口的一个实现。

现成范本：`repository-interface-tiebanshenshu/.../tiao_wen_local_data_source.dart:12`。

### B2 接入 XRAP 作为 bundled 世代

按《协议》§3 交付七项，其中：

- `datasetId`: `geo.admin_division`（国内省市县）、`geo.country`（国家表）、`geo.region`（洲）
- `carriers`: 均为 `{Carrier.row}`（都要按字段查询）
- `schemaRevision`: 1
- `DatasetMaterializer`: 把 JSON 落成 drift 行

**接入后 shell 的注入点签名不变** —— 这是《协议》P1 的兑现：

```dart
// A 阶段
final geoRepo = AssetGeoLocationRepository(path: '...');
// B 阶段之后
final geoRepo = XrapGeoLocationRepository(installer: datasetInstaller);
// CreationLaunchPage / ViewModel 一行不改
```

### B3 验收

| # | 判据 |
|---|---|
| B-V1 | **差分测试**：新实现与 A 阶段实现在全部 7 个查询方法上逐字段相等（《协议》§8.4 A2） |
| B-V2 | 安装全过程 outbox 零新增（《协议》I6） |
| B-V3 | 冷启动零网络请求（《协议》P4），用计数式 spy 验证 |
| B-V4 | 旧的直读 asset 代码已删除（《协议》§3 第 7 项） |

---

## 6. 遗留问题与待拍板

| # | 问题 | 状态 |
|---|---|---|
| Q1 | `city.min.json`（337 条）是否为 `province_city_area` 的冗余子集？ | **待确认**。若是，删除，不作为独立数据集 |
| Q2 | 两个 example 是否真的在用这些资源？删除后会不会坏？ | **待确认**，A3 的前置 |
| Q3 | 国家表数据由谁提供？ | 人类提供，方向见 §4.1 |
| Q4 | 选国家得到时区后，如何接入现有真太阳时链路？ | **未查证**。`default_moment_resolver.dart` 我尚未读，衔接点不明 |

### 6.1 我尚未核实的事

- `default_moment_resolver.dart`（7.4K）未读，因此 Q4 无法回答。
- `TimezoneLocationViewModel` 的 10 个外部消费方（shell 的 creation_flow、各模块的
  `*_timezone_provider_adapter.dart`）我只确认了存在，**未逐个读**。B 阶段改接口形状前必须逐个核实影响面。
- `city.min.json` 与 `province_city_area` 的实际关系未比对（Q1）。

---

## 7. 与 XRAP 协议的关系

本次施工是《协议》的**首个接入样板**，验证三件事：

1. **bundled 世代路径可用** —— 不依赖 endpoint 与签名等未决项（《协议》§10.1）；
2. **注入点签名跨阶段不变** —— A 阶段与 B 阶段的 shell 代码相同，兑现 P1；
3. **七项交付清单可执行** —— 若某一项在真实场景下无法交付，说明协议要改。

**反向约束**：若本次施工发现协议某条规则不可执行，应回头修改《协议》而非在此打特例。
这正是《协议》§0.2「改协议而非考古」的运作方式。
