#!/usr/bin/env bash
# 负测试：fixture 里【每一个】违规文件都必须各自产生【预期类型】的 error，
# 且【不得】出现预期之外的 error。
#
# R1 加固：pub get 失败即退出；逐文件独立 analyze；核对错误码与所在文件。
# R2 加固：
#   (a) 【不用 declare 的 -A 关联数组】—— macOS 自带 /bin/bash 是 3.2.57，
#       不支持关联数组，结合 set -u 会直接退出 127，脚本在跑到检查前就死。
#       改用 while read 表驱动。
#   (b) analyze 退出码必须【恰为 3】（error 级）。只判「日志里有目标错误」不够——
#       目标错误 + 一堆无关错误也会通过。
#   (c) 出现【允许集合之外】的 ERROR 一律判失败。
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FIXTURE="$ROOT/test_fixtures/policy_negative"
cd "$FIXTURE" || { echo "❌ 找不到 fixture 目录 $FIXTURE"; exit 1; }

if ! dart pub get --suppress-analytics >/tmp/pn_pubget.log 2>&1; then
  echo "❌ dart pub get 失败，无法判定。这是环境问题，不是约束失效。"
  cat /tmp/pn_pubget.log
  exit 1
fi

# 表驱动，bash 3.2 兼容。三列：文件名 | 必须出现的错误码 | 额外允许的伴生错误码
# 伴生错误说明：`const x = Foo(bad: 1);` 除了 UNDEFINED_NAMED_PARAMETER，
# 还会连带报 CONST_INITIALIZED_WITH_NON_CONSTANT_VALUE。那是同一处违规的副产物，
# 属允许集合；但任何【其它】错误码都判失败。
CASES='
v1_shared_with_channels|UNDEFINED_NAMED_PARAMETER|CONST_INITIALIZED_WITH_NON_CONSTANT_VALUE
v2_control_with_publisher|UNDEFINED_NAMED_PARAMETER|CONST_INITIALIZED_WITH_NON_CONSTANT_VALUE
v3_private_with_cloud|UNDEFINED_NAMED_PARAMETER|CONST_INITIALIZED_WITH_NON_CONSTANT_VALUE
v4_private_with_channels|UNDEFINED_NAMED_PARAMETER|CONST_INITIALIZED_WITH_NON_CONSTANT_VALUE
v5_private_policy_direct_ctor|CONST_WITH_UNDEFINED_CONSTRUCTOR_DEFAULT|NEW_WITH_UNDEFINED_CONSTRUCTOR_DEFAULT|CONST_INITIALIZED_WITH_NON_CONSTANT_VALUE
v6_shared_policy_direct_ctor|CONST_WITH_UNDEFINED_CONSTRUCTOR_DEFAULT|NEW_WITH_UNDEFINED_CONSTRUCTOR_DEFAULT|CONST_INITIALIZED_WITH_NON_CONSTANT_VALUE
v7_resource_policy_direct_ctor|CONST_WITH_UNDEFINED_CONSTRUCTOR_DEFAULT|NEW_WITH_UNDEFINED_CONSTRUCTOR_DEFAULT|CONST_INITIALIZED_WITH_NON_CONSTANT_VALUE
v8_control_policy_direct_ctor|CONST_WITH_UNDEFINED_CONSTRUCTOR_DEFAULT|NEW_WITH_UNDEFINED_CONSTRUCTOR_DEFAULT|CONST_INITIALIZED_WITH_NON_CONSTANT_VALUE
'

FAILED=0
COUNT=0
while IFS= read -r LINE; do
  LINE="$(echo "$LINE" | tr -d '[:space:]')"
  [ -z "$LINE" ] && continue
  NAME="${LINE%%|*}"
  RULES="${LINE#*|}"                       # 必须码 + 伴生码，| 分隔
  REQUIRED="${RULES%%|*}"                  # 第一个就是「必须出现」的码
  ALLOWED="$RULES"                         # 全部都在允许集合内
  COUNT=$((COUNT+1))

  SRC="lib/${NAME}.dart"
  if [ ! -f "$SRC" ]; then
    echo "❌ $NAME: 缺文件 $SRC"; FAILED=1; continue
  fi

  LOG="/tmp/pn_${NAME}.log"
  dart analyze --suppress-analytics --format=machine "$SRC" >"$LOG" 2>&1
  EC=$?

  if [ "$EC" -ne 3 ]; then
    echo "❌ $NAME: analyze 退出码 ${EC}，期望 3（error 级）"
    case "$EC" in
      0) echo "   含义：该违规【竟然编译通过】，对应约束失效了。" ;;
      1|2) echo "   含义：只有 info/warning，没有 error，约束没生效。" ;;
      *) echo "   含义：analyze 执行异常。" ;;
    esac
    sed 's/^/     /' "$LOG"; FAILED=1; continue
  fi

  if grep -qE "URI_DOES_NOT_EXIST|URI_HAS_NOT_BEEN_GENERATED" "$LOG"; then
    echo "❌ $NAME: 出现 URI 解析错误，依赖没装好，不能据此判定约束生效"
    FAILED=1; continue
  fi

  # (1) 必须出现目标错误码，且位置落在本违规文件
  if ! awk -F'|' -v pat="$REQUIRED" -v f="${NAME}.dart" \
       '$1=="ERROR" && $3 ~ pat && index($4, f) > 0 { found=1 }
        END { exit found?0:1 }' "$LOG"; then
    echo "❌ $NAME: 【没有】产生预期的 error（${REQUIRED}），该条约束失效了。"
    sed 's/^/     /' "$LOG"; FAILED=1; continue
  fi

  # (2) 不得出现允许集合之外的 ERROR
  UNEXPECTED="$(awk -F'|' -v allow="$ALLOWED" \
    '$1=="ERROR" { split(allow, A, "|"); ok=0;
                   for (i in A) if ($3 == A[i]) ok=1;
                   if (!ok) print $3 }' "$LOG" | sort -u)"
  if [ -n "$UNEXPECTED" ]; then
    echo "❌ $NAME: 出现预期之外的 ERROR，无法确认是本约束在起作用："
    echo "$UNEXPECTED" | sed 's/^/     /'
    FAILED=1; continue
  fi

  echo "✅ $NAME: 按预期被拒绝（${REQUIRED}）"
done <<EOF
$CASES
EOF

if [ "$COUNT" -ne 8 ]; then
  echo "❌ 只检查了 $COUNT 条，期望 8 条。CASES 表被改动过？"
  exit 1
fi
if [ "$FAILED" -eq 0 ]; then
  echo "✅ 负测试全部通过：8 条非法组合逐条被拒绝"
  exit 0
fi
echo "❌ 负测试失败：上面标 ❌ 的条目对应的参数表约束没有生效，回 ACT 02 修 storage_policy.dart"
exit 1
