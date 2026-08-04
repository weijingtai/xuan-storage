// ignore_for_file: lines_longer_than_80_chars

/// drift 后端持久化测试（验收 drift store 跨进程存活）。
///
/// 验证：drift installer 安装后，用「同一文件」新建 installer 实例
/// （模拟重启），active() 仍能查回，ensureInstalled 返回 alreadyCurrent
/// （不重新执行 .sql）。
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_assets/geo/drift/geo_database.dart';
import 'package:persistence_assets/geo/drift_dataset_installer.dart';
import 'package:persistence_assets/geo/geo_datasets.dart';
import 'package:persistence_core/persistence_core.dart';

const _kAssetFiles = {
  'packages/persistence_assets/lib/geo/admin_division.sql':
      'lib/geo/admin_division.sql',
  'packages/persistence_assets/lib/geo/region.sql': 'lib/geo/region.sql',
  'packages/persistence_assets/lib/geo/city.sql': 'lib/geo/city.sql',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late File dbFile;
  late GeoDatabase db;
  late DriftDatasetInstaller installer;

  setUp(() async {
    DatasetRegistry.clearForTesting();
    dbFile = File('/tmp/geo_test_${DateTime.now().microsecondsSinceEpoch}.sqlite');
    if (await dbFile.exists()) await dbFile.delete();
    db = GeoDatabase(NativeDatabase(dbFile));
    installer =
        DriftDatasetInstaller(db: db, bundledSource: const BundledDatasetSource());
    await _setupMockAssets();
    registerGeoDatasets(db: db);
  });

  tearDown(() async {
    await db.close();
    if (await dbFile.exists()) await dbFile.delete();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  test('drift store: 安装后 active() 返回 generation 0 + ready', () async {
    await installer.ensureInstalled('geo.admin_division');
    final active = await installer.active('geo.admin_division');
    expect(active, isNotNull);
    expect(active!.generation, 0);
    expect(active.status, DatasetGenerationStatus.ready);
    expect(active.actualRowCount, 3515);
  });

  test('drift store: 重启后（新实例同文件）active 仍在，ensureInstalled 返回 alreadyCurrent', () async {
    // 第一次安装
    await installer.ensureInstalled('geo.admin_division');

    // 模拟重启：关 db，用同一文件新建实例
    await db.close();
    db = GeoDatabase(NativeDatabase(dbFile));
    final restartedInstaller = DriftDatasetInstaller(
        db: db, bundledSource: const BundledDatasetSource());

    // active 仍在
    final active = await restartedInstaller.active('geo.admin_division');
    expect(active, isNotNull, reason: '重启后 active 应仍在');
    expect(active!.generation, 0);
    expect(active.status, DatasetGenerationStatus.ready);

    // ensureInstalled 返回 alreadyCurrent（不重新执行 .sql）
    final outcome = await restartedInstaller.ensureInstalled('geo.admin_division');
    expect(outcome, isA<InstallAlreadyCurrent>(),
        reason: '重启后应直接返回 alreadyCurrent，零解析');
  });

  test('drift store: 数据真实可查（GeoRepository 查北京市）', () async {
    await installer.ensureInstalled('geo.admin_division');
    final repo = GeoRepository(db);
    final beijing = await repo.getAdminDivisionByCode('110000');
    expect(beijing, isNotNull);
    expect(beijing!.name, '北京市');
  });

  test('drift store: generations() 列出全部世代', () async {
    await installer.ensureInstalled('geo.region');
    final gens = await installer.generations('geo.region');
    expect(gens.length, 1);
    expect(gens.first.generation, 0);
    expect(gens.first.status, DatasetGenerationStatus.ready);
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
