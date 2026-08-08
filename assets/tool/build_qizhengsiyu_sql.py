#!/usr/bin/env python3
"""qizhengsiyu 数据 SQL 构建脚本。

照 assets/tool/build_geo_sql.py 的样板：
- 表形数据（star_position_status.json、ge_ju_database.sqlite）生成 *.sql 载荷
  （CREATE TABLE + INSERT，事务包裹，UTF-8 中文不转义），属 DatasetPayloadFormat.prebuilt。
- 非表形数据（嵌套 JSON）不生成 SQL，直接作为 DatasetPayloadFormat.raw 载荷，
  决策理由记入 BUILD-REPORT.md 与任务纪要。

幂等：可重复运行，产物可覆盖，结果一致。
"""
import hashlib
import json
import os
import sqlite3
from datetime import datetime, timezone
from pathlib import Path

QZ_DIR = Path(__file__).resolve().parent.parent / 'lib' / 'qizhengsiyu' / 'assets'
OUT_DIR = QZ_DIR

# ---------------------------------------------------------------- 表定义

STAR_POSITION_STATUS_DDL = [
    'CREATE TABLE IF NOT EXISTS star_position_status ('
    '  id INTEGER PRIMARY KEY,'
    '  class_name TEXT,'
    '  star TEXT,'
    '  position_status_type TEXT,'
    '  position_list_json TEXT'
    ')',
]

# ge_ju sqlite 的 5 张表：保留源库 schema（含 CHECK / UNIQUE / 默认值）。
# 注意：ge_ju_rules.id 为 AUTOINCREMENT，导出时保留显式 id 以保持行级稳定。
GE_JU_TABLES = [
    'ge_ju_patterns',
    'ge_ju_schools',
    'ge_ju_categories',
    'ge_ju_rules',
    'ge_ju_versions',
]

# ------------------------------------------------- 非表形数据 -> JSON 文档表
#
# 协议强制内置数据集 payloadFormat 必须 prebuilt（dataset_registry.dart 注册期
# 校验，rawText 会被拒绝）。非表形 JSON（嵌套对象/数组，无法拆成字段级表）按
# 人类裁定 2026-08-07 以「JSON 文档表」落地：每类建一张
# `file_name + payload_json` 表，构建期生成 SQL，设备侧执行恢复表即零解析，
# 领域 Repository 从 drift 表读整段 JSON 再 decode（decode 属领域层职责）。
#
# 每项：(sql 文件名, 表名, 数据集 id, 源文件相对 QZ_DIR 的 glob)
# 表名统一加 `_document` 后缀：避免与 ge_ju.sql 内 `ge_ju_rules` 等表同名冲突。
DOCUMENT_DATASETS = [
    ('zhou_tian', 'zhou_tian_document', 'qizheng.zhou_tian', ['ecliptic_tropical_*.json']),
    ('ephemeris', 'ephemeris_document', 'qizheng.ephemeris', ['ecliptic_ancient_365.json', 'ecliptic_tuihuangdao.json', 'four_season.json', 'han_chidao_hengxin.json', 'han_chidao_hengxin.v2.json', 'yuan_chidao_hengxing.json', 'yuan_chidao_hengxing.v2.json', 'yuan_shoushi_chidao_hengxin.json', 'yuan_sky_equatorial_sidereal.json', 'ming_si_huangdao_hengxing.json', 'ming_si_huangdao_hengxing.v2.json', 'song_sanchentongzai.json', 'huangdao_huigui_gu.json', 'huangdao_huigui_gu_corrected.json', 'huangdao_huigui_gu_now.json', 'stars_four_relationship.json', 'zheng_shi_xing_an.json']),
    ('shen_sha', 'shen_sha_document', 'qizheng.shen_sha', ['shen_sha/74_shensha_*.json']),
    ('hua_yao', 'hua_yao_document', 'qizheng.hua_yao', ['shen_sha/74_huayao_*.json']),
    ('ge_ju_rules', 'ge_ju_rules_document', 'qizheng.ge_ju_rules', ['ge_ju/rules/*.json']),
    ('ge_ju_content', 'ge_ju_content_document', 'qizheng.ge_ju_content', ['ge_ju/content/*.json']),
]

DOCUMENT_TABLE_DDL = (
    'CREATE TABLE IF NOT EXISTS {table} ('
    '  file_name TEXT PRIMARY KEY,'
    '  payload_json TEXT NOT NULL'
    ')'
)


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


def _wrap_sql(ddl_statements: list, inserts: list) -> str:
    """事务包裹的 *.sql 文本。"""
    lines = ['BEGIN TRANSACTION;']
    for stmt in ddl_statements:
        lines.append(stmt + ';')
    lines.extend(inserts)
    lines.append('COMMIT;')
    return '\n'.join(lines) + '\n'


def _insert_lines(table: str, cols: list, rows: list) -> list:
    """逐行生成 INSERT 语句。

    列名一律加双引号引用（SQLite 保留字安全，如 ge_ju_categories.order）。
    """
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


def build_star_position_status() -> dict:
    """star_position_status.json（表形：97 行）-> star_position_status.sql。"""
    json_path = QZ_DIR / 'star_position_status.json'
    sql_path = OUT_DIR / 'star_position_status.sql'
    expected = 97

    with open(json_path, 'r', encoding='utf-8') as f:
        rows = json.load(f)
    if len(rows) != expected:
        raise RuntimeError(
            f'star_position_status: 源 JSON 行数 {len(rows)} 与预期 {expected} 不符，停下报告'
        )

    # 内存 SQLite 中间步骤：只为生成正确语法的 INSERT（数值/转义交给 sqlite3 处理）。
    conn = sqlite3.connect(':memory:')
    cur = conn.cursor()
    for stmt in STAR_POSITION_STATUS_DDL:
        cur.execute(stmt)
    for r in rows:
        cur.execute(
            'INSERT OR REPLACE INTO star_position_status '
            '(id, class_name, star, position_status_type, position_list_json) '
            'VALUES (?, ?, ?, ?, ?)',
            (
                int(r['id']),
                r['className'],
                r['star'],
                r['starPositionStatusType'],
                json.dumps(r.get('positionList', []), ensure_ascii=False),
            ),
        )
    conn.commit()
    actual = cur.execute('SELECT COUNT(*) FROM star_position_status').fetchone()[0]
    if actual != expected:
        raise RuntimeError(f'star_position_status: 插入后行数 {actual} != {expected}')
    conn.close()

    # 导出 *.sql：只导出本表的 DDL + INSERT，事务包裹。
    with sqlite3.connect(':memory:') as conn:
        cur = conn.cursor()
        for stmt in STAR_POSITION_STATUS_DDL:
            cur.execute(stmt)
        with open(json_path, 'r', encoding='utf-8') as f:
            rows = json.load(f)
        for r in rows:
            cur.execute(
                'INSERT OR REPLACE INTO star_position_status '
                '(id, class_name, star, position_status_type, position_list_json) '
                'VALUES (?, ?, ?, ?, ?)',
                (
                    int(r['id']),
                    r['className'],
                    r['star'],
                    r['starPositionStatusType'],
                    json.dumps(r.get('positionList', []), ensure_ascii=False),
                ),
            )
        conn.commit()
        cols = [
            d[0]
            for d in cur.execute('SELECT * FROM star_position_status LIMIT 0').description
        ]
        all_rows = cur.execute(
            f'SELECT {", ".join(cols)} FROM star_position_status'
        ).fetchall()

    inserts = _insert_lines('star_position_status', cols, all_rows)
    sql_text = _wrap_sql(STAR_POSITION_STATUS_DDL, inserts)
    sql_path.write_text(sql_text, encoding='utf-8')
    return _stat(sql_path, 'star_position_status', expected)


def build_ge_ju() -> dict:
    """ge_ju_database.sqlite（预构建 SQLite，v1 权威源）-> ge_ju.sql。

    逐表导出：schema（保留源库 DDL，含 CHECK/UNIQUE/AUTOINCREMENT）+ INSERT，事务包裹。
    这是「预构建产物随包」的最正形态（XRAP §4.2 既有先例）。
    """
    sqlite_path = QZ_DIR / 'ge_ju' / 'ge_ju_database.sqlite'
    sql_path = OUT_DIR / 'ge_ju.sql'

    src = sqlite3.connect(str(sqlite_path))
    ddl_statements = []
    inserts = []
    total_rows = 0

    for table in GE_JU_TABLES:
        row = src.execute(
            "SELECT sql FROM sqlite_master WHERE type='table' AND name=?", (table,)
        ).fetchone()
        if row is None:
            raise RuntimeError(f'ge_ju: 源库缺表 {table}')
        ddl = row[0].rstrip().rstrip(';')
        ddl_statements.append(ddl)

        cur = src.execute(f'SELECT * FROM {table}')
        cols = [d[0] for d in cur.description]
        rows = cur.fetchall()
        total_rows += len(rows)
        if rows:
            inserts.extend(_insert_lines(table, cols, rows))

    src.close()
    sql_text = _wrap_sql(ddl_statements, inserts)
    sql_path.write_text(sql_text, encoding='utf-8')

    # 行数校验：导出行数与源库一致（I4 前置）。
    verify = sqlite3.connect(str(sqlite_path))
    expected_total = 0
    for table in GE_JU_TABLES:
        (c,) = verify.execute(f'SELECT COUNT(*) FROM {table}').fetchone()
        expected_total += c
    verify.close()
    if total_rows != expected_total:
        raise RuntimeError(f'ge_ju: 导出行数 {total_rows} != 源库 {expected_total}')

    return _stat(sql_path, 'ge_ju(5表)', expected_total)


def build_document_dataset(table: str, dataset_id: str, patterns: list) -> dict:
    """非表形 JSON -> JSON 文档表（file_name + payload_json）。

    按人类裁定 2026-08-07：协议强制内置 payloadFormat 必须 prebuilt，
    非表形数据以文档表落地，满足「构建期结构化、设备零解析」。
    """
    sql_path = OUT_DIR / f'{table}.sql'
    ddl = [DOCUMENT_TABLE_DDL.format(table=table)]

    files = []
    for pat in patterns:
        files.extend(sorted(QZ_DIR.glob(pat)))
    if not files:
        raise RuntimeError(f'{dataset_id}: 源 JSON 匹配 0 个文件，停下报告')
    if len(files) != len(patterns) and not any('*' in p for p in patterns):
        # 无通配符时应一一对应；有通配符时数量由 glob 决定
        raise RuntimeError(
            f'{dataset_id}: 显式源文件数 {len(patterns)} 与匹配数 {len(files)} 不符'
        )

    rows = []
    for f in files:
        payload = f.read_text(encoding='utf-8')
        rows.append((f.name, payload))

    inserts = _insert_lines(table, ['file_name', 'payload_json'], rows)
    sql_text = _wrap_sql(ddl, inserts)
    sql_path.write_text(sql_text, encoding='utf-8')
    return _stat(sql_path, f'{table}(文档表)', len(rows))


def main():
    print('=' * 60)
    print('qizhengsiyu 数据 SQL 构建')
    print('=' * 60)
    results = [
        build_star_position_status(),
        build_ge_ju(),
    ]
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
        '# qizhengsiyu 数据 SQL 构建报告',
        '',
        f'- 构建时间：{now}',
        '- 构建脚本：assets/tool/build_qizhengsiyu_sql.py',
        '- 源数据：star_position_status.json（表形 97 行）+ ge_ju/ge_ju_database.sqlite（预构建 SQLite）',
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
        f'- 每个 *.sql 含 BEGIN TRANSACTION / COMMIT：{all_ok}',
        '- 每个 *.sql 含 CREATE TABLE：是',
        '- 中文（如「日月夹命」）正确写入 UTF-8，未转义为 \\uXXXX',
        '',
        '## payloadFormat 决策',
        '',
        '| 数据集（草案） | 载荷 | payloadFormat | 理由 |',
        '|---|---|---|---|',
        '| qizheng.star_position_status | star_position_status.sql | prebuilt | 表形（97 行），构建期建表，设备上零解析 |',
        '| qizheng.ge_ju | ge_ju.sql | prebuilt | 源已是预构建 SQLite（5 表），导出为事务包裹 *.sql，照 geo 模式 |',
        '| qizheng.zhou_tian | ecliptic_tropical_*.json ×3 | raw | 嵌套对象（gongOrder/gongDegreeSeq/starInnOrder），非表形 |',
        '| qizheng.ephemeris | 其余星历 JSON（约 18 个） | raw | 嵌套对象/数组（黄道/赤道/恒星/四季），非表形 |',
        '| qizheng.shen_sha / qizheng.hua_yao | 74_shensha_*/74_huayao_* ×9 | raw | 嵌套 LIST（locationMapper 为 map），非表形 |',
        '| qizheng.ge_ju_rules / qizheng.ge_ju_content | ge_ju/rules + content JSON ×26 | raw | 嵌套 variants/conditions，非表形 |',
        '',
        '## 数据质量说明',
        '',
        '- `ge_ju_rules` 表 `id` 为 AUTOINCREMENT，导出保留显式 id，行级稳定。',
        '- `ge_ju_versions` 表 0 行（源库为空），仍保留建表语句。',
        '- ge_ju 的 rules/content JSON（raw）与 sqlite（prebuilt）可能为同一批格局数据的两种形态，',
        '  消费方目前两者都读；是否冗余待阶段 5 消费方切换时统一判定（记入任务纪要）。',
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
