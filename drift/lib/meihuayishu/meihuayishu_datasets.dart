/// meihuayishu 域 XRAP 数据集注册（照 daliuren/qizhengsiyu 样板）。
///
/// `meihua.dictionary`：字典数据库（characters/pinyin/etymology 3 表，
/// 28180 行）以预构建 SQL 载荷落地。载荷的表与 [DictionaryDatabase] 的
/// drift 表同构（snake_case 列名一致），installer 把数据灌入后，
/// [DriftMeiHuaDictionaryRepository] 从 drift 表直读（7 方法端口不变）。
library;

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:persistence_core/persistence_core.dart';

import 'dictionary_database.dart';

const _kDictionaryAssetPath =
    'packages/persistence_assets/lib/meihuayishu/assets/dictionary_database.sql';

class _MeihuaManifests {
  static final dictionary = DatasetManifest(
    datasetId: 'meihua.dictionary',
    contentVersion: '2026-08-11',
    minimumAppSchemaRevision: 1,
    payloadFormat: DatasetPayloadFormat.prebuilt,
    carriers: const {Carrier.row},
    payloadSha256:
        '77adf3f825588fe16039fcf0a8139e7ee9f8140bb4c2d9f231bafbfbd459fb05',
    payloadBytes: 4471505,
    declaredRowCount: 28180,
    publishedAtUtc: DateTime.utc(2026, 8, 11),
  );
}

final _meihuaPolicy = StoragePolicy.resource(
  carriers: const {Carrier.row},
  sources: const {Source.bundled, Source.officialRemote},
);

/// 注册 meihuayishu 域全部数据集（重复注册抛 [DatasetRegistrationError]）。
void registerMeihuaDatasets({required DictionaryDatabase db}) {
  DatasetRegistry.register(
    DatasetDescriptor(
      datasetId: 'meihua.dictionary',
      appSchemaRevision: 1,
      policy: _meihuaPolicy,
      bundledManifest: _MeihuaManifests.dictionary,
      materializer: () => MeihuaSqlMaterializer(
        datasetId: 'meihua.dictionary',
        assetPath: _kDictionaryAssetPath,
        declaredRowCount: 28180,
        db: db,
      ),
    ),
  );
}

/// SQL 载荷 materializer：读 asset → customStatement 灌入 drift 库。
class MeihuaSqlMaterializer implements AssetBackedMaterializer {
  MeihuaSqlMaterializer({
    required this.datasetId,
    required this.assetPath,
    required this.declaredRowCount,
    required this.db,
  });

  @override
  final String datasetId;
  final String assetPath;
  final int declaredRowCount;
  final DictionaryDatabase db;

  @override
  Future<Uint8List> loadBundledBytes() async {
    final data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  }

  @override
  Future<MaterializeOutcome> materialize({
    required DatasetManifest manifest,
    required Stream<List<int>> payload,
    required int generation,
    CancellationToken? cancel,
  }) async {
    final bytes = <int>[];
    await for (final chunk in payload) {
      bytes.addAll(chunk);
    }
    final sqlText = utf8.decode(bytes);
    await db.customStatement(sqlText);
    final actualRows = await _countRows();
    return MaterializeOutcome(
      rowCount: actualRows,
      bytesOnDisk: bytes.length,
    );
  }

  @override
  Future<void> dropGeneration(int generation) async {
    // 内置世代 0 唯一，无世代列，drop 无副作用。
  }

  Future<int> _countRows() async {
    var total = 0;
    for (final t in const ['characters', 'pinyin', 'etymology']) {
      final row = await db.customSelect('SELECT COUNT(*) AS c FROM $t')
          .getSingle();
      total += row.read<int>('c');
    }
    return total;
  }
}
