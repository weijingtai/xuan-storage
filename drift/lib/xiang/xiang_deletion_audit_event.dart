/// 最小删除审计事件（FA12 单一方针）。
///
/// 只记录操作/时间/操作者与媒体引用计数，**不记录任何敏感内容**
/// （不记 refId、不记文本、不记媒体数据本身）。
class XiangDeletionAuditEvent {
  final String operation;
  final DateTime recordedAt;
  final String operatorUid;
  final int mediaRefCount;

  const XiangDeletionAuditEvent({
    required this.operation,
    required this.recordedAt,
    required this.operatorUid,
    required this.mediaRefCount,
  });
}
