# PLAN

## WEB-BLOB-CHROME-REWORK ACT 01（2026-08-31，Storage IndexedDB backend，GREEN）

- [x] WB1：`WebBlobByteBackend` S1d 占位替换为 IndexedDB（库
      `xuan_blob_bytes_v1` / store `chunks`，key = manifestDir/index，二进制
      structured-clone，单 key 事务原子，缺失读 BlobNotFoundError，orphan 恒空）。
      接口移入 `blob_byte_backend_contract.dart`；边界死条件 `dart.library.html`
      → `dart.library.js_interop`；`DriftLocalBlobStore` / `DriftBlobGarbageCollector`
      改经平台工厂取 backend（native 布局不变）。提交 `3d30dea`。
- [x] WB1 验证：`dart test -p chrome test/blob/web_blob_byte_backend_test.dart`
      → 9/9 exit 0（真实 IndexedDB，dart2js）；`flutter test -d chrome …` → exit 0
      （DDC 走 native 分支兼容）；VM 回归 46/46 + 宽扫 test/blob+media 134/134；
      analyze 变更文件 0 issue；mutation（web 工厂→Unsupported）RED→GREEN。

## WEB-BLOB-CHROME-REWORK ACT 00（2026-08-31，Chrome 真实 RED 冻结）

- [x] WB0：`test/blob/web_blob_byte_backend_test.dart`（Chrome-only）：经 `web.dart`
      构造 `WebBlobByteBackend`，断言 writeChunk → readChunk 0x00/0xFF 无损往返 +
      listChunks；当前必须 UnsupportedError RED（S1d 永久占位，7447e74）。提交
      `d15cf8e`。已探明：既有条件入口 `blob_byte_backend.dart` 的
      `if (dart.library.html)` 在本工具链（Flutter 3.44 / DDC 与 release 均）为死条件，
      WB1 须改为 `if (dart.library.js_interop)` 并删第二个分支（生产改动，WB0 未动）。

- [x] C1（FINAL-REWORK-PLAN CURRENT EXECUTION CONTRACT，2026-08-30）：saveWithBlobs
  事务内原子校验引用 blob —— openRead + 完整消费每个声明的 handle，absent/partial/
  corrupt/undecryptable 映射现有 StorageError 并整体回滚（Record/index/refs/outbox），
  重启后仍全空；提交 `dac540b`。
- [x] Wave 0 / Storage S4：解析稳定 Account 与 Xiang 依赖；删除本任务相关的重复 dependency overrides 和 Xiang feature ref；新增 Account L0 get/put 契约编译测试。
- [x] Wave 0 / Storage S4：运行 `flutter pub get`、Account 契约测试、10.7 五个 S4 定向测试、限定范围 analyze 与 `git diff --check`；把 lockfile source/url/resolved-ref 写入 HANDOFF。
- [x] Wave 1A A2 / ScopeResolver：真实 device scope RequestContext、Err 传播、session absent/repository Err/identity-link Err/双账户测试。
- [x] Wave 1A A3 / Record direct transaction body：DataSource direct body、UoW 唯一事务、search/index/refs/outbox 原子性、生产 outbox required、显式 test-only no-outbox factory。
- [x] Wave 1A A4 / Scope relation writes：LocalRecord uuid+module+scope、Case/WorkItem/Participant/PanelRef/WorkItemPanelRef scope 与关系验证、A/B mutation zero-residue tests。
- [x] Wave 1A A4 follow-up：Case UUID 写入前检查既有 scope，拒绝 B 覆盖 A；新增零残留回归测试。
- [ ] Wave 1A A1：fresh analyzer 未出现需重做的旧 L0 七文件编译清单，按任务指示跳过；后续如新 fresh analyzer 明确列出再单独处理。
- [ ] Wave 1B：由 Shell owner 按 §10.8 执行。

## MEDIA-REWORK ACT 05（2026-08-31，本仓无改动，验收 PASS）

- [x] drift_media_acquisition_adapter_test 6/6、analyze 0 issue、diff-check clean。
