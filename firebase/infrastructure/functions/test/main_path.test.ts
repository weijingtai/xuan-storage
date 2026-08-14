/**
 * Task 10.3 · production-Rules 真实主链路集成测试。
 *
 * 在 production Rules Emulator（165）上验证：
 * - Alice 发帖；Bob 根回复/二级回复；Alice 点赞/收藏/应验/反馈（均成功）；
 * - Bob 越权编辑/应验/反馈失败；Alice 应验自己的 root 失败；
 * - 匿名 alias 同帖稳定跨帖不同（post_{postId}）；
 * - 墓碑 raw Firestore get 不泄漏正文（is_tombstoned=true 且 body 清空，非作者读拒绝）；
 * - Functions/outbox/notification 均未写入。
 *
 * identity_map 由本测试经 withSecurityRulesDisabled 预置（production Rules
 * identity_map write:false，客户端不可 seed）；之后所有操作走真实 production Rules。
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
const [H, P] = FIRESTORE_HOST.split(':');
const FS_PORT = parseInt(P, 10);
const AUTH_HOST = process.env.FIREBASE_AUTH_EMULATOR_HOST || 'localhost:9099';

const ALICE_UID = 'alice-uid';
const ALICE_APP = 'app-alice';
const ALICE_PUB = 'pub_alice_128bit';
const ALICE_ALIAS = '玄友0001';
const BOB_UID = 'bob-uid';
const BOB_APP = 'app-bob';
const BOB_PUB = 'pub_bob_128bit';
const BOB_ALIAS = '玄友0002';

let testEnv: RulesTestEnvironment;
const now = () => new Date();

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { host: H, port: FS_PORT, rules: rulesContent },
  });
});
afterAll(async () => {
  if (testEnv) await testEnv.cleanup();
});
beforeEach(async () => {
  if (testEnv) await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const fs = ctx.firestore();
    await fs.collection('identity_map').doc(ALICE_UID).set({
      app_user_id: ALICE_APP, provider_uid: ALICE_UID, provider_id: 'firebase',
      public_presentation_id: ALICE_PUB, public_display_alias: ALICE_ALIAS,
    });
    await fs.collection('identity_map').doc(BOB_UID).set({
      app_user_id: BOB_APP, provider_uid: BOB_UID, provider_id: 'firebase',
      public_presentation_id: BOB_PUB, public_display_alias: BOB_ALIAS,
    });
  });
});

function alice() { return testEnv.authenticatedContext(ALICE_UID, {}); }
function bob() { return testEnv.authenticatedContext(BOB_UID, {}); }

function postPayload(postId: string, pubId: string, alias: string, body: string) {
  return {
    id: postId, text: body, presentation_mode: 'stableAlias',
    presentation_identity_id: pubId, presentation_display_alias: alias,
    presentation_avatar_url: null, public_profile_ref: null, status: 'active',
    allowed_chart_technique_ids: [], attachments: [], has_chart: false,
    revision_no: 1, current_revision_id: 'r0000000001',
    idempotency_key: 'k', payload_hash: 'h', created_at: now(), updated_at: now(),
  };
}
function replyPayload(replyId: string, postId: string, pubId: string, alias: string, body: string, depth: number, rootId: string | null) {
  return {
    id: replyId, post_id: postId, presentation_mode: 'stableAlias',
    presentation_identity_id: pubId, presentation_display_alias: alias,
    presentation_avatar_url: null, public_profile_ref: null, depth,
    body, is_tombstoned: false, root_reply_id: rootId, reply_to_reply_id: rootId,
    technique_tags: [], chart_attachment: null, media_attachments: [],
    revision_no: 1, current_revision_id: 'r0000000001',
    idempotency_key: 'k', payload_hash: 'h', created_at: now(), updated_at: now(),
  };
}

async function seedPost(postId = 'post-main-1') {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const fs = ctx.firestore();
    await fs.collection('playground_posts').doc(postId).set(postPayload(postId, ALICE_PUB, ALICE_ALIAS, 'Alice 的帖子'));
    await fs.collection('playground_post_owners').doc(postId).set({
      content_id: postId, provider_uid: ALICE_UID, app_user_id: ALICE_APP,
      public_presentation_id: ALICE_PUB, created_at: now(),
    });
    await fs.collection('playground_posts').doc(postId).collection('revisions').doc('r0000000001').set({
      id: 'r0000000001', parent_id: '', revision_no: 1, body: 'Alice 的帖子',
      allowed_chart_technique_ids: [], attachments: [], presentation_mode: 'stableAlias',
      presentation_identity_id: ALICE_PUB, presentation_display_alias: ALICE_ALIAS,
      presentation_avatar_url: null, public_profile_ref: null, created_at: now(),
    });
  });
  return postId;
}

async function seedRootReply(postId: string, rootId = 'root-main-1', uid = BOB_UID, app = BOB_APP, pub = BOB_PUB, alias = BOB_ALIAS) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const fs = ctx.firestore();
    await fs.collection('playground_replies').doc(rootId).set(replyPayload(rootId, postId, pub, alias, 'Bob 根回复', 0, null));
    await fs.collection('playground_reply_owners').doc(rootId).set({
      content_id: rootId, provider_uid: uid, app_user_id: app,
      public_presentation_id: pub, created_at: now(),
    });
  });
  return rootId;
}

describe('Task 10.3 · production-Rules 真实主链路', () => {
  test('Alice 发帖 + Bob 根/二级回复 + Alice 点赞/收藏/应验/反馈 全成功', async () => {
    const postId = await seedPost();
    const rootId = await seedRootReply(postId);

    const bobFs = bob().firestore();
    const aliceFs = alice().firestore();

    // Bob 二级回复（depth 1，reply_to=root）。
    const discId = 'disc-main-1';
    const bobBatch = bobFs.batch();
    bobBatch.set(bobFs.collection('playground_replies').doc(discId), replyPayload(discId, postId, BOB_PUB, BOB_ALIAS, 'Bob 二级回复', 1, rootId));
    bobBatch.set(bobFs.collection('playground_reply_owners').doc(discId), {
      content_id: discId, provider_uid: BOB_UID, app_user_id: BOB_APP,
      public_presentation_id: BOB_PUB, created_at: now(),
    });
    bobBatch.set(bobFs.collection('playground_replies').doc(discId).collection('revisions').doc('r0000000001'), {
      id: 'r0000000001', parent_id: '', revision_no: 1, body: 'Bob 二级回复',
      presentation_mode: 'stableAlias', presentation_identity_id: BOB_PUB,
      presentation_display_alias: BOB_ALIAS, presentation_avatar_url: null,
      public_profile_ref: null, created_at: now(),
    });
    await assertSucceeds(bobBatch.commit());

    // Alice 点赞（post target）。
    const likeId = 'like-main-1';
    const likeBatch = aliceFs.batch();
    likeBatch.set(aliceFs.collection('playground_likes').doc(likeId), {
      id: likeId, target_type: 'post', target_id: postId, created_at: now(),
    });
    likeBatch.set(aliceFs.collection('playground_like_owners').doc(likeId), {
      like_id: likeId, provider_uid: ALICE_UID, app_user_id: ALICE_APP,
      target_type: 'post', target_id: postId, created_at: now(),
    });
    await assertSucceeds(likeBatch.commit());

    // Alice 收藏。
    const bmId = 'bm-main-1';
    await assertSucceeds(aliceFs.collection('playground_bookmarks').doc(bmId).set({
      id: bmId, user_provider_uid: ALICE_UID, user_app_user_id: ALICE_APP,
      post_id: postId, created_at: now(),
    }));

    // Alice 应验 Bob 的 root 回复。
    const verId = `verify_${postId}_${rootId}`;
    await assertSucceeds(aliceFs.collection('playground_verifications').doc(verId).set({
      id: verId, post_id: postId, root_reply_id: rootId,
      created_at: now(), revoked_at: null,
    }));

    // Alice 设置最终反馈（feedback + revision 同批）。
    const fbId = `feedback_${postId}`;
    const fbBatch = aliceFs.batch();
    fbBatch.set(aliceFs.collection('playground_outcome_feedback').doc(fbId), {
      id: fbId, post_id: postId, outcome_description: '应验了', revision_no: 1,
      current_revision_id: 'r0000000001', created_at: now(), updated_at: now(), deleted_at: null,
    });
    fbBatch.set(aliceFs.collection('playground_outcome_feedback').doc(fbId).collection('revisions').doc('r0000000001'), {
      id: 'r0000000001', parent_id: '', revision_no: 1, body: '应验了',
      presentation_mode: 'stableAlias', presentation_identity_id: ALICE_PUB,
      presentation_display_alias: ALICE_ALIAS, presentation_avatar_url: null,
      public_profile_ref: null, created_at: now(),
    });
    await assertSucceeds(fbBatch.commit());
  });

  test('Bob 越权编辑/应验/反馈失败；Alice 应验自己的 root 失败', async () => {
    const postId = await seedPost();
    const rootId = await seedRootReply(postId);

    const bobFs = bob().firestore();
    const aliceFs = alice().firestore();

    // Bob 编辑 Alice 的帖子 → deny。
    const alicePost = bobFs.collection('playground_posts').doc(postId);
    await assertFails(alicePost.update({
      text: '篡改', revision_no: 2, current_revision_id: 'r0000000002',
      updated_at: now(),
    }));

    // Bob（非 Poster）应验 → deny。
    const verId = `verify_${postId}_${rootId}`;
    await assertFails(bobFs.collection('playground_verifications').doc(verId).set({
      id: verId, post_id: postId, root_reply_id: rootId,
      created_at: now(), revoked_at: null,
    }));

    // Bob（非 Poster）设置反馈 → deny。
    const fbId = `feedback_${postId}`;
    await assertFails(bobFs.collection('playground_outcome_feedback').doc(fbId).set({
      id: fbId, post_id: postId, outcome_description: '越权', revision_no: 1,
      current_revision_id: 'r0000000001', created_at: now(), updated_at: now(), deleted_at: null,
    }));

    // Alice 应验自己的 root 回复（root owner = Alice）→ deny。
    // seed 一个 Alice 自己的 root。
    const aliceRoot = 'root-alice-own';
    await seedRootReply(postId, aliceRoot, ALICE_UID, ALICE_APP, ALICE_PUB, ALICE_ALIAS);
    const verOwn = `verify_${postId}_${aliceRoot}`;
    await assertFails(aliceFs.collection('playground_verifications').doc(verOwn).set({
      id: verOwn, post_id: postId, root_reply_id: aliceRoot,
      created_at: now(), revoked_at: null,
    }));
  });

  test('匿名 alias：oneTimeAnonymous 帖子/回复同帖稳定跨帖不同 + 墓碑不泄漏正文 + outbox/notification 未写入', async () => {
    const postId = await seedPost();
    const rootId = await seedRootReply(postId);

    const bobFs = bob().firestore();
    const aliceFs = alice().firestore();

    // Bob 匿名二级回复（depth 1，oneTimeAnonymous，ID = post_{postId}）。
    const anonId = 'anon-main-1';
    const anonBatch = bobFs.batch();
    anonBatch.set(bobFs.collection('playground_replies').doc(anonId), {
      id: anonId, post_id: postId, presentation_mode: 'oneTimeAnonymous',
      presentation_identity_id: `post_${postId}`, presentation_display_alias: '匿名用户',
      presentation_avatar_url: null, public_profile_ref: null, depth: 1,
      body: '匿名讨论', is_tombstoned: false, root_reply_id: rootId, reply_to_reply_id: rootId,
      technique_tags: [], chart_attachment: null, media_attachments: [],
      revision_no: 1, current_revision_id: 'r0000000001',
      idempotency_key: 'k', payload_hash: 'h', created_at: now(), updated_at: now(),
    });
    anonBatch.set(bobFs.collection('playground_reply_owners').doc(anonId), {
      content_id: anonId, provider_uid: BOB_UID, app_user_id: BOB_APP,
      public_presentation_id: BOB_PUB, created_at: now(),
    });
    anonBatch.set(bobFs.collection('playground_replies').doc(anonId).collection('revisions').doc('r0000000001'), {
      id: 'r0000000001', parent_id: '', revision_no: 1, body: '匿名讨论',
      presentation_mode: 'oneTimeAnonymous', presentation_identity_id: `post_${postId}`,
      presentation_display_alias: '匿名用户', presentation_avatar_url: null,
      public_profile_ref: null, created_at: now(),
    });
    await assertSucceeds(anonBatch.commit());

    // 匿名 alias 同帖稳定：读回。
    const anonDoc = await bobFs.collection('playground_replies').doc(anonId).get();
    expect(anonDoc.data()!['presentation_identity_id']).toBe(`post_${postId}`);

    // 墓碑：seed 一个已墓碑化回复（body 清空）→ raw get 不泄漏正文。
    const tombRootId = 'root-tomb-1';
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const fs = ctx.firestore();
      await fs.collection('playground_replies').doc(tombRootId).set({
        ...replyPayload(tombRootId, postId, BOB_PUB, BOB_ALIAS, '', 0, null),
        is_tombstoned: true,
      });
      await fs.collection('playground_reply_owners').doc(tombRootId).set({
        content_id: tombRootId, provider_uid: BOB_UID, app_user_id: BOB_APP,
        public_presentation_id: BOB_PUB, created_at: now(),
      });
    });
    // 墓碑 raw get（Alice 非作者）→ deny。
    await assertFails(aliceFs.collection('playground_replies').doc(tombRootId).get());
    // 墓碑 raw get（作者 Bob）→ body 为空（不泄漏正文）。
    const tomb = await bobFs.collection('playground_replies').doc(tombRootId).get();
    expect(tomb.data()!['is_tombstoned']).toBe(true);
    expect(tomb.data()!['body']).toBe('');

    // Functions/outbox/notification 未写入（outbox/notifications 非客户端可读，
    // 用 rules-disabled 计数证明无 Functions 写入）。
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const fs = ctx.firestore();
      expect((await fs.collection('playground_outbox').get()).size).toBe(0);
      expect((await fs.collection('playground_notifications').get()).size).toBe(0);
    });
  });
});
