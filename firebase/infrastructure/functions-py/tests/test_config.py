"""集合名必须与 TS 侧 src/index.ts 的 COLLECTIONS 完全一致。"""
import re
from pathlib import Path

from xuan.config import COLLECTIONS, REGION

TS_INDEX = Path(__file__).parents[2] / "functions" / "src" / "index.ts"
if not TS_INDEX.exists():
    TS_INDEX = Path(__file__).resolve().parents[2] / "functions" / "src" / "index.ts"



def test_region_与_ts_一致():
    assert REGION == "us-central1"


def test_集合名与_ts_逐项一致():
    """直接解析 TS 源文件，避免两边各自维护常量而悄悄漂移。"""
    src = TS_INDEX.read_text(encoding="utf-8")
    block = re.search(r"COLLECTIONS = \{(.*?)\} as const", src, re.S)
    assert block, "没找到 TS 侧 COLLECTIONS 定义"

    ts_pairs = dict(re.findall(r"(\w+):\s*'([^']+)'", block.group(1)))
    assert ts_pairs, "TS 侧 COLLECTIONS 解析为空"

    # 键名转换：TS 用 camelCase，Python 用 snake_case
    def to_snake(name: str) -> str:
        return re.sub(r"(?<!^)(?=[A-Z])", "_", name).lower()

    for ts_key, ts_value in ts_pairs.items():
        py_key = to_snake(ts_key)
        assert py_key in COLLECTIONS, f"Python 侧缺少集合 {py_key}"
        assert COLLECTIONS[py_key] == ts_value, (
            f"集合名不一致：{py_key} → Python={COLLECTIONS[py_key]} TS={ts_value}"
        )
