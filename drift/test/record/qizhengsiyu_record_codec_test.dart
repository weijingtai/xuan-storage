import 'dart:convert';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/qizhengsiyu/qizheng_record_codec.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

String _fixtureDatetimeJson() {
  return const JsonEncoder.withIndent('').convert({
    'uuid': 'dt-1',
    'isDst': false,
    'isSeersLocation': false,
    'observer': {
      'type': '标准时间',
      'timezoneStr': 'Asia/Shanghai',
      'isManualCalibration': false,
      'coordinate': {'latitude': 39.9042, 'longitude': 116.4074},
      'location': {
        'address': {
          'countryName': '中国',
          'countryId': 45,
          'regionId': 9,
          'province': {
            'name': '北京市', 'latitude': 39.9042, 'longitude': 116.4074,
            'level': 1, 'code': '110000', 'parentCode': '0',
          },
          'city': {
            'name': '北京市', 'latitude': 39.9042, 'longitude': 116.4074,
            'code': '110100', 'parentCode': '110000', 'level': 2,
          },
          'timezone': 'Asia/Shanghai',
        },
      },
    },
    'datetime': '1990-01-01T12:00:00.000',
    'yearJiaZi': '己巳', 'monthJiaZi': '丙子',
    'dayJiaZi': '甲子', 'timeJiaZi': '庚午',
    'lunarMonth': 11, 'lunarDay': 5,
    'jieQiInfo': {
      'jieQi': '立春',
      'startAt': '1990-01-01T00:00:00.000',
      'endAt': '1990-01-15T00:00:00.000',
    },
    'isLeapMonth': false,
  });
}

QiZhengSiYuPanContract _rec({String uuid = 'q1', String reqUuid = 'req-123'}) => QiZhengSiYuPanContract(
      uuid: uuid,
      createdAt: DateTime.utc(2026),
      lastUpdatedAt: DateTime.utc(2026),
      deletedAt: null,
      divinationRequestInfoUuid: reqUuid,
      divinationDatetimeJson: _fixtureDatetimeJson(),
      panelConfigJson: '{}',
      panelModelJson: '{}',
    );

void main() {
  setUpAll(() => tz_data.initializeTimeZones());
  final codec = QiZhengRecordCodec();

  test('encode then decode round-trips the contract', () {
    final encoded = codec.encode(_rec(), scopeUid: 's1');
    expect(encoded.meta.module, 'qizhengsiyu');
    expect(encoded.meta.scopeUid, 's1');
    expect(encoded.meta.category, 'divination');
    expect(encoded.meta.divinationType, 'qi_zheng');

    final decoded = codec.decode(encoded.meta, encoded.moduleData);
    expect(decoded, equals(_rec()));
  });

  test('decode with mismatched module throws', () {
    final encoded = codec.encode(_rec(), scopeUid: 's1');
    final badMeta = RecordMeta(
      uuid: encoded.meta.uuid,
      scopeUid: encoded.meta.scopeUid,
      module: 'mismatched',
      category: encoded.meta.category,
      divinationType: encoded.meta.divinationType,
      createdAt: encoded.meta.createdAt,
    );
    expect(() => codec.decode(badMeta, encoded.moduleData), throwsA(isA<RecordCodecMismatch>()));
  });

  test('extractSearchTags emits divinationRequestInfoUuid', () {
    final encoded = codec.encode(_rec(), scopeUid: 's1');
    final tags = codec.extractSearchTags(encoded.meta, encoded.moduleData);
    expect(tags, contains(const SearchTag('divination_request_info_uuid', 'req-123')));
  });

  test('uuidOf and withUuid operations', () {
    final r = _rec();
    expect(codec.uuidOf(r), 'q1');
    final r2 = codec.withUuid(r, 'q2');
    expect(codec.uuidOf(r2), 'q2');
    expect(r2.divinationRequestInfoUuid, 'req-123');
  });
}
