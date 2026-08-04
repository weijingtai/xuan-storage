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
