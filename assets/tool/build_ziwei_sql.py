#!/usr/bin/env python3
"""ziwei 数据 SQL 构建脚本。

照 assets/tool/build_taiyishenshu_sql.py 的样板（M3 同构）：
- 3 个数据集全部为非表形/整份读数据，以「JSON 文档表」落地
  （file_name + payload_json 两列，整文档存一行）：
  - ziwei.star_catalog（stars.csv 原文 1 行，payload_json 存 CSV 文本）
  - ziwei.star_metadata（ziwei_stars_main.json + ziwei_stars_minor.json 2 行）
  - ziwei.four_transformations（ziwei_four_transformations.json 1 行）
- brightness / palaces 无契约端口（D4），物理保存于 assets/brightness/、assets/palaces/
  不注册 dataset，不进本脚本的 dataset 列表。
- payload_json 存文件**原文**（UTF-8 不转义），保证 A2 差分逐字节相等。

幂等：可重复运行，产物可覆盖，结果一致。
"""
import hashlib
import os
from datetime import datetime, timezone
from pathlib import Path

ZIWEI_DIR = Path(__file__).resolve().parent.parent / 'lib' / 'ziwei' / 'assets'
OUT_DIR = ZIWEI_DIR

DOCUMENT_TABLE_DDL = (
    'CREATE TABLE IF NOT EXISTS {table} ('
    '  file_name TEXT PRIMARY KEY,'
    '  payload_json TEXT NOT NULL'
    ')'
)

# (sql 文件名, 表名, 数据集 id, 源文件相对 ZIWEI_DIR 的列表)
DOCUMENT_DATASETS = [
    (
        'star_catalog_document',
        'star_catalog_document',
        'ziwei.star_catalog',
        ['stars.csv'],
    ),
    (
        'star_metadata_document',
        'star_metadata_document',
        'ziwei.star_metadata',
        ['ziwei_stars_main.json', 'ziwei_stars_minor.json'],
    ),
    (
        'four_transformations_document',
        'four_transformations_document',
        'ziwei.four_transformations',
        ['ziwei_four_transformations.json'],
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


def build_document_dataset(table: str, dataset_id: str, files: list) -> dict:
    """整份读数据 -> JSON 文档表（file_name + payload_json）。"""
    sql_path = OUT_DIR / f'{table}.sql'
    ddl = [DOCUMENT_TABLE_DDL.format(table=table)]

    missing = [f for f in files if not (ZIWEI_DIR / f).exists()]
    if missing:
        raise RuntimeError(f'{dataset_id}: 缺少源文件 {missing}，停下报告')

    rows = []
    for f in files:
        payload = (ZIWEI_DIR / f).read_text(encoding='utf-8')
        rows.append((f, payload))

    inserts = _insert_lines(table, ['file_name', 'payload_json'], rows)
    sql_text = _wrap_sql(ddl, inserts, table)
    sql_path.write_text(sql_text, encoding='utf-8')
    return _stat(sql_path, f'{table}(文档表)', len(rows))


def main():
    print('=' * 60)
    print('ziwei 数据 SQL 构建')
    print('=' * 60)
    results = []
    for sql_name, table, dataset_id, files in DOCUMENT_DATASETS:
        results.append(build_document_dataset(table, dataset_id, files))
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
        '# ziwei 数据 SQL 构建报告',
        '',
        f'- 构建时间：{now}',
        '- 构建脚本：assets/tool/build_ziwei_sql.py',
        '- 源数据：stars.csv ×1 + ziwei_stars_main/minor.json ×2 + ziwei_four_transformations.json ×1（全部 JSON 文档表）',
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
        '- 中文（如「紫微」「天机」）正确写入 UTF-8，未转义为 \\uXXXX',
        '',
        '## payloadFormat 决策',
        '',
        '| 数据集 | 载荷 | payloadFormat | 理由 |',
        '|---|---|---|---|',
        '| ziwei.star_catalog | star_catalog_document.sql | prebuilt | stars.csv 原文整读 1 行，文档表，shell 读 payload_json 取 CSV 原文（保持 String 接口） |',
        '| ziwei.star_metadata | star_metadata_document.sql | prebuilt | 主辅星 JSON 整读 2 行，文档表，XrapZiweiStarRepository 读后契约映射 |',
        '| ziwei.four_transformations | four_transformations_document.sql | prebuilt | 四化 JSON 整读 1 行，文档表，getFourTransformations 读 sanhe 表 |',
        '',
        '## 数据质量说明',
        '',
        '- brightness（ziwei_star_brightness.json，2D 星曜×地支表）与 palaces（ziwei_palaces.json，十二宫定义）无契约 Repository 端口（D4），物理保存在 assets/brightness/ 与 assets/palaces/，不注册 dataset。',
        '- ziwei_charting_algorithm.json（算法配置）与 assets/fixtures/（源仓测试证据）未迁，保留在源仓（待人类裁定）。',
        '',
        '## 幂等性',
        '',
        '- 脚本可重复运行，产物可覆盖，结果一致。',
    ]
    (OUT_DIR / 'BUILD-REPORT.md').write_text('\n'.join(report) + '\n', encoding='utf-8')
    print('BUILD-REPORT.md 已生成')


if __name__ == '__main__':
    main()
