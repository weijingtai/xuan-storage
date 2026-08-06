// 包：persistence_core (test_support)  文件：core/lib/test_support/theme_probes.dart
// THEME-DRIFT T5：主题测试探针上移版（原 core/test/support/theme_probes.dart）。
//
// 【为什么上移】契约套件 `theme_resource_store_contract_suite.dart` 在 lib/test_support/，
// 不能 import test/。把 reader 探针（CountingLocalReader / SlowLocalReader /
// MutableLocalReader）与安装器探针（CountingDatasetInstaller）移到 lib 侧，
// 套件与各包测试都能 import；core/test/support/theme_probes.dart 改为 re-export
// 保持既有 import 路径不变（照 signaling_contract_suite.dart 的 D3 决定：
// 深路径消费、不进 barrel —— s1b_architecture_guard_test 已断言 barrel 不含 test_support）。

import 'dart:async';

import 'package:persistence_core/model/cancellation_token.dart';
import 'package:persistence_core/model/dataset/dataset_installer.dart';
import 'package:persistence_core/model/dataset/dataset_registry.dart';
import 'package:persistence_core/model/theme_source_ports.dart';
import 'package:persistence_core/model/theme_value_types.dart';

/// 计数式 ThemeLocalReader spy。P3-b 行为正向控制用。
final class CountingLocalReader implements ThemeLocalReader {
  CountingLocalReader(this._fixture);

  final Map<String, dynamic> _fixture; // 任意非空 fixture（readBundledTokens 返回它）

  int bundledReadCount = 0;
  int activeThemeReadCount = 0;
  int overrideReadCount = 0;

  @override
  Future<Map<String, dynamic>> readBundledTokens() async {
    bundledReadCount++;
    return Map.unmodifiable(_fixture);
  }

  @override
  Future<Map<String, dynamic>?> readActiveThemeTokens(String themeId) async {
    activeThemeReadCount++;
    return null; // 默认无已装主题包，P6 用 SlowLocalReader 替代
  }

  @override
  Future<Map<String, OverrideEntry>> readOverrides() async {
    overrideReadCount++;
    return const <String, OverrideEntry>{};
  }
}

/// 活跃世代读取挂起的 reader。P6 用：readActiveThemeTokens 返回永不完成的
/// [Completer] future，另两个方法正常返回。
final class SlowLocalReader implements ThemeLocalReader {
  SlowLocalReader(this._fixture);

  final Map<String, dynamic> _fixture;
  final Completer<Map<String, dynamic>?> _never =
      Completer<Map<String, dynamic>?>();

  @override
  Future<Map<String, dynamic>> readBundledTokens() async =>
      Map.unmodifiable(_fixture);

  @override
  Future<Map<String, dynamic>?> readActiveThemeTokens(String themeId) =>
      _never.future; // 永不完成

  @override
  Future<Map<String, OverrideEntry>> readOverrides() async =>
      const <String, OverrideEntry>{};
}

/// 可变 packageTokens 的 reader，契约套件 A10/A12 换包 / 卸载用例用。
///
/// bundled 恒非空；packageTokens 可为 null（卸载）；overrides 恒空
/// （覆盖层由 store.applyOverrides 写入，不走 reader）。
/// 原 `_MutableLocalReader`（core/test/theme_resource_store_contract_test.dart）
/// 提为公共类，供契约套件跨包使用。
final class MutableLocalReader implements ThemeLocalReader {
  MutableLocalReader(this._bundled, {Map<String, dynamic>? packageTokens})
      : _packageTokens = packageTokens;

  final Map<String, dynamic> _bundled;
  final Map<String, dynamic>? _packageTokens;

  @override
  Future<Map<String, dynamic>> readBundledTokens() async => _bundled;

  @override
  Future<Map<String, dynamic>?> readActiveThemeTokens(String themeId) async =>
      _packageTokens;

  @override
  Future<Map<String, OverrideEntry>> readOverrides() async =>
      const <String, OverrideEntry>{};
}

/// P4/A21 用的 XRAP 安装器 spy。implements DatasetInstaller 必须六个抽象方法全实现。
///
/// 它不只是计数器 —— [ensureInstalled] 会**真的**调 descriptor 的 materializer
/// 工厂并驱动 `materialize`，这样 P4/A21 测的才是 §4.5 那条真链路，
/// 而不是测试自己伪造的落地物。
///
/// **本 fake 零 IO 零网络**：载荷来自入参的内存 Stream。
final class CountingDatasetInstaller implements DatasetInstaller {
  /// [bundledPayload] 每次调用返回一条**新的** `Stream<List<int>>`
  /// （Stream 只能监听一次，复用会抛 StateError）。
  /// 取 `ThemeBenchFixture.bundledJsonlBytes`（§11.3）。
  CountingDatasetInstaller({
    required Stream<List<int>> Function() bundledPayload,
  }) : _bundledPayload = bundledPayload;

  final Stream<List<int>> Function() _bundledPayload;
  InstalledDataset? _record;

  // ---- 计数字段：初值一律 0；calledDatasetIds 初值为空 List ----
  int ensureInstalledCallCount = 0;
  int checkForUpdateCallCount = 0;
  int activeCallCount = 0;
  int generationsCallCount = 0;
  int rollbackToCallCount = 0;
  int collectGarbageCallCount = 0;

  /// 被请求过的 datasetId，按调用顺序追加（**可重复**，不是 Set）。
  /// 类型写死 `List<String>`，初值 `<String>[]`。六个方法**全部**追加。
  final List<String> calledDatasetIds = <String>[];

  /// 把六个计数清零并 `calledDatasetIds.clear()`。
  /// P4 用它把"装配期的调用"与"resolve 期间的调用"分开计。
  void resetCounts() {
    ensureInstalledCallCount = 0;
    checkForUpdateCallCount = 0;
    activeCallCount = 0;
    generationsCallCount = 0;
    rollbackToCallCount = 0;
    collectGarbageCallCount = 0;
    calledDatasetIds.clear();
  }

  // ---- 六个抽象方法的 fake 返回值，逐个写死 ----

  /// +1；追加 id。
  /// 已有 ready 世代 → 直接返回 `InstallOutcome.alreadyCurrent(_record!)`；
  /// 否则：取 descriptor、调工厂驱动 materialize（§4.5 第 3 步）、记录落地。
  @override
  Future<InstallOutcome> ensureInstalled(
    String datasetId, {
    CancellationToken? cancel,
  }) async {
    ensureInstalledCallCount++;
    calledDatasetIds.add(datasetId);
    if (_record != null && _record!.status == DatasetGenerationStatus.ready) {
      return InstallOutcome.alreadyCurrent(_record!);
    }
    final d = DatasetRegistry.lookup(datasetId)!;
    final outcome = await d.materializer().materialize(
          manifest: d.bundledManifest,
          payload: _bundledPayload(),
          generation: 0,
        );
    _record = InstalledDataset(
      datasetId: datasetId,
      generation: 0,
      manifest: d.bundledManifest,
      status: DatasetGenerationStatus.ready,
      sourceId: 'fake.bundled',
      actualRowCount: outcome.rowCount,
      installedAtUtc: DateTime.utc(2026),
    );
    return InstallOutcome.installed(_record!);
  }

  /// +1；追加 id。**永远返回** `sourceUnavailable` —— 这是协议 P5 的正常路径，不是错误。
  @override
  Future<InstallOutcome> checkForUpdate(
    String datasetId, {
    CancellationToken? cancel,
  }) async {
    checkForUpdateCallCount++;
    calledDatasetIds.add(datasetId);
    return InstallOutcome.sourceUnavailable(
      reason: 'fake: 本探针不触网',
      current: _record,
    );
  }

  /// +1；追加 id。返回 `_record`（未装过则 null）。**读路径走这里。**
  @override
  Future<InstalledDataset?> active(String datasetId) async {
    activeCallCount++;
    calledDatasetIds.add(datasetId);
    return _record;
  }

  /// +1；追加 id。返回 `_record == null ? <InstalledDataset>[] : [_record!]`。
  @override
  Future<List<InstalledDataset>> generations(String datasetId) async {
    generationsCallCount++;
    calledDatasetIds.add(datasetId);
    return _record == null ? <InstalledDataset>[] : [_record!];
  }

  /// +1；追加 id。返回 `InstallOutcome.alreadyCurrent(_record!)`；
  /// `_record == null` 时抛 `StateError`（测试若走到这里说明用错了）。
  @override
  Future<InstallOutcome> rollbackTo(String datasetId, int generation) async {
    rollbackToCallCount++;
    calledDatasetIds.add(datasetId);
    if (_record == null) {
      throw StateError('rollbackTo 前必须先 ensureInstalled（测试用错）');
    }
    return InstallOutcome.alreadyCurrent(_record!);
  }

  /// +1；`only != null` 时追加它，否则追加 `'*'`。**恒返回 0 字节**。
  @override
  Future<int> collectGarbage({String? only}) async {
    collectGarbageCallCount++;
    calledDatasetIds.add(only ?? '*');
    return 0;
  }
}
