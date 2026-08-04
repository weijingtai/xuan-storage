# storage-s1b-multipeer ACT 转译闸门 R4

审查基线：`b17a83e`（转译 v3.1）  
审查对象：`docs/storage-s1b-multipeer/act/01.yaml` 至 `11.yaml`  
审查日期：2026-08-02

## 判定：返工

方案 A 的结构性前提仍然成立，但 v3.1 尚未达到可机械下发标准。当前确认有 5 项必须返工：2 项 P0、2 项 P1、1 项 P2。

本轮是只读验收；未修改 ACT、任务纪要或验收标准。

## 方案 A 是否成立

成立，本轮没有推翻 R3 的结论：ACT 03 可先完成 drift schema v6→v7，ACT 04 再在一个 ACT 内闭合 core 端口与 drift 实现变更。

R3 已验证的依据仍有效：

- `SyncStatesDao` 通过列谓词定位记录，不依赖复合主键 API。
- `peerId` 有默认值时，生成的 Companion 字段仍可选，不会迫使所有旧调用点立刻传参。
- schema 切换时只有 `firestore` 一个 peer 值，二元唯一性与三元唯一性在该阶段行为等价。
- drift 基线实跑结果为 276 个既有测试通过。

因此，本轮返工点属于 ACT 可执行性和门禁证明力问题，不是方案 A 本身失效。

## 新发现的必须返工项

### P0-1：ACT 08 的收敛性测试无法按文档执行

文件：`docs/storage-s1b-multipeer/act/08.yaml:319-344`

问题：

- `convergence_over_fixed_stamps` 缺少其他 TESTS_FIRST 条目具备的 `RED_COMMAND`、`RED_EXPECT` 和 `COVERS`，执行者无法机械完成红灯阶段，覆盖映射也无法由结构化字段核验。
- 文档要求构造两个“归并器”实例，但 ACT 08 没有定义对应的生产类型或签名。
- 真正负责定序的 `HlcConflictArbiter` 要到 ACT 09 才产生；ACT 08 此时没有可供该测试驱动的生产仲裁实现。若测试自造归并函数，就会退化为测试代码自证，无法约束生产实现。

修正标准：

- 将该收敛性测试移至 ACT 09，在 `HlcConflictArbiter` 或明确的生产 reducer 上运行；或在 ACT 08 明确定义并实现随后由 ACT 09 复用的生产归并抽象。
- 补齐 `RED_COMMAND`、`RED_EXPECT`、`COVERS`。
- 两个独立状态实例必须使用同一组冻结 VersionStamp、不同到达顺序，并调用真实生产仲裁路径；把仲裁退化为“后到者赢”时，该测试必须变红。

### P0-2：ACT 10 的生产接线契约自相矛盾且样板不可编译

文件：`docs/storage-s1b-multipeer/act/10.yaml:110-160`

问题：

- `:124-127` 声称同一 applier 可跨 scope 复用，但样板中的 `readLocalStamp` 和 `applyWithStamp` 在构造时捕获固定的 `scope`（`:143-151`）。回调签名本身不接收 `scopeUid`，所以实例不能按每次 `applyRemoteChanges` 的 scope 工作。
- `:153` 使用 `const ConflictArbiter()`，但 `ConflictArbiter` 是抽象契约；实际实现应为 ACT 09 的 `HlcConflictArbiter`。
- `:142` 调用 `findRecordByUuid`，而既有生产接口是 `getRecord(String uuid)`；`:156-158` 又要求“没有就新增方法”，导致执行者可能重复造接口。
- `drift_record_data_source.dart` 若可能被修改，就必须明确列入 ACT 的 MODIFY/SCOPE；不能一边把它当只读依赖，一边条件式要求修改。

修正标准：

- 让需要数据库访问的回调显式接收 `scopeUid`，并由 `applyRemoteChanges` 的本次参数传入；或明确每个 applier 只绑定一个 scope，并删除“跨 scope 复用”的承诺。二者只能选一套一致契约。
- 样板实例化真实具体类 `HlcConflictArbiter`。
- 对齐现有 `getRecord(String uuid)`，除非有独立、可验证的理由新增方法。
- 若修改 `drift_record_data_source.dart`，将其明确加入写范围；否则删除条件式修改指令。

### P1-1：极端量级用例仍包含错误的溢出论证

文件：`docs/storage-s1b-multipeer/act/09.yaml:285-299`

问题：

- `:289-295` 要求用规格合法值构造超过 `2^62`、甚至跨 `2^63` 的差值，并声称减法会符号翻转；但 `:297` 又承认合法值域内减法不会符号翻转。
- 对合法的 packed 值，减法若不溢出，符号与三路比较一致，所以该数值测试不能抓到“用减法实现 compareTo”。
- `:299` 反称该用例能兜住“用减法但数值没溢出”，逻辑正好相反：没溢出时减法给出的比较结果是正确的。

修正标准：

- 删除“合法极端值必因减法溢出而红”和“非溢出也能抓减法”的表述。
- 把禁止减法实现的权威门禁明确限定为源码文本检查，并用 SELF_CHECK 将实现临时改为减法，证明该门禁会红。
- 数值测试只保留对边界排序结果的行为验证，不再宣称它能识别实现手法。

### P1-2：A1 门禁自测的恢复与洁净性要求不可靠

文件：`docs/storage-s1b-multipeer/act/11.yaml:286-323`

问题：

- `:302` 指示使用 `git checkout` 恢复文件，既不符合本 worktree 的安全规则，也无法可靠恢复新建的未跟踪文件。
- `:315` 要求每次注入后整个 `git status --porcelain` 为空，但执行 ACT 11 时本来就会新增或修改多个尚未提交的文件，工作树合法地可能非空。
- 第二、三次注入没有给出统一、异常安全的恢复机制；脚本中途退出可能遗留被篡改文件，污染后续验证。

修正标准：

- 使用 `mktemp -d` 保存逐文件备份，并用 `trap` 在成功、失败和信号退出时统一恢复。
- 测试开始前记录 `git status --porcelain` 快照，结束后比较前后快照一致，而不是要求全局为空。
- 对测试中新建的文件显式记录并删除；不得依赖 `git checkout` 恢复未跟踪文件。
- 至少自测一次门禁失败中途退出，确认 trap 仍能恢复现场。

### P2-1：ACT 10 对旧名 `rev` 的完成条件过宽且与现状冲突

文件：`docs/storage-s1b-multipeer/act/10.yaml:504-513`，重点 `:511`

问题：

- `RecordMeta` 对业务字段 `rev` 的解析是既有合法行为；“源码里不再有 rev”会误杀正常领域字段。
- ACT 的验证命令实际只禁止 `LamportStamp` 和 `overwritten*`，并没有、也不应全局禁止裸词 `rev`。DONE_WHEN 与 VERIFICATION 口径不一致。

修正标准：

- 将条件改为：禁止把 `rev` 用作冲突仲裁坐标、版本胜负依据或旧 Lamport 路径；允许业务模型继续解析和保存其既有 `rev` 字段。
- 增加针对仲裁实现路径的精确验证，避免对整个源码目录粗暴 grep 裸词 `rev`。

## A1–A14 覆盖复核

结构化 `COVERS` 统计中，A1–A14 均至少出现一次；但“出现映射”不等于门禁有效。

- A7：已有 TESTS_FIRST 映射，本轮未发现新的阻断项。
- A13：`applyWithStamp` 生产接口和 `getEntityStamp` 读取接口已补入，但 ACT 10 的 scope 接线矛盾使生产闭环仍不可执行，因此只能判“部分覆盖”。
- A14：signed int64 的 `l` 上限和 deviceId UTF-8 字节序基准已经补入；但 ACT 09 的减法检测论证仍需按 P1-1 修正。
- A1：已有注入型 TESTS_FIRST 映射，但恢复机制不可靠，尚不能证明门禁在不污染工作树的前提下稳定地红/绿闭环。

## 已验证通过的通用检查

- 11 个 ACT YAML 均可被 Ruby YAML 解析。
- 163 条 VERIFICATION 命令均通过 `bash -n` 语法检查。
- A1–A14 文本与基线提交 `cd064c6` 保持字节一致，验收标准未被转译者篡改。
- A1–A14 均有至少一个 `COVERS` 映射。
- R3 曾报告的“重复 YAML key”属于截断/交错输出导致的误判，本轮不再列项。

## 返工完成后的复验门槛

五项全部修复后再提交 R5。复验至少应包括：

1. 严格重复 key 检查和 YAML 解析。
2. 全部 VERIFICATION 命令 `bash -n`。
3. A1–A14 与 `cd064c6` 的完整性比较。
4. A1–A14 的结构化覆盖计数。
5. 对上述五项逐条执行 mutation/self-check，确认点名门禁确实能红，而不是由无关测试代替变红。
