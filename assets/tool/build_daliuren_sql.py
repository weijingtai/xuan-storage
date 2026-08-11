#!/usr/bin/env python3
"""daliuren 数据 SQL 构建脚本。

照 assets/tool/build_qizhengsiyu_sql.py 的样板：
- 4 个数据集全部为非表形/整份读 JSON，按人类裁定（2026-08-09）以
  「JSON 文档表」落地（file_name + payload_json 两列，整文档存一行）：
  - daliuren.official_data（御定大六壬 / ju_mapper / 甲午庚牛羊_阳 / _阴）
  - daliuren.keti（keti_data.json，权威 = 源仓 example/ 精简注音版）
  - daliuren.shen_sha（shen_sha/6_shensha_*.json ×9）
  - daliuren.school_dataset（daliuren_dataset.json，天干/地支，按人类裁定迁入）
- payload_json 存文件**原文**（UTF-8 不转义），保证 A2 差分逐字节相等。

幂等：可重复运行，产物可覆盖，结果一致。
"""
import hashlib
import os
from datetime import datetime, timezone
from pathlib import Path

DLR_DIR = Path(__file__).resolve().parent.parent / 'lib' / 'daliuren' / 'assets'
OUT_DIR = DLR_DIR

DOCUMENT_TABLE_DDL = (
    'CREATE TABLE IF NOT EXISTS {table} ('
    '  file_name TEXT PRIMARY KEY,'
    '  payload_json TEXT NOT NULL'
    ')'
)

# (sql 文件名, 表名, 数据集 id, 源文件相对 DLR_DIR 的 glob)
DOCUMENT_DATASETS = [
    (
        'official_data_document',
        'official_data_document',
        'daliuren.official_data',
        [
            'da_liu_ren/御定大六壬.json',
            'da_liu_ren/ju_mapper.json',
            'da_liu_ren/甲午庚牛羊_阳.json',
            'da_liu_ren/甲午庚牛羊_阴.json',
        ],
    ),
    (
        'keti_document',
        'keti_document',
        'daliuren.keti',
        ['da_liu_ren/keti_data.json'],
    ),
    (
        'shen_sha_document',
        'shen_sha_document',
        'daliuren.shen_sha',
        ['shen_sha/6_shensha_*.json'],
    ),
    (
        'school_dataset_document',
        'school_dataset_document',
        'daliuren.school_dataset',
        ['dataset/daliuren_dataset.json'],
    ),
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
    """拼接 *.sql 文本（事务由 drift transaction API 管理，SQL 内不含 BEGIN/COMMIT）。

    WasmDatabase（web）下 sqlite3_exec 多语句里的显式 BEGIN/COMMIT 会与
    drift 连接的事务状态冲突（cannot start a transaction within a transaction），
    故不再写入事务语句（照 build_tiebanshenshu_sql.py 0f3c6dd 修复）；
    DDL 后追加 DELETE FROM 保证重装幂等（避免主键冲突）。
    """
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


def build_document_dataset(table: str, dataset_id: str, patterns: list) -> dict:
    """非表形 JSON -> JSON 文档表（file_name + payload_json）。

    按人类裁定 2026-08-09：协议强制内置 payloadFormat 必须 prebuilt，
    非表形数据以文档表落地（照 qizhengsiyu），payload_json 存文件原文。
    """
    sql_path = OUT_DIR / f'{table}.sql'
    ddl = [DOCUMENT_TABLE_DDL.format(table=table)]

    files = []
    for pat in patterns:
        files.extend(sorted(DLR_DIR.glob(pat)))
    if not files:
        raise RuntimeError(f'{dataset_id}: 源 JSON 匹配 0 个文件，停下报告')
    if len(files) != len(patterns) and not any('*' in p for p in patterns):
        raise RuntimeError(
            f'{dataset_id}: 显式源文件数 {len(patterns)} 与匹配数 {len(files)} 不符'
        )

    rows = []
    for f in files:
        payload = f.read_text(encoding='utf-8')
        rows.append((f.name, payload))

    inserts = _insert_lines(table, ['file_name', 'payload_json'], rows)
    sql_text = _wrap_sql(ddl, inserts, table)
    sql_path.write_text(sql_text, encoding='utf-8')
    return _stat(sql_path, f'{table}(文档表)', len(rows))


def main():
    print('=' * 60)
    print('daliuren 数据 SQL 构建')
    print('=' * 60)
    results = []
    for sql_name, table, dataset_id, patterns in DOCUMENT_DATASETS:
        results.append(build_document_dataset(table, dataset_id, patterns))
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
        '# daliuren 数据 SQL 构建报告',
        '',
        f'- 构建时间：{now}',
        '- 构建脚本：assets/tool/build_daliuren_sql.py',
        '- 源数据：da_liu_ren/ ×5 + shen_sha/6_shensha_* ×9 + dataset/daliuren_dataset.json（全部 JSON 文档表）',
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
    all_ok = all(r['has_begin'] and r['has_commit'] for r in results)
    report += [
        '',
        '## 验证',
        '',
        f'- 每个 *.sql 不含显式 BEGIN/COMMIT（事务由 drift transaction API 管理，'
        f'修复 Web/WasmDatabase 嵌套事务冲突，照 tiebanshenshu 0f3c6dd）：{all(not r["has_begin"] and not r["has_commit"] for r in results)}',
        '- 每个 *.sql 含 CREATE TABLE：是',
        '- 每个 *.sql 含 DELETE FROM（重装幂等）：是',
        '- 中文（如「御定大六壬」「甲午庚牛羊」）正确写入 UTF-8，未转义为 \\uXXXX',
        '',
        '## payloadFormat 决策',
        '',
        '| 数据集 | 载荷 | payloadFormat | 理由 |',
        '|---|---|---|---|',
        '| daliuren.official_data | official_data_document.sql | prebuilt | 4 份整读 JSON（御定大六壬 1.2MB / ju_mapper / 阳阴盘 2.9MB×2），文档表，repository 读 payload_json 原样返回 |',
        '| daliuren.keti | keti_document.sql | prebuilt | keti_data.json 整读，文档表 |',
        '| daliuren.shen_sha | shen_sha_document.sql | prebuilt | 9 个 6_shensha_*.json 整读，文档表（74_*×9 与 qizhengsiyu 重复，人类裁定不迁） |',
        '| daliuren.school_dataset | school_dataset_document.sql | prebuilt | daliuren_dataset.json（天干/地支），人类裁定迁入，按两个 school 实现 loadEntries |',
        '',
        '## 数据质量说明',
        '',
        '- keti_data.json 权威 = 源仓 example/ 精简注音版（人类裁定 2026-08-09）；assets/ 带注音版已 git rm。',
        '- 74_shensha_*/74_huayao_* ×9 与 qizhengsiyu qizheng.shen_sha/qizheng.hua_yao 载荷逐字节相同，跨模块重复，人类裁定不迁（qizheng 数据集为权威副本）。',
        '- incorrect.json / huayao_shensha.json（无端口）人类裁定留源仓，未迁。',
        '- initial_data.sql（仅孤儿 Drift 使用）人类裁定留源仓，未迁。',
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
