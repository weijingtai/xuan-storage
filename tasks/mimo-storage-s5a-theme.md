# 任务: storage-s5a-theme
负责: mimo ｜ 分支: agent/mimo/storage-s5a-theme ｜ 开工: 2026-08-03
状态: 蓝图（设计完成，待转译 ACT）

## 目标

在 `persistence_core` 交付主题资源分发的**契约层**（端口签名 + 值类型 + 策略声明，零实现），
使主题从「编译进包的死物」演进为「可下载安装、可用户覆盖、可跨设备同步」的资源，
且 `theme` 包零改动、启动路径零网络。

## 规格来源

- 详细设计：`docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md`（本任务的唯一真相源）
- 上游总纲：`docs/superpowers/specs/2026-07-31-storage-architecture-design.md`
- 外部契约：`/xuan-migration/openspec/changes/theme-token-customization-contract/`（4 轮评审已签署，其 spec 的 SHALL 条款约束本任务）

**§ 号在下方每个验收标准里给出，执行时按 § 号定位原文，不要凭记忆写。**

## 范围

### 做

- `ThemeResourceStore` 端口（读合并结果 / 写用户覆盖层，设计 §5.3）
- 中立 token 值类型 `ThemeTokenSet` / `ThemeTokenSection`（设计 §5.1）
- 溯源类型 `ThemeResolution` / `ThemeLayerInfo` / `ThemeSelectionOrigin` / `ThemeLayerKind`（设计 §5.2）
- 配套值类型 `InstalledTheme` / `AvailableTheme` / `OverrideEntry` / `OverrideOrigin`（设计 §5.4）
- 三条 `StoragePolicy` 声明 + 装配期注册（设计 §5.5）
- 契约测试：三层合并语义、读写不对称、性能判据 P1–P7（设计 §7.5）

### 不做

- ❌ 具体实现类（drift / blob / 下载器）—— 与 S1a 同，本任务零实现
- ❌ `theme` 包的任何改动（设计 §2.2，零 IO 边界必须保住）
- ❌ Marketplace（人类已确认当前不做，将来独立包）
- ❌ chart token 的语义解析（仅透传，避让并行的 QiZhengSiYu Canvas 提取，设计 §8.3）
- ❌ 主题内容本身（完整 style YAML 尚未产出，不属本任务，设计 §1.3）

## 前置依赖

| 依赖 | 状态 |
|---|---|
| S1a 契约层（`persistence_core`） | ✅ 已交付 |
| S5c 控制下发（`xuan_config`，`a324902`） | ✅ 已交付，接口签名已逐个核实 |
| S1b 同步引擎多 peer 化 | ⬜ **不依赖**（设计 §2.3：覆盖层同步到云端单 peer 即满足跨设备） |
| `ConfigBootstrap` 三个真值 | 🔴 **仍为占位符** —— 阻塞真实下载能力，不阻塞契约层交付 |

## 验收标准

- [ ] **A1** `cd core && dart analyze --fatal-infos` —— S5a 自有文件零 issue。
      ⚠️ 口径沿用 S1a 的三条制门禁（既有断点基线已冻结，见 S1a 纪要 A1）：
      ①S5a 自有文件 `--fatal-infos` 零 issue；②有 issue 的文件集合是冻结白名单子集；
      ③全包 issue 总数 ≤ 冻结基线
- [ ] **A2** `cd core && flutter test` 全绿，且下方 A9–A15 的测试文件存在且被执行
- [ ] **A3** `grep -rn "class .*Impl\|UnimplementedError" core/lib/model/theme_*` 无输出
      —— 零实现，出现任何具体实现类即不合格（EXPECT_EXIT:1 + EXPECT_STDOUT:""）
- [ ] **A4** `theme` 包零改动：`git diff --exit-code -- <theme 包路径>` 退出码 0
      —— 设计 §2.2 的依赖方向铁律
- [ ] **A5** `persistence_core` **不得**依赖 `theme` 包：
      `grep -n "theme" core/pubspec.yaml` 无主题包依赖行
- [ ] **A6** `ThemeResourceStore` 的读写不对称在签名上可见：
      `resolve()` 返回 `ThemeTokenSet`；`applyOverrides` / `removeOverrides` 的
      dartdoc 必须写明「只作用于用户覆盖层，与 resolve 不是逆运算」（设计 §2.5）
- [ ] **A7** 写入契约恰为「批量 patch + 显式删除」两个方法，**不存在**任何
      `save(整份)` / `set(单 key)` 形态的方法（设计 §2.6）
- [ ] **A8** 三条 `StoragePolicy` 声明存在且能通过 `StoragePolicyRegistry.register`
      的两条注册期不变式（resource 必须 official、sources 非空性，总纲 §2.3.2 #4/#5）
      —— ⚠️ 这是 Registry 的**首个生产调用点**，需实际驱动而非仅声明

### 契约测试（每条对应一个测试文件）

- [ ] **A9** 三层合并语义：override > 已装包 > bundled，逐 key 取第一命中（设计 §6.1）
- [ ] **A10** 换主题包后用户覆盖仍生效；卸载主题包不影响覆盖层（设计 §6.1 关键性质）
- [ ] **A11** `applyOverrides` 只影响 patch 中的 key，未出现的 key 不被清除（设计 §2.4 差量语义）
- [ ] **A12** `removeOverrides` 后该 key 回落到下层；对不存在的 key 幂等（设计 §2.6）
- [ ] **A13** 悬空覆盖不参与合并，且出现在 `ThemeResolution.orphanedOverrideKeys`（设计 §6.4）
- [ ] **A14** 版本兼容五条规则各一用例（设计 §4.3）：
      `package_format_version` 过高拒装 / `min_app_version` 过高拒装 /
      `token_schema_version` 过高降级解析 / 未知字段静默忽略 /
      **单字段非法只回退该字段，不整包失效**（在途 change 第二轮评审 finding #5）
- [ ] **A15** 溯源完整性：`ThemeResolution` 能回答「哪个主题包 / 什么版本 / id 来源 /
      各层贡献多少 key」（对齐 S5c 的 A11 诊断链）

### 性能判据（设计 §7.5，人类要求首屏对标微信）

- [ ] **P1** 三层合并（16 组件 × light/dark）< 1 ms —— 基准测试 100 次取中位数
- [ ] **P2** 相同输入连续两次 `resolve()` 返回 `identical` 实例
- [ ] **P3** 启动路径**零网络请求** —— **计数式 spy**，断言 `callCount == 0`
- [ ] **P4** 启动路径**零解压、零 blob 读取** —— 计数式 spy
- [ ] **P5** 合并产出结构不持有任何「下一层」引用（`component(id)` 保持 O(1)）
- [ ] **P6** 下载未完成时 `resolve()` 仍立刻返回旧主题
- [ ] **P7** 合并输出的 Map key 顺序稳定（多次合并逐 key 序列比对）

验收命令: `bash scripts/run_s5a_analyze_gate.sh && (cd core && flutter test)`

## 门禁写作纪律（S1a / S5c 返工换来，转 ACT 时必须遵守）

1. `grep -c` 无匹配时打印 "0" 且退出码 1 ⇒ `EXPECT_STDOUT` 与 `EXPECT_EXIT` **两个都要写**
2. 测试里**不要用 `fail()` 做断言** —— 调用方 catch-all 会吞掉 `TestFailure`。用**计数式 spy**
   （P3/P4 尤其适用；S5c 返工 F1 即因此）
3. 文本扫描类门禁**必须有写死的覆盖下限**，否则正则写错扫到 0 个文件会静默全绿
4. 任何以 `|| true` 结尾的验证命令都是假的
5. `expect(SomeClass, isNotNull)` 是同义反复 —— 必须真的构造实例并驱动行为
   （S5c 返工 F2 即因此）
6. macOS `/bin/bash` 是 3.2.57 —— 没有 `declare -A`、没有 `mapfile`/`readarray`
7. YAML 里 list item 不要以反引号开头
8. **每个 SELF_CHECK 必须「临时改坏 → 确认变红 → 改回 → git status 为空」**
   —— 一个绿的门禁如果证明不了自己能红，它就是假的

## 当前状态

- [x] 设计讨论完成 2026-08-03（含现状实查、四仓库边界、三层合并、性能预算）
- [x] 详细设计文档产出 → `docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md`
- [ ] 转译为 ACT（`wjt-act`）
- [ ] 跨模型闸门（`wjt-react`，≤2 轮）
- [ ] 下发执行
- [ ] 人类验收

## 决定记录

- 2026-08-03 **整包分发（方向 A）**，不做 token/资产分半。理由: 整包让版本兼容退化为单一维度；
  分半会产生 token 版本 × 资产版本的二维矩阵，且 Marketplace 上传要打包两半、卸载无法原子。
  人类拍板认可。
- 2026-08-03 **主题当前是纯 YAML**（实测 4 个 preset 共 64K，16 组件，零二进制），
  **但格式必须为资产预留位**。理由: 人类确认 TTF/PNG/SVG/Lottie 将来必定引入；
  不留位则加资产时要破坏性升级。总纲 §2.1.2:162「每个数 MB」在当前时点不成立。
- 2026-08-03 **`theme` 包零改动**。理由: 实查 `theme/lib` 零 IO（`SharedPreferences|dart:io|File(|drift|http` 全部零命中），
  且 `token_loader.dart:11` 自陈「theme 层禁止读取 YAML / 解析 $ref / 执行 schema 校验」。
  让它依赖 `persistence_*` 会破坏该边界并造成 UI 层依赖存储层。
- 2026-08-03 **Controller 是 shell 侧已存在的 `ShellThemeController`**，`theme` 是纯函数库。
  理由: `theme` 零 IO 拿不到任何数据。修正了讨论初期「theme 是 Controller」的说法。
- 2026-08-03 **用户覆盖层归 `private` + `user`，落 drift，走现有同步引擎**，不放 `preferences`。
  理由: 实查 `preferences` 包零同步能力（`OutboxStore|SyncPeer` 无命中），换设备用户创作丢失；
  且它是将来 UGC 主题的雏形，塞进 SharedPreferences 的 JSON string 无法直接取出。
- 2026-08-03 **只存差量，不存拷贝**。否决「生成 C 包」与「拷完整 YAML 只替换一处」两案。
  理由相同: A 包升级后拷贝不跟随、无法区分「用户显式设定」与「A 的默认值」（做不出恢复默认）、
  存储放大。C 包仅在用户显式「导出/上架」时生成。
- 2026-08-03 **写入 = 批量差量 patch + 显式 `removeOverrides`**。人类拍板认可。
  理由: 整体覆盖会摧毁差量模型并引入读改写竞态；单字段写会让一次编辑（拖阴影滑块改 4 字段）
  产生 4 次 UI 重建与中间态闪烁。批量 patch 是二者上界。
  `removeOverrides` 必须独立，因为 patch 传 `null` 有歧义（「设为空值」vs「删除覆盖」）。
- 2026-08-03 **读写不对称**（读=合并结果，写=只碰覆盖层）。人类拍板接受。
  理由: 对称的 read/write 会把主题包内容与用户覆盖混成一坨写回覆盖层，摧毁差量模型。
- 2026-08-03 覆盖用**增量 patch**，而 blob 引用计数用**全量对账**（`reconcileRefs`），二者相反。
  理由: 「记录引用哪些 blob」天然全量可知；「用户覆盖了哪些 token」可能数十条而一次编辑只碰一两条，
  全量声明会强迫调用方先读全量，引入读改写竞态。总纲 §3.2.2:586 的教训在此场景下结论相反。
- 2026-08-03 **覆盖取值 = 值快照 + 记来源**，不存对 B 包的引用。
  理由: 引用会导致 B 卸载即破坏用户主题。资产例外（记 `BlobHandle` 走引用计数，
  即总纲 §6.4:1080 选内容寻址而非「跟随 record」的兑现）。
- 2026-08-03 **启动路径纯本地、零网络、零解压**；下载与切换全在后台，装好后经
  `watchResolved` 通知。理由: 人类要求首屏对标微信。S5c 的 offline-first 已挡住配置侧
  （`runtime_config_repository.dart:84-87` 缓存命中不发网络），S5a 须把同一纪律扩展到主题包。
  总纲 §8.4:1302 同款教训。
- 2026-08-03 **不依赖 S1b**。理由: 覆盖层同步到云端单 peer 即满足「换设备能带走」，
  S1b 解决的是多 peer fan-out。避免执行者误以为要等 S1b。
- 2026-08-03 **`chart` token 仅透传不解析**。理由: `xuan-qizhengsiyu` 的 Canvas/painter
  提取正在并行，`lib/painter/**` 有明确文件所有权，解析 chart 会撞上它。
- 2026-08-03 **澄清 `config_repository.dart:8` 的「override 合并」不是本任务的用户覆盖**。
  该处与 `$ref` 并列，指 YAML 文件内部合并。佐证: 在途 change 第三轮评审 E3 指出
  `TokenLoader.fromConfigResult` 消费已解析的 `ConfigResult`、永远看不到 raw YAML，
  故 raw 顶层键归 `xuan_config`；同理用户覆盖合并的是已解析 token 结构，不归 `xuan_config`。
- 2026-08-03 **S5a 即在途 OpenSpec change 点名要的那个独立 change**。
  依据: 其 `spec.md` 的 Tier 3 场景明写 marketplace / sync / uploaded assets
  「MUST NOT be implemented under the Tier 1 theme-token work」，`design.md:108`
  说这些「require separate OpenSpec changes」。故 S5a 与之不重叠，但须遵守其 SHALL 条款。
- 2026-08-03 **本任务将是 `StoragePolicyRegistry` 的首个生产调用点**（实查当前仅两个 core 测试文件调用）。
  注册期两条不变式第一次被真实驱动，ACT 需为可能炸出的 S1a 未预见问题准备验证。

## 待人类确认（转 ACT 前）

- [ ] 覆盖最小单位 = **叶子字段 + 属性组补全**（设计 §6.2）
      ⚠️ 已知摩擦: `token_loader.dart:289` 的 `_parseShadow` 是整组解析（`color` 为 null 直接返回 null），
      `_parseBorder`（:303）同理。处置方案是合并层输出前补全属性组
- [ ] light/dark **key 内含 brightness、两份完全独立**（设计 §6.3）
- [ ] 悬空覆盖 **保留 + 标记 orphan + 诊断暴露**，不静默丢弃（设计 §6.4）
- [ ] 主题包是否复用 S5c 的 ed25519 签名体系（设计 §9 待决）
- [ ] bundled 默认主题的物理位置（shell assets / theme 包 / storage assets 包）

## 阻塞项

- 🔴 `ConfigBootstrap.endpoints` / `allowedHostSuffixes` / `l0PublicKeyBase64`
  仍为占位符（`'config.invalid'` / `'invalid'` / 含"占位"字样），**待人类填入真值**。
  不阻塞契约层交付，阻塞真实下载能力的联调。

## 踩坑墓地

- 2026-08-03: 曾判断「S5a 可缩水为 S5c 加一条配置源」（依据是实测主题为 5–9KB 纯 YAML）。
  被人类否决 —— 二进制资产（TTF/PNG/SVG/Lottie）将来必定引入，blob 链路必须建。
  结论: 按当前形态实现，但格式与端口必须为资产留位。
- 2026-08-03: 曾把 `theme` 包描述为「从 xuan-storage 取数据的 Controller」。
  经实查修正 —— `theme/lib` 零 IO，它拿不到任何数据；真正的 Controller 是
  `xuan-shell/lib/theme/shell_theme_controller.dart`。结论: `theme` 是纯函数库，别给它加存储依赖。
- 2026-08-03: 曾以为 `xuan-shell` 的主题链路已工作。实查发现
  `ShellThemeLoader.loadAndValidate` 返回 `Future<void>`（只校验不产出），
  `_themeSet` 始终是构造器里的 `DefaultXuanThemeData.themeSet`，
  且 `assets/themes/default.yaml` 只有 197 字节（三个空 Map）。
  结论: 当前渲染的是代码内置默认主题，YAML 链路空转。人类确认这是内容未就绪所致，不属 S5a。
- 2026-08-03: 总纲 §8.1:1235 示意图写 `ThemeRepository.get(...)`，但 xuan-storage 全仓库
  grep `ThemeRepository` **零命中**。结论: 该类不存在，主题现状整个在独立 `theme` 仓库
  （总纲 §0.1 的包名对照表未列该仓库）+ `xuan_config`。

## 冷冻快照
<搁置时由 /hibernate 填写>
