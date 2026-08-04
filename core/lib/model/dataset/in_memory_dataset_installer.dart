/// XRAP 安装器基类与内存实现（协议 §5）。
///
/// [DatasetInstallerBase] 含 §5.2 完整安装序列逻辑，依赖
/// [DatasetGenerationStore] 端口持久化世代状态。内存版与 drift 版
/// 共用同一份安装逻辑，只换 store 实现。
///
/// 协议 §5.2 安装序列：
/// 1. 取清单 -> 2. 版本判定 -> 3. 幂等判定 -> 4. 取载荷 ->
/// 5. 校验 -> 6. 落地 -> 7. 行数自检 -> 8. 翻转指针 -> 9. 回收
///
/// 内置世代（generation 0）特殊处理：载荷在 asset 内，
/// 由 materializer 自行读取（asset path 在 descriptor 内），
/// 不经 source.openPayload。这与 §4.2 D3 一致：内置是预构建产物。
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import '../cancellation_token.dart';
import 'dataset_descriptor.dart';
import 'dataset_generation_store.dart';
import 'dataset_installer.dart';
import 'dataset_materializer.dart';
import 'dataset_registry.dart';
import 'dataset_source.dart';

/// 安装器基类：§5.2 完整序列逻辑，存储后端由 [store] 注入。
///
/// 子类只需提供 store（内存 / drift / ...），安装逻辑全部复用。
class DatasetInstallerBase implements DatasetInstaller {
  DatasetInstallerBase({
    required DatasetGenerationStore store,
    DatasetSource? bundledSource,
  })  : _store = store,
        _bundledSource = bundledSource;

  final DatasetGenerationStore _store;
  final DatasetSource? _bundledSource;

  @override
  Future<InstallOutcome> ensureInstalled(
    String datasetId, {
    CancellationToken? cancel,
  }) async {
    final descriptor = DatasetRegistry.lookup(datasetId);
    if (descriptor == null) {
      return InstallOutcome.sourceUnavailable(
        reason: '数据集 "$datasetId" 未注册',
        current: null,
      );
    }

    // 已有活跃且 ready 的世代 -> 立即返回，零网络（P4）。
    final activeGen = await _store.activeGeneration(datasetId);
    if (activeGen != null) {
      final rec = await _store.findGeneration(datasetId, activeGen);
      if (rec != null && rec.status == DatasetGenerationStatus.ready) {
        return InstallOutcome.alreadyCurrent(rec);
      }
    }

    return _installBundled(descriptor, cancel);
  }

  @override
  Future<InstallOutcome> checkForUpdate(
    String datasetId, {
    CancellationToken? cancel,
  }) async {
    // 远端更新检查：当前阶段无远端源，直接 ensureInstalled。
    return ensureInstalled(datasetId, cancel: cancel);
  }

  @override
  Future<InstalledDataset?> active(String datasetId) async {
    final gen = await _store.activeGeneration(datasetId);
    if (gen == null) return null;
    final rec = await _store.findGeneration(datasetId, gen);
    if (rec == null || rec.status != DatasetGenerationStatus.ready) {
      return null;
    }
    return rec;
  }

  @override
  Future<List<InstalledDataset>> generations(String datasetId) async {
    return _store.listGenerations(datasetId);
  }

  @override
  Future<InstallOutcome> rollbackTo(String datasetId, int generation) async {
    final rec = await _store.findGeneration(datasetId, generation);
    if (rec == null) {
      return InstallOutcome.sourceUnavailable(
        reason: '世代 $generation 不存在',
        current: await active(datasetId),
      );
    }
    if (rec.status != DatasetGenerationStatus.superseded &&
        rec.status != DatasetGenerationStatus.ready) {
      return InstallOutcome.sourceUnavailable(
        reason: '目标世代状态 ${rec.status} 不可回滚（须 superseded 或 ready）',
        current: await active(datasetId),
      );
    }
    // 翻转指针（I1：只能指向 ready）。
    await _store.saveGeneration(rec.copyWith(status: DatasetGenerationStatus.ready));
    await _store.setActiveGeneration(datasetId, generation);
    final updated = await _store.findGeneration(datasetId, generation);
    return InstallOutcome.installed(updated!);
  }

  @override
  Future<int> collectGarbage({String? only}) async {
    final ids = only != null
        ? [only]
        : await _allDatasetIds();
    var freed = 0;
    for (final id in ids) {
      final list = await _store.listGenerations(id);
      // 保留最近 1 个 superseded，更早的回收（§5.5）。
      final superseded = list
          .where((r) => r.status == DatasetGenerationStatus.superseded)
          .toList()
        ..sort((a, b) => b.generation.compareTo(a.generation));
      for (var i = 1; i < superseded.length; i++) {
        final r = superseded[i];
        freed += r.manifest.payloadBytes;
        await DatasetRegistry.lookup(id)?.materializer().dropGeneration(r.generation);
        await _store.deleteGeneration(id, r.generation);
      }
    }
    return freed;
  }

  /// 安装内置世代（generation 0）。
  Future<InstallOutcome> _installBundled(
    DatasetDescriptor descriptor,
    CancellationToken? cancel,
  ) async {
    final datasetId = descriptor.datasetId;
    final manifest = descriptor.bundledManifest;

    // §5.2 第 2 步：版本判定（I5）。
    if (!descriptor.supports(manifest)) {
      return InstallOutcome.rejectedSchema(
        requiredRevision: manifest.minimumAppSchemaRevision,
        appRevision: descriptor.appSchemaRevision,
        current: await active(datasetId),
      );
    }

    // §5.2 第 3 步：幂等判定。内置世代 sha256 与现有一致 -> alreadyCurrent。
    final activeGen = await _store.activeGeneration(datasetId);
    if (activeGen != null) {
      final rec = await _store.findGeneration(datasetId, activeGen);
      if (rec != null &&
          rec.manifest.payloadSha256 == manifest.payloadSha256 &&
          rec.status == DatasetGenerationStatus.ready) {
        return InstallOutcome.alreadyCurrent(rec);
      }
    }

    // §5.2 第 4-6 步：取载荷 + 校验 + 落地。
    final materializer = descriptor.materializer();
    final payloadBytes = await _readBundledPayload(materializer);
    if (payloadBytes == null) {
      return InstallOutcome.sourceUnavailable(
        reason: '内置载荷读取失败（materializer 未提供 asset path）',
        current: await active(datasetId),
      );
    }

    // §5.2 第 5 步：sha256 校验（I3）。
    final actualSha = _sha256Hex(payloadBytes);
    if (actualSha != manifest.payloadSha256) {
      return InstallOutcome.integrityFailed(
        reason: 'sha256 不匹配：期望 ${manifest.payloadSha256}，实际 $actualSha',
        current: await active(datasetId),
      );
    }

    // §5.2 第 6 步：落地（generation 0 for 内置）。
    const generation = 0;
    final outcome = await materializer.materialize(
      manifest: manifest,
      payload: Stream.value(payloadBytes.toList()),
      generation: generation,
      cancel: cancel,
    );

    final sourceId = _bundledSource?.sourceId ?? 'bundled';

    // §5.2 第 7 步：行数自检（I4）。
    if (manifest.requiresRowCountCheck &&
        outcome.rowCount != manifest.declaredRowCount) {
      await _store.saveGeneration(InstalledDataset(
        datasetId: datasetId,
        generation: generation,
        manifest: manifest,
        status: DatasetGenerationStatus.failed,
        sourceId: sourceId,
        actualRowCount: outcome.rowCount,
      ));
      return InstallOutcome.integrityFailed(
        reason: '行数不符：期望 ${manifest.declaredRowCount}，实际 ${outcome.rowCount}',
        current: await active(datasetId),
      );
    }

    // §5.2 第 8 步：翻转指针（I1/I2：只在 ready 后翻转）。
    final installed = InstalledDataset(
      datasetId: datasetId,
      generation: generation,
      manifest: manifest,
      status: DatasetGenerationStatus.ready,
      sourceId: sourceId,
      actualRowCount: outcome.rowCount,
      installedAtUtc: DateTime.now().toUtc(),
    );
    await _store.saveGeneration(installed);
    // 旧活跃世代转 superseded（§5.2 第 9 步）。
    if (activeGen != null) {
      final old = await _store.findGeneration(datasetId, activeGen);
      if (old != null && old.status == DatasetGenerationStatus.ready) {
        await _store.saveGeneration(
            old.copyWith(status: DatasetGenerationStatus.superseded));
      }
    }
    await _store.setActiveGeneration(datasetId, generation);

    return InstallOutcome.installed(installed);
  }

  /// 读内置载荷字节。
  Future<Uint8List?> _readBundledPayload(DatasetMaterializer m) async {
    if (m is AssetBackedMaterializer) {
      return m.loadBundledBytes();
    }
    return null;
  }

  /// 收集所有已注册的 datasetId（用于 GC 遍历）。
  Future<List<String>> _allDatasetIds() async {
    return DatasetRegistry.all.keys.toList();
  }

  String _sha256Hex(Uint8List bytes) {
    return crypto.sha256.convert(bytes).toString();
  }
}

/// 内存版安装器：用 [InMemoryDatasetGenerationStore] 持久化世代状态。
///
/// 进程结束即丢。用于测试与协议序列验证。
class InMemoryDatasetInstaller extends DatasetInstallerBase {
  // ignore: use_super_parameters
  InMemoryDatasetInstaller({DatasetSource? bundledSource})
      : super(
          store: InMemoryDatasetGenerationStore(),
          bundledSource: bundledSource,
        );
}

/// 内存版世代存储（测试用）。
class InMemoryDatasetGenerationStore implements DatasetGenerationStore {
  final Map<String, Map<int, InstalledDataset>> _byDataset = {};
  final Map<String, int> _active = {};

  @override
  Future<InstalledDataset?> findGeneration(
      String datasetId, int generation) async {
    return _byDataset[datasetId]?[generation];
  }

  @override
  Future<List<InstalledDataset>> listGenerations(String datasetId) async {
    final m = _byDataset[datasetId];
    if (m == null) return const [];
    return m.values.toList()..sort((a, b) => a.generation.compareTo(b.generation));
  }

  @override
  Future<void> saveGeneration(InstalledDataset record) async {
    _byDataset
        .putIfAbsent(record.datasetId, () => {})[record.generation] = record;
  }

  @override
  Future<void> deleteGeneration(String datasetId, int generation) async {
    _byDataset[datasetId]?.remove(generation);
  }

  @override
  Future<int?> activeGeneration(String datasetId) async {
    return _active[datasetId];
  }

  @override
  Future<void> setActiveGeneration(String datasetId, int generation) async {
    _active[datasetId] = generation;
  }
}

/// 资产支持的 materializer 契约：内置载荷从 asset 读。
///
/// [DatasetInstallerBase] 通过此接口读内置载荷字节，
/// 而不直接依赖 rootBundle（core 不依赖 flutter）。
abstract class AssetBackedMaterializer implements DatasetMaterializer {
  /// 读内置载荷的字节。
  Future<Uint8List> loadBundledBytes();
}
