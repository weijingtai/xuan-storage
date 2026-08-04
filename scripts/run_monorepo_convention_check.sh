#!/usr/bin/env bash
# monorepo 约定门禁
#
# 两条约定，都已经复发过，所以做成门禁而不是文档：
#
#   [1] 仓内子包互相引用一律用相对路径 path: ../xxx，不得用 git URL 指回本仓
#       git URL 会让 pub 去拉远端快照 —— 本地改了 core，其他包看不见，
#       要先 push 才生效；worktree 里更是会拉到与当前分支无关的代码。
#       （git 依赖会克隆整个仓库，故外部仓库经 git 依赖消费本仓子包时，
#         ../core 在其缓存内可正确解析，转相对路径不破坏外部消费方。）
#
#   [2] Flutter 自动生成的 .flutter-plugins-dependencies 不得入库
#       它每次 pub get 重写、逐包生成、含本机绝对路径。
#       注意：.gitignore 对【已入库】的文件无效 —— 本仓 assets/ 那份就是
#       被 ignore 规则覆盖着却一直被追踪，规则从未生效。故必须查索引，
#       而不是查 .gitignore 里有没有写。
#
# 兼容性：必须能在 macOS 自带 /bin/bash 3.2.57 下运行。

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 2
fail=0

# ── [1] 仓内自引用不得用 git URL ──
selfrefs="$(grep -ln "xuan-storage\.git" ./*/pubspec.yaml 2>/dev/null)"
if [ -n "$selfrefs" ]; then
  echo "❌ [检查1] 以下 pubspec 用 git URL 引用本仓子包，应改为 path: ../<子包>"
  for f in $selfrefs; do
    echo "   $f"
    grep -n -B2 "xuan-storage\.git" "$f" | sed 's/^/      /'
  done
  fail=1
else
  echo "✅ [检查1] 仓内子包互引全部使用相对路径，无 git URL 自引用"
fi

# ── [2] 自动生成文件不得入库 ──
tracked="$(git ls-files | grep -E '(^|/)\.flutter-plugins(-dependencies)?$')"
if [ -n "$tracked" ]; then
  echo "❌ [检查2] 以下自动生成文件被 git 追踪（.gitignore 对已入库文件无效）:"
  echo "$tracked" | sed 's/^/   /'
  echo "   修复: git rm --cached <文件>"
  fail=1
else
  echo "✅ [检查2] 无自动生成的 .flutter-plugins* 被追踪"
fi

echo "———"
if [ "$fail" -eq 0 ]; then
  echo "✅ monorepo 约定门禁通过"
else
  echo "❌ monorepo 约定门禁未通过"
fi
exit "$fail"
