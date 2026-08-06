# 执行指令：BUILD-THEME 收尾验收（ACT 协议任务文档）

> 2026-08-06 ｜ 分支: agent/pi/storage-build-theme ｜ 基线: 62a1e4c ｜ 当前: 7b1414a
> 类型: 验收收尾（编码已完成，仅剩跑门禁 + 誊抄记录）
> 权威派工: ~/Downloads/storage_refactor/DISPATCH-BUILD-THEME.md

---

## 〇、给执行 agent 的一句话

**编码已完成且通过变异自检，你的唯一任务是：跑全量验收命令，全绿则誊抄变异自检记录并提交；有红则按本文档第四节定位修复。禁止重写已交付的代码，除非验收命令要求。**

---

## 一、目标

把 BUILD-THEME 任务从"主体完成"推进到"验收通过"。具体：

1. 跑派工文档第八节的全量验收命令，确认全绿
2. 核对 A9（S1a 57 条冻结基线未抬高、dartdoc 下限 161 未调低）+ A10（四包测试只增不减）
3. 把变异自检记录誊抄到 `tasks/mimo-storage-build-theme.md` 的「决定记录」段
4. 全绿后提交，任务完成

## 二、已完成（不要重做）

### 2.1 构建脚本（commit ba9b85c）
- `assets/tool/build_theme_jsonl.py`（390 行，照 `assets/tool/build_geo_sql.py` 形制）
  - YAML -> 扁平 token -> jsonl 载荷（行 schema `{"k","v","t"}`，**零 g 字段**，R4-P0）
  - 三条 SHALL 构建期校验：数值类型(SHALL-1, A14d) / 未知字段(SHALL-2, A14a) / 整体形状(SHALL-3, A14e)
  - 幂等（key 字典序排序，稳定 diff）
  - 支持 `--presets-dir` 参数（测试喂坏 fixture 用）
  - 路径用向上查找策略（main + worktree 都能跑，符合 AGENTS.md 铁律 #3）
- 跑通 4 个预设，产出 4 个 `.jsonl` + `BUILD-REPORT.md`
- **default.jsonl 真值**（generation 0 内置载荷）：338 行 / 27458 字节 / sha256 `aa62ab4aaa45038a2625dc0fcf26daee616c1a7c40d00bf50ab081f15d634af1`

### 2.2 manifest 回填（commit ba9b85c）
`core/lib/model/theme_dataset.dart` 的 `kThemeBundledManifest` 四处 TODO 已填真值：
```dart
contentVersion: '2026-08-06',        // 照 T1 geo 的 '2026-08-03'，构建日期
payloadSha256: 'aa62ab4aaa...',       // default.jsonl 的 sha256
payloadBytes: 27458,
declaredRowCount: 338,
```

### 2.3 测试 + 坏 fixture + 变异自检（commit 0de80b8）
- `assets/test/theme/build_theme_test.dart`：A1/A3/A5/A7/幂等（9 tests，全绿）
- `core/test/theme_bundled_manifest_consistency_test.dart`：A2/A6/A7（2 tests，全绿）
- `assets/tool/test_fixtures/theme/bad_numeric.yaml`（SHALL-1：radius="8px"）
- `assets/tool/test_fixtures/theme/bad_shape.yaml`（SHALL-3：顶层缺 light/dark）
- **变异自检 6 项全过**（红在目标断言非编译失败）：
  | 变异 | 注入 | 红在哪 |
  |---|---|---|
  | A6-1 | sha256 首字符 a->b | sha256 断言（theme_bundled_manifest_consistency_test.dart:66）|
  | A6-2 | rowCount 338->337 | rowCount 断言 |
  | A6-3 | bytes 27458->27457 | bytes 断言 |
  | A3 | 禁用数值校验（return 提前）| "期望非零退出但实际 0" |
  | A5 | 禁用形状校验（return 提前）| "期望非零退出但实际 0" |
  | A7 | jsonl 行注入 g 字段 | 产物扫描 + 源码扫描双向均红 |

## 三、剩余工作（按序，逐步门禁）

### 步骤 1：跑全量验收命令

在 worktree 根目录执行（**不要加 markdown 反引号包裹整行**，`aiwt` 用 `eval` 执行）：

```bash
cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/agent-pi-storage-build-theme
bash scripts/run_s1a_analyze_gate.sh && bash scripts/run_s1b_analyze_gate.sh && bash scripts/run_monorepo_convention_check.sh && bash scripts/run_s5a_analyze_gate.sh && bash scripts/run_s5a_residue_gate.sh && (cd assets && flutter test) && (cd core && flutter test) && (cd drift && flutter test) && (cd p2p && flutter test) && (cd firebase && flutter test)
```

### 步骤 2：核对判据（A9 / A10）

**A9 - S1a 冻结基线未抬高**：
- `run_s1a_analyze_gate.sh` 输出的 issue 数 = **57**（不得 >57）
- dartdoc 覆盖下限 = **161**（`s1a_dartdoc_coverage_test.dart` 不得被调低）

**A10 - 四包测试只增不减**（基线参考，实测应 +2 因 core 新增 2 测试）：
- core：基线 256 -> 应 **258**（+2：theme_bundled_manifest_consistency_test.dart）
- drift：基线 401（不变）
- p2p：基线 62+1skip（不变）
- firebase：基线 131+4skip（不变）

### 步骤 3：誊抄变异自检记录

把第 2.3 节的变异自检表誊到 `tasks/mimo-storage-build-theme.md` 的「决定记录」段（或新增「变异自检记录」段），逐条写明：注入了什么、红在哪条断言。满足 A8。

### 步骤 4：提交

```bash
git add -A
git commit -m "build-theme: 验收通过 + 变异自检记录誊抄"
```

## 四、有红怎么办（按可能性的顺序）

### 4.1 `run_monorepo_convention_check.sh` 红
该脚本检查「仓内子包互相引用一律用 `path: ../xxx`，不得用 git URL 指回本仓」。
- 本任务新增的 `assets/lib/theme/*.jsonl` 是载荷文件，不是 pubspec 依赖，**不应触发**
- 若红：读脚本输出，看是不是误报；大概率与本任务无关（可能是既有问题）

### 4.2 `run_s5a_residue_gate.sh` 红
该脚本检查是否残留触碰 S5a 代码的痕迹。
- 本任务**未改** `core/lib/reference/` 下任何文件（git diff 可证）
- 若红：`git diff 62a1e4c HEAD -- core/lib/reference/` 应为空，拿这个证据说明非本任务引入

### 4.3 `run_s1a_analyze_gate.sh` 红（issue > 57）
- 先确认是否本任务引入：`git diff 62a1e4c HEAD -- core/lib/ assets/lib/`
- 本任务只改了 `theme_dataset.dart`（4 行真值）+ 新增测试文件，不应引入 analyze issue
- 若是 `theme_dataset.dart` 的注释触发 lint：调整注释格式（不改真值）

### 4.4 某包 flutter test 红
- 若是 core：确认是不是 `theme_bundled_manifest_consistency_test.dart` 本身的问题（路径 `../assets/lib/theme/default.jsonl` 在 core 包测试里能否读到）
- 若是 assets：确认 `build_theme_test.dart` 调 python3 是否成功（CI 环境需有 python3 + pyyaml）
- 若是 drift/p2p/firebase：与本任务无关，报告但不修（派工 §六"不碰 S1b/S1d/S3c/S6/T1"）

## 五、停止条件（遇到立即停下报告）

1. 验收命令全绿 -> 继续步骤 3 誊抄
2. 某门禁红且**确认是本任务引入** -> 尝试最小修复；若修不了或涉及架构判断，停下报告
3. 某门禁红且**确认非本任务引入**（既有问题）-> 报告，不修，等人类裁定
4. 发现派工文档与本任务成果有冲突 -> 停下报告，不擅自改方向

## 六、禁止项

- ❌ 禁止重写 `build_theme_jsonl.py`（已通过变异自检，重写会丢这个证据）
- ❌ 禁止改 `core/lib/model/dataset/` 下 XRAP 契约（T1 已交付在用）
- ❌ 禁止改 `core/lib/reference/` 下 S5a 运行期代码
- ❌ 禁止改 `theme/config/presets/*.yaml` 源文件（theme 仓）
- ❌ 禁止在 main 分支操作（在 agent/pi/storage-build-theme 分支）
- ❌ 禁止用模糊词（"适当"/"优雅"/"合理地"/"必要时"）
- ❌ 禁止不实汇报：一律贴机器输出，查不出写"未验证"

## 七、环境注意（AGENTS.md 铁律）

1. 进 worktree 先对每个包 `flutter pub get`（core/drift/p2p/firebase/assets/preferences/supabase）
   - assets 包需要 gitignored 的 `pubspec_overrides.yaml`（已配，深度 `../../../../xuan-time-location`）
2. 报错指向 `.pub-cache` 类型不匹配 -> 陈旧 lock，`rm pubspec.lock && flutter pub get`
3. 已知：`run_s1b_analyze_gate.sh` 的 drift 基线 146 在深层 worktree 恒红（149）-- main 上同深度也 149，与本任务无关，别改基线

## 八、最终证据（任务完成的判据）

全绿后，在汇报里贴：
1. `git log --oneline -1`（最终提交 hash）
2. 验收命令最后一行的退出码（0）
3. core 测试数（应 258）/ S1a issue 数（应 57）/ dartdoc 下限（应 161）
4. 变异自检记录已誊抄的文件路径
