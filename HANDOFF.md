# HANDOFF

更新时间：2026-07-19
当前分支/worktree：/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage

刚完成：
- bazi case/record preferences repository 已按 scopeUid 隔离。
- key 使用 bazi.$scopeUid.cases / bazi.$scopeUid.records。
- 匿名 scope 与登录 scope 不自动迁移，数据按 scope 保留。

验证：
- cd preferences && flutter test：27 项通过。
- 反向验证：临时去掉 key 中 scopeUid 后，scope isolation 测试失败；恢复 scope key 后测试通过。

已知风险：
- 本轮不处理跨 scope 自动迁移/合并。
- isConflict 不在 bazi storage 内自动合并。
