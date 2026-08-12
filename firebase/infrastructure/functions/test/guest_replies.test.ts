/**
 * RED-A：BLOCK-03 游客代表性回复（guest_replies.ts）纯逻辑契约测试。
 *
 * 覆盖（PHASE-5-DISPATCH §4.1）：
 * - 未认证可调：`request.auth` 为 null 不抛 unauthenticated（游客 callable 必须允许 auth==null）；
 * - 确定性：同 fixture 同参数两次调用 → 相同 ID 顺序（spec Scenario 4）；
 * - limit clamp：limit=3 → 返回 ≥5 条；limit=20 → 返回 ≤10 条；
 * - 反绕过：带 cursor/page/offset/sort 额外参数 → 结果与不带完全一致；
 * - 计数：totalReplyCount/hiddenReplyCount 正确；tombstone 不入 total；
 * - outcome feedback 对游客保持可见（返回 outcomeFeedback 非 null）；
 * - 敏感字段：visibleReplies[i] 不含 author_provider_uid/presentation_identity_id；
 * - 未知 selectionPolicyVersion（如 2）→ invalid-argument。
 *
 * 注意：本文件是纯逻辑测试（in-memory store，参照 blck01_callables.test.ts）；
 * 游客直连 deny 走真 emulator（firestore.rules.test.ts 的 BLOCK-03 guest 断言）。
 */

import { clearStore, dumpStore } from './helpers';

jest.mock('firebase-admin', () => {
  const { createAdminMock } = require('./helpers');
  return createAdminMock();
});

jest.mock('firebase-functions/v2/https', () => {
  const actual = jest.requireActual('firebase-functions/v2/https');
  return {
    ...actual,
    onCall: (...args: any[]) => {
      const handler = typeof args[0] === 'function' ? args[0] : args[1];
      return handler;
    },
  };
});

jest.mock('firebase-functions/v2/firestore', () => ({
  onDocumentCreated: (...args: any[]) => ({ run: jest.fn(), __opts: args[0] }),
}));

jest.mock('firebase-functions/v2/storage', () => ({
  onObjectFinalized: (...args: any[]) => ({ run: jest.fn(), __opts: args[0] }),
}));

jest.mock('firebase-functions/v2/scheduler', () => ({
  onSchedule: (...args: any[]) => ({ run: jest.fn(), __opts: args[0] }),
}));

import { getGuestRepresentativeReplies as _getGuestRepresentativeReplies } from '../src/guest_replies';
import * as admin from 'firebase-admin';
import { HttpsError } from 'firebase-functions/v2/https';

const getGuestRepresentativeReplies = _getGuestRepresentativeReplies as unknown as (
  req: any,
) => Promise<any>;

beforeEach(() => {
  clearStore();
});

function makeReq(data: any, uid?: string) {
  return { data, auth: uid ? { uid } : undefined } as any;
}

/** 递归检查对象任意层级是否包含敏感键。 */
function containsKeyDeep(obj: any, key: string): boolean {
  if (obj === null || typeof obj !== 'object') return false;
  if (Object.prototype.hasOwnProperty.call(obj, key)) return true;
  return Object.values(obj).some((v) => containsKeyDeep(v, key));
}

/** 种子：post + 12 条非墓碑 root + 2 条 tombstone root + 1 条 discussion + 1 条其他 post root。 */
async function seedThread() {
  const db = admin.firestore();
  await db.collection('playground_posts').doc('post-1').set({
    id: 'post-1',
    text: '测试帖子',
    author_provider_uid: 'user-a',
    author_app_user_id: 'app-a',
    status: 'active',
    has_outcome_feedback: true,
    created_at: '2026-01-01T00:00:00.000Z',
  });

  const roots = [
    { id: 'root-1', createdAt: '2026-01-01T08:00:00.000Z', verified: true, likes: 0 },
    { id: 'root-2', createdAt: '2026-01-01T01:00:00.000Z', verified: false, likes: 5 },
    { id: 'root-3', createdAt: '2026-01-01T02:00:00.000Z', verified: false, likes: 5 },
    { id: 'root-4', createdAt: '2026-01-01T03:00:00.000Z', verified: false, likes: 2 },
    { id: 'root-5', createdAt: '2026-01-01T04:00:00.000Z', verified: false, likes: 0 },
    { id: 'root-6', createdAt: '2026-01-01T05:00:00.000Z', verified: false, likes: 0 },
    { id: 'root-7', createdAt: '2026-01-01T06:00:00.000Z', verified: false, likes: 0 },
    { id: 'root-8', createdAt: '2026-01-01T07:00:00.000Z', verified: false, likes: 0 },
    { id: 'root-9', createdAt: '2026-01-02T01:00:00.000Z', verified: false, likes: 0 },
    { id: 'root-10', createdAt: '2026-01-02T02:00:00.000Z', verified: false, likes: 0 },
    { id: 'root-11', createdAt: '2026-01-02T03:00:00.000Z', verified: false, likes: 0 },
    { id: 'root-12', createdAt: '2026-01-02T04:00:00.000Z', verified: false, likes: 0 },
  ];

  for (const r of roots) {
    await db.collection('playground_replies').doc(r.id).set({
      id: r.id,
      post_id: 'post-1',
      parent_reply_id: null,
      root_reply_id: null,
      reply_to_reply_id: null,
      depth: 0,
      author_provider_uid: `author-${r.id}`,
      author_app_user_id: `app-author-${r.id}`,
      presentation_identity_id: `presentation-${r.id}`,
      body: `正文 ${r.id}`,
      is_tombstoned: false,
      technique_tags: ['六爻'],
      chart_attachment: null,
      media_attachments: [],
      verification: r.verified ? { verifier_app_user_id: 'app-poster', verified_at: '2026-01-03T00:00:00.000Z' } : null,
      revisions: [],
      created_at: r.createdAt,
      updated_at: null,
    });
  }

  // tombstone 不入 total、不参与 visible。
  for (const id of ['root-t1', 'root-t2']) {
    await db.collection('playground_replies').doc(id).set({
      id,
      post_id: 'post-1',
      parent_reply_id: null,
      root_reply_id: null,
      depth: 0,
      author_provider_uid: `author-${id}`,
      body: '',
      is_tombstoned: true,
      created_at: '2026-01-01T00:30:00.000Z',
    });
  }

  // discussion（depth=1）不入 total（total 只统计 root）。
  await db.collection('playground_replies').doc('disc-1').set({
    id: 'disc-1',
    post_id: 'post-1',
    parent_reply_id: 'root-1',
    root_reply_id: 'root-1',
    reply_to_reply_id: 'root-1',
    depth: 1,
    author_provider_uid: 'author-disc-1',
    body: '讨论回复',
    is_tombstoned: false,
    created_at: '2026-01-01T09:00:00.000Z',
  });

  // 其他 post 的 root——不得进入本 post 结果。
  await db.collection('playground_replies').doc('other-root').set({
    id: 'other-root',
    post_id: 'post-other',
    depth: 0,
    author_provider_uid: 'author-other',
    body: '别的帖子',
    is_tombstoned: false,
    created_at: '2026-01-01T00:00:00.000Z',
  });

  // likes：root-2 5 个、root-3 5 个、root-4 2 个。
  const likeTargets: Record<string, number> = {
    'root-2': 5,
    'root-3': 5,
    'root-4': 2,
  };
  let likeSeq = 0;
  for (const [replyId, count] of Object.entries(likeTargets)) {
    for (let i = 0; i < count; i++) {
      likeSeq++;
      await db.collection('playground_likes').doc(`like-reply-${likeSeq}`).set({
        id: `like-reply-${likeSeq}`,
        reply_id: replyId,
        user_provider_uid: `liker-${likeSeq}`,
        created_at: '2026-01-01T00:00:00.000Z',
      });
    }
  }

  // outcome feedback：游客保持可见。
  await db.collection('playground_outcome_feedback').doc('fb-1').set({
    id: 'fb-1',
    post_id: 'post-1',
    author_provider_uid: 'user-a',
    author_app_user_id: 'app-a',
    outcome_description: '占测已应验',
    deleted_at: null,
    created_at: '2026-01-05T00:00:00.000Z',
  });
}

describe('getGuestRepresentativeReplies（BLOCK-03 RED-A）', () => {
  it('未认证可调：request.auth 为 null 不抛 unauthenticated', async () => {
    await seedThread();
    const result = await getGuestRepresentativeReplies(
      makeReq({ postId: 'post-1' }),
    );
    expect(result.postId).toBe('post-1');
  });

  it('确定性：同 fixture 同参数两次调用 → 相同 ID 顺序（spec Scenario 4）', async () => {
    await seedThread();
    const r1 = await getGuestRepresentativeReplies(makeReq({ postId: 'post-1' }));
    const r2 = await getGuestRepresentativeReplies(makeReq({ postId: 'post-1' }));
    const ids1 = r1.visibleReplies.map((v: any) => v.publicReplyId);
    const ids2 = r2.visibleReplies.map((v: any) => v.publicReplyId);
    expect(ids1).toEqual(ids2);
    expect(ids1.length).toBe(5);
  });

  it('确定性排序：isVerified 优先 → likeCount desc → createdAt asc → replyId asc', async () => {
    await seedThread();
    const result = await getGuestRepresentativeReplies(
      makeReq({ postId: 'post-1', limit: 10 }),
    );
    const ids = result.visibleReplies.map((v: any) => v.publicReplyId);
    // root-1 被应验 → 第一位。
    expect(ids[0]).toBe('root-1');
    // root-2 / root-3 同为 5 赞 → 按 createdAt asc：root-2(01:00) 在 root-3(02:00) 前。
    const i2 = ids.indexOf('root-2');
    const i3 = ids.indexOf('root-3');
    expect(i2).toBeGreaterThan(0);
    expect(i3).toBeGreaterThan(i2);
    // root-4（2 赞）在 root-2/root-3 之后。
    expect(ids.indexOf('root-4')).toBeGreaterThan(i3);
  });

  it('limit clamp：limit=3 → 返回 ≥5 条；limit=20 → 返回 ≤10 条', async () => {
    await seedThread();
    const small = await getGuestRepresentativeReplies(
      makeReq({ postId: 'post-1', limit: 3 }),
    );
    expect(small.visibleReplies.length).toBeGreaterThanOrEqual(5);
    expect(small.visibleReplies.length).toBeLessThanOrEqual(10);

    const large = await getGuestRepresentativeReplies(
      makeReq({ postId: 'post-1', limit: 20 }),
    );
    expect(large.visibleReplies.length).toBeLessThanOrEqual(10);
  });

  it('非法 limit（非数字）→ 回退 5', async () => {
    await seedThread();
    const result = await getGuestRepresentativeReplies(
      makeReq({ postId: 'post-1', limit: 'abc' }),
    );
    expect(result.visibleReplies.length).toBe(5);
  });

  it('反绕过：带 cursor/page/offset/sort 额外参数 → 结果与不带完全一致', async () => {
    await seedThread();
    const base = await getGuestRepresentativeReplies(makeReq({ postId: 'post-1' }));
    const tampered = await getGuestRepresentativeReplies(
      makeReq({
        postId: 'post-1',
        cursor: 'next-page-token',
        page: 2,
        offset: 20,
        sort: 'created_at_desc',
      }),
    );
    expect(tampered).toEqual(base);
  });

  it('计数：total=12（非墓碑 root）、limit=5 → visible=5 hidden=7；tombstone 不入 total', async () => {
    await seedThread();
    const result = await getGuestRepresentativeReplies(makeReq({ postId: 'post-1' }));
    expect(result.totalReplyCount).toBe(12);
    expect(result.visibleReplies.length).toBe(5);
    expect(result.hiddenReplyCount).toBe(7);
    expect(result.selectionPolicyVersion).toBe(1);
  });

  it('outcome feedback 对游客可见', async () => {
    await seedThread();
    const result = await getGuestRepresentativeReplies(makeReq({ postId: 'post-1' }));
    expect(result.outcomeFeedback).not.toBeNull();
    expect(result.outcomeFeedback.body).toBe('占测已应验');
    expect(result.outcomeFeedback.isEdited).toBe(false);
  });

  it('registrationUnlock 元数据返回', async () => {
    await seedThread();
    const result = await getGuestRepresentativeReplies(makeReq({ postId: 'post-1' }));
    expect(result.registrationUnlock.requiresRegistration).toBe(true);
    expect(typeof result.registrationUnlock.ctaMessageKey).toBe('string');
    expect(typeof result.registrationUnlock.unlockRoute).toBe('string');
  });

  it('敏感字段：visibleReplies 不含 author_provider_uid/presentation_identity_id/author_app_user_id', async () => {
    await seedThread();
    const result = await getGuestRepresentativeReplies(
      makeReq({ postId: 'post-1', limit: 10 }),
    );
    expect(result.visibleReplies.length).toBeGreaterThan(0);
    for (const v of result.visibleReplies) {
      expect(containsKeyDeep(v, 'author_provider_uid')).toBe(false);
      expect(containsKeyDeep(v, 'author_app_user_id')).toBe(false);
      expect(containsKeyDeep(v, 'presentation_identity_id')).toBe(false);
      expect(v.isTombstoned).toBe(false);
    }
  });

  it('未知 selectionPolicyVersion（如 2）→ invalid-argument', async () => {
    await seedThread();
    await expect(
      getGuestRepresentativeReplies(
        makeReq({ postId: 'post-1', selectionPolicyVersion: 2 }),
      ),
    ).rejects.toThrow(HttpsError);
  });

  it('缺省 selectionPolicyVersion → 1', async () => {
    await seedThread();
    const result = await getGuestRepresentativeReplies(makeReq({ postId: 'post-1' }));
    expect(result.selectionPolicyVersion).toBe(1);
  });

  it('post 不存在 → not-found', async () => {
    const db = admin.firestore();
    await db.collection('playground_posts').doc('post-x').set({
      id: 'post-x',
      text: '不活跃',
      status: 'inactive',
      author_provider_uid: 'user-a',
      created_at: '2026-01-01T00:00:00.000Z',
    });
    await expect(
      getGuestRepresentativeReplies(makeReq({ postId: 'post-x' })),
    ).rejects.toThrow(HttpsError);
  });

  it('0 条回复 → visible 空、total=0、hidden=0', async () => {
    const db = admin.firestore();
    await db.collection('playground_posts').doc('post-0').set({
      id: 'post-0',
      text: '空帖',
      status: 'active',
      author_provider_uid: 'user-a',
      created_at: '2026-01-01T00:00:00.000Z',
    });
    const result = await getGuestRepresentativeReplies(
      makeReq({ postId: 'post-0' }),
    );
    expect(result.visibleReplies).toEqual([]);
    expect(result.totalReplyCount).toBe(0);
    expect(result.hiddenReplyCount).toBe(0);
  });

  it('1 条回复 → visible=1 hidden=0', async () => {
    const db = admin.firestore();
    await db.collection('playground_posts').doc('post-1r').set({
      id: 'post-1r',
      text: '单回复帖',
      status: 'active',
      author_provider_uid: 'user-a',
      created_at: '2026-01-01T00:00:00.000Z',
    });
    await db.collection('playground_replies').doc('solo').set({
      id: 'solo',
      post_id: 'post-1r',
      depth: 0,
      author_provider_uid: 'author-solo',
      body: '唯一回复',
      is_tombstoned: false,
      technique_tags: [],
      chart_attachment: null,
      media_attachments: [],
      verification: null,
      revisions: [],
      created_at: '2026-01-01T08:00:00.000Z',
    });
    const result = await getGuestRepresentativeReplies(
      makeReq({ postId: 'post-1r' }),
    );
    expect(result.visibleReplies.length).toBe(1);
    expect(result.totalReplyCount).toBe(1);
    expect(result.hiddenReplyCount).toBe(0);
  });

  it('无 likes 集合数据时 likeCount=0 不报错', async () => {
    // seedThread 已覆盖有 likes；此处验证空 likes 集合 path。
    const db = admin.firestore();
    await db.collection('playground_posts').doc('post-nl').set({
      id: 'post-nl',
      text: '无赞帖',
      status: 'active',
      author_provider_uid: 'user-a',
      created_at: '2026-01-01T00:00:00.000Z',
    });
    await db.collection('playground_replies').doc('nl-1').set({
      id: 'nl-1',
      post_id: 'post-nl',
      depth: 0,
      author_provider_uid: 'author-nl',
      body: '无赞回复',
      is_tombstoned: false,
      verification: null,
      revisions: [],
      created_at: '2026-01-01T08:00:00.000Z',
    });
    const result = await getGuestRepresentativeReplies(
      makeReq({ postId: 'post-nl' }),
    );
    expect(result.totalReplyCount).toBe(1);
    expect(result.visibleReplies[0].publicReplyId).toBe('nl-1');
  });
});
