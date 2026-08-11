# taiyishenshu 数据 SQL 构建报告

- 构建时间：2026-08-11 23:13:31 UTC
- 构建脚本：assets/tool/build_taiyishenshu_sql.py
- 源数据：schools/ ×3（kebab 精简契约）+ deities/ ×47 + minggua/ ×1（全部 JSON 文档表）

## 产物

| 文件 | 表名 | 行数 | 字节数 | sha256 |
|---|---|---|---|---|
| schools_document.sql | schools_document(文档表) | 3 | 3878 | cfb13ade0c988dbcad650482502cd3007e7369635040995aee974e10476bc343 |
| deities_document.sql | deities_document(文档表) | 47 | 31609 | 36eeee338abbfcbfab69afc502e5c7ca7cb8fcadee63a00976d7d70558d5ca50 |
| minggua_document.sql | minggua_document(文档表) | 1 | 912 | 9fb441277e4f686c15ee7cceaadea3164c9deb9071e5e9cb753348b51877a0fb |

## 验证

- 每个 *.sql 不含显式 BEGIN/COMMIT（事务由 drift transaction API 管理，修复 Web/WasmDatabase 嵌套事务冲突，照 tiebanshenshu 0f3c6dd）：True
- 每个 *.sql 含 CREATE TABLE：是
- 每个 *.sql 含 DELETE FROM（重装幂等）：是
- 中文（如「集成派」「太乙」）正确写入 UTF-8，未转义为 \uXXXX

## payloadFormat 决策

| 数据集 | 载荷 | payloadFormat | 理由 |
|---|---|---|---|
| taiyi.schools | schools_document.sql | prebuilt | 3 份精简学派 JSON 整读，文档表，repository 读 payload_json 再契约 fromJson |
| taiyi.deities | deities_document.sql | prebuilt | 47 份神将 JSON 整读，文档表 |
| taiyi.minggua | minggua_document.sql | prebuilt | tong_zong_sequence.json 整读，文档表（人类裁定迁入，MingGuaRepository 端口） |

## 数据质量说明

- schools 命名双写是**两套数据**：kebab 小文件（ji-cheng 629B 等）= 精简 School 契约（id/name/source/epoch/deityIds），snake 大文件（ji_cheng 7514B 等）= 全量学派文档（schemaVersion/meta/palace/rules/charts/dun/...）。本脚本只注册 kebab 3 份；snake 5 份（ji_cheng/jing_mirror/tong_zong/fu_ying/tao_jin_ge）无契约端口（D4），物理保存在 assets/schools/ 供后续接入，不注册 dataset。
- nian_ming_gua/sixty_four_gua_stems.json（64 卦年命卦配置）无契约 Repository 端口（D4），物理保存在 assets/nian_ming_gua/，不注册 dataset。

## 幂等性

- 脚本可重复运行，产物可覆盖，结果一致。
