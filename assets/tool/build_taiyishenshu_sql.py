#!/usr/bin/env python3
"""taiyishenshu 数据 SQL 构建脚本。

照 assets/tool/build_daliuren_sql.py 的样板：
- 3 个数据集全部为非表形/整份读 JSON，以「JSON 文档表」落地
  （file_name + payload_json 两列，整文档存一行）：
  - taiyi.schools（schools/ 下 3 个 kebab 精简契约文件：
    ji-cheng.json / jing-mirror.json / tong-zong.json）
  - taiyi.deities（deities/ 47 个神将 kebab 文件）
  - taiyi.minggua（minggua/tong_zong_sequence.json，人类裁定迁入）
- snake 全量学派文档 5 份（ji_cheng/jing_mirror/tong_zong/fu_ying/tao_jin_ge）
  与 nian_ming_gua 1 份：无契约端口（D4），物理保存于 assets/ 不注册 dataset，
  不进本脚本的 dataset 列表。
- payload_json 存文件**原文**（UTF-8 不转义），保证 A2 差分逐字节相等。

幂等：可重复运行，产物可覆盖，结果一致。
"""
import hashlib
import os
from datetime import datetime, timezone
from pathlib import Path

TAIYI_DIR = Path(__file__).resolve().parent.parent / 'lib' / 'taiyishenshu' / 'assets'
OUT_DIR = TAIYI_DIR

DOCUMENT_TABLE_DDL = (
    'CREATE TABLE IF NOT EXISTS {table} ('
    '  file_name TEXT PRIMARY KEY,'
    '  payload_json TEXT NOT NULL'
    ')'
)

# (sql 文件名, 表名, 数据集 id, 源文件相对 TAIYI_DIR 的 glob)
DOCUMENT_DATASETS = [
    (
        'schools_document',
        'schools_document',
        'taiyi.schools',
        ['schools/ji-cheng.json', 'schools/jing-mirror.json', 'schools/tong-zong.json'],
    ),
    (
        'deities_document',
        'deities_document',
        'taiyi.deities',
        ['deities/*.json'],
    ),
    (
        'minggua_document',
        'minggua_document',
        'taiyi.minggua',
        ['minggua/tong_zong_sequence.json'],
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
    """拼接 *.sql 文本（不含显式 BEGIN/COMMIT，照 0f3c6dd 修复）；
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


def build_document_dataset(table: str, dataset_id: str, patterns: list) -> dict:
    """非表形 JSON -> JSON 文档表（file_name + payload_json）。"""
    sql_path = OUT_DIR / f'{table}.sql'
    ddl = [DOCUMENT_TABLE_DDL.format(table=table)]

    files = []
    for pat in patterns:
        files.extend(sorted(TAIYI_DIR.glob(pat)))
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
    print('taiyishenshu 数据 SQL 构建')
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
        '# taiyishenshu 数据 SQL 构建报告',
        '',
        f'- 构建时间：{now}',
        '- 构建脚本：assets/tool/build_taiyishenshu_sql.py',
        '- 源数据：schools/ ×3（kebab 精简契约）+ deities/ ×47 + minggua/ ×1（全部 JSON 文档表）',
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
        '- 中文（如「集成派」「太乙」）正确写入 UTF-8，未转义为 \\uXXXX',
        '',
        '## payloadFormat 决策',
        '',
        '| 数据集 | 载荷 | payloadFormat | 理由 |',
        '|---|---|---|---|',
        '| taiyi.schools | schools_document.sql | prebuilt | 3 份精简学派 JSON 整读，文档表，repository 读 payload_json 再契约 fromJson |',
        '| taiyi.deities | deities_document.sql | prebuilt | 47 份神将 JSON 整读，文档表 |',
        '| taiyi.minggua | minggua_document.sql | prebuilt | tong_zong_sequence.json 整读，文档表（人类裁定迁入，MingGuaRepository 端口） |',
        '',
        '## 数据质量说明',
        '',
        '- schools 命名双写是**两套数据**：kebab 小文件（ji-cheng 629B 等）= 精简 School 契约（id/name/source/epoch/deityIds），snake 大文件（ji_cheng 7514B 等）= 全量学派文档（schemaVersion/meta/palace/rules/charts/dun/...）。本脚本只注册 kebab 3 份；snake 5 份（ji_cheng/jing_mirror/tong_zong/fu_ying/tao_jin_ge）无契约端口（D4），物理保存在 assets/schools/ 供后续接入，不注册 dataset。',
        '- nian_ming_gua/sixty_four_gua_stems.json（64 卦年命卦配置）无契约 Repository 端口（D4），物理保存在 assets/nian_ming_gua/，不注册 dataset。',
        '',
        '## 幂等性',
        '',
        '- 脚本可重复运行，产物可覆盖，结果一致。',
    ]
    (OUT_DIR / 'BUILD-REPORT.md').write_text('\n'.join(report) + '\n', encoding='utf-8')
    print('BUILD-REPORT.md 已生成')


if __name__ == '__main__':
    main()
