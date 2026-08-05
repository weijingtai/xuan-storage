/// drift 版世代状态存储与安装器（XRAP §5 持久化实现）。
///
/// [DriftDatasetGenerationStore] 把世代状态持久化到 [GeoDatabase]
/// 的 `dataset_generation` 表，进程重启后状态保留。
/// [DriftDatasetInstaller] 用此 store + [DatasetInstallerBase] 的
/// §5.2 安装序列逻辑。
library;

import 'package:drift/drift.dart';
import 'package:persistence_core/persistence_core.dart';

import 'drift/geo_database.dart';

/// drift 版世代存储。
///
/// 世代记录存 `dataset_generation` 表。活跃指针由
/// `status='ready'` 隐式表达（查询 active 时取 ready 的那条）。
class DriftDatasetGenerationStore implements DatasetGenerationStore {
  DriftDatasetGenerationStore(this._db);

  final GeoDatabase _db;

  @override
  Future<InstalledDataset?> findGeneration(
      String datasetId, int generation) async {
    final row = await (_db.select(_db.datasetGenerations)
          ..where((t) =>
              t.datasetId.equals(datasetId) & t.generation.equals(generation)))
        .getSingleOrNull();
    return row == null ? null : _toInstalled(row);
  }

  @override
  Future<List<InstalledDataset>> listGenerations(String datasetId) async {
    final rows = await (_db.select(_db.datasetGenerations)
          ..where((t) => t.datasetId.equals(datasetId))
          ..orderBy([(t) => OrderingTerm(expression: t.generation)]))
        .get();
    return rows.map(_toInstalled).toList();
  }

  @override
  Future<void> saveGeneration(InstalledDataset record) async {
    await _db.into(_db.datasetGenerations).insertOnConflictUpdate(
          DatasetGenerationsCompanion.insert(
            datasetId: record.datasetId,
            generation: record.generation,
            payloadSha256: record.manifest.payloadSha256,
            payloadBytes: record.manifest.payloadBytes,
            declaredRowCount: Value(record.manifest.declaredRowCount),
            status: record.status.name,
            sourceId: record.sourceId,
            installedAtUtc: Value(record.installedAtUtc),
          ),
        );
  }

  @override
  Future<void> deleteGeneration(String datasetId, int generation) async {
    await (_db.delete(_db.datasetGenerations)
          ..where((t) =>
              t.datasetId.equals(datasetId) & t.generation.equals(generation)))
        .go();
  }

  @override
  Future<int?> activeGeneration(String datasetId) async {
    // 活跃指针由 status='ready' 隐式表达。
    final row = await (_db.select(_db.datasetGenerations)
          ..where((t) =>
              t.datasetId.equals(datasetId) & t.status.equals('ready'))
          ..limit(1))
        .getSingleOrNull();
    return row?.generation;
  }

  @override
  Future<void> setActiveGeneration(String datasetId, int generation) async {
    // 翻转：先把当前 ready 的转 superseded，再把目标设 ready。
    await _db.transaction(() async {
      await (_db.update(_db.datasetGenerations)
            ..where((t) =>
                t.datasetId.equals(datasetId) & t.status.equals('ready')))
          .write(const DatasetGenerationsCompanion(status: Value('superseded')));
      await (_db.update(_db.datasetGenerations)
            ..where((t) =>
                t.datasetId.equals(datasetId) &
                t.generation.equals(generation)))
          .write(const DatasetGenerationsCompanion(status: Value('ready')));
    });
  }

  InstalledDataset _toInstalled(DatasetGenerationEntry row) {
    return InstalledDataset(
      datasetId: row.datasetId,
      generation: row.generation,
      manifest: DatasetManifest(
        datasetId: row.datasetId,
        contentVersion: '',
        minimumAppSchemaRevision: 1,
        payloadFormat: DatasetPayloadFormat.prebuilt,
        carriers: const {Carrier.row},
        payloadSha256: row.payloadSha256,
        payloadBytes: row.payloadBytes,
        declaredRowCount: row.declaredRowCount,
        publishedAtUtc: row.installedAtUtc ?? DateTime.utc(2026, 8, 3),
      ),
      status: DatasetGenerationStatus.values.firstWhere(
        (s) => s.name == row.status,
        orElse: () => DatasetGenerationStatus.failed,
      ),
      sourceId: row.sourceId,
      actualRowCount: row.declaredRowCount,
      installedAtUtc: row.installedAtUtc,
    );
  }
}

/// drift 版安装器：用 [DriftDatasetGenerationStore] 持久化世代状态。
///
/// 安装序列逻辑继承自 [DatasetInstallerBase]，只换存储后端。
class DriftDatasetInstaller extends DatasetInstallerBase {
  // ignore: use_super_parameters
  DriftDatasetInstaller({
    required GeoDatabase db,
    DatasetSource? bundledSource,
  }) : super(
          store: DriftDatasetGenerationStore(db),
          bundledSource: bundledSource,
        );
}
