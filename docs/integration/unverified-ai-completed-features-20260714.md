# AI 已完成但未人工验收的 Storage 功能记录

更新时间：2026-07-14

## 当前状态

本仓库近期由 AI agents 完成了一批 storage 相关编码工作，并经历了若干轮本地测试、自动化测试、回归修复与编译问题修正。现有提交历史显示，多项 record、scope、sync、decision link、seeker 与 Drift 适配能力已经被实现或修复。

但这些能力仍应被视为“编码完成、自动验证通过过若干轮、业务验收未完成”的状态。它们尚缺少人类产品/业务侧验收，也缺少在真实上层业务应用中的完整集成测试。因此，后续接手者不应仅凭当前代码和测试结果直接认定这些功能已经达到可发布或可迁移完成状态。

## 已完成编码的主要 Storage 功能

### Record 基础设施

- 建立 `LocalRecordRepository`、`DriftRecordDataSource` 与 adapter registry 体系。
- 支持 scope 约束查询、cursor paging、watch、事务化 search-index 写入等基础能力。
- 引入 record scope 与 index 查询能力，并扩展 scope PID 系统。
- 增加基础 repository class、typed record base、module registry、central record module registry 等模块化接入设施。
- 完成 meihua、liuyao、qizhengsiyu、daliuren、qimendunjia、taiyishenshu、tiebanshenshu、ziweidoushu 等记录模块接入或修复。
- 增加多模块 codec 与 repository 测试，并修复 module registry uuid 类型、barrel export、unused import 等编译和 lint 问题。

### Scope 与账号边界

- 实现或导出 `AccountDatabase`、`DriftAccountIdentityLinkRepository`、`DriftScopeLedger` 等账号/身份关联相关能力。
- 实现 `DriftScopeBootstrapStore`，并补充 scope 相关 E2E 测试。
- 已有代码围绕 scope 强制过滤、身份绑定、scope ledger 与本地匿名身份进行过多轮修正。

### 同步与远端路由

- 增加记录云同步相关组件，包括 `RecordLocalApplier`、Outbox、SyncConfig、sync runtime、sync coordinator、remote gateway router 等。
- 增加 sync logger、sync configuration manager 与默认配置文件。
- 这些能力具备本地自动测试基础，但尚未完成真实云端账号、网络异常、冲突合并、离线恢复与跨端一致性的人工验证。

### Fork / Link / Merge 与决策链

- 实现 Fork/Link/Merge 引擎、入口推断与 schema v3。
- 增加 decision link、omni entity、omni op、omni coordinator 等相关模型和协调层。
- 该部分可能影响记录之间的引用关系、派生关系和合并语义，需要结合真实业务流重新确认数据含义。

### Seeker 解耦

- Seeker 相关数据已解耦到 `t_record_meta`，并以 `module='seeker'` 方式接入 record 元数据体系。
- 该改动涉及上层查询、迁移兼容和历史 seeker 数据解释，仍需要业务端回放验证。

### Drift 与平台适配

- 修复 Drift 相关技术债，包括用条件导入隔离 Drift FFI 依赖，以修复 Web 编译问题。
- 仓库中存在 Drift、Firebase、Supabase、assets、preferences 等多后端/多包结构；不同运行环境下的差异仍需逐项确认。

## 已有验证基础

从提交历史和测试目录看，AI agents 已围绕以下方向做过本地或自动化验证：

- core 层 repository、connection factory、version guard、storage error、remote gateway router 等单元测试。
- Drift 层 record、scope、sync、account、decision links、seeker、divination case、AI、各术数模块等测试。
- 多轮编译修复、lint 修复、Web 编译相关修复。
- 对部分 scope、record、module registry、codec、repository contract 做过回归修复。

这些验证能说明“代码已经被自动化测试覆盖过一部分”，但不能替代人工验收，也不能证明真实业务链路、真实数据迁移和真实跨端同步已经安全。

## 主要风险

- **业务语义风险**：record module、scope、decision link、seeker meta 的语义可能与上层业务真实预期存在偏差。
- **迁移兼容风险**：历史本地数据、旧 schema、旧模块记录、旧 seeker 数据在新结构中的映射仍需真实样本验证。
- **权限与隔离风险**：scope、account identity link、anonymous identity、scope ledger 的边界必须用多账号、多设备、多租户场景重新验收。
- **同步一致性风险**：Outbox、local applier、冲突处理、失败重试、离线恢复和远端路由尚需真实网络与云端环境验证。
- **查询与分页风险**：cursor paging、index query、search tags 与 module registry 组合后，可能在大数据量、缺索引或跨模块查询时暴露性能/正确性问题。
- **平台适配风险**：Drift FFI 条件导入修复了 Web 编译问题，但移动端、桌面端、Web 端的数据库能力和资源路径仍需分别验证。
- **测试可信度风险**：现有自动测试多由 AI agents 驱动补齐，仍可能覆盖了“实现认为正确的路径”，但没有覆盖真实用户路径。

## 后续接手建议

1. 先冻结当前功能清单，不要继续扩大 storage 行为面，优先做验收。
2. 以真实业务场景建立人工验收脚本：创建记录、编辑记录、跨 scope 查询、按模块查询、搜索、分页、关联、fork/link/merge、seeker 读写、删除与恢复。
3. 准备历史数据样本，执行旧数据到新 record/scope/module/seeker 结构的迁移回放。
4. 用至少两个账号、两个设备和离线/弱网场景验证 sync outbox、local applier 与远端路由。
5. 对 Drift/Firebase/Supabase 三类后端分别跑最小集成测试，确认接口契约一致。
6. 对 Web、macOS、iOS/Android 或实际目标平台分别验证 Drift FFI 条件导入和数据库初始化路径。
7. 把人工验收结果沉淀为项目内 acceptance 文档，并把真实失败样本补成回归测试。
8. 在上层业务应用完成一次端到端 smoke test 前，不要将这些能力标记为“业务已验收完成”。

## 接手判断

当前建议状态：

- 编码状态：已完成一批 storage 能力的实现与修复。
- 自动验证状态：经过若干轮本地/自动/回归测试，但覆盖面仍需审计。
- 人工验收状态：未完成。
- 业务集成状态：未完成。
- 发布建议：仅可作为待验收候选，不应直接作为已验收发布结论。
