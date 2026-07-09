# ACT 可执行实现计划 — Seeker 解耦与统一记录接入

> **日期**: 2026-06-29
> **来源 spec**: `docs/superpowers/specs/2026-06-29-seeker-decoupling-design.md` (S0–S7)
> **目标**: 将 Seeker 从旧 divination 耦合表中解耦，作为统一记录模块接入 `t_record_meta`
> **前置条件**: ACT-1 ~ ACT-13 已完成（8 模块全部接入统一记录系统）
> **实现顺序依赖**: Seeker 解耦 → Fork/Merge 推断 → 云同步（后者依赖前者已合入）

---

## 总览

| 任务 | 目标 | TDD 类型 | 涉及文件数 | 预估改动行数 |
|------|------|----------|-----------|-------------|
| S0 | 影响分析：评估 seeker 解耦对现有表/DAO/仓库的波及面 | 分析 | 0（只读） | 0 |
| S1 | 创建 Seeker 合约 + RecordModuleCodec + 模块注册 + 仓库 | TDD Red→Green | 5 | ~180 |
| S2 | 迁移现有 Seeker 数据到 t_record_meta（单向迁移脚本） | TDD Red→Green | 2 | ~120 |
| S3 | 更新 DivinationCase 参与者引用，指向 record_meta 而非旧 seekers 表 | TDD Red→Green | 3 | ~60 |
| S4 | 在 DriftRecordDataSource/BaseRecordBackedRepository 中补充 seeker 索引查询 | TDD Red→Green | 2 | ~50 |
| S5 | 标记旧表 t_seekers / t_seeker_divination_mapper 为 deprecated | 清理 | 3 | ~30 |
| S6 | 端到端集成验证：seeker 全生命周期走 record 通道 | 验证 | 1 | ~80 |
| S7 | 清理旧 DAO 中直接引用 divinationUuid 的查询方法 | 清理 | 2 | ~40 |

---

## S0: 影响分析（只读，不写代码）

```yaml
TASK_ID: "seeker-decoupling-s0-impact"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    Seeker 当前耦合到三张表：
    1. t_seekers — 求测人主表，含 divinationUuid 外键
    2. t_seeker_divination_mapper — 多对多映射
    3. t_divinations — 含 ownerSeekerUuid / seekerName 字段

    t_record_meta 已有 seekerUuid / seekerName / gender / fateYear 字段（空置）。
    8 个占测模块的 codec 均未填充这些字段。

    本任务只读分析，产出影响报告，不修改任何文件。

  STRATEGY: |
    运行 grep 扫描所有引用 t_seekers / SeekerModel / seekers_dao / divinationUuid / ownerSeekerUuid 的文件。
    列出每个引用位置、引用方式、是否需要修改、建议修改方案。
    将报告写入 docs/superpowers/plans/2026-06-29-seeker-impact-report.md。

TASK_DEPS: []

COMMANDS:
  PRECHECK: |
    echo "=== S0 影响分析（只读） ==="
    echo "扫描 t_seekers 引用..."
    grep -rn "t_seekers\|Seekers\b" xuan-storage/drift/lib/ --include="*.dart" | head -80
    echo ""
    echo "扫描 SeekerModel 引用..."
    grep -rn "SeekerModel\|seeker_model" xuan-storage/drift/lib/ --include="*.dart" | head -40
    echo ""
    echo "扫描 divinationUuid 引用..."
    grep -rn "divinationUuid\|divination_uuid" xuan-storage/drift/lib/ --include="*.dart" | head -40
    echo ""
    echo "扫描 ownerSeekerUuid 引用..."
    grep -rn "ownerSeekerUuid\|seeker_uuid" xuan-storage/drift/lib/ --include="*.dart" | head -40
    echo ""
    echo "扫描 seekers_dao 引用..."
    grep -rn "seekers_dao\|SeekersDao" xuan-storage/drift/lib/ --include="*.dart" | head -20

  STEP_1: |
    执行上述 PRECHECK 命令，收集所有引用位置。
    将输出粘贴到影响报告文档中。

  STEP_2: |
    对每个引用位置标注：
    - 文件路径:行号
    - 引用方式（表定义/DAO 方法调用/外键/import）
    - 是否需要修改（是/否/条件）
    - 建议修改方案

  STEP_3: |
    产出影响报告，写入：
    docs/superpowers/plans/2026-06-29-seeker-impact-report.md
    包含：波及文件清单、每文件修改方案、风险点、回滚策略。

ASSERTIONS:
  EXECENV: "报告文件存在且内容完整"
  CASES:
    - "所有引用 t_seekers 的文件均已列出"
    - "所有引用 SeekerModel 的文件均已列出"
    - "所有引用 ownerSeekerUuid 的文件均已列出"
    - "每个引用均有修改建议"

PROTOCOL:
  MODE: "read-only-analysis"
  NO_PROSE: false
  OUTPUT_FORMAT: "Markdown 报告写入 docs/superpowers/plans/"

VERIFICATION: "ls -la docs/superpowers/plans/2026-06-29-seeker-impact-report.md && wc -l docs/superpowers/plans/2026-06-29-seeker-impact-report.md"
```

---

## S1: 创建 Seeker 统一记录模块（Red→Green→Refactor）

```yaml
TASK_ID: "seeker-decoupling-s1-codec-registry-repo"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    参照已接入的 8 个模块模式（以 liuyao 为模板），为 Seeker 创建：
    1. Seeker 记录合约（如果现有 SeekerModel 不满足）
    2. SeekerRecordCodec（实现 RecordModuleCodec<SeekerModel>）
    3. SeekerModuleRegistry（静态 codec() + repository() 工厂）
    4. RecordBackedSeekerRepository（继承 BaseRecordBackedRepository）
    5. 在 RecordModuleRegistry 中注册 seeker 模块

    关键设计决策：
    - module = 'seeker'，category = 'person'（不是 'divination'）
    - divinationType = ''（seeker 不是占测类型）
    - encode 时将 SeekerModel 的日历/干支/位置字段序列化到 moduleDataJson
    - extractSearchTags 输出 username, gender, lunar_month 等可搜索标签
    - scope_uid 强制非空，由 _store.scopeUid 注入

  STRATEGY: |
    严格 TDD：先写失败测试 → 最小实现让测试通过 → 重构。
    参照 drift/lib/liuyao/ 的三文件模式。

TASK_DEPS: ["seeker-decoupling-s0-impact"]

COMMANDS:
  PRECHECK: |
    cd xuan-storage/drift && flutter test test/seeker/ 2>&1 | head -20 || echo "测试目录尚不存在（预期）"

  # ── RED: 写失败测试 ──
  STEP_0_RED: |
    创建 drift/test/seeker/seeker_record_codec_test.dart：
    - test('codec module is seeker') → 断言 codec.module == 'seeker'
    - test('codec category is person') → 断言 codec.category == 'person'
    - test('encode produces RecordMeta with scopeUid') → 编码后 meta.scopeUid 非空
    - test('encode → decode roundtrip preserves fields') → 编解码往返保持字段一致
    - test('decode throws RecordCodecMismatch on wrong module') → 模块不匹配抛异常
    - test('extractSearchTags returns expected tags') → 标签提取正确

    运行测试，预期全部 FAIL（因为文件还不存在）。

  STEP_0_RED_CONTENT: |
    import 'package:flutter_test/flutter_test.dart';
    import 'package:metaphysics_core/datamodel/seeker_model.dart';
    import 'package:metaphysics_core/enums/enum_gender.dart';
    import 'package:metaphysics_core/enums/enum_datetime_type.dart';
    import 'package:metaphysics_core/enums/enum_jia_zi.dart';
    import 'package:repository_interface_record/repository_interface_record.dart';
    import 'package:persistence_drift/persistence_drift.dart';
    // 以下 import 路径待 S1 实现后生效
    // import 'package:persistence_drift/seekers/seeker_record_codec.dart';

    void main() {
      group('SeekerRecordCodec', () {
        // 所有测试在此先 FAIL
        test('codec module is seeker', () {
          // final codec = SeekerRecordCodec();
          // expect(codec.module, 'seeker');
        }, skip: '待实现');
      });
    }

  STEP_0_RED_CMD: "cd xuan-storage/drift && flutter test test/seeker/seeker_record_codec_test.dart 2>&1 | tail -5"
  STEP_0_RED_EXPECT: "测试文件编译失败（类不存在）或全部 skip — 确认为 RED"

  # ── GREEN: 最小实现 ──
  STEP_1_GREEN: |
    创建 drift/lib/seeker/seeker_record_codec.dart：
    实现 RecordModuleCodec<SeekerModel>。
    module='seeker', category='person', divinationType=''.
    encode: 序列化 timingType/datetime/yearGanZhi/monthGanZhi/dayGanZhi/timeGanZhi/
            lunarMonth/isLeapMonth/lunarDay/location/timingInfoListJson 到 moduleDataJson。
    decode: 反序列化回 SeekerModel。
    extractSearchTags: username, gender.name, 'lunar_month:${lunarMonth}'。

  STEP_1_GREEN_CONTENT: |
    import 'dart:convert';
    import 'package:metaphysics_core/datamodel/seeker_model.dart';
    import 'package:metaphysics_core/enums/enum_gender.dart';
    import 'package:metaphysics_core/enums/enum_datetime_type.dart';
    import 'package:metaphysics_core/enums/enum_jia_zi.dart';
    import 'package:repository_interface_record/repository_interface_record.dart';

    class SeekerRecordCodec implements RecordModuleCodec<SeekerModel> {
      @override String get module => 'seeker';
      @override String get category => 'person';
      @override String get divinationType => '';

      @override String uuidOf(SeekerModel c) => c.uuid;
      @override
      SeekerModel withUuid(SeekerModel c, String uuid) => c.copyWith(uuid: uuid);

      @override
      EncodedRecord encode(SeekerModel c, {required String scopeUid}) {
        final data = <String, dynamic>{
          'username': c.username, 'nickname': c.nickname,
          'gender': c.gender.name, 'timingType': c.timingType.name,
          'datetime': c.datetime.toIso8601String(),
          'yearGanZhi': c.yearGanZhi.name, 'monthGanZhi': c.monthGanZhi.name,
          'dayGanZhi': c.dayGanZhi.name, 'timeGanZhi': c.timeGanZhi.name,
          'lunarMonth': c.lunarMonth, 'isLeapMonth': c.isLeapMonth,
          'lunarDay': c.lunarDay, 'timingInfoUuid': c.timingInfoUuid,
          'currentCalendarUuid': c.currentCalendarUuid,
        };
        final meta = RecordMeta(
          uuid: c.uuid, scopeUid: scopeUid, module: module, category: category,
          divinationType: divinationType, seekerName: c.nickname ?? c.username,
          gender: c.gender.name, fateYear: null,
          moduleDataJson: jsonEncode(data),
          navParamsJson: jsonEncode({'recordUuid': c.uuid}),
          createdAt: c.createdAt, updatedAt: c.lastUpdatedAt,
          deletedAt: c.deletedAt, rev: 1,
        );
        return (meta: meta, moduleData: data);
      }

      @override
      SeekerModel decode(RecordMeta meta, Map<String, dynamic>? moduleData) {
        if (meta.module != module) throw RecordCodecMismatch(message: 'module mismatch');
        final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
        return SeekerModel(
          uuid: meta.uuid,
          username: d['username'] as String?,
          nickname: d['nickname'] as String? ?? meta.seekerName,
          gender: Gender.values.firstWhere((g) => g.name == (d['gender'] ?? meta.gender)),
          timingType: DateTimeType.values.firstWhere((t) => t.name == d['timingType']),
          datetime: DateTime.parse(d['datetime'] as String),
          yearGanZhi: JiaZi.values.firstWhere((j) => j.name == d['yearGanZhi']),
          monthGanZhi: JiaZi.values.firstWhere((j) => j.name == d['monthGanZhi']),
          dayGanZhi: JiaZi.values.firstWhere((j) => j.name == d['dayGanZhi']),
          timeGanZhi: JiaZi.values.firstWhere((j) => j.name == d['timeGanZhi']),
          lunarMonth: d['lunarMonth'] as int,
          isLeapMonth: d['isLeapMonth'] as bool? ?? false,
          lunarDay: d['lunarDay'] as int,
          timingInfoUuid: d['timingInfoUuid'] as String?,
          currentCalendarUuid: d['currentCalendarUuid'] as String?,
          createdAt: meta.createdAt,
          lastUpdatedAt: meta.updatedAt,
          deletedAt: meta.deletedAt,
        );
      }

      @override
      List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? moduleData) {
        final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
        return [
          if (meta.seekerName != null) SearchTag('seeker_name', meta.seekerName!),
          if (meta.gender != null) SearchTag('gender', meta.gender!),
          if (d['lunarMonth'] != null) SearchTag('lunar_month', '${d['lunarMonth']}'),
        ];
      }
    }

  STEP_2_GREEN: |
    创建 drift/lib/seeker/seeker_module_registry.dart：
    参照 liuyao_module_registry.dart 模式。

  STEP_2_GREEN_CONTENT: |
    import 'package:metaphysics_core/datamodel/seeker_model.dart';
    import 'package:repository_interface_record/repository_interface_record.dart';
    import 'package:uuid/uuid.dart';
    import 'seeker_record_codec.dart';
    import 'record_backed_seeker_repository.dart';

    class SeekerModuleRegistry {
      static RecordModuleCodec<SeekerModel> codec() => SeekerRecordCodec();

      static RecordBackedSeekerRepository repository({
        required ScopedRecordStore store,
        Uuid? uuid,
      }) => RecordBackedSeekerRepository(store: store, codec: codec(), uuid: uuid);
    }

  STEP_3_GREEN: |
    创建 drift/lib/seeker/record_backed_seeker_repository.dart：
    继承 BaseRecordBackedRepository<SeekerModel>，实现核心业务方法。

  STEP_3_GREEN_CONTENT: |
    import 'package:metaphysics_core/datamodel/seeker_model.dart';
    import '../record/base_record_backed_repository.dart';
    import 'seeker_record_codec.dart';

    class RecordBackedSeekerRepository
        extends BaseRecordBackedRepository<SeekerModel> {
      RecordBackedSeekerRepository({
        required super.store,
        required super.codec,
        super.uuid,
      });

      Future<String> saveSeeker(SeekerModel seeker) => save(seeker);
      Future<SeekerModel?> getSeekerByUuid(String uuid) => getByUuid(uuid);
      Future<List<SeekerModel>> getAllSeekers() => getAll();
      Future<bool> softDeleteSeeker(String uuid) => softDelete(uuid);
      Future<SeekerModel?> findByName(String name) =>
          getFirstByIndex('seeker_name', name);
    }

  STEP_4_GREEN: |
    在 RecordModuleRegistry 中注册 seeker 模块。
    修改 drift/lib/record/record_module_registry.dart：
    - 添加 import '../seeker/seeker_module_registry.dart';
    - 在 allExtractors() 中添加 SeekerModuleRegistry.codec()
    - 在 repositoryFor() switch 中添加 case 'seeker'

  STEP_4_GREEN_CONTENT: |
    // 在 allExtractors() 返回列表末尾添加：
    SeekerModuleRegistry.codec(),

    // 在 repositoryFor() switch 中添加：
    case 'seeker':
      return SeekerModuleRegistry.repository(store: store);

  STEP_5_GREEN: |
    取消 S0_RED 测试中的 skip，补全测试断言，运行验证。

  STEP_5_GREEN_CMD: "cd xuan-storage/drift && flutter test test/seeker/seeker_record_codec_test.dart 2>&1"
  STEP_5_GREEN_EXPECT: "All tests passed! (6 tests)"

  # ── REFACTOR: 优化 ──
  STEP_6_REFACTOR: |
    检查 codec 中是否有重复的枚举反序列化逻辑，提取公共 helper。
    确认所有文件 dart analyze 零错误。

  STEP_6_REFACTOR_CMD: "cd xuan-storage/drift && dart analyze lib/seeker/ 2>&1"

PROHIBITED:
  - 修改 t_seekers 表结构（本任务仅新增，不删旧表）
  - 修改 SeekerModel 类定义（它在 metaphysics_core 中，不属本仓库）
  - 在 codec 中硬编码 scope_uid 为空字符串
  - 引入对旧 DAO (SeekersDao) 的依赖

ABSOLUTELY_PROHIBITED:
  - 修改 t_record_meta 或 t_record_search_index 表结构
  - 删除任何旧表或旧 DAO 方法

ASSERTIONS:
  EXECENV: "cd xuan-storage/drift && dart analyze lib/seeker/ 零错误"
  CASES:
    - "SeekerRecordCodec 实现 RecordModuleCodec<SeekerModel>"
    - "encode → decode 往返保持 username/nickname/gender/timingType 一致"
    - "extractSearchTags 至少包含 seeker_name 标签"
    - "RecordModuleRegistry.allExtractors() 包含 9 个提取器（8 占测 + 1 seeker）"
    - "RecordModuleRegistry.repositoryFor(module: 'seeker') 返回 RecordBackedSeekerRepository"

PROTOCOL:
  MODE: "write-files-only"
  NO_PROSE: true
  OUTPUT_FORMAT: "每个 STEP 产出对应的 .dart 文件"

VERIFICATION: "cd xuan-storage/drift && flutter test test/seeker/ && dart analyze lib/seeker/"
```

---

## S2: 迁移现有 Seeker 数据到 t_record_meta

```yaml
TASK_ID: "seeker-decoupling-s2-migration"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    现有 t_seekers 表中已有求测人数据（含 username/nickname/gender/日历/干支/位置）。
    需要编写单向迁移脚本，将 t_seekers 中的数据通过 SeekerRecordCodec 编码后
    写入 t_record_meta + t_record_search_index。

    迁移策略：
    - 只迁移 deletedAt IS NULL 的记录（未软删除）
    - 每条 seeker 生成 module='seeker' 的 RecordMeta
    - scopeUid 从当前 DriftRecordDataSource.scopeUid 获取
    - 使用 SeekerRecordCodec.encode() 保证编解码一致
    - 迁移后验证：查询 t_record_meta WHERE module='seeker' 行数 ≥ t_seekers 有效行数

  STRATEGY: |
    先写失败测试验证迁移前后数据一致性，再实现迁移逻辑，最后验证。

TASK_DEPS: ["seeker-decoupling-s1-codec-registry-repo"]

COMMANDS:
  PRECHECK: |
    cd xuan-storage/drift && flutter test test/seeker/ 2>&1 | tail -5

  # ── RED ──
  STEP_0_RED: |
    创建 drift/test/seeker/seeker_migration_test.dart：
    - test('migrateAllSeekers copies non-deleted seekers to t_record_meta')
    - test('migrated seeker roundtrips through codec')
    - test('migration is idempotent')
    - test('soft-deleted seekers are skipped')

    运行测试，预期全部 FAIL。

  STEP_0_RED_CMD: "cd xuan-storage/drift && flutter test test/seeker/seeker_migration_test.dart 2>&1 | tail -5"
  STEP_0_RED_EXPECT: "Some tests failed (4 failed)"

  # ── GREEN ──
  STEP_1_GREEN: |
    创建 drift/lib/seeker/seeker_migration.dart：
    - migrateAllSeekers(SeekersDao oldDao, ScopedRecordStore store, SeekerRecordCodec codec)
    - 读取 t_seekers WHERE deletedAt IS NULL
    - 对每条 seeker 调用 codec.encode() → store.saveRecord()
    - 返回迁移计数

  STEP_1_GREEN_CONTENT: |
    import 'package:repository_interface_record/repository_interface_record.dart';
    import '../../daos/seekers_dao.dart';
    import 'seeker_record_codec.dart';

    class SeekerMigration {
      final SeekersDao _oldDao;
      final ScopedRecordStore _store;
      final SeekerRecordCodec _codec;

      SeekerMigration(this._oldDao, this._store, this._codec);

      Future<int> migrateAll() async {
        final seekers = await _oldDao.getAllSeekers();
        final active = seekers.where((s) => s.deletedAt == null).toList();
        for (final s in active) {
          final encoded = _codec.encode(s, scopeUid: _store.scopeUid);
          await _store.saveRecord(encoded.meta, moduleData: encoded.moduleData);
        }
        return active.length;
      }
    }

  STEP_2_GREEN: |
    补全测试中的断言，运行验证。

  STEP_2_GREEN_CMD: "cd xuan-storage/drift && flutter test test/seeker/seeker_migration_test.dart 2>&1"
  STEP_2_GREEN_EXPECT: "All tests passed! (4 tests)"

  # ── REFACTOR ──
  STEP_3_REFACTOR: |
    检查迁移是否应使用 batch 操作提升性能。
    添加迁移进度日志。

PROHIBITED:
  - 删除 t_seekers 中的任何数据
  - 修改 SeekerModel 类

ASSERTIONS:
  CASES:
    - "迁移后 t_record_meta 中 module='seeker' 的行数 = t_seekers 有效行数"
    - "迁移后通过 codec.decode() 还原的 SeekerModel 与原数据一致"
    - "重复迁移不产生重复记录（幂等）"

PROTOCOL:
  MODE: "write-files-only"
  NO_PROSE: true

VERIFICATION: "cd xuan-storage/drift && flutter test test/seeker/seeker_migration_test.dart"
```

---

## S3: 更新 DivinationCase 参与者引用

```yaml
TASK_ID: "seeker-decoupling-s3-case-participants"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    drift/lib/divination_case/case_participants_table.dart 中 seekerUuid 字段
    当前指向 t_seekers.uuid。解耦后应指向 t_record_meta.uuid (module='seeker')。

    drift/lib/divination_case/drift_divination_case_repository.dart 中
    第 165、176 行直接读写 seekerUuid，需要更新读取逻辑：
    - 写：保持不变（seekerUuid 值不变，只是引用的表变了）
    - 读：从 t_record_meta 查询 seeker 详情

  STRATEGY: |
    最小改动：不修改表结构，只改 repository 中的读取路径。
    添加通过 RecordModuleRegistry 查询 seeker 的辅助方法。

TASK_DEPS: ["seeker-decoupling-s1-codec-registry-repo"]

COMMANDS:
  PRECHECK: |
    cd xuan-storage/drift && dart analyze lib/divination_case/ 2>&1

  # ── RED ──
  STEP_0_RED: |
    在现有 case participant 测试中（如存在）添加：
    - test('participant seekerUuid resolves via RecordModuleRegistry')
    或创建 drift/test/seeker/case_participant_seeker_test.dart

  # ── GREEN ──
  STEP_1_GREEN: |
    在 DriftDivinationCaseRepository 中添加私有方法：
    - _resolveSeekerName(String seekerUuid) → 通过 RecordModuleRegistry 查 t_record_meta
    替换第 176 行直接读 SeekerModel 的逻辑。
    注意：此改动不应影响现有 case participant 的读写行为。

  STEP_2_GREEN: |
    运行 divination_case 相关测试确保无回归。

  STEP_2_GREEN_CMD: "cd xuan-storage/drift && flutter test test/divination_case/ 2>&1 || echo '无现有测试，手动验证'"

PROHIBITED:
  - 修改 t_case_participants 表结构
  - 删除 seekerUuid 字段

ASSERTIONS:
  CASES:
    - "case participant 创建/读取不受影响"
    - "seeker 名称解析可通过 record 通道完成"

VERIFICATION: "cd xuan-storage/drift && dart analyze lib/divination_case/"
```

---

## S4: 补充 Seeker 索引查询

```yaml
TASK_ID: "seeker-decoupling-s4-index-queries"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    BaseRecordBackedRepository 已提供 getFirstByIndex / getAllByIndex / watchFirstByIndex。
    但针对 seeker 场景需要补充：
    - 按 username 精确查找
    - 按 gender 过滤
    - 按 lunar_month 过滤

    这些可通过现有的 findByIndex 方法实现（search tag 已包含这些键）。
    本任务主要是为 RecordBackedSeekerRepository 添加便捷方法。

  STRATEGY: |
    在 RecordBackedSeekerRepository 中添加 findByUsername / findByGender / findByLunarMonth。
    编写对应测试。

TASK_DEPS: ["seeker-decoupling-s1-codec-registry-repo"]

COMMANDS:
  PRECHECK: |
    cd xuan-storage/drift && flutter test test/seeker/seeker_record_codec_test.dart 2>&1 | tail -3

  # ── RED ──
  STEP_0_RED: |
    在 seeker_record_codec_test.dart 中添加索引查询测试：
    - test('findByUsername returns matching seeker')
    - test('findByGender filters correctly')
    - test('findByLunarMonth filters correctly')

  # ── GREEN ──
  STEP_1_GREEN: |
    在 RecordBackedSeekerRepository 中添加：
    - Future<List<SeekerModel>> findByUsername(String name)
    - Future<List<SeekerModel>> findByGender(Gender gender)
    - Future<List<SeekerModel>> findByLunarMonth(int month)
    均委托给 getAllByIndex()。

  STEP_2_GREEN_CMD: "cd xuan-storage/drift && flutter test test/seeker/ 2>&1"
  STEP_2_GREEN_EXPECT: "All tests passed!"

PROTOCOL:
  MODE: "write-files-only"
  NO_PROSE: true

VERIFICATION: "cd xuan-storage/drift && flutter test test/seeker/"
```

---

## S5: 标记旧表为 deprecated

```yaml
TASK_ID: "seeker-decoupling-s5-deprecate-old-tables"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    解耦完成后，旧表 t_seekers / t_seeker_divination_mapper 应标记为 deprecated。
    不删除（向后兼容），但在文件头部添加 @Deprecated 注解和迁移指引注释。

  STRATEGY: |
    在 seekers_table.dart / seeker_divination_mappers_table.dart 文件头部添加注释。
    在 SeekersDao / SeekerDivinationMappersDao 类上添加 @Deprecated 注解。
    添加迁移指引：'Migrated to t_record_meta (module='seeker'). See SeekerMigration.'

TASK_DEPS: ["seeker-decoupling-s2-migration"]

COMMANDS:
  STEP_1: |
    修改 drift/lib/tables/seekers_table.dart：
    在 class Seekers extends Table 前添加：
    // @Deprecated: 已迁移至 t_record_meta (module='seeker')。
    // 新代码请使用 RecordBackedSeekerRepository。
    // 迁移工具: drift/lib/seeker/seeker_migration.dart

  STEP_2: |
    修改 drift/lib/daos/seekers_dao.dart：
    在 class SeekersDao 上添加 @Deprecated 注解。

  STEP_3: |
    修改 drift/lib/tables/seeker_divination_mappers_table.dart：
    添加相同的 deprecated 注释。

  STEP_4: |
    修改 drift/lib/daos/seeker_divination_mappers_dao.dart：
    在类上添加 @Deprecated 注解。

  STEP_4_CMD: "cd xuan-storage/drift && dart analyze lib/ 2>&1 | grep -i 'deprecat' | head -10"
  STEP_4_EXPECT: "应无新的 deprecation 相关错误（只有 info/hint）"

PROHIBITED:
  - 删除任何旧表或 DAO 方法
  - 修改旧表结构

ASSERTIONS:
  CASES:
    - "SeekersDao 类带有 @Deprecated 注解"
    - "seekers_table.dart 文件头部有迁移指引注释"

VERIFICATION: "cd xuan-storage/drift && dart analyze lib/"
```

---

## S6: 端到端集成验证

```yaml
TASK_ID: "seeker-decoupling-s6-e2e"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    验证 seeker 全生命周期通过 record 通道：
    创建 → 编码 → 保存 → 索引 → 查询 → 解码 → 软删除 → 验证已删除

  STRATEGY: |
    编写集成测试，使用内存数据库（或 fake ScopedRecordStore），
    覆盖 seeker 的完整 CRUD + 索引查询 + 软删除生命周期。

TASK_DEPS: ["seeker-decoupling-s1-codec-registry-repo", "seeker-decoupling-s4-index-queries"]

COMMANDS:
  PRECHECK: |
    cd xuan-storage/drift && flutter test test/seeker/ 2>&1 | tail -3

  # ── RED ──
  STEP_0_RED: |
    创建 drift/test/seeker/seeker_e2e_test.dart：
    - test('full lifecycle: create → read → update → soft-delete → verify deleted')
    - test('scope isolation: seeker from scope A not visible in scope B')
    - test('concurrent seekers from same scope')

  # ── GREEN ──
  STEP_1_GREEN: |
    实现测试（使用 InMemoryRecordRepository 或轻量 Drift 内存数据库）。
    注意：scope 隔离测试需要两个不同 scopeUid 的 store 实例。

  STEP_1_GREEN_CMD: "cd xuan-storage/drift && flutter test test/seeker/seeker_e2e_test.dart 2>&1"
  STEP_1_GREEN_EXPECT: "All tests passed! (3 tests)"

  # ── REFACTOR ──
  STEP_2_REFACTOR: |
    检查测试是否有重复的 setup 代码，提取共享 fixture。

PROTOCOL:
  MODE: "write-files-only"
  NO_PROSE: true

VERIFICATION: "cd xuan-storage/drift && flutter test test/seeker/"
```

---

## S7: 清理旧 DAO 中的 divinationUuid 直接引用

```yaml
TASK_ID: "seeker-decoupling-s7-cleanup-divination-refs"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    t_divinations 表中有 ownerSeekerUuid / seekerName 字段。
    SeekersDao 中有 getSeekersByDivinationUuid() 方法。
    解耦后这些直接引用应通过 t_record_meta (module='seeker') 间接解析。

    清理策略：
    - 不删除字段（向后兼容），但标记 deprecated
    - getSeekersByDivinationUuid() 标记 deprecated，引导使用 RecordModuleRegistry

  STRATEGY: |
    添加 deprecated 注解，不修改现有调用方（由后续 Fork/Merge 任务处理）。

TASK_DEPS: ["seeker-decoupling-s5-deprecate-old-tables"]

COMMANDS:
  STEP_1: |
    在 SeekersDao.getSeekersByDivinationUuid() 上添加 @Deprecated 注解。

  STEP_2: |
    在 divinations_table.dart 的 ownerSeekerUuid / seekerName 字段上添加注释：
    // @Deprecated: use t_record_meta (module='seeker') for seeker resolution

  STEP_3: |
    dart analyze 确认无新增错误。

  STEP_3_CMD: "cd xuan-storage/drift && dart analyze lib/ 2>&1"

PROHIBITED:
  - 删除任何字段或方法
  - 修改调用方代码

ASSERTIONS:
  CASES:
    - "getSeekersByDivinationUuid 带 @Deprecated 注解"
    - "ownerSeekerUuid 字段有迁移指引注释"

VERIFICATION: "cd xuan-storage/drift && dart analyze lib/"
```

---

## 实现顺序依赖声明

```
S0 (影响分析)
 └─ S1 (codec + registry + repo)
     ├─ S2 (数据迁移) ── S5 (标记 deprecated) ── S7 (清理 divination 引用)
     ├─ S3 (case participants)
     └─ S4 (索引查询) ── S6 (E2E 验证)

全部 S0–S7 完成后，Fork/Merge 推断（F0–F8）才能开始（依赖 Seeker 解耦完毕）。
Fork/Merge 完成后，云同步（C0–C7）才能开始（依赖统一记录系统完整）。
```

---

## Git 提交粒度

| 提交 | 内容 | 关联任务 |
|------|------|----------|
| `git commit -m "docs: S0 seeker impact analysis report"` | 影响报告 | S0 |
| `git commit -m "test: S1 RED failing seeker codec tests"` | 失败测试 | S1-RED |
| `git commit -m "feat: S1 GREEN seeker codec + registry + repository"` | codec/registry/repo | S1-GREEN |
| `git commit -m "refactor: S1 refactor seeker codec"` | 重构 | S1-REFACTOR |
| `git commit -m "feat: S2 seeker data migration"` | 迁移 | S2 |
| `git commit -m "feat: S3 case participant seeker resolution"` | 参与者引用 | S3 |
| `git commit -m "feat: S4 seeker index queries"` | 索引查询 | S4 |
| `git commit -m "chore: S5 deprecate old seeker tables"` | deprecated | S5 |
| `git commit -m "test: S6 seeker E2E integration tests"` | E2E 测试 | S6 |
| `git commit -m "chore: S7 deprecate divinationUuid refs"` | 清理引用 | S7 |
