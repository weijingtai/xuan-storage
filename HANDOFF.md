# HANDOFF

## WEB-BLOB-CHROME-REWORK ACT 03（WB3）— 门禁复核（2026-09-02）

- HEAD/worktree 不变：`3b97cb8`（WB1 docs 提交）/ `xuan-storage/.worktrees/
  media-preview-hint`。WB3 代码零改动；本段为 WB3 自动化门禁在 storage worktree 的
  复核记录。
- `flutter test -d chrome test/blob/web_blob_byte_backend_test.dart` → exit 0，9/9
  （真实 IndexedDB；session 内跨实例读取/隔离/前缀用例）。
- `flutter test --no-pub` blob+media 七文件 → exit 0，46/46。
- analyzer `lib/blob test/blob`：0 error/0 warning，仅 1 条既有基线 info
  （`in_memory_blob_store.dart:92` curly_braces，96699be 遗留、仅测试引用，不顺手修）。
- `git diff --check` clean；禁止项静态扫描生产路径无命中（唯一命中为同一既有测试
  Fake）。
- 权威日志与截图/台账：根
  `openspec/changes/integrate-xiang-kanyu-common-ui-cast/evidence/web-blob-chrome/`；
  真实系统 picker 人工旅程待用户执行（见同目录 final-evidence.md §8）。

## WEB-BLOB-CHROME-REWORK ACT 01 — IndexedDB WebBlobByteBackend（2026-08-31）

- 当前分支/worktree/HEAD: `fix/media-preview-hint` / `xuan-storage/.worktrees/
  media-preview-hint` / `3d30dea`（实现提交；上一基线 `dc94193`）
- 变更范围（WRITE + MAY_CREATE 全清单）：
  - `drift/lib/blob/blob_byte_backend_contract.dart`（新）：唯一
    `BlobByteBackend` 接口移入平台中立文件，解除 web 分支条件导入循环。
  - `drift/lib/blob/web.dart`：S1d UnsupportedError 占位（7447e74）替换为
    IndexedDB 实现 —— 版本化库 `xuan_blob_bytes_v1` / store `chunks`；value 为
    二进制 structured-clone（JSUint8Array）；key = `'$manifestDir/$index'`
    （manifestDir 已含 logical namespace + scopeUid/cipherManifestId）；单 key
    read-write 事务原子提交，无 temp/rename；缺失读映射既有 `BlobNotFoundError`；
    事务/请求错误传播 `IdbBlobStorageException`（带 DOMException name/message）；
    `orphanChunkPaths` 恒空。枚举/删除按精确前缀过滤（相邻 manifest 名前缀不串）。
  - `drift/lib/blob/blob_byte_backend.dart`：死条件 `dart.library.html` 改为
    活的 `dart.library.js_interop`；导出契约 + 对应平台实现。
  - `drift/lib/blob/blob_byte_backend_factory{,_native,_web}.dart`（新）：平台
    工厂；`DriftLocalBlobStore` 与 `DriftBlobGarbageCollector` 改消费工厂
    （不再硬编码 FileSystemBlobByteBackend；native 布局不变）。
  - `drift/pubspec.yaml`：直接依赖 `web: ^1.1.1`。
  - `drift/test/blob/web_blob_byte_backend_test.dart`：WB0 RED 文件扩为完整
    合同套件（9 例：往返/原子覆盖/BlobNotFoundError/精确 index+size/删除隔离/
    跨实例读取/scope 隔离/相邻前缀隔离/orphan 恒空），经工厂构造 backend。
  - `drift/.gitignore`：`xuan-blob/`（DDC 运行会落入测试残渣目录）。
- GREEN（命令/退出码）：
  - `dart test -p chrome test/blob/web_blob_byte_backend_test.dart` → **exit 0
    9/9**。这是**真实 IndexedDB 证明**（dart2js 编译、浏览器 IndexedDB 持久化，
    跨实例读取用例即收割于真实存储）。
  - `flutter test -d chrome test/blob/web_blob_byte_backend_test.dart` → exit 0
    （同套件；注意 DDC 下工厂解析到 native 分支，走的是文件后端，非 IndexedDB
    —— 仅作兼容性验证，真实 IndexedDB 以 dart2js 运行为准）。
- RED（WB0 已冻结；MUTATION_PROOF）：
  - 实现前：同一套件在 `dart test -p chrome` 下 9/9 RED（UnsupportedError）。
  - Mutation：`blob_byte_backend_factory_web.dart` 临时返回
    `UnsupportedBlobByteBackend` → `dart test -p chrome` 9/9 RED（exit 1）→
    还原 → 9/9 GREEN（exit 0）。
- 回归：ACT 指定 7 文件 `flutter test --no-pub …` → 46/46 exit 0；超宽
  `flutter test --no-pub test/blob test/media` → **134/134 exit 0**；
  `git diff --check` → clean。
- analyzer：`flutter analyze --no-pub lib/blob test/blob/web_blob_byte_backend_test.dart`
  → 变更文件 0 error / 0 warning / 0 info（唯一 info 为未触碰的
  `in_memory_blob_store.dart:92` 既有基线）；`lib/blob/web.dart` 单独分析 →
  No issues。
- 环境探明事实（WB2 必读；同时修正 WB0 HANDOFF 的两处误读）：
  1. **工具链分叉**：`flutter test -d chrome` 走 DDC，本包文件**直接**
     `import 'dart:js_interop'` 无法编译（`'JSObject' isn't a type` /
     `'toJS' isn't defined`）；因此条件工厂/边界在 DDC 下解析 native 分支。
     `dart test -p chrome` 走 dart2js，`dart.library.js_interop` 完整可用 ——
     真实 IndexedDB 验证的唯一现成测试运行器（`flutter test --wasm` 本工具链
     不支持）。
  2. **package:web 用法**：`package:web/web.dart` barrel 在 DDC 下因
     helpers/http.dart 的遗留 `jsify`（已从 dart:js_interop 移除）编译失败；
     web.dart 改 import 窄入口 `package:web/src/dom.dart`（带说明 + 定向
     ignore）。生产 release（dart2js）下 barrel 亦可，但窄入口双平台一致。
  3. **persistence_core barrel → Flutter**：barrel 传导
     `world_country_repository.dart`（imports Flutter），dart2js 无法编译
     Flutter 引擎源码；web.dart 与测试改用窄 import
     `package:persistence_core/model/blob_error.dart`。
  4. 修正 WB0 记录：当时探针的“wasm worker 可起/sqlite 持久打开失败于沙箱”系
     误读 —— 那些错误来自 drift_flutter 的 **native 分支**（DDC 下
     js_interop=false 误选 native，stub dart:io / path_provider），从未真正
     运行 WasmDatabase。真实 drift-web 只在 dart2js 上下文可用
     （`flutter build web` / `flutter run -d chrome` 产物级）。
- 未运行项：Shell 侧 WB2 生产装配（下一步）；真实 Chrome picker/重启（WB3）；
  release `flutter build web`（WB2 门禁）。
- 提交：`3d30dea fix(storage): persist web blob chunks in IndexedDB`（未 push）。
- 下一步：`act/web-blob/02-shell-web-wiring.yaml`（Shell Web 生产装配与 E2E；
  Shell WB0 RED 转 GREEN 需让 DriftLocalBlobStore 在真实 Chrome（dart2js）下
  用 IndexedDB 后端 + 真实 drift 库（wasm 在 HTTP 宿主下可用）跑通）。

---

## WEB-BLOB-CHROME-REWORK ACT 00 — Chrome 真实 RED 冻结（2026-08-31）

- 当前分支/worktree/HEAD: `fix/media-preview-hint` / `xuan-storage/.worktrees/
  media-preview-hint` / `d15cf8e`（test commit，上一基线 `12684e6`）
- 变更范围（仅新增测试，零生产代码改动）：
  - `drift/test/blob/web_blob_byte_backend_test.dart`：Chrome-only，经 `web.dart`
    直接构造 `WebBlobByteBackend`（有条件入口 `blob_byte_backend.dart` 的
    `dart.library.html` 死条件，本工具链恒解析 native，故不经它），断言
    writeChunk → readChunk 的 0x00/0xFF 无损往返 + listChunks={0}。
- RED（命令/退出码/断言）：`flutter test -d chrome test/blob/web_blob_byte_backend_test.dart`
  → exit 1，`Unsupported operation: Blob byte storage is not supported on web
  platforms in S1d…`（web.dart:35 `_unsupported`，S1d 永久占位 7447e74）。
- GREEN：未执行（本 ACT 只冻结 RED，GREEN 属 WB1 IndexedDB 实现）。
- analyzer：`flutter analyze --no-pub test/blob/web_blob_byte_backend_test.dart`
  → exit 0，No issues。`git diff --check` → clean。
- mutation：不适用（无生产代码改动；该测试即 WB1 的行为契约，实现回退即 RED）。
- 探明事实（WB1 必读）：
  1. `dart.library.html` 已是死条件（DDC 与 dart2js 均 false），既有条件入口
     `blob_byte_backend.dart` 在 Web 目标恒解析 native.dart；仓库现代样板为
     `if (dart.library.js_interop) 'web.dart' if (dart.library.ffi) 'native.dart'`
     （见 `four_zhu_card_templates/connection.dart`）。WB1 改条件入口属生产改动。
  2. `flutter test -d chrome` 走 DDC（`Uri.base` 为 file://），`dart.library.
     js_interop` 亦 false；drift_flutter `driftDatabase` 因此误选 native 分支
     （构造期崩于 path_provider），`package:drift/wasm.dart` 亦无法编译
     （sqlite3 wasm 的 JSObject/JSBigInt 类型解析失败）。真实 wasm/IndexedDB
     枚举断言须在 `flutter run -d chrome`（dart2js，HTTP）或等价 harness 运行，
     或经显式 WasmDatabase + 插件桩（本仓未完成该组合）。
- 未运行项：VM 回归（本 ACT 零生产改动，无回归面）；真实 Chrome picker（WB3）。
- 提交：`d15cf8e test(storage): reproduce Chrome blob backend failure`（未 push）。
- 下一步：`act/web-blob/01-storage-indexeddb.yaml`（WB1：IndexedDB WebBlobByteBackend
  七方法 + DriftLocalBlobStore 条件 factory + 死条件修复；本文件转 GREEN）。

---

## MEDIA-REWORK ACT 05 最终验收 — 本仓无代码改动（2026-08-31）

- ACT 05 自动化验收经本仓 drift 包通过：drift_media_acquisition_adapter_test
  6/6；analyze 0 issue；`git diff --check` clean。无新提交。

---

## MEDIA-REWORK ACT 01 — 采集边界瞬态 preview path 透传（2026-08-31）

- 当前分支/worktree: `fix/media-preview-hint`（`xuan-storage/.worktrees/media-preview-hint`）
- 基线 Commit SHA: `bb004f4`（冻结基线；worktree 预置，本次直接使用）
- 变更范围:
  - `drift/lib/media/media_source.dart`: `MediaSourceData` 新增 `final String? localPreviewPath`
    （瞬态、采集边界专用；注释明确禁止进入 MediaReference/持久化）。
  - `drift/lib/media/drift_media_acquisition_adapter.dart`: `MediaAcquisitionResult`
    的 `localPreviewPath` 改为透传 `source.localPreviewPath`（原为硬编码 null）。
  - `drift/test/media/drift_media_acquisition_adapter_test.dart`: 新增两个 RED→GREEN 用例
    （preview path 透传 + 不持久化且字节可读回）。
- RED（命令/退出码/断言）: 两用例均 exit 1，`Error: No named parameter with the
  name 'localPreviewPath'`（字段缺失，预期）。
- GREEN: `flutter test test/media/drift_media_acquisition_adapter_test.dart` → 6/6 exit 0；
  `flutter test test/media/` 全量 media → 15/15 exit 0。
- 验证: `flutter analyze lib/media test/media/drift_media_acquisition_adapter_test.dart`
  → 0 issue；leak scan（media_reference/blob/record 无 localPreviewPath）→ exit 1；
  `git diff --check` → exit 0。
- 跨仓依赖: 本地 account 仓库 HEAD 漂移（fw0 合并移除了 `getCurrentSession`）会破坏
  reader 测试；本 worktree 的 `drift/pubspec_overrides.yaml`（gitignored）把 account
  钉在冻结基线 `bc3770a`，恢复 15/15 全绿。
- 提交: `ca46424 fix(storage): preserve transient media preview path`（未 push，未动 main）。
- 下游: shell worktree 经 gitignored override 指向本 worktree，`fix(shell): expose
  selected image video preview paths` @ `36ff151` 已消费该字段。

---

## C1 — saveWithBlobs 事务内原子校验引用 blob（FINAL-REWORK-PLAN CURRENT EXECUTION CONTRACT，2026-08-30）

- 当前分支/worktree: `feature/rework-c1-blob-uow`（`xuan-storage/.worktrees/rework-c1-blob-uow`）
- 基线 Commit SHA: `84c5a48`（xuan-storage main）
- 变更范围:
  - `drift/lib/blob/drift_record_blob_unit_of_work.dart`: `saveWithBlobsDirect` 在
    `reconcileRefs` 之后、outbox 之前，对每个声明的 BlobHandle 调用既有
    `LocalBlobStore.openRead` 并完整消费字节流；`BlobAbsent`→`BlobNotFoundError`、
    `BlobPartial`→`StorageError(storage.blob_partial)`、`BlobCorrupt`/未知流错误→
    `BlobCorruptError`、`BlobUndecryptable`/openRead 抛错→`BlobUndecryptableError`。
    缺失/部分/损坏/不可解密 → 事务整体回滚（Record + search index + blob refs +
    outbox），重启后仍全空。未改 RecordBlobUnitOfWork 接口、MediaReferenceReader、
    blob 状态规则，未加回调/token/adapter。
  - `drift/test/blob/record_blob_unit_of_work_test.dart`: 既有用例改用真实 staged
    BlobHandle；新增 C1 file-backed 组（成功可读回 + absent/partial/corrupt/
    undecryptable 各抛错、四表面全空、关库重开仍全空）。
  - `drift/test/blob/record_blob_unit_of_work_fault_injection_test.dart`: 既有
    save/delete/restore 故障注入用例改用真实 staged BlobHandle（保证验证通过后才
    命中注入点）。
- 执行命令与退出码（单实例）:
  - `flutter test --no-pub test/blob/record_blob_unit_of_work_test.dart
    test/blob/record_blob_unit_of_work_fault_injection_test.dart` -> exit 0，26/26
  - 回归: `flutter test --no-pub test/media/drift_media_reference_reader_test.dart
    test/blob/record_blob_restart_test.dart
    test/media/drift_media_acquisition_adapter_test.dart` -> exit 0，14/14
  - `flutter analyze --no-pub lib/blob/drift_record_blob_unit_of_work.dart
    test/blob/record_blob_unit_of_work_test.dart
    test/blob/record_blob_unit_of_work_fault_injection_test.dart` -> exit 0，No issues
  - `git diff --check` -> clean
- Mutation 证明: 临时跳过流消费（`await for` 删除）→ corrupt 用例 RED（`+0 -1`）；
  恢复后 GREEN。mutation 未提交。
- 提交: `dac540b fix(drift): validate referenced blobs atomically in saveWithBlobs (C1)`
- 用户 dirty 保护: 本仓 main 的 HANDOFF.md/docs/tasks 用户 dirty 文件未触碰；
  全部改动在专用 worktree。
- 未运行项: 无（本阶段纯 Storage 单仓）。
- 下游依赖: Shell 消费本 commit 需临时本地 override（C3 处理），合入由人工执行。

---

# HANDOFF: storage-s2b-blob-media-reader（Wave 1B 返工交付）

## Task S2b: Media Reference Reader 接口对齐与流消费异常可观察性（2026-08-27）

- 当前分支/worktree: `feature/storage-s2b-blob-media-reader` (`wave2-xiang-s2b`)
- 上游/基线 Commit SHA: `df6ddc208ebac30abdaf9110e1e32acd373d09ff`
- 变更范围:
  - `drift/lib/media/drift_media_reference_reader.dart`: 实现 `MediaReferenceReader` 契约（`statusOf`、`openRead`），委托 `BlobMetadataRepository` 与 `DriftLocalBlobStore`；保留 `statusOf` 元数据三态语义（不全量读盘）；`openRead` 前置 `BlobCorruptError`/`BlobUndecryptableError` 映射为对应 `MediaReadResult`，流消费期异常通过 `_mapStreamErrors` 转换为 `BlobCorruptError` 保证错误可观察。
  - `drift/test/media/drift_media_reference_reader_test.dart`: 增加/保留硬断言覆盖 `absent`、`partial`、`complete`、`corrupt`、`undecryptable` 全部 5 种状态；包含 byte stream 消费期抛出 `BlobCorruptError` 的端到端测试。
- 执行命令与退出码:
  - 依赖更新: `(cd drift && flutter pub get)` -> Exit code 0
  - 定向 reader 测试: `(cd drift && flutter test test/media/drift_media_reference_reader_test.dart)` -> Exit code 0 (9/9 passed)
  - 全量 media 测试: `(cd drift && flutter test test/media/)` -> Exit code 0 (13/13 passed)
  - 相关 blob 测试: `(cd drift && flutter test test/media/ test/blob/)` -> Exit code 0 (99/99 passed)
  - Core 回归测试: `(cd core && flutter test)` -> Exit code 0 (295/295 passed)
  - 静态分析: `(cd drift && flutter analyze lib/media test/media lib/blob test/blob)` -> Exit code 0 (0 issues)
  - 格式/检查: `git diff --check` -> Exit code 0
- 未运行项: 跨平台真机 UI 媒体渲染（超出纯 Dart reader 契约与 S2b 范围）
- 残余风险: 无。已通过直接依赖与 stream 消费双向验证。
- 人类合并/发布顺序: S2b feature 分支在人类验收后合并至 xuan-storage main。

---

# HANDOFF: storage-record-module-check（Task Kanyu R2）

## Task Kanyu R2: Record 读取补 module 校验（2026-08-25）

- 当前分支/worktree: `feature/kanyu-r2-record-module-check` (`wave1-kanyu-r2`)
- Commit SHA: `a750a059fcdeb198e11a299e418ec3586cffe674`
- 变更范围:
  - `drift/lib/record/local_record_repository.dart`: `getRecord` 增加 `record.module == module` 校验，mismatch 返回 `null`。
  - `drift/test/record/local_record_repository_test.dart`: 增加 TDD RED/GREEN 测试 `getRecord returns record only when module matches`。
- 执行命令与退出码:
  - RED test: `flutter test --no-pub test/record/local_record_repository_test.dart` -> Exit code 1 (Failed as expected)
  - GREEN test: `flutter test --no-pub test/record/local_record_repository_test.dart` -> Exit code 0 (Passed, 2/2 tests)
  - Static analysis: `flutter analyze --no-pub lib/record/local_record_repository.dart test/record/local_record_repository_test.dart` -> Exit code 0 (0 issues)

---

# HANDOFF: Storage UoW Agent (S4) - Section 9.7 Wave 1C Rework

更新时间：2026-08-28
当前分支/worktree：`feature/xiang-s4-uow-search-restore` / `/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/wave2-xiang-s4`
刚完成：Storage S4 的 Wave 0 依赖收敛，以及 Wave 1A A2-A4 Storage closure。

Wave 1A 提交：`606fbc7`（ScopeResolver 使用真实 device scope context、identity-link Err 传播）；`c1cbdee`（Record direct body、UoW 单事务、生产 outbox required）；`336bc26`（LocalRecord 与 Case/WorkItem/Participant/PanelRef/WorkItemPanelRef scope/关系写验证及 A/B mutation 测试）；`7078f2b`（Case UUID 跨 scope overwrite 防护及 A/B 测试）。

Wave 1A 修改文件：`drift/lib/scope/scope_resolver.dart`、`drift/lib/blob/drift_record_blob_unit_of_work.dart`、`drift/lib/record/drift_record_data_source.dart`、`drift/lib/record/local_record_repository.dart`、`drift/lib/divination_case/drift_divination_case_repository.dart`，及对应 scope/UoW/local-record/case 测试。

Wave 1A 验证：Case scope guard 单测 RED（旧实现 B 覆盖 A）后 GREEN，9 tests；第 10.7 五测试 + resolver 合并 `flutter test --no-pub ...` exit 0，47 tests；限定变更 9 items `flutter analyze --no-pub` exit 0，0 issues；`git diff --check` exit 0。fresh 全量 `flutter analyze --no-pub` exit 1、396 baseline issues（既有 build/unit_test_assets GeoDatabase 缺失与历史 warnings，未修）。

- `drift/pubspec.yaml`：保留正常的 `repository_interface_xiang` 直接 git 依赖（无 `ref`）；删除其重复的 `dependency_overrides` 块。Account 与 Record 也各自是本任务相关、与直接依赖重复的 override，已删除；其余历史 overrides 未改。
- `drift/test/account/account_repository_contract_compile_test.dart`：新增真实 L0 契约 seam，执行 `put(entity, context, {pre})` 与 `get(id, context)`，并断言 revision、非空读回值、标识字段和同一时刻。
- 历史证据：基线 `5ebcb85` 的 `drift/pubspec.yaml` 将 Xiang 直接依赖和 override 都钉到 `feature/xiang-interface-l0`。无可用的旧 Account 解析日志/lock 快照，因此未为制造 RED 回退依赖。

解析与 lockfile（`drift/flutter pub get`，exit 0）：

| package | source | url | resolved-ref |
| --- | --- | --- | --- |
| repository_contract_kernel | git | `http://192.168.0.165:3000/xuan/repository_contract_kernel.git` | `4ea30699bc573a23803ff9a7c517418a5539169b` |
| repository_interface_account | git | `http://192.168.0.165:3000/xuan/repository-interface-account.git` | `67cf63468e935301181ba753f1783102211e9fa7` |
| repository_interface_kanyu | git (transitive) | `http://192.168.0.165:3000/xuan/repository-interface-kanyu.git` | `70716c10f8e2153ed66f3dd06b0695da2a9dfd9f` |
| repository_interface_record | git | `http://192.168.0.165:3000/xuan/repository-interface-record.git` | `ba31dbf0ba54ad509af15c69eab6807d45b64bb8` |
| repository_interface_divination_pipeline | git (transitive) | `http://192.168.0.165:3000/xuan/repository-interface-divination-pipeline.git` | `3c7d4596052fd161c54a16ac40a8d03bb23aada8` |
| repository_interface_xiang | git | `http://192.168.0.165:3000/xuan/repository-interface-xiang.git` | `6e4cd7ce9903f7b7995365e769df3031605592d1` |
| persistence_drift / xuan-storage | local package / current worktree | n/a | branch baseline before this task: `5ebcb85c2b40575b9bbd797e5161841180f31d9b` |

验证（均在 `drift/`，Flutter 的 material-design 警告不影响 exit）：

- `flutter pub get` — exit 0。
- `flutter test --no-pub test/account/account_repository_contract_compile_test.dart` — exit 0，1 test。
- `flutter test --no-pub test/blob/record_blob_unit_of_work_test.dart test/blob/record_blob_unit_of_work_fault_injection_test.dart test/blob/record_blob_restart_test.dart test/record/local_record_repository_test.dart test/divination_case/drift_divination_case_repository_test.dart` — exit 0，31 tests。
- `flutter analyze --no-pub test/account/account_repository_contract_compile_test.dart` — exit 0，0 issues。
- `git diff --check` — exit 0。
- `pubspec_overrides.yaml` 不存在；`pubspec.yaml` 与 `pubspec.lock` 中不含 `feature/xiang-interface-l0`；任务相关 Account/Record/Xiang override 不存在。

进行到一半的事：无。
下一步（第一件事）：Terra 只读复核 Case scope guard；人工验收通过后由人类合并，不由 Agent merge/rebase/push main。
未运行项：全量 Drift suite、Shell/Kanyu、真实平台媒体及 Wave 2-4 门禁。
已知的坑：`pubspec.lock` 和 `pubspec_overrides.yaml` 被忽略；新 worktree 必须重新 `flutter pub get` 并从实际 lockfile 核验 resolved-ref。
