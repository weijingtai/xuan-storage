# 任务: storage-build-theme（BUILD-THEME）
负责: pi ｜ 分支: agent/pi/storage-build-theme ｜ 开工: 2026-08-06
基线 main: `62a1e4c` ｜ 状态: **立项中 -- §七决定待人类确认后开工**

> 由 S5a ACT 07 收尾创建的占位纪要（防三条 SHALL 在移交中丢失，R5 F2），
> 本文件将其补全为正式立项纪要。派工文档：`~/Downloads/storage_refactor/DISPATCH-BUILD-THEME.md`。

## 一、为什么这件事必须做

S5a 已交付**读主题的整条链**（三层合并 / 缓存 / 超时降级 / 启动装配），但**产不出主题包**。
`core/lib/model/theme_dataset.dart:43-51` 的 `kThemeBundledManifest` 有三处 TODO 占位
（contentVersion / payloadSha256 / declaredRowCount，外加 payloadBytes），
**占位值不填真，内置世代（generation 0）装不进去**（XRAP 不变式 I3/I4 会拒）。
本任务产出这三个真值 + 它们描述的载荷 + 产出载荷的构建脚本 + 三条 SHALL 的构建期校验。

## 二、目标

`theme/config/presets/*.yaml` -> Python 构建脚本 -> `.jsonl` 扁平 token 载荷
-> sha256 / bytes / rowCount 真值 -> 回填 `kThemeBundledManifest`。
照 T1 的 `assets/tool/build_geo_sql.py` 形制。

## 三、载荷格式（已定死，不许改，设计 §4.3）

- 行 schema：`{"k","v","t"}`（key / value / type），扁平 token，`.jsonl`（每行一个 JSON 对象）
- `k`：扁平 token key，形如 `light.components.xuan-common-ui.button.primary.radius`
- `v`：any，**不得是 Map**（嵌套在构建期展平）；List 视为叶子不再下降
- `t`：`s`/`n`/`b`/`a`/`z`（string/number/bool/array/null）
- **零 `g` 字段**（R4-P0 裁定：generation 是运行时 materializer 入参，不是构建期可预知的包内容）
- UTF-8，LF 换行，末尾 `\n`
- `rowCount` = jsonl 行数；`payloadSha256` = 对载荷整段字节算 sha256 hex 小写

扁平化规则（设计 §6.6 第 1 步）：扁平 key = 从根到叶子的路径以 `.` 连接；
递归下降遇非 Map 值停止；List 视为叶子；空 Map `{}` 不产生 key。

## 四、§七 决定记录（⚠ 待人类确认后开工）

### 决定 1：载荷进版本控制（照 T1）

**选择：进版本控制。**

理由：
1. **A6 门禁要求**：载荷与 manifest 不一致时测试必须变红。不进版本控制，
   `kThemeBundledManifest.payloadSha256` 的真值就无法在仓库里被 CI 校验 -- 门禁形同虚设。
2. **T1 先例**：`assets/lib/geo/*.sql` 载荷已进版本控制（`git ls-files` 实证），
   `.gitignore` 未排除 `.sql`/`.jsonl`。设计 §4.3 否决了 `*.sql` 形态但未否决"进版本控制"。
3. **构建可复现**：内置世代载荷必须随包发布（rootBundle），进版本控制才能锁定。
4. **contentVersion 对应**：真值需与载荷字节对应，进版本控制才能锁定。

代价：每次改 yaml 产生二进制式 diff（与 T1 的 `*.sql` 同性质）。可接受。

### 决定 2：default.yaml 是内置世代（generation 0）的载荷源

`themeDatasetId = 'theme.package'`（singular），`kThemeBundledManifest` 是单数。
内置世代 = 一个载荷 = `default.yaml`（含 light+dark 两套 brightness，是恒存在的兜底主题）。

构建脚本跑通全部 4 个预设产出 4 个 `.jsonl`（满足 A1"可跑通 4 个现有预设"），
但**只有 `default.jsonl` 喂 `kThemeBundledManifest`**（A2 回填三个真值）。
其余 3 个预设的 `.jsonl` 是构建产物（验证脚本通用性），其 manifest 不在本任务回填
（属远端下发/主题包安装，派工 §六明确"不做远端下发"）。

> ⚠ 决定 1、2 均待人类确认。确认前不动代码。

### 决定 3：contentVersion 规则

照 T1（`geo_datasets.dart` 用 `'2026-08-03'`）：**contentVersion = 构建日期 `YYYY-MM-DD`**。
`dataset_manifest.dart` 明确 contentVersion"人可读，用于展示与诊断，不参与兼容判定"，
故日期式足够且确定。本任务首次构建填 `2026-08-06`，每次重新出包更新。

### 决定 4：变异自检记录（A8，2026-08-06 誊抄自 HANDOFF.md:32-39）

每条新测试做过变异自检：注入违规 -> 确认红在**目标断言**（非编译失败）-> 复原。逐条如下：

| 变异 | 注入了什么 | 红在哪条断言 |
|---|---|---|
| A6-1 | `kThemeBundledManifest.payloadSha256` 首字符 `a`->`b` | sha256 断言（`theme_bundled_manifest_consistency_test.dart:66`）|
| A6-2 | `declaredRowCount` 338->337 | rowCount 断言 |
| A6-3 | `payloadBytes` 27458->27457 | bytes 断言 |
| A3 | 禁用数值校验（校验函数 return 提前）| "期望非零退出但实际 0"（SHALL-1 fixture）|
| A5 | 禁用形状校验（校验函数 return 提前）| "期望非零退出但实际 0"（SHALL-3 fixture）|
| A7 | jsonl 行注入 `g` 字段 | 产物扫描 + 源码扫描**双向均红** |

> 六项自检全部红在目标断言，无一是编译失败（符合本仓纪律 #1：变红要红在对的地方）。

### 决定 5：返工评审 3 条 P2 的处置（2026-08-06，不修，留痕）

返工评审列的 3 条 P2 评估后均未修（评审明确"可不修"，且涉及禁改对象 / 超出本任务范围）：

- **BUILD-REPORT 时间戳导致工作区脏**：时间戳由 `build_theme_jsonl.py` 写入，该脚本已过变异自检、执行指令 §六 禁止重写，不修。
- **assets 侧 A7 先重建再扫、护不住已入库载荷**：改 A7 测试属重写已交付测试逻辑；产物另有 rootBundle 真读测试 + core 一致性门禁 + 验收命令（含 assets）覆盖，不修。
- **另 3 个 jsonl（dark/ai-mingli-ink/ai-starry-bronze）无一致性门禁**：其 manifest 不在本任务回填范围（决定 2：只有 default.jsonl 喂 kThemeBundledManifest），不修。

## 五、三条 SHALL（承接自外部契约，构建期拒绝出包）

| # | 出处 | 内容 | 承接动作 | 坏 fixture |
|---|---|---|---|---|
| 1 | spec.md:60-66 | 数值字段非数值（如 radius=`"8px"`）-> 构建期拒绝（A14d） | 构建脚本对数值字段类型校验，非法即非零退出 | radius 写成字符串 |
| 2 | spec.md:86 + design.md:136 | 未知字段 -> 构建期决定收不收（A14a） | 扁平化按 schema 过滤未知 key，行为明确（非"视情况"） | yaml 加一个 schema 外的 key |
| 3 | 评审 #5 | 整体形状非法 -> 构建期拒绝（A14e） | 对组件形状做 schema 校验，非法即非零退出 | 顶层缺 `light:`/`dark:` 或结构错乱 |

> ⚠ spec.md 本身讲的是**运行期 loader 的 fallback**；派工裁定为**构建期就要执行**
> （构建期拒绝出包，不等设备端 fallback）。三条各要一个故意写坏的 fixture，跑构建必须非零退出。

数值字段清单（来自 spec.md:62 + fixture）：`text.font_size`, `text.font_weight`,
`icon.size`, `opacity`, `min_width`, `min_height`, `max_width`, `max_height`,
`gap`, `radius`, `border.width`, `shadow.blur_radius`, `shadow.offset_x`,
`shadow.offset_y`, `padding.*`, `margin.*`, chart `geometry.*`, typography `fontSize`/`height`。
（精确清单在实现时按 yaml 实测字段定，见 §六 schema）

## 六、范围

### 做

1. 构建脚本（Python，照 `build_geo_sql.py` 形制）：`theme/config/presets/*.yaml` -> `.jsonl`
2. 三个真值：payloadSha256（载荷字节）/ payloadBytes / declaredRowCount
3. 回填 `core/lib/model/theme_dataset.dart:43-51` 四处占位
4. contentVersion 真值（见决定 3）
5. 三条 SHALL 构建期校验 + 各一个坏 fixture 测试
6. 产物落盘 + `.gitignore` 策略（载荷进版本控制，见决定 1）
7. 一条会红的门禁：载荷与 manifest 不一致 -> 测试红（A6，须变异自检证明能红）

### 不做

- ❌ 不碰 S5a 已交付运行期代码（`core/lib/reference/` 下 store/assembly/merger/materializer）
- ❌ 不改 `core/lib/model/dataset/` 下 XRAP 契约（T1 已交付在用）
- ❌ 不做 THEME-DRIFT（落地的 drift 表，另有派工）
- ❌ 不做远端下发（全仓只有 BundledDatasetSource）
- ❌ 不碰 S1b/S1d/S3c/S6/T1 文件
- ❌ 不改 theme 仓 yaml 源文件（除非加坏 fixture，且放测试专用目录）

## 七、产物落盘（拟定，待人类确认决定 1）

- 构建脚本：`assets/tool/build_theme_jsonl.py`（照 `assets/tool/build_geo_sql.py` 同目录）
- 载荷：`assets/lib/theme/<preset>.jsonl`（照 geo 的 `assets/lib/geo/*.sql` 同形制）
  - `default.jsonl`（喂 kThemeBundledManifest）+ dark/ai-mingli-ink/ai-starry-bronze（构建产物）
- 构建报告：`assets/lib/theme/BUILD-REPORT.md`（照 geo 的 BUILD-REPORT.md）
- 坏 fixture：`assets/tool/test_fixtures/theme/*.yaml`（测试专用，不改源 yaml）
- 构建脚本测试：`assets/test/build_theme_jsonl_test.dart`（Dart 调 Python 脚本，验退出码/sha256）
- 一致性门禁：`core/test/theme_bundled_manifest_consistency_test.dart`
  （读 `default.jsonl` 算 sha256 比对 `kThemeBundledManifest.payloadSha256`）

## 八、验收标准（逐条 + 变异自检要求）

- A1 构建脚本跑通 4 个预设产出 `.jsonl`
- A2 `kThemeBundledManifest` 四处占位填真值，payloadSha256 与实际载荷对得上（测试验）
- A3 SHALL-1：数值非法 fixture -> 构建非零退出
- A4 SHALL-2：未知字段按 schema 过滤/告警，行为明确
- A5 SHALL-3：整体形状非法 fixture -> 构建非零退出
- A6 载荷与 manifest 一致性门禁：改载荷不改 manifest（或反之）-> 测试红。**须变异自检证明能红**
- A7 载荷行 schema 严格 `{"k","v","t"}`，零 `g`（源码/产物双向扫描）
- A8 每条新测试做变异自检（注入违规 -> 确认红在目标断言非编译失败 -> 复原），逐条记注入了什么/红在哪条断言
- A9 既有门禁全绿，S1a 57 条冻结基线未抬高，dartdoc 下限 161 未调低
- A10 四包测试只增不减

验收命令: bash scripts/run_s1a_analyze_gate.sh && bash scripts/run_s1b_analyze_gate.sh && bash scripts/run_monorepo_convention_check.sh && bash scripts/run_s5a_analyze_gate.sh && bash scripts/run_s5a_residue_gate.sh && (cd assets && flutter test) && (cd core && flutter test) && (cd drift && flutter test) && (cd p2p && flutter test) && (cd firebase && flutter test)

基线参考（以实测为准，只增不减）：core 256 / drift 401 / p2p 62+1skip / firebase 131+4skip / S1a 全包 issue 57 / dartdoc 下限 161。

## 九、本仓纪律（违反即打回）

1. 变红要红在对的地方（注入变异红在编译失败不算自检通过）
2. "事实上合规" ≠ "有门禁守着"（sha256 现在对得上 ≠ A6 达成）
3. 恒绿断言不许写在未 await 的 .then()/.listen() 回调里
4. 模糊词是毒药："适当"/"优雅"/"合理地"/"必要时"出现即返工
5. shell 里 `${var}` 后跟中文标点会吞字节，一律写 `${var}`

## 十、开工方式

分支从 main 起（`62a1e4c`，已确认）。worktree：
`.worktrees/agent-pi-storage-build-theme`（分支 `agent/pi/storage-build-theme`）。

**§七决定 1/2 待人类确认后再开工**。每完成一个子任务 `/wjt-handoff` 落盘一次。
汇报一律贴机器输出，查不出写"未验证"，不许推测当结论。
