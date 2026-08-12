// ignore_for_file: lines_longer_than_80_chars

/// kanyu 域 XRAP 全链路差分测试（验收 A2 运行期，照 ziwei diff 样板）。
///
/// 验证：KanyuDriftDatasetInstaller.ensureInstalled 落库后，
/// XRAP Repository 返回的契约对象与源文件逐字段一致（A2 差分）。
library;

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_assets/kanyu/drift/kanyu_database.dart';
import 'package:persistence_assets/kanyu/drift_dataset_installer.dart';
import 'package:persistence_assets/kanyu/kanyu_datasets.dart';
import 'package:persistence_assets/kanyu/xrap_kanyu_repositories.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_kanyu/repository_interface_kanyu.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late KanyuDatabase db;
  late KanyuDriftDatasetInstaller installer;

  setUp(() {
    DatasetRegistry.clearForTesting();
    db = KanyuDatabase(NativeDatabase.memory());
    installer = KanyuDriftDatasetInstaller(db: db);
    registerKanyuDatasets(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('A2 运行期差分：XRAP 链路 vs 源文件', () {
    test('loadRuleConfig: fan-gua-water-v1 → ruleSetId 正确 + name 匹配', () async {
      final repo = XrapKanyuRuleConfigRepository(db: db, installer: installer);
      final cfg = await repo.loadRuleConfig('fan-gua-water-v1');
      expect(cfg.ruleSetId, 'fan-gua-water-v1');
      expect(cfg.name, '辅星翻卦水法');
      expect(cfg.category, 'yinzai');
      expect(cfg.version, '1.0.0');
      expect(cfg.authorType, 'built-in');
    });

    test('loadRuleConfig: 全部 6 个 ruleSetId 均可加载', () async {
      final repo = XrapKanyuRuleConfigRepository(db: db, installer: installer);
      const ids = [
        'ba-zhai-you-nian-v1',
        'fan-gua-water-v1',
        'fenjin-kongwang-v1',
        'san-he-three-pan-v1',
        'xingsha-detection-v1',
        'xuan-kong-feixing-v1',
      ];
      for (final id in ids) {
        final cfg = await repo.loadRuleConfig(id);
        expect(cfg.ruleSetId, id, reason: 'id=$id 应可加载');
      }
    });

    test('loadRuleConfig: 不存在的 ruleSetId 抛 NotFound', () async {
      final repo = XrapKanyuRuleConfigRepository(db: db, installer: installer);
      expect(
        () => repo.loadRuleConfig('not-exist-v1'),
        throwsA(isA<NotFound>()),
      );
    });

    test('listAvailableRules: 无过滤 6 条 + category 过滤', () async {
      final repo = XrapKanyuRuleConfigRepository(db: db, installer: installer);
      final all = await repo.listAvailableRules();
      expect(all, hasLength(6), reason: '官方 6 条规则');
      final yinzai = await repo.listAvailableRules(category: 'yinzai');
      expect(yinzai, hasLength(4), reason: 'yinzai 类 4 条');
      final yangzhai = await repo.listAvailableRules(category: 'yangzhai');
      expect(yangzhai, hasLength(1), reason: 'yangzhai 类 1 条');
      final common = await repo.listAvailableRules(category: 'common');
      expect(common, hasLength(1), reason: 'common 类 1 条');
    });

    test('loadRuleConfigRaw: fan-gua-water-v1 逐字节等于源文件', () async {
      final repo = XrapKanyuRuleConfigRepository(db: db, installer: installer);
      final raw = await repo.loadRuleConfigRaw('fan-gua-water-v1');
      final src = await File('lib/kanyu/assets/rules/fan_gua/fan_gua.json')
          .readAsString(encoding: utf8);
      expect(raw, src, reason: 'raw 必须逐字节等于源文件');
    });

    test('validateConfigPackage: schemaValid/hashMatched true，无 errors', () async {
      final repo = XrapKanyuRuleConfigRepository(db: db, installer: installer);
      final result = await repo.validateConfigPackage();
      expect(result.schemaValid, isTrue);
      expect(result.hashMatched, isTrue);
      expect(result.errors, isEmpty);
    });

    test('loadDocumentRaw: static_data 按相对路径可读（dataRefs 解析前置）', () async {
      final repo = XrapKanyuRuleConfigRepository(db: db, installer: installer);
      final raw = await repo.loadDocumentRaw(
          'kanyu.static_data', 'data/bagua/najia_bagua.json');
      expect(raw, isNotNull);
      final json = jsonDecode(raw!) as Map<String, dynamic>;
      expect(json['configType'], 'static');
      expect(json['layer'], 'A');
      expect(json['id'], 'bagua-najia-v1');
    });

    test('loadDocumentRaw: schema 可读且含 JSON Schema 标志', () async {
      final repo = XrapKanyuRuleConfigRepository(db: db, installer: installer);
      final raw = await repo.loadDocumentRaw(
          'kanyu.schema', 'schema/layer-b-rule-config.schema.json');
      expect(raw, isNotNull);
      expect(raw!.contains('json-schema.org'), isTrue);
    });
  });
}
