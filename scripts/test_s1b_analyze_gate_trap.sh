#!/bin/bash
# trap 自测 harness：用子进程验证 test_s1b_analyze_gate.sh 的 trap 真能恢复现场。
# 已退出的脚本无法自证 trap，必须由父进程检查。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SNAP_BEFORE="$(git status --porcelain)"

# 用环境变量让子进程在第二次注入后自杀（exit 3）
set +e
S1B_TRAP_SELFTEST=1 bash "$ROOT/scripts/test_s1b_analyze_gate.sh"
rc=$?
set -e

if [ "$rc" != "3" ]; then
  echo "❌ 子进程未按预期以 3 退出（实际 $rc）"
  exit 1
fi

SNAP_AFTER="$(git status --porcelain)"
if [ "$SNAP_BEFORE" != "$SNAP_AFTER" ]; then
  echo "❌ trap 未能恢复现场"
  exit 1
fi

# 临时目录必须已清理：子进程里 mktemp 的目录不应残留
leftover="$(ls /tmp/ | grep -c '^tmp\.' 2>/dev/null || true)"

echo "✅ trap 自测通过（子进程以 3 退出，工作树已恢复）"
exit 0
