# M1 record 切片化缺口落档（R2）

> 日期：2026-08-19
> 分支：`wip/m1-record-slice-migration`
> 目的：把 M1 试点中「未走 L0 契约内核路径」的现状、根因与后续影响正式落档，
> 供 M2（drift 与 rest 双实现跑同一套件）与 M4（适配层退场）排期使用。

## 背景

M1 试点将 `BaseRecordBackedRepository` 降级为适配层：读/删路径委托 L0 契约内核
（`CrudBaseRepository<Map<String, Object?>, String>` + `RecordStorageDriver` +
`recordEntityDescriptor`），但以下**四条路径**保留 `ScopedRecordStore` 端口直连：

1. `save`
2. `getByUuid`
3. `watchAll`
4. 三个索引查询（`getFirstByIndex` / `getAllByIndex` / `watchFirstByIndex`）

这四条路径的取舍此前只写在代码注释里，未形成正式文档；本文件补齐。

---

## 1. 四条路径逐条现状

### 1.1 `save`（store 端口直写）

| 项 | 说明 |
|---|---|
| 当前实现 | `_store.saveRecord(encoded.meta, moduleData: encoded.moduleData)`，先经 `RecordModuleCodec.encode` 产出 `RecordMeta + moduleData` 两段结构，再落库 |
| 未走 L0 的原因 | record 的 **encode / outbox / 搜索索引** 是 `ScopedRecordStore` 独有能力；L0 `put` 的行形态（`EntityCodec.toMap` 产出单行 Map）无法等价表达这两段结构 |
| 技术阻碍 | ① L0 `put` 只写一行 `Map<String, Object?>`，无法表达 `RecordMeta` 与 `moduleData` 的分离；② outbox 语义（记录写后待同步事件）无 L0 对应物；③ 搜索标签（`RecordSearchTagExtractor`）在 L0 侧无索引 API 承接 |
| 附加约束 | 直写与既有 `watchRecords` 流的时序保持一致，避免订阅竞争回归 |

### 1.2 `getByUuid`（store 端口直连）

| 项 | 说明 |
|---|---|
| 当前实现 | `_store.getRecord(uuid, module: module)` |
| 未走 L0 的原因 | 既有语义**允许读取已软删记录**（返回带 `deletedAt` 的实体）；L0 `get` 一律排除软删，语义不等价 |
| 技术阻碍 | L0 `RawFilter` 虽有 `includeSoftDeleted`，但 `get` 路径固定传 `filterOf(ctx, const {})`（不含软删），契约层面也未定义「读软删行」的返回形态（`get` 返回 `T?`，无 deletedAt 位） |

### 1.3 `watchAll`（store 端口直连）

| 项 | 说明 |
|---|---|
| 当前实现 | `_store.watchRecords(module: module, category: _codec.category)`，map 解码为 `TContract` 列表 |
| 未走 L0 的原因 | drift watch 的 **category SQL 过滤**与**订阅即发初始快照**时序语义，L0 `watch`（通用 equals 内存过滤）无法等价 |
| 技术阻碍 | ① L0 `watch` 只支持通用 equals 过滤，category（module 内子类型）语义缺失；② 订阅后首帧是否立即推送初始快照的时序由 driver 决定，既有行为是 drift watch 首帧即快照，L0 需在 driver 侧对齐 |

### 1.4 索引查询（三个方法，store 端口直连）

| 项 | 说明 |
|---|---|
| 当前实现 | `_store.findByIndex(module, indexKey, indexValue, limit)` / `_store.watchByIndex(...)` |
| 未走 L0 的原因 | **L0 契约内核暂无索引 API**；`RecordSearchTagExtractor` 标签体系是 record 独有能力，`findByIndex` 走的是 SQL 索引而非通用 equals 过滤 |
| 技术阻碍 | L0 `query` 的 equals 过滤是内存/全量语义，无法替代按标签列下推的 SQL 索引查询；索引 schema（`t_record_meta` 上的标签列与索引）在 L0 侧无对应声明 |

---

## 2. 关键根因：恒等 codec 导致的泛型断裂

`recordEntityDescriptor` 的 codec 是**恒等 codec**（`T = Map<String, Object?>`，行即实体），
而非将 `RecordModuleCodec<TContract>` 适配为 L0 `EntityCodec`。

- **现状**：`BaseRecordBackedRepository<TContract>` 持有两份能力——
  `_l0`（L0 仓储，实体类型 `Map<String, Object?>`）与 `_codec`（`RecordModuleCodec<TContract>`）。
  上层 `TContract` 泛型只存在于适配层，**无法穿透到 L0**。
- **直接后果**：`save(TContract)` 无法走 `L0.put`——L0 `put` 拿到的是恒等实体
  （行即实体），而 `save` 需要把 `TContract` encode 成 `RecordMeta + moduleData`
  两段结构再落库；恒等 codec 的行形态无法承载这段编码逻辑。
- **定性判断**：**有意取舍，同时是待偿债务**。
  - 有意：M1 目标是「八模块零改动 + C1–C10 契约全绿」，恒等 codec 让
    契约套件在最小改动面上跑通；写路径直连 store 避免了为 L0 补
    encode/outbox/索引能力带来的范围膨胀。
  - 债务：只要 `save` 还直连 store，L0 `put` 就没有真实写路径基准；
    适配 codec（让 `EntityCodec.toMap` 调 `RecordModuleCodec.encode`，
    `fromMap` 调 `decode`）是 M4 前必须补的桥梁，且该 codec 构造需要
    scopeUid（与单 scope 架构一致，参考既有 `RecordEntityCodec` 经验）。

---

## 3. 对 M2（drift 与 rest 双实现跑同一套件）的影响

- **写路径无 L0 基准**：契约套件 C1–C11 只覆盖 L0 语义（读写往返、scope 隔离、
  乐观锁、软删、分页、批量、错误码）；`save` 直连 store 意味着 drift 的
  record 写语义（encode/outbox/索引写入）**不在套件覆盖内**，REST adapter
  同样没有 L0 写基准可比。
- **对齐方式**：
  1. 契约套件以 **L0 语义**为唯一通过标准——drift 与 REST 双实现都必须跑绿
     C1–C11（R1 已把 C11 加入，覆盖跨 scope 写）；
  2. record 独有能力（encode/outbox/搜索标签）在套件外补 **port 级测试**
     （如既有 `test/record/` 的 codec 测试、migration 测试），双实现各自
     为自己的独有能力兜底；
  3. M2 阶段如需「双实现跑同一套件」覆盖写路径，必须先完成 §2 的
     适配 codec（债务），否则 drift 的写仍是黑盒。
- **风险提示**：R1 修复前，跨 scope 写被翻译成 `conflict.version`（可重试），
  调用方会「重读合并重试」；R1 后为 `permission_denied`（不可重试），
  REST adapter 在实现写路径时必须遵循该语义，不得对越权做重试。

---

## 4. 对 M4（适配层退场）的影响

M4 目标：`BaseRecordBackedRepository` 整体退场，调用方直接使用 L0 切片。
四条路径退场需要以下前置能力：

| 路径 | 退场所需前置能力 | M4 前必须补 / 可长期保留 |
|---|---|---|
| `save` | ① 适配 codec：`RecordModuleCodec<TContract>` → L0 `EntityCodec`（encode 产出含 meta 与 moduleData 的行形态）；② outbox 语义在 L0 的等价物（或确认可剥离）；③ 搜索索引写入由 L0 写路径承接 | **必须补**（缺适配 codec，L0 `put` 无法落 record 行） |
| `getByUuid` | L0 `get` 支持**含软删读**（`includeSoftDeleted` 在 get 路径生效，或新增显式 API），且返回形态能携带 `deletedAt` | **必须补**（软删读是既有公开语义，不能静默丢失） |
| `watchAll` | L0 `watch` 支持 category 过滤（或等价 SQL 下推），且 driver 侧对齐「订阅即发初始快照」时序 | **必须补**（watch 是既有消费方依赖的实时语义） |
| 索引查询 | L0 新增**索引 API**（按标签列查询/订阅），承接 `findByIndex` / `watchByIndex` | **必须补**（标签索引是 record 的查询主力，equals 全量过滤不可替代） |

**可长期保留项**：暂无——四条路径均为既有公开 API 的等价能力，M4 前都应补齐，
否则调用方在适配层退场后功能缺失。若某模块确认不使用某路径（如无索引查询消费方），
可在 M4 排期时单独评估剥离，但**默认按必须补处理**。

---

## 5. 验收依据（R1 关联）

- 内核侧：`StorageScopeViolation` 单测 + 契约套件 C11 全绿（内存参考实现）。
- xuan-storage 侧：`flutter test test/record/` 全绿（≥110），
  record 实现契约套件 C1–C11 全绿。
- 八模块 `record_backed_*` 文件 diff 为空。
