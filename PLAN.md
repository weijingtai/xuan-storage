# PLAN

- [x] Wave 0 / Storage S4：解析稳定 Account 与 Xiang 依赖；删除本任务相关的重复 dependency overrides 和 Xiang feature ref；新增 Account L0 get/put 契约编译测试。
- [x] Wave 0 / Storage S4：运行 `flutter pub get`、Account 契约测试、10.7 五个 S4 定向测试、限定范围 analyze 与 `git diff --check`；把 lockfile source/url/resolved-ref 写入 HANDOFF。
- [x] Wave 1A A2 / ScopeResolver：真实 device scope RequestContext、Err 传播、session absent/repository Err/identity-link Err/双账户测试。
- [x] Wave 1A A3 / Record direct transaction body：DataSource direct body、UoW 唯一事务、search/index/refs/outbox 原子性、生产 outbox required、显式 test-only no-outbox factory。
- [x] Wave 1A A4 / Scope relation writes：LocalRecord uuid+module+scope、Case/WorkItem/Participant/PanelRef/WorkItemPanelRef scope 与关系验证、A/B mutation zero-residue tests。
- [x] Wave 1A A4 follow-up：Case UUID 写入前检查既有 scope，拒绝 B 覆盖 A；新增零残留回归测试。
- [ ] Wave 1A A1：fresh analyzer 未出现需重做的旧 L0 七文件编译清单，按任务指示跳过；后续如新 fresh analyzer 明确列出再单独处理。
- [ ] Wave 1B：由 Shell owner 按 §10.8 执行。
