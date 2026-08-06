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
