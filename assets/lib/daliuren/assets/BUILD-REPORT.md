# daliuren 数据 SQL 构建报告

- 构建时间：2026-08-11 04:17:25 UTC
- 构建脚本：assets/tool/build_daliuren_sql.py
- 源数据：da_liu_ren/ ×5 + shen_sha/6_shensha_* ×9 + dataset/daliuren_dataset.json（全部 JSON 文档表）

## 产物

| 文件 | 表名 | 行数 | 字节数 | sha256 |
|---|---|---|---|---|
| official_data_document.sql | official_data_document(文档表) | 4 | 7228354 | e436e91bc8282f0cbabe7f688eaa16cd961e6790a7413a9d9e988f86daac79c5 |
| keti_document.sql | keti_document(文档表) | 1 | 87321 | 3fb7d328a5a20e4bca9920b38e9a45499604bd444f18e7f8988decb9d20ce5e1 |
| shen_sha_document.sql | shen_sha_document(文档表) | 9 | 138273 | 89522b9a705ceda29fd968e73e8cd802493d858b39ee4298ecb054f3d06e5395 |
| school_dataset_document.sql | school_dataset_document(文档表) | 1 | 584 | 8e75ed2a336341572fcece2418419a52200160151d8e1484640af668be4cd3f1 |

## 验证

- 每个 *.sql 含 BEGIN TRANSACTION / COMMIT：True
- 每个 *.sql 含 CREATE TABLE：是
- 中文（如「御定大六壬」「甲午庚牛羊」）正确写入 UTF-8，未转义为 \uXXXX

## payloadFormat 决策

| 数据集 | 载荷 | payloadFormat | 理由 |
|---|---|---|---|
| daliuren.official_data | official_data_document.sql | prebuilt | 4 份整读 JSON（御定大六壬 1.2MB / ju_mapper / 阳阴盘 2.9MB×2），文档表，repository 读 payload_json 原样返回 |
| daliuren.keti | keti_document.sql | prebuilt | keti_data.json 整读，文档表 |
| daliuren.shen_sha | shen_sha_document.sql | prebuilt | 9 个 6_shensha_*.json 整读，文档表（74_*×9 与 qizhengsiyu 重复，人类裁定不迁） |
| daliuren.school_dataset | school_dataset_document.sql | prebuilt | daliuren_dataset.json（天干/地支），人类裁定迁入，按两个 school 实现 loadEntries |

## 数据质量说明

- keti_data.json 权威 = 源仓 example/ 精简注音版（人类裁定 2026-08-09）；assets/ 带注音版已 git rm。
- 74_shensha_*/74_huayao_* ×9 与 qizhengsiyu qizheng.shen_sha/qizheng.hua_yao 载荷逐字节相同，跨模块重复，人类裁定不迁（qizheng 数据集为权威副本）。
- incorrect.json / huayao_shensha.json（无端口）人类裁定留源仓，未迁。
- initial_data.sql（仅孤儿 Drift 使用）人类裁定留源仓，未迁。

## 幂等性

- 脚本可重复运行，产物可覆盖，结果一致。
