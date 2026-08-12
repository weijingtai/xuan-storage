// ignore_for_file: lines_longer_than_80_chars

/// ziwei 域 XRAP 全链路差分测试（验收 A2 运行期，照 taiyishenshu diff 样板）。
///
/// 验证：ZiweiDriftDatasetInstaller.ensureInstalled 落库后，
/// XRAP Repository 返回的契约对象与「源文件 → 手写映射」逐字段一致
/// （A2 差分：数据经 XRAP 链路后无信息损失）。
///
/// 门禁纪律（协议 §8.2）：计数式断言；每条断言能因实现变坏而变红。
library;

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_assets/ziwei/drift/ziwei_database.dart';
import 'package:persistence_assets/ziwei/drift_dataset_installer.dart';
import 'package:persistence_assets/ziwei/ziwei_datasets.dart';
import 'package:persistence_assets/ziwei/xrap_ziwei_repositories.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_ziweidoushu/repository_interface_ziwei.dart';

/// 与 xrap_ziwei_repositories.dart 内联映射一致的「源文件 → 契约」参照实现。
/// 测试只读源 JSON，不复用实现代码（否则 A2 差分无意义）。
ZiweiStar _srcStar(Map<String, dynamic> json) {
  StarCategory categoryOf(String c) {
    switch (c) {
      case 'main':
        return StarCategory.mainStar;
      case 'minor_auspicious':
      case 'baleful':
        return StarCategory.auxiliaryStar;
      default:
        return StarCategory.miscellaneousStar;
    }
  }

  StarElement? elementOf(String? e) {
    switch (e) {
      case '金':
        return StarElement.metal;
      case '木':
        return StarElement.wood;
      case '水':
        return StarElement.water;
      case '火':
        return StarElement.fire;
      case '土':
        return StarElement.earth;
      default:
        return null;
    }
  }

  StarYinYang? yinYangOf(String? y) {
    switch (y) {
      case '阴':
        return StarYinYang.yin;
      case '阳':
        return StarYinYang.yang;
      default:
        return null;
    }
  }

  return ZiweiStar(
    name: json['name'] as String,
    category: categoryOf(json['category'] as String),
    element: elementOf(json['five_elements'] as String?),
    yinYang: yinYangOf(json['yin_yang'] as String?),
    brightness: null,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ZiweiDatabase db;
  late ZiweiDriftDatasetInstaller installer;

  setUp(() {
    DatasetRegistry.clearForTesting();
    db = ZiweiDatabase(NativeDatabase.memory());
    installer = ZiweiDriftDatasetInstaller(db: db);
    registerZiweiDatasets(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  /// 读源 JSON 并按参照映射解码（flutter_test 工作目录 = assets 包根）。
  Future<List<ZiweiStar>> _srcStars(String relPath) async {
    final raw = await File(relPath).readAsString(encoding: utf8);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final stars = json['stars'] as List<dynamic>;
    return stars.map((s) => _srcStar(s as Map<String, dynamic>)).toList();
  }

  group('A2 运行期差分：XRAP 链路 vs 源文件参照映射', () {
    test('CSV 原文：loadStarCatalogCsv 与源 stars.csv 逐字节一致', () async {
      final repo = XrapZiweiStarRepository(db: db, installer: installer);
      final csv = await repo.loadStarCatalogCsv();
      final src = await File('lib/ziwei/assets/stars.csv')
          .readAsString(encoding: utf8);
      expect(csv, src, reason: 'CSV 原文必须逐字节一致（shell StarCatalog.parse 依赖）');
      expect(csv.split('\n').where((l) => l.trim().isNotEmpty),
          hasLength(108), reason: '108 行星表（源 CSV 以换行结尾）');
    });

    test('主星：getAllMainStars = 14，逐字段与源 stars_main 一致', () async {
      final repo = XrapZiweiStarRepository(db: db, installer: installer);
      final all = await repo.getAllMainStars();
      final src = await _srcStars('lib/ziwei/assets/ziwei_stars_main.json');
      expect(all, hasLength(src.length), reason: '主星数应与源一致（14）');
      expect(all, src, reason: '主星逐字段一致（name/category/element/yinYang/brightness）');
    });

    test('辅星：getAllAuxiliaryStars = minor_auspicious + baleful，与源一致', () async {
      final repo = XrapZiweiStarRepository(db: db, installer: installer);
      final all = await repo.getAllAuxiliaryStars();
      final src = await _srcStars('lib/ziwei/assets/ziwei_stars_minor.json');
      final expected = src
          .where((s) =>
              s.category == StarCategory.auxiliaryStar)
          .toList();
      expect(all, expected, reason: '辅星应为 minor_auspicious + baleful 全集');
      expect(all, isNotEmpty, reason: '辅星非空');
    });

    test('getStarByName：紫微 命中且 category=mainStar；不存在返回 null', () async {
      final repo = XrapZiweiStarRepository(db: db, installer: installer);
      final ziwei = await repo.getStarByName('紫微');
      expect(ziwei, isNotNull);
      expect(ziwei!.category, StarCategory.mainStar);
      expect(ziwei.element, StarElement.earth, reason: '紫微五行属土');
      expect(ziwei.yinYang, StarYinYang.yin, reason: '紫微属阴');
      expect(await repo.getStarByName('不存在的星'), isNull);
    });

    test('四化：getFourTransformations(0)（甲）4 条 entries 与源 sanhe 表一致', () async {
      final repo = XrapZiweiStarRepository(db: db, installer: installer);
      final t = await repo.getFourTransformations(0);
      expect(t, isNotNull);
      expect(t!.tianGanIndex, 0);
      expect(t.entries, hasLength(4), reason: '甲 4 化');
      final lu = t.entries.singleWhere((e) => e.type == TransformationType.lu);
      final quan =
          t.entries.singleWhere((e) => e.type == TransformationType.quan);
      final ke = t.entries.singleWhere((e) => e.type == TransformationType.ke);
      final ji = t.entries.singleWhere((e) => e.type == TransformationType.ji);
      expect(lu.starName, '廉贞', reason: '甲年化禄廉贞');
      expect(quan.starName, '破军', reason: '甲年化权破军');
      expect(ke.starName, '武曲', reason: '甲年化科武曲');
      expect(ji.starName, '太阳', reason: '甲年化忌太阳');
    });

    test('四化：getFourTransformations(9)（癸）与源一致；越界返回 null', () async {
      final repo = XrapZiweiStarRepository(db: db, installer: installer);
      final t = await repo.getFourTransformations(9);
      expect(t, isNotNull);
      expect(
        t!.entries.singleWhere((e) => e.type == TransformationType.lu).starName,
        '破军',
        reason: '癸年化禄破军',
      );
      expect(await repo.getFourTransformations(10), isNull);
      expect(await repo.getFourTransformations(-1), isNull);
    });

    test('全 10 天干四化均 4 条 entries（数据完整性门禁）', () async {
      final repo = XrapZiweiStarRepository(db: db, installer: installer);
      for (var i = 0; i < 10; i++) {
        final t = await repo.getFourTransformations(i);
        expect(t, isNotNull, reason: '第 $i 天干（$i 甲…）四化非空');
        expect(t!.entries, hasLength(4), reason: '第 $i 天干 4 化齐全');
        final types = t.entries.map((e) => e.type).toSet();
        expect(types, {
          TransformationType.lu,
          TransformationType.quan,
          TransformationType.ke,
          TransformationType.ji,
        }, reason: '第 $i 天干四化类型必须 lu/quan/ke/ji 各一');
      }
    });
  });
}
