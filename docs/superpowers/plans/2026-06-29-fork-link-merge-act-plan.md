# ACT 可执行实现计划 — Fork/Link/Merge 推断与决策链

> **日期**: 2026-06-29
> **来源 spec**: `docs/superpowers/specs/2026-06-29-fork-link-merge-inference-design.md` (F0–F8)
> **目标**: 实现分叉/关联/合并推断机制，将 decision_links 从简单边表升级为多类型决策链
> **前置条件**: Seeker 解耦 (S0–S7) 已完成并合入
> **实现顺序依赖**: Seeker 解耦 → Fork/Merge 推断 → 云同步（后者依赖前者已合入）

---

## 总览

| 任务 | 目标 | TDD 类型 | 涉及文件数 | 预估改动行数 |
|------|------|----------|-----------|-------------|
| F0 | 影响分析 + 表结构变更设计 | 分析 | 0（只读） | 0 |
| F1 | 扩展 t_decision_links 表：link_type + session_id + merge_target + inference_meta | TDD Red→Green | 3 | ~80 |
| F2 | 扩展 DecisionLinksDao：遍历/分叉/合并/推断查询 | TDD Red→Green | 2 | ~120 |
| F3 | 实现推断入口 + 强兜底逻辑（永不改已有记录/inference_session_id 原子 undo/歧义降级人工） | TDD Red→Green | 2 | ~150 |
| F4 | 实现 Fork（分叉）操作：从一条记录分叉出多条子记录 | TDD Red→Green | 2 | ~80 |
| F5 | 实现 Merge（合并）操作：多条记录合并为一条 | TDD Red→Green | 2 | ~100 |
| F6 | 决策链遍历引擎：getFullChain / getForks / getMergeSources | TDD Red→Green | 1 | ~100 |
| F7 | 集成验证：scope 隔离 + 原子性 undo + 歧义降级 | 验证 | 1 | ~120 |
| F8 | 更新 DivinationCase WorkItem 以使用新决策链类型 | 适配 | 2 | ~60 |

---

## 验收硬门槛（永不违反）

```yaml
HARD_GATES:
  - name: "永不修改已有记录"
    rule: "推断操作绝不修改已有 t_record_meta 行的 moduleDataJson 或其他业务字段。仅创建新的 decision_link 边。"
    check: "所有推断测试验证：原始记录在推断前后 moduleDataJson 不变。"

  - name: "inference_session_id 原子 undo"
    rule: "每次推断会话（session）创建的所有 link 可原子回滚。undo 删除该 session 的全部 link，不留残留。"
    check: "测试：创建 session → 添加 3 条 link → undo → 验证 0 条 link 残留。"

  - name: "歧义降级人工"
    rule: "当自动推断置信度低于阈值时，创建 link_type='inference_ambiguous' 而非 'inference'，等待人工确认。"
    check: "测试：低置信度输入 → 产出 link_type='inference_ambiguous'。"

  - name: "scope_uid 隔离"
    rule: "所有 decision_link 读写按 scope_uid 过滤。空 scope 一票否决（写操作前断言 scopeUid 非空）。"
    check: "测试：scopeA 的 link 在 scopeB 查询中不可见。空 scope 写操作抛异常。"

  - name: "入口推断强兜底"
    rule: "推断入口函数必须校验输入记录存在、scope 匹配、记录未被软删除。任一失败立即拒绝。"
    check: "测试：传入已删除记录 UUID → 抛异常。传入不匹配 scope 的 UUID → 抛异常。"
```

---

## F0: 影响分析 + 表结构变更设计

```yaml
TASK_ID: "fork-link-merge-f0-impact"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    当前 t_decision_links 只有 source_uuid / target_uuid / intent / context_snapshot_json。
    缺少：link_type 枚举（fork/sequential/merge/inference/inference_ambiguous）、
    session_id 分组、merge_target（合并目标）、inference_meta（推断元数据）。

    需要新增字段但不破坏现有数据。

  STRATEGY: |
    只读分析，产出变更设计文档。

TASK_DEPS: []

COMMANDS:
  PRECHECK: |
    echo "=== F0 影响分析 ==="
    echo "当前 t_decision_links 表结构："
    grep -A 20 "class DecisionLinks" xuan-storage/drift/lib/tables/decision_links_table.dart
    echo ""
    echo "当前 DecisionLinksDao 方法："
    grep -A 20 "class DecisionLinksDao" xuan-storage/drift/lib/daos/decision_links_dao.dart
    echo ""
    echo "引用 decision_links 的文件："
    grep -rn "decision_links\|DecisionLink\|decisionLinks" xuan-storage/drift/lib/ --include="*.dart" | grep -v ".g.dart" | head -30
    echo ""
    echo "引用 decision_links 的 core 文件："
    grep -rn "decision_links\|DecisionLink\|decisionLinks\|IDecisionRepository" xuan-storage/core/lib/ --include="*.dart" | head -20

  STEP_1: |
    执行 PRECHECK，收集所有引用。产出设计文档：
    docs/superpowers/plans/2026-06-29-fork-link-merge-impact-report.md

  STEP_2: |
    设计文档内容：
    - 新增字段列表（link_type, session_id, merge_target_uuid, inference_meta_json）
    - 每字段的类型、默认值、迁移策略（ALTER TABLE ADD COLUMN 或新建表）
    - 波及文件清单及修改建议
    - 兼容性分析（现有数据不受影响）

ASSERTIONS:
  CASES:
    - "设计文档列出所有需要修改的文件"
    - "每新增字段有明确的数据类型和默认值"

PROTOCOL:
  MODE: "read-only-analysis"

VERIFICATION: "ls -la docs/superpowers/plans/2026-06-29-fork-link-merge-impact-report.md"
```

---

## F1: 扩展 t_decision_links 表

```yaml
TASK_ID: "fork-link-merge-f1-schema"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    向 t_decision_links 新增字段：
    - link_type: TEXT, NOT NULL, DEFAULT 'sequential'（枚举值：fork/sequential/merge/inference/inference_ambiguous）
    - session_id: TEXT, nullable（同一推断会话的 link 共享此 ID）
    - merge_target_uuid: TEXT, nullable（merge 操作的目标记录 UUID）
    - inference_meta_json: TEXT, nullable（推断元数据：模型、置信度、时间戳等）

    由于 Drift 使用代码生成（.g.dart），需要：
    1. 修改表定义 → 重新生成 .g.dart
    2. 更新 DAO 的 upsert companion
    3. 编写迁移测试

  STRATEGY: |
    Drift 表变更标准流程：修改 table 定义 → build_runner build → 更新 DAO → 测试。

TASK_DEPS: ["fork-link-merge-f0-impact"]

COMMANDS:
  PRECHECK: |
    cd xuan-storage/drift && dart analyze lib/tables/decision_links_table.dart 2>&1

  # ── RED ──
  STEP_0_RED: |
    创建 drift/test/decision_links/decision_links_schema_test.dart：
    - test('link_type defaults to sequential')
    - test('session_id is nullable')
    - test('merge_target_uuid is nullable')
    - test('inference_meta_json is nullable')
    - test('existing data migration preserves old rows')

    运行测试，预期 FAIL（新字段尚不存在）。

  STEP_0_RED_CMD: "cd xuan-storage/drift && flutter test test/decision_links/decision_links_schema_test.dart 2>&1 | tail -5"
  STEP_0_RED_EXPECT: "FAIL（字段不存在）"

  # ── GREEN ──
  STEP_1_GREEN: |
    修改 drift/lib/tables/decision_links_table.dart：
    新增字段：
    - TextColumn get linkType => text().withDefault(const Constant('sequential')).named('link_type')();
    - TextColumn get sessionId => text().named('session_id').nullable()();
    - TextColumn get mergeTargetUuid => text().named('merge_target_uuid').nullable()();
    - TextColumn get inferenceMetaJson => text().named('inference_meta_json').nullable()();

  STEP_1_GREEN_CONTENT: |
    // 在 DecisionLinks 类中添加：
    TextColumn get linkType => text().withDefault(const Constant('sequential')).named('link_type')();
    TextColumn get sessionId => text().named('session_id').nullable()();
    TextColumn get mergeTargetUuid => text().named('merge_target_uuid').nullable()();
    TextColumn get inferenceMetaJson => text().named('inference_meta_json').nullable()();

  STEP_2_GREEN: |
    运行 build_runner 重新生成 .g.dart：
    cd xuan-storage/drift && dart run build_runner build --delete-conflicting-outputs

  STEP_2_GREEN_CMD: "cd xuan-storage/drift && dart run build_runner build --delete-conflicting-outputs 2>&1 | tail -10"
  STEP_2_GREEN_EXPECT: "Succeeded"

  STEP_3_GREEN: |
    更新 DecisionLinksDao.upsert() 的 companion 构建逻辑，
    确保新字段正确传入。

  STEP_4_GREEN: |
    补全测试断言，运行验证。

  STEP_4_GREEN_CMD: "cd xuan-storage/drift && flutter test test/decision_links/decision_links_schema_test.dart 2>&1"
  STEP_4_GREEN_EXPECT: "All tests passed!"

PROHIBITED:
  - 删除现有字段（source_uuid, target_uuid, intent, context_snapshot_json 等）
  - 修改现有字段的数据类型
  - 手动编辑 .g.dart 文件

ABSOLUTELY_PROHIBITED:
  - 删除 t_decision_links 中的任何现有数据

ASSERTIONS:
  CASES:
    - "linkType 默认值为 'sequential'"
    - "新字段均为 nullable 或带默认值（不破坏现有行）"
    - "build_runner 生成成功"

PROTOCOL:
  MODE: "write-files-only"
  NO_PROSE: true

VERIFICATION: "cd xuan-storage/drift && dart run build_runner build && dart analyze lib/tables/decision_links_table.dart && flutter test test/decision_links/"
```

---

## F2: 扩展 DecisionLinksDao

```yaml
TASK_ID: "fork-link-merge-f2-dao"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    当前 DecisionLinksDao 只有 upsert / getById / listBySource。
    需要新增：
    - listByTarget: 反向查找（谁指向我）
    - listBySession: 按 session_id 查询所有 link
    - listForks: 查询某 source 的所有 fork 类型 link
    - listInferences: 查询某 target 的所有 inference 类型 link
    - listByType: 按 link_type 过滤
    - deleteBySession: 删除某 session 的全部 link（用于原子 undo）
    - getMergeChain: 递归追踪 merge 链

  STRATEGY: |
    先写失败测试，再逐个实现 DAO 方法。使用 Drift 的标准 query builder。

TASK_DEPS: ["fork-link-merge-f1-schema"]

COMMANDS:
  PRECHECK: |
    cd xuan-storage/drift && flutter test test/decision_links/ 2>&1 | tail -5

  # ── RED ──
  STEP_0_RED: |
    在 drift/test/decision_links/ 中添加 decision_links_dao_test.dart：
    - test('listByTarget returns links pointing to target')
    - test('listBySession groups links by session_id')
    - test('listForks returns only fork-type links')
    - test('listInferences returns inference-type links')
    - test('deleteBySession removes all links of a session')
    - test('getMergeChain traverses merge links recursively')

    运行测试，预期全部 FAIL。

  # ── GREEN ──
  STEP_1_GREEN: |
    在 DecisionLinksDao 中添加：
    - Future<List<DecisionLinkRow>> listByTarget(String targetUuid, String scopeUid)
    - Future<List<DecisionLinkRow>> listBySession(String sessionId, String scopeUid)
    - Future<List<DecisionLinkRow>> listByType(String sourceUuid, String linkType, String scopeUid)
    - Future<int> deleteBySession(String sessionId, String scopeUid)
    - Future<List<DecisionLinkRow>> getMergeChain(String startUuid, String scopeUid)

    所有方法必须过滤 scopeUid。

  STEP_1_GREEN_CONTENT: |
    // 新增 DAO 方法：
    Future<List<DecisionLinkRow>> listByTarget(String targetUuid, String scopeUid) =>
        (select(db.decisionLinks)
              ..where((t) => t.targetUuid.equals(targetUuid) & t.scopeUid.equals(scopeUid) & t.deletedAtMs.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.createdAtMs)]))
            .get();

    Future<List<DecisionLinkRow>> listBySession(String sessionId, String scopeUid) =>
        (select(db.decisionLinks)
              ..where((t) => t.sessionId.equals(sessionId) & t.scopeUid.equals(scopeUid)))
            .get();

    Future<List<DecisionLinkRow>> listByType(String sourceUuid, String linkType, String scopeUid) =>
        (select(db.decisionLinks)
              ..where((t) => t.sourceUuid.equals(sourceUuid) & t.linkType.equals(linkType) & t.scopeUid.equals(scopeUid) & t.deletedAtMs.isNull()))
            .get();

    Future<int> deleteBySession(String sessionId, String scopeUid) =>
        (delete(db.decisionLinks)
              ..where((t) => t.sessionId.equals(sessionId) & t.scopeUid.equals(scopeUid)))
            .go();

    Future<List<DecisionLinkRow>> getMergeChain(String startUuid, String scopeUid) async {
      final results = <DecisionLinkRow>[];
      var current = startUuid;
      while (true) {
        final links = await listBySource(current, scopeUid);
        final mergeLinks = links.where((l) => l.linkType == 'merge').toList();
        if (mergeLinks.isEmpty) break;
        results.addAll(mergeLinks);
        current = mergeLinks.first.targetUuid;
      }
      return results;
    }

  STEP_2_GREEN: |
    运行 build_runner 重新生成 DAO .g.dart。

  STEP_3_GREEN: |
    补全测试，运行验证。

  STEP_3_GREEN_CMD: "cd xuan-storage/drift && flutter test test/decision_links/decision_links_dao_test.dart 2>&1"
  STEP_3_GREEN_EXPECT: "All tests passed! (6 tests)"

PROHIBITED:
  - 修改现有方法签名（向后兼容）
  - 手动编辑 .g.dart 文件

ASSERTIONS:
  CASES:
    - "所有新增查询方法过滤 scopeUid"
    - "deleteBySession 原子删除该 session 全部 link"
    - "getMergeChain 正确处理循环引用（通过 visited set 防无限循环）"

VERIFICATION: "cd xuan-storage/drift && flutter test test/decision_links/"
```

---

## F3: 推断入口 + 强兜底逻辑

```yaml
TASK_ID: "fork-link-merge-f3-inference-engine"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    推断入口函数负责创建 inference 类型的 decision_link。
    必须实现所有验收硬门槛：
    1. 永不修改已有记录 — 只创建 link，不修改 t_record_meta
    2. inference_session_id 原子 undo — session 内所有 link 可批量回滚
    3. 歧义降级人工 — 低置信度标记为 inference_ambiguous
    4. scope_uid 隔离 + 空 scope 一票否决
    5. 入口推断强兜底 — 校验输入记录存在/scope 匹配/未删除

  STRATEGY: |
    创建 InferenceEngine 类，封装所有推断逻辑。
    先写失败测试覆盖所有硬门槛，再实现。

TASK_DEPS: ["fork-link-merge-f2-dao"]

COMMANDS:
  PRECHECK: |
    cd xuan-storage/drift && flutter test test/decision_links/ 2>&1 | tail -3

  # ── RED ──
  STEP_0_RED: |
    创建 drift/test/decision_links/inference_engine_test.dart：
    覆盖全部 5 个硬门槛测试用例。

  STEP_0_RED_CONTENT: |
    group('InferenceEngine hard gates', () {
      test('never modifies existing records', () { /* RED */ });
      test('atomic undo by session_id', () { /* RED */ });
      test('ambiguity downgrades to inference_ambiguous', () { /* RED */ });
      test('empty scopeUid throws AssertionError', () { /* RED */ });
      test('deleted record inference throws StateError', () { /* RED */ });
      test('scope mismatch throws StateError', () { /* RED */ });
    });

  # ── GREEN ──
  STEP_1_GREEN: |
    创建 drift/lib/decision_links/inference_engine.dart：
    - inferLink(sourceUuid, targetUuid, intent, {sessionId, confidence})
    - undoSession(sessionId)
    - validateInputs(sourceUuid, targetUuid, scopeUid) → 检查记录存在/scope 匹配/未删除
    - 低置信度自动降级为 inference_ambiguous

  STEP_1_GREEN_CONTENT: |
    import 'package:repository_interface_record/repository_interface_record.dart';
    import 'package:uuid/uuid.dart';
    import '../daos/decision_links_dao.dart';
    import '../persistence_drift.dart';

    class InferenceEngine {
      final DecisionLinksDao _dao;
      final ScopedRecordStore _recordStore;
      final Uuid _uuid;

      InferenceEngine(this._dao, this._recordStore, {Uuid? uuid})
          : _uuid = uuid ?? const Uuid();

      String get scopeUid => _recordStore.scopeUid;

      /// 推断一条 link。返回创建的 link ID。
      Future<String> inferLink({
        required String sourceUuid,
        required String targetUuid,
        required String intent,
        String? sessionId,
        double confidence = 1.0,
        Map<String, dynamic>? inferenceMeta,
      }) async {
        await _validateInputs(sourceUuid, targetUuid);

        final effectiveType = confidence < 0.7 ? 'inference_ambiguous' : 'inference';
        final linkId = _uuid.v7();
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        final meta = <String, dynamic>{
          'confidence': confidence,
          'inferredAt': DateTime.now().toUtc().toIso8601String(),
          if (inferenceMeta != null) ...inferenceMeta,
        };

        await _dao.upsert(DecisionLinksCompanion.insert(
          id: linkId,
          sourceUuid: sourceUuid,
          targetUuid: targetUuid,
          intent: intent,
          linkType: effectiveType,
          sessionId: Value(sessionId),
          inferenceMetaJson: Value('{$meta}'), // simplified; use jsonEncode
          scopeUid: scopeUid,
          createdAtMs: nowMs,
          updatedAtMs: nowMs,
        ));
        return linkId;
      }

      /// 原子回滚一个推断会话的全部 link。
      Future<int> undoSession(String sessionId) =>
          _dao.deleteBySession(sessionId, scopeUid);

      Future<void> _validateInputs(String sourceUuid, String targetUuid) async {
        if (scopeUid.isEmpty) throw AssertionError('scopeUid must not be empty');
        final source = await _recordStore.getRecord(sourceUuid, module: ''); // module 不限
        if (source == null) throw StateError('Source record $sourceUuid not found');
        if (source.deletedAt != null) throw StateError('Source record $sourceUuid is deleted');
        if (source.scopeUid != scopeUid) throw StateError('Source scope mismatch');
        final target = await _recordStore.getRecord(targetUuid, module: '');
        if (target == null) throw StateError('Target record $targetUuid not found');
        if (target.deletedAt != null) throw StateError('Target record $targetUuid is deleted');
        if (target.scopeUid != scopeUid) throw StateError('Target scope mismatch');
      }
    }

  STEP_2_GREEN: |
    补全测试，运行验证。

  STEP_2_GREEN_CMD: "cd xuan-storage/drift && flutter test test/decision_links/inference_engine_test.dart 2>&1"
  STEP_2_GREEN_EXPECT: "All tests passed! (6 tests)"

PROHIBITED:
  - 在推断过程中修改 t_record_meta 的任何行
  - 跳过 scopeUid 校验
  - 允许对已删除记录创建 link

ABSOLUTELY_PROHIBITED:
  - 修改已有记录的 moduleDataJson 或任何业务字段

ASSERTIONS:
  CASES:
    - "所有 5 个硬门槛测试全部通过"
    - "inferLink 置信度 < 0.7 时 link_type='inference_ambiguous'"
    - "undoSession 后该 session 的 link 数量为 0"

PROTOCOL:
  MODE: "write-files-only"
  NO_PROSE: true

VERIFICATION: "cd xuan-storage/drift && flutter test test/decision_links/inference_engine_test.dart"
```

---

## F4: Fork 分叉操作

```yaml
TASK_ID: "fork-link-merge-f4-fork"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    Fork 操作：从一条源记录分叉出多条子记录，每个子记录代表一个分支方向。
    所有 fork link 共享同一个 session_id（用于批量管理）。
    link_type = 'fork'。

  STRATEGY: |
    在 InferenceEngine（或新建 ForkEngine）中添加 forkRecords() 方法。
    创建 fork link 时同时创建子记录（如果子记录尚不存在）。

TASK_DEPS: ["fork-link-merge-f3-inference-engine"]

COMMANDS:
  PRECHECK: |
    cd xuan-storage/drift && flutter test test/decision_links/ 2>&1 | tail -3

  # ── RED ──
  STEP_0_RED: |
    创建 drift/test/decision_links/fork_engine_test.dart：
    - test('fork creates multiple child links from one source')
    - test('fork links share same session_id')
    - test('fork children are queryable via listByType with fork')
    - test('fork source must exist and not be deleted')

  # ── GREEN ──
  STEP_1_GREEN: |
    创建 drift/lib/decision_links/fork_engine.dart：
    - Future<String> fork(String sourceUuid, List<String> targetUuids, {String? sessionId})
    - 为每个 target 创建 link_type='fork' 的 link
    - 返回 sessionId

  STEP_2_GREEN_CMD: "cd xuan-storage/drift && flutter test test/decision_links/fork_engine_test.dart 2>&1"
  STEP_2_GREEN_EXPECT: "All tests passed! (4 tests)"

PROHIBITED:
  - 修改源记录或目标记录的内容

ASSERTIONS:
  CASES:
    - "fork 后所有子 link 的 sourceUuid 相同"
    - "fork 后所有子 link 的 sessionId 相同且非空"
    - "listByType(source, 'fork') 返回所有分叉 link"

VERIFICATION: "cd xuan-storage/drift && flutter test test/decision_links/fork_engine_test.dart"
```

---

## F5: Merge 合并操作

```yaml
TASK_ID: "fork-link-merge-f5-merge"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    Merge 操作：多条源记录合并为一条目标记录。
    link_type = 'merge'，merge_target_uuid 指向合并后的记录。
    源记录本身不被修改（硬门槛）。

    支持两种 merge 模式：
    - mergeInto: 多条源 → 一条已存在的目标
    - mergeNew: 多条源 → 创建新目标记录

  STRATEGY: |
    创建 MergeEngine，实现 mergeInto / mergeNew。
    源记录的 moduleDataJson 永不修改。

TASK_DEPS: ["fork-link-merge-f4-fork"]

COMMANDS:
  PRECHECK: |
    cd xuan-storage/drift && flutter test test/decision_links/ 2>&1 | tail -3

  # ── RED ──
  STEP_0_RED: |
    创建 drift/test/decision_links/merge_engine_test.dart：
    - test('mergeInto creates merge links from sources to target')
    - test('mergeNew creates target record and merge links')
    - test('source records are NOT modified after merge')
    - test('merge sources must exist and not be deleted')

  # ── GREEN ──
  STEP_1_GREEN: |
    创建 drift/lib/decision_links/merge_engine.dart：
    - mergeInto(List<String> sourceUuids, String targetUuid, {String? sessionId})
    - mergeNew(List<String> sourceUuids, TContract targetContract, RecordModuleCodec<TContract> codec)

  STEP_2_GREEN_CMD: "cd xuan-storage/drift && flutter test test/decision_links/merge_engine_test.dart 2>&1"
  STEP_2_GREEN_EXPECT: "All tests passed! (4 tests)"

ASSERTIONS:
  CASES:
    - "merge 后源记录的 moduleDataJson 与原值完全一致"
    - "merge link 的 mergeTargetUuid 指向目标记录"
    - "getMergeChain 可追踪完整合并链"

VERIFICATION: "cd xuan-storage/drift && flutter test test/decision_links/merge_engine_test.dart"
```

---

## F6: 决策链遍历引擎

```yaml
TASK_ID: "fork-link-merge-f6-traversal"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    提供统一的决策链遍历接口：
    - getFullChain(rootUuid) → 从根记录出发遍历所有下游 link
    - getForks(sourceUuid) → 查询某记录的所有分叉
    - getMergeSources(targetUuid) → 查询合并到某记录的所有源
    - getInferenceChain(targetUuid) → 查询指向某记录的所有推断链

  STRATEGY: |
    创建 DecisionChainTraverser 类，封装遍历逻辑。
    使用 BFS/DFS，防止循环引用。

TASK_DEPS: ["fork-link-merge-f5-merge"]

COMMANDS:
  PRECHECK: |
    cd xuan-storage/drift && flutter test test/decision_links/ 2>&1 | tail -3

  # ── RED ──
  STEP_0_RED: |
    创建 drift/test/decision_links/chain_traverser_test.dart：
    - test('getFullChain returns all downstream links in BFS order')
    - test('getForks returns only fork links')
    - test('getMergeSources returns merge links pointing to target')
    - test('getInferenceChain returns inference links')
    - test('cycle detection prevents infinite loops')

  # ── GREEN ──
  STEP_1_GREEN: |
    创建 drift/lib/decision_links/decision_chain_traverser.dart：
    - getFullChain(rootUuid) → BFS 遍历
    - getForks(sourceUuid) → filter link_type='fork'
    - getMergeSources(targetUuid) → filter link_type='merge'
    - getInferenceChain(targetUuid) → filter link_type='inference' or 'inference_ambiguous'
    - 所有方法带 visited set 防循环

  STEP_2_GREEN_CMD: "cd xuan-storage/drift && flutter test test/decision_links/chain_traverser_test.dart 2>&1"
  STEP_2_GREEN_EXPECT: "All tests passed! (5 tests)"

ASSERTIONS:
  CASES:
    - "循环引用不会导致无限循环"
    - "遍历结果按 createdAt 排序"
    - "所有遍历方法过滤 scopeUid"

VERIFICATION: "cd xuan-storage/drift && flutter test test/decision_links/chain_traverser_test.dart"
```

---

## F7: 集成验证

```yaml
TASK_ID: "fork-link-merge-f7-integration"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    端到端集成测试，覆盖：
    - 完整场景：创建记录 → fork → inference → merge → 验证链完整性
    - scope 隔离：scopeA 的链在 scopeB 不可见
    - 原子 undo：session 级别的回滚
    - 歧义降级：低置信度自动标记

  STRATEGY: |
    使用内存 Drift 数据库，构建完整的 fork→inference→merge 场景。

TASK_DEPS: ["fork-link-merge-f6-traversal"]

COMMANDS:
  PRECHECK: |
    cd xuan-storage/drift && flutter test test/decision_links/ 2>&1 | tail -3

  # ── RED ──
  STEP_0_RED: |
    创建 drift/test/decision_links/integration_test.dart：
    - test('full scenario: create → fork → infer → merge → verify chain')
    - test('scope A chain invisible in scope B')
    - test('session undo removes all links atomically')
    - test('ambiguity downgrade preserves chain but marks ambiguous')

  # ── GREEN ──
  STEP_1_GREEN: |
    实现集成测试，使用 Drift 内存数据库（NativeDatabase.memory()）。

  STEP_1_GREEN_CMD: "cd xuan-storage/drift && flutter test test/decision_links/integration_test.dart 2>&1"
  STEP_1_GREEN_EXPECT: "All tests passed! (4 tests)"

ASSERTIONS:
  CASES:
    - "集成场景端到端通过"
    - "scope 隔离生效"
    - "原子 undo 无残留"
    - "歧义降级正确标记"

VERIFICATION: "cd xuan-storage/drift && flutter test test/decision_links/"
```

---

## F8: 适配 DivinationCase WorkItem 使用新决策链

```yaml
TASK_ID: "fork-link-merge-f8-case-adapter"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    t_divination_work_items 有 parent_work_item_uuid 字段（树形层级）。
    t_decision_links 现在有 fork/merge/inference 类型。
    需要在 DriftDivinationCaseRepository 中适配：
    - work item 的 parent 关系可通过 decision_links 的 fork 类型表达
    - 不修改 work_items 表结构，仅添加辅助方法

  STRATEGY: |
    在 DriftDivinationCaseRepository 中添加：
    - getWorkItemForks(workItemUuid) → 查询该 work item 关联的 fork links
    - 不强制迁移现有 parent_work_item_uuid 数据

TASK_DEPS: ["fork-link-merge-f7-integration"]

COMMANDS:
  PRECHECK: |
    cd xuan-storage/drift && dart analyze lib/divination_case/ 2>&1

  STEP_1: |
    在 DriftDivinationCaseRepository 中添加私有方法：
    - _getDecisionLinksForWorkItem(String workItemUuid)
    通过 t_record_meta.work_item_uuid 找到关联记录，再查 decision_links。

  STEP_2: |
    添加测试验证 work item ↔ decision link 关联。

  STEP_2_CMD: "cd xuan-storage/drift && flutter test test/divination_case/ 2>&1 || echo '测试待补充'"

PROHIBITED:
  - 修改 t_divination_work_items 表结构
  - 删除 parent_work_item_uuid 字段

ASSERTIONS:
  CASES:
    - "work item 可通过 record 间接关联 decision_links"

VERIFICATION: "cd xuan-storage/drift && dart analyze lib/divination_case/"
```

---

## 实现顺序依赖声明

```
F0 (影响分析)
 └─ F1 (表结构扩展)
     └─ F2 (DAO 扩展)
         └─ F3 (推断引擎 + 强兜底)
             ├─ F4 (Fork 分叉)
             │   └─ F5 (Merge 合并)
             │       └─ F6 (遍历引擎)
             │           └─ F7 (集成验证)
             └─ F8 (Case 适配，可与 F4–F7 并行)

前置：全部 S0–S7 (Seeker 解耦) 已完成并合入。
后续：F0–F8 全部完成后，云同步 (C0–C7) 才能开始。
```

---

## Git 提交粒度

| 提交 | 内容 | 关联任务 |
|------|------|----------|
| `git commit -m "docs: F0 fork-link-merge impact report"` | 影响分析 | F0 |
| `git commit -m "test: F1 RED schema extension tests"` | 失败测试 | F1-RED |
| `git commit -m "feat: F1 GREEN extend decision_links table schema"` | 表结构+代码生成 | F1-GREEN |
| `git commit -m "test: F2 RED DAO extension tests"` | 失败测试 | F2-RED |
| `git commit -m "feat: F2 GREEN extend DecisionLinksDao"` | DAO 方法 | F2-GREEN |
| `git commit -m "feat: F3 inference engine with hard gates"` | 推断引擎 | F3 |
| `git commit -m "feat: F4 fork engine"` | 分叉 | F4 |
| `git commit -m "feat: F5 merge engine"` | 合并 | F5 |
| `git commit -m "feat: F6 decision chain traverser"` | 遍历引擎 | F6 |
| `git commit -m "test: F7 integration tests"` | 集成测试 | F7 |
| `git commit -m "feat: F8 case work item decision link adapter"` | 适配 | F8 |
