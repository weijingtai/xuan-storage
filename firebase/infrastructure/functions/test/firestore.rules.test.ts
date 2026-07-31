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
  test('allow: 认证用户创建自己的 active 帖子', async () => {
    const db = aliceContext();
    const fs = db.firestore();
    await assertSucceeds(
      db.firestore().collection('playground_posts').doc('post-1').set({
        text: '测试帖',
        author_provider_uid: 'alice-uid',
        status: 'active',
        allowed_chart_technique_ids: [],
        attachments: [],
        idempotency_key: 'k1',
      }),
    );
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

  test('deny: 非作者修改他人帖子', async () => {
    const aliceDb = aliceContext();
    await aliceDb.firestore().collection('playground_posts').doc('post-7').set({
      text: 'Alice 的帖',
      author_provider_uid: 'alice-uid',
      status: 'active',
    });

    const bobDb = bobContext();
    await assertFails(
      bobDb.firestore().collection('playground_posts').doc('post-7').update({ text: 'Bob 改的' }),
    );
  });

  test('allow: 作者修改自己的帖子', async () => {
    const db = aliceContext();
    const fs = db.firestore();
    await db.firestore().collection('playground_posts').doc('post-8').set({
      text: '原始',
      author_provider_uid: 'alice-uid',
      status: 'active',
    });
    await assertSucceeds(
      db.firestore().collection('playground_posts').doc('post-8').update({ text: '修改后' }),
    );
  });

  test('deny: 认证用户删除帖子', async () => {
    const db = aliceContext();
    const fs = db.firestore();
    await db.firestore().collection('playground_posts').doc('post-9').set({
      text: '待删',
      author_provider_uid: 'alice-uid',
      status: 'active',
    });
    await assertFails(
      db.firestore().collection('playground_posts').doc('post-9').delete(),
    );
  });
});

// ==============================
// playground_replies
// ==============================

describe('playground_replies', () => {
  async function seedPost(db: any, docId: string, authorUid: string) {
    await db.firestore().collection('playground_posts').doc(docId).set({
      text: '测试帖',
      author_provider_uid: authorUid,
      status: 'active',
    });
  }

  test('allow: 认证用户创建 depth=0 根回复', async () => {
    const db = aliceContext();
    const fs = db.firestore();
    await seedPost(db, 'p-reply-1', 'alice-uid');
    await assertSucceeds(
      db.firestore().collection('playground_replies').doc('r-1').set({
        body: '根回复',
        post_id: 'p-reply-1',
        depth: 0,
        author_provider_uid: 'alice-uid',
        is_tombstoned: false,
      }),
    );
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

  test('deny: 非作者更新他人回复', async () => {
    const aliceDb = aliceContext();
    await aliceDb.firestore().collection('playground_replies').doc('r-5').set({
      body: 'Alice 的回复',
      post_id: 'p-reply-2',
      depth: 0,
      author_provider_uid: 'alice-uid',
      is_tombstoned: false,
    });

    const bobDb = bobContext();
    await assertFails(
      bobDb.firestore().collection('playground_replies').doc('r-5').update({ body: 'Bob 改的' }),
    );
  });

  test('deny: 删除回复', async () => {
    const db = aliceContext();
    const fs = db.firestore();
    await db.firestore().collection('playground_replies').doc('r-6').set({
      body: '待删',
      post_id: 'p-any',
      depth: 0,
      author_provider_uid: 'alice-uid',
      is_tombstoned: false,
    });
    await assertFails(
      db.firestore().collection('playground_replies').doc('r-6').delete(),
    );
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
  test('allow: 用户创建自己的收藏', async () => {
    const db = aliceContext();
    const fs = db.firestore();
    await assertSucceeds(
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
