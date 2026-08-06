// 包：persistence_drift (test)  文件：drift/test/theme/theme_restart_test.dart
// THEME-DRIFT T6.3：A7 重启后主题仍在 —— 本任务存在的理由。
//
// 内存版 InMemoryThemeResourceStore 把状态存在进程内 Map，重启即失；
// drift 版落独立 .sqlite 文件（ThemeDatabase，D1），进程退出文件还在、
// 重开即恢复。本测试用**文件库**（不是 memory()）验证：
//   1. 库 A 写入 selectTheme + applyOverrides
//   2. resolve() 拿到 result1
//   3. 关库 A（await db.close()）
//   4. 同一文件路径重开库 B
//   5. resolve() 拿到 result2
//   6. 断言 result2 与 result1 的 token 值一致（覆盖值 'o1' 仍在、选择仍在）

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/theme_dataset.dart' show themeDatasetId;
import 'package:persistence_core/model/theme_resolution.dart'
    show ThemeSelectionOrigin;
import 'package:persistence_core/model/theme_token_types.dart';
import 'package:persistence_core/model/theme_value_types.dart';
import 'package:persistence_drift/theme/drift_dataset_generation_store.dart';
import 'package:persistence_drift/theme/drift_theme_local_reader.dart';
import 'package:persistence_drift/theme/drift_theme_resource_store.dart';
import 'package:persistence_drift/theme/drift_theme_token_store.dart';
import 'package:persistence_drift/theme/theme_database.dart';

void main() {
  test('A7_重启后主题仍在', () async {
    const k1 = 'light.components.four_zhu_card.shadow.color';
    const scopeUid = 'u1';
    final tmpDir = await Directory.systemTemp.createTemp('theme_restart_test');
    final dbPath = '${tmpDir.path}/theme.sqlite';

    // 1. 造库 A（文件库），写入选择 + 覆盖。
    final dbA = ThemeDatabase(NativeDatabase(File(dbPath)));
    final tokenStoreA = DriftThemeTokenStore(dbA);
    // bundled 落地 generation 0（照装配第 3 步，落地物进库文件）。
    await tokenStoreA.putGeneration(0, const {
      k1: '#8B0000',
    });
    final storeA = DriftThemeResourceStore(
      scopeUid: scopeUid,
      db: dbA,
      localReader: DriftThemeLocalReader(
        db: dbA,
        tokenStore: tokenStoreA,
        installer: DriftThemeDatasetInstaller(db: dbA),
        scopeUid: scopeUid,
      ),
    );
    await storeA.selectTheme(themeDatasetId);
    await storeA.applyOverrides(
      patch: const {k1: 'o1'},
      origin: OverrideOrigin.manual,
    );

    // 2. resolve() 拿到 result1。
    final result1 = await storeA.resolve();
    expect(_valueAt(result1, k1), 'o1');
    expect(result1.resolution.selectionOrigin, ThemeSelectionOrigin.userSelected);

    // 3. 关库 A。
    await dbA.close();

    // 4. 用同一文件路径重开库 B。
    final dbB = ThemeDatabase(NativeDatabase(File(dbPath)));
    final tokenStoreB = DriftThemeTokenStore(dbB);
    final storeB = DriftThemeResourceStore(
      scopeUid: scopeUid,
      db: dbB,
      localReader: DriftThemeLocalReader(
        db: dbB,
        tokenStore: tokenStoreB,
        installer: DriftThemeDatasetInstaller(db: dbB),
        scopeUid: scopeUid,
      ),
    );

    // 5. resolve() 拿到 result2。
    final result2 = await storeB.resolve();

    // 6. 断言：覆盖值 'o1' 仍在、选择仍在（userSelected）。
    expect(_valueAt(result2, k1), _valueAt(result1, k1));
    expect(_valueAt(result2, k1), 'o1');
    expect(result2.resolution.selectionOrigin, ThemeSelectionOrigin.userSelected);

    await dbB.close();
    await tmpDir.delete(recursive: true);
  });
}

/// 从 resolve 结果里按扁平 key 取嵌套值（key 形如 light.components.x.y）。
dynamic _valueAt(ThemeTokenSet set, String flatKey) {
  final segments = flatKey.split('.');
  final section = segments[0] == 'light' ? set.light : set.dark;
  dynamic node = section.components;
  for (final seg in segments.sublist(2)) {
    node = (node as Map<String, dynamic>)[seg];
  }
  return node;
}
