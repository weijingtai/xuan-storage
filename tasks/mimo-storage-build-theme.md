# 任务: storage-build-theme（占位纪要 · BUILD-THEME）
状态: **占位** —— 由 S5a ACT 07 收尾创建，防三条 SHALL 在移交中丢失（R5 Finding F2）。
正式立项时补充：范围 / 验收 / 依赖（S5a 的 `kThemeBundledManifest` 真值回填）。

## 目标

主题构建脚本：`theme/config/presets/*.yaml` → `.jsonl` 预构建载荷（扁平 token）+ sha256 / bytes / rowCount
真值 → `DatasetManifest`（回填 `core/lib/model/theme_dataset.dart` 的 `kThemeBundledManifest` 占位）。
照 T1 的 `assets/tool/build_geo_sql.py` 形制。

## 三条 SHALL（承接自外部契约 theme-token-customization-contract，不得丢失）

| # | 出处 | 内容 | 承接动作 |
|---|---|---|---|
| 1 | `spec.md` :60 | 数值非法（如 radius 为 `"8px"`）→ 构建期捕获并拒绝出包（A14d） | 构建脚本对数值字段做类型校验，非法即构建失败 |
| 2 | `spec.md` :86 | 未知字段 → 构建期决定收不收（A14a），设备端合并层一视同仁不透传白名单 | 构建脚本扁平化时按 schema 过滤/告警未知 key |
| 3 | 第二轮评审 #5 | 整体形状非法（结构不符 schema）→ 构建期拒绝（A14e 单字段回退由 `token_loader` 兜底） | 构建脚本对组件形状做 schema 校验，非法即构建失败 |

## 指向

- 设计 §4.3：载荷格式（`{"k","v","t"}` 行 schema，**无 `g` 字段**，R4-P0）
- 设计 §11.5：移交项登记表（A14a/d/e 归属构建脚本的原始出处）
