## Context

字节采用文件系统、元数据采用 drift。逻辑 chunk 固定 16KB。现有 WIP 已创建 v9 三表，但必须在继续实现前修正 scope 主键、生成文件差异和两个未裁定的协议缺口。

## Goals / Non-Goals

**Goals:**
- 四个 core blob 端口均有真实可运行 adapter。
- 断点续传、内容去重、五态读取、UTC、事务性和 GC 有可变异验证的测试。
- sourceOfTruth 零引用只 orphaned，不被自动删除。

**Non-Goals:**
- Web blob、跨设备 refCount 收敛、真正的 private 密钥派生、xuan-shell 平台配置。

## Decisions

1. 数据库身份使用 `(scope_uid, cipher_manifest_id)`；chunk/ref 表也带 `scope_uid`，防止多账号公开同内容发生主键冲突。文件路径继续按 scope 隔离。
2. 文件写入采用临时文件 + flush + rename；只有 rename 成功后写 chunk 元数据。崩溃最多产生可回收文件孤儿，不产生数据库幽灵行。
3. `DriftRecordBlobUnitOfWork` 不调用会自行开事务的 `saveRecord()`；先从 `DriftRecordDataSource` 提取 transaction-aware 私有写原语，公开方法继续包事务，UoW 在同一外层事务复用原语并维护现有搜索索引语义。
4. GC 是独立 `DriftBlobGarbageCollector`，注入 UTC clock，由应用启动/空间压力调用；只删超时 staged、零引用 cache 和文件孤儿。sourceOfTruth 零引用更新为 orphaned。
5. public 使用 identity cipher；private resolver 由外部安全存储实现注入。默认 resolver 对 private 明确失败，不伪造加密。
6. 禁止使用 `plaintextSha256` 作为 private 远端对象名；public 对象名可等于 hash。

## Risks / Trade-offs

- [首次远端/P2P chunk 缺 tier/visibility] → core `putChunk` 无注册参数；实现前必须由人类选择前置 manifest 注册流程或允许修改契约。不得从 cipherId 猜 tier。
- [Firebase 无服务端签名协议] → 实现前必须确定 callable/REST client 接口、对象路径、票据 TTL 与下架检查。不得用客户端伪造签名 URL。
- [生成文件跨版本漂移] → 先恢复所有生成文件，再只生成主文件；逐 hunk 保留 blob 表相关块，门禁禁止删除任何 `REFERENCES`。
- [文件与 SQLite 非同一事务] → 先文件后元数据，GC 扫描孤儿；读取时交叉校验长度和 hash。

## Migration Plan

1. 从干净 v8 基线生成 v9 三表及索引。
2. 验证 fresh、v8→v9、v1→v9 和旧数据不丢。
3. 若 WIP 表主键已偏离本设计，在合并前重写 v9（尚未发布，无线上 v9 数据）。
4. 回滚代码时数据库保持 v9；旧应用不得打开新库，发布流程必须随 schemaVersion 同步。

## Open Questions

- **D1（阻塞 LocalBlobStore/P2P）**：首次只有 `BlobHandle` 的 `putChunk` 之前，谁负责持久化 tier/visibility？推荐新增后端内部 `stageIncomingManifest(handle, tier, visibility)` 编排步骤，但 core 当前没有该端口。
- **D2（阻塞 Firebase Gateway）**：直传协议由 Firebase Storage + Cloud Function、现有 REST 服务还是可注入测试 client 提供？需给出服务端端点与认证规则。
