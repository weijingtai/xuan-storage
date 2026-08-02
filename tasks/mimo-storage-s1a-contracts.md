# 任务: storage-s1a-contracts
负责: mimo ｜ 分支: agent/mimo/storage-s1a-contracts ｜ 开工: 2026-08-01
状态: 蓝图

## 目标
在 `persistence_core` 包内交付存储分层架构的分类契约与全部端口签名（零实现），并用契约测试证明策略的结构性不变式不可被违反。

## 规格来源
`docs/superpowers/specs/2026-07-31-storage-architecture-design.md`（1659 行，已过 /autoplan 三阶段评审 + Codex 跨模型验证）。
**§ 号在下方每个子任务里给出，执行时按 § 号定位原文，不要凭记忆写。**

## 计划

已转译为 ACT，按 ORDER 顺序执行，每个 ACT 内含 SCOPE / SIGNATURE / TESTS_FIRST / VERIFICATION。

- [ ] ACT 01: 六个分类 enum + CancellationToken + blob 错误子类 -> `docs/storage-s1a-contracts/act/01.yaml`
- [ ] ACT 02: StoragePolicy sealed 类族 + Registry + 不变式契约测试 -> `docs/storage-s1a-contracts/act/02.yaml`
- [ ] ACT 03: blob 值类型 + LocalBlobStore + BlobCipher + RecordBlobUnitOfWork -> `docs/storage-s1a-contracts/act/03.yaml`
- [ ] ACT 04: BlobGateway + Transport/PeerSession + ExportBundleWriter/Reader -> `docs/storage-s1a-contracts/act/04.yaml`
- [ ] ACT 05: barrel export + 策略通道过滤契约测试 -> `docs/storage-s1a-contracts/act/05.yaml`
- [ ] ACT 06: analyzer 负测试（方向易反，STRONG_MODEL_ONLY） -> `docs/storage-s1a-contracts/act/06.yaml`

原 T1–T16 的映射见「决定记录」末尾的转译对照。

## 验收标准

- [ ] A1 `cd core && dart analyze --fatal-infos` 零 issue
- [ ] A2 `cd core && flutter test` 全绿，且 T13/T14/T15 三个测试文件存在且被执行
- [ ] A3 T16 的负测试脚本执行后退出码为 0（即 fixture 内 `dart analyze` 确实报错了）
- [ ] A4 `grep -rn "class .*Impl\|UnimplementedError" core/lib/model/` 无输出 —— **S1a 是零实现，出现任何具体实现类即不合格**
- [ ] A5 `grep -rn "enum Visibility " core/lib/` 无输出 —— 必须叫 `DataVisibility`
- [ ] A6 `grep -rn "ExportFileTransport\|class NetworkUnavailable" core/lib/` 无输出 —— 这两个名字已被明确否决
- [ ] A7 `StoragePolicy.private` 参数表不含 `cloud` / `channels`；`StoragePolicy.shared` 不含 `channels`；`StoragePolicy.control` 无任何参数
- [ ] A8 四个 `*Policy` 子类构造器均为私有（`._`）
- [ ] A9 新增端口全部出现在 `core/lib/persistence_core.dart` 的 export 列表
- [ ] A10 每个新端口的 dartdoc 中文注释齐全（仓库惯例，见既有 `ports.dart`）

验收命令: `cd core && dart analyze --fatal-infos && flutter test && bash test/model/storage_policy_analyzer_test/run_negative_check.sh`

## 当前状态
- [x] ACT 01: 六个分类 enum + CancellationToken + blob 错误子类 ✅
  2026-08-01 完成。新增 4 文件：storage_classification.dart（6 enum 照 §2.1）、
  cancellation_token.dart（抽象接口）、blob_error.dart（5 子类，code 前缀
  storage.blob_）、storage_classification_test.dart（3 用例全绿）。
  验证: analyze 0 / flutter test 4 通过 / 无裸 Visibility / 无 NetworkUnavailable。
- [x] ACT 02: StoragePolicy sealed 族 + Registry + 不变式契约测试 ✅
  2026-08-01 完成。新增 storage_policy.dart（照 §2.3 原文，四子类构造器全私有）、
  storage_policy_registry.dart（register 校验不变式 #4/#5 抛 StateError）、
  storage_policy_test.dart（7 用例全绿）。A8 自检已做：临时加 SharedPolicy.public
  被 grep 拦到后恢复。@visibleForTesting 改从 flutter/foundation 取（meta 未声明为依赖）。
- [ ] ACT 03: blob 值类型 + LocalBlobStore + BlobCipher + RecordBlobUnitOfWork（未开工）
- [ ] ACT 04: BlobGateway + Transport/PeerSession + ExportBundleWriter/Reader（未开工）
- [ ] ACT 05: barrel export + 策略通道过滤契约测试（未开工）
- [ ] ACT 06: analyzer 负测试（未开工）

## 决定记录
- 2026-08-01: S1 拆为 S1a(契约) + S1b(引擎多 peer 化)。理由: 核实发现 `t_outbox` 主键 `{operationId}`、`t_sync_state` 主键 `{scopeUid,entityType}`、`markSuccess` 签名均无 peerId，多 peer 需两次 schema 迁移，不属契约层。原文档「SyncCoordinator/SyncRuntime 零改动」经核实为假。
- 2026-08-01: `private` 策略的 `cloud` 从参数表移除，改为结构上不可关闭。理由: 上一版用 `Set<Channel>` 自由传入，`StoragePolicy.private(channels: {Channel.lan})` 可构造，直接违反「private 必含 cloud」不变式。Codex 跨模型评审发现。
- 2026-08-01: 四个 Policy 子类构造器改私有。理由: public 构造器可绕过命名工厂的参数表约束。
- 2026-08-01: 不变式分「结构性」与「注册期」两级，不再统一宣称编译期。理由: 实测 Dart const 构造器无法用 assert 判定集合成员。
- 2026-08-01: 加密由独立 `BlobCipher` 端口承担，`LocalBlobStore` 存密文且不是密码学组件。理由: 若在 put 之外加密，本地磁盘裸存私人照片，与「客户端 E2EE」的声称矛盾。
- 2026-08-01: 新增 `readCipherChunk`。理由: 原设计只有写密文 chunk 与读明文，本地密文取不出来上传，而 `BlobGateway.putChunk` 要密文，上传链是断的。Codex 发现。
- 2026-08-01: 新增 `RecordBlobUnitOfWork` 聚合端口。理由: 原文只写「reconcileRefs 必须与记录写入同事务」，但两个端口都无事务令牌，调用方实现不了。
- 2026-08-01: `enum Visibility` 改名 `DataVisibility`。理由: `persistence_core` 依赖 flutter，与 `Visibility` widget 冲突。
- 2026-08-01 转译v1 覆盖对照: A1->ACT01,02,03,04,05,06; A2->ACT02,03,04,05; A3->ACT06; A4->ACT03,04; A5->ACT01; A6->ACT04; A7->ACT02,05; A8->ACT02; A9->ACT05; A10->全部 ACT 的 CONSTRAINTS。T1 拆入 ACT01(建文件)与 ACT05(barrel); T2->ACT01; T3,T4,T13->ACT02; T5-T8,T14->ACT03; T9-T11->ACT04; T12 拆入 ACT01(CancellationToken/错误类)与各 ACT 的 dartdoc 约束; T15->ACT05; T16->ACT06。无自然语言遗留项，16 项全部可机械执行。
- 2026-08-01 转译期偏差修正1: 测试文件路径由纪要的 `core/test/model/xxx_test.dart` 改为 `core/test/xxx_test.dart`。理由: core 包既有测试全部平铺在 test/ 下（storage_error_test.dart 等 8 个），无 model/ 子目录，遵循既有惯例。
- 2026-08-01 转译期偏差修正2: 「用 StoragePolicy 体系」具体化为「新建 XxxError extends StorageError，构造器 super(code/message/reason/suggestion)，code 前缀 storage.blob_」。理由: 核对 core/lib/model/storage_error.dart 发现 StorageError 是带四字段的具体类，既有子类 SyncConflictError 就是这个模式，不是 sealed union。
- 2026-08-01 转译期偏差修正3: analyzer 负测试 fixture 由纪要的 `core/test/model/storage_policy_analyzer_test/` 移到仓库根 `test_fixtures/policy_negative/`，依赖路径由 `../../../..` 改为 `../../core`。理由: 已实测嵌套 fixture 会被 `cd core && dart analyze` 扫到导致全包 analyze 失败; 而用 analysis_options exclude 排除后 fixture 单独 analyze 会继承排除规则、变成 No issues，负测试失效。放仓库根两边互不可见。
- 2026-08-01 转译期偏差修正4: 负测试的判定由「期望退出码非 0」收紧为「期望退出码恰为 3」。理由: 已实测 dart analyze 退出码分级 0=无问题/1=info/2=warning/3=error，fixture 只剩 unused_import 警告时退出码是 2，按「非零」判会假通过。
- 2026-08-01 转译期新增前置条件: ACT 01 标注必须能连通内网 Gitea 192.168.0.165:3000。理由: core/pubspec.yaml 有 5 个 git 依赖托管在该地址，连不通则 flutter pub get 失败，整个任务无法开工。
- 2026-08-01 转译审查R1(执行者: Codex, 与转译者 Claude 不同厂商): 返工 9 项，已全部修复。核心问题是 oracle 过宽——多处验证只能证明「至少一条约束生效」，不能证明「每条都生效」。
- 2026-08-01 R1返工-1: ACT06 由「五条违规同文件、只看总退出码」改为「八条违规各一文件、逐条独立 analyze」。理由: 聚合 oracle 下即使 v2-v5 全部意外合法，只要 v1 仍报错脚本照样通过。同时把子类直接构造的负探针从 1 个（PrivatePolicy）补到 4 个（四个子类各一）。
- 2026-08-01 R1返工-2: ACT06 脚本改用 dart analyze --format=machine，逐条核对错误【码】与错误【所在文件】，不再只看退出码。新增 pub get 退出码检查与 URI_DOES_NOT_EXIST 拦截。理由: 依赖解析失败也会让 analyze 返回 3，会被误判为「约束生效」。
- 2026-08-01 R1返工-3: ACT02/03/04 中三处 `grep -c` 的 EXPECT_STDOUT:"0" 补上 EXPECT_EXIT:1。理由: 已实测 grep -c 无匹配时打印 0 但退出码是 1，只声明 stdout 会让验证契约不闭合。
- 2026-08-01 R1返工-4: ACT02 的 A8 验证由「四个 ._ 总数为 4」改为「四个子类各自 grep -c 为 1」+「无匹配任何公开构造器」。理由: 总数为 4 无法排除「4 条都是 PrivatePolicy._」。
- 2026-08-01 R1返工-5: ACT05 补 A4 全目录零实现扫描（原先各 ACT 只扫自己那几个文件）、A9 由验 2 条 export 改为逐条验 12 条、A10 新增中文 dartdoc 门禁测试（原先 A10 只写在 CONSTRAINTS 里，无任何验证）。
- 2026-08-01 转译审查R1 结论: 9 项返工全部修复，ACT 由 6 个块（22 测试用例/26 验证命令）增至 6 个块（27 测试用例/32 验证命令）。待 R2 复审。
- 2026-08-01 转译审查R2(Codex): 9 项中 6 项确认已修，2 项部分修复，另发现 1 项新风险。三项已全部修复。
- 2026-08-01 R2返工-1: ACT02 的 A8 正则由 `XxxPolicy\(` 扩为 `XxxPolicy(\.[a-zA-Z]|\()`。理由: 原正则只拦无名公开构造器，`SharedPolicy.public(...)` 这类公开【命名】构造器仍可逃逸（`._` 因 _ 非字母不被误伤）。
- 2026-08-01 R2返工-2: ACT06 脚本弃用 `declare -A`，改 while-read 表驱动。理由: 已实测 macOS 自带 /bin/bash 为 3.2.57，不支持关联数组，配合 set -u 直接退出 127，脚本会在跑到八项检查前就死。VERIFICATION 增加 `/bin/bash -n` 与 `/bin/bash 跑通` 两条。
- 2026-08-01 R2返工-3: ACT06 oracle 由「日志中存在目标错误」收紧为「analyze 退出码恰为 3 + 存在目标错误 + 不存在允许集合之外的 ERROR」。理由: 原判据下「目标错误 + 一堆无关错误」也会通过。已在 bash 3.2 下用假日志实测：注入 UNDEFINED_IDENTIFIER 后正确判失败。
- 2026-08-01 R2返工-4: 伴生错误码纳入允许集合。理由: `const x = Foo(bad:1)` 除 UNDEFINED_NAMED_PARAMETER 外必然连带 CONST_INITIALIZED_WITH_NON_CONSTANT_VALUE，若不允许会误报。已实测确认该伴生关系。
- 2026-08-01 转译审查R2 结论: 3 项返工已修复并实测验证（bash 3.2 兼容性 + oracle 严格性）。ACT 最终 6 块 / 28 测试用例 / 36 验证命令。协议规定闸门 ≤2 轮，是否再跑 R3 由人类决定。

## 踩坑墓地
- 2026-08-01: 尝试用 const 构造器的 `assert(channels.contains(Channel.cloud))` 把不变式做成编译错误，失败。原因: `Set.contains` 是方法调用，const 表达式禁止，报 `const_eval_method_invocation`。结论: 别再试 assert 路线，用「把参数从参数表移除」的结构化手法。
- 2026-08-01: Codex 评审主张「重定向工厂的可选非空参数必须在工厂声明自身写默认值，写在目标构造器上编译不过」。实测证伪: `dart analyze` 零 issue，Dart 允许默认值写在目标构造器。结论: 该主张不成立，别按它改。
- 2026-08-01: 曾把 `ExportFileTransport` 设计为 `Transport` 的实现。否决。原因: 文件不是持续连接，没有握手/心跳/双向并发流/实时多路复用，而这四样正是 `PeerSession` 的契约，硬套会得到一堆 `UnsupportedError`。结论: 导出导入走独立的 `ExportBundleWriter/Reader`，只复用 `RemoteChangesPage` 数据形状，不复用连接抽象。
- 2026-08-01: 曾声称「禁止去中心化分享是拓扑上无法到达」。否决。原因: `peekBatch({scopeUid, limit})` 无 policy 过滤，shared 草稿照样会被 fan-out 到本人 LAN peer。结论: 必须有主动的 channel 过滤（S1b 交付），拓扑不构成保护。
- 2026-08-01: 曾把 `Transport` 与 `SyncPeer` / `BlobGateway` 并列画成「三组端口」。否决。原因: LAN peer 的 oplog 流与 blob chunk 流共用同一条物理连接，并列画法导致连接建立/握手/心跳/重连/流控无归属。结论: `Transport` 在下层，由 `PeerSession` 持有并多路复用。

## 冷冻快照
<搁置时由 /hibernate 填写>
