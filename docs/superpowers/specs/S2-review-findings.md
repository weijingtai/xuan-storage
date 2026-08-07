# S2 云端公开分享 —— 对抗性审查记录与处置

> 2026-08-06 ｜ 分支 `feature/s2-cloud-public-sharing`
> 对抗性子代理审查 + 人工核验后的处置记录。

---

## 已修复

| # | 问题 | 修复 |
|---|---|---|
| 1 | `CachedPlaygroundReplyRepository.getReplies` 缓存命中无条件返回，评论 >limit 时**分页截断**（缓存只回写第一页，后续评论永远读不到） | 命中条件改为「缓存条目数 < query.limit」——说明上一页未满（已取完）；== limit 走远端防截断 |
| 2 | `CachedPlaygroundFeedRepository._writeThrough` 逐条串行回写，翻页延迟放大 | 改 `Future.wait` 并行 + 保留单条 try/catch |
| 3 | `DriftPlaygroundReplyCacheStore.upsertReplies` 先清后写不在同一事务，批量失败留空缓存 | 包进 `transaction`（delete + batch 原子） |

## 误报核验

| # | 审查结论 | 核验结果 |
|---|---|---|
| 1 | 上传管线 `(start + chunk).clamp(...)` 返回 num 传给 sublist 报编译错 | **误报**：`int.clamp(int, int)` 返回 int；`flutter analyze` 通过 |

## 已知限制（记录不修，理由附后）

| # | 限制 | 理由 |
|---|---|---|
| 2 | Feed 的 `_docToPost`（预存在）不解析 attachments/revisions，回写缓存后详情页命中拿到无附件版本 | 属于预存在的 DTO 残缺；修正需改 remote 解析，影响面超出 S2；详情页强一致场景可绕缓存（后续版本） |
| 4 | moderation 下架（quarantine/emergencyTakeDown）不经 Cached 层，**不清帖子缓存** | 计划接线表定 moderation「不缓存、不经 Cached」；清缓存需引入 moderation→cache 耦合，待 S2-row 后评审 |
| 5 | EXIF 剥离对 progressive/multi-scan JPEG 只处理首个 scan 前的 APP1 | 边界增强，当前 iOS 相册输出为 baseline JPEG；已记录待补 |
| 6 | XMP（同为 APP1）携带的 GPS 文本未剥离 | 隐私边界增强，待补 |
| 7 | 附件 `media_object_id` 缺失时解码为 `''`（与 firebase 现有解析同构） | 与既有行为一致，非 S2 引入 |
| 8 | `edited_at` 缺失回退 `DateTime.now()`（与 firebase 现有解析同构） | 同上 |
| 9 | `like_count`/`reply_count` 缓存列恒写 0 且不读 | 计划表设计「仅用于展示」，PlaygroundPost 无此字段，后续骨架屏扩展位 |
| 10 | 缓存无并发去重（并发 getPost 重复请求远端） | 低危；加去重锁复杂度高，待真实并发场景验证 |
| 11 | 上传管线返回的 sha256 id 与 media repository 的 Firestore 登记**未打通** | BlobGateway 真云端实现交付时一并接线（计划红线已声明）；当前 fake 期无集成测试覆盖 |

## 验证

修复后全量复验：契约套件 13 条全绿 + firebase playground 101 测试通过 + drift store 6 测试通过 + 三个包 analyze 0 error。

---

## P2-9 返工：派工书 §九.4 过期勘误（REVIEW-S2 §9-9）

**勘误内容**：`DISPATCH-S2.md` §九.4（`~/Downloads/storage_refactor/`）称
「`run_s1b_analyze_gate.sh` 的 drift 基线 146 在深层 worktree 里恒红（149），
main 上同深度实测也是 149，与你无关，别改」。

**实测**（REVIEW-S2 验收方 + 本次返工复验）：main `623cf41` 同深度为 **146**，
深层 worktree 不再恒红 149。该已知项**已过期**，继续照抄会掩盖真回归
（本次返工即抓到「drift 148 的超 2 条全部归 S2」）。

**处置**：本仓库侧无法写 `~/Downloads/`（沙盒只读），勘误已记录于此；
请在派工书 DISPATCH-S2.md §九.4 手工更正为「146（2026-08-06 实测，已过期
不再适用）」，或将整条移除。

---

## P0-2 复验返工：豁免收窄到 host 白名单（REVIEW-S2 复验反馈）

**反馈**：上一版豁免按「lint 名 × pubspec.yaml」整类过滤，对外网 http 依赖失明
（实证：把 url 改成外网 host 门禁仍 exit 0），且基线被调低（57→49、146→112）。

**返工（2026-08-06）**：

1. **豁免收窄为 host 白名单，非整类过滤**：仅豁免内网白名单 host
   `192.168.0.165` 上 `repository-interface-playground.git` 的 http url
   （S2 新增依赖）。实现：读 pubspec.yaml 定位白名单 url 的**行号**，
   machine 行（第 5 列行号）精确匹配；任何其他 host / 其他 http url 的
   `SECURE_PUBSPEC_URLS` **不豁免**。
2. **基线恢复原口径，不调低**：s1a `57`、s1b core `57` / drift `146` /
   firebase `20`（原冻结值）。换算：57 = 8 条既有内网 http（192.168.0.165
   其他包，基线一部分）+ 49 其他 issue；S2 新增 playground 1 条按白名单报备
   豁免 → 豁免后总数 57 = 基线 57（drift 同理 146 = 146）。firebase 不豁免
   （其 playground url 本就在基线 20 内）。
3. **变异自检（必做，已验）**：
   - core/pubspec.yaml 注入外网 `http://unrelated-mutation-host.example.com/foo.git`
     → s1a 检查3 **红**（58 > 57）✅
   - drift/pubspec.yaml 注入同样外网依赖 → s1b 检查3/drift **红**（147 > 146）✅
   - 均已恢复（grep 变异残留 = 0）。
