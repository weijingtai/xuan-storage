/// XRAP 安装器内存实现（协议 §5）。
///
/// 【这是协议的参考实现，世代状态存内存】-- 验证全链路用。
/// 生产实现应把世代状态持久化到 drift（`DatasetGenerationStore`），
/// 但安装序列与不变式逻辑完全相同，只是存储后端不同。
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
import 'dataset_installer.dart';
import 'dataset_manifest.dart';
import 'dataset_materializer.dart';
import 'dataset_registry.dart';
import 'dataset_source.dart';

/// 世代记录（内存形态）。
class _GenerationRecord {
  _GenerationRecord({
    required this.datasetId,
    required this.generation,
    required this.manifest,
    required this.status,
    required this.sourceId,
    this.actualRowCount,
    this.installedAtUtc,
  });

  final String datasetId;
  final int generation;
  final DatasetManifest manifest;
  DatasetGenerationStatus status;
  final String sourceId;
  int? actualRowCount;
  DateTime? installedAtUtc;
}

/// 内存版安装器。
///
/// 世代状态存内存 Map，进程结束即丢。用于验证全链路与协议序列正确性。
/// 生产实现替换存储后端即可，安装逻辑不变（协议 §3.3：唯一可插拔点是
/// materializer，安装器是唯一实现）。
class InMemoryDatasetInstaller implements DatasetInstaller {
  InMemoryDatasetInstaller({DatasetSource? bundledSource})
      : _bundledSource = bundledSource;

  final DatasetSource? _bundledSource;

  /// datasetId -> 世代列表（按 generation 升序）。
  final Map<String, List<_GenerationRecord>> _generations = {};

  /// datasetId -> 当前活跃 generation 号。
  final Map<String, int> _activeGeneration = {};

  @override
  Future<InstallOutcome> ensureInstalled(
    String datasetId, {
    CancellationToken? cancel,
  }) async {
    final descriptor = DatasetRegistry.lookup(datasetId);
    if (descriptor == null) {
      // 未注册：fail closed。返回 sourceUnavailable，current=null。
      return InstallOutcome.sourceUnavailable(
        reason: '数据集 "$datasetId" 未注册',
        current: null,
      );
    }

    // 已有活跃且 ready 的世代 -> 立即返回，零网络（P4）。
    final activeGen = _activeGeneration[datasetId];
    if (activeGen != null) {
      final rec = _findRecord(datasetId, activeGen);
      if (rec != null && rec.status == DatasetGenerationStatus.ready) {
        return InstallOutcome.alreadyCurrent(_toInstalled(rec));
      }
    }

    // 无 ready 世代 -> 安装内置世代（generation 0）。
    return _installBundled(descriptor, cancel);
  }

  @override
  Future<InstallOutcome> checkForUpdate(
    String datasetId, {
    CancellationToken? cancel,
  }) async {
    // 远端更新检查：当前阶段无远端源，直接 ensureInstalled。
    // 真实实现会经 source.fetchManifest 做版本协商。
    return ensureInstalled(datasetId, cancel: cancel);
  }

  @override
  Future<InstalledDataset?> active(String datasetId) async {
    final gen = _activeGeneration[datasetId];
    if (gen == null) return null;
    final rec = _findRecord(datasetId, gen);
    if (rec == null || rec.status != DatasetGenerationStatus.ready) {
      return null;
    }
    return _toInstalled(rec);
  }

  @override
  Future<List<InstalledDataset>> generations(String datasetId) async {
    final list = _generations[datasetId] ?? const [];
    return list.map(_toInstalled).toList();
  }

  @override
  Future<InstallOutcome> rollbackTo(String datasetId, int generation) async {
    final rec = _findRecord(datasetId, generation);
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
    rec.status = DatasetGenerationStatus.ready;
    _activeGeneration[datasetId] = generation;
    return InstallOutcome.installed(_toInstalled(rec));
  }

  @override
  Future<int> collectGarbage({String? only}) async {
    final ids = only != null ? [only] : _generations.keys.toList();
    var freed = 0;
    for (final id in ids) {
      final list = _generations[id];
      if (list == null) continue;
      // 保留最近 1 个 superseded，更早的回收（§5.5）。
      final superseded = list
          .where((r) => r.status == DatasetGenerationStatus.superseded)
          .toList()
        ..sort((a, b) => b.generation.compareTo(a.generation));
      final active = _activeGeneration[id];
      for (var i = 1; i < superseded.length; i++) {
        final r = superseded[i];
        freed += r.manifest.payloadBytes;
        await descriptor(id)?.materializer().dropGeneration(r.generation);
        list.remove(r);
      }
    }
    return freed;
  }

  /// 安装内置世代（generation 0）。
  ///
  /// 序列：取内置清单 -> 版本判定 -> 幂等判定（内置恒为新）->
  /// materializer 读 asset 载荷 -> 校验 sha256 -> 落地 -> 行数自检 ->
  /// 翻转指针。
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
    final activeGen = _activeGeneration[datasetId];
    if (activeGen != null) {
      final rec = _findRecord(datasetId, activeGen);
      if (rec != null &&
          rec.manifest.payloadSha256 == manifest.payloadSha256 &&
          rec.status == DatasetGenerationStatus.ready) {
        return InstallOutcome.alreadyCurrent(_toInstalled(rec));
      }
    }

    // §5.2 第 4-6 步：取载荷 + 校验 + 落地。
    // 内置世代：materializer 自行读 asset（asset path 在 descriptor 内）。
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

    // §5.2 第 7 步：行数自检（I4）。
    if (manifest.requiresRowCountCheck &&
        outcome.rowCount != manifest.declaredRowCount) {
      // 落地失败：标记 failed，不翻转指针（I2）。
      _recordGeneration(
        datasetId: datasetId,
        generation: generation,
        manifest: manifest,
        status: DatasetGenerationStatus.failed,
        sourceId: _bundledSource?.sourceId ?? 'bundled',
        actualRowCount: outcome.rowCount,
      );
      return InstallOutcome.integrityFailed(
        reason: '行数不符：期望 ${manifest.declaredRowCount}，实际 ${outcome.rowCount}',
        current: await active(datasetId),
      );
    }

    // §5.2 第 8 步：翻转指针（I1/I2：只在 ready 后翻转）。
    final rec = _recordGeneration(
      datasetId: datasetId,
      generation: generation,
      manifest: manifest,
      status: DatasetGenerationStatus.ready,
      sourceId: _bundledSource?.sourceId ?? 'bundled',
      actualRowCount: outcome.rowCount,
    );
    // 旧活跃世代转 superseded（§5.2 第 9 步）。
    if (activeGen != null) {
      final old = _findRecord(datasetId, activeGen);
      if (old != null && old.status == DatasetGenerationStatus.ready) {
        old.status = DatasetGenerationStatus.superseded;
      }
    }
    _activeGeneration[datasetId] = generation;

    return InstallOutcome.installed(_toInstalled(rec));
  }

  /// 读内置载荷字节。
  ///
  /// materializer 若实现了 `AssetBackedMaterializer`，则从其 assetPath 读。
  Future<Uint8List?> _readBundledPayload(DatasetMaterializer m) async {
    if (m is AssetBackedMaterializer) {
      return m.loadBundledBytes();
    }
    return null;
  }

  DatasetDescriptor? descriptor(String id) => DatasetRegistry.lookup(id);

  _GenerationRecord? _findRecord(String datasetId, int generation) {
    final list = _generations[datasetId];
    if (list == null) return null;
    for (final r in list) {
      if (r.generation == generation) return r;
    }
    return null;
  }

  _GenerationRecord _recordGeneration({
    required String datasetId,
    required int generation,
    required DatasetManifest manifest,
    required DatasetGenerationStatus status,
    required String sourceId,
    int? actualRowCount,
  }) {
    final rec = _GenerationRecord(
      datasetId: datasetId,
      generation: generation,
      manifest: manifest,
      status: status,
      sourceId: sourceId,
      actualRowCount: actualRowCount,
      installedAtUtc:
          status == DatasetGenerationStatus.ready ? DateTime.now().toUtc() : null,
    );
    final list = _generations.putIfAbsent(datasetId, () => []);
    // 替换同 generation 的旧记录（幂等）。
    list.removeWhere((r) => r.generation == generation);
    list.add(rec);
    return rec;
  }

  InstalledDataset _toInstalled(_GenerationRecord rec) {
    return InstalledDataset(
      datasetId: rec.datasetId,
      generation: rec.generation,
      manifest: rec.manifest,
      status: rec.status,
      sourceId: rec.sourceId,
      actualRowCount: rec.actualRowCount,
      installedAtUtc: rec.installedAtUtc,
    );
  }

  String _sha256Hex(Uint8List bytes) {
    return crypto.sha256.convert(bytes).toString();
  }
}

/// 资产支持的 materializer 契约：内置载荷从 asset 读。
///
/// [InMemoryDatasetInstaller] 通过此接口读内置载荷字节，
/// 而不直接依赖 rootBundle（core 不依赖 flutter）。
abstract class AssetBackedMaterializer implements DatasetMaterializer {
  /// 读内置载荷的字节。
  Future<Uint8List> loadBundledBytes();
}
