/**
 * Firestore Security Rules — allow/deny 成对测试。
 *
 * 使用 @firebase/rules-unit-testing 连接本地 Emulator。
 * 运行前提：Firebase Emulator Suite 已启动（Firestore on 8081, Auth on 9099）。
 *   FIRESTORE_EMULATOR_HOST=localhost:8081
 *   FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
 *   npm test -- firestore.rules
 */

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import { readFileSync } from 'fs';
import { resolve } from 'path';

const rulesPath = resolve(__dirname, '../../firestore.rules');
const rulesContent = readFileSync(rulesPath, 'utf8');

const PROJECT_ID = 'playground-test';
const FIRESTORE_HOST = process.env.FIRESTORE_EMULATOR_HOST || 'localhost:8082';
const [FIRESTORE_HOSTNAME, FIRESTORE_PORT_STR] = FIRESTORE_HOST.split(':');
const FIRESTORE_PORT = parseInt(FIRESTORE_PORT_STR, 10);
const AUTH_HOST = process.env.FIREBASE_AUTH_EMULATOR_HOST || 'localhost:9099';

let testEnv: RulesTestEnvironment;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      host: FIRESTORE_HOSTNAME,
      port: FIRESTORE_PORT,
      rules: rulesContent,
    },
  });
});

afterAll(async () => {
  if (testEnv) await testEnv.cleanup();
});

beforeEach(async () => {
  if (testEnv) await testEnv.clearFirestore();
});

// ---- 辅助函数 ----

function aliceContext() {
  return testEnv.authenticatedContext('alice-uid', {});
}

function bobContext() {
  return testEnv.authenticatedContext('bob-uid', {});
}

function unauthContext() {
  return testEnv.unauthenticatedContext();
}

// ==============================
// playground_posts
// ==============================

describe('playground_posts', () => {
  test('deny: 认证客户端即使自报作者也不能创建帖子', async () => {
    const db = aliceContext();
    await assertFails(db.firestore().collection('playground_posts').doc('post-1').set({
      text: '测试帖', author_provider_uid: 'alice-uid', author_app_user_id: 'forged',
      presentation_mode: 'stableAlias', status: 'active',
    }));
  });

  test('deny: 未认证用户创建帖', async () => {
    const db = unauthContext();
    const fs = db.firestore();
    await assertFails(
      db.firestore().collection('playground_posts').doc('post-2').set({
        text: '未认证',
        author_provider_uid: 'anon',
        status: 'active',
      }),
    );
  });

  test('deny: 伪造 author（author_provider_uid != auth.uid）', async () => {
    const db = aliceContext();
    const fs = db.firestore();
    await assertFails(
      db.firestore().collection('playground_posts').doc('post-3').set({
        text: '伪造帖',
        author_provider_uid: 'bob-uid',
        status: 'active',
      }),
    );
  });

  test('deny: 客户端写入 like_count 被字段 allowlist 拒绝', async () => {
    const db = aliceContext();
    const fs = db.firestore();
    await assertFails(
      db.firestore().collection('playground_posts').doc('post-4').set({
        text: '尝试写计数',
        author_provider_uid: 'alice-uid',
        status: 'active',
        like_count: 9999,
      }),
    );
  });

  test('deny: 客户端写入 verification_count 被拒绝', async () => {
    const db = aliceContext();
    const fs = db.firestore();
    await assertFails(
      db.firestore().collection('playground_posts').doc('post-5').set({
        text: '尝试写应验数',
        author_provider_uid: 'alice-uid',
        status: 'active',
        verification_count: 100,
      }),
    );
  });

  test('deny: 客户端写入 reputation 被拒绝', async () => {
    const db = aliceContext();
    const fs = db.firestore();
    await assertFails(
      db.firestore().collection('playground_posts').doc('post-6').set({
        text: '尝试写声望',
        author_provider_uid: 'alice-uid',
        status: 'active',
        reputation: 'expert',
      }),
    );
  });

  test('deny: 作者也不能直连编辑或墓碑帖子', async () => {
    const db = aliceContext();
    await assertFails(db.firestore().collection('playground_posts').doc('post-8').update({ text: '修改后' }));
    await assertFails(db.firestore().collection('playground_posts').doc('post-8').delete());
  });
});

// ==============================
// playground_replies
// ==============================

describe('playground_replies', () => {
  test('deny: 认证客户端不能创建根回复或伪造冻结结构', async () => {
    const db = aliceContext();
    await assertFails(db.firestore().collection('playground_replies').doc('r-1').set({
      body: '根回复', post_id: 'p-reply-1', depth: 0,
      author_provider_uid: 'alice-uid', author_app_user_id: 'forged', is_tombstoned: false,
    }));
  });

  test('deny: 未认证用户创建回复', async () => {
    const db = unauthContext();
    const fs = db.firestore();
    await assertFails(
      db.firestore().collection('playground_replies').doc('r-2').set({
        body: '未认证回复',
        post_id: 'p-any',
        depth: 0,
        author_provider_uid: 'anon',
      }),
    );
  });

  test('deny: 第三层 depth=2 被拒绝', async () => {
    const db = aliceContext();
    const fs = db.firestore();
    await assertFails(
      db.firestore().collection('playground_replies').doc('r-3').set({
        body: '第三层',
        post_id: 'p-any',
        depth: 2,
        author_provider_uid: 'alice-uid',
        is_tombstoned: false,
      }),
    );
  });

  test('deny: 客户端写入 like_count 被字段 allowlist 拒绝', async () => {
    const db = aliceContext();
    const fs = db.firestore();
    await assertFails(
      db.firestore().collection('playground_replies').doc('r-4').set({
        body: '试写计数',
        post_id: 'p-any',
        depth: 0,
        author_provider_uid: 'alice-uid',
        like_count: 500,
      }),
    );
  });

  test('deny: 作者也不能直连编辑或删除回复', async () => {
    const db = aliceContext();
    await assertFails(db.firestore().collection('playground_replies').doc('r-6').update({ body: '改写' }));
    await assertFails(db.firestore().collection('playground_replies').doc('r-6').delete());
  });
});

describe('playground_profiles', () => {
  test('deny: profile create/update cannot bypass updateMyProfile callable', async () => {
    const db = aliceContext();
    await assertFails(db.firestore().collection('playground_profiles').doc('forged-app-user').set({
      user_provider_uid: 'alice-uid', display_name: 'forged',
    }));
    await assertFails(db.firestore().collection('playground_profiles').doc('forged-app-user').update({
      display_name: 'forged-again',
    }));
  });
});

// ==============================
// playground_verifications
// ==============================

describe('playground_verifications', () => {
  test('deny: 普通客户端直接写应验', async () => {
    const db = aliceContext();
    const fs = db.firestore();
    await assertFails(
      db.firestore().collection('playground_verifications').doc('v-1').set({
        post_id: 'p-1',
        root_reply_id: 'r-1',
        poster_user_id: 'alice-uid',
        created_at: new Date(),
      }),
    );
  });

  test('allow: 认证用户读取应验', async () => {
    const db = aliceContext();
    const fs = db.firestore();
    // read-only — succeeds on empty collection
    await assertSucceeds(
      db.firestore().collection('playground_verifications').limit(1).get(),
    );
  });

  test('deny: 未认证用户读取应验', async () => {
    const db = unauthContext();
    const fs = db.firestore();
    await assertFails(
      db.firestore().collection('playground_verifications').limit(1).get(),
    );
  });
});

// ==============================
// playground_likes
// ==============================

describe('playground_likes', () => {
  test('deny: 普通客户端直接写点赞', async () => {
    const db = aliceContext();
    const fs = db.firestore();
    await assertFails(
      db.firestore().collection('playground_likes').doc('like-1').set({
        post_id: 'p-1',
        user_provider_uid: 'alice-uid',
      }),
    );
  });
});

// ==============================
// playground_bookmarks
// ==============================

describe('playground_bookmarks', () => {
  test('deny: 用户不能绕过 setBookmark callable 创建自己的收藏', async () => {
    const db = aliceContext();
    await assertFails(
      db.firestore().collection('playground_bookmarks').doc('bm-1').set({
        post_id: 'p-1',
        user_provider_uid: 'alice-uid',
        created_at: new Date(),
      }),
    );
  });

  test('deny: 用户创建他人的收藏', async () => {
    const db = aliceContext();
    const fs = db.firestore();
    await assertFails(
      db.firestore().collection('playground_bookmarks').doc('bm-2').set({
        post_id: 'p-1',
        user_provider_uid: 'bob-uid',
      }),
    );
  });
});

// ==============================
// playground_notifications
// ==============================

describe('playground_notifications', () => {
  test('deny: 普通客户端创建通知', async () => {
    const db = aliceContext();
    const fs = db.firestore();
    await assertFails(
      db.firestore().collection('playground_notifications').doc('n-1').set({
        recipient_provider_uid: 'alice-uid',
        category: 'like',
      }),
    );
  });
});

// ==============================
// playground_media
// ==============================

describe('playground_media', () => {
  test('deny: 用户绑定他人 media object', async () => {
    const db = aliceContext();
    const fs = db.firestore();
    // 用 alice auth 但 owner 写 bob
    await assertFails(
      db.firestore().collection('playground_media').doc('m-1').set({
        owner_provider_uid: 'bob-uid',
        status: 'pending',
      }),
    );
  });

  test('allow: 用户创建自己的 media', async () => {
    const db = aliceContext();
    const fs = db.firestore();
    await assertSucceeds(
      db.firestore().collection('playground_media').doc('m-2').set({
        owner_provider_uid: 'alice-uid',
        status: 'pending',
      }),
    );
  });
});

// ==============================
// playground_messages — Functions only（BLOCK-01 收紧）
// ==============================

describe('playground_messages', () => {
  test('deny: 客户端直接创建消息（即使 sender 为自己的 uid）', async () => {
    const db = aliceContext();
    await assertFails(
      db.firestore().collection('playground_messages').doc('msg-1').set({
        conversation_id: 'conv-1',
        sender_provider_uid: 'alice-uid',
        text: '你好',
        sent_at: new Date(),
      }),
    );
  });

  test('deny: 客户端更新消息', async () => {
    const db = aliceContext();
    await assertFails(
      db.firestore().collection('playground_messages').doc('msg-2').update({
        text: '被篡改',
      }),
    );
  });

  test('deny: 客户端删除消息', async () => {
    const db = aliceContext();
    await assertFails(
      db.firestore().collection('playground_messages').doc('msg-3').delete(),
    );
  });

  test('deny: 客户端伪造 sender 创建消息（伪造他人 uid）', async () => {
    const db = aliceContext();
    await assertFails(
      db.firestore().collection('playground_messages').doc('msg-4').set({
        conversation_id: 'conv-1',
        sender_provider_uid: 'bob-uid',
        text: '伪造 sender',
        sent_at: new Date(),
      }),
    );
  });
});

// ==============================
// playground_idempotency — Functions only
// ==============================

describe('playground_idempotency', () => {
  test('deny: 客户端直接写幂等记录', async () => {
    const db = aliceContext();
    await assertFails(
      db.firestore().collection('playground_idempotency').doc('idem-1').set({
        payload_hash: 'fake',
        result: {},
      }),
    );
  });
});

// ==============================
// identity_map — Functions only（BLOCK-01 resolveMyIdentity）
// ==============================

describe('identity_map', () => {
  test('deny: 客户端直接写身份映射（伪造 appUserId）', async () => {
    const db = aliceContext();
    await assertFails(
      db.firestore().collection('identity_map').doc('alice-uid').set({
        app_user_id: 'app-forged',
        provider_uid: 'alice-uid',
        provider_id: 'firebase',
      }),
    );
  });
});

// ==============================
// BLOCK-02 · playground_replies · production payload 契约（RED-B）
// 与 RED-A（Dart payload 契约测试）同一字段集，真 emulator 下验证
// production Rules 的 allow/deny 矩阵。跨帖/深度由 Functions + Rules 双层：
// rules 静态层 depth≤1；跨帖（reply_to_reply_id 不同 post）由 Functions
// createDiscussionReply 校验（Dart 直写路径由查询约束 post_id）。
// ==============================

describe('BLOCK-02 · replies · production payload（RED-B）', () => {
  function productionRootReplyPayload(overrides: Record<string, any> = {}) {
    return {
      body: '根回复正文',
      post_id: 'p-payload-1',
      root_reply_id: null,
      reply_to_reply_id: null,
      depth: 0,
      technique_tags: ['六爻'],
      chart_attachment: null,
      media_attachments: [],
      author_provider_uid: 'alice-uid',
      presentation_identity_id: 'anon-1',
      is_tombstoned: false,
      revisions: [],
      created_at: new Date(),
      updated_at: new Date(),
      idempotency_key: 'rk-1',
      ...overrides,
    };
  }

  test('deny: production-shaped root reply payload cannot bypass callable', async () => {
    const db = aliceContext();
    await assertFails(
      db
        .firestore()
        .collection('playground_replies')
        .doc('pr-payload-1')
        .set(productionRootReplyPayload()),
    );
  });

  test('deny: production-shaped discussion reply payload cannot bypass callable', async () => {
    const db = aliceContext();
    await assertFails(
      db
        .firestore()
        .collection('playground_replies')
        .doc('pd-payload-1')
        .set({
          ...productionRootReplyPayload(),
          depth: 1,
          root_reply_id: 'pr-payload-1',
          reply_to_reply_id: 'pr-payload-1',
          technique_tags: [],
          chart_attachment: null,
        }),
    );
  });

  test('deny: create 携带 status 被 allowlist 拒绝', async () => {
    const db = aliceContext();
    await assertFails(
      db
        .firestore()
        .collection('playground_replies')
        .doc('pr-payload-2')
        .set(productionRootReplyPayload({ status: 'active' })),
    );
  });

  test('deny: create 携带 is_root 被拒绝', async () => {
    const db = aliceContext();
    await assertFails(
      db
        .firestore()
        .collection('playground_replies')
        .doc('pr-payload-3')
        .set(productionRootReplyPayload({ is_root: true })),
    );
  });

  test('deny: create 携带 author_app_user_id 被拒绝', async () => {
    const db = aliceContext();
    await assertFails(
      db
        .firestore()
        .collection('playground_replies')
        .doc('pr-payload-4')
        .set(productionRootReplyPayload({ author_app_user_id: 'app-1' })),
    );
  });

  test('deny: create 携带 text 被拒绝（reply 正文字段唯一为 body）', async () => {
    const db = aliceContext();
    await assertFails(
      db
        .firestore()
        .collection('playground_replies')
        .doc('pr-payload-5')
        .set(productionRootReplyPayload({ text: '旧字段' })),
    );
  });

  test('deny: depth=2 第三层被拒绝', async () => {
    const db = aliceContext();
    await assertFails(
      db
        .firestore()
        .collection('playground_replies')
        .doc('pr-payload-6')
        .set(productionRootReplyPayload({ depth: 2 })),
    );
  });

  test('allow: list where(is_tombstoned == false)（生产 getReplies 同款过滤）', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const fs = ctx.firestore();
      await fs
        .collection('playground_replies')
        .doc('pr-list-1')
        .set({
          ...productionRootReplyPayload(),
          post_id: 'p-list',
          created_at: new Date('2026-01-01T00:00:00Z'),
        });
      await fs
        .collection('playground_replies')
        .doc('pr-list-2')
        .set({
          ...productionRootReplyPayload(),
          post_id: 'p-list',
          depth: 1,
          is_tombstoned: false,
          root_reply_id: 'pr-list-1',
          reply_to_reply_id: 'pr-list-1',
          created_at: new Date('2026-01-02T00:00:00Z'),
        });
    });
    const db = aliceContext();
    await assertSucceeds(
      db
        .firestore()
        .collection('playground_replies')
        .where('post_id', '==', 'p-list')
        .where('is_tombstoned', '==', false)
        .orderBy('depth')
        .orderBy('created_at')
        .get(),
    );
  });

  test('allow: get 单条（非 tombstone）', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx
        .firestore()
        .collection('playground_replies')
        .doc('pr-get-1')
        .set(productionRootReplyPayload());
    });
    const db = aliceContext();
    await assertSucceeds(
      db.firestore().collection('playground_replies').doc('pr-get-1').get(),
    );
  });

  test('allow: 作者可读自己的 tombstone', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx
        .firestore()
        .collection('playground_replies')
        .doc('pr-tomb-1')
        .set({ ...productionRootReplyPayload(), is_tombstoned: true });
    });
    const db = aliceContext();
    await assertSucceeds(
      db.firestore().collection('playground_replies').doc('pr-tomb-1').get(),
    );
  });

  test('deny: 非作者读他人 tombstone', async () => {
    // productionRootReplyPayload 默认 author_provider_uid=alice-uid；
    // bob 读 alice 的 tombstone 必须被拒。
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx
        .firestore()
        .collection('playground_replies')
        .doc('pr-tomb-2')
        .set({ ...productionRootReplyPayload(), is_tombstoned: true });
    });
    const bobDb = bobContext();
    await assertFails(
      bobDb
        .firestore()
        .collection('playground_replies')
        .doc('pr-tomb-2')
        .get(),
    );
  });
});

// ==============================
// BLOCK-02 · playground_posts · production payload 契约（RED-B）
// ==============================

describe('BLOCK-02 · posts · production payload（RED-B）', () => {
  function productionPostPayload(overrides: Record<string, any> = {}) {
    return {
      text: '帖子正文',
      author_provider_uid: 'alice-uid',
      status: 'active',
      allowed_chart_technique_ids: ['六爻'],
      attachments: [],
      created_at: new Date(),
      updated_at: new Date(),
      revisions: [],
      has_outcome_feedback: false,
      idempotency_key: 'pk-1',
      ...overrides,
    };
  }

  test('deny: production-shaped post payload cannot bypass callable', async () => {
    const db = aliceContext();
    await assertFails(
      db
        .firestore()
        .collection('playground_posts')
        .doc('p-payload-1')
        .set(productionPostPayload()),
    );
  });

  test('deny: create 携带 author_app_user_id 被拒绝（客户端不写作者 app id）', async () => {
    const db = aliceContext();
    await assertFails(
      db
        .firestore()
        .collection('playground_posts')
        .doc('p-payload-2')
        .set(productionPostPayload({ author_app_user_id: 'app-1' })),
    );
  });
});

// ==============================
// BLOCK-03 · 游客代表性回复 · 反绕过第一道闸（Rules 游客直连 deny）
// 游客完整回复读取只能走受信 Functions `getGuestRepresentativeReplies`；
// 客户端直连 playground_replies 的 list/get 在未认证下必须全部 DENY。
// ==============================

describe('BLOCK-03 · guest · 游客直连 replies 被 Rules 拒绝', () => {
  function guestRootReplyPayload(overrides: Record<string, any> = {}) {
    return {
      body: '根回复正文',
      post_id: 'p-guest-1',
      root_reply_id: null,
      reply_to_reply_id: null,
      depth: 0,
      technique_tags: ['六爻'],
      chart_attachment: null,
      media_attachments: [],
      author_provider_uid: 'alice-uid',
      presentation_identity_id: 'anon-1',
      is_tombstoned: false,
      revisions: [],
      created_at: new Date('2026-01-01T00:00:00Z'),
      updated_at: new Date('2026-01-01T00:00:00Z'),
      idempotency_key: 'grk-1',
      ...overrides,
    };
  }

  test('deny: 未认证用户 list playground_replies（游客不能分页绕过）', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx
        .firestore()
        .collection('playground_replies')
        .doc('guest-list-1')
        .set(guestRootReplyPayload());
    });
    const guestDb = unauthContext();
    await assertFails(
      guestDb
        .firestore()
        .collection('playground_replies')
        .where('post_id', '==', 'p-guest-1')
        .where('is_tombstoned', '==', false)
        .get(),
    );
  });

  test('deny: 未认证用户 get 单条非墓碑 reply（游客不能直连读取）', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx
        .firestore()
        .collection('playground_replies')
        .doc('guest-get-1')
        .set(guestRootReplyPayload());
    });
    const guestDb = unauthContext();
    await assertFails(
      guestDb
        .firestore()
        .collection('playground_replies')
        .doc('guest-get-1')
        .get(),
    );
  });

  test('deny: 未认证用户 get 墓碑 reply（游客不可见）', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx
        .firestore()
        .collection('playground_replies')
        .doc('guest-tomb-1')
        .set(guestRootReplyPayload({ is_tombstoned: true }));
    });
    const guestDb = unauthContext();
    await assertFails(
      guestDb
        .firestore()
        .collection('playground_replies')
        .doc('guest-tomb-1')
        .get(),
    );
  });

  test('allow: 认证用户（注册后）list 同款查询（注册用户正常分页）', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx
        .firestore()
        .collection('playground_replies')
        .doc('guest-reg-1')
        .set(guestRootReplyPayload());
    });
    const db = aliceContext();
    await assertSucceeds(
      db
        .firestore()
        .collection('playground_replies')
        .where('post_id', '==', 'p-guest-1')
        .where('is_tombstoned', '==', false)
        .get(),
    );
  });
});
