# ACT 可执行实现计划 — Record 云同步 (Outbox 接入 + Pull + Remote)

> **日期**: 2026-06-29
> **来源 spec**: `docs/superpowers/specs/2026-06-29-record-cloud-sync-design.md` (C0–C7)
> **目标**: 将统一记录系统的本地保存接入 Outbox→Push 管道，实现 Pull→LocalApply 闭环
> **前置条件**: Seeker 解耦 (S0–S7) + Fork/Merge 推断 (F0–F8) 已完成并合入
> **实现顺序依赖**: Seeker 解耦 → Fork/Merge 推断 → 云同步（后者依赖前者已合入）

---

## 总览

| 任务 | 目标 | TDD 类型 | 涉及文件数 | 预估改动行数 |
|------|------|----------|-----------|-------------|
| C0 | **【最前置】** 核验 record 是否真入 outbox：写测试证明当前 save 不走 outbox | 验证（只读） | 1 | ~50 |
| C1 | 定义 entity_type='record_meta' 约定 + RecordMeta → OutboxRecord mapper | TDD Red→Green | 2 | ~80 |
| C2 | 将 OutboxStore 注入 DriftRecordDataSource.saveRecord() 管道 | TDD Red→Green | 3 | ~80 |
| C3 | 实现 RecordLocalApplier：pull 侧将远程变更写入本地 t_record_meta | TDD Red→Green | 2 | ~130 |
| C4 | 注册 'record_meta' entity type 到 SyncStateStore + 配置 pull cursor | TDD Red→Green | 2 | ~50 |
| C5 | 补全 RemoteGateway 对 record_meta 的 push/listChanges 实现 | TDD Red→Green | 1 | ~100 |
| C6 | 软删除同步：softDeleteRecord 同时 enqueue tombstone OutboxRecord | TDD Red→Green | 2 | ~60 |
| C7 | 端到端集成测试：save → outbox → push → pull → local apply → verify | 验证 | 1 | ~120 |

---

## C0: 【最前置】核验 record 是否真入 outbox

```yaml
TASK_ID: "record-cloud-sync-c0-verify-outbox-gap"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    当前架构：
    - Outbox 基础设施完整：t_outbox 表、OutboxRecordsDao、DriftOutboxStore、
      OutboxPusher、SyncCoordinator、SyncRuntime 全部就位。
    - 记录保存管道：BaseRecordBackedRepository.save() → LocalRecordRepository.saveRecord()
      → DriftRecordDataSource.saveRecord() → 写 t_record_meta + t_record_search_index。
    - 两个系统互相不知道对方存在。DriftRecordDataSource.saveRecord() 从不调用 OutboxStore.enqueue()。

    本任务是整个云同步的前置门禁——先写测试证明"record 保存后 outbox 为空"，
    后续 C2 再修复这个 gap。

  STRATEGY: |
    写一个明确的 RED 测试：保存一条 record → 查询 t_outbox → 断言 outbox 为空。
    这个测试在 C0 阶段通过（证明 gap 存在），在 C2 完成后变为 FAIL（需要更新断言）。

TASK_DEPS: []

COMMANDS:
  PRECHECK: |
    echo "=== C0: 核验 record 是否入 outbox ==="
    echo "确认 OutboxRecordsDao 存在："
    grep -n "class OutboxRecordsDao" xuan-storage/drift/lib/persistence_drift.dart
    echo ""
    echo "确认 DriftRecordDataSource.saveRecord 不调用 outbox："
    grep -n "outbox\|Outbox" xuan-storage/drift/lib/record/drift_record_data_source.dart || echo "（无 outbox 引用 — 确认 gap）"
    echo ""
    echo "确认 LocalRecordRepository.saveRecord 不调用 outbox："
    grep -n "outbox\|Outbox" xuan-storage/drift/lib/record/local_record_repository.dart || echo "（无 outbox 引用 — 确认 gap）"

  # ── RED（本阶段预期通过 — 证明 gap 存在）──
  STEP_0: |
    创建 drift/test/sync/record_outbox_gap_test.dart：
    使用内存 Drift 数据库，创建一条记录，查询 t_outbox，断言为空。

  STEP_0_CONTENT: |
    import 'package:flutter_test/flutter_test.dart';
    import 'package:drift/native.dart';
    import 'package:repository_interface_record/repository_interface_record.dart';
    import 'package:persistence_drift/persistence_drift.dart';

    void main() {
      late PersistenceDriftDatabase db;
      late DriftRecordDataSource ds;
      late OutboxRecordsDao outboxDao;

      setUp(() {
        db = PersistenceDriftDatabase(NativeDatabase.memory());
        ds = DriftRecordDataSource(db, scopeUid: 'test-scope-c0');
        outboxDao = OutboxRecordsDao(db);
      });

      tearDown(() async => await db.close());

      test('C0: record save does NOT enqueue outbox — proving the gap', () async {
        final meta = RecordMeta(
          uuid: 'c0-test-uuid', scopeUid: 'test-scope-c0',
          module: 'meihua', category: 'divination',
          divinationType: 'mei_hua', createdAt: DateTime.now(), rev: 1,
        );
        await ds.saveRecord(meta, []);

        // 查询 t_outbox：预期为空（gap 存在）
        final outboxRows = await outboxDao.peekBatch(
          scopeUid: 'test-scope-c0', limit: 100,
        );
        expect(outboxRows, isEmpty,
          reason: 'C0 gap: record saved but outbox is empty. '
                  'This proves the save pipeline does not enqueue outbox records. '
                  'C2 will fix this.');
      });
    }

  STEP_0_CMD: "cd xuan-storage/drift && flutter test test/sync/record_outbox_gap_test.dart 2>&1"
  STEP_0_EXPECT: "测试通过（outbox 为空 — 确认 gap 存在）"

ASSERTIONS:
  EXECENV: "flutter test 通过，证明 record save 不走 outbox"
  CASES:
    - "t_record_meta 有 1 条记录"
    - "t_outbox 有 0 条记录"
    - "gap 确认后可进入 C2 修复"

PROTOCOL:
  MODE: "write-test-only"
  NO_PROSE: true
  OUTPUT_FORMAT: "测试文件，通过即证明 gap"

VERIFICATION: "cd xuan-storage/drift && flutter test test/sync/record_outbox_gap_test.dart"
```

---

## C1: 定义 entity_type 约定 + RecordMeta → OutboxRecord mapper

```yaml
TASK_ID: "record-cloud-sync-c1-entity-mapper"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    需要定义：
    - entity_type 常量：'record_meta'（用于 outbox + sync_state 统一标识）
    - op_type 常量：'UPSERT'（新建/更新）、'DELETE'（软删除）
    - RecordMeta → OutboxRecord 的映射逻辑：
      - operationId = uuid.v7()
      - entityType = 'record_meta'
      - entityId = record.uuid
      - opType = 'UPSERT' 或 'DELETE'
      - payloadJson = JSON 编码 {meta: RecordMeta.toJson(), moduleData, searchTags}
      - scopeUid = record.scopeUid

  STRATEGY: |
    创建 RecordOutboxMapper 工具类。先写测试验证映射逻辑。

TASK_DEPS: ["record-cloud-sync-c0-verify-outbox-gap"]

COMMANDS:
  PRECHECK: |
    cd xuan-storage/drift && flutter test test/sync/record_outbox_gap_test.dart 2>&1 | tail -3

  # ── RED ──
  STEP_0_RED: |
    创建 drift/test/sync/record_outbox_mapper_test.dart：
    - test('maps RecordMeta to OutboxRecord with entity_type record_meta')
    - test('opType is UPSERT for new record')
    - test('opType is DELETE for soft-deleted record')
    - test('payloadJson contains meta and moduleData')
    - test('scopeUid matches record.scopeUid')

  # ── GREEN ──
  STEP_1_GREEN: |
    创建 drift/lib/sync/record_outbox_mapper.dart：
    - static const entityType = 'record_meta'
    - static const opUpsert = 'UPSERT'
    - static const opDelete = 'DELETE'
    - static OutboxRecord toOutboxRecord(RecordMeta meta, Map<String, dynamic>? moduleData, List<SearchTag> tags, String opType)

  STEP_1_GREEN_CONTENT: |
    import 'dart:convert';
    import 'package:uuid/uuid.dart';
    import 'package:repository_interface_record/repository_interface_record.dart';
    import 'package:core/core.dart'; // for OutboxRecord

    class RecordOutboxMapper {
      static const entityType = 'record_meta';
      static const opUpsert = 'UPSERT';
      static const opDelete = 'DELETE';

      static OutboxRecord toOutboxRecord({
        required RecordMeta meta,
        Map<String, dynamic>? moduleData,
        List<SearchTag> tags = const [],
        required String opType,
        Uuid? uuid,
      }) {
        final effectiveUuid = uuid ?? const Uuid();
        final payload = <String, dynamic>{
          'meta': _metaToJson(meta),
          if (moduleData != null) 'moduleData': moduleData,
          'searchTags': tags.map((t) => {'key': t.key, 'value': t.value}).toList(),
        };
        return OutboxRecord(
          operationId: effectiveUuid.v7(),
          scopeUid: meta.scopeUid,
          entityType: entityType,
          entityId: meta.uuid,
          opType: opType,
          payloadJson: jsonEncode(payload),
          createdAtUtc: DateTime.now().toUtc(),
          attempt: 0,
        );
      }

      static Map<String, dynamic> _metaToJson(RecordMeta meta) => {
        'uuid': meta.uuid, 'scopeUid': meta.scopeUid, 'module': meta.module,
        'category': meta.category, 'divinationType': meta.divinationType,
        'caseUuid': meta.caseUuid, 'workItemUuid': meta.workItemUuid,
        'seekerUuid': meta.seekerUuid, 'question': meta.question,
        'detail': meta.detail, 'tag': meta.tag, 'directPredict': meta.directPredict,
        'verificationStatus': meta.verificationStatus, 'seekerName': meta.seekerName,
        'gender': meta.gender, 'fateYear': meta.fateYear,
        'moduleDataJson': meta.moduleDataJson, 'navParamsJson': meta.navParamsJson,
        'createdAt': meta.createdAt.toUtc().toIso8601String(),
        'updatedAt': meta.updatedAt?.toUtc().toIso8601String(),
        'deletedAt': meta.deletedAt?.toUtc().toIso8601String(),
        'rev': meta.rev,
      };
    }

  STEP_2_GREEN_CMD: "cd xuan-storage/drift && flutter test test/sync/record_outbox_mapper_test.dart 2>&1"
  STEP_2_GREEN_EXPECT: "All tests passed! (5 tests)"

PROHIBITED:
  - 在 mapper 中执行任何 I/O（只做数据转换）
  - 硬编码 scopeUid

ASSERTIONS:
  CASES:
    - "entityType 恒为 'record_meta'"
    - "scopeUid 从 RecordMeta.scopeUid 透传"
    - "payloadJson 可逆解析回原始 meta + moduleData + searchTags"

VERIFICATION: "cd xuan-storage/drift && flutter test test/sync/record_outbox_mapper_test.dart"
```

---

## C2: OutboxStore 注入 saveRecord 管道

```yaml
TASK_ID: "record-cloud-sync-c2-inject-outbox"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    核心改动：在 DriftRecordDataSource.saveRecord() 或 LocalRecordRepository.saveRecord()
    中，本地写入成功后同步 enqueue 一条 OutboxRecord。

    设计选择：
    - 注入点放在 LocalRecordRepository（而非 DriftRecordDataSource），因为
      LocalRecordRepository 已有 RecordAdapterRegistry（可获取 searchTags），
      且它是 ScopedRecordStore 的唯一实现。
    - 或者直接在 DriftRecordDataSource 的事务中同时写 t_outbox。

    推荐方案：LocalRecordRepository 接受可选的 OutboxStore 参数，
    在 saveRecord() 中调用 outboxStore.enqueue()。
    软删除同理（C6）。

  STRATEGY: |
    修改 LocalRecordRepository 构造函数，接受可选 OutboxStore。
    在 saveRecord() 末尾 enqueue outbox 记录。
    更新 C0 测试断言（现在 outbox 应有记录）。

TASK_DEPS: ["record-cloud-sync-c1-entity-mapper"]

COMMANDS:
  PRECHECK: |
    cd xuan-storage/drift && flutter test test/sync/ 2>&1 | tail -5

  # ── RED ──
  STEP_0_RED: |
    创建 drift/test/sync/record_save_outbox_test.dart：
    - test('saveRecord enqueues OutboxRecord with entity_type record_meta')
    - test('outbox record payload contains original meta fields')
    - test('outbox record has status pending')
    - test('save without outbox store still works (backward compat)')

    运行测试，预期 FAIL。

  # ── GREEN ──
  STEP_1_GREEN: |
    修改 drift/lib/record/local_record_repository.dart：
    - 添加 import 'package:core/core.dart'; // OutboxStore, OutboxRecord
    - 添加 import '../sync/record_outbox_mapper.dart';
    - 构造函数新增可选参数 OutboxStore? outboxStore
    - saveRecord() 方法末尾：if outboxStore != null → enqueue
    - 注意：enqueue 应在 try-catch 中，失败不应阻断本地保存

  STEP_1_GREEN_CONTENT: |
    class LocalRecordRepository implements ScopedRecordStore {
      final DriftRecordDataSource _ds;
      final RecordAdapterRegistry _registry;
      final OutboxStore? _outboxStore;

      LocalRecordRepository(this._ds, this._registry, {OutboxStore? outboxStore})
          : _outboxStore = outboxStore;

      @override
      Future<void> saveRecord(RecordMeta record, {Map<String, dynamic>? moduleData}) async {
        final tags = _registry.forModule(record.module)?.extractSearchTags(record, moduleData) ?? const <SearchTag>[];
        await _ds.saveRecord(record, tags);

        // 异步 enqueue outbox（不阻塞本地保存完成）
        if (_outboxStore != null) {
          try {
            final outboxRecord = RecordOutboxMapper.toOutboxRecord(
              meta: record, moduleData: moduleData, tags: tags, opType: RecordOutboxMapper.opUpsert,
            );
            await _outboxStore!.enqueue(outboxRecord);
          } catch (e) {
            // outbox enqueue 失败不阻断本地保存
            // 可通过日志/埋点上报（后续版本）
          }
        }
      }
      // ... 其余方法不变
    }

  STEP_2_GREEN: |
    更新 C0 测试（record_outbox_gap_test.dart）：
    现在应使用带 OutboxStore 的 LocalRecordRepository，断言 outbox 不为空。

  STEP_3_GREEN: |
    运行所有 sync 测试。

  STEP_3_GREEN_CMD: "cd xuan-storage/drift && flutter test test/sync/ 2>&1"
  STEP_3_GREEN_EXPECT: "All tests passed!"

PROHIBITED:
  - 在 DriftRecordDataSource 中引入 OutboxStore 依赖（保持数据层纯净）
  - outbox enqueue 失败阻断本地保存
  - 修改 DriftRecordDataSource 的接口

ASSERTIONS:
  CASES:
    - "saveRecord 后 t_outbox 有 1 条 entity_type='record_meta' 的记录"
    - "outbox 记录的 scopeUid 与 record 一致"
    - "outboxStore 为 null 时行为与旧版一致（向后兼容）"
    - "outbox enqueue 异常不抛到调用方"

PROTOCOL:
  MODE: "write-files-only"
  NO_PROSE: true

VERIFICATION: "cd xuan-storage/drift && flutter test test/sync/"
```

---

## C3: 实现 RecordLocalApplier（Pull 侧写入）

```yaml
TASK_ID: "record-cloud-sync-c3-local-applier"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    云同步 Pull 流程：RemoteGateway.listChanges() → LocalApplier.applyRemoteChanges() → 写本地 DB。
    当前缺少针对 record_meta entity type 的 LocalApplier 实现。

    需要实现：
    - 解析 OutboxRecord 的 payloadJson → 提取 RecordMeta + moduleData + searchTags
    - 写入 t_record_meta（insertOnConflictUpdate，以 uuid 为主键）
    - 写入 t_record_search_index（先删后插）
    - 不回触发 outbox 再 enqueue（反循环）

    反循环机制：
    - applyRemoteChanges 直接调用 DriftRecordDataSource.saveRecord() 的内部逻辑，
      但跳过 LocalRecordRepository 的 outbox enqueue 步骤。
    - 或者新增 DriftRecordDataSource.applyRemoteRecord() 方法，只写本地不触发 outbox。

  STRATEGY: |
    在 DriftRecordDataSource 中新增 applyRemoteRecord() 方法。
    创建 RecordLocalApplier 实现 LocalApplier 接口。

TASK_DEPS: ["record-cloud-sync-c2-inject-outbox"]

COMMANDS:
  PRECHECK: |
    cd xuan-storage/drift && flutter test test/sync/ 2>&1 | tail -3

  # ── RED ──
  STEP_0_RED: |
    创建 drift/test/sync/record_local_applier_test.dart：
    - test('applyRemoteRecord writes to t_record_meta without outbox enqueue')
    - test('applyRemoteRecord overwrites existing record with same uuid')
    - test('applyRemoteRecord writes search tags to t_record_search_index')
    - test('applyRemoteRecord respects scopeUid isolation')
    - test('applyRemoteRecord payload without moduleData still works')

  # ── GREEN ──
  STEP_1_GREEN: |
    在 DriftRecordDataSource 中新增方法：
    - Future<void> applyRemoteRecord(RecordMeta record, List<SearchTag> tags)
    与 saveRecord() 逻辑相同，但仅供 LocalApplier 调用（不经过 LocalRecordRepository）。

  STEP_1_GREEN_CONTENT: |
    /// 供 RecordLocalApplier 使用：直接写入本地，不触发 outbox。
    Future<void> applyRemoteRecord(RecordMeta record, List<SearchTag> tags) {
      return db.transaction(() async {
        await db.into(db.tRecordMeta).insertOnConflictUpdate(_companion(record));
        await (db.delete(db.tRecordSearchIndex)
              ..where((t) => t.recordUuid.equals(record.uuid) & t.scopeUid.equals(scopeUid)))
            .go();
        for (final t in tags) {
          await db.into(db.tRecordSearchIndex).insert(TRecordSearchIndexCompanion(
                recordUuid: Value(record.uuid), scopeUid: Value(scopeUid),
                module: Value(record.module), indexKey: Value(t.key),
                indexValue: Value(t.value),
              ));
        }
      });
    }

  STEP_2_GREEN: |
    创建 drift/lib/sync/record_local_applier.dart：
    - 实现 LocalApplier 接口（来自 core）
    - applyRemoteChanges(List<OutboxRecord>) → 解析 payloadJson → 调用 ds.applyRemoteRecord()
    - 处理 DELETE opType：调用 ds.softDeleteRecord()

  STEP_2_GREEN_CONTENT: |
    import 'dart:convert';
    import 'package:repository_interface_record/repository_interface_record.dart';
    import 'package:core/core.dart'; // LocalApplier, OutboxRecord
    import '../record/drift_record_data_source.dart';
    import 'record_outbox_mapper.dart';

    class RecordLocalApplier implements LocalApplier {
      final DriftRecordDataSource _ds;

      RecordLocalApplier(this._ds);

      @override
      bool canApply(String entityType) => entityType == RecordOutboxMapper.entityType;

      @override
      Future<void> applyRemoteChanges(List<OutboxRecord> records) async {
        for (final r in records) {
          if (r.entityType != RecordOutboxMapper.entityType) continue;
          final payload = jsonDecode(r.payloadJson) as Map<String, dynamic>;
          final meta = _parseMeta(payload['meta'] as Map<String, dynamic>);
          final tags = _parseTags(payload['searchTags'] as List<dynamic>?);

          if (r.opType == RecordOutboxMapper.opDelete) {
            await _ds.softDeleteRecord(meta.uuid);
          } else {
            await _ds.applyRemoteRecord(meta, tags);
          }
        }
      }

      RecordMeta _parseMeta(Map<String, dynamic> json) { /* ... */ }
      List<SearchTag> _parseTags(List<dynamic>? list) { /* ... */ }
    }

  STEP_3_GREEN_CMD: "cd xuan-storage/drift && flutter test test/sync/record_local_applier_test.dart 2>&1"
  STEP_3_GREEN_EXPECT: "All tests passed! (5 tests)"

PROHIBITED:
  - applyRemoteChanges 中调用 LocalRecordRepository.saveRecord()（会触发 outbox 循环）
  - 跳过 scopeUid 校验

ASSERTIONS:
  CASES:
    - "远程写入后 t_outbox 无新增记录（无反循环）"
    - "远程写入的 scopeUid 使用 dataSource 的 scopeUid（不信任远程值）"
    - "远程 DELETE 记录在本地查询中不可见"

VERIFICATION: "cd xuan-storage/drift && flutter test test/sync/record_local_applier_test.dart"
```

---

## C4: 注册 entity type 到 SyncStateStore

```yaml
TASK_ID: "record-cloud-sync-c4-sync-state"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    SyncStateStore 用于追踪每种 entity type 的 pull cursor（时间戳/revision）。
    需要为 'record_meta' 注册 cursor 类型和初始值。

    t_sync_state 表的主键是 (scope_uid, entity_type)。
    需要：
    - 定义 cursor_type = 'timestamp'（按 updated_at 增量同步）
    - 初始化 cursor（如果不存在）
    - 提供查询/更新 cursor 的便捷方法

  STRATEGY: |
    在 RecordOutboxMapper 或新建的 RecordSyncConfig 中添加 entity type 注册逻辑。
    确保 SyncCoordinator.pullOnce() 能正确获取 record_meta 的 cursor。

TASK_DEPS: ["record-cloud-sync-c3-local-applier"]

COMMANDS:
  PRECHECK: |
    cd xuan-storage/drift && flutter test test/sync/ 2>&1 | tail -3

  # ── RED ──
  STEP_0_RED: |
    在 drift/test/sync/ 中添加 record_sync_state_test.dart：
    - test('sync state initializes for record_meta entity type')
    - test('getCursor returns null for uninitialized record_meta')
    - test('setCursorIfNewer advances the cursor')
    - test('cursor is scoped by scopeUid')

  # ── GREEN ──
  STEP_1_GREEN: |
    创建 drift/lib/sync/record_sync_config.dart：
    - static const entityType = 'record_meta'
    - static const cursorType = 'timestamp'
    - static Future<void> ensureInitialized(SyncStateStore store, String scopeUid)

  STEP_2_GREEN_CMD: "cd xuan-storage/drift && flutter test test/sync/record_sync_state_test.dart 2>&1"
  STEP_2_GREEN_EXPECT: "All tests passed! (4 tests)"

ASSERTIONS:
  CASES:
    - "record_meta 的 cursor 与其他 entity type 隔离"
    - "cursor 更新后 getCursor 返回新值"

VERIFICATION: "cd xuan-storage/drift && flutter test test/sync/record_sync_state_test.dart"
```

---

## C5: 补全 RemoteGateway 对 record_meta 的实现

```yaml
TASK_ID: "record-cloud-sync-c5-remote-gateway"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    当前 RemoteGateway 接口定义在 core/lib/model/ports.dart：
    - push(OutboxRecord) → 推送单条记录到远程
    - listChanges(sinceCursor) → 拉取远程变更列表

    Firebase 实现（firebase/lib/firebase_realtime_remote_gateway.dart）已有 push，
    但需要确认是否支持 record_meta entity type 的 push/listChanges。

    本任务负责：
    - 确保 push 方法能处理 entity_type='record_meta' 的 OutboxRecord
    - 实现 listChanges 按 entity_type='record_meta' 过滤
    - 如使用 Firebase Realtime Database，路径约定：/records/{scopeUid}/{uuid}

  STRATEGY: |
    如果 Firebase 实现已足够通用，则只需验证并添加测试。
    如果缺失，补充实现。

TASK_DEPS: ["record-cloud-sync-c4-sync-state"]

COMMANDS:
  PRECHECK: |
    echo "=== C5: RemoteGateway 现状 ==="
    echo "core RemoteGateway 接口："
    grep -A 10 "abstract.*class RemoteGateway\|abstract.*RemoteGateway" xuan-storage/core/lib/model/ports.dart 2>/dev/null || echo "未找到"
    echo ""
    echo "Firebase 实现："
    ls -la xuan-storage/firebase/lib/ 2>/dev/null || echo "firebase 目录不存在"
    echo ""
    echo "Supabase 实现："
    ls -la xuan-storage/supabase/lib/ 2>/dev/null || echo "supabase 目录不存在"

  # ── RED ──
  STEP_0_RED: |
    创建 drift/test/sync/record_remote_gateway_test.dart：
    使用 fake/mock RemoteGateway：
    - test('push record_meta outbox record succeeds')
    - test('listChanges returns records since cursor')
    - test('listChanges empty when no new records')
    - test('push failure triggers retry in OutboxPusher')

  # ── GREEN ──
  STEP_1_GREEN: |
    在 firebase/lib/ 中补充 record_meta 的 push/listChanges 实现。
    或创建 drift/lib/sync/record_remote_gateway_adapter.dart（适配层）。

    具体实现取决于实际使用的远程后端（Firebase/Supabase/自定义）。
    本计划假定 Firebase，路径：/records/{scopeUid}/{uuid}.json

  STEP_2_GREEN_CMD: "cd xuan-storage/drift && flutter test test/sync/record_remote_gateway_test.dart 2>&1"
  STEP_2_GREEN_EXPECT: "All tests passed! (4 tests)"

ASSERTIONS:
  CASES:
    - "push 成功后 outbox 记录状态变为 success"
    - "listChanges 返回的记录可按 entity_type 过滤"
    - "网络错误时 outbox 记录状态变为 failed（不丢数据）"

VERIFICATION: "cd xuan-storage/drift && flutter test test/sync/record_remote_gateway_test.dart"
```

---

## C6: 软删除同步

```yaml
TASK_ID: "record-cloud-sync-c6-soft-delete-sync"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    当前 softDeleteRecord() 只写本地 t_record_meta.deletedAt，不 enqueue outbox。
    需要确保软删除操作也同步到远程。

    修改方案：
    - LocalRecordRepository.softDeleteRecord() 中，删除成功后 enqueue
      op_type='DELETE' 的 OutboxRecord。
    - RecordLocalApplier 已支持处理 DELETE opType（C3 实现）。

  STRATEGY: |
    修改 LocalRecordRepository.softDeleteRecord()，添加 outbox enqueue。
    写测试验证。

TASK_DEPS: ["record-cloud-sync-c2-inject-outbox"]

COMMANDS:
  PRECHECK: |
    cd xuan-storage/drift && flutter test test/sync/ 2>&1 | tail -3

  # ── RED ──
  STEP_0_RED: |
    在 drift/test/sync/record_save_outbox_test.dart 中添加：
    - test('softDelete enqueues DELETE OutboxRecord')
    - test('DELETE outbox record has opType DELETE')
    - test('softDelete without outbox store still works')

  # ── GREEN ──
  STEP_1_GREEN: |
    修改 LocalRecordRepository.softDeleteRecord()：
    在 _ds.softDeleteRecord(uuid) 成功后 enqueue DELETE outbox。

  STEP_1_GREEN_CONTENT: |
    @override
    Future<bool> softDeleteRecord(String uuid, {required String module}) async {
      final deleted = await _ds.softDeleteRecord(uuid);
      if (deleted && _outboxStore != null) {
        try {
          // 先获取被删记录的 meta（用于构造 outbox payload）
          final meta = await _ds.getRecord(uuid);
          if (meta != null) {
            final outboxRecord = RecordOutboxMapper.toOutboxRecord(
              meta: meta, opType: RecordOutboxMapper.opDelete,
            );
            await _outboxStore!.enqueue(outboxRecord);
          }
        } catch (_) { /* outbox enqueue 失败不阻断本地删除 */ }
      }
      return deleted;
    }

  STEP_2_GREEN_CMD: "cd xuan-storage/drift && flutter test test/sync/record_save_outbox_test.dart 2>&1"
  STEP_2_GREEN_EXPECT: "All tests passed!"

ASSERTIONS:
  CASES:
    - "softDelete 后 t_outbox 有 1 条 op_type='DELETE' 的记录"
    - "DELETE outbox 的 entityId 等于被删记录的 uuid"
    - "outbox enqueue 失败不阻断本地软删除"

VERIFICATION: "cd xuan-storage/drift && flutter test test/sync/"
```

---

## C7: 端到端集成测试

```yaml
TASK_ID: "record-cloud-sync-c7-e2e"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    完整的云同步闭环测试：
    1. 本地创建记录 → outbox enqueue
    2. OutboxPusher.pushOnce() → RemoteGateway.push() → 远程存储
    3. SyncCoordinator.pullOnce() → RemoteGateway.listChanges() → RecordLocalApplier → 本地写入
    4. 验证：另一设备（模拟）可看到同步的记录

    使用内存 fake 实现 RemoteGateway（两个 fake 实例模拟双端）。

  STRATEGY: |
    创建集成测试，使用 InMemoryOutboxStore + FakeRemoteGateway + 内存 Drift DB。
    模拟完整 push→pull 闭环。

TASK_DEPS:
  - "record-cloud-sync-c2-inject-outbox"
  - "record-cloud-sync-c3-local-applier"
  - "record-cloud-sync-c5-remote-gateway"
  - "record-cloud-sync-c6-soft-delete-sync"

COMMANDS:
  PRECHECK: |
    cd xuan-storage/drift && flutter test test/sync/ 2>&1 | tail -5

  # ── RED ──
  STEP_0_RED: |
    创建 drift/test/sync/record_sync_e2e_test.dart：
    - test('full sync cycle: save → outbox → push → pull → verify on peer')
    - test('soft-delete syncs to peer')
    - test('scope isolation: records from different scopes do not leak')
    - test('concurrent saves from two peers converge')

  # ── GREEN ──
  STEP_1_GREEN: |
    实现集成测试。
    使用两个独立的内存 Drift 数据库 + FakeRemoteGateway 共享存储。
    模拟 device A 创建记录 → push → device B pull → 验证。

  STEP_1_GREEN_CMD: "cd xuan-storage/drift && flutter test test/sync/record_sync_e2e_test.dart 2>&1"
  STEP_1_GREEN_EXPECT: "All tests passed! (4 tests)"

ASSERTIONS:
  CASES:
    - "device A 创建记录后，device B pull 可获取"
    - "device A 软删除后，device B pull 后记录标记为已删除"
    - "不同 scope 的记录在 pull 时被 scopeUid 过滤"
    - "并发写入不丢失数据（last-write-wins 或 CRDT）"

PROTOCOL:
  MODE: "write-test-only"
  NO_PROSE: true

VERIFICATION: "cd xuan-storage/drift && flutter test test/sync/record_sync_e2e_test.dart"
```

---

## 实现顺序依赖声明

```
C0 (核验 gap — 最前置)
 └─ C1 (entity mapper)
     └─ C2 (outbox 注入 saveRecord)
         ├─ C3 (LocalApplier pull 写入)
         │   └─ C4 (SyncState 注册)
         │       └─ C5 (RemoteGateway 实现)
         ├─ C6 (软删除同步，可与 C3–C5 并行)
         └─ C7 (E2E 集成，依赖 C2+C3+C5+C6)

前置：全部 S0–S7 (Seeker 解耦) + F0–F8 (Fork/Merge 推断) 已完成并合入。
```

---

## Git 提交粒度

| 提交 | 内容 | 关联任务 |
|------|------|----------|
| `git commit -m "test: C0 prove record save does NOT enqueue outbox"` | gap 验证测试 | C0 |
| `git commit -m "test: C1 RED record outbox mapper tests"` | 失败测试 | C1-RED |
| `git commit -m "feat: C1 GREEN record outbox mapper"` | mapper 实现 | C1-GREEN |
| `git commit -m "feat: C2 inject outbox store into LocalRecordRepository"` | outbox 注入 | C2 |
| `git commit -m "feat: C3 record local applier for pull"` | pull 写入 | C3 |
| `git commit -m "feat: C4 register record_meta entity type in sync state"` | sync state | C4 |
| `git commit -m "feat: C5 record_meta remote gateway support"` | remote gateway | C5 |
| `git commit -m "feat: C6 soft-delete outbox sync"` | 软删除同步 | C6 |
| `git commit -m "test: C7 record sync E2E integration tests"` | E2E 测试 | C7 |
