import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/cancellation_token.dart';
import 'package:persistence_core/model/dataset/dataset_manifest.dart';
import 'package:persistence_core/model/dataset/dataset_materializer.dart';
import 'package:persistence_core/model/dataset/dataset_registry.dart';
import 'package:persistence_core/model/storage_policy_registry.dart';
import 'package:persistence_core/model/theme_dataset.dart';
import 'package:persistence_core/model/theme_module_registry.dart';
import 'package:persistence_core/model/theme_storage_policies.dart';

/// S5a 契约层 · ACT 03 存储策略 + XRAP 数据集声明 + 模块注册器。
///
/// 覆盖验收 A8：真实调用 [ThemeModuleRegistry.register] 并断言三条策略进入
/// [StoragePolicyRegistry.all] 且主题数据集进入 [DatasetRegistry]。
///
/// 本 ACT 用最小 fake materializer（InMemoryThemeMaterializer 在 ACT 05 交付）。
class _FakeThemeMaterializer implements DatasetMaterializer {
  @override
  String get datasetId => themeDatasetId;

  @override
  Future<MaterializeOutcome> materialize({
    required DatasetManifest manifest,
    required Stream<List<int>> payload,
    required int generation,
    CancellationToken? cancel,
  }) async {
    return const MaterializeOutcome(rowCount: 0, bytesOnDisk: 0);
  }

  @override
  Future<void> dropGeneration(int generation) async {}
}

void main() {
  setUp(() {
    StoragePolicyRegistry.clearForTesting();
    DatasetRegistry.clearForTesting();
    ThemeModuleRegistry.resetForTesting();
  });

  group('ACT 03 策略 / 数据集声明 / 模块注册器', () {
    test('register_real_drives_policy_and_dataset', () {
      // 真实调用 register（不是只检查声明存在）。
      ThemeModuleRegistry.register(
        themeMaterializer: () => _FakeThemeMaterializer(),
      );

      // ① 三条策略进入 StoragePolicyRegistry.all，且与常量同一实例。
      final all = StoragePolicyRegistry.all;
      expect(all.containsKey(themePackageEntityType), isTrue);
      expect(all[themePackageEntityType], same(officialThemePolicy));
      expect(all[themeOverrideEntityType], same(themeOverridePolicy));
      expect(all[themeSelectionEntityType], same(themeSelectionPolicy));

      // ② 主题数据集进入 DatasetRegistry。
      final descriptor = DatasetRegistry.lookup(themeDatasetId);
      expect(descriptor, isNotNull);
      expect(descriptor!.datasetId, themeDatasetId);
      expect(descriptor.bundledManifest.datasetId, themeDatasetId);

      // ③ 幂等：重复注册不抛异常。
      expect(
        () => ThemeModuleRegistry.register(
          themeMaterializer: () => _FakeThemeMaterializer(),
        ),
        returnsNormally,
      );
    });

    test('register_idempotent_flag_not_swallow', () {
      // 首次注册成功。
      ThemeModuleRegistry.register(
        themeMaterializer: () => _FakeThemeMaterializer(),
      );

      // 重置标志后清空策略表，再手动抢注同名 entityType，
      // 然后走 register —— 必须抛 StateError。
      // 证明幂等靠 _registered 短路，不是 try-catch 吞异常（§5.6.3）。
      ThemeModuleRegistry.resetForTesting();
      StoragePolicyRegistry.clearForTesting();
      StoragePolicyRegistry.register(themePackageEntityType, officialThemePolicy);

      expect(
        () => ThemeModuleRegistry.register(
          themeMaterializer: () => _FakeThemeMaterializer(),
        ),
        throwsStateError,
      );
    });

    test('entity_type_constants_not_inlined', () {
      expect(themePackageEntityType, 'theme_package');
      expect(themeOverrideEntityType, 'theme_override');
      expect(themeSelectionEntityType, 'theme_selection');

      // 注册后 registry 的 key 与常量引用同一字符串（防拼写漂移）。
      ThemeModuleRegistry.register(
        themeMaterializer: () => _FakeThemeMaterializer(),
      );
      final all = StoragePolicyRegistry.all;
      expect(all.containsKey(themePackageEntityType), isTrue);
      expect(all[themePackageEntityType], same(officialThemePolicy));
    });
  });
}
