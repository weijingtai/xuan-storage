# S5a 样式资源分发 · 详细设计

- 日期：2026-08-03
- 状态：讨论完成，待转译为 ACT
- 范围：主题资源的分发、安装、读取与用户覆盖；跨 `xuan-storage` / `xuan_config` / `theme` / `xuan-shell` 四个仓库的职责边界
- 上游文档：
  - [2026-07-31 Storage 分层隔离存储架构 · 设计总纲](2026-07-31-storage-architecture-design.md)（下称"总纲"，引用格式 `总纲 §x.y:行号`）
  - `xuan-storage/tasks/mimo-storage-s1a-contracts.md`（S1a 契约层，已交付）
  - `xuan_config/tasks/mimo-config-s5c-remote-source.md`（S5c 控制下发，已交付，最新提交 `a324902`）
  - `/xuan-migration/openspec/changes/theme-token-customization-contract/`（在途 OpenSpec change，含 4 轮评审）

---

## 0. 本文档的定位

本文档是 **S5a 的详细设计**，不是 ACT。下游流程是 `wjt-act` 转译 → `wjt-react` 跨模型闸门 → 下发执行。

它要确定的是：

1. 主题资源的分发形态（整包 vs 分半）与包格式；
2. 四个仓库各自的职责边界，以及为什么 `theme` 包不该改；
3. 主题资源读写契约的端口签名（读合并结果 / 写用户覆盖层）；
4. 三层合并模型与用户覆盖的语义；
5. 启动路径的性能预算与可验证判据。

**本文档中的 Dart 代码块是端口签名，不是实现。** S5a 的交付物形态参照 S1a：契约先行，实现随后。

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

`theme/lib/` 共 19 个 dart 文件。搜 `SharedPreferences|dart:io|File(|drift|sqlite|http` **零命中**。

`theme/lib/src/loader/token_loader.dart:11` 的注释自陈边界：

> 内部类：theme 层禁止读取 YAML / 解析 `$ref` / 执行 schema 校验（那是 xuan_config 的事）。

它唯一的外部依赖是注入进来的 `ConfigRepository`（:29 调 `loadThemeConfig`），失败降级 `DefaultXuanThemeData.themeSet`（:32）。

**结论：`theme` 的职责是「给定已解析的 token → 产出 `XuanThemeSet`」的纯函数库。保住它零 IO 是本设计最有价值的约束之一。**

### 1.3 shell 侧的主题链路当前空转

- `xuan-shell/lib/theme/shell_theme_controller.dart` 是真正的 Controller（`ChangeNotifier`，持有 `XuanThemeSet` + `ThemeMode`）。
- 它的 `initialize()` 调 `ShellThemeLoader.loadAndValidate(...)` 两次，但该方法签名是 `Future<void>`（`shell_theme_loader.dart` 末），**只做校验不产出主题**，返回值无从接收。
- 因此 `_themeSet` 始终是构造器里的 `DefaultXuanThemeData.themeSet`（代码内置默认）。
- `xuan-shell/assets/themes/default.yaml` 全文 **197 字节**，`light`/`dark` 下的 `semantic`/`components`/`chart` 全是空 Map；与 `theme/config/presets/default.yaml`（9.1K，`version: 2`）**不是同一份**，shell 侧是 `version: 1` 的空壳。

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

⚠️ **`ConfigBootstrap.endpoints` / `allowedHostSuffixes` / `l0PublicKeyBase64` 三个真值仍是占位符**（`'config.invalid'` / `'invalid'` / 含"占位"字样），待人类填入。**这是 S5a 真实下载能力的前置阻塞项。**

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

**归为 `private` 类后自动获得**：E2EE、cloud + 三条 P2P 通道、跨设备同步、导出导入。**不需要为它新建任何同步机制。**

> ✅ **不依赖 S1b**：现有同步引擎已能同步到云端单 peer，足以满足"换设备能带走"。S1b 解决的是多 peer fan-out，S5a 不等它。

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

## 4. 主题包格式

### 4.1 包结构

```
theme-package.zip
├── manifest.yaml          必需。包的身份、版本、内容清单
├── tokens/
│   ├── theme.yaml         必需。token 主体（light/dark × components/chart/semantic）
│   └── components/*.yaml  可选。按组件拆分（对应 theme/config/components/ 的现状）
└── assets/                可选。当前为空，为将来预留
    ├── fonts/*.ttf
    ├── icons/*.png|*.svg
    └── animations/*.json  Lottie
```

### 4.2 `manifest.yaml` 字段

| 字段 | 必需 | 说明 |
|---|---|---|
| `package_format_version` | ✅ | **包格式**版本（不是主题内容版本）。决定解包器如何理解这个包 |
| `id` | ✅ | 主题唯一标识，对应 `defaultThemeId` 的取值 |
| `version` | ✅ | 主题内容版本（语义化版本） |
| `display_name` | ✅ | 展示名 |
| `author` | ✅ | 作者 |
| `publisher` | ✅ | `official` / `user`（当前恒为 `official`，字段现在就要有） |
| `token_schema_version` | ✅ | token 遵循的 schema 版本，对应现有 YAML 的 `version:` 键 |
| `min_app_version` | ✅ | 最低兼容 app 版本。低于此版本的 app 拒绝安装 |
| `assets` | ⬜ | 资产清单：每项含 `path` / `sha256` / `size` / `type` |
| `preview` | ⬜ | 预览图路径（Marketplace 用，当前可空） |

### 4.3 版本兼容规则

总纲 §10:1583 把"版本兼容"判给 S5a。规则如下，**与在途 OpenSpec change 的 "Additive YAML Schema Evolution" 要求一致**：

| 情形 | 行为 |
|---|---|
| `package_format_version` 高于本 app 支持的最高版本 | **拒绝安装**，提示升级 app |
| `min_app_version` 高于当前 app 版本 | **拒绝安装**，提示升级 app |
| `token_schema_version` 高于 app 认识的 | **安装但降级解析**：未知字段静默忽略（不得崩溃） |
| token 中出现未知字段 | **静默忽略**，不影响渲染 |
| token 中某字段值非法 | 该字段回退其默认值；若整体结构非法则整包回退 `DefaultXuanThemeData` |

> 最后两条直接来自在途 change 的 spec：「unknown fields → loader SHALL ignore」「widget rendering SHALL not fail」。
> 倒数第二条的粒度要求来自该 change 第二轮评审 finding #5：**一个坏的 `shadow.color` 不得让整个主题失效**。

### 4.4 完整性校验

主题包按公开缓存类 blob 处理（`BlobVisibility.public` + `BlobTier.cache`），**内容寻址天然提供完整性校验**（总纲 §6.1:1046 每 chunk 独立 sha256）。资产逐项的 `sha256` 另在 manifest 内声明，解包后校验。

**由此免费获得**：分块下载、断点续传、缓存 LRU 清理、紧急下架黑名单清除（`LocalBlobStore.evictByExternalId`，总纲 §7.5.1 第 3 层）。

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
  /// 【性能硬约束】本方法**不得发起任何网络请求、不得解压主题包**。
  /// 它只读本地已就绪的数据。远端刷新走 [refreshCatalog]，下载走 [install]。
  /// 详见 §7 启动路径预算。
  ///
  /// 【幂等与缓存】相同输入（主题 id + 覆盖层版本）连续调用必须返回
  /// `identical` 的实例，以便 `XuanThemeScope.updateShouldNotify` 的深比较
  /// 被 identical 短路（§7.2）。
  Future<ThemeTokenSet> resolve({CancellationToken? cancel});

  /// 当前生效主题的解析结果流。覆盖层变更、主题切换、安装完成时推送新值。
  ///
  /// 【为什么是 Stream】主题下载完成是异步事件，UI 需要被通知而非轮询
  /// —— 这是"下载不阻塞启动"（§7.3）的落地形式。
  Stream<ThemeTokenSet> watchResolved();

  /// 已安装主题清单（含 bundled 默认）。
  Future<List<InstalledTheme>> listInstalled();

  /// 可安装主题清单（来自 xuan_config 下发的 catalog）。
  ///
  /// 【离线可用】返回上次缓存的清单；无缓存时返回空列表，**不抛异常、不等网络**。
  Future<List<AvailableTheme>> listAvailable();

  // ── 写 · 主题选择 ──

  /// 用户显式选择主题。写入 private 层，跨设备同步。
  ///
  /// 选择后 [ThemeResolution.selectionOrigin] 变为 userSelected，
  /// 此后 xuan_config 下发的 defaultThemeId **不再覆盖**用户的选择。
  ///
  /// [themeId] 必须已安装，否则抛 StorageError（调用方应先 [install]）。
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

  // ── 写 · 主题包生命周期 ──

  /// 安装主题包。下载 → 校验 → 解包 → 落 blob + row。
  ///
  /// 【不阻塞 UI】本方法耗时可达秒级，调用方不得在启动路径上 await 它。
  /// 安装完成后经 [watchResolved] 通知。
  Future<void> install(String themeId, {
    CancellationToken? cancel,
    void Function(int received, int total)? onProgress,
  });

  /// 卸载主题包。**不影响用户覆盖层**（§2.4：覆盖层独立于包）。
  ///
  /// 若卸载的是当前生效主题，自动回退 bundled 默认。
  Future<void> uninstall(String themeId);

  /// 后台刷新可安装主题清单。**结果下次 [resolve] 生效**，
  /// 与 S5c 的 RuntimeConfigRepository.refresh 同语义（offline-first）。
  ///
  /// 失败返回 false，不抛 —— 后台刷新失败不是致命错误。
  Future<bool> refreshCatalog({CancellationToken? cancel});
}
```

### 5.4 配套值类型

```dart
/// 已安装主题的元数据（drift row）。
final class InstalledTheme {
  /// 主题 id。
  final String id;

  /// 主题内容版本。
  final String version;

  /// 展示名。
  final String displayName;

  /// 作者。
  final String author;

  /// 发布者身份。当前恒为 official，字段为将来 UGC 预留（§3.3 约束 2）。
  final Publisher publisher;

  /// 是否为 bundled 内置主题（内置主题不可卸载）。
  final bool isBundled;

  /// 安装时刻（UTC）。
  final DateTime installedAtUtc;

  /// 占用字节数（含资产），用于存储管理 UI。
  final int sizeBytes;

  const InstalledTheme({
    required this.id,
    required this.version,
    required this.displayName,
    required this.author,
    required this.publisher,
    required this.isBundled,
    required this.installedAtUtc,
    required this.sizeBytes,
  });
}

/// 可安装主题（来自下发的 catalog，尚未安装）。
final class AvailableTheme {
  /// 主题 id。
  final String id;

  /// 最新版本。
  final String version;

  /// 展示名。
  final String displayName;

  /// 作者。
  final String author;

  /// 预计下载字节数，供 UI 提示。
  final int downloadBytes;

  /// 是否已安装（已安装则可比较版本决定是否可更新）。
  final bool isInstalled;

  const AvailableTheme({
    required this.id,
    required this.version,
    required this.displayName,
    required this.author,
    required this.downloadBytes,
    required this.isInstalled,
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

### 5.5 存储策略声明与注册

```dart
// 主题包：resource 类，row 元数据 + blob 资产
const officialThemePolicy = StoragePolicy.resource(
  carriers: {Carrier.row, Carrier.blob},
  sources: {Source.bundled, Source.officialRemote},
);   // publisher 默认 official

// 用户覆盖层：private 类，当前仅 row
const themeOverridePolicy = StoragePolicy.private(
  carriers: {Carrier.row},
);

// 用户主题选择：private 类
const themeSelectionPolicy = StoragePolicy.private(
  carriers: {Carrier.row},
);
```

装配期注册（总纲 §2.4:416「声明之后必须注册，否则推送侧 fail closed」）：

```dart
StoragePolicyRegistry.register('theme_package', officialThemePolicy);
StoragePolicyRegistry.register('theme_override', themeOverridePolicy);
StoragePolicyRegistry.register('theme_selection', themeSelectionPolicy);
```

⚠️ **这将是 `StoragePolicyRegistry` 的首个生产调用点**（§1.6 已核实当前零调用）。注册期的两条不变式（总纲 §2.3.2 #4 resource 必须 official、#5 sources 非空性）**第一次被真实驱动**，可能炸出 S1a 未预见的问题。ACT 需为此准备验证。

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

**采纳：叶子字段**（如 `light.components.four_zhu_card.shadow.color`）。

理由：粒度最细，用户只改颜色时，主题包对 `blur_radius` 的定义仍然生效。

⚠️ **已知摩擦（必须在实现期解决）**：`token_loader.dart` 的 `_parseShadow`（:289）是**整组解析**的 —— `color` 为 null 直接返回 null（:292），`_parseBorder`（:303）同理。意味着 shadow / border 这类属性组在解析层是"要么全有要么全无"。

**处置**：合并层在输出前**补全属性组** —— 若某组内有任一叶子被覆盖，则该组的其余叶子从下层补齐后整组输出。这样叶子粒度的存储 + 整组形态的输出，两边都满足。

> 📌 此项人类未明确拍板，按倾向采纳并标注。**转 ACT 前建议复核。**

### 6.3 light / dark 的处理

**采纳：token key 内含 brightness 前缀，两份完全独立。**

`light.components.xxx` 与 `dark.components.xxx` 是两条独立记录。用户改 light 不影响 dark。

理由：简单、无歧义。代价是用户要分别调两次 —— 这属于编辑器 UI 的便利问题（可提供"同步到暗色"按钮），不是存储层该解决的。

> 📌 人类未明确拍板，按倾向采纳并标注。

### 6.4 悬空覆盖（orphan）

用户覆盖了 `four_zhu_card.shadow.color`，主题包升级后该 key 不存在了（重构/改名）。

**采纳：保留但标记 orphan，不参与合并，经 `ThemeResolution.orphanedOverrideKeys` 暴露给 UI。**

被否决：静默丢弃 —— **静默丢弃用户的创作是最坏选择**，与 S5c 的 A11 诊断链精神一致（任何值都要能回答来龙去脉）。

> 📌 人类未明确拍板，按倾向采纳并标注。

### 6.5 覆盖数量上限

不设硬上限；设**软上限 + 诊断告警**。理由：无上限时失控的编辑器可写入数万条，合并时逐 key 查找会拖慢启动。

**具体阈值不在本设计决定** —— 参照总纲 §10:1581 对缓存容量上限的处理（"S1a 定接口，S2 定阈值"）。本设计只要求端口能暴露当前覆盖条数。

---

## 7. 启动路径与性能

**人类要求：首屏时间对标微信，越快越好。**

### 7.1 合并成本的量级（有实测支撑）

§1.1 实测：真实主题 **16 个 components + 少量 variants**，不是 1600 个。

三层合并 = 遍历约 16 × 2（light/dark）个组件 + variants ≈ **几十次 Map 查找**，**微秒级**。

**结论：合并本身不是性能瓶颈，一次都不会是。** 卡顿不会来自这里。

### 7.2 真实风险一：`updateShouldNotify` 的深比较

§1.5 核实：`XuanThemeScope.updateShouldNotify`（`xuan_theme_scope.dart:25`）用 `themeData != oldWidget.themeData`，`XuanThemeData` 是 Equatable，一次 `!=` 要比较 16 个组件 × 每个约 15 字段 + variants 嵌套 —— 数百次字段比较。

单次仍是微秒级，**但它在每次 InheritedWidget 重建时都跑**。

**防法（写入契约）**：
1. `resolve()` 的结果**缓存**：输入（主题 id + 覆盖层版本 + brightness）不变则返回**同一个实例** → `identical` 短路，深比较根本不执行；
2. 合并产出的 Map **key 顺序必须稳定**（有序 Map 或排序输出），否则 Equatable 的 Map 比较可能产生意外不等；
3. 验收判据：连续两次相同输入的 `resolve()` 结果必须 `identical`。

### 7.3 真实风险二：启动路径上的耗时操作（这才是"卡很久"的来��）

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

| # | 判据 | 验证方式 |
|---|---|---|
| **P1** | 三层合并（16 组件 × light/dark）耗时 < 1 ms | 基准测试，100 次取中位数 |
| **P2** | 相同输入连续两次 `resolve()` 返回 `identical` 实例 | 单测断言 `identical(a, b) == true` |
| **P3** | 启动路径**零网络请求** | **计数式 spy**：注入 fake HTTP client，断言 `callCount == 0` |
| **P4** | 启动路径**零解压、零 blob 读取** | **计数式 spy**：fake `LocalBlobStore`，断言读取次数 == 0 |
| **P5** | `component(id)` 保持 O(1)，无逐层回退 | 静态检查：合并产出的结构不持有任何"下一层"引用 |
| **P6** | 下载未完成时 `resolve()` 仍立刻返回旧主题 | 单测：注入永不完成的下载，断言 `resolve()` 在 X ms 内返回 |
| **P7** | 合并输出的 Map key 顺序稳定 | 单测：同一输入多次合并，逐 key 序列比对 |

---

## 8. 与外部契约的对齐

### 8.1 必须遵守的在途 OpenSpec change

`/xuan-migration/openspec/changes/theme-token-customization-contract/` 已过 4 轮评审并签署。其 `specs/theme-token-system/spec.md` 中与 S5a 相关的 SHALL 条款：

| 条款 | 对 S5a 的约束 |
|---|---|
| **No Direct YAML Parsing In Widgets Or Drawing Packages** | S5a 的输出必须是 typed / 已解析结构，**不得把 raw YAML 递给 Widget**；Widget 不得 import `xuan_config` |
| **Additive YAML Schema Evolution** | 主题包 token schema 演进必须 additive；未知字段静默忽略，渲染不得失败（已落入 §4.3） |
| **Token Field Fallback** | 每个字段有确定性降级；数值字段必须 checked 解析（`token_loader.dart:88` 的 `_parseCheckedDouble` 已实现） |
| **降级分粒度**（第二轮评审 finding #5） | 整体形状非法 → `DefaultXuanThemeData`；单字段非法 → 该字段默认。**一个坏的 `shadow.color` 不得让整个主题失效** |
| **Tier 3 隔离** | marketplace / cloud sync / uploaded assets **MUST NOT** 在 Tier 1 theme-token 工作下实现 —— 它们要独立 change。**S5a 正是那个独立 change** |

### 8.2 一条被澄清的归属问题

`xuan_config/lib/src/config_repository.dart:8` 写着「Phase 0a 不做 `$ref` 解析、**override 合并**、schema 校验」。

**该处的 "override 合并" 指 YAML 文件内部的合并**（与 `$ref` 并列），**不是**"用户覆盖主题包"。二者同名不同物。

佐证：在途 change 第三轮评审 finding E3 明确指出 —— `TokenLoader.fromConfigResult` 消费的是**已解析的 `ConfigResult`，永远看不到 raw YAML**，因此 raw 顶层键（如 `version`）的归属只能判给 `xuan_config`。同理，**用户覆盖层合并的是已解析的 token 结构，不是 raw YAML，故不归 `xuan_config`**，应在 storage / 装配层。

### 8.3 必须避让的并行工作

`xuan-qizhengsiyu` 的 Canvas / painter 提取正在并行进行，有明确文件所有权：`lib/painter/**` 归 Canvas agents，`lib/painter/chart_style/**` 是冻结的共享桥接区，`lib/presentation/widgets/rings/*_painter.dart` 亦归其所有。

**S5a 声明：不碰任何 chart 相关路径与 painter 文件。** 主题包中的 `chart` token 段仅做透传（合并后原样交出），不做语义解析。

---

## 9. 待决事项

| 事项 | 状态 | 归属 |
|---|---|---|
| **`ConfigBootstrap` 三个真值**（`endpoints` / `allowedHostSuffixes` / `l0PublicKeyBase64`）仍为占位符 | 🔴 **阻塞真实下载** | 人类填入 |
| 覆盖最小单位 = 叶子字段 + 属性组补全 | 按倾向采纳，未拍板 | 转 ACT 前复核 |
| light/dark key 内含 brightness、两份独立 | 按倾向采纳，未拍板 | 转 ACT 前复核 |
| 悬空覆盖保留 + 标记 orphan | 按倾向采纳，未拍板 | 转 ACT 前复核 |
| 覆盖数量软上限的具体阈值 | 本设计只定接口 | 后续（参照总纲 §10:1581 的处理方式） |
| **下载字体的运行时注册（`FontLoader`）与失败降级** | ⚠️ **未查证** | 资产引入时深挖 |
| 主题包的加密与签名（是否复用 S5c 的 ed25519） | 未讨论 | 转 ACT 前需定 |
| shell 侧 `version: 1` 空壳与 theme 侧 `version: 2` 预设的统一 | 未讨论 | 主题内容就绪时处理 |
| bundled 默认主题的物理位置（shell assets / theme 包 / storage assets 包） | 未讨论 | 转 ACT 前需定 |

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
