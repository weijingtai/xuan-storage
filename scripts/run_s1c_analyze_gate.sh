#!/usr/bin/env bash
# S1c 静态分析门禁（三段式，覆盖 core / drift 两个包）
#
# 为什么不能直接用全包 analyze：
#   仓库开工前基线（main 分支）全包 analyze 就是红的 —— core 59 条（含
#   four_zhu_card_templates 孤儿模块、pubspec http 协议等既有断点）、
#   drift 146 条（既有 WARNING/INFO lint）。这些是既有代码的挂账问题，
#   不属于 S1c，S1c 无权修既有文件。
#
# 本门禁改判三件事（严格程度不降反升）：
#   [1] S1c 新增/重写的文件必须零 issue（--fatal-infos，含 INFO）
#   [2] 有 issue 的文件集合必须是冻结白名单的子集 —— 防止把断点挪到新文件
#   [3] 全包 issue 总数不得超过冻结基线 —— 防止在既有文件里新增问题
#
# 兼容性：必须能在 macOS 自带 /bin/bash 3.2.57 下运行，只能使用基础 for 循环与字符串处理。

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CORE="$ROOT/core"

# ── 前置断言：本 worktree 必须已解析过依赖 ──
if [ ! -f "$CORE/.dart_tool/package_config.json" ]; then
  echo "❌ 前置失败: 未找到 $CORE/.dart_tool/package_config.json"
  echo "   本 worktree 还没解析过依赖，此时跑 analyze 得到的全是假 issue。"
  echo "   先执行: (cd \"$CORE\" && flutter pub get)"
  exit 2
fi

# ── 冻结基线（2026-08-06 实测，S1c 开工前；与 S1b 门禁同口径）──
# 注：core 57 = S1c 开工前 59 减 2（S1c 改动 transport_contract_test.dart
# 等既有文件后总数下降，已同步下调基线）。
BASELINE_TOTAL_CORE=57
BASELINE_TOTAL_DRIFT=146

# ── S1c 拥有的文件（检查 1 的 scoped analyze 对象）──
# 这些文件出现任何 issue 都算失败。含本任务新增的全部库文件与测试文件。
S1C_FILES='
core/lib/model/reconciliation.dart
core/lib/model/reconciliation_ports.dart
core/lib/core/reconciliation_coordinator.dart
core/lib/sync/manifest_comparator.dart
core/lib/sync/reconciliation_trigger.dart
core/lib/test_support/reconciliation_contract_suite.dart
core/lib/persistence_core.dart
core/test/s1c_manifest_comparator_test.dart
core/test/s1c_peer_denial_test.dart
core/test/s1c_reconciliation_coordinator_test.dart
core/test/s1c_reconciliation_trigger_test.dart
core/test/transport_contract_test.dart
drift/lib/sync/record_reconciliation_applier.dart
drift/lib/sync/entity_stamp_manifest_source.dart
drift/test/sync/record_reconciliation_applier_test.dart
drift/test/sync/entity_stamp_manifest_source_test.dart
'

# ── 允许存在 issue 的既有文件白名单（相对 ROOT）──
# 与 S1b 门禁的 BASELINE_FILES 并集 + drift/firebase 的既有断点文件。
# 冻结于 2026-08-06。core 增加 pubspec.yaml（http 协议 2 条既有 info）。
BASELINE_FILES_CORE='
lib/datasource/loca_binary/world_country_repository.dart
lib/four_zhu_card_templates/layout_template_local_data_source.dart
lib/four_zhu_card_templates/layout_template_repository_impl.dart
lib/model/calculation_strategy_config_data_model.dart
lib/model/datetime_details_bundle_data_model.dart
lib/model/lunar_date_info_v2_data_model.dart
pubspec.yaml
test/synced_divination_case_repository_test.dart
'
BASELINE_FILES_DRIFT='
  lib/account/account.dart
  lib/account/account_database.dart
  lib/ai/daos/ai_provenances_dao.dart
  lib/ai/daos/prompt_versions_dao.dart
  lib/daos/divination_panel_mappers_dao.dart
  lib/daos/divination_sub_divination_type_mappers_dao.dart
  lib/daos/divination_types_dao.dart
  lib/daos/panel_skill_class_mappers_dao.dart
  lib/daos/panels_dao.dart
  lib/daos/skill_classes_dao.dart
  lib/daos/skills_dao.dart
  lib/daos/timing_divinations_dao.dart
  lib/decision_links/inference_engine.dart
  lib/divination_case/creation_audit_logs_dao.dart
  lib/divination_case/creation_audit_logs_table.dart
  lib/divination_case/drift_divination_case_repository.dart
  lib/four_zhu_card_templates/app_database.dart
  lib/four_zhu_card_templates/four_zhu_tables.dart
  lib/four_zhu_card_templates/layout_template_local_data_source.dart
  lib/four_zhu_card_templates/models/layout_template.dart
  lib/meihuayishu/dictionary_database_connection_native.dart
  lib/meihuayishu/drift_meihua_divination_record_repository.dart
  lib/meihuayishu/meihua_database_connection_native.dart
  lib/qizhengsiyu/qizheng_record_codec.dart
  lib/record/local_record_repository.dart
  lib/scope/drift_scope_ledger.dart
  lib/sync/record_outbox_mapper.dart
  lib/sync/record_sync_config.dart
  pubspec.yaml
  test/ai/drift_ai_chat_history_test.dart
  test/bazi/record_backed_bazi_repository_test.dart
  test/decision_links/fork_engine_test.dart
  test/decision_links/inference_engine_test.dart
  test/decision_links/merge_engine_test.dart
  test/divination_case/drift_divination_case_repository_test.dart
  test/divination_tag/drift_tag_dimension_repository_test.dart
  test/drift_sync_state_store_test.dart
  test/qizhengsiyu/qizheng_record_codec_spacetime_test.dart
  test/record/codec_search_tag_wiring_test.dart
  test/record/daliuren_record_codec_test.dart
  test/record/drift_record_data_source_sorting_test.dart
  test/record/liuyao_record_codec_test.dart
  test/record/meihua_record_migration_test.dart
  test/record/qimendunjia_record_codec_test.dart
  test/record/qizhengsiyu_record_codec_test.dart
  test/record/record_backed_daliuren_repository_test.dart
  test/record/record_backed_liuyao_repository_test.dart
  test/record/record_backed_qimendunjia_repository_test.dart
  test/record/record_backed_qizhengsiyu_repository_test.dart
  test/record/record_backed_taiyishenshu_repository_test.dart
  test/record/record_backed_tiebanshenshu_repository_test.dart
  test/record/record_backed_ziweidoushu_repository_test.dart
  test/record/record_module_registry_test.dart
  test/record/taiyishenshu_record_codec_test.dart
  test/record/tiebanshenshu_record_codec_test.dart
  test/record/ziweidoushu_record_codec_test.dart
  test/scope/drift_scope_ledger_test.dart
  test/scope/scope_end_to_end_test.dart
  test/seeker/case_participant_seeker_test.dart
  test/seeker/seeker_e2e_test.dart
  test/seeker/seeker_migration_test.dart
  test/seeker/seeker_record_codec_test.dart
  test/sync/record_outbox_mapper_test.dart
  test/sync/record_remote_gateway_test.dart
  test/sync/record_sync_state_test.dart
  test/taiyishenshu/taiyi_user_school_repository_test.dart
  test/xiang/xiang_reading_repository_impl_test.dart
'

fail=0

# ── 通用函数：scoped analyze（检查 1）──
check_scoped() {
  local pkg="$1"
  local dir="$2"
  shift 2
  local files="$*"
  [ -z "$files" ] && return 0
  # shellcheck disable=SC2086
  (cd "$dir" && dart analyze --fatal-infos --suppress-analytics $files) >/tmp/s1c_scoped.log 2>&1
  local ec
  ec=$?
  if [ "$ec" -ne 0 ]; then
    echo "❌ [检查1/$pkg] S1c 文件存在 issue（退出码 ${ec}），必须全部为零："
    cat /tmp/s1c_scoped.log
    fail=1
  else
    echo "✅ [检查1/$pkg] scoped analyze 零 issue"
  fi
}

# ── 通用函数：全包分析 + 白名单子集 + 总数（检查 2/3）──
check_pkg() {
  local pkg="$1"
  local dir="$2"
  local baseline_total="$3"
  local baseline_files="$4"

  # shellcheck disable=SC2164
  (cd "$dir" && dart analyze --format=machine --suppress-analytics) >/tmp/s1c_full.log 2>&1

  # ⚠ 报备豁免（S2 返工 P0-3 复验，2026-08-06，与 S1a/S1b 门禁同口径）：
  #   **host 白名单，非整类过滤**。仅豁免内网白名单 host 192.168.0.165 上
  #   repository-interface-playground.git 的 http url（S2 新增依赖；内网 gitea
  #   无 https、ssh 需 key、path 依赖与 taiyishenshu 等 git 包结构性冲突，
  #   均实测不可行）。main 合并后 core/drift 的 pubspec.yaml 均含该 url，
  #   本门禁与 S1a/S1b 同步豁免口径，基线保持 57/146 不调低。
  local ALLOWED_HOST="192.168.0.165"
  local EXEMPT_RE=""
  while IFS= read -r LN; do
    local LINE_NO="${LN%%:*}"
    local URL_LINE="${LN#*:}"
    case "$URL_LINE" in
      *"$ALLOWED_HOST"*repository-interface-playground.git*)
        if [ -z "$EXEMPT_RE" ]; then EXEMPT_RE="$LINE_NO"; else EXEMPT_RE="$EXEMPT_RE|$LINE_NO"; fi ;;
    esac
  done < <(grep -nE 'url: http' "$dir/pubspec.yaml")

  if [ -n "$EXEMPT_RE" ]; then
    grep -E '^(ERROR|WARNING|INFO)\|' /tmp/s1c_full.log \
      | grep -vE "^[A-Z]+\|[A-Z]+\|SECURE_PUBSPEC_URLS\|[^|]*pubspec\.yaml\|($EXEMPT_RE)\|" \
      > /tmp/s1c_filtered.log
  else
    grep -E '^(ERROR|WARNING|INFO)\|' /tmp/s1c_full.log > /tmp/s1c_filtered.log
  fi

  local total
  total=$(grep -cE '^(ERROR|WARNING|INFO)\|' /tmp/s1c_filtered.log)

  # 抽出现 issue 的文件（相对 ROOT），去重
  grep -E '^(ERROR|WARNING|INFO)\|' /tmp/s1c_filtered.log \
    | awk -F'|' '{print $4}' \
    | sed "s#^$ROOT/##" \
    | sort -u >/tmp/s1c_files.txt

  local pkg_fail=0

  # 检查 2：文件集合必须是白名单子集
  while IFS= read -r F; do
    [ -z "$F" ] && continue
    HIT=0
    while IFS= read -r B; do
      B="$(echo "$B" | tr -d '[:space:]')"
      [ -z "$B" ] && continue
      # 白名单是相对 pkg 的，转成相对 ROOT 比较
      local broot="$pkg/$B"
      if [ "$F" = "$broot" ]; then HIT=1; break; fi
    done <<EOF
$baseline_files
EOF
    if [ "$HIT" -eq 0 ]; then
      echo "❌ [检查2/$pkg] 白名单外的文件出现 issue：$F"
      grep -E "^(ERROR|WARNING|INFO)\|[^|]*\|[^|]*\|$ROOT/$pkg/$F\|" /tmp/s1c_full.log 2>/dev/null | head -5
      pkg_fail=1
    fi
  done </tmp/s1c_files.txt

  if [ "$pkg_fail" -eq 0 ]; then
    echo "✅ [检查2/$pkg] 有 issue 的文件均在冻结白名单内"
  fi

  # 检查 3：总数不得超过基线
  if [ "$total" -gt "$baseline_total" ]; then
    echo "❌ [检查3/$pkg] 全包 issue 总数 $total 超过冻结基线 $baseline_total"
    pkg_fail=1
  elif [ "$total" -lt "$baseline_total" ]; then
    echo "✅ [检查3/$pkg] 全包 issue 总数 $total < 基线 ${baseline_total}（请同步下调基线）"
  else
    echo "✅ [检查3/$pkg] 全包 issue 总数 $total = 基线 $baseline_total"
  fi

  [ "$pkg_fail" -ne 0 ] && fail=1
}

echo "═══ S1c 静态分析门禁 ═══"

# ── core ──
echo "── core ──"
CORE_FILES=""
while IFS= read -r F; do
  F="$(echo "$F" | tr -d '[:space:]')"
  [ -z "$F" ] && continue
  case "$F" in core/*)
    CORE_FILES="$CORE_FILES $(echo "$F" | sed 's#^core/##')"
  esac
done <<EOF
$S1C_FILES
EOF
# shellcheck disable=SC2086
check_scoped core "$CORE" $CORE_FILES
check_pkg core "$CORE" "$BASELINE_TOTAL_CORE" "$BASELINE_FILES_CORE"

# ── drift ──
echo "── drift ──"
DRIFT_FILES=""
while IFS= read -r F; do
  F="$(echo "$F" | tr -d '[:space:]')"
  [ -z "$F" ] && continue
  case "$F" in drift/*)
    DRIFT_FILES="$DRIFT_FILES $(echo "$F" | sed 's#^drift/##')"
  esac
done <<EOF
$S1C_FILES
EOF
# shellcheck disable=SC2086
check_scoped drift "$ROOT/drift" $DRIFT_FILES
check_pkg drift "$ROOT/drift" "$BASELINE_TOTAL_DRIFT" "$BASELINE_FILES_DRIFT"

echo "———"
if [ "$fail" -eq 0 ]; then
  echo "✅ S1c 静态分析门禁通过"
  exit 0
else
  echo "❌ S1c 静态分析门禁未通过"
  exit 1
fi
