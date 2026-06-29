# scope_uid 与身份(匿名 / 用户 / 设备)绑定设计

> **状态**:设计草案,待并入 OpenSpec change `typed-record-backed-repository-base`
> **日期**:2026-06-27
> **读者**:正在实现统一记录存储 / Base 仓库 / 账户接入的 AI Agent(假定零背景)
> **适用范围**:`xuan-storage/drift`(记录层)、`xuan-account`、`repository-interface-account`
> **前置文档**:
> - `xuan-storage/docs/superpowers/specs/2026-06-25-record-storage-base-class-design.md`(Base 设计)
> - `docs/superpowers/specs/2026-06-24-unified-record-system-CONVERGED-design.md`(统一记录 SSOT)
> **重要**:本文只做设计与决策说明,**不要求你在阅读后立即改代码**;请先理解,再按所属任务的指令推进。

---

## 0. TL;DR(先读这段)

统一记录系统的每条记录都带一个 `scope_uid`,它是**多租户隔离的红线**:所有查询、watch、删除都必须按当前 `scope_uid` 过滤,否则会出现跨用户数据泄漏。

问题:用户身份会变——**没登录时是匿名 id,登录后是用户 id,没有 Firebase 时只有设备 id**。如果直接把 `scope_uid` 设成"当前身份 id",那么"匿名→登录"会让 `scope_uid` 改变,导致之前写的记录变成孤儿(在新 scope 下查不到)。

本方案的核心决定:

> **`scope_uid` 不等于身份 id。它是一个首次启动就铸造、终生不变的本地代理键(UUIDv7)。匿名 id / 用户 id / 设备 id 都只是指向它的"别名"。身份变化 = 改别名,记录原地不动。**

这样"匿名→登录"从 **O(N) 重写所有记录** 降级为 **O(1) 插入一条别名**,并连带解掉了多个 CRITICAL 风险。

---

## 1. 背景:scope_uid 是什么,为什么不能错

- 记录主表 `t_record_meta` 有列 `scope_uid`(见 `xuan-storage/drift/lib/tables/record_meta_table.dart`)。
- 数据源 `DriftRecordDataSource`(`xuan-storage/drift/lib/record/drift_record_data_source.dart`)在**每一个**读/写/删/watch 查询里都加 `scope_uid == 当前 scope` 过滤,这是隔离红线 S1。
- 当前 `DriftRecordDataSource` 的 `scopeUid` 是**构造期固定的 `final` 字段**:
  ```dart
  DriftRecordDataSource(this.db, {required this.scopeUid});
  ```
  也就是说:一个数据源实例绑定一个 scope,**运行时不能改**。
- 目前演示装配里 `scopeUid` 被**硬编码成模块名**(`xuan-meihuayishu/example/lib/main.dart` 里 `scopeUid: 'meihua'`)。这是临时占位,**把"模块隔离轴"和"租户隔离轴"混用了**,必须纠正——scope 是"谁的数据",module 是"哪种占测",两者正交。

---

## 2. 账户体系现状(已核实,带文件路径)

`xuan-account` 已经有一套相当完整的身份体系,本方案**几乎全部复用它,不自研身份**。关键事实(均已核对源码):

| 概念 | 位置 | 说明 |
|------|------|------|
| `AccountSession` | `repository-interface-account/lib/src/models/account_session.dart` | 当前会话。含 `appUserId`(`AccountUserId`)、`providerUserId`、`kind`(`AccountKind.anonymous` / `registered`)、`providerId`、`email`。`isAnonymous` getter。 |
| `AppUserIdResolver` | `repository-interface-account/lib/src/ports/app_user_id_resolver.dart` | `resolve(providerUserId, providerId) → AccountUserId`。把"后端身份"映射成 **app 自有的稳定 id**。 |
| `AccountSessionRepository` | `repository-interface-account/lib/src/ports/account_session_repository.dart` | `getCurrentSession()` / `saveCurrentSession()` / `clearCurrentSession()`。 |
| 会话持久化实现 | `xuan-storage/preferences/lib/src/account/preferences_account_session_repository.dart` | 会话(含 appUserId)落 shared_preferences → **跨重启稳定**。 |
| `GuestIdentityStore` | `xuan-account/lib/auth/guest_identity_store.dart` | 匿名访客 id:有匿名会话则返回其 `appUserId`,否则生成 `guest-<随机hex>`。 |
| `AuthCoordinator` | `xuan-account/lib/auth/auth_coordinator.dart` | 登录编排。**关键**:见下文升级 / 冲突逻辑。 |
| `AccountIdentityLink` | `repository-interface-account`(模型) | `(anonymousAppUserId, registeredAppUserId, providerId, linkedAt)`。注册时由 AuthCoordinator 写入,**这就是天然的"匿名↔注册"映射**。 |
| `GuestAccountConflictDelegate` | `xuan-account/lib/auth/auth_coordinator.dart` | `mergeGuestIntoAccount(guestAppUserId, accountAppUserId)` / `discardGuest(guestAppUserId)`。冲突时的合并/丢弃钩子。 |
| `DeviceIdentityProvider` / `DeviceIdentity` | `xuan-storage/core/lib/model/ports.dart`(约 240–271 行) | `DeviceIdentity.deviceId`「稳定且不含敏感信息」。(**已核实:仅端口,全仓无实现。但不阻塞——Ghost scope_uid 是 bootstrap 自己铸的本地 UUIDv7,自给自足,不依赖 DeviceIdentityProvider。降级为可选/后续,从关键路径移除。**) |
| `AccountIdentityLinkRepository` | `repository-interface-account` | **已存在**(`InMemoryAccountIdentityLinkRepository`,见 `no_firebase_assembly_test`)。AuthCoordinator 注册时已写 `AccountIdentityLink(guest→registered)`。`ScopeResolver` 注入此依赖即可消费 link,bind-on-upgrade 不需额外造数据源。 |

### 2.1 AuthCoordinator 的两条关键路径(决定 scope 行为)

1. **匿名 → 注册新账户**(`signInOrRegisterWithEmailPassword`):若当前有 guest 会话且解析出的注册 `appUserId` 与 guest 不同,**会写一条 `AccountIdentityLink(guest → registered)`**,然后激活注册身份。→ 这条 link 就是 scope 别名的数据来源。

2. **登录已存在账户**(`signInWithEmailPassword`):若 guest 存在且 `accountAppUserId != guestAppUserId`,**抛 `GuestAccountConflict`**。→ 这正是"本地有 guest 数据,却登录了另一个已有账户"的真冲突,交给 delegate 处理。

### 2.2 sessionChanges() — 已核实为真 stream

`AuthCoordinator.sessionChanges()` 转发 `authGateway.watchSession()`(端口 `account_auth_gateway.dart:4`)。**Firebase 真实现** `xuan-storage/firebase/lib/account/firebase_account_auth_gateway.dart:17` 有落地,且 emulator 测试验证了 `signOut → watchSession emit null`。→ **epoch 重绑机制可直接订阅它,不用自己包一层。**

### 2.3 identityLinkRepository — 已存在,可复用

`AccountIdentityLinkRepository` 有 `InMemoryAccountIdentityLinkRepository` 实现(见 `no_firebase_assembly_test`)。AuthCoordinator 注册时已写入 `AccountIdentityLink(guest→registered)`。**`ScopeResolver` 只需注入此依赖即可消费 link**,bind-on-upgrade 不需额外造数据源。

> 结论:`appUserId` 在"匿名→注册"时**会变**(`guest-x` → `reg-y`),但系统已经把这次变化记录在 `AccountIdentityLink` 里,并为冲突留了 delegate。本方案就架在这两个接缝上。

---

## 3. 问题:为什么不能直接 `scope_uid = appUserId`

身份是三态,且会迁移:

| 状态 | 当前身份取值 |
|------|------|
| 没登录(匿名) | guest `appUserId`(如 `guest-x`) |
| 登录后 | registered `appUserId`(如 `reg-y`) |
| 无 BaaS / 纯单机 | device id |

若 `scope_uid` 直接取"当前身份":

- **CRITICAL-1 升级孤儿**:匿名写的记录在 `scope=guest-x`;登录后 scope 变 `reg-y`;旧记录查不到了。要么 O(N) 重写所有记录的 scope_uid,要么丢数据。
- **CRITICAL-2 运行时切换 vs 构造期固定**:`DriftRecordDataSource.scopeUid` 是 `final`。登录使 scope 变化,但持有旧 scope 的数据源实例还在用 → 写错租户 / 泄漏。
- **CRITICAL-3 空值坍缩**:`appUserId` 边界可能为空字符串;一旦 `scope_uid=''`,所有用户记录挤进同一桶 → 泄漏。
- **HIGH-1 已有账户冲突**:登录一个已有账户且本地有 guest 数据 → 两份数据要合并。
- **HIGH-2 登出残留**:登出后注册用户的本地记录仍在(多人共用设备隐私)。

---

## 4. 方案:稳定代理键 + 身份别名账本

### 4.1 核心思想

```
身份(会变)          别名账本                稳定分区(不变)
─────────          ─────────              ─────────────
Ghost(首启)  ┐
匿名 guest-x  ┤──►  identity → scope_uid ──►  scope_uid(永不变)
注册 reg-y    ┤                                  │
Device id     ┘                                  ▼
                                            t_record_meta(记录原地不动)
```

- 首次启动(还没任何登录)就**铸造一个本地 `scope_uid`(UUIDv7)并持久化**——这就是用户口中的 "Ghost UID",同时天然充当无 BaaS 时的设备 scope。
- 所有记录都写在这个 `scope_uid` 下。
- 匿名 id、注册 id、设备 id 都是**指向 scope_uid 的别名**,记在别名账本里。
- **"匿名→登录" = 给同一个 scope_uid 多挂一条别名(O(1) 插入),不动任何记录行。**
- 只有"登录另一个已存在账户"才是真冲突 → 另起一个新 scope_uid,并由 delegate 决定是否合并。

### 4.2 为什么这样能解决问题(直觉)

把"身份会不会变"和"记录存在哪个分区"**彻底解耦**。身份在变的是"别名→scope_uid"的映射,而记录所在的 scope_uid 始终不变。于是升级不再触碰记录,运行时也不需要在升级时切 scope。

---

## 5. 数据模型(本地,落主库)

新增一张小表(命名建议,实施时以 OpenSpec spec delta 为准):

```text
t_scope_alias
  auth_kind   TEXT      -- 'anonymous' | 'registered' | 'device'
  auth_id     TEXT      -- appUserId 或 deviceId
  scope_uid   TEXT      -- 指向的稳定分区键
  linked_at   INTEGER
  PRIMARY KEY (auth_kind, auth_id)
```

外加一个 bootstrap 单例(可存 preferences):`active_device_scope_uid` = 本设备首启铸的 ghost scope_uid。

> 注:别名账本的内容**可由现有 `AccountIdentityLink` 派生**(匿名↔注册的映射那部分已经有了),`t_scope_alias` 主要补充"identity → 本地 scope_uid"这一跳和 device 这一态。实施时优先复用,避免重复事实源。

---

## 6. 解析算法:`ScopeResolver.resolve(session)`

```text
输入:当前 AccountSession?(来自 AccountSessionRepository.getCurrentSession)
输出:非空的 scope_uid

if session == null:                       // 登出 / 尚未登录
    return ledger.deviceScope()           // bootstrap 铸的本地 ghost/device scope

appUserId = session.appUserId.value
guard(appUserId 非空)                      // 否则抛错,绝不返回空串(解 C3)

hit = ledger.scopeForIdentity(appUserId)
if hit != null:
    return hit                            // 本机老用户 / 匿名续命

// appUserId 还没有别名:
device = ledger.deviceScope()
if device 未被别的身份占用
   OR 经 identityLinkRepository 能把 appUserId 链回 device 的占用者:
    ledger.bind(appUserId → device)       // ★ 升级:O(1) 插别名,scope 不变(解 C1)
    return device
else:
    // 真冲突:本地 device scope 已属另一个用户,且无 link 关系(解 H1)
    newScope = ledger.mintAndBind(appUserId)
    通知 GuestAccountConflictDelegate(可选合并 / 保持分开)
    return newScope
```

要点:

- **唯一出口**:所有 scope 取值只经 `ScopeResolver`,空值在此处一票否决(解 C3)。
- **升级零重写**:命中 link → 复用 device scope,只插别名(解 C1)。
- **冲突收窄**:只有"登录已存在账户且无 link"才另起新 scope(解 H1)。

---

## 7. 运行时切换:session epoch 重绑(解 C2)

> **Phase**:此节完整实现属于 **Phase 5+**(双模块跑通之后)。Phase 2.5 只交付 ghost bootstrap + bind-on-upgrade,epoch 重绑在 MVP 阶段不会触发(升级不切 scope,真换人才触发)。

因为升级不再切 scope,真正的切换只剩"登出 → 换另一个人登录",频率极低。处理方式:

- 引入 **session epoch**:每次 active scope 真正变化(订阅 `AuthCoordinator.sessionChanges()`)就 mint 一个新 epoch。
- record store 子树(`DriftRecordDataSource` / `LocalRecordRepository` / 各模块 `RecordBacked*Repository`)**按 epoch 重建**;旧的 watch 流随旧 epoch 关闭,避免悬挂订阅写错 scope。
- 这样 `scopeUid` 仍可保持构造期 `final`(无需改成可变),只是"实例的生命周期 = 一个 epoch"。

> 轻量替代:把 `scopeUid` 改成每次操作从 `ActiveScopeHolder` 动态读取。可行但 watch 流生命周期更难管,**优先用 epoch 重绑**。

---

## 8. 跨设备 / 云:再加一层"所有者"

> **Phase**:此节完整实现属于 **Phase 5+**。Base+双模块 MVP 阶段只在单设备上跑,不涉及跨设备聚合。

本地 `scope_uid` 是**设备内分区键**(每台设备各自铸造,互不相同)。跨设备聚合不能用它,必须用**注册 `appUserId` 作为云端 owner**:

- 记录同步上云时,由别名账本把 `scope_uid` 解析成当前 owner `appUserId` 并附带。
- 云端按 `owner = appUserId` 聚合;本地查询仍按 `scope_uid` 隔离。
- 同一用户两台设备:各有各的本地 scope_uid,云端用 owner 统一。
- **好处**:升级时 scope_uid 不变 → 本地 outbox / sync_state **无需迁移**(解 MEDIUM 同步漂移);仅冲突合并那一次才动同步,范围有界。

---

## 9. 风险逐条缓解

| 风险 | 等级 | 本方案缓解 |
|------|------|-----------|
| C1 升级孤儿 | CRITICAL | scope_uid 不变,升级仅 `INSERT alias`,零行重写 |
| C2 运行时切换 vs 构造期固定 | CRITICAL | 升级不切 scope;真换人才按 session epoch 重建 store |
| C3 空 scope 坍缩泄漏 | CRITICAL | scope_uid 由账本铸造,`ScopeResolver` 唯一出口,空值抛错不落库 |
| H1 已有账户冲突合并 | HIGH | 收窄到"登录已有账户"一种;默认保持分开,opt-in 才跑唯一一次 O(N) 合并 |
| H2 登出本地残留 | HIGH | 默认保留 + scope 隔离不可见;给"登出即清"开关;根治=按 scope 静态加密 |
| device id 不稳定 | MEDIUM | scope_uid 存本地存储,不依赖 OS vendor id;重装即新设备语义自洽 |
| 同步 scope 漂移 | MEDIUM | 升级 scope_uid 不变 → outbox/sync 无需迁移 |

---

## 10. 复用的现有接缝(别重造)

- 身份与稳定 id:`AppUserIdResolver`、`AccountSession.appUserId`。
- 跨重启持久化:`preferences_account_session_repository`。
- 匿名↔注册映射:`AccountIdentityLink`(AuthCoordinator 已写)。
- 冲突合并/丢弃:`GuestAccountConflictDelegate`。
- 无 BaaS 设备身份:`DeviceIdentityProvider`(端口已在,**落地实现待核**)。
- 会话变化订阅:`AuthCoordinator.sessionChanges()`。

---

## 11. 非目标 / 已知残留(诚实说明)

1. **合并去重**仍是固有难点(H1 opt-in 路径):UUIDv7 保证无主键碰撞,但内容级重复需按 `divination_uuid` / 内容哈希去重。本方案只是把它**关进唯一一个角落**,没有消灭它。
2. **按 scope 静态加密**(H2 根治)是额外工程,MVP 可先用 scope 隔离 + 登出清除兜底。
3. `DeviceIdentityProvider` 只确认了端口,全仓无实现。**但这不阻塞:Ghost scope_uid 是 bootstrap 自己铸的本地 UUIDv7,自给自足,不依赖 DeviceIdentityProvider。** 已从关键路径移除,降级为可选/后续。
4. 本方案不改业务模块端口,不改占测算法。

---

## 12. 验收要点(实施时需覆盖的测试场景)

- 首启无会话 → scope_uid 非空且稳定(重启不变)。
- 匿名写 3 条记录 → 注册新账户 → 仍能读到那 3 条(scope_uid 未变,别名已加)。
- 登录"另一个已有账户"(无 link)→ 触发冲突路径,默认看不到前一个 scope 的记录。
- 登出 → 再以匿名进入 → 看不到注册用户的记录(scope 隔离)。
- 任何分支都不产生空 `scope_uid`(负向测试:resolver 对空 appUserId 抛错)。
- 两个 scope 用相同 `divination_uuid` 索引值互不可见(沿用 Base 设计 §14.3 的隔离测试)。

---

## 13. 参考

- 统一记录 SSOT:`docs/superpowers/specs/2026-06-24-unified-record-system-CONVERGED-design.md`(S1 scope 红线、§14 三打包形态、Fork/Merge)。
- Base 仓库设计:`xuan-storage/docs/superpowers/specs/2026-06-25-record-storage-base-class-design.md`(`ScopedRecordStore.scopeUid`、scope/module 隔离测试)。
- 各模块现状分析:`xuan-storage/docs/superpowers/specs/2026-06-28-module-record-repository-analysis.md`。
- OpenSpec change:`openspec/changes/typed-record-backed-repository-base/`(本设计的 scope 决策应并入其 design + spec delta)。
- 账户源码:`xuan-account/lib/auth/`、`repository-interface-account/lib/src/`。

---

## 14. Phase 切分与交叉引用

### 14.1 为什么拆分

本设计的全部内容(ghost bootstrap + bind-on-upgrade + epoch 重绑 + 冲突合并 + 云端 owner)若一次性塞进 Phase 3,会把 Base 的正确性绑死在整套身份机器上,风险太高。

### 14.2 分阶段交付

| 阶段 | 内容 | 解掉的风险 | 前置条件 |
|------|------|-----------|---------|
| **Phase 2.5**(Phase 3 之前) | `ScopeResolver` + ghost bootstrap + `t_scope_alias` + **bind-on-upgrade** + 空值守卫 | C1(升级孤儿)、C3(空 scope) | `identityLinkRepository` 已存在;`sessionChanges()` 已有真实现 |
| **Phase 3**(Base + 梅花迁移) | Base 实现 + 梅花 codec 迁移 + DI 装配(从 `ScopeResolver` 取 scope 替掉 `scopeUid:'meihua'`) | — | Phase 2.5 交付了真实非空 scope 来源 |
| **Phase 5+**(双模块跑通之后) | epoch 重绑(C2 完整)、冲突合并(H1)、按 scope 加密(H2)、云端 owner 层 | C2/H1/H2、跨设备 | 这些只在"运行时换人/登录已有账户/跨设备"才触发 |

### 14.3 与 Base 设计文档的关系

本文档是 Base 设计文档(`2026-06-25-record-storage-base-class-design.md`)的**前置依赖,非替代**:

- Base 设计 §11 规定了 scope 从 `ScopedRecordStore.scopeUid` 来、构造期固定。
- 本文档解释了这个值的**生命周期语义**:它怎么铸造、怎么绑定、身份变化时怎么不变。
- 两篇文档通过本节的交叉引用关联,不需重写任一文档。

### 14.4 Phase 2.5 的最小可交付

```
Phase 2.5 交付物:
  ✅ ScopeResolver(含 ghost bootstrap + bind-on-upgrade + 空值守卫)
  ✅ t_scope_alias 表(schema migration, additive)
  ✅ Phase 3 的 DI 能用 ScopeResolver.resolve(session) 产出真实 scope_uid
  ❌ 不包含:epoch 重绑、冲突合并、按 scope 加密、云端 owner
```
