# 各子模块 Record Repository 现状分析报告

> **日期**：2026-06-28
> **前置文档**：[2026-06-25-record-storage-base-class-design.md](./2026-06-25-record-storage-base-class-design.md)
> **目的**：统计所有占测子模块的 Repository 实现程度，评估 Base 父类方案的落地可行性，为后续逐个模块接入统一 Record 存储打下基础。

---

## 0. 项目全景

### 0.1 架构分层

```
┌─────────────────────────────────────────────────────┐
│  repository-interface-*  (12 包)                     │
│  抽象端口：定义接口 + 模型 + 契约，不含实现            │
├─────────────────────────────────────────────────────┤
│  xuan-*  (20 包)                                     │
│  领域逻辑：占测算法、业务规则、核心引擎                 │
├─────────────────────────────────────────────────────┤
│  xuan-storage/  (6 子包)                             │
│  持久化实现：drift / firebase / preferences / assets   │
│  / supabase / core                                   │
└─────────────────────────────────────────────────────┘
```

### 0.2 统一 Record 存储基础设施（已建成）

| 组件 | 位置 | 职责 |
|------|------|------|
| `RecordRepository` 接口 | `repository-interface-record/lib/src/ports/record_repository.dart` | 通用 CRUD/watch 端口 |
| `RecordMeta` 模型 | `repository-interface-record/lib/src/models/record_meta.dart` | 20 列通用元数据 |
| `ModuleRecordAdapter` 接口 | `repository-interface-record/lib/src/ports/module_record_adapter.dart` | 模块数据 ↔ 通用元数据的双向适配器 |
| `LocalRecordRepository` | `xuan-storage/drift/lib/record/local_record_repository.dart` | Drift 实现，委托给 DataSource + AdapterRegistry |
| `DriftRecordDataSource` | `xuan-storage/drift/lib/record/drift_record_data_source.dart` | SQL 操作 `t_record_meta` + `t_record_search_index` |
| `t_record_meta` 表 | `xuan-storage/drift/lib/tables/record_meta_table.dart` | 20 列（uuid, scope_uid, module, category, divination_type, question, module_data_json, timestamps...） |
| `t_record_search_index` 表 | `xuan-storage/drift/lib/tables/record_search_index_table.dart` | (module, index_key, index_value) → record_uuid 索引 |
| `RecordAdapterRegistry` | `xuan-storage/drift/lib/record/record_adapter_registry.dart` | 适配器注册与查找 |

---

## 1. 各模块实现程度统计

### 1.1 总体概览

| # | 模块 | 端口接口 | 合约/模型 | Drift 实现 | ModuleRecordAdapter | 接入统一 Record 存储 | 状态 |
|---|------|---------|----------|-----------|-------------------|---------------------|------|
| 1 | **meihuayishu** | ✅ | ✅ | ✅ | ✅ | ✅ **已完成** | 🟢 参考实现 |
| 2 | **liuyao** | ✅ | ✅ | ❌ | ❌ | ❌ | 🟡 接口就绪，缺实现 |
| 3 | **qimendunjia** | ❌ | ❌ | ❌ | ❌ | ❌ | 🔴 无记录存储 |
| 4 | **daliuren** | ❌ | ❌ | ❌ | ❌ | ❌ | 🔴 无记录存储 |
| 5 | **qizhengsiyu** | ❌ | ❌ | ❌ | ❌ | ❌ | 🔴 无记录存储 |
| 6 | **taiyishenshu** | ❌ | ❌ | ❌ | ❌ | ❌ | 🔴 无记录存储 |
| 7 | **tiebanshenshu** | ❌ | ❌ | ❌ | ❌ | ❌ | 🔴 无记录存储 |
| 8 | **ziweidoushu** | ❌ | ❌ | ❌ | ❌ | ❌ | 🔴 无记录存储 |
| 9 | **four-zhu-card** | ⚠️ | ⚠️ | ⚠️ | ❌ | ❌ | 🟠 有 UsageRecorder，非记录存储 |
| — | **record**（通用层） | ✅ | ✅ | ✅ | ✅（接口） | N/A | 🟢 基础设施 |

### 1.2 详细分析

#### 1.2.1 🟢 meihuayishu — 参考实现（唯一完整接入）

**文件清单**：

| 文件 | 位置 | 行数 | 职责 |
|------|------|------|------|
| `MeiHuaDivinationRecordRepository` | `repository-interface-meihuayishu/lib/src/repositories/meihua_divination_record_repository.dart` | 22 | 端口接口：7 个方法 |
| `MeiHuaDivinationRecordContract` | `repository-interface-meihuayishu/lib/src/contracts/meihua_divination_record_contract.dart` | ~70 | 合约类：15 个字段 |
| `RecordBackedMeiHuaRepository` | `xuan-storage/drift/lib/meihuayishu/record_backed_meihua_repository.dart` | 85 | 实现类：委托给 LocalRecordRepository |
| `MeihuaRecordAdapter` | `xuan-storage/drift/lib/meihuayishu/meihua_record_adapter.dart` | 77 | 适配器：contract ↔ RecordMeta |
| `meihua_record_migration.dart` | `xuan-storage/drift/lib/meihuayishu/meihua_record_migration.dart` | 22 | 旧库迁移 |
| `DriftMeiHuaDivinationRecordRepository` | `xuan-storage/drift/lib/meihuayishu/drift_meihua_divination_record_repository.dart` | 103 | @Deprecated 旧实现 |

**端口接口方法**：

```dart
abstract interface class MeiHuaDivinationRecordRepository {
  Future<String> saveRecord(MeiHuaDivinationRecordContract record);
  Future<List<MeiHuaDivinationRecordContract>> getAllRecords();
  Stream<List<MeiHuaDivinationRecordContract>> watchAllRecords();
  Future<MeiHuaDivinationRecordContract?> getRecordByUuid(String uuid);
  Future<MeiHuaDivinationRecordContract?> getRecordByDivinationUuid(String divinationUuid);
  Stream<MeiHuaDivinationRecordContract?> watchRecordByDivinationUuid(String divinationUuid);
  Future<bool> softDeleteRecord(String uuid);
}
```

**合约字段**：uuid, divinationUuid, question, originalUpperGua, originalLowerGua, changingYao, changedUpperGua, changedLowerGua, huUpperGua, huLowerGua, method, paramsJson, createdAt, updatedAt, deletedAt

**搜索索引**：`divination_uuid`, `upper_gua`, `lower_gua`, `changing_yao`

---

#### 1.2.2 🟡 liuyao — 接口就绪，缺实现

**文件清单**：

| 文件 | 位置 | 行数 | 职责 |
|------|------|------|------|
| `SixYaoDivinationRecordRepository` | `repository-interface-liuyao/lib/src/ports/six_yao_divination_record_repository.dart` | 28 | 端口接口：5 个方法 |
| `SixYaoDivinationRecord` | `repository-interface-liuyao/lib/src/models/six_yao_divination_record.dart` | 91 | 合约类：8 个字段 + 2 个枚举 |
| ❌ 无 drift 实现 | `xuan-storage/drift/lib/liuyao/` 目录不存在 | — | — |
| ❌ 无适配器 | — | — | — |
| ❌ 无迁移 | — | — | — |

**端口接口方法**：

```dart
abstract interface class SixYaoDivinationRecordRepository {
  Future<String> saveRecord(SixYaoDivinationRecord record);
  Future<SixYaoDivinationRecord?> getRecordByUuid(String uuid);
  Future<List<SixYaoDivinationRecord>> getAllRecords();
  Future<bool> softDeleteRecord(String uuid);
  Future<List<SixYaoDivinationRecord>> getLatestRecords({int limit = 10});
}
```

**合约字段**：uuid, question, yaoResults (List<SixYaoYaoResult>), originalGuaId, changedGuaId?, createdAt, updatedAt?, deletedAt?

**辅助类型**：`YaoType` 枚举 (laoyang, shaoyang, laoyin, shaoyin), `SixYaoYaoResult` (index, yaoType)

**与梅花接口的差异**：

| 维度 | 梅花 | 六爻 |
|------|------|------|
| 方法数 | 7 | 5 |
| watchAllRecords | ✅ | ❌ |
| watchByXxx | ✅ (watchRecordByDivinationUuid) | ❌ |
| getBySearchIndex | ✅ (getRecordByDivinationUuid) | ❌ |
| getLatestRecords | ❌ | ✅ |

> **结论**：六爻接口是梅花接口的**子集 + 1 个新增**。Base 的 save/getAll/getByUuid/softDelete/getLatest 可直接覆盖。不需要 watch 相关方法。这是 Base 方案最理想的第二个接入目标。

---

#### 1.2.3 🔴 qimendunjia — 无记录存储

**现状**：
- `repository-interface-qimendunjia/` 仅有 `official_rule_repository.dart`（官方规则查询），无记录相关接口或模型
- `xuan-storage/assets/qimendunjia/` 仅有 `assets_qimendunjia_official_rule_repository.dart`
- 无 drift 目录，无适配器

**待建**（从零开始）：
1. 在 `repository-interface-qimendunjia/` 中新增 `QiMenDivinationRecordRepository` 接口
2. 在 `repository-interface-qimendunjia/` 中新增 `QiMenDivinationRecord` 合约类
3. 在 `xuan-storage/drift/lib/` 中新建 `qimendunjia/` 目录
4. 实现 `QimenRecordAdapter` + `RecordBackedQimenRepository`

---

#### 1.2.4 🔴 daliuren — 无记录存储

**现状**：
- `repository-interface-daliuren/` 仅有 school/keti/shensha 相关的参考数据仓库，无记录接口
- `xuan-storage/drift/lib/` 无 `daliuren/` 目录

**待建**：同 qimendunjia 模式，从零开始

---

#### 1.2.5 🔴 qizhengsiyu — 无记录存储

**现状**：
- `repository-interface-qizhengsiyu/` 的 ports 中有 `recordDeletion` 方法，但那是神煞/化曜数据的删除操作，不是用户占卜记录存储
- 存在 `ShenShaRecordContract` 和 `HuaYaoRecordContract`，但它们是**领域数据模型**（描述神煞/化曜的计算结果），不是存储记录合约

**待建**：从零开始

---

#### 1.2.6 🔴 taiyishenshu — 无记录存储

**现状**：
- `repository-interface-taiyishenshu/` 仅有 school/destiny/minggua 仓库，无记录接口
- `xuan-storage/drift/lib/taiyishenshu/` 目录存在但只有 `DriftUserRepository`（太乙神数门派/神将 CRUD），无记录存储代码

**待建**：从零开始

---

#### 1.2.7 🔴 tiebanshenshu — 无记录存储

**现状**：
- `repository-interface-tiebanshenshu/` 仅有 `tiao_wen_repository`（条文查询），无记录接口
- `xuan-storage/assets/tiebanshenshu/` 仅有 `assets_tiao_wen_repository.dart`

**待建**：从零开始

---

#### 1.2.8 🔴 ziweidoushu — 无记录存储

**现状**：
- `repository-interface-ziweidoushu/` 仅有 `ziwei_star_repository`（星曜数据），无记录接口
- 有领域模型（`ziwei_chart`, `ziwei_palace` 等）但无存储记录合约

**待建**：从零开始

---

#### 1.2.9 🟠 four-zhu-card — 有 UsageRecorder，非记录存储

**现状**：
- `repository-interface-four-zhu-card/` 有 `FourZhuCardTemplateUsageRecorder` 接口 + `UsageRecord` 模型
- `xuan-storage/drift/lib/four_zhu_card_templates/` 有 `CardTemplateSkillUsageDao`
- 这是**模板使用追踪**，不是占卜记录存储——概念上不同，但技术上可复用类似模式

**与统一 Record 存储的关系**：如果未来需要将模板使用记录也纳入统一的记录管理（如用户操作历史），可参考梅花模式接入。但目前它是独立系统。

---

## 2. 模块间接口差异矩阵

| 方法 | 梅花 | 六爻 | 奇门(预估) | 大六壬(预估) | 奇政(预估) | 太乙(预估) | 铁板(预估) | 紫微(预估) |
|------|:----:|:----:|:--------:|:---------:|:--------:|:--------:|:--------:|:--------:|
| saveRecord | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| getAllRecords | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| getRecordByUuid | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| softDeleteRecord | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| watchAllRecords | ✅ | ❌ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ |
| getByDivinationUuid | ✅ | ❌ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ |
| watchByDivinationUuid | ✅ | ❌ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ |
| getLatestRecords | ❌ | ✅ | ❓ | ❓ | ❓ | ❓ | ❓ | ❓ |

> 图例：✅ 已有 / ❌ 无 / ❓ 待定（模块尚未设计记录接口）

**关键发现**：`saveRecord`、`getAllRecords`、`getRecordByUuid`、`softDeleteRecord` 是**所有模块的刚性需求**。这 4 个方法在 Base 中已完整实现，子类只需一行委托。

---

## 3. 可行性与优先级分析

### 3.1 按接入难度排序

| 优先级 | 模块 | 待建工作量 | 难度 | 理由 |
|--------|------|-----------|------|------|
| **P0** | meihuayishu | 0（已完成） | — | 参考实现 |
| **P1** | liuyao | ~150 行（适配器 ~70 + 实现 ~30 + 迁移 ~25 + DI ~25） | ⭐ 低 | 接口+模型已就绪，只需写适配器和实现 |
| **P2** | qimendunjia | ~250 行（接口 ~25 + 模型 ~60 + 适配器 ~70 + 实现 ~30 + 迁移 ~25 + DI ~40） | ⭐⭐ 中 | 从零开始，但奇门盘数据相对规整 |
| **P2** | daliuren | ~250 行 | ⭐⭐ 中 | 同奇门 |
| **P2** | ziweidoushu | ~250 行 | ⭐⭐ 中 | 同奇门 |
| **P3** | taiyishenshu | ~250 行 | ⭐⭐ 中 | 同奇门 |
| **P3** | tiebanshenshu | ~250 行 | ⭐⭐ 中 | 同奇门 |
| **P3** | qizhengsiyu | ~250 行 | ⭐⭐ 中 | 同奇门 |
| — | four-zhu-card | N/A | — | 非占卜记录存储，独立系统 |

### 3.2 Base 方案的适用性验证

对照 [Base 设计文档](./2026-06-25-record-storage-base-class-design.md) 中的方法清单：

| Base 方法 | 梅花 | 六爻 | 适用性 |
|-----------|:----:|:----:|--------|
| `save(T)` | ✅ | ✅ | 所有模块 |
| `getAll({limit})` | ✅ | ✅ | 所有模块 |
| `watchAll()` | ✅ | ❌ | 可选，子类不暴露即可 |
| `getByUuid(String)` | ✅ | ✅ | 所有模块 |
| `softDelete(String)` | ✅ | ✅ | 所有模块 |
| `getBySearchIndex(key, value)` | ✅ | ❌ | 可选 |
| `getAllBySearchIndex(key, value)` | ✅ | ❌ | 可选 |
| `getLatest({limit})` | ❌ | ✅ | 可选 |

**结论**：Base 方案的 8 个方法中，4 个（save/getAll/getByUuid/softDelete）是**所有模块的刚性需求**，其余 4 个是可选扩展。六爻不声明 watchAll/watchByXxx 方法，子类只需不暴露这些方法即可——这证明了 Base 的"工具箱"设计是正确的。

### 3.3 建议接入顺序

```
Phase 1 (当前): meihuayishu ✅ 已完成
Phase 2 (立即): liuyao — 作为 Base 方案的第一个验证案例
Phase 3 (短期): qimendunjia + daliuren — 两个典型盘式模块
Phase 4 (中期): ziweidoushu + taiyishenshu + tiebanshenshu
Phase 5 (远期): qizhengsiyu
```

**理由**：
1. 六爻接口已就绪，改动最小，可快速验证 Base 方案的可用性
2. 奇门和大六壬是盘式占测的代表，接口设计可互相参考
3. 紫微/太乙/铁板各有独特的领域模型，接口设计需要更多领域知识
4. 奇政四余是最后考虑的模块

---

## 4. 关键风险与依赖

### 4.1 风险

| 风险 | 影响模块 | 严重程度 | 缓解措施 |
|------|---------|---------|---------|
| 各模块 detail 结构差异大 | 全部 | 中 | 适配器模式已天然隔离差异；Base 不关心 moduleData 内容 |
| 端口签名不一致 | 全部 | 低 | Base 不实现任何端口——子类 `implements` 并委托 |
| `ModuleRecordAdapter.fromRecord` 返回 `Object`，需要 `as TContract` 转型 | 全部 | 低 | 泛型约束 + 开发阶段立即暴露 |
| 某些模块可能有"批量保存"或"事务性保存"需求 | 奇门/紫微（盘式） | 中 | 可在 Base 中增加 `saveBatch` hook，但不影响现有单条保存 |
| watchBySearchIndex 效率 | 梅花（当前） | 低 | MVP 阶段接受 watchAll + filter；中期优化 |

### 4.2 依赖

- **Base 类尚未实现**：设计文档已就绪，待团队评审 NEEDS_CONTEXT 问题后实现
- **六爻模块需要**：创建 `xuan-storage/drift/lib/liuyao/` 目录 + 3 个文件
- **其他模块需要**：先在 `repository-interface-*` 中定义端口接口和合约类

---

## 5. 总结

### 5.1 数据快照

| 指标 | 数值 |
|------|------|
| 占测子模块总数 | 9（含 four-zhu-card） |
| 已接入统一 Record 存储 | 1（meihuayishu） |
| 接口就绪、待实现 | 1（liuyao） |
| 无记录存储 | 6（qimendunjia, daliuren, qizhengsiyu, taiyishenshu, tiebanshenshu, ziweidoushu） |
| 独立系统（非占卜记录） | 1（four-zhu-card） |
| 每模块接入预估工作量 | 150–250 行（取决于是否已有接口+模型） |
| Base 方案可覆盖的方法 | 所有模块的 save/getAll/getByUuid/softDelete（100% 刚性需求） |

### 5.2 下一步行动

1. **评审 Base 设计文档** 中的 4 个 NEEDS_CONTEXT 问题
2. **实现 Base 类**（`BaseRecordBackedRepository<TContract>` + `migrateModuleRecords`）
3. **以六爻为第一个验证案例**，接入 Base → 验证设计 → 反馈改进
4. **制定各模块接口规范**（为奇门/大六壬等模块统一端口命名约定）
5. **逐个模块接入**，按优先级顺序推进

---

> **报告结束**。本报告为纯分析文档，基于对 monorepo 中所有 12 个 repository-interface 包和 xuan-storage 的完整代码审查。
