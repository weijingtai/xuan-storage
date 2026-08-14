#!/bin/bash
# ============================================================
# run_playground_emulator_gate.sh — fail-closed Playground Emulator gate (Task 8)
#
# 验证：
#  1. Emulator 单一 Rules 源：emulator/firebase.json 引用 ../firestore.rules，且
#     旧 emulator/firestore.rules 不存在。
#  2. LAN Emulator (192.168.0.165) Firestore/Auth 可达；不可达 → exit 1（fail-closed，
#     不静默跳过）。
#  3. 生产 Rules fixture 10/10 GREEN（@firebase/rules-unit-testing 会把本机 rules 编译
#     下发到 165 的 playground-test namespace，不改 165 挂载文件）。
#  4. firestore_rules_source_contract_test.dart GREEN。
#
# fail-closed 语义：不可达 / skip / early return / allow-all 任一出现 → exit 1。
# ============================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"   # 即 firebase/（脚本在 firebase/scripts/ 下）
FIREBASE_DIR="$REPO_ROOT"
INFRA_DIR="$FIREBASE_DIR/infrastructure"
FUNCTIONS_DIR="$INFRA_DIR/functions"

FIRESTORE_HOST="${FIRESTORE_EMULATOR_HOST:-192.168.0.165:8080}"
AUTH_HOST="${FIREBASE_AUTH_EMULATOR_HOST:-192.168.0.165:9099}"
FS_HOST="${FIRESTORE_HOST%%:*}"
FS_PORT="${FIRESTORE_HOST##*:}"
AUTH_PORT="${AUTH_HOST##*:}"

FAILED=0
note()  { echo "[gate] $*"; }
die()   { echo "[gate] FAIL: $*" >&2; exit 1; }

# ---------- 1. 单一 Rules 源 ----------
note "校验单一 Rules 源..."
if ! grep -q '"rules"[[:space:]]*:[[:space:]]*"\.\./firestore\.rules"' "$INFRA_DIR/emulator/firebase.json"; then
  die "emulator/firebase.json 未引用 ../firestore.rules（单一源）"
fi
if [ -f "$INFRA_DIR/emulator/firestore.rules" ]; then
  die "旧 emulator/firestore.rules 仍存在，必须删除（单一源）"
fi
if [ ! -s "$INFRA_DIR/firestore.rules" ]; then
  die "生产 infrastructure/firestore.rules 不存在或为空"
fi

# ---------- 2. Emulator 可达性（fail-closed） ----------
note "探测 Firestore $FIRESTORE_HOST ..."
if ! curl -s -m 5 -o /dev/null "http://$FIRESTORE_HOST/"; then
  die "Firestore Emulator $FIRESTORE_HOST 不可达（fail-closed）"
fi
note "探测 Auth $AUTH_HOST ..."
if ! curl -s -m 5 -o /dev/null "http://$AUTH_HOST/"; then
  die "Auth Emulator $AUTH_HOST 不可达（fail-closed）"
fi

# ---------- 3. 生产 Rules fixture（TS，10/10） ----------
note "运行 production Rules fixture（direct_write_schema_fixture.test.ts）..."
(
  cd "$FUNCTIONS_DIR"
  FIRESTORE_EMULATOR_HOST="$FIRESTORE_HOST" \
  FIREBASE_AUTH_EMULATOR_HOST="$AUTH_HOST" \
    npx jest --runInBand direct_write_schema_fixture.test.ts
) || { echo "[gate] FAIL: direct_write_schema_fixture.test.ts 未全绿" >&2; FAILED=1; }

# ---------- 4. Source contract（Dart 静态） ----------
note "运行 firestore_rules_source_contract_test.dart..."
(
  cd "$FIREBASE_DIR"
  flutter test test/playground/firestore_rules_source_contract_test.dart
) || { echo "[gate] FAIL: firestore_rules_source_contract_test.dart 未通过" >&2; FAILED=1; }

# ---------- 结果 ----------
if [ "$FAILED" -ne 0 ]; then
  die "Emulator gate 未通过（fail-closed）"
fi
note "Emulator gate 全部通过 ✅（单一源 + 可达 + Rules 10/10 + source contract）"
exit 0
