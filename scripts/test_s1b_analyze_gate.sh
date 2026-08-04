#!/bin/bash
# S1b 门禁注入自测：对 run_s1b_analyze_gate.sh 做三次注入，每次都必须让它非 0 退出。
#
# ⚠ 恢复机制必须先写好再写注入。不用 git checkout（恢复不了未跟踪新建文件），
# 用备份文件 + 显式 restore（幂等）。trap 只兜异常，正常路径显式调 restore。
#
# macOS /bin/bash 3.2.57：无 declare -A / mapfile；CREATED_FILES 用空格分隔字符串。

set -euo pipefail

BACKUP_DIR="$(mktemp -d)"
CREATED_FILES=""
BACKED_UP=""
SNAPSHOT_BEFORE="$(git status --porcelain)"
RESTORED=0

backup_file() {
  local f="$1"
  mkdir -p "$BACKUP_DIR"
  cp "$f" "$BACKUP_DIR/$(echo "$f" | tr / _)"
  BACKED_UP="$BACKED_UP $f"
}

restore() {
  [ "$RESTORED" = "1" ] && return 0
  RESTORED=1
  for f in $BACKED_UP; do
    cp "$BACKUP_DIR/$(echo "$f" | tr / _)" "$f"
  done
  for f in $CREATED_FILES; do rm -f "$f"; done
  rm -rf "$BACKUP_DIR"
}

reset_for_next_injection() {
  RESTORED=0
  BACKED_UP=""
  CREATED_FILES=""
}

trap restore EXIT INT TERM

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GATE="$ROOT/scripts/run_s1b_analyze_gate.sh"
TEST_FILE="$ROOT/core/lib/model/conflict_arbiter.dart"

# ── 注入 1：scoped analyze 必须为 0 这一段 ──
# 在 S1b 新增文件末尾追加未使用的私有变量 → 检查1 必须红
backup_file "$TEST_FILE"
echo "" >> "$TEST_FILE"
echo "final _unused = 1;" >> "$TEST_FILE"
if bash "$GATE" >/dev/null 2>&1; then
  echo "❌ 注入1失败：加 unused 变量后门禁仍绿"
  exit 1
fi
echo "✅ 注入1：scoped analyze 段能红"
restore
reset_for_next_injection

# ── 注入 2：白名单子集这一段 ──
# 往【非白名单】文件加 unused import → 检查2 必须红（有 issue 的文件不在白名单）
backup_file "$ROOT/core/lib/model/storage_policy_registry.dart"
echo "import 'dart:async';" >> "$ROOT/core/lib/model/storage_policy_registry.dart"
if bash "$GATE" >/dev/null 2>&1; then
  echo "❌ 注入2失败：白名单外文件出现 issue 后门禁仍绿"
  exit 1
fi
echo "✅ 注入2：白名单子集段能红"
restore
reset_for_next_injection

# ── 注入 3：总数不超基线这一段 ──
# 临时把基线常量改成 0 → 检查3 必须红（实际数超过了"基线"）
backup_file "$GATE"
sed -i '' 's/BASELINE_TOTAL_CORE=57/BASELINE_TOTAL_CORE=0/; s/BASELINE_TOTAL_DRIFT=151/BASELINE_TOTAL_DRIFT=0/; s/BASELINE_TOTAL_FIREBASE=20/BASELINE_TOTAL_FIREBASE=0/' "$GATE"
if bash "$GATE" >/dev/null 2>&1; then
  echo "❌ 注入3失败：把基线改成 0 后门禁仍绿"
  exit 1
fi
echo "✅ 注入3：总数基线段能红"
restore
reset_for_next_injection

# ── trap 自测钩子（常驻，不要删）──
# 默认不设该环境变量时不生效；设了才在第二次注入后自杀，让外层 harness 验 trap。
if [ "${S1B_TRAP_SELFTEST:-0}" = "1" ]; then
  backup_file "$TEST_FILE"
  echo "final _trap_test = 1;" >> "$TEST_FILE"
  exit 3
fi

# 【关键顺序】先显式恢复，再比较快照
restore
SNAPSHOT_AFTER="$(git status --porcelain)"
if [ "$SNAPSHOT_BEFORE" != "$SNAPSHOT_AFTER" ]; then
  echo "❌ 工作树被污染，注入未完全恢复"
  exit 1
fi

echo "✅ A1 门禁自测通过"
exit 0
