# R5 返工复核与处置（转译者，2026-08-03）

> Codex R5 报告原文：`REACT-R5-CODEX.md`（判定：返工，3 项，**整体正在收敛**）
> 本文件是转译者对那 3 项的**逐条独立复核**结论与处置记录。产出 **v3.3**。

---

## 判定汇总

| 项 | Codex 判定 | 我的复核 | 处置 |
|---|---|---|---|
| R4 P0-1 收敛性用例 | 未修 | **属实** | 已按其原方案挪到 ACT 09 |
| R4 P0-2 ACT 10 scope | 部分修，仍有矛盾 | **属实，且比报告更深** | 已改（选方案 2） |
| R4 P1-1 减法论证 | 已修 ✓ | 一致 | 无需改动 |
| R4 P1-2 A1 自测恢复 | 部分修，顺序错 | **属实** | 已改 |
| R4 P2-1 rev 条件 | 已修 ✓ | 一致 | 无需改动 |

**3 项全部采纳，无驳回。**

### 收敛曲线（Codex 统计）

```
R1: 25 → R2: 10 → R3: 6 → R4: 5 → R5: 3
严重度：数据泄漏/编译死锁/计划分解错误 → 局部契约与测试控制流
```

---

## 逐项处置

### P0-1 收敛性用例仍无生产被测对象 —— 属实，**兑现 R4 时的承诺**

我在 R4 复核里写过：「这是边界品味问题，若 R5 仍认为不可接受，按原方案挪即可，**我不坚持**。」
Codex R5 明确要求挪，且给出了我当时没想透的一条硬理由：

> 不定义胜者选择规则，就不存在可执行的归并算法；若测试内自造规则，
> 它只能证明测试辅助代码，不约束任何生产实现。
> RED_EXPECT 仅为"HlcClock 不存在"，执行者即使不实现任何生产归并器，
> 也能让该测试从红变绿。

**最后一句是决定性的** —— 我的"数学结构命题"版本，RED 阶段过后没有任何东西能保证
它在考生产代码。这不是品味问题，是**门禁失效**。

**处置**（ACT 08 与 ACT 09 各一半）：

**ACT 08 侧**（只产数据，不谈收敛）：
- 删除 `convergence_over_fixed_stamps` 用例；
- `property_three_node_simulation` 里指向"收敛性由 ACT 09 覆盖"；
- 新增 `TASK_DETAIL.frozen_stamps_for_act09`，把仿真产物提取为
  **可被其它测试 import 的生产位置函数**
  `core/lib/test_support/frozen_stamps.dart` 的 `generateFrozenStamps({seed, count})`
  （与 ACT 04 抽出的内存 fake 同一位置，同一套理由：跨包 import 不到私有测试类）；
- 新增用例 `frozen_stamps_are_deterministic_and_contain_concurrent_pairs`，
  守住 ACT 09 依赖的四个前提：确定性、**含并发对**、≥3 个 entityId、≥50 条。
  （没有并发对，ACT 09 那条会退化成"给一列全序值排序"，什么都证明不了）
- SELF_CHECK 由 8 条减为 6 条，DONE_WHEN 同步。

**ACT 09 侧**（真实仲裁器上跑）：
- 新增 `convergence_over_fixed_stamps`，**必须驱动 `const HlcConflictArbiter()`**，
  显式写明"不许在测试里自造归并规则"及理由；
- 归并规则写死为走 `arbiter.arbitrate(remote:, local:)` 并按
  `ArbitrationDecision` 决定替换，两侧规则完全相同、只有到达顺序不同；
- 断言两个独立容器逐 entityId 最终状态相等（比字段不比引用）；
- SELF_CHECK 加两条：
  ① 归并改成"后到者恒胜"（绕开 arbiter，退化 RWW）→ 该用例必红、其余全绿；
  ② 第二个容器改成复用第一个 → 该用例**不会**红，证明它确实退化成了自比。
- SCOPE 的 READ 加入 ACT 08 的 `frozen_stamps.dart`。

### P0-2 ACT 10 scope 契约 —— 属实，**且我实测发现比 Codex 说的更深**

Codex 指出 `readLocalRecord` 仍绑定固定 scope。我去源码核实，发现**问题更大**：

| 回调 | 来源 | scope 从哪来 |
|---|---|---|
| `applyRecord` | `drift_record_data_source.dart:73` `applyRemoteRecord` | **实例字段** |
| `deleteRecord` | `:166` `softDeleteRecord` | **实例字段** |
| `readLocalRecord` | `:89` `getRecord` | **实例字段** |

`DriftRecordDataSource(this.db, {required this.scopeUid})`（`:6-9`）——
**scope 在构造时固定，三个方法全部用实例字段过滤，都不接受 scope 参数。**

所以 **Codex 给的方案 1（"给 readLocalRecord 也加 scopeUid 参数"）救不了这个洞** ——
`applyRecord` / `deleteRecord` 是既有签名，要让它们接受 per-call scope
就得改 `DriftRecordDataSource` 的三个方法，那是溢出 ACT 10 范围的改动，
还会波及其它调用方。

**因此采用 Codex 方案 2：applier 按 scope 构造。** 具体：

- `scopeUid` **进构造参数**，一个实例只服务一个 scope；
- `readLocalStamp` / `applyWithStamp` 的 scopeUid 参数**去掉**
  （v3.2 刚加上，本轮又去掉 —— 因为半 per-call 半 per-instance 才是最坏的组合）；
- **"跨 scope 复用"的承诺彻底删除**，需要另一个 scope 就另建实例；
- `applyRemoteChanges` **必须在最前面拒绝 scope 不匹配的调用**，
  与既有的 entityType 早退并列，且 `canAdvanceCursor` 必须为 false；
- 新增 `TASK_DETAIL.applier_is_scope_bound`（替换 v3.2 的 `scope_is_per_call`），
  把实测行号与"为什么方案 1 不行"写死。

**新增两个测试**（Codex R5 明确要求）：
- `rejects_scope_mismatch` —— 四条断言，**最关键的是第④条**：
  断言 scope-A 的库里没有任何写入。只查返回值的话，
  一个"记了 error 但仍继续应用"的实现照样绿，而那正是跨租户串写。
- `same_uuid_in_two_scopes_never_cross_reads` —— 同一 uuid 在两 scope 下
  实体存在性不同，断言两个 applier 走**不同分支**。

SELF_CHECK 加两条（删早退 → 必红；两个 applier 共用同一个 ds → 必红）。

### P1-1 减法论证 —— Codex 判"已修"，一致，无需改动

### P1-2 A1 自测控制流顺序 —— 属实，已改

Codex 指出两个致命顺序问题，我复核后确认：

**① `SNAPSHOT_AFTER` 比较发生在 restore 之前 ⇒ 脚本必然假失败**
`trap restore EXIT` 只在**进程退出时**触发，而我把快照比较写在脚本正常流程里 ——
那时三次注入还留在工作树上，比较必然不等。恢复最终会成功，但**脚本必定报失败**。

**② 已退出的脚本无法自证 trap**
我写的"插入 `exit 3` 确认 trap 恢复后再删掉"——
父进程都退出了，没法在同一进程里继续确认。

**处置**：整段重写为完整可执行控制流：
- `restore()` 做成**幂等函数**（`RESTORED` 标志），
  正常路径**显式调用**它，`trap` 只作异常兜底；
- 顺序钉死：`restore` → 取 `SNAPSHOT_AFTER` → 比较 → `exit 0`；
- 加 `backup_file()` 辅助函数，`BACKED_UP` / `CREATED_FILES` 用空格分隔字符串
  （macOS bash 3.2.57 无数组友好写法）；
- trap 自测改为**外层 harness + 子进程**：新增
  `scripts/test_s1b_analyze_gate_trap.sh`，用环境变量
  `S1B_TRAP_SELFTEST=1` 让子进程在第二次注入后 `exit 3`，
  父进程检查退出码、快照一致性、临时目录已清理；
- **那行 `exit 3` 是常驻代码，不要事后删掉** ——
  v3.2 要求删掉是错的，删了就再也验不了 trap。
  默认不设环境变量时它不生效，既不影响正常路径又可反复验证。

VERIFICATION 加三条：trap harness 必须过、
`restore` 必须在正常路径被显式调用（grep 独立一行的 `restore`）、
`S1B_TRAP_SELFTEST` 钩子必须保留。

---

## 改后自检结果（全部实跑）

```
① YAML 严格解析（含重复 key 检测） ......... 11/11 通过
② TESTS_FIRST 用例字段完整性 .............. 94 个用例，字段不全 0 个
③ A1–A14 结构化覆盖 ....................... 14/14
④ VERIFICATION 命令 bash -n ............... 167 条，语法错 0 条
⑤ || true 恒绿门禁 ........................ 0 条
⑥ 验收标准与基线 cd064c6 逐字比对 .......... 一致 ✓
```

**规模变化**：91 测试 / 164 验证 / 66 自检 → **94 测试 / 167 验证 / 68 自检注入**

新增用例三个：
- ACT 08 `frozen_stamps_are_deterministic_and_contain_concurrent_pairs`
- ACT 09 `convergence_over_fixed_stamps`（从 ACT 08 迁入并重写）
- ACT 10 `rejects_scope_mismatch` + `same_uuid_in_two_scopes_never_cross_reads`
（ACT 08 删除一个，净 +3）

> ⚠ 本轮我又一次引入了 YAML 语法错误：**list item 以 `**` 开头会被当成 alias**
> （`  - **foo**：...`），三个文件各一处，由严格解析器当场抓出。
> 连同上一轮的"反引号开头"，**list item 首字符不能是 `` ` `` 或 `*`** ——
> 已写进 HANDOFF 的踩坑提示。

---

## 给 R6 的说明

Codex 建议 R6 走**封闭式复验**：只验本报告的 3 项 + 固定回归门禁，不再开放式扩张。
我认同这个口径。三项的复验要点：

1. **P0-1**：ACT 09 的 `convergence_over_fixed_stamps` 是否真的驱动
   `HlcConflictArbiter`；ACT 08 的 `generateFrozenStamps` 是否真能被 ACT 09 import。
2. **P0-2**：applier 绑定 scope 后，三个回调 + 两个转发闭包是否**全部锚定同一个 scope**；
   `rejects_scope_mismatch` 的第④条断言（scope-A 无写入）是否真能抓到"记了 error 仍继续应用"。
3. **P1-2**：`restore` 的显式调用是否在取 `SNAPSHOT_AFTER` **之前**；
   trap harness 的子进程退出码检查是否可靠。

**第 6 轮闸门须人类重新授权** —— 2 轮上限已被突破三次（R3、R4、R5）。
