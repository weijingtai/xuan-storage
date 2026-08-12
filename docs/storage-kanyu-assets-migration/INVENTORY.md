# INVENTORY · M8 kanyu（堪舆/风水）资源迁移盘点清单

> 步骤 0 盘点产物｜2026-08-11｜执行 agent：pi（当前会话）
> 复核基准：源仓 `xuan-kanyu` main HEAD `26463df`（**工作区 24 处未提交改动 = 7/31 开发中工作：8 个 `.FIXED.json` 未跟踪 + `evidence/` + `lib/src/domain/...` 重构 + `test/`，全部与已跟踪资源零重叠**）；storage main HEAD `aa1c931`（含 M4 ziwei）
> 依据：`docs/assets-migration/PLAN-REMAINING-MODULES-ASSETS-MIGRATION.md` §四 M8 预盘点（已逐项复核，有修正见 §五）

---

## 一、源仓资源全量清单（`xuan-kanyu/assets/configs/`，已跟踪 25 文件）

### 1.1 rules/（Layer B 规则配置，8 文件）

| 子目录 | 文件 | ruleId | 归类 |
|---|---|---|---|
| ba_zhai | `wandering_star.json` | - | 迁 + 注册 |
| xuan_kong | `feixing.json` | - | 迁 + 注册 |
| san_he | `three_pan.json` | - | 迁 + 注册 |
| fan_gua | `fan_gua.json` | `fan-gua-water-v1` | 迁 + 注册 |
| fenjin | `fenjin_kongwang.json` | - | 迁 + 注册 |
| xingsha | `detection.json` | - | 迁 + 注册 |

**结构**：`{$schema, configType: rule, layer: B, ruleId, name, version, source, authorType: built-in, category, description, parameters, dataRefs, pipeline, outputs, testFixtures}`

### 1.2 data/（Layer A 静态数据，16 文件）

| 子目录 | 文件 | 归类 |
|---|---|---|
| bearing | `24_mountains.json` | 迁 + 注册 |
| bagua | `minggua_formula.json` / `najia_bagua.json` / `nine_palace.json` / `wandering_star.json` | 迁 + 注册 |
| feixing | `fan_gua_sequence.json` / `parent_star.json` / `three_yuan_dragon.json` | 迁 + 注册 |
| fenjin | `120_fenjin.json` / `kongwang_lines.json` | 迁 + 注册 |
| lubanchi | `luban_chi.json` | 迁 + 注册 |
| sanhe | `double_mountains.json` / `four_bureaus.json` / `three_pans.json` | 迁 + 注册 |
| sanyuan | `nine_yun.json` | 迁 + 注册 |
| xingsha | `geometry.json` | 迁 + 注册 |

**结构**：`{$schema, configType: static, layer: A, id, name, version, source, description, ...}`

### 1.3 schema/（2 文件）

- `layer-a-static-data.schema.json` / `layer-b-rule-config.schema.json`：JSON Schema 校验规格

### 1.4 其他

- `CONFIGS-MANIFEST.md`：配置说明文档，不迁（记录在案）

## 二、storage 现状

- **完全无 kanyu**：无目录、无旧桩、无依赖、无测试、无 barrel 导出

## 三、接口契约（`repository-interface-kanyu`）

- `RuleConfigRepository`（`lib/src/repositories/rule_config_repository.dart`）4 方法：
  - `loadRuleConfig(String ruleSetId)` → `RuleSetManifestContract`
  - `listAvailableRules({String? category})` → `List<RuleSetManifestContract>`
  - `validateConfigPackage()` → `ConfigValidationResultContract`
  - `loadRuleConfigRaw(String ruleSetId)` → `String`（原始 JSON）
- 契约模型 **freezed + fromJson**（RuleSetManifestContract / ConfigPackageManifestContract / ConfigValidationResultContract 等）
- `SceneDocumentRepository`（场景文档，非资源类，不迁）；`UserRuleRepository`（用户规则，非官方资源，不迁）

## 四、shell 消费方现状

- 待查：shell 是否已接入 kanyu 模块（`xuan-shell/lib/modules/` 是否有 kanyu entry）

## 五、修正与裁定（对照 PLAN M8 预盘点）

1. **前置阻塞**：24 处改动**不阻塞**——100% 与已跟踪资源零重叠（.FIXED.json 是未跟踪新文件，源码重构在 lib/），git rm 指定已跟踪文件安全
2. **`.FIXED.json` 裁定（D7）**：`.FIXED.json` 是 7/31 未提交的修正版（描述修正/数据补全/与 sequence 对齐），比无后缀版新准。**不迁**——未跟踪文件不属于已提交基线，迁入会造成源仓/storage 数据不一致。留源仓由主人后续提交。**只迁已跟踪 25 文件**
3. **data 类端口确认**：契约 `RuleConfigRepository` 4 方法**明确对应 rules**（loadRuleConfig/loadRuleConfigRaw 按 ruleSetId）。data 类无独立端口 → 但 dataRefs 被 rules 引用（`dataRefs: list(3)` 指向 data 文件 id）→ **data 类迁 + 注册**（`kanyu.static_data`，供 rules 的 dataRefs 解析），不注册则 rules 无法解析
4. **schema 裁定**：2 schema.json 是校验规格（配置元数据），**迁 + 注册**（`kanyu.schema`，raw payloadFormat 不落表，validateConfigPackage 需要）——预盘点倾向 raw，采纳
5. **payloadFormat 裁定**：协议强制内置 prebuilt → 全部以 **JSON 文档表**落地（照 M3/M4）：
   - `kanyu.rules`（8 行，ruleId 作逻辑键，file_name 存相对路径）
   - `kanyu.static_data`（16 行）
   - `kanyu.schema`（2 行）
6. **契约映射**：RuleSetManifestContract.fromJson 直接解析 rules JSON（字段名一致：ruleId→ruleSetId? 需核对——rules JSON 顶层键是 `ruleId`，契约字段是 `ruleSetId`，**需手写映射**）

## 六、任务拆分（照 GUIDE 7 步）

| 步骤 | 内容 | 落点 |
|---|---|---|
| 0 | 本盘点 | `docs/storage-kanyu-assets-migration/INVENTORY.md` |
| 1 | 物理迁移 25 文件（已跟踪）+ pubspec 注册 | 源仓 git rm + storage 物理 |
| 2 | build_kanyu_sql.py + 3 SQL 载荷 | storage `assets/tool/` + `assets/lib/kanyu/assets/` |
| 3 | XRAP 注册（manifest + registerKanyuDatasets + materializer） | `assets/lib/kanyu/kanyu_datasets.dart` + drift 三件套 |
| 4 | 注册测试 + 不变式门禁 | `assets/test/kanyu/` |
| 5 | 新建 `XrapKanyuRuleConfigRepository`（4 方法） | `assets/lib/kanyu/xrap_kanyu_repositories.dart` |
| 6 | shell 消费方（待查是否接入） | shell worktree |
| 7 | Web 验证 | 人类执行 |

## 七、禁止事项

- 不碰 24 处未提交改动（.FIXED.json / evidence/ / lib 重构 / test/）；git rm 只指定 25 个已跟踪文件
- 不改 `repository-interface-kanyu` 契约
- 不碰已迁模块；禁止 push（人类决定）；一切在独立 worktree 分支
