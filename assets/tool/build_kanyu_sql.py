#!/usr/bin/env python3
"""kanyu 数据 SQL 构建脚本。

照 assets/tool/build_taiyishenshu_sql.py 的样板（M3/M4 同构）：
- 3 个数据集全部为整份读 JSON，以「JSON 文档表」落地
  （file_name + payload_json 两列，整文档存一行）：
  - kanyu.rules（rules/ 6 文件：Layer B 规则配置）
  - kanyu.static_data（data/ 16 文件：Layer A 静态数据）
  - kanyu.schema（schema/ 2 文件：JSON Schema 校验规格）
- payload_json 存文件**原文**（UTF-8 不转义），保证 A2 差分逐字节相等。

幂等：可重复运行，产物可覆盖，结果一致。
"""
import hashlib
import os
from datetime import datetime, timezone
from pathlib import Path

KANYU_DIR = Path(__file__).resolve().parent.parent / 'lib' / 'kanyu' / 'assets'
OUT_DIR = KANYU_DIR

DOCUMENT_TABLE_DDL = (
    'CREATE TABLE IF NOT EXISTS {table} ('
    '  file_name TEXT PRIMARY KEY,'
    '  payload_json TEXT NOT NULL'
    ')'
)

# (sql 文件名, 表名, 数据集 id, 源目录相对 KANYU_DIR)
DOCUMENT_DATASETS = [
    ('rules_document', 'rules_document', 'kanyu.rules', ['rules']),
    ('static_data_document', 'static_data_document', 'kanyu.static_data', ['data']),
    ('schema_document', 'schema_document', 'kanyu.schema', ['schema']),
]


def _sql_str(v) -> str:
    """Python 值 -> SQL 字面量（字符串单引号转义）。"""
    if v is None:
        return 'NULL'
    if isinstance(v, (int, float)):
        return str(v)
    if isinstance(v, bool):
        return '1' if v else '0'
    escaped = str(v).replace("'", "''")
    return f"'{escaped}'"


def _wrap_sql(ddl_statements: list, inserts: list, table: str) -> str:
    """拼接 *.sql 文本（不含显式 BEGIN/COMMIT）；
    DDL 后追加 DELETE FROM 保证重装幂等。"""
    lines = []
    for stmt in ddl_statements:
        lines.append(stmt + ';')
    lines.append(f'DELETE FROM {table};')
    lines.extend(inserts)
    return '\n'.join(lines) + '\n'


def _insert_lines(table: str, cols: list, rows: list) -> list:
    """逐行生成 INSERT 语句。"""
    quoted_cols = ', '.join(f'"{c}"' for c in cols)
    lines = []
    for row in rows:
        values = [_sql_str(v) for v in row]
        lines.append(
            f"INSERT INTO {table} ({quoted_cols}) VALUES ({', '.join(values)});"
        )
    return lines


def _stat(sql_path: Path, table: str, rows: int) -> dict:
    sha = hashlib.sha256(sql_path.read_bytes()).hexdigest()
    return {
        'table': table,
        'sql_path': str(sql_path),
        'rows': rows,
        'bytes': os.path.getsize(sql_path),
        'sha256': sha,
        'has_begin': 'BEGIN TRANSACTION;' in sql_path.read_text(encoding='utf-8'),
        'has_commit': 'COMMIT;' in sql_path.read_text(encoding='utf-8'),
    }


def build_document_dataset(table: str, dataset_id: str, dirs: list) -> dict:
    """整份读 JSON -> JSON 文档表（file_name + payload_json）。

    file_name 存相对 KANYU_DIR 的路径（如 rules/fan_gua/fan_gua.json），
    保证 repository 能按 ruleSetId/dataRef 定位。
    """
    sql_path = OUT_DIR / f'{table}.sql'
    ddl = [DOCUMENT_TABLE_DDL.format(table=table)]

    files = []
    for d in dirs:
        files.extend(sorted((KANYU_DIR / d).rglob('*.json')))
    if not files:
        raise RuntimeError(f'{dataset_id}: 源 JSON 匹配 0 个文件，停下报告')

    rows = []
    for f in files:
        payload = f.read_text(encoding='utf-8')
        rel = f.relative_to(KANYU_DIR).as_posix()
        rows.append((rel, payload))

    inserts = _insert_lines(table, ['file_name', 'payload_json'], rows)
    sql_text = _wrap_sql(ddl, inserts, table)
    sql_path.write_text(sql_text, encoding='utf-8')
    return _stat(sql_path, f'{table}(文档表)', len(rows))


def main():
    print('=' * 60)
    print('kanyu 数据 SQL 构建')
    print('=' * 60)
    results = []
    for sql_name, table, dataset_id, dirs in DOCUMENT_DATASETS:
        results.append(build_document_dataset(table, dataset_id, dirs))
    for r in results:
        print(f"\n-- {r['table']} --")
        print(f"   产物: {r['sql_path']}")
        print(f"   行数: {r['rows']}")
        print(f"   字节: {r['bytes']}")
        print(f"   sha256: {r['sha256']}")
        print(f"   BEGIN/COMMIT: {r['has_begin']}/{r['has_commit']}")

    print('\n' + '=' * 60)
    print('BUILD-REPORT.md 生成中...')
    print('=' * 60)
    now = datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')
    report = [
        '# kanyu 数据 SQL 构建报告',
        '',
        f'- 构建时间：{now}',
        '- 构建脚本：assets/tool/build_kanyu_sql.py',
        '- 源数据：rules/ ×6 + data/ ×16 + schema/ ×2（全部 JSON 文档表）',
        '',
        '## 产物',
        '',
        '| 文件 | 表名 | 行数 | 字节数 | sha256 |',
        '|---|---|---|---|---|',
    ]
    for r in results:
        fname = Path(r['sql_path']).name
        report.append(
            f"| {fname} | {r['table']} | {r['rows']} | {r['bytes']} | {r['sha256']} |"
        )
    report += [
        '',
        '## 验证',
        '',
        f'- 每个 *.sql 不含显式 BEGIN/COMMIT（事务由 drift transaction API 管理，'
        f'修复 Web/WasmDatabase 嵌套事务冲突，照 tiebanshenshu 0f3c6dd）：'
        f'{all(not r["has_begin"] and not r["has_commit"] for r in results)}',
        '- 每个 *.sql 含 CREATE TABLE：是',
        '- 每个 *.sql 含 DELETE FROM（重装幂等）：是',
        '- 中文（如「翻卦」「水法」）正确写入 UTF-8，未转义为 \\uXXXX',
        '',
        '## payloadFormat 决策',
        '',
        '| 数据集 | 载荷 | payloadFormat | 理由 |',
        '|---|---|---|---|',
        '| kanyu.rules | rules_document.sql | prebuilt | Layer B 规则配置 6 份整读，文档表，repository 按 ruleSetId 查 |',
        '| kanyu.static_data | static_data_document.sql | prebuilt | Layer A 静态数据 16 份整读，文档表，rules 的 dataRefs 解析需要 |',
        '| kanyu.schema | schema_document.sql | prebuilt | JSON Schema 校验规格 2 份，文档表，validateConfigPackage 需要 |',
        '',
        '## 数据质量说明',
        '',
        '- .FIXED.json（8 份未跟踪修正版）未迁，保留源仓（7/31 开发中，待源仓主人提交）。',
        '- CONFIGS-MANIFEST.md（文档）不迁，源仓 git rm 一并删除。',
        '',
        '## 幂等性',
        '',
        '- 脚本可重复运行，产物可覆盖，结果一致。',
    ]
    (OUT_DIR / 'BUILD-REPORT.md').write_text('\n'.join(report) + '\n', encoding='utf-8')
    print('BUILD-REPORT.md 已生成')


if __name__ == '__main__':
    main()
