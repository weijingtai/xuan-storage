// ignore_for_file: lines_longer_than_80_chars

/// taiyishenshu 域 XRAP 全链路差分测试（验收 A2 运行期，照 daliuren diff 样板）。
///
/// 验证：TaiyiDriftDatasetInstaller.ensureInstalled 落库后，
/// XRAP Repository 返回的契约对象与「源 JSON → 契约 fromJson」逐字段一致
/// （A2 差分：数据经 XRAP 链路后无信息损失）。
///
/// 门禁纪律（协议 §8.2）：计数式断言；每条断言能因实现变坏而变红。
library;

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_assets/taiyishenshu/taiyishenshu_datasets.dart';
import 'package:persistence_assets/taiyishenshu/drift/taiyishenshu_database.dart';
import 'package:persistence_assets/taiyishenshu/drift_dataset_installer.dart';
import 'package:persistence_assets/taiyishenshu/xrap_taiyishenshu_repositories.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TaiyishenshuDatabase db;
  late TaiyiDriftDatasetInstaller installer;

  setUp(() {
    DatasetRegistry.clearForTesting();
    db = TaiyishenshuDatabase(NativeDatabase.memory());
    installer = TaiyiDriftDatasetInstaller(db: db);
    registerTaiyiDatasets(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  /// 读源 JSON 并按契约 fromJson 解码（flutter_test 工作目录 = assets 包根）。
  Future<T> _srcContract<T>(String relPath, T Function(Map<String, dynamic>) fromJson) async {
    final raw = await File(relPath).readAsString(encoding: utf8);
    return fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  group('A2 运行期差分：XRAP 链路 vs 源文件契约解码', () {
    test('schools：loadAllSchools = 3 份，逐份字段级一致', () async {
      final repo = XrapTaiyiSchoolRepository(db: db, installer: installer);

      final all = await repo.loadAllSchools();
      expect(all, hasLength(3), reason: '3 份精简学派必须全部读出');

      final checks = <String, String>{
        'ji-cheng.json': 'ji-cheng.json',
        'jing-mirror.json': 'jing-mirror.json',
        'tong-zong.json': 'tong-zong.json',
      };
      var checked = 0;
      for (final entry in checks.entries) {
        final expected = await _srcContract<TaiYiSchoolContract>(
          'lib/taiyishenshu/assets/schools/${entry.value}',
          TaiYiSchoolContract.fromJson,
        );
        expect(all.map((s) => s.id).toSet(),
            contains(expected.id), reason: 'school id 必须存在');
        final actual = await repo.loadSchool(expected.id);
        expect(actual, isNotNull, reason: 'loadSchool(${expected.id}) 非空');
        expect(actual, expected,
            reason: 'loadSchool(${expected.id}) 应与源文件契约解码逐字段一致');
        checked++;
      }
      expect(checked, 3, reason: '3 份学派必须全部差分');
    });

    test('deities：loadAllDeities = 47 份，loadDeity 逐份字段级一致', () async {
      final repo = XrapTaiyiSchoolRepository(db: db, installer: installer);

      final all = await repo.loadAllDeities();
      expect(all, hasLength(47), reason: '47 份神将必须全部读出');

      final files = Directory('lib/taiyishenshu/assets/deities')
          .listSync()
          .whereType<File>()
          .map((f) => f.path)
          .toList()
        ..sort();
      expect(files, hasLength(47));

      var checked = 0;
      for (final f in files) {
        final expected = await _srcContract<DeityDefinitionContract>(
          f,
          DeityDefinitionContract.fromJson,
        );
        final actual = await repo.loadDeity(expected.id);
        expect(actual, isNotNull, reason: 'loadDeity(${expected.id}) 非空');
        expect(actual, expected,
            reason: 'loadDeity(${expected.id}) 应与源文件契约解码逐字段一致');
        checked++;
      }
      expect(checked, 47, reason: '47 份神将必须全部差分');
    });

    test('minggua：loadConfig(tongZong) 与源 tong_zong_sequence.json 一致', () async {
      final repo = XrapTaiyiMingGuaRepository(db: db, installer: installer);

      final configs = await repo.loadAllConfigs();
      expect(configs, hasLength(1), reason: 'minggua 数据集应恰有 1 条配置');

      final expected = await _srcContract<MingGuaConfigContract>(
        'lib/taiyishenshu/assets/minggua/tong_zong_sequence.json',
        MingGuaConfigContract.fromJson,
      );
      expect(configs.first.id, 'tongZong');
      expect(configs.first, expected,
          reason: 'loadConfig 应与源文件契约解码逐字段一致');
    });

    test('只读约束：save/delete 抛 UnsupportedError（官方资源只读）', () async {
      final schoolRepo = XrapTaiyiSchoolRepository(db: db, installer: installer);
      final mingGuaRepo = XrapTaiyiMingGuaRepository(db: db, installer: installer);

      expect(() => schoolRepo.saveSchool(
            const TaiYiSchoolContract(
              id: 'x',
              name: 'x',
              epoch: SchoolEpochConfigContract(
                ancientBase: 0,
                epochYear: 0,
                correction: 0,
                tropicalYear: 365.24,
              ),
            ),
          ),
          throwsUnsupportedError);
      expect(() => schoolRepo.deleteSchool('x'), throwsUnsupportedError);
      expect(() => mingGuaRepo.saveConfig(
            const MingGuaConfigContract(
              id: 'x',
              name: 'x',
              epochBase: 0,
              guaSequence: [],
            ),
          ),
          throwsUnsupportedError);
      expect(() => mingGuaRepo.deleteConfig('x'), throwsUnsupportedError);
    });
  });
}
