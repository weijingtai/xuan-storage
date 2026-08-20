# 59 张无 scope_uid 列 Drift 表全量分类与反查关系审计表

> **生成时间**：2026-08-19  
> **审计目标**：为 SW1/SW2（scope 列迁移）提供准确、经验证的表清单与分类判据，绝不省略任何行。

---

## 一、59 张表全量分类盘点表

| 表名 | 证据(文件:行号) | 分类(U/G/S/R/?) | 判断理由 | 反查字段(仅U类) |
|---|---|---|---|---|
| AccountIdentityLinks | account/account_identity_links_table.dart:9 | U | 用户匿名账号与注册账号的身份绑定关系 ⚠ 存疑：本表为 scope 判定依据，加列可能形成循环依赖，待架构裁决 | 无（本身为 scope 判定依据） |
| AgentInvocations | ai/tables/tables.dart:514 | U | 用户在会话中触发的 Agent 调用历史与结果 | sessionUuid → AiChatSessions.uuid |
| AiApiCalls | ai/tables/tables.dart:348 | U | 用户对话过程中产生的底层 API 请求与响应 | sessionUuid → AiChatSessions.uuid |
| AiChatMessages | ai/tables/tables.dart:303 | U | 用户与 AI 对话产生的具体消息记录 | sessionUuid → AiChatSessions.uuid |
| AiChatSessions | ai/tables/tables.dart:271 | U | 用户的 AI 对话会话根记录 | divinationUuid → t_record_meta.divination_uuid |
| AiDivinations | ai/tables/tables.dart:458 | U | 用户针对特定占测请求生成的 AI 解读与评分反馈 | divinationUuid → t_record_meta.divination_uuid |
| AiPersonas | ai/tables/tables.dart:216 | ? | 混合表：包含系统内置人设(G)与用户自定义人设(U) | — |
| AiProvenances | ai/tables/tables.dart:407 | U | AI 生成内容的完整溯源快照与审计链 | 无（多态 entityUuid，无法稳定直接 JOIN） |
| AiTools | ai/tables/tables.dart:626 | G | 系统内置的 AI 工具 Schema 与执行器配置字典 | — |
| AiUsageAudits | ai/tables/tables.dart:569 | U | 具体用户的 Token 消耗与费用使用审计 | 无（多态 entityUuid，无法稳定直接 JOIN） |
| BlobChunks | blob/blob_tables.dart:93 | S | 系统底层分块索引，由 cipherManifestId 归属 BlobMeta | — |
| BlobRefs | blob/blob_tables.dart:123 | R | 业务记录对 Blob 的多对多引用表（跟随主表 t_record_meta，U 类） | ownerRecordUuid → t_record_meta.uuid |
| CardTemplateMetas | four_zhu_card_templates/four_zhu_tables.dart:71 | U | 用户自定义四柱卡片模板的元数据与作者记录 | 无（templateUuid 指向缺 scope 的 LayoutTemplates） |
| CardTemplateSettings | four_zhu_card_templates/four_zhu_tables.dart:91 | U | 用户针对卡片模板的个性化排版与显示设置 | 无（templateUuid 指向缺 scope 的 LayoutTemplates） |
| CardTemplateSkillUsages | four_zhu_card_templates/four_zhu_tables.dart:108 | U | 用户在排盘查询中使用卡片模板的历史记录 | queryUuid → t_record_meta.uuid |
| CaseParticipants | divination_case/case_participants_table.dart:3 | U | 案卷中的求测人与参与者角色绑定关系 | 无（caseUuid 指向缺 scope 的 DivinationCases） |
| Characters | meihuayishu/dictionary_tables.dart:5 | G | 梅花字典汉字库，随包分发的只读参考数据 | — |
| CombinedDivinations | tables/combined_divinations_table.dart:6 | U | 用户创建的组合/复合排盘记录 | divinationUuid → t_record_meta.uuid |
| CreationAuditLogs | divination_case/creation_audit_logs_table.dart:5 | U | 案卷草稿编辑与保存的历史审计日志 | 无（caseUuid 指向缺 scope 的 DivinationCases） |
| DaYunRecords | tables/da_yun_records_table.dart:4 | U | 八字排盘中的大运计算结果记录 | sourceUuid → t_record_meta.uuid |
| DivinationCalendars | tables/divination_calendars_table.dart:4 | U | 对应用户排盘的历法基准时间记录 | 无（sourceUuid 为多态字段，无法稳定 JOIN） |
| DivinationCases | divination_case/divination_cases_table.dart:3 | U | 占卜案卷聚合根，记录用户的案例与主诉 | 无（仅主键） |
| DivinationPanelMappers | tables/divination_panel_mappers_table.dart:4 | R | 占测记录与盘面的中间映射表（跟随主表 Divinations，U 类） | divinationUuid → t_record_meta.uuid |
| DivinationSubDivinationTypeMappers | tables/divination_sub_divination_type_mappers_table.dart:7 | R | 占测记录与子类型的关联表（跟随主表 Divinations，U 类） | divinationUuid → t_record_meta.uuid |
| DivinationTagDimensions | divination_tag/drift_tag_tables.dart:12 | G | 标签维度字典定义（五行/吉凶等只读词表） | — |
| DivinationTags | divination_tag/drift_tag_tables.dart:28 | G | 标签维度下的静态枚举词条（金木水火土等） | — |
| DivinationTypes | tables/divination_types_table.dart:5 | G | 术数类型（六爻/奇门/梅花等）系统内置字典 | — |
| DivinationWorkItems | divination_case/divination_work_items_table.dart:3 | U | 案卷下的具体工作项与推演步骤断语 | 无（caseUuid 指向缺 scope 的 DivinationCases） |
| Divinations | tables/divinations_table.dart:8 | U | 占卜主记录表（旧版），记录用户起卦核心数据 | 无（仅主键） |
| Etymologies | meihuayishu/dictionary_tables.dart:31 | G | 字典字源数据，只读静态参考数据 | — |
| HlcClockStates | persistence_drift.dart:301 | S | 设备级 HLC 时钟持久化单行表（id=0），系统级单例 | — |
| LayoutTemplates | four_zhu_card_templates/four_zhu_tables.dart:51 | ? | 混合表：包含官方预置模板(G)与用户自定义模板(U) | — |
| LlmModels | ai/tables/tables.dart:61 | G | LLM 模型规格参数与能力字典 | — |
| LlmProviders | ai/tables/tables.dart:32 | ? | 混合表：包含官方默认端点(G)与用户自定义供应商(U) | — |
| MarketTemplateInstalls | four_zhu_card_templates/four_zhu_tables.dart:140 | U | 用户从市场安装/固定的卡片模板本地记录 | 无（localTemplateUuid 指向缺 scope 的 LayoutTemplates） |
| MeiHuaGuaInfos | meihuayishu/meihua_gua_infos.dart:6 | U | 梅花易数排盘特有卦象数据（本/变/互/动爻） | divinationUuid → t_record_meta.uuid |
| MeihuaDatasetGenerations | meihuayishu/dictionary_tables.dart:43 | S | 字典数据集 XRAP 安装世代版本控制记录 | — |
| OutboxPeerAcks | persistence_drift.dart:198 | S | 同步协议中 per-peer 的 ACK 水位表 | — |
| PanelRefs | divination_case/panel_refs_table.dart:3 | U | 案卷挂载的具体盘面引用项 | 无（caseUuid/panelUuid 指向的表均缺 scope） |
| PanelSkillClassMappers | tables/panel_skill_class_mappers_table.dart:4 | R | 盘面与技法分类的映射表（跟随主表 Panels，U 类） | 无（panelUuid 指向缺 scope 的 Panels） |
| Panels | tables/panels_table.dart:4 | U | 盘面主表，记录用户排盘生成的图盘数据 | 无（仅主键） |
| Pinyins | meihuayishu/dictionary_tables.dart:19 | G | 汉字拼音只读字典表 | — |
| PlaygroundPostCaches | playground/playground_cache_tables.dart:18 | S | 广场公开帖子在客户端的只读展示缓存 | — |
| PlaygroundReplyCaches | playground/playground_cache_tables.dart:69 | S | 广场公开回复在客户端的只读展示缓存 | — |
| PromptSkillBindings | ai/tables/tables.dart:184 | G | 系统 Prompt 模板与占测技法的预设绑定字典 | — |
| PromptTemplates | ai/tables/tables.dart:117 | ? | 混合表：包含系统内置模板(G)与用户自定义模板(U) | — |
| PromptVersions | ai/tables/tables.dart:153 | R | Prompt 模板版本历史表（跟随主表 PromptTemplates，? 类待定） | templateUuid → PromptTemplates.uuid |
| SeekerDivinationMappers | tables/seeker_divination_mappers_table.dart:10 | R | 求测人与占测记录的多对多关系表（跟随 Seekers / Divinations，U 类） | divinationUuid → t_record_meta.uuid |
| Seekers | tables/seekers_table.dart:12 | U | 求测人档案主表，记录用户的客户个人信息 | 无（仅主键） |
| SkillClasses | tables/skill_classes_table.dart:4 | G | 术数技法分类字典，系统内置只读数据 | — |
| Skills | tables/skills_table.dart:4 | G | 占断技法元数据字典，系统内置只读数据 | — |
| SubDivinationTypes | tables/sub_divination_types_table.dart:5 | G | 细分子占断类型字典，系统内置只读数据 | — |
| TaiYuanRecords | tables/tai_yuan_records_table.dart:4 | U | 八字排盘中的胎元排盘记录 | 无（calendarUuid 指向缺 scope 的 DivinationCalendars） |
| ThemeDatasetGenerations | theme/tables/theme_dataset_generations_table.dart:18 | S | XRAP 主题包的安装世代与版本记录 | — |
| ThemeTokens | theme/tables/theme_tokens_table.dart:20 | G | 官方主题包展开的扁平 Token 键值对资源库 | — |
| TimingDivinations | tables/timing_divinations_table.dart:8 | U | 择日与时空占测的参数与快照记录 | divinationUuid → t_record_meta.uuid |
| UserDeities | taiyishenshu/taiyi_database.dart:21 | U | 用户自定义的太乙神煞/神明配置项 ⚠ 属独立库 TaiYiDatabase | 无（独立库） |
| UserSchools | taiyishenshu/taiyi_database.dart:11 | U | 用户自定义的太乙流派规则配置 ⚠ 属独立库 TaiYiDatabase | 无（独立库） |
| WorkItemPanelRefs | divination_case/work_item_panel_refs_table.dart:3 | R | 案卷工作项与盘面引用的映射表（跟随 DivinationWorkItems，U 类） | 无（workItemUuid 指向缺 scope 的 DivinationWorkItems） |

---

## 二、需要加 scope 列的表（U 类 + 跟随 U 的 R 类）汇总（共 34 张）

经核对，已确定归属且需要进入 SW1/SW2 增加 `scope_uid` 列的表共有 **34 张**（包含 28 张独立 U 类实体表与 6 张跟随 U 的 R 类关联映射表）：

### 1. 独立 U 类实体表（28 张）
1. `AccountIdentityLinks`（反查：无，为 scope 判定依据）
2. `AgentInvocations`（反查：`sessionUuid` → `AiChatSessions.uuid`）
3. `AiApiCalls`（反查：`sessionUuid` → `AiChatSessions.uuid`）
4. `AiChatMessages`（反查：`sessionUuid` → `AiChatSessions.uuid`）
5. `AiChatSessions`（反查：`divinationUuid` → `t_record_meta.divination_uuid`）
6. `AiDivinations`（反查：`divinationUuid` → `t_record_meta.divination_uuid`）
7. `AiProvenances`（反查：无，多态引用）
8. `AiUsageAudits`（反查：无，多态引用）
9. `CardTemplateMetas`（反查：无）
10. `CardTemplateSettings`（反查：无）
11. `CardTemplateSkillUsages`（反查：`queryUuid` → `t_record_meta.uuid`）
12. `CaseParticipants`（反查：无）
13. `CombinedDivinations`（反查：`divinationUuid` → `t_record_meta.uuid`）
14. `CreationAuditLogs`（反查：无）
15. `DaYunRecords`（反查：`sourceUuid` → `t_record_meta.uuid`）
16. `DivinationCalendars`（反查：无）
17. `DivinationCases`（反查：无，仅主键）
18. `DivinationWorkItems`（反查：无）
19. `Divinations`（反查：无，仅主键）
20. `MarketTemplateInstalls`（反查：无）
21. `MeiHuaGuaInfos`（反查：`divinationUuid` → `t_record_meta.uuid`）
22. `PanelRefs`（反查：无）
23. `Panels`（反查：无，仅主键）
24. `Seekers`（反查：无，仅主键）
25. `TaiYuanRecords`（反查：无）
26. `TimingDivinations`（反查：`divinationUuid` → `t_record_meta.uuid`）
27. `UserDeities`（反查：无，独立库 ⚠ 属独立库 TaiYiDatabase）
28. `UserSchools`（反查：无，独立库 ⚠ 属独立库 TaiYiDatabase）

### 2. 跟随 U 的 R 类关联映射表（6 张）
1. `BlobRefs`（主表 `t_record_meta`，反查：`ownerRecordUuid` → `t_record_meta.uuid`）
2. `DivinationPanelMappers`（主表 `Divinations`，反查：`divinationUuid` → `t_record_meta.uuid`）
3. `DivinationSubDivinationTypeMappers`（主表 `Divinations`，反查：`divinationUuid` → `t_record_meta.uuid`）
4. `PanelSkillClassMappers`（主表 `Panels`，反查：无）
5. `SeekerDivinationMappers`（主表 `Seekers`/`Divinations`，反查：`divinationUuid` → `t_record_meta.uuid`）
6. `WorkItemPanelRefs`（主表 `DivinationWorkItems`，反查：无）

> **关于 `PromptVersions` 的说明**：`PromptVersions` 跟随 `PromptTemplates`，后者为 ? 类待裁决，故本表归属一并待定。

---

## 三、拿不准的表（? 类）及纠结点

共 **4 张表** 标记为 `?`（混合表），均存在“系统预置与用户私有共用一张物理表”的特征，需在 SW1/SW2 执行前回填策略裁决：

1. **`AiPersonas`** (`ai/tables/tables.dart:216`)：
   - **纠结点**：目前内置预设人设为 G 类；但设计预留了自定义/克隆人设（U 类）。若加 scope 列，系统内置行需统一指定 `scope_uid = 'system'` 或保持 NULL。
2. **`LayoutTemplates`** (`four_zhu_card_templates/four_zhu_tables.dart:51`)：
   - **纠结点**：官方内置模板为 G 类，用户派生/另存模板为 U 类。
3. **`LlmProviders`** (`ai/tables/tables.dart:32`)：
   - **纠结点**：公共预设端点（如 OpenAI / DeepSeek 官方入口）为 G 类，用户自定义私有 API 端点/中转服务为 U 类。
4. **`PromptTemplates`** (`ai/tables/tables.dart:117`)：
   - **纠结点**：表中已包含 `isBuiltin` 列。`isBuiltin=true` 的内置模板为 G 类，`isBuiltin=false` 的自定义模板为 U 类。

---

## 四、无反查字段的表（SW2 需单独裁决回填策略）

以下 **18 张表** 在 SW2 回填阶段无法通过关联字段直接 JOIN 到已具备 `scope_uid` 的主表（如 `t_record_meta`）。这批表 SW2 无法按关联反查真实归属，只能走兜底策略（如回填本地默认主 scope），存在误归风险，需在 SW1/SW2 阶段单独裁决其回填规则：

1. **主键自立 / 无外部外键的聚合根与主表（4 张）**：
   - `DivinationCases`
   - `Divinations`
   - `Panels`
   - `Seekers`
2. **多态弱引用 / 关联主表同样缺 scope 的派生表与映射表（11 张）**：
   - `AiProvenances`（`entityUuid` 为多态引用）
   - `AiUsageAudits`（`entityUuid` 为多态引用）
   - `CardTemplateMetas`（`templateUuid` 指向缺 scope 的 `LayoutTemplates`）
   - `CardTemplateSettings`（`templateUuid` 指向缺 scope 的 `LayoutTemplates`）
   - `CaseParticipants`（`caseUuid` 指向缺 scope 的 `DivinationCases`）
   - `CreationAuditLogs`（`caseUuid` 指向缺 scope 的 `DivinationCases`）
   - `DivinationCalendars`（`sourceUuid` 为多态引用）
   - `DivinationWorkItems`（`caseUuid` 指向缺 scope 的 `DivinationCases`）
   - `MarketTemplateInstalls`（`localTemplateUuid` 指向缺 scope 的 `LayoutTemplates`）
   - `PanelRefs`（`caseUuid`/`panelUuid` 指向的表均缺 scope）
   - `PanelSkillClassMappers`（`panelUuid` 指向缺 scope 的 `Panels`）
   - `TaiYuanRecords`（`calendarUuid` 指向缺 scope 的 `DivinationCalendars`）
   - `WorkItemPanelRefs`（`workItemUuid` 指向缺 scope 的 `DivinationWorkItems`）
3. **独立库表（2 张）**：
   - `UserDeities`（独立库 `TaiYiDatabase`）
   - `UserSchools`（独立库 `TaiYiDatabase`）
4. **判定依据表（1 张，循环依赖风险）**：
   - `AccountIdentityLinks`（本身即为 scope 判定依据）

---

## 五、独立数据库（@DriftDatabase）分布全量核对说明

经全库 grep 检索 `@DriftDatabase`，除主库 `PersistenceDriftDatabase`（`AppDatabase`）外，其余各领域的独立库与表分布如下：

1. **`TaiYiDatabase`**（`taiyishenshu/taiyi_database.dart:31`）：
   - 表：`UserSchools`, `UserDeities`（2 张 U 类表，迁移时需使用独立的 DatabaseMigrator 与版本控制）。
2. **`AccountDatabase`**（`account/account_database.dart:7`）：
   - 表：`AccountIdentityLinks`。
3. **`AiDatabase`**（`ai/ai_database.dart:29`）：
   - 表：14 张 AI 表（`LlmProviders`、`LlmModels`、`PromptTemplates`、`PromptVersions`、`PromptSkillBindings`、`AiPersonas`、`AiChatSessions`、`AiChatMessages`、`AiApiCalls`、`AiProvenances`、`AiDivinations`、`AgentInvocations`、`AiUsageAudits`、`AiTools`）。
4. **`FourZhuDatabase`**（`four_zhu_card_templates/app_database.dart:19`）：
   - 表：`DaYunRecords`, `TaiYuanRecords`, `LayoutTemplates`, `CardTemplateMetas`, `CardTemplateSettings`, `CardTemplateSkillUsages`, `MarketTemplateInstalls`。
5. **`MeiHuaDatabase`**（`meihuayishu/meihua_database.dart:12`）：
   - 表：`MeiHuaGuaInfos`。
6. **`DictionaryDatabase`**（`meihuayishu/dictionary_database.dart:11`）：
   - 表：`Characters`, `Pinyins`, `Etymologies`, `MeihuaDatasetGenerations`。
7. **`ThemeDatabase`**（`theme/theme_database.dart:34`）：
   - 表：`ThemeTokens`, `ThemeDatasetGenerations`。
