## ADDED Requirements

### Requirement: Scoped durable blob storage
系统 SHALL 将 blob 字节存入 app-specific 文件目录，并以 scope、tier 和 manifest 隔离路径；相同 scope 的相同内容 SHALL 去重。

#### Scenario: Exact round trip and deduplication
- **WHEN** 同一 scope 两次写入相同字节
- **THEN** 返回相同内容身份且读取字节逐字节一致，磁盘只保存一份内容

### Requirement: Resumable verified chunks
系统 SHALL 以 16384 字节逻辑分块，记录每块长度与 hash，并允许乱序和重复写入。

#### Scenario: Resume after interruption
- **WHEN** 部分 chunk 落盘后操作取消并再次恢复
- **THEN** 已完成 chunk 保留且只需补齐缺失 chunk

### Requirement: Incoming manifests are policy derived
`stageIncomingManifest` SHALL 根据本地可信 entityType 查询 `StoragePolicyRegistry` 派生 visibility、tier 和 encryption，并 SHALL 拒绝未注册策略、非 blob carrier 或与对端声明不一致的请求。

#### Scenario: Forged private-to-resource declaration is rejected
- **WHEN** 本地策略为 private blob，但对端声明 visibility/tier 为 resource/cache
- **THEN** staging 被拒绝且数据库与文件系统均不产生新记录

### Requirement: Incomplete staged blobs are not readable
未完成的 staged blob SHALL 对普通读取、状态、大小和列表查询不可见，仅续传内部查询可以看到已持有 chunk。

#### Scenario: Staged partial bytes are hidden
- **WHEN** manifest 已 staged 且只有部分 chunk 落盘但尚未 complete
- **THEN** 普通 openRead/statusOf/sizeOf/list 不暴露可消费 blob，presentChunks 仍可供续传使用

### Requirement: Safe lifecycle and GC
系统 SHALL 只通过引用对账将 staged 转 committed；sourceOfTruth 零引用 SHALL 转 orphaned 且保留字节，cache 零引用才可删除。

#### Scenario: Source of truth becomes orphaned
- **WHEN** sourceOfTruth blob 的最后引用被移除并运行 GC
- **THEN** 元数据状态为 orphaned 且原字节仍可读取

#### Scenario: Cache is reclaimed
- **WHEN** 零引用 cache blob 被 GC 或容量逐出
- **THEN** 元数据与字节均被删除且 sourceOfTruth 不受影响

### Requirement: Five-state reads
系统 SHALL 区分 absent、partial、complete、corrupt 和 undecryptable，并让 openRead 返回对应 sealed 结果。

#### Scenario: Corrupt chunk is identified
- **WHEN** 已记录 chunk 的文件长度或 hash 不匹配
- **THEN** 返回 corrupt 并列出坏 chunk index
