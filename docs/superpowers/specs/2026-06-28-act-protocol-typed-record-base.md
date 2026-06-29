# ACT 协议文档 — 类型安全可复用记录存储 Base

> 生成日期: 2026-06-28
> 源设计文档:
> - `docs/superpowers/specs/2026-06-25-record-storage-base-class-design.md`
> - `docs/superpowers/specs/2026-06-27-scope-uid-identity-binding-design.md`
> - `docs/superpowers/specs/2026-06-28-module-record-repository-analysis.md`
>
> 本文件包含 7 个 ACT 任务，按依赖顺序排列。每个任务自包含，零背景 agent 可独立执行。

---

## ACT-1: Phase 1 — 接口与 fake

```yaml
TASK_ID: "typed-record-phase1-ports-and-fakes"
LANG: "dart"
TARGET_FILE: "repository-interface-record/lib/src/ports/"
CONTEXT:
  DOMAIN: |
    统一记录存储系统当前有两个端口文件:
    - record_repository.dart: RecordRepository 接口 (saveRecord/getRecord/listRecords/softDeleteRecord/watchRecords)
    - module_record_adapter.dart: ModuleRecordAdapter 接口 (module/category/divinationType/toRecord/fromRecord/extractSearchTags)

    现有接口缺陷:
    1. getRecord(uuid) 不带 module 参数 → 跨模块 UUID 碰撞风险
    2. softDeleteRecord(uuid) 不带 module 参数 → 同上
    3. 无索引查询端口 → Base 被迫直查 Drift 表，绕过 scope 过滤
    4. ModuleRecordAdapter 输入输出为 Object → 运行时 as 转型，无编译期类型安全
    5. 无 scope-bound 的统一 store 接口

  STRATEGY: |
    新增 4 个端口文件，修订 1 个。不删除 ModuleRecordAdapter（保持向后兼容）。
    所有新增类型使用 abstract interface class。
    导入路径使用 package: 前缀。

TASK_DEPS: []

COMMANDS:
  PRECHECK: |
    dart analyze repository-interface-record/lib/src/ports/

  STEP_1: |
    创建 record_search_tag_extractor.dart:
    非泛型标签提取端口，供异构注册表使用。
    与 ModuleRecordAdapter.extractSearchTags 签名一致但独立于泛型 codec。

  STEP_1_CONTENT: |
    import '../models/record_meta.dart';
    import '../models/search_tag.dart';

    /// Non-generic search-tag extraction interface.
    ///
    /// The [RecordAdapterRegistry] stores one of these per module so it can
    /// regenerate search tags from saved records without knowing the module's
    /// contract type.
    abstract interface class RecordSearchTagExtractor {
      String get module;

      List<SearchTag> extractSearchTags(
        RecordMeta meta,
        Map<String, dynamic>? moduleData,
      );
    }

  STEP_2: |
    创建 record_module_codec.dart:
    类型安全模块 codec，泛型 TContract 提供编译期类型安全。
    同时实现 RecordSearchTagExtractor，同一实例可注册到异构注册表。

  STEP_2_CONTENT: |
    import '../models/record_meta.dart';
    import 'record_search_tag_extractor.dart';

    /// Result of encoding a module contract into a [RecordMeta].
    typedef EncodedRecord = ({
      RecordMeta meta,
      Map<String, dynamic>? moduleData,
    });

    /// Type-safe codec for converting between a module's contract type
    /// [TContract] and the unified [RecordMeta] storage model.
    abstract interface class RecordModuleCodec<TContract>
        implements RecordSearchTagExtractor {
      String get category;
      String get divinationType;

      /// Returns the UUID of [contract] (may be empty for unsaved records).
      String uuidOf(TContract contract);

      /// Returns a copy of [contract] with the UUID replaced by [uuid].
      TContract withUuid(TContract contract, String uuid);

      /// Encodes [contract] into a [RecordMeta] and optional module data.
      /// [RecordMeta.module] must equal [module].
      /// [RecordMeta.scopeUid] must equal [scopeUid].
      EncodedRecord encode(TContract contract, {required String scopeUid});

      /// Decodes a [RecordMeta] back into [TContract].
      /// Must throw [RecordCodecMismatch] if [meta.module] != [module].
      TContract decode(RecordMeta meta, Map<String, dynamic>? moduleData);
    }

    /// Thrown when encode/decode encounters module/scope/category mismatch.
    class RecordCodecMismatch implements Exception {
      final String message;
      const RecordCodecMismatch({required this.message});
      @override
      String toString() => 'RecordCodecMismatch: $message';
    }

  STEP_3: |
    创建 record_index_repository.dart:
    Scope-bound 索引查询端口。实现自动按 scope 过滤。

  STEP_3_CONTENT: |
    import '../models/record_meta.dart';

    abstract interface class RecordIndexRepository {
      Future<List<RecordMeta>> findByIndex({
        required String module,
        required String indexKey,
        required String indexValue,
        required int limit,
      });

      Stream<List<RecordMeta>> watchByIndex({
        required String module,
        required String indexKey,
        required String indexValue,
      });
    }

  STEP_4: |
    创建 scoped_record_store.dart:
    将 RecordRepository + RecordIndexRepository 绑定到单一 scope。
    Base 依赖此接口而非分别依赖两个端口。

  STEP_4_CONTENT: |
    import 'record_repository.dart';
    import 'record_index_repository.dart';

    abstract interface class ScopedRecordStore
        implements RecordRepository, RecordIndexRepository {
      String get scopeUid;
    }

  STEP_5: |
    修订 record_repository.dart:
    在 getRecord/softDeleteRecord 中增加 required String module 参数。
    listRecords 的 module 改为 required。
    watchRecords 的 module 改为 required。

  STEP_5_CONTENT: |
    import '../models/record_meta.dart';

    abstract interface class RecordRepository {
      Future<void> saveRecord(RecordMeta record, {Map<String, dynamic>? moduleData});

      /// Scoped to current scope + [module].
      Future<RecordMeta?> getRecord(String uuid, {required String module});

      /// Scoped to current scope + [module]. Ordered createdAt DESC, uuid ASC.
      Future<List<RecordMeta>> listRecords({
        required String module,
        String? category,
        String? divinationType,
        required int limit,
        String? cursor,
      });

      /// Scoped to current scope + [module].
      Future<bool> softDeleteRecord(String uuid, {required String module});

      /// Streams all non-deleted records for [module] in current scope.
      Stream<List<RecordMeta>> watchRecords({required String module});
    }

  STEP_6: |
    更新 barrel 文件 repository_interface_record.dart:
    新增 export 四个新端口。

  STEP_6_CONTENT: |
    export 'src/models/record_meta.dart';
    export 'src/models/search_tag.dart';
    export 'src/ports/record_repository.dart';
    export 'src/ports/record_search_tag_extractor.dart';
    export 'src/ports/record_module_codec.dart';
    export 'src/ports/record_index_repository.dart';
    export 'src/ports/scoped_record_store.dart';
    export 'src/ports/module_record_adapter.dart';  // 保留向后兼容
    export 'src/fakes/in_memory_record_repository.dart';

  STEP_7: |
    更新 in_memory_record_repository.dart:
    适配修订后的 RecordRepository 接口 (module 参数)。
    同时实现 RecordIndexRepository，基于内存索引查询。

PROHIBITED:
  - 删除或重命名 ModuleRecordAdapter（保持向后兼容）
  - 修改 RecordMeta 或 SearchTag 模型
  - 引入 package:drift 依赖
  - 在端口文件中包含实现代码

ABSOLUTELY_PROHIBITED:
  - 修改 t_record_meta 或 t_record_search_index 表结构

ASSERTIONS:
  EXECENV: "dart analyze repository-interface-record/ 零错误"
  CASES:
    - "RecordModuleCodec<T> 可被具体 codec 类 implements"
    - "ScopedRecordStore 同时满足 RecordRepository 和 RecordIndexRepository 类型约束"
    - "RecordSearchTagExtractor 可独立于 RecordModuleCodec 使用"
    - "现有 ModuleRecordAdapter 实现类不受影响"

PROTOCOL:
  MODE: "write-files-only"
  NO_PROSE: true
  OUTPUT_FORMAT: "每个 STEP 产出对应的 .dart 文件"

VERIFICATION: "cd repository-interface-record && dart analyze && dart test"
```

---

## ACT-2: Phase 2 — Drift scope 修复与 index query

```yaml
TASK_ID: "typed-record-phase2-drift-scope-fix"
LANG: "dart"
TARGET_FILE: "xuan-storage/drift/lib/record/"
CONTEXT:
  DOMAIN: |
    DriftRecordDataSource 是统一记录存储的 SQL 实现层:
    - 持有 PersistenceDriftDatabase db 和 final String scopeUid
    - 所有查询已带 scopeUid 过滤
    - saveRecord 在同一事务中写 t_record_meta + t_record_search_index

    当前缺陷:
    1. softDeleteRecord 删除 search_index 时未过滤 scopeUid
    2. 无 findByIndex/watchByIndex 方法
    3. LocalRecordRepository 未暴露 scopeUid 和 index 方法

    已有基础设施:
    - t_record_meta 表: uuid(PK), scope_uid, module, category, divination_type, ...
    - t_record_search_index 表: record_uuid, scope_uid, module, index_key, index_value
    - RecordCursor: 游标编解码

  STRATEGY: |
    在 DriftRecordDataSource 中新增两个方法，修复一个缺陷。
    在 LocalRecordRepository 中暴露新方法。
    不修改表结构。

TASK_DEPS: ["typed-record-phase1-ports-and-fakes"]

COMMANDS:
  PRECHECK: |
    dart analyze xuan-storage/drift/lib/record/

  STEP_1: |
    确保 DriftRecordDataSource 有 findByIndex 方法:
    使用 INNER JOIN t_record_search_index，一次性返回完整 RecordMeta。
    过滤条件: scopeUid + module + indexKey + indexValue + deletedAt IS NULL。
    排序: createdAt DESC, uuid ASC。
    使用 limit 参数，禁止 N+1 查询。
    若方法已存在，验证签名和 scope 过滤正确性。

  STEP_1_CONTENT: |
    /// Returns [RecordMeta] rows matching index query via JOIN.
    /// Scope-isolated; no N+1 UUID lookups.
    Future<List<RecordMeta>> findByIndex({
      required String module,
      required String indexKey,
      required String indexValue,
      int limit = 50,
    }) async {
      final metaAlias = db.tRecordMeta;
      final idxAlias = db.tRecordSearchIndex;
      final q = db.select(metaAlias).join([
        innerJoin(idxAlias, idxAlias.recordUuid.equalsExp(metaAlias.uuid))
      ]);
      q.where(metaAlias.scopeUid.equals(scopeUid) &
          metaAlias.deletedAt.isNull() &
          idxAlias.module.equals(module) &
          idxAlias.scopeUid.equals(scopeUid) &
          idxAlias.indexKey.equals(indexKey) &
          idxAlias.indexValue.equals(indexValue));
      q.orderBy([OrderingTerm.desc(metaAlias.createdAt), OrderingTerm.asc(metaAlias.uuid)]);
      q.limit(limit);
      final rows = await q.map((row) => row.readTable(metaAlias)).get();
      return rows.map(_toMeta).toList();
    }

  STEP_2: |
    确保 DriftRecordDataSource 有 watchByIndex 方法:
    与 findByIndex 相同的 JOIN + WHERE，但返回 Stream。
    使用 Drift 的 .watch() 自动监听变更。
    若方法已存在，验证签名和 scope 过滤正确性。

  STEP_2_CONTENT: |
    /// Streams [RecordMeta] rows matching index query.
    /// Uses Drift .watch() — does NOT simulate via full-table scan.
    Stream<List<RecordMeta>> watchByIndex({
      required String module,
      required String indexKey,
      required String indexValue,
    }) {
      final metaAlias = db.tRecordMeta;
      final idxAlias = db.tRecordSearchIndex;
      final q = db.select(metaAlias).join([
        innerJoin(idxAlias, idxAlias.recordUuid.equalsExp(metaAlias.uuid))
      ]);
      q.where(metaAlias.scopeUid.equals(scopeUid) &
          metaAlias.deletedAt.isNull() &
          idxAlias.module.equals(module) &
          idxAlias.scopeUid.equals(scopeUid) &
          idxAlias.indexKey.equals(indexKey) &
          idxAlias.indexValue.equals(indexValue));
      q.orderBy([OrderingTerm.desc(metaAlias.createdAt)]);
      return q.map((row) => row.readTable(metaAlias)).watch().map((rows) => rows.map(_toMeta).toList());
    }

  STEP_3: |
    修复 softDeleteRecord:
    在删除 t_record_search_index 的 WHERE 中增加 scopeUid 过滤。

  STEP_3_CONTENT: |
    Future<bool> softDeleteRecord(String uuid) {
      return db.transaction(() async {
        final n = await (db.update(db.tRecordMeta)
              ..where((t) => t.uuid.equals(uuid) & t.scopeUid.equals(scopeUid)))
            .write(TRecordMetaCompanion(deletedAt: Value(DateTime.now())));
        await (db.delete(db.tRecordSearchIndex)
              ..where((t) => t.recordUuid.equals(uuid) & t.scopeUid.equals(scopeUid)))
            .go();
        return n > 0;
      });
    }

  STEP_4: |
    在 LocalRecordRepository 中:
    - 确认已有 scopeUid getter (委托给 _ds.scopeUid)
    - 确认已有 findByIndex/watchByIndex 方法 (委托给 _ds)
    - 确保签名与 Phase 1 的 ScopedRecordStore 端口匹配

  STEP_4_CONTENT: |
    String get scopeUid => _ds.scopeUid;

    Future<List<RecordMeta>> findByIndex({
      required String module, required String indexKey,
      required String indexValue, int limit = 50,
    }) => _ds.findByIndex(module: module, indexKey: indexKey, indexValue: indexValue, limit: limit);

    Stream<List<RecordMeta>> watchByIndex({
      required String module, required String indexKey,
      required String indexValue,
    }) => _ds.watchByIndex(module: module, indexKey: indexKey, indexValue: indexValue);

PROHIBITED:
  - 修改 t_record_meta 或 t_record_search_index 表结构
  - 在 findByIndex 中逐条调用 getRecord (N+1)
  - 在 watchByIndex 中使用 watchRecords + filter 模拟
  - 移除现有 saveRecord 事务中的任何步骤

ABSOLUTELY_PROHIBITED:
  - 在非 DriftRecordDataSource 的类中直接访问 db.tRecordSearchIndex

ASSERTIONS:
  EXECENV: "dart analyze xuan-storage/drift/lib/record/ 零错误"
  CASES:
    - "findByIndex 查询带 scopeUid 过滤"
    - "watchByIndex 使用 JOIN + .watch() 而非全表 watch"
    - "softDeleteRecord 删除索引时过滤 scopeUid"

PROTOCOL:
  MODE: "edit-files-only"
  NO_PROSE: true
  OUTPUT_FORMAT: "修改 drift_record_data_source.dart 和 local_record_repository.dart"

VERIFICATION: "dart analyze xuan-storage/drift/lib/record/ | grep -c 'No issues found'"
```

---

## ACT-3: Phase 2.5 — Scoped PID 身份体系

```yaml
TASK_ID: "typed-record-phase2.5-scoped-pid"
LANG: "dart"
TARGET_FILE: "xuan-storage/drift/lib/scope/"
CONTEXT:
  DOMAIN: |
    scope_uid 是多租户隔离红线。当前被硬编码为模块名 (scopeUid: 'meihua')。

    Scoped PID 方案核心:
    scope_uid 是首次启动铸造的本地代理键 (UUIDv7)，终生不变。
    所有身份 (guest UID / user ID / device ID) 都只是指向它的别名。
    身份变化 (匿名→登录) = 改别名，记录原地不动。

    已有基础设施:
    - DriftRecordDataSource.scopeUid 是构造期固定的 final 字段
    - t_record_meta 有 scope_uid 列，所有查询都按 scope_uid 过滤
    - AccountSession / AccountSessionRepository 已实现
    - AccountIdentityLink / AccountIdentityLinkRepository 已实现 (InMemory)
    - AuthCoordinator 注册时已写入 AccountIdentityLink(guest→registered)
    - GuestAccountConflictDelegate 已实现

    本期交付完整的 Scoped PID 身份体系:
    - ScopeResolver: 所有 scope 取值的唯一出口，空值一票否决
    - ScopeLedger: 别名账本 CRUD 接口
    - t_scope_alias 表: identity → scope_uid 映射 (Drift schema migration)
    - Ghost bootstrap: 首启铸 UUIDv7 scope_uid (通过端口持久化)
    - bind-on-upgrade: 匿名→注册 = INSERT alias (O(1)，不动记录)

    不包含 (留给 Phase 5+):
    - session epoch 重绑
    - 冲突合并逻辑
    - 按 scope 加密
    - 云端 owner 层
    - DeviceIdentityProvider 实现

    错误传播约定:
    - ScopeResolver.resolve() 在 appUserId 为空时抛 StateError
    - Phase 3 的 DI 装配 (ACT-4) 必须 catch StateError 并降级到 device scope
    - ScopeResolver 内部不 catch 自己抛出的异常

  STRATEGY: |
    Phase 2.5 交付 6 个源文件 + 2 个测试文件 + 1 个 barrel 导出:
    源文件 (xuan-storage/drift/lib/scope/):
      1. scope_alias_entry.dart — 别名条目模型 (ScopeAuthKind 枚举)
      2. scope_bootstrap_store.dart — Ghost scope 持久化端口 + InMemory 实现
      3. scope_ledger.dart — 别名账本接口 (scopeForIdentity/bind/mintAndBind)
      4. scope_resolver.dart — 唯一 scope 出口 (resolve 算法，6 个分支)
      5. drift_scope_alias_table.dart — Drift 表 TScopeAlias 定义
      6. drift_scope_ledger.dart — ScopeLedger 的 Drift 实现
    测试文件 (xuan-storage/drift/test/scope/):
      7. scope_resolver_test.dart — 8 个场景覆盖 resolve 算法
      8. drift_scope_ledger_test.dart — 6 个场景覆盖别名 CRUD
    修改文件:
      9. persistence_drift.dart — schemaVersion 2→3, 注册 t_scope_alias 表
     10. barrel file — 导出 scope 模块公共 API

    ScopeResolver.resolve() 算法:
      1. session == null → 返回 deviceScope (登出/未登录)
      2. appUserId 为空 → 抛 StateError (C3 空值守卫)
      3. scopeForIdentity(appUserId) 命中 → 返回已有 scope
      4. deviceScope 未被占用 → bind (首次注册)
      5. deviceScope 被占用但有 AccountIdentityLink → bind (升级，O(1))
      6. deviceScope 被占用且无 link → mintAndBind (真冲突)

    ScopeBootstrapStore 是端口: xuan-storage/drift 不依赖 SharedPreferences，
    app 层提供生产实现 (SharedPreferences)。scope 模块内提供 InMemory 实现供测试。

    schema migration: PersistenceDriftDatabase schemaVersion 2→3，
    onUpgrade 中创建 t_scope_alias 表 (纯 additive)。

TASK_DEPS: []

COMMANDS:
  PRECHECK: |
    dart analyze xuan-storage/drift/lib/

  STEP_1: |
    创建 scope_alias_entry.dart。
    位置: xuan-storage/drift/lib/scope/scope_alias_entry.dart
    别名账本条目模型。纯数据类，不依赖 Drift 或账户模型。

  STEP_1_CONTENT: |
    /// 别名身份类型。
    enum ScopeAuthKind {
      anonymous,  // guest appUserId
      registered, // 注册 appUserId
      device,     // 设备 id (无 BaaS 场景，仅 ScopeBootstrapStore 内部标识 ghost scope)
    }

    /// 别名账本条目：某个身份 → 某个 scope_uid 的映射。
    ///
    /// 主键是 (authKind, authId)。同一 authId 不会出现在两个 scope 下。
    class ScopeAliasEntry {
      const ScopeAliasEntry({
        required this.authKind,
        required this.authId,
        required this.scopeUid,
        required this.linkedAt,
      });

      final ScopeAuthKind authKind;
      final String authId;
      final String scopeUid;
      final DateTime linkedAt;

      @override
      bool operator ==(Object other) =>
          identical(this, other) ||
          other is ScopeAliasEntry &&
              runtimeType == other.runtimeType &&
              authKind == other.authKind &&
              authId == other.authId &&
              scopeUid == other.scopeUid;

      @override
      int get hashCode => Object.hash(authKind, authId, scopeUid);
    }

  STEP_2: |
    创建 scope_bootstrap_store.dart。
    位置: xuan-storage/drift/lib/scope/scope_bootstrap_store.dart
    Ghost scope_uid 持久化端口 + InMemory 测试实现。

  STEP_2_CONTENT: |
    /// Ghost scope_uid 的持久化端口。
    ///
    /// 首次调用 [getOrCreate] 时铸造 UUIDv7 并持久化，
    /// 后续调用返回已持久化的值——保证终生不变。
    abstract interface class ScopeBootstrapStore {
      /// 返回本设备的稳定 scope_uid，绝不返回空字符串。
      Future<String> getOrCreate();

      /// 仅用于测试/重置场景。生产代码不应调用。
      Future<void> resetForTest();
    }

    /// InMemory 实现，供测试使用。
    class InMemoryScopeBootstrapStore implements ScopeBootstrapStore {
      String? _cached;
      int _generatedCount = 0;

      @override
      Future<String> getOrCreate() async {
        if (_cached != null && _cached!.isNotEmpty) return _cached!;
        _generatedCount++;
        _cached = 'test-scope-$_generatedCount';
        return _cached!;
      }

      @override
      Future<void> resetForTest() async {
        _cached = null;
      }

      int get generatedCount => _generatedCount;
    }

  STEP_3: |
    创建 scope_ledger.dart。
    位置: xuan-storage/drift/lib/scope/scope_ledger.dart
    别名账本接口。纯接口，不依赖 Drift。

  STEP_3_CONTENT: |
    import 'scope_alias_entry.dart';

    /// 别名账本接口。
    ///
    /// 管理 identity → scope_uid 的映射关系。
    /// ScopeResolver 通过此接口完成所有 scope 查询和绑定。
    abstract interface class ScopeLedger {
      /// 返回设备级 ghost scope_uid (bootstrap 铸的值)。
      Future<String> deviceScope();

      /// 查询某个身份是否已有别名。
      /// 命中 → 返回对应的 scope_uid；未命中 → 返回 null。
      Future<String?> scopeForIdentity(String authId, ScopeAuthKind authKind);

      /// 绑定身份到已有 scope (INSERT alias)。
      /// 升级场景：匿名→注册时调用。
      ///
      /// 注意：如果 (authKind, authId) 已存在，此方法会覆盖 scope_uid。
      /// 调用方必须保证不重复绑定不同 scope（由 ScopeResolver 算法保证）。
      Future<void> bind(String authId, ScopeAuthKind authKind, String scopeUid);

      /// 铸造新 scope_uid 并绑定身份。
      /// 冲突场景：登录已有账户且无 link 时调用。
      Future<String> mintAndBind(String authId, ScopeAuthKind authKind);

      /// 返回某个 scope_uid 下的所有别名条目。
      Future<List<ScopeAliasEntry>> entriesForScope(String scopeUid);
    }

  STEP_4: |
    创建 scope_resolver.dart。
    位置: xuan-storage/drift/lib/scope/scope_resolver.dart
    所有 scope 取值的唯一出口。空值在此一票否决。

  STEP_4_CONTENT: |
    import 'package:repository_interface_account/repository_interface_account.dart';
    import 'scope_bootstrap_store.dart';
    import 'scope_ledger.dart';
    import 'scope_alias_entry.dart';

    /// Scope 解析结果。
    ///
    /// isUpgrade/isConflict 为 Phase 5+ 预留（冲突合并、epoch 重绑）。
    /// Phase 2.5 的 DI 装配仅使用 scopeUid。
    class ResolvedScope {
      const ResolvedScope({
        required this.scopeUid,
        required this.isUpgrade,
        required this.isConflict,
      });

      /// 解析出的 scope_uid，绝不为空。
      final String scopeUid;

      /// true = 这是一次升级 (匿名→注册，复用 device scope)。
      final bool isUpgrade;

      /// true = 这是一次真冲突 (登录已有账户，新铸 scope)。
      final bool isConflict;
    }

    /// 所有 scope 取值的唯一出口。
    ///
    /// 空值在此一票否决——绝不返回空 scope_uid。
    class ScopeResolver {
      ScopeResolver({
        required AccountSessionRepository sessionRepository,
        required AccountIdentityLinkRepository identityLinkRepository,
        required ScopeLedger ledger,
        required ScopeBootstrapStore bootstrapStore,
      }) : _sessionRepository = sessionRepository,
           _identityLinkRepository = identityLinkRepository,
           _ledger = ledger,
           _bootstrapStore = bootstrapStore;

      final AccountSessionRepository _sessionRepository;
      final AccountIdentityLinkRepository _identityLinkRepository;
      final ScopeLedger _ledger;
      final ScopeBootstrapStore _bootstrapStore;

      /// 解析当前 session 对应的 scope_uid。
      ///
      /// 绝不返回空字符串。任何异常路径都抛出而非静默返回空值。
      Future<ResolvedScope> resolve() async {
        final session = await _sessionRepository.getCurrentSession();

        // 1. 无 session (登出 / 尚未登录) → 返回 device scope
        if (session == null) {
          final deviceScope = await _ledger.deviceScope();
          return ResolvedScope(
            scopeUid: deviceScope,
            isUpgrade: false,
            isConflict: false,
          );
        }

        // 2. 空 appUserId → 抛错 (解 C3 空 scope 坍缩)
        final appUserId = session.appUserId.value;
        if (appUserId.isEmpty) {
          throw StateError(
            'ScopeResolver: appUserId is empty — '
            'this would cause scope collapse (C3). '
            'Session kind=${session.kind}, providerId=${session.providerId}',
          );
        }

        // 3. 查别名 → 命中则返回
        final authKind = session.isAnonymous
            ? ScopeAuthKind.anonymous
            : ScopeAuthKind.registered;
        final hit = await _ledger.scopeForIdentity(appUserId, authKind);
        if (hit != null) {
          return ResolvedScope(
            scopeUid: hit,
            isUpgrade: false,
            isConflict: false,
          );
        }

        // 4. appUserId 还没有别名 → 检查 device scope
        final deviceScope = await _ledger.deviceScope();
        final entries = await _ledger.entriesForScope(deviceScope);

        if (entries.isEmpty) {
          // device scope 未被任何身份占用 → 直接绑定
          await _ledger.bind(appUserId, authKind, deviceScope);
          return ResolvedScope(
            scopeUid: deviceScope,
            isUpgrade: false,
            isConflict: false,
          );
        }

        // 5. device scope 已被占用 → 检查是否能通过 link 链回
        final canLinkBack = await _canLinkBack(appUserId, entries);
        if (canLinkBack) {
          // 升级：复用 device scope，只插别名 (解 C1)
          await _ledger.bind(appUserId, authKind, deviceScope);
          return ResolvedScope(
            scopeUid: deviceScope,
            isUpgrade: true,
            isConflict: false,
          );
        }

        // 6. 真冲突：登录已有账户，本地 device scope 属于另一个用户
        final newScope = await _ledger.mintAndBind(appUserId, authKind);
        return ResolvedScope(
          scopeUid: newScope,
          isUpgrade: false,
          isConflict: true,
        );
      }

      /// 检查 appUserId 是否能通过 AccountIdentityLink 链回
      /// device scope 的占用者。
      Future<bool> _canLinkBack(
        String appUserId,
        List<ScopeAliasEntry> deviceEntries,
      ) async {
        for (final entry in deviceEntries) {
          if (entry.authKind == ScopeAuthKind.anonymous) {
            final link = await _identityLinkRepository
                .getByAnonymousUserId(AccountUserId(entry.authId));
            if (link != null &&
                link.registeredAppUserId.value == appUserId) {
              return true;
            }
          }
          if (entry.authKind == ScopeAuthKind.registered) {
            final link = await _identityLinkRepository
                .getByRegisteredUserId(AccountUserId(entry.authId));
            if (link != null &&
                link.anonymousAppUserId.value == appUserId) {
              return true;
            }
          }
        }
        return false;
      }
    }

  STEP_5: |
    创建 drift_scope_alias_table.dart。
    位置: xuan-storage/drift/lib/scope/drift_scope_alias_table.dart
    Drift 表 TScopeAlias 定义。

  STEP_5_CONTENT: |
    import 'package:drift/drift.dart';

    /// 别名账本表。
    ///
    /// 记录 identity → scope_uid 的映射关系。
    /// 主键 (auth_kind, auth_id) 保证同一身份不会映射到两个 scope。
    class TScopeAlias extends Table {
      @override
      String get tableName => 't_scope_alias';

      TextColumn get authKind => text().named('auth_kind')();
      TextColumn get authId => text().named('auth_id')();
      TextColumn get scopeUid => text().named('scope_uid')();
      DateTimeColumn get linkedAt => dateTime().named('linked_at')();

      @override
      Set<Column> get primaryKey => {authKind, authId};
    }

  STEP_6: |
    创建 drift_scope_ledger.dart。
    位置: xuan-storage/drift/lib/scope/drift_scope_ledger.dart
    ScopeLedger 的 Drift 实现。mintAndBind 使用 Uuid().v7() 铸造新 scope。

  STEP_6_CONTENT: |
    import 'package:drift/drift.dart';
    import 'package:uuid/uuid.dart';
    import '../persistence_drift.dart';
    import 'scope_alias_entry.dart';
    import 'scope_bootstrap_store.dart';
    import 'scope_ledger.dart';

    /// ScopeLedger 的 Drift 实现。
    class DriftScopeLedger implements ScopeLedger {
      DriftScopeLedger({
        required PersistenceDriftDatabase db,
        required ScopeBootstrapStore bootstrapStore,
      }) : _db = db,
           _bootstrapStore = bootstrapStore;

      final PersistenceDriftDatabase _db;
      final ScopeBootstrapStore _bootstrapStore;
      static final _uuid = Uuid();

      @override
      Future<String> deviceScope() => _bootstrapStore.getOrCreate();

      @override
      Future<String?> scopeForIdentity(
        String authId,
        ScopeAuthKind authKind,
      ) async {
        final row = await (_db.select(_db.tScopeAlias)
              ..where((t) =>
                  t.authKind.equals(authKind.name) &
                  t.authId.equals(authId)))
            .getSingleOrNull();
        return row?.scopeUid;
      }

      @override
      Future<void> bind(
        String authId,
        ScopeAuthKind authKind,
        String scopeUid,
      ) async {
        await _db.into(_db.tScopeAlias).insertOnConflictUpdate(
              TScopeAliasCompanion.insert(
                authKind: authKind.name,
                authId: authId,
                scopeUid: scopeUid,
                linkedAt: DateTime.now(),
              ),
            );
      }

      @override
      Future<String> mintAndBind(String authId, ScopeAuthKind authKind) async {
        final newScope = _uuid.v7();
        await bind(authId, authKind, newScope);
        return newScope;
      }

      @override
      Future<List<ScopeAliasEntry>> entriesForScope(String scopeUid) async {
        final rows = await (_db.select(_db.tScopeAlias)
              ..where((t) => t.scopeUid.equals(scopeUid)))
            .get();
        return rows
            .map((r) => ScopeAliasEntry(
                  authKind: ScopeAuthKind.values.byName(r.authKind),
                  authId: r.authId,
                  scopeUid: r.scopeUid,
                  linkedAt: r.linkedAt,
                ))
            .toList();
      }
    }

  STEP_7: |
    在 persistence_drift.dart 中注册 TScopeAlias 表。
    schemaVersion 从 2 升到 3。
    注意：当前数据库的 onCreate 使用 m.createTable() 而非 m.createAll()，
    必须在三个位置都添加 t_scope_alias。

  STEP_7_CONTENT: |
    // 修改 PersistenceDriftDatabase 类:
    //
    // 1. 导入新表:
    //    import 'scope/drift_scope_alias_table.dart';
    //
    // 2. 添加表 getter (在现有 tRecordMeta/tRecordSearchIndex getter 附近):
    //    TScopeAlias get tScopeAlias => TScopeAlias();
    //
    // 3. schemaVersion 改为 3:
    //    int get schemaVersion => 3;
    //
    // 4. onCreate 中添加 (在现有 m.createTable(tRecordSearchIndex) 之后):
    //    await m.createTable(tScopeAlias);
    //
    // 5. onUpgrade 中添加 (在现有 if (from < 2) 块之后):
    //    if (from < 3) {
    //      await m.createTable(tScopeAlias);
    //    }
    //
    // 6. 运行 dart run build_runner build 重新生成 persistence_drift.g.dart

  STEP_7B: |
    创建 barrel file 导出。
    位置: xuan-storage/drift/lib/scope.dart (或在现有 barrel file 中添加 export)
    导出 scope 模块的公共 API，供其他包 import。

  STEP_7B_CONTENT: |
    // 在 xuan-storage/drift/lib/ 的 barrel file 中添加:
    // export 'scope/scope_alias_entry.dart';
    // export 'scope/scope_bootstrap_store.dart';
    // export 'scope/scope_ledger.dart';
    // export 'scope/scope_resolver.dart';
    //
    // 不导出 drift_scope_alias_table.dart 和 drift_scope_ledger.dart
    // (它们是 Drift 实现细节，仅在 scope 模块内部使用)。

  STEP_8: |
    创建 scope_resolver_test.dart。
    位置: xuan-storage/drift/test/scope/scope_resolver_test.dart
    覆盖 resolve 算法的 8 个场景。
    每个 test group 使用独立的 InMemoryScopeBootstrapStore + InMemoryScopeLedger 实例。

  STEP_8_CONTENT: |
    // 测试场景清单 (使用 InMemory 实现，不依赖 Drift/Firebase):
    //
    // 基础场景 (每个用独立 mock 实例):
    // 1. session == null → 返回 device scope (登出/未登录)
    // 2. session 有 appUserId，已有别名 → 返回已有 scope
    // 3. session 有 appUserId，无别名，device scope 未占用 → 绑定 device scope
    // 4. session 有 appUserId，无别名，device scope 被占用，有 link → 升级绑定
    //    mock: AccountIdentityLinkRepository 返回 guest→registered link
    // 5. session 有 appUserId，无别名，device scope 被占用，无 link → 新铸 scope (冲突)
    //    mock: AccountIdentityLinkRepository 返回 null
    // 6. session.appUserId 为空 → 抛出 StateError (C3 空值守卫)
    //
    // 端到端场景 (需要 mock AccountSessionRepository 在不同时间返回不同 session):
    // 7. 匿名写记录 → 注册 → 仍能读到 (scope_uid 不变)
    //    mock: 第一次 resolve 返回 anonymous session → 得到 scope A
    //          第二次 resolve 返回 registered session (有 link) → 仍返回 scope A
    // 8. 登出 → 再匿名 → 看不到注册用户记录 (scope 隔离)
    //    mock: 第一次 resolve 返回 registered session → 得到 scope A
    //          第二次 resolve 返回 null session → 得到 device scope (≠ scope A)

  STEP_9: |
    创建 drift_scope_ledger_test.dart。
    位置: xuan-storage/drift/test/scope/drift_scope_ledger_test.dart
    覆盖 Drift 实现的 6 个场景。

  STEP_9_CONTENT: |
    // 测试场景清单 (使用内存 Drift 数据库):
    //
    // 1. 首次 bind → scopeForIdentity 返回正确值
    // 2. mintAndBind → 铸造新 scope 并绑定
    // 3. entriesForScope → 返回该 scope 下所有别名
    // 4. 重复 bind 同一 (authKind, authId) → upsert 不报错
    // 5. deviceScope → 返回 bootstrap 值
    // 6. schema migration → t_scope_alias 表存在且可查询

  STEP_10: |
    运行全部测试，确认通过。

PROHIBITED:
  - 返回空字符串作为 scope_uid
  - 静默吞掉异常
  - 做 epoch 重绑 (Phase 5+)
  - 做冲突合并 (Phase 5+)
  - 直接访问 Drift 表 (scope 模块内)
  - 修改 t_record_meta 或 t_record_search_index 表结构

ABSOLUTELY_PROHIBITED:
  - resolve() 产生空 scope_uid
  - 在 getOrCreate() 中产生空 scope_uid

ASSERTIONS:
  EXECENV: "dart analyze xuan-storage/drift/lib/scope/ 零错误"
  CASES:
    - "session == null → 返回 device scope"
    - "session 有 appUserId，已有别名 → 返回已有 scope"
    - "session 有 appUserId，无别名，device scope 未占用 → 绑定 device scope"
    - "session 有 appUserId，无别名，device scope 被占用但有 link → 升级绑定"
    - "session 有 appUserId，无别名，device scope 被占用且无 link → 新铸 scope"
    - "session.appUserId 为空 → 抛出 StateError"
    - "匿名写记录 → 注册 → 仍能读到 (scope_uid 不变)"
    - "登出 → 再匿名 → 看不到注册用户记录 (scope 隔离)"

PROTOCOL:
  MODE: "edit-files-only"
  NO_PROSE: true
  OUTPUT_FORMAT: "修改 persistence_drift.dart + barrel file, 新增 6 个源文件 + 2 个测试文件"

VERIFICATION: |
  dart analyze xuan-storage/drift/lib/scope/ | grep -c 'No issues found'
  dart run build_runner build --delete-conflicting-outputs
  flutter test xuan-storage/drift/test/scope/ | grep -c 'All tests passed'
```

---

## ACT-4: Phase 3 — Base 类与梅花迁移

```yaml
TASK_ID: "typed-record-phase3-base-and-meihua"
LANG: "dart"
TARGET_FILE: "xuan-storage/drift/lib/record/"
CONTEXT:
  DOMAIN: |
    梅花 RecordBackedMeiHuaRepository 已完整实现，约 85 行。
    其中 ~70% 是委托样板 (saveRecord/getAllRecords/watchAllRecords/getByUuid/softDelete)。

    目标: 创建泛型 BaseRecordBackedRepository<TContract>，将委托逻辑收进基类。
    梅花子类方法体从 5-15 行缩减为 1 行委托。

    已有:
    - Phase 1 端口: RecordModuleCodec<T>, ScopedRecordStore, RecordIndexRepository
    - Phase 2 Drift: findByIndex/watchByIndex + scope 修复
    - Phase 2.5 scope: ScopeResolver + ghost bootstrap
    - 编译 spike: .spike/ 已验证泛型签名可通过 dart analyze + 7/7 测试

    MeiHuaDivinationRecordContract 字段 (15 个):
    uuid, divinationUuid, question, originalUpperGua, originalLowerGua,
    changingYao, changedUpperGua, changedLowerGua, huUpperGua, huLowerGua,
    method, paramsJson, createdAt, updatedAt, deletedAt

    梅花搜索索引: divination_uuid, upper_gua, lower_gua, changing_yao

  STRATEGY: |
    1. 创建 BaseRecordBackedRepository (依赖 ScopedRecordStore + RecordModuleCodec<T>)
    2. 创建 MeiHuaRecordCodec (实现 RecordModuleCodec<MeiHuaDivinationRecordContract>)
    3. 改写 RecordBackedMeiHuaRepository 为继承 Base
    4. 保持现有梅花端口 MeiHuaDivinationRecordRepository 不变
    5. 保持数据兼容 (现有梅花记录无需重写即可读取)

TASK_DEPS:
  - "typed-record-phase1-ports-and-fakes"
  - "typed-record-phase2-drift-scope-fix"
  - "typed-record-phase2.5-scoped-pid"

COMMANDS:
  PRECHECK: |
    dart analyze xuan-storage/drift/lib/record/ xuan-storage/drift/lib/meihuayishu/

  STEP_1: |
    创建 BaseRecordBackedRepository。
    位置: xuan-storage/drift/lib/record/base_record_backed_repository.dart
    只依赖 ScopedRecordStore + RecordModuleCodec<TContract>。
    不导入 Drift、数据库或具体表。
    提供: save/getByUuid/getAll/watchAll/getLatest/softDelete/getFirstByIndex/getAllByIndex/watchFirstByIndex

  STEP_1_CONTENT: |
    import 'dart:async';
    import 'package:uuid/uuid.dart';
    import 'package:repository_interface_record/repository_interface_record.dart';

    /// Type-safe reusable record-storage base.
    /// Depends only on [ScopedRecordStore] and [RecordModuleCodec<TContract>].
    /// Does NOT import Drift, table classes, or datasource internals.
    abstract class BaseRecordBackedRepository<TContract> {
      BaseRecordBackedRepository({
        required ScopedRecordStore store,
        required RecordModuleCodec<TContract> codec,
        Uuid? uuid,
      })  : _store = store,
            _codec = codec,
            _uuid = uuid ?? const Uuid();

      final ScopedRecordStore _store;
      final RecordModuleCodec<TContract> _codec;
      final Uuid _uuid;

      String get module => _codec.module;

      // ── save ──
      Future<String> save(TContract contract) async {
        final currentUuid = _codec.uuidOf(contract);
        final effectiveUuid = currentUuid.isNotEmpty ? currentUuid : _uuid.v7();
        final fixed = currentUuid.isNotEmpty ? contract : _codec.withUuid(contract, effectiveUuid);
        final encoded = _codec.encode(fixed, scopeUid: _store.scopeUid);
        _validateEncodedMeta(encoded.meta, effectiveUuid);
        await _store.saveRecord(encoded.meta, moduleData: encoded.moduleData);
        return effectiveUuid;
      }

      // ── read ──
      Future<TContract?> getByUuid(String uuid) async {
        final meta = await _store.getRecord(uuid, module: module);
        return meta == null ? null : _codec.decode(meta, null);
      }

      Future<List<TContract>> getAll({int pageSize = 200}) async {
        final results = <TContract>[];
        String? cursor;
        while (true) {
          final page = await _store.listRecords(module: module, limit: pageSize, cursor: cursor);
          if (page.isEmpty) break;
          results.addAll(page.map((m) => _codec.decode(m, null)));
          if (page.length < pageSize) break;
          cursor = page.last.uuid;
        }
        return results;
      }

      Stream<List<TContract>> watchAll() =>
          _store.watchRecords(module: module).map((metas) => metas.map((m) => _codec.decode(m, null)).toList());

      Future<List<TContract>> getLatest({int limit = 10}) async {
        final metas = await _store.listRecords(module: module, limit: limit);
        return metas.map((m) => _codec.decode(m, null)).toList();
      }

      // ── delete ──
      Future<bool> softDelete(String uuid) => _store.softDeleteRecord(uuid, module: module);

      // ── index queries ──
      Future<TContract?> getFirstByIndex(String indexKey, String indexValue) async {
        final metas = await _store.findByIndex(module: module, indexKey: indexKey, indexValue: indexValue, limit: 1);
        return metas.isEmpty ? null : _codec.decode(metas.first, null);
      }

      Future<List<TContract>> getAllByIndex(String indexKey, String indexValue, {int limit = 200}) async {
        final metas = await _store.findByIndex(module: module, indexKey: indexKey, indexValue: indexValue, limit: limit);
        return metas.map((m) => _codec.decode(m, null)).toList();
      }

      Stream<TContract?> watchFirstByIndex(String indexKey, String indexValue) =>
          _store.watchByIndex(module: module, indexKey: indexKey, indexValue: indexValue)
              .map((metas) => metas.isEmpty ? null : _codec.decode(metas.first, null));

      void _validateEncodedMeta(RecordMeta meta, String expectedUuid) {
        if (meta.uuid != expectedUuid) throw RecordCodecMismatch(message: 'uuid mismatch');
        if (meta.module != _codec.module) throw RecordCodecMismatch(message: 'module mismatch');
        if (meta.scopeUid != _store.scopeUid) throw RecordCodecMismatch(message: 'scope mismatch');
      }
    }

  STEP_2: |
    创建 MeiHuaRecordCodec。
    位置: xuan-storage/drift/lib/meihuayishu/meihua_record_codec.dart
    实现 RecordModuleCodec<MeiHuaDivinationRecordContract>。
    负责 encode/decode/uuidOf/withUuid/extractSearchTags。

  STEP_2_CONTENT: |
    import 'dart:convert';
    import 'package:repository_interface_meihuayishu/repository_interface_meihuayishu.dart';
    import 'package:repository_interface_record/repository_interface_record.dart';

    class MeiHuaRecordCodec implements RecordModuleCodec<MeiHuaDivinationRecordContract> {
      @override String get module => 'meihua';
      @override String get category => 'divination';
      @override String get divinationType => 'mei_hua';

      @override String uuidOf(MeiHuaDivinationRecordContract c) => c.uuid;

      @override
      MeiHuaDivinationRecordContract withUuid(MeiHuaDivinationRecordContract c, String uuid) {
        return MeiHuaDivinationRecordContract(
          uuid: uuid, divinationUuid: c.divinationUuid.isNotEmpty ? c.divinationUuid : uuid,
          question: c.question, originalUpperGua: c.originalUpperGua,
          originalLowerGua: c.originalLowerGua, changingYao: c.changingYao,
          changedUpperGua: c.changedUpperGua, changedLowerGua: c.changedLowerGua,
          huUpperGua: c.huUpperGua, huLowerGua: c.huLowerGua,
          method: c.method, paramsJson: c.paramsJson,
          createdAt: c.createdAt, updatedAt: c.updatedAt, deletedAt: c.deletedAt,
        );
      }

      @override
      EncodedRecord encode(MeiHuaDivinationRecordContract c, {required String scopeUid}) {
        final data = <String, dynamic>{
          'divinationUuid': c.divinationUuid, 'originalUpperGua': c.originalUpperGua,
          'originalLowerGua': c.originalLowerGua, 'changingYao': c.changingYao,
          'changedUpperGua': c.changedUpperGua, 'changedLowerGua': c.changedLowerGua,
          'huUpperGua': c.huUpperGua, 'huLowerGua': c.huLowerGua,
          'method': c.method, 'paramsJson': c.paramsJson,
        };
        final meta = RecordMeta(
          uuid: c.uuid, scopeUid: scopeUid, module: module, category: category,
          divinationType: divinationType, question: c.question,
          moduleDataJson: jsonEncode(data), navParamsJson: jsonEncode({'recordUuid': c.uuid}),
          createdAt: c.createdAt, updatedAt: c.updatedAt, deletedAt: c.deletedAt, rev: 1,
        );
        return (meta: meta, moduleData: data);
      }

      @override
      MeiHuaDivinationRecordContract decode(RecordMeta meta, Map<String, dynamic>? moduleData) {
        if (meta.module != module) throw RecordCodecMismatch(message: 'module mismatch');
        final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
        return MeiHuaDivinationRecordContract(
          uuid: meta.uuid, divinationUuid: d['divinationUuid'] ?? meta.uuid,
          question: meta.question, originalUpperGua: d['originalUpperGua'],
          originalLowerGua: d['originalLowerGua'], changingYao: d['changingYao'],
          changedUpperGua: d['changedUpperGua'], changedLowerGua: d['changedLowerGua'],
          huUpperGua: d['huUpperGua'], huLowerGua: d['huLowerGua'],
          method: d['method'], paramsJson: d['paramsJson'],
          createdAt: meta.createdAt, updatedAt: meta.updatedAt ?? meta.createdAt,
          deletedAt: meta.deletedAt,
        );
      }

      @override
      List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? moduleData) {
        final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
        return [
          SearchTag('divination_uuid', '${d['divinationUuid']}'),
          SearchTag('upper_gua', '${d['originalUpperGua']}'),
          SearchTag('lower_gua', '${d['originalLowerGua']}'),
          SearchTag('changing_yao', '${d['changingYao']}'),
        ];
      }
    }

  STEP_3: |
    改写 RecordBackedMeiHuaRepository。
    继承 BaseRecordBackedRepository<MeiHuaDivinationRecordContract>。
    实现 MeiHuaDivinationRecordRepository。
    方法体均为一行委托。

  STEP_3_CONTENT: |
    import 'package:repository_interface_meihuayishu/repository_interface_meihuayishu.dart';
    import '../record/base_record_backed_repository.dart';
    import 'meihua_record_codec.dart';

    class RecordBackedMeiHuaRepository
        extends BaseRecordBackedRepository<MeiHuaDivinationRecordContract>
        implements MeiHuaDivinationRecordRepository {

      RecordBackedMeiHuaRepository({
        required super.store,
        required super.codec,
        super.uuid,
      });

      @override Future<String> saveRecord(MeiHuaDivinationRecordContract r) => save(r);
      @override Future<List<MeiHuaDivinationRecordContract>> getAllRecords() => getAll();
      @override Stream<List<MeiHuaDivinationRecordContract>> watchAllRecords() => watchAll();
      @override Future<MeiHuaDivinationRecordContract?> getRecordByUuid(String u) => getByUuid(u);
      @override Future<MeiHuaDivinationRecordContract?> getRecordByDivinationUuid(String d) =>
          getFirstByIndex('divination_uuid', d);
      @override Stream<MeiHuaDivinationRecordContract?> watchRecordByDivinationUuid(String d) =>
          watchFirstByIndex('divination_uuid', d);
      @override Future<bool> softDeleteRecord(String u) => softDelete(u);
    }

  STEP_4: |
    保留 MeihuaRecordAdapter (向后兼容)。
    保留 DriftMeiHuaDivinationRecordRepository (标记 @Deprecated)。
    保留 meihua_record_migration.dart。

  STEP_5: |
    更新 drift pubspec.yaml:
    确保依赖包含 repository_interface_record (Phase 1 修订版)。

  STEP_6: |
    DI 装配更新:
    在 composition root 中:
    - 创建 ScopeBootstrapStore 实现 (SharedPreferences)
    - 创建 ScopeLedger (DriftScopeLedger)
    - 创建 ScopeResolver (注入 sessionRepository, identityLinkRepository, ledger, bootstrapStore)
    - 调用 ScopeResolver.resolve() 获取 ResolvedScope
    - 使用 resolved.scopeUid 创建 DriftRecordDataSource
    - 创建 LocalRecordRepository (实现 ScopedRecordStore)
    - 创建 MeiHuaRecordCodec 并注册到 RecordAdapterRegistry
    - 创建 RecordBackedMeiHuaRepository(store: localRecords, codec: meihuaCodec)

PROHIBITED:
  - 在 Base 中导入 package:drift
  - 在 Base 中访问 PersistenceDriftDatabase
  - 修改 MeiHuaDivinationRecordRepository 接口
  - 改变现有梅花记录数据的 module_data_json 格式
  - 删除 MeihuaRecordAdapter (保持向后兼容)

ABSOLUTELY_PROHIBITED:
  - 在 Base 中直接查询 t_record_search_index
  - 删除或修改 t_record_meta 或 t_record_search_index 表

ASSERTIONS:
  EXECENV: "dart analyze xuan-storage/drift/lib/record/ xuan-storage/drift/lib/meihuayishu/ 零错误"
  CASES:
    - "梅花现有端口行为全部保持"
    - "现有梅花记录数据无需重写即可读取"
    - "Base 源码中不存在 Drift import"
    - "MeiHuaRecordCodec 往返 encode→decode 保真"

PROTOCOL:
  MODE: "write-files-only"
  NO_PROSE: true
  OUTPUT_FORMAT: "产出 .dart 文件"

VERIFICATION: "dart analyze xuan-storage/drift/lib/record/ xuan-storage/drift/lib/meihuayishu/ | grep -c 'No issues found'"
```

---

## ACT-5: Phase 4 — 六爻双模块证明

```yaml
TASK_ID: "typed-record-phase4-liuyao-dual-module"
LANG: "dart"
TARGET_FILE: "xuan-storage/drift/lib/liuyao/"
CONTEXT:
  DOMAIN: |
    六爻 (Liu Yao / Six Yao) 是第二个接入统一 Record 存储的模块。
    已有:
    - SixYaoDivinationRecordRepository 接口 (5 方法)
    - SixYaoDivinationRecord 模型 (8 字段 + 2 枚举)
    - SixYaoYaoResult (index, yaoType)
    - YaoType 枚举 (laoyang, shaoyang, laoyin, shaoyin)

    六爻接口 vs 梅花接口差异:
    - 六爻无 watchAllRecords / watchByXxx / getByDivinationUuid
    - 六爻有 getLatestRecords (梅花无)
    - 共用 saveRecord / getAllRecords / getRecordByUuid / softDeleteRecord

    已有代码:
    - drift/lib/liuyao/liuyao_record_codec.dart (已创建，通过 analyze)
    - drift/lib/liuyao/record_backed_liuyao_repository.dart (已创建，通过 analyze)

  STRATEGY: |
    将现有 liuyao codec 和 repository 迁移到新接口体系:
    1. LiuYaoRecordCodec 实现 RecordModuleCodec<SixYaoDivinationRecord>
    2. RecordBackedLiuYaoRepository 继承 BaseRecordBackedRepository
    3. 双模块 DI 装配 (梅花 + 六爻共享同一个 LocalRecordRepository)
    4. 验证双模块隔离 (同一 scope 下 module 隔离，同一 index key 不同 module 互不可见)

TASK_DEPS:
  - "typed-record-phase3-base-and-meihua"

COMMANDS:
  PRECHECK: |
    dart analyze xuan-storage/drift/lib/liuyao/

  STEP_1: |
    更新 LiuYaoRecordCodec:
    实现 RecordModuleCodec<SixYaoDivinationRecord> (替换当前无接口约束的实现)。
    yaoResults 序列化为 JSON 数组 [{"index":0,"yaoType":"shaoyang"},...]。
    搜索索引: original_gua_id, changed_gua_id (nullable)。

  STEP_1_CONTENT: |
    import 'dart:convert';
    import 'package:repository_interface_liuyao/repository_interface_liuyao.dart';
    import 'package:repository_interface_record/repository_interface_record.dart';

    class LiuYaoRecordCodec implements RecordModuleCodec<SixYaoDivinationRecord> {
      @override String get module => 'liuyao';
      @override String get category => 'divination';
      @override String get divinationType => 'liu_yao';

      @override String uuidOf(SixYaoDivinationRecord c) => c.uuid;

      @override
      SixYaoDivinationRecord withUuid(SixYaoDivinationRecord c, String uuid) {
        return SixYaoDivinationRecord(
          uuid: uuid, question: c.question, yaoResults: c.yaoResults,
          originalGuaId: c.originalGuaId, changedGuaId: c.changedGuaId,
          createdAt: c.createdAt, updatedAt: c.updatedAt, deletedAt: c.deletedAt,
        );
      }

      @override
      EncodedRecord encode(SixYaoDivinationRecord c, {required String scopeUid}) {
        final yaoJson = c.yaoResults.map((y) => {'index': y.index, 'yaoType': y.yaoType.name}).toList();
        final data = <String, dynamic>{'yaoResults': yaoJson, 'originalGuaId': c.originalGuaId, 'changedGuaId': c.changedGuaId};
        final meta = RecordMeta(
          uuid: c.uuid, scopeUid: scopeUid, module: module, category: category,
          divinationType: divinationType, question: c.question,
          moduleDataJson: jsonEncode(data), navParamsJson: jsonEncode({'recordUuid': c.uuid}),
          createdAt: c.createdAt, updatedAt: c.updatedAt, deletedAt: c.deletedAt, rev: 1,
        );
        return (meta: meta, moduleData: data);
      }

      @override
      SixYaoDivinationRecord decode(RecordMeta meta, Map<String, dynamic>? moduleData) {
        if (meta.module != module) throw RecordCodecMismatch(message: 'module mismatch');
        final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
        final yaoList = (d['yaoResults'] as List<dynamic>?) ?? [];
        final yaoResults = yaoList.map((y) {
          final m = y as Map<String, dynamic>;
          return SixYaoYaoResult(index: m['index'], yaoType: YaoType.values.firstWhere((t) => t.name == m['yaoType']));
        }).toList();
        return SixYaoDivinationRecord(
          uuid: meta.uuid, question: meta.question ?? '', yaoResults: yaoResults,
          originalGuaId: d['originalGuaId'], changedGuaId: d['changedGuaId'],
          createdAt: meta.createdAt, updatedAt: meta.updatedAt, deletedAt: meta.deletedAt,
        );
      }

      @override
      List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? moduleData) {
        final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
        return [
          SearchTag('original_gua_id', '${d['originalGuaId']}'),
          if (d['changedGuaId'] != null) SearchTag('changed_gua_id', '${d['changedGuaId']}'),
        ];
      }
    }

  STEP_2: |
    改写 RecordBackedLiuYaoRepository:
    继承 BaseRecordBackedRepository<SixYaoDivinationRecord>。
    实现 SixYaoDivinationRecordRepository。
    方法体均为一行委托。

  STEP_2_CONTENT: |
    import 'package:repository_interface_liuyao/repository_interface_liuyao.dart';
    import '../record/base_record_backed_repository.dart';
    import 'liuyao_record_codec.dart';

    class RecordBackedLiuYaoRepository
        extends BaseRecordBackedRepository<SixYaoDivinationRecord>
        implements SixYaoDivinationRecordRepository {

      RecordBackedLiuYaoRepository({
        required super.store,
        required super.codec,
        super.uuid,
      });

      @override Future<String> saveRecord(SixYaoDivinationRecord r) => save(r);
      @override Future<SixYaoDivinationRecord?> getRecordByUuid(String u) => getByUuid(u);
      @override Future<List<SixYaoDivinationRecord>> getAllRecords() => getAll();
      @override Future<bool> softDeleteRecord(String u) => softDelete(u);
      @override Future<List<SixYaoDivinationRecord>> getLatestRecords({int limit = 10}) => getLatest(limit: limit);
    }

  STEP_3: |
    双模块 DI 装配。
    在 composition root 中:
    - 同一个 LocalRecordRepository (scope_uid 来自 ScopeResolver)
    - 同一个 RecordAdapterRegistry 注册 meihuaCodec + liuyaoCodec
    - meihuaRepository 和 liuyaoRepository 共享同一个 store

  STEP_3_CONTENT: |
    // Composition root (示例)
    // scope_uid 由 ScopeResolver 从 session + alias ledger 解析得出
    final bootstrapStore = SharedPreferencesScopeBootstrapStore();
    final ledger = DriftScopeLedger(db: database, bootstrapStore: bootstrapStore);
    final resolver = ScopeResolver(
      sessionRepository: sessionRepository,
      identityLinkRepository: identityLinkRepository,
      ledger: ledger,
      bootstrapStore: bootstrapStore,
    );
    final resolved = await resolver.resolve();
    final dataSource = DriftRecordDataSource(database, scopeUid: resolved.scopeUid);
    final meihuaCodec = MeiHuaRecordCodec();
    final liuyaoCodec = LiuYaoRecordCodec();
    final registry = RecordAdapterRegistry([meihuaCodec, liuyaoCodec]);
    final store = LocalRecordRepository(dataSource, registry);

    final meihuaRepo = RecordBackedMeiHuaRepository(store: store, codec: meihuaCodec);
    final liuyaoRepo = RecordBackedLiuYaoRepository(store: store, codec: liuyaoCodec);

  STEP_4: |
    验证双模块隔离:
    - 梅花写一条记录 → 六爻 getAllRecords 看不到
    - 六爻写一条记录 → 梅花 getAllRecords 看不到
    - 同一 index key (如 original_gua_id) 在梅花和六爻中互不可见
    - 软删除只影响本模块记录

PROHIBITED:
  - 创建独立的 LocalRecordRepository 实例给六爻
  - 修改 SixYaoDivinationRecordRepository 接口
  - 在 liuyao codec 中硬编码 scope
  - 改变 yaoResults 的 JSON 序列化格式

ABSOLUTELY_PROHIBITED:
  - 在 liuyao repository 中直接访问 Drift 数据库

ASSERTIONS:
  EXECENV: "dart analyze xuan-storage/drift/lib/liuyao/ 零错误"
  CASES:
    - "LiuYaoRecordCodec 往返 encode→decode 保真 (含 yaoResults 嵌套结构)"
    - "六爻 getAllRecords 和 getLatestRecords 满足契约"
    - "双模块共享同一个 store 实例"
    - "梅花写记录 → 六爻查不到 (module 隔离)"
    - "同一 index key 不同 module 互不可见"

PROTOCOL:
  MODE: "edit-files-only"
  NO_PROSE: true
  OUTPUT_FORMAT: "修改现有 liuyao 文件"

VERIFICATION: "dart analyze xuan-storage/drift/lib/liuyao/ | grep -c 'No issues found'"
```

---

## ACT-6: Phase 5 — 验收与门禁

```yaml
TASK_ID: "typed-record-phase5-acceptance"
LANG: "dart"
TARGET_FILE: "openspec/changes/typed-record-backed-repository-base/"
CONTEXT:
  DOMAIN: |
    验收阶段不写新功能代码。只执行验证命令、补充测试、通过门禁。

    门禁清单 (来自 Base 设计文档 §16):
    - [x] 独立 OpenSpec change 已创建
    - [ ] OpenSpec change 已由人类批准
    - [x] OpenSpec proposal/design/tasks/spec delta 齐全
    - [x] openspec validate --strict 零错误
    - [x] t_record_meta 保持 UUID 单列主键
    - [x] GitNexus impact 不再是 UNKNOWN
    - [ ] HIGH/CRITICAL 影响已经向用户说明并取得批准
    - [x] 编译 spike 已完成
    - [x] 双模块测试计划完整
    - [x] scope/module 负向测试已进入任务清单
    - [x] 迁移通用化不属于第一期
    - [ ] gStack 工程复评给出明确 verdict
    - [ ] Reviewer 与 QA Delivery Auditor 均未留下 blocker

  STRATEGY: |
    补齐可自动化的验证，标记需人类操作的项。

TASK_DEPS:
  - "typed-record-phase4-liuyao-dual-module"

COMMANDS:
  PRECHECK: |
    echo "验证所有前置 Phase 已完成"

  STEP_1: |
    运行全量静态分析。

  STEP_1_CONTENT: |
    cd repository-interface-record && dart analyze
    cd xuan-storage/drift && dart analyze
    cd repository-interface-meihuayishu && dart analyze
    cd repository-interface-liuyao && dart analyze

  STEP_2: |
    运行所有相关测试。

  STEP_2_CONTENT: |
    cd repository-interface-record && dart test
    cd xuan-storage/drift && dart test --tags=record

  STEP_3: |
    运行 OpenSpec 严格校验。

  STEP_3_CONTENT: |
    openspec validate typed-record-backed-repository-base --strict

  STEP_4: |
    运行 GitNexus 影响分析。

  STEP_4_CONTENT: |
    gitnexus detect-changes --change typed-record-backed-repository-base

  STEP_5: |
    补充 scope/module 负向测试 (若 Phase 3-4 未覆盖):
    注意: 这是补充测试代码，不属于"新功能"，是验收必需的回归保障。
    - 两个 scope 使用相同 index key/value 互不可见
    - 两个 module 使用相同 index key/value 互不可见
    - 其他 module 的 UUID 不能通过当前模块仓库解码
    - 软删除只删除当前 scope/module 的索引
    - meta 与索引写入事务原子性
    - 索引查询排除软删除
    - 结果排序为 createdAt DESC, uuid ASC
    - getAll 不截断 (遍历分页直到结束)
    - watchByIndex 不通过全量 watchAll 模拟

  STEP_6: |
    标记需人类操作的未完成门禁:
    - [ ] OpenSpec change 已由人类批准
    - [ ] HIGH/CRITICAL 影响已经向用户说明并取得批准
    - [ ] gStack 工程复评给出明确 verdict
    - [ ] Reviewer 与 QA Delivery Auditor 均未留下 blocker

PROHIBITED:
  - 在验收阶段写新功能代码
  - 跳过任何门禁步骤

ABSOLUTELY_PROHIBITED:
  - 在人类批准 OpenSpec change 前合并代码

ASSERTIONS:
  EXECENV: "所有 dart analyze 零错误，所有测试通过"
  CASES:
    - "openspec validate --strict 返回 0 failed"
    - "GitNexus 影响分析无 UNKNOWN"
    - "所有负向测试通过"

PROTOCOL:
  MODE: "verify-only"
  NO_PROSE: true
  OUTPUT_FORMAT: "门禁检查清单"

VERIFICATION: "所有自动化门禁通过 + 人类批准 OpenSpec change"
```

---

## ACT-7: 新模块接入模板 (供后续模块参考)

```yaml
TASK_ID: "typed-record-new-module-template"
LANG: "dart"
TARGET_FILE: "xuan-storage/drift/lib/<module>/"
CONTEXT:
  DOMAIN: |
    此任务为模板，供奇门/大六壬/紫微/太乙/铁板/奇政等模块接入时参考。
    每个新模块需写 3-4 个文件，~150-250 行代码。

    接入前提:
    - 模块已有 repository-interface-<module> 包 (含 RecordRepository 端口 + Contract 模型)
    - Phase 1-3 已完成 (RecordModuleCodec + Base + ScopedRecordStore 可用)

  STRATEGY: |
    按以下顺序创建文件:
    1. <Module>RecordCodec (实现 RecordModuleCodec<TContract>)
    2. RecordBacked<Module>Repository (继承 Base，实现模块端口)
    3. (可选) <module>_record_migration.dart
    4. DI 装配注册

TASK_DEPS:
  - "typed-record-phase3-base-and-meihua"

COMMANDS:
  STEP_1: |
    创建 <Module>RecordCodec。
    模板:

  STEP_1_CONTENT: |
    import 'dart:convert';
    import 'package:repository_interface_<module>/repository_interface_<module>.dart';
    import 'package:repository_interface_record/repository_interface_record.dart';

    class <Module>RecordCodec implements RecordModuleCodec<<Module>RecordContract> {
      @override String get module => '<module_key>';        // snake_case, 与 t_record_meta.module 一致
      @override String get category => 'divination';        // 或 'destiny'
      @override String get divinationType => '<type_key>';  // snake_case

      @override String uuidOf(<Module>RecordContract c) => c.uuid;

      @override
      <Module>RecordContract withUuid(<Module>RecordContract c, String uuid) {
        return <Module>RecordContract(
          uuid: uuid,
          // ... 复制其他字段，派生字段 (如 divinationUuid) 空时填 uuid
        );
      }

      @override
      EncodedRecord encode(<Module>RecordContract c, {required String scopeUid}) {
        final data = <String, dynamic>{
          // ... 模块特有字段
        };
        final meta = RecordMeta(
          uuid: c.uuid, scopeUid: scopeUid, module: module, category: category,
          divinationType: divinationType, question: c.question,
          moduleDataJson: jsonEncode(data),
          navParamsJson: jsonEncode({'recordUuid': c.uuid}),
          createdAt: c.createdAt, updatedAt: c.updatedAt,
          deletedAt: c.deletedAt, rev: 1,
        );
        return (meta: meta, moduleData: data);
      }

      @override
      <Module>RecordContract decode(RecordMeta meta, Map<String, dynamic>? moduleData) {
        if (meta.module != module) throw RecordCodecMismatch(message: 'module mismatch');
        final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
        return <Module>RecordContract(
          uuid: meta.uuid,
          // ... 从 d 中读取字段
          createdAt: meta.createdAt,
          updatedAt: meta.updatedAt ?? meta.createdAt,
          deletedAt: meta.deletedAt,
        );
      }

      @override
      List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? moduleData) {
        final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
        return [
          // 定义搜索索引标签，key 使用 snake_case
          SearchTag('<index_key>', '${d['<field>']}'),
        ];
      }
    }

  STEP_2: |
    创建 RecordBacked<Module>Repository。

  STEP_2_CONTENT: |
    import 'package:repository_interface_<module>/repository_interface_<module>.dart';
    import '../record/base_record_backed_repository.dart';
    import '<module>_record_codec.dart';

    class RecordBacked<Module>Repository
        extends BaseRecordBackedRepository<<Module>RecordContract>
        implements <Module>RecordRepository {

      RecordBacked<Module>Repository({
        required super.store,
        required super.codec,
        super.uuid,
      });

      @override Future<String> saveRecord(<Module>RecordContract r) => save(r);
      @override Future<<Module>RecordContract?> getRecordByUuid(String u) => getByUuid(u);
      @override Future<List<<Module>RecordContract>> getAllRecords() => getAll();
      @override Future<bool> softDeleteRecord(String u) => softDelete(u);

      // 模块特有方法示例:
      // @override Future<List<T>> getLatestRecords({int limit = 10}) => getLatest(limit: limit);
      // @override Future<T?> getRecordByXxx(String x) => getFirstByIndex('xxx', x);
    }

  STEP_3: |
    DI 装配:
    在 composition root 中注册新 codec 到共享 RecordAdapterRegistry。

  STEP_3_CONTENT: |
    final <module>Codec = <Module>RecordCodec();
    // 注册到已有 registry (scope_uid 来自 ScopeResolver.resolve()):
    // final registry = RecordAdapterRegistry([meihuaCodec, liuyaoCodec, <module>Codec]);
    final <module>Repo = RecordBacked<Module>Repository(store: store, codec: <module>Codec);

  STEP_4: |
    验证清单:
    - [ ] dart analyze 零错误
    - [ ] codec encode→decode 往返测试
    - [ ] withUuid 空 UUID 回填测试
    - [ ] module/category/divinationType 正确
    - [ ] 所有必需索引标签存在
    - [ ] 与已有模块 (梅花/六爻) 互不可见 (module 隔离)
    - [ ] 与不同 scope 互不可见 (scope 隔离)

PROHIBITED:
  - 创建独立的 LocalRecordRepository 实例
  - 在 codec 或 repository 中硬编码 scope
  - 直接访问 Drift 数据库或 search index 表
  - 修改 Base 或 RecordModuleCodec 接口

ABSOLUTELY_PROHIBITED:
  - 复制 Base 的方法实现到子类
  - 绕过 ScopeResolver 自行生成 scope_uid

ASSERTIONS:
  EXECENV: "dart analyze 零错误，所有测试通过"
  CASES:
    - "codec 往返保真"
    - "module 隔离有效"
    - "scope 隔离有效"

PROTOCOL:
  MODE: "write-files-only"
  NO_PROSE: true
  OUTPUT_FORMAT: "产出 .dart 文件"

VERIFICATION: "dart analyze && dart test"
```

---

## 附录 A: 文件路径速查

| 文件 | Phase | 操作 |
|------|-------|------|
| `repository-interface-record/lib/src/ports/record_search_tag_extractor.dart` | 1 | 新建 |
| `repository-interface-record/lib/src/ports/record_module_codec.dart` | 1 | 新建 |
| `repository-interface-record/lib/src/ports/record_index_repository.dart` | 1 | 新建 |
| `repository-interface-record/lib/src/ports/scoped_record_store.dart` | 1 | 新建 |
| `repository-interface-record/lib/src/ports/record_repository.dart` | 1 | 修订 |
| `repository-interface-record/lib/repository_interface_record.dart` | 1 | 修订 |
| `repository-interface-record/lib/src/fakes/in_memory_record_repository.dart` | 1 | 修订 |
| `xuan-storage/drift/lib/record/drift_record_data_source.dart` | 2 | 修订 |
| `xuan-storage/drift/lib/record/local_record_repository.dart` | 2 | 修订 |
| `xuan-storage/drift/lib/scope/scope_alias_entry.dart` | 2.5 | 新建 |
| `xuan-storage/drift/lib/scope/scope_bootstrap_store.dart` | 2.5 | 新建 |
| `xuan-storage/drift/lib/scope/scope_ledger.dart` | 2.5 | 新建 |
| `xuan-storage/drift/lib/scope/scope_resolver.dart` | 2.5 | 新建 |
| `xuan-storage/drift/lib/scope/drift_scope_alias_table.dart` | 2.5 | 新建 |
| `xuan-storage/drift/lib/scope/drift_scope_ledger.dart` | 2.5 | 新建 |
| `xuan-storage/drift/lib/persistence_drift.dart` | 2.5 | 修订 (schema 2→3, 注册 t_scope_alias) |
| `xuan-storage/drift/lib/record/base_record_backed_repository.dart` | 3 | 新建 |
| `xuan-storage/drift/lib/meihuayishu/meihua_record_codec.dart` | 3 | 新建 |
| `xuan-storage/drift/lib/meihuayishu/record_backed_meihua_repository.dart` | 3 | 改写 |
| `xuan-storage/drift/lib/liuyao/liuyao_record_codec.dart` | 4 | 改写 |
| `xuan-storage/drift/lib/liuyao/record_backed_liuyao_repository.dart` | 4 | 改写 |
| `xuan-storage/drift/pubspec.yaml` | 2.5/4 | 修订 |

## 附录 B: 依赖图

```
ACT-1 (接口) ──┬──► ACT-2 (Drift scope 修复)
               ├──► ACT-3 (scope 身份绑定)
               │         │
               │         ▼
               └────► ACT-4 (Base + 梅花)
                          │
                          ▼
                       ACT-5 (六爻双模块)
                          │
                          ▼
                       ACT-6 (验收)
                          
ACT-7 (新模块模板) ← 独立，可在 ACT-4 完成后随时使用
```
