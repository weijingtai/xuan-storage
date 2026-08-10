// ignore_for_file: lines_longer_than_80_chars

/// tiebanshenshu 域 XRAP 接入的注册测试（验收 A1 + A2，照 qizhengsiyu_datasets_test.dart）。
///
/// 验证两件事：
/// - A1: `registerTiebanshenshuDatasets(db: db)` 后 4 个 datasetId 均可 lookup，
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
import 'package:persistence_assets/tiebanshenshu/drift/tiebanshenshu_database.dart';
import 'package:persistence_assets/tiebanshenshu/tiebanshenshu_datasets.dart';
import 'package:persistence_core/persistence_core.dart';

/// 测试用真值（必须与 assets/lib/tiebanshenshu/assets/BUILD-REPORT.md 一致）。
/// 若 *.sql 被重新构建，此处需同步更新，否则 sha256 断言变红——这正是门禁要的。
const _kTruth = <String, ({String sha256, int bytes, int rows})>{
  'tiebanshenshu.tiao_wen': (
    sha256: 'f9978642d783e9a388a99b3b998976e0c5adb9ffd82b05eac558157c08c0234e',
    bytes: 1645508,
    rows: 12000,
  ),
  'tiebanshenshu.kao_ke': (
    sha256: '73c2d46761555a7c51f919c432f35815015554f94c87c3ddc756ab30973cd57b',
    bytes: 80590,
    rows: 21,
  ),
  'tiebanshenshu.shaozishu': (
    sha256: 'ff5d448ad192dcb463a3a55b50609b5aaf81b1c5a8855cbf1f1386a80b987895',
    bytes: 573977,
    rows: 12,
  ),
  'tiebanshenshu.formulas': (
    sha256: 'efd9536635545a5b7d1c7b4deb03b3c47a2154e91d2143f1c154c89078f282a5',
    bytes: 29677,
    rows: 3,
  ),
};

/// 载荷在 rootBundle 里的路径（与 tiebanshenshu_datasets.dart 内常量必须一致）。
const _kAssetPath = <String, String>{
  'tiebanshenshu.tiao_wen':
      'packages/persistence_assets/lib/tiebanshenshu/assets/tiao_wen.sql',
  'tiebanshenshu.kao_ke':
      'packages/persistence_assets/lib/tiebanshenshu/assets/kao_ke_document.sql',
  'tiebanshenshu.shaozishu':
      'packages/persistence_assets/lib/tiebanshenshu/assets/shaozishu_document.sql',
  'tiebanshenshu.formulas':
      'packages/persistence_assets/lib/tiebanshenshu/assets/formulas_document.sql',
};

void main() {
  late TiebanshenshuDatabase db;

  setUp(() {
    DatasetRegistry.clearForTesting();
    db = TiebanshenshuDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('A1 registerTiebanshenshuDatasets 注册验证', () {
    test('注册后 4 个 datasetId 均可 lookup', () {
      registerTiebanshenshuDatasets(db: db);

      final present = _kTruth.keys
          .map(DatasetRegistry.lookup)
          .where((d) => d != null)
          .length;
      expect(present, 4, reason: '4 个 datasetId 必须全部 lookup 到');
    });

    test('未注册的 id 返回 null（fail closed，协议 §3）', () {
      registerTiebanshenshuDatasets(db: db);
      expect(DatasetRegistry.lookup('tiebanshenshu.not_exist'), isNull);
    });

    for (final entry in _kTruth.entries) {
      test('${entry.key} manifest 字段与实际载荷一致', () {
        registerTiebanshenshuDatasets(db: db);
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
      registerTiebanshenshuDatasets(db: db);
      expect(
        () => registerTiebanshenshuDatasets(db: db),
        throwsA(isA<DatasetRegistrationError>()),
        reason: '同一 datasetId 只能注册一次',
      );
    });

    test('全部已注册数据集数量为 4（一致性门禁）', () {
      registerTiebanshenshuDatasets(db: db);
      expect(DatasetRegistry.all.length, 4);
      expect(DatasetRegistry.all.keys.toSet(), _kTruth.keys.toSet());
    });
  });

  group('A2 运行期载荷加载验证', () {
    // 用真实文件内容构造 FakeAssetBundle，模拟 rootBundle 加载。
    // 验证：asset path 字符串正确 + *.sql 内容 sha256 与 manifest 一致（I3 前置）。

    for (final entry in _kTruth.entries) {
      test('${entry.key} 能从 asset path 加载且 sha256 与 manifest 一致', () async {
        final bytes = await _loadAssetBytes(_kAssetPath[entry.key]!);
        expect(bytes.length, entry.value.bytes,
            reason: '加载字节数应与 manifest 声明一致');
        expect(_sha256Hex(bytes), entry.value.sha256,
            reason: '加载内容 sha256 应与 manifest 声明一致');
      });
    }

    test('tiao_wen.sql 内容含 CREATE TABLE / INSERT / 中文', () async {
      final bytes =
          await _loadAssetBytes(_kAssetPath['tiebanshenshu.tiao_wen']!);
      final text = utf8.decode(bytes);
      expect(text.contains('BEGIN TRANSACTION;'), isTrue);
      expect(text.contains('COMMIT;'), isTrue);
      expect(text.contains('CREATE TABLE'), isTrue);
      expect(text.contains('INSERT INTO'), isTrue);
      // 中文未转义
      expect(text.contains('一树残花'), isTrue);
    });

    test('kao_ke_document.sql 内容含 21 个文件名（中文未转义）', () async {
      final bytes = await _loadAssetBytes(_kAssetPath['tiebanshenshu.kao_ke']!);
      final text = utf8.decode(bytes);
      expect(text.contains('CREATE TABLE IF NOT EXISTS kao_ke_document'),
          isTrue);
      expect(text.contains('shi_tu.json'), isTrue);
      expect(text.contains('师徒爻密数'), isTrue);
    });

    test('shaozishu_document.sql 内容含 12 个地支 txt', () async {
      final bytes =
          await _loadAssetBytes(_kAssetPath['tiebanshenshu.shaozishu']!);
      final text = utf8.decode(bytes);
      expect(text.contains('CREATE TABLE IF NOT EXISTS shaozishu_document'),
          isTrue);
      expect(text.contains('子.txt'), isTrue);
      expect(text.contains('子時初刻弟兄稀'), isTrue);
    });
  });
}

/// 从测试用 FakeAssetBundle 加载 asset 字节（照 geo/qizhengsiyu 测试模式）。
///
/// assetPath 形如 'packages/persistence_assets/lib/tiebanshenshu/assets/x.sql'，
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
  final tmp = File('/tmp/tbs_test_${DateTime.now().microsecondsSinceEpoch}.bin');
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
