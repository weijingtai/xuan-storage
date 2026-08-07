# HANDOFF: storage-build-theme（交接信封 · 第 2 轮）

> 交接时刻: 2026-08-06 ｜ 触发: runtime iteration budget >=80%（40/50）
> 分支: agent/pi/storage-build-theme ｜ 基线: 62a1e4c ｜ 最新提交: 0de80b8
> 上一轮信封: commit 8bd86e2（立项完成，待人类确认 §七）

## 一句话状态

**人类已确认 §七决定（载荷进版本控制），主体工作已完成并通过变异自检，只剩全量验收命令未跑。**

## 已完成（Phase 1-3 全做完）

### Phase 1：构建脚本 ✅
- `assets/tool/build_theme_jsonl.py`（360 行，照 build_geo_sql.py 形制）
  - YAML -> 扁平 token -> jsonl 载荷（行 schema {"k","v","t"}，零 g，R4-P0）
  - 三条 SHALL 构建期校验：数值类型(SHALL-1)/未知字段(SHALL-2)/整体形状(SHALL-3)
  - 幂等（key 字典序排序，稳定 diff）
  - 支持 `--presets-dir` 参数（测试喂坏 fixture 用）
  - 路径用向上查找策略（main + worktree 都能跑，符合铁律 #3）
- 跑通 4 个预设，产出 4 个 .jsonl + BUILD-REPORT.md
- default.jsonl 真值：338 行 / 27458 字节 / sha256 `aa62ab4aaa...`

### Phase 2：回填 + 门禁 ✅
- `core/lib/model/theme_dataset.dart` 四处 TODO 已填真值：
  - contentVersion='2026-08-06' / sha256=aa62ab4a... / bytes=27458 / rows=338
- `core/test/theme_bundled_manifest_consistency_test.dart`（A2/A6/A7，2 tests，全绿）

### Phase 3：三条 SHALL 坏 fixture 测试 + 变异自检 ✅
- `assets/test/theme/build_theme_test.dart`（A1/A3/A5/A7/幂等，9 tests，全绿）
- `assets/tool/test_fixtures/theme/bad_numeric.yaml`（SHALL-1：radius="8px"）
- `assets/tool/test_fixtures/theme/bad_shape.yaml`（SHALL-3：顶层缺 light/dark）
- **变异自检全过**（逐条记录）：
  - A6-1 篡改 sha256(aa->ba) → 红在 sha256 断言(行66) ✅
  - A6-2 篡改 rowCount(338->337) → 红在 rowCount 断言 ✅
  - A6-3 篡改 bytes(27458->27457) → 红在 bytes 断言 ✅
  - A3 禁用数值校验 → 红在"期望非零退出但实际0" ✅
  - A5 禁用形状校验 → 红在"期望非零退出但实际0" ✅
  - A7 注入 g 字段 → 产物扫描+源码扫描双向均红 ✅
  - 所有自检红在**目标断言**非编译失败（符合本仓纪律 #1）

## §七 决定（人类已确认）

1. ✅ 载荷进版本控制（人类确认"决定一同意进版本控制"）
2. default.yaml 喂 generation 0（契约定死，照做）
3. contentVersion = 构建日期 YYYY-MM-DD（照 T1，照做）

## 未完成（仅剩 Phase 4 验收）

### 必做：跑全量验收命令
```bash
cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/agent-pi-storage-build-theme
bash scripts/run_s1a_analyze_gate.sh && bash scripts/run_s1b_analyze_gate.sh && bash scripts/run_monorepo_convention_check.sh && bash scripts/run_s5a_analyze_gate.sh && bash scripts/run_s5a_residue_gate.sh && (cd core && flutter test) && (cd drift && flutter test) && (cd p2p && flutter test) && (cd firebase && flutter test)
```
**重点核对 A9/A10**：
- S1a 全包 issue **57** 未抬高（dartdoc 下限 **161** 未调低）
- 四包测试**只增不减**：core 基线 256（+2 新测试=应 258）/ drift 401 / p2p 62+1skip / firebase 131+4skip

### 可能要处理的
- 若 `run_monorepo_convention_check.sh` 拦截（仓内子包 path 引用规则）：检查 assets/lib/theme/ 是否触发，按脚本提示修
- 若 S5a residue gate 拦：检查是否触碰了 S5a reference 代码（应没有）
- A8「决定记录」变异自检已在 HANDOFF 记录，需誊抄到 `tasks/mimo-storage-build-theme.md`

### 不需要做的（已排除）
- ❌ 不碰 S5a 运行期代码 / XRAP 契约 / theme 仓 yaml 源文件（均未触碰，git diff 可证）

## 下一个 agent 的起点

1. `cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/agent-pi-storage-build-theme`
2. `git log --oneline -4` 确认在 `0de80b8`（工作区干净）
3. **直接跑上面的验收命令**（核心剩余工作）
4. 若全绿：把变异自检记录誊到 `tasks/mimo-storage-build-theme.md` 的「决定记录」，提交，任务完成
5. 若有红：按报错修，重点看是否误触 S5a/XRAP/T1 文件

## 关键产物清单

| 文件 | 作用 |
|---|---|
| `assets/tool/build_theme_jsonl.py` | 构建脚本（核心） |
| `assets/lib/theme/default.jsonl` | generation 0 内置载荷（喂 manifest） |
| `assets/lib/theme/{dark,ai-mingli-ink,ai-starry-bronze}.jsonl` | 其余预设载荷（验证脚本通用性） |
| `assets/lib/theme/BUILD-REPORT.md` | 真值报告 |
| `assets/tool/test_fixtures/theme/bad_*.yaml` | SHALL-1/3 坏 fixture |
| `assets/test/theme/build_theme_test.dart` | A1/A3/A5/A7 测试（9 tests） |
| `core/test/theme_bundled_manifest_consistency_test.dart` | A2/A6/A7 门禁（2 tests） |
| `core/lib/model/theme_dataset.dart` | manifest 真值回填（4 处） |
| `tasks/mimo-storage-build-theme.md` | 立项纪要（§七决定 + 范围 + 验收） |

## 关键约束（已遵守，下一 agent 维持）

- 载荷行 schema 严格 `{"k","v","t"}`，**零 g 字段**（R4-P0）
- sha256 对**整段字节**算（含末尾 `\n`），hex 小写；rowCount = 非空行数
- 三条 SHALL 是**构建期拒绝出包**（非运行期 fallback）
- 变异自检要红在**目标断言**非编译失败（已验证）
- 不碰 S5a 运行期代码 / XRAP 契约 / theme 仓 yaml 源文件
- 不在 main 改代码（在 agent/pi/storage-build-theme 分支）
