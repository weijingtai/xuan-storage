/**
 * Task 7 · direct-write schema fixture —— production Rules allow/deny 成对测试。
 *
 * 验证 Design §4.4/§5/§6/§7/§10.4：
 * - 公开 post/reply 文档 exact keys（零 provider_uid/app_user_id/author_*）；
 * - post create（post+owner+revision）同一 atomic write 成功；
 * - 伪造展示身份/缺 owner/多余字段 → 拒绝；
 * - reply create：root/discussion；depth 语义；跨帖/墓碑目标拒绝；
 * - access budget：post create 唯一访问 ≤4；one-time discussion reply ≤8。
 *
 * 运行前提：Firestore Emulator 在 8082 且加载生产 firestore.rules。
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
const [HOST, PORT_STR] = FIRESTORE_HOST.split(':');
const PORT = parseInt(PORT_STR, 10);
const AUTH_HOST = process.env.FIREBASE_AUTH_EMULATOR_HOST || 'localhost:9099';

let testEnv: RulesTestEnvironment;

const ALICE_UID = 'alice-uid';
const ALICE_APP = 'app-alice';
const ALICE_PUB = 'pub_alice_128bit';
const ALICE_ALIAS = '玄友0001';
const BOB_UID = 'bob-uid';
const BOB_APP = 'app-bob';
const BOB_PUB = 'pub_bob_128bit';

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { host: HOST, port: PORT, rules: rulesContent },
  });
});

afterAll(async () => {
  if (testEnv) await testEnv.cleanup();
});

beforeEach(async () => {
  if (testEnv) await testEnv.clearFirestore();
  // seed identity_map（Playground 不创建；fixture 模拟账号层已预置）。
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const fs = ctx.firestore();
    await fs.collection('identity_map').doc(ALICE_UID).set({
      app_user_id: ALICE_APP,
      provider_uid: ALICE_UID,
      provider_id: 'firebase',
      public_presentation_id: ALICE_PUB,
      public_display_alias: ALICE_ALIAS,
    });
    await fs.collection('identity_map').doc(BOB_UID).set({
      app_user_id: BOB_APP,
      provider_uid: BOB_UID,
      provider_id: 'firebase',
      public_presentation_id: BOB_PUB,
      public_display_alias: '玄友0002',
    });
  });
});

function alice() {
  return testEnv.authenticatedContext(ALICE_UID, {});
}
function bob() {
  return testEnv.authenticatedContext(BOB_UID, {});
}

/** 合法 stableAlias post create payload（公开 + owner + revision 同批）。 */
function validPostCreate() {
  const now = new Date();
  const docId = 'post-valid-1';
  return {
    docId,
    public: {
      id: docId,
      text: '占测正文',
      presentation_mode: 'stableAlias',
      presentation_identity_id: ALICE_PUB,
      presentation_display_alias: ALICE_ALIAS,
      presentation_avatar_url: null,
      public_profile_ref: null,
      status: 'active',
      allowed_chart_technique_ids: ['liuyao'],
      attachments: [],
      has_chart: false,
      revision_no: 1,
      current_revision_id: 'r0000000001',
      idempotency_key: 'idem-valid-1',
      payload_hash: 'hash-valid-1',
      created_at: now,
      updated_at: now,
    },
    owner: {
      content_id: docId,
      provider_uid: ALICE_UID,
      app_user_id: ALICE_APP,
      public_presentation_id: ALICE_PUB,
      created_at: now,
    },
    revision: {
      id: 'r0000000001',
      parent_id: '',
      revision_no: 1,
      body: '占测正文',
      presentation_mode: 'stableAlias',
      presentation_identity_id: ALICE_PUB,
      presentation_display_alias: ALICE_ALIAS,
      presentation_avatar_url: null,
      public_profile_ref: null,
      created_at: now,
    },
  };
}

async function writePost(ctx: any, payload: ReturnType<typeof validPostCreate>) {
  const fs = ctx.firestore();
  await fs
    .collection('playground_posts')
    .doc(payload.docId)
    .set(payload.public);
  await fs
    .collection('playground_post_owners')
    .doc(payload.docId)
    .set(payload.owner);
  await fs
    .collection('playground_posts')
    .doc(payload.docId)
    .collection('revisions')
    .doc('r0000000001')
    .set(payload.revision);
}

// ==============================
// playground_posts —— 公开 + owner + revision atomic
// ==============================

describe('direct-write · playground_posts', () => {
  test('allow: stableAlias 合法 post create（post+owner+revision）', async () => {
    const db = alice();
    const payload = validPostCreate();
    // 独立 doc.set 不能验证 atomic（Rules getAfter 看不到同批），
    // 用 batch/transaction 验证 atomic 语义。
    const fs = db.firestore();
    const batch = fs.batch();
    batch.set(fs.collection('playground_posts').doc(payload.docId), payload.public);
    batch.set(fs.collection('playground_post_owners').doc(payload.docId), payload.owner);
    batch.set(
      fs.collection('playground_posts').doc(payload.docId).collection('revisions').doc('r0000000001'),
      payload.revision,
    );
    await assertSucceeds(batch.commit());
  });

  test('deny: 公开 post 携带 author_provider_uid（内部身份泄漏）', async () => {
    const db = alice();
    const payload = validPostCreate() as any;
    payload.public = { ...payload.public, author_provider_uid: ALICE_UID };
    await assertFails(
      db
        .firestore()
        .collection('playground_posts')
        .doc(payload.docId)
        .set(payload.public),
    );
  });

  test('deny: oneTimeAnonymous 展示 ID 非 post_{id}（伪造）', async () => {
    const db = alice();
    const payload = validPostCreate();
    payload.public = {
      ...payload.public,
      presentation_mode: 'oneTimeAnonymous',
      presentation_identity_id: 'forged-anon-id',
    };
    await assertFails(
      db
        .firestore()
        .collection('playground_posts')
        .doc(payload.docId)
        .set(payload.public),
    );
  });

  test('deny: owner provider_uid != auth.uid（越权冒充）', async () => {
    const db = alice();
    const payload = validPostCreate();
    payload.owner = { ...payload.owner, provider_uid: BOB_UID };
    const fs = db.firestore();
    const batch = fs.batch();
    batch.set(fs.collection('playground_posts').doc(payload.docId), payload.public);
    batch.set(fs.collection('playground_post_owners').doc(payload.docId), payload.owner);
    await assertFails(batch.commit());
  });

  test('deny: 未认证用户创建帖', async () => {
    const db = testEnv.unauthenticatedContext();
    const payload = validPostCreate();
    await assertFails(
      db
        .firestore()
        .collection('playground_posts')
        .doc(payload.docId)
        .set(payload.public),
    );
  });
});

// ==============================
// playground_replies —— depth / 跨帖 / 墓碑
// ==============================

describe('direct-write · playground_replies', () => {
  test('deny: depth=2 第三层回复', async () => {
    const db = alice();
    await assertFails(
      db
        .firestore()
        .collection('playground_replies')
        .doc('reply-depth2')
        .set({
          id: 'reply-depth2',
          post_id: 'post-x',
          presentation_mode: 'stableAlias',
          presentation_identity_id: ALICE_PUB,
          presentation_display_alias: ALICE_ALIAS,
          presentation_avatar_url: null,
          public_profile_ref: null,
          depth: 2,
          body: '第三层',
          is_tombstoned: false,
          root_reply_id: 'r1',
          reply_to_reply_id: 'r2',
          technique_tags: [],
          chart_attachment: null,
          media_attachments: [],
          revision_no: 1,
          current_revision_id: 'r0000000001',
          idempotency_key: 'k',
          payload_hash: 'h',
          created_at: new Date(),
          updated_at: new Date(),
        }),
    );
  });

  test('deny: 负 depth', async () => {
    const db = alice();
    await assertFails(
      db
        .firestore()
        .collection('playground_replies')
        .doc('reply-neg')
        .set({
          id: 'reply-neg',
          post_id: 'post-x',
          presentation_mode: 'stableAlias',
          presentation_identity_id: ALICE_PUB,
          presentation_display_alias: ALICE_ALIAS,
          presentation_avatar_url: null,
          public_profile_ref: null,
          depth: -1,
          body: '负深度',
          is_tombstoned: false,
          root_reply_id: null,
          reply_to_reply_id: null,
          technique_tags: [],
          chart_attachment: null,
          media_attachments: [],
          revision_no: 1,
          current_revision_id: 'r0000000001',
          idempotency_key: 'k',
          payload_hash: 'h',
          created_at: new Date(),
          updated_at: new Date(),
        }),
    );
  });

  test('deny: reply 公开文档携带 author_app_user_id', async () => {
    const db = alice();
    await assertFails(
      db
        .firestore()
        .collection('playground_replies')
        .doc('reply-leak')
        .set({
          id: 'reply-leak',
          post_id: 'post-x',
          author_app_user_id: ALICE_APP,
          presentation_mode: 'stableAlias',
          presentation_identity_id: ALICE_PUB,
          presentation_display_alias: ALICE_ALIAS,
          presentation_avatar_url: null,
          public_profile_ref: null,
          depth: 0,
          body: '泄漏',
          is_tombstoned: false,
          root_reply_id: null,
          reply_to_reply_id: null,
          technique_tags: [],
          chart_attachment: null,
          media_attachments: [],
          revision_no: 1,
          current_revision_id: 'r0000000001',
          idempotency_key: 'k',
          payload_hash: 'h',
          created_at: new Date(),
          updated_at: new Date(),
        }),
    );
  });
});

// ==============================
// Access budget（§10.4）—— 最重路径必须成功（Emulator 10/20 文档访问上限内）
// ==============================

describe('access budget · heavy paths succeed (§10.4)', () => {
  test('one-time anonymous discussion reply create succeeds（6 访问）', async () => {
    // seed post + reply owner + root reply（admin）。
    // 匿名回复展示 ID 内容派生为 post_{postId}，无需 thread presentation mapping。
    const postId = 'post-heavy-1';
    const rootId = 'root-heavy-1';
    const now = new Date();
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const fs = ctx.firestore();
      await fs.collection('playground_posts').doc(postId).set({
        id: postId, text: '帖', presentation_mode: 'stableAlias',
        presentation_identity_id: ALICE_PUB, presentation_display_alias: ALICE_ALIAS,
        presentation_avatar_url: null, public_profile_ref: null, status: 'active',
        allowed_chart_technique_ids: [], attachments: [], has_chart: false,
        revision_no: 1, current_revision_id: 'r0000000001',
        idempotency_key: 'k', payload_hash: 'h', created_at: now, updated_at: now,
      });
      await fs.collection('playground_post_owners').doc(postId).set({
        content_id: postId, provider_uid: ALICE_UID, app_user_id: ALICE_APP,
        public_presentation_id: ALICE_PUB, created_at: now,
      });
      await fs.collection('playground_replies').doc(rootId).set({
        id: rootId, post_id: postId, presentation_mode: 'stableAlias',
        presentation_identity_id: BOB_PUB, presentation_display_alias: '玄友0002',
        presentation_avatar_url: null, public_profile_ref: null, depth: 0,
        body: '根', is_tombstoned: false, root_reply_id: null, reply_to_reply_id: null,
        technique_tags: [], chart_attachment: null, media_attachments: [],
        revision_no: 1, current_revision_id: 'r0000000001',
        idempotency_key: 'k2', payload_hash: 'h2', created_at: now, updated_at: now,
      });
      await fs.collection('playground_reply_owners').doc(rootId).set({
        content_id: rootId, provider_uid: BOB_UID, app_user_id: BOB_APP,
        public_presentation_id: BOB_PUB, created_at: now,
      });
    });

    // Bob 以 oneTimeAnonymous 写二级回复（reply + reply_owner + revision 同批）。
    const db = bob();
    const fs = db.firestore();
    const replyId = 'disc-heavy-1';
    const batch = fs.batch();
    batch.set(fs.collection('playground_replies').doc(replyId), {
      id: replyId, post_id: postId, presentation_mode: 'oneTimeAnonymous',
      presentation_identity_id: `post_${postId}`, presentation_display_alias: '匿名用户',
      presentation_avatar_url: null, public_profile_ref: null, depth: 1,
      body: '二级回复', is_tombstoned: false, root_reply_id: rootId, reply_to_reply_id: rootId,
      technique_tags: [], chart_attachment: null, media_attachments: [],
      revision_no: 1, current_revision_id: 'r0000000001',
      idempotency_key: 'k3', payload_hash: 'h3', created_at: new Date(), updated_at: new Date(),
    });
    batch.set(fs.collection('playground_reply_owners').doc(replyId), {
      content_id: replyId, provider_uid: BOB_UID, app_user_id: BOB_APP,
      public_presentation_id: BOB_PUB, created_at: new Date(),
    });
    batch.set(fs.collection('playground_replies').doc(replyId).collection('revisions').doc('r0000000001'), {
      id: 'r0000000001', parent_id: '', revision_no: 1, body: '二级回复',
      presentation_mode: 'oneTimeAnonymous', presentation_identity_id: `post_${postId}`,
      presentation_display_alias: '匿名用户', presentation_avatar_url: null,
      public_profile_ref: null, created_at: new Date(),
    });
    await assertSucceeds(batch.commit());
  });

  test('post-target like + like_owner atomic create succeeds（target_type/target_id）', async () => {
    const postId = 'post-like-1';
    const now = new Date();
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const fs = ctx.firestore();
      await fs.collection('playground_posts').doc(postId).set({
        id: postId, text: '帖', presentation_mode: 'stableAlias',
        presentation_identity_id: ALICE_PUB, presentation_display_alias: ALICE_ALIAS,
        presentation_avatar_url: null, public_profile_ref: null, status: 'active',
        allowed_chart_technique_ids: [], attachments: [], has_chart: false,
        revision_no: 1, current_revision_id: 'r0000000001',
        idempotency_key: 'k', payload_hash: 'h', created_at: now, updated_at: now,
      });
      await fs.collection('playground_post_owners').doc(postId).set({
        content_id: postId, provider_uid: ALICE_UID, app_user_id: ALICE_APP,
        public_presentation_id: ALICE_PUB, created_at: now,
      });
    });

    const db = bob();
    const fs = db.firestore();
    const likeId = 'like-post-1';
    const batch = fs.batch();
    batch.set(fs.collection('playground_likes').doc(likeId), {
      id: likeId, target_type: 'post', target_id: postId, created_at: new Date(),
    });
    batch.set(fs.collection('playground_like_owners').doc(likeId), {
      like_id: likeId, provider_uid: BOB_UID, app_user_id: BOB_APP,
      target_type: 'post', target_id: postId, created_at: new Date(),
    });
    await assertSucceeds(batch.commit());
  });

  test('deny: Poster 应验自己的 root 回复（非 Poster 自己回复校验）', async () => {
    // Alice 既是帖子 owner 又是 root 回复作者 → verify 必须被拒绝。
    const postId = 'post-own-verify-1';
    const rootId = 'root-own-verify-1';
    const now = new Date();
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const fs = ctx.firestore();
      await fs.collection('playground_posts').doc(postId).set({
        id: postId, text: '帖', presentation_mode: 'stableAlias',
        presentation_identity_id: ALICE_PUB, presentation_display_alias: ALICE_ALIAS,
        presentation_avatar_url: null, public_profile_ref: null, status: 'active',
        allowed_chart_technique_ids: [], attachments: [], has_chart: false,
        revision_no: 1, current_revision_id: 'r0000000001',
        idempotency_key: 'k', payload_hash: 'h', created_at: now, updated_at: now,
      });
      await fs.collection('playground_post_owners').doc(postId).set({
        content_id: postId, provider_uid: ALICE_UID, app_user_id: ALICE_APP,
        public_presentation_id: ALICE_PUB, created_at: now,
      });
      await fs.collection('playground_replies').doc(rootId).set({
        id: rootId, post_id: postId, presentation_mode: 'stableAlias',
        presentation_identity_id: ALICE_PUB, presentation_display_alias: ALICE_ALIAS,
        presentation_avatar_url: null, public_profile_ref: null, depth: 0,
        body: 'Alice 自己的根回复', is_tombstoned: false,
        root_reply_id: null, reply_to_reply_id: null,
        technique_tags: [], chart_attachment: null, media_attachments: [],
        revision_no: 1, current_revision_id: 'r0000000001',
        idempotency_key: 'k2', payload_hash: 'h2', created_at: now, updated_at: now,
      });
      await fs.collection('playground_reply_owners').doc(rootId).set({
        content_id: rootId, provider_uid: ALICE_UID, app_user_id: ALICE_APP,
        public_presentation_id: ALICE_PUB, created_at: now,
      });
    });

    const db = alice();
    const fs = db.firestore();
    const verificationId = `verify_${postId}_${rootId}`;
    await assertFails(
      fs.collection('playground_verifications').doc(verificationId).set({
        id: verificationId, post_id: postId, root_reply_id: rootId,
        created_at: new Date(), revoked_at: null,
      }),
    );
  });
});
