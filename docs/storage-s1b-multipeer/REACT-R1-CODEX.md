# 转译审查 R1 —— Codex 跨模型闸门（wjt-react）

日期: 2026-08-02 ｜ 审查者: Codex CLI 0.146.0（model_reasoning_effort=high，read-only）
审查对象: `docs/storage-s1b-multipeer/act/{01,01b,02,03,04,05,06,06b,07,08,09,10}.yaml`
会话: 019fc232-5ed8-78a1-a7c6-1d7e3c6d4811

## 判定

**返工 —— 12 个 ACT 不可开工。必须返工 25 项，建议改进 4 项。**

理由: 存在真实数据泄漏、冲突仲裁失效、接口不可实现及恒绿门禁。四查未全部通过。

## 转译者独立复核（4 条关键指控，全部属实）

| 指控 | 复核方式 | 结论 |
|---|---|---|
| P0-1 pushToAll 架空 channel 过滤 | 读 ACT05 SIGNATURE 与 ACT09 SIGNATURE | 属实。`pushToAll(record)` 无 eligible peer 参数 |
| P0-3 ACT06b 取错字段 | grep firebase 两个 gateway | 属实。实体文档写 `lastDeviceId`(:222/741/757)，`'deviceId'`(:644) 只进 oplog |
| P0-4/5 Lamport 时钟域 | 读 `_revisionRef` 定义 + grep drift schema | 属实且更糟。RTDB revision 是 (scopeUid,entityType) **集合级**计数；本地 drift **无 rev 列** |
| P1-18 grep -c 缺双 EXPECT | 脚本统计全部 VERIFICATION | 属实，实测 26 条 / 11 个 ACT（仅 ACT01 幸免） |

## 必须返工 25 项

### P0 会让执行体做错事（13 项）
1. ACT05+09: channel 过滤挡不住 pushToAll，shared 仍发往 LAN ｜ 修正: 定义 eligible peer 集合如何进入扇出接口 + coordinator→pusher 端到端测试（cloud pushCount=1 / LAN pushCount=0）
2. ACT06: runtime 看不到 per-peer 结果，也不能按 peer 跳过 push/pull ｜ 修正: SIGNATURE 定义可枚举 peer、per-peer push outcome、pullOnce(peerId)、移除 peer 的正式接口；测试走正式路径不得篡 debug Map
3. ACT06b: deviceId 数据源与真实 Firebase 实体 schema 不符 ｜ 修正: 从实体文档 `lastDeviceId` 读，用 push→listChanges round-trip 验证
4. ACT06b+07+08: Lamport 坐标不在同一时钟域 ｜ 修正: 先定义并持久化同一实体、同一单调序列的 (rev, deviceId)；加"两实体交错写入不改变另一实体胜负"的测试
5. ACT06b+07: Firestore rev=null→0 不自洽（本地 rev≥1 时恒输）｜ 修正: 必须证明更高 Firestore 版本可 takeRemote
6. ACT07: null 降级无生产 API 落点（LamportStamp/arbitrate 参数全非空）｜ 修正: SIGNATURE 定义唯一的 nullable 坐标规范化入口，测试直接调它
7. ACT08: applier 无法读取本地 stamp 和旧 payload ｜ 修正: 明确 reader 的类型/构造参数/类型来源与全部构造点迁移；不得以"拿不到就 RWW"作为 DONE
8. ACT07+08: keepLocal 后远端 loser 不可回溯 ｜ 修正: keepLocal 的 outcome 也要承载被丢弃的远端 payload/stamp
9. ACT08: failed/skipped 未覆盖畸形 payload ｜ 修正: JSON 解析失败/字段缺失/持久化异常均须 failed + canAdvanceCursor=false + lastError 含 operationId
10. ACT05: 纪要要求 router 改 fan-out，ACT 却守卫它保持 1-of-N ｜ 修正: **人类先裁定 router 与 pusher 的最终职责**并写入决定记录
11. ACT02: "全部方法加 peerId"与 enqueue 例外冲突，且 required PeerId 实际 11 处却验 12 ｜ 修正: 正式记录 enqueue 例外，门禁改准确值
12. ACT09: 凭空给 backlog/watch/dead 扩 channel，SIGNATURE 只给 peekBatch ｜ 修正: 先写决定记录并补全三个签名，否则限于已批准的 peekBatch
13. ACT03: 'firestore' 耦合测试允许退化成单边硬编码 ｜ 修正: SCOPE.READ 加 firebase 源文件，精确解析 getter 比对，禁 fallback

### P1 会导致执行体做不动（7 项）
14. ACT03: 预期编译失败与迁移测试 exit 0 不可同时满足（测试 import 同一个 persistence_drift.dart）｜ 修正: 调整 ACT 顺序/边界，或给出可独立编译的迁移 harness
15. ACT05: 无读取 per-peer attempt 的端口；新测试不能用另一 test library 的私有 fake ｜ 修正: 明确 attempt 由 store 原子自增或新增读接口；共享 fake 提取到 test-support 文件并纳入 SCOPE
16. ACT06: 要求新增公开 debug getter，但验证正则会拒绝它 ｜ 修正: 钉死四个只读 getter 签名；门禁只禁可写/public 字段
17. ACT01b+02: TESTS_FIRST 引用的新测试文件未列入 SCOPE.WRITE
18. 11 个 ACT / 26 条 grep -c 缺双 EXPECT ｜ 修正: 每条同时写 EXPECT_STDOUT 与 EXPECT_EXIT
19. 全部 12 个 ACT 缺 ON_FAIL ｜ 修正: 至少区分 RED 未红 / 实现验证失败 / 基线失败 / 预期中间态 / 自检残留
20. 6 个 ACT 的 HEAD~1 范围守卫依赖"每个 ACT 恰好一个提交"｜ 修正: 记录不可变 base ref，用 `<act-base>..HEAD`

### P2 门禁会假绿或工作量失控（5 项）
21. ACT10: A2 没守住 core 64 / drift 276 既有测试 ｜ 修正: 加测试名称/数量基线与旧断言无删改门禁
22. ACT10: A12 只扫三个新 core 文件 ｜ 修正: 覆盖 types.dart 新字段、drift 公共表、全部新增/修改公开声明
23. ACT10: A1–A12 防篡改命令恒弱（main 中不存在本任务文件）｜ 修正: 对立项提交 bf1dc85 的验收标准区逐字比较或校验哈希
24. ACT08: "不得给 SkipReasonCode 加值"的验证含 `|| true` 永远 exit 0 ｜ 修正: 删 `|| true`，对 enum 完整成员做精确比较并注入验证
25. 7 个 ACT 明显超 30–60 分钟粒度（01b 跨三包 14 文件 / 06 同改 push+pull+生命周期 / 08 同修游标与冲突持久化 / 10 同做三包门禁与架构守卫）

## 建议改进 4 项
- ACT01b: `get_capabilities_never_throws` 未触达两个 Firebase 实现，建议加源码守卫禁 `throw UnimplementedError`
- ACT05: 三个 200ms delay 断言 <400ms 判并发，CI 会抖，建议改 Completer/屏障式确定性测试
- ACT09: 10 shared + 3 private 抓不到固定倍数 over-fetch，建议让 shared 前缀超过内部 chunk 并断言三个具体 private ID 及顺序
- ACT07: 实际 7 CASE / 5 自检，DONE_WHEN 却写 6 CASE / 4 自检，计数不一致会让便宜模型漏做

## 五个点名疑点的结论
1. **ACT03 回填 'firestore'**: 值正确（推翻 'cloud' 是对的），门禁不牢 —— 允许 fallback 必须删
2. **Firestore rev 恒 null**: **不自洽**。null→0 遇本地 rev≥1 恒 keepLocal；"取不到本地 stamp 就 takeRemote"又退回 RWW。RTDB 集合级 revision 与本地实体 rev 不可比
3. **failed vs skipped**: 方向正确、分类不完备。keepLocal/identical 记 skipped 并推进游标是对的，不会"永远不推进"；错的是声称远端 loser 下次还能拉到 —— 游标已推进
4. **ACT04 LEFT JOIN/NULL**: 测试能抓 ✅。**ACT09 先过滤后截断**: 能抓直接错误实现，抓不到固定倍数 over-fetch，也抓不到 fan-out 端到端泄漏
5. **63 条 SELF_CHECK 存在假自检**:
   - ACT07 把 compareTo 改成 `rev - other.rev` 后自反/反对称/传递仍可能全成立 → 该突变不保证变红
   - ACT05 把 per-peer catch 移到 Future.wait 外，所有 future 仍已启动，pushCount 仍为 1 → 该突变不保证变红
   - ACT08 的 enum 检查含 `|| true` 恒绿；ACT06 的合法 debug getter 会被自身门禁拒绝

## 核对结果汇总（可执行性）
- MODIFY 路径全部存在 ✅；WRITE 路径全部不存在 ✅
- 后续 ACT 缺失的 READ 文件均由声明的前序 ACT 创建，依赖上可解释 ✅
- 遗漏: ACT01b、ACT02 的新测试文件未列 WRITE ❌
- flutter/dart/bash/grep/awk/sed 均存在；bash 3.2.57 ✅
- 模糊词（适当/优雅/合理地/必要时/酌情）扫描结果 **0** ✅
- DEPENDS_ON 严格单链 ORDER 1–12，无环，遵守依赖时无并行踩踏 ✅
- 12 个 ACT 均无 ON_FAIL ❌
- 实测统计 71 CASE / 118 VERIFICATION / 63 SELF_CHECK ✅
- A1–A12 与立项提交 bf1dc85 对比确未被篡改 ✅
