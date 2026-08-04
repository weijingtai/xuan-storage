# R3 返工复核与处置（转译者，2026-08-03）

> Codex R3 报告原文：`REACT-R3-CODEX.md`（判定：返工，6 项）
> 本文件是转译者对那 6 项的**逐条独立复核**结论与处置记录。
> wjt-react 纪律：**不照单全收** —— R1/R2 都出现过 Codex 判错，
> 每一条都必须自己去源码里验证过才动手。

---

## 判定汇总

| 项 | Codex 判定 | 我的复核 | 处置 |
|---|---|---|---|
| 方案 A 是否成立 | 成立 | **确认成立** | 无需改动 |
| ACT 04 阶段 1 说明缺调用点 | 返工 | **属实** | 已改 |
| P0-1 戳读取/构造点契约缺口 | 返工 | **属实**（但迁移面比报告小） | 已改 |
| P0-2 收敛性测错性质 | 返工 | **属实** | 已改 |
| P0-3 UTF-8 排序缺口 | 返工 | **属实** | 已改 |
| P1-1 减法自检必红声明是假的 | 返工 | **属实** | 已改 |
| P2-1 重复 YAML key | 返工 | **误判，驳回** | 不改，但加了防线 |
| P2-2 A1 无 TESTS_FIRST | 返工 | **属实** | 已改 |

**采纳 6 项，驳回 1 项。**

---

## 一、方案 A 成立性：与 Codex 结论一致

转译者独立验证 ACT 03 的「改主键不破坏编译」断言，证据链：

| 证据 | 位置 | 结论 |
|---|---|---|
| `primaryKey => {scopeUid, entityType}` | `persistence_drift.dart:215` | 待改点确认 |
| `find()` 用 `t.scopeUid.equals(..) & t.entityType.equals(..)` | `:439-444` | 列比较，不依赖主键 ✓ |
| `SyncStatesCompanion.insert(...)` 两处调用**均无 peerId 参数** | `:390`、`:420` | 新列带 `withDefault` ⇒ drift 不生成 required ⇒ 这两处一字不改 ✓ |
| `upsert()` 用 `insertOnConflictUpdate` | `:448` | 冲突目标即主键，但 peer_id 单一取值 ⇒ 三元组与二元组等价 ✓ |

**方案 A 前半段成立，ACT 03 不需要改。**

---

## 二、逐项处置

### ACT 04 阶段 1 —— 属实，已改

**问题**：`act/04.yaml:46-48` 阶段 1 只写「端口 + fake + core 测试」，
但端口签名一改，`sync_coordinator.dart:57/:74` 立刻编译不过，
`cd core && flutter test` 不可能绿 —— 执行者会卡在一个自相矛盾的检查上。

**处置**：阶段 1 改名为「core 端口 + 内存 fake + core 侧调用点」，
显式列出 `sync_coordinator.dart:57`（peekBatch）、`:74`（markSuccess）
与 `sync_runtime.dart` 的转发点，并写明**必须在本阶段内改完、不能拖到阶段 3**。

### P0-1 戳读取与构造点契约 —— 属实，已改（但修正 Codex 的数字）

**Codex 说**：另有 7 个 `RecordLocalApplier(...)` 构造点未列入 SCOPE。

**我的实测**：构造点共 **8 处，且全部在测试代码里，生产 `lib/` 下一处都没有**：

```
drift/test/sync/record_local_applier_test.dart:76, 104, 149, 175
drift/test/sync/record_sync_e2e_test.dart:111, 172, 231
drift/lib/sync/record_local_applier.dart:10   ← 定义处，不是调用
```

`grep -rn --include="*.dart" "RecordLocalApplier(" drift/lib firebase/lib core/lib`
只命中 1 处，且那是 `drift_record_data_source.dart:72` 的**注释**。

所以**契约缺口属实，但迁移面只在 `drift/test` 内，不牵动任何业务仓库** ——
比报告描述的乐观。这个事实反过来支持了「回调注入」而非「仓库注入」的选择。

**处置**（三处）：

1. **ACT 08 加 `getEntityStamp` 读取接口**（`persistence_drift.dart`）：
   钉死签名与返回类型，并写明返回 null 的**两种现实**由调用方区分。
2. **ACT 10 新增 `TASK_DETAIL.applier_constructor_signature`**：
   完整钉死改造后的构造签名（四个新增 required 参数：
   `readLocalRecord` / `readLocalStamp` / `applyWithStamp` / `arbiter`），
   并说明**沿用现有回调注入风格**、`scopeUid` 不进构造参数的理由。
3. **ACT 10 新增 `TASK_DETAIL.existing_construction_sites`**：
   列出全部 8 个构造点的文件行号 + 一份可照抄的迁移样板，
   并写明「若 `DriftRecordDataSource` 没有按 uuid 读单条的方法就地加一个，
   **不要在测试里裸查表绕过它**」—— 那样生产接线仍是空的，A13 落不了地。
   SCOPE 的 READ/MODIFY 同步补上 `record_sync_e2e_test.dart` 与 `drift_record_data_source.dart`。

### P0-2 收敛性测错性质 —— 属实，已改

**问题**：`act/08.yaml` 原属性测试把「收敛性」和单调性/因果性并列成 HLC 的三条不变式。
但 **HLC 的逻辑计数 `c` 本身就受 `observe` 到达顺序影响** ——
同一组事件按不同顺序重放，生成的戳可以合法地不同。
要求「不同顺序重放后胜负相同」是在断言 HLC **没有承诺**的性质，
实现正确也可能红，那是个假门禁。

**处置**：
- `property_three_node_simulation` 收缩为**两条**不变式（单调性 + 因果性），
  并写明「收敛性不在本用例里」及理由。
- 新增独立用例 `convergence_over_fixed_stamps`：
  **先冻结一组已生成的 `(hlc, deviceId)`**，再用两个**互相独立的归并器实例**
  按两种不同到达顺序（含违反因果先后的乱序）喂入，断言每个 entityId 的最终胜者相同。
  收敛性落在**归并/仲裁**层，不依赖 HLC 生成顺序的可重复性。
- SELF_CHECK 相应改写：新增「归并规则改成后到者恒胜（退化 RWW）→ 新用例必红、
  而生成侧用例仍绿」这一条，证明两层各守各的。

### P0-3 UTF-8 排序未落到 compareTo —— 属实，已改

**问题**：`act/09.yaml:54-80` 只说 deviceId 比「字典序」，
`act/11.yaml:59-76` 才提到 Dart `String.compareTo` 走 UTF-16。
执行者照 ACT 09 会直接用 `String.compareTo`，ASCII 测试全绿，
但跨语言客户端得出**相反胜负**，且不报错、只是静默分叉。

**处置**（三处）：
1. `VersionStamp` 的 dartdoc 契约改为明确要求 **UTF-8 字节序**，
   并给出 U+10000（UTF-8 首字节 `F0`／UTF-16 首单元 `D800`）
   与 U+E000（`EE`／`E000`）这组**结论相反**的反例。
2. 新增用例 `device_id_compared_as_utf8_bytes_not_utf16`，
   用上述两个非 ASCII 标识断言按 UTF-8 序的胜负，
   并写明「纯 ASCII 测试抓不到这个 bug」。
3. VERIFICATION 加两道文本门禁：
   禁止 `deviceId.compareTo`（EXPECT_EXIT 1）、
   必须出现 `utf8.encode`（EXPECT_STDOUT 1 + EXPECT_EXIT 0），
   外加断言测试文件里存在那两个码点。
   SELF_CHECK 加「改回 `String.compareTo` → 新用例必红、其余全绿」。

### P1-1 减法自检的必红声明是假的 —— 属实，已改

**问题**：原 SELF_CHECK 声称「把 compareTo 改成减法 →
`compare_to_survives_extreme_magnitude` 必红」。
但 A14 把合法 packed 值限定在 `[0, 2^63)`，**合法值域内两数相减不会符号翻转**，
那条用例在合法值上抓不到减法。声称必红是假的。

**处置**：
- SELF_CHECK 改为「**文本 grep 门禁**必须变红」，并显式写明
  「不要声称那条测试用例一定会红」及理由。
- 用例 BEHAVIOR 里补一段：**禁止减法的权威门禁是文本 grep**，
  极端量级用例的定位是兜底（非法/越界值时的第二道网），不是主力。
- DONE_WHEN 同步改为「由文本 grep 门禁权威守卫」。

### P2-1 重复 YAML key —— **误判，驳回**

**Codex 说**：`08.yaml:429-430`、`09.yaml:180`、`09.yaml:339-340`、`10.yaml:219-220` 有重复 key。

**我的实测**：用 PyYAML + 自定义 loader（覆盖 `construct_mapping`，
对同一 mapping 内的重复 key 打印告警）扫描 11 个 ACT，**零命中**。

逐条核对 Codex 指的四处：

| 位置 | 实际情况 |
|---|---|
| `08.yaml:429-430` | `RED_COMMAND` / `RED_EXPECT` 属于**同一个 list item**，是两个不同的 key |
| `09.yaml:180` | `no_subtraction_in_compare_to` 全文件**只出现 1 次**（grep 实证） |
| `09.yaml:339-340` | 不同 list item 的同名字段 —— YAML 里合法 |
| `10.yaml:219-220` | 同上 |

**同名字段出现在不同 list item 里不是重复 key。** 驳回。

**但采纳其修正标准的后半段**：转译者已建立一个能拒绝 duplicate key 的
严格校验器（`/tmp/dupkey.py` 式），并纳入本轮自检流程 —— 作为防线保留。

### P2-2 A1 没有 TESTS_FIRST 覆盖 —— 属实，已改

**问题**：A1 在 11 个 ACT 里只有 ACT 11 收工时那条
`bash scripts/run_s1b_analyze_gate.sh` + `EXPECT_EXIT: 0`，
**没有任何用例证明这个门禁能红**。违反「一个绿的门禁如果证明不了自己能红，它就是假的」。

**处置**：ACT 11 新增 TESTS_FIRST 用例 `analyze_gate_catches_all_three_regressions`
（`COVERS: [A1]`），要求写一个**姊妹脚本** `scripts/test_s1b_analyze_gate.sh`，
对门禁三段各做一次注入并断言其非 0 退出：
① scoped analyze 必须为 0（注入未使用私有变量）
② 白名单子集（引入非白名单问题 / 临时删白名单项）
③ 总数不超基线（把基线常量临时改成 0）
每次注入后 restore 并确认 `git status --porcelain` 干净；
脚本用 `set -euo pipefail`，**禁止 `|| true`**（另有一道 grep 门禁守这一点）；
并提醒 macOS `/bin/bash` 3.2.57 无 `declare -A` / `mapfile`。
SCOPE 的 WRITE 段同步加入该脚本。

---

## 三、改后自检结果（全部实跑）

```
YAML 严格解析（含重复 key 检测） ... 11/11 通过
编号自洽（TASK_ID = 文件名 = ORDER，DEPENDS_ON 严格单链 01→11） ... 11/11
grep -c 缺双 EXPECT ...................... 0 条
<ACT_BASE> 占位符残留 .................... 0
|| true 恒绿门禁 ......................... 0（仅剩「禁止它」的说明文字）
验收标准 A1–A14 与基线 cd064c6 逐字比对 ... 一致 ✓
```

**规模变化**：88 测试 / 158 验证 / 64 自检 → **91 测试 / 163 验证 / 66 自检注入项**
（新增：`convergence_over_fixed_stamps`、`device_id_compared_as_utf8_bytes_not_utf16`、
`analyze_gate_catches_all_three_regressions` 三个用例）

> 说明：改动过程中我自己引入过两处 YAML 语法错误
> （list item 以反引号开头会被 YAML 当作特殊字符），
> 均由上述严格解析器当场抓出并修复。这也侧面说明这道校验值得常设。

---

## 四、仍未解决 / 需人类知晓

1. **ACT 04 超粒度**依旧存在，是人类明知代价后的选择，本轮未改变。
2. **第 4 轮闸门须重新请示人类** —— wjt-react 的 2 轮上限已被额外授权突破一次，
   R3 是那次授权的兑现。本轮改动是否需要 R4 验证，由人类裁定。
3. **本地 `main` 超前 `gitea/main` 27 个提交未推送**，S1b 全部工作建在这批未备份提交上。
