# four_zhu 数据 SQL 构建报告

- 构建时间：2026-08-12 01:51:41 UTC
- 构建脚本：assets/tool/build_four_zhu_sql.py
- 源数据：templates/ 9 JSON（default_template 1 + market_payload 4 + outbox_payload 4，全部 JSON 文档表）

## 产物

| 文件 | 表名 | 行数 | 字节数 | sha256 |
|---|---|---|---|---|
| default_template_document.sql | default_template_document(文档表) | 1 | 19101 | 4ac90dd9de2461ced56ee8a3a8d3690134004da56d54cafe1ef82c477df46c16 |
| market_templates_document.sql | market_templates_document(文档表) | 4 | 97826 | 367cfc024e1dedc137dc9f55bc591b847808dfb1d42dbf270a2cb69853496577 |
| outbox_templates_document.sql | outbox_templates_document(文档表) | 4 | 98880 | 062c3a11697f8c67c43161d3ec16b9866a29ded13c21535c1972cdf5c707196d |

## 验证

- 每个 *.sql 不含显式 BEGIN/COMMIT（事务由 drift transaction API 管理，修复 Web/WasmDatabase 嵌套事务冲突，照 tiebanshenshu 0f3c6dd）：True
- 每个 *.sql 含 CREATE TABLE：是
- 每个 *.sql 含 DELETE FROM（重装幂等）：是
- 中文（如「翻卦」「水法」）正确写入 UTF-8，未转义为 \uXXXX

## payloadFormat 决策

| 数据集 | 载荷 | payloadFormat | 理由 |
|---|---|---|---|
| four_zhu.default_template | default_template_document.sql | prebuilt | 默认模板 1 份整读，文档表，LayoutTemplateContract 映射 |
| four_zhu.market_templates | market_templates_document.sql | prebuilt | 市场模板 4 份整读，文档表，templateId+layoutTemplate 形态 |
| four_zhu.outbox_templates | outbox_templates_document.sql | prebuilt | 出站模板 4 份整读，文档表，layout_template 形态 |

## 数据质量说明

- colors/ 2 份 .pb（zhongguose / forbidden_city，protobuf 二进制）无契约端口，D4 物理迁入不注册数据集（照 ziwei brightness/palaces 先例）。
- 源仓 pubspec 无 assets 块（资源从未被打包），git rm 无需改 pubspec。

## 幂等性

- 脚本可重复运行，产物可覆盖，结果一致。
