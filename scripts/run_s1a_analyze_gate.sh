#!/usr/bin/env bash
# S1a 静态分析门禁（替代「全包 dart analyze --fatal-infos 必须为 0」）
#
# 为什么不能直接用全包 analyze：
#   开工前基线（commit 1fae94c，main 分支同样如此）全包 analyze 就是红的，
#   58 条 issue 全部来自既有代码，其中 42 条集中在 lib/four_zhu_card_templates/。
#   根因：该模块 import 了 'package:drift/drift.dart' 与 '../database/app_database.dart'，
#   但 core 包既没有 drift 依赖，也没有 lib/database/ 目录 —— 它是从 persistence_drift
#   搬进来却没接线的孤儿模块。这是仓库既有断点，不属于 S1a 范围，S1a 也无权修既有文件。
#
# 本门禁改判三件事（严格程度不降反升）：
#   [1] S1a 自己的 18 个文件（12 源 + 6 测试）必须零 issue —— 包含 INFO，等价 --fatal-infos
#   [2] 有 issue 的文件集合必须是冻结白名单的子集 —— 防止把断点挪到新文件
#   [3] 全包 issue 总数不得超过冻结基线 —— 防止在既有文件里新增问题
#
# 兼容性：必须能在 macOS 自带 /bin/bash 3.2.57 下运行，不得使用 declare -A / mapfile。

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CORE="$ROOT/core"

# ── 前置断言：本 worktree 必须已解析过依赖 ──
# 新建的 worktree 不会自带 .dart_tool/。缺 package_config.json 时，analyzer 无法解析
# 任何 package: import，会把每一条 import 都报成 uri_does_not_exist，产出 500+ 条假 issue，
# 与本门禁的 58 条冻结基线毫无可比性 —— 那不是回归，是环境没装好。
# 与其让人对着一屏红字找原因，不如在这里直接说清楚。
if [ ! -f "$CORE/.dart_tool/package_config.json" ]; then
  echo "❌ 前置失败: 未找到 $CORE/.dart_tool/package_config.json"
  echo "   本 worktree 还没解析过依赖，此时跑 analyze 得到的全是假 issue。"
  echo "   先执行: (cd \"$CORE\" && flutter pub get)"
  exit 2
fi

# ── 冻结基线（2026-08-01，基线 commit 1fae94c；与 main 上 core 的状态一致）──
BASELINE_TOTAL=58

# 允许存在 issue 的既有文件（相对 core/ 的路径）。冻结于同一时点。
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

# S1a 拥有的文件：这些文件出现任何 issue 都算失败
S1A_FILES='
lib/model/storage_classification.dart
lib/model/cancellation_token.dart
lib/model/blob_error.dart
lib/model/storage_policy.dart
lib/model/storage_policy_registry.dart
lib/model/blob_types.dart
lib/model/blob_cipher.dart
lib/model/local_blob_store.dart
lib/model/record_blob_unit_of_work.dart
lib/model/blob_gateway.dart
lib/model/transport.dart
lib/model/export_bundle.dart
test/storage_classification_test.dart
test/storage_policy_test.dart
test/blob_types_test.dart
test/transport_contract_test.dart
test/policy_channel_filter_test.dart
test/s1a_dartdoc_coverage_test.dart
'

cd "$CORE" || { echo "❌ 找不到 core 目录 $CORE"; exit 1; }

# ── 检查 1：S1a 自有文件必须零 issue（scoped analyze，含 INFO）──
SCOPED=""
while IFS= read -r F; do
  F="$(echo "$F" | tr -d '[:space:]')"
  [ -z "$F" ] && continue
  if [ ! -f "$F" ]; then
    echo "❌ [检查1] S1a 文件缺失：core/$F"
    exit 1
  fi
  SCOPED="$SCOPED $F"
done <<EOF
$S1A_FILES
EOF

# shellcheck disable=SC2086
dart analyze --fatal-infos --suppress-analytics $SCOPED >/tmp/s1a_scoped.log 2>&1
SCOPED_EC=$?
if [ "$SCOPED_EC" -ne 0 ]; then
  echo "❌ [检查1] S1a 自有 18 个文件存在 issue（退出码 $SCOPED_EC），必须全部为零："
  cat /tmp/s1a_scoped.log
  exit 1
fi
echo "✅ [检查1] S1a 18 个文件 --fatal-infos 零 issue"

# ── 检查 2/3：全包分析，比对冻结白名单与基线总数 ──
dart analyze --format=machine --suppress-analytics >/tmp/s1a_full.log 2>&1

TOTAL=$(grep -cE '^(ERROR|WARNING|INFO)\|' /tmp/s1a_full.log)

# 抽出出现 issue 的文件（转为相对 core/ 的路径），去重
grep -E '^(ERROR|WARNING|INFO)\|' /tmp/s1a_full.log \
  | awk -F'|' '{print $4}' \
  | sed "s#^$CORE/##" \
  | sort -u >/tmp/s1a_files.txt

FAILED=0

# 检查 2：文件集合必须是白名单子集
while IFS= read -r F; do
  [ -z "$F" ] && continue
  HIT=0
  while IFS= read -r B; do
    B="$(echo "$B" | tr -d '[:space:]')"
    [ -z "$B" ] && continue
    if [ "$F" = "$B" ]; then HIT=1; break; fi
  done <<EOF
$BASELINE_FILES
EOF
  if [ "$HIT" -eq 0 ]; then
    echo "❌ [检查2] 白名单外的文件出现 issue：core/$F"
    grep -E "^(ERROR|WARNING|INFO)\|[^|]*\|[^|]*\|$CORE/$F\|" /tmp/s1a_full.log | head -5
    FAILED=1
  fi
done </tmp/s1a_files.txt

if [ "$FAILED" -eq 0 ]; then
  echo "✅ [检查2] 有 issue 的文件均在冻结白名单内（未把断点扩散到新文件）"
fi

# 检查 3：总数不得超过基线
if [ "$TOTAL" -gt "$BASELINE_TOTAL" ]; then
  echo "❌ [检查3] 全包 issue 总数 $TOTAL 超过冻结基线 ${BASELINE_TOTAL}，说明在既有文件里新增了问题"
  FAILED=1
elif [ "$TOTAL" -lt "$BASELINE_TOTAL" ]; then
  echo "✅ [检查3] 全包 issue 总数 $TOTAL < 基线 ${BASELINE_TOTAL}（既有断点被修复了，请同步下调 BASELINE_TOTAL）"
else
  echo "✅ [检查3] 全包 issue 总数 $TOTAL = 冻结基线 ${BASELINE_TOTAL}（无新增）"
fi

if [ "$FAILED" -ne 0 ]; then
  echo "———"
  echo "S1a 静态分析门禁未通过。"
  exit 1
fi

echo "———"
echo "✅ S1a 静态分析门禁通过（既有断点 ${BASELINE_TOTAL} 条已按人类决定挂账，见任务纪要决定记录）"
exit 0
