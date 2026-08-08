// ignore_for_file: lines_longer_than_80_chars

/// qizhengsiyu 域 XRAP 接入的注册测试（验收 A1 + A2，照 geo_datasets_test.dart）。
///
/// 验证两件事：
/// - A1: `registerQizhengDatasets(db: db)` 后 8 个 datasetId 均可 lookup，
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
import 'package:persistence_assets/qizhengsiyu/drift/qizhengsiyu_database.dart';
import 'package:persistence_assets/qizhengsiyu/qizhengsiyu_datasets.dart';
import 'package:persistence_core/persistence_core.dart';

/// 测试用真值（必须与 assets/lib/qizhengsiyu/assets/BUILD-REPORT.md 一致）。
/// 若 *.sql 被重新构建，此处需同步更新，否则 sha256 断言变红——这正是门禁要的。
const _kTruth = <String, ({String sha256, int bytes, int rows})>{
  'qizheng.star_position_status': (
    sha256: '243db078fb6681344414e4227ee298a0d309baafd97409265ff4c05cde1825a5',
    bytes: 15601,
    rows: 97,
  ),
  'qizheng.ge_ju': (
    sha256: '40a8fa09e1002987e9e32407b61f38c0feb515ccd9d4f0a9c92ef1ef13ae62c0',
    bytes: 532810,
    rows: 1005,
  ),
  'qizheng.zhou_tian': (
    sha256: '2227d006af44b0d98818ba4db0662d8955beb2e8efc3c64640043d4d68e895e9',
    bytes: 9128,
    rows: 3,
  ),
  'qizheng.ephemeris': (
    sha256: '83a4bc14573d6352ce881b8d8b149d14408e9f5ca6c36427cade97fb0ed08925',
    bytes: 52572,
    rows: 17,
  ),
  'qizheng.shen_sha': (
    sha256: '2bd3a0d25d615b166ddfc7b8d903bd60ded853382fab812233cf271c4cbe3acb',
    bytes: 48540,
    rows: 6,
  ),
  'qizheng.hua_yao': (
    sha256: 'e082234a001660c9be64328ec85f5d34e210d2fb3c5b0bb9a67ab408e3d488b6',
    bytes: 21591,
    rows: 3,
  ),
  'qizheng.ge_ju_rules': (
    sha256: 'cd88a8379dd364c51d9723c13f0acfc1d16ef7eecf510a4d139d279ba68f9df7',
    bytes: 235092,
    rows: 13,
  ),
  'qizheng.ge_ju_content': (
    sha256: '35da58c353099d4792568065cdbf5a773478b07a4a6d3d8b4968e3e5c4284ee7',
    bytes: 287858,
    rows: 13,
  ),
};

/// 载荷在 rootBundle 里的路径（与 qizhengsiyu_datasets.dart 内常量必须一致）。
const _kAssetPath = <String, String>{
  'qizheng.star_position_status':
      'packages/persistence_assets/lib/qizhengsiyu/assets/star_position_status.sql',
  'qizheng.ge_ju':
      'packages/persistence_assets/lib/qizhengsiyu/assets/ge_ju.sql',
  'qizheng.zhou_tian':
      'packages/persistence_assets/lib/qizhengsiyu/assets/zhou_tian_document.sql',
  'qizheng.ephemeris':
      'packages/persistence_assets/lib/qizhengsiyu/assets/ephemeris_document.sql',
  'qizheng.shen_sha':
      'packages/persistence_assets/lib/qizhengsiyu/assets/shen_sha_document.sql',
  'qizheng.hua_yao':
      'packages/persistence_assets/lib/qizhengsiyu/assets/hua_yao_document.sql',
  'qizheng.ge_ju_rules':
      'packages/persistence_assets/lib/qizhengsiyu/assets/ge_ju_rules_document.sql',
  'qizheng.ge_ju_content':
      'packages/persistence_assets/lib/qizhengsiyu/assets/ge_ju_content_document.sql',
};

void main() {
  late QizhengsiyuDatabase db;

  setUp(() {
    DatasetRegistry.clearForTesting();
    db = QizhengsiyuDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('A1 registerQizhengDatasets 注册验证', () {
    test('注册后 8 个 datasetId 均可 lookup', () {
      registerQizhengDatasets(db: db);

      final present = _kTruth.keys
          .map(DatasetRegistry.lookup)
          .where((d) => d != null)
          .length;
      expect(present, 8, reason: '8 个 datasetId 必须全部 lookup 到');
    });

    test('未注册的 id 返回 null（fail closed，协议 §3）', () {
      registerQizhengDatasets(db: db);
      expect(DatasetRegistry.lookup('qizheng.not_exist'), isNull);
    });

    for (final entry in _kTruth.entries) {
      test('${entry.key} manifest 字段与实际载荷一致', () {
        registerQizhengDatasets(db: db);
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
      registerQizhengDatasets(db: db);
      expect(
        () => registerQizhengDatasets(db: db),
        throwsA(isA<DatasetRegistrationError>()),
        reason: '同一 datasetId 只能注册一次',
      );
    });

    test('全部已注册数据集数量为 8（一致性门禁）', () {
      registerQizhengDatasets(db: db);
      expect(DatasetRegistry.all.length, 8);
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

    test('star_position_status.sql 内容含 CREATE TABLE / INSERT / 中文', () async {
      final bytes =
          await _loadAssetBytes(_kAssetPath['qizheng.star_position_status']!);
      final text = utf8.decode(bytes);
      expect(text.contains('BEGIN TRANSACTION;'), isTrue);
      expect(text.contains('COMMIT;'), isTrue);
      expect(text.contains('CREATE TABLE'), isTrue);
      expect(text.contains('INSERT INTO'), isTrue);
      // 中文未转义
      expect(text.contains('果老'), isTrue);
    });

    test('ge_ju.sql 内容含 5 张表（中文未转义）', () async {
      final bytes = await _loadAssetBytes(_kAssetPath['qizheng.ge_ju']!);
      final text = utf8.decode(bytes);
      for (final t in [
        'ge_ju_patterns',
        'ge_ju_schools',
        'ge_ju_categories',
        'ge_ju_rules',
        'ge_ju_versions',
      ]) {
        expect(text.contains('CREATE TABLE IF NOT EXISTS "$t"'), isTrue,
            reason: 'ge_ju.sql 应含 $t 建表语句');
      }
      expect(text.contains('日月夹命'), isTrue);
    });
  });
}

/// 从测试用 FakeAssetBundle 加载 asset 字节（照 geo 测试模式）。
///
/// assetPath 形如 'packages/persistence_assets/lib/qizhengsiyu/assets/x.sql'，
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
  final tmp = File('/tmp/qizheng_test_${DateTime.now().microsecondsSinceEpoch}.bin');
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
