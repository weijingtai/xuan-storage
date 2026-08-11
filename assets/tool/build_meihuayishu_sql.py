#!/usr/bin/env python3
"""meihuayishu 数据 SQL 构建脚本（照 build_qizhengsiyu_sql.py 样板）。

字典数据库 dictionary.db（3 表：characters / pinyin / etymology）→
单一 SQL 载荷 dictionary_database.sql（DatasetPayloadFormat.prebuilt），
drift（DictionaryDatabase）打开时表已存在（IF NOT EXISTS 跳过 CREATE），
installer customStatement 灌入数据，领域 Repository 从 drift 表直读。

幂等：可重复运行，产物可覆盖，结果一致。
"""
import hashlib
import sqlite3
from datetime import datetime, timezone
from pathlib import Path

# 输入：storage 备份的 dictionary.db（drift 包 assets 下，与源仓逐字节一致）
SRC_DB = Path(__file__).resolve().parent.parent.parent / 'drift' / 'lib' / 'meihuayishu' / 'assets' / 'sql' / 'dictionary.db'
OUT_DIR = Path(__file__).resolve().parent.parent.parent / 'assets' / 'lib' / 'meihuayishu' / 'assets'
OUT_SQL = OUT_DIR / 'dictionary_database.sql'

# 3 张业务表（sqlite_sequence 为 AUTOINCREMENT 系统表，排除）
TABLES = ['characters', 'pinyin', 'etymology']


def _sql_str(v) -> str:
    """Python 值 -> SQL 字面量（None -> NULL；单引号转义；数字直出）。"""
    if v is None:
        return 'NULL'
    if isinstance(v, (int, float)):
        return str(v)
    escaped = str(v).replace("'", "''")
    return f"'{escaped}'"


def _wrap_sql(ddl: list, inserts: list, delete_tables: list) -> str:
    """拼接 *.sql 文本（无 BEGIN/COMMIT，Web WasmDatabase 嵌套事务冲突修复，
    照 build_qizhengsiyu_sql.py；DDL 后 DELETE 保证重装幂等）。"""
    lines = [s + ';' for s in ddl]
    lines.extend(f'DELETE FROM {t};' for t in delete_tables)
    lines.extend(inserts)
    return '\n'.join(lines) + '\n'


def main():
    conn = sqlite3.connect(str(SRC_DB))
    ddl, inserts, delete_tables = [], [], []
    for table in TABLES:
        # 保留源库 DDL（drift 表结构兼容：snake_case 列名一致）
        (ddl_src,) = conn.execute(
            "SELECT sql FROM sqlite_master WHERE type='table' AND name=?", (table,)).fetchone()
        ddl.append(ddl_src.rstrip(';').replace('CREATE TABLE ', 'CREATE TABLE IF NOT EXISTS ', 1))
        delete_tables.append(table)
        # 列名（双引号引用，保留字安全）
        cols = [r[1] for r in conn.execute(f'PRAGMA table_info({table})').fetchall()]
        quoted = ', '.join(f'"{c}"' for c in cols)
        row_count = 0
        for row in conn.execute(f'SELECT * FROM {table}'):
            values = [_sql_str(v) for v in row]
            inserts.append(
                f'INSERT INTO {table} ({quoted}) VALUES ({", ".join(values)});')
            row_count += 1
        total_rows = locals().get('total_rows', 0) + row_count
        print(f'{table}: {row_count} 行')
    conn.close()

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    total_rows = locals().get('total_rows', 0)
    sql_text = _wrap_sql(ddl, inserts, delete_tables)
    OUT_SQL.write_text(sql_text, encoding='utf-8')

    sha = hashlib.sha256(sql_text.encode('utf-8')).hexdigest()
    print(f'产物: {OUT_SQL} ({len(sql_text.encode("utf-8"))}B) sha256={sha}')

    # BUILD-REPORT
    report = OUT_DIR / 'BUILD-REPORT.md'
    report.write_text(
        f'# meihuayishu 数据 SQL 构建报告\n\n'
        f'- 构建时间：{datetime.now(timezone.utc).isoformat()}\n'
        f'- 构建脚本：assets/tool/build_meihuayishu_sql.py\n'
        f'- 源数据：dictionary.db（storage drift 备份，与源仓逐字节一致）\n\n'
        f'## 产物\n\n'
        f'| 文件 | 表名 | 行数 | 字节数 | sha256 |\n|---|---|---|---|---|\n'
        f'| dictionary_database.sql | characters/pinyin/etymology | '
        f'{total_rows} | {len(sql_text.encode("utf-8"))} | {sha} |\n',
        encoding='utf-8',
    )
    print('BUILD-REPORT.md 已生成')



if __name__ == '__main__':
    main()
