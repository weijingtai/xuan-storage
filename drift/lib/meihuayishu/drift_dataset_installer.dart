/// drift 版世代状态存储与安装器（XRAP §5 持久化实现，照 daliuren/qizhengsiyu 样板）。
///
/// [MeihuaDriftDatasetGenerationStore] 把世代状态持久化到
/// [DictionaryDatabase] 的 `dataset_generation` 表，进程重启后状态保留。
/// [MeihuaDriftDatasetInstaller] 用此 store + [DatasetInstallerBase] 的
/// §5.2 安装序列逻辑。
library;

import 'package:drift/drift.dart';
import 'package:persistence_core/persistence_core.dart';

import 'dictionary_database.dart';

/// drift 版世代存储。
class MeihuaDriftDatasetGenerationStore implements DatasetGenerationStore {
  MeihuaDriftDatasetGenerationStore(this._db);

  final DictionaryDatabase _db;

  @override
  Future<InstalledDataset?> findGeneration(
    String datasetId,
    int generation,
  ) async {
    final row =
        await (_db.select(_db.meihuaDatasetGenerations)..where(
              (t) =>
                  t.datasetId.equals(datasetId) &
                  t.generation.equals(generation),
            ))
            .getSingleOrNull();
    return row == null ? null : _toInstalled(row);
  }

  @override
  Future<List<InstalledDataset>> listGenerations(String datasetId) async {
    final rows =
        await (_db.select(_db.meihuaDatasetGenerations)
              ..where((t) => t.datasetId.equals(datasetId))
              ..orderBy([(t) => OrderingTerm(expression: t.generation)]))
            .get();
    return rows.map(_toInstalled).toList();
  }

  @override
  Future<void> saveGeneration(InstalledDataset record) async {
    await _db
        .into(_db.meihuaDatasetGenerations)
        .insertOnConflictUpdate(
          MeihuaDatasetGenerationsCompanion.insert(
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
    await (_db.delete(_db.meihuaDatasetGenerations)..where(
          (t) =>
              t.datasetId.equals(datasetId) & t.generation.equals(generation),
        ))
        .go();
  }

  @override
  Future<int?> activeGeneration(String datasetId) async {
    final row =
        await (_db.select(_db.meihuaDatasetGenerations)
              ..where(
                (t) => t.datasetId.equals(datasetId) & t.status.equals('ready'),
              )
              ..limit(1))
            .getSingleOrNull();
    return row?.generation;
  }

  @override
  Future<void> setActiveGeneration(String datasetId, int generation) async {
    await _db.transaction(() async {
      await (_db.update(_db.meihuaDatasetGenerations)..where(
            (t) => t.datasetId.equals(datasetId) & t.status.equals('ready'),
          ))
          .write(
            const MeihuaDatasetGenerationsCompanion(
              status: Value('superseded'),
            ),
          );
      await (_db.update(_db.meihuaDatasetGenerations)..where(
            (t) =>
                t.datasetId.equals(datasetId) & t.generation.equals(generation),
          ))
          .write(
            const MeihuaDatasetGenerationsCompanion(status: Value('ready')),
          );
    });
  }

  InstalledDataset _toInstalled(MeihuaDatasetGenerationEntry row) {
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
        publishedAtUtc: row.installedAtUtc ?? DateTime.utc(2026, 8, 11),
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

/// drift 版安装器：用 [MeihuaDriftDatasetGenerationStore] 持久化世代状态。
class MeihuaDriftDatasetInstaller extends DatasetInstallerBase {
  // ignore: use_super_parameters
  MeihuaDriftDatasetInstaller({
    required DictionaryDatabase db,
    DatasetSource? bundledSource,
  }) : super(
         store: MeihuaDriftDatasetGenerationStore(db),
         bundledSource: bundledSource,
       );
}
