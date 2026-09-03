#!/usr/bin/env python3
import subprocess
import os
import re
import sys

DATASETS = [
    # daliuren (4)
    ("daliuren", "daliuren.official_data", "assets/lib/daliuren/assets/official_data_document.sql", "assets/lib/daliuren/daliuren_datasets.dart"),
    ("daliuren", "daliuren.keti", "assets/lib/daliuren/assets/keti_document.sql", "assets/lib/daliuren/daliuren_datasets.dart"),
    ("daliuren", "daliuren.shen_sha", "assets/lib/daliuren/assets/shen_sha_document.sql", "assets/lib/daliuren/daliuren_datasets.dart"),
    ("daliuren", "daliuren.school_dataset", "assets/lib/daliuren/assets/school_dataset_document.sql", "assets/lib/daliuren/daliuren_datasets.dart"),
    # kanyu (3)
    ("kanyu", "kanyu.rules", "assets/lib/kanyu/assets/rules_document.sql", "assets/lib/kanyu/kanyu_datasets.dart"),
    ("kanyu", "kanyu.static_data", "assets/lib/kanyu/assets/static_data_document.sql", "assets/lib/kanyu/kanyu_datasets.dart"),
    ("kanyu", "kanyu.schema", "assets/lib/kanyu/assets/schema_document.sql", "assets/lib/kanyu/kanyu_datasets.dart"),
    # taiyishenshu (3)
    ("taiyishenshu", "taiyi.schools", "assets/lib/taiyishenshu/assets/schools_document.sql", "assets/lib/taiyishenshu/taiyishenshu_datasets.dart"),
    ("taiyishenshu", "taiyi.deities", "assets/lib/taiyishenshu/assets/deities_document.sql", "assets/lib/taiyishenshu/taiyishenshu_datasets.dart"),
    ("taiyishenshu", "taiyi.minggua", "assets/lib/taiyishenshu/assets/minggua_document.sql", "assets/lib/taiyishenshu/taiyishenshu_datasets.dart"),
    # tiebanshenshu (4)
    ("tiebanshenshu", "tiebanshenshu.tiao_wen", "assets/lib/tiebanshenshu/assets/tiao_wen.sql", "assets/lib/tiebanshenshu/tiebanshenshu_datasets.dart"),
    ("tiebanshenshu", "tiebanshenshu.kao_ke", "assets/lib/tiebanshenshu/assets/kao_ke_document.sql", "assets/lib/tiebanshenshu/tiebanshenshu_datasets.dart"),
    ("tiebanshenshu", "tiebanshenshu.shaozishu", "assets/lib/tiebanshenshu/assets/shaozishu_document.sql", "assets/lib/tiebanshenshu/tiebanshenshu_datasets.dart"),
    ("tiebanshenshu", "tiebanshenshu.formulas", "assets/lib/tiebanshenshu/assets/formulas_document.sql", "assets/lib/tiebanshenshu/tiebanshenshu_datasets.dart"),
    # ziwei (3)
    ("ziwei", "ziwei.star_catalog", "assets/lib/ziwei/assets/star_catalog_document.sql", "assets/lib/ziwei/ziwei_datasets.dart"),
    ("ziwei", "ziwei.star_metadata", "assets/lib/ziwei/assets/star_metadata_document.sql", "assets/lib/ziwei/ziwei_datasets.dart"),
    ("ziwei", "ziwei.four_transformations", "assets/lib/ziwei/assets/four_transformations_document.sql", "assets/lib/ziwei/ziwei_datasets.dart"),
    # four_zhu_card (3)
    ("four_zhu_card", "four_zhu.default_template", "assets/lib/four_zhu_card/assets/default_template_document.sql", "assets/lib/four_zhu_card/four_zhu_datasets.dart"),
    ("four_zhu_card", "four_zhu.market_templates", "assets/lib/four_zhu_card/assets/market_templates_document.sql", "assets/lib/four_zhu_card/four_zhu_datasets.dart"),
    ("four_zhu_card", "four_zhu.outbox_templates", "assets/lib/four_zhu_card/assets/outbox_templates_document.sql", "assets/lib/four_zhu_card/four_zhu_datasets.dart"),
    # qizhengsiyu (8)
    ("qizhengsiyu", "qizheng.star_position_status", "assets/lib/qizhengsiyu/assets/star_position_status.sql", "assets/lib/qizhengsiyu/qizhengsiyu_datasets.dart"),
    ("qizhengsiyu", "qizheng.ge_ju", "assets/lib/qizhengsiyu/assets/ge_ju.sql", "assets/lib/qizhengsiyu/qizhengsiyu_datasets.dart"),
    ("qizhengsiyu", "qizheng.zhou_tian", "assets/lib/qizhengsiyu/assets/zhou_tian_document.sql", "assets/lib/qizhengsiyu/qizhengsiyu_datasets.dart"),
    ("qizhengsiyu", "qizheng.ephemeris", "assets/lib/qizhengsiyu/assets/ephemeris_document.sql", "assets/lib/qizhengsiyu/qizhengsiyu_datasets.dart"),
    ("qizhengsiyu", "qizheng.shen_sha", "assets/lib/qizhengsiyu/assets/shen_sha_document.sql", "assets/lib/qizhengsiyu/qizhengsiyu_datasets.dart"),
    ("qizhengsiyu", "qizheng.hua_yao", "assets/lib/qizhengsiyu/assets/hua_yao_document.sql", "assets/lib/qizhengsiyu/qizhengsiyu_datasets.dart"),
    ("qizhengsiyu", "qizheng.ge_ju_rules", "assets/lib/qizhengsiyu/assets/ge_ju_rules_document.sql", "assets/lib/qizhengsiyu/qizhengsiyu_datasets.dart"),
    ("qizhengsiyu", "qizheng.ge_ju_content", "assets/lib/qizhengsiyu/assets/ge_ju_content_document.sql", "assets/lib/qizhengsiyu/qizhengsiyu_datasets.dart"),
]

def get_actual_metrics(sql_path):
    sha_cmd = f"shasum -a 256 '{sql_path}'"
    sha_out = subprocess.check_output(sha_cmd, shell=True).decode().strip().split()[0]

    bytes_cmd = f"wc -c < '{sql_path}'"
    bytes_out = int(subprocess.check_output(bytes_cmd, shell=True).decode().strip())

    try:
        rows_cmd = f"LC_ALL=C grep -c '^INSERT' '{sql_path}'"
        rows_out = int(subprocess.check_output(rows_cmd, shell=True).decode().strip())
    except subprocess.CalledProcessError as e:
        if e.returncode == 1:
            rows_out = 0
        else:
            raise

    return sha_out, bytes_out, rows_out

def parse_manifest(manifest_dart_path, dataset_id, use_qizheng_branch=False):
    if use_qizheng_branch and "qizhengsiyu" in manifest_dart_path:
        try:
            content = subprocess.check_output(
                f"git show wip/qizheng-manifest-fix:{manifest_dart_path}",
                shell=True
            ).decode()
        except Exception:
            content = open(manifest_dart_path).read()
    else:
        content = open(manifest_dart_path).read()

    pos = content.find(f"datasetId: '{dataset_id}'")
    if pos == -1:
        raise ValueError(f"Could not find {dataset_id} in {manifest_dart_path}")
    block = content[pos:pos+500]

    sha_m = re.search(r"payloadSha256:\s*'([0-9a-fA-F]+)'", block)
    bytes_m = re.search(r"payloadBytes:\s*([0-9]+)", block)
    rows_m = re.search(r"declaredRowCount:\s*([0-9]+)", block)

    if not (sha_m and bytes_m and rows_m):
        raise ValueError(f"Could not parse manifest fields for {dataset_id} in {manifest_dart_path}")

    return sha_m.group(1).lower(), int(bytes_m.group(1)), int(rows_m.group(1))

def run_scan(output_file, use_qizheng_branch=False):
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    os.chdir(repo_root)

    mismatches = []
    matches = []

    report_lines = []
    banner = "ASSETS MANIFEST vs ACTUAL .SQL TRUTH SCAN"
    if use_qizheng_branch:
        banner += " (including wip/qizheng-manifest-fix for qizhengsiyu)"
    report_lines.append("=" * 100)
    report_lines.append(banner)
    report_lines.append("=" * 100)

    header = f"{'Domain':<14} | {'Dataset ID':<30} | {'Status':<8} | {'Field':<10} | {'Declared':<64} | {'Actual'}"
    report_lines.append(header)
    report_lines.append("-" * 140)

    for domain, dataset_id, sql_rel_path, dart_rel_path in DATASETS:
        act_sha, act_bytes, act_rows = get_actual_metrics(sql_rel_path)
        dec_sha, dec_bytes, dec_rows = parse_manifest(dart_rel_path, dataset_id, use_qizheng_branch)

        is_sha_match = (act_sha == dec_sha)
        is_bytes_match = (act_bytes == dec_bytes)
        is_rows_match = (act_rows == dec_rows)

        all_match = is_sha_match and is_bytes_match and is_rows_match

        status_str = "MATCH" if all_match else "MISMATCH"
        if all_match:
            matches.append(dataset_id)
            line = f"{domain:<14} | {dataset_id:<30} | {status_str:<8} | (all 3)   | sha: {dec_sha[:8]}... bytes: {dec_bytes:<7} rows: {dec_rows:<5} | ALL MATCH"
            report_lines.append(line)
        else:
            mismatches.append(dataset_id)
            diff_fields = []
            if not is_sha_match:
                diff_fields.append("sha256")
            if not is_bytes_match:
                diff_fields.append("bytes")
            if not is_rows_match:
                diff_fields.append("rows")

            line = f"{domain:<14} | {dataset_id:<30} | {status_str:<8} | {','.join(diff_fields):<10} |"
            report_lines.append(line)
            if not is_sha_match:
                s_line = f"  - sha256 : dec={dec_sha} | act={act_sha}"
                report_lines.append(s_line)
            if not is_bytes_match:
                b_line = f"  - bytes  : dec={dec_bytes} | act={act_bytes}"
                report_lines.append(b_line)
            if not is_rows_match:
                r_line = f"  - rows   : dec={dec_rows} | act={act_rows}"
                report_lines.append(r_line)

    summary_1 = f"\nTotal datasets scanned: {len(DATASETS)}"
    summary_2 = f"Matches: {len(matches)} / {len(DATASETS)}"
    summary_3 = f"Mismatches: {len(mismatches)} / {len(DATASETS)}"
    report_lines.extend([summary_1, summary_2, summary_3])

    if mismatches:
        report_lines.append("\nMismatched datasets:")
        for m in mismatches:
            report_lines.append(f"  - {m}")
        if any("qizheng" in m for m in mismatches) and not use_qizheng_branch:
            report_lines.append("\nNote: qizhengsiyu (8 datasets) was already fixed on branch wip/qizheng-manifest-fix (commit ee706d9) and is pending human merge into main.")

    output_path = os.path.join(repo_root, "docs", output_file)
    with open(output_path, "w") as f:
        f.write("\n".join(report_lines) + "\n")
    print("\n".join(report_lines))
    print(f"\nReport saved to {output_path}")

def main():
    use_qizheng = "--with-qizheng" in sys.argv
    out_name = "manifest_truth_scan_after.txt" if "--after" in sys.argv else "manifest_truth_scan_current.txt"
    if "--out" in sys.argv:
        idx = sys.argv.index("--out")
        if idx + 1 < len(sys.argv):
            out_name = sys.argv[idx + 1]

    run_scan(out_name, use_qizheng)

if __name__ == "__main__":
    main()
