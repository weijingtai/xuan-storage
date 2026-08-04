## Context

字节采用文件系统、元数据采用 drift。逻辑 chunk 固定 16KB。现有 WIP 已创建 v9 三表，但必须在继续实现前修正 scope 主键、生成文件差异和两个未裁定的协议缺口。

## Goals / Non-Goals

**Goals:**
- LocalBlobStore、BlobCipherResolver、RecordBlobUnitOfWork 有真实 adapter；BlobGateway 本轮提供契约完整的内存 fake。
- 断点续传、内容去重、五态读取、UTC、事务性和 GC 有可变异验证的测试。
- sourceOfTruth 零引用只 orphaned，不被自动删除。

**Non-Goals:**
- Web blob、跨设备 refCount 收敛、真正的 private 密钥派生、xuan-shell 平台配置。

## Decisions

1. 数据库身份使用 `(scope_uid, cipher_manifest_id)`；chunk/ref 表也带 `scope_uid`，防止多账号公开同内容发生主键冲突。文件路径继续按 scope 隔离。
2. drift concrete adapter 新增 `stageIncomingManifest`，但不修改 core。它接收本地可信 `entityType`，必须通过 `StoragePolicyRegistry.lookup` 派生 visibility、tier、encryption 和 blob carrier；未注册、非 blob carrier、对端声明不匹配均 fail closed。对端声明绝不能决定策略。
3. 未 complete 的 staged blob 对普通读路径不可见：`openRead/statusOf/sizeOf/list` 不返回可消费数据；仅传输恢复内部 API 可查询已持有 chunk。
4. 文件写入采用临时文件 + flush + rename；只有 rename 成功后写 chunk 元数据。崩溃最多产生可回收文件孤儿，不产生数据库幽灵行。
5. `DriftRecordBlobUnitOfWork` 不调用会自行开事务的 `saveRecord()`；先从 `DriftRecordDataSource` 提取 transaction-aware 私有写原语，公开方法继续包事务，UoW 在同一外层事务复用原语并维护现有搜索索引语义。
6. GC 是独立 `DriftBlobGarbageCollector`，注入 UTC clock，由应用启动/空间压力调用；只删超时 staged、零引用 cache 和文件孤儿。sourceOfTruth 零引用更新为 orphaned。
7. public 使用 identity cipher；private resolver 由外部安全存储实现注入。默认 resolver 对 private 明确失败，不伪造加密。
8. 本轮 BlobGateway 仅交付内存 fake；真实 Firebase/云端实现延后到 S2-blob，不添加 `firebase_storage`、`cloud_functions` 或自建分块协议。

## Risks / Trade-offs

- [对端伪造策略声明] → `stageIncomingManifest` 只信任本地 registry，并以伪造 private→resource 声明负测试证明 fail closed。
- [staged 数据提前曝光] → 普通读面过滤未 complete staged，独立测试证明 partial/staged 只能供恢复 API 使用。
- [生成文件跨版本漂移] → 先恢复所有生成文件，再只生成主文件；逐 hunk 保留 blob 表相关块，门禁禁止删除任何 `REFERENCES`。
- [文件与 SQLite 非同一事务] → 先文件后元数据，GC 扫描孤儿；读取时交叉校验长度和 hash。

## Migration Plan

1. 从干净 v8 基线生成 v9 三表及索引。
2. 验证 fresh、v8→v9、v1→v9 和旧数据不丢。
3. 若 WIP 表主键已偏离本设计，在合并前重写 v9（尚未发布，无线上 v9 数据）。
4. 回滚代码时数据库保持 v9；旧应用不得打开新库，发布流程必须随 schemaVersion 同步。

## Open Questions

无本轮阻塞问题。云端对象存储选型与原 D2 延后到 S2-blob。
