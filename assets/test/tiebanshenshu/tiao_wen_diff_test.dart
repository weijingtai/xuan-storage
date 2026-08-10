// ignore_for_file: lines_longer_than_80_chars

/// tiebanshenshu 差分一致性测试：旧桩 `AssetsTiaoWenRepository`（CSV 直读）
/// vs XRAP `XrapTiaoWenRepository`（drift SQL，XRAP 协议）行为对齐。
///
/// 同一组查询（11 方法全覆盖）分别在两条链路上执行，逐条比对输出。
/// 这是「xuan-shell 与 example 运行结果一致」的机器证明：
/// 两者都消费同一个 XRAP 数据集，此处证明 XRAP 与旧桩语义等价。
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:persistence_assets/persistence_assets.dart';
import 'package:persistence_assets/tiebanshenshu/drift/tiebanshenshu_database.dart';
import 'package:persistence_assets/tiebanshenshu/tiebanshenshu_datasets.dart';
import 'package:persistence_assets/tiebanshenshu/xrap_tiebanshenshu_repositories.dart';
import 'package:persistence_core/persistence_core.dart' hide StorageError;
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';

/// 旧桩读取的 asset 路径（rootBundle 形态）→ 测试工作目录下的真实文件。
const _kCsvAssetPath =
    'packages/persistence_assets/lib/tiebanshenshu/assets/all_tiao_wen_v1.csv';
const _kCsvFilePath = 'lib/tiebanshenshu/assets/all_tiao_wen_v1.csv';
const _kTiaoWenSqlAssetPath =
    'packages/persistence_assets/lib/tiebanshenshu/assets/tiao_wen.sql';
const _kTiaoWenSqlFilePath = 'lib/tiebanshenshu/assets/tiao_wen.sql';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TiebanshenshuDatabase db;
  late XrapTiaoWenRepository xrapRepo;
  late AssetsTiaoWenRepository legacyRepo;

  setUp(() async {
    DatasetRegistry.clearForTesting();
    AssetsTiaoWenRepository.clearCache();
    db = TiebanshenshuDatabase(NativeDatabase.memory());
    registerTiebanshenshuDatasets(db: db);
    final installer = TiebanshenshuDriftDatasetInstaller(
      db: db,
      bundledSource: const BundledDatasetSource(),
    );
    xrapRepo = XrapTiaoWenRepository(db: db, installer: installer);
    legacyRepo = AssetsTiaoWenRepository(dataPath: _kCsvAssetPath);
    await _setupMockAssets();
  });

  tearDown(() async {
    await db.close();
    AssetsTiaoWenRepository.clearCache();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  group('差分一致性：旧桩 CSV 直读 vs XRAP drift SQL', () {
    test('getById 一致（含 ageSet1 解析）', () async {
      for (final id in [1001, 1002, 12000, 5000]) {
        final legacy = await legacyRepo.getById(id);
        final xrap = await xrapRepo.getById(id);
        expect(_norm(legacy), _norm(xrap), reason: 'getById($id) 应一致');
      }
    });

    test('getById 不存在 ID 一致返回 null', () async {
      expect(await legacyRepo.getById(99999), isNull);
      expect(await xrapRepo.getById(99999), isNull);
    });

    test('getByIdsWithPageRange 一致', () async {
      final ids = List<int>.generate(300, (i) => 1001 + i);
      final legacy = await legacyRepo.getByIdsWithPageRange(
        ids: ids,
        pageRange: [10, 200],
        steps: 3,
      );
      final xrap = await xrapRepo.getByIdsWithPageRange(
        ids: ids,
        pageRange: [10, 200],
        steps: 3,
      );
      expect(_normList(xrap), _normList(legacy),
          reason: 'getByIdsWithPageRange 应一致');
    });

    test('listAll 一致（12000 行全量）', () async {
      final legacy = await legacyRepo.listAll();
      final xrap = await xrapRepo.listAll();
      expect(xrap.length, 12000);
      expect(legacy.length, 12000);
      expect(_normList(xrap), _normList(legacy), reason: 'listAll 应一致');
    });

    test('search 按地支一致', () async {
      for (final setName in ['子', '丑', '午', '亥']) {
        final legacy = await legacyRepo.search(setName: setName);
        final xrap = await xrapRepo.search(setName: setName);
        expect(_normList(xrap), _normList(legacy),
            reason: 'search(setName=$setName) 应一致');
      }
    });

    test('search 按内容关键词一致', () async {
      for (final kw in ['一树残花', '自立门户', '帝座']) {
        final legacy = await legacyRepo.search(contentKeyword: kw);
        final xrap = await xrapRepo.search(contentKeyword: kw);
        expect(_normList(xrap), _normList(legacy),
            reason: 'search(contentKeyword=$kw) 应一致');
      }
    });

    test('search 未知地支一致返回空列表', () async {
      expect(await legacyRepo.search(setName: '不存在的地支'), isEmpty);
      expect(await xrapRepo.search(setName: '不存在的地支'), isEmpty);
    });

    test('getCount 一致（12000）', () async {
      expect(await legacyRepo.getCount(), 12000);
      expect(await xrapRepo.getCount(), 12000);
    });

    test('getAroundById 一致（含 includeCenterItem）', () async {
      final legacy = await legacyRepo.getAroundById(
        centerId: 5000,
        beforeCount: 5,
        afterCount: 8,
      );
      final xrap = await xrapRepo.getAroundById(
        centerId: 5000,
        beforeCount: 5,
        afterCount: 8,
      );
      expect(_normList(xrap), _normList(legacy), reason: 'getAroundById 应一致');

      final legacyNoCenter = await legacyRepo.getAroundById(
        centerId: 5000,
        beforeCount: 3,
        afterCount: 3,
        includeCenterItem: false,
      );
      final xrapNoCenter = await xrapRepo.getAroundById(
        centerId: 5000,
        beforeCount: 3,
        afterCount: 3,
        includeCenterItem: false,
      );
      expect(_normList(xrapNoCenter), _normList(legacyNoCenter),
          reason: 'getAroundById(includeCenterItem=false) 应一致');
    });

    test('getByIntervalAroundId 一致', () async {
      final legacy = await legacyRepo.getByIntervalAroundId(
        centerId: 3000,
        interval: 7,
        minCount: 10,
      );
      final xrap = await xrapRepo.getByIntervalAroundId(
        centerId: 3000,
        interval: 7,
        minCount: 10,
      );
      expect(_normList(xrap), _normList(legacy),
          reason: 'getByIntervalAroundId 应一致');
    });

    test('getByIdRange 一致', () async {
      final legacy = await legacyRepo.getByIdRange(startId: 1001, endId: 1500);
      final xrap = await xrapRepo.getByIdRange(startId: 1001, endId: 1500);
      expect(_normList(xrap), _normList(legacy), reason: 'getByIdRange 应一致');
    });

    test('getByIdList 一致（preserveOrder 两种模式）', () async {
      final ids = [1001, 1003, 1002, 99999, 1001];
      final legacy = await legacyRepo.getByIdList(
        queryList: ids,
        preserveOrder: true,
        skipNotFound: true,
      );
      final xrap = await xrapRepo.getByIdList(
        queryList: ids,
        preserveOrder: true,
        skipNotFound: true,
      );
      expect(_normList(xrap), _normList(legacy),
          reason: 'getByIdList(preserveOrder=true) 应一致');

      final legacy2 = await legacyRepo.getByIdList(
        queryList: ids,
        preserveOrder: false,
        skipNotFound: true,
      );
      final xrap2 = await xrapRepo.getByIdList(
        queryList: ids,
        preserveOrder: false,
        skipNotFound: true,
      );
      expect(_normList(xrap2), _normList(legacy2),
          reason: 'getByIdList(preserveOrder=false) 应一致');
    });

    test('getTiaoWenContentByNumbers / ByNumber 一致', () async {
      final nums = [1001, 1002, 99999];
      final legacyMap = await legacyRepo.getTiaoWenContentByNumbers(nums);
      final xrapMap = await xrapRepo.getTiaoWenContentByNumbers(nums);
      expect(xrapMap, legacyMap, reason: 'getTiaoWenContentByNumbers 应一致');

      expect(await legacyRepo.getTiaoWenContentByNumber(1001),
          await xrapRepo.getTiaoWenContentByNumber(1001));
      expect(await legacyRepo.getTiaoWenContentByNumber(99999),
          await xrapRepo.getTiaoWenContentByNumber(99999));
    });

    test('ageSet1 空值一致（无 ageSet 行 ageSet1 为 null）', () async {
      // 1002 在 INVENTORY 中是 3 列无 ageSet 的示例行
      final legacy = await legacyRepo.getById(1002);
      final xrap = await xrapRepo.getById(1002);
      expect(xrap!.ageSet1, legacy!.ageSet1);
      expect(xrap.ageSet2, legacy.ageSet2);
      expect(xrap.content2, legacy.content2);
      expect(xrap.setName, legacy.setName);
    });

    test('setName DiZhi 枚举一致', () async {
      final legacy = await legacyRepo.getById(1001);
      final xrap = await xrapRepo.getById(1001);
      expect(xrap!.setName, DiZhi.ZI);
      expect(legacy!.setName, DiZhi.ZI);
    });
  });
}

/// TiaoWenDataModel -> 可比较的记录（忽略模型对象身份，只比业务字段）。
///
/// ageSet1 序列化为逗号字符串：Dart 的 `List ==` 是引用比较（普通 List 也一样），
/// record 内嵌 List 无法值比较。XRAP 经 `jsonDecode().cast<int>()` 得到 CastList，
/// 旧桩是 List<int>，内容相同但类型/引用不同，序列化后按字符串比才等价。
({int id, String setName, String content1, String? ageSet1Key}) _norm(
    TiaoWenDataModel? m) {
  expect(m, isNotNull, reason: '差分数据不应为 null');
  return (
    id: m!.id,
    setName: m.setName.name,
    content1: m.content1,
    ageSet1Key: m.ageSet1 == null ? null : m.ageSet1!.join(','),
  );
}

List<({int id, String setName, String content1, String? ageSet1Key})>
    _normList(List<TiaoWenDataModel> list) => list.map(_norm).toList();

/// 用 setMockMessageHandler 注入 asset 内容到 rootBundle（照 qizhengsiyu full_chain 测试）。
Future<void> _setupMockAssets() async {
  final assetContents = <String, Uint8List>{
    _kCsvAssetPath: await File(_kCsvFilePath).readAsBytes(),
    _kTiaoWenSqlAssetPath: await File(_kTiaoWenSqlFilePath).readAsBytes(),
  };

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
