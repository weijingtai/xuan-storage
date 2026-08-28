import 'dart:convert';
import 'package:meta/meta.dart';

/// Oplog streaming frame for P2P replication.
@immutable
final class OplogFrame {
  const OplogFrame({
    this.schemaVersion = 1,
    required this.operationId,
    required this.scopeUid,
    required this.entityType,
    required this.entityId,
    required this.opType,
    required this.payloadJson,
    required this.hlcPacked,
    required this.senderDeviceId,
    required this.signatureBase64,
  });

  final int schemaVersion;
  final String operationId;
  final String scopeUid;
  final String entityType;
  final String entityId;
  final String opType;
  final String payloadJson;
  final int hlcPacked;
  final String senderDeviceId;
  final String signatureBase64;

  /// Signature preimage bytes for verification:
  /// `UTF8("xuan-oplog-frame-v1\0") || UTF8("$schemaVersion\0$operationId\0$scopeUid\0$entityType\0$entityId\0$opType\0$hlcPacked\0$senderDeviceId\0") || UTF8(payloadJson)`
  List<int> computeSignaturePreimage() {
    final prefix = 'xuan-oplog-frame-v1\x00$schemaVersion\x00$operationId\x00$scopeUid\x00$entityType\x00$entityId\x00$opType\x00$hlcPacked\x00$senderDeviceId\x00';
    return utf8.encode(prefix + payloadJson);
  }

  Map<String, dynamic> toJson() => {
        'schema_version': schemaVersion,
        'operation_id': operationId,
        'scope_uid': scopeUid,
        'entity_type': entityType,
        'entity_id': entityId,
        'op_type': opType,
        'payload_json': payloadJson,
        'hlc_packed': hlcPacked,
        'sender_device_id': senderDeviceId,
        'signature': signatureBase64,
      };

  List<int> encode() {
    return utf8.encode(jsonEncode(toJson()));
  }

  factory OplogFrame.fromJson(Map<String, dynamic> json) {
    final version = json['schema_version'];
    if (version != 1) {
      throw FormatException('Unsupported OplogFrame schema version: $version (expected 1)');
    }
    return OplogFrame(
      schemaVersion: version as int,
      operationId: json['operation_id'] as String,
      scopeUid: json['scope_uid'] as String,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String,
      opType: json['op_type'] as String,
      payloadJson: json['payload_json'] as String,
      hlcPacked: json['hlc_packed'] as int,
      senderDeviceId: json['sender_device_id'] as String,
      signatureBase64: json['signature'] as String,
    );
  }

  factory OplogFrame.decode(List<int> bytes) {
    final string = utf8.decode(bytes);
    final json = jsonDecode(string);
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Malformed OplogFrame: expected JSON object');
    }
    return OplogFrame.fromJson(json);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OplogFrame &&
          runtimeType == other.runtimeType &&
          schemaVersion == other.schemaVersion &&
          operationId == other.operationId &&
          scopeUid == other.scopeUid &&
          entityType == other.entityType &&
          entityId == other.entityId &&
          opType == other.opType &&
          payloadJson == other.payloadJson &&
          hlcPacked == other.hlcPacked &&
          senderDeviceId == other.senderDeviceId &&
          signatureBase64 == other.signatureBase64;

  @override
  int get hashCode => Object.hash(
        schemaVersion,
        operationId,
        scopeUid,
        entityType,
        entityId,
        opType,
        payloadJson,
        hlcPacked,
        senderDeviceId,
        signatureBase64,
      );
}

/// Application ACK frame sent by receiver only after local Drift transaction commits.
@immutable
final class ApplicationAckFrame {
  const ApplicationAckFrame({
    this.schemaVersion = 1,
    required this.operationId,
    required this.receiverDeviceId,
    required this.committedHlcPacked,
    required this.signatureBase64,
  });

  final int schemaVersion;
  final String operationId;
  final String receiverDeviceId;
  final int committedHlcPacked;
  final String signatureBase64;

  /// Signature preimage bytes:
  /// `UTF8("xuan-app-ack-frame-v1\0") || UTF8("$schemaVersion\0$operationId\0$receiverDeviceId\0$committedHlcPacked")`
  List<int> computeSignaturePreimage() {
    return utf8.encode('xuan-app-ack-frame-v1\x00$schemaVersion\x00$operationId\x00$receiverDeviceId\x00$committedHlcPacked');
  }

  Map<String, dynamic> toJson() => {
        'schema_version': schemaVersion,
        'operation_id': operationId,
        'receiver_device_id': receiverDeviceId,
        'committed_hlc_packed': committedHlcPacked,
        'signature': signatureBase64,
      };

  List<int> encode() {
    return utf8.encode(jsonEncode(toJson()));
  }

  factory ApplicationAckFrame.fromJson(Map<String, dynamic> json) {
    final version = json['schema_version'];
    if (version != 1) {
      throw FormatException('Unsupported ApplicationAckFrame schema version: $version (expected 1)');
    }
    final opId = json['operation_id'];
    final devId = json['receiver_device_id'];
    final hlc = json['committed_hlc_packed'];
    final sig = json['signature'];
    if (opId is! String || devId is! String || hlc is! int || sig is! String) {
      throw const FormatException('Missing required fields in ApplicationAckFrame');
    }
    return ApplicationAckFrame(
      schemaVersion: version as int,
      operationId: opId,
      receiverDeviceId: devId,
      committedHlcPacked: hlc,
      signatureBase64: sig,
    );
  }

  factory ApplicationAckFrame.decode(List<int> bytes) {
    final string = utf8.decode(bytes);
    final json = jsonDecode(string);
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Malformed ApplicationAckFrame: expected JSON object');
    }
    return ApplicationAckFrame.fromJson(json);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplicationAckFrame &&
          runtimeType == other.runtimeType &&
          schemaVersion == other.schemaVersion &&
          operationId == other.operationId &&
          receiverDeviceId == other.receiverDeviceId &&
          committedHlcPacked == other.committedHlcPacked &&
          signatureBase64 == other.signatureBase64;

  @override
  int get hashCode => Object.hash(
        schemaVersion,
        operationId,
        receiverDeviceId,
        committedHlcPacked,
        signatureBase64,
      );
}
