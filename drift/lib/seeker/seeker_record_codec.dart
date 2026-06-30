import 'dart:convert';
import 'package:metaphysics_core/datamodel/seeker_model.dart';
import 'package:metaphysics_core/datamodel/location.dart';
import 'package:metaphysics_core/enums/enum_gender.dart';
import 'package:metaphysics_core/enums/enum_datetime_type.dart';
import 'package:metaphysics_core/enums/enum_jia_zi.dart';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:repository_interface_record/repository_interface_record.dart';

class SeekerRecordCodec implements RecordModuleCodec<SeekerModel> {
  @override String get module => 'seeker';
  @override String get category => 'person';
  @override String get divinationType => '';

  @override String uuidOf(SeekerModel c) => c.uuid;

  @override
  SeekerModel withUuid(SeekerModel c, String uuid) {
    return SeekerModel(
      uuid: uuid,
      username: c.username,
      nickname: c.nickname,
      gender: c.gender,
      timingType: c.timingType,
      datetime: c.datetime,
      yearGanZhi: c.yearGanZhi,
      monthGanZhi: c.monthGanZhi,
      dayGanZhi: c.dayGanZhi,
      timeGanZhi: c.timeGanZhi,
      lunarMonth: c.lunarMonth,
      isLeapMonth: c.isLeapMonth,
      lunarDay: c.lunarDay,
      createdAt: c.createdAt,
      lastUpdatedAt: c.lastUpdatedAt,
      deletedAt: c.deletedAt,
      location: c.location,
      timingInfoUuid: c.timingInfoUuid,
      timingInfoListJson: c.timingInfoListJson,
      divinationUuid: c.divinationUuid,
    );
  }

  @override
  EncodedRecord encode(SeekerModel c, {required String scopeUid}) {
    final data = <String, dynamic>{
      'username': c.username,
      'nickname': c.nickname,
      'gender': c.gender.name,
      'timingType': c.timingType.name,
      'datetime': c.datetime.toIso8601String(),
      'yearGanZhi': c.yearGanZhi.name,
      'monthGanZhi': c.monthGanZhi.name,
      'dayGanZhi': c.dayGanZhi.name,
      'timeGanZhi': c.timeGanZhi.name,
      'lunarMonth': c.lunarMonth,
      'isLeapMonth': c.isLeapMonth,
      'lunarDay': c.lunarDay,
      'timingInfoUuid': c.timingInfoUuid,
    };
    data['location'] = c.location?.toJson();
    data['timingInfoListJson'] = c.timingInfoListJson?.map((e) => e.toJson()).toList();
    final meta = RecordMeta(
      uuid: c.uuid, scopeUid: scopeUid, module: module, category: category,
      divinationType: divinationType, seekerName: c.nickname ?? c.username,
      gender: c.gender.name, fateYear: null,
      moduleDataJson: jsonEncode(data),
      navParamsJson: jsonEncode({'recordUuid': c.uuid}),
      createdAt: c.createdAt, updatedAt: c.lastUpdatedAt,
      deletedAt: c.deletedAt, rev: 1,
    );
    return (meta: meta, moduleData: data);
  }

  @override
  SeekerModel decode(RecordMeta meta, Map<String, dynamic>? moduleData) {
    if (meta.module != module) throw RecordCodecMismatch(message: 'module mismatch');
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) as Map<String, dynamic> : <String, dynamic>{});
    final locRaw = d['location'];
    final location = locRaw != null ? Location.fromJson(locRaw as Map<String, dynamic>) : null;
    List<DivinationDatetimeModel>? timingInfoList;
    if (d['timingInfoListJson'] != null) {
      timingInfoList = (d['timingInfoListJson'] as List<dynamic>)
          .map((e) => DivinationDatetimeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return SeekerModel(
      uuid: meta.uuid,
      username: d['username'] as String?,
      nickname: d['nickname'] as String? ?? meta.seekerName,
      gender: Gender.values.firstWhere((g) => g.name == (d['gender'] ?? meta.gender)),
      timingType: DateTimeType.values.firstWhere((t) => t.name == d['timingType']),
      datetime: DateTime.parse(d['datetime'] as String),
      yearGanZhi: JiaZi.values.firstWhere((j) => j.name == d['yearGanZhi']),
      monthGanZhi: JiaZi.values.firstWhere((j) => j.name == d['monthGanZhi']),
      dayGanZhi: JiaZi.values.firstWhere((j) => j.name == d['dayGanZhi']),
      timeGanZhi: JiaZi.values.firstWhere((j) => j.name == d['timeGanZhi']),
      lunarMonth: d['lunarMonth'] as int,
      isLeapMonth: d['isLeapMonth'] as bool? ?? false,
      lunarDay: d['lunarDay'] as int,
      timingInfoUuid: d['timingInfoUuid'] as String?,
      location: location,
      timingInfoListJson: timingInfoList,
      createdAt: meta.createdAt,
      lastUpdatedAt: meta.updatedAt,
      deletedAt: meta.deletedAt,
      divinationUuid: null,
    );
  }

  @override
  List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? moduleData) {
    final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) as Map<String, dynamic> : <String, dynamic>{});
    return [
      if (meta.seekerName != null) SearchTag('seeker_name', meta.seekerName!),
      if (meta.gender != null) SearchTag('gender', meta.gender!),
      if (d['lunarMonth'] != null) SearchTag('lunar_month', '${d['lunarMonth']}'),
    ];
  }
}
