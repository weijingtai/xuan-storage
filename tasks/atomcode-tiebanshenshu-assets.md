# 任务纪要 · tiebanshenshu（铁板神数）资源迁入 xuan-storage

> 执行 agent：AtomCode（deepseek-v4-flash）
> 日期：2026-08-09
> 跨仓：源仓 `xuan-tiebanshenshu`（main `785556e`）→ 目标仓 `xuan-storage`（分支 `feat/tiebanshenshu-assets-xrap`，自 main `99ead53`）
> 参考：`PLAN-REMAINING-MODULES-ASSETS-MIGRATION.md` §四 M6 + `GUIDE-ASSETS-MIGRATION.md` + 样板 geo/qizhengsiyu

## 目标

把铁板神数的数据资源按 XRAP 协议统一迁入 `xuan-storage/assets/lib/tiebanshenshu/`：
1. `tiebanshenshu.tiao_wen` 数据集（all_tiao_wen_v1.csv → prebuilt CSV→表）XRAP 注册 + drift + `XrapTiaoWenRepository` 实现 `TiaoWenRepository` 11 方法
2. kao_ke（21）/ shaozishu（12）/ formulas（3）无端口 → 按 D4 不注册 dataset，物理文件已迁入保留
3. 源仓双副本 git rm（assets/ + example/assets/），分支 `feat/tiebanshenshu-assets-xrap`

## 盘点清单

见 `docs/storage-tiebanshenshu-assets-migration/INVENTORY.md`（已落盘）。

## 决定记录

- D1 payloadFormat：CSV 表形 → `prebuilt`（CSV→表，照 geo JSON→表 改 CSV 解析）；**不做 rawText**（DatasetRegistry 拒绝）。
- D2 双副本：全部 IDENTICAL → 任选权威，两份都 git rm，commit message 含禁令。
- D4 无端口：kao_ke / shaozishu / formulas 不注册 dataset，物理保留，交接报告记录「待 repository-interface-tiebanshenshu 补端口后接入」。
- **待人类确认**：CSV 解析方案 A（完整 SQL 实现 11 方法）vs 方案 B（drift 表存原始行 + 保留旧解析逻辑读表后内存处理）。PLAN 建议 B。**本次已按方案 A 实现**（`XrapTiaoWenRepository` 完整 SQL 查询，测试全绿），若人类裁定改用 B 需重写 repository 层。
- D8 Web 端：drift 只经 XRAP installer 落库，不让 shell 直开 → 无需条件导入。
- D3 旧桩：`AssetsTiaoWenRepository` 有消费方（源仓 main/example/test + xuan-shell `shell_scoped_storage_runtime.dart`）→ 标 `@Deprecated` 保留过渡，不删除。

## 步骤进度

- [x] 步骤 0：盘点 + INVENTORY 落盘
- [x] 步骤 1：源仓 git rm 双副本（worktree `xuan-tiebanshenshu/.worktrees/atomcode-tiebanshenshu-assets-rm`，commit `6d20727` 含禁令）
- [x] 步骤 2：`assets/tool/build_tiebanshenshu_sql.py` + BUILD-REPORT.md（重跑幂等，sha256 与 manifest 一致）
- [x] 步骤 3：`tiebanshenshu_datasets.dart` + drift 表 + installer + `XrapTiaoWenRepository`（11 方法方案 A）
- [x] 步骤 4：注册测试 + A1/A2（15 条全绿）+ analyze 新文件零 issue
- [x] 步骤 5：旧桩 `@Deprecated` + 消费方清单（见下）

## 消费方清单（步骤 5 / 步骤 6 跨仓切换用）

| 消费方 | 位置 | 当前链路 | 切换动作 |
|---|---|---|---|
| 源仓 main | `xuan-tiebanshenshu/lib/main.dart:29` | `AssetsTiaoWenRepository` | 换 `XrapTiaoWenRepository`（跨仓后续） |
| 源仓 example | `xuan-tiebanshenshu/example/lib/main.dart:47` | 同上 | 同上 |
| 源仓测试 | `test/tiao_wen_repository_test.dart` 等 5 处 | 同上 | 换 XRAP 后同步测试（跨仓后续） |
| xuan-shell | `xuan-shell/lib/storage/shell_scoped_storage_runtime.dart` | 同上 | 换 XRAP 链路（跨仓后续） |

## 验收命令:

bash scripts/run_s1a_analyze_gate.sh && (cd core && flutter test) && (cd assets && flutter test) && bash scripts/run_monorepo_convention_check.sh

## 踩坑墓地

- 进 worktree 第一件事 `flutter pub get`，否则 analyze 假 issue
- pubspec_overrides.yaml 整体取代 dependency_overrides，新建时把原有条目一并抄来（已从 qizhengsiyu worktree 抄入）
- 入库 pubspec 相对路径以 main 为准，不许改路径深度
- CSV 解析容错：ageSet 括号/空白、DiZhi 模糊匹配 `name == setNameStr || toString().contains(setNameStr)`，差分测试需对齐
