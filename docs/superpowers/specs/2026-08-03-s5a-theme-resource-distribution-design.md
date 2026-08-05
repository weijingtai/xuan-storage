# S5a 样式资源分发 · 详细设计

- 日期：2026-08-03（**v4**，2026-08-04 按人类四条裁定并入 XRAP，范围大幅收窄）
- 状态：范围已裁定，待转译为 ACT
- 范围：**主题包的 XRAP Materializer 实现 + 用户覆盖层**。下载 / 校验 / 世代 / 指针翻转 / 回滚 / GC / 幂等**全部归 XRAP**，S5a 不再自建
- **交付形态：契约 + reference 实现**（方案 B）
- 上游文档：
  - [2026-07-31 Storage 分层隔离存储架构 · 设计总纲](2026-07-31-storage-architecture-design.md)（下称"总纲"，引用格式 `总纲 §x.y:行号`）
  - **XRAP 资源资产协议**（S5b 交付，已合入 `main`）：`core/lib/model/dataset/` 七个契约文件
  - `xuan-storage/tasks/mimo-storage-s1a-contracts.md`（S1a 契约层，已交付并已合入本仓库 `main`）
  - `xuan_config/tasks/mimo-config-s5c-remote-source.md`（S5c 控制下发，已交付，最新提交 `a324902`）
  - `/xuan-migration/openspec/changes/theme-token-customization-contract/`（在途 OpenSpec change，含 4 轮评审）

---

## 0. 本文档的定位

本文档是 **S5a 的详细设计**，不是 ACT。下游流程是 `wjt-act` 转译 → `wjt-react` 跨模型闸门 → 下发执行。

### 0.0 ⚠️ v4 范围裁定：S5a = XRAP 的一个 Materializer + 一层 XRAP 拒收的用户覆盖

**2026-08-04 人类四条裁定**（均有代码依据，不再重新论证）：

| # | 裁定 | 代码依据 |
|---|---|---|
| 1 | **XRAP 能承载主题包**。v3 担心的"blob 资产 XRAP 装不下"是误判 | `Carrier` 枚举本就是 `{row, blob}`；`DatasetManifest.declaredRowCount` 注释明写"纯 blob 数据集为 null" |
| 2 | **XRAP 承载不了用户覆盖层，且是硬拒** | `dataset_registry.dart:62-68` 要求 `publisher == official`，否则注册期抛 `DatasetRegistrationError`（不变式 I9）。用户覆盖的 publisher 不可能是 official |
| 3 | **边界不在"是不是主题"，在"谁发布"** | `dataset_installer.dart:188-192` 写死"唯一实现，数据集无关，差异由各自的 `DatasetMaterializer` 承担"。再写一个主题专用安装器直接违反它 |
| 4 | **`ConfigBootstrap` 三个占位符不是 S5a 的阻塞项** | `dataset_source.dart:61` 明写"未配置返回 null（此时只用内置世代）"；`bundledManifest` 恒存在、冷启动零网络。实证：T1 已交付完整接入样板（main `6cd7a66`，geo 三数据集），全程 generation 0，未用到任何域名或公钥 |

**由此得出的范围划分**：

| 能力 | 归属 | S5a 的动作 |
|---|---|---|
| 下载 / 校验 / 世代管理 / 活跃指针翻转 / 回滚 / GC / 幂等 | **XRAP** | ❌ S5a 不提供任何安装类方法与安装态类型；主题包格式、签名、版本兼容规则一律不由本设计定义 |
| 主题包字节 → 落地形态 | **S5a** | ✅ 写 `InMemoryThemeMaterializer implements DatasetMaterializer` —— **唯一可插拔点**（不另包 `ThemeMaterializer` 子接口，见 §4.2） |
| override > package > bundled 三层合并 | **S5a** | ✅ 保留（XRAP 完全没有） |
| `applyOverrides` / `removeOverrides` / orphan 判定 / 读写不对称 | **S5a** | ✅ 保留（XRAP 硬拒非 official publisher） |

> **一句话：S5a = XRAP 的一个 Materializer + 一层 XRAP 拒收的用户覆盖。**

**接入样板**：T1 的 `assets/lib/geo/geo_datasets.dart`（main `6cd7a66`）是首个 XRAP 接入实例 —— 3 个 `DatasetDescriptor` + `DatasetManifest`（sha256/bytes/rowCount 真值）+ 一个最小 `Materializer`。S5a 照此形制写。

### 0.1 本文档要确定的

1. S5a 在 XRAP 中的落地器（`DatasetMaterializer` 实现）及其对协议的遵守；
2. 用户覆盖层的存储、合并语义与读写契约；
3. 四个仓库的职责边界，以及为什么 `theme` 包不该改；
4. 三层合并算法的完整规格（§6.6）；
5. 启动路径的性能预算与可验证判据。

### 0.2 交付形态：契约 + reference 实现（方案 B）

**S5a 交付两层**：

| 层 | 内容 | 位置 |
|---|---|---|
| **契约层** | 端口签名 + 值类型 + 策略声明（零实现） | `core/lib/model/theme_*.dart` |
| **reference 实现层** | `InMemoryThemeResourceStore` —— 纯内存、无 IO、无网络的完整行为实现 | `core/lib/reference/in_memory_theme_resource_store.dart` |

**为什么需要 reference 实现（否决"纯契约"的理由）**：

三层合并、差量写入、缓存 identical、启动零网络 —— 这些是 S5a 的**核心价值**，而抽象接口产生不了行为，无法验证。若砍掉这些验收，S5a 只剩一堆没人用过的接口。

**反面教训就在本仓库**：S1a 交付了纯契约，结果 `StoragePolicyRegistry` **至今零生产调用点**（§1.6 实查），没有任何证据表明它好不好用。S5c 走的是"契约 + 一个真实现"，交付质量明显更高（A1–A13 全过 + 5 条返工均能定位到具体失守门禁）。

**reference 实现的定位与边界**：

1. **它是行为规格的可执行形式**，不是生产实现。生产实现（drift + blob + 下载器）是后续子任务；
2. **它必须零 IO**：不碰文件系统、不发网络、不依赖 drift。全部状态在内存 Map 里；
3. **它是后续生产实现的对照基准** —— 同一套契约测试必须能同时跑通 reference 实现与将来的 drift 实现（测试对端口编程，不对实现编程）；
4. **它承载 §6.6 的合并算法**。合并算法必须只有一份权威定义，生产实现复用它而非重写。

**因此本文档中的 Dart 代码块分两类，各自标注**：
- 标 `【契约】` 的是端口签名，零实现；
- 标 `【reference】` 的是必须实现的行为，其算法在 §6.6 有完整规格。

---

## 1. 现状核实

以下全部为实查结果，非推断。行号可复核。

### 1.1 主题的真实形态：纯 YAML，零二进制

`/xuan-migration/theme/config/presets/` 下 4 个预设：

| 文件 | 体积 | components | variants | semantic | chart |
|---|---|---|---|---|---|
| `default.yaml` | 9.1K | 16 | 6 | 4 | 4 |
| `dark.yaml` | 5.1K | 14 | 1 | 0 | 1 |
| `ai-starry-bronze.yaml` | 8.3K | 15 | 2 | 1 | 4 |
| `ai-mingli-ink.yaml` | 8.2K | 15 | 2 | 1 | 4 |

`config/` 全目录 **64K**。全仓库搜 `.png/.jpg/.ttf/.otf/.webp` 只有 4 个 golden 测试截图，**没有任何随主题分发的字体或图片**。字体走 `google_fonts: ^6.2.1`（`theme/pubspec.yaml`），运行时按 family 名取，不打包。

**因此总纲 §2.1.2:162「每个数 MB（图/字体）」在当前时点不成立。** 但人类已确认二进制资产（TTF / PNG icon / SVG / Lottie JSON）**将来必定引入**，故 blob 链路仍须建设 —— 见 §2.1。

### 1.2 `theme` 包是纯内存映射层，零 IO

`theme/lib/` 共 **20** 个 dart 文件。搜 `SharedPreferences|dart:io|File(|drift|sqlite|http` **零命中**。

`theme/lib/src/loader/token_loader.dart:11` 的注释自陈边界：

> 内部类：theme 层禁止读取 YAML / 解析 `$ref` / 执行 schema 校验（那是 xuan_config 的事）。

它唯一的外部依赖是注入进来的 `ConfigRepository`（:29 调 `loadThemeConfig`），失败降级 `DefaultXuanThemeData.themeSet`（:32）。

**结论：`theme` 的职责是「给定已解析的 token → 产出 `XuanThemeSet`」的纯函数库。保住它零 IO 是本设计最有价值的约束之一。**

### 1.3 shell 侧的主题链路当前空转

- `xuan-shell/lib/theme/shell_theme_controller.dart` 是真正的 Controller（`ChangeNotifier`，持有 `XuanThemeSet` + `ThemeMode`）。
- 它的 `initialize()` 调 `ShellThemeLoader.loadAndValidate(...)` 两次，但该方法签名是 `Future<void>`（`shell_theme_loader.dart` 末），**只做校验不产出主题**，返回值无从接收。
- 因此 `_themeSet` 始终是构造器里的 `DefaultXuanThemeData.themeSet`（代码内置默认）。
- `xuan-shell/assets/themes/default.yaml` 全文 **203 字节**（`dark.yaml` 为 197 字节），`light`/`dark` 下的 `semantic`/`components`/`chart` 全是空 Map；与 `theme/config/presets/default.yaml`（9.1K，`version: 2`）**不是同一份**，shell 侧是 `version: 1` 的空壳。

**结论：当前 app 渲染的是代码内置默认主题，YAML 链路接通但空转。**

人类已确认：这是因为完整的主题 style YAML 配置尚未产出，**不属于 S5a 要解决的问题**。S5a 只管契约与机制，不管主题内容本身。

### 1.4 缺失的接口：可跨设备的用户偏好空间

`preferences/lib/persistence_preferences.dart` 仅导出三项，全部是业务专用实现，底层 SharedPreferences，且搜 `OutboxStore|SyncPeer|RemoteGateway` **零命中 —— 不参与同步**。

**没有通用的、可跨设备同步的用户偏好端口。** 而主题偏好（用哪个主题、用户的覆盖差量）必须跨设备。这是 S5a 必须新建的东西，**不能假设已存在**。

### 1.5 消费侧的性能事实

- `theme/lib/src/tokens/xuan_theme_data.dart:20`：`ComponentStyle component(String id) => components[id] ?? ComponentStyle.empty;` —— **O(1) Map 查找，永不返回 null**。
- `theme/lib/src/scope/xuan_theme_scope.dart:25`：`updateShouldNotify` 用 `themeData != oldWidget.themeData`，而 `XuanThemeData extends Equatable`，`props = [components, chartTokens, semanticTokens]`（`xuan_theme_data.dart:32`）—— **是整个 component Map 的深比较**。

### 1.6 S1a / S5c 已交付且可依赖的地基

S1a（`persistence_core`，已交付）：`DataVisibility`/`Publisher`/`Carrier`/`Source`/`Channel`/`Encryption` 六个 enum、`StoragePolicy` 类族与 `StoragePolicyRegistry`、`LocalBlobStore` + `BlobCipher` + `BlobHandle`/`BlobTier`/`BlobStatus`、`BlobGateway`、`RecordBlobUnitOfWork`。全部零实现契约，已在 barrel 导出。

⚠️ `StoragePolicyRegistry.register` **至今零生产调用点**（只在 core 的两个测试文件里出现）。S5a 若落地策略注册，将是**第一个生产装配入口**。

S5c（`xuan_config`，已交付，`a324902`）：`RemoteConfigSource`（`fetch`/`probe`/`capabilities`）、`WatchableConfigSource`、`ConfigFetchResult` 三态、`FirebaseHostingConfigSource`、`RuntimeConfigRepository`（有序源链 + offline-first + `ResolvedConfig` 四溯源字段）、L0 ed25519 验签、`isTrustedEndpoint` 七条白名单、缓存中毒缓解。

ℹ️ **`ConfigBootstrap.endpoints` / `allowedHostSuffixes` / `l0PublicKeyBase64` 三个真值仍是占位符**（`'config.invalid'` / `'invalid'` / 含"占位"字样），待人类填入。

**这不是 S5a 的阻塞项**（§0.0 裁定 4，全文唯一口径）：`dataset_source.dart:61` 明写"未配置返回 null（此时只用内置世代）"，`bundledManifest` 恒存在、冷启动零网络；T1 实证全程 generation 0，未用到任何域名或公钥。状态登记见 §9.2，**不得写入 S5a 的 stop conditions**（§11.4 的五条均与 `ConfigBootstrap` 无关）。

---

## 2. 关键设计决定

### 2.1 决定一：整包分发（方向 A），不做 token/资产分半

**主题包是一个自包含的原子单元**：manifest + token + 资产，整体分发、整体安装、整体卸载。

被否决的替代方案（方向 B · 分半）：token 继续走 `xuan_config` 配置链，资产走 blob 链，靠 manifest 对齐版本。

| | 整包（采纳） | 分半（否决） |
|---|---|---|
| 版本对齐 | **问题消失** —— 包内自带版本，包即原子单元 | 「token 说要 `bg_v2.png`，blob 里只有 v1」是永久负担 |
| 将来的 Marketplace | 交换单元天然是"一个主题" | 上传要打包两半，用户心智负担 |
| 卸载 | 删包即可，原子 | 要清两处，永远无法原子 |
| 代价 | 主题内容来源需从配置链迁移到主题仓库 | 不动现有链路 |

**决定理由的核心**：总纲 §10:1583 把"主题包的格式、版本兼容"列为 S5a 待决问题，而整包分发让"版本兼容"退化为单一维度（包的 schema 版本），分半则会产生 token 版本 × 资产版本的二维兼容矩阵。

**当前时点的现实**：资产尚不存在，故 v1 主题包在物理上就是"一个 manifest + 一份 token YAML"。**但格式必须从第一天就为资产留位**，否则加资产时要破坏性升级。

### 2.2 决定二：`theme` 包零改动

依赖方向铁律：

```
xuan-shell（装配层）
   ├──> theme            （纯函数：token → XuanThemeSet）
   ├──> xuan_config      （控制平面：下发指针）
   └──> persistence_*    （数据平面：搬字节、存行）

theme  ──X──>  persistence_*      禁止
persistence_* ──X──>  theme       禁止
```

**`theme` 不得依赖任何 `persistence_*` 包**，否则破坏 §1.2 核实到的零 IO 边界。
**`xuan-storage` 不得依赖 `theme`**，否则数据平面反向依赖 UI 层。

因此 S5a 的输出必须是**源无关的中立 token 结构**，由装配层适配成 `theme` 能吃的形状。`TokenLoader.fromConfigResult`（`token_loader.dart:15`）这个入口已经存在，不需要新建。

> ⚠️ 已知摩擦点：`TokenLoader.loadSetOrDefault`（:24）直接依赖具体类 `ConfigRepository`，而后者只持有**单个** source（`config_repository.dart:10`），装不下三层合并。
> **处置**：装配层改用 `fromConfigResult`（纯函数）+ 自行组装，不用 `loadSetOrDefault`。后者是 Phase 0a 遗留（其注释自陈"Phase 0a 的 app-entry/测试用它"）。`theme` 包本身仍零改动。

### 2.3 决定三：用户覆盖层 = `private` 类，落 drift，可同步

用户"装了 A 主题但四柱卡片用自己的设计"这件事，按总纲 §4.1:837 的判据（**这份数据我能不能改？能改 → 本地是真相源**）归类：

| | 已安装主题包 | 用户覆盖层 |
|---|---|---|
| Visibility | `resource` | **`private`** |
| Publisher | `official`（当前） | **`user`** |
| Carrier | `row`（元数据）+ `blob`（资产） | **`row`**（当前；将来用户传自制资产才有 blob） |
| 能否修改 | 只读 | **可写，本地即真相源** |
| 跨设备 | 不需要（重新下载即可） | **需要** —— 走现有 outbox 同步引擎 |
| 存储 | 主题仓库（drift row + blob） | **drift**，`private` 类 |

**不放 `preferences` 包的三条理由**：
1. SharedPreferences 零同步能力（§1.4 已核实），换设备用户的创作就没了；
2. 它实质是"用户的创作"，将来 Marketplace 开放时是 UGC 主题的雏形，塞进 JSON string 无法直接取出；
3. 它有 schema、需要校验与版本迁移，string blob 不适合承载。

**归为 `private` 类的意义与边界（诚实分类，勿过度推导）**：

| 说法 | 是否成立 |
|---|---|
| 归 `private` 后**自动**获得同步 / E2EE / 导出 | ❌ **不成立** —— 标策略不会自动创建 drift 表、mapper、outbox enqueue、remote apply |
| `private` 类**有资格**走这些能力，且策略层不构成阻碍 | ✅ 成立 |
| 能力真正落地需要后续 `persistence_drift` 适配（建表 + codec + outbox 接入） | ✅ 这是后续子任务，不在 S5a |

> ✅ **S5a 契约层与 reference 实现不依赖 S1b**：reference 实现是纯内存的，不涉及任何同步。
> ⚠️ **但"可跨设备同步"这个产品目标依赖后续的 drift + outbox 集成**（单 peer 即可，仍不需要 S1b 的多 peer fan-out）。
> 两句话必须分开说 —— 混为一谈会让执行者以为 S5a 交付完就自动有跨设备能力。

### 2.4 决定四：存差量，不存拷贝

用户覆盖只存**被改动的 token 差量**，不拷贝主题包的其余内容。

被否决的两个替代方案：

| 方案 | 否决理由 |
|---|---|
| 生成一个合并后的 C 包 | ①A 包升级后 C 不跟随，用户永远停在旧版；②存储放大（试三个主题各改一处 = 三份近乎完整拷贝，资产引入后更严重）；③无法区分"用户显式设定"与"A 的默认值"，做不出"恢复默认" |
| 从 A 拷完整 YAML，只替换字段 | 同上 ① 和 ③ —— **坏处不在于拷成包还是拷成文件，而在于"拷了不该拷的"** |

**C 包唯一该出现的时机**：用户显式点击"导出为主题 / 上架"。那是一个低频、用户知情的动作，不是每次改颜色都在背后生成包。

> 📌 与 blob 引用计数的对比（总纲 §3.2.2:586）：blob 用 `reconcileRefs`（幂等**全量**声明），主题覆盖用**增量** patch。二者相反，原因是场景不同 ——「这条记录引用哪些 blob」天然全量可知；「用户覆盖了哪些 token」可能有数十条而一次编辑只碰一两条，全量声明会强迫调用方先读全量，引入读改写竞态。

### 2.5 决定五：读写不对称

- **读** = 合并后的完整结果（override > 已装主题包 > bundled 默认）
- **写** = 只作用于用户覆盖层

二者**不是逆运算**，契约命名必须防止误解。若设计成对称的 `read()` / `write(整份)`，会把主题包内容与用户覆盖混成一坨写回覆盖层，摧毁 §2.4 的差量模型。

### 2.6 决定六：写入用批量差量 patch + 显式删除

```
applyOverrides(patch)      // 新增/修改覆盖，一次多 key，原子提交
removeOverrides(keys)      // 删除覆盖，恢复到下层
```

三种候选写法的比较：

| 写法 | 否决/采纳理由 |
|---|---|
| 整体覆盖 `save(整份)` | 摧毁差量模型（退回"拷贝 A 包"）；读改写竞态：两处 UI 同时改不同字段会互相覆盖 |
| 单字段写 `set(key, value)` | 一次编辑常涉多字段（拖阴影滑块 = color + blur + offsetX + offsetY），四次独立写 = 四次 UI 重建 + 中间态闪烁 + 崩溃留半套值 |
| **批量差量 patch（采纳）** | 是前两者的上界：单字段是它的特例；原子提交、一次通知、无中间态 |

**必须配 `removeOverrides` 的原因**：`applyOverrides` 无法表达"删除覆盖恢复默认" —— 传 `null` 有歧义（是"设为空值"还是"删除这条覆盖"）。"恢复全部默认" = `removeOverrides(全部已覆盖 key)`。

---

## 3. 分层与职责边界

### 3.1 四仓库分工

| 仓库 | 职责 | 判据 |
|---|---|---|
| **`xuan_config`** | 下发**指针**：`defaultThemeId`、主题清单 endpoint、`serverEndpoints`、功能开关。L0 验签 + 白名单 + offline-first 源链 | 控制平面（总纲 §8.1:1241「下发指针不下发内容」） |
| **`xuan-storage`** | 搬**字节**、存**行**：主题包下载（blob）、已装主题元数据（row）、用户覆盖差量（row，可同步）、缓存与 GC。**S5a 主战场** | 数据平面，唯一有 drift + blob 端口 + 同步引擎的地方 |
| **`theme`** | token → `XuanThemeSet` 的纯映射 + 内置默认兜底 | 现状已如此且零 IO（§1.2） |
| **`xuan-shell`** | 装配：接三层 token 源、喂给 `theme`、响应用户切主题 | DI 归宿（总纲 §3.1:446） |

### 3.2 运行时流程（修正版）

```
① Shell 启动 · DI 装配
   构造 ThemeResourceStore（storage 侧）+ RuntimeConfigRepository（config 侧）

② 决定"用哪个主题"—— 用户优先
   ├─ 用户显式选择（private / drift，可跨设备）   ← 选过就用这个
   └─ xuan_config 下发的 defaultThemeId（L1）      ← 没选过用官方推的（春节主题走这条）

③ 取主题内容（本地，零网络）
   ├─ 已安装主题包？→ 取（row 元数据 + blob 资产）
   └─ 没有 → 用 bundled 默认，同时后台触发下载

④ 叠加用户覆盖差量（private / drift）
   三层合并：override > 已装主题包 > bundled 默认，逐 key 取第一个命中

⑤ 合并结果 → theme 包纯函数
   TokenLoader.fromConfigResult(...)     ← 入口已存在

⑥ ShellThemeController.setThemeSet(结果) → notifyListeners()
   → XuanThemeScope 重建

⑦ Widget 消费
   XuanThemeData.maybeOf(context)?.component('four_zhu_card')
   → radius / padding / background / border / shadow / text / icon ...
```

**与直觉的关键差异**：③④ 在装配层（或 storage 提供的门面）完成，**不在 `theme` 包内**。`theme` 只承担 ⑤，是纯函数。

### 3.3 Marketplace 的位置

人类已确认：**当前完全不做**，将来抽象为**独立包/子模块**，不进 `theme` 也不进 `xuan-storage`。

S5a 现在必须满足的三条前瞻约束（总纲 §9.1:1513「S5a 的主题仓库与安装逻辑照常建设，因为它与将来的用户主题同构」）：

1. **主题包格式即公开稳定版** —— 将来用户按同一格式上传，格式一旦下发过就极难改；
2. **下载/安装/卸载机制与 publisher 无关** —— `Publisher.official / user` 不进入机制代码，只进入"来源与信任"层；
3. **`Source` 加 `marketplace` 必须是纯增量** —— 总纲 §2.1:134 已承诺"加一个枚举值 + 一个源实现 + 策略声明加一项，不触及其余"，端口形状要保证这条真能成立。

---

## 4. S5a 在 XRAP 中的 Materializer —— 唯一可插拔点

> **v4 重写**。v3 的「主题包格式（zip + manifest.yaml + 版本兼容规则 + 签名）」整章删除 ——
> 那是 XRAP 的 `DatasetManifest` + `DatasetInstaller` 的职责（§0.0 裁定 3）。
> 本章只写 S5a 真正要写的东西：把已校验的载荷落成主题 token。

### 4.1 XRAP 侧的事实（S5a 只消费，不重定义）

| 事实 | 出处 | 对 S5a 的含义 |
|---|---|---|
| `DatasetMaterializer` 是**唯一可插拔点**，取载荷/校验/状态机/世代/指针翻转/GC 一律由协议实现统一负责 | `dataset_materializer.dart:1-5`（协议 N1） | S5a 只实现 `materialize` 与 `dropGeneration` 两个方法 |
| 调用 `materialize` 时**已完成 sha256 校验** | `dataset_materializer.dart:43-45` | S5a **不再校验完整性**，只管解析与写入 |
| 实现**只写入入参给定的 generation，不得触碰其它世代** | `dataset_materializer.dart:34-35` | 主题落地结构必须有世代判别列 |
| 实现**不得改动活跃指针** —— 翻转由安装器在独立事务内完成 | `dataset_materializer.dart:35-36`（协议 P3） | S5a 不实现"切换到新主题"的原子性，那是 XRAP 的 |
| `dropGeneration` **必须幂等** | `dataset_materializer.dart:62` | 删不存在的世代是正常调用，不是错误 |
| 长耗时解析应在独立 isolate 内完成 | `dataset_materializer.dart:37` | YAML 解析走 isolate |
| `MaterializeOutcome.rowCount` 会与 `DatasetManifest.declaredRowCount` 比对，不符则**不进入 ready** | `dataset_materializer.dart:13-15`（不变式 I4） | S5a 必须返回真实行数 |
| 纯 blob 数据集 `rowCount` 返回 0 | `dataset_materializer.dart:12` | 主题当前是 token（row 形态），返回真实 token 条数 |

### 4.2 S5a 不定义主题专属的 Materializer 接口

**S5a 直接实现 XRAP 的 `DatasetMaterializer`，不再包一层 `ThemeMaterializer`。**

> 📌 **v5 修正**（Codex R3 P2）：v4 曾定义
> `abstract interface class ThemeMaterializer implements DatasetMaterializer {}`
> 且明确"不新增任何方法" —— 那是一个类型别名级的空接口，**没有唯一消费者**：
> XRAP 的 `DatasetDescriptor.materializer` 字段类型是
> `DatasetMaterializer Function()`（`dataset_descriptor.dart:44`），它既不认识也不需要
> 这个子接口。保留它只会多一个文件、多一层间接。**已删除。**

因此 S5a 侧的落地器就是一个普通实现类：

```dart
// core/lib/reference/in_memory_theme_materializer.dart
final class InMemoryThemeMaterializer implements DatasetMaterializer { ... }
```

其精确签名见 §4.4 末尾。**必须遵守 §4.1 那八条 XRAP 事实**，尤其：
只写入参给定的 generation、不改活跃指针、不重复校验 sha256、`dropGeneration` 幂等。

⚠️ **若实现时发现需要在 `DatasetMaterializer` 之外新增扩展点**，说明 XRAP 协议有缺口，
应走协议变更流程，不得在 S5a 侧绕过（否则违反"唯一实现，数据集无关"）——
这是 stop condition #4。

### 4.3 载荷格式（唯一答案，不留选择）

XRAP 要求内置世代的 `payloadFormat` **必须**是 `DatasetPayloadFormat.prebuilt`
（`dataset_descriptor.dart:33-37`，注册期强制，设备上零解析是硬要求）。

**格式定为 JSON Lines（`.jsonl`），UTF-8，LF 换行，每行一个扁平 token。**

> 否决 `*.sql`（T1 用的形态）：主题 token 的落地结构在 S5a 阶段是内存 Map
> （reference 实现），生产实现才进 drift。用 SQL 会把落地结构过早绑死在 SQLite 上，
> 且 reference 实现要为了消费 SQL 而引入解析器 —— 违反"零 IO、零依赖"。
> JSON Lines 可逐行流式消费，与 `Stream<List<int>>` 入参天然契合。

#### 行 schema（每行一个 JSON 对象，字段固定三个）

| 字段 | 类型 | 说明 |
|---|---|---|
| `k` | string | 扁平 token key，形如 `light.components.four_zhu_card.shadow.color` |
| `v` | any | token 值（string / num / bool / List / null）。**不得是 Map** —— 嵌套已在构建期展平 |
| `t` | string | 值类型标记：`s`/`n`/`b`/`a`/`z`（string/number/bool/array/null），供落地层做类型校验 |

⚠️ **不含 `g`（generation）字段**。XRAP 的 generation 是**运行时**安装器调用
materializer 时传入的落地世代号（`materialize(generation:)` 入参），不是构建期可预知的
包内容；同一载荷重装、回滚后重落地或安装到不同设备时 generation 可以不同
（`dataset_materializer.dart:50-56` 明写"generation 由调用方提供"）。
**若把运行时 generation 写进载荷并要求相等，合法载荷会在第二次落地时被拒绝。**

Materializer 实现用**入参** generation 作为落地物的第一层 key（落地物存在共享 store 里，见 §4.4 / §4.5）：

```dart
@override
Future<MaterializeOutcome> materialize({
  required DatasetManifest manifest,
  required Stream<List<int>> payload,
  required int generation,
  CancellationToken? cancel,
}) async {
  final tokens = <String, dynamic>{};
  var rowCount = 0;
  var bytes = 0;
  // Stream<List<int>> → 逐行 UTF-8 解码。载荷是 LF 分隔的 JSON Lines。
  await for (final line in payload
      .map((chunk) { bytes += chunk.length; return chunk; })
      .transform(utf8.decoder)
      .transform(const LineSplitter())) {
    if (line.isEmpty) continue;                 // 末行 LF 产生的空串，跳过
    final j = jsonDecode(line) as Map<String, dynamic>;
    if (j['v'] is Map) {
      throw StateError('token 值不得是 Map（嵌套应在构建期展平）: ${j['k']}');
    }
    tokens[j['k'] as String] = j['v'];          // 只读 k/v/t，载荷里没有 g
    rowCount++;
  }
  _tokens.putGeneration(generation, tokens);    // 用入参 generation，不读载荷
  return MaterializeOutcome(rowCount: rowCount, bytesOnDisk: bytes);
}
```

⚠️ 上面这段是**可编译形状的示意**，三处易错点已写死，不许自行发挥：
`payload` 是 `Stream<List<int>>`（不是 `Uint8List`）；`MaterializeOutcome` 只有**默认构造器**
`MaterializeOutcome({required rowCount, required bytesOnDisk})`，**没有** `.success` 命名工厂
（`dataset_materializer.dart:23-26`）；载荷行**没有** `g` 字段，因此**不得**写「`g != generation` 即抛」
一类的校验 —— 那正是 R4-P0 删掉的东西。

示例（三行，均无 `g`）：

```
{"k":"light.components.btn.radius","v":8,"t":"n"}
{"k":"light.components.btn.shadow.color","v":"#8B0000","t":"s"}
{"k":"dark.semantic.luck.daji","v":"#22C55E","t":"s"}
```

#### 构建期产出（不在 S5a ACT 范围，见 §11.5）

```
theme/config/presets/*.yaml
    → 构建脚本：解析 + 扁平化（§6.6 第 1 步的构造规则）
    → *.jsonl 载荷
    → 算 sha256 / bytes / rowCount 真值写进 DatasetManifest
```

`rowCount` = **jsonl 的行数**（每行一个 token），这是 `MaterializeOutcome.rowCount`
必须返回的真值，XRAP 会与 `declaredRowCount` 比对（不变式 I4）。

### 4.4 落地结构（reference 实现的唯一形态）

**落地物不存在 materializer 实例里，存在一个装配期创建、工厂闭包捕获的共享持有者里。**
理由见 §4.5 —— 这是 R4-P1-3「数据流不闭合」的闭合点，不是风格选择。

文件：`core/lib/reference/in_memory_theme_materializer.dart`（与 materializer 同文件，
两者是一体的落地形态，拆开会让 reference 层多一个文件而不增加任何信息）

```dart
/// reference 落地物的**共享持有者**：世代号 → (扁平 key → 值) 的两级内存 Map。
///
/// 【为什么必须是独立对象，而不是 materializer 的私有字段】
/// XRAP 的 `DatasetDescriptor.materializer` 字段类型是
/// `DatasetMaterializer Function()`（`dataset_descriptor.dart:44`）—— 是**工厂**，
/// 且协议注释写明「落地器可能持有数据库连接等资源，由安装器在需要时创建、用完释放」。
/// 因此安装器每次落地都新建一个 materializer 实例，该实例出了安装流程即不可达。
/// 落地物若存在实例私有字段里，启动路径的 `ThemeLocalReader` **永远读不到**。
/// 故落地物必须存在这个由工厂闭包捕获的外部对象里。
final class InMemoryThemeTokenStore {
  /// 构造一个空的落地物持有者。**装配期建一个，全生命周期共享**（§4.5 第 1 步）。
  InMemoryThemeTokenStore();

  /// 写入某一代的全部 token（整代覆盖写，幂等）。**只有 materializer 调用它。**
  void putGeneration(int generation, Map<String, dynamic> tokens);

  /// 读取某一代的 token；该代未落地返回 null。
  /// 返回 `Map.unmodifiable` 只读视图（A16 不可变性）。
  Map<String, dynamic>? tokensOf(int generation);

  /// 删除某一代。不存在时静默返回（XRAP 要求 `dropGeneration` 幂等）。
  void dropGeneration(int generation);

  /// 已落地的世代号集合。诊断与 P4/A20 断言用。
  Set<int> get generations;
}
```

- **世代隔离**：`materialize(generation: g)` 只调 `putGeneration(g, ...)`，不触碰其它世代；
- **`dropGeneration(g)`**：转调 `store.dropGeneration(g)`，不存在时静默返回（幂等）；
- **读取**：由 `XrapThemeLocalReader` 按 XRAP 活跃指针给出的世代号取那一层 Map（§4.5 第 4 步）。

> ⚠️ **生产实现（drift 表）不在本设计决定** —— 它属后续任务 `THEME-DRIFT`（§11.5），
> 需与 S1d/S5b 协调 schema 版本号。但**行 schema、世代隔离语义、以及「落地物由外部持有、
> 工厂闭包捕获」这一装配形状已在此定死**，生产实现必须遵守（drift 版的"外部持有者"就是
> 数据库连接/DAO），且必须能通过同一套 A20 契约测试。

#### `InMemoryThemeMaterializer` 实现的精确签名【reference】

同一文件：`core/lib/reference/in_memory_theme_materializer.dart`

```dart
final class InMemoryThemeMaterializer implements DatasetMaterializer {
  /// 构造。落地物写进**外部传入的共享 store**，不存在实例私有字段里
  /// —— 这是安装期与启动读取期能看到同一份落地物的唯一原因（§4.5）。
  InMemoryThemeMaterializer(this._tokens);

  final InMemoryThemeTokenStore _tokens;

  @override
  String get datasetId => themeDatasetId;

  /// 消费 JSON Lines 载荷（§4.3），整代写入 [generation]。
  ///
  /// 实现要点（逐条都有对应验收，见 A20）：
  /// - 逐行解析；`v` 为 Map 的行立即抛（契约违反，嵌套应在构建期展平）；
  /// - **载荷行没有 `g` 字段**，世代号一律取入参 —— 不得从载荷里读或校验世代
  ///   （R4-P0：那会让合法载荷在第二次落地时被拒）；
  /// - 返回 `MaterializeOutcome(rowCount: 实际写入行数, bytesOnDisk: 载荷字节数)`；
  /// - **不重复校验 sha256**（XRAP 已校验，`dataset_materializer.dart:43-45`）；
  /// - **不改动活跃指针**（协议 P3，翻转是安装器的事）。
  @override
  Future<MaterializeOutcome> materialize({
    required DatasetManifest manifest,
    required Stream<List<int>> payload,
    required int generation,
    CancellationToken? cancel,
  });

  /// 转调 `_tokens.dropGeneration(generation)`。幂等。
  @override
  Future<void> dropGeneration(int generation);
}
```

> 📌 **v6 变更**：v5 曾在 materializer 上挂一个 `@visibleForTesting Map<String, dynamic>? tokensOf(int)`
> 供 reader 读。**已删除** —— 它只能读到"某一个实例"的落地物，而安装器手里的是工厂新建的
> 另一个实例，这正是 R4-P1-3 抓到的断链。读取入口现在是 `InMemoryThemeTokenStore.tokensOf`，
> 且它是**生产读路径**，不是 `@visibleForTesting`。

### 4.5 装配数据流：安装 → 落地 → 启动读取（R4-P1-3 闭合点）

**问题**：`DatasetDescriptor.materializer` 是工厂（`dataset_descriptor.dart:44`），
安装器新建的 materializer 实例与启动路径的 `ThemeLocalReader` 是两个互不认识的对象。
落地物怎么从前者传到后者？

**结论：方案 A（工厂闭包捕获外部共享 store）+ 方案 C（世代号取自 XRAP 活跃指针）的组合。
不改 `core/lib/model/dataset/` 下任何 XRAP 契约。**

> **为什么不选"materializer 改单例注入"**：`dataset_descriptor.dart:44` 的字段类型就是
> `final DatasetMaterializer Function() materializer;` —— 契约要的是工厂。改成实例
> 等于改 XRAP 契约，而 XRAP 是 T1 已交付并在用的东西（§0.0 裁定 3）。**已排除。**
>
> **为什么不只用方案 C**：`DatasetRegistry` / `DatasetInstaller` 只记录**世代元数据**
> （`InstalledDataset`：世代号、状态、清单、行数），**不持有落地物本身** ——
> 落地物长什么样正是 materializer 的自由（协议 §3.3）。所以 C 能提供"读哪一代"，
> 提供不了"那一代的字节在哪"。二者必须合用。

**五步链，每步都指明发生在哪个文件里的哪个函数**：

| 步 | 时机 | 在哪 | 做什么 |
|---|---|---|---|
| 1 | 装配期 | `theme_assembly.dart` 的 `assembleThemeStore` | `final tokenStore = InMemoryThemeTokenStore();` —— **全进程一个** |
| 2 | 装配期 | 同上 | `ThemeModuleRegistry.register(themeMaterializer: () => InMemoryThemeMaterializer(tokenStore));`<br>**这个闭包就是捕获点** —— 工厂每次调用新建 materializer，但它们全都写进同一个 `tokenStore` |
| 3 | 装配期 + 安装期 | XRAP `DatasetInstaller` | `await installer.ensureInstalled(themeDatasetId)`（装配期调一次，**不触网**，`dataset_installer.dart` 明写）→ 安装器调 `descriptor.materializer()` 拿到实例 → `materialize(generation: 0, ...)` → 落地物进 `tokenStore` 的第 0 代 → 安装器单事务翻转活跃指针 |
| 4 | 启动读取期 | `theme_assembly.dart` 的 `XrapThemeLocalReader` | `final active = await installer.active(themeDatasetId);`（**XRAP 的落地产物**，`dataset_installer.dart` 明写 active 是"读路径的唯一入口……不得直接查最大世代号"）→ `tokenStore.tokensOf(active.generation)` |
| 5 | 启动读取期 | `in_memory_theme_resource_store.dart` | `InMemoryThemeResourceStore` 只认识 `ThemeLocalReader`，对 `tokenStore` / `installer` **一无所知** —— P3 的结构性零网络保证不受影响 |

**装配连接点的精确签名【reference】**

文件：`core/lib/reference/theme_assembly.dart`

```dart
/// 把 XRAP 的落地产物接到 S5a 读路径上的 reference reader。
///
/// 【它是 §4.5 第 4 步的落地形态】生产实现（drift）换掉本类即可，
/// `InMemoryThemeResourceStore` 一行不改 —— 这正是端口存在的意义。
final class XrapThemeLocalReader implements ThemeLocalReader {
  /// 构造。三个入参分别对应三个读方法的数据来源。
  ///
  /// - [tokenStore]: §4.5 第 1 步创建的那一个，与 materializer 工厂捕获的是**同一个实例**；
  /// - [installer]: XRAP 安装器。**只用来读活跃指针**（`active`），
  ///   reader 不得调 `ensureInstalled` / `checkForUpdate`（P4 会断言）；
  /// - [initialOverrides]: 用户覆盖差量的初始快照。生产实现改为查 drift 覆盖表。
  XrapThemeLocalReader({
    required InMemoryThemeTokenStore tokenStore,
    required DatasetInstaller installer,
    required Map<String, OverrideEntry> initialOverrides,
  });

  /// bundled = XRAP 的 **generation 0**（`dataset_descriptor.dart:33-37`：
  /// 内置世代恒存在，且作为 generation 0 参与统一机制）。
  ///
  /// 实现：`_tokens.tokensOf(0)`；为 null 抛 `StateError`（fail closed）——
  /// 说明装配漏了第 3 步的 `ensureInstalled`，**不得静默返回空 Map**
  /// （空 Map 会让三层合并全部落空却全绿）。
  @override
  Future<Map<String, dynamic>> readBundledTokens();

  /// 活跃世代的 token。**六步，无分支歧义**：
  ///   1. `themeId != themeDatasetId` → 抛 `ArgumentError`。
  ///      reference 阶段主题包与 XRAP 数据集一一对应，themeId 即 datasetId；
  ///      「多主题包并存」需要多个 datasetId，属 THEME-DRIFT，不在 S5a。
  ///   2. `final active = await installer.active(themeDatasetId);`
  ///   3. `active == null || !active.isUsable` → 返回 null（无 ready 世代）
  ///   4. `active.generation == 0` → 返回 null
  ///      （第 0 代是 bundled，由 readBundledTokens 承担，不重复算作"已装主题包"）
  ///   5. `final t = _tokens.tokensOf(active.generation);`
  ///      `t == null` → 返回 null（指针指向的世代无落地物：结构性不一致，
  ///      fail closed 交给 bundled 兜底，与 P6 同一条降级路径）
  ///   6. 返回 `t`
  @override
  Future<Map<String, dynamic>?> readActiveThemeTokens(String themeId);

  /// 返回 [initialOverrides] 的只读视图。
  @override
  Future<Map<String, OverrideEntry>> readOverrides();
}

/// reference 装配入口。**P4 的唯一注入点**。
///
/// 【为什么需要它】P4 要断言「启动路径不触发安装」，就必须有一个能同时看到
/// store 与 installer 的位置。生产装配在 xuan-shell 的 DI bootstrap，
/// reference 装配在这里，二者形状一致 —— 测试对装配函数编程，不对实现编程。
///
/// 【它按顺序做四件事，缺一不可】
///   1. `final tokenStore = InMemoryThemeTokenStore();`
///   2. `ThemeModuleRegistry.register(
///          themeMaterializer: () => InMemoryThemeMaterializer(tokenStore));`
///   3. `await installer.ensureInstalled(themeDatasetId);`
///      —— 保证 generation 0 已落地。该方法**不触网**（`dataset_installer.dart`：
///      「这是读路径唯一允许调用的安装方法 —— 它不触网」）。
///   4. `return InMemoryThemeResourceStore(
///          scopeUid: scopeUid,
///          localReader: XrapThemeLocalReader(
///              tokenStore: tokenStore, installer: installer,
///              initialOverrides: initialOverrides));`
Future<ThemeResourceStore> assembleThemeStore({
  required String scopeUid,
  required DatasetInstaller installer,
  required Map<String, OverrideEntry> initialOverrides,
});
```

> ⚠️ **`assembleThemeStore` 不接收 `localReader`**。reader 由它自己按第 4 步造 ——
> 若把 reader 做成入参，P4 就只在测自己传进去的假货，证明不了生产链路。
> P3-b / P6 需要注入探针 reader 时，**直接构造 `InMemoryThemeResourceStore`**
> （§5.5.4），不走装配函数。

**这条链的回归守卫**：P4 断言 `tokenStore.generations.contains(0)`。
把 `InMemoryThemeMaterializer` 改回持有私有 Map（不写共享 store），该断言立刻变红
—— 这就是本条的「怎么让它变红」（§5.5.4 P4 第 3 条自检）。

---

## 5. 端口契约

> 以下是**签名**，不是实现。包归属：`persistence_core`（契约） + `persistence_drift`（实现，不在 S5a 首批范围）。
> 命名沿用总纲既有惯例（`LocalBlobStore` / `ScopedRecordStore` / `BlobGateway`）。

### 5.1 中立数据结构（不依赖 `theme`，不依赖 `xuan_config`）

```dart
// 包：persistence_core   文件：core/lib/model/theme_token_types.dart

/// 一份已合并、源无关的主题 token 集合。
///
/// 【为什么不直接返回 theme 包的 XuanThemeSet】依赖方向：persistence_* 不得
/// 依赖 theme（§2.2）。本类型是中立形状，由装配层适配成 theme 能消费的结构。
///
/// 形状与 xuan_config 的 ConfigResult 对齐（light/dark 各含 components/chart/
/// semantic），因此装配层的适配是机械映射，不含业务逻辑。
final class ThemeTokenSet {
  /// 亮色模式 token。
  final ThemeTokenSection light;

  /// 暗色模式 token。
  final ThemeTokenSection dark;

  /// 溯源信息：这份结果由哪些层合并而来。
  final ThemeResolution resolution;

  const ThemeTokenSet({
    required this.light,
    required this.dark,
    required this.resolution,
  });
}

/// 单 brightness 下的 token 分区。值保持 Map 形态（源无关），
/// 由装配层交给 theme 包做 typed 解析 —— 本层不解析业务语义。
final class ThemeTokenSection {
  /// 组件 token：组件 id → 原始 Map。
  final Map<String, dynamic> components;

  /// 图表 token，可空。
  final Map<String, dynamic>? chart;

  /// 语义 token（五行色板等），可空。
  final Map<String, dynamic>? semantic;

  const ThemeTokenSection({
    required this.components,
    this.chart,
    this.semantic,
  });
}
```

### 5.2 溯源结构（对齐 S5c 的诊断链要求）

```dart
/// 一次主题解析的完整溯源。
///
/// 【为什么必须有】S5c 的 A11 验收标准要求「任一配置值可回答来自哪个 sourceId /
/// 什么 version / 何时拉取」。主题是同一类问题：用户报"我的主题不对"时，
/// 必须能回答这份 token 由哪些层合成。
final class ThemeResolution {
  /// 生效的主题包 id；未安装任何包时为 null（纯 bundled）。
  final String? activeThemeId;

  /// 生效主题包的版本；同上可为 null。
  final String? activeThemeVersion;

  /// 主题 id 的来源：用户显式选择 / 官方下发 / 内置默认。
  final ThemeSelectionOrigin selectionOrigin;

  /// 参与合并的层，按优先级从高到低。
  final List<ThemeLayerInfo> layers;

  /// 本次解析时刻（UTC）。
  final DateTime resolvedAtUtc;

  /// 已失效的覆盖（指向当前主题包不存在的 token 路径）。
  /// 【不静默丢弃】用户的创作不得无声消失，UI 据此提示。
  final List<String> orphanedOverrideKeys;

  const ThemeResolution({
    required this.activeThemeId,
    required this.activeThemeVersion,
    required this.selectionOrigin,
    required this.layers,
    required this.resolvedAtUtc,
    this.orphanedOverrideKeys = const [],
  });
}

/// 主题 id 从哪来。决定"用户选过没有"，进而决定官方下发能否覆盖。
enum ThemeSelectionOrigin {
  /// 用户显式选择过（存于 private 层，优先级最高）。
  userSelected,

  /// xuan_config 下发的 defaultThemeId（用户未选过时生效）。
  officialDefault,

  /// 两者都拿不到，回退代码内置默认。
  bundledFallback,
}

/// 参与合并的一层。
final class ThemeLayerInfo {
  /// 层类型。
  final ThemeLayerKind kind;

  /// 该层来源标识（主题包 id / 'bundled' / 'user_override'）。
  final String sourceId;

  /// 该层贡献了多少个 token key（诊断用）。
  final int contributedKeyCount;

  const ThemeLayerInfo({
    required this.kind,
    required this.sourceId,
    required this.contributedKeyCount,
  });
}

/// 三层模型的层类型，优先级从高到低。
enum ThemeLayerKind {
  /// 用户覆盖差量（private，可同步）。
  userOverride,

  /// 已安装的主题包（resource，只读）。
  installedPackage,

  /// 编译进 app 的默认主题（bundled）。
  bundled,
}
```

### 5.3 主门面：`ThemeResourceStore`（读 + 写）

```dart
// 包：persistence_core   文件：core/lib/model/theme_resource_store.dart

/// 主题资源的读写门面。
///
/// 【设计要点 · 读写不对称】（§2.5）
/// - 读 [resolve]：返回**三层合并后**的完整结果；
/// - 写 [applyOverrides] / [removeOverrides]：**只作用于用户覆盖层**。
/// 二者不是逆运算。切勿把 resolve 的结果整份写回。
///
/// 【设计要点 · 源无关】调用方不感知数据来自 bundled asset、已装主题包、
/// drift、还是远端下载 —— 对齐总纲 §2.1:140「Repository 必须对来源无感」。
///
/// 通用约定（§3.6）：失败抛 StorageError 子类，不用 null 表达失败；
/// 可能超过 1 秒的方法接受 CancellationToken。
abstract interface class ThemeResourceStore {
  /// 作用域 uid（多账号隔离）。
  String get scopeUid;

  // ── 读 ──

  /// 解析当前生效主题：三层合并（override > 已装包 > bundled），逐 key 取第一命中。
  ///
  /// 【性能硬约束】本方法**不得发起任何网络请求、不得触发 XRAP 安装流程**。
  /// 它只读本地已就绪的数据（XRAP 已翻转到活跃世代的落地物 + 用户覆盖层）。
  /// 详见 §7 启动路径预算。
  ///
  /// 【幂等与缓存】相同输入（活跃世代号 + 覆盖层版本）连续调用必须返回
  /// `identical` 的实例，以便 `XuanThemeScope.updateShouldNotify` 的深比较
  /// 被 identical 短路（§7.2）。
  Future<ThemeTokenSet> resolve({CancellationToken? cancel});

  /// 当前生效主题的解析结果流。覆盖层变更、主题切换、
  /// **XRAP 活跃指针翻转**时推送新值。
  ///
  /// 【为什么是 Stream】XRAP 安装完成后翻转活跃指针是异步事件，
  /// UI 需要被通知而非轮询 —— 这是"安装不阻塞启动"（§7.3）的落地形式。
  Stream<ThemeTokenSet> watchResolved();

  /// 本地可用的主题清单。
  ///
  /// 【数据来源】XRAP 的活跃世代落地物 + bundled 世代（generation 0）。
  /// **不含"可下载但未安装"的主题** —— 那是 XRAP catalog 的职责，不在本端口。
  Future<List<LocalTheme>> listLocalThemes();

  // ── 写 · 主题选择 ──

  /// 用户显式选择主题。写入 private 层，跨设备同步。
  ///
  /// 选择后 [ThemeResolution.selectionOrigin] 变为 userSelected，
  /// 此后 xuan_config 下发的 defaultThemeId **不再覆盖**用户的选择。
  ///
  /// [themeId] 必须在 [listLocalThemes] 中，否则抛 StorageError
  /// （调用方应先经 XRAP 的 `DatasetInstaller` 安装）。
  Future<void> selectTheme(String themeId);

  /// 清除用户的主题选择，回到跟随官方下发。
  Future<void> clearThemeSelection();

  // ── 写 · 用户覆盖层（§2.6）──

  /// 批量应用覆盖差量。**原子提交**：要么全成，要么全不成。
  ///
  /// 参数说明：
  /// - [patch]: token 路径 → 值。路径形如
  ///   `light.components.four_zhu_card.shadow.color`（含 brightness 前缀，
  ///   light/dark 完全独立 —— 见 §6.3）。
  /// - [origin]: 该覆盖的来源，用于诊断与"B 包有新版本要不要更新这部分"的提示。
  ///
  /// 【只存差量】未出现在 [patch] 中的 key 不受影响，不会被清除（§2.4）。
  /// 【幂等】相同 patch 重复应用结果一致。
  Future<void> applyOverrides({
    required Map<String, dynamic> patch,
    required OverrideOrigin origin,
  });

  /// 删除指定覆盖，恢复到下层（已装包 → bundled）。
  ///
  /// 【为什么需要独立方法】[applyOverrides] 无法表达删除：传 null 有歧义
  /// （"设为空值"还是"删除这条覆盖"）。"恢复全部默认" =
  /// removeOverrides(当前全部已覆盖 key)。
  ///
  /// 不存在的 key 静默忽略（幂等）。
  Future<void> removeOverrides(Set<String> tokenKeys);

  /// 当前全部用户覆盖（诊断与"恢复默认"UI 用）。
  Future<Map<String, OverrideEntry>> listOverrides();
}
```

> ⚠️ **本端口不提供安装类方法**（归 XRAP，见 §0.0 裁定 3）。
> 主题包的下载、校验、世代管理、活跃指针翻转、回滚、GC、幂等**全部由
> `DatasetInstaller` 统一负责** —— `dataset_installer.dart:188-192` 写死
> 「唯一实现，数据集无关」，S5a 再写一个主题专用安装器是直接违反它。
>
> **调用方视角**：安装主题 = 调 XRAP 的 `DatasetInstaller`（传入 `theme.package` 这个
> datasetId）；安装完成后 XRAP 翻转活跃指针，`ThemeResourceStore.watchResolved()`
> 推送新的合并结果。两者通过**活跃世代号**衔接，不直接互调。

### 5.4 配套值类型

```dart
/// 本地可用的主题（XRAP 活跃世代落地物 + generation 0 内置世代）。
///
/// 【S5a 不定义安装态类型】安装态（安装时刻 / 占用字节 / 是否内置 /
/// publisher）全部归 XRAP —— 它由 DatasetInstaller 维护世代与状态机
/// （`dataset_installer.dart:188-192`）。S5a 只需要「本地有哪些主题可选」。
///
/// 【不含"可下载但未安装"的主题】那是 XRAP catalog 的职责，不在本端口。
final class LocalTheme {
  /// 主题 id（对应 defaultThemeId 的取值）。
  final String id;

  /// 展示名。
  final String displayName;

  /// 作者。
  final String author;

  /// 该主题落地物所在的 XRAP 世代号。generation 0 即 bundled 内置世代。
  final int generation;

  /// 构造一条本地可用主题。
  const LocalTheme({
    required this.id,
    required this.displayName,
    required this.author,
    required this.generation,
  });
}

/// 一条用户覆盖记录。
final class OverrideEntry {
  /// 覆盖的值。
  final dynamic value;

  /// 来源（手动编辑 / 取自某个主题包）。
  final OverrideOrigin origin;

  /// 写入时刻（UTC）。
  final DateTime updatedAtUtc;

  const OverrideEntry({
    required this.value,
    required this.origin,
    required this.updatedAtUtc,
  });
}

/// 覆盖来源。
///
/// 【存值不存引用】取自 B 包的覆盖记录的是**值快照**，不是对 B 包的引用。
/// 因此 B 包卸载后用户的设计不受影响，B 包升级也不会悄悄改变用户看到的样子。
/// 本字段仅用于诊断与"B 有新版本，是否更新这部分"的提示。
final class OverrideOrigin {
  /// 用户手动编辑。
  static const manual = OverrideOrigin._('manual', null, null);

  /// 来源类型标识。
  final String kind;

  /// 取值来源的主题包 id（manual 时为 null）。
  final String? sourceThemeId;

  /// 取值时该主题包的版本（manual 时为 null）。
  final String? sourceThemeVersion;

  const OverrideOrigin._(this.kind, this.sourceThemeId, this.sourceThemeVersion);

  /// 取自某个主题包的某个版本。
  const OverrideOrigin.fromPackage({
    required String themeId,
    required String version,
  }) : this._('package', themeId, version);
}
```

> ⚠️ **资产覆盖的例外**：若用户覆盖引用了 B 包内的字体/图片，字节不能靠值快照。
> 此时 override 记录 `BlobHandle`，并通过 `LocalBlobStore.reconcileRefs`（总纲 §3.2）
> 登记引用 —— 即使 B 包卸载，引用计数不为 0，字节不被 GC 回收。
> 这是总纲 §6.4:1080 选择"内容寻址 + 引用计数"而非"blob 生命周期跟随 record"的直接兑现。
> **当前无资产，此路径不在 S5a 首批实现范围，但端口形状必须容纳它。**

### 5.5 reference 实现的注入面与测试探针【reference】

> **本节关闭 Codex R2 的四条 P1。** 原版在验收标准里写了 `_CountingHttpClient`、`localTokenReadCount`、
> "永不完成的 install"、"验签钩子"、"bundled 权威源"，却没在任何地方定义它们的类型与注入点 ——
> 机械执行者只能自己发明 API。以下写死。

#### 5.5.1 设计原则：reference 零 IO，但**注入面**必须存在

reference 实现本身不碰网络、文件、drift（§0.1）。但 P3/P4/P6 要验证的正是"**没有**发生 IO"，
而"没有发生"只能通过**可观测的抽象边界**证明 —— 若边界不存在，测试无从下手，也无法证明
将来的生产实现会遵守同一约束。

因此 reference store 的构造器接收四个**窄端口**。生产实现注入真实现，测试注入计数式 spy，
reference 的默认值是"什么都不做"的空实现（保持零 IO）。

#### 5.5.2 注入端口【契约】

> **S5a 不持有远端拉取、包落盘、验签三类端口** —— 它们是 XRAP 安装流程的一部分。
> 依据 §0.0 裁定 3：`dataset_installer.dart:188-192`「唯一实现，数据集无关」。

S5a 只保留**一个**注入端口。

文件：`core/lib/model/theme_source_ports.dart`

```dart
/// 主题 token 与用户覆盖的本地读取端口。
///
/// 【为什么需要它】P3/P4 要验证的正是"启动路径**没有**发生 IO"，
/// 而"没有发生"只能通过可观测的抽象边界证明。生产实现读 XRAP 活跃世代
/// 的落地物 + drift 覆盖表；测试注入内存 fixture。
///
/// 【bundled 的来源】v4 裁定 4：`bundledManifest` 恒存在、冷启动零网络
/// （`dataset_source.dart:61`）。bundled token 由装配层从 XRAP 的
/// generation 0 落地物读出后注入，**S5a 不跨仓库去 theme 包找文件**
/// （stop condition #2）。
abstract interface class ThemeLocalReader {
  /// 读取 bundled（XRAP generation 0）的**已解析、已扁平化** token。
  ///
  /// 返回值不得为 null —— bundled 是最后兜底层，恒存在（XRAP 协议 P5）。
  Future<Map<String, dynamic>> readBundledTokens();

  /// 读取 XRAP **当前活跃世代**的主题 token；无已装主题时返回 null。
  ///
  /// 【不触发安装】本方法只读已翻转到活跃指针的落地物。
  /// 安装与指针翻转由 `DatasetInstaller` 负责，S5a 不介入。
  Future<Map<String, dynamic>?> readActiveThemeTokens(String themeId);

  /// 读取用户覆盖差量（private 层，XRAP 硬拒的那部分）。
  Future<Map<String, OverrideEntry>> readOverrides();
}
```

#### 5.5.3 reference store 的精确构造器【reference】

文件：`core/lib/reference/in_memory_theme_resource_store.dart`

```dart
final class InMemoryThemeResourceStore implements ThemeResourceStore {
  /// 构造 reference store。
  ///
  /// 参数说明：
  /// - [scopeUid]: 作用域 uid。
  /// - [localReader]: **必需**。bundled / 活跃世代 / override 的唯一来源。
  ///   测试注入内存 fixture（§7.5 的 ThemeBenchFixture）。
  ///
  /// 【v4：不再接收 remoteFetcher / packageStore / signatureVerifier】
  /// 那三样归 XRAP。reference 的零 IO 由「只有一个本地读取端口」这一
  /// 结构事实保证 —— 它连发起网络的能力都没有，比"默认实现抛异常"更强。
  InMemoryThemeResourceStore({
    required this.scopeUid,
    required ThemeLocalReader localReader,
  });
}
```

> 📌 **v4 的一个结构性改进**：v3 靠"默认实现恒抛 `StateError`"来兑现零 IO；
> v4 直接**移除了发起 IO 的能力**（没有 remote/package 端口可注入）。
> 不可表达优于运行时拦截 —— 与 S1a §2.3 的「把非法值从参数表移除」同一手法。

#### 5.5.4 测试探针的精确定义与计数语义

文件：`core/test/support/theme_probes.dart`

| 探针 | 实现端口 | 计数字段 | **何时 +1** |
|---|---|---|---|
| `CountingLocalReader` | `ThemeLocalReader` | `bundledReadCount` | 每次 `readBundledTokens()` 返回 |
| | | `activeThemeReadCount` | 每次 `readActiveThemeTokens()` 返回 |
| | | `overrideReadCount` | 每次 `readOverrides()` 返回 |
| `SlowLocalReader` | `ThemeLocalReader` | — | `readActiveThemeTokens()` 返回**永不完成的 `Completer.future`**；另两个方法正常返回（用于 P6） |
| `CountingDatasetInstaller` | `DatasetInstaller`（XRAP） | `installCallCount` | 每次 `install(...)` 被**进入**（不等返回，用于 P4） |
| | | `calledDatasetIds` | 同上，追加被请求的 datasetId |

**P3 的可执行 oracle（Dart 无实用反射，故用静态扫描 + 行为断言双保险）**：

Dart 的 `dart:mirrors` 在 Flutter 下不可用，**无法在运行时读构造器参数表**。
因此 P3 拆成两条各自可执行的断言：

```
P3-a 静态扫描（架构守卫测试内以纯文本读源码）
  读 core/lib/reference/in_memory_theme_resource_store.dart 全文，断言：
    (1) 'ThemeLocalReader' 命中次数 == 1                    唯一注入端口
    (2) 正则 'http|Http|Socket|Uri|DatasetInstaller|DatasetSource' 命中 == 0
    (3) 构造器参数区内 'required ' 出现次数 == 2             scopeUid + localReader
  三条任一失败即红。(2) 是关键 —— 证明该类连发起 IO 的符号都没引用到。

P3-b 行为断言（正向控制）
  store = InMemoryThemeResourceStore(
      scopeUid: 'u1', localReader: CountingLocalReader(fixture))
  await store.resolve()
  断言 localReader.bundledReadCount  > 0     确实走了启动路径
  断言 localReader.overrideReadCount > 0
```

> ⚠️ **P3-a 第 (3) 条的防假绿要求**：必须先从 `InMemoryThemeResourceStore({`
> 切到配对的 `})` 得到参数区子串，再在**子串内**计数 —— 全文计数会被值类型的
> `required` 污染。且须对子串加长度下限断言（`length > 50`），
> 否则正则失配切出空串时 `0 == 0` 会静默通过。

**P4 的装配入口（v4 原缺，此处补全）**：

P4 要验证 `resolve()` 不触发 XRAP 安装。但 `ThemeResourceStore` 本身**不持有**
`DatasetInstaller`（那是 XRAP 的东西），所以注入点不在 store 上，**在装配函数上**：

```dart
// core/lib/reference/theme_assembly.dart —— reference 装配入口
//
// 【为什么需要它】P4 要断言「启动路径不触发安装」，就必须有一个能同时看到
// store 与 installer 的位置。生产装配在 xuan-shell 的 DI bootstrap，
// reference 装配在这里，二者形状一致 —— 测试对装配函数编程，不对实现编程。
Future<ThemeResourceStore> assembleThemeStore({
  required String scopeUid,
  required ThemeLocalReader localReader,
  required DatasetInstaller installer,   // 只服务安装流程；resolve 路径不得触碰
});
```

```
P4 的断言：
  installerSpy = CountingDatasetInstaller()
  store = await assembleThemeStore(
      scopeUid: 'u1',
      localReader: CountingLocalReader(fixture),
      installer: installerSpy)
  await store.resolve()
  断言 installerSpy.installCallCount == 0     零安装
  断言 localReader.bundledReadCount  > 0      正向控制：确实走了启动路径
```

第二条正向控制不可省 —— 没有它，一个 `assembleThemeStore` 什么都不做的实现
也能让第一条通过（门禁纪律第 9 条）。

**P6 的状态转换**：

```
1. store = InMemoryThemeResourceStore(localReader: SlowLocalReader(fixture, 活跃世代读取挂起))
2. sw = Stopwatch()..start()
3. result = await store.resolve()
4. 断言 sw.elapsedMilliseconds < 50
5. 断言 result 来自 bundled 层（activeThemeId == null 或 bundled 兜底生效）
6. 断言不抛异常 —— 活跃世代读不到时优雅降级到 bundled，不是失败
```

> 📌 **P6 语义在 v4 变了**：v3 测的是"下载未完成时返回旧主题"，但下载已归 XRAP。
> v4 测的是"**活跃世代落地物读取挂起时，resolve 仍在 50ms 内返回 bundled 兜底**"
> —— 这才是 S5a 侧真实存在的降级路径。

#### 5.5.5 A14 / A19 的归属裁决（v4 重新划分）

v3 已把 A14b/d/e 移交 installer/parser。**v4 进一步收窄** —— 依据 §4.3：
设备上消费的是**预构建载荷**，YAML 解析发生在**构建期**，不在设备上。

| 验收 | 内容 | v3 归属 | **v4 归属** |
|---|---|---|---|
| A14a | 未知字段静默忽略 | S5a 合并层 | ⬜ **构建脚本**（扁平化时决定收不收未知 key）+ S5a 保底：合并层对任何 key 一视同仁，不做白名单过滤 |
| A14c | 缺失字段保持 legacy fallback | S5a 合并层 | ✅ **留在 S5a** —— 这是 §6.6 第 4 步原子组补全的直接验收，输入输出都是 Map |
| A14b | manifest 版本拒装 | installer | ⬜ **XRAP**（`DatasetDescriptor.supports()` 已实现「只比大小」判定，`dataset_descriptor.dart:59-61`） |
| A14d | 数值非法透传诊断 | parser | ⬜ **构建脚本**（非法值在构建期就该被发现并拒绝出包） |
| A14e | 单字段非法只回退该字段 | parser | ⬜ **构建脚本 + `token_loader`**（设备侧由既有 `_parseCheckedDouble` 兜底） |
| **A19** | 合并层不吞值 | S5a | ✅ **留在 S5a**，语义不变：注入一个值为 `"8px"` 的 radius，断言它**原样出现在** `resolve()` 结果中 —— 证明合并层没有偷偷过滤或修正 |

**S5a 在此的责任降为两条，都可验收**：
1. **不吞值**（A19）—— 任何 key/value 原样透传，不做白名单、不做修正；
2. **原子组补全**（A14c）—— §6.6 第 4 步。

> 📌 移交项须在 XRAP 侧与构建脚本任务的纪要中承接，不得丢失（§11.5 已登记）。

### 5.6 存储策略与 XRAP 数据集声明

#### 5.6.1 策略声明【契约】

文件：`core/lib/model/theme_storage_policies.dart`

```dart
/// 主题数据集：resource 类。**给 XRAP 的 DatasetDescriptor 用**。
///
/// XRAP 注册期强制 publisher == official（`dataset_registry.dart:62-68`，
/// 不变式 I9），且策略的 carriers 是 manifest carriers 的上界（I8）。
const officialThemePolicy = StoragePolicy.resource(
  carriers: {Carrier.row, Carrier.blob},
  sources: {Source.bundled, Source.officialRemote},
);   // publisher 默认 official

/// 用户覆盖层：private 类，当前仅 row。
/// **XRAP 装不下这个** —— publisher 非 official，注册期会被硬拒（§0.0 裁定 2）。
const themeOverridePolicy = StoragePolicy.private(
  carriers: {Carrier.row},
);

/// 用户主题选择：private 类。同样不进 XRAP。
const themeSelectionPolicy = StoragePolicy.private(
  carriers: {Carrier.row},
);
```

#### 5.6.2 XRAP 数据集声明【契约】

文件：`core/lib/model/theme_dataset.dart`

照 T1 样板（`assets/lib/geo/geo_datasets.dart`，main `6cd7a66`）的形制：

```dart
/// 主题数据集的 XRAP 声明。
///
/// 【接入 XRAP 的全部动作】构造 DatasetDescriptor 并调 DatasetRegistry.register
/// （`dataset_descriptor.dart:3-4`）。
///
/// 【为什么 materializer 工厂从外部传入】契约层（`core/lib/model/`）**不得依赖**
/// reference 层（`core/lib/reference/`）—— 否则 A3「契约层零实现」与分层方向双双被破坏。
/// 把工厂做成入参后，`InMemoryThemeMaterializer` 与共享 `InMemoryThemeTokenStore`
/// 的知识全部留在 reference 层，契约层只做原样透传（§4.5 第 2 步）。
DatasetDescriptor themeDatasetDescriptor({
  required DatasetMaterializer Function() materializer,
}) =>
    DatasetDescriptor(
      datasetId: themeDatasetId,                  // 'theme.package'
      appSchemaRevision: kThemeAppSchemaRevision,  // 本 app 的落地结构版本
      policy: officialThemePolicy,
      bundledManifest: kThemeBundledManifest,      // generation 0，恒存在
      materializer: materializer,                  // 原样透传，契约层不认识 reference 层
    );

/// 数据集稳定标识。**不得内联字面量**（同 entityType 常量的理由）。
const themeDatasetId = 'theme.package';

/// 本 app 的主题落地结构版本。落地逻辑升级到能读更高结构时递增
/// （`dataset_descriptor.dart:20-27` 的 minSdkVersion 模型）。
const kThemeAppSchemaRevision = 1;
```

⚠️ `kThemeBundledManifest` 的 `sha256` / `bytes` / `rowCount` 必须是**构建脚本产出的真值**，
不得手写占位 —— XRAP 安装器会比对，不符则不进 ready（不变式 I4）。
T1 的做法是构建脚本输出 `BUILD-REPORT.md` 记录真值。

#### 5.6.3 注册落点（精确到文件、函数、时机、幂等策略）

> Codex gStack 评审 P0：原设计只给三行裸 `register(...)`，没说放哪个文件、何时调用、重复注册怎么办，机械执行者无法判断。以下写死。

**文件**：`core/lib/model/theme_module_registry.dart`（新建）

**形态**：

```dart
/// 主题模块的策略注册入口。
///
/// 【调用时机】由装配层（xuan-shell 的 DI bootstrap）在**构造任何
/// ThemeResourceStore 之前**调用一次。
///
/// 【幂等】StoragePolicyRegistry.register 对重复 entityType 抛 StateError
/// （storage_policy_registry.dart:38-42），而热重启 / 测试会重复进入装配期。
/// 因此本函数用 [_registered] 标志保证「只注册一次」，重复调用直接返回。
///
/// 【为何不用 try-catch 吞 StateError】那会掩盖「别的模块抢注了同名
/// entityType」这一真实错误。标志位只防自己重入，不防冲突。
abstract final class ThemeModuleRegistry {
  static bool _registered = false;

  /// 注册主题模块：三条存储策略 + 一个 XRAP 数据集。幂等。
  ///
  /// [themeMaterializer] 是**落地器工厂**，由装配层给出（§4.5 第 2 步）。
  /// 契约层不认识 reference 层的 `InMemoryThemeMaterializer`，故只透传不构造。
  static void register({
    required DatasetMaterializer Function() themeMaterializer,
  }) {
    if (_registered) return;
    // 1) S1a 策略注册
    StoragePolicyRegistry.register(themePackageEntityType, officialThemePolicy);
    StoragePolicyRegistry.register(themeOverrideEntityType, themeOverridePolicy);
    StoragePolicyRegistry.register(themeSelectionEntityType, themeSelectionPolicy);
    // 2) XRAP 数据集注册（§5.6.2）。注册期会校验 publisher == official 等
    //    不变式，失败抛 DatasetRegistrationError。
    DatasetRegistry.register(
      themeDatasetDescriptor(materializer: themeMaterializer),
    );
    _registered = true;
  }

  /// 仅测试用：重置标志，配合 StoragePolicyRegistry.clearForTesting()
  /// 与 DatasetRegistry 的对应清理方法。
  @visibleForTesting
  static void resetForTesting() => _registered = false;
}

/// entityType 常量。**不得内联字符串字面量** —— 测试与生产必须引用同一常量，
/// 否则拼写漂移不会被编译器发现。
const themePackageEntityType = 'theme_package';
const themeOverrideEntityType = 'theme_override';
const themeSelectionEntityType = 'theme_selection';
```

**调用点**：`xuan-shell` 的 DI bootstrap（**由 shell 侧调用，不在 S5a 交付范围**；S5a 交付 `ThemeModuleRegistry.register()` 这个可调用入口，并在纪要中记录 shell 侧的接线要求）。

⚠️ **这将是 `StoragePolicyRegistry` 的首个生产调用点**（§1.6 已核实当前零调用）。注册期两条不变式（总纲 §2.3.2 #4 resource 必须 official、#5 sources 非空性）**第一次被真实驱动**。验收 A8 必须真实调用 `ThemeModuleRegistry.register()` 并断言三条策略进入 `StoragePolicyRegistry.all` **且主题数据集进入 `DatasetRegistry`**，而非仅检查声明存在。

---

## 6. 三层合并模型

### 6.1 合并规则

```
用户覆盖层（private，可同步）      ← 最高优先级
        ↓ 覆盖
已安装主题包（resource，只读）
        ↓ 覆盖
bundled 默认主题（编译进包）        ← 兜底，永远存在
```

**逐 token key 自上而下取第一个命中。** 用户只覆盖了 `four_zhu_card.shadow.color`，其余全部落到主题包；主题包未定义的，落到 bundled。

**关键性质**：
- 换主题包时第 2 层整体替换，**第 3 层不动** → 用户的四柱设计跟着他走；
- 卸载主题包不碰覆盖层；
- 「恢复此项默认」= 删掉那一行 override；
- 存储成本 = 用户真正改动的那几个字段。

**与 S5c 源链的同构性**：`RuntimeConfigRepository` 是「有序源链，按序尝试直到命中」（总纲 §8.6.5）。此处是同一思想用在 **token key 粒度**上。

### 6.2 覆盖的最小单位

**已拍板：叶子字段 + 属性组补全。**（2026-08-03 人类授权按倾向拍板）

覆盖以**叶子标量**为存储单位，例如 `light.components.four_zhu_card.shadow.color`。

**已知摩擦**：`token_loader.dart` 的 `_parseShadow`（:289）是整组解析 —— `color` 为 null 直接返回 null（:292），`_parseBorder`（:303）同理。故 shadow / border 这类属性组在解析层是"要么全有要么全无"。

**处置（属性组补全，算法见 §6.6 第 4 步）**：合并层输出前，若某个"原子组"内有任一叶子来自较高层，则该组其余叶子从较低层补齐后**整组输出**。

**原子组清单（写死，不得由执行者自行推断）**：

| 组路径后缀 | 成员叶子 | 依据 |
|---|---|---|
| `.shadow` | `color` / `blur_radius` / `offset_x` / `offset_y` | `token_loader.dart:289-301` |
| `.border` | `color` / `width` | `token_loader.dart:303-311` |
| `.text.text_shadow` | `color` / `blur_radius` / `offset_x` / `offset_y` | `token_loader.dart:197-209` |
| `.padding` / `.margin` | `top` / `bottom` / `left` / `right` / `all` | `token_loader.dart:157-182`（也接受单标量，见下） |

**非原子组**（逐叶子独立覆盖，无需补全）：`.text` 的其余字段、`.icon`、以及 `radius` / `gap` / `opacity` / `min_width` / `min_height` / `max_width` / `max_height` 等标量。

**`padding` / `margin` 的双形态**：`token_loader.dart:160` 接受单个数值（`EdgeInsets.all`），:164 接受四方向 Map。**规则**：若较高层给的是标量，则整体替换较低层的值（不做补全）；若较高层给的是 Map 的某几个方向，则按原子组补全其余方向。

### 6.3 light / dark 的处理

**已拍板：token key 内含 brightness 前缀，两份完全独立。**（2026-08-03 人类授权按倾向拍板）

`light.components.xxx` 与 `dark.components.xxx` 是两条独立记录。用户改 light 不影响 dark。

理由：简单、无歧义。代价是用户要分别调两次 —— 属编辑器 UI 的便利问题（可提供"同步到暗色"按钮），不是存储层该解决的。

### 6.4 悬空覆盖（orphan）

**已拍板：保留 + 标记 orphan + 诊断暴露，不静默丢弃。**（2026-08-03 人类授权按倾向拍板）

用户覆盖了 `four_zhu_card.shadow.color`，主题包升级后该 key 不存在了（重构 / 改名）。

**判定规则（机械可判，供 §6.6 第 5 步使用）**：一条覆盖是 orphan **当且仅当**：其 token 路径在"已装主题包层"与"bundled 层"**都不存在同路径的叶子**。

**处置**：
1. 该覆盖**不参与合并输出**；
2. 其 key 出现在 `ThemeResolution.orphanedOverrideKeys`；
3. **数据不删除** —— 用户可能换回原主题包，届时自动恢复生效。

被否决：静默丢弃 —— **静默丢弃用户的创作是最坏选择**，与 S5c 的 A11 诊断链精神一致。

### 6.5 覆盖数量上限

不设硬上限；设**软上限 + 诊断告警**。理由：无上限时失控的编辑器可写入数万条，合并时逐 key 查找会拖慢启动。

**本设计只要求端口能暴露当前覆盖条数**（`listOverrides().length`）。具体阈值参照总纲 §10:1581 对缓存容量上限的处理方式（"S1a 定接口，S2 定阈值"），不在本设计决定。

### 6.6 合并算法完整规格（reference 实现的权威定义）

> **本节是 §0.1 reference 实现的行为规格。** 算法只有这一份权威定义，将来的 drift 生产实现必须复用它，不得重写。
> 机械执行者按本节逐步实现即可，无需推断。

#### 输入

| 名称 | 类型 | 说明 |
|---|---|---|
| `bundledTokens` | `Map<String, dynamic>` | bundled 默认主题的**扁平化** token（key 形如 `light.components.btn.radius`） |
| `packageTokens` | `Map<String, dynamic>?` | 已安装主题包的扁平化 token；无已装包时为 null |
| `overrides` | `Map<String, OverrideEntry>` | 用户覆盖差量 |

#### 步骤

**第 1 步 · 输入校验（不做扁平化）**

⚠️ **合并算法的三个输入已经是扁平 Map**（`Map<String, dynamic>`，key 形如
`light.components.four_zhu_card.shadow.color`）。**运行时不做扁平化** ——
YAML → 扁平 key 的转换发生在**构建期**（§4.3），设备上零 YAML 解析。

本步只做两条断言（reference 实现中为 `assert`，生产实现中为诊断日志）：

- 每个 key 均不含空段（`a..b` 非法）且不以 `.` 开头或结尾；
- 每个 value 均**非 Map**（若出现 Map 说明上游传了嵌套结构，是契约违反）。

**扁平 key 的构造规则（构建脚本遵守，此处仅为规格定义）**：

- 扁平 key = 从根到叶子的路径，以 `.` 连接；
- 递归下降，遇到**非 Map 值**即停止（该值是叶子）；
- **List 视为叶子**，不再下降（颜色数组等整体替换）；
- 空 Map `{}` 不产生任何 key。

> 📌 **本规则由构建脚本实现，不由 S5a 的 reference 合并器实现。**
> 写在这里是因为它定义了合并算法的输入契约 —— 构建脚本与合并器必须对同一套
> key 空间达成一致，否则两边各扁平各的会产生对不上的 key。

**第 2 步 · 逐 key 三层取值**

对全体 key 的并集（`bundled ∪ package ∪ override` 的 key 集合），逐 key 按优先级取第一个命中：

```
override（非 orphan）  >  package  >  bundled
```

- "命中"= 该层存在此 key（**注意：值为 `null` 也算命中**，不可用 `?? `写，须用 `containsKey`）；
- 三层都无 → 该 key 不出现在结果里。

**第 3 步 · 记录每层贡献数**

统计每层实际被采用的 key 数，写入 `ThemeLayerInfo.contributedKeyCount`（诊断用，A15 验收）。

**第 4 步 · 原子组补全**

对 §6.2 表中列出的每个原子组后缀：

1. 找出结果中属于该组的全部叶子 key；
2. 若该组**至少一个**叶子来自较高层（override 或 package），而组内**其他**成员叶子在结果中缺失；
3. 则从较低层按同样的优先级顺序补齐缺失成员；
4. 若较低层也没有，则该成员保持缺失（由 `token_loader` 的字段默认值兜底，如 `_parseShadow:293` 的 `blurRadius ?? 4.0`）。

**第 5 步 · 识别 orphan**

对 `overrides` 中的每个 key：若 `packageTokens` 与 `bundledTokens` **都不含**该 key（`containsKey` 为 false），则：

- 该 key 从第 2 步的结果中**移除**（它不该凭空创造 token）；
- 该 key 加入 `orphanedOverrideKeys`。

> ⚠️ 顺序要求：第 5 步的判定必须在第 2 步之后、第 4 步之前完成，否则 orphan 会参与原子组补全并污染结果。
> **实现顺序：1 → 5（判定）→ 2 → 4 → 3 → 6。** 本节按逻辑分组编号，实现顺序以此行为准。

**第 6 步 · 反扁平化（unflatten）与稳定排序**

- 把扁平 key 还原成嵌套 `ThemeTokenSection`（`components` / `chart` / `semantic` 三个分区）；
- **所有层级的 Map 必须按 key 字典序插入**（`SplayTreeMap` 或先排序后插入），保证 P7 的顺序稳定性；
- 顶层按 brightness 前缀拆成 `light` / `dark` 两个 `ThemeTokenSection`。

#### 缓存（P2 的实现要求）

reference 实现须持有一个**单条缓存**：

- 缓存键 = `(activeThemeId, packageVersion, overridesRevision)` 三元组；
- `overridesRevision` 是一个单调递增计数器，每次 `applyOverrides` / `removeOverrides` 成功后 +1；
- 缓存键相同 → **返回同一个实例**（`identical` 为真），不重新计算；
- 缓存键变化 → 重算并替换。

#### 不可变性（Codex P2 finding 的处置）

合并产出的 `ThemeTokenSection.components` / `chart` / `semantic` 必须是**不可修改视图**（`Map.unmodifiable`），且内部嵌套 Map 逐层 unmodifiable。

**理由**：若调用方能修改返回的 Map，会就地污染缓存实例，使 P2（identical）与 P7（顺序稳定）失效，且 bug 极难定位。

**验收**：A16 —— 对 `resolve()` 结果的任意层级 Map 执行写操作必须抛 `UnsupportedError`。

---

## 7. 启动路径与性能

**人类要求：首屏时间对标微信，越快越好。**

### 7.1 合并成本的量级（有实测支撑）

§1.1 实测：真实主题 **16 个 components + 少量 variants**，不是 1600 个。

三层合并 = 遍历约 16 × 2（light/dark）个组件 + variants ≈ **几十次 Map 查找**，**微秒级**。

**结论：合并本身不是性能瓶颈，一次都不会是。** 卡顿不会来自这里。

### 7.2 真实风险一：`updateShouldNotify` 的深比较

§1.5 核实：`XuanThemeScope.updateShouldNotify`（`xuan_theme_scope.dart:25`）用 `themeData != oldWidget.themeData`，`XuanThemeData` 是 Equatable，一次 `!=` 要比较 16 个组件 × 每个 16 个字段（`component_style.dart:102-106` 的 `props`）+ variants 嵌套 —— 数百次字段比较。

单次仍是微秒级，**但它在每次 InheritedWidget 重建时都跑**。

**防法（写入契约）**：
1. `resolve()` 的结果**缓存**：输入（主题 id + 覆盖层版本 + brightness）不变则返回**同一个实例** → `identical` 短路，深比较根本不执行；
2. 合并产出的 Map **key 顺序必须稳定**（有序 Map 或排序输出），否则 Equatable 的 Map 比较可能产生意外不等；
3. 验收判据：连续两次相同输入的 `resolve()` 结果必须 `identical`。

### 7.3 真实风险二：启动路径上的耗时操作（这才是"卡很久"的来源）

| 操作 | 量级 | 允许在启动路径？ |
|---|---|---|
| 读 bundled YAML + 解析 | 毫秒 | ✅ |
| 读用户覆盖（drift 查询） | 毫秒 | ✅ |
| 三层合并 | 微秒 | ✅ |
| 读已安装主题包的 token | 毫秒 | ✅ |
| **等网络拉 `defaultThemeId`** | 几百 ms ~ 超时 | ❌ **绝对禁止** |
| **等下载主题包（含 TTF/PNG）** | 秒级 | ❌ **绝对禁止** |
| **解压主题包 zip** | 几十 ~ 几百 ms | ❌ 禁止（安装期做，不在启动期） |
| **注册下载的字体（FontLoader）** | 未测 | ⚠️ 存疑，见 §9 |

**S5c 已经挡住了前两条**：`RuntimeConfigRepository.load()` 是 offline-first —— 缓存命中立刻返回、**不发任何网络请求**（`runtime_config_repository.dart:84-87`），后台 `refresh()` 的结果下次启动生效。这正是总纲 §8.4:1302「若写成 remote 优先，每次冷启动都要等网络请求，弱网下 app 卡在启动画面」。

**S5a 必须继承同一条纪律并扩展到主题包**：

```
启动：  bundled / 已装主题（纯本地） → 立刻渲染      ← 零网络、零解压
         ↓ 后台异步
异步：  拉 defaultThemeId → 发现要换 → 下载 → 安装 → 经 watchResolved 通知切换
```

**主题切换是"装好之后才生效"，不是"边下边等"。** 用户永远先看到一个立刻可用的界面。这同时兑现总纲 §2.1.2:167「拿不到时回退默认主题」。

### 7.4 写入路径的性能

批量 patch（§2.6）在性能上同样正确：
- 拖阴影滑块改 4 个字段 → 一次 `applyOverrides` → **一次**重建；
- 若用单字段写 → 4 次写 → **4 次**重建 + 中间态闪烁。

**补充要求**：编辑器实时预览**不得每次滑动都落库**，应防抖或在"确认"时提交，预览用内存态。因此**合并逻辑必须是纯函数、可脱离存储单独调用** —— 这条要在实现中体现。

### 7.5 性能验收判据

> 不可验证的性能承诺等于没有承诺。以下每条都必须可测。
> 门禁写法遵循 S1a / S5c 的血泪纪律：用**计数式 spy**，不用 `fail()`（调用方 catch-all 会吞掉 `TestFailure`）。
>
> ⚠️ Codex gStack 评审指出原版三处缺陷，已在下表修正：P1 无 fixture/warm-up 定义会假通过且 CI 抖动；
> P3/P4 的 spy 未绑定真实启动入口，测试可绕过生产调用链直接调 fake；P6 的「X ms」是自然语言占位符。

#### 共同 fixture（写死，供 P1/P2/P7 使用）

**`ThemeBenchFixture`**（`core/test/support/theme_bench_fixture.dart`）：

- bundled 层：**16 个 components**，每个含 §6.2 全部原子组（shadow 4 叶子 + border 2 叶子 + padding 4 叶子）+ 8 个标量字段 ⇒ 每组件 18 个叶子；
- 其中 6 个组件各带 1 个 variant（对齐 `default.yaml` 实测的 variants=6）；
- package 层：覆盖其中 8 个组件的各 3 个叶子；
- override 层：**50 条**（含 5 条 orphan，用于同时驱动第 5 步）；
- light / dark 各一份 ⇒ 全量约 **(16×18 + 6×18) × 2 ≈ 792 个叶子 key**。

**禁止用空 Map 或极小输入跑 P1** —— 那是假通过。fixture 的叶子总数须有下限断言（`>= 700`），防止 fixture 被悄悄改小。

| # | 判据 | 验证方式（已具体化） |
|---|---|---|
| **P1** | 三层合并 `ThemeBenchFixture` **< 5 ms** | 独立 benchmark 测试（`@Tags(['benchmark'])`）：**先 warm-up 20 次**（触发 JIT），再测 100 次取**中位数**。断言中位数 < 5 ms。<br>⚠️ **不进 CI 阻塞门禁**（Flutter debug VM 抖动大），标记为趋势观测；CI 只跑一次冒烟确认不超时（< 100 ms）。<br>⚠️ fixture 叶子数须 `>= 700`，防止用空输入假通过 |
| **P2** | 相同输入连续两次 `resolve()` 返回 `identical` 实例 | 单测断言 `identical(a, b) == true`；**再改一次 override 后断言 `identical` 为 false**（证明缓存键真的参与判定，不是恒返回同一实例） |
| **P3** | 启动路径**零网络请求** | **v4：结构性保证** —— `InMemoryThemeResourceStore` 构造器只接收 `ThemeLocalReader`，没有网络端口可传（§5.5.3）。架构守卫断言其参数表仅两项；**正向控制**断言 `localReader.bundledReadCount > 0` 且 `overrideReadCount > 0` |
| **P4** | 启动路径**不触发 XRAP 安装** | 把 `DatasetInstaller` 的 fake 传给装配层，断言 `resolve()` 期间其 `install` 调用次数 == 0 + 正向控制 `localReader.bundledReadCount > 0` |
| **P5** | 合并产出不持有"下一层"引用 | 结构断言：`ThemeTokenSection` 的字段类型中不出现 `ThemeResourceStore` / 任何 layer 引用；且 `resolve()` 返回后**销毁 store 实例**，结果仍可正常读取（证明无回指） |
| **P6** | 活跃世代读取挂起时 `resolve()` **50 ms 内**返回 bundled 兜底 | 六步见 **§5.5.4**：注入 `SlowLocalReader`（`readActiveThemeTokens` 永不完成），`Stopwatch` 计时，断言 < 50 ms + 结果来自 bundled + **不抛异常** |
| **P7** | 合并输出的 Map key 顺序稳定 | 同一 fixture 合并 **10 次**，逐层 `keys.toList()` 序列**逐元素**比对全部相等；且断言顺序为**字典序**（`keys.toList()` == `keys.toList()..sort()`） |
| **A16** | 结果不可变 | 对 `resolve()` 结果的 `components` / 嵌套 Map 执行 `[]=` 与 `remove()`，断言抛 `UnsupportedError`（§6.6 不可变性要求） |

---

## 8. 与外部契约的对齐

### 8.1 必须遵守的在途 OpenSpec change（逐条 SHALL 映射）

`/xuan-migration/openspec/changes/theme-token-customization-contract/` 已过 4 轮评审并签署。下表**逐条**映射其 `specs/theme-token-system/spec.md` 的 SHALL 条款，每条给出 S5a 的处置与**对应验收标准编号**（无验收标准 = 未闭合，不得进 ACT）。

| spec.md 位置 | SHALL 条款 | S5a 的处置 | 验收 / 承接方 |
|---|---|---|---|
| :54 | **缺失字段保持 legacy fallback** —— widget 消费的字段在主题中缺失时，保留既有视觉回退或文档化默认 | 合并算法第 4 步的原子组补全；补不齐时由既有 `token_loader` 的字段默认兜底（§6.6） | ✅ **A14c**（S5a 内） |
| :60 | **数值非法须 caught error + 诊断**，不得抛未捕获 `TypeError` | **不在 S5a**：非法值在**构建期**就该被拒绝出包（§4.3）；设备侧由既有 `token_loader.dart:88` 的 `_parseCheckedDouble` 兜底，S5a 未新增数值解析。S5a 的责任仅为**不吞值**（原样透传） | ⬜ 承接方 **BUILD-THEME**；S5a 侧 ✅ **A19** |
| :69–74 | **Widget / 绘图包不得直接解析 YAML**，不得 import `xuan_config` | S5a 输出 `ThemeTokenSet`（已解析结构），不传 raw YAML；`persistence_core` 亦不依赖 `xuan_config` | ✅ **A5b**（S5a 内） |
| :86 | **Additive schema 演进**：未知字段忽略，渲染不得失败 | **不在 S5a**：未知字段的取舍在构建期扁平化时决定（§4.3）。S5a 的责任是**对任何 key 一视同仁、不做白名单过滤**，故未知 key 天然透传、不会导致渲染失败 | ⬜ 承接方 **BUILD-THEME**；S5a 侧 ✅ **A19** |
| :116 | **Canvas 文件所有权**：不得编辑 `lib/painter/**` 等 | §8.3 声明不碰；S5a 全部产出在 `xuan-storage/core/` 内 | ✅ **A17**（S5a 内） |
| :123 | **API 未稳定时停止**：绘图包 API 未稳定前不得集成 chart | `chart` 段仅透传不解析（§8.3） | ✅ **A17**（S5a 内） |
| :134 | **可执行计划门禁**：实施前须列精确文件 / 测试 / fallback 断言 / 验证命令 / stop condition | 本文档 §11 交付物清单 + 纪要 A1–A20/P1–P7 逐条给命令 | ✅ **纪要整体** |
| Tier 3 隔离 | marketplace / cloud sync / uploaded assets **MUST NOT** 在 Tier 1 theme-token 工作下实现，须独立 change | **S5a 即是那个独立 change**（design.md:108 明写这些 require separate OpenSpec changes） | — |
| 第二轮评审 #5 | **降级分粒度**：整体形状非法 → `DefaultXuanThemeData`；单字段非法 → 该字段默认 | **不在 S5a**：整体形状非法在构建期即拒绝出包；单字段降级由既有 `token_loader` 承担（S5a 未改动它） | ⬜ 承接方 **BUILD-THEME** + 既有 `token_loader` |

> ⚠️ **承接方 `BUILD-THEME` 是一个尚未立项的任务**（主题构建脚本：YAML → `.jsonl` 载荷 +
> sha256/rowCount 真值）。上表三条 ⬜ 必须写进它的验收标准，**S5a 转 ACT 时须同时创建
> 该任务的占位纪要**，否则这三条 SHALL 会在移交中丢失（§11.5 已登记）。
>
> 📌 **v4 的「版本兼容规则」引用已失效** —— 那套规则随主题包格式一并移交 XRAP，
> 本表已改为直接指向构建期与既有 `token_loader`，不再引用已删章节。

### 8.2 一条归属判断（架构决定，非源码已证实）

`xuan_config/lib/src/config_repository.dart:8` 写着「Phase 0a 不做 `$ref` 解析、**override 合并**、schema 校验（Phase 0+）」。

**本设计的判断**：该处的 "override 合并" **不指** 本文档所说的"用户覆盖主题包"，故用户覆盖层的合并不归 `xuan_config`。

**证据强度的诚实说明**（按 Codex gStack 评审的指正降调）：

| 证据 | 能证明什么 | 不能证明什么 |
|---|---|---|
| `config_repository.dart:8` 与 `$ref` 并列出现 | 支持"配置解析阶段的合并"这一解释 | **不能**证明它特指 YAML 内部 merge |
| 该行只有一句 Phase 0a TODO，未定义 override 的对象、算法或层级 | —— | 无法据此推断任何具体语义 |
| `TokenLoader.fromConfigResult` 消费已解析的 `ConfigResult`，看不到 raw YAML（在途 change 第三轮评审 E3） | 证明**用户覆盖不应放在 `TokenLoader`** | **不能**单独证明它应归 storage |

**结论**：这是一条**架构决定**（用户覆盖层的合并归 storage / 装配层），理由是数据在 storage、合并的是已解析 token 结构、且 `xuan_config` 的 `ConfigSource.loadRaw → String` 签名要求源差异挡在字符串边界外。**但它不是"源码已证实"的事实**，本设计此前的表述过强，已修正。

> 📌 若将来 `xuan_config` 明确了它那句 override 的语义，本条需复核。

### 8.3 必须避让的并行工作

`xuan-qizhengsiyu` 的 Canvas / painter 提取正在并行进行，有明确文件所有权：`lib/painter/**` 归 Canvas agents，`lib/painter/chart_style/**` 是冻结的共享桥接区，`lib/presentation/widgets/rings/*_painter.dart` 亦归其所有。

**S5a 声明：不碰任何 chart 相关路径与 painter 文件。** 主题包中的 `chart` token 段仅做透传（合并后原样交出），不做语义解析。

---

## 9. 待决事项

> Codex gStack 评审 P0：原版有 5 项标"转 ACT 前确认"，其中前三项已被 A9–A14 当作既定行为在测 —— 未定的东西不能进验收标准。
> 现已全部关闭（人类 2026-08-03 授权按倾向拍板 + 本次补充决定）。

### 9.1 已关闭（本轮拍板）

| 事项 | 决定 | 位置 |
|---|---|---|
| 覆盖最小单位 | ✅ **叶子字段 + 原子组补全**，原子组清单写死 | §6.2 |
| light/dark | ✅ **key 内含 brightness 前缀，两份完全独立** | §6.3 |
| 悬空覆盖 | ✅ **保留 + 标记 orphan + 诊断暴露**，判定规则机械可判 | §6.4 |
| 主题包签名 | ⬜ **归 XRAP** —— 验签是安装流程的一环，由 `DatasetInstaller` 负责，本设计不定义任何验签类型（§0.0 裁定 3） |
| bundled 默认主题物理位置 | ✅ **XRAP generation 0**（`bundledManifest` 恒存在，`dataset_descriptor.dart:33-37`）。构建脚本从 `theme/config/presets/default.yaml` 预构建产出载荷；**S5a 不跨仓库读取**，token 由 `ThemeLocalReader` 注入（stop condition #2） |

### 9.2 仍开放（不阻塞 ACT）

| 事项 | 状态 | 归属 |
|---|---|---|
| **`ConfigBootstrap` 三个真值**（`endpoints` / `allowedHostSuffixes` / `l0PublicKeyBase64`）仍为占位符 | ⬜ **已知非阻塞背景**（裁定 4）：`dataset_source.dart:61` 未配置返回 null，此时只用内置世代；`bundledManifest` 恒存在、冷启动零网络。实证 T1 全程 generation 0 未用到域名或公钥。**不构成 S5a 的 stop gate** | 与 S5a 无关，由 XRAP 远端源任务承接 |
| 覆盖数量软上限的具体阈值 | 本设计只定接口（`listOverrides().length` 可查） | 后续（参照总纲 §10:1581） |
| **下载字体的运行时注册（`FontLoader`）与失败降级** | ⚠️ **未查证** | 资产引入时深挖（S5a 无资产） |
| shell 侧 `version: 1` 空壳的废弃 | 已定方向（§9.1），执行不在 S5a | 主题内容就绪时 |

---

## 11. 交付物清单（精确到文件）

> **v4 已大幅收窄**：删掉安装机制相关文件，新增 `InMemoryThemeMaterializer`（XRAP Materializer 实现）与数据集声明。

### 11.1 契约层（零实现）

| 文件 | 内容 | 验收 |
|---|---|---|
| `core/lib/model/theme_token_types.dart` | `ThemeTokenSet` / `ThemeTokenSection` | A6, A16 |
| `core/lib/model/theme_resolution.dart` | `ThemeResolution` / `ThemeLayerInfo` / `ThemeSelectionOrigin` / `ThemeLayerKind` | A15 |
| `core/lib/model/theme_resource_store.dart` | `ThemeResourceStore` 端口（读合并结果 + 写覆盖层 + 主题选择，无安装类方法） | A3, A6, A7 |
| `core/lib/model/theme_value_types.dart` | `LocalTheme` / `OverrideEntry` / `OverrideOrigin` | A6 |
| `core/lib/model/theme_source_ports.dart` | **一个**注入端口 `ThemeLocalReader`（§5.5.2） | A3, A6, P3 |
| `core/lib/model/theme_storage_policies.dart` | 三条 `StoragePolicy` const + 三个 entityType 常量 | A8 |
| `core/lib/model/theme_dataset.dart` | `themeDatasetDescriptor({required DatasetMaterializer Function() materializer})` + `themeDatasetId` + `kThemeAppSchemaRevision` + `kThemeBundledManifest`（§5.6.2） | A8, A20 |
| `core/lib/model/theme_module_registry.dart` | `ThemeModuleRegistry.register({required DatasetMaterializer Function() themeMaterializer})`（策略 + XRAP 数据集，幂等）+ `resetForTesting()` + 三个 entityType 常量（§5.6.3） | A8 |

⚠️ 契约层共 **8 个文件**（A3 覆盖下限相应为 8）。

### 11.2 reference 实现层

| 文件 | 内容 | 精确签名出处 | 验收 |
|---|---|---|---|
| `core/lib/reference/theme_token_merger.dart` | §6.6 合并算法的权威实现（纯函数，无状态） | §6.6 | A9–A13, A14c, A19, P1, P7 |
| `core/lib/reference/in_memory_theme_resource_store.dart` | `InMemoryThemeResourceStore`（构造器**只有** `{required String scopeUid, required ThemeLocalReader localReader}`，§5.5.3）+ 缓存 | §5.5.3 | P2, P3, P5, P6 |
| `core/lib/reference/in_memory_theme_materializer.dart` | `InMemoryThemeTokenStore`（落地物共享持有者）+ `InMemoryThemeMaterializer implements DatasetMaterializer`（消费 jsonl 载荷 → 共享 store，含世代隔离） | §4.4 | A20, A21 |
| `core/lib/reference/theme_assembly.dart` | `XrapThemeLocalReader implements ThemeLocalReader`（按 XRAP 活跃指针取世代号 → 从共享 store 取落地物，六步无分支歧义）+ `Future<ThemeResourceStore> assembleThemeStore({required String scopeUid, required DatasetInstaller installer, required Map<String, OverrideEntry> initialOverrides})`（**P4 的唯一注入入口**，四步装配） | §4.5 | A21, P4 |

⚠️ reference 实现层共 **4 个文件**。
⚠️ **`core/lib/reference/` 是新目录**。A3 的零实现扫描须**排除**此目录，扫描范围限定 `core/lib/model/theme_*`。

> 📌 **`theme_assembly.dart` 不可省**：它是 §4.5 那条「安装 → 落地 → 启动读取」链的唯一
> 连接点，也是 P4 的唯一注入入口。机械执行者若按旧清单只建 3 个文件，P4 直接不可执行，
> 且 R4-P1-3 的断链会原样重现。

### 11.3 测试与支撑

| 文件 | 内容 |
|---|---|
| `core/test/support/theme_bench_fixture.dart` | §7.5 共同 fixture（叶子数 >= 700）+ `ThemeLocalReader` 的 fixture 实现 + `bundledJsonlBytes()`（§4.3 行 schema 的 `Stream<List<int>>`，供 `CountingDatasetInstaller` 落地 generation 0） |
| `core/test/support/theme_probes.dart` | §5.5.4 的 `CountingLocalReader` / `SlowLocalReader` / **`CountingDatasetInstaller`**（三个探针的完整定义见 §5.5.4，照抄即可编译） |
| `core/test/theme_token_merger_test.dart` | A9–A13、A14c、A19 合并语义 |
| `core/test/theme_resource_store_contract_test.dart` | A6/A7/A15/A16 契约形状 + 溯源 |
| `core/test/theme_module_registry_test.dart` | A8 注册与幂等（策略 + XRAP 数据集） |
| `core/test/theme_materializer_test.dart` | A20：世代隔离 / dropGeneration 幂等 / rowCount 真实性 / 不读载荷 `g` |
| `core/test/theme_startup_path_test.dart` | **A21**（§4.5 装配链闭合）+ P3/P4/P5/P6 |
| `core/test/theme_merge_bench_test.dart` | P1（标 `@Tags(['benchmark'])`） |

⚠️ 测试与支撑共 **8 个文件**（A2 的计数下限相应为 8）。**A21 不新增文件** ——
它测的是 §4.5 那条装配链，与 P4 同属启动路径，放同一个文件。

### 11.4 Stop conditions（触发即停，报人类）

1. **S1a 契约或 XRAP 契约不在当前分支基线** —— 开工第一步验证 `core/lib/model/storage_policy.dart` 与 `core/lib/model/dataset/dataset_materializer.dart` 均存在；
2. **本 ACT 的任何文件读取 `theme` 仓库** —— 跨仓库读取在 S5a ACT 范围外。
   ⚠️ **澄清（Codex R3 P1-6）**：构建脚本**确实**要读 `theme/config/presets/*.yaml`，
   但**构建脚本不属于本 ACT**（它是独立任务 `BUILD-THEME`，见 §11.5）。
   本 ACT 交付的全部文件（`core/lib/model/theme_*`、`core/lib/reference/*`、
   `core/test/*`）**均不得**出现 `theme/` 路径引用；测试用的 bundled token 由
   **fixture 内联常量**提供，不从任何外部文件读取。执行者若发现需要读 theme 仓库，
   说明范围理解错了，即停。
3. **`theme` 包出现任何改动** —— A4 门禁触发即停；
4. **发现需要在 XRAP 的 `DatasetMaterializer` 之外新增扩展点** —— 说明协议有缺口，须走协议变更，不得在 S5a 侧绕过（§4.2）；
5. **需要触碰 `xuan-qizhengsiyu/lib/painter/**`** —— Canvas 提取工作所有权，须先握手。

### 11.5 移交后续任务的项（每项有唯一承接 ID，不得丢失）

| 承接 ID | 项 | 移交去向 | 该任务须承接的 SHALL |
|---|---|---|---|
| — | 主题包下载 / 校验 / 世代 / 指针翻转 / 回滚 / GC / 幂等 | **XRAP `DatasetInstaller`**（已实现） | — |
| — | 主题包验签 | **XRAP 安装流程**（已实现） | — |
| — | manifest 版本拒装（原 A14b） | **XRAP** `DatasetDescriptor.supports()`（已实现） | — |
| **BUILD-THEME** | **主题构建脚本**：`theme/config/presets/*.yaml` → `.jsonl` 载荷（§4.3 行 schema）+ sha256 / bytes / rowCount 真值 → 写进 `DatasetManifest` | **新建任务，尚未立项**。照 T1 的 `assets/tool/build_geo_sql.py` + `BUILD-REPORT.md` 形制 | **spec.md :60**（数值非法在构建期拒绝出包）<br>**spec.md :86**（未知字段取舍）<br>**第二轮评审 #5**（整体形状非法即拒绝出包） |
| **THEME-DRIFT** | 主题落地的 drift 表与 schema 版本（reference 用内存 Map，生产需建表） | **新建任务**，与 S1d / S5b 协调 `schemaVersion` 号 | — |

> ⚠️ **`BUILD-THEME` 是 S5a 转 ACT 的伴生前提**：三条 SHALL 挂在它名下。
> **转 ACT 时须同时创建它的占位纪要**（哪怕只有目标 + 那三条 SHALL），
> 否则这三条会在移交中悄悄丢失 —— 这正是 Codex R3 P1-4 指出的风险。

### 11.6 残留门禁（防止本轮的失守重演）

> Codex R3 的 P0 是「已裁定删除的类型仍有残留」，根因是我用正则批量替换后**未独立验证**。
> 以下门禁写进 ACT 的 VERIFICATION，每次执行都跑，不依赖人的自觉。

```bash
# scripts/run_s5a_residue_gate.sh
# 已裁定移出 S5a 的标识符，出现即失败
FORBIDDEN='InstalledTheme|AvailableTheme|ThemeRemoteFetcher|ThemePackageStore|ThemeSignatureVerifier|ThemeSignatureVerdict|refreshCatalog|listInstalled'
HITS=$(grep -rnE "$FORBIDDEN" core/lib/model/theme_*.dart core/lib/reference/ core/test/theme_*.dart 2>/dev/null | wc -l | tr -d ' ')
[ "$HITS" = "0" ] || { echo "RESIDUE_FOUND: $HITS"; exit 1; }
# 覆盖下限：防止 glob 失配扫到 0 个文件而假绿
FILES=$(ls core/lib/model/theme_*.dart 2>/dev/null | wc -l | tr -d ' ')
[ "$FILES" -ge 8 ] || { echo "SCAN_TOO_NARROW: only $FILES files"; exit 2; }
echo "RESIDUE_GATE_OK (scanned $FILES contract files)"
```

**必须做变红自检**：临时在任一 `theme_*.dart` 里写一行 `// InstalledTheme`，
确认脚本 `exit 1`；删掉后回到 `exit 0`。一个绿的门禁若证明不了自己能红，它就是假的。

> 📌 **门禁扫代码文件，不扫文档**。本节的 `FORBIDDEN` 变量与上面这行自检示例
> 是门禁的**定义**，本身含这些标识符属正当。评审若做全文 grep，请排除
> 设计 §11.6 与纪要的门禁说明段 —— 那里出现是必需的，不是残留。

---

## 10. 决策记录（含被否决方案）

| 决策 | 结论 | 被否决的替代方案与理由 |
|---|---|---|
| 主题分发形态 | **整包分发**（manifest + token + 资产） | token/资产分半 —— 产生二维版本兼容矩阵；Marketplace 上传要打包两半；卸载无法原子 |
| 主题包当前形态 | 纯 YAML（实测 5–9KB、16 组件、零二进制），**但格式为资产预留位** | 按"数 MB 图/字体"设计 —— 实测不成立（总纲 §2.1.2:162 有误）；但不留位则加资产时要破坏性升级 |
| `theme` 包的改动 | **零改动**，保住零 IO 边界 | 让 `theme` 依赖 `persistence_*` 直接取数据 —— 破坏它自陈的边界（`token_loader.dart:11`），且造成 UI 层依赖存储层 |
| Controller 的位置 | **`ShellThemeController`（shell 侧，已存在）**；`theme` 是纯函数库 | 把 `theme` 当 Controller —— 它零 IO，拿不到任何数据 |
| 用户覆盖层的分类 | **`private` + `user`，落 drift，走现有同步引擎** | 放 `preferences` —— SharedPreferences 零同步（实测），换设备用户创作丢失；且它是 UGC 主题雏形，塞 JSON string 取不出来 |
| 覆盖的存储形态 | **只存差量 + 来源** | ①生成合并后的 C 包 ②从 A 拷完整文件只替换一处 —— 二者同病：A 升级不跟随、用户设定与默认值不可分、存储放大 |
| C 包的生成时机 | **仅在用户显式"导出/上架"时** | 每次编辑后台生成 —— 低频动作被做成高频副作用 |
| 覆盖的写入形状 | **批量差量 patch + 显式 `removeOverrides`** | ①整体覆盖 —— 摧毁差量模型 + 读改写竞态 ②单字段写 —— 一次编辑多字段导致多次重建与中间态闪烁 |
| 读写关系 | **不对称**：读=合并结果，写=只碰覆盖层 | 对称 read/write —— 会把主题包内容写回覆盖层，摧毁差量模型 |
| 覆盖取值方式 | **值快照 + 记来源** | 引用 B 包 —— B 卸载即破坏用户主题，不可接受的耦合。（资产例外：记 `BlobHandle` 走引用计数） |
| 覆盖 vs blob 引用计数 | 覆盖用**增量 patch**；blob 用**全量对账**（`reconcileRefs`） | 统一为全量声明 —— 覆盖可能数十条而一次编辑只碰一两条，全量会强迫先读全量，引入读改写竞态 |
| 主题 id 的优先级 | **用户选择 > 官方下发 `defaultThemeId` > bundled** | 官方下发优先 —— 会覆盖用户的显式选择 |
| 启动路径 | **纯本地立刻渲染；下载/切换全在后台** | 启动等 `defaultThemeId` 或等下载 —— 弱网卡启动画面（总纲 §8.4:1302 同款教训） |
| 主题包的 blob 类别 | **公开缓存类**（`BlobVisibility.public` + `BlobTier.cache`） | 真相源类 —— 主题包丢了可重新下载，不该占不可回收的真相源区 |
| Marketplace | **当前完全不做**，将来独立包/子模块 | 现在预建 —— 总纲 §9.1:1507 已收窄；但格式与机制必须现在就为它留位 |
| S1b 依赖 | **不依赖** | 以为要等 S1b —— 覆盖层同步到云端单 peer 即满足跨设备，S1b 解决的是多 peer fan-out |
| chart token 处理 | **仅透传，不解析** | 解析 chart —— 会撞上并行的 QiZhengSiYu Canvas 提取工作的文件所有权 |

---

## 附录 · 与总纲的偏差声明

本设计与总纲不一致之处，均已在正文给出实查依据：

| 总纲原文 | 本设计的修正 | 依据 |
|---|---|---|
| §2.1.2:162「样式资源每个数 MB（图/字体）」 | 当前实测 5–9KB 纯 YAML，零二进制；资产为将来预留 | §1.1 实测 |
| §8.1:1235 示意图直接写 `ThemeRepository.get(...)` | xuan-storage 中**不存在** `ThemeRepository`；主题现状整个在独立 `theme` 仓库 + `xuan_config` | 全仓库 grep 零命中 |
| §2.1.2:163「落地载体 blob 为主 + row 元数据」 | 当前 row 为主（token）+ blob 为空；资产引入后才 blob 为主 | §1.1 实测 |

总纲未提及但对 S5a 有决定性影响的事实：

- 存在独立的 `/xuan-migration/theme` 仓库（总纲 §0.1 的包名对照表未列）；
- 存在在途的 `theme-token-customization-contract` OpenSpec change（4 轮评审已签署），其 Tier 3 明确把 marketplace / sync / uploaded assets 推给独立 change —— **S5a 即是该独立 change**；
- `xuan-qizhengsiyu` 的 Canvas 提取工作正在并行，有明确文件所有权边界。
