# Xuan Social FaaS (Python Firebase Functions)

> **版本**：v1.2.1 · **Python**：3.10+ (兼容 3.14) · **单测覆盖**：43+ 专项测试 100% PASS  
> **核心定位**：处理占卜广场业务、用户关系、内容举报、拉黑风控与通知偏好的高可靠 Callable 后端。

---

## 🏛️ 架构铁律与规范

1. **统一用户标识**：入参一律不信任客户端传递的 `uid`，统一使用 `require_auth_uid(req.auth.uid)` + `resolve_app_user_id(uid)` 解析出权威 `app_user_id`；
2. **标准错误抛出**：业务异常一律统一抛出 `XuanHttpsError(code, message)`，与客户端错误映射层一一对齐；
3. **命名与注册规范**：所有 Callable 统一添加 `_py` 后缀，并在 `main.py` 中集中导出。

---

## 🚀 核心 Callable 函数清单

| 函数名 (`main.py` 导出) | 模块文件 | 功能说明 | 事务与幂等性保障 |
|---|---|---|---|
| `follow_user_py` | `xuan/handlers/follow.py` | 关注目标用户 | 事务增计数器 (`following_count`/`followers_count`) + 投递 `user_followed` outbox |
| `unfollow_user_py` | `xuan/handlers/follow.py` | 取消关注 | 原子减计数器 + 投递 `user_unfollowed` outbox |
| `search_users_py` | `xuan/handlers/user_search.py` | 用户名前缀/昵称模糊搜索 | 自动排除自身与双向拉黑用户 |
| `get_mention_candidates_py` | `xuan/handlers/user_search.py` | @艾特候选人智能推荐 | P0（互关/关注/常聊）> P1（公开 Profile）优先级排序 |
| `report_post_py` | `xuan/handlers/moderation.py` | 举报帖子 | 记录 report 记录（保留不幂等，多次举报作为严重程度指标） |
| `report_reply_py` | `xuan/handlers/moderation.py` | 举报回复 | 记录 reply 举报记录 |
| `block_user_py` | `xuan/handlers/conversations.py` | 拉黑指定用户 | **采用固定 ID `block_${caller}_${target}` 事务写入**，彻底杜绝并发重复 |
| `unblock_user_py` | `xuan/handlers/conversations.py` | 解除拉黑 | 事务删除确定性文档 + 兜底清理旧格式历史记录 |
| `set_notification_preference_py` | `xuan/handlers/subscriptions.py`| 设置通知推送偏好 | 支持合并更新与 `with_idempotency` 幂等保护 |

---

## 🛠️ 测试与验证

```bash
# 1. 验证主入口导入
py -3.14 -c "import main"

# 2. 运行完整单元测试套件
py -3.14 -m pytest
```
