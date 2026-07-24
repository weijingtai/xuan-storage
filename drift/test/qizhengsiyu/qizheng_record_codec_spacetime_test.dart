import 'dart:convert';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/qizhengsiyu/qizheng_record_codec.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

QiZhengSiYuPanContract _rec() {
  return QiZhengSiYuPanContract(
    uuid: 'q1',
    createdAt: DateTime.utc(2026),
    lastUpdatedAt: DateTime.utc(2026),
    deletedAt: null,
    divinationRequestInfoUuid: 'req-123',
    divinationDatetimeJson: const JsonEncoder.withIndent('').convert({
      'uuid': 'dt-1',
      'isDst': false,
      'isSeersLocation': false,
      'observer': {
        'type': '标准时间',
        'timezoneStr': 'Asia/Shanghai',
        'isManualCalibration': false,
        'coordinate': {
          'latitude': 39.9042,
          'longitude': 116.4074,
        },
        'location': {
          'address': {
            'countryName': '中国',
            'countryId': 45,
            'regionId': 9,
            'province': {
              'name': '北京市',
              'latitude': 39.9042,
              'longitude': 116.4074,
              'level': 1,
              'code': '110000',
              'parentCode': '0',
            },
            'city': {
              'name': '北京市',
              'latitude': 39.9042,
              'longitude': 116.4074,
              'code': '110100',
              'parentCode': '110000',
              'level': 2,
            },
            'timezone': 'Asia/Shanghai',
          },
        },
      },
      'datetime': '1990-01-01T12:00:00.000',
      'yearJiaZi': '己巳',
      'monthJiaZi': '丙子',
      'dayJiaZi': '甲子',
      'timeJiaZi': '庚午',
      'lunarMonth': 11,
      'lunarDay': 5,
      'jieQiInfo': {
        'jieQi': '立春',
        'startAt': '1990-01-01T00:00:00.000',
        'endAt': '1990-01-15T00:00:00.000',
      },
      'isLeapMonth': false,
    }),
    panelConfigJson: '{}',
    panelModelJson: '{}',
  );
}

void main() {
  final codec = QiZhengRecordCodec();

  setUpAll(() {
    tz_data.initializeTimeZones();
  });

  group('spacetime column fill', () {
    test('T-M4-FILL: encode fills all public spacetime columns (RED→GREEN)', () {
      final encoded = codec.encode(_rec(), scopeUid: 's1');
      final meta = encoded.meta;

      // occurredAtUtc: 1990-01-01 12:00 Asia/Shanghai = 1990-01-01 04:00 UTC
      expect(meta.occurredAtUtc, DateTime.utc(1990, 1, 1, 4, 0, 0));

      expect(meta.reckoningType, '标准时间');
      expect(meta.timezoneStr, 'Asia/Shanghai');
      expect(meta.latitude, closeTo(39.9042, 0.0001));
      expect(meta.longitude, closeTo(116.4074, 0.0001));
      expect(meta.locationName, '北京市');
      expect(meta.spacetimeJson, isNotNull);
      expect(meta.spacetimeJson, contains('1990-01-01T12:00:00.000'));
      expect(meta.spacetimeJson, contains('Asia/Shanghai'));
    });

    test('T-M4-ROUND: encode→decode round-trips by field', () {
      final encoded = codec.encode(_rec(), scopeUid: 's1');
      final decoded = codec.decode(encoded.meta, encoded.moduleData);

      expect(decoded.uuid, 'q1');
      expect(decoded.createdAt, DateTime.utc(2026));
      expect(decoded.lastUpdatedAt, DateTime.utc(2026));
      expect(decoded.deletedAt, isNull);
      expect(decoded.divinationRequestInfoUuid, 'req-123');
      expect(decoded.divinationDatetimeJson, _rec().divinationDatetimeJson);
      expect(decoded.panelConfigJson, '{}');
      expect(decoded.panelModelJson, '{}');
    });
  });
}
