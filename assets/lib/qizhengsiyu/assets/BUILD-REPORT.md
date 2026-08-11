# qizhengsiyu 数据 SQL 构建报告

- 构建时间：2026-08-11 05:18:52 UTC
- 构建脚本：assets/tool/build_qizhengsiyu_sql.py
- 源数据：star_position_status.json（表形 97 行）+ ge_ju/ge_ju_database.sqlite（预构建 SQLite）

## 产物

| 文件 | 表名 | 行数 | 字节数 | sha256 |
|---|---|---|---|---|
| star_position_status.sql | star_position_status | 97 | 15608 | 7d59428dec52ec814b12cc259f0b3d3c7cdb70dc07fdcdefe5918a36c3b6f5bc |
| ge_ju.sql | ge_ju(5表) | 1005 | 532921 | c265f87b85ba3a2c78b45b4fc89998f75018ddd81d4bb9b9c6f163519cb747f0 |
| zhou_tian_document.sql | zhou_tian_document(文档表) | 3 | 9133 | 0d9b7831aa4528019f029495f8871155da885ef244c4bf2f02d2e5aa5dd17b4d |
| ephemeris_document.sql | ephemeris_document(文档表) | 17 | 52577 | 65de841d0d72aeb7b7d13f92c33c5072ae1b229e72f15f374d616624e0e88372 |
| shen_sha_document.sql | shen_sha_document(文档表) | 6 | 48544 | 0d05ff7d53c78581e711f118ea75fba1e29b13164a7a37a2adb805421a8cc9dd |
| hua_yao_document.sql | hua_yao_document(文档表) | 3 | 21594 | 7780c48e0f4aa7fb9fb30a83d97cc9fc77cc8ec9f8ad553b914cdadaaeffdb0e |
| ge_ju_rules_document.sql | ge_ju_rules_document(文档表) | 13 | 235099 | 2ad683c610b29f816ac1bc36a5426a3cf4c5e79af0f0264bb292540db2deaca1 |
| ge_ju_content_document.sql | ge_ju_content_document(文档表) | 13 | 287867 | 70feb55ec2b524459e1f0892fa40a7090a59dad6985f31b9c234383bc388e337 |

## 验证

- 每个 *.sql 不含显式 BEGIN/COMMIT（事务由 drift transaction API 管理，修复 Web/WasmDatabase 嵌套事务冲突，照 tiebanshenshu 0f3c6dd）：True
- 每个 *.sql 含 CREATE TABLE：是
- 每个 *.sql 含 DELETE FROM（重装幂等）：是
- 中文（如「日月夹命」）正确写入 UTF-8，未转义为 \uXXXX

## payloadFormat 决策

| 数据集（草案） | 载荷 | payloadFormat | 理由 |
|---|---|---|---|
| qizheng.star_position_status | star_position_status.sql | prebuilt | 表形（97 行），构建期建表，设备上零解析 |
| qizheng.ge_ju | ge_ju.sql | prebuilt | 源已是预构建 SQLite（5 表），导出为事务包裹 *.sql，照 geo 模式 |
| qizheng.zhou_tian | ecliptic_tropical_*.json ×3 | raw | 嵌套对象（gongOrder/gongDegreeSeq/starInnOrder），非表形 |
| qizheng.ephemeris | 其余星历 JSON（约 18 个） | raw | 嵌套对象/数组（黄道/赤道/恒星/四季），非表形 |
| qizheng.shen_sha / qizheng.hua_yao | 74_shensha_*/74_huayao_* ×9 | raw | 嵌套 LIST（locationMapper 为 map），非表形 |
| qizheng.ge_ju_rules / qizheng.ge_ju_content | ge_ju/rules + content JSON ×26 | raw | 嵌套 variants/conditions，非表形 |

## 数据质量说明

- `ge_ju_rules` 表 `id` 为 AUTOINCREMENT，导出保留显式 id，行级稳定。
- `ge_ju_versions` 表 0 行（源库为空），仍保留建表语句。
- ge_ju 的 rules/content JSON（raw）与 sqlite（prebuilt）可能为同一批格局数据的两种形态，
  消费方目前两者都读；是否冗余待阶段 5 消费方切换时统一判定（记入任务纪要）。

## 幂等性

- 脚本可重复运行，产物可覆盖，结果一致。
