## ADDED Requirements

### Requirement: Resumable remote blob transfer
Firebase adapter SHALL 支持开始上传、乱序/重传 chunk、查询远端 chunk、完成校验、获取短期下载票据和删除对象，并在 capability timeout 内返回或失败。

#### Scenario: Resume remote upload
- **WHEN** 上传中断后重新查询同一 ticket
- **THEN** remoteChunks 返回已确认 index，客户端只上传缺失块

#### Scenario: Fresh download ticket
- **WHEN** 连续两次请求下载票据
- **THEN** adapter 每次访问服务端下架检查且不复用缓存票据
