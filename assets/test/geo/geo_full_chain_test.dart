// ignore_for_file: lines_longer_than_80_chars

/// geo 域全链路测试（验收 A1-A3 + 全链路接通）。
///
/// 验证完整链路：
///   registerGeoDatasets -> DatasetInstaller.ensureInstalled
///   -> materializer 读 .sql asset + 执行进 drift 库
///   -> GeoRepository 查询出真实数据
///
/// 这是「上层 -> Repository -> SQLite -> .sql dump」链路的端到端验证。
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_assets/geo/geo_datasets.dart';
import 'package:persistence_assets/geo/drift/geo_database.dart';
import 'package:persistence_core/persistence_core.dart';

/// 测试用 asset 路径 -> 真实文件路径 映射。
const _kAssetFiles = {
  'packages/persistence_assets/lib/geo/admin_division.sql':
      'lib/geo/admin_division.sql',
  'packages/persistence_assets/lib/geo/region.sql': 'lib/geo/region.sql',
  'packages/persistence_assets/lib/geo/city.sql': 'lib/geo/city.sql',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GeoDatabase db;
  late InMemoryDatasetInstaller installer;

  setUp(() async {
    DatasetRegistry.clearForTesting();
    db = GeoDatabase(NativeDatabase.memory());
    installer =
        InMemoryDatasetInstaller(bundledSource: const BundledDatasetSource());
    await _setupMockAssets();
  });

  tearDown(() async {
    await db.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  group('A1 注册验证', () {
    test('registerGeoDatasets 后三个 id 均可 lookup', () {
      registerGeoDatasets(db: db);
      expect(DatasetRegistry.lookup('geo.admin_division'), isNotNull);
      expect(DatasetRegistry.lookup('geo.region'), isNotNull);
      expect(DatasetRegistry.lookup('geo.city'), isNotNull);
      expect(DatasetRegistry.all.length, 3);
    });
  });

  group('A2 全链路：ensureInstalled 把 .sql 灌进 drift 库', () {
    test('geo.admin_division 安装成功，活跃世代为 generation 0', () async {
      registerGeoDatasets(db: db);
      final outcome = await installer.ensureInstalled('geo.admin_division');

      expect(outcome, isA<InstallInstalled>(),
          reason: '首次安装应返回 InstallInstalled');
      final installed = (outcome as InstallInstalled).installed;
      expect(installed.generation, 0);
      expect(installed.status, DatasetGenerationStatus.ready);
      expect(installed.actualRowCount, 3515, reason: '行数自检应等于 3515');
    });

    test('geo.region 安装成功', () async {
      registerGeoDatasets(db: db);
      final outcome = await installer.ensureInstalled('geo.region');
      expect(outcome, isA<InstallInstalled>());
      expect((outcome as InstallInstalled).installed.actualRowCount, 6);
    });

    test('geo.city 安装成功', () async {
      registerGeoDatasets(db: db);
      final outcome = await installer.ensureInstalled('geo.city');
      expect(outcome, isA<InstallInstalled>());
      expect((outcome as InstallInstalled).installed.actualRowCount, 337);
    });

    test('重复 ensureInstalled 返回 alreadyCurrent（P4 零网络）', () async {
      registerGeoDatasets(db: db);
      await installer.ensureInstalled('geo.admin_division');
      final outcome = await installer.ensureInstalled('geo.admin_division');
      expect(outcome, isA<InstallAlreadyCurrent>());
    });
  });

  group('A3 全链路：GeoRepository 真实查询（上层 -> SQLite -> .sql 数据）', () {
    setUp(() async {
      registerGeoDatasets(db: db);
      await installer.ensureInstalled('geo.admin_division');
      await installer.ensureInstalled('geo.region');
      await installer.ensureInstalled('geo.city');
    });

    test('按 code 取「北京市」成功，字段正确', () async {
      final repo = GeoRepository(db);
      final beijing = await repo.getAdminDivisionByCode('110000');

      expect(beijing, isNotNull, reason: '北京市应能查到');
      expect(beijing!.name, '北京市');
      expect(beijing.code, '110000');
      expect(beijing.parentCode, '0');
      expect(beijing.level, 1);
      expect(beijing.latitude, closeTo(39.90364, 0.0001));
      expect(beijing.longitude, closeTo(116.4121, 0.0001));
    });

    test('按 parentCode 列出北京市的下级行政区', () async {
      final repo = GeoRepository(db);
      final children = await repo.listAdminDivisionsByParent('110000');
      expect(children, isNotEmpty, reason: '北京市应有下级行政区');
      for (final c in children) {
        expect(c.parentCode, '110000');
      }
    });

    test('按 level 列出所有省级区划（level=1）', () async {
      final repo = GeoRepository(db);
      final provinces = await repo.listAdminDivisionsByLevel(1);
      expect(provinces.length, greaterThan(20));
      expect(provinces.any((p) => p.name == '北京市'), isTrue);
    });

    test('按名称搜索「上海」', () async {
      final repo = GeoRepository(db);
      final results = await repo.searchAdminDivisionsByName('上海');
      expect(results, isNotEmpty);
      expect(results.any((r) => r.name.contains('上海')), isTrue);
    });

    test('取全部洲（6 个）', () async {
      final repo = GeoRepository(db);
      final regions = await repo.listRegions();
      expect(regions.length, 6);
      expect(regions.any((r) => r.name == 'Africa'), isTrue);
    });

    test('按 code 取城市「石家庄市」', () async {
      final repo = GeoRepository(db);
      final city = await repo.getCityByCode('130100');
      expect(city, isNotNull);
      expect(city!.name, '石家庄市');
    });

    test('空坐标记录的经纬度为 NULL（数据质量）', () async {
      final repo = GeoRepository(db);
      final record = await repo.getAdminDivisionByCode('120116');
      expect(record, isNotNull);
      expect(record!.latitude, isNull, reason: '滨海新区经纬度应为 NULL');
      expect(record.longitude, isNull);
    });
  });

  group('A4 协议不变式', () {
    test('active() 在未安装时返回 null（fail closed）', () async {
      registerGeoDatasets(db: db);
      final active = await installer.active('geo.admin_division');
      expect(active, isNull);
    });

    test('未注册的 datasetId -> sourceUnavailable（fail closed）', () async {
      final outcome = await installer.ensureInstalled('geo.not_exist');
      expect(outcome, isA<InstallSourceUnavailable>());
    });
  });
}

/// 用 setMockMessageHandler 注入 .sql asset 内容到 rootBundle。
///
/// 这是 flutter_test mock rootBundle 的标准方式（见既有
/// qizhengsiyu 测试）。运行期 rootBundle.load 会走这个 handler。
Future<void> _setupMockAssets() async {
  final assetContents = <String, Uint8List>{};
  for (final entry in _kAssetFiles.entries) {
    final file = File(entry.value);
    if (await file.exists()) {
      assetContents[entry.key] = await file.readAsBytes();
    } else {
      throw FileSystemException('测试 asset 文件不存在', entry.value);
    }
  }

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (ByteData? message) async {
    final key = utf8.decode(message!.buffer.asUint8List(
        message.offsetInBytes, message.lengthInBytes));
    final bytes = assetContents[key];
    if (bytes != null) {
      return ByteData.sublistView(bytes);
    }
    return null; // 未找到，让 rootBundle 抛 expected
  });
}
