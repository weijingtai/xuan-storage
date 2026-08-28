# HANDOFF

更新时间：2026-08-28
当前分支/worktree：`feature/xiang-s4-uow-search-restore` / `/Users/jingtaiwei/Git/Public/xuan-migration/xuan-storage/.worktrees/wave2-xiang-s4`
刚完成：Storage S4 的 Wave 0 依赖收敛，以及 Wave 1A A2-A4 Storage closure。

Wave 1A 提交：`606fbc7`（ScopeResolver 使用真实 device scope context、identity-link Err 传播）；`c1cbdee`（Record direct body、UoW 单事务、生产 outbox required）；`336bc26`（LocalRecord 与 Case/WorkItem/Participant/PanelRef/WorkItemPanelRef scope/关系写验证及 A/B mutation 测试）。

Wave 1A 修改文件：`drift/lib/scope/scope_resolver.dart`、`drift/lib/blob/drift_record_blob_unit_of_work.dart`、`drift/lib/record/drift_record_data_source.dart`、`drift/lib/record/local_record_repository.dart`、`drift/lib/divination_case/drift_divination_case_repository.dart`，及对应 scope/UoW/local-record/case 测试。

Wave 1A 验证：第 10.7 五测试 + resolver 合并 `flutter test --no-pub ...` exit 0，46 tests；限定变更 9 items `flutter analyze --no-pub` exit 0，0 issues；`git diff --check` exit 0。fresh 全量 `flutter analyze --no-pub` exit 1、396 baseline issues（既有 build/unit_test_assets GeoDatabase 缺失与历史 warnings，未修）。

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
下一步（第一件事）：Terra 只读审核当前三个提交；人工验收通过后由人类合并，不由 Agent merge/rebase/push main。
未运行项：全量 Drift suite、Shell/Kanyu、真实平台媒体及 Wave 2-4 门禁。
已知的坑：`pubspec.lock` 和 `pubspec_overrides.yaml` 被忽略；新 worktree 必须重新 `flutter pub get` 并从实际 lockfile 核验 resolved-ref。
