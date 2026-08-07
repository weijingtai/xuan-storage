// 包：persistence_drift (test)  文件：drift/test/theme/theme_resource_store_contract_test.dart
// THEME-DRIFT T6.2：drift 版跑与内存版同一套契约测试（验收 A2）。
//
// 套件在 core/lib/test_support/theme_resource_store_contract_suite.dart（T5），
// 本文件用 DriftThemeResourceStore 实现调同一套 —— 契约约束不各写各的。
// 三条变异自检（A3/A4/A5）在 theme_mutation_selfcheck_test.dart。

import 'package:drift/native.dart';
import 'package:persistence_core/test_support/theme_bench_fixture.dart';
import 'package:persistence_core/test_support/theme_resource_store_contract_suite.dart';
import 'package:persistence_drift/theme/drift_theme_resource_store.dart';
import 'package:persistence_drift/theme/drift_theme_token_store.dart';
import 'package:persistence_drift/theme/theme_database.dart';

void main() {
  runThemeResourceStoreContractSuite(
    implementationName: 'Drift',
    makeStore: ({required scopeUid, required localReader}) async {
      // 造内存 drift 库（NativeDatabase.memory()）。
      final db = ThemeDatabase(NativeDatabase.memory());
      // 预置：generation 0 落地 bundled fixture（照 §6.2，用 putGeneration）。
      // ⚠ 契约套件注入的是 fake reader（CountingLocalReader/MutableLocalReader），
      // bundled/package token 走 reader 不走 DB，故无需预置 generation 1 与
      // 活跃指针 —— 真 reader -> DB 的路径由 A7 重启测试覆盖。
      await DriftThemeTokenStore(db).putGeneration(0, ThemeBenchFixture().bundledTokens);
      return DriftThemeResourceStore(
        scopeUid: scopeUid,
        db: db,
        localReader: localReader,
      );
    },
    makeBundledFixture: () => ThemeBenchFixture().bundledTokens,
    makePackageFixture: () => ThemeBenchFixture().packageTokens,
  );
}
