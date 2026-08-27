# HANDOFF: storage-s2b-blob-media-reader（Wave 1B 返工交付）

## Task S2b: Media Reference Reader 接口对齐与流消费异常可观察性（2026-08-27）

- 当前分支/worktree: `feature/storage-s2b-blob-media-reader` (`wave2-xiang-s2b`)
- 上游/基线 Commit SHA: `df6ddc208ebac30abdaf9110e1e32acd373d09ff`
- 变更范围:
  - `drift/lib/media/drift_media_reference_reader.dart`: 实现 `MediaReferenceReader` 契约（`statusOf`、`openRead`），委托 `BlobMetadataRepository` 与 `DriftLocalBlobStore`；保留 `statusOf` 元数据三态语义（不全量读盘）；`openRead` 前置 `BlobCorruptError`/`BlobUndecryptableError` 映射为对应 `MediaReadResult`，流消费期异常通过 `_mapStreamErrors` 转换为 `BlobCorruptError` 保证错误可观察。
  - `drift/test/media/drift_media_reference_reader_test.dart`: 增加/保留硬断言覆盖 `absent`、`partial`、`complete`、`corrupt`、`undecryptable` 全部 5 种状态；包含 byte stream 消费期抛出 `BlobCorruptError` 的端到端测试。
- 执行命令与退出码:
  - 依赖更新: `(cd drift && flutter pub get)` -> Exit code 0
  - 定向 reader 测试: `(cd drift && flutter test test/media/drift_media_reference_reader_test.dart)` -> Exit code 0 (9/9 passed)
  - 全量 media 测试: `(cd drift && flutter test test/media/)` -> Exit code 0 (13/13 passed)
  - 相关 blob 测试: `(cd drift && flutter test test/media/ test/blob/)` -> Exit code 0 (99/99 passed)
  - Core 回归测试: `(cd core && flutter test)` -> Exit code 0 (295/295 passed)
  - 静态分析: `(cd drift && flutter analyze lib/media test/media lib/blob test/blob)` -> Exit code 0 (0 issues)
  - 格式/检查: `git diff --check` -> Exit code 0
- 未运行项: 跨平台真机 UI 媒体渲染（超出纯 Dart reader 契约与 S2b 范围）
- 残余风险: 无。已通过直接依赖与 stream 消费双向验证。
- 人类合并/发布顺序: S2b feature 分支在人类验收后合并至 xuan-storage main。

---

# HANDOFF: storage-record-module-check（Task Kanyu R2）

## Task Kanyu R2: Record 读取补 module 校验（2026-08-25）

- 当前分支/worktree: `feature/kanyu-r2-record-module-check` (`wave1-kanyu-r2`)
- Commit SHA: `a750a059fcdeb198e11a299e418ec3586cffe674`
- 变更范围:
  - `drift/lib/record/local_record_repository.dart`: `getRecord` 增加 `record.module == module` 校验，mismatch 返回 `null`。
  - `drift/test/record/local_record_repository_test.dart`: 增加 TDD RED/GREEN 测试 `getRecord returns record only when module matches`。
- 执行命令与退出码:
  - RED test: `flutter test --no-pub test/record/local_record_repository_test.dart` -> Exit code 1 (Failed as expected)
  - GREEN test: `flutter test --no-pub test/record/local_record_repository_test.dart` -> Exit code 0 (Passed, 2/2 tests)
  - Static analysis: `flutter analyze --no-pub lib/record/local_record_repository.dart test/record/local_record_repository_test.dart` -> Exit code 0 (0 issues)

---

# HANDOFF: storage-build-theme（交接信封 · 第 2 轮）

## Playground Firestore direct-write Design（2026-08-12）

- 当前分支/worktree：`fix/playground-firebase-repairs`。
- 刚完成：按 OpenSpec/gStack/Matt 复核意见加固
  `docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md`；同步更新容器级
  `openspec/changes/add-divination-playground` 的 proposal/design/tasks/spec delta 与 Firebase
  authority 文档，使 Functions/通知/私信/Profile/可信游客限制后移。
- 下一步第一件事：用户批准 Design 后重写 TDD/ACT；不得直接执行旧 TDD。
- 已知的坑：identity schema convergence 是编码 P0 前置；旧 callable 与新 public/private schema
  不兼容，不能作为回滚；当前 direct Phase 不交付待断/派生状态 Filter。
- R2 修订：旧执行计划已整体重写；RI 新增 viewer capabilities 并合并远端 main、两仓 pin 同一
  resolved-ref 是 Task 0 人工门禁。当前远端 `192.168.0.165:3000` 不可达，未执行 merge/push，
  因此状态仍是 DESIGN/PLAN READY，CODING BLOCKED。
- R2 计数裁决：详情用 replies/likes/verifications 三个 count aggregation，
  `aggregateReadCount=3`；Feed count/feedback 为占位且 UI 必须隐藏。bookmark 字段保持
  `user_provider_uid/user_app_user_id`；Rules 最重路径预算 8/20。
- 开工前补丁：Task 0.4 改为 fetch + 非空 remote main + 双 ancestor 的 fail-closed gate；likes
  count 明确使用 equality index merge、不增加 composite，Task 7 TDD 必须删除旧 likes composite
  并做变异验证。现有 TDD 计划只做增补，未再次重写。

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
