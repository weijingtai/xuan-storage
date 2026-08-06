#!/usr/bin/env bash
# scripts/run_s5a_residue_gate.sh
# S5a 残留门禁：已裁定移出 S5a 的标识符出现即失败。
# 从仓库根目录执行。macOS /bin/bash 是 3.2.57 -- 只用普通数组，不用 declare -A / mapfile。
set -euo pipefail

readonly FORBIDDEN='InstalledTheme|AvailableTheme|ThemeRemoteFetcher|ThemePackageStore|ThemeSignatureVerifier|ThemeSignatureVerdict|refreshCatalog|listInstalled'

# 三个显式文件数组（与设计 §11.1/11.2/11.3 逐字对应）
CONTRACT_FILES=(
  "core/lib/model/theme_token_types.dart"
  "core/lib/model/theme_resolution.dart"
  "core/lib/model/theme_resource_store.dart"
  "core/lib/model/theme_value_types.dart"
  "core/lib/model/theme_source_ports.dart"
  "core/lib/model/theme_storage_policies.dart"
  "core/lib/model/theme_dataset.dart"
  "core/lib/model/theme_module_registry.dart"
)
REFERENCE_FILES=(
  "core/lib/reference/theme_token_merger.dart"
  "core/lib/reference/in_memory_theme_resource_store.dart"
  "core/lib/reference/in_memory_theme_materializer.dart"
  "core/lib/reference/theme_assembly.dart"
)
TEST_FILES=(
  "core/test/support/theme_bench_fixture.dart"
  "core/test/support/theme_probes.dart"
  "core/test/theme_token_merger_test.dart"
  "core/test/theme_resource_store_contract_test.dart"
  "core/test/theme_module_registry_test.dart"
  "core/test/theme_materializer_test.dart"
  "core/test/theme_startup_path_test.dart"
  "core/test/theme_merge_bench_test.dart"
)
ALL_FILES=( "${CONTRACT_FILES[@]}" "${REFERENCE_FILES[@]}" "${TEST_FILES[@]+"${TEST_FILES[@]}"}" )
# ⚠️ 上面的 ${arr[@]+...} 守卫是 bash 3.2 兼容写法：set -u 下空数组裸展开
# 会报 "unbound variable"（exit 1），守卫让空数组安全展开为空，
# 从而使「TEST_FILES 被改空」能走到下方 SCAN_TOO_NARROW 分支（exit 2，§11.6）。

# 覆盖下限之一：交付清单里的文件必须全部存在
missing=0
for f in "${ALL_FILES[@]}"; do
  if [ ! -f "${f}" ]; then
    echo "MISSING_FILE: ${f}"
    missing=$(( missing + 1 ))
  fi
done
if [ "${missing}" -ne 0 ]; then
  echo "SCAN_INCOMPLETE: ${missing} declared deliverable(s) missing"
  exit 2
fi

# 覆盖下限之二：数组本身不许被改空
readonly SCANNED=${#ALL_FILES[@]}
if [ "${SCANNED}" -lt 20 ]; then
  echo "SCAN_TOO_NARROW: only ${SCANNED} files in deliverable arrays (expected >= 20)"
  exit 2
fi

# 残留扫描。grep 三种退出码全部显式处理，不用 || true
set +e
matches="$(grep -nE "${FORBIDDEN}" "${ALL_FILES[@]}")"
grep_status=$?
set -e
if [ "${grep_status}" -ge 2 ]; then
  echo "GREP_ERROR: exit ${grep_status}"
  exit 3
fi
if [ "${grep_status}" -eq 0 ]; then
  echo "RESIDUE_FOUND:"
  echo "${matches}"
  exit 1
fi

echo "RESIDUE_GATE_OK (scanned ${SCANNED} deliverable files, 0 residue)"
exit 0
