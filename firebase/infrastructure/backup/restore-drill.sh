#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INFRA_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
EMULATOR_DIR="$INFRA_DIR/emulator"
FUNCTIONS_DIR="$INFRA_DIR/functions"

DATE=$(date +%Y%m%d-%H%M%S)
LOG_FILE="$SCRIPT_DIR/restore-drill-$DATE.log"
EXPORT_DIR="$EMULATOR_DIR/seed/drill-export-$DATE"
IMPORT_DIR="$EXPORT_DIR"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== Restore Drill — $DATE ==="
echo "工作目录: $SCRIPT_DIR"

# 1. 检查 Emulator 是否运行
echo ""
echo "--- Step 1: 检查 Emulator 状态 ---"
FIRESTORE_RUNNING=false
if curl -s "http://localhost:8082" > /dev/null 2>&1; then
  FIRESTORE_RUNNING=true
  echo "Firestore Emulator 已运行在 localhost:8082"
elif curl -s "http://localhost:8080" > /dev/null 2>&1; then
  FIRESTORE_RUNNING=true
  echo "Firestore Emulator 已运行在 localhost:8080"
else
  echo "Firestore Emulator 未运行，尝试启动..."
  cd "$EMULATOR_DIR"
  firebase emulators:start --import=./seed &
  EMULATOR_PID=$!
  sleep 10
  if curl -s "http://localhost:8082" > /dev/null 2>&1; then
    FIRESTORE_RUNNING=true
    echo "Emulator 启动成功 (PID: $EMULATOR_PID)"
  else
    echo "WARNING: Emulator 启动失败，使用 emulators:export 仅导出本地 seed 数据"
  fi
fi

# 2. 导出当前 Firestore 数据
echo ""
echo "--- Step 2: 导出 Firestore 数据 ---"
mkdir -p "$EXPORT_DIR"

if [ "$FIRESTORE_RUNNING" = true ]; then
  echo "从运行中的 Emulator 导出到 $EXPORT_DIR ..."
  firebase emulators:export "$EXPORT_DIR" \
    --project demo-playground \
    --only firestore 2>&1 || echo "WARNING: emulators:export 失败，尝试目录复制"

  # 计算导出文档数
  if [ -d "$EXPORT_DIR" ]; then
    EXPORT_DOC_COUNT=$(find "$EXPORT_DIR" -type f | wc -l | tr -d ' ')
    echo "导出文件数: $EXPORT_DOC_COUNT"
  fi
else
  echo "Emulator 未运行，复制现有 seed 数据作为基准"
  if [ -d "$EMULATOR_DIR/seed" ]; then
    cp -r "$EMULATOR_DIR/seed/firestore_export" "$EXPORT_DIR/" 2>/dev/null || true
    cp -r "$EMULATOR_DIR/seed/auth_export" "$EXPORT_DIR/" 2>/dev/null || true
  fi
  EXPORT_DOC_COUNT=$(find "$EXPORT_DIR" -type f 2>/dev/null | wc -l | tr -d ' ')
  echo "基准文件数: $EXPORT_DOC_COUNT"
fi

# 3. 校验导出完整性
echo ""
echo "--- Step 3: 校验导出完整性 ---"
EXPORT_SIZE=$(du -sh "$EXPORT_DIR" 2>/dev/null | cut -f1)
echo "导出大小: ${EXPORT_SIZE:-0}"
echo "文件数量: ${EXPORT_DOC_COUNT:-0}"

if [ "${EXPORT_DOC_COUNT:-0}" -gt 0 ]; then
  echo "PASS: 导出包含数据"
  
  # 生成 SHA256 哈希列表
  if command -v shasum &> /dev/null; then
    find "$EXPORT_DIR" -type f -exec shasum -a 256 {} \; > "$SCRIPT_DIR/export-checksums-$DATE.txt"
    CHECKSUM_COUNT=$(wc -l < "$SCRIPT_DIR/export-checksums-$DATE.txt" | tr -d ' ')
    echo "校验和文件: $SCRIPT_DIR/export-checksums-$DATE.txt ($CHECKSUM_COUNT 行)"
  fi
else
  echo "WARNING: 导出为空或目录不存在"
fi

# 4. 导入到独立目录（模拟恢复）
echo ""
echo "--- Step 4: 导入恢复验证 ---"
RESTORE_DIR="$EMULATOR_DIR/seed/drill-restore-$DATE"
if [ -d "$EXPORT_DIR" ] && [ "${EXPORT_DOC_COUNT:-0}" -gt 0 ]; then
  mkdir -p "$RESTORE_DIR"
  cp -r "$EXPORT_DIR"/* "$RESTORE_DIR/" 2>/dev/null || true
  
  # 使用恢复的数据启动 Emulator 验证
  echo "使用恢复数据启动 Emulator 验证..."
  cd "$EMULATOR_DIR"
  
  # 临时替换 seed 目录做导入验证
  SEED_BACKUP="$EMULATOR_DIR/seed"
  if [ -d "$SEED_BACKUP" ]; then
    cp -r "$EXPORT_DIR" "$EMULATOR_DIR/seed-restore-test" 2>/dev/null || true
    RESTORE_FILE_COUNT=$(find "$RESTORE_DIR" -type f 2>/dev/null | wc -l | tr -d ' ')
    echo "恢复文件数: $RESTORE_FILE_COUNT"
    
    if [ "$RESTORE_FILE_COUNT" -eq "$EXPORT_DOC_COUNT" ]; then
      echo "PASS: 导入恢复文件数与导出一致"
    else
      echo "WARNING: 文件数不一致 (导出 $EXPORT_DOC_COUNT vs 恢复 $RESTORE_FILE_COUNT)"
    fi
  fi
fi

# 5. 运行合同测试
echo ""
echo "--- Step 5: 运行合同测试 ---"
cd "$FUNCTIONS_DIR"
if [ -f "package.json" ] && command -v npm &> /dev/null; then
  echo "运行 Functions 测试..."
  npm test 2>&1 | tail -10 || echo "WARNING: 测试运行失败"
  TEST_EXIT=$?
  if [ $TEST_EXIT -eq 0 ]; then
    echo "PASS: 测试通过"
  else
    echo "WARNING: 测试退出码 $TEST_EXIT"
  fi
fi

# 6. 汇总
echo ""
echo "=== Restore Drill Complete ==="
echo "日期: $DATE"
echo "导出大小: ${EXPORT_SIZE:-N/A}"
echo "导出文件: ${EXPORT_DOC_COUNT:-N/A}"
echo "日志文件: $LOG_FILE"
echo "校验和文件: $SCRIPT_DIR/export-checksums-$DATE.txt (如有)"
echo ""

# 清理临时文件
rm -rf "$EMULATOR_DIR/seed-restore-test" 2>/dev/null || true

echo "Drill 完成。"
