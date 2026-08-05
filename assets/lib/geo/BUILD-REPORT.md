# geo 数据 SQL 构建报告

- 构建时间：2026-08-04 05:18:31 UTC
- 构建脚本：assets/tool/build_geo_sql.py
- 源数据：3 个 JSON（保留在原位，未改动）

## 产物

| 文件 | 表名 | 行数 | 字节数 | sha256 |
|---|---|---|---|---|
| admin_division.sql | admin_division | 3515 | 517853 | cbb337c627436a4d877f01dfa651d3eaf5c970ad4f9ae98b5566dbb26590d83e |
| region.sql | region | 6 | 2614 | aeb0032c68a19e8e10d10dae6292c8274330b8705d793bd0227421d17a5ed91d |
| city.sql | city | 337 | 34626 | 98bea3dcf0cf04b6d227f6caf6b676880a25195dc5c7349b212e38dbb6c05917 |

## 验证

- INSERT 语句数与源 JSON 条数对比：一致
- 每个 *.sql 含 BEGIN TRANSACTION / COMMIT：True
- 每个 *.sql 含 CREATE TABLE：是
- 每个 *.sql 经 SQLite3 重新 executescript 验证语法正确：通过
- 中文（如「北京市」）正确写入 UTF-8，未转义为 \uXXXX

## 数据质量说明

- `admin_division` 源 JSON 中有 **146 条记录**的 `latitude` / `longitude` 为空字符串（源数据本身缺失，非构建引入）。构建脚本将其转为 SQL `NULL`，不影响行数自检（I4 按行数不按字段完整性）。
- `city` 表（337 行）与 `admin_division` 表（3515 行）可能存在数据重叠（接通设计 Q1 未决）。当前决定：作为独立 dataset `geo.city` 接入，待人类确认是否冗余后再决定去留。

## 幂等性

- 脚本可重复运行，产物可覆盖，结果一致。
