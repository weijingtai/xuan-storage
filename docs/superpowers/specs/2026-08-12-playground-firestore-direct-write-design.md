# Playground Firestore 直写设计

## 1. 决策、目标与一期边界

一期仅为已经接近完成的三个 Flutter 页面接通后端：广场列表、发帖、帖子详情。
调用链固定为：

`UI -> ViewModel -> UseCase -> Repository Interface -> FirestoreDirectRepository`

一期使用 Firebase Auth、Cloud Firestore、Security Rules、indexes 和 Emulator，核心写操作
由客户端 SDK 直接提交。现有 callable adapters 与 Functions 源码保留，但不装配、不继续扩展。
未来切回 Functions 或 REST 时，UI、ViewModel、UseCase 和 Repository Interface 不变。

本方案只承诺正常客户端的重试幂等和 Rules 授权，不承诺服务端 exactly-once、服务端限流、
反刷或不可绕过的游客代表性回复限制。以下能力明确后移，不得被一期宣称为完成：

- 通知、推送、私信、个人主页及其 UI/UseCase。
- 声望投影与排行；一期只做按关系集合实时聚合的帖子级数字。
- 依赖可信派生数据的“待断”和个性化“推荐”排序；本期提供“最新”与多选技法 Filter，
  UI 的推荐入口暂时明确映射为最新，不显示尚未可信实现的待断入口。
- Functions atomic idempotency、outbox、服务端限流与反作弊。
- 未注册访客只能看 5–10 条代表性回复的不可绕过服务端策略。
- REST、H5、小程序以及 SEO。

本文件是上述一期直写范围的权威实现设计；长期产品能力仍保留在 OpenSpec，但必须标成
后续 Phase，不得作为本期编码通过条件。

## 2. 本期业务范围

本期直写：

- 帖子：创建、编辑、软删除。
- 回复：根回复、二级回复、编辑、软删除。
- 互动：帖子/回复点赞、帖子收藏。
- Poster 操作：应验、撤回应验、最终反馈、撤回反馈。
- 举报沿用现有直写实现，只做生产 Rules 回归。

现有实现生命周期：

1. `FirebasePlayground*CommandRepository`：callable 实现，保留但不装配。
2. `FirestoreDirectPlayground*Repository`：本期生产装配。
3. 旧 `FirebasePlaygroundPostRepository`、`FirebasePlaygroundReplyRepository`：废弃
   facade，不复活、不装配；消费方归零后另行删除。

## 3. 身份、公开投影与所有权隔离

Firestore Rules 不能对同一文档按字段脱敏，因此公开帖子/回复绝不能保存 provider UID、
canonical `appUserId`、邮箱、姓名或其他内部账号字段。

### 3.1 账号预置合同

`identity_map/{providerUid}` 是私有身份文档，只允许当前 `request.auth.uid` 读取自己的文档，
禁止 Playground 客户端创建、修改、枚举或读取他人的映射。它至少包含：

- `app_user_id`：内部 canonical ID，不进入任何公开内容文档。
- `public_presentation_id`：账号层预生成的随机、稳定、不可由 `appUserId` 或 provider UID
  推导的公开别名 ID。
- `public_display_alias`：账号层生成的公开别名，默认不得取真实姓名。
- 可选 `public_avatar_url/public_profile_ref`：只能是已经批准公开的投影；一期可为空。

Playground 只读取该文档。映射或 `public_presentation_id` 缺失时写入以
`identity-not-ready` fail closed；一期不调用 callable 自动创建，也不自行生成替代映射。
匿名账号升级必须由 xuan-account 保留这两个值。

编码前必须以 account Emulator fixture 证明匿名注册、登录恢复、匿名升级三条路径均会预置
这些字段；如果当前 xuan-account 尚未提供，先把它列为接线前依赖，禁止在 Playground
adapter 中临时补建。

当前生产者只写 `app_user_id/provider_uid/provider_id/created_at`，旧 account resolver 还读取
camelCase `appUserId`；因此 **identity schema convergence 是 direct adapter 的 P0 前置任务**：

1. 权威 schema 统一为上述 snake_case 字段；读取期可兼容旧 `appUserId`，新写只写 snake_case。
2. xuan-account 的匿名创建/恢复/升级负责原子写入随机 `public_presentation_id` 与系统生成
   `public_display_alias`；Playground 无此权限。
3. 对现有 identity_map 做一次幂等 backfill；项目尚无生产用户时只处理 dev/test fixture。
   若发布前发现生产数据非空，暂停 rollout，另做有备份和抽样校验的迁移。
4. 回滚只回滚 account 生产者版本，不删除新增字段；旧 reader 可忽略新增字段。
5. account contract tests 未通过前不得启动 direct adapter 编码或 Shell 接线。

### 3.2 公开文档

公开 `playground_posts`、`playground_replies` 只保存展示模式、不可反推的
展示 ID 及经过账号层批准的 alias/avatar/profile-ref 快照：

- `stableAlias`：使用账号层的随机 `public_presentation_id`。
- `oneTimeAnonymous`：帖子使用 Rules 可验证的 `post_{postId}`；同一 actor 在同一帖子下的
  所有回复使用私有 thread-presentation mapping 首次生成的 128-bit 随机 ID，线程内稳定、
  跨帖不可关联。adapter 不再定义或接受 SHA-256 格式的 thread presentation ID。

展示模式和展示 ID 创建后不可修改。公开 DTO 不得返回内部身份。

Rules 对展示快照做精确校验：`stableAlias` 的 ID、alias、avatar/profile ref 必须与当前
identity_map 的公开投影一致；`oneTimeAnonymous` 的 alias 固定为产品文案“匿名用户”，
avatar/profile ref 必须为 null。这样客户端不能把真实姓名或任意链接伪装成系统公开身份。

### 3.3 私有所有权文档

真实所有权放在以下 deny-by-default 集合：

- `playground_post_owners/{postId}`
- `playground_reply_owners/{replyId}`
- `playground_like_owners/{likeId}`
- `playground_thread_presentations/{postId}__{providerUid}`

owner 文档保存 `provider_uid`、`app_user_id`、`public_presentation_id`、目标 ID 和
`created_at`，仅 owner 可读；禁止
list。创建公开事实时必须在同一 batch/transaction 创建 owner 文档，Rules 使用
`getAfter()` 验证两者一一对应。公开事实被墓碑化时 owner 文档保留；禁止客户端物理删除
帖子、回复和 owner 文档。

thread-presentation 文档只允许当前 UID get、禁止 list/write-after-create，字段为
`post_id,provider_uid,presentation_identity_id,created_at`。首次 one-time anonymous 回复时，
adapter 在同一 transaction 创建随机 presentation ID 的 mapping、reply 与 reply owner；后续
回复必须复用 mapping。Rules 通过可寻址路径
`{postId}__{request.auth.uid}` 的 `getAfter()` 比对 reply 展示 ID。伪造 ID、跨 actor 复用、
重复创建 mapping 均拒绝。one-time anonymous 帖子自身仍用 Rules 可验证的 `post_{postId}`。

收藏是私有事实，`playground_bookmarks/{bookmarkId}` 可直接包含内部 owner 字段，但只允许
本人 get/query/write，任何其他用户不可读。

## 4. 数据模型与单一事实源

### 4.1 公开内容

| 集合 | 核心字段 | 可变字段 | 不变量 |
|---|---|---|---|
| `playground_posts` | 见 4.4 | 正文、技法、附件、revision 指针、状态；关系事务可改查询投影 | 不含内部身份；展示快照、创建时间不可改 |
| `playground_replies` | 见 4.4 | 作者可改正文/附件/revision 指针及墓碑 | post、展示快照、depth/root/reply-to、创建时间不可改 |
| `playground_verifications` | `id,post_id,root_reply_id,created_at,revoked_at` | `revoked_at` 状态转换 | Poster-only；root-only；同帖；禁止应验自己的回复 |
| `playground_outcome_feedback` | `post_id,outcome_description,revision_no,current_revision_id,created_at,updated_at,deleted_at` | 正文、revision 指针、删除时间 | Poster-only；每帖一份当前事实 |

公开 post/reply 不保存客户端可改的关系计数、活动时间、verification map 或 feedback 状态。
详情 adapter 从 replies/likes/verifications/feedback 权威事实查询并合成 DTO。Feed 卡片一期不显示
这些数字；需要时按固定页面 ID 分块查询事实，不能允许非 owner 修改公开 post/reply 投影。

### 4.2 关系事实

| 集合 | 文档 ID | 公开性与约束 |
|---|---|---|
| `playground_likes` | client deterministic opaque hash | 公开文档仅含目标和时间；owner 在私有 like owner 文档；同一 batch 创建/删除 |
| `playground_bookmarks` | client deterministic opaque hash | 私有；只允许本人读取；帖子目标必须存在 |
| `playground_verifications` | `verify_{postId}_{rootReplyId}` | 可公开读取；Rules 可机械校验路径、帖子 owner、root/post/depth |
| `playground_outcome_feedback` | `feedback_{postId}` | 可公开读取未删除事实；Rules 校验路径与帖子 owner |

like/bookmark 的正常客户端 ID 为
`sha256(v1|operation|authUid|targetId)`；Firestore Rules 无 SHA-256 原语，不能证明该 hash。
Rules 仍验证 actor 的私有 owner 文档和目标关系，防止越权，但恶意客户端可为自己的同一目标
制造多个不同 ID。该滥用风险只能由后续 Functions/反作弊消除，不得在一期验收中宣称解决。

### 4.3 不可变 revision

禁止在帖子/回复中保存可重排、可覆写的 `revisions[]`。使用 append-only 子集合：

- `playground_posts/{postId}/revisions/{revisionId}`
- `playground_replies/{replyId}/revisions/{revisionId}`
- `playground_outcome_feedback/{feedbackId}/revisions/{revisionId}`

revision 创建后永远拒绝 update/delete。创建内容时 batch 同时写 revision 1；编辑时 transaction：

1. 读取当前事实和 owner；
2. 创建 `revision_no + 1` 的完整新版本快照；revision 只含公开内容快照和公开展示身份，
   不含内部 owner 字段；
3. 把事实的 `revision_no/current_revision_id` 精确推进一位并更新正文；
4. Rules 通过 `getAfter()` 验证指向的新 revision 存在、编号连续且快照匹配更新后的当前内容。

revision 子集合不是公开历史：只允许 content owner 单文档/列表读取，其他普通用户拒绝；后续
moderator 权限另立。公共 DTO 只返回 `revision_no/updated_at` 摘要，不返回历史正文。tombstone
transaction 必须先追加最后 revision，再把公开 post 的 `text=''`、attachments/techniques 清空，
或把 reply 的 `body=''`、chart/media/techniques 清空；公开读永远拿不到已删除正文。feedback
撤回同样把 `outcome_description=''` 并设置 `deleted_at`。不得只改 status/flag 后保留公开正文。

### 4.4 机械 schema（`?` 表示字段可缺省；其余字段必须存在）

所有 ID、enum、正文、hash 为 string；depth、revision/schema/dimensions 为 int；时间为
Firestore timestamp；附件为 map/list。nullable 字段必须明确写 null，不得在“缺省/null”间漂移。

```text
playground_posts/{postId}
  id:string, text:string, presentation_mode:string,
  presentation_identity_id:string, presentation_display_alias:string,
  presentation_avatar_url:string|null, public_profile_ref:string|null,
  status:string, allowed_chart_technique_ids:list<string>, attachments:list<map>,
  has_chart:bool,
  revision_no:int, current_revision_id:string,
  idempotency_key:string, payload_hash:string,
  created_at:timestamp, updated_at:timestamp

playground_replies/{replyId}
  id:string, post_id:string, presentation_mode:string,
  presentation_identity_id:string, presentation_display_alias:string,
  presentation_avatar_url:string|null, public_profile_ref:string|null,
  depth:int, body:string, is_tombstoned:bool,
  root_reply_id:string|null, reply_to_reply_id:string|null,
  technique_tags:list<string>, chart_attachment:map|null,
  media_attachments:list<map>,
  revision_no:int, current_revision_id:string,
  idempotency_key:string, payload_hash:string,
  created_at:timestamp, updated_at:timestamp

playground_{post|reply}_owners/{contentId}
  content_id:string, provider_uid:string, app_user_id:string,
  public_presentation_id:string, created_at:timestamp

playground_like_owners/{likeId}
  like_id:string, provider_uid:string, app_user_id:string,
  target_type:string(post|reply), target_id:string, created_at:timestamp

playground_thread_presentations/{postId}__{providerUid}
  post_id:string, provider_uid:string, presentation_identity_id:string,
  created_at:timestamp

playground_likes/{likeId}
  id:string, target_type:string(post|reply), target_id:string,
  created_at:timestamp

playground_bookmarks/{bookmarkId}
  id:string, provider_uid:string, app_user_id:string, post_id:string,
  created_at:timestamp

playground_verifications/verify_{postId}_{rootReplyId}
  id:string, post_id:string, root_reply_id:string,
  created_at:timestamp, revoked_at:timestamp|null

playground_outcome_feedback/feedback_{postId}
  id:string, post_id:string, outcome_description:string,
  revision_no:int, current_revision_id:string,
  created_at:timestamp, updated_at:timestamp, deleted_at:timestamp|null

{post|reply|feedback}/revisions/{revisionId}
  id:string, parent_id:string, revision_no:int, body:string,
  allowed_chart_technique_ids:list<string>?, technique_tags:list<string>?,
  attachments:list<map>?, chart_attachment:map|null?, media_attachments:list<map>?,
  presentation_mode:string, presentation_identity_id:string,
  presentation_display_alias:string, presentation_avatar_url:string|null,
  public_profile_ref:string|null, created_at:timestamp
```

revision ID 固定为零填充十位十进制 `r0000000001`；create 必须是 1，edit 必须精确为当前
`revision_no + 1`。revision 的 optional 字段由 parent type 决定，其他 parent 类型字段禁止。
post/reply create 不带任何关系计数或活动投影。likes、replies、verifications、feedback 各自的
关系文档就是单一事实源；Rules 对普通关系操作者永远不开放 post/reply update。任何新增
计数、`last_activity_at`、`has_feedback` 字段的写入都因 exact key allowlist 被拒绝。

## 5. 精确字段约束

schema 单一事实源为版本化测试 fixture
`firebase/test/playground/fixtures/direct_write_schema_v1.json`。Dart adapter 与 Rules 不能直接
共享运行期常量，因此分别实现，但同一合同测试必须读取该 fixture 生成合法/非法 payload；
fixture、adapter 和 Rules 任一改变必须同批提交，漂移测试比较精确字段集合与枚举：

- post `text`：客户端 NFC normalize + trim 后 1–4000 Unicode code points；Rules 可执行门禁为
  string 且 `size()` 1–4000，并拒绝首尾 ASCII whitespace。完整 Unicode normalization 只由
  Dart 合同测试保证，不宣称 Rules 可证明。
- reply `body` 同上 1–4000；feedback 同上 1–2000。
- technique ID/tag：每项 1–64 字符；列表去重且最多 16 项。
- 帖子附件最多 9 个；根回复 1 个可选 chart + 最多 9 个 media；二级回复最多 9 个 media。
- `presentation_mode` 只允许 `stableAlias|oneTimeAnonymous`。
- status 只允许 `active|tombstoned`；depth 只允许 `0|1`。
- 时间全部使用 server timestamp；create 时 `created_at == updated_at == request.time`；更新时
  `created_at` 不变且 `updated_at == request.time`。
- 所有 create/update 使用 `keys().hasOnly(...)` 和 required-key 检查；未知字段拒绝。
- Rules 因无通用列表循环，必须用固定上限 helper 逐槽验证 technique 的 0–15 项和附件的
  0–8 项；每个槽位先以 size guard 判断再调用判别联合校验。只检查 `is list/map` 不算通过。

附件使用判别联合并拒绝混合字段：

- `xuanChart`：必须且只能包含 `type,technique_id,school_id?,public_chart_snapshot,
  renderer_schema_version,chart_source`；snapshot 1–65536 字符，schema version 为正整数。
- `image`：必须且只能包含 `type,media_object_id,mime_type,width?,height?,moderation_state`。
- `video`：在 image 字段基础上允许 `duration_seconds?`。
- media ID 1–128 字符；mime 1–128 字符；width/height 为正整数；duration 为 1–3600；
  moderation state 只允许 `pending|approved|quarantined|rejected`。

隐私 `privacyContext/privacyConfirmations` 没有私有存储合同，绝不写公开文档。命令任一非空时
adapter 在任何 Firestore 调用前返回 `privacy-storage-unavailable`，不得静默丢弃。

## 6. 帖子与回复 Rules 不变量

### 6.1 帖子

- create：必须认证；公开 post 与 post owner 在同一 atomic write 中创建；owner 的
  `provider_uid == request.auth.uid`，owner `app_user_id/public_presentation_id` 必须与当前
  identity_map 匹配；公开 post 展示身份按 3.2 计算。
- update：仅 owner；仅允许第 4.1 节可变字段；状态只允许原值或
  `active -> tombstoned`；tombstone 必须按 4.3 清空公开内容；不得物理 delete。
- read：仅返回公开 post；owner/identity_map 永不随帖子查询暴露。

### 6.2 回复

- create 前必须验证目标 post 存在且 `status=active`。
- depth 0：`root_reply_id=null` 且 `reply_to_reply_id=null`。
- depth 1：root 必须存在、`depth=0`、同 post、未墓碑；`reply_to_reply_id` 必须为空或
  指向同 post、同 root、未墓碑的现有 reply。
- depth 小于 0、大于 1、跨帖、跨 root、第三层、回复墓碑目标全部拒绝。
- 公开 reply 与 reply owner 必须同一 atomic write 创建；只有 owner 可编辑/墓碑；不得物理
  delete；墓碑必须按 4.3 清空公开内容。Poster 不再直接修改 reply，因为 verification 是独立事实。

## 7. Poster 操作状态机

### 7.1 应验

- 仅帖子 owner 可操作；目标必须是同帖、depth 0、未墓碑且非 Poster 自己的回复。
- `verify_{postId}_{rootReplyId}` 的 ID、`post_id`、`root_reply_id` 必须相互一致。
- 首次 verify：create，`created_at=request.time`、`revoked_at=null`。
- revoke：只允许 `null -> request.time`。
- re-verify：只允许非空 `revoked_at -> null`，`created_at` 保持不变。
- 重复 verify/revoke 返回当前期望状态，不新增第二条事实。

### 7.2 最终反馈

- 仅帖子 owner 可操作；`feedback_{postId}` 与 `post_id` 必须一致。
- 首次发布创建事实和 revision 1；编辑按 4.3 追加 revision；撤回只允许
  `deleted_at: null -> request.time`；再次发布清空 `deleted_at` 并追加 revision。
- 发布反馈永不改变 post status，也不阻止新回复。

## 8. 幂等与 UI 生命周期

创建帖子/回复必须有 128-bit 以上随机 `idempotencyKey`；缺失返回
`invalid-idempotency-key`。正常客户端文档 ID 为
`sha256(v1|operation|authUid|idempotencyKey)`，payload hash 为不含时间、key 和内部身份的
canonical JSON SHA-256。

transaction 读取确定性文档：不存在则创建；存在且 operation、actor owner、key、payload
hash 相同则返回原结果；同 key 不同 payload 返回 `idempotency-conflict`。

ViewModel 对一次“逻辑提交”只生成一次 key：

- 首次点击提交时生成并保存在 draft/submission state。
- 网络超时、离线恢复、重试按钮继续使用同一个 key。
- 仅在服务端确认成功或用户明确取消/丢弃草稿后清除。
- 编辑后作为新逻辑提交才生成新 key。
- post composer 与 reply composer 必须执行同一规则，禁止在每次 `submit()` 内重新生成。

这只能保证正常客户端重试不重复，不能阻止修改版客户端绕过 ID 约定。

## 9. 可观察错误合同

RI 不新增 enum；使用现有 `PlaygroundErrorCode`，细分原因放稳定 `machineCode`：

| 条件 | `code` / `machineCode` | UI 行为 |
|---|---|---|
| 未认证 | `unauthenticated` / `auth/unauthenticated` | 显示登录/匿名会话恢复入口 |
| identity_map/公开别名缺失 | `unavailable` / `identity/not-ready` | 阻止提交并提示重试账号初始化 |
| 隐私字段非空 | `invalidArgument` / `privacy/storage-unavailable` | 阻止提交，不丢字段 |
| key 缺失/格式错误 | `invalidArgument` / `idempotency/invalid-key` | 保留草稿，视为客户端错误 |
| 同 key 不同 payload | `conflict` / `idempotency/payload-conflict` | 保留草稿，禁止自动换 key |
| 非 owner/非 Poster | `forbidden` / `authorization/forbidden` | 回滚乐观状态并显示无权限 |
| 目标不存在 | `notFound` / `content/not-found` | 渲染不可用状态 |
| 已墓碑 | `tombstoned` / `content/tombstoned` | 渲染墓碑状态 |
| 字段/附件不合法 | `invalidArgument` / `validation/invalid-payload` | 定位到发布器字段 |
| 当前直写 Phase 不支持的 Filter | `invalidArgument` / `filter/not-supported-in-direct-phase` | 不展示该选项；深链/旧状态进入时退回全部并提示 |
| Firestore 暂不可用 | `unavailable` / `provider/unavailable` | 保留同 key，允许重试 |

adapter 必须把 Firebase 异常稳定映射为以上代码；不得返回 collection、Rules 行号或 SDK
异常给 UseCase/UI。

## 10. 读取、聚合与成本

### 10.1 精确查询计划

| 语义 | Firestore query（全部 limit 1–50） | cursor |
|---|---|---|
| 最新 Feed | posts: `status==active`, order `created_at desc,__name__ desc` | `[created_at,docId]` |
| 推荐入口（一期降级） | 与最新完全相同，UI 标明当前按最新；不宣称算法推荐 | `[created_at,docId]` |
| 技法多选 Feed | 在上述 query 增加 `allowed_chart_technique_ids array-contains-any techniqueIds`；选择 1–10 项，超过 10 返回 validation 错误 | 同对应 tab |
| 回复页 | replies: `post_id==id,is_tombstoned==false`, order `created_at asc,__name__ asc` | `[created_at,docId]` |
| 当前页应验状态 | 对当前 replies page 的 root IDs 每 10 个一组：verifications `post_id==id,root_reply_id in ids,revoked_at==null`, order `created_at asc,__name__ asc` | 随 reply page，无独立 cursor |
| 帖子应验总数 | verifications `post_id==id,revoked_at==null` 的 `count()` aggregation | 无 |
| 最终反馈 | `feedback_{postId}` document get | 无 |
| viewer state | post owner、当前 viewer 的 like/bookmark deterministic IDs 各 direct get；不读 root owners | 无 |
| 收藏列表 | bookmarks: `provider_uid==auth.uid`, order `created_at desc,__name__ desc`，再以最多 10 IDs 的 `documentId in` 批量取 posts | `[created_at,docId]` |

content/time 过滤在 adapter 对扫描页执行，因为 Firestore 组合索引爆炸。
每次底层扫描 `scanLimit=min(requestedLimit*5,100)`，返回 cursor 指向**最后扫描**而非最后返回的
post；结果不足一页也合法，继续分页不会重复/漏扫。content 读取 `has_chart`，time 读取
`created_at`。当前 RI 的 feedback/reply 状态 filter 只接受 `all`；其他值返回
`filter/not-supported-in-direct-phase`，UI 当前 Phase 不展示这些选项。同一 cursor 只能与
完全相同的 tab/filter 使用，cursor envelope 含 filter hash，错用返回 invalidArgument。

### 10.2 必须提交的 index 条目

`firestore.indexes.json` 必须包含以下精确字段序列；`__name__` 由 Firestore 随同末字段方向
使用，无需在 JSON 重复声明。每个 `TECH?` 表示分别生成“不含 technique”与包含
`allowed_chart_technique_ids: CONTAINS` 的两条：

```text
posts: status ASC, created_at DESC                         (TECH?)
replies: post_id ASC, is_tombstoned ASC, created_at ASC
verifications: post_id ASC, root_reply_id ASC, revoked_at ASC, created_at ASC
verifications: post_id ASC, revoked_at ASC
bookmarks: provider_uid ASC, created_at DESC
```

因此 posts 共 2 条（有/无 technique）、replies 1、verifications 2、bookmarks 1，总计 6 条
current-phase composite indexes。旧
`author_app_user_id/presentation_mode` profile indexes 标成后续且不得被当前 query 依赖。

### 10.3 固定读取成本

- 详情固定组合：1 post get、1 owner get、1 replies page、每 10 个当前页 root IDs 1 次
  verification query、1 verification count aggregation、1 feedback get，以及 viewer 的
  like/bookmark direct gets；不读 root owner。
- Feed 每个扫描 batch 只有 1 query，不逐帖读取 owner/identity_map；Feed 卡片本期不加载关系计数。
- 合同测试以 recording adapter/emulator instrumentation 断言 query/get 的次数与
  query shape；不把 Emulator 无法可靠模拟的 billed reads 当作通过证据。
- 本期不维护 profile/reputation 派生计数。
- 游客 5–10 条代表性回复必须等后续可信 read projection/Function/REST 才能成为不可绕过策略；
  本期 UI 截断只能作为展示实验，不能作为安全或转化验收证据。

每个生产查询必须在 `firestore.indexes.json` 有明确索引，并由 Emulator 大线程 fixture 记录
Firestore read 数；数据量增长时固定组合查询次数不随回复逐条增长。

## 11. 单一 Rules 源与发布顺序

生产唯一 Rules 文件是 `firebase/infrastructure/firestore.rules`；
`firebase/infrastructure/emulator/firebase.json` 必须引用它。删除旧 emulator Rules 文件；
不保留“删除或生成”二选一。

发布顺序：

1. 在隔离 Emulator 以 production Rules 跑 adapter contract、真实生产 payload 和成对
   allow/deny 测试；不可达、skip、allow-all 任一出现即失败。
2. 部署兼容现有只读流与新 direct schema 的 Rules/indexes；旧 callable 不在兼容承诺内。
3. 发布 Shell feature flag，五个端口一次性切换到 direct adapter。
4. 观测 permission denied、index missing、重复事实和 read 数后再扩大 rollout。

现有 callable 依赖公开 post/reply 内的旧 author 字段，与新 public/private schema 不兼容，
因此 **禁止把“切回 callable”作为本期回滚**。回滚只允许：关闭新建/编辑类 UI feature flag，
保留 direct adapter 对已创建内容的读写，修复后重新开启；Rules 只能向前修复，不能回滚到
拒绝新 schema 的版本。若未来要恢复 callable，必须先让全部 callable 读取 owner/revision 新
schema，并在 Emulator 覆盖“direct 创建后 callable 编辑、删除、应验、反馈”后另行切换。
任何真实部署、清库或迁移都需人类批准。

## 12. 装配与验收门禁

实现位于 `xuan-storage/firebase/`，只从其 `playground.dart` 导出；Shell 仅在
`xuan-shell/lib/playground/shell_playground_bootstrap.dart` 选择 provider。
当前 Shell worktree 已使用新 command/query ports，不迁回 deprecated facade。装配表冻结如下：

| RI port / 方法 | 当前 Phase adapter | `PlaygroundDependencies` 字段 | UseCase 消费方 |
|---|---|---|---|
| `PlaygroundPostCommandRepository`: `createPost/editPost/tombstonePost/getPublicPost` | `FirestoreDirectPlaygroundPostCommandRepository` | `postCommandRepository` | `CreatePostUseCase`, `LoadPostDetailUseCase`；编辑/删除动作复用同 port |
| `PlaygroundReplyCommandRepository`: `createRootReply/createDiscussionReply/editReply/tombstoneReply` | `FirestoreDirectPlaygroundReplyCommandRepository` | `replyCommandRepository` | `CreateReplyUseCase`；编辑/删除动作复用同 port |
| `PlaygroundEngagementRepository`: `setContentLike/setBookmark/getViewerState/getMyBookmarkedPosts` | `FirestoreDirectPlaygroundEngagementRepository` | `engagementRepository` | `LikeUseCase`, `BookmarkUseCase`；viewer state/detail 调用 |
| `PlaygroundVerificationRepository`: `verifyRootReply/revokeVerification/getVerificationsForPost/isRootReplyVerified` | `FirestoreDirectPlaygroundVerificationRepository` | `verificationRepository` | `VerifyReplyUseCase`, `LoadPostDetailUseCase` |
| `PlaygroundOutcomeFeedbackRepository`: `setOutcomeFeedback/revokeOutcomeFeedback/getOutcomeFeedback` | `FirestoreDirectPlaygroundOutcomeFeedbackRepository` | `outcomeFeedbackRepository` | `SetOutcomeFeedbackUseCase`, `LoadPostDetailUseCase` |
| `PlaygroundFeedQueryRepository`: 四个 Feed 查询 | 更新现有 Firebase query adapter 读取 v1 公开 schema | `feedQueryRepository` | `LoadFeedUseCase` |
| `PlaygroundThreadQueryRepository`: registered detail/reply page | 更新现有 Firebase query adapter；guest representative 方法当前返回明确 `unavailable`，不伪造可信限制 | `threadQueryRepository` | `LoadPostDetailUseCase` |
| `PlaygroundReportRepository` | 现有直写 adapter，仅 Rules 回归 | `reportRepository` | `ReportContentUseCase` |

profile/notification/conversation 字段继续注入现有 adapter 以保持构造兼容，但其页面与 UseCase 不
属于本期验收，不能调用新 public schema 推导完成状态。

Shell 与 storage 必须解析同一 RI revision：当前冻结基线为
`repository-interface-playground@756121b233c494093b2e1130163e93a5cdc57839` 或包含完全相同
ports/error contract 且通过共同合同的后继提交。提交代码不得把 worktree `path` override 写入
pubspec；CI lock/resolution 证据必须显示两仓使用同一 commit。

### 12.1 Viewer capability 投影

公开 DTO 继续不含 owner ID。query adapter 对当前已认证 viewer 只做点查：

- `getPublicPost/getRegisteredThreadDetail` 额外 `get(post_owner/{postId})`；本人文档存在且
  `provider_uid == auth.uid` 时填充 `viewerState.isOwner/canEdit/canDelete/canSetFeedback`。
- 页面级 `canVerify` 只表示当前 viewer 是帖子 owner；所有未墓碑 root 可显示应验动作。点击后
  Rules 读取该 root owner 并拒绝 Poster 自己的回复，adapter 映射为 `authorization/forbidden`。
  UI 收到该错误后保持未应验状态并提示“不能应验自己的回复”。这样不做逐 root owner N+1。
- 非 owner、未认证、owner 文档缺失或不一致全部 fail closed 为 false；真正写入仍由 Rules 决定。
- owner 文档只允许 get、禁止 list；不通过公开 presentation ID 反查 owner。

UI 只根据 provider-neutral viewer state 显示编辑、删除、应验、撤回应验和反馈控件；不得比较
`appUserId` 与 `publicPresentationUserId`。owner/非 owner/未认证/owner 缺失四种情况必须有合同
和 widget 测试；另测 Poster 自己 root 的按钮可见但提交被 Rules 拒绝且 UI 回滚。

Design 进入 Coding 前必须能机械证明：

- OpenSpec 已把直写范围标成当前 Phase，并把 Functions、通知、私信、个人主页、游客代表性
  服务端限制移到后续 Phase；不存在相反的 Phase 1 SHALL。
- 公开可读文档和 DTO 全部不含 provider UID、`appUserId`、姓名、邮箱或可反推稳定 ID。
- owner/identity_map 只允许本人 get，禁止 list；public/owner 双文档 atomic Rules 成对测试通过。
- revision 子集合 update/delete 全拒绝，编辑必须连续追加 revision。
- reply 的跨帖、跨 root、负 depth、第三层、墓碑目标全部有拒绝测试。
- post/reply composer 的同一逻辑提交重试复用 key；成功/取消才清除。
- Rules 对 required keys、types、枚举、长度、附件判别联合、时间和状态转换有真实测试。
- verification 与 feedback 的 verify/revoke/re-verify、发布/编辑/撤回/再发布状态机通过。
- 三个页面生产写路径零 `httpsCallable`；callable 源码仍存在但未被 Shell 注入。
- Emulator production-Rules gate 无 skip；Feed/详情读取成本符合固定基线。

以上任一项未通过，结论只能是“可继续设计/编码，禁止发布”，不能声明 Firestore 直写完成。
