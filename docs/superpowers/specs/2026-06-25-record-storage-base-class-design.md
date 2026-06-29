# 类型安全的可复用记录存储 Base — 修订设计

> **状态**：修订版，OpenSpec 草案已创建，待工程复评
> **原始提案日期**：2026-06-25
> **修订日期**：2026-06-27
> **适用范围**：`repository-interface-record`、`xuan-storage/drift`、梅花记录仓库、六爻记录仓库
> **参照实现**：`RecordBackedMeiHuaRepository`
> **实施结论**：本文档通过全部放行门禁前，不得进入编码阶段

---

## 1. 结论摘要

本设计保留“复用记录仓库 CRUD/watch/index 委托逻辑”的目标，但不采用原提案中直接持有
`DriftRecordDataSource` 和数据库对象的 Base，也不在第一期通用化迁移。

第一期采用以下边界：

1. 新增类型安全的 `RecordModuleCodec<TContract>`，负责模块合约与 `RecordMeta` 的双向转换、
   UUID 读取和 UUID 回填。
2. 新增只负责索引标签的非泛型 `RecordSearchTagExtractor`，供异构注册表使用。
3. `BaseRecordBackedRepository<TContract>` 只依赖一个 scope-bound 的
   `ScopedRecordStore`，不依赖 Drift、数据库或具体表。
4. UUID、module、scope 隔离由端口和 Base 共同强制执行。
5. `getAll`、分页、latest、索引查询和索引监听具有明确且互不混淆的语义。
6. 通用迁移、跨进程共享库和远端同步不属于第一期。

该方向在工程上可行，但属于公共接口和持久化查询能力变更。独立 OpenSpec change 为
`typed-record-backed-repository-base`；完成严格校验、影响分析和工程复评后才能实施。

---

## 2. 背景与问题

现有 `RecordBackedMeiHuaRepository` 已验证下列链路能够工作：

```text
模块端口
  → 模块合约
  → 模块适配器
  → RecordMeta + moduleData
  → RecordRepository
  → DriftRecordDataSource
  → t_record_meta / t_record_search_index
```

以下逻辑会在每个记录型模块中重复：

- 空 UUID 的生成与回填；
- 合约到 `RecordMeta` 的编码；
- 按 module 读取和监听；
- UUID 查询与软删除；
- search index 查询；
- `RecordMeta` 到合约的解码。

但原提案存在以下结构性问题：

- adapter 输入输出为 `Object`，泛型 Base 不能提供真实的编译期类型安全；
- Base 直接查询 Drift 表，破坏存储端口边界；
- 索引查询缺少 scope 隔离；
- UUID 查询未校验 module；
- `getAll()` 以默认 1000 条静默截断；
- 私有 `_extractUuid` 被设计成可由子类 override，Dart 中不可行；
- 通用迁移缺少稳定身份、分批、失败恢复和空 UUID 幂等语义；
- `moduleKey` 与 `adapter.module` 是两个可能漂移的事实来源。

本次修订以消除这些问题为前提，而不是把当前梅花实现原样搬进父类。

---

## 3. 目标与非目标

### 3.1 第一阶段目标

- 为梅花和六爻提供同一套类型安全的仓库委托能力。
- Base 不导入 Drift，不知道表名，不访问 `PersistenceDriftDatabase`。
- 任意读取、索引查询、监听和删除均保持 scope/module 隔离。
- 模块 codec 类型不匹配在编译期暴露，而不是运行到 `as` 才失败。
- 保留现有模块端口，不要求业务 use case 改为依赖 Base。
- 为分页、全量、latest 和索引监听提供可测试的确定语义。
- 让新模块接入时只实现 codec、端口薄适配和 DI 注册。

### 3.2 明确非目标

- 第一阶段不抽象旧库迁移循环。
- 第一阶段不修改远端同步、Outbox 或 Firebase。
- 第一阶段不改变业务模块现有仓库端口的方法名。
- 第一阶段不承诺消灭所有模块代码；字段映射仍然属于模块职责。
- 第一阶段不引入反射、代码生成或运行时 service locator。
- 第一阶段不把 Base 暴露给业务层。

### 3.3 成功指标

成功不以“减少多少行”为唯一标准，而以以下结果为准：

- 梅花和六爻共用同一 Base，行为契约测试全部通过；
- Base 源码中不存在 Drift import、数据库 getter 或表查询；
- codec 使用错误不能通过静态分析；
- scope/module 负向测试通过；
- 新模块接入不需要复制 CRUD、索引查询或监听算法；
- 所有 OpenSpec 和测试门禁通过。

---

## 4. 方案比较

### 4.1 方案 A：类型安全 codec + 端口化 Base（采用）

Base 依赖同时实现 `RecordRepository` 和 `RecordIndexRepository` 的单一
`ScopedRecordStore`，模块通过 `RecordModuleCodec<TContract>` 提供类型信息。

优点：

- 类型安全；
- 不泄漏 Drift；
- 索引查询可由 Drift、内存或远端实现；
- Base 可独立测试；
- 适合梅花和六爻端口差异。

代价：

- 需要调整 `repository-interface-record` 公共接口；
- 注册表需与 typed codec 分离；
- 实施前必须做跨包影响分析。

### 4.2 方案 B：保留 `Object` adapter，仅抽取现有代码（拒绝）

优点是改动小，但会永久保留运行时 cast、module 双重配置和 Drift 耦合。它只能减少几行代码，
不能提高正确性，因此不采用。

### 4.3 方案 C：不建 Base，继续复制垂直切片（保留为回退）

若 OpenSpec 影响分析证明公共端口变更成本过高，则暂时继续使用组合与复制，但必须先修复
scope/module 查询缺陷。该方案是安全回退，不是首选。

---

## 5. 架构边界

```text
┌──────────────────────────────────────────────────────┐
│  模块业务层                                           │
│  仅依赖 MeiHua/SixYao 等模块仓库端口                  │
└────────────────────────┬─────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────┐
│  RecordBackedModuleRepository                        │
│  implements 模块端口                                 │
│  一行委托给 Base                                     │
└────────────────────────┬─────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────┐
│  BaseRecordBackedRepository<TContract>               │
│  只依赖：                                             │
│  - ScopedRecordStore                                 │
│  - RecordModuleCodec<TContract>                      │
└───────────────┬──────────────────────┬───────────────┘
                │                      │
┌───────────────▼──────────────┐  ┌────▼────────────────┐
│ LocalRecordRepository       │  │ ModuleRecordCodec<T>│
│ 端口实现，scope-bound       │  │ typed encode/decode │
└───────────────┬──────────────┘  └─────────────────────┘
                │
┌───────────────▼──────────────────────────────────────┐
│ DriftRecordDataSource                                │
│ 唯一允许知道 Drift 表和 scope_uid 的层               │
└──────────────────────────────────────────────────────┘
```

### 5.1 依赖规则

- 业务层不得依赖 Base。
- Base 不得依赖 `package:drift`、`PersistenceDriftDatabase` 或具体 datasource。
- codec 不得直接写数据库。
- scope 由单一 `ScopedRecordStore` 绑定；codec 不持有 scope，Base 不接受调用方临时传入
  scope。
- module 的唯一来源是 codec。
- 索引查询必须通过同一个 `ScopedRecordStore`。

---

## 6. 公共类型设计

以下签名是待 OpenSpec 固化的接口草案。实施时须先在独立分支中进行编译验证。

### 6.1 编码结果

```dart
typedef EncodedRecord = ({
  RecordMeta meta,
  Map<String, dynamic>? moduleData,
});
```

### 6.2 非泛型标签提取端口

注册表需要容纳不同模块，因此只保存它真正需要的能力，不保存 typed encode/decode。

```dart
abstract interface class RecordSearchTagExtractor {
  String get module;

  List<SearchTag> extractSearchTags(
    RecordMeta meta,
    Map<String, dynamic>? moduleData,
  );
}
```

### 6.3 类型安全模块 codec

```dart
abstract interface class RecordModuleCodec<TContract>
    implements RecordSearchTagExtractor {
  String get category;
  String get divinationType;

  String uuidOf(TContract contract);

  TContract withUuid(TContract contract, String uuid);

  EncodedRecord encode(
    TContract contract, {
    required String scopeUid,
  });

  TContract decode(
    RecordMeta meta,
    Map<String, dynamic>? moduleData,
  );
}
```

设计约束：

- `encode` 生成的 `meta.module` 必须等于 `module`。
- `encode` 生成的 `meta.scopeUid` 必须等于调用方传入的 `scopeUid`。
- `encode` 生成的 `meta.category` 和 `meta.divinationType` 必须与 codec getter 一致。
- `withUuid` 必须只改变 UUID 及由 UUID 派生、且契约明确允许回填的字段。
- `decode` 收到其他 module 的 meta 时必须抛出明确的 `RecordCodecMismatch`，不能盲目 cast。
- codec 的字段往返必须由单元测试证明。

### 6.4 为什么拆成两个接口

`RecordAdapterRegistry` 只需要按 module 找到标签提取器；如果它保存
`RecordModuleCodec<Object>`，Dart 的泛型参数和方法入参会重新引入运行时类型风险。

因此：

- Base 持有 `RecordModuleCodec<TContract>`；
- Registry 持有 `RecordSearchTagExtractor`；
- 同一个具体 codec 同时实现两种用途，但注册表不会调用 typed encode/decode。

---

## 7. 存储端口修订

### 7.1 `RecordRepository`

```dart
abstract interface class RecordRepository {
  Future<void> saveRecord(
    RecordMeta record, {
    Map<String, dynamic>? moduleData,
  });

  Future<RecordMeta?> getRecord(
    String uuid, {
    required String module,
  });

  Future<List<RecordMeta>> listRecords({
    required String module,
    String? category,
    String? divinationType,
    required int limit,
    String? cursor,
  });

  Stream<List<RecordMeta>> watchRecords({
    required String module,
  });

  Future<bool> softDeleteRecord(
    String uuid, {
    required String module,
  });
}
```

语义要求：

- 具体实现是 scope-bound 的。
- `getRecord`、`softDeleteRecord` 必须同时约束当前 scope 和 module。
- `listRecords` 只返回未删除记录，按 `createdAt DESC, uuid ASC` 排序。
- `limit` 必须为正数；非法值抛出参数错误。
- cursor 必须与同一 module/scope 的排序规则匹配。

### 7.2 `RecordIndexRepository`

```dart
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
```

语义要求：

- scope 由实现绑定并强制过滤。
- 查询必须排除软删除记录。
- 结果按 `createdAt DESC, uuid ASC` 确定排序。
- 单条查询由调用方对结果执行 `firstOrNull`，不依赖数据库无序的 `rows.first`。
- Drift 实现应使用 join 或等价查询一次返回 `RecordMeta`，禁止 Base 执行 N+1 UUID 查询。

### 7.3 `ScopedRecordStore`

Base 不分别接收记录端口和索引端口，避免两个实现绑定到不同 scope。

```dart
abstract interface class ScopedRecordStore
    implements RecordRepository, RecordIndexRepository {
  String get scopeUid;
}
```

语义要求：

- `scopeUid` 是 Base 所有操作的唯一 scope 来源。
- `saveRecord` 必须拒绝 `record.scopeUid != scopeUid`，不能静默改写。
- codec 不在构造函数中接收 scope；Base 调用 `encode` 时显式传入 `store.scopeUid`。
- Drift 的 `LocalRecordRepository` 应实现 `ScopedRecordStore`。

### 7.4 索引表约束

OpenSpec 必须决定并记录是否为 `t_record_search_index` 增加以下约束：

```text
UNIQUE(scope_uid, module, index_key, index_value, record_uuid)
INDEX(scope_uid, module, index_key, index_value)
```

无论是否增加唯一约束，所有删除、替换、查询和监听都必须包含当前 `scope_uid`。

---

## 8. Base 设计

```dart
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

  Future<String> save(TContract contract) async {
    final currentUuid = _codec.uuidOf(contract);
    final effectiveUuid =
        currentUuid.isEmpty ? _uuid.v7() : currentUuid;
    final fixed = currentUuid.isEmpty
        ? _codec.withUuid(contract, effectiveUuid)
        : contract;
    final encoded = _codec.encode(
      fixed,
      scopeUid: _store.scopeUid,
    );
    _validateEncodedMeta(encoded.meta, effectiveUuid);
    await _store.saveRecord(
      encoded.meta,
      moduleData: encoded.moduleData,
    );
    return effectiveUuid;
  }

  Future<TContract?> getByUuid(String uuid) async {
    final meta = await _store.getRecord(
      uuid,
      module: module,
    );
    return meta == null ? null : _codec.decode(meta, null);
  }

  Future<bool> softDelete(String uuid) {
    return _store.softDeleteRecord(
      uuid,
      module: module,
    );
  }

  Future<List<TContract>> getLatest({int limit = 10}) async {
    _requirePositiveLimit(limit);
    final metas = await _store.listRecords(
      module: module,
      limit: limit,
    );
    return metas.map((meta) => _codec.decode(meta, null)).toList();
  }

  Future<List<TContract>> getAll({int pageSize = 200}) async {
    _requirePositiveLimit(pageSize);
    final result = <TContract>[];
    String? cursor;
    do {
      final page = await _store.listRecords(
        module: module,
        limit: pageSize,
        cursor: cursor,
      );
      result.addAll(page.map((meta) => _codec.decode(meta, null)));
      if (page.length < pageSize) break;
      cursor = RecordCursor(
        page.last.createdAt,
        page.last.uuid,
      ).encode();
    } while (true);
    return result;
  }

  Stream<List<TContract>> watchAll() {
    return _store.watchRecords(module: module).map(
      (metas) =>
          metas.map((meta) => _codec.decode(meta, null)).toList(),
    );
  }

  Future<TContract?> getFirstByIndex(
    String indexKey,
    String indexValue,
  ) async {
    final metas = await _store.findByIndex(
      module: module,
      indexKey: indexKey,
      indexValue: indexValue,
      limit: 1,
    );
    return metas.isEmpty ? null : _codec.decode(metas.first, null);
  }

  Future<List<TContract>> findByIndex(
    String indexKey,
    String indexValue, {
    int limit = 200,
  }) async {
    _requirePositiveLimit(limit);
    final metas = await _store.findByIndex(
      module: module,
      indexKey: indexKey,
      indexValue: indexValue,
      limit: limit,
    );
    return metas.map((meta) => _codec.decode(meta, null)).toList();
  }

  Stream<TContract?> watchFirstByIndex(
    String indexKey,
    String indexValue,
  ) {
    return _store
        .watchByIndex(
          module: module,
          indexKey: indexKey,
          indexValue: indexValue,
        )
        .map(
          (metas) =>
              metas.isEmpty ? null : _codec.decode(metas.first, null),
        );
  }

  void _validateEncodedMeta(RecordMeta meta, String uuid) {
    if (meta.uuid != uuid ||
        meta.scopeUid != _store.scopeUid ||
        meta.module != _codec.module ||
        meta.category != _codec.category ||
        meta.divinationType != _codec.divinationType) {
      throw RecordCodecMismatch(
        expectedUuid: uuid,
        actualUuid: meta.uuid,
        expectedScopeUid: _store.scopeUid,
        actualScopeUid: meta.scopeUid,
        expectedModule: _codec.module,
        actualModule: meta.module,
        expectedCategory: _codec.category,
        actualCategory: meta.category,
        expectedDivinationType: _codec.divinationType,
        actualDivinationType: meta.divinationType,
      );
    }
  }

  void _requirePositiveLimit(int limit) {
    if (limit <= 0) {
      throw ArgumentError.value(limit, 'limit', 'must be positive');
    }
  }
}
```

### 8.1 Base 的固定不变量

- module 只来自 codec。
- scope 只来自 `ScopedRecordStore`。
- 空 UUID 先生成并回填，再编码。
- 编码结果在写入前校验 UUID/scope/module/category/divinationType。
- UUID 查询和软删除始终携带 module。
- Base 不捕获并吞掉存储异常。
- Base 不直接接触 scopeUid；scope 由端口实现绑定。
- Base 不直接接触 search index 表。
- Base 不为 `getAll` 设置隐藏的总数上限。

### 8.2 `getAll` 与分页

现有模块端口把方法命名为 `getAllRecords`，因此 Base 的 `getAll` 必须遍历 cursor 直到结束，
不能默默返回前 1000 条。

需要页面级消费的模块应新增显式 `listPage` 端口，而不是改变 `getAll` 的含义。

### 8.3 `watchAll` 的边界

`watchAll` 保留现有行为，用于记录量有限且端口已经承诺全量监听的模块。高数据量模块不得默认
暴露该方法，应设计分页或查询条件监听。第一期不试图建立通用分页 stream。

---

## 9. 模块实现示例

### 9.1 梅花仓库

```dart
final class RecordBackedMeiHuaRepository
    extends BaseRecordBackedRepository<MeiHuaDivinationRecordContract>
    implements MeiHuaDivinationRecordRepository {
  RecordBackedMeiHuaRepository({
    required super.store,
    required super.codec,
    super.uuid,
  });

  @override
  Future<String> saveRecord(MeiHuaDivinationRecordContract record) =>
      save(record);

  @override
  Future<List<MeiHuaDivinationRecordContract>> getAllRecords() =>
      getAll();

  @override
  Stream<List<MeiHuaDivinationRecordContract>> watchAllRecords() =>
      watchAll();

  @override
  Future<MeiHuaDivinationRecordContract?> getRecordByUuid(String uuid) =>
      getByUuid(uuid);

  @override
  Future<MeiHuaDivinationRecordContract?> getRecordByDivinationUuid(
    String divinationUuid,
  ) =>
      getFirstByIndex('divination_uuid', divinationUuid);

  @override
  Stream<MeiHuaDivinationRecordContract?> watchRecordByDivinationUuid(
    String divinationUuid,
  ) =>
      watchFirstByIndex('divination_uuid', divinationUuid);

  @override
  Future<bool> softDeleteRecord(String uuid) => softDelete(uuid);
}
```

### 9.2 六爻仓库

```dart
final class RecordBackedLiuYaoRepository
    extends BaseRecordBackedRepository<SixYaoDivinationRecord>
    implements SixYaoDivinationRecordRepository {
  RecordBackedLiuYaoRepository({
    required super.store,
    required super.codec,
    super.uuid,
  });

  @override
  Future<String> saveRecord(SixYaoDivinationRecord record) =>
      save(record);

  @override
  Future<SixYaoDivinationRecord?> getRecordByUuid(String uuid) =>
      getByUuid(uuid);

  @override
  Future<List<SixYaoDivinationRecord>> getAllRecords() => getAll();

  @override
  Future<bool> softDeleteRecord(String uuid) => softDelete(uuid);

  @override
  Future<List<SixYaoDivinationRecord>> getLatestRecords({
    int limit = 10,
  }) =>
      getLatest(limit: limit);
}
```

示例表达目标接口形状，不作为编译通过证据。实施阶段必须以真实 package export、构造参数语法和
当前 Dart SDK 运行 `dart analyze`。

---

## 10. DI 与注册

注册表必须在 composition root 一次性收集本应用启用的全部模块 codec，不能让每个模块创建
只包含自己的“局部统一仓库”。

```dart
final meihuaCodec = MeiHuaRecordCodec();
final liuYaoCodec = LiuYaoRecordCodec();

final tagRegistry = RecordSearchTagRegistry([
  meihuaCodec,
  liuYaoCodec,
]);

final dataSource = DriftRecordDataSource(
  database,
  scopeUid: currentScopeUid,
);

final localRecords = LocalRecordRepository(
  dataSource,
  tagRegistry,
);

final meihuaRepository = RecordBackedMeiHuaRepository(
  store: localRecords,
  codec: meihuaCodec,
);
```

注册时必须拒绝重复 module，并在错误中列出冲突 module 和 codec 类型。

---

## 11. Scope、module 与数据完整性

> **前置阅读**：scope_uid 的完整生命周期语义（铸造、身份绑定、升级零重写、Phase 切分）见 [2026-06-27-scope-uid-identity-binding-design.md](./2026-06-27-scope-uid-identity-binding-design.md)。本节聚焦 scope 在 Base 和存储层中的使用契约。

### 11.1 强制过滤矩阵

| 操作 | scope | module | deletedAt |
|------|-------|--------|-----------|
| save/replace meta | 当前 scope | codec module | 允许保存传入状态 |
| replace search tags | 当前 scope | codec module | 不适用 |
| get by UUID | 当前 scope | 必须匹配 | 端口决定是否返回已删除记录；V1 返回记录原状态 |
| list/latest/all | 当前 scope | 必须匹配 | 仅未删除 |
| find/watch index | 当前 scope | 必须匹配 | 仅未删除 |
| soft delete | 当前 scope | 必须匹配 | 写入删除时间 |
| delete search tags | 当前 scope | 必须匹配 | 不适用 |

### 11.2 当前表主键约束

`t_record_meta` 继续以 `uuid` 单列为主键。记录 UUID 是跨 scope 全局唯一标识：

- 新记录必须使用 UUIDv7 或等价的全局唯一 UUID；
- 导入记录若 UUID 已被其他 scope 占用，必须报告冲突，不能覆盖或静默改写；
- 第一阶段不把主键改成 `(scope_uid, uuid)`，因此不需要主键 schema migration；
- scope 仍是授权和查询隔离条件，不能因为 UUID 全局唯一而省略。

### 11.3 软删除索引

当前 datasource 删除搜索索引时必须补齐 scope/module 条件。Base 只调用端口，不承担补救。
软删除 meta 与删除索引必须位于同一事务。

---

## 12. 错误处理

新增错误至少包括：

```text
RecordCodecMismatch
  - expectedScopeUid / actualScopeUid
  - expectedModule / actualModule
  - expectedCategory / actualCategory
  - expectedDivinationType / actualDivinationType
  - expectedUuid / actualUuid

DuplicateRecordModule
  - module
  - existingCodecType
  - incomingCodecType

InvalidRecordCursor
  - module
  - cursor
  - reason
```

规则：

- 不把 codec mismatch 转成 null。
- “未找到”返回 null；“找到了错误 module 的记录”属于数据完整性错误。
- JSON 解码错误保留原始 cause，但不得在日志中输出完整用户数据。
- 参数错误在进入 datasource 前失败。

---

## 13. 迁移设计

### 13.1 第一阶段决定

通用迁移函数从第一阶段移除。现有梅花迁移保持模块特有实现，六爻迁移也先按模块实现。

原因：

- 泛型 `TContract` 无法天然提供稳定 legacy identity；
- 空 UUID 记录无法仅靠 `getByUuid` 保证重跑幂等；
- 大库迁移需要批处理、checkpoint、错误策略和进度语义；
- 迁移与 CRUD Base 的发布风险不同，不应捆绑。

### 13.2 后续迁移设计的最低要求

后续独立 OpenSpec change 必须定义：

- `legacyIdentityOf(TLegacy)`；
- `contractUuidOf(TContract)`；
- 分页/分批读取；
- 每条或每批事务边界；
- checkpoint 和中断恢复；
- 重跑幂等；
- 空/非法 legacy identity 策略；
- 单条失败是终止、跳过还是收集；
- `onProgress` 是否包含最终 `total/total`；
- 迁移报告格式和回滚策略。

在这些语义确定前，不新增 `base_record_migration.dart`。

---

## 14. 测试与验收

### 14.1 codec 单元测试

每个 codec 必须覆盖：

- contract → encoded → contract 完整往返；
- 空 UUID 经 `withUuid` 回填后往返；
- module/category/divinationType 正确；
- 所有必需索引标签存在；
- 缺字段、错误 JSON、错误 module 的失败类型；
- nullable 字段和时间字段不丢失；
- 六爻 `yaoResults` 等嵌套结构往返。

### 14.2 Base 契约测试

用 fake repository 和 fake codec 覆盖：

- 非空 UUID 原样保存；
- 空 UUID 只生成一次，返回值和持久化值一致；
- 编码结果 UUID/module/category/type 不一致时拒绝写入；
- 编码结果 scope 不等于 store scope 时拒绝写入；
- Base 只能注入一个同时提供记录和索引能力的 store；
- UUID 查询携带 module；
- 软删除携带 module；
- `getLatest` 尊重 limit；
- `getAll` 跨越多页且不丢失、不重复；
- 非法 limit 在调用 datasource 前失败；
- 索引单条结果按确定顺序取第一条；
- 索引多结果不产生 N+1；
- watch index 正确发出新增、更新和删除后的结果。

### 14.3 Drift 集成测试

必须覆盖：

- 两个 scope 使用相同 index key/value 时互不可见；
- 两个 module 使用相同 index key/value 时互不可见；
- 其他 module 的 UUID 不能通过当前模块仓库解码；
- 软删除只删除当前 scope/module 的索引；
- meta 与索引写入事务原子性；
- 索引查询排除软删除；
- 结果排序为 `createdAt DESC, uuid ASC`；
- 超过 1000 条时 `getAll` 不截断；
- `watchByIndex` 不通过全量 `watchAll` 模拟。

### 14.4 双模块验收

第一期必须同时完成梅花和六爻两个模块，不能只用一个模块证明抽象：

- 梅花现有端口行为全部保持；
- 六爻 `getAllRecords` 和 `getLatestRecords` 满足现有契约；
- 两个 codec 同时注册；
- DI 不创建互相独立的局部 registry；
- 现有梅花记录数据无需重写即可读取。

### 14.5 必跑命令

具体命令由实施计划根据 package 边界固定，至少包括：

```text
dart analyze / flutter analyze
repository-interface-record tests
repository-interface-meihuayishu tests
repository-interface-liuyao tests
xuan-storage/drift record-related tests
OpenSpec strict validation
GitNexus detect changes
```

测试通过不等于设计自动批准；还必须满足第 16 节门禁。

---

## 15. 实施拆分

### Phase 0：规格与影响分析

- 使用 OpenSpec change：`typed-record-backed-repository-base`。
- 分离 proposal、design、tasks、spec delta。
- 为每个 requirement 提供 Scenario。
- 对公共端口和 schema 执行 GitNexus impact。
- 若 GitNexus 仍返回 `UNKNOWN`，先刷新有效索引，不得按低风险处理。
- 固化 `t_record_meta.uuid` 全局唯一、scope 作为查询隔离条件的策略。

### Phase 1：接口与 fake

- 新增 `RecordSearchTagExtractor`。
- 新增 `RecordModuleCodec<TContract>`。
- 修订 `RecordRepository`。
- 新增 `RecordIndexRepository`。
- 更新内存 fake 和契约测试。

### Phase 2：Drift 实现

- 修复所有 scope/module 过滤。
- 实现 join-based index query/watch。
- 补索引约束或 migration。
- 更新 `LocalRecordRepository` 和 registry。

### Phase 3：Base 与梅花

- 实现 Base。
- 将梅花 codec 和仓库迁移到新接口。
- 保持现有梅花端口和数据兼容。
- 通过全部梅花回归。

### Phase 4：六爻证明

- 增加 Drift package 所需依赖。
- 实现六爻 codec 和 repository。
- 完成双模块 DI。
- 通过六爻契约与双模块隔离测试。

### Phase 5：验收

- `openspec validate <change-id> --strict` 通过；
- analyze、测试和 `gitnexus_detect_changes` 通过；
- Reviewer 检查公共接口、scope/module 隔离和回归范围；
- QA Delivery Auditor 核对证据；
- 人类批准后方可合并。

---

## 16. 放行门禁

只有全部满足才能把状态改为“可实施”：

- [x] 独立 OpenSpec change 已创建。
- [ ] OpenSpec change 已由人类批准。
- [x] OpenSpec proposal/design/tasks/spec delta 齐全。
- [x] `openspec validate typed-record-backed-repository-base --strict` 零错误。
- [x] `t_record_meta` 保持 UUID 单列主键，UUID 跨 scope 全局唯一。
- [x] 公共接口和 schema 的 GitNexus impact 不再是 `UNKNOWN`。
- [ ] HIGH/CRITICAL 影响已经向用户说明并取得批准。
- [x] 文档中的接口草案已在真实 package 中完成编译 spike。
- [x] 梅花与六爻双模块测试计划完整。
- [x] scope/module 负向测试已进入任务清单。
- [x] 迁移通用化明确不属于第一期。
- [ ] gStack 工程复评给出明确 verdict。
- [ ] Reviewer 与 QA Delivery Auditor 均未留下 blocker。

任意一项未满足，结论均为 NO-GO。

---

## 17. 已决策事项

原提案中的未决问题已按本修订版收敛：

| 原问题 | 决策 |
|--------|------|
| UUID 如何提取 | codec 提供公开、类型安全的 `uuidOf`，不使用私有 `_extractUuid` |
| 是否需要 `fillContract` | codec 提供 `withUuid`，Base 不复制模块字段 |
| 是否需要 `watchBySearchIndex` | 第一阶段需要，由 `RecordIndexRepository.watchByIndex` 提供 |
| 迁移是否进入 Base | 不进入；第一阶段移除通用迁移 |
| Base 是否持有 datasource/db | 不持有，只依赖端口 |
| moduleKey 从哪里来 | 只来自 codec |
| `getAll` 是否有限制 | 遍历分页直到结束，不做静默总量截断 |
| scope 从哪里来 | 单一 `ScopedRecordStore.scopeUid`；codec 无 scope 状态 |
| UUID/scope 主键策略 | 保持 UUID 单列主键，UUID 跨 scope 全局唯一 |
| 索引多结果方法语义 | 使用 `findByIndex(..., limit:)`，不声称返回全部 |

---

## 18. 开发者接入清单

新模块接入前必须确认：

- [ ] 模块端口和 contract 已存在。
- [ ] codec 实现 `RecordModuleCodec<TContract>`。
- [ ] `uuidOf` 与 `withUuid` 行为明确。
- [ ] encode/decode 完整往返。
- [ ] module/category/divinationType 使用已批准常量。
- [ ] 必需 search tags 已定义。
- [ ] codec 注册到 composition root 的共享 registry。
- [ ] store 的 scope 从 DI 注入，不硬编码；codec 不保存 scope。
- [ ] 模块仓库只做端口到 Base 的薄委托。
- [ ] 没有直接访问 Drift 数据库或 search index 表。
- [ ] codec、Base 契约、Drift 集成和模块端口测试全部存在。

---

## 19. 风险登记

| 风险 | 等级 | 控制措施 |
|------|------|----------|
| 公共接口改动影响 fake、registry 和现有实现 | HIGH | OpenSpec + GitNexus impact + 分阶段迁移 |
| scope/module 过滤遗漏造成跨租户错误 | CRITICAL | 端口强制参数、datasource 过滤、负向测试 |
| search index 约束迁移破坏现有数据 | HIGH | 独立 migration、备份/回滚、兼容测试 |
| typed codec 与 registry 异构存储冲突 | MEDIUM | 拆分 typed codec 与非泛型 tag extractor |
| `getAll` 在极大数据集占用内存 | MEDIUM | 保持端口兼容；新模块优先使用分页端口 |
| watch index 实现触发全表刷新 | MEDIUM | Drift join watch、性能测试、禁止 Base 过滤全量 |
| 过早抽象收益不足 | MEDIUM | 必须由梅花+六爻两个真实模块证明 |

---

## 20. 当前证据

修订期间已执行现有记录链路基线测试：

```text
drift_record_data_source_test.dart
local_record_repository_test.dart
meihua_record_adapter_test.dart
meihua_record_migration_test.dart
record_backed_meihua_repository_test.dart
record_e2e_test.dart
```

共 15 项测试通过。该证据只证明当前梅花垂直切片基线可用，不证明本修订方案已实现或已通过。

独立 OpenSpec change `typed-record-backed-repository-base` 已创建，包含 proposal、design、
tasks 和 9 条 requirements 的 spec delta。严格校验结果为 1 passed、0 failed。

GitNexus 索引已刷新至当前提交。影响分析结果：

- `ModuleRecordAdapter`：LOW，8 个上游节点，2 个直接依赖；
- `RecordRepository`：LOW，10 个上游节点，4 个直接依赖；
- `LocalRecordRepository`：LOW，26 个上游节点，1 个直接依赖；
- `TRecordMeta` / `TRecordSearchIndex`：LOW，各 27 个上游节点。

当前仍未完成的证据是：人类批准、真实 package 编译 spike、gStack 工程复评，以及实现后的
Reviewer/QA Delivery Auditor 验收。因此本文档保持“待工程复评”状态。

---

## 21. 最终建议

先完成人类 OpenSpec 批准、GitNexus impact 和真实 package 编译 spike，不直接编码完整 Base。
这些门禁通过后再按 Phase 1–4 实施。

第一期的价值判断也必须基于双模块结果：如果梅花和六爻落地后仍需大量字段复制、特殊分支或
绕过 Base，则应停止推广并回退到组合方案，而不是继续扩大继承体系。
