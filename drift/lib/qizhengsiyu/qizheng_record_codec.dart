import 'dart:convert';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:timezone/timezone.dart' as tz;

class QiZhengRecordCodec implements RecordModuleCodec<QiZhengSiYuPanContract> {
  @override String get module => 'qizhengsiyu';
  @override String get category => 'divination';
  @override String get divinationType => 'qi_zheng';

  // ponytail: politicalCenter 枚举在当前依赖 metaphysics_core@41efe45 不存在，升级后添加
  static const _reckoningMap = {
    EnumDatetimeType.standard: '标准时间',
    EnumDatetimeType.removeDST: '移除夏令时',
    EnumDatetimeType.meanSolar: '平太阳时',
    EnumDatetimeType.trueSolar: '真太阳时',
  };

  static DateTime? _localToUtc(DateTime local, String tzStr) {
    final loc = tz.getLocation(tzStr);
    final tzDt = tz.TZDateTime(loc, local.year, local.month, local.day,
        local.hour, local.minute, local.second);
    return tzDt.toUtc();
  }

  @override String uuidOf(QiZhengSiYuPanContract c) => c.uuid;

  @override
  QiZhengSiYuPanContract withUuid(QiZhengSiYuPanContract c, String uuid) {
    return QiZhengSiYuPanContract(
      uuid: uuid,
      createdAt: c.createdAt,
      lastUpdatedAt: c.lastUpdatedAt,
      deletedAt: c.deletedAt,
      divinationRequestInfoUuid: c.divinationRequestInfoUuid,
      divinationDatetimeJson: c.divinationDatetimeJson,
      panelConfigJson: c.panelConfigJson,
      panelModelJson: c.panelModelJson,
    );
  }

  @override
  EncodedRecord encode(QiZhengSiYuPanContract c, {required String scopeUid}) {
    final data = <String, dynamic>{
      'divinationRequestInfoUuid': c.divinationRequestInfoUuid,
      'divinationDatetimeJson': c.divinationDatetimeJson,
      'panelConfigJson': c.panelConfigJson,
      'panelModelJson': c.panelModelJson,
    };

    String? reckoningType, timezoneStr, locationName, spacetimeJson;
    double? latitude, longitude;
    DateTime? occurredAtUtc;

    if (c.divinationDatetimeJson.isNotEmpty && c.divinationDatetimeJson != '{}') {
      try {
        final dt = DivinationDatetimeModel.fromJson(
          jsonDecode(c.divinationDatetimeJson) as Map<String, dynamic>,
        );
        final obs = dt.observer;
        spacetimeJson = c.divinationDatetimeJson;
        reckoningType = _reckoningMap[obs.type];
        timezoneStr = obs.timezoneStr.isNotEmpty ? obs.timezoneStr : null;

        if (obs.timezoneStr.isNotEmpty) {
          occurredAtUtc = _localToUtc(dt.datetime, obs.timezoneStr);
        }
        latitude = obs.coordinate?.latitude;
        longitude = obs.coordinate?.longitude;
        locationName = obs.location?.address?.formattedAddress;
      } catch (e) {
        // malformed or incompatible — public columns stay null
      }
    }

    final meta = RecordMeta(
      uuid: c.uuid, scopeUid: scopeUid, module: module, category: category,
      divinationType: divinationType,
      moduleDataJson: jsonEncode(data),
      navParamsJson: jsonEncode({'recordUuid': c.uuid}),
      occurredAtUtc: occurredAtUtc,
      reckoningType: reckoningType, timezoneStr: timezoneStr,
      latitude: latitude, longitude: longitude,
      locationName: locationName, spacetimeJson: spacetimeJson,
      gender: null,
      createdAt: c.createdAt, updatedAt: c.lastUpdatedAt,
      deletedAt: c.deletedAt, rev: 1,
    );
    return (meta: meta, moduleData: data);
  }

  @override
  QiZhengSiYuPanContract decode(RecordMeta meta, Map<String, dynamic>? moduleData) {
    if (meta.module != module) throw RecordCodecMismatch(message: 'module mismatch');
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
    return QiZhengSiYuPanContract(
      uuid: meta.uuid, createdAt: meta.createdAt,
      lastUpdatedAt: meta.updatedAt ?? meta.createdAt,
      deletedAt: meta.deletedAt,
      divinationRequestInfoUuid: d['divinationRequestInfoUuid'],
      divinationDatetimeJson: d['divinationDatetimeJson'],
      panelConfigJson: d['panelConfigJson'],
      panelModelJson: d['panelModelJson'],
    );
  }

  @override
  List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? moduleData) {
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
    final tags = <SearchTag>[];
    final requestUuid = d['divinationRequestInfoUuid'];
    if (requestUuid != null && '$requestUuid'.isNotEmpty) {
      tags.add(SearchTag('divination_request_info_uuid', '$requestUuid'));
    }
    return tags;
  }
}
