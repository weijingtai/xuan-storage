# Playground Firestore 直写设计

## 目标

一期让广场列表、发帖和帖子详情直接接入 Firestore。保留现有 Firebase Functions 写入实现，但不在生产装配中启用。

## 范围

直写覆盖三个页面已经使用的写操作：

- 帖子：创建、编辑、软删除。
- 回复：根回复、二级回复、编辑、软删除。
- 互动：点赞、收藏、应验、撤回应验、最终反馈、撤回反馈。

个人主页、通知、私信及其 UI/UseCase/Repository 改造延后。本次不修改 UI 协议，也不实现 REST。

## 结构

调用链保持：

`UI -> ViewModel -> UseCase -> Repository Interface -> FirestoreDirectRepository`

- 新增 Firestore 直写实现；不改变 Repository Interface 的业务边界。
- 装配层默认注入直写实现。
- Functions 实现继续保留，后续可以重新切换。
- 读取沿用现有 Firestore Query Repository。

## 安全与数据合同

- Firestore Rules 只允许已认证用户写入。
- 创建时作者身份来自当前登录上下文；禁止客户端冒充其他作者。
- 更新和软删除仅允许资源作者操作；应验和最终反馈仅允许帖子作者操作。
- Rules 使用字段白名单，并禁止修改资源 ID、作者、所属帖子和创建时间等不可变字段。
- 写入字段必须与现有列表和详情读取模型一致。
- 计数等并发状态使用 Firestore transaction 或 batch；不得依赖客户端先读后写。

## 错误与验证

- Firebase 异常映射到既有 Repository 错误类型，不向 UI 暴露 Firebase DTO。
- 按 TDD 先证明当前 Functions 调用或 Rules 拒绝导致测试失败，再实现直写。
- Emulator 验收主链路：发帖后列表可见，详情可读，可以回复、点赞、收藏、应验和反馈；越权写入被拒绝。
- 不以 Fake、skip 或 allow-all Rules 作为通过证据。

