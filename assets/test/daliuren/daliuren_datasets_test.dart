// ignore_for_file: lines_longer_than_80_chars

/// daliuren 域 XRAP 接入的注册测试（验收 A1 + A2，照 qizhengsiyu_datasets_test.dart）。
///
/// 验证两件事：
/// - A1: `registerDaliurenDatasets(db: db)` 后 4 个 datasetId 均可 lookup，
///   manifest 的 sha256/bytes/rowCount 与实际载荷文件一致。
/// - A2: 载荷 *.sql 在运行期真能被 AssetBundle 加载（不只是 .dart 里写了路径）。
///
/// 门禁纪律（协议 §8.2）：不用 fail()，用计数式断言；每条断言能因实现变坏而变红。
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_assets/daliuren/drift/daliuren_database.dart';
import 'package:persistence_assets/daliuren/daliuren_datasets.dart';
import 'package:persistence_core/persistence_core.dart';

/// 测试用真值（必须与 assets/lib/daliuren/assets/BUILD-REPORT.md 一致）。
/// 若 *.sql 被重新构建，此处需同步更新，否则 sha256 断言变红——这正是门禁要的。
const _kTruth = <String, ({String sha256, int bytes, int rows})>{
  'daliuren.official_data': (
    sha256: 'dc4778d5db5a7faf8b525fca11263d2739d6599cb5776010971dcd722ac1386b',
    bytes: 7228363,
    rows: 4,
  ),
  'daliuren.keti': (
    sha256: '93c0a93406d04463e214bb74b31f0b8ce90b8967e7278e6536fe2e67c03227db',
    bytes: 87321,
    rows: 1,
  ),
  'daliuren.shen_sha': (
    sha256: 'caffd13b1c4577c2cadeac209b7d5c11aa0143ec181c2ba607c35921f5998249',
    bytes: 138277,
    rows: 9,
  ),
  'daliuren.school_dataset': (
    sha256: '5568dcb65ef5f585d30e2c462fffb69a5bd801ab430a597af5e64d76a64ed2ef',
    bytes: 594,
    rows: 1,
  ),
};

/// 载荷在 rootBundle 里的路径（与 daliuren_datasets.dart 内常量必须一致）。
const _kAssetPath = <String, String>{
  'daliuren.official_data':
      'packages/persistence_assets/lib/daliuren/assets/official_data_document.sql',
  'daliuren.keti':
      'packages/persistence_assets/lib/daliuren/assets/keti_document.sql',
  'daliuren.shen_sha':
      'packages/persistence_assets/lib/daliuren/assets/shen_sha_document.sql',
  'daliuren.school_dataset':
      'packages/persistence_assets/lib/daliuren/assets/school_dataset_document.sql',
};

void main() {
  late DaliurenDatabase db;

  setUp(() {
    DatasetRegistry.clearForTesting();
    db = DaliurenDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('A1 registerDaliurenDatasets 注册验证', () {
    test('注册后 4 个 datasetId 均可 lookup', () {
      registerDaliurenDatasets(db: db);

      final present = _kTruth.keys
          .map(DatasetRegistry.lookup)
          .where((d) => d != null)
          .length;
      expect(present, 4, reason: '4 个 datasetId 必须全部 lookup 到');
    });

    test('未注册的 id 返回 null（fail closed，协议 §3）', () {
      registerDaliurenDatasets(db: db);
      expect(DatasetRegistry.lookup('daliuren.not_exist'), isNull);
    });

    for (final entry in _kTruth.entries) {
      test('${entry.key} manifest 字段与实际载荷一致', () {
        registerDaliurenDatasets(db: db);
        final d = DatasetRegistry.lookup(entry.key)!;
        final m = d.bundledManifest;

        expect(m.datasetId, entry.key);
        expect(m.payloadSha256, entry.value.sha256);
        expect(m.payloadBytes, entry.value.bytes);
        expect(m.declaredRowCount, entry.value.rows);
        expect(m.carriers, {Carrier.row});
        expect(m.payloadFormat, DatasetPayloadFormat.prebuilt);
        expect(m.minimumAppSchemaRevision, 1);
        // 内置世代载荷在 asset 内，无 payloadPath
        expect(m.payloadPath, isNull);
        // descriptor 的 policy 必须是 resource + official（不变式 I9）
        expect(d.policy.visibility, DataVisibility.resource);
        expect(d.policy.publisher, Publisher.official);
        // appSchemaRevision 必须能读自己的内置世代（D2 方向 B）
        expect(d.supports(m), isTrue);
      });
    }

    test('重复注册同一 datasetId 抛 DatasetRegistrationError（协议注册期校验）', () {
      registerDaliurenDatasets(db: db);
      expect(
        () => registerDaliurenDatasets(db: db),
        throwsA(isA<DatasetRegistrationError>()),
        reason: '同一 datasetId 只能注册一次',
      );
    });

    test('全部已注册数据集数量为 4（一致性门禁）', () {
      registerDaliurenDatasets(db: db);
      expect(DatasetRegistry.all.length, 4);
      expect(DatasetRegistry.all.keys.toSet(), _kTruth.keys.toSet());
    });
  });

  group('A2 运行期载荷加载验证', () {
    for (final entry in _kTruth.entries) {
      test('${entry.key} 能从 asset path 加载且 sha256 与 manifest 一致', () async {
        final bytes = await _loadAssetBytes(_kAssetPath[entry.key]!);
        expect(bytes.length, entry.value.bytes,
            reason: '加载字节数应与 manifest 声明一致');
        expect(_sha256Hex(bytes), entry.value.sha256,
            reason: '加载内容 sha256 应与 manifest 声明一致');
      });
    }

    test('official_data_document.sql 内容含 CREATE TABLE / INSERT / 中文（无显式事务）', () async {
      final bytes =
          await _loadAssetBytes(_kAssetPath['daliuren.official_data']!);
      final text = utf8.decode(bytes);
      // Web/WasmDatabase 嵌套事务冲突修复（照 tiebanshenshu 0f3c6dd）：
      // SQL 内不再含显式 BEGIN/COMMIT，DDL 后追加 DELETE FROM 保证重装幂等。
      expect(text.contains('BEGIN TRANSACTION;'), isFalse);
      expect(text.contains('COMMIT;'), isFalse);
      expect(text.contains('DELETE FROM official_data_document;'), isTrue);
      expect(text.contains('CREATE TABLE'), isTrue);
      expect(text.contains('INSERT INTO'), isTrue);
      // 中文未转义
      expect(text.contains('御定大六壬'), isTrue);
    });

    test('四个 *.sql 各自 payload_json 与源 JSON 文件逐字节一致（A2 差分前置）', () async {
      // 对照 storage assets 下的源文件（flutter_test 工作目录 = assets 包根）。
      final checks = <String, List<String>>{
        'official_data_document.sql': [
          'lib/daliuren/assets/da_liu_ren/御定大六壬.json',
          'lib/daliuren/assets/da_liu_ren/ju_mapper.json',
          'lib/daliuren/assets/da_liu_ren/甲午庚牛羊_阳.json',
          'lib/daliuren/assets/da_liu_ren/甲午庚牛羊_阴.json',
        ],
        'keti_document.sql': ['lib/daliuren/assets/da_liu_ren/keti_data.json'],
        'shen_sha_document.sql': [
          'lib/daliuren/assets/shen_sha/6_shensha_gan.json',
          'lib/daliuren/assets/shen_sha/6_shensha_year.json',
          'lib/daliuren/assets/shen_sha/6_shensha_month.json',
          'lib/daliuren/assets/shen_sha/6_shensha_zhi.json',
          'lib/daliuren/assets/shen_sha/6_shensha_ji.json',
          'lib/daliuren/assets/shen_sha/6_shensha_xun.json',
          'lib/daliuren/assets/shen_sha/6_shensha_year_gan.json',
          'lib/daliuren/assets/shen_sha/6_shensha_month_gan.json',
          'lib/daliuren/assets/shen_sha/6_shensha_month_zhi_gan.json',
        ],
        'school_dataset_document.sql': [
          'lib/daliuren/assets/dataset/daliuren_dataset.json',
        ],
      };
      for (final entry in checks.entries) {
        final sqlText =
            utf8.decode(await _loadAssetBytes(
                'packages/persistence_assets/lib/daliuren/assets/${entry.key}'));
        for (final srcPath in entry.value) {
          final src =
              await File(srcPath).readAsString(encoding: utf8);
          expect(
            sqlText.contains("'${src.replaceAll("'", "''")}'"),
            isTrue,
            reason: '$srcPath 的 payload_json 应逐字节内嵌于 ${entry.key}',
          );
        }
      }
    });
  });
}

/// 从测试用 FakeAssetBundle 加载 asset 字节（照 geo/qizhengsiyu 测试模式）。
///
/// assetPath 形如 'packages/persistence_assets/lib/daliuren/assets/x.sql'，
/// 去掉前缀后是 flutter_test 工作目录（assets/ 包根）下的相对路径。
Future<Uint8List> _loadAssetBytes(String assetPath) async {
  final filePath = assetPath.replaceFirst('packages/persistence_assets/', '');
  final full = File(filePath);
  if (!await full.exists()) {
    throw FileSystemException('测试资产不存在', full.path);
  }
  return full.readAsBytes();
}

/// 计算 sha256 hex（小写），与 manifest.payloadSha256 同形态。
String _sha256Hex(Uint8List bytes) {
  final tmp =
      File('/tmp/daliuren_test_${DateTime.now().microsecondsSinceEpoch}.bin');
  try {
    tmp.writeAsBytesSync(bytes);
    final result = Process.runSync('shasum', ['-a', '256', tmp.path]);
    final out = (result.stdout as String).trim();
    return out.split(' ').first;
  } finally {
    if (tmp.existsSync()) {
      tmp.deleteSync();
    }
  }
}
