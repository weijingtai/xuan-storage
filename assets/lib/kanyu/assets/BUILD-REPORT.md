# kanyu 数据 SQL 构建报告

- 构建时间：2026-08-12 01:06:46 UTC
- 构建脚本：assets/tool/build_kanyu_sql.py
- 源数据：rules/ ×6 + data/ ×16 + schema/ ×2（全部 JSON 文档表）

## 产物

| 文件 | 表名 | 行数 | 字节数 | sha256 |
|---|---|---|---|---|
| rules_document.sql | rules_document(文档表) | 6 | 18216 | c1a5a61f490c15db6df47d5fcc0753f84ce056e0d7b3d4ed22aede51d18ff76c |
| static_data_document.sql | static_data_document(文档表) | 16 | 49191 | 224f47a03f854fb4010eb71521834a495a12bfb9a410280d7d2cdea5dbc385cd |
| schema_document.sql | schema_document(文档表) | 2 | 7150 | 1bb50cf1514c49fa565c89ced342a4884e1e1f56c0406741fd54176a7ca292d9 |

## 验证

- 每个 *.sql 不含显式 BEGIN/COMMIT（事务由 drift transaction API 管理，修复 Web/WasmDatabase 嵌套事务冲突，照 tiebanshenshu 0f3c6dd）：True
- 每个 *.sql 含 CREATE TABLE：是
- 每个 *.sql 含 DELETE FROM（重装幂等）：是
- 中文（如「翻卦」「水法」）正确写入 UTF-8，未转义为 \uXXXX

## payloadFormat 决策

| 数据集 | 载荷 | payloadFormat | 理由 |
|---|---|---|---|
| kanyu.rules | rules_document.sql | prebuilt | Layer B 规则配置 6 份整读，文档表，repository 按 ruleSetId 查 |
| kanyu.static_data | static_data_document.sql | prebuilt | Layer A 静态数据 16 份整读，文档表，rules 的 dataRefs 解析需要 |
| kanyu.schema | schema_document.sql | prebuilt | JSON Schema 校验规格 2 份，文档表，validateConfigPackage 需要 |

## 数据质量说明

- .FIXED.json（8 份未跟踪修正版）未迁，保留源仓（7/31 开发中，待源仓主人提交）。
- CONFIGS-MANIFEST.md（文档）不迁，源仓 git rm 一并删除。

## 幂等性

- 脚本可重复运行，产物可覆盖，结果一致。
