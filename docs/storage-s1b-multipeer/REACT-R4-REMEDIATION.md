# R4 返工复核与处置（转译者，2026-08-03）

> Codex R4 报告原文：`REACT-R4-CODEX.md`（判定：返工，5 项）
> 本文件是转译者对那 5 项的**逐条独立复核**结论与处置记录。
> 产出 **v3.2**。

---

## 判定汇总

| 项 | Codex 判定 | 我的复核 | 处置 |
|---|---|---|---|
| 方案 A 是否成立 | 成立（未推翻 R3） | 一致 | 无需改动 |
| P0-1 收敛性用例无法机械执行 | 返工 | **属实** | 已改 |
| P0-2 ACT 10 接线契约自相矛盾 | 返工 | **属实**（四处全中） | 已改 |
| P1-1 减法论证仍自相矛盾 | 返工 | **属实** | 已改 |
| P1-2 A1 自测恢复机制不可靠 | 返工 | **属实**（三条全中） | 已改 |
| P2-1 `rev` 完成条件过宽 | 返工 | **属实** | 已改 |

**5 项全部采纳，无驳回。**

> 📌 Codex 本轮主动更正：R3 的「重复 YAML key」确系其**截断/交错输出导致的误判**
> （R4 报告 :124），与转译者 R3 复核时的驳回结论一致。

---

## 逐项处置

### P0-1 收敛性用例无法按文档执行 —— 属实，已改

**Codex 指控三点，我逐条验证**：

| 指控 | 复核 |
|---|---|
| 缺 `RED_COMMAND`/`RED_EXPECT`/`COVERS` | **属实** —— 我在 R3 新增这个用例时漏了这三个字段，是我的疏漏 |
| ACT 08 没定义"归并器"生产类型 | **属实** |
| 真正的仲裁 `HlcConflictArbiter` 要到 ACT 09 才有 | **属实**（`09.yaml:124`） |

**处置**：Codex 给了两条路（挪到 ACT 09 / 在 ACT 08 定义生产归并抽象），
我选了**第三条更小的改法**并说明理由：

- 补齐三个缺失字段（`RED_COMMAND` / `RED_EXPECT` / `COVERS: [A8]`）；
- 明确把该用例的职责**收缩为"冻结一组版本、证明收敛性命题的数学结构"**，
  并写明「本用例不做仲裁的具体实现，也不管哪个版本赢 ——
  谁是胜者由 ACT 09 的 `HlcConflictArbiter` 判定」。

**为什么不挪到 ACT 09**：ACT 08 的职责是"HLC 生成侧"，
收敛性命题依赖的"一组冻结的戳"正是 ACT 08 的产物；
挪到 09 会让 09 反过来依赖 08 的仿真装置，把两个 ACT 的边界搅浑。
收缩职责后，该用例不再需要生产仲裁类型 —— 它验的是**命题结构**而非**仲裁实现**。
仲裁实现的收敛性由 ACT 09 的 `comparison_is_a_total_order_exhaustive`
与 ACT 10 的端到端用例覆盖。

> ⚠ 若 R5 认为这个边界划分仍不可接受，那就按 Codex 原方案挪到 ACT 09 ——
> 这是一个**边界品味问题**，不是对错问题，我不坚持。

### P0-2 ACT 10 接线契约自相矛盾 —— 属实（四处全中），已改

Codex 指的四处，我逐条验证后**全部属实，且都是我在 R3 引入的**：

**① scope 契约自相取消（最严重）**
`:130-133` 写「scopeUid 不进构造参数，以便跨 scope 复用」，
但样板 `:149-151` 让闭包在构造点捕获固定的 `scope`。
**照样板写出来的实例根本不能跨 scope 工作** —— 两句话互相取消。

处置：按 Codex 的"选一套一致契约"，选**回调显式接收 scopeUid**：
```
readLocalStamp({required scopeUid, required entityId})
applyWithStamp({required scopeUid, required entityType, ...})
```
由 `applyRemoteChanges` 把本次调用的值传入。新增 `TASK_DETAIL.scope_is_per_call`
把这个决定与理由写死，并注明「不许改回构造时捕获」。

`readLocalRecord(uuid)` **保持不带 scopeUid** 并说明理由：
它走的是已按 scope 构造的 `DriftRecordDataSource` 实例方法，
uuid 在 scope 内已唯一 —— 这不是疏漏，是两类依赖的性质不同。

**② `const ConflictArbiter()` 不可编译**
`ConflictArbiter` 是抽象接口（`09.yaml:112`），不能实例化。
具体类是 `HlcConflictArbiter`（`09.yaml:124`，有 `const` 构造）。

处置：样板改为 `const HlcConflictArbiter()`；
字段类型**保持抽象接口**（测试要注入 fake，`10.yaml:389` 正是这么用的），
并在 dartdoc 里把"字段抽象、实例化具体"这个设计意图写清楚。

**③ `findRecordByUuid` 是我凭空造的方法名**
实测既有接口是 `drift_record_data_source.dart:89` 的
`Future<RecordMeta?> getRecord(String uuid)`，**签名与需求完全吻合**。

处置：样板改用 `getRecord`；删除"若没有就地加一个"的条件式指令；
明确写「**`drift_record_data_source.dart` 一个字都不用改**」。

**④ 条件式修改 SCOPE**
Codex 说不能一边把某文件当只读依赖、一边条件式要求修改它。
③ 解决后这条自动消失 —— 该文件回归纯 READ。

处置：③ 解决后这条自动消失 —— 该文件回归纯 READ。
实测 SCOPE 的 MODIFY 段**本来就没有**这个文件（只在 READ 段），
所以无需移除；真正的问题是 `TASK_DETAIL` 里那句"就地加一个并把它加进 MODIFY"
与 SCOPE 冲突。已删除该条件式指令，并把 READ 段注释钉死为
「**只读，本 ACT 一个字都不改**」+ 标注 `getRecord:89` 直接可用。
另加一句「若样板里某个回调无法直接引用，**停下核对，不要凭记忆造方法名**」。

### P1-1 减法论证仍自相矛盾 —— 属实，已改

**这是我 R3 修得不彻底**：加了免责声明，却没删掉原来错的论证，
结果同一段里三句话互相打架：

| 位置 | 原文 | 问题 |
|---|---|---|
| `:292` | 「差超过 2^62，减法会绕回符号翻转，这条会红」 | **错** |
| `:297` | 「合法值域内减法不会符号翻转」 | 对，但与 :292 矛盾 |
| `:299` | 「本用例兜住用减法但没溢出的漏网」 | **逻辑正好反了** —— 没溢出时减法结果是对的 |

**处置**（三处）：
- 用例**改名** `compare_to_survives_extreme_magnitude`
  → `compare_to_orders_extreme_packed_values_correctly`，
  名字不再暗示它能识别实现手法；
- BEHAVIOR 全部重写为**纯行为验证**（极端合法值上排序结果正确），
  并明确写出「本用例**不能**用来识别是否用减法」及两条**不要声称**；
- `TASK_DETAIL.no_subtraction_in_compare_to` 里同源的错误论证
  （`:197-198` 的"真实故障点是溢出"）一并改掉，
  改述为"减法把语义比较降级成数值相减，格式变化时含义会悄悄漂移"；
- 权威门禁明确为**源码文本检查**，由 SELF_CHECK 的注入证明其能红。

### P1-2 A1 自测恢复机制不可靠 —— 属实（三条全中），已改

| 指控 | 复核 |
|---|---|
| `git checkout` 恢复不了未跟踪的新建文件，且不符合本 worktree 安全规则 | **属实** |
| 要求全局 `git status --porcelain` 为空，但 ACT 11 执行中工作树合法非空 | **属实** —— 这个要求等于让门禁永远失败 |
| 二三次注入无统一异常安全恢复，中途退出会遗留污染 | **属实** |

**处置**：整段按 `mktemp -d` + `trap` 重写，给出可照抄的骨架：
```bash
BACKUP_DIR="$(mktemp -d)"
CREATED_FILES=""
SNAPSHOT_BEFORE="$(git status --porcelain)"
restore() { ... }
trap restore EXIT INT TERM     # 成功/失败/被中断都恢复
```
收尾断言改为**前后快照比较**而非全局为空；
新建文件显式记录并删除；**新增最后一步：自测 trap 本身**
（故意插 `exit 3` 中途退出，确认仍能恢复，确认后删掉）。
并按 macOS bash 3.2.57 的限制注明用空格分隔字符串而非数组。

### P2-1 `rev` 完成条件过宽 —— 属实，已改

**实测确认口径不一致**：
- VERIFICATION `:482` 的 grep **实际只禁** `LamportStamp|overwrittenPayloadJson|overwrittenStamp`，
  **没有禁裸词 `rev`**；
- 但 DONE_WHEN `:547` 写「源码里不再有 LamportStamp / **rev** / overwritten*」。

而 `RecordMeta.rev` 是**既有合法业务字段**（记录自身的业务版本号），
全局禁它会误杀正常领域代码。

**处置**：
- DONE_WHEN 改为「**定序坐标里**不再有 LamportStamp / overwritten*，
  且 `rev` 不被用作冲突仲裁坐标、版本胜负依据或旧 Lamport 路径」，
  并明确「`RecordMeta.rev` 作为业务字段的解析与保存是既有合法行为，
  **不得全局禁裸词 rev**」；
- `TASK_DETAIL.arbitration_wiring` 里「本 ACT 里不存在 rev」
  改为「**定序坐标里**不存在 rev」+ 业务字段合法性说明；
- **新增一条精确门禁**（不误杀业务字段）：
  ```
  grep -nE "rev.*compareTo|compareTo.*rev|rev.*hlc|hlc.*rev" \
    drift/lib/sync/record_local_applier.dart   → EXPECT_EXIT: 1
  ```

---

## 改后自检结果（全部实跑）

```
① YAML 严格解析（含重复 key 检测） ......... 11/11 通过
② grep -c 缺双 EXPECT ..................... 0 条
③ || true 恒绿门禁 ........................ 0 条
④ TESTS_FIRST 用例字段完整性 .............. 91 个用例，字段不全 0 个
   （结构化校验 NAME/FILE/BEHAVIOR/RED_COMMAND/RED_EXPECT/COVERS 六项）
⑤ A1–A14 结构化覆盖 ....................... 14/14 全部有 COVERS 映射
⑥ 验收标准与基线 cd064c6 逐字比对 .......... 一致 ✓
⑦ VERIFICATION 命令 bash -n ............... 164 条，语法错 0 条
```

**规模变化**：91 测试 / 163 验证 / 66 自检 → **91 测试 / 164 验证 / 66 自检注入**
（新增 P2-1 的仲裁路径精确门禁一条）

**A1–A14 覆盖明细**（⑤ 的输出）：
```
A1→11        A2→02,03,11     A3→03,08     A4→04,06
A5→04,06     A6→07           A7→01,05,06,11
A8→08,09,10,11               A9→09,10     A10→10
A11→01,02,06 A12→01,02,04,11 A13→08       A14→09,11
```

---

## 给 R5 的说明

1. **P0-1 我没按 Codex 的原方案改**（没挪到 ACT 09），
   而是收缩了用例职责并说明理由。这是**边界品味问题**，
   若 R5 仍认为不可接受，按原方案挪即可，我不坚持。
2. 其余 4 项均按 Codex 的修正标准执行。
3. Codex 提出的 R5 复验门槛五条，本轮自检已覆盖前四条；
   第五条（逐条 mutation 验证门禁真能红）**属于执行阶段**的 SELF_CHECK，
   文档阶段无法预跑 —— 每个 ACT 的 SELF_CHECK 已写明注入方式与期望现象。
4. **第 5 轮闸门须人类重新授权** —— 2 轮上限已被突破两次（R3、R4）。
