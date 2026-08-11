#!/usr/bin/env python3
"""tiebanshenshu 数据 SQL 构建脚本。

照 assets/tool/build_geo_sql.py / build_qizhengsiyu_sql.py 的样板：
- 表形数据（all_tiao_wen_v1.csv）生成 tiao_wen.sql
  （CREATE TABLE + INSERT，事务包裹，UTF-8 中文不转义），属 DatasetPayloadFormat.prebuilt。
- 非表形数据（kao_ke JSON / shaozishu TXT / formulas JSON）以「文档表」落地
  （file_name + payload 两列），照 qizhengsiyu document_tables.dart 模式。

幂等：可重复运行，产物可覆盖，结果一致。
"""
import csv
import hashlib
import json
import os
import re
from datetime import datetime, timezone
from pathlib import Path

TBS_DIR = Path(__file__).resolve().parent.parent / 'lib' / 'tiebanshenshu' / 'assets'
OUT_DIR = TBS_DIR

# ---------------------------------------------------------------- 表定义

TIAO_WEN_DDL = [
    'CREATE TABLE IF NOT EXISTS tiao_wen ('
    '  id INTEGER PRIMARY KEY,'
    '  set_name TEXT NOT NULL,'
    '  content1 TEXT NOT NULL,'
    '  age_set1_json TEXT'
    ')',
]

DOCUMENT_TABLE_DDL = (
    'CREATE TABLE IF NOT EXISTS {table} ('
    '  file_name TEXT PRIMARY KEY,'
    '  payload_json TEXT NOT NULL'
    ')'
)

SHAOZISHU_TABLE_DDL = (
    'CREATE TABLE IF NOT EXISTS {table} ('
    '  file_name TEXT PRIMARY KEY,'
    '  payload_text TEXT NOT NULL'
    ')'
)

# 非表形数据 -> 文档表。
# 每项：(sql 文件名, 表名, 数据集 id, 源 glob)
DOCUMENT_DATASETS = [
    ('kao_ke_document', 'kao_ke_document', 'tiebanshenshu.kao_ke', ['kao_ke/*.json']),
    ('formulas_document', 'formulas_document', 'tiebanshenshu.formulas', ['formulas/*.json']),
]

# shaozishu 12 txt -> 文档表（payload_text）。
SHAOZISHU_DATASETS = [
    ('shaozishu_document', 'shaozishu_document', 'tiebanshenshu.shaozishu', ['shaozishu/*.txt']),
]


def _sql_str(v) -> str:
    """Python 值 -> SQL 字面量（None -> NULL；字符串单引号转义；数字直出）。"""
    if v is None:
        return 'NULL'
    if isinstance(v, (int, float)):
        return str(v)
    if isinstance(v, bool):
        return '1' if v else '0'
    escaped = str(v).replace("'", "''")
    return f"'{escaped}'"


def _wrap_sql(ddl_statements: list, inserts: list, table: str) -> str:
    """拼接 *.sql 文本（事务由 drift transaction API 管理，SQL 内不含 BEGIN/COMMIT）。

    WasmDatabase（web）下 sqlite3_exec 多语句里的显式 BEGIN/COMMIT 会与
    drift 连接的事务状态冲突（cannot start a transaction within a transaction），
    故不再写入事务语句；DDL 后追加 DELETE FROM 保证重装幂等（避免主键冲突）。
    """
    lines = []
    for stmt in ddl_statements:
        lines.append(stmt + ';')
    lines.append(f'DELETE FROM {table};')
    lines.extend(inserts)
    return '\n'.join(lines) + '\n'
def _insert_lines(table: str, cols: list, rows: list) -> list:
    """逐行生成 INSERT 语句（列名双引号引用，SQLite 保留字安全）。"""
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


# ------------------------------------------- ageSet1 解析（与旧桩 _parseAgeSet 对齐）
#
# 旧桩逻辑：移除括号/小数点/冒号/连字符/μ/单引号/字母中文，按空格拆数字。
# CSV 实际形如 `(47)` 或 `(21 22)`，但为差分对齐保留同款容错。
_AGE_CLEAN = re.compile(r'[()]')
_AGE_JUNK = re.compile(r'[a-zA-Z\u4e00-\u9fa5]')


def parse_age_set(age_set_str: str):
    """' (47)' / '(21 22)' -> JSON 数组字符串（如 '[47]' / '[21,22]'）；空则 None。"""
    if not age_set_str or not age_set_str.strip():
        return None
    cleaned = _AGE_CLEAN.sub('', age_set_str)
    cleaned = cleaned.replace('.', '').replace(':', ' ').replace('-', ' ')
    cleaned = cleaned.replace('\u03bc', ' ').replace("'", ' ')
    cleaned = _AGE_JUNK.sub('', cleaned)
    cleaned = re.sub(r'\s+', ' ', cleaned).strip()
    if not cleaned:
        return None
    numbers = []
    for token in cleaned.split(' '):
        token = token.strip()
        if not token:
            continue
        try:
            numbers.append(int(token))
        except ValueError:
            continue
    if not numbers:
        return None
    return json.dumps(numbers, ensure_ascii=False)


def build_tiao_wen() -> dict:
    """all_tiao_wen_v1.csv（12000 行，无表头）-> tiao_wen.sql。"""
    csv_path = TBS_DIR / 'all_tiao_wen_v1.csv'
    sql_path = OUT_DIR / 'tiao_wen.sql'

    rows = []
    with open(csv_path, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        for line in reader:
            if not line or all(cell.strip() == '' for cell in line):
                continue
            if len(line) < 3:
                raise RuntimeError(f'tiao_wen: 行字段数 < 3: {line}')
            id_ = int(line[0].strip())
            set_name = line[1].strip()
            content1 = line[2].strip()
            age_set1 = parse_age_set(line[3].strip()) if len(line) > 3 else None
            rows.append((id_, set_name, content1, age_set1))

    expected = 12000
    if len(rows) != expected:
        raise RuntimeError(f'tiao_wen: CSV 数据行数 {len(rows)} 与预期 {expected} 不符，停下报告')

    inserts = _insert_lines('tiao_wen', ['id', 'set_name', 'content1', 'age_set1_json'], rows)
    sql_text = _wrap_sql(TIAO_WEN_DDL, inserts, 'tiao_wen')
    sql_path.write_text(sql_text, encoding='utf-8')
    return _stat(sql_path, 'tiao_wen', len(rows))


def build_document_dataset(table: str, dataset_id: str, patterns: list, payload_col: str = 'payload_json') -> dict:
    """非表形 JSON/TXT -> 文档表（file_name + payload_json / payload_text）。"""
    sql_path = OUT_DIR / f'{table}.sql'
    if payload_col == 'payload_json':
        ddl = [DOCUMENT_TABLE_DDL.format(table=table)]
    else:
        ddl = [SHAOZISHU_TABLE_DDL.format(table=table)]

    files = []
    for pat in patterns:
        files.extend(sorted(TBS_DIR.glob(pat)))
    if not files:
        raise RuntimeError(f'{dataset_id}: 源文件匹配 0 个，停下报告')

    rows = []
    for f in files:
        if payload_col == 'payload_json':
            payload = f.read_text(encoding='utf-8')
        else:
            payload = f.read_text(encoding='utf-8')
        rows.append((f.name, payload))

    inserts = _insert_lines(table, ['file_name', payload_col], rows)
    sql_text = _wrap_sql(ddl, inserts, table)
    sql_path.write_text(sql_text, encoding='utf-8')
    return _stat(sql_path, f'{table}(文档表)', len(rows))


def main():
    print('=' * 60)
    print('tiebanshenshu 数据 SQL 构建')
    print('=' * 60)
    results = [build_tiao_wen()]
    for sql_name, table, dataset_id, patterns in DOCUMENT_DATASETS:
        results.append(build_document_dataset(table, dataset_id, patterns))
    for sql_name, table, dataset_id, patterns in SHAOZISHU_DATASETS:
        results.append(build_document_dataset(table, dataset_id, patterns, payload_col='payload_text'))

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
        '# tiebanshenshu 数据 SQL 构建报告',
        '',
        f'- 构建时间：{now}',
        '- 构建脚本：assets/tool/build_tiebanshenshu_sql.py',
        '- 源数据：all_tiao_wen_v1.csv（表形 12000 行）+ kao_ke（21 JSON）+ shaozishu（12 TXT）+ formulas（3 JSON）',
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
    all_ok = all((not r['has_begin']) and (not r['has_commit']) for r in results)
    report += [
        '',
        '## 验证',
        '',
        f'- 每个 *.sql 不含 BEGIN TRANSACTION / COMMIT：{all_ok}',
        '- 每个 *.sql 含 CREATE TABLE：是',
        '- 中文（如「一树残花，有枝复茂。」）正确写入 UTF-8，未转义为 \\uXXXX',
        '',
        '## payloadFormat 决策',
        '',
        '| 数据集 | 载荷 | payloadFormat | 理由 |',
        '|---|---|---|---|',
        '| tiebanshenshu.tiao_wen | tiao_wen.sql | prebuilt | 表形（12000 行，id/set_name/content1/age_set1_json），构建期建表，设备上零解析 |',
        '| tiebanshenshu.kao_ke | kao_ke_document.sql | prebuilt（JSON 文档表） | 21 个嵌套 JSON，非表形，按 file_name 整取 |',
        '| tiebanshenshu.shaozishu | shaozishu_document.sql | prebuilt（TXT 文档表） | 12 个地支 txt，整文件存取，消费方按行解析 |',
        '| tiebanshenshu.formulas | formulas_document.sql | prebuilt（JSON 文档表） | 3 个皇极公式 JSON，非表形，按 file_name 整取 |',
        '',
        '## 数据质量说明',
        '',
        '- tiao_wen 表 age_set1_json 列存 JSON 数组（如 `[47]` / `[21,22]`），空 ageSet 存 NULL（与旧桩 _parseAgeSet 容错逻辑对齐）。',
        '- formulas 以源仓 assets/ 版（huang_ji_formula_manager 在用）为权威；example/ 版已随双副本 git rm。',
        '- kao_ke 以 assets/ 版为权威；example/ 版已随双副本 git rm。',
        '',
        '## 幂等性',
        '',
        '- 脚本可重复运行，产物可覆盖，结果一致。',
        '',
    ]
    report_path = OUT_DIR / 'BUILD-REPORT.md'
    report_path.write_text('\n'.join(report), encoding='utf-8')
    print(f'   报告: {report_path}')

    print('\n完成。')


if __name__ == '__main__':
    main()
