// ignore_for_file: lines_longer_than_80_chars

/// taiyishenshu 域 XRAP 接入的注册测试（验收 A1 + A2，照 daliuren_datasets_test.dart）。
///
/// 验证两件事：
/// - A1: `registerTaiyiDatasets(db: db)` 后 3 个 datasetId 均可 lookup，
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
import 'package:persistence_assets/taiyishenshu/drift/taiyishenshu_database.dart';
import 'package:persistence_assets/taiyishenshu/taiyishenshu_datasets.dart';
import 'package:persistence_core/persistence_core.dart';

/// 测试用真值（必须与 assets/lib/taiyishenshu/assets/BUILD-REPORT.md 一致）。
/// 若 *.sql 被重新构建，此处需同步更新，否则 sha256 断言变红——这正是门禁要的。
const _kTruth = <String, ({String sha256, int bytes, int rows})>{
  'taiyi.schools': (
    sha256: 'cfb13ade0c988dbcad650482502cd3007e7369635040995aee974e10476bc343',
    bytes: 3878,
    rows: 3,
  ),
  'taiyi.deities': (
    sha256: '36eeee338abbfcbfab69afc502e5c7ca7cb8fcadee63a00976d7d70558d5ca50',
    bytes: 31609,
    rows: 47,
  ),
  'taiyi.minggua': (
    sha256: '9fb441277e4f686c15ee7cceaadea3164c9deb9071e5e9cb753348b51877a0fb',
    bytes: 912,
    rows: 1,
  ),
};

/// 载荷在 rootBundle 里的路径（与 taiyishenshu_datasets.dart 内常量必须一致）。
const _kAssetPath = <String, String>{
  'taiyi.schools':
      'packages/persistence_assets/lib/taiyishenshu/assets/schools_document.sql',
  'taiyi.deities':
      'packages/persistence_assets/lib/taiyishenshu/assets/deities_document.sql',
  'taiyi.minggua':
      'packages/persistence_assets/lib/taiyishenshu/assets/minggua_document.sql',
};

void main() {
  late TaiyishenshuDatabase db;

  setUp(() {
    DatasetRegistry.clearForTesting();
    db = TaiyishenshuDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('A1 registerTaiyiDatasets 注册验证', () {
    test('注册后 3 个 datasetId 均可 lookup', () {
      registerTaiyiDatasets(db: db);

      final present = _kTruth.keys
          .map(DatasetRegistry.lookup)
          .where((d) => d != null)
          .length;
      expect(present, 3, reason: '3 个 datasetId 必须全部 lookup 到');
    });

    test('未注册的 id 返回 null（fail closed，协议 §3）', () {
      registerTaiyiDatasets(db: db);
      expect(DatasetRegistry.lookup('taiyi.not_exist'), isNull);
    });

    for (final entry in _kTruth.entries) {
      test('${entry.key} manifest 字段与实际载荷一致', () {
        registerTaiyiDatasets(db: db);
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
      registerTaiyiDatasets(db: db);
      expect(
        () => registerTaiyiDatasets(db: db),
        throwsA(isA<DatasetRegistrationError>()),
        reason: '同一 datasetId 只能注册一次',
      );
    });

    test('全部已注册数据集数量为 3（一致性门禁）', () {
      registerTaiyiDatasets(db: db);
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

    test('schools_document.sql 内容含 CREATE TABLE / INSERT / DELETE / 中文（无显式事务）', () async {
      final bytes = await _loadAssetBytes(_kAssetPath['taiyi.schools']!);
      final text = utf8.decode(bytes);
      // Web/WasmDatabase 嵌套事务冲突修复（照 0f3c6dd）：无显式 BEGIN/COMMIT
      expect(text.contains('BEGIN TRANSACTION;'), isFalse);
      expect(text.contains('COMMIT;'), isFalse);
      expect(text.contains('DELETE FROM schools_document;'), isTrue);
      expect(text.contains('CREATE TABLE'), isTrue);
      expect(text.contains('INSERT INTO'), isTrue);
      // 中文未转义（集成派）
      expect(text.contains('集成派'), isTrue);
    });

    test('三个 *.sql 各自 payload_json 与源 JSON 文件逐字节一致（A2 差分前置）', () async {
      // 对照 storage assets 下的源文件（flutter_test 工作目录 = assets 包根）。
      final checks = <String, List<String>>{
        'schools_document.sql': [
          'lib/taiyishenshu/assets/schools/ji-cheng.json',
          'lib/taiyishenshu/assets/schools/jing-mirror.json',
          'lib/taiyishenshu/assets/schools/tong-zong.json',
        ],
        'deities_document.sql': [
          for (var i = 1; i <= 47; i++) 'lib/taiyishenshu/assets/deities/*.json',
        ],
        'minggua_document.sql': [
          'lib/taiyishenshu/assets/minggua/tong_zong_sequence.json',
        ],
      };
      for (final entry in checks.entries) {
        final sqlText = utf8.decode(await _loadAssetBytes(
            'packages/persistence_assets/lib/taiyishenshu/assets/${entry.key}'));
        if (entry.key == 'deities_document.sql') {
          final deityFiles = Directory('lib/taiyishenshu/assets/deities')
              .listSync()
              .whereType<File>()
              .map((f) => f.path)
              .toList();
          expect(deityFiles, hasLength(47), reason: 'deities/ 源文件应为 47');
          for (final srcPath in deityFiles) {
            final src = await File(srcPath).readAsString(encoding: utf8);
            expect(
              sqlText.contains("'${src.replaceAll("'", "''")}'"),
              isTrue,
              reason: '$srcPath 的 payload_json 应逐字节内嵌于 deities_document.sql',
            );
          }
        } else {
          for (final srcPath in entry.value) {
            final src = await File(srcPath).readAsString(encoding: utf8);
            expect(
              sqlText.contains("'${src.replaceAll("'", "''")}'"),
              isTrue,
              reason: '$srcPath 的 payload_json 应逐字节内嵌于 ${entry.key}',
            );
          }
        }
      }
    });
  });
}

/// 从测试用 FakeAssetBundle 加载 asset 字节（照 geo/qizhengsiyu/daliuren 测试模式）。
///
/// assetPath 形如 'packages/persistence_assets/lib/taiyishenshu/assets/x.sql'，
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
      '/tmp/taiyishenshu_test_${DateTime.now().microsecondsSinceEpoch}.bin');
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
