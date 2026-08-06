# HANDOFF: storage-build-theme（交接信封）

> 交接时刻: 2026-08-06 ｜ 触发: runtime iteration budget >=80%（40/50）
> 分支: agent/pi/storage-build-theme ｜ 基线: 62a1e4c ｜ 最新提交: 5e31f0c

## 状态：立项完成，待人类确认 §七 决定后开工

**一句话**：派工读完了、worktree 建好了、立项纪要落盘并提交了，但 §七 的三项决定
（载荷进版本控制 / default.yaml 喂 generation0 / contentVersion 规则）按派工要求
**必须等人类确认后才开工**，所以代码一行没动。

## 已完成

1. **派工文档读完**：`~/Downloads/storage_refactor/DISPATCH-BUILD-THEME.md`
2. **必读材料全读完并分析落盘到纪要**：
   - `tasks/mimo-storage-build-theme.md`（占位纪要 -> 正式立项纪要，含三条 SHALL 映射）
   - `core/lib/model/theme_dataset.dart`（4 处 TODO 待回填）
   - `assets/tool/build_geo_sql.py`（形制样板）
   - 设计 §4.3（载荷格式 {"k","v","t"} 零 g）、§6.6（扁平化规则）
   - `core/lib/model/dataset/dataset_manifest.dart`（DatasetManifest 契约）
   - 4 个预设 yaml 结构（default/dark/ai-mingli-ink/ai-starry-bronze）
   - 契约 spec.md:60-66/86 + design.md:136（三条 SHALL 出处）
   - T1 geo 样板：`*.sql` 载荷**进版本控制**（git ls-files 实证）、BUILD-REPORT、geo_datasets.dart 真值写法
   - S5a fixture 的 `_typeOf`（s/n/b/a/z）与 `bundledJsonlBytes` 格式
3. **worktree 建好**：`.worktrees/agent-pi-storage-build-theme`（分支 agent/pi/storage-build-theme，基线 62a1e4c）
4. **各包 pub get 完成**：core/drift/p2p/firebase/preferences/supabase + assets（assets 配了 gitignored pubspec_overrides.yaml，照 T1 模板，深度 ../../../../xuan-time-location）
5. **立项纪要提交**：commit 5e31f0c

## §七 三项决定（⚠ 待人类确认，已在纪要「决定记录」写明）

1. **载荷进版本控制**（照 T1）-- 理由：A6 门禁需在 CI 校验 sha256，不进版本控制则门禁形同虚设；T1 的 `*.sql` 已进版本控制。
2. **default.yaml 是内置世代 generation 0 的载荷源**（themeDatasetId 单数）-- 构建脚本跑通全 4 预设，但只 default.jsonl 喂 kThemeBundledManifest。
3. **contentVersion = 构建日期 YYYY-MM-DD**（照 T1 的 '2026-08-03'）-- manifest 注释明示不参与兼容判定。

## 未完成（开工后按序）

### Phase 0（确认后立即）
- [ ] 人类确认 §七 三项决定

### Phase 1：构建脚本
- [ ] 写 `assets/tool/build_theme_jsonl.py`（Python，照 build_geo_sql.py）：解析 yaml -> 扁平化 -> jsonl + sha256/bytes/rowCount
- [ ] 三条 SHALL 构建期校验（数值类型 / 未知字段 / 整体形状）非零退出
- [ ] 跑通 4 个预设产出 4 个 .jsonl + BUILD-REPORT.md

### Phase 2：回填 + 门禁
- [ ] 回填 `core/lib/model/theme_dataset.dart` 四处 TODO（contentVersion/payloadSha256/payloadBytes/declaredRowCount）
- [ ] 一致性门禁 `core/test/theme_bundled_manifest_consistency_test.dart`（读 default.jsonl 算 sha256 比对）+ 变异自检证明能红（A6）
- [ ] A7 零 g 字段双向扫描门禁

### Phase 3：三条 SHALL 坏 fixture 测试 + 变异自检
- [ ] SHALL-1 数值非法 fixture -> 非零退出（A3）
- [ ] SHALL-2 未知字段过滤/告警，行为明确（A4）
- [ ] SHALL-3 整体形状非法 fixture -> 非零退出（A5）
- [ ] 每条变异自检：注入违规 -> 红在目标断言非编译失败 -> 复原 -> 记录

### Phase 4：验收
- [ ] 验收命令全绿（见纪要「验收标准」那行，不加 markdown 反引号）
- [ ] 四包测试只增不减（基线 core 256/drift 401/p2p 62+1skip/firebase 131+4skip）
- [ ] S1a 57 条冻结基线未抬高，dartdoc 下限 161 未调低

## 下一个 agent 的起点

1. `cd .worktrees/agent-pi-storage-build-theme`（已是功能分支 agent/pi/storage-build-theme）
2. **先读 `tasks/mimo-storage-build-theme.md`**（立项纪要，含全部分析 + §七 决定 + 范围 + 验收）
3. **确认 §七 三项决定已获人类批准**（若未批准，停下问人类；不要擅自开工）
4. 已批准则从 Phase 1 开始写构建脚本
5. 仓库根（main 位置）：`/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage`
6. 预设 yaml 源（另一仓）：`/Users/jingtaiwei/Git/Public/xuan-migration/theme/config/presets/`

## 关键约束（易踩坑）

- 载荷行 schema 严格 `{"k","v","t"}`，**零 g 字段**（R4-P0，设计 §4.3 写死）
- `v` 不得是 Map（构建期展平）；List 是叶子
- sha256 对**整段字节**算（含末尾 `\n`），hex 小写；rowCount = 行数
- yaml 里 key 自带 `.`（如 `xuan-common-ui.button.primary`），扁平化原样拼接路径
- 三条 SHALL 是**构建期拒绝出包**（非运行期 fallback）；spec.md 本身讲运行期，派工裁定为构建期
- 变异自检要红在**目标断言**非编译失败；恒绿断言不许写在未 await 回调
- 不碰 S5a 运行期代码 / XRAP 契约 / theme 仓 yaml 源文件
- 不在 main 改代码（铁律）；worktree 深度差由 gitignored pubspec_overrides.yaml 承担
