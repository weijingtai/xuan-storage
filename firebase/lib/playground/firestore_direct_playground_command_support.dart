/// Firestore 直写 command support —— 直写 adapter 共享的身份、hash、ID 与错误原语。
///
/// Design 文档：docs/superpowers/specs/2026-08-12-playground-firestore-direct-write-design.md
/// - §3 身份与公开/私有 payload 分离
/// - §8 幂等与确定性文档 ID
/// - §9 可观察错误合同
library;

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

/// 直写 actor —— 同时携带内部 app ID 与公开展示身份。
///
/// [ownerPayload] 与 [presentationPayload] 必须分开提供：
/// owner 文档只保存私有 owner 字段；公开文档只保存展示快照，绝不含
/// provider UID / canonical appUserId。
final class DirectWriteActor {
  final String providerUid;
  final String appUserId;
  final String publicPresentationId;
  final String publicDisplayAlias;
  final String? publicAvatarUrl;
  final String? publicProfileRef;

  const DirectWriteActor({
    required this.providerUid,
    required this.appUserId,
    required this.publicPresentationId,
    required this.publicDisplayAlias,
    this.publicAvatarUrl,
    this.publicProfileRef,
  });

  /// 私有 owner 文档 payload（§3.3）：content_id + provider_uid + app_user_id
  /// + public_presentation_id + created_at。不含公开 alias/avatar。
  Map<String, dynamic> ownerPayload({
    required String contentId,
    Object? createdAt,
  }) {
    return {
      'content_id': contentId,
      'provider_uid': providerUid,
      'app_user_id': appUserId,
      'public_presentation_id': publicPresentationId,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  /// 公开展示快照 payload（§3.2）：presentation_* 字段。
  /// 绝不含 provider_uid / app_user_id。
  Map<String, dynamic> presentationPayload({String? identityId}) {
    return {
      'presentation_mode': 'stableAlias',
      'presentation_identity_id': identityId ?? publicPresentationId,
      'presentation_display_alias': publicDisplayAlias,
      'presentation_avatar_url': publicAvatarUrl,
      'public_profile_ref': publicProfileRef,
    };
  }

  /// 公开展示快照 payload（one-time anonymous 变体）：
  /// alias 固定为产品文案“匿名用户”，avatar/profile-ref 必须为 null（§3.2）。
  Map<String, dynamic> oneTimeAnonymousPresentationPayload({
    required String identityId,
  }) {
    return {
      'presentation_mode': 'oneTimeAnonymous',
      'presentation_identity_id': identityId,
      'presentation_display_alias': '匿名用户',
      'presentation_avatar_url': null,
      'public_profile_ref': null,
    };
  }
}

/// 从当前认证 session 解析直写 actor（§3.1）。
///
/// 直读 Firestore `identity_map/{providerUid}`，不通过 callable；Playground
/// 不创建 identity_map。缺失 `app_user_id` / `public_presentation_id` /
/// `public_display_alias` 任一 → fail closed：`unavailable` + `identity/not-ready`。
Future<DirectWriteActor> requireDirectActor({
  required FirebaseFirestore firestore,
  required FirebaseAuth auth,
}) async {
  final user = auth.currentUser;
  if (user == null) {
    throw directPlaygroundError(
      code: PlaygroundErrorCode.unauthenticated,
      machineCode: 'auth/unauthenticated',
      message: '未登录，请先注册或匿名登录',
    );
  }

  final doc = await firestore.collection('identity_map').doc(user.uid).get();
  if (!doc.exists) {
    throw directPlaygroundError(
      code: PlaygroundErrorCode.unavailable,
      machineCode: 'identity/not-ready',
      message: '身份映射不存在，请完成账号初始化',
    );
  }

  final data = doc.data()!;
  final appUserId = _readString(data, 'app_user_id') ?? _readString(data, 'appUserId');
  final presentationId = _readString(data, 'public_presentation_id');
  final displayAlias = _readString(data, 'public_display_alias');

  if (appUserId == null || presentationId == null || displayAlias == null) {
    throw directPlaygroundError(
      code: PlaygroundErrorCode.unavailable,
      machineCode: 'identity/not-ready',
      message: '身份映射字段不完整，请完成账号初始化',
    );
  }

  return DirectWriteActor(
    providerUid: user.uid,
    appUserId: appUserId,
    publicPresentationId: presentationId,
    publicDisplayAlias: displayAlias,
    publicAvatarUrl: _readString(data, 'public_avatar_url'),
    publicProfileRef: _readString(data, 'public_profile_ref'),
  );
}

/// 计算 canonical JSON 的 SHA-256 hex（键顺序无关，§8）。
///
/// 对 map 按键排序、列表保序、bool/int/double/string 直接编码；
/// 时间不参与 payload hash（payload hash 不含时间字段，§8）。
String canonicalJsonHash(Object? payload) {
  final canonical = _canonicalize(payload);
  return sha256Hex(canonical);
}

/// SHA-256 hex 助手。
String sha256Hex(String input) {
  return sha256.convert(utf8.encode(input)).toString();
}

/// 确定性 create 文档 ID：`sha256(v1|operation|authUid|idempotencyKey)`（§8）。
String deterministicCreateId({
  required String operation,
  required String authUid,
  required String idempotencyKey,
}) {
  return sha256Hex('v1|$operation|$authUid|$idempotencyKey');
}

/// 构造带稳定 machineCode 的 [PlaygroundError]（§9）。
PlaygroundError directPlaygroundError({
  required PlaygroundErrorCode code,
  required String machineCode,
  String? message,
  Object? cause,
}) {
  return PlaygroundError(
    code: code,
    message: message ?? '操作失败',
    machineCode: machineCode,
    cause: cause,
  );
}

String? _readString(Map<String, dynamic> data, String key) {
  final value = data[key];
  if (value is String && value.isNotEmpty) return value;
  return null;
}

/// 键排序的 canonical 编码；结果作为 SHA-256 输入。
String _canonicalize(Object? value) {
  if (value == null) return 'null';
  if (value is Map) {
    final keys = value.keys.toList()
      ..sort((a, b) => _stringify(a).compareTo(_stringify(b)));
    final entries = keys
        .map((k) => '${jsonEncode(_stringify(k))}:${_canonicalize(value[k])}')
        .join(',');
    return '{$entries}';
  }
  if (value is List) {
    return '[${value.map(_canonicalize).join(',')}]';
  }
  if (value is String) {
    return jsonEncode(value);
  }
  if (value is bool) return value ? 'true' : 'false';
  if (value is num) return value.toString();
  // 其他类型（Timestamp 等）：以字符串化表示参与，保证确定性。
  return jsonEncode(value.toString());
}

String _stringify(Object key) {
  if (key is String) return key;
  return key.toString();
}
