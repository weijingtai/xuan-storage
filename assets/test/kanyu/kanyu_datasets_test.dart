// ignore_for_file: lines_longer_than_80_chars

/// kanyu 域 XRAP 接入的注册测试（验收 A1 + A2，照 ziwei_datasets_test.dart）。
///
/// 验证两件事：
/// - A1: `registerKanyuDatasets(db: db)` 后 3 个 datasetId 均可 lookup，
///   manifest 的 sha256/bytes/rowCount 与实际载荷文件一致。
/// - A2: 载荷 *.sql 在运行期真能被加载（不只是 .dart 里写了路径）。
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_assets/kanyu/drift/kanyu_database.dart';
import 'package:persistence_assets/kanyu/kanyu_datasets.dart';
import 'package:persistence_core/persistence_core.dart';

/// 测试用真值（必须与 assets/lib/kanyu/assets/BUILD-REPORT.md 一致）。
const _kTruth = <String, ({String sha256, int bytes, int rows})>{
  'kanyu.rules': (
    sha256: 'c1a5a61f490c15db6df47d5fcc0753f84ce056e0d7b3d4ed22aede51d18ff76c',
    bytes: 18216,
    rows: 6,
  ),
  'kanyu.static_data': (
    sha256: '224f47a03f854fb4010eb71521834a495a12bfb9a410280d7d2cdea5dbc385cd',
    bytes: 49191,
    rows: 16,
  ),
  'kanyu.schema': (
    sha256: '1bb50cf1514c49fa565c89ced342a4884e1e1f56c0406741fd54176a7ca292d9',
    bytes: 7150,
    rows: 2,
  ),
};

/// 载荷在 rootBundle 里的路径（与 kanyu_datasets.dart 内常量必须一致）。
const _kAssetPath = <String, String>{
  'kanyu.rules':
      'packages/persistence_assets/lib/kanyu/assets/rules_document.sql',
  'kanyu.static_data':
      'packages/persistence_assets/lib/kanyu/assets/static_data_document.sql',
  'kanyu.schema':
      'packages/persistence_assets/lib/kanyu/assets/schema_document.sql',
};

void main() {
  late KanyuDatabase db;

  setUp(() {
    DatasetRegistry.clearForTesting();
    db = KanyuDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('A1 registerKanyuDatasets 注册验证', () {
    test('注册后 3 个 datasetId 均可 lookup', () {
      registerKanyuDatasets(db: db);
      final present = _kTruth.keys
          .map(DatasetRegistry.lookup)
          .where((d) => d != null)
          .length;
      expect(present, 3, reason: '3 个 datasetId 必须全部 lookup 到');
    });

    test('未注册的 id 返回 null（fail closed，协议 §3）', () {
      registerKanyuDatasets(db: db);
      expect(DatasetRegistry.lookup('kanyu.not_exist'), isNull);
    });

    for (final entry in _kTruth.entries) {
      test('${entry.key} manifest 字段与实际载荷一致', () {
        registerKanyuDatasets(db: db);
        final d = DatasetRegistry.lookup(entry.key)!;
        final m = d.bundledManifest;

        expect(m.datasetId, entry.key);
        expect(m.payloadSha256, entry.value.sha256);
        expect(m.payloadBytes, entry.value.bytes);
        expect(m.declaredRowCount, entry.value.rows);
        expect(m.carriers, {Carrier.row});
        expect(m.payloadFormat, DatasetPayloadFormat.prebuilt);
        expect(m.minimumAppSchemaRevision, 1);
        expect(m.payloadPath, isNull);
        expect(d.policy.visibility, DataVisibility.resource);
        expect(d.policy.publisher, Publisher.official);
        expect(d.supports(m), isTrue);
      });
    }

    test('重复注册同一 datasetId 抛 DatasetRegistrationError（协议注册期校验）', () {
      registerKanyuDatasets(db: db);
      expect(
        () => registerKanyuDatasets(db: db),
        throwsA(isA<DatasetRegistrationError>()),
        reason: '同一 datasetId 只能注册一次',
      );
    });

    test('全部已注册数据集数量为 3（一致性门禁）', () {
      registerKanyuDatasets(db: db);
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

    test('rules_document.sql 内容含 CREATE TABLE / INSERT / DELETE / 中文（无显式事务）', () async {
      final bytes = await _loadAssetBytes(_kAssetPath['kanyu.rules']!);
      final text = utf8.decode(bytes);
      expect(text.contains('BEGIN TRANSACTION;'), isFalse);
      expect(text.contains('COMMIT;'), isFalse);
      expect(text.contains('DELETE FROM rules_document;'), isTrue);
      expect(text.contains('CREATE TABLE'), isTrue);
      expect(text.contains('INSERT INTO'), isTrue);
      expect(text.contains('翻卦'), isTrue, reason: '中文未转义');
    });

    test('三个 *.sql 各自 payload_json 与源文件逐字节一致（A2 差分前置）', () async {
      final checks = <String, String>{
        'rules_document.sql': 'rules',
        'static_data_document.sql': 'data',
        'schema_document.sql': 'schema',
      };
      for (final entry in checks.entries) {
        final sqlText = utf8.decode(await _loadAssetBytes(
            'packages/persistence_assets/lib/kanyu/assets/${entry.key}'));
        final dir = Directory('lib/kanyu/assets/${entry.value}');
        final files = dir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.json'))
            .toList();
        expect(files, isNotEmpty, reason: '${entry.value}/ 应有源 JSON');
        for (final f in files) {
          final src = await f.readAsString(encoding: utf8);
          expect(
            sqlText.contains("'${src.replaceAll("'", "''")}'"),
            isTrue,
            reason: '${f.path} 的 payload_json 应逐字节内嵌于 ${entry.key}',
          );
        }
      }
    });
  });
}

/// 从测试工作目录加载 asset 字节（照 ziwei 测试模式）。
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
      '/tmp/kanyu_test_${DateTime.now().microsecondsSinceEpoch}.bin');
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
