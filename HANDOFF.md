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
