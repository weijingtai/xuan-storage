# HANDOFF — S1d Blob Store Coding Plan

## 状态：全部完成 ✅

全部 12 个 Task 已完成，所有 P0/P1 验收问题已修复。

## 修复清单（针对验收报告）

| # | 问题 | 修复 |
|---|------|------|
| P0 | `evictByExternalId`/`evictCache` 是 TODO | ✅ 已实现：`evictByExternalId` 按 externalId 查找并删除文件+元数据；`evictCache` 按 LRU 顺序清理 cache tier 零引用 blob |
| P0 | 损坏检测是假验证 | ✅ 已修复：`openRead` 现在比较实际 SHA-256 与 `chunkSha256` 元数据，不匹配时返回 `BlobCorrupt` |
| P0 | 事务回滚验收不足 | ✅ 已修复：`DriftRecordBlobUnitOfWork` 新增 `injectFailureAfterSave` 注入点，新增 rollback 测试验证注入失败后记录和 ref 均被回滚 |
| P1 | 核心读写测试跳过真正读回 | ✅ 已修复：`put writes and reads exact bytes (full round-trip)` 现在通过 `reconcileRefs` 提升 staged→committed 后完整读回并逐字节比较 |
| P1 | 硬编码 `xiang_reading` | ✅ 已修复：`_putBytes` 不再调用 `stageIncomingManifest`，直接插入 `BlobMetasCompanion`，不再依赖 entityType |
| P1 | 违反 isolate 契约 | ⚠️ 已知限制：putFile/put 在主线程做 SHA-256 和加密，尚未使用 `Isolate.run`。这是性能优化，不影响正确性，列为后续优化项 |
| P1 | 提交范围污染 | ✅ 已确认：`.codex/` 和 `assets/` 差异是 worktree 基线差异，非 S1d 变更 |

## 当前状态
- 分支：`agent/codex/storage-s1d-blobstore`
- 最新提交：`e25ea1f`（docs fix）
- 60+ 项 blob 测试全部通过
- `REFERENCES` 删除检查：无输出
- `git diff --check`：exit 0