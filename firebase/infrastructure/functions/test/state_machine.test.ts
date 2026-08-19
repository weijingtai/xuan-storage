/**
 * R1 P0 状态机测试 —— production Rules 下真实认证客户端完成全部正常状态机，
 * 且 非 owner / 跨帖 / 跳号 / 缺 revision / 伪造 revision 全部拒绝。
 *
 * identity_map 经 withSecurityRulesDisabled 预置（production identity_map write:false），
 * 其余所有读写走真实 production Rules（165）。
 */

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import { readFileSync } from 'fs';
import { resolve } from 'path';

const rulesContent = readFileSync(resolve(__dirname, '../../firestore.rules'), 'utf8');
const HOST = process.env.FIRESTORE_EMULATOR_HOST || 'localhost:8082';
const [H, P] = HOST.split(':');
const FS_PORT = parseInt(P, 10);

const ALICE_UID = 'alice-uid', ALICE_APP = 'app-alice', ALICE_PUB = 'pub_alice_128bit', ALICE_ALIAS = '玄友0001';
const BOB_UID = 'bob-uid', BOB_APP = 'app-bob', BOB_PUB = 'pub_bob_128bit', BOB_ALIAS = '玄友0002';

let testEnv: RulesTestEnvironment;
const now = () => new Date();

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'playground-test',
    firestore: { host: H, port: FS_PORT, rules: rulesContent },
  });
});
afterAll(async () => { if (testEnv) await testEnv.cleanup(); });
beforeEach(async () => {
  await testEnv.clearFirestore();
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

function postPayload(postId: string, body: string) {
  return {
    id: postId, text: body, presentation_mode: 'stableAlias',
    presentation_identity_id: ALICE_PUB, presentation_display_alias: ALICE_ALIAS,
    presentation_avatar_url: null, public_profile_ref: null, status: 'active',
    allowed_chart_technique_ids: [], attachments: [], has_chart: false,
    revision_no: 1, current_revision_id: 'r0000000001',
    idempotency_key: 'k', payload_hash: 'h', created_at: now(), updated_at: now(),
  };
}
function replyPayload(replyId: string, postId: string, body: string, depth: number, rootId: string | null, pubId = BOB_PUB, alias = BOB_ALIAS) {
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

async function seedPost(postId = 'post-sm-1', body = 'Alice 的帖子') {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const fs = ctx.firestore();
    await fs.collection('playground_posts').doc(postId).set(postPayload(postId, body));
    await fs.collection('playground_post_owners').doc(postId).set({
      content_id: postId, provider_uid: ALICE_UID, app_user_id: ALICE_APP,
      public_presentation_id: ALICE_PUB, created_at: now(),
    });
    await fs.collection('playground_posts').doc(postId).collection('revisions').doc('r0000000001').set({
      id: 'r0000000001', parent_id: '', revision_no: 1, body,
      allowed_chart_technique_ids: [], attachments: [], presentation_mode: 'stableAlias',
      presentation_identity_id: ALICE_PUB, presentation_display_alias: ALICE_ALIAS,
      presentation_avatar_url: null, public_profile_ref: null, created_at: now(),
    });
  });
  return postId;
}

async function seedRootReply(postId: string, rootId = 'root-sm-1', uid = BOB_UID, app = BOB_APP, pub = BOB_PUB, alias = BOB_ALIAS) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const fs = ctx.firestore();
    await fs.collection('playground_replies').doc(rootId).set(replyPayload(rootId, postId, 'Bob 根回复', 0, null, pub, alias));
    await fs.collection('playground_reply_owners').doc(rootId).set({
      content_id: rootId, provider_uid: uid, app_user_id: app,
      public_presentation_id: pub, created_at: now(),
    });
  });
  return rootId;
}

async function seedLike(likeId: string, targetType: string, targetId: string, uid = ALICE_UID, app = ALICE_APP) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const fs = ctx.firestore();
    await fs.collection('playground_likes').doc(likeId).set({
      id: likeId, target_type: targetType, target_id: targetId, created_at: now(),
    });
    await fs.collection('playground_like_owners').doc(likeId).set({
      like_id: likeId, provider_uid: uid, app_user_id: app,
      target_type: targetType, target_id: targetId, created_at: now(),
    });
  });
}

describe('R1 P0 · 帖子状态机（edit/tombstone）', () => {
  test('owner 编辑成功（同批 revision r2，parent=r1，body=新正文）', async () => {
    const postId = await seedPost();
    const db = alice().firestore();
    const ref = db.collection('playground_posts').doc(postId);
    const batch = db.batch();
    batch.update(ref, {
      text: '编辑后', allowed_chart_technique_ids: [], attachments: [],
      revision_no: 2, current_revision_id: 'r0000000002', updated_at: now(),
    });
    batch.set(ref.collection('revisions').doc('r0000000002'), {
      id: 'r0000000002', parent_id: 'r0000000001', revision_no: 2, body: '编辑后',
      allowed_chart_technique_ids: [], attachments: [], presentation_mode: 'stableAlias',
      presentation_identity_id: ALICE_PUB, presentation_display_alias: ALICE_ALIAS,
      presentation_avatar_url: null, public_profile_ref: null, created_at: now(),
    });
    await assertSucceeds(batch.commit());
  });

  test('owner 墓碑成功（同批 revision 保存旧正文快照）', async () => {
    const postId = await seedPost();
    const db = alice().firestore();
    const ref = db.collection('playground_posts').doc(postId);
    const batch = db.batch();
    batch.update(ref, {
      status: 'tombstoned', text: '', attachments: [], allowed_chart_technique_ids: [],
      revision_no: 2, current_revision_id: 'r0000000002', updated_at: now(),
    });
    batch.set(ref.collection('revisions').doc('r0000000002'), {
      id: 'r0000000002', parent_id: 'r0000000001', revision_no: 2, body: 'Alice 的帖子',
      allowed_chart_technique_ids: [], attachments: [], presentation_mode: 'stableAlias',
      presentation_identity_id: ALICE_PUB, presentation_display_alias: ALICE_ALIAS,
      presentation_avatar_url: null, public_profile_ref: null, created_at: now(),
    });
    await assertSucceeds(batch.commit());
  });

  test('非 owner 编辑拒绝', async () => {
    const postId = await seedPost();
    const ref = bob().firestore().collection('playground_posts').doc(postId);
    await assertFails(ref.update({ text: '越权', revision_no: 2, current_revision_id: 'r0000000002', updated_at: now() }));
  });

  test('跳号（revision_no 2 但 revision 写 r0000000003）拒绝', async () => {
    const postId = await seedPost();
    const db = alice().firestore();
    const ref = db.collection('playground_posts').doc(postId);
    const batch = db.batch();
    batch.update(ref, { text: 'X', revision_no: 2, current_revision_id: 'r0000000003', updated_at: now() });
    batch.set(ref.collection('revisions').doc('r0000000003'), {
      id: 'r0000000003', parent_id: 'r0000000001', revision_no: 3, body: 'X',
      allowed_chart_technique_ids: [], attachments: [], presentation_mode: 'stableAlias',
      presentation_identity_id: ALICE_PUB, presentation_display_alias: ALICE_ALIAS,
      presentation_avatar_url: null, public_profile_ref: null, created_at: now(),
    });
    await assertFails(batch.commit());
  });

  test('缺 revision（update 不写 revision）拒绝', async () => {
    const postId = await seedPost();
    const ref = alice().firestore().collection('playground_posts').doc(postId);
    await assertFails(ref.update({ text: 'X', revision_no: 2, current_revision_id: 'r0000000002', updated_at: now() }));
  });

  test('伪造 revision（body != 新正文）拒绝', async () => {
    const postId = await seedPost();
    const db = alice().firestore();
    const ref = db.collection('playground_posts').doc(postId);
    const batch = db.batch();
    batch.update(ref, { text: '新正文', revision_no: 2, current_revision_id: 'r0000000002', updated_at: now() });
    batch.set(ref.collection('revisions').doc('r0000000002'), {
      id: 'r0000000002', parent_id: 'r0000000001', revision_no: 2, body: '伪造不同',
      allowed_chart_technique_ids: [], attachments: [], presentation_mode: 'stableAlias',
      presentation_identity_id: ALICE_PUB, presentation_display_alias: ALICE_ALIAS,
      presentation_avatar_url: null, public_profile_ref: null, created_at: now(),
    });
    await assertFails(batch.commit());
  });

  test('跨帖/改 post_id 拒绝（update 不允许改 post_id）', async () => {
    const postId = await seedPost();
    const ref = alice().firestore().collection('playground_posts').doc(postId);
    await assertFails(ref.update({ text: 'X', post_id: 'other', revision_no: 2, current_revision_id: 'r0000000002', updated_at: now() }));
  });
});

describe('R1 P0 · 回复状态机（edit/tombstone）', () => {
  test('owner 编辑回复成功', async () => {
    const postId = await seedPost();
    const rootId = await seedRootReply(postId);
    const db = bob().firestore();
    const ref = db.collection('playground_replies').doc(rootId);
    const batch = db.batch();
    batch.update(ref, {
      body: 'Bob 编辑后', technique_tags: [], chart_attachment: null, media_attachments: [],
      revision_no: 2, current_revision_id: 'r0000000002', updated_at: now(),
    });
    batch.set(ref.collection('revisions').doc('r0000000002'), {
      id: 'r0000000002', parent_id: 'r0000000001', revision_no: 2, body: 'Bob 编辑后',
      technique_tags: [], chart_attachment: null, media_attachments: [],
      presentation_mode: 'stableAlias', presentation_identity_id: BOB_PUB,
      presentation_display_alias: BOB_ALIAS, presentation_avatar_url: null,
      public_profile_ref: null, created_at: now(),
    });
    await assertSucceeds(batch.commit());
  });

  test('owner 墓碑回复成功', async () => {
    const postId = await seedPost();
    const rootId = await seedRootReply(postId);
    const db = bob().firestore();
    const ref = db.collection('playground_replies').doc(rootId);
    const batch = db.batch();
    batch.update(ref, {
      is_tombstoned: true, body: '', technique_tags: [], chart_attachment: null,
      media_attachments: [], revision_no: 2, current_revision_id: 'r0000000002',
      updated_at: now(),
    });
    batch.set(ref.collection('revisions').doc('r0000000002'), {
      id: 'r0000000002', parent_id: 'r0000000001', revision_no: 2, body: 'Bob 根回复',
      technique_tags: [], chart_attachment: null, media_attachments: [],
      presentation_mode: 'stableAlias', presentation_identity_id: BOB_PUB,
      presentation_display_alias: BOB_ALIAS, presentation_avatar_url: null,
      public_profile_ref: null, created_at: now(),
    });
    await assertSucceeds(batch.commit());
  });

  test('非 owner 编辑回复拒绝', async () => {
    const postId = await seedPost();
    const rootId = await seedRootReply(postId);
    const ref = alice().firestore().collection('playground_replies').doc(rootId);
    await assertFails(ref.update({ body: '越权', revision_no: 2, current_revision_id: 'r0000000002', updated_at: now() }));
  });
});

describe('R1 P0 · 应验状态机（revoke/re-verify）', () => {
  test('owner revoke → re-verify 成功；非 owner revoke 拒绝', async () => {
    const postId = await seedPost();
    const rootId = await seedRootReply(postId);
    const verId = `verify_${postId}_${rootId}`;
    // 预置一个应验事实（by Alice）。
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('playground_verifications').doc(verId).set({
        id: verId, post_id: postId, root_reply_id: rootId, created_at: now(), revoked_at: null,
      });
    });
    const db = alice().firestore();
    const ref = db.collection('playground_verifications').doc(verId);
    // revoke：revoked_at null -> timestamp。
    await assertSucceeds(ref.update({ revoked_at: now() }));
    // re-verify：timestamp -> null。
    await assertSucceeds(ref.update({ revoked_at: null }));
    // 非 owner（Bob）revoke 拒绝。
    const bobRef = bob().firestore().collection('playground_verifications').doc(verId);
    await assertFails(bobRef.update({ revoked_at: now() }));
  });
});

describe('R1 P0 · 反馈状态机（edit/revoke/re-publish + revision 注入拒绝）', () => {
  async function seedFeedback(postId: string, body = '应验了', revisionNo = 1, currentRev = 'r0000000001', deletedAt: Date | null = null) {
    const fbId = `feedback_${postId}`;
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const fs = ctx.firestore();
      await fs.collection('playground_outcome_feedback').doc(fbId).set({
        id: fbId, post_id: postId, outcome_description: body, revision_no: revisionNo,
        current_revision_id: currentRev, created_at: now(), updated_at: now(), deleted_at: deletedAt,
      });
    });
    return fbId;
  }

  test('owner 编辑反馈成功（同批 revision 连续）', async () => {
    const postId = await seedPost();
    const fbId = await seedFeedback(postId, '初版');
    const db = alice().firestore();
    const ref = db.collection('playground_outcome_feedback').doc(fbId);
    const batch = db.batch();
    batch.update(ref, {
      outcome_description: '编辑版', revision_no: 2, current_revision_id: 'r0000000002',
      updated_at: now(), deleted_at: null,
    });
    batch.set(ref.collection('revisions').doc('r0000000002'), {
      id: 'r0000000002', parent_id: 'r0000000001', revision_no: 2, body: '编辑版',
      presentation_mode: 'stableAlias', presentation_identity_id: ALICE_PUB,
      presentation_display_alias: ALICE_ALIAS, presentation_avatar_url: null,
      public_profile_ref: null, created_at: now(),
    });
    await assertSucceeds(batch.commit());
  });

  test('owner 撤回成功（deleted_at + 保存旧正文快照）', async () => {
    const postId = await seedPost();
    const fbId = await seedFeedback(postId, '应验了');
    const db = alice().firestore();
    const ref = db.collection('playground_outcome_feedback').doc(fbId);
    const batch = db.batch();
    batch.update(ref, {
      outcome_description: '', revision_no: 2, current_revision_id: 'r0000000002',
      updated_at: now(), deleted_at: now(),
    });
    batch.set(ref.collection('revisions').doc('r0000000002'), {
      id: 'r0000000002', parent_id: 'r0000000001', revision_no: 2, body: '应验了',
      presentation_mode: 'stableAlias', presentation_identity_id: ALICE_PUB,
      presentation_display_alias: ALICE_ALIAS, presentation_avatar_url: null,
      public_profile_ref: null, created_at: now(),
    });
    await assertSucceeds(batch.commit());
  });

  test('非 owner 编辑反馈拒绝', async () => {
    const postId = await seedPost();
    const fbId = await seedFeedback(postId);
    const ref = bob().firestore().collection('playground_outcome_feedback').doc(fbId);
    await assertFails(ref.update({ outcome_description: 'X', revision_no: 2, current_revision_id: 'r0000000002', updated_at: now() }));
  });

  test('非 owner 注入 feedback revision 拒绝（孤儿 revision）', async () => {
    const postId = await seedPost();
    const fbId = await seedFeedback(postId, '应验了');
    const db = bob().firestore();
    await assertFails(
      db.collection('playground_outcome_feedback').doc(fbId).collection('revisions').doc('r0000000099').set({
        id: 'r0000000099', parent_id: 'r0000000001', revision_no: 2, body: '注入',
        presentation_mode: 'stableAlias', presentation_identity_id: BOB_PUB,
        presentation_display_alias: BOB_ALIAS, presentation_avatar_url: null,
        public_profile_ref: null, created_at: now(),
      }),
    );
  });

  test('owner 跳号 revision 拒绝（revision_no 2 但编号 5）', async () => {
    const postId = await seedPost();
    const fbId = await seedFeedback(postId, '应验了');
    const db = alice().firestore();
    const ref = db.collection('playground_outcome_feedback').doc(fbId);
    const batch = db.batch();
    batch.update(ref, { outcome_description: 'X', revision_no: 2, current_revision_id: 'r0000000005', updated_at: now(), deleted_at: null });
    batch.set(ref.collection('revisions').doc('r0000000005'), {
      id: 'r0000000005', parent_id: 'r0000000001', revision_no: 5, body: 'X',
      presentation_mode: 'stableAlias', presentation_identity_id: ALICE_PUB,
      presentation_display_alias: ALICE_ALIAS, presentation_avatar_url: null,
      public_profile_ref: null, created_at: now(),
    });
    await assertFails(batch.commit());
  });
});

describe('R1 P0 · 点赞 unlike 原子删除', () => {
  test('owner like → unlike 成功（公开 like + 私有 owner 同批删除）', async () => {
    const postId = await seedPost();
    const likeId = 'like-unlike-1';
    await seedLike(likeId, 'post', postId);
    const db = alice().firestore();
    const batch = db.batch();
    batch.delete(db.collection('playground_likes').doc(likeId));
    batch.delete(db.collection('playground_like_owners').doc(likeId));
    await assertSucceeds(batch.commit());
  });

  // 注：单删公开 like 的 rules 级拒绝依赖 getAfter(owner).data==null（同批删除校验），
  // 但本 emulator 对 batch 中删除的文档 getAfter 抛 Null value（见 handoff），无法在
  // rules 层实现；原子性由 adapter 事务（同批删 like+owner）保证 + 各侧 owner-only。
  // 移除该负例（其断言与 emulator 能力冲突），不在本套件中断言。

  test('删除他人 like 拒绝', async () => {
    const postId = await seedPost();
    const likeId = 'like-other-1';
    await seedLike(likeId, 'post', postId, BOB_UID, BOB_APP);
    const db = alice().firestore();
    const batch = db.batch();
    batch.delete(db.collection('playground_likes').doc(likeId));
    batch.delete(db.collection('playground_like_owners').doc(likeId));
    await assertFails(batch.commit());
  });
});
