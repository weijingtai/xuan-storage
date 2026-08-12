# HANDOFF · M8 kanyu 资源迁移（未完成交接）

> 2026-08-11｜交接 agent：pi（预算耗尽触发迭代内交接协议）
> 状态：**源仓 rm 完成（0ff97e6）；storage 接入代码完成并 commit（eb8f0d7）；build_runner .g.dart 未跑、测试未写、shell 未查**

## 已完成

### 源仓 worktree `xuan-kanyu/.worktrees/pi-kanyu-assets-rm`（feat/kanyu-assets-xrap）
- `0ff97e6`：git rm assets/configs/ 全部已跟踪文件（rules 6 + data 16 + schema 2 = 24 数据文件 + CONFIGS-MANIFEST.md 文档）+ pubspec 移除 15 行 flutter.assets 注册
- **主工作区 24 处未提交改动（.FIXED.json ×8 / evidence/ / lib 重构 / test/）未卷入 ✓**

### storage worktree `xuan-storage/.worktrees/pi-kanyu-assets`（feat/kanyu-assets-xrap）
- `eb8f0d7`：
  - 物理迁入 `assets/lib/kanyu/assets/`（24 文件，.FIXED.json 已删）
  - `tool/build_kanyu_sql.py` → 3 SQL：rules_document(6行/18216B/sha256 c1a5a61f)、static_data_document(16行/49191B/224f47a0)、schema_document(2行/7150B/1bb50cf1) + BUILD-REPORT.md
  - drift 三件套 + `kanyu_datasets.dart`（manifest 真值见上）+ `drift_dataset_installer.dart`（照 ziwei 复制）
  - `xrap_kanyu_repositories.dart`：XrapKanyuRuleConfigRepository 4 方法（ruleId→ruleSetId 手写映射；异常用契约 NotFound(entityType/entityId)）
  - barrel 3 行 export + pubspec（repository_interface_kanyu 依赖 + lib/kanyu/assets/ 注册，**已修 sed 错位块**）
  - worktree `assets/pubspec_overrides.yaml`（4 级 path，pub get 已过）

## 待办（下一步从这开始）

1. **build_runner**：`cd xuan-storage/.worktrees/pi-kanyu-assets/assets && dart run build_runner build --delete-conflicting-outputs` → 生成 `kanyu_database.g.dart`，然后 `flutter analyze lib/kanyu/` 修 error
2. **写测试** `assets/test/kanyu/`（照 ziwei 样板）：
   - A1 注册：3 id lookup + manifest 真值（sha256/bytes/rows 见上）+ 重复注册 + 数量门禁 3
   - A2 差分：loadRuleConfig('fan-gua-water-v1') → RuleSetManifestContract.ruleSetId=='fan-gua-water-v1'；listAvailableRules()==6；validateConfigPackage（schemaValid/hashMatched true）；loadRuleConfigRaw 逐字节 == 源文件；static_data 16 行
3. **storage 门禁**：`flutter test test/kanyu/` 全绿 + `flutter test` 全量（qizhengsiyu ephemeris 3 失败为 main 既有）
4. **shell 消费方**：查 `xuan-shell/lib/modules/` 是否有 kanyu entry（预盘点无；若 shell 未接入 kanyu 模块 → **跳过 shell 切换，报告清单**，M8 只在 storage 侧交付）
5. **用户验证**：若 shell 有 kanyu 模块 → shell worktree + overrides path + flutter run -d chrome；无则 storage 测试全绿即验收
6. **人类授权后合并**：源仓 → master（注意 kanyu 默认分支 main，查 `git symbolic-ref refs/remotes/origin/HEAD`）+ push；storage → main + push（gitea+github）；shell 若有改动 → main；清理 worktree + 分支 + Todo.md 勾选 M8

## 关键决策（已核实）

- 只迁**已跟踪 24 文件**（.FIXED.json 未跟踪不迁，源仓主人后续提交）
- data 类有端口依据：rules 的 dataRefs 指向 data 文件 → static_data 注册
- schema 注册（validateConfigPackage 需要），预盘点倾向 raw 但协议强制 prebuilt → 文档表
- 契约 freezed fromJson 但 rules 顶层键 ruleId vs 契约 ruleSetId → 手写 `_ruleIdToRuleSetId`
- kanyu 异常：KanyuRepositoryError(sealed) + NotFound(entityType, entityId) + StorageError + ValidationError + IntegrityError（**无 KanyuErrorCode**）
- storage worktree 深度差 4 级：overrides 用 `../../../../xuan-time-location`

## 禁止

- push（人类决定）；改契约；碰已迁模块；git add -A（源仓 24 处未提交会卷入）；碰 .FIXED.json
