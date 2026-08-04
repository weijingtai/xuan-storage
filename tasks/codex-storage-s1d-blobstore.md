# 任务: storage-s1d-blobstore
负责: codex ｜ 分支: agent/codex/storage-s1d-blobstore ｜ 开工: 2026-08-04
状态: 计划待复验（D1 已裁定，D2/真实云网关移出本轮）

## 目标
实现 drift LocalBlobStore、cipher resolver、RecordBlobUnitOfWork 与内存 BlobGateway fake，完成 v9 schema、文件系统续传、策略校验、原子 UoW 和 tier-safe GC；真实云对象存储延后到 S2-blob。

## 计划
- [x] 0.1 D1：drift concrete `stageIncomingManifest`，core 不变；策略只从本地 StoragePolicyRegistry 派生。
- [x] 0.2 D1 安全门禁：伪造 private→resource/cache 声明必须拒绝；未 complete staged 对普通读面不可见。
- [x] 0.3 D2 与 Firebase 真实网关移出本轮，云端选型延后到 S2-blob。
- [ ] 1.1 清理 build_runner 产物并建立零 `REFERENCES` 删除门禁。
- [ ] 1.2 完成 scope-aware 三表、v9 迁移、v1→v9 链路和 UTC 测试。
- [ ] 2.1 实现条件 byte backend 与原子 native chunk 文件。
- [ ] 2.2 实现 metadata repository、LocalBlobStore 五态/续传/去重/取消。
- [ ] 3.1 实现 async cipher registry、staged/committed/orphaned 状态机与 tier-safe GC。
- [ ] 4.1 提取 transaction-aware record 原语，实现 drift UoW 与内存 fake。
- [ ] 5.1 实现契约完整的内存 BlobGateway fake，覆盖 complete gating、续传、票据和取消。
- [ ] 6.1 完成逐测试变异证据、fatal analyze、core/drift 测试与四条门禁。
详细机械执行计划：`docs/superpowers/plans/2026-08-04-storage-s1d-blobstore-implementation-plan.md`。OpenSpec：`openspec/changes/storage-s1d-blobstore/`。

## 验收标准
- [ ] LocalBlobStore/cipher/UoW 有真实现，BlobGateway 有契约完整内存 fake；新增文件 `dart analyze --fatal-infos` 零 issue。
- [ ] v8→v9 三张表与索引存在，且 v1→v9 全链路迁移通过；不改 v8 及以前分支。
- [ ] blob 写入/读取字节一致、可从中断点续传、同内容不重复存储；DateTime 往返保持 `isUtc == true`。
- [ ] resolver `resolve` 为异步签名；identity cipher 返回已完成 Future。
- [ ] staged→committed 与 GC 符合裁定：sourceOfTruth 归零仅 orphaned 且保留字节，cache tier 才删除。
- [ ] diff 无任何既有 `REFERENCES` 外键删除；Web/P1/P2 不在本期实现。
- [ ] 每条测试完成变异自检并在决定记录写明注入点、预期红灯与复原结果。
- [ ] 四条既有门禁及 core/drift 测试全绿。
验收命令: bash scripts/run_s1a_analyze_gate.sh && bash scripts/run_s1b_analyze_gate.sh && bash scripts/run_monorepo_convention_check.sh && (cd core && flutter test) && (cd drift && flutter test)

## 当前状态
已完成计划返工：OpenSpec change 已通过 `openspec validate storage-s1d-blobstore`，4/4 artifacts 完成。
当前无协议决策阻塞；计划需完成本次裁定后的 OpenSpec 复验。
已有 WIP：v9 三表迁移/UTC converter 提交于 `57fe842`；identity cipher/内存 fake 提交于 `0595c25`。
下一步：计划复验通过后，从详细计划 Task 1 开始；完整门禁尚未运行。

## 决定记录
2026-08-04: schema 使用 v9，v8 及以前迁移保持不变，因为 S1b 已占用 v8。
2026-08-04: 本期不交付 Web blob 与 P1/P2 平台缺口，遵循人类裁定并仅记录残余风险。
2026-08-04: 仅修复新建 blob 三表的 DateTime UTC 语义，不顺手统一全仓，避免越界改动。
2026-08-04: GC 中 sourceOfTruth refCount 归零转 orphaned 但不删字节，只有 cache tier 真删，遵循收紧裁定。
2026-08-04: 不修改 core/lib/model 契约；实现全部放在具体后端与 fake 层，保持 core 零后端依赖。
2026-08-04: 旧 worktree 的 blob v8 产物仅作参考，不直接沿用，因为其缺少 main 上 D7 异步签名与 S1b v8。
2026-08-04: 用户要求本轮只制定 coding 计划并暂停编码；已将未完成实现作为 WIP 落盘，不宣称 S1d 已完成。
2026-08-04: 计划验收发现 D1（incoming putChunk 的 tier/visibility 来源）和 D2（Firebase 服务端票据协议）不可安全猜测，列为 Coding 前置闸门。
2026-08-04: 计划扩展为 13 个有文件、RED/GREEN、变异、提交点的机械任务；OpenSpec change `storage-s1d-blobstore` validate 通过。
2026-08-04: D1 采纳 drift `stageIncomingManifest` 且 core 不变；必须由 StoragePolicyRegistry 派生策略，拒绝伪造声明，未 complete staged 对普通读面不可见。
2026-08-04: D2 不在本轮裁定；删除 Firebase 实现任务，只交付内存 BlobGateway fake，真实云对象存储延后到 S2-blob。

## 踩坑墓地
2026-08-04: build_runner 在当前依赖版本删除大量无关 `.g.dart`；结论：恢复全部无关生成文件，只保留 blob 相关 hunk，并用 REFERENCES 删除检查门禁。
2026-08-04: 独立 worktree 的 drift path 依赖需 `.worktrees/` 本地链接才能 pub get；结论：这是环境准备，不改 pubspec 的 monorepo path 语义。

## 冷冻快照
当前不冷冻；无待决协议，等待收敛后的计划复验。
