# ACT 批量接入计划 — 6 模块统一记录存储

> **日期**: 2026-06-28
> **前置条件**: ACT-1 到 ACT-7 已完成（梅花 + 六爻已接入）
> **目标**: 将剩余 6 个模块接入统一记录存储系统
> **执行顺序**: ACT-8 → ACT-9 → ACT-10 → ACT-11 → ACT-12 → ACT-13

---

## 总览

| ACT | 模块 | 需新建 Contract | 需新建 RecordRepository Port | 需新建 Codec | 需新建 Repository | 工作量 |
|-----|------|----------------|----------------------------|-------------|-------------------|--------|
| ACT-8 | 七政四余 | ❌ 已有 QiZhengSiYuPanContract | ⚠️ 需适配 | ✅ ~80行 | ✅ ~30行 | M |
| ACT-9 | 大六壬 | ✅ 需新建 DaliurenDivinationRecord | ✅ 需新建 | ✅ ~80行 | ✅ ~30行 | L |
| ACT-10 | 奇门遁甲 | ✅ 需新建 QimenDivinationRecord | ✅ 需新建 | ✅ ~80行 | ✅ ~30行 | L |
| ACT-11 | 太乙神数 | ✅ 需新建 TaiyiDivinationRecord | ✅ 需新建 | ✅ ~80行 | ✅ ~30行 | L |
| ACT-12 | 铁板神数 | ✅ 需新建 TiebanDivinationRecord | ✅ 需新建 | ✅ ~80行 | ✅ ~30行 | L |
| ACT-13 | 紫微斗数 | ✅ 需新建 ZiweiDivinationRecord | ✅ 需新建 | ✅ ~80行 | ✅ ~30行 | L |

---

## ACT-8: 七政四余接入

```yaml
TASK_ID: "record-onboard-qizhengsiyu"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    七政四余已有 QiZhengSiYuPanContract（盘面保存记录），字段：
    uuid, createdAt, lastUpdatedAt, deletedAt, divinationRequestInfoUuid,
    divinationDatetimeJson, panelConfigJson, panelModelJson

    已有 IQiZhengSiYuPanRepository（完整 CRUD 接口）。

    但现有接口方法签名与统一 RecordRepository 不同，需要适配。

  STRATEGY: |
    1. 在 xuan-storage/drift/pubspec.yaml 添加依赖
    2. 在 repository-interface-qizhengsiyu 中添加 RecordRepository port
    3. 在 xuan-storage/drift/lib/qizhengsiyu/ 创建 codec + repository
    4. 验证

TASK_DEPS: ["typed-record-phase3-base-and-meihua"]

COMMANDS:
  PRECHECK: |
    dart analyze repository-interface-qizhengsiyu/lib/ 2>/dev/null || true

  STEP_0: |
    在 xuan-storage/drift/pubspec.yaml 中添加 repository_interface_qizhengsiyu 依赖。

  STEP_0_CONTENT: |
    repository_interface_qizhengsiyu:
      path: ../../repository-interface-qizhengsiyu

  STEP_1: |
    在 repository-interface-qizhengsiyu 中添加 QiZhengRecordRepository 端口。
    位置: repository-interface-qizhengsiyu/lib/src/repositories/qizheng_record_repository.dart
    方法签名对齐统一 RecordRepository（saveRecord/getAllRecords/getRecordByUuid/softDeleteRecord）。
    注意：保留 IQiZhengSiYuPanRepository 不变（向后兼容），新端口独立存在。

  STEP_1_CONTENT: |
    import '../contracts/qizhengsiyu_pan_contract.dart';

    /// 七政四余排盘记录仓储（统一记录存储接口）。
    abstract interface class QiZhengRecordRepository {
      Future<String> saveRecord(QiZhengSiYuPanContract record);
      Future<List<QiZhengSiYuPanContract>> getAllRecords();
      Future<QiZhengSiYuPanContract?> getRecordByUuid(String uuid);
      Future<bool> softDeleteRecord(String uuid);
      Stream<List<QiZhengSiYuPanContract>> watchAllRecords();
    }

  STEP_2: |
    更新 barrel 文件，导出 QiZhengRecordRepository。

  STEP_3: |
    创建 QiZhengRecordCodec。
    位置: xuan-storage/drift/lib/qizhengsiyu/qizheng_record_codec.dart
    实现 RecordModuleCodec<QiZhengSiYuPanContract>。
    module = 'qizhengsiyu', category = 'divination', divinationType = 'qi_zheng'
    encode: 将 panelConfigJson/panelModelJson/divinationDatetimeJson 序列化到 moduleDataJson
    decode: 从 moduleDataJson 反序列化
    extractSearchTags: divination_request_info_uuid, divination_datetime

  STEP_3_CONTENT: |
    import 'dart:convert';
    import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
    import 'package:repository_interface_record/repository_interface_record.dart';

    class QiZhengRecordCodec implements RecordModuleCodec<QiZhengSiYuPanContract> {
      @override String get module => 'qizhengsiyu';
      @override String get category => 'divination';
      @override String get divinationType => 'qi_zheng';

      @override String uuidOf(QiZhengSiYuPanContract c) => c.uuid;

      @override
      QiZhengSiYuPanContract withUuid(QiZhengSiYuPanContract c, String uuid) {
        return QiZhengSiYuPanContract(
          uuid: uuid,
          createdAt: c.createdAt,
          lastUpdatedAt: c.lastUpdatedAt,
          deletedAt: c.deletedAt,
          divinationRequestInfoUuid: c.divinationRequestInfoUuid,
          divinationDatetimeJson: c.divinationDatetimeJson,
          panelConfigJson: c.panelConfigJson,
          panelModelJson: c.panelModelJson,
        );
      }

      @override
      EncodedRecord encode(QiZhengSiYuPanContract c, {required String scopeUid}) {
        final data = <String, dynamic>{
          'divinationRequestInfoUuid': c.divinationRequestInfoUuid,
          'divinationDatetimeJson': c.divinationDatetimeJson,
          'panelConfigJson': c.panelConfigJson,
          'panelModelJson': c.panelModelJson,
        };
        final meta = RecordMeta(
          uuid: c.uuid, scopeUid: scopeUid, module: module, category: category,
          divinationType: divinationType,
          moduleDataJson: jsonEncode(data),
          navParamsJson: jsonEncode({'recordUuid': c.uuid}),
          createdAt: c.createdAt, updatedAt: c.lastUpdatedAt,
          deletedAt: c.deletedAt, rev: 1,
        );
        return (meta: meta, moduleData: data);
      }

      @override
      QiZhengSiYuPanContract decode(RecordMeta meta, Map<String, dynamic>? moduleData) {
        if (meta.module != module) throw RecordCodecMismatch(message: 'module mismatch');
        final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
        return QiZhengSiYuPanContract(
          uuid: meta.uuid, createdAt: meta.createdAt,
          lastUpdatedAt: meta.updatedAt ?? meta.createdAt,
          deletedAt: meta.deletedAt,
          divinationRequestInfoUuid: d['divinationRequestInfoUuid'],
          divinationDatetimeJson: d['divinationDatetimeJson'],
          panelConfigJson: d['panelConfigJson'],
          panelModelJson: d['panelModelJson'],
        );
      }

      @override
      List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? moduleData) {
        final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
        final tags = <SearchTag>[];
        final requestUuid = d['divinationRequestInfoUuid'];
        if (requestUuid != null && '$requestUuid'.isNotEmpty) {
          tags.add(SearchTag('divination_request_info_uuid', '$requestUuid'));
        }
        return tags;
      }
    }

  STEP_4: |
    创建 RecordBackedQiZhengRepository。
    位置: xuan-storage/drift/lib/qizhengsiyu/record_backed_qizheng_repository.dart
    继承 BaseRecordBackedRepository<QiZhengSiYuPanContract>。
    实现 QiZhengRecordRepository。
    方法体均为一行委托。

  STEP_4_CONTENT: |
    import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
    import '../record/base_record_backed_repository.dart';
    import 'qizheng_record_codec.dart';

    class RecordBackedQiZhengRepository
        extends BaseRecordBackedRepository<QiZhengSiYuPanContract>
        implements QiZhengRecordRepository {

      RecordBackedQiZhengRepository({
        required super.store,
        required super.codec,
        super.uuid,
      });

      @override Future<String> saveRecord(QiZhengSiYuPanContract r) => save(r);
      @override Future<List<QiZhengSiYuPanContract>> getAllRecords() => getAll();
      @override Stream<List<QiZhengSiYuPanContract>> watchAllRecords() => watchAll();
      @override Future<QiZhengSiYuPanContract?> getRecordByUuid(String u) => getByUuid(u);
      @override Future<bool> softDeleteRecord(String u) => softDelete(u);
    }

  STEP_5: |
    运行 dart analyze 和 flutter test 验证。

PROHIBITED:
  - 修改 IQiZhengSiYuPanRepository 现有接口
  - 修改 QiZhengSiYuPanContract 现有字段
  - 创建独立的 LocalRecordRepository 实例

ASSERTIONS:
  EXECENV: "dart analyze 零错误，flutter test 全部通过"
  CASES:
    - "QiZhengRecordCodec 往返 encode→decode 保真"
    - "RecordBackedQiZhengRepository 满足 QiZhengRecordRepository 契约"

VERIFICATION: "dart analyze && flutter test"
```

---

## ACT-9: 大六壬接入

```yaml
TASK_ID: "record-onboard-daliuren"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    大六壬当前无排盘记录保存接口。所有 repository 都是 assets-backed 只读数据加载。

    需要新建：
    - DaliurenDivinationRecord contract（排盘结果）
    - DaliurenRecordRepository port
    - DaliurenRecordCodec
    - RecordBackedDaliurenRepository

  STRATEGY: |
    1. 在 xuan-storage/drift/pubspec.yaml 添加依赖
    2. 在 repository-interface-daliuren 中新建 contract + port
    3. 在 xuan-storage/drift/lib/daliuren/ 创建 codec + repository
    4. 验证

TASK_DEPS: ["typed-record-phase3-base-and-meihua"]

COMMANDS:
  PRECHECK: |
    dart analyze repository-interface-daliuren/lib/ 2>/dev/null || true

  STEP_0: |
    在 xuan-storage/drift/pubspec.yaml 中添加 repository_interface_daliuren 依赖。

  STEP_0_CONTENT: |
    repository_interface_daliuren:
      path: ../../repository-interface-daliuren

  STEP_1: |
    创建 DaliurenDivinationRecordContract。
    位置: repository-interface-daliuren/lib/src/contracts/daliuren_divination_record_contract.dart
    字段设计（基于大六壬排盘核心数据）：
    - uuid: String
    - question: String?（占测问题）
    - lunarDateJson: String?（农历日期 JSON）
    - ganzhiJson: String?（干支 JSON）
    - juNumber: int?（课局编号）
    - juName: String?（课局名称）
    - schoolId: String?（流派 ID）
    - yueJiangJson: String?（月将 JSON）
    - riYueJson: String?（日月 JSON）
    - sanChuanJson: String?（三传 JSON）
    - siKeJson: String?（四课 JSON）
    - twelveTianJinJson: String?（十二天将 JSON）
    - paramsJson: String?（其他参数）
    - createdAt: DateTime
    - updatedAt: DateTime?
    - deletedAt: DateTime?

  STEP_1_CONTENT: |
    import 'package:equatable/equatable.dart';

    final class DaliurenDivinationRecordContract extends Equatable {
      const DaliurenDivinationRecordContract({
        required this.uuid,
        this.question,
        this.lunarDateJson,
        this.ganzhiJson,
        this.juNumber,
        this.juName,
        this.schoolId,
        this.yueJiangJson,
        this.riYueJson,
        this.sanChuanJson,
        this.siKeJson,
        this.twelveTianJinJson,
        this.paramsJson,
        required this.createdAt,
        this.updatedAt,
        this.deletedAt,
      });

      final String uuid;
      final String? question;
      final String? lunarDateJson;
      final String? ganzhiJson;
      final int? juNumber;
      final String? juName;
      final String? schoolId;
      final String? yueJiangJson;
      final String? riYueJson;
      final String? sanChuanJson;
      final String? siKeJson;
      final String? twelveTianJinJson;
      final String? paramsJson;
      final DateTime createdAt;
      final DateTime? updatedAt;
      final DateTime? deletedAt;

      @override
      List<Object?> get props => [uuid, question, createdAt];
    }

  STEP_2: |
    创建 DaliurenRecordRepository port。
    位置: repository-interface-daliuren/lib/src/repositories/daliuren_record_repository.dart

  STEP_2_CONTENT: |
    import '../contracts/daliuren_divination_record_contract.dart';

    abstract interface class DaliurenRecordRepository {
      Future<String> saveRecord(DaliurenDivinationRecordContract record);
      Future<List<DaliurenDivinationRecordContract>> getAllRecords();
      Future<DaliurenDivinationRecordContract?> getRecordByUuid(String uuid);
      Future<bool> softDeleteRecord(String uuid);
      Stream<List<DaliurenDivinationRecordContract>> watchAllRecords();
    }

  STEP_3: |
    更新 barrel 文件，导出新 contract 和 port。

  STEP_4: |
    创建 DaliurenRecordCodec。
    位置: xuan-storage/drift/lib/daliuren/daliuren_record_codec.dart
    module = 'daliuren', category = 'divination', divinationType = 'da_liu_ren'
    encode: 将所有 JSON 字段序列化到 moduleDataJson
    extractSearchTags: school_id, ju_name

  STEP_5: |
    创建 RecordBackedDaliurenRepository。
    位置: xuan-storage/drift/lib/daliuren/record_backed_daliuren_repository.dart
    继承 BaseRecordBackedRepository<DaliurenDivinationRecordContract>。
    实现 DaliurenRecordRepository。

  STEP_6: |
    运行 dart analyze 和 flutter test 验证。

PROHIBITED:
  - 修改 DaLiuRenSchoolDataRepository 等现有只读接口
  - 创建独立的 LocalRecordRepository 实例

ASSERTIONS:
  EXECENV: "dart analyze 零错误，flutter test 全部通过"

VERIFICATION: "dart analyze && flutter test"
```

---

## ACT-10: 奇门遁甲接入

```yaml
TASK_ID: "record-onboard-qimendunjia"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    奇门遁甲当前无排盘记录保存接口。QimendunjiaOfficialRuleRepository 是只读规则加载。
    contracts/ 目录不存在，需新建。

    需要新建：
    - QimenDivinationRecord contract
    - QimenRecordRepository port
    - QimenRecordCodec
    - RecordBackedQimenRepository

  STRATEGY: |
    1. 在 xuan-storage/drift/pubspec.yaml 添加依赖
    2. 创建 contracts/ 目录和 contract + port
    3. 创建 codec + repository
    4. 验证

TASK_DEPS: ["typed-record-phase3-base-and-meihua"]

COMMANDS:
  PRECHECK: |
    dart analyze repository-interface-qimendunjia/lib/ 2>/dev/null || true

  STEP_0: |
    在 xuan-storage/drift/pubspec.yaml 中添加 repository_interface_qimendunjia 依赖。

  STEP_0_CONTENT: |
    repository_interface_qimendunjia:
      path: ../../repository-interface-qimendunjia

  STEP_1: |
    创建 contracts/ 目录（如不存在）和 QimenDivinationRecordContract。
    位置: repository-interface-qimendunjia/lib/src/contracts/qimen_divination_record_contract.dart

  STEP_1_CONTENT: |
    import 'package:equatable/equatable.dart';

    final class QimenDivinationRecordContract extends Equatable {
      const QimenDivinationRecordContract({
        required this.uuid,
        this.question,
        this.datetimeJson,
        this.juType,
        this.juNumber,
        this.paiPanJson,
        this.shiJiJson,
        this.yueJiangJson,
        this.paramsJson,
        required this.createdAt,
        this.updatedAt,
        this.deletedAt,
      });

      final String uuid;
      final String? question;
      final String? datetimeJson;
      final String? juType;
      final int? juNumber;
      final String? paiPanJson;
      final String? shiJiJson;
      final String? yueJiangJson;
      final String? paramsJson;
      final DateTime createdAt;
      final DateTime? updatedAt;
      final DateTime? deletedAt;

      @override
      List<Object?> get props => [uuid, question, createdAt];
    }

  STEP_2: |
    创建 QimenRecordRepository port。
    位置: repository-interface-qimendunjia/lib/src/repositories/qimen_record_repository.dart

  STEP_2_CONTENT: |
    import '../contracts/qimen_divination_record_contract.dart';

    abstract interface class QimenRecordRepository {
      Future<String> saveRecord(QimenDivinationRecordContract record);
      Future<List<QimenDivinationRecordContract>> getAllRecords();
      Future<QimenDivinationRecordContract?> getRecordByUuid(String uuid);
      Future<bool> softDeleteRecord(String uuid);
      Stream<List<QimenDivinationRecordContract>> watchAllRecords();
    }

  STEP_3: |
    更新 barrel 文件，导出新 contract 和 port。

  STEP_4: |
    创建 xuan-storage/drift/lib/qimendunjia/ 目录（如不存在）。
    创建 QimenRecordCodec。
    位置: xuan-storage/drift/lib/qimendunjia/qimen_record_codec.dart

  STEP_4_CONTENT: |
    import 'dart:convert';
    import 'package:repository_interface_qimendunjia/repository_interface_qimendunjia.dart';
    import 'package:repository_interface_record/repository_interface_record.dart';

    class QimenRecordCodec implements RecordModuleCodec<QimenDivinationRecordContract> {
      @override String get module => 'qimendunjia';
      @override String get category => 'divination';
      @override String get divinationType => 'qi_men';

      @override String uuidOf(QimenDivinationRecordContract c) => c.uuid;

      @override
      QimenDivinationRecordContract withUuid(QimenDivinationRecordContract c, String uuid) {
        return QimenDivinationRecordContract(
          uuid: uuid, question: c.question, datetimeJson: c.datetimeJson,
          juType: c.juType, juNumber: c.juNumber, paiPanJson: c.paiPanJson,
          shiJiJson: c.shiJiJson, yueJiangJson: c.yueJiangJson,
          paramsJson: c.paramsJson, createdAt: c.createdAt,
          updatedAt: c.updatedAt, deletedAt: c.deletedAt,
        );
      }

      @override
      EncodedRecord encode(QimenDivinationRecordContract c, {required String scopeUid}) {
        final data = <String, dynamic>{
          'datetimeJson': c.datetimeJson, 'juType': c.juType,
          'juNumber': c.juNumber, 'paiPanJson': c.paiPanJson,
          'shiJiJson': c.shiJiJson, 'yueJiangJson': c.yueJiangJson,
          'paramsJson': c.paramsJson,
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
      QimenDivinationRecordContract decode(RecordMeta meta, Map<String, dynamic>? moduleData) {
        if (meta.module != module) throw RecordCodecMismatch(message: 'module mismatch');
        final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
        return QimenDivinationRecordContract(
          uuid: meta.uuid, question: meta.question, datetimeJson: d['datetimeJson'],
          juType: d['juType'], juNumber: d['juNumber'], paiPanJson: d['paiPanJson'],
          shiJiJson: d['shiJiJson'], yueJiangJson: d['yueJiangJson'],
          paramsJson: d['paramsJson'], createdAt: meta.createdAt,
          updatedAt: meta.updatedAt ?? meta.createdAt, deletedAt: meta.deletedAt,
        );
      }

      @override
      List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? moduleData) {
        final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
        final tags = <SearchTag>[];
        if (d['juType'] != null) tags.add(SearchTag('ju_type', '${d['juType']}'));
        if (d['juNumber'] != null) tags.add(SearchTag('ju_number', '${d['juNumber']}'));
        return tags;
      }
    }

  STEP_5: |
    创建 RecordBackedQimenRepository。
    位置: xuan-storage/drift/lib/qimendunjia/record_backed_qimen_repository.dart

  STEP_5_CONTENT: |
    import 'package:repository_interface_qimendunjia/repository_interface_qimendunjia.dart';
    import '../record/base_record_backed_repository.dart';
    import 'qimen_record_codec.dart';

    class RecordBackedQimenRepository
        extends BaseRecordBackedRepository<QimenDivinationRecordContract>
        implements QimenRecordRepository {

      RecordBackedQimenRepository({
        required super.store,
        required super.codec,
        super.uuid,
      });

      @override Future<String> saveRecord(QimenDivinationRecordContract r) => save(r);
      @override Future<List<QimenDivinationRecordContract>> getAllRecords() => getAll();
      @override Stream<List<QimenDivinationRecordContract>> watchAllRecords() => watchAll();
      @override Future<QimenDivinationRecordContract?> getRecordByUuid(String u) => getByUuid(u);
      @override Future<bool> softDeleteRecord(String u) => softDelete(u);
    }

  STEP_6: |
    运行 dart analyze 和 flutter test 验证。

PROHIBITED:
  - 修改 QimendunjiaOfficialRuleRepository
  - 创建独立的 LocalRecordRepository 实例

ASSERTIONS:
  EXECENV: "dart analyze 零错误，flutter test 全部通过"
  CASES:
    - "QimenRecordCodec 往返 encode→decode 保真"
    - "RecordBackedQimenRepository 满足 QimenRecordRepository 契约"
    - "梅花写记录 → 奇门查不到 (module 隔离)"

VERIFICATION: "dart analyze && flutter test"
```

---

## ACT-11: 太乙神数接入

```yaml
TASK_ID: "record-onboard-taiyishenshu"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    太乙神数当前无排盘记录保存接口。所有 contract 都是配置/计算结果类。
    太乙已有 drift 实现（taiyi_database.dart），但那是用户/配置存储，不是排盘记录。
    repository_interface_taiyishenshu 已是 xuan-storage/drift 的依赖。

    需要新建：
    - TaiyiDivinationRecord contract
    - TaiyiRecordRepository port
    - TaiyiRecordCodec
    - RecordBackedTaiyiRepository

  STRATEGY: |
    1. 创建 contract + port
    2. 创建 codec + repository
    3. 验证

TASK_DEPS: ["typed-record-phase3-base-and-meihua"]

COMMANDS:
  PRECHECK: |
    dart analyze repository-interface-taiyishenshu/lib/ 2>/dev/null || true

  STEP_1: |
    创建 TaiyiDivinationRecordContract。
    位置: repository-interface-taiyishenshu/lib/src/contracts/taiyi_divination_record_contract.dart

  STEP_1_CONTENT: |
    import 'package:equatable/equatable.dart';

    final class TaiyiDivinationRecordContract extends Equatable {
      const TaiyiDivinationRecordContract({
        required this.uuid,
        this.question,
        this.datetimeJson,
        this.schoolId,
        this.juNumber,
        this.taiYiPalaceJson,
        this.ninePalaceJson,
        this.deitiesJson,
        this.paramsJson,
        required this.createdAt,
        this.updatedAt,
        this.deletedAt,
      });

      final String uuid;
      final String? question;
      final String? datetimeJson;
      final String? schoolId;
      final int? juNumber;
      final String? taiYiPalaceJson;
      final String? ninePalaceJson;
      final String? deitiesJson;
      final String? paramsJson;
      final DateTime createdAt;
      final DateTime? updatedAt;
      final DateTime? deletedAt;

      @override
      List<Object?> get props => [uuid, question, createdAt];
    }

  STEP_2: |
    创建 TaiyiRecordRepository port。
    位置: repository-interface-taiyishenshu/lib/src/repositories/taiyi_record_repository.dart

  STEP_2_CONTENT: |
    import '../contracts/taiyi_divination_record_contract.dart';

    abstract interface class TaiyiRecordRepository {
      Future<String> saveRecord(TaiyiDivinationRecordContract record);
      Future<List<TaiyiDivinationRecordContract>> getAllRecords();
      Future<TaiyiDivinationRecordContract?> getRecordByUuid(String uuid);
      Future<bool> softDeleteRecord(String uuid);
      Stream<List<TaiyiDivinationRecordContract>> watchAllRecords();
    }

  STEP_3: |
    更新 barrel 文件，导出新 contract 和 port。

  STEP_4: |
    创建 xuan-storage/drift/lib/taiyishenshu/taiyi_record_codec.dart

  STEP_4_CONTENT: |
    import 'dart:convert';
    import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
    import 'package:repository_interface_record/repository_interface_record.dart';

    class TaiyiRecordCodec implements RecordModuleCodec<TaiyiDivinationRecordContract> {
      @override String get module => 'taiyishenshu';
      @override String get category => 'divination';
      @override String get divinationType => 'tai_yi';

      @override String uuidOf(TaiyiDivinationRecordContract c) => c.uuid;

      @override
      TaiyiDivinationRecordContract withUuid(TaiyiDivinationRecordContract c, String uuid) {
        return TaiyiDivinationRecordContract(
          uuid: uuid, question: c.question, datetimeJson: c.datetimeJson,
          schoolId: c.schoolId, juNumber: c.juNumber,
          taiYiPalaceJson: c.taiYiPalaceJson, ninePalaceJson: c.ninePalaceJson,
          deitiesJson: c.deitiesJson, paramsJson: c.paramsJson,
          createdAt: c.createdAt, updatedAt: c.updatedAt, deletedAt: c.deletedAt,
        );
      }

      @override
      EncodedRecord encode(TaiyiDivinationRecordContract c, {required String scopeUid}) {
        final data = <String, dynamic>{
          'datetimeJson': c.datetimeJson, 'schoolId': c.schoolId,
          'juNumber': c.juNumber, 'taiYiPalaceJson': c.taiYiPalaceJson,
          'ninePalaceJson': c.ninePalaceJson, 'deitiesJson': c.deitiesJson,
          'paramsJson': c.paramsJson,
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
      TaiyiDivinationRecordContract decode(RecordMeta meta, Map<String, dynamic>? moduleData) {
        if (meta.module != module) throw RecordCodecMismatch(message: 'module mismatch');
        final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
        return TaiyiDivinationRecordContract(
          uuid: meta.uuid, question: meta.question, datetimeJson: d['datetimeJson'],
          schoolId: d['schoolId'], juNumber: d['juNumber'],
          taiYiPalaceJson: d['taiYiPalaceJson'], ninePalaceJson: d['ninePalaceJson'],
          deitiesJson: d['deitiesJson'], paramsJson: d['paramsJson'],
          createdAt: meta.createdAt, updatedAt: meta.updatedAt ?? meta.createdAt,
          deletedAt: meta.deletedAt,
        );
      }

      @override
      List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? moduleData) {
        final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
        final tags = <SearchTag>[];
        if (d['schoolId'] != null) tags.add(SearchTag('school_id', '${d['schoolId']}'));
        return tags;
      }
    }

  STEP_5: |
    创建 RecordBackedTaiyiRepository。
    位置: xuan-storage/drift/lib/taiyishenshu/record_backed_taiyi_repository.dart

  STEP_5_CONTENT: |
    import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
    import '../record/base_record_backed_repository.dart';
    import 'taiyi_record_codec.dart';

    class RecordBackedTaiyiRepository
        extends BaseRecordBackedRepository<TaiyiDivinationRecordContract>
        implements TaiyiRecordRepository {

      RecordBackedTaiyiRepository({
        required super.store,
        required super.codec,
        super.uuid,
      });

      @override Future<String> saveRecord(TaiyiDivinationRecordContract r) => save(r);
      @override Future<List<TaiyiDivinationRecordContract>> getAllRecords() => getAll();
      @override Stream<List<TaiyiDivinationRecordContract>> watchAllRecords() => watchAll();
      @override Future<TaiyiDivinationRecordContract?> getRecordByUuid(String u) => getByUuid(u);
      @override Future<bool> softDeleteRecord(String u) => softDelete(u);
    }

  STEP_6: |
    运行 dart analyze 和 flutter test 验证。

PROHIBITED:
  - 修改 SchoolRepository/MingGuaRepository/DestinyRepository 等现有接口
  - 修改 TaiyiDatabase 相关代码
  - 创建独立的 LocalRecordRepository 实例

ASSERTIONS:
  EXECENV: "dart analyze 零错误，flutter test 全部通过"
  CASES:
    - "TaiyiRecordCodec 往返 encode→decode 保真"
    - "RecordBackedTaiyiRepository 满足 TaiyiRecordRepository 契约"

VERIFICATION: "dart analyze && flutter test"
```

---

## ACT-12: 铁板神数接入

```yaml
TASK_ID: "record-onboard-tiebanshenshu"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    铁板神数当前无排盘记录保存接口。TiaoWenDataModel 是条文参考数据。
    contracts/ 目录已存在（有 tiao_wen_data_model.dart）。
    特殊注意：TiaoWenDataModel 依赖 metaphysics_core/enums.dart（DiZhi 枚举），
    新 contract 不应重复此错误。

    需要新建：
    - TiebanDivinationRecord contract
    - TiebanRecordRepository port
    - TiebanRecordCodec
    - RecordBackedTiebanRepository

  STRATEGY: |
    1. 在 xuan-storage/drift/pubspec.yaml 添加依赖
    2. 创建 contract + port
    3. 创建 codec + repository
    4. 验证

TASK_DEPS: ["typed-record-phase3-base-and-meihua"]

COMMANDS:
  PRECHECK: |
    dart analyze repository-interface-tiebanshenshu/lib/ 2>/dev/null || true

  STEP_0: |
    在 xuan-storage/drift/pubspec.yaml 中添加 repository_interface_tiebanshenshu 依赖。

  STEP_0_CONTENT: |
    repository_interface_tiebanshenshu:
      path: ../../repository-interface-tiebanshenshu

  STEP_1: |
    创建 TiebanDivinationRecordContract。
    位置: repository-interface-tiebanshenshu/lib/src/contracts/tieban_divination_record_contract.dart
    注意：不使用 DiZhi 枚举，所有干支数据用 JSON 字符串存储。

  STEP_1_CONTENT: |
    import 'package:equatable/equatable.dart';

    final class TiebanDivinationRecordContract extends Equatable {
      const TiebanDivinationRecordContract({
        required this.uuid,
        this.question,
        this.birthDatetimeJson,
        this.birthGanZhiJson,
        this.calculationResultJson,
        this.matchedTiaoWenIdsJson,
        this.paramsJson,
        required this.createdAt,
        this.updatedAt,
        this.deletedAt,
      });

      final String uuid;
      final String? question;
      final String? birthDatetimeJson;
      final String? birthGanZhiJson;
      final String? calculationResultJson;
      final String? matchedTiaoWenIdsJson;
      final String? paramsJson;
      final DateTime createdAt;
      final DateTime? updatedAt;
      final DateTime? deletedAt;

      @override
      List<Object?> get props => [uuid, question, createdAt];
    }

  STEP_2: |
    创建 TiebanRecordRepository port。
    位置: repository-interface-tiebanshenshu/lib/src/repositories/tieban_record_repository.dart

  STEP_2_CONTENT: |
    import '../contracts/tieban_divination_record_contract.dart';

    abstract interface class TiebanRecordRepository {
      Future<String> saveRecord(TiebanDivinationRecordContract record);
      Future<List<TiebanDivinationRecordContract>> getAllRecords();
      Future<TiebanDivinationRecordContract?> getRecordByUuid(String uuid);
      Future<bool> softDeleteRecord(String uuid);
      Stream<List<TiebanDivinationRecordContract>> watchAllRecords();
    }

  STEP_3: |
    更新 barrel 文件，导出新 contract 和 port。

  STEP_4: |
    创建 xuan-storage/drift/lib/tiebanshenshu/ 目录（如不存在）。
    创建 TiebanRecordCodec。
    位置: xuan-storage/drift/lib/tiebanshenshu/tieban_record_codec.dart

  STEP_4_CONTENT: |
    import 'dart:convert';
    import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';
    import 'package:repository_interface_record/repository_interface_record.dart';

    class TiebanRecordCodec implements RecordModuleCodec<TiebanDivinationRecordContract> {
      @override String get module => 'tiebanshenshu';
      @override String get category => 'divination';
      @override String get divinationType => 'tie_ban';

      @override String uuidOf(TiebanDivinationRecordContract c) => c.uuid;

      @override
      TiebanDivinationRecordContract withUuid(TiebanDivinationRecordContract c, String uuid) {
        return TiebanDivinationRecordContract(
          uuid: uuid, question: c.question, birthDatetimeJson: c.birthDatetimeJson,
          birthGanZhiJson: c.birthGanZhiJson, calculationResultJson: c.calculationResultJson,
          matchedTiaoWenIdsJson: c.matchedTiaoWenIdsJson, paramsJson: c.paramsJson,
          createdAt: c.createdAt, updatedAt: c.updatedAt, deletedAt: c.deletedAt,
        );
      }

      @override
      EncodedRecord encode(TiebanDivinationRecordContract c, {required String scopeUid}) {
        final data = <String, dynamic>{
          'birthDatetimeJson': c.birthDatetimeJson, 'birthGanZhiJson': c.birthGanZhiJson,
          'calculationResultJson': c.calculationResultJson,
          'matchedTiaoWenIdsJson': c.matchedTiaoWenIdsJson,
          'paramsJson': c.paramsJson,
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
      TiebanDivinationRecordContract decode(RecordMeta meta, Map<String, dynamic>? moduleData) {
        if (meta.module != module) throw RecordCodecMismatch(message: 'module mismatch');
        final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
        return TiebanDivinationRecordContract(
          uuid: meta.uuid, question: meta.question,
          birthDatetimeJson: d['birthDatetimeJson'], birthGanZhiJson: d['birthGanZhiJson'],
          calculationResultJson: d['calculationResultJson'],
          matchedTiaoWenIdsJson: d['matchedTiaoWenIdsJson'],
          paramsJson: d['paramsJson'], createdAt: meta.createdAt,
          updatedAt: meta.updatedAt ?? meta.createdAt, deletedAt: meta.deletedAt,
        );
      }

      @override
      List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? moduleData) {
        final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
        final tags = <SearchTag>[];
        if (d['birthGanZhiJson'] != null) tags.add(SearchTag('birth_gan_zhi', '${d['birthGanZhiJson']}'));
        return tags;
      }
    }

  STEP_5: |
    创建 RecordBackedTiebanRepository。
    位置: xuan-storage/drift/lib/tiebanshenshu/record_backed_tieban_repository.dart

  STEP_5_CONTENT: |
    import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';
    import '../record/base_record_backed_repository.dart';
    import 'tieban_record_codec.dart';

    class RecordBackedTiebanRepository
        extends BaseRecordBackedRepository<TiebanDivinationRecordContract>
        implements TiebanRecordRepository {

      RecordBackedTiebanRepository({
        required super.store,
        required super.codec,
        super.uuid,
      });

      @override Future<String> saveRecord(TiebanDivinationRecordContract r) => save(r);
      @override Future<List<TiebanDivinationRecordContract>> getAllRecords() => getAll();
      @override Stream<List<TiebanDivinationRecordContract>> watchAllRecords() => watchAll();
      @override Future<TiebanDivinationRecordContract?> getRecordByUuid(String u) => getByUuid(u);
      @override Future<bool> softDeleteRecord(String u) => softDelete(u);
    }

  STEP_6: |
    运行 dart analyze 和 flutter test 验证。

PROHIBITED:
  - 修改 TiaoWenRepository
  - 在新 contract 中依赖 metaphysics_core
  - 创建独立的 LocalRecordRepository 实例

ASSERTIONS:
  EXECENV: "dart analyze 零错误，flutter test 全部通过"
  CASES:
    - "TiebanRecordCodec 往返 encode→decode 保真"
    - "RecordBackedTiebanRepository 满足 TiebanRecordRepository 契约"

VERIFICATION: "dart analyze && flutter test"
```

---

## ACT-13: 紫微斗数接入

```yaml
TASK_ID: "record-onboard-ziweidoushu"
LANG: "dart"
CONTEXT:
  DOMAIN: |
    紫微斗数当前无排盘记录保存接口。ZiweiStarRepository 是只读星曜数据加载。
    已有丰富的模型（ZiweiChart, ZiweiPalace, ZiweiStar 等）。
    contracts/ 目录不存在，需新建。

    需要新建：
    - ZiweiDivinationRecord contract（排盘结果快照）
    - ZiweiRecordRepository port
    - ZiweiRecordCodec
    - RecordBackedZiweiRepository

    注意：ZiweiChart 是计算结果对象，不是持久化 contract。
    新 contract 应是 ZiweiChart 的 JSON 快照，不是 ZiweiChart 本身。

  STRATEGY: |
    1. 在 xuan-storage/drift/pubspec.yaml 添加依赖
    2. 创建 contracts/ 目录和 contract + port
    3. 创建 codec + repository
    4. 验证

TASK_DEPS: ["typed-record-phase3-base-and-meihua"]

COMMANDS:
  PRECHECK: |
    dart analyze repository-interface-ziweidoushu/lib/ 2>/dev/null || true

  STEP_0: |
    在 xuan-storage/drift/pubspec.yaml 中添加 repository_interface_ziweidoushu 依赖。

  STEP_0_CONTENT: |
    repository_interface_ziweidoushu:
      path: ../../repository-interface-ziweidoushu

  STEP_1: |
    创建 contracts/ 目录（如不存在）和 ZiweiDivinationRecordContract。
    位置: repository-interface-ziweidoushu/lib/src/contracts/ziwei_divination_record_contract.dart

  STEP_1_CONTENT: |
    import 'package:equatable/equatable.dart';

    final class ZiweiDivinationRecordContract extends Equatable {
      const ZiweiDivinationRecordContract({
        required this.uuid,
        this.question,
        this.birthDatetimeJson,
        this.isMale,
        this.chartRequestJson,
        this.chartResultJson,
        this.fourTransformationsJson,
        this.paramsJson,
        required this.createdAt,
        this.updatedAt,
        this.deletedAt,
      });

      final String uuid;
      final String? question;
      final String? birthDatetimeJson;
      final bool? isMale;
      final String? chartRequestJson;
      final String? chartResultJson;
      final String? fourTransformationsJson;
      final String? paramsJson;
      final DateTime createdAt;
      final DateTime? updatedAt;
      final DateTime? deletedAt;

      @override
      List<Object?> get props => [uuid, question, createdAt];
    }

  STEP_2: |
    创建 ZiweiRecordRepository port。
    位置: repository-interface-ziweidoushu/lib/src/repositories/ziwei_record_repository.dart

  STEP_2_CONTENT: |
    import '../contracts/ziwei_divination_record_contract.dart';

    abstract interface class ZiweiRecordRepository {
      Future<String> saveRecord(ZiweiDivinationRecordContract record);
      Future<List<ZiweiDivinationRecordContract>> getAllRecords();
      Future<ZiweiDivinationRecordContract?> getRecordByUuid(String uuid);
      Future<bool> softDeleteRecord(String uuid);
      Stream<List<ZiweiDivinationRecordContract>> watchAllRecords();
    }

  STEP_3: |
    更新 barrel 文件，导出新 contract 和 port。

  STEP_4: |
    创建 xuan-storage/drift/lib/ziweidoushu/ 目录（如不存在）。
    创建 ZiweiRecordCodec。
    位置: xuan-storage/drift/lib/ziweidoushu/ziwei_record_codec.dart

  STEP_4_CONTENT: |
    import 'dart:convert';
    import 'package:repository_interface_ziweidoushu/repository_interface_ziwei.dart';
    import 'package:repository_interface_record/repository_interface_record.dart';

    class ZiweiRecordCodec implements RecordModuleCodec<ZiweiDivinationRecordContract> {
      @override String get module => 'ziweidoushu';
      @override String get category => 'divination';
      @override String get divinationType => 'zi_wei';

      @override String uuidOf(ZiweiDivinationRecordContract c) => c.uuid;

      @override
      ZiweiDivinationRecordContract withUuid(ZiweiDivinationRecordContract c, String uuid) {
        return ZiweiDivinationRecordContract(
          uuid: uuid, question: c.question, birthDatetimeJson: c.birthDatetimeJson,
          isMale: c.isMale, chartRequestJson: c.chartRequestJson,
          chartResultJson: c.chartResultJson,
          fourTransformationsJson: c.fourTransformationsJson,
          paramsJson: c.paramsJson, createdAt: c.createdAt,
          updatedAt: c.updatedAt, deletedAt: c.deletedAt,
        );
      }

      @override
      EncodedRecord encode(ZiweiDivinationRecordContract c, {required String scopeUid}) {
        final data = <String, dynamic>{
          'birthDatetimeJson': c.birthDatetimeJson, 'isMale': c.isMale,
          'chartRequestJson': c.chartRequestJson, 'chartResultJson': c.chartResultJson,
          'fourTransformationsJson': c.fourTransformationsJson,
          'paramsJson': c.paramsJson,
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
      ZiweiDivinationRecordContract decode(RecordMeta meta, Map<String, dynamic>? moduleData) {
        if (meta.module != module) throw RecordCodecMismatch(message: 'module mismatch');
        final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
        return ZiweiDivinationRecordContract(
          uuid: meta.uuid, question: meta.question,
          birthDatetimeJson: d['birthDatetimeJson'], isMale: d['isMale'],
          chartRequestJson: d['chartRequestJson'], chartResultJson: d['chartResultJson'],
          fourTransformationsJson: d['fourTransformationsJson'],
          paramsJson: d['paramsJson'], createdAt: meta.createdAt,
          updatedAt: meta.updatedAt ?? meta.createdAt, deletedAt: meta.deletedAt,
        );
      }

      @override
      List<SearchTag> extractSearchTags(RecordMeta meta, Map<String, dynamic>? moduleData) {
        final d = moduleData ?? (meta.moduleDataJson != null ? jsonDecode(meta.moduleDataJson!) : const {});
        final tags = <SearchTag>[];
        if (d['birthDatetimeJson'] != null) tags.add(SearchTag('birth_datetime', '${d['birthDatetimeJson']}'));
        return tags;
      }
    }

  STEP_5: |
    创建 RecordBackedZiweiRepository。
    位置: xuan-storage/drift/lib/ziweidoushu/record_backed_ziwei_repository.dart

  STEP_5_CONTENT: |
    import 'package:repository_interface_ziweidoushu/repository_interface_ziwei.dart';
    import '../record/base_record_backed_repository.dart';
    import 'ziwei_record_codec.dart';

    class RecordBackedZiweiRepository
        extends BaseRecordBackedRepository<ZiweiDivinationRecordContract>
        implements ZiweiRecordRepository {

      RecordBackedZiweiRepository({
        required super.store,
        required super.codec,
        super.uuid,
      });

      @override Future<String> saveRecord(ZiweiDivinationRecordContract r) => save(r);
      @override Future<List<ZiweiDivinationRecordContract>> getAllRecords() => getAll();
      @override Stream<List<ZiweiDivinationRecordContract>> watchAllRecords() => watchAll();
      @override Future<ZiweiDivinationRecordContract?> getRecordByUuid(String u) => getByUuid(u);
      @override Future<bool> softDeleteRecord(String u) => softDelete(u);
    }

  STEP_6: |
    运行 dart analyze 和 flutter test 验证。

PROHIBITED:
  - 修改 ZiweiStarRepository
  - 直接 import ZiweiChart 作为 codec 的类型参数（用 contract 代替）
  - 创建独立的 LocalRecordRepository 实例

ASSERTIONS:
  EXECENV: "dart analyze 零错误，flutter test 全部通过"
  CASES:
    - "ZiweiRecordCodec 往返 encode→decode 保真"
    - "RecordBackedZiweiRepository 满足 ZiweiRecordRepository 契约"

VERIFICATION: "dart analyze && flutter test"
```

---

## 附录：批量接入后 DI 装配更新

所有 6 个模块接入后，DI 装配需要更新：

```dart
// 最终 DI 装配 (8 个模块)
final scopeResolved = await scopeResolver.resolve();
final dataSource = DriftRecordDataSource(database, scopeUid: scopeResolved.scopeUid);

// 创建所有 codec 实例
final meihuaCodec = MeiHuaRecordCodec();
final liuyaoCodec = LiuYaoRecordCodec();
final qizhengCodec = QiZhengRecordCodec();
final daliurenCodec = DaliurenRecordCodec();
final qimenCodec = QimenRecordCodec();
final taiyiCodec = TaiyiRecordCodec();
final tiebanCodec = TiebanRecordCodec();
final ziweiCodec = ZiweiRecordCodec();

final registry = RecordAdapterRegistry([
  meihuaCodec, liuyaoCodec, qizhengCodec, daliurenCodec,
  qimenCodec, taiyiCodec, tiebanCodec, ziweiCodec,
]);

final store = LocalRecordRepository(dataSource, registry);

// 各模块 repository (直接传 codec 实例)
final meihuaRepo = RecordBackedMeiHuaRepository(store: store, codec: meihuaCodec);
final liuyaoRepo = RecordBackedLiuYaoRepository(store: store, codec: liuyaoCodec);
final qizhengRepo = RecordBackedQiZhengRepository(store: store, codec: qizhengCodec);
final daliurenRepo = RecordBackedDaliurenRepository(store: store, codec: daliurenCodec);
final qimenRepo = RecordBackedQimenRepository(store: store, codec: qimenCodec);
final taiyiRepo = RecordBackedTaiyiRepository(store: store, codec: taiyiCodec);
final tiebanRepo = RecordBackedTiebanRepository(store: store, codec: tiebanCodec);
final ziweiRepo = RecordBackedZiweiRepository(store: store, codec: ziweiCodec);
```

---

## 附录：每个模块新增文件清单

| 模块 | repository-interface 新增 | xuan-storage/drift 新增 |
|------|-------------------------|----------------------|
| 七政四余 | qizheng_record_repository.dart | qizheng_record_codec.dart, record_backed_qizheng_repository.dart |
| 大六壬 | daliuren_divination_record_contract.dart, daliuren_record_repository.dart | daliuren/daliuren_record_codec.dart, daliuren/record_backed_daliuren_repository.dart |
| 奇门遁甲 | qimen_divination_record_contract.dart, qimen_record_repository.dart | qimendunjia/qimen_record_codec.dart, qimendunjia/record_backed_qimen_repository.dart |
| 太乙神数 | taiyi_divination_record_contract.dart, taiyi_record_repository.dart | taiyishenshu/taiyi_record_codec.dart, taiyishenshu/record_backed_taiyi_repository.dart |
| 铁板神数 | tieban_divination_record_contract.dart, tieban_record_repository.dart | tiebanshenshu/tieban_record_codec.dart, tiebanshenshu/record_backed_tieban_repository.dart |
| 紫微斗数 | ziwei_divination_record_contract.dart, ziwei_record_repository.dart | ziweidoushu/ziwei_record_codec.dart, ziweidoushu/record_backed_ziwei_repository.dart |

每个模块总共新增 3-4 个文件，约 150-250 行代码。
