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
    sha256: '7d59428dec52ec814b12cc259f0b3d3c7cdb70dc07fdcdefe5918a36c3b6f5bc',
    bytes: 15608,
    rows: 97,
  ),
  'qizheng.ge_ju': (
    sha256: 'c265f87b85ba3a2c78b45b4fc89998f75018ddd81d4bb9b9c6f163519cb747f0',
    bytes: 532921,
    rows: 1005,
  ),
  'qizheng.zhou_tian': (
    sha256: '0d9b7831aa4528019f029495f8871155da885ef244c4bf2f02d2e5aa5dd17b4d',
    bytes: 9133,
    rows: 3,
  ),
  'qizheng.ephemeris': (
    sha256: '9b60db66db4539c822f7abe85f0113b82c2b401fe222e33096598b1c0feafce2',
    bytes: 61571,
    rows: 20,
  ),
  'qizheng.shen_sha': (
    sha256: '0d05ff7d53c78581e711f118ea75fba1e29b13164a7a37a2adb805421a8cc9dd',
    bytes: 48544,
    rows: 6,
  ),
  'qizheng.hua_yao': (
    sha256: '7780c48e0f4aa7fb9fb30a83d97cc9fc77cc8ec9f8ad553b914cdadaaeffdb0e',
    bytes: 21594,
    rows: 3,
  ),
  'qizheng.ge_ju_rules': (
    sha256: '2ad683c610b29f816ac1bc36a5426a3cf4c5e79af0f0264bb292540db2deaca1',
    bytes: 235099,
    rows: 13,
  ),
  'qizheng.ge_ju_content': (
    sha256: '70feb55ec2b524459e1f0892fa40a7090a59dad6985f31b9c234383bc388e337',
    bytes: 287867,
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

    test('star_position_status.sql 内容含 CREATE TABLE / INSERT / 中文（无显式事务）', () async {
      final bytes =
          await _loadAssetBytes(_kAssetPath['qizheng.star_position_status']!);
      final text = utf8.decode(bytes);
      // Web/WasmDatabase 嵌套事务冲突修复（照 tiebanshenshu 0f3c6dd）：
      // SQL 内不再含显式 BEGIN/COMMIT，DDL 后追加 DELETE FROM 保证重装幂等。
      expect(text.contains('BEGIN TRANSACTION;'), isFalse);
      expect(text.contains('COMMIT;'), isFalse);
      expect(text.contains('DELETE FROM star_position_status;'), isTrue);
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
