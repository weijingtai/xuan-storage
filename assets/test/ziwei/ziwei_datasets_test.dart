// ignore_for_file: lines_longer_than_80_chars

/// ziwei 域 XRAP 接入的注册测试（验收 A1 + A2，照 taiyishenshu_datasets_test.dart）。
///
/// 验证两件事：
/// - A1: `registerZiweiDatasets(db: db)` 后 3 个 datasetId 均可 lookup，
///   manifest 的 sha256/bytes/rowCount 与实际载荷文件一致。
/// - A2: 载荷 *.sql 在运行期真能被加载（不只是 .dart 里写了路径）。
///
/// 门禁纪律（协议 §8.2）：不用 fail()，用计数式断言；每条断言能因实现变坏而变红。
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_assets/ziwei/drift/ziwei_database.dart';
import 'package:persistence_assets/ziwei/ziwei_datasets.dart';
import 'package:persistence_core/persistence_core.dart';

/// 测试用真值（必须与 assets/lib/ziwei/assets/BUILD-REPORT.md 一致）。
/// 若 *.sql 被重新构建，此处需同步更新，否则 sha256 断言变红——这正是门禁要的。
const _kTruth = <String, ({String sha256, int bytes, int rows})>{
  'ziwei.star_catalog': (
    sha256: '612e618a89b9d9b2bca1f797fcf647ab1642300fe1eaf6f6984e245384b3e79d',
    bytes: 11013,
    rows: 1,
  ),
  'ziwei.star_metadata': (
    sha256: '8b8a1f60ff9b3dbfd6f9442395ceca9e2791ebf2af9bf2b3d1cbf906121cae3f',
    bytes: 21947,
    rows: 2,
  ),
  'ziwei.four_transformations': (
    sha256: '099d1031d4ec1b3539054d7ae8769ea864ac8b7b8548fd3c071d249a25864a32',
    bytes: 4390,
    rows: 1,
  ),
};

/// 载荷在 rootBundle 里的路径（与 ziwei_datasets.dart 内常量必须一致）。
const _kAssetPath = <String, String>{
  'ziwei.star_catalog':
      'packages/persistence_assets/lib/ziwei/assets/star_catalog_document.sql',
  'ziwei.star_metadata':
      'packages/persistence_assets/lib/ziwei/assets/star_metadata_document.sql',
  'ziwei.four_transformations':
      'packages/persistence_assets/lib/ziwei/assets/four_transformations_document.sql',
};

void main() {
  late ZiweiDatabase db;

  setUp(() {
    DatasetRegistry.clearForTesting();
    db = ZiweiDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('A1 registerZiweiDatasets 注册验证', () {
    test('注册后 3 个 datasetId 均可 lookup', () {
      registerZiweiDatasets(db: db);

      final present = _kTruth.keys
          .map(DatasetRegistry.lookup)
          .where((d) => d != null)
          .length;
      expect(present, 3, reason: '3 个 datasetId 必须全部 lookup 到');
    });

    test('未注册的 id 返回 null（fail closed，协议 §3）', () {
      registerZiweiDatasets(db: db);
      expect(DatasetRegistry.lookup('ziwei.not_exist'), isNull);
    });

    for (final entry in _kTruth.entries) {
      test('${entry.key} manifest 字段与实际载荷一致', () {
        registerZiweiDatasets(db: db);
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
      registerZiweiDatasets(db: db);
      expect(
        () => registerZiweiDatasets(db: db),
        throwsA(isA<DatasetRegistrationError>()),
        reason: '同一 datasetId 只能注册一次',
      );
    });

    test('全部已注册数据集数量为 3（一致性门禁）', () {
      registerZiweiDatasets(db: db);
      expect(DatasetRegistry.all.length, 3);
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

    test('star_catalog_document.sql 内容含 CREATE TABLE / INSERT / DELETE / 中文（无显式事务）', () async {
      final bytes = await _loadAssetBytes(_kAssetPath['ziwei.star_catalog']!);
      final text = utf8.decode(bytes);
      // Web/WasmDatabase 嵌套事务冲突修复（照 0f3c6dd）：无显式 BEGIN/COMMIT
      expect(text.contains('BEGIN TRANSACTION;'), isFalse);
      expect(text.contains('COMMIT;'), isFalse);
      expect(text.contains('DELETE FROM star_catalog_document;'), isTrue);
      expect(text.contains('CREATE TABLE'), isTrue);
      expect(text.contains('INSERT INTO'), isTrue);
      // 中文未转义（紫微）
      expect(text.contains('紫微'), isTrue);
    });

    test('三个 *.sql 各自 payload_json 与源文件逐字节一致（A2 差分前置）', () async {
      // 对照 storage assets 下的源文件（flutter_test 工作目录 = assets 包根）。
      final checks = <String, List<String>>{
        'star_catalog_document.sql': ['lib/ziwei/assets/stars.csv'],
        'star_metadata_document.sql': [
          'lib/ziwei/assets/ziwei_stars_main.json',
          'lib/ziwei/assets/ziwei_stars_minor.json',
        ],
        'four_transformations_document.sql': [
          'lib/ziwei/assets/ziwei_four_transformations.json',
        ],
      };
      for (final entry in checks.entries) {
        final sqlText = utf8.decode(await _loadAssetBytes(
            'packages/persistence_assets/lib/ziwei/assets/${entry.key}'));
        for (final srcPath in entry.value) {
          final src = await File(srcPath).readAsString(encoding: utf8);
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

/// 从测试工作目录加载 asset 字节（照 taiyishenshu 测试模式）。
///
/// assetPath 形如 'packages/persistence_assets/lib/ziwei/assets/x.sql'，
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
  final tmp = File(
      '/tmp/ziwei_test_${DateTime.now().microsecondsSinceEpoch}.bin');
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
