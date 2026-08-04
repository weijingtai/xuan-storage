# 转译审查 R2 —— Codex 跨模型闸门

日期: 2026-08-02 ｜ 审查对象: 转译 v2（commit 50e062f）｜ 会话: 019fc460-7a17-7ab0-b90b-8adfc5e92eb0

## 判定：返工（第 2 轮）

Codex 原话："v2 相比 v1 确实实质变好，尤其接口方向、ON_FAIL 和 grep 门禁已改善，
但仍未达到可机械执行状态。"

**wjt-react 协议上限为 2 轮。R1 + R2 已用完，按协议上报人类。**

## R1 的 25 项状态（Codex 复核）

修了 11 项 ｜ 部分修 6 项 ｜ 没修 5 项 ｜ 因设计变更失效 4 项（HLC 方案取代了原 Lamport 设计）

已彻底解决：P0-2（per-peer 接口）、P0-8（双向留档）、P0-9（畸形 payload）、
P0-11（enqueue 例外与 11/12 计数）、P1-16（只读 getter）、P1-17（SCOPE.WRITE）、
P1-18（grep -c 双 EXPECT，实数 33 条现为 0 缺）、P1-19（12/12 有 ON_FAIL）、P2-23（防篡改基线比对）

仍未解决：P0-12（backlog/watch/dead 扩 channel 无人类决定记录）、P0-13（'firestore' 耦合仍允许 fallback）、
**P1-14（编译死锁）**、P1-15（无 attempt 读取端口 + 引用私有 fake）、P2-22（dartdoc 只扫 3 文件）、
P2-24（`|| true` 恒绿门禁）、P2-25（多个 ACT 仍超粒度）

## 转译者自查确认的两条结构性问题

### ① P1-14 没修好，而且我修错了地方（已实证）

```
drift/lib/persistence_drift.dart:614  class DriftOutboxStore implements OutboxStore
drift/lib/persistence_drift.dart:916  class DriftSyncStateStore implements SyncStateStore
```

这两个类【直接 implements core 的端口】。ACT 03 给端口 11 个方法加 `required peerId`
之后，它们必然报 `NON_ABSTRACT_CLASS_INHERITS_ABSTRACT_MEMBER`。
**我在 ACT 04 做的"纯加法保持可编译"救不了这个** —— 编译是被【端口变更】打断的，
不是被 schema 打断的。加不加列都一样红。

这暴露的是**分解方式本身的问题**：在静态类型 + 跨包 implements 的结构下，
"端口变更"与"实现跟进"无法拆到两个 ACT 而不产生不可编译的中间态。

### ② 线上格式的 signed int64 边界（实测，属规格缺口非现网 bug）

`(l << 16) | c` 中 l 占 48 位，理论上会占满 int64 的符号位。实测：
当前毫秒数 l ≈ 2^40，打包后占 57 位，距符号位（第 63 位）还有 6 位余量，
**需要 l ≥ 2^47 才会变负，约 4460 年后**。实践安全，但规格必须写明 l 的有效上限，
否则跨语言实现各自猜。

## Codex 新发现的必须返工（10 项，摘要）

1. **ACT04**：继承 ACT03 的编译错误却禁止改 DAO，"不改 DAO 仍全包绿"不可能成立；
   且 fresh DB 用例错误地要求 v7 已是三元主键
2. **ACT07**：SIGNATURE 的 override 仍是旧的 `pushToAll(OutboxRecord record)`，与 ACT01 契约不兼容
3. **ACT09**：`EntityStamps` 主键只有 `(entityType, entityId)`，**缺 scopeUid** ——
   不同账号的同名实体会共用戳；`hlcClockState` 只有调用名没有表结构
4. **ACT09/11**：A13 的"同事务"只有测试意图，没有可落地的生产事务接口；
   `applyRecord` 回调无法保证与边表更新共享同一 drift transaction
5. **ACT09**：收敛性测试是"同一确定性函数自比"，证明力不足
6. **ACT10**：四条序性质抓不到"用减法实现 compareTo"（普通值上减法同样满足全部性质）
7. **ACT10/11**：null 降级把"边表无戳"等同于"本地实体不存在"，两者语义不同
8. **ACT11**：`arbitration_wiring` 仍要求 `(rev, deviceId)`/`LamportStamp`，
   takeRemote 测试仍引用已不存在的 `overwrittenPayloadJson`
9. **多个 ACT**：`<ACT_BASE>` 被当字面量写进命令，不是可执行 shell 表达式
10. **ACT09/10/12**：signed int64 与 UTF-8 字节序的跨语言边界未闭合

## A1–A14 覆盖对照（Codex 抽验）

覆盖充分 1 条（A6）｜已承接但被其他问题阻断 2 条｜部分 8 条｜**抽验不通过 3 条**（A7 / A13 / A14）

## 建议改进
- 全局清除重编号后的陈旧引用（多个 ACT 有错号，ACT12 残留 `LamportStamp` / `06b` / "A1–A12"）
- 依赖钉死 `hlc_dart: 1.1.0+2`，不用会漂移的 `^1.1.0`
- 校正 DONE_WHEN 计数（ACT11 实际 9 CASE/8 自检，写成 6/5）
