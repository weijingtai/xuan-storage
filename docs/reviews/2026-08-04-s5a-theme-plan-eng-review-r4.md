# S5a Theme v5 plan-eng-review（HEAD `e25ea1f`）

结论：**REVISE-FIRST**

v5 已实质关闭 R3 的多数问题，但尚不能进入 `wjt-act`。本轮发现 1 条协议级 P0，以及交付清单/P3-P4 oracle/裁定同步方面的 P1。以下均为只读核验结果。

## Findings

| 严重度 | 证据 | finding |
|---|---|---|
| P0 阻塞 | `docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:369-396,427-440`; `core/lib/model/dataset/dataset_materializer.dart:50-56` | JSONL 行 schema 把 `g`（generation）写进**构建期载荷**，并要求等于运行时 `materialize(generation:)`，不符即抛。XRAP 的 generation 是安装器调用 materializer 时传入的落地世代，不是发布构建期可预知的包内容；同一载荷重装、回滚后重落地或安装到不同设备时 generation 可不同。当前格式会让合法载荷因运行时世代不同被拒绝。应从载荷删除 `g`，由 materializer 用入参 generation 写入 `_byGeneration[g]`；若坚持携带，只能把它定义为非 XRAP generation 的其他稳定字段并改名。 |
| P1 应修 | `docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:891-906,1428-1436`; `tasks/mimo-storage-s5a-theme.md:37-39,240-243` | P4 新增第四个 reference 文件 `core/lib/reference/theme_assembly.dart`，但 §11.2 和纪要仍声明 reference 实现只有 3 个文件，交付表完全没有 `theme_assembly.dart`。机械执行者按清单不会创建 P4 的唯一注入入口，P4 随即不可执行。reference 数量应改为 4，并把文件、签名、验收编号列入 §11.2/纪要。 |
| P1 应修 | `docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:856-863,1438-1449` | `CountingDatasetInstaller` 已成为 P4 必需探针，但 §11.3 的 `theme_probes.dart` 交付说明仍只列 `CountingLocalReader / SlowLocalReader`，遗漏 installer spy；其构造器、`DatasetInstaller` 全部抽象方法的 fake 返回值、`installCallCount` 初值和 `calledDatasetIds` 类型也未给出。仅表格两行不足以直接写出可编译 fake。 |
| P1 应修 | `docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:400-447,409,1003`; `:804-818` | materializer 的 `_byGeneration` 是实例私有状态，descriptor 使用 `materializer: () => InMemoryThemeMaterializer()` 工厂创建实例；但 `ThemeLocalReader` 又必须读取该实例的 generation Map。文档没有共享 backing store、materializer factory 捕获实例、reader 构造器或装配连接签名。`tokensOf()` 仅供单实例读取，无法说明安装器新建的 materializer 如何与启动路径 reader 共享落地物。reference 数据流仍不闭合。 |
| P1 应修 | `docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:865-889`; `tasks/mimo-storage-s5a-theme.md:162-164` | P3-a 规定源码全文中 `ThemeLocalReader` 恰好命中 1 次，但正常实现至少可能同时出现字段声明与构造器参数，文档自身构造器片段也未展示字段如何保存。该 oracle 测的是拼写次数而非依赖图，会迫使实现者用类型推断/规避文本来过门禁，仍有假阳性和误杀风险。应扫描 import/字段/构造器的 AST 或限定“允许类型集合”，并做一次新增网络依赖的变红自检。 |
| P1 应修 | `docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:144`; `tasks/mimo-storage-s5a-theme.md:199-204,391-401`; `docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:1402` | ConfigBootstrap 仍未全局同步：设计 §1.6 仍称其为“S5a 真实下载能力的前置阻塞项”，纪要 stop condition #4 仍写“需要真实网络下载→等人类”，但后文又明确“与 S5a 无关、不得写入 S5a stop conditions”。这是直接自相矛盾，且与人类裁定 4 不一致。 |
| P1 应修 | `tasks/mimo-storage-s5a-theme.md:7-8,251-252,264-269,284-287`; `docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:332-348` | v5 已删除 `ThemeMaterializer` 空接口，但纪要目标仍写“ThemeMaterializer + 用户覆盖层”，v4 决定记录仍写“新增 ThemeMaterializer”，并同时写契约层 7→9、A3 `==8`。即使作为历史，当前文字没有标注该结论已被 v5 supersede，会让 ACT 转译器重新创建已删除接口。应统一改为 `InMemoryThemeMaterializer implements DatasetMaterializer` 并清理冲突计数。 |
| P1 应修 | `docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:1479-1497`; `tasks/mimo-storage-s5a-theme.md:174-180`; commit `e25ea1f` 文件统计 | 验收命令要求 `scripts/run_s5a_residue_gate.sh`，但该脚本未列入 §11.1–§11.3 交付物，提交中也不存在；ACT 若机械按交付表创建文件，最终验证会因命令不存在失败。应把脚本列为精确交付文件并更新总数/范围。脚本还应使用 `rg --files`/显式文件数组，避免 `ls` glob 对空匹配和目录递归口径产生歧义。 |
| P2 建议 | `tasks/mimo-storage-s5a-theme.md:187`; `tasks/mimo-storage-s5a-theme.md:92-95` | 门禁纪律仍写“A3 文件数 == 6”，当前验收已改为 8。虽非主验收本体，但属于会被 ACT 引用的写作纪律，应同步。 |
| P2 建议 | `docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md:13,74` | 文档仍有可见 UTF-8 replacement character `�`，建议在转译前清理，避免路径/语义被机械执行器误读。 |

## 已确认关闭的 R3 项

- `InstalledTheme` 类本体已删除，`AvailableTheme` 已改为 `LocalTheme`；当前命中主要来自门禁定义和历史说明。
- §6.6 已把运行时输入改为预扁平结构，YAML 扁平化明确移交 `BUILD-THEME`。
- 载荷格式已从“SQL 或 JSONL”收敛为 JSON Lines，并定义 `k/v/t/g` schema（但 `g` 设计本身构成上述 P0）。
- A14a/d/e 已用唯一承接 ID `BUILD-THEME` 登记，§8.1 不再引用已删除的版本兼容章节。
- §11.4 已明确本 ACT 不跨仓库读取 theme 文件，构建脚本属于独立任务。
- 空 `ThemeMaterializer` 子接口已从当前设计契约删除，契约表本体为 8 行。

## 转 ACT 前必须完成的修订

1. 删除 JSONL 的运行时 generation 字段，或重新定义为与 XRAP generation 无关的稳定字段；补同载荷在不同 generation 落地的 A20 测试。
2. 将 `theme_assembly.dart` 纳入 reference 交付清单并把 reference 数量改为 4；完整定义 `CountingDatasetInstaller`。
3. 定义 materializer 与 `ThemeLocalReader` 的共享 backing store/装配数据流，使 XRAP 工厂创建的实例可被读路径读取。
4. 重写 P3 静态 guard，避免用类型名恰好出现一次作为 oracle，并规定变红自检。
5. 清除 ConfigBootstrap stop gate 和已删除 `ThemeMaterializer` 的冲突性当前表述。
6. 把 `scripts/run_s5a_residue_gate.sh` 纳入精确交付物，并同步所有数量与写作纪律。

完成上述 P0/P1 后再进行 R5；当前不应进入 `wjt-act`。
