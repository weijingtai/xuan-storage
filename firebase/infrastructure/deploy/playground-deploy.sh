#!/bin/bash
set -euo pipefail

# ============================================================================
# Playground 部署脚本
#
# 用法: bash playground-deploy.sh --project <staging|production>
#
# 前置: firebase CLI 已登录（firebase login），infrastructure/firebase.json 为 project 配置。
# 说明: 本脚本只部署 Rules/indexes/Functions/Storage，不删除任何用户内容。
# ============================================================================

PROJECT=""
EMULATOR_RULES_TEST="${EMULATOR_RULES_TEST:-auto}" # auto|on|off

usage() {
  echo "用法: bash playground-deploy.sh --project <staging|production>" >&2
  echo "  --project  必填，staging 或 production" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      PROJECT="${2:-}"
      shift 2
      ;;
    --emulator-rules-test)
      EMULATOR_RULES_TEST="${2:-auto}"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "未知参数: $1" >&2
      usage
      ;;
  esac
done

if [[ -z "$PROJECT" ]]; then
  echo "错误: 缺少 --project 参数" >&2
  usage
fi

if [[ "$PROJECT" != "staging" && "$PROJECT" != "production" ]]; then
  echo "错误: --project 必须是 staging 或 production，当前: $PROJECT" >&2
  usage
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INFRA_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FUNCTIONS_DIR="$INFRA_DIR/functions"
CONTRACT_DIR="$(cd "$INFRA_DIR/../../.." && pwd)/repository-interface-playground"

echo "=== Playground Deploy → $PROJECT ==="

# --- Step 1: Contract 测试 ---
echo ""
echo "--- Step 1: Contract 测试 (repository-interface-playground) ---"
if [[ -d "$CONTRACT_DIR" ]]; then
  echo "[cmd] cd $CONTRACT_DIR && dart test"
  (cd "$CONTRACT_DIR" && dart test)
  echo "[ok] Contract 测试通过 (退出码 $?)"
else
  echo "[skip] contract 目录不存在: $CONTRACT_DIR" >&2
fi

# --- Step 2: Functions 编译 + 单元测试 ---
echo ""
echo "--- Step 2: Functions 编译 + 单元测试 ---"
echo "[cmd] cd $FUNCTIONS_DIR && npm run build"
(cd "$FUNCTIONS_DIR" && npm run build)
echo "[ok] Functions 编译通过"

# --- Step 2b: Rules 测试（依赖 emulator，可条件跳过）---
echo ""
echo "--- Step 2b: Rules 测试 (需 emulator) ---"
if [[ "$EMULATOR_RULES_TEST" == "off" ]]; then
  echo "[skip] EMULATOR_RULES_TEST=off，跳过 Rules 测试（--emulator-rules-test off 可跳过）"
elif [[ "$EMULATOR_RULES_TEST" == "on" ]] || curl -s "http://localhost:8082" > /dev/null 2>&1; then
  echo "[cmd] cd $FUNCTIONS_DIR && FIRESTORE_EMULATOR_HOST=localhost:8082 FIREBASE_AUTH_EMULATOR_HOST=localhost:9099 npm test -- firestore.rules"
  (cd "$FUNCTIONS_DIR" && FIRESTORE_EMULATOR_HOST=localhost:8082 FIREBASE_AUTH_EMULATOR_HOST=localhost:9099 npm test -- firestore.rules)
  echo "[ok] Rules 测试通过"
else
  echo "[skip] Firestore Emulator 未运行 (localhost:8082)，跳过 Rules 测试"
  echo "[hint] 先启动: cd $INFRA_DIR/emulator && firebase emulators:start"
fi

# --- Step 3: 部署 Firestore Rules + Indexes ---
echo ""
echo "--- Step 3: Deploy Firestore Rules + Indexes ---"
echo "[cmd] firebase deploy --only firestore:rules,firestore:indexes --project $PROJECT"
(cd "$INFRA_DIR" && firebase deploy --only firestore:rules,firestore:indexes --project "$PROJECT")
echo "[ok] Firestore Rules + Indexes 已部署"

# --- Step 4: 部署 Functions ---
echo ""
echo "--- Step 4: Deploy Functions ---"
echo "[cmd] firebase deploy --only functions --project $PROJECT"
(cd "$INFRA_DIR" && firebase deploy --only functions --project "$PROJECT")
echo "[ok] Functions 已部署"

# --- Step 5: 部署 Storage Rules ---
echo ""
echo "--- Step 5: Deploy Storage Rules ---"
echo "[cmd] firebase deploy --only storage --project $PROJECT"
(cd "$INFRA_DIR" && firebase deploy --only storage --project "$PROJECT")
echo "[ok] Storage Rules 已部署"

# --- Step 6: Smoke 测试 ---
echo ""
echo "--- Step 6: Smoke 测试 ---"
SMOKE_SCRIPT="$INFRA_DIR/../../openspec/changes/add-divination-playground/STAGING-SMOKE-CHECKLIST-2026-07-30.md"
if [[ -f "$SMOKE_SCRIPT" ]]; then
  echo "[info] Smoke 清单: $SMOKE_SCRIPT"
  echo "[hint] 请按 smoke 清单在 $PROJECT 手测全链路（发帖/应验/回复/点赞/通知/越权拒绝）"
else
  echo "[warn] Smoke 清单不存在，跳过（待补: $SMOKE_SCRIPT）" >&2
fi

echo ""
echo "=== Deploy $PROJECT 完成（未删除任何用户内容）==="
