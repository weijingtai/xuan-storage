---
agent_id: S5a-Theme
phase: S5a
phase_title: 样式资源分发（主题包下载安装 + 用户覆盖层）
repo: /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.claude/worktrees/mimo-storage-s5a-theme
branch: worktree-mimo-storage-s5a-theme
head_commit: 16b6f78
worktree_dirty: false
state: planning
progress_pct: 0
blocked_by: [S1a]
blocks: []
confidence: 高
report_time: 2026-08-04 01:45
---

## 1. 一句话现状

设计文档已过两轮 Codex 评审并定稿，**代码一行未写**；分支基线错误（缺 S1a 契约），rebase 因平台工具故障未执行成功。

## 2. 我被指派的任务

- **原始指派**：讨论 S5a（样式资源分发）子系统设计，产出设计文档 + 立项纪要（人类原话「设计文档+设计纪要」），**明确不写代码**（人类原话：「这个定义也不用现在写代码，你只需要把它做成文档落地，稍后会由文档转换为TDD，找其他的AI agents执行」）。随后人类要求用 Codex 做 gStack `plan-eng-review` 验收，判断能否转 ACT。
- **我实际理解的边界**：
  - 该做：主题资源的分发/安装/读取/用户覆盖的设计；四仓库职责边界；端口契约签名；验收标准。
  - 不该做：任何实现代码；`theme` 包的改动；Marketplace；主题内容（YAML）本身；chart token 语义解析。
- **我认为指派里含糊不清的地方**：
  - 「S5a 主体落在哪个仓库」我问过三次（xuan-storage / xuan_config / theme），人类未直接回答；我按代码事实推导定为 xuan-storage，人类未反对也未明确确认。
  - 与在途 OpenSpec change `theme-token-customization-contract` 的关系（并入还是独立），我问过两次未获答复，最后由我自行判定为「S5a 即该 change 点名要的独立 change」。

## 3. 已完成

| 条目 | 档位 | 证据（路径:行号 / 命令） | 验证方式与真实结果 |
|---|---|---|---|
| S5a 详细设计文档 v3 | **A** | `docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md`（提交 `16b6f78`） | Codex gStack `plan-eng-review` R2 判定 PASS-WITH-REVISIONS；R2 独立重跑全部 file:line 引用并确认属实，见 `docs/reviews/2026-08-03-s5a-theme-plan-eng-review-r2.md:41-47` |
| S5a 立项纪要 v3 | **A** | `tasks/mimo-storage-s5a-theme.md`（提交 `16b6f78`） | 同上；R2 报告 `:29`/`:31` 确认基线 stop condition 与 A3 覆盖下限已就位 |
| R1 的 4×P0 + 8×P1 + 2×P2 修订 | **A** | 提交 `502bd11`（v2） | R2 报告 `:27-37` 逐条确认已修 |
| R2 的 4×P1 修订 | **B** | 提交 `16b6f78`（v3） | **未经复审**。我自己按 R2 findings 改的，Codex 尚未复核 v3 |
| 现状事实核查（theme/lib 20 个 dart 文件、shell default.yaml 203 字节空壳、preferences 零同步、StoragePolicyRegistry 零生产调用点等） | **A** | 设计文档 §1 | 我自己 grep 验证 + R2 独立重跑确认（R2 报告 `:44-45`） |

## 4. 进行中

- **正在改的文件**：无。工作区 clean（`git status --porcelain` 空输出）。
- **改到哪一步**：文档已定稿提交，代码未开始。唯一未完成的动作是 `git rebase main`。
- **换人接手必须先知道的三件事**：
  1. **本分支基线是错的** —— 建在 `origin/main`(`2824f37`)，落后本地 `main`(`16987fe`) 27 个提交，S1a 契约四文件在本 worktree **不存在**（已用 Read 工具确认 `core/lib/model/storage_policy.dart` 返回 `File does not exist`）。必须先 `git rebase main`。
  2. 交付形态是**契约 + reference 实现**（方案 B，人类拍板），不是纯契约。`core/lib/reference/` 是新目录，A3 的零实现扫描必须排除它。
  3. 合并算法的权威定义在设计 §6.6，**实现顺序是 `1→5→2→4→3→6`**（非自然编号顺序，orphan 判定必须在三层取值之后、原子组补全之前）。照做，不要自行推断。

## 5. 未开始

| 剩余条目 | 粗估工作量 | 是否依赖别人 |
|---|---|---|
| `git rebase main`（修基线） | 1 分钟 | 否（仅受平台工具故障阻塞） |
| Codex 复审 v3（R3） | 1 轮 | 需人类冷启动 Codex |
| `wjt-act` 转译为 ACT | 未估 | 否 |
| `wjt-react` 跨模型闸门 | ≤2 轮 | 需人类启动另一模型 |
| 契约层 7 个文件编码 | 未估 | 依赖 S1a 契约就位 |
| reference 实现 2 个文件编码 | 未估 | 同上 |
| 测试与支撑 7 个文件编码 | 未估 | 同上 |

## 6. 阻塞清单

| # | 我需要什么 | 依赖哪个阶段/谁 | 需要的形态 | 阻塞从何时开始 | 我目前的绕行方式 | 绕行留下的技术债 |
|---|---|---|---|---|---|---|
| 1 | 本分支包含 S1a 契约（`StoragePolicy` / `StoragePolicyRegistry` / `CancellationToken` / `blob_*`） | S1a（**已完成，已在本地 `main` `16987fe`**） | 一次 `git rebase main` | 2026-08-03 建 worktree 时（我选错基线） | 无绕行。设计文档按 S1a 契约存在来写 | 若不 rebase，全部端口签名在本分支编译不过 |
| 2 | 平台 Bash/Agent/Monitor/跨目录 Write 工具可用 | 平台（Anthropic 分类器故障） | 工具恢复 | 2026-08-03 约 22:40 起间歇性故障 | 用 Read/worktree 内 Write/Edit 等免分类器路径完成文档 | 报告无法直接写到 `~/Downloads/storage_refactor/`，改写在 worktree 内待人工复制 |
| 3 | `ConfigBootstrap.endpoints` / `allowedHostSuffixes` / `l0PublicKeyBase64` 真值 | S5c（已交付但留占位符） | 三个字符串常量 | S5c 交付时 | 设计中标为「不阻塞契约层与 reference 实现，阻塞真实下载联调」 | 无（已隔离） |

## 7. 我单方面做出的假设与决策 ⚠️

**说明：本阶段零代码，故「已落进代码的位置」全部为文档位置。**

| # | 我假设/决定了什么 | 为什么被迫自己定 | 已落进的位置 | 推翻代价 | 我认为谁有权推翻 |
|---|---|---|---|---|---|
| 1 | S5a 主战场在 `xuan-storage`，`theme` 包零改动 | 人类三次未直接回答「落哪个仓库」 | 设计 §2.2、§3.1 | **高**（推翻则整份设计重写） | 人类 |
| 2 | S5a 即在途 OpenSpec change 点名要的独立 change，不并入它 | 两次询问未获答复 | 设计 §8.1 | 中 | 人类 / 该 change 负责人 |
| 3 | 覆盖最小单位 = 叶子字段 + 原子组补全，原子组清单写死 4 项（shadow/border/text_shadow/padding-margin） | 人类先说「覆盖不需要讨论」后又说「还是应该讨论」，最终授权按倾向拍板 | 设计 §6.2 | 中 | 人类 |
| 4 | light/dark 用 brightness 前缀，两份完全独立 | 同上 | 设计 §6.3 | 低 | 人类 |
| 5 | 悬空覆盖保留 + 标记 orphan，不静默丢弃 | 同上 | 设计 §6.4 | 低 | 人类 |
| 6 | 主题包签名复用 S5c 的 ed25519；S5a 自持 `ThemeSignatureVerifier` 窄接口，由装配层适配 | 人类未讨论过此项 | 设计 §5.5.2、§9.1 | 中 | 人类 / S5c 负责人 |
| 7 | bundled 权威源 = `theme/config/presets/default.yaml`；shell 的 203 字节空壳应废弃 | 人类未讨论过 | 设计 §9.1 | 中 | 人类 |
| 8 | A14b/d/e **移交**后续 installer/parser 任务，S5a 只留 A14a/c + 新增 A19 守边界 | R2 指出它们在 reference 表面无法执行；我自行决定移交而非扩大 S5a 范围 | 设计 §5.5.5、§11.5 | 中 | 总协调者（涉及跨阶段任务划分） |
| 9 | P1 性能阈值由 <1ms 放宽到 <5ms，且不进 CI 阻塞门禁 | Codex 指出 CI 抖动，具体数值由我定 | 设计 §7.5 | 低 | 人类 |
| 10 | 覆盖数量只设软上限，具体阈值不在本设计决定 | 参照总纲 §10:1581 对缓存上限的处理方式 | 设计 §6.5 | 低 | 人类 |
| 11 | 四个注入端口（`ThemeLocalReader`/`ThemeRemoteFetcher`/`ThemePackageStore`/`ThemeSignatureVerifier`）的形状 | R2 要求 P3/P4/P6 的探针必须是真实类型，我自行设计 | 设计 §5.5.2 | 中 | 人类 / 未来的生产实现者 |

## 8. 我对外提供的契约

**全部为设计文档中的签名，尚无代码实现。** 计划落点见设计 §11.1/§11.2。

```dart
// core/lib/model/theme_resource_store.dart
abstract interface class ThemeResourceStore {
  String get scopeUid;
  Future<ThemeTokenSet> resolve({CancellationToken? cancel});
  Stream<ThemeTokenSet> watchResolved();
  Future<List<InstalledTheme>> listInstalled();
  Future<List<AvailableTheme>> listAvailable();
  Future<void> selectTheme(String themeId);
  Future<void> clearThemeSelection();
  Future<void> applyOverrides({required Map<String, dynamic> patch, required OverrideOrigin origin});
  Future<void> removeOverrides(Set<String> tokenKeys);
  Future<Map<String, OverrideEntry>> listOverrides();
  Future<void> install(String themeId, {CancellationToken? cancel, void Function(int, int)? onProgress});
  Future<void> uninstall(String themeId);
  Future<bool> refreshCatalog({CancellationToken? cancel});
}

// core/lib/model/theme_source_ports.dart
abstract interface class ThemeLocalReader {
  Future<Map<String, dynamic>> readBundledTokens();
  Future<Map<String, dynamic>?> readPackageTokens(String themeId);
  Future<Map<String, OverrideEntry>> readOverrides();
}
abstract interface class ThemeRemoteFetcher { /* fetchCatalog / downloadPackage */ }
abstract interface class ThemePackageStore { /* installBytes / removePackage */ }
abstract interface class ThemeSignatureVerifier {
  Future<ThemeSignatureVerdict> verify({required List<int> packageBytes, required String? signatureBase64});
}
enum ThemeSignatureVerdict { valid, missingSignature, malformed, mismatch, noPublicKey, skipped }

// core/lib/model/theme_module_registry.dart
abstract final class ThemeModuleRegistry { static void register(); }
const themePackageEntityType = 'theme_package';
const themeOverrideEntityType = 'theme_override';
const themeSelectionEntityType = 'theme_selection';
```

值类型：`ThemeTokenSet` / `ThemeTokenSection` / `ThemeResolution` / `ThemeLayerInfo` / `ThemeSelectionOrigin` / `ThemeLayerKind` / `InstalledTheme` / `AvailableTheme` / `OverrideEntry` / `OverrideOrigin`（签名见设计 §5.1/§5.2/§5.4）。

**产物文件清单**：设计 §11 列了 16 个文件（7 契约 + 2 reference + 7 测试支撑）。

## 9. 我消费的外部契约

| 我依赖的东西 | 我假定它长什么样（真实签名） | 假定来源 |
|---|---|---|
| `StoragePolicy.resource` / `.private` 工厂 | `const factory StoragePolicy.resource({required Set<Carrier> carriers, required Set<Source> sources, Publisher publisher})` | **代码**（在 s1a worktree 读过 `storage_policy.dart`） |
| `StoragePolicyRegistry` | `static void register(String entityType, StoragePolicy policy)`，重复注册抛 `StateError`；另有 `lookup` / `all` / `clearForTesting` | **代码**（读过 `storage_policy_registry.dart:37-84`） |
| `CancellationToken` | 存在于 `core/lib/model/cancellation_token.dart` | **代码**（S1a barrel 导出列表） |
| `Carrier` / `Source` / `Publisher` / `DataVisibility` | 见 `storage_classification.dart:11-37` | **代码** |
| S5c 的 `ConfigSignatureVerifier` | `Future<SignatureVerdict> verify({required String raw, required String? signatureBase64})` | **代码**（读过 `xuan_config/.worktrees/mimo-config-s5c-remote-source/lib/src/bootstrap/config_signature.dart:26-29`）。⚠️ **其入参是 `String raw`，而主题包是二进制字节，类型不匹配。我在设计中未写出这一差异，是缺口** |
| `theme` 包的 `TokenLoader.fromConfigResult` | `static XuanThemeSet fromConfigResult(ConfigResult result, {String path})` | **代码**（`theme/lib/src/loader/token_loader.dart:15`） |
| `xuan_config` 的 `ConfigResult` | `{light, dark} × {components, chart, semantic}` | **代码**（`xuan_config/lib/src/config_result.dart:2-25`） |

## 10. 我动过的文件与目录范围

**全部在本 worktree 内，均为新增；无修改/删除/重命名。**

| 路径 | 操作 |
|---|---|
| `docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md` | 新增（`502bd11` 创建，`16b6f78` 修订） |
| `tasks/mimo-storage-s5a-theme.md` | 新增（同上） |
| `docs/reviews/STATUS-S5a-S5a-Theme.md` | 新增（本报告） |
| `docs/reviews/2026-08-03-s5a-theme-plan-eng-review-r2.md` | **非我创建**（Codex 或人类放入），我只读 |

**未提交改动**：本报告文件（写完后未提交）。

**我未触碰**：`core/` `drift/` `firebase/` `preferences/` `assets/` 任何源码；`theme` / `xuan_config` / `xuan-shell` / `xuan-qizhengsiyu` 四个外部仓库（全部只读）。

## 11. 当前可运行状态

- **能否编译/构建**：**未试**。本阶段零代码产出；且本分支缺 S1a 契约，即使有代码也编译不过。
- **测试命令与真实结果**：未运行任何测试。
- **已知失败项**：
  - `git rebase main` 未执行成功 —— 平台分类器故障，多次重试均返回 `temporarily unavailable`。
  - S1a 契约四文件在本 worktree 不存在 —— Read `core/lib/model/storage_policy.dart` 返回 `File does not exist`。

## 12. 需要人类拍板的问题

| # | 问题 | 我的建议选项 |
|---|---|---|
| 1 | S5a 主战场确认在 `xuan-storage` 吗？ | **建议：是**。唯一同时具备 drift + blob 端口 + 同步引擎的仓库；`theme` 包的零 IO 边界应保住 |
| 2 | A14b/d/e 移交给谁承接？ | **建议：新建 installer/parser 子任务**。若不新建，这三条验收会丢失 |
| 3 | 是否需要 Codex 复审 v3（R3）？ | **建议：需要**。v3 的四条修订是我自改自评，未经独立复核；R2 只说「改完这四条即可转 ACT」，未验证我改得对 |
| 4 | 本 worktree 保留 rebase 还是重建？ | **建议：rebase 保留**。改动仅两个文档文件，冲突风险极低 |

## 13. 需要其他 Agent 回答的问题

| 问谁 | 问题 |
|---|---|
| S1a | 我设计了 `ThemeModuleRegistry._registered` 布尔标志防重入（不用 try-catch 吞 `StateError`），这与 `StoragePolicyRegistry.register` 的预期用法一致吗？ |
| S5c | `ConfigSignatureVerifier.verify` 入参是 `String raw`，但主题包是二进制字节 —— 该由 S5c 扩展一个字节重载，还是 S5a 侧自行做编码转换？ |
| S5c | `ConfigBootstrap` 三个占位符真值预计何时填入？ |
| S1b | S1b 是否会改动 `core/lib/persistence_core.dart` 的 barrel，或 `core/lib/model/` 下的既有文件？S5a 计划新增 7 个 `theme_*.dart` 并在 barrel 末尾追加 9 行导出 |
| S5b | 你是否计划改 `drift/lib/persistence_drift.dart` 的 `schemaVersion` 或 `@DriftDatabase(tables:)`？S5a 首批不动 drift，但后续 installer 任务会动 |

## 14. 如果我是总协调者

**先解 S1a 契约的分发问题。** S1a 已完成且在本地 `main`，但 `main` 超前 `gitea/main` 27 个提交未推送 —— 任何从远端起分支的 worktree 都会缺 S1a 契约。我就是这么栽的。这不是我一个人的坑，是**所有下游阶段共享的地雷**。

## 15. 风险与「我可能错在哪」

- **我对本阶段最没把握的一件事**：S5a 的仓库归属。人类三次未正面回答，我从代码事实推导（`theme` 零 IO、`preferences` 零同步、只有 xuan-storage 有 drift+blob+同步引擎）。推导链我认为成立，但**这是我单方面的判断**，且推翻代价高。
- **如果我错了，最可能错在**：
  1. 我把「主题 token 走 `xuan_config` 配置链」这个既成事实判定为「主题只有 token 时的历史偶然」，从而主张整包分发迁到 xuan-storage。若人类原意是保持配置链，方向 A 要重来。
  2. §5.5.2 的四个注入端口是我为满足 R2 可测性要求而设计的，**没有任何现有代码验证过这个形状好不好用**。S1a 的 `StoragePolicyRegistry` 至今零生产调用点，正是同类风险的前车之鉴。
  3. S5c 的 `verify({required String raw})` 与「主题包是字节」类型不匹配，设计里没写出来（第 9 节已标注）。
- **我怀疑与其他阶段存在冲突的地方**：
  1. **`core/lib/persistence_core.dart` barrel**：S1b 的 ACT 11 要求「末尾追加不重排」且有门禁断言 S1a 那批 export 一条不少；S5a 也要在末尾追加 9 行。三方追加同一处会文本冲突（语义不冲突，逐条 rebase 可解）。
  2. **`drift/lib/persistence_drift.dart` 的 `schemaVersion`**：S1b 的 ACT 03 已把 `7` 写死并有 grep 门禁。S5a 首批不动 drift，但**后续 installer 任务必然要建主题表**，届时会与 S5b 争抢版本号。这是尚未爆发但确定会爆发的冲突。
  3. **`StoragePolicyRegistry` 的首个生产调用点**：S5a 若先落地，注册期两条不变式（resource 必须 official、sources 非空性）第一次被真实驱动，可能炸出 S1a 未预见的问题。
