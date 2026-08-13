# Playground Firestore 直写设计

## 1. 决策与目标

一期将广场列表、发帖、帖子详情已经使用的写操作改为 Firestore 客户端直写。现有 Firebase Functions 业务代码和 callable adapters 保留但不继续扩展，也不由 Shell 装配。

最终调用链：

`UI -> ViewModel -> UseCase -> Repository Interface -> FirestoreDirectRepository`

本决定接受一期直写的明确降级：不再提供服务端可信的严格 exactly-once、通知 outbox 和服务端限流；采用确定性文档 ID、事务和 Rules 达到重试不重复及越权防护。后续恢复 Functions 或 REST 时，Repository Interface 和 UI 不变。

## 2. 范围

本期直写：

- 帖子：创建、编辑、软删除。
- 回复：根回复、二级回复、编辑、软删除。
- 互动：点赞、收藏。
- Poster 操作：应验、撤回应验、最终反馈、撤回反馈。
- 举报已经由 `FirebasePlaygroundReportRepository` 直写，本次只做回归，不改实现。

明确延后：

- 通知、私信、个人主页及其 UI/UseCase 改造。
- Functions 的 atomic idempotency 迁移。
- REST 实现。
- 服务端限流和反刷。

## 3. 现有实现的处理

当前存在三类写实现，生命周期固定如下：

1. `FirebasePlayground*CommandRepository`：当前 callable 实现，保留，不装配。
2. `FirestoreDirectPlayground*Repository`：新增的当前 Repository Interface 实现，一期装配。
3. `FirebasePlaygroundPostRepository`、`FirebasePlaygroundReplyRepository` 等旧 `RemoteDataSource`：已废弃兼容层，不复活、不装配；待其消费方归零后另行删除。

不能直接复活旧直写层，因为它返回旧领域对象、部分字段不完整，并且不满足当前 `PublicPost/PublicReply` 端口。

## 4. 身份与匿名展示

客户端不得自行决定作者身份：

- `author_provider_uid` 必须等于 `request.auth.uid`。
- `author_app_user_id` 由只读 `identity_map/{request.auth.uid}.app_user_id` 获取。
- identity map 必须由既有 xuan-account 注册/匿名身份流程预先建立；Playground 客户端不得创建映射。映射缺失时写入 fail closed。
- Rules 用同一 identity map 校验 `author_app_user_id`。
- `stableAlias` 的 `presentation_identity_id` 固定为 `user_{appUserId}`。
- `oneTimeAnonymous` 帖子固定为 `post_{postId}`；回复固定为 `reply_{replyId}`。
- `presentation_mode` 和 `presentation_identity_id` 创建后不可修改。

`privacyContext/privacyConfirmations` 目前没有安全的私有集合合同，不得写入公开 post 文档。命令包含非空隐私上下文时直写 adapter 必须 fail closed，而不是静默丢弃；该能力另立隐私存储任务。

## 5. 直写幂等语义

严格服务端 exactly-once 在不可信客户端直写模式下不成立。本期合同是：

- 创建帖子/回复必须提供 `idempotencyKey`；缺失时拒绝写入。
- 文档 ID 为 `sha256(v1|operation|authUid|idempotencyKey)` 的小写 hex。
- `payload_hash` 为 canonical payload（不含时间和 idempotency key）的 SHA-256。
- Firestore transaction 读取确定性文档：不存在则创建；存在且 actor、operation、key、payload hash 相同则返回原文档；否则返回 conflict。
- 点赞、收藏、应验和反馈使用确定性业务文档 ID，重复 set/delete 自然收敛。
- 编辑和软删除为目标文档事务更新；同一状态重复执行成功，不保存无限期命令历史。

这能防止网络重试和重复点击产生重复业务记录，但不能抵抗恶意客户端伪造自己的 idempotency metadata；这是一期直写的已知边界。

现有 `firebase_playground_idempotency_test.dart` 必须改为针对当前 direct command adapter：同 key/同 payload 返回同文档，同 key/不同 payload 返回 conflict，缺 key 创建帖子/回复失败。

## 6. 集合字段矩阵

| 集合 | 文档 ID | 创建字段 | 可变字段 | 不可变/校验 |
|---|---|---|---|---|
| `playground_posts` | create command hash | `id,text,author_provider_uid,author_app_user_id,presentation_mode,presentation_identity_id,status,allowed_chart_technique_ids,attachments,revisions,has_outcome_feedback,idempotency_key,payload_hash,created_at,updated_at` | `text,allowed_chart_technique_ids,attachments,revisions,status,has_outcome_feedback,updated_at` | id、两类作者、展示身份、创建时间不可改；status 只允许 `active -> tombstoned` |
| `playground_replies` | create command hash | `id,post_id,author_provider_uid,author_app_user_id,presentation_mode,presentation_identity_id,depth,body,is_tombstoned,root_reply_id,reply_to_reply_id,technique_tags,chart_attachment,media_attachments,verification,revisions,idempotency_key,payload_hash,created_at,updated_at` | 作者可改正文/附件/修订/墓碑；Poster 只能改 `verification,updated_at` | post、作者、展示身份、depth/root/reply-to、创建时间不可改 |
| `playground_likes` | `like_post_{uid}_{postId}` 或 `like_reply_{uid}_{replyId}` | `id,user_provider_uid,user_app_user_id,post_id XOR reply_id,created_at` | 无；取消即删除 | UID 必须为当前用户；目标必须存在 |
| `playground_bookmarks` | `bookmark_{uid}_{postId}` | `id,user_provider_uid,user_app_user_id,post_id,created_at` | 无；取消即删除 | UID 必须为当前用户；帖子必须存在 |
| `playground_verifications` | `verify_{postId}_{rootReplyId}` | `id,post_id,root_reply_id,verifier_provider_uid,verifier_app_user_id,created_at,revoked_at` | 仅 `revoked_at` | verifier 必须是 Poster；root 必须属于 post、depth=0 且不能是 Poster 自己的回复 |
| `playground_outcome_feedback` | `feedback_{postId}` | `id,post_id,author_provider_uid,author_app_user_id,outcome_description,created_at,updated_at,deleted_at` | 正文、更新时间、删除时间 | 作者必须是 Poster，post_id/作者/创建时间不可改 |

读取模型只认本表字段。`firebase_playground_reply_post_payload_contract_test.dart` 必须同时覆盖 callable 与 direct payload，防止双合同漂移。

## 7. Rules 机械约定

### 帖子

- create：已认证；字段集合完全位于矩阵 allowlist；两类作者和展示身份匹配当前用户；status=`active`。
- update：普通作者只能修改帖子可变字段；不得物理 delete。
- 非作者任何更新失败。

### 回复

- create：已认证且作者字段匹配；depth 只能为 0 或 1。
- depth=0：`root_reply_id=null` 且 `reply_to_reply_id=null`。
- depth=1：root 必须存在、depth=0、同 post；reply-to 非空时也必须存在且与 root/post 相同。
- 作者更新只允许正文、附件、revisions、is_tombstoned、updated_at。
- Poster 更新采用独立 verification-only 分支：`affectedKeys().hasOnly(['verification','updated_at'])`，并验证 reply.post_id 对应帖子的 `author_provider_uid == request.auth.uid`。

### 点赞、收藏、应验、反馈

- like/bookmark 只能创建或删除当前 UID 的确定性文档，不能更新或伪造目标。
- verification 只能由 Poster 创建/撤回；确定性 ID 保证一帖一根回复只有一条记录。
- outcome feedback 只能由 Poster 写入该 post 的确定性文档。
- `identity_map/outbox/notifications/conversations/messages/profiles` 继续 `write: if false`。

## 8. 应验的双写一致性

详情读取当前通过 reply 的 `verification` 判断单条回复是否应验，同时通过 verification 集合统计数量，因此直写必须用一个 `WriteBatch` 同时：

1. set/update 确定性 verification 文档；
2. update root reply 的 `verification` 映射或置 null。

Rules 的 verification-only 分支只允许 Poster 做这项双写。若 batch 任一写失败，全部失败。

项目尚未上线、没有生产用户数据，因此不执行线上迁移。开发/测试环境若已有自动 ID verification 数据，在启用新 Rules 前清空；若未来发现非空线上集合，则必须暂停发布并另写迁移脚本，将每个 `(post_id,root_reply_id)` 收敛为确定性文档后才能切换。

## 9. 通知与计数决定

- 本期点赞、应验和回复不写 `playground_outbox`，也不触发通知；通知是明确延后能力，UI 不得显示“已通知”。客户端永远不能获得 outbox 写权限。
- 不维护 `playground_profiles.public_post_count/public_reply_count`。列表和详情的回复数、点赞数、应验数继续查询集合聚合；个人主页恢复时再选择 Firestore aggregation query 或服务端触发器。
- `has_outcome_feedback` 由 Poster 的反馈 batch 同步更新 post；Rules 只允许 Poster 修改该字段。
- 当前 `abuse_control.ts` 未被生产写路径调用，因此本期不声称具有限流；后续服务端化时补齐。

## 10. 装配位置

- 实现与 Rules：`xuan-storage/firebase/`。
- 导出：`xuan-storage/firebase/lib/playground/playground.dart`。
- 生产装配：`xuan-shell/lib/playground/shell_playground_bootstrap.dart`。
- Shell 只把 post/reply/engagement/verification/outcome feedback 五个端口切到 direct 实现。
- profile、notification、conversation 的装配保持不变。

## 11. Emulator 与 Rules 单一事实源

生产唯一 Rules 文件为 `firebase/infrastructure/firestore.rules`。

- `firebase/infrastructure/emulator/firebase.json` 必须把 rules 路径改为 `../firestore.rules`。
- `firebase/infrastructure/emulator/firestore.rules` 不再作为运行输入；删除或改为由构建脚本生成，禁止人工维护第二份。
- 新增 `firebase/scripts/run_playground_emulator_gate.sh`：Emulator 不可达即退出 1；测试出现 skip 即退出 1；禁止 allow-all。
- Rules allow/deny 使用 Firebase 官方 `@firebase/rules-unit-testing`。这是测试基础设施，不是 Functions 业务实现。

## 12. 验收结果

完成时必须同时满足：

- 三个页面现用写路径零 `httpsCallable`。
- callable adapters 和 Functions 源码仍存在但不被 Shell 注入。
- 创建重试不产生重复帖子/回复；同 key 不同 payload 返回 conflict。
- 合法发帖、回复、点赞、收藏、应验和反馈在生产 Rules 下成功；所有越权对照失败。
- 匿名展示字段在写入、列表和详情间一致。
- 生产 Rules 是本地和局域网 Emulator 的唯一事实源。
- 通知、私信、个人主页没有新增实现。
