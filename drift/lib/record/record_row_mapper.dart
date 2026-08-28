import 'dart:convert';

import 'package:repository_interface_record/repository_interface_record.dart';

/// RecordMeta ↔ 扁平行（L0 StorageDriver 数据形态）双向映射。
///
/// driver 与 EntityCodec 共用，保证「写入的行」与「读出的行」键名一致。
/// 行内键采用 snake_case 平铺；`_rev` 由 driver 维护，写路径的行
/// 不含 `_rev`（读路径才带），避免调用方伪造版本。
class RecordRowMapper {
  RecordRowMapper._();

  static DateTime? _dt(Object? v) =>
      v == null ? null : DateTime.parse(v as String).toUtc();

  static String? _iso(DateTime? v) => v?.toUtc().toIso8601String();

  static double? _num(Object? v) => v == null ? null : (v as num).toDouble();

  static String? _str(Object? v) => v == null ? null : '$v';

  /// RecordMeta → 扁平行。`_rev` 写为字符串。
  static Map<String, Object?> metaToRow(RecordMeta m) => {
    'id': m.uuid,
    'scope_uid': m.scopeUid,
    'module': m.module,
    'category': m.category,
    'divination_type': m.divinationType,
    'case_uuid': m.caseUuid,
    'work_item_uuid': m.workItemUuid,
    'seeker_uuid': m.seekerUuid,
    'question': m.question,
    'detail': m.detail,
    'tag': m.tag,
    'direct_predict': m.directPredict,
    'verification_status': m.verificationStatus,
    'seeker_name': m.seekerName,
    'gender': m.gender,
    'fate_year': m.fateYear,
    'occurred_at': _iso(m.occurredAtUtc),
    'reckoning_type': m.reckoningType,
    'timezone_str': m.timezoneStr,
    'latitude': m.latitude,
    'longitude': m.longitude,
    'location_name': m.locationName,
    'spacetime_json': m.spacetimeJson,
    'module_data': m.moduleDataJson,
    'nav_params_json': m.navParamsJson,
    'created_at': _iso(m.createdAt),
    'updated_at': _iso(m.updatedAt),
    'deleted_at': _iso(m.deletedAt),
    '_rev': '${m.rev}',
  };

  /// 扁平行 → RecordMeta。
  ///
  /// [fallbackRev]：写路径的行来自 codec.toMap，不含 `_rev`，
  /// 由 driver 计算出的新版本号回填；读路径的行自带 `_rev` 则优先。
  static RecordMeta rowToMeta(Map<String, Object?> row, {int fallbackRev = 1}) {
    final rawRev = row['_rev'];
    return RecordMeta(
      uuid: _str(row['id']) ?? '',
      scopeUid: _str(row['scope_uid']) ?? '',
      module: _str(row['module']) ?? '',
      category: _str(row['category']) ?? '',
      divinationType: _str(row['divination_type']) ?? '',
      caseUuid: _str(row['case_uuid']),
      workItemUuid: _str(row['work_item_uuid']),
      seekerUuid: _str(row['seeker_uuid']),
      question: _str(row['question']),
      detail: _str(row['detail']),
      tag: _str(row['tag']),
      directPredict: _str(row['direct_predict']),
      verificationStatus: _str(row['verification_status']),
      seekerName: _str(row['seeker_name']),
      gender: _str(row['gender']),
      fateYear: _str(row['fate_year']),
      occurredAtUtc: _dt(row['occurred_at']),
      reckoningType: _str(row['reckoning_type']),
      timezoneStr: _str(row['timezone_str']),
      latitude: _num(row['latitude']),
      longitude: _num(row['longitude']),
      locationName: _str(row['location_name']),
      spacetimeJson: _str(row['spacetime_json']),
      moduleDataJson: _str(row['module_data']),
      navParamsJson: _str(row['nav_params_json']),
      createdAt:
          _dt(row['created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      updatedAt: _dt(row['updated_at']),
      deletedAt: _dt(row['deleted_at']),
      rev: rawRev == null
          ? fallbackRev
          : int.tryParse('$rawRev') ?? fallbackRev,
    );
  }

  /// 取行中的模块数据（JSON 字符串 → Map），供 decode 使用。
  static Map<String, dynamic>? moduleDataOf(Map<String, Object?> row) {
    final s = row['module_data'];
    if (s == null) return null;
    try {
      final v = jsonDecode(s.toString());
      return v is Map ? Map<String, dynamic>.from(v) : null;
    } catch (_) {
      return null;
    }
  }
}
