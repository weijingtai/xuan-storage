# geo 域数据集（XRAP 首个接入样板）

本目录是 XRAP 资源资产协议的**首个接入样板**，承载时间/地点/城市相关的基础数据。

## 数据集

| datasetId | 物理载荷 | 表名 | 行数 | 说明 |
|---|---|---|---|---|
| `geo.admin_division` | `admin_division.sql` | `admin_division` | 3515 | 国内省市县经纬度 |
| `geo.region` | `region.sql` | `region` | 6 | 洲（Africa/Asia/...） |
| `geo.city` | `city.sql` | `city` | 337 | 城市精简数据 |

## 数据来源与迁移

数据原分散在 `xuan-qizhengsiyu/example/assets/dataset/` 与
`xuan-qimendunjia/example/assets/dataset/` 两处，**逐文件 sha256 完全相同**
（两份副本）。已去重迁入本目录，源副本已从两个仓库删除。

`timezones.json`（TopoJSON 时区边界）经人类确认废弃，未迁入，备份在
`~/Downloads/timezones.json`。时区能力将走接通设计 §4 的 `countries.json`
路线（选国家->得时区），数据待人类提供，不在本样板范围。

## 载荷形态：*.sql（prebuilt）

按 XRAP §4.2 / D3，内置世代必须是构建期做好的落地形态（`prebuilt`），
设备上零解析。本样板的载荷是 `*.sql` 文件（`CREATE TABLE` + `INSERT` 语句，
事务包裹），由构建脚本从源 JSON 产出。

`DatasetPayloadFormat.prebuilt` 的语义已涵盖 `*.sql`（构建期已完成字段映射
与表结构设计，设备侧执行即恢复表，不再做语义解析）。见
`core/lib/model/dataset/dataset_manifest.dart` 注释。

## 构建脚本

`assets/tool/build_geo_sql.py` -- 幂等，可重复执行。

```
python3 assets/tool/build_geo_sql.py
```

流程：读 JSON -> 插入内存 SQLite3（中间步骤，保证 SQL 语法正确）->
导出 `*.sql`（CREATE TABLE + INSERT，事务包裹）。

改了源 JSON 后必须重跑脚本，并同步更新 `geo_datasets.dart` 里的
manifest 真值（sha256/bytes/rowCount），否则安装期 sha256 校验失败（I3）。
真值见 `BUILD-REPORT.md`。

## 接入代码

`geo_datasets.dart`:
- `registerGeoDatasets()` -- 装配期调用，注册 3 个 `DatasetDescriptor`
- `_GeoSqlMaterializer` -- `DatasetMaterializer` 实现（当前最小形态）

## 当前形态与待办（诚实声明）

本样板是 XRAP 接入的**第一步**，验证了「注册 + lookup + 载荷完整性」链路。
以下尚未完成，属后续阶段：

- **Materializer 未接真实 drift 落位**：当前 `materialize()` 只消费字节流
  返回 rowCount，不写 drift 表。真实数据访问需补 `ResourceDatasetDatabase`
  （§9.1）+ drift 表 + 索引。
- **领域查询接口未抽包**：按 §3 第 5 项 / N5，接口应放
  `repository-interface-*` 包，不依赖 `persistence_core`。当前接口藏在
  materializer 内，是临时形态。
- **差分测试**（§8.4 A2）：新实现 vs 旧 `GeoLocationRepository` 逐字段相等。
- **删旧直读代码门禁**（§3.2 / N6）：`xuan-time-location` 的
  `GeoLocationRepository` 仍直接读 asset（违反 N1），需改为走 XRAP，并加
  grep 门禁断言旧路径消失。

## city.min.json 冗余说明 ⚠️

`city.min.json`（337 行）与 `province_city_area_lng_lat.json`（3515 行）
可能存在数据重叠（接通设计 Q1 未决）。

**当前决定**（2026-08-04，人类授权）：作为独立 dataset `geo.city` 接入，
**不删除**。待人类确认是否冗余后再决定去留：
- 若确认冗余 -> 删除 `geo.city` dataset + `city.sql` + `city.min.json`
- 若确认独立 -> 保留，补领域查询接口

此决定已记录于 `BUILD-REPORT.md` 与本文件。

## 数据质量说明

`admin_division` 源 JSON 有 **146 条记录**的 `latitude` / `longitude` 为
空字符串（源数据本身缺失）。构建脚本将其转为 SQL `NULL`，不影响行数自检
（I4 按行数不按字段完整性）。
