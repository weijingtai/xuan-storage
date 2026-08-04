# XRAP · Xuan 资源资产协议

- 代号：**XRAP**（Xuan Resource Asset Protocol）
- 协议版本：**1.0**
- 日期：2026-08-02
- 状态：草案，待人类拍板 D1–D7
- 适用范围：monorepo 内**全部 submodule 的静态资源文件**
- 上位规格：`2026-07-31-storage-architecture-design.md`（下称《总纲》），本协议是其 §5a/§5b 的落地形态，并把适用面从「拆书内容」扩大到全部静态资源

---

## 0. 本协议的定位

### 0.1 要解决的问题

当前每个 submodule 各自管���资源：自己读 asset、自己定格式、自己做缓存。后果有三：

1. **同一份数据出现多个物理副本** —— 已证实：同一套 geo 数据集在 `xuan-qimendunjia/example/assets/dataset/` 与 `xuan-qizhengsiyu/example/assets/dataset/` 下各有一份完整副本（`province_city_area_lng_lat.json` 各 444K）。
2. **换方案要全仓考古** —— 想把资源改为按需下载、或���存储技术，必须逐个模块读源码、逐个改。
3. **没有统一的正确性保证** —— 每个模块自己判断「数据装好了没有」，没有共同的完整性判据。

### 0.2 本协议是什么

**XRAP 是资源管理的唯一真相源。**

- 任何人（含 AI agent）要了解「资源如何被管理」，**读本协议即可，不必读各模块源码**；
- 要更改管理方案（换存储、换分发、换格式），**改本协议 + 各模块按新协议改**，而不是逐模块考古；
- 本协议的每一条规则都**必须对应一个可编译的 Dart 接口签名**。只有文档没有接口的规则，不是本协议的一部分。

### 0.3 协议 ⇄ 代码的对应关系（本协议的立身之本）

规范与代码是**同一件事的两种投影**，不允许出现只存在于文档里的规则：

| 本文档章节 | 对应代码 | 包 |
|---|---|---|
| §2 概念模型 | `DatasetManifest` / `DatasetPayloadFormat` | `persistence_core` |
| §3 模块必须提供什么 | `DatasetDescriptor` / `DatasetRegistry` / `DatasetMaterializer` / `MaterializeOutcome` | `persistence_core` |
| §4 取用与来源链 | `DatasetSource` / `DatasetEndpointProvider` | `persistence_core` |
| §5 安装与生命周期 | `DatasetInstaller` / `InstalledDataset` / `DatasetGenerationStatus` / `InstallOutcome` | `persistence_core` |
| §6 不变式 | `dataset_protocol_test.dart` 契约测试 | `persistence_core/test` |
| §7 禁止事项 | 架构守卫测试 + grep 门禁 | `persistence_core/test` |
| §8 错误诊断 | `DatasetRegistrationError` / `DatasetMaterializerContractError` | `persistence_core` |
| §4 + §5 参考实现 | `BundledDatasetSource`（内置数据源，§4）/ `InMemoryDatasetInstaller`（安装器内存实现，§5）/ `AssetBackedMaterializer`（资产支持的 materializer 契约，供内置载荷读取） | `persistence_core` |

`InstallOutcome` 的五个变体 —— `InstallAlreadyCurrent` / `InstallInstalled` /
`InstallRejectedSchema` / `InstallIntegrityFailed` / `InstallSourceUnavailable`
—— 逐一对应 §5 的五种安装后果，语义见 §5.2 与 §10 的结果表。

**协议一致性门禁**（§8.3）会机械校验这张表：文档里出现的每个接口名必须在代码中存在，反之亦然。

### 0.4 术语

| 术语 | 含义 |
|---|---|
| **资源（resource）** | 官方发布的只读静态数据。对应《总纲》§2.1 的 `DataVisibility.resource` |
| **数据集（dataset）** | 资源的最小管理单位。有稳定 id、独立版本线、独立更新节奏 |
| **世代（generation）** | 同一数据集某个版本在本地的一次完整落地。多代可共存，仅一代活跃 |
| **载荷（payload）** | 数据集的字节内容本身 |
| **清单（manifest）** | 描述某个数据集某个版本的元数据。发布侧产出，安装侧据此判定 |
| **落地（materialize）** | 把载荷变成模块可查询的本地形态（drift 行 / 文件 / 内存索引） |
| **活跃指针** | 记录「某数据集当前用哪一代」的单一事实。读路径的唯一入口 |

---

## 1. 协议的六条根本原则

这六条是本协议的宪法。后续所有规则都是它们的推论；修改它们等于制定新协议。

**P1 · 模块对来源无感。**
业务代码调用同一个查询接口，不感知数据来自内置资源、已下载资源还是别的什么。来源变化不导致业务代码修改。
> 依据：《总纲》§2.1:140

**P2 · 落地形态由检索需求决定，不由传输方式决定。**
「从远端下载」与「落地为什么形态」是正交的两件事。需要按字段查询的落 row；只按 id 整取的落 blob。
> 依据：《总纲》§2.1.2:170。注意该条原文的论据是「要支持按格局查讲解」——**是检索需求推出 row，不是下载推出 row**。

**P3 · 半安装态不可见。**
一个数据集在本地要么是完整可用的旧版本，要么是完整可用的新版本，**不存在"装了一半"的可见状态**。

**P4 · 冷启动不等网络。**
应用启动路径上不得有任何资源相关的网络请求。更新检查只能由显式动作触发。
> 依据：《总纲》§8.4:1300

**P5 · 失败沿用现存，永不空手。**
任何环节失败（网络不可达、校验不通过、版本不兼容），结果都是**沿用当前已有的世代**，而不是让功能不可用。内置世代是永久兜底。

**P6 · 拒绝优于损坏。**
宁可拒绝安装一个可疑的数据集，也不让它落地。所有校验 fail closed。

---

## 2. 概念模型

### 2.1 数据集标识

每个数据集有一个全局唯一、跨版本不变的 `datasetId`。

**命名约定（强制）**：`<域>.<名>`，全小写，下划线分词。
例：`geo.admin_division`、`geo.timezone_boundary`、`tiebanshenshu.tiao_wen`。

`datasetId` 同时用作《总纲》§2.3.1 `StoragePolicyRegistry` 的 `entityType`，两者必须一致。

### 2.2 载体：直接复用 S1a 的 `Carrier`

**本协议不引入新的形态枚举。** S1a 已交付 `enum Carrier { row, blob }`（`core/lib/model/storage_classification.dart:17`），且 `StoragePolicy.resource` 的参数表就是 `Set<Carrier>`。

| 数据集示例 | carriers | 依据 |
|---|---|---|
| 行政区划（3515 行） | `{row}` | 按 code 点查、按 parentCode 树查、按 name 搜 |
| 时区边界（TopoJSON） | `{blob}` | 点在多边形内，SQL 表达不了 |
| 主题包 | `{row, blob}` | 元数据可查 + 资产整取 |

复用的收益：概念不膨胀；且天然获得一条门禁 —— **manifest 声明的 carriers 必须是注册策略 carriers 的子集**，否则拒装。

### 2.3 版本：两个字段，各司其职

| 字段 | 类型 | 作用 | 是否参与兼容判定 |
|---|---|---|---|
| `contentVersion` | String | 人读，展示与诊断 | **否** |
| `minimumAppSchemaRevision` | int | 机械兼容判定的唯一依据 | **是** |

**为什么不用 semver**：semver 要求比较方正确解析并比较字符串，且「1.2.0 → 2.0.0 算不算 breaking」在不同人手里判断不一。整数比大小没有歧义，也没有解析失败的可能。

> 同源教训：S1a 区分「结构性不变式」与「注册期不变式」（《总纲》§2.3.0）—— 不要把正确性寄托在判断力上。

### 2.4 兼容判定方向（D2 · 已定：方向 B）

**发布方声明「读我需要什么水平的 app」，消费方只比大小。**

```
manifest 声明：minimumAppSchemaRevision = 2   ← 发布方做判断
app    声明：appSchemaRevision          = 3   ← 编译期常量
判定：3 >= 2 → 安装
     若 app 为 1：1 < 2 → 拒绝安装，沿用现有世代（P5），不报错
```

这是 `minSdkVersion` 模型：判断「这次结构改动要求消费方具备什么能力」由**发布方**做出并写进清单，消费方不做兼容性推理，只做一次整数比较。

**新增字段而不升 revision 的场景**：只加可选字段、不改已有字段语义时，
`minimumAppSchemaRevision` **保持不变** —— 老 app 忽略新字段照常工作。
只有当「老 app 读了会出错或读出错误结果」时才递增。**这个判断是发布方的责任。**

**已知代价（人类知情后选定）**：发布方一旦判断失误 —— 该升没升 —— 老客户端会装进读不了的数据。协议提供的缓解是**留痕而非阻止**：

- `InstallOutcome` 记录本次判定的两个数值（`requiredRevision` / `appRevision`），出事时可一眼定位是哪次发布、哪个版本区间受影响；
- 完整性自检（不变式 I4：行数比对）仍在下游兜底，结构性损坏在落地阶段仍会被拦截，不会进入 ready。


---

## 3. 模块必须提供什么（接入契约）

每个接入 XRAP 的模块，交付物**恰好以下七项**，缺一不合格。

| # | 交付物 | 形态 |
|---|---|---|
| 1 | `DatasetDescriptor` 注册项 | 装配期代码 |
| 2 | 内置载荷 + 内置清单 | `persistence_assets` 内的文件 |
| 3 | `DatasetMaterializer` 实现 | 模块自己的适配层 |
| 4 | 落地结构（carriers 含 row 时：drift 表 + 索引） | 模块自己的 drift 层 |
| 5 | 领域查询接口 + 实现 | **接口放接口包**，不依赖 `persistence_core` |
| 6 | 差分测试（新实现 vs 旧实现逐字段相等） | 测试 |
| 7 | 删除旧 asset 与旧直读代码 + 门禁断言其消失 | 测试 |

### 3.1 关于第 5 项的依赖方向

领域查询接口必须放在 `repository-interface-*` 接口包内，**不得依赖 `persistence_core`**。
> 依据：《总纲》§0.1:51「`repository_interface_*` 各包不得依赖 `persistence_core`」

现成范本：`repository-interface-tiebanshenshu/lib/src/data_sources/tiao_wen_local_data_source.dart:12`，其注释已写明「实现类负责具体的本地存储技术（TXT 文件 / SQLite / CSV 等）」—— 这正是本协议需要的替换点。

### 3.2 关于第 7 项

**不带删除门禁的"迁移"只会制造第 N+1 份副本。** §0.1 已证实 geo 数据集存在两份完整副本，若无此门禁，接入后会变成三份。

### 3.3 唯一的可插拔点：`DatasetMaterializer`

模块之间的差异**全部收敛到这一个接口**。取载荷、校验、状态机、世代管理、活跃指针翻转、GC —— 全部由协议实现统一负责，模块不得自行实现。

---

## 4. 取用：来源链

### 4.1 来源链顺序

```
已成功安装的世代  >  内置世代
```

与《总纲》§8.4:1297 的配置来源链同构。**是「已安装的」优先，不是「远端」优先** —— 冷启动直接用本地已有世代，零网络（P4）。

### 4.2 内置世代必须预构建，不在设备上解析（D3 · 已定）

内置资源作为 generation 0 参与同一套机制，**但它的载荷是构建期就做好的落地形态，不是原始 JSON/CSV**。

```
构建期（开发机 / CI）            设备上（首次启动）
────────────────────            ──────────────────
原始 JSON/CSV                    直接落位预构建产物
   │  解析 + 建表 + 建索引          （文件拷贝 / 首次打开）
   ▼                              零解析、零建索引
预构建产物（.sqlite 等）  ──────▶  立即可查
   随包发布
```

**硬要求：设备上不得在首次访问时解析原始文本。** 3515 行的 JSON 解析加建索引会让首个用到该数据集的界面卡顿，这是不可接受的。

仓库既有先例：`xuan-qizhengsiyu` 的 `ge_ju_database.sqlite`（440K）就是随包的预构建 SQLite。

由此产生的两条约束：

1. **`DatasetMaterializer` 必须能处理两种载荷**：预构建产物（内置 / 未来可能的远端）与原始文本（远端增量）。协议不规定哪种，由 `DatasetManifest.payloadFormat` 声明；
2. **构建期工具链是接入方的交付物之一**（§3 第 2 项）—— 「把原始数据变成预构建产物」的脚本必须可重复执行、可在 CI 中运行，不能是某个人手工做一次。

**远端世代不受此限**：远端可以下发原始文本并在设备上解析，因为那发生在用户显式触发更新之后（§5.6），不在启动或首访路径上。若远端也下发预构建产物，则设备侧零解析，代价是产物体积通常大于压缩文本。


### 4.3 endpoint 的来源

endpoint 由 `xuan_config` 下发（《总纲》§8.1:1237），�� `persistence_*` **不得 import `xuan_config`**（S5c 记录的既有架构禁令 `no_xuan_config_in_lib_test.dart`）。

因此协议定义窄端口 `DatasetEndpointProvider`，由 app 的 DI 层接线。

### 4.4 不复用配置通道搬运载荷

**禁止**用 `RemoteConfigSource` / `ConfigSource.loadRaw` 拉取数据集载荷。三条理由：

1. `loadRaw → String` 会把整个数据集读进内存字符串；
2. 7 天缓存有效期与 L0 三次确认是配置语义，不是数据语义；
3. 直接违反《总纲》§8.1:1241「下发的永远是指针和开关，**不是内容本身**」。

---

## 5. 安装与生命周期

### 5.1 状态机

```
staged ──→ verified ──→ ready ──→ superseded ──→ (GC)
   └──────── failed ←──────┘
```

### 5.2 安装序列（P3 的实现）

```
1. 取清单     fetchManifest
2. 版本判定   schemaRevision ∈ supportedSchemaRevisions ?  否 → rejectedSchema（不下载，省带宽）
3. 幂等判定   已有同 payloadSha256 的 ready 世代 ?         是 → alreadyCurrent
4. 取载荷     openPayload（支持字节水位续传）
5. 校验       整包 sha256 比对              不符 → integrityFailed（绝不落地）
6. 落地       materialize(generation: N)    只写新世代，不碰活跃指针
7. 自检       实际行数 == 声明行数           不符 → integrityFailed
8. 翻转       单事务改活跃指针               ← 唯一的可见性开关
9. 回收       旧世代转 superseded，择机 GC
```

**第 6 与第 8 步的分离，就是 P3「半安装态不可见」的结构保证**：装到一半的世代对读路径**根本不存在**，而不是"存在但不完整"。

这解决了 row 类资源的一个根本困难：blob 靠内容寻址与分块，「传了 60%」可独立校验（《总纲》§6.1:1046）；而 row 的"装了一半"是**可以被查出来的**，用户会读到残缺数据且无从发现。世代 + 指针翻转让这种中间态不可见。

### 5.3 续传粒度

**只在取载荷阶段续传**（字节水位），落地阶段整代重做。
理由：「解析到第几行」的续传语义会引入无法校验的中间态，与 P3 冲突，不值得。

### 5.4 回滚（D4）

机制支持：superseded 世代在 GC 前仍完整，回滚 = 把活跃指针指回去。
**当前阶段 UI 不暴露**，仅供诊断与故障处置。

### 5.5 GC（D5）

保留最近 1 个 superseded 世代作为回滚窗口，更早的立即回收。
诚实代价：峰值磁盘占用约为两代之和。

### 5.6 更新检查时机（D6）

**冷启动不检查**（P4）。合法触发点仅三个：

1. 用户在设置页手动「检查更新」；
2. 首次用到某数据集且无任何 ready 世代；
3. 显式的业务动作要求最新数据。

---

## 6. 不变式（每条都必须有能变红的门禁）

| # | 不变式 | 强制级别 |
|---|---|---|
| I1 | 活跃指针只能指向 `status == ready` 的世代 | 运行时 + 契约测试 |
| I2 | 从 staged 到 ready 全过程，活跃指针**一个字节不变** | 契约测试 |
| I3 | sha256 不匹配 → **绝不进入 materialize** | 契约测试 |
| I4 | 实际行数 ≠ 声明行数 → **绝不进入 ready** | 契约测试 |
| I5 | schemaRevision 不受支持 → 在**取载荷之前**拒绝 | 契约测试 |
| I6 | 安装全过程 **outbox 零新增** —— 资源不是用户数据 | 契约测试 |
| I7 | 资源行**不进** `t_record_meta` / `t_record_search_index` | grep 门禁 |
| I8 | manifest 的 carriers ⊆ 注册策略的 carriers | 注册期抛异常 |
| I9 | 注册的 policy 必须是 `resource` + `official` | 注册期抛异常 |

**I6 / I7 的理由**：资源数据不属于任何用户，不应产生 oplog，也不应进入 scoped 记录体系。安装器只写资源库自己的 DAO，**绝不经 `ScopedRecordStore`**（后者会生成 outbox 记录）。

> 门禁写作纪律见 §8.2。**一个绿的门禁如果证明不了自己能红，它就是假的。**

---

## 7. 禁止事项

| # | 禁止 | 理由 |
|---|---|---|
| N1 | 模块自行读 asset / 自行缓存 / 自行判断数据是否就绪 | 违反本协议存在的目的 |
| N2 | 用 `ConfigSource` / `RemoteConfigSource` 搬运载荷 | §4.4 |
| N3 | 资源数据经 `ScopedRecordStore` 写入 | 会产生 outbox 记录（I6） |
| N4 | 资源表进主库 `PersistenceDriftDatabase` | §9.1 |
| N5 | 领域查询接口依赖 `persistence_core` | 《总纲》§0.1:51 |
| N6 | 迁移后保留旧 asset 或旧直读代码 | §3.2 |
| N7 | 用 semver 或字符串比较做兼容判定 | §2.3 |
| N8 | 在冷启动路径上检查更新 | P4 |

---

## 8. 验收与门禁

### 8.1 协议级验收（协议本身是否成立）

```bash
cd core && dart analyze --fatal-infos && flutter test
```

必须包含：
- `core/test/dataset_protocol_test.dart` —— §6 的 I1–I9 逐条
- `core/test/dataset_protocol_consistency_test.dart` —— §8.3 的文档⇄代码一致性

### 8.2 门禁写作纪律（血泪，违反即为假门禁）

1. `grep -c` 无匹配时打印 "0" 且退出码 1 ⇒ `EXPECT_STDOUT` 与 `EXPECT_EXIT` **两个都要写**
2. 测试里不要用 `fail()` 做断言 —— 调用方常有 catch-all 会吞掉 `TestFailure`。用**计数式 spy**
3. 文本扫描类门禁**必须有写死的覆盖下限** —— 正则写错扫到 0 个文件时会静默全绿
4. 任何以 `|| true` 结尾的验证命令都是假的
5. `expect(SomeClass, isNotNull)` 是同义反复 —— 必须真的构造实例并驱动行为
6. macOS `/bin/bash` 是 3.2.57 —— 没有 `declare -A`、没有 `mapfile`
7. 每个门禁必须做过「改坏 → 确认变红 → 改回」的自检

### 8.3 协议一致性门禁（本协议可落地的机械保证）

这是 §0.3 那张表的自动校验，也是本协议区别于普通设计文档的地方：

- 本文档中以 `` `Xxx` `` 形式出现的**协议接口名**，必须在 `core/lib/model/dataset/` 下真实存在；
- `core/lib/model/dataset/` 下的每个公开类型，必须在本文档中被提及；
- 任一方向不满足 → 测试红。

**效果**：文档与代码不可能漂移。改协议必然改代码，改代码必然改协议。

### 8.4 模块接入验收（每个 submodule 接入时）

| # | 判据 | 验证方式 |
|---|---|---|
| A1 | 七项交付物齐全（§3） | 逐项检查 |
| A2 | 差分测试通过：新旧实现在全部查询上逐字段相等 | 单测 |
| A3 | 旧 asset 与旧直读代码已删除 | grep 门禁，期望零命中 |
| A4 | 安装全过程 outbox 零新增 | 单测 |
| A5 | 冷启动零网络请求 | 计数式 spy |
| A6 | 断电模拟：安装中断后活跃指针仍指旧世代 | 单测注入中断 |

**A2 是唯一装不了假的 oracle** —— 它验的不是「测试通过」，而是「新旧实现不可区分」。

---

## 9. 落地约束

### 9.1 资源落在独立数据库，不进主库

**独立 `ResourceDatasetDatabase`，schemaVersion 从 1 起。**

四条理由：

1. **资源无主，主库是 scoped 的** —— 主库 22 张表中仅 4 张带 `scope_uid`，而 `ScopedRecordStore` 每个方法都要 scopeUid。资源不属于任何用户。
2. **避免 schemaVersion 争抢** —— 主库现为 6（`drift/lib/persistence_drift.dart:541`），S1b 已在 ACT 中写死 7 并带 grep 门禁（`docs/storage-s1b-multipeer/act/03.yaml:151`）。资源若入主库将形成三方争抢，而 schemaVersion 是语义全序，撞号会让用户数据库走错迁移分支。
3. **备份语义不同** —— 用户数据必须备份，资源丢了重下即可。
4. **卸载干净** —— 「清理已下载资源」是删一个库文件，不必在主库做外科手术。

本仓库既有惯例支持这一点：drift 包内已有 7 个独立库各自管版本（`four_zhu_card_templates` v7、`ai` v3、`meihua` v1、`account` v1、`taiyi` v1 等）。

### 9.2 blob 类载荷不走 `LocalBlobStore`

**这是对《总纲》§3.2 的一处有意偏离，明确记录以供否决。**

`LocalBlobStore` 带 `String get scopeUid`（`core/lib/model/local_blob_store.dart:23`）且挂载 `BlobCipher` 机制。资源是无主、公开、官方数据：scopeUid 无从填写，加密无意义。因此 blob 类载荷落安装器自管目录。

---

## 10. 待拍板

| # | 事项 | 结论 |
|---|---|---|
| D1 | 版本标识形态 | ✅ **已定**：`contentVersion`(人读) + `minimumAppSchemaRevision`(机械)，不用 semver |
| D2 | 兼容判定方向 | ✅ **已定（人类 2026-08-02）**：方向 B —— 发布方声明所需 app 水平，消费方比大小（minSdkVersion 模型） |
| D3 | 内置资源是否算一个世代 | ✅ **已定（人类 2026-08-02）**：算，**但必须预构建**，设备上零解析 |
| D4 | 回滚是否暴露给用户 | 机制支持，UI 不暴露 |
| D5 | GC 保留几代 | 保留 1 个 superseded 作回滚窗口 |
| D6 | 更新检查时机 | 冷启动不查，仅三个显式触发点 |
| D7 | manifest 是否 ed25519 验签 | 倾向签。复用 S5c 现成验签器，但强依赖 `ConfigBootstrap.l0PublicKeyBase64` 真值（现为占位符） |

### 10.1 已知阻塞

`ConfigBootstrap.endpoints / allowedHostSuffixes / l0PublicKeyBase64` 三个值目前均为占位符（S5c 纪要列为「待人类确���」）。

**不阻塞内置世代路径与全部机制建设**（注入 fake source 即可测试），仅阻塞真实远端下载。D7 若选签名，则强依赖公钥真值。

---

## 11. 决策记录

| 决策 | 结论 | 被否决的替代方案与理由 |
|---|---|---|
| 形态枚举 | **复用 S1a 的 `Carrier`** | 新造 `DatasetShape{row,opaque,hybrid}` —— 概念膨胀，且与 `StoragePolicy.resource` 的参数表重复 |
| 落地形态的判据 | **由检索需求决定** | 「数据资源一律落 row」—— 时区边界是 TopoJSON，点在多边形内 SQL 表达不了，硬拆成 row 是主动做错 |
| 兼容判定 | **发布方声明 `minimumAppSchemaRevision`，消费方比大小**（人类 2026-08-02 定，方向 B） | ①semver —— 需解析与比较字符串，且 breaking 的界定因人而异；②消费方声明支持集（方向 A）—— 每次结构升级都要发新版 app 才能用上新数据，人类判定该代价更高 |
| 内置世代形态 | **预构建产物随包，设备上零解析**（人类 2026-08-02 定） | 设备上解析原始 JSON —— 3515 行解析加建索引会让首访界面卡顿，不可接受 |
| 半安装态 | **世代 + 单事务指针翻转** | 边下边写 —— row 的"装了一半"可被查出，用户读到残缺数据且无从发现 |
| 续传粒度 | **仅字节水位，落地整代重做** | 行级续传 —— 引入无法校验的中间态，与 P3 冲突 |
| 资源库位置 | **独立 `ResourceDatasetDatabase`** | 进主库 —— 与 S1b(v7) 争抢 schemaVersion；且资源无主而主库 scoped |
| 载荷传输通道 | **自建 `DatasetSource`** | 复用 `RemoteConfigSource` —— `loadRaw→String` 全量进内存；违反《总纲》§8.1:1241 指针/内容分离 |
| blob 载荷落点 | **安装器自管目录** | `LocalBlobStore` —— 带 scopeUid 与 cipher，对无主公开数据无意义 |
| 内置资源 | **作为 generation 0 参与统一机制** | 单独读路径 —— 零首访开销，但要永久维护两条读路径 |

---

## 12. 要换方案时改哪几节（本协议的使用说明）

这是 §0.2「改协议而非考古」的兑现方式。按你要换的东西查表：

| 你想换的东西 | 改本协议的 | 改代码的 | **不动** |
|---|---|---|---|
| 换分发后端（Firebase → 自建 REST/CDN） | §4.3 | 新增一个 `DatasetSource` 实现 | 全部模块、安装器、落地层 |
| 换本地存储（drift → 其他） | §9.1 | 各模块的 `DatasetMaterializer` 实现 | 协议契约、安装器、领域接口 |
| 改版本兼容策略 | §2.3、§2.4 | `DatasetManifest` / `DatasetDescriptor` 字段 | 各模块落地层 |
| 加一种载体形态 | §2.2 | S1a 的 `Carrier` 加枚举值 | 安装器状态机 |
| 改更新时机策略 | §5.6 | `DatasetInstaller` 调用点 | 全部契约 |
| 改 GC 策略 | §5.5 | `DatasetInstaller` 实现 | 全部模块 |
| 加签名 / 换签名算法 | §10 D7 | 安装序列第 5 步 | 全部模块 |
| 新增一个数据集 | 不改 | 按 §3 交付七项 | 协议与全部既有模块 |

**最后一行是本协议的核心价值**：接入新资源不需要改协议，也不影响任何既有模块。
