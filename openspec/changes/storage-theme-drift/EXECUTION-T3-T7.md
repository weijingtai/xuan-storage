# 执行指令：THEME-DRIFT 剩余实现（T3-T7）

> 权威派工：`~/Downloads/storage_refactor/DISPATCH-THEME-DRIFT.md`
> 立项纪要：`openspec/changes/storage-theme-drift/{proposal,design,tasks}.md`
> 已完成交接：`openspec/changes/storage-theme-drift/HANDOFF.md`（T0-T2 已交付并提交）
> 本文档取代 HANDOFF.md 作为 T3-T7 的执行依据（HANDOFF.md 的「下一个 agent 起始位置」段以本文为准）。

## 0. 起始状态确认（开工前必做，只读）

1. worktree：`cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/claude-storage-theme-drift`
2. 确认分支：`git branch --show-current` => `agent/claude/storage-theme-drift`
3. 确认基线：`cd drift && dart analyze 2>&1 | tail -1` => `146 issues found.`（= main 基线）；`cd core && dart analyze 2>&1 | tail -1` => `57 issues found.`
4. 确认 T0-T2 已提交：`git log --oneline -4` 应见 T1/T2/handoff 三个 commit。
5. 已交付文件（**不要改**）：`drift/lib/theme/{theme_database.dart, theme_database.g.dart, tables/*}` + `{drift_theme_token_store.dart, drift_theme_materializer.dart, drift_dataset_generation_store.dart}`。

**环境已 pub get，analyze 干净。改 schema 后才需重新 `dart run build_runner build`（全量，禁用 `--build-filter`）。**

---

## 1. 硬约束（违反即打回）

### 1.1 不许碰（撞车面 / 冻结面）
- ❌ 不改 `core/lib/model/dataset/*`（XRAP 契约，T1 已交付在用）
- ❌ 不删/不改 `core/lib/reference/in_memory_*` 的行为（内存版是 reference 与 fake）
- ❌ 不动 `drift/lib/persistence_drift.dart` 主库的 `schemaVersion`（保持 9）与 tables 列表
- ❌ 不碰 S1b/S1d/S3c/S6/T1 的任何文件
- ❌ 不做 BUILD-THEME（构建脚本，另有派工）、不做远端下发
- ❌ 不抢占已用 schemaVersion（v8=HLC, v9=blob；本任务用独立库 v1，与主库无关）

### 1.2 §八纪律（本仓已抓到过四次不实汇报）
1. **变红要红在对的地方**：注入变异后若红在编译失败而非目标断言，本次自检不算数
2. **不许为了让断言绿而改断言** -- `identical` 改 `==` 是最典型的作弊面
3. **覆盖是自己证的**：新分支若无测试真走到它，注变异不会红 = 没交付
4. **恒绿断言**：不许写在未 await 的 `.then()` / `.listen()` 回调里
5. **汇报一律贴机器输出**，查不出来写「未验证」，不许推测当结论
6. **每条新测试做过变异自检**，逐条写明「注入了什么、红在哪条断言上」

### 1.3 协同约束
另一个 AI agent 也在处理 Theme 相关问题。本任务**只新增** `drift/lib/theme/*` 与 `drift/test/theme/*`，以及 T5 的 `core/lib/test_support/theme_resource_store_contract_suite.dart`（新增）+ `core/test/theme_resource_store_contract_test.dart`（refactor 调套件，断言条数对齐）。绝不修改 `core/lib/reference/` 与 `core/lib/model/`。

---

## 2. 必读样板（动手前读，照做）

| 要做什么 | 读哪个文件 | 抄什么 |
|---|---|---|
| T3 local reader 六步无分支 | `core/lib/reference/theme_assembly.dart` 的 `XrapThemeLocalReader` | 六步逻辑 1:1 搬，只换数据源 |
| T4 store 行为本体 | `core/lib/reference/in_memory_theme_resource_store.dart` | resolve/缓存/超时/applyOverrides/watchResolved 全部行为 |
| T5 套件提取手法 | `core/lib/test_support/signaling_contract_suite.dart` | `runXxxContractSuite({required 工厂})` + group/test 结构 |
| 现有契约断言 | `core/test/theme_resource_store_contract_test.dart` | 4 条 store 行为用例（A10/A11/A12/A13 + shape/A16）逐条搬进套件 |
| 测试探针 | `core/test/support/theme_probes.dart` | `CountingLocalReader` / `SlowLocalReader`（A4 变异自检用） |
| T1 drift 世代 store | `assets/lib/geo/drift_dataset_installer.dart` | 已在 T2 照抄，T3 调用其 `active()` |
| fixture | `core/test/support/theme_bench_fixture.dart` | bundled/package tokens 的标准 fixture |

---

## 3. 任务 T3 -- drift 版 ThemeLocalReader

### 3.1 新建 `drift/lib/theme/drift_theme_local_reader.dart`

`implements ThemeLocalReader`，三方法，**逐方法对齐 `XrapThemeLocalReader`**（`core/lib/reference/theme_assembly.dart`），只把数据源从内存换成 drift：

- 构造器入参：`DriftThemeTokenStore tokenStore` + `DatasetInstaller installer`（用 `DriftThemeDatasetInstaller` 或测试 fake）+ `String scopeUid`（读覆盖表要用）。
- `readBundledTokens()`：
  - `final t = await tokenStore.tokensOf(0);`
  - `t == null` -> 抛 `StateError('generation 0 未落地：装配期漏调 ensureInstalled（§4.5 第 3 步）')`（fail closed，照 XrapThemeLocalReader）
  - 返回 `t`
- `readActiveThemeTokens(String themeId)`：**六步无分支**，照 XrapThemeLocalReader：
  1. `themeId != tokenStore.datasetId`（='theme.package'）-> 抛 `ArgumentError`
  2. `final active = await installer.active(themeDatasetId);`
     - ⚠ `themeDatasetId` 从 `core/lib/model/theme_dataset.dart` import（`const themeDatasetId = 'theme.package'`）。**只 import 常量，不改该文件。**
  3. `active == null || !active.isUsable` -> 返回 null
  4. `active.generation == 0` -> 返回 null（generation 0 归 bundled）
  5. `final t = await tokenStore.tokensOf(active.generation);` `t == null` -> 返回 null
  6. 返回 `t`
- `readOverrides()`：
  - 查 `t_theme_override` 表 where `scope_uid = scopeUid`
  - 每行还原成 `OverrideEntry(value: jsonDecode(value), origin: _originFrom(row), updatedAtUtc: row.updatedAtUtc)`
  - `_originFrom`：`originKind == 'manual'` -> `OverrideOrigin.manual`；`== 'package'` -> `OverrideOrigin.fromPackage(themeId: row.originThemeId, version: row.originThemeVersion)`
  - 返回 `Map<String, OverrideEntry>`

### 3.2 验证
- `cd drift && dart analyze lib/theme/` => 0 issue
- 不写测试（T6 统一写）

### 3.3 提交
`git commit -m "feat(theme-drift): T3 drift 版 ThemeLocalReader（六步无分支照 XrapThemeLocalReader）"`

---

## 4. 任务 T4 -- drift 版 ThemeResourceStore（核心，三条变异自检都在这）

### 4.1 新建 `drift/lib/theme/drift_theme_resource_store.dart`

`implements ThemeResourceStore`（端口在 `core/lib/model/theme_resource_store.dart`，先读它确认 7 个方法签名）。**行为 1:1 对齐 `InMemoryThemeResourceStore`**，差异只在存储后端 + 缓存/事务要显式建。

#### 字段
- `final ThemeDatabase _db;`
- `final String scopeUid;`
- `final ThemeLocalReader _reader;`（注入 `DriftThemeLocalReader`；测试可注入 fake）
- `ThemeTokenSet? _cache; String? _cacheThemeId; int _cacheRevision = -1;`（**D4 缓存层**，三元组键）
- `final StreamController<ThemeTokenSet> _controller = StreamController.broadcast();`
- `static const _activeReadTimeout = Duration(milliseconds: 30);`（P6）
- `_overridesRevision` 不再是内存计数器，而是**从覆盖表行数或一个单调值派生**。最简：用覆盖表的「最大 updated_at_utc 的毫秒数」或单独维护一个 revision 列。

  > ⚠ **设计选择**：内存版 `_overridesRevision` 是内存计数器，drift 版要在重启后仍能正确失效缓存。两个选项：
  > - **(a)** 在 `t_theme_selection` 表加一列 `overrides_revision INTEGER`，每次 apply/remove 在事务内 +1。简单、持久。
  > - **(b)** 缓存键改用「覆盖表行数 + 最大 updated_at_utc」，不维护计数器。
  > **推荐 (a)**：与内存版语义最一致，缓存键直接可比。若选 (a)，需在 T1 的 `theme_selection_table.dart` 加列并重新 build_runner（**改了表就要重跑生成 + 重新提交 .g.dart**）。
  > **决定权在执行 agent**，但必须在 commit message 与 design.md 补一条 D8 说明选了哪个。

#### `resolve({Object? cancel})`
完全照 `InMemoryThemeResourceStore.resolve`：
1. `bundled = await _reader.readBundledTokens();`
2. `baseOverrides = await _reader.readOverrides();`
3. `applied = await _readAppliedOverridesFromDb();`（查 t_theme_override where scope_uid）
4. `overrides = {...baseOverrides, ...applied};`
5. `themeId = (await _readSelection()) ?? themeDatasetId;`
6. `packageTokens = await _readActiveWithTimeout(themeId);`
7. `activeThemeId = packageTokens == null ? null : themeId;`
8. **缓存命中判定**：`_cache != null && _cacheThemeId == activeThemeId && _cacheRevision == (await _readOverridesRevision())` -> `return _cache!;`（**identical**）
9. 算 `selectionOrigin`（照内存版三分支）
10. `result = mergeThemeTokens(...)`（`mergeThemeTokens` 从 `core/lib/reference/theme_token_merger.dart` import，**不改它**）
11. `_cache = result; _cacheThemeId = activeThemeId; _cacheRevision = await _readOverridesRevision();`
12. `return result;`

#### `_readActiveWithTimeout(themeId)`
照内存版：`_reader.readActiveThemeTokens(themeId).timeout(_activeReadTimeout, onTimeout: () => null);`

#### `applyOverrides({required Map<String,dynamic> patch, required OverrideOrigin origin})`
**D5 单事务原子**，照内存版两段：
1. **校验段**（事务外）：`for (entry in patch) if (entry.value is Map) throw StateError('覆盖值不得为 Map...: ${entry.key}');`
2. **写入段**（单事务）：
   ```
   await _db.transaction(() async {
     final now = DateTime.now().toUtc();
     for (entry in patch) {
       await _db.into(_db.themeOverrides).insertOnConflictUpdate(
         ThemeOverridesCompanion.insert(
           scopeUid: scopeUid,
           tokenKey: entry.key,
           value: jsonEncode(entry.value),
           originKind: origin.kind,
           originThemeId: Value(origin.sourceThemeId),
           originThemeVersion: Value(origin.sourceThemeVersion),
           updatedAtUtc: now,
         ),
       );
     }
     // revision++（若选 D8-a）
     await _bumpOverridesRevision();
   });
   ```
3. `await _refreshAndNotify();`

#### `removeOverrides(Set<String> tokenKeys)`
照内存版（幂等）：
```
await _db.transaction(() async {
  for (key in tokenKeys) {
    await (_db.delete(_db.themeOverrides)
      ..where((t) => t.scopeUid.equals(scopeUid) & t.tokenKey.equals(key))).go();
  }
  await _bumpOverridesRevision();
});
await _refreshAndNotify();
```

#### `selectTheme(String themeId)` / `clearThemeSelection()`
- 照内存版：themeId 必须在 listLocalThemes 中（reference 阶段 = themeDatasetId，否则抛 StateError）
- 写 t_theme_selection（upsert / delete selected_theme_id 置 null）
- `await _refreshAndNotify();`

#### `listLocalThemes()`
照内存版：bundled（generation 0，displayName '内置默认主题'）+ 若 `await _readActiveWithTimeout(themeDatasetId) != null` 则加 '已安装主题包'。

#### `listOverrides()`
`base = await _reader.readOverrides(); applied = await _readAppliedOverridesFromDb(); return {...base, ...applied};`（unmodifiable）

#### `watchResolved()`
`return _controller.stream;`

#### `_refreshAndNotify()`
照内存版：`if (_controller.isClosed) return;` 失效缓存（`_cache=null; _cacheThemeId=null; _cacheRevision=-1;`）-> `_controller.add(await resolve());`

### 4.2 验证
- `dart analyze lib/theme/` => 0 issue

### 4.3 提交
`git commit -m "feat(theme-drift): T4 drift 版 ThemeResourceStore（identical 缓存/30ms 超时/事务原子 applyOverrides/watchResolved）"`

---

## 5. 任务 T5 -- 契约套件提取（refactor，无行为变化）

### 5.1 新建 `core/lib/test_support/theme_resource_store_contract_suite.dart`

照 `signaling_contract_suite.dart` 的形态。**关键**：现有契约测试里 4 条 store 行为用例用了两个私有探针 `_MutableLocalReader` 和 `CountingLocalReader`（在 `theme_probes.dart`，已是 test_support 等价物）+ `ThemeBenchFixture`。套件要参数化「如何造 store」。

签名设计（照 signaling 的 `runSignalingContractSuite`）：

```dart
FutureOr<void> runThemeResourceStoreContractSuite({
  required String implementationName,
  required ThemeResourceStore Function({
    required String scopeUid,
    required ThemeLocalReader localReader,
  }) makeStore,
  required Map<String, dynamic> Function() makeBundledFixture,
  required Map<String, dynamic> Function()? makePackageFixture,
}) {
  group('契约 · $implementationName', () {
    // 搬 4 条 store 行为用例（A10/A11/A12/A13 + shape/A16）
    // 把 `InMemoryThemeResourceStore(scopeUid: 'u1', localReader: X)` 
    // 改成 `makeStore(scopeUid: 'u1', localReader: X)`
    // 其余（fixture、_MutableLocalReader、CountingLocalReader、_valueAt、_leafCount）原样用
  });
}
```

⚠ **要点**：
- `_MutableLocalReader` 和 `CountingLocalReader` 和 `ThemeBenchFixture` 都在 `core/test/` 下，套件在 `core/lib/test_support/`。**test_support 不能 import test/**。解决：把 `_MutableLocalReader` 也提到 `theme_probes.dart`（它已经是 test_support 性质的文件，但在 test/ 下）。
  > **决定**：检查 `theme_probes.dart` 是否能被 lib import。若不能，则把 `CountingLocalReader` + 新增 `MutableLocalReader` 提到 `core/lib/test_support/theme_probes.dart`（新增 lib 版），test/ 下的 `theme_probes.dart` 改为 re-export 或删除。**执行 agent 判断最小改动**，但必须保证套件能 import 到这两个探针。
- 套件不含「ACT 02 主门面 / ACT 01 数据结构」那两组（它们断言的是源码文件本身，与 store 实现无关，留在原 test 文件）。

### 5.2 改 `core/test/theme_resource_store_contract_test.dart`

- 删掉「ACT 06 store 行为」那组 4 条用例
- 改为调套件：
  ```dart
  void main() {
    runThemeResourceStoreContractSuite(
      implementationName: 'InMemory',
      makeStore: ({required scopeUid, required localReader}) =>
          InMemoryThemeResourceStore(scopeUid: scopeUid, localReader: localReader),
      makeBundledFixture: () => ThemeBenchFixture().bundledTokens,
      makePackageFixture: () => ThemeBenchFixture().packageTokens,
    );
    // 保留 ACT 02 / ACT 01 两组（源码断言 + 数据结构）
    group('ACT 02 主门面...', () { ... });
    group('ACT 01 中立数据结构...', () { ... });
  }
  ```

### 5.3 验证（A10 内存版测试一条不少）
- `cd core && flutter test test/theme_resource_store_contract_test.dart` => 全绿
- **断言条数对齐**：跑前后对比 `flutter test --reporter expanded` 的 test 数，内存版的 4 条 store 行为用例必须一条不少（只是换成了套件调用）。若条数减少，说明套件漏搬，打回。

### 5.4 提交
`git commit -m "refactor(theme-drift): T5 提取主题契约套件到 test_support（内存版断言条数对齐，A10）"`

---

## 6. 任务 T6 -- drift 版契约测试 + A7 重启测试 + 装配入口

### 6.1 新建 `drift/lib/theme/theme_assembly_drift.dart`

照 `core/lib/reference/theme_assembly.dart` 的 `assembleThemeStore` 四步，**并存不替换**（design.md D7）：

```dart
Future<ThemeResourceStore> assembleThemeStoreDrift({
  required String scopeUid,
  required ThemeDatabase db,
  required DatasetInstaller installer,
  required DatasetSource? bundledSource,  // 传给 DriftThemeDatasetInstaller
}) async {
  final tokenStore = DriftThemeTokenStore(db);
  ThemeModuleRegistry.register(
    themeMaterializer: () => DriftThemeMaterializer(tokenStore),
  );
  await installer.ensureInstalled(themeDatasetId);
  return DriftThemeResourceStore(
    scopeUid: scopeUid,
    db: db,
    localReader: DriftThemeLocalReader(
      tokenStore: tokenStore,
      installer: installer,
      scopeUid: scopeUid,
    ),
  );
}
```

### 6.2 新建 `drift/test/theme/theme_resource_store_contract_test.dart`

调套件，drift 版跑同一套：
```dart
void main() {
  runThemeResourceStoreContractSuite(
    implementationName: 'Drift',
    makeStore: ({required scopeUid, required localReader}) async {
      // 造内存 drift 库（NativeDatabase.memory()）
      final db = ThemeDatabase(NativeDatabase.memory());
      // 预置：generation 0 落地 bundled fixture（用 DriftThemeMaterializer 或直接 putGeneration）
      // 预置：若有 packageFixture，落一个 generation 1 + setActiveGeneration
      return DriftThemeResourceStore(scopeUid: scopeUid, db: db, localReader: localReader);
    },
    makeBundledFixture: () => ThemeBenchFixture().bundledTokens,
    makePackageFixture: () => ThemeBenchFixture().packageTokens,
  );
}
```
⚠ drift 版的 `makeStore` 要 async（造库是异步的），套件签名若 `makeStore` 是同步返回，需调整套件签名为 `Future<ThemeResourceStore> Function(...)`。**执行 agent 统一套件与两处调用的签名**。

### 6.3 新建 `drift/test/theme/theme_restart_test.dart`（A7，本任务存在的理由）
```dart
test('A7_重启后主题仍在', () async {
  // 1. 造库 A（文件库，不是 memory），写入：
  //    - selectTheme('theme.package')
  //    - applyOverrides({'light.components.x.y': 'o1'})
  // 2. resolve() 拿到 result1
  // 3. 关库 A（await db.close()）
  // 4. 用同一文件路径重开库 B
  // 5. resolve() 拿到 result2
  // 6. 断言 result2 与 result1 的 token 值一致（覆盖值 'o1' 仍在、选择仍在）
});
```
用 `NativeDatabase(File(tmpPath))` 而非 `memory()`。tmpPath 用 `Directory.systemTemp`。

### 6.4 新建 `drift/test/theme/theme_materializer_test.dart`
照 `core/test/theme_materializer_test.dart`，验证 `DriftThemeMaterializer` 落地 `.jsonl` 后 `tokenStore.tokensOf(g)` 返回正确 Map；v 为 Map 抛 StateError。

### 6.5 三条变异自检（A8，逐条做并写明）

**这三条是本任务的真验收门槛。每条：注入变异 -> 跑测试 -> 确认红在目标断言（不是编译失败）-> 恢复 -> 绿。**

#### A3 变异自检（identical 缓存）
- **测试**（在 `drift/test/theme/theme_resource_store_contract_test.dart` 或单独 `theme_cache_test.dart`）：
  ```dart
  test('A3_同 key 重复 resolve 返回 identical 对象', () async {
    final store = await makeStore(...);
    final r1 = await store.resolve();
    final r2 = await store.resolve();
    expect(identical(r1, r2), isTrue);  // ← 不许改成 ==
  });
  ```
- **变异**：注释掉 `resolve()` 里的缓存命中 `if (_cache != null && ...) return _cache!;`（让它每次重算）
- **预期红**：`identical(r1, r2)` 断言失败
- **恢复**：取消注释 -> 绿
- **记录**：commit message 或测试注释里写「变异：拆缓存 -> 红在 identical 断言」

#### A4 变异自检（30ms 超时降级）
- **测试**：
  ```dart
  test('A4_活跃世代慢读取 30ms 超时降级到 bundled', () async {
    final store = DriftThemeResourceStore(
      scopeUid: 'u1', db: db,
      localReader: SlowLocalReader(fixture.bundledTokens),  // readActiveThemeTokens 永不完成
    );
    final sw = Stopwatch()..start();
    final r = await store.resolve();
    expect(sw.elapsedMilliseconds, lessThan(50));  // 50ms 内返回
    // 降级到 bundled（无 packageTokens）
    expect(r.resolution.selectionOrigin, ThemeSelectionOrigin.bundledFallback);
  });
  ```
- **变异**：把 `_activeReadTimeout` 改成 `Duration(minutes: 1)` 或注释掉 `.timeout(...)`
- **预期红**：`lessThan(50)` 断言超时失败（测试会 hang 到 timeout）
- **恢复**->绿
- **记录**

#### A5 变异自检（applyOverrides 原子）
- **测试**：
  ```dart
  test('A5_applyOverrides 中途失败不留半套', () async {
    final store = await makeStore(...);
    await store.applyOverrides(patch: {'k1': 'a'}, origin: OverrideOrigin.manual);
    // 注入中途异常：patch 含一个会触发 Map 校验的非法条目
    await expectLater(
      store.applyOverrides(
        patch: {'k2': 'b', 'k3': <String,dynamic>{}},  // k3 是 Map -> 校验抛
        origin: OverrideOrigin.manual,
      ),
      throwsA(isA<StateError>()),
    );
    final list = await store.listOverrides();
    expect(list.containsKey('k2'), isFalse);  // ← k2 不该留下（原子回滚）
  });
  ```
- **变异**：把 `applyOverrides` 的写入从单事务改成逐条写（去掉 `await _db.transaction(() async {...})`，直接循环 `await _db.into(...).insertOnConflictUpdate(...)`）
- **预期红**：`containsKey('k2')` 为 isTrue（k2 留下了半套），断言失败
  - ⚠ **注意**：内存版靠「先校验后写」天然原子；drift 版的原子性来自事务。若校验段在事务外已拦住 Map，则 A5 变异要构造「写入段中途失败」（如 mock 一个第二条 insert 抛异常），而非靠 Map 校验。**执行 agent 必须确保变异真的测到「事务回滚」而非「校验前置」**，否则自检不算数（§八第 3 条）。
- **恢复**->绿
- **记录**

### 6.6 验证
- `cd drift && flutter test test/theme/` => 全绿（含三条变异自检已恢复后绿）
- `cd drift && dart analyze test/theme/` => 0 issue

### 6.7 提交（可分多个 commit）
`git commit -m "feat(theme-drift): T6 drift 装配入口 + 契约测试 + A7 重启测试 + 三条变异自检（A2-A8）"`

---

## 7. 任务 T7 -- 全门禁验收

### 7.1 验收命令（逐条跑，贴机器输出）

```
bash scripts/run_s1a_analyze_gate.sh
bash scripts/run_s1b_analyze_gate.sh
bash scripts/run_monorepo_convention_check.sh
bash scripts/run_s5a_analyze_gate.sh
bash scripts/run_s5a_residue_gate.sh
(cd core && flutter test)
(cd drift && flutter test)
(cd p2p && flutter test)
(cd firebase && flutter test)
```

### 7.2 基线（只增不减，派工 §七）

| 项 | main 基线 | 要求 |
|---|---|---|
| core 测试 | 256 | ≥ 256 |
| drift 测试 | 401 | ≥ 401（T6 新增主题测试应让它涨） |
| p2p 测试 | 62 + 1 skip | ≥ 62 + 1 skip |
| firebase 测试 | 131 + 4 skip | ≥ 131 + 4 skip |
| S1a 全包 issue | 57 | ≤ 57 |
| dartdoc 下限 | 161 | ≥ 161 |

### 7.3 已知坑（派工 §九，不要改基线）
- `run_s1b_analyze_gate.sh` 的 drift 基线 146 在深层 worktree 恒红 149（`../../` sibling 路径 `path_does_not_exist`，main 同深度也是 149）。**与己无关，别改这个基线。**
- 若 analyze 报 500+ `uri_does_not_exist` -> 新 worktree 没 pub get（已 get 过，但若切包要重 get）。
- 若报 `.pub-cache` 类型不匹配/重复定义 -> 陈旧 lock，`rm pubspec.lock && flutter pub get`。

### 7.4 最终提交
`git commit -m "docs(theme-drift): T7 全门禁验收通过（基线只增不减）"`

若有门禁红，**不许改基线让门禁假绿**（§八）。先定位是真回归还是环境坑。

---

## 8. 验收清单（派工 §七，逐条对照）

- [ ] **A1** 主题表落地，schema 决策已论证（design.md D1，已人类确认）✅ 立项时完成
- [ ] **A2** drift 版跑通与内存版同一套契约测试，全绿（T5+T6）
- [ ] **A3** identical 缓存 + 变异自检（T4 实现 + T6 自检）
- [ ] **A4** 30ms 超时降级 + 变异自检（T4 实现 + T6 自检）
- [ ] **A5** applyOverrides 原子 + 变异自检（T4 实现 + T6 自检）
- [ ] **A6** watchResolved 推送（T4 实现 + T6 测试）
- [ ] **A7** 重启后主题仍在（T6 theme_restart_test）
- [ ] **A8** 每条新测试做过变异自检，写明注入什么/红在哪
- [ ] **A9** 既有门禁全绿，S1a 57 未抬高，dartdoc 161 未调低
- [ ] **A10** 四包测试只增不减；内存版测试一条不少（T5 对齐）

---

## 9. 停止条件（遇到就停，报告人类）

- §四裁定被质疑（选 A 已确认，若执行中发现 A 不成立的硬证据）
- T5 套件提取导致内存版断言条数减少且无法对齐
- T4 的 identical/超时/原子三条中任一变异自检无法红在对的地方（§八第 1 条）
- 任何门禁基线需要被「调低」才能绿（这是作弊面）
- 与另一个 Theme agent 在 `core/lib/reference/` 或 `core/lib/model/` 产生冲突

---

## 10. 一句话启动语（给执行 agent）

> 读 `openspec/changes/storage-theme-drift/EXECUTION-T3-T7.md`（本文）后，从 T3 开始，按 §3-§7 顺序执行；T0-T2 已交付，不要重做。
