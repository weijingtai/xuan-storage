# 任务: storage-s1a-transport-passive
负责: claude ｜ 分支: agent/claude/storage-s1a-transport-passive ｜ 开工: 2026-08-03
状态: 待验收合并

## 目标
给 S1a 的 `Transport`/`PeerSession` 补上被动侧（广播 + 接听 + 入站流）与不暴露私钥的设备密钥端口，并修掉 `transport_contract_test.dart` 的恒绿断言 —— 全部零实现，只交付签名与可变红的契约测试。

## 计划
- [x] T1 `DeviceKeyPair`（值类，只有公钥）→ `DeviceKeyStore`（接口，只暴露 sign/verify）
- [x] T2 新增 `AdvertisementHandle`，让「广播只含随机 id」从注释变成可断言的返回值
- [x] T3 `Transport` 补 `advertise` / `stopAdvertising` / `incoming`
- [x] T4 `PeerSession` 补 `incomingStreams`
- [x] T5 修恒绿：`multiplexing_uses_awaited_instances` 改 await 后比真实例
- [x] T6 补 6 条契约测试并逐条做变异自检
- [x] T7 上调 A10 dartdoc 覆盖下限（133→142 实测，下限 123→132）

## 验收标准
- [x] A1 `bash scripts/run_s1a_analyze_gate.sh` 退出码 0
- [x] A2 `cd core && flutter test` 全绿
- [x] A3 `bash scripts/run_policy_negative_check.sh` 退出码 0
- [x] A4 零实现：`transport.dart` 内无任何 `Impl` 类、无 `UnimplementedError`
- [x] A5 `Transport` 的主动侧与被动侧成对存在（discover↔advertise、connect↔incoming）
- [x] A6 契约里不得出现 `privateKey`，不得残留 `DeviceKeyPair`
- [x] A7 六条新增契约测试**每条都做过变异自检**（注入违规→变红→复原）

验收命令: bash scripts/run_s1a_analyze_gate.sh && (cd core && flutter test) && bash scripts/run_policy_negative_check.sh

## 当前状态
- [x] 全部 7 项完成，三条门禁全绿：analyze 门禁 ✅ / core 70 测试全绿 / 负测试 8 行 ✅
- 改动仅 3 文件：`core/lib/model/transport.dart`、`core/test/transport_contract_test.dart`、`core/test/s1a_dartdoc_coverage_test.dart`（仅下限常量）
- 六条变异自检全部实做并确认能变红，复原后回绿（见决定记录）
- 与 S1b 无冲突：已核 ACT 05–10 的 SCOPE.WRITE，无一碰 `transport.dart`。唯一同步点是 ACT 11（读 barrel 的守卫测试 + dartdoc 下限）
- 下一步：人类验收合并；合并后 S6 / S3b / S3c 的准入条件 #1 #2 即达成

## 决定记录
- 2026-08-04: `DeviceKeyPair`（值类，字段 `publicKeyPem`）改为 `DeviceKeyStore`（接口，`localIdentity`/`sign`/`verify`）。理由: 值类要能签名就必然要加 `privateKeyPem` 字段，等于强制私钥以字符串形态进 Dart 内存。接口化之后契约上根本没有「取出私钥」这个 API，Keychain / Android Keystore / 将来的 Secure Enclave 实现都能塞进同一个口子，升级时只换实现不改接口。全仓零实现类，改签名代价接近零（实测 `implements Transport` 仅测试内 3 个 `_Fake*`）。
- 2026-08-04: 设备私钥走安全存储（`flutter_secure_storage`），与 D16「业务数据不做应用层落盘加密」不冲突。理由: 私钥不是数据是身份凭证，泄露后果是攻击者可冒充本设备加入用户同步网络，属账户级危害；且 D7 的提交正文自己就写了「真实现取密钥需读安全存储（Keychain / KeyStore），那是异步操作」，两条决议本来就默认了会用它。
- 2026-08-04: `advertise` 返回 `AdvertisementHandle` 而非 `void`。理由: 补丁前「广播只含随机 service id、不含 scopeUid 或设备名」这条隐私约定写在 `discover()`（查询侧）的注释上，而真正执行广播的方法根本不存在 —— 约定无处可实现、无测试可验（s3bc 体检报告 B5）。返回句柄后契约测试可直接断言 id 不含 scopeUid 与设备名，从一句空话变成一条门禁。
- 2026-08-04: `AdvertisementHandle` 带 `rotateAfter`。理由: 固定不变的 service id 即使不含身份信息也能被长期追踪，轮换周期必须是契约的一部分而非实现细节。
- 2026-08-04: 隐私约定的注释从 `discover()` 移到 `advertise()`。理由: 注释必须写在能实现它的方法上，否则永远无法验证。
- 2026-08-04: 修恒绿断言。原写法 `session.then((s){ final a=s.openStream(..); final b=s.openStream(..); expect(a,isNot(same(b))); })` —— `openStream` 是 `async`，`a`/`b` 是两个 **Future 对象**，`isNot(same(b))` 比的是包装器而非流本身，**恒真**。已在仓库外用「永远返回同一条流」的假实现实证：原写法 PASS，await 后比较真实例则 FAIL。同一缺陷还存在于 `export_reader_reuses_existing_remote_changes_page`（断言在未 await 的 `.listen` 回调里），一并修掉。
- 2026-08-04: 六条新增/修改的契约测试逐条做了变异自检，全部确认能变红: ①connect 不推给对端→rendezvous 红 ②openStream 返回同一实例→多路复用红（正是原恒绿那条）③不投递入站流→incomingStreams 红 ④广播 id 塞设备名→隐私红 ⑤stopAdvertising 空操作→停播红 ⑥契约里加回 privateKey→私钥门禁红。复原后 10 条全绿。
- 2026-08-04: A10 dartdoc 覆盖下限 123→132（实测 member 计数 133→142）。理由: 新增 9 个公开声明，下限须随之上移，否则门禁的防退化能力被稀释。

## 踩坑墓地
- 2026-08-04: 不要在同步 `test(() { ... })` 体内用 `future.then((x){ expect(...) })` 或 `stream.listen((x){ expect(...) })` 写断言。回调在测试结束后才跑，断言不参与判定。更隐蔽的是本例：即便回调真的执行了，`openStream` 是 `async` 使得比较对象变成 Future 包装器，`same()` 恒不相等。结论: 契约测试一律 `async` + `await`，比较**被 await 之后的值**。
- 2026-08-04: 不要把隐私/安全类约定写在「查询侧」方法的注释上（原 `discover()` 上那条广播约定）。写在无法实现它的方法上，等于永远无法验证。结论: 约定跟着能实现它的方法走，并尽量转成可断言的返回值。
- 2026-08-04: 不要用值类型承载密钥对。`DeviceKeyPair{publicKeyPem}` 看着无害，但一旦要签名就只能加 `privateKeyPem`，私钥就此进入 Dart 内存且无法收回。结论: 密钥一律用接口暴露能力（sign/verify），不暴露材料。

## 冷冻快照
<仅在搁置时由 /hibernate 填写>
