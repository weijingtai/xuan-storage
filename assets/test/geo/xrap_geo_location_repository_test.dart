// ignore_for_file: lines_longer_than_80_chars

/// XrapGeoLocationRepository 全链路测试。
///
/// 验证：通过 GeoLocationRepository 接口（time-location 定义），
/// XrapGeoLocationRepository 实现（persistence_assets），查到真实数据。
/// 这模拟了 MVVM -> Repository(接口) -> XRAP 实现 -> drift -> *.sql 的完整链路。
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/datamodel/geo_location.dart';
import 'package:persistence_assets/geo/drift/geo_database.dart';
import 'package:persistence_assets/geo/drift_dataset_installer.dart';
import 'package:persistence_assets/geo/geo_datasets.dart';
import 'package:persistence_assets/geo/xrap_geo_location_repository.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:xuan_time_location/xuan_time_location.dart';

const _kAssetFiles = {
  'packages/persistence_assets/lib/geo/admin_division.sql':
      'lib/geo/admin_division.sql',
  'packages/persistence_assets/lib/geo/region.sql': 'lib/geo/region.sql',
  'packages/persistence_assets/lib/geo/city.sql': 'lib/geo/city.sql',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GeoDatabase db;
  late DriftDatasetInstaller installer;
  late GeoLocationRepository repo; // 接口类型

  setUp(() async {
    DatasetRegistry.clearForTesting();
    db = GeoDatabase(NativeDatabase.memory());
    installer =
        DriftDatasetInstaller(db: db, bundledSource: const BundledDatasetSource());
    await _setupMockAssets();
    registerGeoDatasets(db: db);
    // 接口类型注入 XRAP 实现（shell DI 模拟）
    repo = XrapGeoLocationRepository(db: db, installer: installer);
  });

  tearDown(() async {
    await db.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  test('通过 GeoLocationRepository 接口查「北京市」', () async {
    final beijing = await repo.getLocationByCode('110000');
    expect(beijing, isNotNull);
    expect(beijing!.name, '北京市');
    expect(beijing.code, '110000');
    expect(beijing.level, GeoLevel.province);
  });

  test('listCitiesByProvince：列出北京市的下级', () async {
    final children = await repo.listCitiesByProvince('110000');
    expect(children, isNotEmpty);
    for (final c in children) {
      expect(c.parentCode, '110000');
    }
  });

  test('listAllByLevel：省级 >20 个', () async {
    final provinces = await repo.listAllByLevel(GeoLevel.province);
    expect(provinces.length, greaterThan(20));
    expect(provinces.any((p) => p.name == '北京市'), isTrue);
  });

  test('searchLocationsByName：搜「上海」', () async {
    final results = await repo.searchLocationsByName('上海');
    expect(results, isNotEmpty);
    expect(results.any((r) => r.name.contains('上海')), isTrue);
  });

  test('getFullAddressPath：北京市的完整路径', () async {
    // 110000 是北京市（省级），路径就是「北京市」
    final path = await repo.getFullAddressPath('110000');
    expect(path, '北京市');
  });

  test('getChildLocations：列出某 code 的子级', () async {
    final children = await repo.getChildLocations('110000');
    expect(children, isNotEmpty);
  });
}

Future<void> _setupMockAssets() async {
  final assetContents = <String, Uint8List>{};
  for (final entry in _kAssetFiles.entries) {
    final file = File(entry.value);
    if (await file.exists()) {
      assetContents[entry.key] = await file.readAsBytes();
    }
  }
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (ByteData? message) async {
    final key = utf8.decode(
        message!.buffer.asUint8List(message.offsetInBytes, message.lengthInBytes));
    final bytes = assetContents[key];
    if (bytes != null) return ByteData.sublistView(bytes);
    return null;
  });
}
