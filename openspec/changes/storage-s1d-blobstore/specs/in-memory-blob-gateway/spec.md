## ADDED Requirements

### Requirement: Contract-complete in-memory gateway
内存 BlobGateway fake SHALL 实现上传票据、乱序/重传 chunk、remoteChunks、complete、每次新下载票据、删除、取消和 capabilities，且不依赖 Firebase SDK。

#### Scenario: Resume in-memory upload
- **WHEN** 上传部分 chunk 后重新查询同一 ticket
- **THEN** remoteChunks 返回已持有 index，重传同 index 为幂等操作

#### Scenario: Incomplete upload is not downloadable
- **WHEN** ticket 尚未 complete
- **THEN** getDownloadTicket 拒绝返回可用下载票据
