# qizhengsiyu 数据 SQL 构建报告

- 构建时间：2026-08-08 04:54:12 UTC
- 构建脚本：assets/tool/build_qizhengsiyu_sql.py
- 源数据：star_position_status.json（表形 97 行）+ ge_ju/ge_ju_database.sqlite（预构建 SQLite）

## 产物

| 文件 | 表名 | 行数 | 字节数 | sha256 |
|---|---|---|---|---|
| star_position_status.sql | star_position_status | 97 | 15601 | 243db078fb6681344414e4227ee298a0d309baafd97409265ff4c05cde1825a5 |
| ge_ju.sql | ge_ju(5表) | 1005 | 532740 | 883672801951ed621203676b4c9b93dd461fb8364e6ed4b9e0e308d9dc755c7f |

## 验证

- 每个 *.sql 含 BEGIN TRANSACTION / COMMIT：True
- 每个 *.sql 含 CREATE TABLE：是
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
