# storage-s1b-multipeer ACT 转译闸门 R5

审查基线：`01106e1`（转译 v3.2）  
对比基线：`32a74e9`（R4 报告）  
审查日期：2026-08-03

## 判定：返工，但整体正在收敛

R4 的 5 项中：2 项确认关闭，3 项仍未形成可机械执行的闭环。本轮确认 3 个必须返工项：2 个 P0、1 个 P1。

这不是问题面继续扩张：R1→R5 的阻断项数量为 **25 → 10 → 6 → 5 → 3**；方案 A、schema/端口分解、A1–A14 完整性等结构性问题已经稳定。当前残留集中在 R4 新改文字的内部一致性，属于尾部收口。

本轮只读验收，未修改 ACT、任务纪要或验收标准。

## R4 五项复核

### R4 P0-1 收敛性用例：未修

证据：`docs/storage-s1b-multipeer/act/08.yaml:319-350`

虽然补齐了 `RED_COMMAND`、`RED_EXPECT`、`COVERS`，但核心问题仍在：

- `:329-344` 仍要求两个“归并器”实例并声称退化成 RWW 时测试必红。
- `:345-347` 又声明本用例“不做仲裁的具体实现，也不管哪个版本赢”。
- 不定义胜者选择规则，就不存在可执行的归并算法；若测试内自造规则，它只能证明测试辅助代码，不约束任何生产实现。
- RED_EXPECT 仅为“HlcClock 不存在”，执行者即使不实现任何生产归并器，也能让该测试从红变绿。

判定：R4 的“职责收缩为数学结构命题”不是可执行替代方案。收敛性不是无仲裁规则即可验证的纯结构性质；它依赖生产的全序/仲裁函数。

修正标准：将该用例移到 ACT 09，使用两个独立状态容器和真实 `HlcConflictArbiter`，对同一批冻结 VersionStamp 以不同顺序归并；把生产仲裁退化为后到者赢时，该测试必须变红。ACT 08 只负责生成/冻结测试戳数据，不负责声称生产收敛性。

### R4 P0-2 ACT 10 接线契约：部分修，仍有 scope 矛盾

证据：

- `docs/storage-s1b-multipeer/act/10.yaml:139-157`
- `docs/storage-s1b-multipeer/act/10.yaml:174-192`
- `drift/lib/record/drift_record_data_source.dart:6-9`
- `drift/lib/record/drift_record_data_source.dart:89-93`

已经正确修复：

- `readLocalStamp` / `applyWithStamp` 显式接收 `scopeUid`。
- 样板改用具体类 `HlcConflictArbiter`。
- 使用既有 `getRecord`，不再凭空新增方法。

仍未闭合：

- ACT 在 `10.yaml:149` 承诺“同一个 applier 实例真的能跨 scope 复用”。
- 但 `readLocalRecord` 仍捕获固定的 `ds`（`:179`），而 `DriftRecordDataSource` 构造时固定保存 `scopeUid`（生产文件 `:6-9`），`getRecord` 查询也使用该固定字段（`:89-93`）。
- 当 `applyRemoteChanges(scopeUid: B)` 被同一个 applier 调用，而 `ds` 绑定 scope A 时，戳从 B 读，实体却从 A 读；“本地无实体 / 本地有实体无戳”的判断会跨租户串读。
- 文档说 uuid 在 scope 内唯一，恰好说明读取必须带正确 scope，不能证明固定 scope 的数据源可跨 scope 使用。

修正标准（二选一，必须统一）：

1. 真正支持跨 scope：`readLocalRecord` 回调也显式接收 `scopeUid`，并通过按 scope 查询的生产接口读取；或
2. applier 按 scope 构造：明确实例绑定单一 scope，删除跨 scope 复用承诺，同时让另外两个回调也使用同一绑定 scope，避免一半 per-call、一半 per-instance。

并增加测试：用同一个 applier 连续处理 scope A、B，两个 scope 有相同 uuid 但实体存在性不同，断言绝不串读。若选择单 scope 实例方案，则测试应验证 scope 不匹配被拒绝。

### R4 P1-1 compareTo 减法论证：已修

证据：`docs/storage-s1b-multipeer/act/09.yaml:291-317`

数值测试已经明确降级为边界排序行为验证，并明确说明它不能识别减法实现；禁止减法由源码门禁和 mutation SELF_CHECK 负责。前后逻辑一致。

### R4 P1-2 A1 门禁自测恢复：部分修，样板执行顺序仍必红

证据：`docs/storage-s1b-multipeer/act/11.yaml:305-349`

正确方向已经具备：`mktemp -d`、`trap`、前后快照比较、显式记录新建文件。

但给出的样板顺序不成立：

- `:318` 的 `trap restore EXIT INT TERM` 只会在脚本退出/收到信号时运行。
- `:320-324` 在正常流程尚未退出、restore 尚未执行时立即读取 `SNAPSHOT_AFTER` 并与 before 比较。
- 只要三次注入仍留在工作树中，这个比较必然失败；随后 exit 1 才触发 trap 恢复。也就是说，恢复最终可能成功，但自测脚本自身必定报告失败。
- `:345-348` 要在脚本内部临时插入 `exit 3` 后“确认 trap 已恢复”，但父脚本已经退出，无法在同一进程中继续确认或删除该注入；必须由外层 harness 启动子进程并在子进程结束后检查。

修正标准：

- 将 restore 拆成可显式调用且幂等的函数：完成三次注入后先 `restore`，再获取 `SNAPSHOT_AFTER` 比较；trap 仅作为异常兜底。
- trap 自测必须由外层测试进程/函数启动一个故意 `exit 3` 的子进程，子进程退出后由父进程检查 status 快照和临时目录；不能要求已退出的脚本自证。
- 给出完整控制流，确保正常路径返回 0、故障路径仍恢复现场。

### R4 P2-1 rev 完成条件：已修

证据：`docs/storage-s1b-multipeer/act/10.yaml:486-491`、`:548-558`

DONE_WHEN 与 VERIFICATION 已统一为“禁止 rev 参与仲裁坐标”，明确允许 `RecordMeta.rev` 作为业务字段存在。本轮未发现新的冲突。

## 新发现的必须返工项

本轮没有与 R4 无关的新需求扩张。上述 3 项均是 R4 修复的可执行性复核：

- P0：ACT 08 收敛性测试仍没有生产被测对象。
- P0：ACT 10 的 scope 契约只修了两个回调，第三个读取通道仍绑定固定 scope。
- P1：ACT 11 的恢复机制组件正确，但控制流顺序错误。

## 通用门禁复核

- 11 个 YAML 均可正常解析。
- A1–A14 验收标准与 `cd064c6` 保持一致。
- v3.2 声明的 91 个 TESTS_FIRST 六字段完整性与 14/14 `COVERS` 映射，本轮未发现反例。
- 未发现新的方案 A、schema 迁移或 ACT 04 编译闭环问题。
- HANDOFF 的“已知未决问题”末尾仍残留陈旧编号 `6. 第 4 轮闸门`，位于新编号 7 之后；这是文档清理项，不单独阻断执行，但下次更新应删除。

## 是否收敛

是，整体正在收敛，但尚未达到 READY。

判断依据：

1. 数量持续下降：25 → 10 → 6 → 5 → 3。
2. 严重度下降：R1/R2 是数据泄漏、编译死锁、计划分解错误；R5 是三个局部契约/测试控制流问题。
3. 问题范围收缩：本轮没有发现新的架构板块或新的验收标准遗漏，全部集中在 R4 改动的四个 ACT 中。
4. 返工仍有价值：三个问题都能让便宜执行者写出“测试绿但生产没被约束”或直接不可运行的脚本，不能仅因轮次多而豁免。

建议下一轮不要再做全量自由探索式翻查，而是执行一次**封闭式 R6**：只验本报告的 3 个修正项，再跑固定的 YAML、字段完整性、A1–A14 完整性和 `bash -n` 回归门禁。若三项关闭且固定门禁无回退，应判 READY；除非发现会导致编译失败、数据错误或假绿验收的 P0/P1 新证据，否则不再扩张审查范围。
