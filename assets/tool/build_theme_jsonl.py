#!/usr/bin/env python3
"""主题预设 YAML -> XRAP JSON Lines 载荷构建脚本。

读 theme/config/presets/*.yaml，扁平化为 token，产出 *.jsonl 载荷
（行 schema {"k","v","t"}，无 g 字段，设计 §4.3 / R4-P0），
并算 sha256 / bytes / rowCount 真值，写进 BUILD-REPORT.md。

形制照 assets/tool/build_geo_sql.py。幂等：可重复运行，产物可覆盖。

三条 SHALL（构建期拒绝出包，承接自 theme-token-customization-contract）：
  SHALL-1 (spec.md:60-66, A14d)：数值字段非数值（如 radius="8px"）-> 非零退出
  SHALL-2 (spec.md:86, A14a)：未知字段 -> 按 schema 过滤并告警，行为明确
  SHALL-3 (评审 #5, A14e)：整体形状非法 -> 非零退出

退出码：
  0  全部预设构建成功
  1  构建失败（SHALL-1/3 违规、源文件不存在、扁平化异常等）
  2  参数错误
"""
import hashlib
import json
import sys
from pathlib import Path

import yaml

# ----------------------------------------------------------------------------
# 路径与常量
# ----------------------------------------------------------------------------

# theme 仓的预设源目录（xuan-migration 是容器目录，theme 是兄弟仓）。
# 向上查找 'theme/config/presets'，使脚本在 main 与深层 worktree 都能工作
# （入库路径以 main 为准，但 worktree 深两层，固定层数会指错；向上查找兼容两者）。
def _find_presets_dir() -> Path:
    here = Path(__file__).resolve().parent
    for cand in [here, *here.parents]:
        d = cand / 'theme' / 'config' / 'presets'
        if d.is_dir():
            return d
    raise FileNotFoundError('找不到 theme/config/presets 目录（应在 xuan-migration 容器内）')

PRESETS_DIR = _find_presets_dir()

# 载荷产物目录（与 geo 的 assets/lib/geo/ 同级形制）
OUT_DIR = Path(__file__).resolve().parent.parent / 'lib' / 'theme'

# 内置世代（generation 0）的载荷源。themeDatasetId 是单数 'theme.package'，
# kThemeBundledManifest 是单数，内置世代只有一个兜底主题 = default。
# 其余预设只验证脚本通用性，不回填 manifest（属远端下发，本任务不做）。
BUNDLED_PRESET = 'default'

# 预设清单（按文件名，去 .yaml）。派工 A1 要求跑通 4 个现有预设。
PRESETS = ['default', 'dark', 'ai-mingli-ink', 'ai-starry-bronze']

# ----------------------------------------------------------------------------
# schema：扁平化规则 + 三条 SHALL 的校验依据
# ----------------------------------------------------------------------------

# YAML 顶层合法结构（设计 §0.0 + design.md:115-125 形状）：
#   version: 2
#   metadata: {id, display_name, author, created_for}
#   light: {semantic:{}, components:{}, chart:{}}
#   dark:  {semantic:{}, components:{}, chart:{}}
#
# 扁平化只对 light/dark 两个 brightness 分区下降（design.md:119-124）。
# metadata / version 不进载荷（它们不是主题 token，是源文件元信息）。
_TOP_LEVEL_BRIGHTNESS = {'light', 'dark'}

# light/dark 下的合法子分区（design.md:119-124：components + chart；semantic 是
# 现有 yaml 的事实分区，载荷要保留它，故一并允许）。
# 未知顶层 key -> SHALL-3（整体形状非法）。
# 未知 light/dark 子分区 key -> SHALL-2（未知字段，按 schema 过滤并告警）。
_BRIGHTNESS_SUBSECTIONS = {'semantic', 'components', 'chart'}

# SHALL-2 未知字段策略：构建期决定收不收（A14a）。
# 本脚本采取「告警 + 丢弃」：未知子分区不进载荷，但打印 WARNING 到 stderr，
# 行为明确（不是「视情况」）。非零退出留给 SHALL-1/3 的硬违规。
# 理由：spec.md:86 + design.md:136「未知字段忽略除非 schema-lint 显式开启」，
# 构建期丢弃 + 告警 = 明确的「收不收」决定（收 = 告警丢弃，不硬拒）。

# SHALL-1 数值字段：这些后缀的叶子必须是数值（int/float，非 bool）。
# 依据 spec.md:62 举例（text.font_size, icon.size, opacity, min_width 等）+
# 实测 4 个预设的数值叶子后缀（见 schema 调研）。
# font_weight/fontWeight 是字符串枚举（w400-w900/normal/bold），不是数值，不在此列。
_NUMERIC_FIELD_SUFFIXES = frozenset({
    'radius',
    'width',            # border.width
    'blur_radius',
    'offset_x',
    'offset_y',
    'opacity',
    'all',              # padding.all / margin.all
    'top', 'bottom', 'left', 'right',
    'font_size',        # components 侧（snake_case）
    'fontSize',         # chart.typography 侧（camelCase）
    'height',           # chart.typography.height（行高，数值）
    'tickLength',
    'longTickLength',
    'innerPadding',
    'outerPadding',
    'guideDotRadius',
    'starHolderRadius',
    'ringStrokeWidth',
    'min_width', 'min_height', 'max_width', 'max_height',  # spec.md:62 举例
    'gap', 'icon_size', 'z_index',  # spec.md:62 举例 / fixture 标量
})


class BuildError(Exception):
    """构建期错误，导致非零退出（SHALL-1/3 硬违规或扁平化异常）。"""


# 类型标记（与 S5a fixture 的 _typeOf 一致，设计 §4.3）
def _type_tag(value) -> str:
    if value is None:
        return 'z'
    if isinstance(value, bool):  # 注意：bool 是 int 子类，先判 bool
        return 'b'
    if isinstance(value, (int, float)):
        return 'n'
    if isinstance(value, str):
        return 's'
    if isinstance(value, list):
        return 'a'
    # Map 不该到这里（扁平化时遇 Map 应继续下降）；到此即契约违反
    raise BuildError(f'token 值不得是 Map（嵌套应在构建期展平），但遇到了 {type(value).__name__}')


# ----------------------------------------------------------------------------
# 三条 SHALL 校验
# ----------------------------------------------------------------------------

def _validate_top_level_shape(name: str, doc) -> None:
    """SHALL-3：整体形状非法 -> 构建期拒绝（非零退出）。

    合法形状：顶层是 dict，至少含 light 或 dark 之一，且 light/dark 是 dict。
    version/metadata 可有可无（不进载荷）。
    """
    if not isinstance(doc, dict):
        raise BuildError(
            f'{name}: 整体形状非法 -- 顶层不是 mapping（是 {type(doc).__name__}），'
            f'无法产出主题载荷（SHALL-3 / A14e）'
        )
    brightness_keys = [k for k in doc if k in _TOP_LEVEL_BRIGHTNESS]
    if not brightness_keys:
        raise BuildError(
            f'{name}: 整体形状非法 -- 顶层缺 light/dark 任一 brightness 分区，'
            f'无法产出主题载荷（SHALL-3 / A14e）'
        )
    for bk in brightness_keys:
        bv = doc[bk]
        if not isinstance(bv, dict):
            raise BuildError(
                f'{name}: 整体形状非法 -- {bk} 不是 mapping（是 {type(bv).__name__}），'
                f'无法产出主题载荷（SHALL-3 / A14e）'
            )


def _validate_numeric_field(name: str, flat_key: str, value) -> None:
    """SHALL-1：数值字段非数值 -> 构建期拒绝（非零退出）。

    判据：叶子的最后一段名在 _NUMERIC_FIELD_SUFFIXES 里，则值必须是数值（int/float），
    且不是 bool（bool 是 int 子类，但主题里 bool 字段不在数值清单）。
    非数值（如 radius="8px"）-> BuildError。
    """
    seg = flat_key.rsplit('.', 1)[-1]
    if seg not in _NUMERIC_FIELD_SUFFIXES:
        return
    if isinstance(value, bool):
        raise BuildError(
            f'{name}: 数值字段 {flat_key!r} 收到 bool 值 {value!r}，'
            f'应为数值（SHALL-1 / A14d）'
        )
    if not isinstance(value, (int, float)):
        raise BuildError(
            f'{name}: 数值字段 {flat_key!r} 收到非数值 {value!r}'
            f'（{type(value).__name__}），应为数值（SHALL-1 / A14d）'
        )


def _flatten(name: str, brightness: str, node, prefix: str, out: dict, unknown_log: list) -> None:
    """递归扁平化，产出 flat_key -> value。设计 §6.6 第 1 步构造规则。

    - 扁平 key = 从根到叶子的路径以 '.' 连接
    - 递归下降遇非 Map 值停止（该值是叶子）
    - List 视为叶子，不再下降
    - 空 Map {} 不产生任何 key
    - SHALL-2：brightness 子分区外的 key 记为未知字段（告警 + 丢弃）
    """
    if isinstance(node, dict):
        if not node:
            # 空 Map 不产生 key（§6.6 第 1 步）
            return
        for k, v in node.items():
            child_key = f'{prefix}.{k}' if prefix else f'{brightness}.{k}'
            # SHALL-2：brightness 下一层只允许 _BRIGHTNESS_SUBSECTIONS
            if prefix == brightness and k not in _BRIGHTNESS_SUBSECTIONS:
                unknown_log.append(
                    f'{name}: 未知字段 {child_key!r}（{brightness} 子分区不在 '
                    f'{sorted(_BRIGHTNESS_SUBSECTIONS)} 内），丢弃（SHALL-2 / A14a）'
                )
                continue
            _flatten(name, brightness, v, child_key, out, unknown_log)
        return
    # 叶子（含 List、str、num、bool、None）
    # SHALL-1：数值字段类型校验
    _validate_numeric_field(name, prefix, value=node)
    out[prefix] = node


def build_one(name: str, presets_dir: Path | None = None) -> dict:
    """构建单个预设的 jsonl 载荷。返回统计信息。

    [presets_dir] 默认用 PRESETS_DIR；测试可传入临时目录喂坏 fixture。
    """
    base = presets_dir if presets_dir is not None else PRESETS_DIR
    src = base / f'{name}.yaml'
    if not src.exists():
        raise BuildError(f'{name}: 源文件不存在：{src}')

    with open(src, 'r', encoding='utf-8') as f:
        try:
            doc = yaml.safe_load(f)
        except yaml.YAMLError as e:
            raise BuildError(f'{name}: YAML 解析失败：{e}')

    # SHALL-3：整体形状校验
    _validate_top_level_shape(name, doc)

    unknown_log = []
    flat_tokens: dict = {}
    for bk in _TOP_LEVEL_BRIGHTNESS:
        if bk not in doc:
            continue
        _flatten(name, bk, doc[bk], bk, flat_tokens, unknown_log)

    # 产出 jsonl：每行 {"k","v","t"}，无 g 字段（R4-P0）
    # 按 key 字典序排序，保证幂等 + 稳定 diff（对齐 §6.6 第 6 步稳定排序精神）
    lines = []
    for k in sorted(flat_tokens):
        v = flat_tokens[k]
        t = _type_tag(v)
        lines.append(json.dumps({'k': k, 'v': v, 't': t}, ensure_ascii=False))

    payload_text = '\n'.join(lines) + '\n'  # 末尾 LF
    payload_bytes = payload_text.encode('utf-8')
    sha = hashlib.sha256(payload_bytes).hexdigest()
    row_count = len(lines)

    out_path = OUT_DIR / f'{name}.jsonl'
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with open(out_path, 'wb') as f:
        f.write(payload_bytes)

    # 输出未知字段告警到 stderr（SHALL-2，行为明确）
    for msg in unknown_log:
        print(f'WARNING: {msg}', file=sys.stderr)

    return {
        'name': name,
        'src': str(src),
        'out': str(out_path),
        'rows': row_count,
        'bytes': len(payload_bytes),
        'sha256': sha,
        'is_bundled': name == BUNDLED_PRESET,
        'unknown_warnings': len(unknown_log),
    }


def _write_report(results: list) -> None:
    from datetime import datetime, timezone
    now = datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')
    lines = [
        '# 主题预设 JSON Lines 载荷构建报告',
        '',
        f'- 构建时间：{now}',
        f'- 构建脚本：assets/tool/build_theme_jsonl.py',
        f'- 源目录：theme/config/presets/*.yaml（theme 仓，不改源文件）',
        f'- 产物目录：assets/lib/theme/*.jsonl',
        '',
        '## 产物',
        '',
        '| 预设 | 文件 | 行数 | 字节数 | sha256 | 内置世代 | 未知字段告警 |',
        '|---|---|---|---|---|---|---|',
    ]
    for r in results:
        fname = Path(r['out']).name
        bundled = '✓ generation 0' if r['is_bundled'] else ''
        lines.append(
            f"| {r['name']} | {fname} | {r['rows']} | {r['bytes']} | "
            f"{r['sha256']} | {bundled} | {r['unknown_warnings']} |"
        )
    lines += [
        '',
        '## 载荷格式（设计 §4.3，R4-P0）',
        '',
        '- 行 schema：`{"k","v","t"}`（key / value / type），扁平 token',
        '- **无 `g` 字段**（generation 是运行时 materializer 入参，非构建期可预知）',
        '- `v` 不得是 Map（嵌套在构建期展平）；List 视为叶子',
        '- `t`：`s`/`n`/`b`/`a`/`z`（string/number/bool/array/null）',
        '- UTF-8，LF 换行，末尾 LF',
        '- `rowCount` = jsonl 行数；`payloadSha256` = 对载荷整段字节算 sha256 hex 小写',
        '',
        '## 内置世代（generation 0）',
        '',
        f'`kThemeBundledManifest`（`core/lib/model/theme_dataset.dart`）回填 `{BUNDLED_PRESET}.jsonl` '
        f'的三个真值（payloadSha256 / payloadBytes / declaredRowCount）。',
        '其余预设的 jsonl 是构建产物（验证脚本通用性），manifest 不在本任务回填（属远端下发）。',
        '',
        '## 三条 SHALL（构建期拒绝出包）',
        '',
        '- **SHALL-1**（spec.md:60-66, A14d）：数值字段非数值（如 radius="8px"）-> 非零退出',
        '- **SHALL-2**（spec.md:86, A14a）：未知字段 -> 告警 + 丢弃，行为明确（非"视情况"）',
        '- **SHALL-3**（评审 #5, A14e）：整体形状非法 -> 非零退出',
        '',
        '## 幂等性',
        '',
        '- 脚本可重复运行，产物可覆盖，结果一致（key 按字典序排序保证稳定 diff）。',
        '',
    ]
    report_path = OUT_DIR / 'BUILD-REPORT.md'
    with open(report_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))


def main(argv=None) -> int:
    argv = argv if argv is not None else sys.argv[1:]
    # 支持 --presets-dir <path> 覆盖预设目录（测试用，喂坏 fixture）
    overrides_dir: Path | None = None
    rest = []
    i = 0
    while i < len(argv):
        a = argv[i]
        if a == '--presets-dir':
            if i + 1 >= len(argv):
                print('错误：--presets-dir 需要一个参数', file=sys.stderr)
                return 2
            overrides_dir = Path(argv[i + 1])
            i += 2
        else:
            rest.append(a)
            i += 1
    targets = rest if rest else PRESETS
    for t in targets:
        if t not in PRESETS:
            print(f'错误：未知预设 {t!r}，可选 {PRESETS}', file=sys.stderr)
            return 2

    src_dir = overrides_dir if overrides_dir is not None else PRESETS_DIR
    print('=' * 60)
    print('主题预设 YAML -> JSON Lines 载荷构建')
    print(f'源目录：{src_dir}')
    print(f'产物目录：{OUT_DIR}')
    print('=' * 60)

    results = []
    failed = False
    for name in targets:
        print(f'\n-- 构建 {name} --')
        try:
            r = build_one(name, presets_dir=overrides_dir)
            results.append(r)
            tag = ' [BUNDLED -> generation 0]' if r['is_bundled'] else ''
            print(f"   产物: {r['out']}{tag}")
            print(f"   行数(rowCount): {r['rows']}")
            print(f"   字节(payloadBytes): {r['bytes']}")
            print(f"   sha256: {r['sha256']}")
            if r['unknown_warnings']:
                print(f"   未知字段告警: {r['unknown_warnings']} 条（见 stderr，SHALL-2）")
        except BuildError as e:
            print(f'   构建失败：{e}', file=sys.stderr)
            failed = True

    if failed:
        print('\n' + '=' * 60, file=sys.stderr)
        print('构建失败（SHALL 违规或源文件问题），非零退出。', file=sys.stderr)
        print('=' * 60, file=sys.stderr)
        return 1

    _write_report(results)
    print('\n' + '=' * 60)
    print('BUILD-REPORT.md 已生成')
    print('=' * 60)
    print('\n完成。')
    return 0


if __name__ == '__main__':
    sys.exit(main())
