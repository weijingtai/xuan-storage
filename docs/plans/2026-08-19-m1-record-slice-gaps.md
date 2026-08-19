# M1 record 切片化缺口还清记录（R3）

> 日期：2026-08-19
> 分支：`wip/m1-record-slice-migration`
> 目的：记录 M1 试点中「四条未走 L0 路径」的技术债务还清方案与落地状态，为 M2（双实现跑同一套件）提供统一基线。

## 背景与决议

M1 试点初期将 `BaseRecordBackedRepository` 降级为适配层时，遗留了四条保留 `ScopedRecordStore` 端口直连的路径（`save`、`getByUuid`、`watchAll`、索引查询）。
经用户裁决：**M2 开工前写路径与读路径的技术债全部还清**。
现已全部改造完毕，`BaseRecordBackedRepository` 的 9 个方法【全部】委托 L0 契约内核。

---

## 1. 四条路径还清现状

### 1.1 `save`（已还清）

| 项 | 说明 |
|---|---|
| 当前实现 | `_codec.encode(fixed, scopeUid: _store.scopeUid)` 产出 `EncodedRecord`，经 `RecordRowMapper.metaToRow` 摊平成扁平行，调用 `_l0.put(row, _ctx)`。`RecordStorageDriver.write` 内部通过 `RecordRowMapper.rowToMeta` 与 `moduleDataOf` 还原两段结构并调用 `_store.saveRecord` |
| 债务偿还方式 | encode 留在适配层；`RecordRowMapper` 负责扁平行与 `RecordMeta + moduleData` 的无损互转；`driver.write` 调用既有 `_store.saveRecord`，完整保留 outbox 待同步队列与搜索标签索引副作用 |
| 验收保证 | save 方法签名不变，八模块零改动；单测验证含 `moduleData` 记录写后读出逐字段比对完全一致 |

### 1.2 `getByUuid`（已还清）

| 项 | 说明 |
|---|---|
| 当前实现 | `_l0.getIncludingDeleted(uuid, _ctx)`，成功返回后经 `_decodeRow` 解码为实体 |
| 债务偿还方式 | L0 契约内核新增正交切片 `SoftDeleteReadable<T, ID>`，`CrudBaseRepository` 实现该接口并通过 `RawFilter(scopeUid: ctx.scopeUid, includeSoftDeleted: true)` 委托 driver 读出含软删记录 |
| 验收保证 | 契约套件 C12 全绿，软删记录读写与还原行为严格符合契约规范 |

### 1.3 `watchAll`（已还清）

| 项 | 说明 |
|---|---|
| 当前实现 | `_l0.watch({'category': _codec.category}, _ctx)`，经 map 解码为 `TContract` 列表 |
| 债务偿还方式 | `RecordStorageDriver.watchMany` 把 `RawFilter.equals['category']` 下推到 `_store.watchRecords(category: ...)` SQL 参数，不在内存全量过滤；同时对齐首帧快照推送时序 |
| 验收保证 | 契约套件 C14 全绿，八模块及 e2e watch 测试全部通过 |

### 1.4 索引查询（三个方法，已还清）

| 项 | 说明 |
|---|---|
| 当前实现 | `getFirstByIndex` / `getAllByIndex` / `watchFirstByIndex` 全部改走 `_l0.getByIndex` / `_l0.watchByIndex` |
| 债务偿还方式 | L0 契约内核新增正交切片 `IndexQueryable<T>`，`ReadOnlyBaseRepository` 实现该接口（未声明索引返回 `invalid_argument`，已声明下推 driver 查询/订阅）；`recordEntityDescriptor` 声明各模块常用索引字段 |
| 验收保证 | 契约套件 C13 全绿，模块标签索引查询与订阅单测全部通过 |

---

## 2. 根因修正与技术总结

- **watchAll 根因修正**：此前将 `watchAll` 判定为「L0 缺能力」是不准确的。L0 `watch` 原本就支持 `spec` 过滤规约，根本原因在于 `RecordStorageDriver` 未把 `equals['category']` 参数下推给底层 store 的 SQL 过滤，而在内存过滤。修正 driver 下推后，既有 L0 `watch` 即可等价满足需求。
- **泛型与行形态**：`BaseRecordBackedRepository` 作为适配层，保留对上层 `TContract` 的泛型支持，通过 `RecordRowMapper` 弥合 L0 扁平行与领域两段结构，既保证了 L0 契约内核的高内聚与正交性，又保证了八模块零改动平滑演进。

---

## 3. 对 M2 与 M4 的后续演进支持

- **M2（双实现跑同一套件）**：
  - L0 契约套件现已扩充为 C1–C14（补齐 C12 软删读、C13 索引查询、C14 订阅首帧快照）。
  - drift 与 REST 双实现均以 C1–C14 为统一验收标准。
- **M4（适配层退场）**：
  - 由于所有方法均已委托 L0 切片，M4 阶段调用方可直接依赖 L0 切片接口（`CrudRepository`, `SoftDeleteReadable`, `IndexQueryable`），适配层可安全平滑退场。

---

## 4. 验收依据

- 内核仓：`dart analyze` 零 issue；`dart test` 全部通过（77/77）。
- 业务仓：`flutter analyze` 零 issue；`flutter test test/record/` 全部通过（116/116）。
- 八模块 `record_backed_*` 文件 diff 为空。
- AIGC 水印防复发测试通过。
