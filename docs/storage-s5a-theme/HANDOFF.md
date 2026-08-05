# S5a 主题样式资源分发 · ACT 冷启动交接（2026-08-04）

> **给下一个接手的 AI agent**：你没有任何前情记忆。按本文档从上往下读一遍再动手。
> 全文约 12 分钟阅读量，读完你应当能独立回答："这个任务要干什么、现在到哪一步、下一步做什么"。

---

## 0. 三十秒版本

- **任务**：`storage-s5a-theme` -- 把 app 主题样式做成可分发的 XRAP 资源包：交付**契约层 + reference 内存实现**，`theme` 包零改动、启动路径零网络。
- **当前阶段**：设计稿 v6 已过 R1–R5 五轮评审（R5 报告 `docs/reviews/2026-08-04-s5a-theme-plan-eng-review-r5.md@08abb03`，判定 **PASS-WITH-REVISIONS**，9/9 闭合、0 P0/P1、2 P2 文字级）。**已转译为 ACT，尚未执行**。
- **下一步**：按 §4 顺序从 ACT 01 开始，严格遵循 `DEPENDS_ON`。**每个 ACT 先写测试再写实现**（TESTS_FIRST）。
- **范围铁律**（人类四条裁定，不得重开）：下载/校验/世代/指针翻转/回滚/GC/幂等全归 XRAP；S5a 只写 `DatasetMaterializer` 的一个实现 + 一层用户覆盖；不做用户自定义覆盖层进 XRAP；`ConfigBootstrap` 三占位符不是 S5a 阻塞项。
- **工作目录**：`xuan-storage/.claude/worktrees/mimo-storage-s5a-theme/`，分支 `worktree-mimo-storage-s5a-theme`

---

## 1. 你在哪儿：目录与文件

```
xuan-storage/                                    ← Git 仓库根（xuan-migration 是容器目录，不是仓库！）
├── .claude/worktrees/mimo-storage-s5a-theme/    ← 【你在这里工作】
│   ├── tasks/mimo-storage-s5a-theme.md          ← 任务纪要：目标/范围/验收 A1–A21,P1–P7/决定记录
│   ├── docs/storage-s5a-theme/
│   │   ├── HANDOFF.md                           ← 本文件
│   │   └── act/01..07.yaml                      ← 7 个 ACT（机械执行文档，执行者只读这个）
│   ├── docs/superpowers/specs/
│   │   └── 2026-08-03-s5a-theme-resource-distribution-design.md  ← 设计稿 v6（唯一真相源，按 § 号定位）
│   ├── docs/reviews/2026-08-04-s5a-theme-plan-eng-review-r5.md   ← R5 评审报告（含 XRAP 契约逐条核对证据）
│   ├── core/                                    ← 唯一会被改的包（persistence_core）
│   │   ├── lib/model/                           ← 契约层（8 个新文件）
│   │   ├── lib/reference/                       ← reference 实现层（4 个新文件，新目录）
│   │   └── test/                                ← 测试（8 个新文件）
│   ├── scripts/                                 ← 2 个新门禁脚本
│   └── drift/pubspec_overrides.yaml             ← 【gitignored，环境关键】见 §5
└── core/lib/model/dataset/                      ← XRAP 契约（S5b 已交付，【只读，禁改】）
```

**规格来源唯一真相**：设计稿 v6（`docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md`）。
**按 § 号定位原文，不要凭记忆写**。每个 ACT 的 `SCOPE.READ` 已给精确 § 号。

---

## 2. 设计目标：S5a 要解决什么

把 app 主题样式（颜色/圆角/阴影这类 design token）做成可分发的资源包，走仓内已有的 **XRAP**（资源资产协议，在 `core/lib/model/dataset/`）。S5a 交付两层：

| 层 | 内容 | 位置 |
|---|---|---|
| **契约层**（8 文件） | 端口签名 + 值类型 + 策略声明 + XRAP 数据集声明（零实现） | `core/lib/model/theme_*.dart` |
| **reference 实现层**（4 文件） | 内存 Map 的完整行为实现（合并算法 + materializer + store + 装配） | `core/lib/reference/` |
| **测试与支撑**（8 文件） | 契约测试 + 合并语义 + materializer + 启动路径 + bench | `core/test/` |
| **门禁脚本**（2 文件） | analyze gate + residue gate | `scripts/` |

**为什么有 reference 实现**：三层合并/差量写入/缓存 identical/启动零网络是 S5a 核心价值，抽象接口产生不了行为无法验证。reference 是纯内存、零 IO、零网络、不依赖 drift，是后续生产实现（drift）的对照基准。

**三层合并模型**：`用户覆盖层（private，可同步） > 已装主题包（resource，只读） > bundled 默认（编译进包）`，逐 key 取第一个命中。读写不对称：读=合并结果，写=只碰覆盖层。

---

## 3. XRAP 契约事实（S5a 只消费，不重定义；R5 已逐条核对）

| 事实 | 出处 | 对 S5a 的含义 |
|---|---|---|
| `DatasetMaterializer` 是唯一可插拔点 | `dataset_materializer.dart:1-5` | S5a 只实现 `materialize` 与 `dropGeneration` |
| 调用 `materialize` 时已完成 sha256 校验 | `dataset_materializer.dart:43-45` | S5a 不再校验完整性 |
| 只写入参 generation，不触其它世代 | `dataset_materializer.dart:34-35` | 落地结构必须有世代判别 |
| 不改活跃指针（翻转归安装器） | `dataset_materializer.dart:35-36` | S5a 不实现切换原子性 |
| `dropGeneration` 必须幂等 | `dataset_materializer.dart:62` | 删不存在世代不是错误 |
| `MaterializeOutcome` 只有默认构造器 | `dataset_materializer.dart:23-26` | 无 `.success` 命名工厂 |
| `materialize` 入参是 `Stream<List<int>>` | `dataset_materializer.dart:50-56` | 不是 `Uint8List` |
| `DatasetDescriptor.materializer` 是**工厂** | `dataset_descriptor.dart:44` | `final DatasetMaterializer Function() materializer;` -- 这决定 §4.5 装配形状 |
| `DatasetInstaller` 抽象方法恰好六个 | `dataset_installer.dart:210-256` | ensureInstalled/checkForUpdate/active/generations/rollbackTo/collectGarbage，**无 `install` 方法** |
| 注册期强制 publisher==official | `dataset_registry.dart:62-68` | 用户覆盖层进不了 XRAP（裁定 2） |
| `endpointFor` 未配置返回 null | `dataset_source.dart:61` | ConfigBootstrap 占位符不阻塞（裁定 4） |

> ⚠ **`core/lib/model/dataset/` 下任何文件都不得修改**。S5a 需要的扩展点若不够，走 stop condition #4（协议变更流程），不得在 S5a 侧绕过。

---

## 4. ACT 切分与依赖（按顺序执行）

| ACT | 标题 | TYPE | DEPENDS_ON | 主要交付文件 | 覆盖验收 |
|---|---|---|---|---|---|
| 01 | 中立数据结构 + 溯源类型 | contract | [] | theme_token_types.dart, theme_resolution.dart | A6,A15,A16 |
| 02 | 主门面 + 值类型 + 注入端口 | contract | [01] | theme_resource_store.dart, theme_value_types.dart, theme_source_ports.dart | A3,A5a,A5b,A6,A7 |
| 03 | 策略 + XRAP 数据集声明 + 注册 | contract | [01,02] | theme_storage_policies.dart, theme_dataset.dart, theme_module_registry.dart | A8 |
| 04 | 合并算法纯函数（reference） | reference | [01] | theme_token_merger.dart | A9-A13,A14c,A19,P1,P7 |
| 05 | materializer + token store（reference） | reference | [03] | in_memory_theme_materializer.dart | A20 |
| 06 | resource store + 装配入口（reference） | reference | [02,04,05] | in_memory_theme_resource_store.dart, theme_assembly.dart | A6,A7,A8,A15,A16,A21,P2,P3,P4,P5,P6 |
| 07 | 门禁脚本 + 总验收 | gate | [01-06] | run_s5a_analyze_gate.sh, run_s5a_residue_gate.sh | A1,A2,A3,A4,A17,A18,残留门禁 |

**执行原则**：
1. **TESTS_FIRST**：每个 ACT 先写测试（测试会红，因为实现不存在），再写实现让测试变绿。
2. **不修改既有文件**：ACT 01-06 只新增；ACT 07 只新增脚本。`theme` 包零改动（A4），`xuan-qizhengsiyu/lib/painter/**` 零改动（A17）。
3. **每个 SELF_CHECK 必须"临时改坏 -> 确认变红 -> 改回 -> git status 为空"**。一个绿的门禁证明不了自己能红就是假的。
4. **变红要红在对的地方**：注入变异后若红在编译失败而非目标断言，那次自检不算数。

---

## 5. 环境（三个坑，已就绪）

1. **worktree 路径**：`.claude/worktrees/mimo-storage-s5a-theme/`（比 s1a/s1b 的 `.worktrees/<name>/` 深一级）。
2. **`drift/pubspec_overrides.yaml`**（gitignored，环境关键）：已由 R5 评审轮建好，sibling-repo 路径用 **5 级 `../`**（`../../../../../repository-interface-*`），不是 s1d 模板的 4 级。**不要动这个文件**；若被删，照 `docs/storage-s1b-multipeer/HANDOFF.md` 的 s1b 模板改路径深度重建。core/p2p 不需要 overrides。
3. **开工第一件事**：每个包 `flutter pub get`（否则 `dart analyze` 报 500+ `uri_does_not_exist` 假 issue）。core/p2p/drift 在 R5 轮已 get 过，`.dart_tool/` 若被清需重 get。

**基线前置**（stop condition #1）：开工第一步验证
```bash
ls core/lib/model/storage_policy.dart core/lib/model/storage_policy_registry.dart \
   core/lib/model/storage_classification.dart core/lib/model/cancellation_token.dart \
   core/lib/model/dataset/dataset_materializer.dart
```
五个文件缺任何一个 → **立即停**，基线错误。

---

## 6. 执行前必须确认的"执行门禁"（来自 R5 未完成项）

> ⚠ **R5 唯一未闭项**：派工书 §九验收命令串后半段未跑完。**这 gating 的是 ACT 的"执行"，不是"转译"**。ACT 文档已就绪可读，但执行者动手前必须先确认以下命令全绿：

```bash
cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme
bash scripts/run_s1b_analyze_gate.sh   # EXIT 0
(cd core && flutter test)              # EXIT 0
(cd drift && flutter test)             # EXIT 0  (前提: drift/pubspec_overrides.yaml 存在)
(cd p2p && flutter test)               # EXIT 0
```

- **全绿** → 开工 ACT 01。
- **任一红在测试断言** → v6 merge main 引入回归，**先上报人类**，不要开工（这是 v6 的问题不是 ACT 的问题）。
- **红在环境**（`uri_does_not_exist` / pub get 失败）→ 按 §5 坑修环境后重跑，不影响开工。

R5 轮已跑通：`run_monorepo_convention_check.sh` ✅、`run_s1a_analyze_gate.sh` ✅（基线 57）。

---

## 7. Stop conditions（触发即停，报人类；与设计 §11.4 / 纪要逐条同构）

1. **S1a 契约或 XRAP 契约不在基线** -- §5 基线前置命令缺任何一个。
2. **本 ACT 任何文件读取 `theme` 仓库** -- 跨仓库读取在 S5a ACT 范围外。测试用 bundled token 由 `ThemeBenchFixture` 内联常量提供，不从 `theme/` 读。构建脚本读 `theme/config/presets/*.yaml` 属独立任务 `BUILD-THEME`（见 §8），不在本 ACT。
3. **`theme` 包出现任何改动** -- A4 门禁触发即停。
4. **发现需要在 `DatasetMaterializer` 之外新增扩展点** -- 走协议变更流程，不得在 S5a 侧绕过（设计 §4.2）。
5. **需要触碰 `xuan-qizhengsiyu/lib/painter/**`** -- Canvas 提取所有权，须先握手。

> `ConfigBootstrap` 三占位符**不是** stop condition（裁定 4）。S5a reference 零网络、冷启动只用内置世代。

---

## 8. 移交后续任务的项（每项有唯一承接 ID，不得丢失）

| 承接 ID | 项 | 状态 |
|---|---|---|
| **BUILD-THEME** | 主题构建脚本：`theme/config/presets/*.yaml` → `.jsonl` 载荷 + sha256/bytes/rowCount 真值 → `DatasetManifest` | **新建任务，尚未立项**。转 ACT 时须同时创建它的占位纪要（哪怕只有目标 + 三条 SHALL：spec.md :60 / :86 / 第二轮评审 #5），否则三条 SHALL 会悄悄丢失。**R5 Finding F2 指出此项未落成真实文件，执行者应在 ACT 07 收尾时创建占位** |
| **THEME-DRIFT** | 主题落地 drift 表与 schema 版本（reference 用内存 Map，生产需建表） | 新建任务，与 S1d/S5b 协调 schemaVersion |

---

## 9. 验收命令（ACT 07 收尾时跑，全绿才算 S5a 完成）

```
bash scripts/run_s5a_analyze_gate.sh && bash scripts/run_s5a_residue_gate.sh && (cd core && flutter test --exclude-tags benchmark)
```

---

## 10. 怎么读一个 ACT

每个 `act/NN.yaml` 自包含，字段含义：
- `SCOPE.READ`：动手前必读的文件（设计稿按 § 号定位 + XRAP 契约真文件）
- `SCOPE.WRITE`：本 ACT 要新建的文件（只新增，不改既有）
- `SIGNATURE`：必须逐字满足的形状约束（照抄，不要"优化"）
- `CONSTRAINTS`：易踩的坑与禁项
- `TESTS_FIRST.CASES`：先写的测试用例（每个有 `RED_COMMAND` 证明它能红）
- `VERIFICATION`：本 ACT 完成的判据命令（每条有 `EXPECT_EXIT`）
- `DONE_WHEN`：收尾条件

**照着 ACT 做就行，不要自行推断架构**。架构问题已在 R1–R5 五轮评审中关闭。
