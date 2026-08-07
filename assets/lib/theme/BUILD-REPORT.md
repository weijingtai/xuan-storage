# 主题预设 JSON Lines 载荷构建报告

- 构建脚本：assets/tool/build_theme_jsonl.py
- 源目录：theme/config/presets/*.yaml（theme 仓，不改源文件）
- 产物目录：assets/lib/theme/*.jsonl

## 产物

| 预设 | 文件 | 行数 | 字节数 | sha256 | 内置世代 | 未知字段告警 |
|---|---|---|---|---|---|---|
| default | default.jsonl | 338 | 27458 | aa62ab4aaa45038a2625dc0fcf26daee616c1a7c40d00bf50ab081f15d634af1 | ✓ generation 0 | 0 |

## 载荷格式（设计 §4.3，R4-P0）

- 行 schema：`{"k","v","t"}`（key / value / type），扁平 token
- **无 `g` 字段**（generation 是运行时 materializer 入参，非构建期可预知）
- `v` 不得是 Map（嵌套在构建期展平）；List 视为叶子
- `t`：`s`/`n`/`b`/`a`/`z`（string/number/bool/array/null）
- UTF-8，LF 换行，末尾 LF
- `rowCount` = jsonl 行数；`payloadSha256` = 对载荷整段字节算 sha256 hex 小写

## 内置世代（generation 0）

`kThemeBundledManifest`（`core/lib/model/theme_dataset.dart`）回填 `default.jsonl` 的三个真值（payloadSha256 / payloadBytes / declaredRowCount）。
其余预设的 jsonl 是构建产物（验证脚本通用性），manifest 不在本任务回填（属远端下发）。

## 三条 SHALL（构建期拒绝出包）

- **SHALL-1**（spec.md:60-66, A14d）：数值字段非数值（如 radius="8px"）-> 非零退出
- **SHALL-2**（spec.md:86, A14a）：未知字段 -> 告警 + 丢弃，行为明确（非"视情况"）
- **SHALL-3**（评审 #5, A14e）：整体形状非法 -> 非零退出

## 幂等性

- 脚本可重复运行，产物可覆盖，结果一致（key 按字典序排序保证稳定 diff）。
