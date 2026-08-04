# S5a Theme v4 plan-eng-review（HEAD `6bf8a6b`）

结论：**REVISE-FIRST**

本轮只读核验了设计 v4、任务纪要 v4、XRAP 源码和 OpenSpec 原文。当前不能进入 `wjt-act`：删除裁定没有在两份文档中闭合，且 v4 新增的构建期边界、P3/P4 注入和 ConfigBootstrap 处置仍存在可机械执行性/一致性缺口。

## Findings

| 严重度 | 证据 | finding |
|---|---|---|
| P0 阻塞 | `tasks/mimo-storage-s5a-theme.md:42-50,229-231,265-273`; `docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:617-625,629-695,766-769,1309,1334` | “删除全部安装机制/端口”的 v4 仍在当前任务正文、交付值类型和 §11.1 中保留 `InstalledTheme`、`AvailableTheme` 及已删除端口名称；纪要决定记录还声称已删除但随后再次列出这些类型。按用户要求的全文残留门禁必失败，且执行者无法判断这些是否应实现。 |
| P1 应修 | `docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:356-367,385-386,1081-1108`; `:1309-1310,1378-1382` | 载荷已改为构建期预构建，但 §6.6 仍把“扁平化”作为运行时合并算法第 1 步；同时写“具体表结构不在本设计决定”，却要求 `in_memory_theme_materializer.dart` 消费“形如 *.sql 或 JSON Lines”的载荷。格式、行 schema、generation/rowCount 解析及构造器签名没有唯一答案，reference 实现不可机械落地。 |
| P1 应修 | `docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:761-762,841-856`; `:1244-1245`; `tasks/mimo-storage-s5a-theme.md:162-167` | P3 仍要求“架构守卫断言构造器参数表仅两项”，但没有给出 Dart 可执行的反射/静态扫描 oracle；“两项”与文档实际只展示 `localReader` 的构造器描述也不闭合。P4 要把 `DatasetInstaller` fake 传给装配层，但 `ThemeResourceStore`/`InMemoryThemeResourceStore` 签名未定义该装配层、provider 或 fake 的具体文件/状态转移，因此不能机械驱动真实启动路径。 |
| P1 应修 | `docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:1259-1266,1378-1382`; `/Users/jingtaiwei/Git/Public/xuan-migration/openspec/changes/theme-token-customization-contract/specs/theme-token-system/spec.md:45-66` | A14d/e 的 SHALL 要求“解析时 caught error、诊断、最窄回退”；v4 将其移交构建脚本/既有 `token_loader`，但 S5a 纪要仍把 A14d/e 列作本任务验收，且没有构建脚本任务文件、输入/输出诊断 oracle 或移交任务标识。A14a 的 §4.3 “版本兼容规则第 4 条”也与 v4 声明已删除版本兼容规则矛盾。三次归属搬迁后 SHALL→验收承接未闭合。 |
| P1 应修 | `tasks/mimo-storage-s5a-theme.md:193-199,354-358`; `docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:1312-1318` | 人类裁定要求 ConfigBootstrap 三占位符不再是 S5a 阻塞项，但两份文档仍在“阻塞项/stop conditions/开放事项”写 `🔴`、真实下载阻塞和“待人类填入”。即使后文写“不阻塞本任务”，该表述违反本轮裁定的一致更新要求，ACT 会继承错误 stop gate。 |
| P1 应修 | `docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:359-370,1310,1368-1370,1382`; `tasks/mimo-storage-s5a-theme.md:195-198` | stop condition #2 禁止读取/拷贝 theme 仓库，但 §4.3/§9.1/§11.5 又要求构建脚本从 `theme/config/presets/*.yaml` 产出载荷。文档没有把构建脚本所在仓库、输入如何由外部流水线提供、是否属于 S5a ACT 交付写成唯一边界；执行者可能触发 stop 或反向跨仓库读取。 |
| P1 应修 | `docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:1245,854-856`; `tasks/mimo-storage-s5a-theme.md:165-166` | P4 的“计数式 spy 覆盖启动路径”缺少可构造的装配入口：没有 `DatasetInstaller` fake 类型、调用计数字段、装配函数签名或测试 fixture。仅断言 `install == 0` 可能在根本未调用装配层时假通过，违反纪要门禁“正向控制/真实入口”纪律。 |
| P2 建议 | `docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:342-349` | `ThemeMaterializer` 是不增加任何方法的空子接口，等价于类型别名级标记；设计没有说明其被 XRAP registry、泛型约束或测试实际消费的价值。若保留，应给出唯一消费者/注册点；否则删除该接口并直接使用 `DatasetMaterializer`。 |
| P2 建议 | `docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:1242` | P1 `<5 ms` 明确不进 CI 阻塞，只做趋势观测；若该性能要求仍是计划验收，应定义稳定的 release/profile 基准环境，否则它不是可重复的 ACT gate。 |
| P2 建议 | `docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:1316`; `tasks/mimo-storage-s5a-theme.md:356-358` | “不阻塞”与“🔴 阻塞真实下载联调”并存，建议改成单一非阻塞备注，避免机械转译器把红色标记当 stop condition。 |

## 已核实的正向事实

- XRAP 关键引用与源码一致：`dataset_materializer.dart:1-5,12-15,34-37,43-45,59-63`、`dataset_descriptor.dart:20-27,29-37,40-44,59-61`、`dataset_registry.dart:62-68`、`dataset_installer.dart:188-192`、`dataset_source.dart:61` 均存在且语义基本相符。
- OpenSpec :54、:60、:69–74、:86、:116、:123、:134 条款原文已核实；当前问题是 v4 的归属与验收承接，不是条款不存在。
- XRAP 合入后 `StoragePolicyRegistry` 已有协议测试调用点（例如 `core/test/policy_channel_filter_test.dart:12-41`、`core/test/storage_policy_test.dart:8-41`）；`core/lib/model/storage_policy_registry.dart:23` 是注册器定义而非生产调用。若设计声称“首个生产调用点”，必须明确它指 S5a 主题注册，否则会把测试/协议基础设施误报为生产调用。

## 转 ACT 前必须完成的修订

1. 从当前契约/交付物/验收/决定记录中彻底删除已裁定移除的端口和安装态类型；历史记录改为不触发全文残留门禁的表述。
2. 明确唯一载荷格式、行 schema、materializer 输入解析和 generation/rowCount 规则；将 §6.6 第 1 步改为“消费已扁平 Map”或明确其只属于构建脚本。
3. 给出 P3 架构守卫的可执行 oracle，以及 P4 的 `DatasetInstaller` fake、装配函数、计数状态和真实启动入口签名。
4. 将 A14a/d/e 从 S5a 验收移除并在外部构建脚本/XRAP 任务中以唯一任务 ID 承接；删除已不存在的“版本兼容规则”引用，重新生成 §8.1 映射。
5. 按裁定 4 统一改写 ConfigBootstrap 所有段落为“已知非阻塞背景”，删除 `🔴 阻塞` 与 S5a stop gate 语义。
6. 明确构建脚本不在本 ACT 的文件范围，输入通过外部产物/fixture 注入；或将脚本及其跨仓库授权正式列入 ACT。

在上述 P0/P1 完成并重新核对纪要数量（契约 9、reference 3、测试 8、A20 五子项、stop conditions 五条）后，方可重新评审。
