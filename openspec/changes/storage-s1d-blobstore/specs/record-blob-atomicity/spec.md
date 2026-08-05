## ADDED Requirements

### Requirement: Atomic record and blob references
记录保存/软删与引用集替换 SHALL 在同一个 drift transaction 内完成，任何一步失败 SHALL 全部回滚。

#### Scenario: Reference write fails
- **WHEN** 保存记录成功后引用写入被注入失败
- **THEN** 记录、搜索索引和引用表均保持事务前状态

#### Scenario: Reconciliation is idempotent
- **WHEN** 同一 owner 连续提交相同完整引用集
- **THEN** 引用行数和 refCount 不累加
