# S1b 冷启动交接（2026-08-02）

> **给下一个接手的 AI agent**：你没有任何前情记忆。按本文档从上往下读一遍再动手。
> 全文约 15 分钟阅读量，读完你应当能独立回答："这个任务要干什么、现在到哪一步、下一步做什么"。

---

## 0. 三十秒版本

- **任务**：`storage-s1b-multipeer` —— 把 xuan-storage 的同步引擎从「单 peer（云端）」改造成「多 peer」。
- **当前阶段**：**转译 v3.1 完成（已回应 Codex R3 的 6 项），等待人类裁定是否需要 R4**。代码一行都还没写。
- **下一步**：人类裁定 —— 直接下发给执行者（见 §7），或再走一轮 R4 验证本轮改动。
- **最新提交**：见 `git log -1`（v3.1 = R3 返工修复）
- **工作目录**：`xuan-storage/.worktrees/mimo-storage-s1b-multipeer/`，分支 `agent/mimo/storage-s1b-multipeer`

---

## 1. 你在哪儿：目录与文件

```
xuan-storage/                                    ← Git 仓库根（xuan-migration 是容器目录，不是仓库！）
├── .worktrees/mimo-storage-s1b-multipeer/       ← 【你在这里工作】
│   ├── tasks/mimo-storage-s1b-multipeer.md      ← 任务纪要：目标/计划/验收标准 A1–A14/决定记录/踩坑墓地
│   ├── docs/storage-s1b-multipeer/
│   │   ├── HANDOFF.md                           ← 本文件
│   │   ├── act/01..11.yaml                      ← 11 个 ACT（机械执行文档，执行者只读这个）
│   │   ├── REACT-R1-CODEX.md                    ← 第 1 轮跨模型闸门报告（返工，25 项）
│   │   ├── REACT-R2-CODEX.md                    ← 第 2 轮闸门报告（仍返工，10 项新的）
│   │   └── CODEX-R3-PROMPT.md                   ← 给 Codex 的第 3 轮验收 prompt（人类手动投喂）
│   ├── core/ drift/ firebase/ supabase/         ← 四个 Dart 包
│   ├── drift/pubspec_overrides.yaml             ← 【gitignored，环境关键】见 §5
│   └── firebase/pubspec_overrides.yaml          ← 【gitignored，环境关键】见 §5
└── docs/superpowers/specs/2026-07-31-storage-architecture-design.md   ← 设计稿 1659 行（主工作区也有）
```

**规格来源唯一真相**：设计稿 `§5.2.1 / §5.2.2 / §5.2.3 / §5.3 / §5.4 / §9`。
**按 § 号定位原文，不要凭记忆写。**

---

## 2. 设计目标：S1b 到底要解决什么

设计稿 §5.2.1 列了**六个硬阻断点** —— 不拆掉这六个，任何 peer 实现（LAN/WebRTC）都无法开工：

| # | 阻断点 | 不改的后果 |
|---|---|---|
| 1 | `t_outbox` 没有 per-peer ack | 一条操作对 N 个对端只有一个成败状态 |
| 2 | `t_sync_state` 主键 `{scopeUid, entityType}` 没有 peer 维度 | 换个 peer 就从错误的位置续拉，静默丢变更 |
| 3 | `markSuccess({operationId, atUtc})` 没有 peerId | **二选一都不可接受**：标 success → 离线的 LAN peer 永远收不到这条操作；标 failed → 一个长期离线的 peer 会在 10 次重试内把整个 outbox 推成 dead |
| 4 | `push` 返回单个 `SyncError?` | N 个对端的结果压不成一个 |
| 5 | 没有 fan-out 推送实现 | — |
| 6 | `getCapabilities` 返回 `RegionCapabilities` | 按 region 而非按 peer 做能力协商 |

另外三块（§5.2.3 / §5.3 / §5.4）：

- **§5.2.3 两个既有缺陷**：
  ① `record_local_applier.dart:60-61` 的 `canAdvanceCursor: true` **恒为真** —— 某条 change 应用失败时，`sync_coordinator.dart:382` 的守卫不触发，**游标照常推进，那条变更永久丢失**。
  ② record 主线是 **RWW（远端无条件覆盖本地），不是 LWW** —— 全文件对 `updatedAt/rev` 只有解析、没有比较逻辑。
- **§5.3 冲突可见化**：冲突时必须保留被覆盖的版本并使其可回溯。**双向**：takeRemote 留本地、keepLocal 留远端（因为 skipped 不阻止游标推进，被丢弃的远端变更再也拉不到）。
- **§5.4 两道锁**：① push 侧策略过滤（`shared` 类记录不得下发给非 cloud 对端）；② E2EE（不在 S1b 范围）。
  ⚠ 设计稿明确**删除**了上一版「拓扑上无法到达」的说法并标注【该说法为假】—— 过滤是主动的，不是被动的。

### 冲突定序方案（人类 2026-08-02 裁定）

用 **`hlc_dart 1.1.0+2`（钉死版本）** 的 HLC（Hybrid Logical Clock）。经四候选实测比选后选定：

| 候选 | 否决理由 |
|---|---|
| `drift_crdt` | 装不上（依赖 `sqlite_crdt ^4.0.0`，pub.dev 最高 3.x） |
| `ditto_live` | 闭源商业，初始化要 Portal 账号 |
| `sql_crdt` | 抽象层可用 drift 后端，但 200 个写调用点要改裸 SQL + 全局软删 |
| `crdt_lf` | 质量最高但为协同文档编辑而生，需双写 + 升 drift 到 2.34 |

**关键澄清（务必记住）**：**HLC 单独不构成全序**。`HybridLogicalClock` 只有 `(l, c)`，**没有 nodeId**，两台设备同毫秒写会 `isConcurrentWith == true`。
所以定序坐标是 **`(hlc, deviceId)`**，类型叫 `VersionStamp`。
HLC 的价值是消灭**因果倒置**（B 收到过 A ⇒ B 必 > A），把"随机丢数据"降级为"并发时按固定规则选一个"。

**戳存哪**：drift 边表 `t_entity_stamp`，主键 `(scope_uid, entity_type, entity_id)`。
**为什么用边表**：`RecordMeta` 在 `repository-interface-record` 仓库，改它要连带下游 12 个业务仓库。边表让 S1b 完全留在 xuan-storage 内，**所有 Data class 零改动**。

---

## 3. wjt 协议链：你现在处在哪一环

```
wjt-plan(立项) → wjt-act(转译) → wjt-react(闸门, Codex 跨模型) → 下发执行 → 人类验收
                                  ↑ 你在这里
```

- **wjt-react 硬规则**：循环 **≤2 轮**不收敛就停止、上报人类（"通常是计划本身有病，不是转译的错"）。
- **R1 + R2 已用完**。R2 之后人类裁定了**方案 A**（见 §4），转译者据此产出 **v3**。
- **v3 尚未过任何闸门。** 第 3 轮是人类额外授权的，不是协议自动续期。

### 三轮闸门的历史

| 轮次 | 判定 | 要点 |
|---|---|---|
| **R1** | 返工，25 项 | 最重：**P0-1 channel 过滤被 `pushToAll` 架空**（peekBatch 辛苦挑出该对端能收的记录，`pushToAll` 转头发给所有人，两边测试都绿） |
| **R2** | 仍返工，10 项新的 | 最重：**编译死锁没修好，而且转译者修错了地方**（见下） |
| **R3** | 返工，6 项 | 方案 A 成立性**获确认**；6 项里转译者复核后**采纳 6、驳回 1**（P2-1 重复 key 误判）。产出 v3.1 |

**R3 的六项与处置**（详见 `REACT-R3-CODEX.md` 原文 + `REACT-R3-REMEDIATION.md` 复核）：

| 项 | 内容 | 处置 |
|---|---|---|
| ACT 04 阶段1 | 端口一改 core 调用点立刻编译不过，阶段检查自相矛盾 | 已补入调用点迁移 |
| P0-1 | 只有写接口 `applyWithStamp`，没有戳读取接口与 applier 构造契约 | ACT 08 加 `getEntityStamp`；ACT 10 钉死构造签名 + 8 个构造点迁移样板 |
| P0-2 | 收敛性不是 HLC 承诺的性质（c 受到达顺序影响），测了会假红 | 拆成独立用例，先冻结戳再用两个独立归并器验 |
| P0-3 | deviceId 只说"字典序"，执行者会用 UTF-16 的 `String.compareTo` | 契约改 UTF-8 字节序 + U+10000/U+E000 分歧用例 + 两道文本门禁 |
| P1-1 | "改成减法则极端量级用例必红"是假的（合法值域内不溢出） | 权威门禁改为文本 grep，用例降级兜底 |
| P2-1 | 声称有重复 YAML key | **驳回**：严格校验器零命中，四处均为不同 list item 的同名字段 |
| P2-2 | A1 没有任何用例证明门禁能红 | ACT 11 加注入型自测脚本 `test_s1b_analyze_gate.sh` |

**R2 那条结构性发现（转译者已独立实证）**：

```
drift/lib/persistence_drift.dart:614  class DriftOutboxStore implements OutboxStore
drift/lib/persistence_drift.dart:916  class DriftSyncStateStore implements SyncStateStore
```

这两个类**直接 implements core 的端口**。端口一加 `required peerId`，它们必然报
`NON_ABSTRACT_CLASS_INHERITS_ABSTRACT_MEMBER` —— **编译是被【端口变更】打断的，不是被 schema 打断的**，加不加列都一样红。
v2 做的"把 schema 拆成纯加法保持可编译"救错了对象。

暴露的是**分解方式本身**：静态类型 + 跨包 `implements` 下，"端口变更"与"实现跟进"**无法拆到两个 ACT 而不产生不可编译的中间态**。

---

## 4. 方案 A：v3 的结构（人类 2026-08-02 裁定）

人类在三个走法中选了 **A**：

- **A（选中）** 合并 ACT，让端口与实现同生共死。代价：那个 ACT 会很大。
- B 接受不可编译中间态，改验收口径。代价：要造一个只为绕过编译问题的测试 harness。
- C 停下重新立项。

### 11 个 ACT（严格单链 01→11，无环）

| ACT | 内容 | STRONG | 收工状态 |
|---|---|---|---|
| 01 | `SyncPeer` / `PeerCapabilities` / `PeerId` / `PeerFanoutPusher` 契约（零实现） | | 只加文件 |
| 02 | `RemoteGateway → SyncPeer` 全量迁移（14 文件）+ 修 firebase 两个既有 ERROR | | 三包全绿 |
| **03** | **drift schema 全量前置 v6→v7**：ack 表 + `peer_id` 列 + 主键切三元组 | ★ | **全程整包绿** |
| **04** | **端口加 `peerId` + drift 实现跟进**，12 个方法，红→绿单 ACT 内闭环 | ★ | 整包重新全绿 |
| 05 | `PeerEligibility` 单一判定源 + peekBatch 按 channel 过滤（fail closed） | | |
| 06 | `PeerFanoutPusher` 实现按 `eligiblePeers` 并发扇出 + coordinator 接线 | | |
| 07 | `PeerRegistry` / `PeerPushOutcome` / `pullOnce(peerId)` + per-peer 退避 | ★ | |
| 08 | HLC 接线 + 时钟持久化 + `t_entity_stamp` 边表 + `applyWithStamp` + v8 迁移 + 属性测试 | ★ | |
| 09 | `ConflictArbiter`：`(hlc, deviceId)` 全序 + 冲突双向留档 | ★ | |
| 10 | 修 `canAdvanceCursor` 恒真 + 接入仲裁 + 畸形 payload 归 failed | | |
| 11 | HLC 线上格式规格（A14）+ barrel + 架构守卫 + `run_s1b_analyze_gate.sh` | | |

**规模**：91 测试用例 / 163 验证命令 / 66 条自检注入，11 个 ACT 全部有 ON_FAIL。

### 让 ACT 03 能"全程绿"的关键事实（**必须理解，否则会以为它写错了**）

改 `t_sync_state` 主键 **不破坏编译**：
- drift 的 `primaryKey` override 只影响生成的 DDL 与 upsert 的冲突目标；
- `SyncStatesDao` 用的是 `where(tbl.scopeUid.equals(..) & tbl.entityType.equals(..))`，**是列比较，不依赖主键**，照常编译；
- 此刻 `peer_id` 只有 `'firestore'` 一个取值，三元组唯一性与二元组**等价** ⇒ **行为零变化**。

所以 schema 可以整体前置，端口变更单独留给 04。

### ACT 04 超粒度是已知代价

明显超出 30–60 分钟的常规粒度，**是人类明知代价后的选择**。补偿手段写在 ACT 文件里：
`STRONG_MODEL_ONLY` + **四阶段推进**（每阶段一次可验证的中间检查）+ 九条自检。
**执行者不得自行再拆**（拆了就回到不可编译中间态）。

四阶段：
1. core 端口 + 内存 fake → `cd core && flutter test` 全绿（drift 此时必然红，**正常**）
2. drift DAO 层 → `dart analyze` 的 ERROR 数**在下降**
3. drift Store 层 + 既有调用点 → ERROR 数为 **0**
4. parity 测试 + 收口 → 三包全绿

---

## 5. 环境：三个必须知道的坑

### ① `pubspec_overrides.yaml` 是 gitignored 的，换机器要重建

worktree 里 `drift/` 与 `firebase/` 各有一个 `pubspec_overrides.yaml`，**不在 git 里**。丢了 `pub get` 就会失败。

**语义陷阱**：`dependency_overrides` 整块**替换** pubspec.yaml 的同名块，**不是合并**。
所以 `drift/pubspec_overrides.yaml` 必须是原 19 条的**完整副本**再改其中 5 条，只写 5 条会抹掉另外 14 条。

改动的 5 条（**一律相对路径，禁止绝对路径** —— 人类规则）：
```yaml
  persistence_core:
    path: ../core                                      # 同级包
  repository_interface_record:
    path: ../../../../repository-interface-record      # worktree 深两级
  repository_interface_xiang:
    path: ../../../../repository-interface-xiang
  repository_interface_divination_tag:
    path: ../../../../repository-interface-divination-tag
  repository_interface_media:
    path: ../../../../repository-interface-media
```
`firebase/pubspec_overrides.yaml` 只需一条 `persistence_core: path: ../core`。

**为什么这 4 个外部依赖不能走 Gitea**：那几个 interface 包**彼此之间用相对路径互相引用**，pub 禁止路径逃出 git 仓库边界，会报
`Invalid description ... the path "../repository-interface-record" cannot refer outside the git repository`。已实测失败并回退。

### ② firebase 包的 Gitea pin 藏了 27 个提交的真相

`firebase/pubspec.yaml` 原本从 Gitea 拿 `persistence_core`，钉在 `bc7f91d`（= `gitea/main`）。
**本地 main 超前 27 个提交且未推送**，那 27 个提交里装着整个 S1a，包括「给 `RemoteGateway` 加 `getCapabilities()`」。
于是 firebase 一直编译的是**没有 getCapabilities 的旧 core**，两个实现类没跟上也不报错 —— 藏了很久。

挂上本地 core 后真相显形，起点是：
- `cd firebase && dart analyze` → 38 issues（**2 ERROR** / 17 WARNING / 19 INFO）
- `cd firebase && flutter test` → 100 通过 / 3 跳过 / **4 失败**

ACT 02 负责把这 4 个失败清零。**这是收紧，不是降低口径。**

### ③ 本地 main 有 27 个提交未推 Gitea

**S1b 的全部工作都建在这批未备份的提交上。** 这是真实风险，值得优先处理。
（推送是对外动作，需要人类明确授权。）

---

## 6. 下一步：你该做什么

**R3 已做完**（Codex 判返工 6 项 → 转译者复核后采纳 6、驳回 1 → 产出 v3.1）。
现在是**人类裁定点**，两条路：

### 路 A：直接下发执行（进 §7）

v3.1 已修掉 R3 的全部实质问题，自检全绿。
若人类认为不必再验，直接按 §7 从 ACT 01 开始下发。

### 路 B：再走一轮 R4，验证本轮改动

⚠ **wjt-react 的 2 轮上限已被人类额外授权突破一次（R3 就是那次兑现）。
第 4 轮必须重新请示人类，agent 不得自行发起。**

若人类授权 R4，重点验这三处（都是本轮新写、还没被任何外部模型看过的）：
- ACT 10 的 `applier_constructor_signature` —— 四个新增回调的注入方式是否真能机械照抄
- ACT 08 的 `convergence_over_fixed_stamps` —— 收敛性挪到归并层后，断言是否还成立
- ACT 11 的 `test_s1b_analyze_gate.sh` —— 三段注入是否真能让门禁红

**agent 不要自行判定"过了"** —— 跨模型闸门的意义就在于不是同一个模型自审。
返工的话，逐条独立复核（**不要照单全收，Codex 会错** —— R3 的 P2-1 就是误判）。

> ⚠ 若要再投 Codex，记得在 prompt 里加一句
> 「把报告写到 `docs/storage-s1b-multipeer/REACT-R4-CODEX.md`」——
> R3 那次没写，报告只留在终端里差点丢了。

---

## 7. 下发执行的规矩

- 执行者只读 `act/NN.yaml`，**按 ORDER 顺序一个一个做**，不许跳、不许并行（DEPENDS_ON 是严格单链）。
- `STRONG_MODEL_ONLY: true` 的 ACT（03/04/07/08/09）**必须用强模型**，不能丢给便宜执行者。
- 每完成一个 ACT 就执行 `wjt-handoff` 落盘进度到纪要，**不要等会话结束**。
- 每个 ACT 内部纪律：**TESTS_FIRST 先红 → 写实现 → 绿 → SELF_CHECK 注入改坏确认能变红 → 改回**。
  **SELF_CHECK 不做不算完成。** 一个绿的门禁如果证明不了自己能红，它就是假的。

---

## 8. 四条门禁写作纪律（S1a/S5c 返工换来的，别再踩）

1. **`grep -c` 无匹配时打印 "0" 且退出码 1** ⇒ `EXPECT_STDOUT` 与 `EXPECT_EXIT` **两个都要写**，只写一个会漏判。
2. **测试里不要用 `fail()` 做断言** —— 调用方常有 catch-all，会吞掉 `TestFailure`，测试假绿。用**计数式 spy**。（S5c F1 的教训）
3. **文本扫描类门禁必须有写死的覆盖下限** —— 没有下限，glob/正则写错导致扫到 0 个文件时门禁会静默全绿。（S1a A10 返工两轮的教训）
4. **`|| true` 让门禁恒绿** —— 任何以 `|| true` 结尾的验证命令都是假的。
5. **`expect(SomeClass, isNotNull)` 是同义反复** —— 必须真的构造实例并驱动行为。（S5c F2 的教训）
6. **macOS `/bin/bash` 是 3.2.57** —— 没有 `declare -A`，没有 `mapfile`/`readarray`。

---

## 9. 铁律（违反会造成不可逆后果）

- **AI 不得合并到 `main`**（S1a 时的一次性授权已用完）。
- **推送到远端是对外动作**，每次都要人类明确授权，前一次授权不延续到下一次。
- **不得修改任务纪要的「验收标准」区（A1–A14）** —— 转译者与执行者都无权改它。
  有一条门禁与基线提交 `cd064c6` 逐字比对（该区共 35 行，2026-08-02 实测一致）。
- **`xuan-migration` 是容器目录，不是 Git 仓库** —— 不要在它根目录执行 git 命令。
- **xuan-storage 内部同级包用相对路径，外部仓库走 Gitea，禁止绝对路径。**
- 产出文档以**中文**为主，源码注释也用中文；只有目录路径、类名等用英文表述才清楚的地方才用英文。

---

## 10. 当前状态快照

| 项 | 状态 |
|---|---|
| 转译 | **v3.1 完成**（R3 返工修复） |
| 跨模型闸门 | R1 返工 / R2 返工 / R3 返工 6 项 → **已修复，等人类裁定是否 R4** |
| 代码 | **一行都没写** |
| 分支 | `agent/mimo/storage-s1b-multipeer`，worktree 干净 |
| 未推送 | 本地 `main` 超前 `gitea/main` **27 个提交** |
| 主工作区未提交 | `firebase/infrastructure/emulator/firestore.rules`（**不是本任务改的，别动**）、`.codegraph/daemon.pid`（同上） |

### v3.1 的自检结果（已跑）

```
YAML 严格解析 ............ 11/11（含重复 key 检测，PyYAML 自定义 loader）
编号自洽 ................. 11/11（TASK_ID = 文件名 = ORDER，DEPENDS_ON 严格单链）
grep -c 缺双 EXPECT ...... 0 条
<ACT_BASE> 占位符残留 .... 0
|| true 恒绿门禁 ......... 0（仅剩"禁止它"的说明文字）
LamportStamp 残留 ........ 仅剩"禁止它"的守卫本身
验收标准 A1–A14 .......... 与 cd064c6 逐字一致
```

> 💡 **YAML 严格校验值得常设**：本轮它当场抓出了转译者自己引入的两处语法错误 ——
> **list item 以反引号开头**（`  - \`foo\` 红了 → ...`）会被 YAML 当成特殊字符而解析失败。
> 写 ACT 时若一行要以反引号开头，前面加个词（如「用例 \`foo\` ...」）。

---

## 11. 已知的未决问题（v3.1 没解决的）

1. **ACT 04 超粒度** —— 已知代价，非缺陷，但执行时可能真的做不完一轮会话。若执行者反馈做不动，选项是：给它更强的模型 / 允许它分多次提交（ACT 文件已允许，no-touch 守卫用 `"$(cat .act-base)"` 而非 `HEAD~1`）。
2. **Firestore 侧 `rev` 恒为 null** —— 这是 v1/v2 时代的决定，HLC 方案下已不再依赖 rev，但纪要「决定记录」里那条历史记录仍在，**不要按它执行**，以 v3.1 的记录为准。
3. **oplog compaction（§5.3）** —— 数据模型已由 `t_outbox_peer_ack` 确定（"所有已知 peer 均已 success 的 operationId 可被压缩"直接查这张表），但**压缩逻辑本身不在 S1b 范围**。
4. **E2EE（§5.4 第二道锁）** —— 不在 S1b 范围。
5. **`local == null` 的两义性** —— 区分责任明确划给 ACT 10 的 applier，ACT 10 有专门的测试守着（R3 后 ACT 10 已补 `readLocalRecord` 回调，区分通道完整）。这是设计选择不是遗漏。
6. **第 4 轮闸门** —— 是否 R4 由人类裁定，agent 不得自行发起（2 轮上限已被额外授权突破一次）。
