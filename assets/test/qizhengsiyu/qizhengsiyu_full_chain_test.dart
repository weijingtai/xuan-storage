// ignore_for_file: lines_longer_than_80_chars

/// qizhengsiyu 域全链路测试（验收 A1-A3 + 全链路接通，照 geo_full_chain_test.dart）。
///
/// 验证完整链路：
///   registerQizhengDatasets -> DatasetInstaller.ensureInstalled
///   -> materializer 读 .sql asset + 执行进 drift 库
///   -> XrapQiZheng*Repository 查询出真实数据
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_assets/qizhengsiyu/drift/qizhengsiyu_database.dart';
import 'package:persistence_assets/qizhengsiyu/qizhengsiyu_datasets.dart';
import 'package:persistence_assets/qizhengsiyu/xrap_qizhengsiyu_repositories.dart';
import 'package:persistence_core/persistence_core.dart' hide StorageError;
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';

/// 测试用 asset 路径 -> 真实文件路径 映射。
const _kAssetFiles = {
  'packages/persistence_assets/lib/qizhengsiyu/assets/star_position_status.sql':
      'lib/qizhengsiyu/assets/star_position_status.sql',
  'packages/persistence_assets/lib/qizhengsiyu/assets/ge_ju.sql':
      'lib/qizhengsiyu/assets/ge_ju.sql',
  'packages/persistence_assets/lib/qizhengsiyu/assets/zhou_tian_document.sql':
      'lib/qizhengsiyu/assets/zhou_tian_document.sql',
  'packages/persistence_assets/lib/qizhengsiyu/assets/ephemeris_document.sql':
      'lib/qizhengsiyu/assets/ephemeris_document.sql',
  'packages/persistence_assets/lib/qizhengsiyu/assets/shen_sha_document.sql':
      'lib/qizhengsiyu/assets/shen_sha_document.sql',
  'packages/persistence_assets/lib/qizhengsiyu/assets/hua_yao_document.sql':
      'lib/qizhengsiyu/assets/hua_yao_document.sql',
  'packages/persistence_assets/lib/qizhengsiyu/assets/ge_ju_rules_document.sql':
      'lib/qizhengsiyu/assets/ge_ju_rules_document.sql',
  'packages/persistence_assets/lib/qizhengsiyu/assets/ge_ju_content_document.sql':
      'lib/qizhengsiyu/assets/ge_ju_content_document.sql',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late QizhengsiyuDatabase db;
  late InMemoryDatasetInstaller installer;

  setUp(() async {
    DatasetRegistry.clearForTesting();
    db = QizhengsiyuDatabase(NativeDatabase.memory());
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
    test('registerQizhengDatasets 后 8 个 id 均可 lookup', () {
      registerQizhengDatasets(db: db);
      expect(DatasetRegistry.all.length, 8);
      expect(DatasetRegistry.lookup('qizheng.star_position_status'), isNotNull);
      expect(DatasetRegistry.lookup('qizheng.ge_ju'), isNotNull);
      expect(DatasetRegistry.lookup('qizheng.zhou_tian'), isNotNull);
      expect(DatasetRegistry.lookup('qizheng.ephemeris'), isNotNull);
      expect(DatasetRegistry.lookup('qizheng.shen_sha'), isNotNull);
      expect(DatasetRegistry.lookup('qizheng.hua_yao'), isNotNull);
      expect(DatasetRegistry.lookup('qizheng.ge_ju_rules'), isNotNull);
      expect(DatasetRegistry.lookup('qizheng.ge_ju_content'), isNotNull);
    });
  });

  group('A2 全链路：ensureInstalled 把 .sql 灌进 drift 库', () {
    test('star_position_status 安装成功，行数自检 97', () async {
      registerQizhengDatasets(db: db);
      final outcome = await installer.ensureInstalled('qizheng.star_position_status');
      expect(outcome, isA<InstallInstalled>(),
          reason: '首次安装应返回 InstallInstalled');
      final installed = (outcome as InstallInstalled).installed;
      expect(installed.generation, 0);
      expect(installed.status, DatasetGenerationStatus.ready);
      expect(installed.actualRowCount, 97, reason: '行数自检应等于 97');
    });

    test('ge_ju 安装成功，行数自检 1005（5 表合计）', () async {
      registerQizhengDatasets(db: db);
      final outcome = await installer.ensureInstalled('qizheng.ge_ju');
      expect(outcome, isA<InstallInstalled>());
      expect((outcome as InstallInstalled).installed.actualRowCount, 1005);
    });

    test('zhou_tian 文档表安装成功，行数自检 3', () async {
      registerQizhengDatasets(db: db);
      final outcome = await installer.ensureInstalled('qizheng.zhou_tian');
      expect(outcome, isA<InstallInstalled>());
      expect((outcome as InstallInstalled).installed.actualRowCount, 3);
    });

    test('ephemeris 文档表安装成功，行数自检 17', () async {
      registerQizhengDatasets(db: db);
      final outcome = await installer.ensureInstalled('qizheng.ephemeris');
      expect(outcome, isA<InstallInstalled>());
      expect((outcome as InstallInstalled).installed.actualRowCount, 17);
    });

    test('重复 ensureInstalled 返回 alreadyCurrent（P4 零网络）', () async {
      registerQizhengDatasets(db: db);
      await installer.ensureInstalled('qizheng.star_position_status');
      final outcome = await installer.ensureInstalled('qizheng.star_position_status');
      expect(outcome, isA<InstallAlreadyCurrent>());
    });
  });

  group('A3 全链路：XrapQiZheng*Repository 真实查询（上层 -> SQLite -> .sql 数据）', () {
    setUp(() async {
      registerQizhengDatasets(db: db);
      await installer.ensureInstalled('qizheng.star_position_status');
      await installer.ensureInstalled('qizheng.zhou_tian');
      await installer.ensureInstalled('qizheng.ephemeris');
      await installer.ensureInstalled('qizheng.shen_sha');
      await installer.ensureInstalled('qizheng.hua_yao');
      await installer.ensureInstalled('qizheng.ge_ju_rules');
      await installer.ensureInstalled('qizheng.ge_ju_content');
    });

    test('星位庙旺状态：97 条，首条为果老/日/庙/戌', () async {
      final repo = XrapQiZhengStarPositionStatusRepository(
        db: db,
        installer: installer,
      );
      final list = await repo.loadStarPositionStatus();
      expect(list.length, 97);
      expect(list.first.raw['className'], '果老');
      expect(list.first.raw['star'], '日');
      expect(list.first.raw['starPositionStatusType'], '庙');
      expect(list.first.raw['positionList'], ['戌']);
    });

    test('周天模型：3 个，字段完整（gongDegreeSeq 非空）', () async {
      final repo = XrapQiZhengZhouTianModelRepository(
        db: db,
        installer: installer,
      );
      final models = await repo.loadBuiltInZhouTianModels();
      expect(models.length, 3);
      for (final m in models) {
        expect(m.raw['systemType'], isNotNull);
        expect(m.raw['gongDegreeSeq'], isA<List<dynamic>>());
      }
    });

    test('星历资源：按文件名取整段 JSON 字符串', () async {
      final repo = XrapQiZhengEphemerisResourceRepository(
        db: db,
        installer: installer,
      );
      final fourSeason = await repo.loadEphemerisResource('four_season.json');
      expect(fourSeason, contains('木星'));
      // 不存在的资源抛 StorageError（fail closed）
      expect(
        () => repo.loadEphemerisResource('no_such.json'),
        throwsA(isA<StorageError>()),
      );
    });

    test('神煞：天干神煞 15 条，首条禄勋/吉', () async {
      final repo = XrapQiZhengShenShaRepository(
        db: db,
        installer: installer,
      );
      final list = await repo.getTianGanShenSha();
      expect(list.length, 15);
      expect(list.first.raw['name'], '禄勋');
      expect(list.first.raw['jiXiong'], '吉');
    });

    test('化曜：天干化曜非空', () async {
      final repo = XrapQiZhengHuaYaoRepository(
        db: db,
        installer: installer,
      );
      final list = await repo.getTianGanHuaYao();
      expect(list, isNotEmpty);
    });

    test('格局 rules：loadBuiltInRules 返回全部规则（含日月夹命）', () async {
      final repo = XrapGeJuBuiltInDataSource(
        db: db,
        installer: installer,
      );
      final rules = await repo.loadBuiltInRules();
      expect(rules, isNotEmpty);
      expect(rules.any((r) => r.id == 'common_001_ri_yue_jia_ming'), isTrue,
          reason: '应能从文档表读到 common 规则');
    });

    test('格局 content：loadJsonFromAsset 按路径取回内容', () async {
      final repo = XrapGeJuBuiltInDataSource(
        db: db,
        installer: installer,
      );
      final content = await repo.loadJsonFromAsset(
        'assets/qizhengsiyu/ge_ju/content/common_ge_ju_content.json',
      );
      expect(content, isNotEmpty);
      expect(content.first['id'], isNotNull);
    });
  });

  group('A4 协议不变式', () {
    test('active() 在未安装时返回 null（fail closed）', () async {
      registerQizhengDatasets(db: db);
      final active = await installer.active('qizheng.star_position_status');
      expect(active, isNull);
    });

    test('未注册的 datasetId -> sourceUnavailable（fail closed）', () async {
      final outcome = await installer.ensureInstalled('qizheng.not_exist');
      expect(outcome, isA<InstallSourceUnavailable>());
    });
  });
}

/// 用 setMockMessageHandler 注入 .sql asset 内容到 rootBundle（照 geo 测试）。
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
    final key = utf8.decode(
        message!.buffer.asUint8List(message.offsetInBytes, message.lengthInBytes));
    final bytes = assetContents[key];
    if (bytes != null) {
      return ByteData.sublistView(bytes);
    }
    return null; // 未找到，让 rootBundle 抛 expected
  });
}
