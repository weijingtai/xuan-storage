# tiebanshenshu 数据 SQL 构建报告

- 构建时间：2026-08-09 23:40:14 UTC
- 构建脚本：assets/tool/build_tiebanshenshu_sql.py
- 源数据：all_tiao_wen_v1.csv（表形 12000 行）+ kao_ke（21 JSON）+ shaozishu（12 TXT）+ formulas（3 JSON）

## 产物

| 文件 | 表名 | 行数 | 字节数 | sha256 |
|---|---|---|---|---|
| tiao_wen.sql | tiao_wen | 12000 | 1645508 | f9978642d783e9a388a99b3b998976e0c5adb9ffd82b05eac558157c08c0234e |
| kao_ke_document.sql | kao_ke_document(文档表) | 21 | 80590 | 73c2d46761555a7c51f919c432f35815015554f94c87c3ddc756ab30973cd57b |
| formulas_document.sql | formulas_document(文档表) | 3 | 29677 | efd9536635545a5b7d1c7b4deb03b3c47a2154e91d2143f1c154c89078f282a5 |
| shaozishu_document.sql | shaozishu_document(文档表) | 12 | 573977 | ff5d448ad192dcb463a3a55b50609b5aaf81b1c5a8855cbf1f1386a80b987895 |

## 验证

- 每个 *.sql 含 BEGIN TRANSACTION / COMMIT：True
- 每个 *.sql 含 CREATE TABLE：是
- 中文（如「一树残花，有枝复茂。」）正确写入 UTF-8，未转义为 \uXXXX

## payloadFormat 决策

| 数据集 | 载荷 | payloadFormat | 理由 |
|---|---|---|---|
| tiebanshenshu.tiao_wen | tiao_wen.sql | prebuilt | 表形（12000 行，id/set_name/content1/age_set1_json），构建期建表，设备上零解析 |
| tiebanshenshu.kao_ke | kao_ke_document.sql | prebuilt（JSON 文档表） | 21 个嵌套 JSON，非表形，按 file_name 整取 |
| tiebanshenshu.shaozishu | shaozishu_document.sql | prebuilt（TXT 文档表） | 12 个地支 txt，整文件存取，消费方按行解析 |
| tiebanshenshu.formulas | formulas_document.sql | prebuilt（JSON 文档表） | 3 个皇极公式 JSON，非表形，按 file_name 整取 |

## 数据质量说明

- tiao_wen 表 age_set1_json 列存 JSON 数组（如 `[47]` / `[21,22]`），空 ageSet 存 NULL（与旧桩 _parseAgeSet 容错逻辑对齐）。
- formulas 以源仓 assets/ 版（huang_ji_formula_manager 在用）为权威；example/ 版已随双副本 git rm。
- kao_ke 以 assets/ 版为权威；example/ 版已随双副本 git rm。

## 幂等性

- 脚本可重复运行，产物可覆盖，结果一致。
