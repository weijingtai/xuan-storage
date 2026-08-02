# Codex R3 闸门 Prompt（人类手动投喂）

> 用法：`cd` 到 worktree 根目录后，把下面 `---` 之间的全文投喂给 Codex。
> ```bash
> cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/mimo-storage-s1b-multipeer
> ```
> **不要让写 ACT 的那个模型自己判定通过** —— 跨模型闸门的意义就在于不是同一个模型自审。

---

你是转译闸门审查者（wjt-react）。审查对象是一批 ACT 机械执行文档，
它们要被下发给一个**便宜的执行者模型**照着写代码。你的任务不是审代码（代码一行都还没写），
而是审**这批文档能不能被机械执行、以及执行完的验收是不是真的**。

## 上下文

- 仓库：`xuan-storage`（Dart/Flutter 多包：`core` / `drift` / `firebase` / `supabase`）
- 任务：`storage-s1b-multipeer` —— 同步引擎从单 peer 改造成多 peer
- 规格：`docs/superpowers/specs/2026-07-31-storage-architecture-design.md`（§5.2.1 / §5.2.2 / §5.2.3 / §5.3 / §5.4）
- 任务纪要（含验收标准 A1–A14、决定记录、踩坑墓地）：`tasks/mimo-storage-s1b-multipeer.md`
- **审查对象**：`docs/storage-s1b-multipeer/act/01.yaml` .. `11.yaml`（11 个）
- 前两轮报告：`docs/storage-s1b-multipeer/REACT-R1-CODEX.md`、`REACT-R2-CODEX.md`
- 冷启动全景：`docs/storage-s1b-multipeer/HANDOFF.md`

## 这是第 3 轮，前两轮都判了返工

R1 提了 25 项，R2 复核后：修了 11 / 部分修 6 / 没修 5 / 因设计变更失效 4，
并另提 10 项新的必须返工。

R2 最关键的一条（转译者已实证属实）：

```
drift/lib/persistence_drift.dart:614  class DriftOutboxStore implements OutboxStore
drift/lib/persistence_drift.dart:916  class DriftSyncStateStore implements SyncStateStore
```

这两个类直接 implements core 的端口。端口一加 `required peerId`，它们必然报
`NON_ABSTRACT_CLASS_INHERITS_ABSTRACT_MEMBER` —— 编译是被【端口变更】打断的，
不是被 schema 打断的。所以"端口变更"与"实现跟进"**无法拆到两个 ACT
而不产生不可编译的中间态**。

**人类据此裁定了方案 A**，转译者产出 v3：
- schema **全部前置**到 ACT 03（v6→v7 一次做完：建 ack 表 + 加 `peer_id` 列 + `t_sync_state` 主键切三元组），
  端口与 DAO/Store 一个字不动，**声称整包全程编译绿、276 个既有测试全绿**；
- 端口变更 + drift 实现**合并进 ACT 04**，红→绿在单个 ACT 内闭环，分四阶段推进；
- 原 ACT 05–12 整体前移一位，共 11 个 ACT。

## 请重点审这些（按优先级）

### P0 — 方案 A 本身成不成立

1. **ACT 03 声称"改 `t_sync_state` 主键不破坏编译、整包全程绿"，这个断言对吗？**
   转译者的论据是：drift 的 `primaryKey` override 只影响生成的 DDL 与 upsert 冲突目标；
   `SyncStatesDao` 用的是列比较 `where(...)` 不依赖主键；且此刻 `peer_id` 只有 `'firestore'`
   一个取值，三元组唯一性与二元组等价 ⇒ 行为零变化。
   **请自己去读 `drift/lib/persistence_drift.dart` 验证**，特别注意：
   - `SyncStatesDao`（约 :350）里有没有依赖主键形状的代码（`insertOnConflictUpdate`、
     `DoUpdate(..., target: ...)`、`replace()`、生成的 `Companion` 用法）
   - drift 代码生成后 `$SyncStatesTable.$primaryKey` 的变化会不会波及手写代码
   - `drift/test/` 下 276 个既有测试里有没有依赖 `t_sync_state` 主键形状的
   **如果这个断言是假的，方案 A 的前半段就塌了，请明确指出并给出替代切法。**

2. **ACT 04 合并后是不是真的能在单个 ACT 内闭环？**
   它的四阶段（core 端口+fake → drift DAO → drift Store+既有调用点 → parity 测试）
   有没有隐含的循环依赖？阶段 1 结束时 core 全绿而 drift 全红，这个中间态
   在 ACT 内部是允许的 —— 但 ACT 的 VERIFICATION 全部是收工时跑的，
   **请确认没有哪条 VERIFICATION 会因为中间态而无法满足**。

3. **ACT 04 的粒度**。它明显超出 30–60 分钟。人类已明知代价并接受。
   请判断：给定的补偿手段（STRONG_MODEL_ONLY + 四阶段中间检查 + 九条自检）
   **够不够让一个执行者不迷路**？如果不够，请具体说缺什么，而不是笼统说"太大了"。

### P1 — R2 那 10 项修没修好

逐条核对（R2 报告在 `REACT-R2-CODEX.md`）：

1. ACT 06 实现侧 `pushToAll` 签名是否已带 `required Set<PeerId> eligiblePeers`
2. `EntityStamps` 主键是否已补 `scope_uid`；`HlcClockStates` 是否已有完整表结构
3. A13「同事务」是否已有**可调用的生产接口**（`applyWithStamp`），
   还是仍然只是测试意图 —— 特别看 ACT 10 有没有强制 applier 走它
4. ACT 08 属性测试③收敛性是否已从"同一确定性函数自比"改成**两组独立实例、不同到达顺序重放**
5. ACT 09 是否已能抓到"用减法实现 `compareTo`"（新增了 `compare_to_survives_extreme_magnitude`
   + 文本 grep）—— **请判断这两条加起来够不够**
6. ACT 10 是否已区分"本地无实体"与"本地有实体但边表无戳"
7. ACT 10 是否已清掉 `LamportStamp` / `rev` / `overwritten*` 残留
8. `<ACT_BASE>` 是否全部改成可执行的 `"$(cat .act-base)"`
9. `hlc_dart` 是否钉死 `1.1.0+2`；dartdoc 门禁是否扫满 8 个文件并断言文件数
10. A14 规格是否补了 signed int64 的 `l` 上限（`0 <= l < 2^47`）与 deviceId 的 UTF-8 字节序基准

### P2 — 通用门禁质量

- 有没有**恒绿**的验证命令（`|| true`、`grep -c` 只写一个 EXPECT、`grep -q` 方向写反、
  `git diff main..` 在 main 里没有该文件时恒为空）
- 有没有**同义反复**的断言（`expect(SomeClass, isNotNull)`）
- SELF_CHECK 的每一条注入，**真的能让它点名的那条测试变红吗**？
  有没有哪条注入其实红的是别的测试、或者根本不会红
- 编号/交叉引用有没有陈旧残留（v3 做了一次 12→11 的重编号）
- A1–A14 每一条**至少有一个 ACT 的 TESTS_FIRST 覆盖**吗？请抽验 A7 / A13 / A14
  （R2 抽验时这三条不通过）

## 输出格式

```
## 判定：通过 / 返工

## 方案 A 是否成立
（ACT 03 的"不破坏编译"断言 —— 你自己验证的结论 + 证据行号）

## R2 十项复核
逐条：已修 / 部分修 / 未修 + 证据

## 新发现的必须返工项
按 P0/P1/P2 分级，每项给出：文件 + 行号 + 为什么是问题 + 怎么改

## A1–A14 覆盖抽验
（重点 A7 / A13 / A14）
```

## 纪律

- **只报你自己验证过的**。拿不准就标"存疑"，不要凑数。
- 引用**具体文件与行号**，不要只说"某个 ACT 有问题"。
- 如果你认为**计划本身**（而不是转译）有病，明说 —— 前两轮不收敛的通常原因就是这个。
- 不要因为已经是第 3 轮就放宽标准。**一个绿的门禁如果证明不了自己能红，它就是假的。**
