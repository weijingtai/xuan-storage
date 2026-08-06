// 包：persistence_drift  文件：drift/lib/theme/drift_dataset_generation_store.dart
// THEME-DRIFT：drift 版世代状态存储（照 T1 assets/lib/geo/drift_dataset_installer.dart）。
//
// 把 XRAP 世代状态持久化到 [ThemeDatabase] 的 t_theme_dataset_generation 表，
// 进程重启后状态保留。DriftDatasetInstaller 复用 DatasetInstallerBase 的
// §5.2 安装序列逻辑，只换存储后端。
//
// 逐方法对齐 T1 的 DriftDatasetGenerationStore（assets 包），区别仅在
// 表名用主题独立库的 ThemeDatasetGenerations 而非 assets 的 DatasetGenerations。

import 'package:drift/drift.dart';
import 'package:persistence_core/persistence_core.dart';

import 'theme_database.dart';

/// drift 版世代存储（主题独立库）。
///
/// 世代记录存 t_theme_dataset_generation 表。活跃指针由
/// `status='ready'` 隐式表达（查询 active 时取 ready 的那条），
/// 与 T1 DriftDatasetGenerationStore 语义一致。
class DriftThemeDatasetGenerationStore implements DatasetGenerationStore {
  DriftThemeDatasetGenerationStore(this._db);

  final ThemeDatabase _db;

  @override
  Future<InstalledDataset?> findGeneration(
      String datasetId, int generation) async {
    final row = await (_db.select(_db.themeDatasetGenerations)
          ..where((t) =>
              t.datasetId.equals(datasetId) & t.generation.equals(generation)))
        .getSingleOrNull();
    return row == null ? null : _toInstalled(row);
  }

  @override
  Future<List<InstalledDataset>> listGenerations(String datasetId) async {
    final rows = await (_db.select(_db.themeDatasetGenerations)
          ..where((t) => t.datasetId.equals(datasetId))
          ..orderBy([(t) => OrderingTerm(expression: t.generation)]))
        .get();
    return rows.map(_toInstalled).toList();
  }

  @override
  Future<void> saveGeneration(InstalledDataset record) async {
    await _db.into(_db.themeDatasetGenerations).insertOnConflictUpdate(
          ThemeDatasetGenerationsCompanion.insert(
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
    await (_db.delete(_db.themeDatasetGenerations)
          ..where((t) =>
              t.datasetId.equals(datasetId) & t.generation.equals(generation)))
        .go();
  }

  @override
  Future<int?> activeGeneration(String datasetId) async {
    // 活跃指针由 status='ready' 隐式表达（照 T1）。
    final row = await (_db.select(_db.themeDatasetGenerations)
          ..where((t) =>
              t.datasetId.equals(datasetId) & t.status.equals('ready'))
          ..limit(1))
        .getSingleOrNull();
    return row?.generation;
  }

  @override
  Future<void> setActiveGeneration(String datasetId, int generation) async {
    // 翻转：先把当前 ready 的转 superseded，再把目标设 ready（照 T1，单事务）。
    await _db.transaction(() async {
      await (_db.update(_db.themeDatasetGenerations)
            ..where((t) =>
                t.datasetId.equals(datasetId) & t.status.equals('ready')))
          .write(const ThemeDatasetGenerationsCompanion(
              status: Value('superseded')));
      await (_db.update(_db.themeDatasetGenerations)
            ..where((t) =>
                t.datasetId.equals(datasetId) &
                t.generation.equals(generation)))
          .write(const ThemeDatasetGenerationsCompanion(status: Value('ready')));
    });
  }

  InstalledDataset _toInstalled(ThemeDatasetGenerationRow row) {
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
        publishedAtUtc: row.installedAtUtc ?? DateTime.utc(2026, 8, 6),
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

/// drift 版安装器（主题独立库）：用 [DriftThemeDatasetGenerationStore]
/// 持久化世代状态，安装序列逻辑继承自 [DatasetInstallerBase]。
class DriftThemeDatasetInstaller extends DatasetInstallerBase {
  DriftThemeDatasetInstaller({
    required ThemeDatabase db,
    super.bundledSource,
  }) : super(
          store: DriftThemeDatasetGenerationStore(db),
        );
}
