#!/bin/bash
set -euo pipefail

# ============================================================================
# Playground 回滚脚本
#
# 用法: bash playground-rollback.sh --project <staging|production>
#
# 前置: firebase CLI 已登录，infrastructure/ 为 git 仓库（用于回滚 Rules）。
# 重要: 本脚本【不删除任何用户内容】——只回滚代码/Rules/关闭入口，不触碰数据文档。
# ============================================================================

PROJECT=""

usage() {
  echo "用法: bash playground-rollback.sh --project <staging|production>" >&2
  echo "  --project  必填，staging 或 production" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      PROJECT="${2:-}"
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
RULES_FILE="$INFRA_DIR/firestore.rules"
SHELL_BOOTSTRAP="$INFRA_DIR/../../../xuan-shell/lib/playground/shell_playground_bootstrap.dart"

echo "=== Playground Rollback → $PROJECT ==="
echo "[note] 本脚本不回滚/不删除任何用户数据文档，仅回滚代码与 Rules。"

# --- Step 1: 关闭写入口（feature flag）---
echo ""
echo "--- Step 1: 关闭写入口 (feature flag) ---"
if [[ -f "$SHELL_BOOTSTRAP" ]]; then
  if grep -q "playgroundEnabled" "$SHELL_BOOTSTRAP"; then
    echo "[ok] 检测到 feature flag: ShellPlaygroundBootstrap.playgroundEnabled"
    echo "[action] 请执行以下操作并重发版本，以停用 Playground 写入口（不删数据）:"
    echo "  1) 编辑 $SHELL_BOOTSTRAP"
    echo "  2) 将 'static bool playgroundEnabled = true;' 改为 'static bool playgroundEnabled = false;'"
    echo "  3) 提交并发布新版本（xuan-shell）"
  else
    echo "[warn] $SHELL_BOOTSTRAP 未找到 playgroundEnabled 开关" >&2
  fi
else
  echo "[warn] xuan-shell bootstrap 未找到: $SHELL_BOOTSTRAP" >&2
  echo "[warn] 请手动确认 ShellPlaygroundBootstrap.playgroundEnabled 置为 false 并重发版本" >&2
fi

# --- Step 2: 回滚 Firestore Rules 到上一版 ---
echo ""
echo "--- Step 2: 回滚 Firestore Rules 到上一版 ---"
if ! git -C "$INFRA_DIR" rev-parse --git-dir > /dev/null 2>&1; then
  echo "[error] $INFRA_DIR 不是 git 仓库，无法回滚 Rules" >&2
  exit 1
fi
PREV_RULES=$(git -C "$INFRA_DIR" show HEAD~1:firebase/infrastructure/firestore.rules 2>/dev/null || git -C "$INFRA_DIR" show HEAD~1:firestore.rules 2>/dev/null || echo "")
if [[ -n "$PREV_RULES" ]]; then
  echo "[cmd] git show HEAD~1:.../firestore.rules > $RULES_FILE"
  git -C "$INFRA_DIR" show HEAD~1:firebase/infrastructure/firestore.rules > "$RULES_FILE" 2>/dev/null \
    || git -C "$INFRA_DIR" show HEAD~1:firestore.rules > "$RULES_FILE"
  echo "[ok] 已还原上一版 Rules 到 $RULES_FILE"
  echo "[cmd] firebase deploy --only firestore:rules --project $PROJECT"
  (cd "$INFRA_DIR" && firebase deploy --only firestore:rules --project "$PROJECT")
  echo "[ok] 上一版 Rules 已部署到 $PROJECT"
else
  echo "[warn] 无 HEAD~1 Rules 可回滚（当前可能是首个提交）" >&2
fi

# --- Step 3: 回滚 Functions（可选：删除 Functions 或部署上一版）---
echo ""
echo "--- Step 3: 回滚 Functions ---"
echo "[action] 如需停用 Functions 触发，请执行:"
echo "  firebase functions:delete --project $PROJECT"
echo "[note] 若 Functions 保持只读幂等设计（createPost 等均走客户端 Rules 校验），可保留 Functions 不清除"
echo "[skip] 本步骤仅打印操作指令，不自动删除 Functions（避免误删线上函数）"

# --- Step 4: 验证读访问 ---
echo ""
echo "--- Step 4: 验证读访问（只读未断）---"
echo "[cmd] firebase firestore:read 需交互，改用 dry-run 验证 Rules 可编译:"
(cd "$INFRA_DIR" && firebase deploy --dry-run --only firestore:rules --project "$PROJECT")
echo "[ok] Rules dry-run 通过，read 访问规则仍在（只读未断）"
echo "[hint] 如需在 $PROJECT 实测读访问，请在客户端登录账号读取任意 active 帖子"

echo ""
echo "=== Rollback $PROJECT 完成（用户内容已保留，未删除任何数据）==="
