#!/usr/bin/env bash
# S1c 门禁负测试：注入变异 → 门禁必须红 → 还原 → 门禁必须绿。
#
# 为什么要这条：A8 变异自检要求「注入变异后必须红在目标断言上」。
# 本脚本验证 S1c 门禁的三个检查确实各自能拦：
#   [注入1] 在 S1c 文件注入 unused 字段（warning）→ 检查3（总数超基线）红
#   [注入2] 在 S1c 文件注入 unused import（INFO）→ 检查1（scoped 零 issue）红
# 还原后门禁必须全绿（证明绿不是蒙的）。

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GATE="$ROOT/scripts/run_s1c_analyze_gate.sh"
TARGET="$ROOT/core/lib/sync/manifest_comparator.dart"
BAK="/tmp/s1c_manifest_comparator.bak"

cp "$TARGET" "$BAK"

fail=0

echo "═══ S1c 门禁负测试 ═══"

# ── 注入 1：unused field（warning）→ 检查3 总数超基线应红 ──
python3 - <<EOF
s = open("$TARGET").read()
s = s.replace(
  "  @override\n  ManifestComparatorDecision classifyLocalEntry({",
  "  final int _mutateUnused = 1;\n  @override\n  ManifestComparatorDecision classifyLocalEntry({",
)
open("$TARGET", "w").write(s)
EOF

"$GATE" >/tmp/s1c_gate_mut1.log 2>&1
M1=$?
cp "$BAK" "$TARGET"
if [ "$M1" -ne 0 ]; then
  echo "✅ [注入1] unused field 变异被门禁拦下（exit ${M1}）"
else
  echo "❌ [注入1] unused field 变异未被门禁拦下（exit 0）"
  fail=1
fi

# ── 注入 2：unused import（INFO）→ 检查1 scoped 零 issue 应红 ──
python3 - <<EOF
s = open("$TARGET").read()
s = s.replace(
  "import 'package:persistence_core/model/conflict_arbiter.dart';",
  "import 'package:persistence_core/model/conflict_arbiter.dart';\nimport 'package:persistence_core/model/conflict_arbiter.dart' as _dup;",
)
open("$TARGET", "w").write(s)
EOF

"$GATE" >/tmp/s1c_gate_mut2.log 2>&1
M2=$?
cp "$BAK" "$TARGET"
if [ "$M2" -ne 0 ]; then
  echo "✅ [注入2] unused import 变异被门禁拦下（exit ${M2}）"
else
  echo "❌ [注入2] unused import 变异未被门禁拦下（exit 0）"
  fail=1
fi

# ── 还原后必须全绿 ──
"$GATE" >/tmp/s1c_gate_clean.log 2>&1
CLEAN=$?
if [ "$CLEAN" -eq 0 ]; then
  echo "✅ [还原] 还原后门禁全绿"
else
  echo "❌ [还原] 还原后门禁仍红（exit ${CLEAN}），证明还原不彻底"
  cat /tmp/s1c_gate_clean.log
  fail=1
fi

echo "———"
if [ "$fail" -eq 0 ]; then
  echo "✅ S1c 门禁负测试通过"
  exit 0
else
  echo "❌ S1c 门禁负测试未通过"
  exit 1
fi
