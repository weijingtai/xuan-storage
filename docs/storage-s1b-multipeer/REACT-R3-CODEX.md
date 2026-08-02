# 转译审查 R3 - Codex 跨模型闸门

日期：2026-08-03
审查对象：`docs/storage-s1b-multipeer/act/01.yaml` 至 `11.yaml`（转译 v3）
审查方式：只读核验源码、规格、任务纪要、R1/R2 报告、ACT 文档与实际测试基线

## 判定：返工

方案 A 的 schema 前置本身成立，但 v3 仍有 6 项必须返工，其中 ACT 08/10 的生产接线缺口和 A14 排序规则缺口属于 P0，暂不能下发执行者。

## 方案 A 是否成立

### ACT 03 的“不破坏编译”断言：成立

证据：

- 当前 `SyncStatesDao` 的 `find`、`clear`、`markPulledAt`、`markPushedAt` 都按列构造条件，不依赖主键形状：`drift/lib/persistence_drift.dart:435-481`。
- `upsert` 使用 `insertOnConflictUpdate`，冲突目标由生成表的 `$primaryKey` 提供：`drift/lib/persistence_drift.dart:447-449`。
- `SyncStatesCompanion.insert` 只要求当前无默认值的列。新增带 SQL 默认值的 `peerId` 后会成为可省略字段，不会打断现有构造点：`drift/lib/persistence_drift.g.dart:1429-1443`。
- 既有测试没有直接依赖二元 `$primaryKey`；当前 drift 基线实跑结果为 **276 tests passed**。
- ACT 03 阶段现有 DAO 只会写默认 peer `firestore`，因此三元主键与原二元主键在实际数据域内等价。

### ACT 04 能否闭环：最终可以，但阶段说明必须修正

阶段 1 修改端口后，`SyncCoordinator` 调用点也必须立即跟进，否则 `cd core && flutter test` 不可能全绿。但 STAGES 只写“端口 + fake + core 测试”：`act/04.yaml:46-48`；调用点迁移只在后文说明：`act/04.yaml:293-298`。

修正标准：阶段 1 明确包含 `sync_coordinator.dart`、`sync_runtime.dart` 的 core 调用点临时单-peer 接线。完成该修订后，`STRONG_MODEL_ONLY`、四阶段门禁和 parity 测试足以补偿其超粒度问题。

## R2 十项复核

1. **已修**：ACT 06 实现签名含 `required Set<PeerId> eligiblePeers`，并有实现侧独立 grep。证据：`act/06.yaml:70-73,275-280`。
2. **已修**：`EntityStamps` 主键含 `scopeUid`；`HlcClockStates` 有完整列、主键和 CHECK 约束。证据：`act/08.yaml:141-194`。
3. **部分修**：增加了 `applyWithStamp`，ACT 10 也要求调用它；但没有戳读取接口、applier 构造签名或现有构造点迁移方案，生产接线仍不完整。
4. **部分修**：已改成两组独立实例、不同顺序重放。证据：`act/08.yaml:271-295`。但该性质本身不是 HLC 保证，详见 P0-2。
5. **部分修**：文本 grep 能抓直接减法；极端量级测试不能可靠抓，SELF_CHECK 的必红声明是假的。
6. **部分修**：ACT 10 已写明“本地无实体”与“本地有实体但边表无戳”的区别及差异测试。证据：`act/10.yaml:134-156,297-313`。但缺少读取本地实体/边表的可调用接口。
7. **部分修**：旧 `LamportStamp` / `overwritten*` 已清理；但 DONE_WHEN 声称源码不得有 `rev`，现有 `_parseMeta` 必须读取 `RecordMeta.rev`，而门禁实际不检查裸 `rev`。
8. **已修**：`<ACT_BASE>` 无残留，均使用 `"$(cat .act-base)"`。
9. **已修**：`hlc_dart: 1.1.0+2` 钉死；dartdoc 设计要求扫描 8 个文件并断言数量。证据：`act/08.yaml:72-80,471-475`、`act/11.yaml:138-155`。
10. **部分修**：规格文字补了 `0 <= l < 2^47` 和 UTF-8 字节序，但实现测试没有 UTF-8/UTF-16 分歧向量，仍可假绿。

## 新发现的必须返工项

### P0-1：ACT 08/10 缺少可机械接线的戳读取与本地记录读取契约

文件与证据：

- `act/08.yaml:196-215`：只定义写入接口 `applyWithStamp`，没有读取 `t_entity_stamp` 的生产接口。
- `act/10.yaml:51-69`：只允许修改 applier 和两个测试文件。
- `drift/lib/sync/record_local_applier.dart:7-13`：当前 applier 只有 `applyRecord`、`deleteRecord` 两个写回调。
- 当前仓库另有 7 个 `RecordLocalApplier(...)` 构造点，ACT 10 未列入 SCOPE，也未给迁移签名。

为什么是问题：ACT 10 要求读取本地实体、旧 payload、本地 stamp，并调用数据库事务接口，却没有说明通过什么正式接口读取、如何注入、现有构造点如何迁移。便宜执行者无法机械实现。

修正标准：

- ACT 08 钉死 `getEntityStamp({scopeUid, entityType, entityId})` 生产接口及返回类型。
- ACT 10 钉死 applier 构造签名、local entity reader、stamp reader、事务 writer。
- 将全部 7 个既有构造点列入 SCOPE，并明确迁移方式。
- 增加生产接线测试，不得仅在测试内直接查表。

### P0-2：ACT 08 的“不同接收顺序重新生成 HLC 后最终胜负一致”不是 HLC 不变式

文件：`act/08.yaml:271-295`。

为什么是问题：HLC 的计数值会受 `observe` 到达顺序影响。用不同消息顺序重新运行时钟可能生成不同 stamp，最终胜者不保证相同；测试可能要求 HLC 并不承诺的性质。

修正标准：先固定一组已经生成的 `(hlc, deviceId)` 版本，再用两个独立存储/仲裁实例按不同到达顺序归并，断言最终选中同一版本。HLC 时钟本身只验证单调性与因果性。

### P0-3：A14 的 UTF-8 排序未落到 `VersionStamp.compareTo`

文件与证据：

- `act/09.yaml:54-80`：只规定 deviceId “字典序”，没有规定 UTF-8 bytes。
- `act/09.yaml:231-270`：比较测试只使用 ASCII deviceId。
- `act/11.yaml:59-76`：后置规格才指出 Dart `String.compareTo` 使用 UTF-16，可能与 UTF-8 结果不同。

为什么是问题：执行者可以直接使用 `String.compareTo`；现有 ASCII 测试和文字 grep 全绿，但跨语言客户端可能得到相反胜负。

修正标准：ACT 09 直接要求按 UTF-8 bytes 做字典序比较，并增加能区分 UTF-8 与 UTF-16 的 Unicode 用例，例如 `U+10000` 对 `U+E000`。ACT 11 黄金向量必须包含至少一组这种分歧用例。

### P1-1：减法 SELF_CHECK 不会按声明变红

文件：`act/09.yaml:272-287,366-368,391-395`。

为什么是问题：A14 把合法 packed 值限定在 `[0, 2^63)`。合法最大值减 0 不发生符号翻转，因此把实现改成 `toPacked() - other.toPacked()` 后，极端量级测试不保证变红。直接减法的文本 grep 能抓到，但“测试与 grep 互补”的声明不成立。

修正标准：把文本门禁作为禁止减法的权威门禁，SELF_CHECK 注入减法后必须证明 grep 变红；删除“合法业务值通过溢出测试必红”的要求。

### P2-1：存在重复 YAML key

文件与行号：

- `act/08.yaml:429-430`：重复 `EXPECT_EXIT`。
- `act/09.yaml:180`：重复 `no_subtraction_in_compare_to`。
- `act/09.yaml:339-340`：重复 `RED_EXPECT`。
- `act/10.yaml:219-220`：重复 `RED_COMMAND`。

为什么是问题：宽松解析器会静默覆盖，严格解析器可能拒绝，机械执行者读取结果不确定。

修正标准：删除全部重复 key，并用能拒绝 duplicate key 的 YAML 校验器重新验证 11 个 ACT。

### P2-2：A1 没有 TESTS_FIRST 覆盖

文件：11 个 ACT 的全部 `COVERS` 映射。

为什么是问题：A1 只有 ACT 11 的最终 VERIFICATION 命令，没有任何 `TESTS_FIRST` case 标记 `COVERS: [A1]`，不符合 wjt-react“每条验收标准至少有一个 TESTS_FIRST/VERIFICATION 覆盖且门禁能证明自己能红”的要求。

修正标准：为 `run_s1b_analyze_gate.sh` 增加明确的注入型 TESTS_FIRST case，覆盖 scoped issue、非白名单 issue、白名单总数超基线三个方向，并标记 `COVERS: [A1]`。

## A1-A14 覆盖抽验

- **A1：不通过。** 无 TESTS_FIRST 映射，只有最终 VERIFICATION。
- **A7：通过。** ACT 05 覆盖 fail-closed、过滤前截断、计数一致性；ACT 06 覆盖 coordinator 到 pusher 的端到端泄漏路径。
- **A13：不通过。** 事务 helper 测试存在，但生产 applier 缺完整读取和构造接线契约。
- **A14：不通过。** signed int64 文字边界已补，但减法自检无效，UTF-8 比较没有可区分 UTF-16 的执行测试。
- 其余 A2-A12 均能找到至少一个 TESTS_FIRST 映射，本轮未发现新的整体遗漏。

## 实际核验证据

- 11 个 ACT 可被当前 Ruby YAML 解析，但宽松解析掩盖了重复 key。
- 158 条 VERIFICATION 命令全部通过 `bash -n` 语法检查。
- 当前 drift 基线实际执行 `flutter test`：**276 tests passed**。
- 当前分支：`agent/mimo/storage-s1b-multipeer`。
- 本审查没有修改 ACT、任务纪要、验收标准或业务代码。
