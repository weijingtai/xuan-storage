import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/cancellation_token.dart';
import 'package:persistence_core/model/dataset/dataset_manifest.dart';
import 'package:persistence_core/model/dataset/dataset_materializer.dart';
import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/theme_dataset.dart';
import 'package:persistence_core/reference/in_memory_theme_materializer.dart';

/// S5a reference 层 · ACT 05 InMemoryThemeMaterializer + InMemoryThemeTokenStore。
///
/// 覆盖验收 A20 ①②③④⑤⑥（世代隔离 / 幂等删除 / 真实行数 / 无指针操作 /
/// 不重复校验完整性 / 同载荷多世代落地）+ payload v 为 Map 抛 StateError。
Stream<List<int>> payloadOf(List<String> lines) => Stream.value(
      utf8.encode(lines.join('\n') + '\n'),
    );

final _sampleManifest = DatasetManifest(
  datasetId: themeDatasetId,
  contentVersion: '0.0.0-test',
  minimumAppSchemaRevision: 1,
  payloadFormat: DatasetPayloadFormat.prebuilt,
  carriers: {Carrier.row},
  payloadSha256: '0' * 64,
  payloadBytes: 0,
  declaredRowCount: 3,
  publishedAtUtc: DateTime.utc(2026, 1, 1),
);

void main() {
  group('ACT 05 materializer + token store', () {
    test('generation_isolation', () async {
      final store = InMemoryThemeTokenStore();
      store.putGeneration(0, {'light.components.k0': 'g0'});
      store.putGeneration(1, {'light.components.k1': 'g1'});

      // 两代互不干扰。
      expect(store.tokensOf(0), {'light.components.k0': 'g0'});
      expect(store.tokensOf(1), {'light.components.k1': 'g1'});
      expect(store.generations, {0, 1});

      // 写第 1 代不影响第 0 代。
      store.putGeneration(1, {'light.components.k1': 'g1-v2'});
      expect(store.tokensOf(0), {'light.components.k0': 'g0'});
      expect(store.tokensOf(1), {'light.components.k1': 'g1-v2'});
    });

    test('drop_generation_idempotent', () {
      final store = InMemoryThemeTokenStore();
      // 删不存在世代：静默返回，不抛。
      expect(() => store.dropGeneration(99), returnsNormally);
      expect(store.generations, isEmpty);

      // 删已存在世代后 tokensOf 变 null。
      store.putGeneration(0, {'light.components.k0': 'g0'});
      store.dropGeneration(0);
      expect(store.tokensOf(0), isNull);
      expect(store.generations, isEmpty);

      // 再删一次同样静默。
      expect(() => store.dropGeneration(0), returnsNormally);
    });

    test('row_count_is_real', () async {
      final store = InMemoryThemeTokenStore();
      final materializer = InMemoryThemeMaterializer(store);

      final outcome = await materializer.materialize(
        manifest: _sampleManifest,
        payload: payloadOf(const [
          '{"k":"light.components.btn.radius","v":8,"t":"n"}',
          '{"k":"light.components.btn.shadow.color","v":"#8B0000","t":"s"}',
          '{"k":"dark.semantic.luck.daji","v":"#22C55E","t":"s"}',
        ]),
        generation: 0,
      );

      expect(outcome.rowCount, 3);
      expect(outcome.bytesOnDisk, greaterThan(0));

      final tokens = store.tokensOf(0)!;
      expect(tokens['light.components.btn.radius'], 8);
      expect(tokens['light.components.btn.shadow.color'], '#8B0000');
      expect(tokens['dark.semantic.luck.daji'], '#22C55E');
    });

    test('no_active_pointer_mutation', () {
      // A20 ④：materializer 不含 DatasetInstaller 的六个方法名
      // （ensureInstalled/checkForUpdate/active/generations/rollbackTo/collectGarbage）。
      final source =
          File('lib/reference/in_memory_theme_materializer.dart')
              .readAsStringSync();
      final installerLike = RegExp(
        r'Future.*(ensureInstalled|checkForUpdate|active|generations|rollbackTo|collectGarbage)',
      ).allMatches(source);
      expect(
        installerLike,
        isEmpty,
        reason: 'materializer 不得含安装器方法（指针翻转归 XRAP DatasetInstaller）',
      );
    });

    test('no_payload_integrity_recheck', () {
      // A20 ⑤：import 集合断言（不是数 sha256 拼写次数）——
      // 不得 import package:crypto（完整性校验是 XRAP 安装器的职责）。
      final source =
          File('lib/reference/in_memory_theme_materializer.dart')
              .readAsStringSync();
      final imports =
          RegExp(r"""^import\s+'(?<uri>[^']+)'.*;$""", multiLine: true)
              .allMatches(source)
              .map((m) => m.namedGroup('uri')!)
              .toList();
      expect(
        imports.where((uri) => uri.startsWith('package:crypto')),
        isEmpty,
        reason: '不得 import package:crypto（不重复校验载荷完整性）',
      );
    });

    test('same_payload_two_generations_both_succeed', () async {
      // A20 ⑥（R4-P0 回归守卫）：同载荷 generation 0 与 1 各落地一次都成功。
      final store = InMemoryThemeTokenStore();
      final materializer = InMemoryThemeMaterializer(store);
      const payloadLines = [
        '{"k":"light.components.btn.radius","v":8,"t":"n"}',
        '{"k":"dark.semantic.luck.daji","v":"#22C55E","t":"s"}',
      ];

      final o0 = await materializer.materialize(
        manifest: _sampleManifest,
        payload: payloadOf(payloadLines),
        generation: 0,
      );
      final o1 = await materializer.materialize(
        manifest: _sampleManifest,
        payload: payloadOf(payloadLines),
        generation: 1,
      );

      expect(o0.rowCount, 2);
      expect(o1.rowCount, 2);
      expect(store.generations, {0, 1});
      expect(store.tokensOf(0)!['light.components.btn.radius'], 8);
      expect(store.tokensOf(1)!['light.components.btn.radius'], 8);
    });

    test('payload_value_map_throws', () async {
      // 载荷某行 v 为 Map（嵌套未展平）-> 立即抛 StateError。
      final store = InMemoryThemeTokenStore();
      final materializer = InMemoryThemeMaterializer(store);

      await expectLater(
        materializer.materialize(
          manifest: _sampleManifest,
          payload: payloadOf(const [
            '{"k":"light.components.btn.radius","v":8,"t":"n"}',
            '{"k":"light.components.btn.shadow","v":{"color":"#000"},"t":"m"}',
          ]),
          generation: 0,
        ),
        throwsStateError,
      );
      // 抛出时不得写入该代。
      expect(store.tokensOf(0), isNull);
    });
  });
}
