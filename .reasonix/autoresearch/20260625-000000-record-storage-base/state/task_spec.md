{
  "task_id": "20260625-000000-record-storage-base",
  "title": "Design reusable Record Storage Base class for divination sub-modules",
  "goal": "Produce a design document at docs/superpowers/specs/2026-06-25-record-storage-base-class-design.md that specifies a reusable BaseRecordBackedRepository<TContract> base class/mixin abstracting common CRUD/watch/search/migration logic shared across xuan-* divination sub-modules.",
  "scope": [
    "Read and analyze all 5 reference groups listed in the task",
    "Identify common vs per-module logic in MeiHua's RecordBackedMeiHuaRepository, adapter, migration",
    "Compare inheritance vs generics+composition approaches",
    "Design generic base with abstract hooks",
    "Design generic key-query mechanism via t_record_search_index",
    "Design reusable migration pattern",
    "Provide new-module onboarding checklist and code snippets",
    "Produce single output: docs/superpowers/specs/2026-06-25-record-storage-base-class-design.md"
  ],
  "non_goals": [
    "Modify any existing code, tests, pubspec.yaml",
    "Modify any sub-module lib/ directories",
    "Refactor MeiHua or other modules",
    "git add -A (only explicitly add the one new document)",
    "Implement anything"
  ],
  "allowed_operations": [
    "Read-only code exploration (read_file, grep, glob, ls, explore, research, lsp_*)",
    "Write only: docs/superpowers/specs/2026-06-25-record-storage-base-class-design.md",
    "Write: .reasonix/autoresearch/20260625-000000-record-storage-base/state/*"
  ],
  "success_criteria": [
    "Design doc exists at specified path",
    "Contains: duplication analysis table comparing MeiHua vs other module ports",
    "Contains: Base class/mixin Dart signatures with abstract hooks clearly identified",
    "Contains: Inheritance vs generics+composition comparison with recommendation",
    "Contains: Generic key-query mechanism design",
    "Contains: Reusable migration pattern design",
    "Contains: New module onboarding checklist with code snippets",
    "Contains: Risk/trade-off analysis"
  ],
  "verification_gates": [
    "Design doc file exists and is valid Markdown",
    "All 7 required sections are present",
    "NEEDS_CONTEXT items listed for any unresolved design decisions"
  ]
}
