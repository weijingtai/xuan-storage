// ignore_for_file: lines_longer_than_80_chars

/// daliuren 域 XRAP 全链路差分测试（验收 A2 运行期，照 qizhengsiyu_full_chain_test.dart）。
///
/// 验证：DaliurenDriftDatasetInstaller.ensureInstalled 落库后，
/// 4 个 XRAP Repository 返回的解码值与源 JSON 文件解码值逐字节一致
/// （A2 差分：数据经 XRAP 链路后无信息损失）。
///
/// 门禁纪律（协议 §8.2）：计数式断言；每条断言能因实现变坏而变红。
library;

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_assets/daliuren/daliuren_datasets.dart';
import 'package:persistence_assets/daliuren/drift/daliuren_database.dart';
import 'package:persistence_assets/daliuren/drift_dataset_installer.dart';
import 'package:persistence_assets/daliuren/xrap_daliuren_repositories.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_daliuren/repository_interface_daliuren.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DaliurenDatabase db;
  late DaliurenDriftDatasetInstaller installer;

  setUp(() {
    DatasetRegistry.clearForTesting();
    db = DaliurenDatabase(NativeDatabase.memory());
    installer = DaliurenDriftDatasetInstaller(db: db);
    registerDaliurenDatasets(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  /// 读源 JSON（flutter_test 工作目录 = assets 包根）。
  Future<dynamic> _srcDecode(String relPath) async {
    final raw = await File(relPath).readAsString(encoding: utf8);
    return jsonDecode(raw);
  }

  group('A2 运行期差分：XRAP 链路 vs 源文件', () {
    test('official_data：御定大六壬 / ju_mapper / 阳盘 / 阴盘', () async {
      final repo = XrapDaLiuRenOfficialDataRepository(
        db: db,
        installer: installer,
      );

      final yuDing = await repo.loadYuDingData();
      expect(yuDing, await _srcDecode('lib/daliuren/assets/da_liu_ren/御定大六壬.json'));

      final juMapper = await repo.loadJuMapperData();
      expect(juMapper, await _srcDecode('lib/daliuren/assets/da_liu_ren/ju_mapper.json'));

      final yang = await repo.loadYangPanData();
      expect(yang, await _srcDecode('lib/daliuren/assets/da_liu_ren/甲午庚牛羊_阳.json'));

      final yin = await repo.loadYinPanData();
      expect(yin, await _srcDecode('lib/daliuren/assets/da_liu_ren/甲午庚牛羊_阴.json'));
    });

    test('keti：loadKetiData 与源 keti_data.json 一致', () async {
      final repo = XrapDaLiuRenKetiRepository(db: db, installer: installer);
      final keti = await repo.loadKetiData();
      expect(keti, await _srcDecode('lib/daliuren/assets/da_liu_ren/keti_data.json'));
      // 64 课体完整性
      expect(keti.length, greaterThanOrEqualTo(64));
    });

    test('shen_sha：9 个 load*Raw 与源 6_shensha_*.json 逐一一致', () async {
      final repo = XrapDaLiuRenShenShaDataRepository(db: db, installer: installer);

      final checks = <String, Future<List<dynamic>> Function()>{
        '6_shensha_gan.json': repo.loadGanShenShaRaw,
        '6_shensha_year.json': repo.loadYearShenShaRaw,
        '6_shensha_month.json': repo.loadMonthShenShaRaw,
        '6_shensha_zhi.json': repo.loadZhiShenShaRaw,
        '6_shensha_ji.json': repo.loadJiShenShaRaw,
        '6_shensha_xun.json': repo.loadXunShenShaRaw,
        '6_shensha_year_gan.json': repo.loadYearGanShenShaRaw,
        '6_shensha_month_gan.json': repo.loadMonthGanShenShaRaw,
        '6_shensha_month_zhi_gan.json': repo.loadMonthZhiGanShenShaRaw,
      };
      var checked = 0;
      for (final entry in checks.entries) {
        final actual = await entry.value();
        expect(actual, await _srcDecode('lib/daliuren/assets/shen_sha/${entry.key}'));
        checked++;
      }
      expect(checked, 9, reason: '9 个神煞方法必须全部差分');
    });

    test('school_dataset：loadEntries(天干)=10 / loadEntries(地支)=12，title 一致', () async {
      final repo = XrapDaLiuRenSchoolDataRepository(db: db, installer: installer);

      final src = await _srcDecode('lib/daliuren/assets/dataset/daliuren_dataset.json')
          as Map<String, dynamic>;

      final gan = await repo.loadEntries('天干');
      final zhi = await repo.loadEntries('地支');

      expect(gan.length, 10);
      expect(zhi.length, 12);
      expect(gan.map((e) => e.schoolId).toSet(), {'天干'});
      expect(zhi.map((e) => e.schoolId).toSet(), {'地支'});
      expect(gan.map((e) => e.title).toList(),
          (src['天干'] as List<dynamic>).cast<String>());
      expect(zhi.map((e) => e.title).toList(),
          (src['地支'] as List<dynamic>).cast<String>());
      // 其他 schoolId 返回空
      expect(await repo.loadEntries('yuding'), isEmpty);
    });
  });

  group('A2 运行期缺行异常（协议 NotFound）', () {
    test('shen_sha 查询不存在文件抛 NotFound', () async {
      final repo = XrapDaLiuRenShenShaDataRepository(db: db, installer: installer);
      // 先安装（generation 表写入 ready 状态）。
      await repo.loadGanShenShaRaw();
      // 清空数据表模拟数据缺失（generation 状态仍在 → ensureInstalled 跳过重装）。
      await (db.delete(db.daliurenShenShaDocuments)).go();
      // 新 repo 实例触发 ensureInstalled：generation 已 ready → 不重装 → 空表 → NotFound。
      final repo2 = XrapDaLiuRenShenShaDataRepository(db: db, installer: installer);
      expect(
        repo2.loadGanShenShaRaw,
        throwsA(isA<NotFound>()),
      );
    });
  });
}
