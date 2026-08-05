# 任务: storage-s5a-theme
负责: mimo ｜ 分支: agent/mimo/storage-s5a-theme ｜ 开工: 2026-08-03
状态: 蓝图 v4（过两轮 Codex 评审 + 2026-08-04 人类四条裁定并入 XRAP，范围大幅收窄）

## 目标

在 `persistence_core` 交付**主题在 XRAP 中的落地器（`InMemoryThemeMaterializer implements
DatasetMaterializer`）+ 用户覆盖层**的契约与 reference 实现，且 `theme` 包零改动、启动路径零网络。

⚠️ **不存在 `ThemeMaterializer` 这个类型**。v4 初稿曾定义空子接口
`abstract interface class ThemeMaterializer implements DatasetMaterializer {}`，
**v5 已删除**（无唯一消费者：`DatasetDescriptor.materializer` 的字段类型是
`DatasetMaterializer Function()`，既不认识也不需要该子接口）。S5a 直接实现
`DatasetMaterializer`。本纪要下文中所有裸 `ThemeMaterializer` 字样均为**历史记录**，
且已就地标注「已被 v5 supersede」—— 转 ACT 时**不得**据此创建任何名为
`ThemeMaterializer` 的类型（设计 §4.2）。

⚠️ **v4 范围裁定（2026-08-04 人类四条，有代码依据）**：
下载 / 校验 / 世代 / 指针翻转 / 回滚 / GC / 幂等 **全部归 XRAP**，S5a 不再自建。
**S5a = XRAP 的一个 Materializer + 一层 XRAP 拒收的用户覆盖。**
详见设计 §0.0。

## 规格来源

- 详细设计：`docs/superpowers/specs/2026-08-03-s5a-theme-resource-distribution-design.md`（v4，本任务唯一真相源）
- 上游总纲：`docs/superpowers/specs/2026-07-31-storage-architecture-design.md`
- 外部契约：`/xuan-migration/openspec/changes/theme-token-customization-contract/`（4 轮评审已签署，其 spec 的 SHALL 条款约束本任务，逐条映射见设计 §8.1）

**§ 号在下方每个验收标准里给出，执行时按 § 号定位原文，不要凭记忆写。**

## 交付形态：契约 + reference 实现（方案 B）

人类 2026-08-03 拍板。**不是纯契约** —— 理由见设计 §0.1：

- 三层合并 / 差量写入 / 缓存 identical / 启动零网络是 S5a 的核心价值，抽象接口产生不了行为，无法验证；
- 反面教训在本仓库：S1a 纯契约交付后 `StoragePolicyRegistry` 至今零生产调用点，无人知其好用与否；
- S5c 走「契约 + 一个真实现」，交付质量明显更高。

**reference 实现的边界**：纯内存、零 IO、零网络、不依赖 drift。它是行为规格的可执行形式与后续 drift 生产实现的对照基准，**不是生产实现**。

## 范围

### 做

- 契约层 **8** 个文件（设计 §11.1）—— 含 XRAP `DatasetDescriptor` 声明（`theme_dataset.dart`）
- reference 实现 **4** 个文件（设计 §11.2）：合并算法 + 内存 store + 内存 materializer（含落地物共享
  持有者 `InMemoryThemeTokenStore`）+ **装配入口 `theme_assembly.dart`**
  （`XrapThemeLocalReader` + `assembleThemeStore`，P4 的唯一注入入口，设计 §4.5）
- 测试 **8** 个文件（设计 §11.3）
- 门禁脚本 **2** 个：`scripts/run_s5a_analyze_gate.sh`（A1）+ `scripts/run_s5a_residue_gate.sh`
  （设计 §11.6）。**两个仓里都还不存在，均由本 ACT 创建**，验收命令直接调用它们
- 合计 **22** 个交付文件（设计 §11.0 总表）
- 合并算法完整规格已在设计 §6.6 写死，**执行者按步骤实现，无需推断**

### 不做（v4 删除的部分）

- ❌ **下载 / 校验 / 世代管理 / 活跃指针翻转 / 回滚 / GC / 幂等** —— 全归 XRAP `DatasetInstaller`
  （`dataset_installer.dart:188-192`「唯一实现，数据集无关」，再写一个主题专用安装器直接违反它）
- ❌ **主题包 zip ���式 / manifest.yaml 定义 / 版本兼容规则 / 签名验证** —— 归 XRAP `DatasetManifest`
- ❌ 任何安装类方法与安装态值类型（S5a 端口只有：读合并结果 / 写覆盖层 / 主题选择）
- ❌ 生产实现（drift 表 / 真实 materializer）—— 后续子任务
- ❌ `theme` 包的任何改动（设计 §2.2，零 IO 边界必须保住）
- ❌ `xuan-shell` 的接线（S5a 交付 `ThemeModuleRegistry.register()` 入口，shell 侧接线属下游）
- ❌ 主题构建脚本（YAML → 预构建载荷）—— 移交新建构建任务，照 T1 的 `build_geo_sql.py`
- ❌ Marketplace（当前不做，将来独立包）
- ❌ chart token 的语义解析（仅透传，避让 QiZhengSiYu Canvas 提取）

## 前置依赖

| 依赖 | 状态 |
|---|---|
| S1a 契约层 | ✅ 已交付并已合入 `main` |
| **XRAP 资源资产协议**（S5b） | ✅ **已合入 `main`**，七个契约文件在 `core/lib/model/dataset/`；T1 已有接入样板（`6cd7a66`） |
| S5c 控制下发（`xuan_config` `a324902`） | ✅ 已交付，接口签名已逐个核实 |
| S1b 同步引擎多 peer 化 | ⬜ **契约层与 reference 实现不依赖**；「可跨设备同步」的能力落地依赖后续 drift+outbox 集成（单 peer 即可，仍不需 S1b） |
| `ConfigBootstrap` 三个真值 | ⬜ **不是本任务的阻塞项**（v4 裁定 4）：`dataset_source.dart:61` 未配置返回 null，只用内置世代；T1 实证全程 generation 0 |

### 🔴 基线前置条件（开工第一步必须验证）

**S1a 契约在 `main`（`16987fe`）上，不在 `origin/main`（`2824f37`）上。**
本任务分支必须从**本地 `main`** 起，或先 rebase 到 `main`。

开工第一条命令：

```bash
ls core/lib/model/storage_policy.dart core/lib/model/storage_policy_registry.dart \
   core/lib/model/storage_classification.dart core/lib/model/cancellation_token.dart
```

四个文件缺任何一个 ⇒ **立即停止**，基线错误（本次撰写即栽在这里，见踩坑墓地）。

## 验收标准

> 每条给出可机械判定的命令或断言。`grep -c` 类命令**同时**声明 `EXPECT_STDOUT` 与 `EXPECT_EXIT`。
> 文本扫描类**必须有覆盖下限**，防止正则写错扫到 0 个文件时静默全绿。

### 结构与边界

- [ ] **A1** `bash scripts/run_s5a_analyze_gate.sh` 退出码 0。三条制（沿用 S1a 口径，见 S1a 纪要 A1）：
      ①S5a 自有文件 `--fatal-infos` 零 issue；②有 issue 的文件集合是冻结白名单子集；
      ③全包 issue 总数 ≤ 冻结基线。
      **脚本须在开工时重新测定基线并写死**（S1a 的基线 58 是它自己那次的，不可直接沿用）
- [ ] **A2** `cd core && flutter test` 全绿，且设计 §11.3 的 **8 个测试文件全部存在且被执行**。
      判定：`flutter test --reporter json` 输出中这 8 个文件各自的测试数 `> 0`（不是只看文件存在）
- [ ] **A3** 契约层零实现：
      `grep -rnE "class .*Impl|UnimplementedError" core/lib/model/theme_*.dart` → EXPECT_EXIT:1 + EXPECT_STDOUT:""
      **覆盖下限**：`ls core/lib/model/theme_*.dart | wc -l` 必须 `== 8`（防 glob 扫到 0 个文件假绿）
      ⚠️ 扫描范围**仅限 `core/lib/model/theme_*`**，`core/lib/reference/` 是方案 B 的实现层，不在此列
- [ ] **A4** `theme` 包零改动：
      `cd /Users/jingtaiwei/Git/Public/xuan-migration/theme && git status --porcelain` → EXPECT_STDOUT:""
      （`theme` 是**独立仓库**，不在 xuan-storage 内，故用其自身 git status 判定）
- [ ] **A5a** `persistence_core` 不依赖 `theme` 包：
      `grep -nE "^\s+theme:" core/pubspec.yaml` → EXPECT_EXIT:1
      （精确匹配依赖行首，不用宽泛的 `grep "theme"`）
- [ ] **A5b** `persistence_core` 不依赖 `xuan_config`（SHALL :69–74）：
      `grep -nE "^\s+xuan_config:" core/pubspec.yaml` → EXPECT_EXIT:1
      且 `grep -rn "package:xuan_config" core/lib/` → EXPECT_EXIT:1
- [ ] **A6** 读写不对称在签名与文档上可见：
      `core/lib/model/theme_resource_store.dart` 中 `applyOverrides` 与 `removeOverrides`
      的 dartdoc 各含「只作用于用户覆盖层」字样；`resolve` 的 dartdoc 含「三层合并」字样。
      逐条 `grep -c` == 1 + EXPECT_EXIT:0
- [ ] **A7** 写入契约恰为两个方法：
      在 `theme_resource_store.dart` 内，匹配 `Future<void> (save|set)[A-Z]` → EXPECT_EXIT:1
      （限定文件范围与方法模式，不做全仓扫描）
- [ ] **A8** 策略注册**真实驱动**（不是仅声明）：
      测试中调用
      `ThemeModuleRegistry.register(themeMaterializer: () => InMemoryThemeMaterializer(tokenStore))`
      （签名见设计 §5.6.3；工厂从外部传入是为了让契约层不依赖 reference 层），
      断言 `StoragePolicyRegistry.all` 含
      `theme_package` / `theme_override` / `theme_selection` 三个 key 且策略对象相等；
      **且 `DatasetRegistry.lookup(themeDatasetId) != null`**；
      **再调一次 `register(...)` 不抛异常**（幂等，设计 §5.6.3）；
      **`resetForTesting()` 后重复注册同名 entityType 抛 `StateError`**（证明幂等标志不是靠吞异常）

### 合并语义（reference 实现驱动）

- [ ] **A9** 三层优先级：override > package > bundled，逐 key 取第一命中（设计 §6.6 第 2 步）。
      **含 null 值命中用例**：某层显式给 `null`，须命中该层而非穿透到下层（用 `containsKey` 而非 `??`）
- [ ] **A10** 换主题包后用户覆盖仍生效；卸载主题包不影响覆盖层（设计 §6.1）
- [ ] **A11** `applyOverrides` 只影响 patch 中的 key，未出现的 key 不被清除（设计 §2.4）；
      且**原子提交**：patch 中一条非法时整批不生效
- [ ] **A12** `removeOverrides` 后该 key 回落到下层；对不存在的 key 幂等不抛
- [ ] **A13** orphan 判定（设计 §6.4）：覆盖的 key 在 package 与 bundled 均不存在时，
      ①不出现在合并结果中 ②出现在 `orphanedOverrideKeys` ③**数据未被删除**（`listOverrides()` 仍含它）
- [ ] **A14c** 字段缺失 → 保持 legacy fallback，原子组补全生效（设计 §6.6 第 4 步）✅ **留在 S5a**
      ⚠️ **v4 已移交**：A14a（未知字段）/ A14d（数值非法）/ A14e（单字段回退）→ **构建脚本**
      （设计 §4.3：YAML 解析在构建期，设备只消费预构建载荷）；A14b（版本拒装）→ **XRAP**
      （`DatasetDescriptor.supports()` 已实现）。移交项登记在设计 §11.5
- [ ] **A19** 合并层**不吞值**（S5a 对 A14d/e 的"不破坏"责任，设计 §5.5.5）：
      注入值为 `"8px"` 的非法 radius，断言它**原样出现在** `resolve()` 结果中
      （证明合并层没有偷偷过滤或修正；非法值的处置由下游解析层负责）
- [ ] **A20** `InMemoryThemeMaterializer`（`implements DatasetMaterializer`）遵守 XRAP 契约（设计 §4.1 八条事实）：
      ①只写入参给定的 generation，不触碰其它世代（注入两代数据，断言互不干扰）
      ②`dropGeneration` 幂等（删不存在的世代不抛）
      ③返回真实 `rowCount`（与 fixture 的 token 条数一致，防填假数）
      ④**不改动活跃指针**（断言 materializer 无任何指针操作 API 调用）
      ⑤`materialize` 不重复校验 sha256（XRAP 已校验，重复即违反 N1）
      ⑥**同一份载荷用两个不同 generation 各落地一次，两次都成功**（R4-P0 的回归守卫：
      载荷行没有 `g` 字段，世代号只能取入参；若实现从载荷读世代或做相等校验，第二次落地必红）
- [ ] **A21** **装配链闭合**（设计 §4.5，R4-P1-3 的回归守卫）——「安装 → 落地 → 启动读取」
      三段必须看到**同一份**落地物：
      ①`tokenStore = InMemoryThemeTokenStore()`；
      `ThemeModuleRegistry.register(themeMaterializer: () => InMemoryThemeMaterializer(tokenStore))`；
      ②`await installer.ensureInstalled(themeDatasetId)`（用 `CountingDatasetInstaller`，
      它会真的调 `descriptor.materializer()` 工厂并驱动 `materialize`）；
      ③断言 `tokenStore.generations.contains(0)` —— **工厂新建的实例把落地物写进了共享 store**；
      ④断言 `await XrapThemeLocalReader(...).readBundledTokens()` 的 key 数 == fixture 的 token 条数
      —— 读路径确实拿到了安装期落地的那一份；
      ⑤**连调两次工厂**（`descriptor.materializer()` 调两次，各落地一代），断言两代都在
      `tokenStore.generations` 里 —— 证明共享的是 store 而不是碰巧同一个实例。
      **怎么让它变红**：把 `InMemoryThemeMaterializer` 改回持有实例私有 Map（不写共享 store），
      ③④⑤三条同时红。这正是 v5 的断链形态
- [ ] **A15** 溯源完整性：`ThemeResolution` 能回答「哪个主题包 / 什么版本 / id 来源 /
      各层贡献多少 key」。**`contributedKeyCount` 之和须等于结果 key 总数**（防止填假数）
- [ ] **A16** 结果不可变：对 `resolve()` 结果的 `components` 及嵌套 Map 执行 `[]=` / `remove()`
      均抛 `UnsupportedError`（设计 §6.6 不可变性）
- [ ] **A17** Canvas 避让（SHALL :116/:123）：
      `git -C /Users/jingtaiwei/Git/Public/xuan-migration/xuan-qizhengsiyu status --porcelain` → EXPECT_STDOUT:""
      且 S5a 全部产出路径均在 `xuan-storage/core/` 内
- [ ] **A18** 每个新增公开 API 有中文 dartdoc（仓库惯例）。
      **覆盖下限**：dartdoc 门禁计数须 `>= 60`（开工后实测填入，留余量），防正则写错扫到 0 个假绿

### 性能（设计 §7.5，人类要求首屏对标微信）

> 共同 fixture `ThemeBenchFixture`（`core/test/support/theme_bench_fixture.dart`）：
> 16 组件 × 18 叶子 + 6 variants，light/dark 各一份，override 50 条（含 5 条 orphan）。
> **fixture 叶子数须断言 `>= 700`** —— 防止用空 Map 假通过。

- [ ] **P1** 合并 fixture **< 5 ms**：warm-up 20 次后测 100 次取中位数。
      标 `@Tags(['benchmark'])`，**不进 CI 阻塞门禁**（Flutter debug VM 抖动）；
      CI 只跑一次冒烟确认 < 100 ms
- [ ] **P2** 相同输入两次 `resolve()` 返回 `identical` 实例；
      **改一次 override 后 `identical` 为 false**（证明缓存键真参与判定，非恒返回同一实例）
- [ ] **P3** 启动路径零网络 —— **结构性保证**：`InMemoryThemeResourceStore` 构造器
      只接收 `{required String scopeUid, required ThemeLocalReader localReader}`，
      **没有网络端口可传**（设计 §5.5.3）。三条断言，全文在设计 §5.5.4：
      **P3-a1** 构造器 tear-off 的**函数类型**断言（`isA<... Function({required String scopeUid,
      required ThemeLocalReader localReader})>()`）—— 新增/删除/改类型任一 required 参数即红；
      **P3-a2** **import 集合**白名单（`IMPORTS ⊆ ALLOWED` + `IMPORTS ⊇ 必需两条`正向控制
      + 无 `export`/`part` 绕过）—— 新增网络依赖必须先 import，即红；
      **P3-b** 行为正向控制 `localReader.bundledReadCount > 0` 且 `overrideReadCount > 0`。
      ⛔ **v5 的「`ThemeLocalReader` 全文命中恰好 1 次」「参数区 `required` 恰好 2 次」已作废**
      （R4-P1-4：数拼写次数不是查依赖图，正常实现光字段+构造器就 2 次）
- [ ] **P4** `resolve()` 期间不触发 XRAP 安装（设计 §5.5.4 完整断言序列）：
      经 `assembleThemeStore` 注入 `CountingDatasetInstaller`，**分装配期/resolve 期两段计数**
      （中间 `resetCounts()`）。装配期断言 `ensureInstalledCallCount == 1`、
      `checkForUpdateCallCount == 0`、`tokenStore.generations.contains(0)`；
      resolve 期断言 `ensureInstalled` / `checkForUpdate` / `rollbackTo` / `collectGarbage`
      四个计数全 `== 0`，**正向控制** `activeCallCount > 0` 且 `calledDatasetIds` 含 `themeDatasetId`。
      ⚠️ **`DatasetInstaller` 没有名为 `install` 的方法** —— 抽象方法恰好六个，
      探针必须六个全实现（v5 写的 `installCallCount` 是凭空发明的方法名）。
      **变红手法三条见设计 §5.5.4**
- [ ] **P5** 无"下一层"回指：`resolve()` 返回后销毁 store 实例，结果仍可正常读取
- [ ] **P6** 活跃世代读取挂起时 `resolve()` **50 ms 内**返回 bundled 兜底（设计 §5.5.4 六步）：
      注入 `SlowLocalReader`（`readActiveThemeTokens` 永不完成），`Stopwatch` 计时，
      断言 < 50 ms + 结果来自 bundled + **不抛异常**（优雅降级，不是失败）
- [ ] **P7** key 顺序稳定：同 fixture 合并 10 次，逐层 `keys.toList()` 逐元素相等，
      且等于其字典序排序结果

验收命令: `bash scripts/run_s5a_analyze_gate.sh && bash scripts/run_s5a_residue_gate.sh && (cd core && flutter test --exclude-tags benchmark)`

> **残留门禁 `scripts/run_s5a_residue_gate.sh`（脚本全文在设计 §11.6，照抄即可运行）**：
> 扫已裁定移除的 8 个标识符（InstalledTheme / AvailableTheme / ThemeRemoteFetcher /
> ThemePackageStore / ThemeSignatureVerifier / ThemeSignatureVerdict / refreshCatalog /
> listInstalled），出现即 `exit 1`。
> **它是精确交付文件**（设计 §11.0 总表），仓里现在不存在，由本 ACT 创建并 `chmod +x`。
> 扫描范围用**显式文件数组**（20 个交付文件逐条写死）+ 逐个 `[ -f ]` 存在性断言，
> **不用 `ls` glob**；缺文件 `exit 2`，数组被改空 `exit 2`，grep 自身出错 `exit 3`。
> **转 ACT 时须做设计 §11.6 表中的三条变红自检**（残留 / 缺文件 / 范围被改空，各红一次）。
> 起因: R3 的 P0 正是我正则替换后未验证导致 InstalledTheme 类定义残留 —— 此门禁防它重演。

## 门禁写作纪律（S1a / S5c 返工换来，转 ACT 时必须遵守）

1. `grep -c` 无匹配时打印 "0" 且退出码 1 ⇒ `EXPECT_STDOUT` 与 `EXPECT_EXIT` **两个都要写**
2. 测试里**不要用 `fail()` 做断言** —— 调用方 catch-all 会吞掉 `TestFailure`。用**计数式 spy**
   （P3/P4 尤其适用；S5c 返工 F1 即因此）
3. 文本扫描类门禁**必须有写死的覆盖下限**（A3 的契约层文件数 == 8、A18 的 dartdoc >= 60、
   fixture 叶子数 >= 700），否则正则写错扫到 0 个会静默全绿。
   ⚠️ 覆盖下限**不许用 `ls` glob 数文件** —— glob 空匹配与目录递归口径有歧义。
   用**显式文件数组 + 逐个 `[ -f ]` 存在性断言**（`run_s5a_residue_gate.sh` 的做法，设计 §11.6）
4. 任何以 `|| true` 结尾的验证命令都是假的
5. `expect(SomeClass, isNotNull)` 是同义反复 —— 必须真的构造实例并驱动行为
   （S5c 返工 F2 即因此；A8 已按此写成"真实调用 register 并断言进表"）
6. macOS `/bin/bash` 是 3.2.57 —— 没有 `declare -A`、没有 `mapfile`/`readarray`
7. YAML 里 list item 不要以反引号开头
8. **每个 SELF_CHECK 必须「临时改坏 → 确认变红 → 改回 → git status 为空」**
   —— 一个绿的门禁如果证明不了自己能红，它就是假的
9. **正向控制**：断言"没做某事"（P3/P4 的零网络）时，必须同时断言"确实做了该做的事"，
   否则一个什么都不做的实现也能通过

## Stop conditions（触发即停，报人类）

> **与设计 §11.4 逐条同构，五条，编号一致。两边任一处改动必须同步另一边。**

1. **S1a 契约或 XRAP 契约不在当前分支基线** —— 开工第一步验证四个 S1a 文件
   （见上方基线前置条件）与 `core/lib/model/dataset/dataset_materializer.dart` 均存在
2. **本 ACT 的任何文件读取 `theme` 仓库** —— 跨仓库读取在 S5a ACT 范围外。
   构建脚本确实要读 `theme/config/presets/*.yaml`，但它属独立任务 `BUILD-THEME`（设计 §11.5），
   不在本 ACT；本 ACT 交付文件均不得出现 `theme/` 路径引用，测试用 bundled token 由 fixture 内联常量提供
3. **`theme` 包出现任何改动** —— A4 触发即停
4. **发现需要在 XRAP 的 `DatasetMaterializer` 之外新增扩展点** —— 说明协议有缺口，
   须走协议变更流程，不得在 S5a 侧绕过（设计 §4.2）
5. **需要触碰 `xuan-qizhengsiyu/lib/painter/**`** —— Canvas 提取所有权，须先握手

> ⚠️ **`ConfigBootstrap` 三占位符不是 stop condition**（v4 裁定 4，设计 §1.6 / §9.2）。
> v5 之前曾把「需要真实网络下载」写成第 4 条，与裁定 4 直接冲突，**v6 已删除**。
> S5a 的 reference 实现零网络、零 IO，冷启动只用内置世代（generation 0），
> 根本走不到需要 `ConfigBootstrap` 真值的路径。

## 当前状态

- [x] 设计讨论完成 2026-08-03
- [x] 详细设计 v1 产出
- [x] **Codex gStack `plan-eng-review` R1 → REVISE-FIRST**（4 条 P0 + 8 条 P1 + 2 条 P2）
- [x] **按 R1 全面修订 → v2**（2026-08-03）
- [x] **Codex gStack `plan-eng-review` R2 → PASS-WITH-REVISIONS**（4 条 P1）
      报告：`docs/reviews/2026-08-03-s5a-theme-plan-eng-review-r2.md`
- [x] **按 R2 四条 P1 修订 → v3**（2026-08-03）
- [x] **rebase 到 main** —— 基线问题解除，S1a 与 XRAP 契约均已就位
- [x] **v4：按人类四条裁定并入 XRAP**（2026-08-04），范围大幅收窄
- [x] **Codex gStack `plan-eng-review` R3 → REVISE-FIRST**（6 条 P1/P0 + 3 条 P2）
      报告：`docs/reviews/2026-08-04-s5a-theme-plan-eng-review-r3.md`
- [x] **按 R3 全面修订 → v5**（2026-08-04，明细见决定记录）
- [ ] Codex 复审（R4）
- [ ] 转译为 ACT（`wjt-act`）
- [ ] 跨模型闸门（`wjt-react`，≤2 轮）
- [ ] 下发执行
- [ ] 人类验收

## 决定记录

### v6 修订（2026-08-05，按 Codex gStack R4 的 1 条 P0 + 7 条 P1 + 2 条 P2）

> R4 报告：`docs/reviews/2026-08-04-s5a-theme-plan-eng-review-r4.md`。
> P0（载荷行 schema 删 `g` 字段）已在 `ebad8af` 闭合，本节记录余下 9 条。

- 2026-08-05 【R4-P1-2】**`CountingDatasetInstaller` 补成可编译的完整定义**。
  发现 v5 的探针表写「每次 `install(...)` 被进入」是**凭空发明的方法名** ——
  `dataset_installer.dart` 的抽象方法恰好六个：`ensureInstalled` / `checkForUpdate` /
  `active` / `generations` / `rollbackTo` / `collectGarbage`，`implements` 必须六个全实现。
  改文件: 设计 §5.5.4 —— 探针表那行改为「六个 `<方法名>CallCount` + `calledDatasetIds`」，
  并补一整段完整定义：构造器 `CountingDatasetInstaller({required Stream<List<int>> Function() bundledPayload})`、
  六个计数字段初值 0、`calledDatasetIds` 类型 `List<String>` 初值 `<String>[]`、
  `resetCounts()`、六个方法逐个写死 fake 返回表达式。
  其中 `ensureInstalled` **会真的调 `descriptor.materializer()` 工厂并驱动 `materialize`**
  —— 这样 P4/A21 测的是 §4.5 那条真链路，不是测试自己伪造的落地物。
  ①设计 §11.3 —— `theme_probes.dart` 那行补上 `CountingDatasetInstaller`；
  ②设计 §11.3 —— `theme_bench_fixture.dart` 补 `bundledJsonlBytes()`（探针的载荷来源）；
  ③纪要 P4 —— 同步断言序列，并写明「没有 `install` 方法」这条坑。
- 2026-08-05 【R4-P1-4】**P3-a oracle 重写：从"数拼写次数"改为结构性断言**。
  v5 的「`ThemeLocalReader` 全文命中恰好 1 次」「参数区 `required` 恰好 2 次」被作废 ——
  正常实现光字段声明 + 构造器参数就 2 次，会逼实现者用类型推断规避文本来过门禁。
  新 oracle 两条，都不需要新依赖（`analyzer` 不在 `core/pubspec.yaml` 里，不为一条门禁引入）：
  **P3-a1** 构造器 tear-off 的**函数类型**断言 —— `final Object ctor = InMemoryThemeResourceStore.new;`
  再 `isA<InMemoryThemeResourceStore Function({required String scopeUid,
  required ThemeLocalReader localReader})>()`。Dart 函数子类型规则保证：新增/删除任一
  required 具名参数、或改任一参数类型/名字，都不再是子类型 → 红，且**红在运行时断言不在编译期**
  （tear-off 先赋给 `Object`）。
  **P3-a2** **import 集合**白名单 —— 逐行抽 `^import\s+'(?<uri>[^']+)'.*;$` 得 `IMPORTS`，
  断言 `IMPORTS ⊆ ALLOWED`（6 条写死）、`IMPORTS ⊇ 必需两条`（正向控制，防空集静默全绿）、
  `^(export|part|part of)\s` 命中 == 0（防绕过）。
  **「新增网络依赖 → 变红」的自检手法已写死**：临时加 `import 'dart:io';` → 断言 1 红；
  临时把 import 正则改成永不匹配 → 断言 2 红。
  **已知缺口明写不藏**：新增**可选**具名参数时 a1 抓不到（仍是子类型），由 a2 兜住；
  若该可选参数的类型来自白名单内文件则两条都抓不到 —— 但白名单里全是 S5a 自己的契约文件，
  不可能是网络端口，对「零网络」这一命题无损。
  改文件: 设计 §5.5.4 P3 段整段重写；纪要 P3 同步。
- 2026-08-05 【R4-P1-7】**`run_s5a_residue_gate.sh` 列为精确交付文件**。
  R4 抓到验收命令调用一个既不在交付表、仓里也不存在的脚本。改文件:
  ①设计**新增 §11.0 交付物总表** —— 契约 8 / reference 4 / 测试 8 / 门禁脚本 2 = **22**，
  并显式点名 `run_s5a_analyze_gate.sh` 也不存在、也必须由本 ACT 创建；
  ②设计 §11.6 —— 脚本全文重写：`ls` glob 换成**三个显式文件数组**（20 个交付文件逐条写死）
  + 逐个 `[ -f ]` 存在性断言 + 数组长度下限；`grep` 的三种退出码（0/1/>=2）全部显式处理，
  **不用 `|| true`**；退出码语义写死（1 残留 / 2 清单或范围问题 / 3 grep 自身出错）；
  变红自检从一条扩到**三条表格**（残留 / 缺文件 / 范围被改空）；
  ③纪要「验收命令」下方的残留门禁说明段同步；④纪要「范围 · 做」补门禁脚本 2 个 / 合计 22。
- 2026-08-05 【R4-P1-3】**数据流闭合 —— 本轮唯一的真设计题**。
  问题: `DatasetDescriptor.materializer` 是**工厂**（`dataset_descriptor.dart:44`
  `final DatasetMaterializer Function() materializer;`），安装器每次落地新建一个
  materializer 实例；而 v5 把落地物放在该实例的私有 `_byGeneration` 里，
  启动路径的 `ThemeLocalReader` 永远读不到那个实例 —— 链断在安装与读取之间。
  **裁定: 方案 A + 方案 C 组合**。
  A（工厂闭包捕获外部共享 store）解决"落地物存哪"，
  C（世代号取自 `DatasetInstaller.active()`）解决"读哪一代"。
  **方案 B（materializer 改单例注入）已排除** —— 契约字段类型就是工厂，改它等于改 XRAP 契约。
  **单独用 C 也不行** —— `DatasetRegistry` / `DatasetInstaller` 只记录世代元数据
  （`InstalledDataset`：世代号/状态/清单/行数），**不持有落地物本身**，落地物形态是
  materializer 的自由（协议 §3.3）。
  **✅ 不需要改 `core/lib/model/dataset/` 下任何 XRAP 契约**，无「需人类裁定」项。
  改文件:
  ①设计 §4.3 —— materialize 示意代码重写（`Stream<List<int>>` 而非 `Uint8List`；
  `MaterializeOutcome` 默认构造器而非不存在的 `.success`；显式禁止对载荷 `g` 做校验）；
  ②设计 §4.4 —— 落地结构从「materializer 私有 `_byGeneration`」改为独立类
  `InMemoryThemeTokenStore`（`putGeneration` / `tokensOf` / `dropGeneration` / `generations`），
  `InMemoryThemeMaterializer(this._tokens)` 构造器收它；**删掉 v5 的
  `@visibleForTesting tokensOf`**（它只能读单个实例，正是断链本体）；
  ③设计**新增 §4.5「装配数据流」** —— 五步链表格（每步指明文件+函数）、
  `XrapThemeLocalReader` 与 `assembleThemeStore` 的精确签名、
  `readActiveThemeTokens` 的六步无分支歧义流程、以及方案 B/单独 C 的排除论证；
  ④设计 §5.6.2 —— `themeDatasetDescriptor({required DatasetMaterializer Function() materializer})`
  （工厂改入参，让契约层不依赖 reference 层，保住 A3 与分层方向）；
  ⑤设计 §5.6.3 —— `ThemeModuleRegistry.register({required DatasetMaterializer Function() themeMaterializer})`；
  ⑥纪要 A8 —— 调用形态同步；⑦纪要**新增 A21**（装配链闭合，五条断言 + 变红手法）。
- 2026-08-05 【R4-P1-1】**`theme_assembly.dart` 进交付表，reference 3 → 4**。
  改文件: ①设计 §11.2 —— 新增该行，含文件、`XrapThemeLocalReader` 与 `assembleThemeStore`
  的签名摘要、精确签名出处（§4.5）、验收编号（A21, P4），并加「共 4 个文件」与
  「不可省」说明；②设计 §11.1 —— `theme_dataset.dart` / `theme_module_registry.dart`
  两行的签名同步；③设计 §11.3 —— 加「共 8 个文件」计数与 A21 归属说明；
  ④纪要「范围 · 做」—— reference 3 → 4，并给出合计 21 个交付文件。
- 2026-08-05 【R4-P1-6】**`ThemeMaterializer` 残留清理**。裸 `ThemeMaterializer`
  （非 `InMemoryThemeMaterializer` 子串）全部标注或消除。改文件:
  ①纪要「目标」—— 改为 `InMemoryThemeMaterializer implements DatasetMaterializer`，
  并加一段「不存在 `ThemeMaterializer` 这个类型」的显式警告，防 ACT 转译器重建已删接口；
  ②纪要 v4 决定记录【裁定 3】—— 加 ⛔ 标注「已被 v5 supersede」；
  ③纪要 v4 决定记录【连带 4】—— 契约层「7 → 9」与 A3「== 8」的打架改为分层标注：
  9 已被 v5 supersede 为 8、reference 3 已被 v6 supersede 为 4，并写明当前唯一有效计数。
  > 📌 **给复审的说明**：`grep -c ThemeMaterializer` 的计数**不会归零** ——
  > `InMemoryThemeMaterializer` 含该子串，它是当前正确的类名。判据是
  > **裸 `ThemeMaterializer` 是否全部已删除或已标注 supersede**，
  > 用 `grep -nE '(^|[^y])ThemeMaterializer'` 复核（`y` 来自 `InMemory`）。
- 2026-08-05 【R4-P2-9】**清 UTF-8 replacement character**。设计稿 4 处 `U+FFFD`：
  §上游文档第 13–15 行（是第 10–12 行的**重复块**，整块删除）、§0.2 第 3 点「测试对端口编程」、
  §2.3 末「会让执行者以为」、§7.3 标题「卡很久的来源」。
  改文件: 设计稿（`grep -c` 现为 0）。
- 2026-08-05 【R4-P2-8】**A3 文件数 6 → 8**。纪要「门禁写作纪律」第 3 条写死的覆盖下限
  与验收 A3（`== 8`）打架。同时把该条的手法从 `ls` glob 改为**显式文件数组 +
  逐个 `[ -f ]` 存在性断言**（glob 空匹配与目录递归口径有歧义，R4-P1-7 同因）。
  改文件: 纪要「门禁写作纪律」第 3 条。
- 2026-08-05 【R4-P1-5】**ConfigBootstrap 自相矛盾清零**。全文只保留一个口径：
  **不是阻塞项**（裁定 4）。改文件:
  ①设计 §1.6 —— 删「这是 S5a 真实下载能力的前置阻塞项」，改为「不是 S5a 的阻塞项」+ 指向 §0.0 裁定 4 / §9.2；
  ②纪要「Stop conditions」—— 删原第 4 条「需要真实网络下载」，整段改为与设计 §11.4 **逐条同构的五条**
  （基线 / 读 theme 仓库 / theme 包改动 / Materializer 之外的扩展点 / painter），并加一条显式说明记录该条已删。
  设计 §9.2 与纪要「已知非阻塞背景」原本口径已正确，未动。

### v5 修订（2026-08-04，按 Codex gStack R3 的六条 P1/P0 + P2）

- 2026-08-04 【R3-P0】**残留清零**。R3 抓到 `InstalledTheme` 的完整类定义（设计 §5.4，40 行）
  根本没删 —— v4 我只改了引用它的表格，漏了本体。根因: 正则批量替换后**未独立验证**。
  处置: 删 `InstalledTheme` 类定义；`AvailableTheme` 重写为 `LocalTheme`（去安装态字段，
  加 `generation` 对齐 XRAP 世代）；历史叙述改中性措辞。**新增 §11.6 残留门禁脚本
  `run_s5a_residue_gate.sh`** 写进验收命令，扫 8 个禁用标识符 + 覆盖下限 8 文件 + 变红自检。
- 2026-08-04 【R3-P1】**扁平化与预构建矛盾**。§6.6 第 1 步改「输入校验（不做扁平化）」，
  扁平化规则保留但标注为构建脚本职责（两边必须对同一套 key 空间达成一致）。
- 2026-08-04 【R3-P1】**载荷格式含糊**。定死 **JSON Lines（UTF-8/LF）**，行 schema 四字段
  `{k,v,t,g}`；否决 *.sql；`rowCount` = jsonl 行数；reference 落地结构写死
  `Map<int, Map<String,dynamic>>`；补 `InMemoryThemeMaterializer` 完整签名。
- 2026-08-04 【R3-P1】**P3/P4 不可测**。P3 拆 P3-a（静态文本扫描，限定构造器参数区内数
  `required` + 子串长度下限防假绿）+ P3-b（行为正向控制）；**新增
  `core/lib/reference/theme_assembly.dart` 装配入口**让 P4 的 `CountingDatasetInstaller`
  有注入点；补探针定义。
- 2026-08-04 【R3-P1】**A14 归属未闭合 + 引用已删章节**。纪要验收只留 A14c + A19；
  a/d/e 在 §8.1 标承接方 **BUILD-THEME**（新建任务 ID）；重建 §8.1 映射删失效引用；
  §11.5 给 BUILD-THEME / THEME-DRIFT 唯一 ID。
- 2026-08-04 【R3-P1】**ConfigBootstrap 仍有 🔴**。设计 §9.2 与纪要「阻塞项」段全改
  「已知非阻塞背景」，删红标与 stop gate 语义。
- 2026-08-04 【R3-P1】**stop condition #2 与构建脚本矛盾**。澄清构建脚本不在本 ACT 文件范围
  （属 BUILD-THEME），本 ACT 交付文件均不得出现 `theme/` 路径，测试 bundled 用 fixture 内联。
- 2026-08-04 【R3-P2】**删冗余空接口**。删 `ThemeMaterializer` 空子接口（无唯一消费者），
  S5a 直接实现 `DatasetMaterializer`。**连带契约层 9 → 8 文件**，A3 下限 / A2 计数同步改。
- 2026-08-04 【R3 正向核实】**「首个生产调用点」需限定**。XRAP 合入后 `StoragePolicyRegistry`
  已有测试调用点，§1.6/§5.6.3 的表述应理解为「首个**生产**调用点（测试不算）」。

### v4 修订（2026-08-04，按人类四条裁定并入 XRAP）

- 2026-08-04 【裁定 1】**XRAP 能承载主题包**。我 v3 担心的"blob 资产 XRAP 装不下"是误判 ——
  `Carrier` 枚举本就是 `{row, blob}`，`DatasetManifest.declaredRowCount` 注释明写
  "纯 blob 数据集为 null"。
- 2026-08-04 【裁定 2】**XRAP 硬拒用户覆盖层**：`dataset_registry.dart:62-68` 要求
  `publisher == official`，否则注册期抛 `DatasetRegistrationError`（不变式 I9）。
  用户覆盖的 publisher 不可能是 official —— 这正是 S5a 独有部分的边界依据。
- 2026-08-04 【裁定 3】**边界在"谁发布"，不在"是不是主题"**。
  `dataset_installer.dart:188-192` 写死"唯一实现，数据集无关，差异由各自的
  `DatasetMaterializer` 承担"。故删除 v3 的全部安装机制：`install` / `uninstall` /
  安装类方法与安装态类型、主题包 zip 格式与 manifest 定义、版本兼容规则、
  验签端口、远端拉取端口、包落盘端口，全部不由 S5a 定义。
  **新增** `ThemeMaterializer`（唯一可插拔点）+ `themeDatasetDescriptor()`。
  > ⛔ **本条的 `ThemeMaterializer` 已被 v5 supersede** —— 该空子接口在 v5 被删除，
  > 现为 `InMemoryThemeMaterializer implements DatasetMaterializer`（设计 §4.2）。
  > `themeDatasetDescriptor()` 的签名也已被 v6 supersede，现为
  > `themeDatasetDescriptor({required DatasetMaterializer Function() materializer})`（设计 §5.6.2）。
- 2026-08-04 【裁定 4】**`ConfigBootstrap` 三占位符不是 S5a 阻塞项**：
  `dataset_source.dart:61` 明写"未配置返回 null（此时只用内置世代）"，`bundledManifest`
  恒存在、冷启动零网络。实证：T1 已交付完整接入样板（main `6cd7a66`，geo 三数据集），
  全程 generation 0，未用到任何域名或公钥。已从阻塞项摘除。
- 2026-08-04 【连带 1】**载荷形态改为预构建**：XRAP 要求内置世代 `payloadFormat` 必须是
  `prebuilt`（`dataset_descriptor.dart:33-37`，注册期强制）。故设备上**零 YAML 解析**，
  YAML → 扁平 token 的转换移到**构建期脚本**（照 T1 的 `assets/tool/build_geo_sql.py`）。
  连带 A14a/d/e 从"合并层责任"改判为"构建脚本责任"。
- 2026-08-04 【连带 2】**P3 由运行时断言升级为结构性保证**：v3 靠"默认实现恒抛 StateError"
  兑现零 IO；v4 直接移除发起 IO 的能力（构造器只收 `ThemeLocalReader`）。
  不可表达优于运行时拦截 —— 与 S1a §2.3「把非法值从参数表移除」同一手法。
- 2026-08-04 【连带 3】**P6 语义变更**：v3 测"下载未完成时返回旧主题"，但下载已归 XRAP。
  v4 改测"活跃世代落地物读取挂起时，`resolve()` 仍在 50ms 内返回 bundled 兜底且不抛异常"
  —— 这才是 S5a 侧真实存在的降级路径。
- 2026-08-04 【连带 4】文件计数变更。**v4 当时的值**：契约层 7 → 9（新增
  `theme_materializer.dart`、`theme_dataset.dart`；安装态值类型改为只保留本地可用主题
  `LocalTheme`）；reference 层 2 → 3（新增内存 materializer）；测试 7 → 8（新增 A20 的
  materializer 测试）。
  > ⛔ **契约层 9 已被 v5 supersede → 8**（v5 删掉 `theme_materializer.dart` 空子接口，
  > A3 覆盖下限 `== 8`）。
  > ⛔ **reference 层 3 已被 v6 supersede → 4**（v6 新增 `theme_assembly.dart`，
  > 设计 §4.5 / §11.2）。
  > **当前唯一有效计数以设计 §11.1–§11.3 与本纪要「范围 · 做」段为准：
  > 契约层 8 / reference 4 / 测试 8 / 门禁脚本 1 = 21 个交付文件。**
- 2026-08-04 【记录】`assets/pubspec.yaml` 的 `dependency_overrides.persistence_core`
  从 git URL 改为 `path:../core` **已随 T1 落到 main**，保留。理由（人类给出）：
  `dependency_overrides` 只在该包作为根包时生效，外部仓库消费 assets 时会忽略；
  而在 worktree 里 `../core` 正确指向本 worktree 的 core，开发期反而更对。

### v3 修订（2026-08-03，按 Codex gStack R2 的四条 P1）

- 2026-08-03 【R2-P1-1】**A14 五条拆分归属**。起因: Codex 指出 A14b/d/e 无法在 reference
  表面执行 —— reference 输入是**已解析的扁平 Map**，不含 manifest，也不做数值解析。
  处置: A14a/A14c 留在 S5a（合并层可执行）；A14b/d/e **移交后续 installer/parser 任务**，
  已登记设计 §11.5 防丢失。新增 **A19** 守边界: 合并层不得吞值，非法值须原样透传
  （注入 `"8px"` 断言原样出现在结果中）。
- 2026-08-03 【R2-P1-2】**新增 §5.5 注入面与测试探针**。起因: Codex 指出
  `_CountingHttpClient` / `localTokenReadCount` / "永不完成的 install" 在 §5/§11 都不是
  真实类型，机械执行者无法知道它们是构造器参数、回调还是测试端口。
  处置: 新增 `core/lib/model/theme_source_ports.dart` 定义四个窄端口
  （当时为四个，v4 收窄为一个 `ThemeLocalReader`），
  写死 `InMemoryThemeResourceStore` 构造器签名、四个探针的**计数时机**（何时 +1）、
  P3 的四步断言与 P6 的九步状态转换。
  **reference 的 remote/package 默认实现恒抛 `StateError`** —— 兑现零 IO 且违反即炸。
- 2026-08-03 【R2-P1-3】**签名钩子落成真实类型**。起因: Codex 指出 §9.1 说"契约须留
  verifySignature 钩子"，但 §11 的八个文件里没有任何验签类型，唯一的验签器在外部
  `xuan_config` 仓库。处置: 当时为 S5a 自持验签窄接口。**v4 已整体移交 XRAP**，
  S5a 不再定义任何验签类型。
- 2026-08-03 【R2-P1-4】**bundled 来源改为注入，跨仓库迁移明确出范围**。起因: Codex 指出
  "bundled 权威源是 theme 仓库的文件"与"ACT 不得动 theme 仓库"矛盾，执行者可能去跨仓库
  拷文件。处置: reference 通过 `ThemeLocalReader.readBundledTokens()` 接收**已解析的 Map**，
  来源由装配层决定；新增 **stop condition #2**「需要读取或拷贝 theme 仓库任何文件即停」。
- 2026-08-03 【连带】契约层文件数 6 → **7**（新增 `theme_source_ports.dart`），
  A3 覆盖下限同步改为 `== 7`；测试支撑新增 `core/test/support/theme_probes.dart`。

### v2 修订（2026-08-03，按 Codex gStack R1）

- 2026-08-03 【P0-1 修复】**交付形态由「纯契约」改为「契约 + reference 实现」**（人类拍板方案 B）。
  起因: Codex 指出 A9–A14、P1–P7 需要可执行行为主体，而"零实现"范围下执行者只能写空断言、
  测试自带算法、或违反零实现，三条都是坏的。新增 `core/lib/reference/` 两个文件承载行为，
  A3 的零实现扫描范围收窄至 `core/lib/model/theme_*`。
- 2026-08-03 【P0-2 修复】**5 项"转 ACT 前确认"全部关闭**。起因: Codex 指出前三项已被
  A9–A14 当作既定行为在测 —— 未定的东西不能进验收标准。覆盖粒度/light-dark/orphan 三项
  人类授权按倾向拍板；主题包签名定为复用 S5c 的 ed25519（分离 `.sig`）；bundled 权威源
  定为 `theme/config/presets/default.yaml`。
- 2026-08-03 【P0-3 修复】**基线错误已诊断**。起因: Codex 发现目标 worktree 的
  `core/lib/model/` 无任何 S1a 文件。查证根因: S1a 契约**已合入本地 `main`（16987fe）**，
  但我把 worktree 建在 `origin/main`（2824f37），后者落后 27 个提交。
  **不是"S1a 未合入"，是我选错基线。** 已加"基线前置条件"与 stop condition #1。
- 2026-08-03 【P0-4 修复】**策略注册落点精确化**。新增 `core/lib/model/theme_module_registry.dart`，
  写死文件、函数、幂等策略（`_registered` 标志，不用 try-catch 吞 StateError 以免掩盖真实冲突）、
  entityType 常量（禁止内联字面量）。A8 改为真实调用 + 断言进表 + 幂等 + 重复注册仍抛。
- 2026-08-03 【P1 修复】**合并算法完整规格补入设计 §6.6**：扁平化规则（List 视为叶子）、
  逐 key 三层取值（`containsKey` 而非 `??`，null 也算命中）、原子组补全（清单写死：
  shadow/border/text_shadow/padding/margin）、orphan 判定与执行顺序（1→5→2→4→3→6）、
  反扁平化与字典序、缓存键三元组、不可变性要求。原设计只有散文描述，无法机械执行。
- 2026-08-03 【P1 修复】**P1 基准判据具体化**：定义共同 fixture（叶子数 >= 700 防空输入假通过）、
  warm-up 20 次、阈值由 <1ms 放宽到 <5ms、标 benchmark tag 不进 CI 阻塞门禁。
  起因: Codex 指出原版无 warm-up/fixture/平台定义，debug VM 抖动且可用空 Map 假通过。
- 2026-08-03 【P1 修复】**P3/P4 绑定真实入口 + 正向控制**。起因: Codex 指出只写"注入 fake"
  无法证明生产调用链使用了这些实例，测试可绕过直接调 fake。现要求注入到 store 构造器、
  经 `resolve()` 驱动、并断言本地读取 spy `callCount > 0`。新增纪律第 9 条。
- 2026-08-03 【P1 修复】**A3/A18/fixture 三处补覆盖下限**（文件数 ==6、dartdoc >=60、叶子 >=700）。
  起因: Codex 指出 A3 的 glob 若不匹配任何文件同样成功，纪律第 3 条自己要求下限却没给 A3 规定。
- 2026-08-03 【P1 修复】**§8.1 补全 SHALL 逐条映射**，每条给出 spec.md 行号 + 处置 + 验收编号。
  新增 A14c（缺失字段 legacy fallback，:54）、A14d（数值非法 caught error，:60）、
  A5b（不依赖 xuan_config，:69–74）、A17（Canvas 避让，:116/:123）。
  起因: Codex 指出原版遗漏这些 SHALL，部分内容在 §8.3 但没进验收标准。
- 2026-08-03 【P1 修复】**§8.2 表述降调**。原写"该处 override 合并**指** YAML 内部合并"，
  改为"这是**架构决定**而非源码已证实"，并列表说明每条证据能证明与不能证明什么。
  起因: Codex 指出 `config_repository.dart:8` 只是一句 Phase 0a TODO，未定义 override 的
  对象/算法/层级，支持但不能证明该解释；`fromConfigResult` 看不到 raw YAML 只能证明
  "不该放 TokenLoader"，不能单独证明"应归 storage"。
- 2026-08-03 【P1 修复】**拆分 S1b 依赖论断**。原写"归 private 后**自动获得**同步/E2EE/导出"，
  改为三行诚实分类：标策略不会自动建表/mapper/outbox；契约层与 reference 不依赖 S1b（成立）；
  但"可跨设备同步"的能力落地依赖后续 drift+outbox 集成（原文漏了）。
- 2026-08-03 【P1 修复】**两处事实错误**: `theme/lib` 19→**20** 个 dart 文件；
  shell `default.yaml` 197→**203** 字节（197 是 `dark.yaml` 的，张冠李戴）。
- 2026-08-03 【P2 修复】**不可变性写入契约**（新增 A16）。起因: Codex 指出
  `Map<String,dynamic>` 可被调用方就地修改，会污染缓存实例使 P2/P7 失效。
  要求 `Map.unmodifiable` 逐层包裹。
- 2026-08-03 【P2 修复】**P6 的"X ms"具体化为 50 ms**，并写明计时起点与 `Stopwatch` 用法。
- 2026-08-03 【新增】**§11 交付物清单**（14 个文件精确路径）+ **4 条 stop conditions**。
  起因: SHALL :134 的可执行计划门禁要求列精确文件/测试/fallback/验证命令/stop condition。

### v1 决定（2026-08-03，讨论期）

- 2026-08-03 **整包分发（方向 A）**，不做 token/资产分半。理由: 整包让版本兼容退化为单一维度；
  分半会产生 token 版本 × 资产版本的二维矩阵，且 Marketplace 上传要打包两半、卸载无法原子。
- 2026-08-03 **主题当前是纯 YAML**（实测 4 个 preset 共 64K，16 组件，零二进制），
  **但格式必须为资产预留位**。理由: 人类确认 TTF/PNG/SVG/Lottie 将来必定引入。
  总纲 §2.1.2:162「每个数 MB」在当前时点不成立。
- 2026-08-03 **`theme` 包零改动**。理由: 实查 `theme/lib` 零 IO，且 `token_loader.dart:11`
  自陈「theme 层禁止读取 YAML / 解析 $ref / 执行 schema 校验」。
- 2026-08-03 **Controller 是 shell 侧已存在的 `ShellThemeController`**，`theme` 是纯函数库。
- 2026-08-03 **用户覆盖层归 `private` + `user`，落 drift**，不放 `preferences`。
  理由: 实查 `preferences` 包零同步能力（`OutboxStore|SyncPeer` 无命中）。
- 2026-08-03 **只存差量，不存拷贝**。否决「生成 C 包」与「拷完整 YAML 只替换一处」两案。
- 2026-08-03 **写入 = 批量差量 patch + 显式 `removeOverrides`**（人类认可）。
- 2026-08-03 **读写不对称**（读=合并结果，写=只碰覆盖层）（人类接受）。
- 2026-08-03 覆盖用**增量 patch**，blob 引用计数用**全量对账**，二者相反。理由见设计 §2.4。
- 2026-08-03 **覆盖取值 = 值快照 + 记来源**，不存对 B 包的引用。
- 2026-08-03 **启动路径纯本地、零网络、零解压**；下载与切换全在后台。
- 2026-08-03 **`chart` token 仅透传不解析**（避让 Canvas 提取）。
- 2026-08-03 **S5a 即在途 OpenSpec change 点名要的那个独立 change**（其 Tier 3 明写
  marketplace/sync/uploaded assets 须独立 change）。

## 阻塞项

**无。** 本任务当前无阻塞项。

### 已知非阻塞背景（记录，不构成 stop gate）

- `ConfigBootstrap.endpoints` / `allowedHostSuffixes` / `l0PublicKeyBase64` 仍为占位符。
  **与 S5a 无关**（人类 2026-08-04 裁定 4）：`dataset_source.dart:61` 明写"未配置返回
  null（此时只用内置世代）"，`bundledManifest` 恒存在、冷启动零网络。
  实证：T1 已交付完整 XRAP 接入样板（main `6cd7a66`），全程 generation 0，
  未用到任何域名或公钥。由 XRAP 远端源任务承接，**不得写入 S5a 的 stop conditions**。

## 踩坑墓地

- 2026-08-03 【严重】**换 worktree 等于换基线，先前核实的事实不自动继承**。
  我在 `mimo-storage-s1b-multipeer` worktree 里亲手核实过 S1a 的 12 个契约文件存在，
  随后开新 worktree 从 `origin/main`（2824f37）起 —— **没有重新验证基线**，
  而 `origin/main` 落后本地 `main`（16987fe）27 个提交，S1a 契约全部不在。
  整份设计的端口签名建立在这些文件上，在错误基线上无法编译。
  Codex 评审发现。**结论: 每次换工作区，第一件事是重验基线，不要相信记忆。**
- 2026-08-03 曾判断「S5a 可缩水为 S5c 加一条配置源」（依据实测主题为 5–9KB 纯 YAML）。
  被人类否决 —— 二进制资产将来必定引入，blob 链路必须建。
- 2026-08-03 曾把 `theme` 包描述为「从 xuan-storage 取数据的 Controller」。
  经实查修正 —— `theme/lib` 零 IO，拿不到任何数据；真正的 Controller 是
  `xuan-shell/lib/theme/shell_theme_controller.dart`。
- 2026-08-03 曾以为 `xuan-shell` 的主题链路已工作。实查发现
  `ShellThemeLoader.loadAndValidate` 返回 `Future<void>`（只校验不产出），
  `_themeSet` 始终是 `DefaultXuanThemeData.themeSet`，
  且 `assets/themes/default.yaml` 只有 203 字节（三个空 Map）。
- 2026-08-03 总纲 §8.1:1235 示意图写 `ThemeRepository.get(...)`，但 xuan-storage 全仓库
  grep **零命中**。主题现状整个在独立 `theme` 仓库（总纲 §0.1 包名对照表未列）+ `xuan_config`。
- 2026-08-03 曾把「零实现契约」与「行为验收标准」写进同一份纪要而未察觉矛盾。
  Codex 指出后才意识到: 抽象接口产生不了行为，A9–A14/P1–P7 无从验证。
  **结论: 写验收标准时先问「谁来产生这个行为」，答不上来就是范围没定清。**

## 冷冻快照
<搁置时由 /hibernate 填写>
