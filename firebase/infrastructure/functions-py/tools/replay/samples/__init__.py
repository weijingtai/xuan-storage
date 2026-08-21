"""样本集聚合导出。"""
from typing import Dict, List
from tools.replay.models import ReplaySample
from tools.replay.samples.posts import SAMPLES as POST_SAMPLES
from tools.replay.samples.replies import SAMPLES as REPLY_SAMPLES
from tools.replay.samples.conversations import SAMPLES as CONV_SAMPLES
from tools.replay.samples.reputation import SAMPLES as REP_SAMPLES
from tools.replay.samples.other_callables import SAMPLES as OTHER_SAMPLES
from tools.replay.samples.triggers import SAMPLES as TRIGGER_SAMPLES

ALL_SAMPLES: List[ReplaySample] = [
    *POST_SAMPLES,
    *REPLY_SAMPLES,
    *CONV_SAMPLES,
    *REP_SAMPLES,
    *OTHER_SAMPLES,
    *TRIGGER_SAMPLES,
]

SAMPLE_MAP: Dict[str, ReplaySample] = {s.id: s for s in ALL_SAMPLES}
