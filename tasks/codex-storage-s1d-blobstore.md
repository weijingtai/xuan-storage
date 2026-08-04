# 任务: storage-s1d-blobstore
负责: codex ｜ 分支: agent/codex/storage-s1d-blobstore ｜ 开工: 2026-08-04
状态: 蓝图

## 目标
在 drift、firebase 与内存层实现 core 的四个 blob 契约，完成 v9 schema 迁移、文件系统内容寻址/分块续传、加密解析、原子 UoW、staged/committed/GC 状态机，并以测试与四条既有门禁证明可用。

## 计划
- [ ] 阅读 S1d 设计稿、总纲、四个 core 契约及现有 S1b v8 迁移，列出实现边界与影响面。
- [ ] 清理上一轮 build_runner 产物，新增三张 drift blob 表、索引及 v9（仅追加 v8 后，不改旧分支）。
- [ ] 实现 LocalBlobStore 文件落盘、内容寻址、分块续传、UTC 往返与 staged/committed 状态。
- [ ] 实现 BlobCipher/BlobCipherResolver（异步 resolve）、RecordBlobUnitOfWork drift 与内存 fake。
- [ ] 实现 firebase BlobGateway，并补齐 GC：sourceOfTruth 归零转 orphaned、cache 才删除字节。
- [ ] 编写/修正迁移与契约测试，逐条完成变异自检并记录红灯证据。
- [ ] 运行 analyze、core/drift 测试及四条门禁，检查 diff 后提交全部改动。

## 验收标准
- [ ] 四个契约均有可运行实现，新增文件 `dart analyze --fatal-infos` 零 issue。
- [ ] v8→v9 三张表与索引存在，且 v1→v9 全链路迁移通过；不改 v8 及以前分支。
- [ ] blob 写入/读取字节一致、可从中断点续传、同内容不重复存储；DateTime 往返保持 `isUtc == true`。
- [ ] resolver `resolve` 为异步签名；identity cipher 返回已完成 Future。
- [ ] staged→committed 与 GC 符合裁定：sourceOfTruth 归零仅 orphaned 且保留字节，cache tier 才删除。
- [ ] diff 无任何既有 `REFERENCES` 外键删除；Web/P1/P2 不在本期实现。
- [ ] 每条测试完成变异自检并在决定记录写明注入点、预期红灯与复原结果。
- [ ] 四条既有门禁及 core/drift 测试全绿。
验收命令: bash scripts/run_s1a_analyze_gate.sh && bash scripts/run_s1b_analyze_gate.sh && bash scripts/run_monorepo_convention_check.sh && (cd core && flutter test) && (cd drift && flutter test)

## 当前状态
已暂停编码，当前保留 WIP：v9 三表迁移与 UTC converter 已提交；identity cipher 与内存 LocalBlobStore 位于 `drift/lib/blob/`，对应测试位于 `drift/test/blob/`。
下一步（恢复编码时第一件事）：先审查并完善内存 fake 的错误语义与 staged/committed/GC 测试，再实现文件系统 LocalBlobStore。
验证：v9 迁移 4/4 通过；identity cipher 与内存 fake 测试通过；完整门禁尚未运行。

## 决定记录
2026-08-04: schema 使用 v9，v8 及以前迁移保持不变，因为 S1b 已占用 v8。
2026-08-04: 本期不交付 Web blob 与 P1/P2 平台缺口，遵循人类裁定并仅记录残余风险。
2026-08-04: 仅修复新建 blob 三表的 DateTime UTC 语义，不顺手统一全仓，避免越界改动。
2026-08-04: GC 中 sourceOfTruth refCount 归零转 orphaned 但不删字节，只有 cache tier 真删，遵循收紧裁定。
2026-08-04: 不修改 core/lib/model 契约；实现全部放在具体后端与 fake 层，保持 core 零后端依赖。
2026-08-04: 旧 worktree 的 blob v8 产物仅作参考，不直接沿用，因为其缺少 main 上 D7 异步签名与 S1b v8。
2026-08-04: 用户要求本轮只制定 coding 计划并暂停编码；已将未完成实现作为 WIP 落盘，不宣称 S1d 已完成。

## 踩坑墓地
<只追加不删改。每次失败的尝试必须入墓, 一行一条:
日期: 尝试了X, 失败原因Y, 结论(别再试/换Z方向)。防止后任重蹈覆辙的负向记忆>

## 冷冻快照
<仅在搁置时由 /hibernate 填写: 业务背景 / 架构决定摘要 / 精确断点 / 重启第一步 / 环境要求>
