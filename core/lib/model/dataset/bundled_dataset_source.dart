/// XRAP 内置数据源（协议 §4.1）。
///
/// 从 rootBundle 读内置世代的载荷字节流。冷启动零网络（P4）。
///
/// 【仅用于内置世代】-- 不实现 fetchManifest 的版本协商（内置清单
/// 随包发布，不存在「远端是否变更」的问题，直接返回 bundledManifest）。
/// 远端世代由未来的官方远端 source 实现。
library;

import 'dart:async';

import '../cancellation_token.dart';
import '../storage_classification.dart';
import 'dataset_manifest.dart';
import 'dataset_registry.dart';
import 'dataset_source.dart';

/// 内置数据源：从 rootBundle 读载荷。
///
/// 装配期由 app DI 层创建并注入 [DatasetInstaller]。
/// sourceKind 恒为 [Source.bundled]，sourceId 恒为 'bundled'。
final class BundledDatasetSource implements DatasetSource {
  const BundledDatasetSource();

  @override
  Source get sourceKind => Source.bundled;

  @override
  String get sourceId => 'bundled';

  @override
  Future<DatasetManifest?> fetchManifest(
    String datasetId, {
    String? knownVersion,
  }) async {
    // 内置清单从注册表取（随包发布，无远端协商）。
    final d = DatasetRegistry.lookup(datasetId);
    return d?.bundledManifest;
  }

  @override
  Stream<List<int>> openPayload(
    DatasetManifest manifest, {
    int startByte = 0,
    CancellationToken? cancel,
  }) async* {
    // 内置载荷路径在 descriptor 内（asset path）。
    // 这里通过约定：materializer 自己持有 assetPath（注册时传入），
    // source 不直接读 payload，而是让 installer 把 asset 读取委托给
    // materializer。但为符合协议 §4（source 负责取载荷），这里仍提供
    // 基于 rootBundle 的读取，需要 manifest 带 payloadPath。
    //
    // 内置世代 manifest.payloadPath 为 null（载荷在 asset 内），
    // asset path 由 descriptor 的 materializer 工厂持有。
    // 因此本 source 的 openPayload 不直接使用，installer 会调
    // materializer 的专用内置读取入口。
    //
    // 远端世代才会真正用本方法（payloadPath 指向远端 URL）。
    throw UnsupportedError(
      'BundledDatasetSource.openPayload 不应被直接调用：'
      '内置世代的载荷读取由 materializer 负责（asset path 在 descriptor 内）。',
    );
  }
}
