# S2 云端公开分享 —— Phase 8 变异自检记录

> 2026-08-06 ｜ 分支 `feature/s2-cloud-public-sharing`
> 变异方式：临时注入 → 跑对应契约测试 → 记录红点 → 立即恢复 → 确认全绿。

---

## 变异记录

| # | 靶点 | 注入变异 | 测试 | 预期红在 | 实际红在 | 结论 |
|---|---|---|---|---|---|---|
| 1 | `firebase/lib/media/exif_stripper.dart` | 删除剥离逻辑，`stripExif` 原样返回 | C6 EXIF 剥离 | 断言：字节流不含 GPS | **断言 1「剥离后必须变小」**：`Expected: not <25> / Actual: <25>` | ✅ 变异被捕获 |
| 2 | `firebase/lib/cached_playground_like_repository.dart` | `isLiked` / `getLikeCount` 改为首查缓存 | C4 点赞态/计数不缓存 | 断言：立刻读必须新值 | **两条都红**：点赞态 `Expected: false / Actual: <true>`；计数 `Expected: <1> / Actual: <0>` | ✅ 变异被捕获 |
| 3 | `firebase/lib/cached_playground_bookmark_repository.dart` | `isBookmarked` 改为首查缓存 | C5 收藏态不缓存 | 断言：立刻读必须新值 | **红**：`Expected: false / Actual: <true>` | ✅ 变异被捕获 |

对应验收：C6→A4/A5，C4→A3/A6，C5→A3。

---

## 恢复确认

变异全部恢复后（`grep -c "变异注入"` 三处均为 0）：

- `flutter test test/playground/` → **101 通过 + 1 skip，All tests passed**
- `flutter analyze`（firebase / drift）→ 0 error

---

## 变异自检暴露的真实缺陷（Phase 7 已修复）

契约 C9 在正常（非变异）运行时捕获一个真 bug：

- **缺陷**：`CachedPlaygroundReplyRepository.deleteReply` 未失效缓存 → 删除评论后
  `getReplies` 命中旧缓存，返回已删除的讨论回复。
- **修复**：`PlaygroundReplyCacheStore` 新增 `removeReply(PlaygroundReplyId)`，
  drift 与内存实现均按 replyId 精确删除缓存行；`deleteReply` 调用之。
- **验证**：修复后 C9 断言「删除后列表只剩根回复」通过。

---

## P0-2 返工变异（独立验收 REVIEW-S2 §5/§9-2）

| # | 靶点 | 注入变异 | 测试 | 预期红在 | 实际红在 | 结论 |
|---|---|---|---|---|---|---|
| 4 | `firebase/lib/media/playground_media_upload_pipeline.dart:43` | 删除剥离步骤，`stripExif(bytes)` 换成 `bytes` | 管线级 A4 门禁（`test/media/playground_media_upload_pipeline_test.dart`） | 断言：gateway 收到的 chunk 字节不含 GPS | **红**：`Expected: false / Actual: <true>`，reason「A4: 上传路径上的字节流不得含 GPS 标签」 | ✅ 变异被捕获（`dart analyze` 0 error，非编译失败） |

> 该门禁直接读 `InMemoryFirebaseBlobGateway.uploadedBytes()` —— 断言的是
> pipeline 实际提交给网关的字节流，不再绕道纯函数。

---

## P1-5 返工变异（REVIEW-S2 §9-5）

| # | 靶点 | 注入变异 | 测试 | 预期红在 | 实际红在 | 结论 |
|---|---|---|---|---|---|---|
| 5 | `firebase/lib/cached_playground_feed_repository.dart` | `getRecommendedFeed` / `getPendingDivinationFeed` 错路由到 `getLatestFeed` | 契约 C2 tab 路由语义 | 断言：待占卜 tab 必须为空 | **红**：`Expected: empty / Actual: [3 帖]`，reason「无 reply_status=pending 时待占卜 tab 必须为空」 | ✅ 变异被捕获（恒绿断言已替换为有信息量断言） |

---

## P1-6 返工变异（REVIEW-S2 §9-6）

| # | 靶点 | 注入变异 | 测试 | 预期红在 | 实际红在 | 结论 |
|---|---|---|---|---|---|---|
| 6 | `firebase/lib/playground/firebase_playground_moderation_repository.dart` | `reportContent` 空实现（直接 return） | 举报落库断言（`playground_contract_suite_test.dart`） | 断言：reports 集合出现该文档 | **红**：`Expected: non-empty / Actual: []`，reason「reportContent 必须写入 playground_reports 集合」 | ✅ 变异被捕获（`dart analyze` 0 error，非编译失败） |
