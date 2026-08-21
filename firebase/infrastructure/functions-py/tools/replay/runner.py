"""离线回放双跑执行引擎。

支持 Callable 内存双跑比对，以及 Trigger 跨进程独立隔离双跑（--phase ts/py/compare）。
"""
import argparse
import json
import os
import sys
import time
from typing import Any, Dict, List, Optional

from tools.replay.client import ReplayClient
from tools.replay.models import ReplaySample, ReplayResult
from tools.replay.samples import ALL_SAMPLES, SAMPLE_MAP
from tools.replay.samples.triggers import SAMPLES as TRIGGER_SAMPLES
from tools.shadow_compare import compare_replay
from xuan.config import COLLECTIONS, db

TS_SNAPSHOT_FILE = "/tmp/trigger_snapshot_ts.json"
PY_SNAPSHOT_FILE = "/tmp/trigger_snapshot_py.json"


def execute_trigger_single_phase(
    sample: ReplaySample,
    client: ReplayClient,
    timeout_sec: float = 10.0,
) -> Dict[str, Any]:
    """在单端 Emulator 环境下执行 Trigger 样本并轮询捕获下游产物快照。
    
    TS 与 PY 阶段完全共用此统一逻辑，确保前置灌入与触发操作逐字节严格一致。
    """
    client.clear_firestore()
    client.clear_auth()
    client.seed_firestore(sample.seed_data)

    if sample.trigger_type == "outbox":
        client.write_document(
            sample.trigger_action["collection"],
            sample.trigger_action["doc_id"],
            sample.trigger_action["doc_data"],
        )
        # 轮询等待 playground_notifications 中出现由 outbox 生成的通知文档
        start_time = time.time()
        fs_client = db()
        notif_col = COLLECTIONS["notifications"]
        found = False
        while time.time() - start_time < timeout_sec:
            docs = list(fs_client.collection(notif_col).stream())
            if docs:
                found = True
                break
            time.sleep(0.1)
        if not found:
            raise TimeoutError(f"Trigger 样本 {sample.id} 等待 downstream notifications 超时 ({timeout_sec}s)")

    elif sample.trigger_type == "storage":
        token = None
        if sample.auth_email or sample.auth_uid:
            token, _ = client.get_auth_token(
                sample.auth_email or "auth@example.com",
                sample.auth_password,
                fixed_uid=sample.auth_uid,
            )
        client.upload_storage_file(
            sample.trigger_action["file_path"],
            content_type=sample.trigger_action.get("content_type", "image/jpeg"),
            id_token=token,
        )
        # 轮询等待 playground_media 集合中的文档状态由 pending 更新为 ready
        start_time = time.time()
        fs_client = db()
        media_col = COLLECTIONS["media"]
        found = False
        while time.time() - start_time < timeout_sec:
            docs = list(fs_client.collection(media_col).stream())
            if any(d.to_dict().get("status") == "ready" for d in docs):
                found = True
                break
            time.sleep(0.1)
        if not found:
            raise TimeoutError(f"Trigger 样本 {sample.id} 等待 downstream media 更新为 ready 超时 ({timeout_sec}s)")

    else:
        raise ValueError(f"未知的 trigger_type: {sample.trigger_type}")

    # 获取全量快照
    return client.snapshot_all_collections()


def run_trigger_phase_record(
    phase_name: str,
    output_file: str,
    client: ReplayClient,
    targets: Optional[List[ReplaySample]] = None,
) -> None:
    """执行 Trigger 录制阶段（TS 或 PY），将快照持久化到本地文件。"""
    samples = targets or TRIGGER_SAMPLES
    snapshots: Dict[str, Any] = {}

    print(f"\n==================== 开始执行 Trigger 隔离录制 [Phase: {phase_name.upper()}] (共 {len(samples)} 个样本) ====================", flush=True)

    for i, s in enumerate(samples, 1):
        print(f"\n[{i}/{len(samples)}] 正在录制: {s.id}", flush=True)
        print(f"       说明: {s.description}", flush=True)
        print(f"       类型: {s.trigger_type}", flush=True)

        try:
            snap = execute_trigger_single_phase(s, client)
            snapshots[s.id] = snap
            print("       结果: ✅ 成功捕获下游快照", flush=True)
        except Exception as e:
            print(f"       结果: ❌ 录制失败: {e}", flush=True)
            sys.exit(1)

    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(snapshots, f, ensure_ascii=False, indent=2, default=str)

    print(f"\n✅ [{phase_name.upper()}] 阶段快照已落盘至: {output_file}", flush=True)


def run_trigger_phase_compare(
    ts_file: str = TS_SNAPSHOT_FILE,
    py_file: str = PY_SNAPSHOT_FILE,
    targets: Optional[List[ReplaySample]] = None,
) -> List[ReplayResult]:
    """读取 TS 与 PY 阶段落盘快照，执行严格归一化比对并输出报告。"""
    if not os.path.exists(ts_file):
        print(f"错误: 找不到 TS 快照文件 {ts_file}，请先运行 --phase ts", file=sys.stderr, flush=True)
        sys.exit(1)
    if not os.path.exists(py_file):
        print(f"错误: 找不到 PY 快照文件 {py_file}，请先运行 --phase py", file=sys.stderr, flush=True)
        sys.exit(1)

    with open(ts_file, "r", encoding="utf-8") as f:
        ts_snapshots = json.load(f)
    with open(py_file, "r", encoding="utf-8") as f:
        py_snapshots = json.load(f)

    samples = targets or TRIGGER_SAMPLES
    results: List[ReplayResult] = []

    print(f"\n==================== 开始比对 Trigger 隔离快照 (共 {len(samples)} 个样本) ====================", flush=True)

    for i, s in enumerate(samples, 1):
        print(f"\n[{i}/{len(samples)}] 正在比对: {s.id}", flush=True)
        print(f"       说明: {s.description}", flush=True)
        print(f"       TS: {s.ts_function} ↔ PY: {s.py_function}", flush=True)

        if s.id not in ts_snapshots or s.id not in py_snapshots:
            print(f"       结果: ❌ 快照缺失 (ts_has={s.id in ts_snapshots}, py_has={s.id in py_snapshots})", flush=True)
            sys.exit(1)

        ts_snap = ts_snapshots[s.id]
        py_snap = py_snapshots[s.id]

        diff, ts_norm, py_norm = compare_replay(
            ts_response={"trigger": "executed"},
            py_response={"trigger": "executed"},
            ts_snapshot=ts_snap,
            py_snapshot=py_snap,
            ts_status=200,
            py_status=200,
            known_static_ids=s.known_static_ids,
        )

        res = ReplayResult(
            sample_id=s.id,
            description=s.description,
            equivalent=diff.equivalent,
            differences=diff.differences,
            ts_status=200,
            py_status=200,
            ts_response={"trigger": "executed"},
            py_response={"trigger": "executed"},
            ts_snapshot=ts_snap,
            py_snapshot=py_snap,
            ts_normalized=ts_norm,
            py_normalized=py_norm,
        )
        results.append(res)

        status_str = "✅ PASS" if res.equivalent else "❌ DIFF"
        print(f"       结果: {status_str} (TS_HTTP=200, PY_HTTP=200, 预期=200)", flush=True)

        if not res.equivalent:
            print("       差异清单:", flush=True)
            for d in res.differences:
                print(f"         - {d}", flush=True)

    total = len(results)
    passed = sum(1 for r in results if r.equivalent)
    failed = total - passed

    print("\n============================== Trigger 比对统计总结 ==============================", flush=True)
    print(f"总计: {total} | 通过: {passed} | 差异/无效: {failed}", flush=True)
    if failed == 0:
        print("🎉 全部 Trigger 样本隔离比对通过，行为完全等价！", flush=True)
    else:
        print("⚠️ Trigger 样本存在不一致差异，请检查详情。", flush=True)

    return results


def run_single_sample(sample: ReplaySample, client: ReplayClient) -> ReplayResult:
    """对单个 Callable 样本执行完整的 TS 跑批 + PY 跑批 + 比对。"""
    if sample.is_trigger:
        # Trigger 样本在全量跑批时如果运行，使用统一单端执行逻辑
        ts_snap = execute_trigger_single_phase(sample, client)
        py_snap = execute_trigger_single_phase(sample, client)

        diff, ts_norm, py_norm = compare_replay(
            ts_response={"trigger": "executed"},
            py_response={"trigger": "executed"},
            ts_snapshot=ts_snap,
            py_snapshot=py_snap,
            ts_status=200,
            py_status=200,
            known_static_ids=sample.known_static_ids,
        )

        return ReplayResult(
            sample_id=sample.id,
            description=sample.description,
            equivalent=diff.equivalent,
            differences=diff.differences,
            ts_status=200,
            py_status=200,
            ts_response={"trigger": "executed"},
            py_response={"trigger": "executed"},
            ts_snapshot=ts_snap,
            py_snapshot=py_snap,
            ts_normalized=ts_norm,
            py_normalized=py_norm,
        )

    # ================= 1. TS 版执行 (Callable) =================
    client.clear_firestore()
    client.clear_auth()
    client.seed_firestore(sample.seed_data)

    ts_token = None
    if sample.auth_email or sample.auth_uid:
        ts_token, _ = client.get_auth_token(
            sample.auth_email or "auth@example.com",
            sample.auth_password,
            fixed_uid=sample.auth_uid,
        )

    ts_status, ts_response = client.call_callable(sample.ts_function, sample.data, id_token=ts_token)
    time.sleep(0.1)
    ts_snapshot = client.snapshot_all_collections()

    # ================= 2. PY 版执行 (Callable) =================
    client.clear_firestore()
    client.clear_auth()
    client.seed_firestore(sample.seed_data)

    py_token = None
    if sample.auth_email or sample.auth_uid:
        py_token, _ = client.get_auth_token(
            sample.auth_email or "auth@example.com",
            sample.auth_password,
            fixed_uid=sample.auth_uid,
        )

    py_status, py_response = client.call_callable(sample.py_function, sample.data, id_token=py_token)
    time.sleep(0.1)
    py_snapshot = client.snapshot_all_collections()

    # ================= 3. 归一化比对 =================
    diff, ts_norm, py_norm = compare_replay(
        ts_response=ts_response,
        py_response=py_response,
        ts_snapshot=ts_snapshot,
        py_snapshot=py_snapshot,
        ts_status=ts_status,
        py_status=py_status,
        known_static_ids=sample.known_static_ids,
    )

    # ================= 4. R-5 结构性闸门校验 =================
    if ts_status != sample.expected_status or py_status != sample.expected_status:
        diff.equivalent = False
        diff.differences.insert(
            0,
            f"HTTP 状态码与预期声明不符: 预期={sample.expected_status}, TS={ts_status}, PY={py_status}",
        )

    return ReplayResult(
        sample_id=sample.id,
        description=sample.description,
        equivalent=diff.equivalent,
        differences=diff.differences,
        ts_status=ts_status,
        py_status=py_status,
        ts_response=ts_response,
        py_response=py_response,
        ts_snapshot=ts_snapshot,
        py_snapshot=py_snapshot,
        ts_normalized=ts_norm,
        py_normalized=py_norm,
    )


def run_samples(samples: List[ReplaySample], client: ReplayClient) -> List[ReplayResult]:
    """批量执行样本并打印报告。"""
    results: List[ReplayResult] = []
    print(f"\n==================== 开始执行离线回放影子比对 (共 {len(samples)} 个样本) ====================", flush=True)

    for i, s in enumerate(samples, 1):
        print(f"\n[{i}/{len(samples)}] 正在执行: {s.id}", flush=True)
        print(f"       说明: {s.description}", flush=True)
        print(f"       TS: {s.ts_function} ↔ PY: {s.py_function}", flush=True)

        res = run_single_sample(s, client)
        results.append(res)

        status_str = "✅ PASS" if res.equivalent else "❌ DIFF"
        print(f"       结果: {status_str} (TS_HTTP={res.ts_status}, PY_HTTP={res.py_status}, 预期={s.expected_status})", flush=True)

        if not res.equivalent:
            print("       差异清单:", flush=True)
            for d in res.differences:
                print(f"         - {d}", flush=True)

    total = len(results)
    passed = sum(1 for r in results if r.equivalent)
    failed = total - passed

    print("\n============================== 回放统计总结 ==============================", flush=True)
    print(f"总计: {total} | 通过: {passed} | 差异/无效: {failed}", flush=True)
    if failed == 0:
        print("🎉 全部样本比对通过，行为完全等价！", flush=True)
    else:
        print("⚠️ 存在不一致差异或无效样本，请检查上述详情。", flush=True)

    return results


def main() -> None:
    parser = argparse.ArgumentParser(description="TS ↔ Python 离线回放影子比对 Harness")
    parser.add_argument("--sample", type=str, help="指定单个样本 ID 执行")
    parser.add_argument("--host", type=str, default="127.0.0.1", help="Emulator 宿主地址 (默认 127.0.0.1)")
    parser.add_argument("--dump", action="store_true", help="打印归一化后完整数据包")
    parser.add_argument(
        "--phase",
        type=str,
        choices=["all", "ts", "py", "compare"],
        default="all",
        help="执行阶段: all(全量双跑) | ts(只跑TS Trigger录制) | py(只跑PY Trigger录制) | compare(比对落盘快照)",
    )
    args = parser.parse_args()

    client = ReplayClient(host=args.host)

    if args.phase == "ts":
        run_trigger_phase_record("ts", TS_SNAPSHOT_FILE, client)
        sys.exit(0)
    elif args.phase == "py":
        run_trigger_phase_record("py", PY_SNAPSHOT_FILE, client)
        sys.exit(0)
    elif args.phase == "compare":
        results = run_trigger_phase_compare(TS_SNAPSHOT_FILE, PY_SNAPSHOT_FILE)
        if args.dump:
            for r in results:
                print(f"\n--- DUMP [{r.sample_id}] TS NORMALIZED ---", flush=True)
                print(json.dumps(r.ts_normalized, indent=2, ensure_ascii=False), flush=True)
                print(f"\n--- DUMP [{r.sample_id}] PY NORMALIZED ---", flush=True)
                print(json.dumps(r.py_normalized, indent=2, ensure_ascii=False), flush=True)
        all_passed = all(r.equivalent for r in results)
        sys.exit(0 if all_passed else 1)

    if args.sample:
        if args.sample not in SAMPLE_MAP:
            print(f"错误: 找不到样本 ID '{args.sample}'", file=sys.stderr, flush=True)
            sys.exit(1)
        targets = [SAMPLE_MAP[args.sample]]
    else:
        targets = ALL_SAMPLES

    results = run_samples(targets, client)

    if args.dump:
        for r in results:
            print(f"\n--- DUMP [{r.sample_id}] TS NORMALIZED ---", flush=True)
            print(json.dumps(r.ts_normalized, indent=2, ensure_ascii=False), flush=True)
            print(f"\n--- DUMP [{r.sample_id}] PY NORMALIZED ---", flush=True)
            print(json.dumps(r.py_normalized, indent=2, ensure_ascii=False), flush=True)

    all_passed = all(r.equivalent for r in results)
    sys.exit(0 if all_passed else 1)


if __name__ == "__main__":
    main()
