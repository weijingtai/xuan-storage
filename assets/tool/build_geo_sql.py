#!/usr/bin/env python3
"""geo 数据 SQL 构建脚本。

读 3 个 JSON，插入内存 SQLite3（中间步骤，只为生成正确语法的 SQL），
再导出为 *.sql 文件（CREATE TABLE + INSERT 语句，事务包裹）。

幂等：可重复运行，产物可覆盖。
"""
import json
import sqlite3
import hashlib
import os
from pathlib import Path

GEO_DIR = Path(__file__).resolve().parent.parent / 'lib' / 'geo'

SOURCES = {
    'admin_division': {
        'json': GEO_DIR / 'province_city_area_lng_lat.json',
        'sql': GEO_DIR / 'admin_division.sql',
        'expected_rows': 3515,
        'ddl': [
            'CREATE TABLE IF NOT EXISTS admin_division ('
            '  code TEXT PRIMARY KEY,'
            '  parent_code TEXT,'
            '  level INTEGER,'
            '  name TEXT,'
            '  latitude REAL,'
            '  longitude REAL'
            ')',
            'CREATE INDEX IF NOT EXISTS idx_admin_division_parent_code ON admin_division(parent_code)',
            'CREATE INDEX IF NOT EXISTS idx_admin_division_level ON admin_division(level)',
            'CREATE INDEX IF NOT EXISTS idx_admin_division_name ON admin_division(name)',
        ],
    },
    'region': {
        'json': GEO_DIR / 'regions.json',
        'sql': GEO_DIR / 'region.sql',
        'expected_rows': 6,
        'ddl': [
            'CREATE TABLE IF NOT EXISTS region ('
            '  id INTEGER PRIMARY KEY,'
            '  name TEXT,'
            '  translations_json TEXT,'
            '  wiki_data_id TEXT'
            ')',
        ],
    },
    'city': {
        'json': GEO_DIR / 'city.min.json',
        'sql': GEO_DIR / 'city.sql',
        'expected_rows': 337,
        'ddl': [
            'CREATE TABLE IF NOT EXISTS city ('
            '  code TEXT PRIMARY KEY,'
            '  name TEXT,'
            '  province_code TEXT,'
            '  year_code TEXT'
            ')',
        ],
    },
}


def build_one(name: str, spec: dict) -> dict:
    """构建单个表的 SQL 文件。返回统计信息。"""
    json_path = spec['json']
    sql_path = spec['sql']
    expected = spec['expected_rows']

    with open(json_path, 'r', encoding='utf-8') as f:
        rows = json.load(f)

    if len(rows) != expected:
        raise RuntimeError(
            f'{name}: 源 JSON 行数 {len(rows)} 与预期 {expected} 不符，停下报告'
        )

    # 内存 SQLite，中间步骤
    conn = sqlite3.connect(':memory:')
    cur = conn.cursor()
    for stmt in spec['ddl']:
        cur.execute(stmt)
    cur.execute(f'DELETE FROM {name}')
    conn.commit()

    if name == 'admin_division':
        for r in rows:
            lat = r['latitude']
            lng = r['longitude']
            cur.execute(
                'INSERT OR REPLACE INTO admin_division '
                '(code, parent_code, level, name, latitude, longitude) '
                'VALUES (?, ?, ?, ?, ?, ?)',
                (
                    r['code'],
                    r['parentCode'],
                    int(r['level']),
                    r['name'],
                    float(lat) if lat != '' else None,
                    float(lng) if lng != '' else None,
                ),
            )
    elif name == 'region':
        for r in rows:
            cur.execute(
                'INSERT OR REPLACE INTO region '
                '(id, name, translations_json, wiki_data_id) '
                'VALUES (?, ?, ?, ?)',
                (
                    int(r['id']),
                    r['name'],
                    json.dumps(r['translations'], ensure_ascii=False),
                    r.get('wikiDataId'),
                ),
            )
    elif name == 'city':
        for r in rows:
            cur.execute(
                'INSERT OR REPLACE INTO city '
                '(code, name, province_code, year_code) '
                'VALUES (?, ?, ?, ?)',
                (r['c'], r['n'], r['p'], r['y']),
            )
    conn.commit()

    actual_rows = cur.execute(f'SELECT COUNT(*) FROM {name}').fetchone()[0]
    if actual_rows != expected:
        raise RuntimeError(
            f'{name}: 插入后行数 {actual_rows} 与预期 {expected} 不符'
        )

    # 导出 *.sql：只导出本表的 DDL + INSERT，事务包裹
    lines = ['BEGIN TRANSACTION;']
    for stmt in spec['ddl']:
        lines.append(stmt + ';')
    # 取出全部行，参数化还原成 INSERT 语句
    cols = [d[0] for d in cur.execute(f'SELECT * FROM {name} LIMIT 0').description]
    all_rows = cur.execute(f'SELECT {", ".join(cols)} FROM {name}').fetchall()
    for row in all_rows:
        values = []
        for v in row:
            if v is None:
                values.append('NULL')
            elif isinstance(v, (int, float)):
                values.append(str(v))
            else:
                # 字符串：用单引号，转义内部单引号
                escaped = str(v).replace("'", "''")
                values.append(f"'{escaped}'")
        lines.append(
            f"INSERT INTO {name} ({', '.join(cols)}) VALUES ({', '.join(values)});"
        )
    lines.append('COMMIT;')

    sql_text = '\n'.join(lines) + '\n'
    with open(sql_path, 'w', encoding='utf-8') as f:
        f.write(sql_text)
    conn.close()

    # 统计
    sha = hashlib.sha256(sql_text.encode('utf-8')).hexdigest()
    byte_size = os.path.getsize(sql_path)
    insert_count = sql_text.count('INSERT INTO')

    return {
        'table': name,
        'sql_path': str(sql_path),
        'rows': actual_rows,
        'insert_count': insert_count,
        'bytes': byte_size,
        'sha256': sha,
        'has_begin': 'BEGIN TRANSACTION;' in sql_text,
        'has_commit': 'COMMIT;' in sql_text,
    }


def main():
    print('=' * 60)
    print('geo 数据 SQL 构建')
    print('=' * 60)
    results = []
    for name, spec in SOURCES.items():
        print(f'\n-- 构建 {name} --')
        r = build_one(name, spec)
        results.append(r)
        print(f"   产物: {r['sql_path']}")
        print(f"   行数: {r['rows']} (INSERT 语句: {r['insert_count']})")
        print(f"   字节: {r['bytes']}")
        print(f"   sha256: {r['sha256']}")
        print(f"   BEGIN/COMMIT: {r['has_begin']}/{r['has_commit']}")

    print('\n' + '=' * 60)
    print('验证: INSERT 语句数与源 JSON 条数对比')
    print('=' * 60)
    all_ok = True
    for r in results:
        ok = r['rows'] == r['insert_count']
        print(f"   {r['table']}: 行数={r['rows']} INSERT={r['insert_count']} -> {'一致' if ok else '不一致'}")
        if not ok:
            all_ok = False

    print('\n' + '=' * 60)
    print('BUILD-REPORT.md 生成中...')
    print('=' * 60)
    from datetime import datetime, timezone
    now = datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')
    report = [f'# geo 数据 SQL 构建报告', f'', f'- 构建时间：{now}', f'- 构建脚本：assets/tool/build_geo_sql.py', f'- 源数据：3 个 JSON（保留在原位，未改动）', f'', f'## 产物', f'', f'| 文件 | 表名 | 行数 | 字节数 | sha256 |', f'|---|---|---|---|---|']
    for r in results:
        fname = Path(r['sql_path']).name
        report.append(f"| {fname} | {r['table']} | {r['rows']} | {r['bytes']} | {r['sha256']} |")
    report += [f'', f'## 验证', f'', f'- INSERT 语句数与源 JSON 条数对比：{"一致" if all_ok else "不一致"}', f'- 每个 *.sql 含 BEGIN TRANSACTION / COMMIT：{all(r["has_begin"] and r["has_commit"] for r in results)}', f'- 每个 *.sql 含 CREATE TABLE：是', f'', f'## 幂等性', f'', f'- 脚本可重复运行，产物可覆盖，结果一致。', f'']
    report_path = GEO_DIR / 'BUILD-REPORT.md'
    with open(report_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(report))
    print(f'   报告: {report_path}')

    print('\n完成。')
    if not all_ok:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
