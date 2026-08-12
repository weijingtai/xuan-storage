# ziwei 数据 SQL 构建报告

- 构建时间：2026-08-12 00:19:17 UTC
- 构建脚本：assets/tool/build_ziwei_sql.py
- 源数据：stars.csv ×1 + ziwei_stars_main/minor.json ×2 + ziwei_four_transformations.json ×1（全部 JSON 文档表）

## 产物

| 文件 | 表名 | 行数 | 字节数 | sha256 |
|---|---|---|---|---|
| star_catalog_document.sql | star_catalog_document(文档表) | 1 | 11013 | 612e618a89b9d9b2bca1f797fcf647ab1642300fe1eaf6f6984e245384b3e79d |
| star_metadata_document.sql | star_metadata_document(文档表) | 2 | 21947 | 8b8a1f60ff9b3dbfd6f9442395ceca9e2791ebf2af9bf2b3d1cbf906121cae3f |
| four_transformations_document.sql | four_transformations_document(文档表) | 1 | 4390 | 099d1031d4ec1b3539054d7ae8769ea864ac8b7b8548fd3c071d249a25864a32 |

## 验证

- 每个 *.sql 不含显式 BEGIN/COMMIT（事务由 drift transaction API 管理，修复 Web/WasmDatabase 嵌套事务冲突，照 tiebanshenshu 0f3c6dd）：True
- 每个 *.sql 含 CREATE TABLE：是
- 每个 *.sql 含 DELETE FROM（重装幂等）：是
- 中文（如「紫微」「天机」）正确写入 UTF-8，未转义为 \uXXXX

## payloadFormat 决策

| 数据集 | 载荷 | payloadFormat | 理由 |
|---|---|---|---|
| ziwei.star_catalog | star_catalog_document.sql | prebuilt | stars.csv 原文整读 1 行，文档表，shell 读 payload_json 取 CSV 原文（保持 String 接口） |
| ziwei.star_metadata | star_metadata_document.sql | prebuilt | 主辅星 JSON 整读 2 行，文档表，XrapZiweiStarRepository 读后契约映射 |
| ziwei.four_transformations | four_transformations_document.sql | prebuilt | 四化 JSON 整读 1 行，文档表，getFourTransformations 读 sanhe 表 |

## 数据质量说明

- brightness（ziwei_star_brightness.json，2D 星曜×地支表）与 palaces（ziwei_palaces.json，十二宫定义）无契约 Repository 端口（D4），物理保存在 assets/brightness/ 与 assets/palaces/，不注册 dataset。
- ziwei_charting_algorithm.json（算法配置）与 assets/fixtures/（源仓测试证据）未迁，保留在源仓（待人类裁定）。

## 幂等性

- 脚本可重复运行，产物可覆盖，结果一致。
