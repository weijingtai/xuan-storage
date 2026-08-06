#!/usr/bin/env bash
# scripts/run_s5a_analyze_gate.sh
# S5a 静态分析门禁，沿用 S1a 三条制（照 scripts/run_s1a_analyze_gate.sh 同形制）。
# 兼容 macOS /bin/bash 3.2.57：不用 declare -A / mapfile。
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CORE="$ROOT/core"
# 前置断言：worktree 必须已 pub get，否则 500+ uri_does_not_exist 假 issue
if [ ! -f "$CORE/.dart_tool/package_config.json" ]; then
  echo "❌ 前置失败: 未找到 $CORE/.dart_tool/package_config.json"
  echo "   先执行: (cd \"$CORE\" && flutter pub get)"
  exit 2
fi
# 基线：开工时实测填入（ACT 07 执行者实测 57，与 S1a 基线一致）。
BASELINE_TOTAL=57
# 允许存在 issue 的既有文件白名单（相对 core/）。开工时实测填入（S1a 那批既有断点，S5a 不新增）。
BASELINE_FILES='
lib/four_zhu_card_templates/layout_template_local_data_source.dart
lib/four_zhu_card_templates/layout_template_repository_impl.dart
pubspec.yaml
lib/model/calculation_strategy_config_data_model.dart
lib/datasource/loca_binary/world_country_repository.dart
lib/model/lunar_date_info_v2_data_model.dart
lib/model/datetime_details_bundle_data_model.dart
lib/sync/sync_runtime.dart
test/synced_divination_case_repository_test.dart
'
# S5a 自有文件（8 契约 + 4 reference + 8 测试 + 2 support）。这些文件出现任何 issue 都算失败。
S5A_FILES='
lib/model/theme_token_types.dart
lib/model/theme_resolution.dart
lib/model/theme_resource_store.dart
lib/model/theme_value_types.dart
lib/model/theme_source_ports.dart
lib/model/theme_storage_policies.dart
lib/model/theme_dataset.dart
lib/model/theme_module_registry.dart
lib/reference/theme_token_merger.dart
lib/reference/in_memory_theme_materializer.dart
lib/reference/in_memory_theme_resource_store.dart
lib/reference/theme_assembly.dart
test/theme_token_merger_test.dart
test/theme_resource_store_contract_test.dart
test/theme_module_registry_test.dart
test/theme_materializer_test.dart
test/theme_startup_path_test.dart
test/theme_merge_bench_test.dart
test/support/theme_probes.dart
test/support/theme_bench_fixture.dart
'
cd "$CORE" || { echo "❌ 找不到 core 目录 $CORE"; exit 1; }
# 检查 1：S5a 自有文件 scoped analyze --fatal-infos 零 issue
SCOPED=""; S5A_COUNT=0
while IFS= read -r F; do
  F="$(echo "$F" | tr -d '[:space:]')"; [ -z "$F" ] && continue
  [ ! -f "$F" ] && { echo "❌ [检查1] S5a 文件缺失：core/$F"; exit 1; }
  SCOPED="$SCOPED $F"; S5A_COUNT=$((S5A_COUNT + 1))
done <<EOF
$S5A_FILES
EOF
# shellcheck disable=SC2086
dart analyze --fatal-infos --suppress-analytics $SCOPED >/tmp/s5a_scoped.log 2>&1
SCOPED_EC=$?
[ "$SCOPED_EC" -ne 0 ] && { echo "❌ [检查1] S5a 自有 $S5A_COUNT 个文件存在 issue"; cat /tmp/s5a_scoped.log; exit 1; }
echo "✅ [检查1] S5a $S5A_COUNT 个文件 --fatal-infos 零 issue"
# 检查 2/3：全包分析，比对冻结白名单与基线总数
dart analyze --format=machine --suppress-analytics >/tmp/s5a_full.log 2>&1
TOTAL=$(grep -cE '^(ERROR|WARNING|INFO)\|' /tmp/s5a_full.log)
grep -E '^(ERROR|WARNING|INFO)\|' /tmp/s5a_full.log | awk -F'|' '{print $4}' | sed "s#^$CORE/##" | sort -u >/tmp/s5a_files.txt
FAILED=0
while IFS= read -r F; do
  [ -z "$F" ] && continue; HIT=0
  while IFS= read -r B; do
    B="$(echo "$B" | tr -d '[:space:]')"; [ -z "$B" ] && continue
    [ "$F" = "$B" ] && { HIT=1; break; }
  done <<EOF
$BASELINE_FILES
EOF
  [ "$HIT" -eq 0 ] && { echo "❌ [检查2] 白名单外的文件出现 issue：core/$F"; FAILED=1; }
done </tmp/s5a_files.txt
[ "$FAILED" -eq 0 ] && echo "✅ [检查2] 有 issue 的文件均在冻结白名单内"
if [ "$TOTAL" -gt "$BASELINE_TOTAL" ]; then
  echo "❌ [检查3] 全包 issue 总数 $TOTAL 超过冻结基线 $BASELINE_TOTAL"; FAILED=1
else
  echo "✅ [检查3] 全包 issue 总数 $TOTAL ≤ 基线 $BASELINE_TOTAL"
fi
[ "$FAILED" -ne 0 ] && { echo "---"; echo "S5a 静态分析门禁未通过"; exit 1; }
echo "---"; echo "✅ S5a 静态分析门禁通过"
exit 0
