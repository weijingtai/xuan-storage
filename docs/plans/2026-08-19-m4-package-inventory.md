# M4 · 18 个 repository-interface-* 包分类盘点与迁移说明表

> **时间**：2026-08-19  
> **目标**：全面记录 18 个 `repository-interface-*` 仓库的分类判定、端口规模、scope 列现状与实际迁移做法。

---

## 一、18 包全量分类盘点表

| 包名 | 类别(A记录型/B配置型/C KV型/D资产型/E不迁) | 端口方法数 | 是否有 scope 列 | 实际迁移做法 | 备注 |
|---|---|---|---|---|---|
| `repository-interface-liuyao` | A 记录型 | 5 | 是 (底层 record 驱动) | 声明 `liuyaoEntityDescriptor`，旧 `SixYaoDivinationRecordRepository` 标注 `@Deprecated('M4 退场，改用 L0 切片')`，接入 C1–C14 契约套件 | 第一批已迁，48 项测试全绿 |
| `repository-interface-meihuayishu` | A 记录型 / B 配置型 | 11 | 记录: 是 / 卦象/字典: 否 | 声明 `meihuaEntityDescriptor`，旧 `MeiHuaDivinationRecordRepository` / `Preference` / `Dictionary` 标注 `@Deprecated`，接入 C1–C14 | 第一批已迁，16 项测试全绿 |
| `repository-interface-daliuren` | A 记录型 + D 资产型 | 13 | 记录: 是 / 资产: 否 | 声明 `daliurenEntityDescriptor`，旧 `DaliurenRecordRepository` 及 4 个官方数据仓储标注 `@Deprecated`，接入 C1–C14 | 第二批已迁，17 项测试全绿 |
| `repository-interface-qimendunjia` | A 记录型 + D 资产型 | 12 | 记录: 是 / 规则: 否 | 声明 `qimenEntityDescriptor`，旧 `QimendunjiaRecordRepository` / `OfficialRule` 标注 `@Deprecated`，接入 C1–C14 | 第二批已迁，17 项测试全绿 |
| `repository-interface-taiyishenshu` | A 记录型 + B 配置型 | 11 | 记录: 是 / 流派神煞: 否 | 声明 `taiyiEntityDescriptor`，旧 `TaiyiRecordRepository` / `School` / `MingGua` / `Destiny` 标注 `@Deprecated`，接入 C1–C14 | 第二批已迁，21 项测试全绿 |
| `repository-interface-tiebanshenshu` | A 记录型 + D 资产型 | 9 | 记录: 是 / 条文: 否 | 声明 `tiebanEntityDescriptor`，旧 `TiebanRecordRepository` / `TiaoWenRepository` 标注 `@Deprecated`，接入 C1–C14 | 第二批已迁，15 项测试全绿 |
| `repository-interface-qizhengsiyu` | A 记录型 + D 资产型 | 16 | 记录: 是 / 资产: 否 | 声明 `qizhengEntityDescriptor`，旧 `QiZhengRecordRepository` / `IQiZhengSiYuPanRepository` 标注 `@Deprecated`，接入 C1–C14 | 第二批已迁，16 项测试全绿 |
| `repository-interface-ziweidoushu` | A 记录型 + D 资产型 | 9 | 记录: 是 / 星曜: 否 | 声明 `ziweiEntityDescriptor`，旧 `ZiweiRecordRepository` / `ZiweiStarRepository` 标注 `@Deprecated`，接入 C1–C14 | 第二批已迁，14 项测试全绿 |
| `repository-interface-divination-tag` | B 配置型 | 8 | 否 (全局维度/标签表无 scope) | 声明 `tagDimensionEntityDescriptor`，旧 `TagDimensionRepository` / `DivinerPreferencePort` 标注 `@Deprecated`，接入 C1–C14 | 第三批已迁，38 项测试全绿 |
| `repository-interface-divination-pipeline` | E 不迁 (跨实体原子组合写/纯计算编排) | 3 | N/A | 跨实体复合原子持久化（`CompositePersistencePort`）与纯排盘管线，非单实体 CRUD，保持独立编排端口 | 判定为 E 类，不进入单实体 CRUD 切片 |
| `repository-interface-four-zhu-card` | A 记录型 / B 配置型 | 18 | 否 (模板/设置表缺 scope) | 声明 `layoutTemplateEntityDescriptor`，旧 `LayoutTemplateRepository` 标注 `@Deprecated`，接入 C1–C14 | 第三批已迁，15 项测试全绿 |
| `repository-interface-bazi` | A 记录型 | 8 | 是 (底层 record 驱动) | 声明 `baziRecordEntityDescriptor`，旧 `BaziRecordRepository` / `BaziCaseRepository` 标注 `@Deprecated`，接入 C1–C14 | 第三批已迁，16 项测试全绿 |
| `repository-interface-kanyu` | A 记录型 + B 配置型 | 12 | 是 (底层 record 驱动) | 声明 `kanyuEntityDescriptor`，旧 `SceneDocumentRepository` 标注 `@Deprecated`，接入 C1–C14 | 第三批已迁，20 项测试全绿 |
| `repository-interface-xiang` | A 记录型 + B 配置型 | 5 | 是 (底层 record 驱动) | 声明 `xiangEntityDescriptor`，旧 `XiangReadingRepository` / `ConsentPort` 标注 `@Deprecated`，接入 C1–C14 | 第三批已迁，45 项测试全绿 |
| `repository-interface-account` | A 记录型 / B 配置型 | 13 | 否 (账号关联表无 scope，以用户主键隔离) | 声明 `accountProfileEntityDescriptor`，旧会话/画像/偏好/关联仓储标注 `@Deprecated`，接入 C1–C14 | 第四批已迁，60 项测试全绿 |
| `repository-interface-ai` | A 记录型 / B 配置型 / C KV型 | 16 | 否 (AI 各表均缺 scope) | 声明 `aiChatSessionEntityDescriptor`，旧对话历史/配置/Prompt/Secret 仓储标注 `@Deprecated`，接入 C1–C14 | 第四批已迁，14 项测试全绿 |
| `repository-interface-media` | E 不迁 (硬件采集/编解码) | 4 | N/A | 外设硬件抽象与音视频抽帧管线（`MediaAcquisitionPort`, `KeyframeExtractionPort`），非 CRUD 数据仓储 | 判定为 E 类，不进入持久化切片 |
| `repository-interface-playground` | A 记录型 / B 配置型 / C KV型 | 25 | 否 (广场本地缓存表缺 scope) | 声明 `playgroundPostEntityDescriptor`，旧命令/查询/互动仓储标注 `@Deprecated`，接入 C1–C14 | 第四批已迁，299 项测试全绿 |

---

## 二、E 类包未迁移详细论证 (divination-pipeline 与 media)

### 2.1 `repository-interface-divination-pipeline` (E 类)
- **存储与接口形态**：
  该包包含两类接口：
  1. 领域计算管线：`MomentResolver`（历法转换）、`ChartCalculator<TReq, TChart>`（纯函数排盘计算）与 `DivinationPipeline`（起盘流程调度）。
  2. 跨聚合持久化端口：`CompositePersistencePort` (`saveAtomically(CompositePersistCommand command)`)，负责将排盘生成的主记录、Case、WorkItem 以及附件以单次原子事务统一持久化。
- **为何 EntityDescriptor / CrudBaseRepository 不适用**：
  L0 的 `EntityDescriptor<T, ID>` 与 `CrudBaseRepository<T, ID>` 是严格针对**单一实体类型**（Single-Entity）的 CRUD / 软删 / 乐观锁 / 游标查询模型。`CompositePersistencePort` 则是跨多个聚合根（Case + DivinationRecord + WorkItems + PanelRefs）的**原子组合写操作（Composite Atomic Persist）**，单实体描述符无法承载多表复合写入。
- **与 L0 `Transactional.inTransaction` 的关系评估**：
  `CompositePersistencePort.saveAtomically` 的底层语义完全对应 L0 `StorageDriver` 的 `Transactional.inTransaction` 事务切片。在后续实现层，`CompositePersistencePort` 应当被实现为一个事务编排 Facade，内部通过 `driver.inTransaction` 依次调用各个 L0 单实体仓库（`CaseRepository.put`, `RecordRepository.put` 等），而不是强行将 `CompositePersistencePort` 自身扭曲成一个 `CrudBaseRepository`。

### 2.2 `repository-interface-media` (E 类)
- **存储与接口形态**：
  该包是相术/多模态占断的硬件设备与媒体流接入契约，包含 `MediaAcquisitionPort`（调用平台摄像头/麦克风采集媒体）与 `KeyframeExtractionPort`（调用系统/FFmpeg 音视频解码器提取关键帧时间戳与图像帧引用 `MediaReference`）。
- **为何 EntityDescriptor / Base 套不上**：
  媒体采集与关键帧提取属于流式外设 IO 操作，输出的是瞬态的内存数据流或本地临时文件路径引用（非结构化数据），并不承担持久化记录的增删改查。真正的媒体元数据持久化已包含在 `XiangReading` 内部。
- **强行迁移会破坏什么**：
  若将硬件设备采集抽象为 CRUD Base，会导致平台流式交互语义扭曲为同步表读写，破坏媒体设备生命周期的掌控。
