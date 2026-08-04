## Why

S6 P2P、S2 公开分享和 S3a 导入导出均需要可恢复、可校验且不会误删用户原始媒体的 blob 落地能力。core 已冻结四个端口，但 drift/firebase 尚无完整实现，当前字节传输链没有可靠终点。

## What Changes

- 新增 drift schema v9 的 blob 元数据、chunk 和引用表，并保持 v8 及以前迁移不变。
- 新增原生文件系统字节后端和 drift 元数据后端，提供内容寻址、16KB 分块、续传和五态读取。
- 新增 identity cipher、异步 resolver 装配点、记录/blob 原子 UoW 和单设备 GC。
- 新增 Firebase BlobGateway adapter；其直传和签名 URL 协议必须在实现前由人类裁定。
- Web、跨设备引用计数和 xuan-shell 平台配置不在本期实现。

## Capabilities

### New Capabilities
- `local-blob-persistence`: 原生 blob 文件、元数据、续传、状态机、引用对账和 GC。
- `blob-cipher-resolution`: public identity cipher 与 private cipher 的异步解析边界。
- `record-blob-atomicity`: 记录写入/软删与 blob 引用在同一 drift 事务内提交。
- `remote-blob-gateway`: Firebase 远端分块上传、续传、完成、下载票据和删除适配。

### Modified Capabilities

无；core 契约保持冻结。

## Impact

主要影响 `drift/lib/blob/`、`drift/lib/persistence_drift.dart`、`drift/lib/record/`、`firebase/lib/blob/` 及对应测试。schema 从 v8 升到 v9；不修改 core 契约、不修改 v8 以前迁移、不交付 Web。
