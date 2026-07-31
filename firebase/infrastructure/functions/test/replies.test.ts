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

import { createRootReply as _crr, createDiscussionReply as _cdr, deleteReply as _dr } from '../src/replies';
import * as admin from 'firebase-admin';
import { HttpsError } from 'firebase-functions/v2/https';
const createRootReply = _crr as unknown as (req: any) => Promise<any>;
const createDiscussionReply = _cdr as unknown as (req: any) => Promise<any>;
const deleteReply = _dr as unknown as (req: any) => Promise<any>;

beforeEach(() => {
  clearStore();
});

function makeReq(data: any, uid?: string) {
  return { data, auth: uid ? { uid } : undefined } as any;
}

async function seedPost(postId: string, authorUid: string = 'author-1') {
  const db = admin.firestore();
  await db.collection('playground_posts').doc(postId).set({
    id: postId,
    text: '测试帖子',
    author_provider_uid: authorUid,
    status: 'active',
    created_at: new Date().toISOString(),
  });
}

async function seedReply(replyId: string, postId: string, authorUid: string = 'author-1', overrides: any = {}) {
  const db = admin.firestore();
  await db.collection('playground_replies').doc(replyId).set({
    id: replyId,
    post_id: postId,
    parent_reply_id: null,
    root_reply_id: null,
    depth: 0,
    author_provider_uid: authorUid,
    text: '测试回复',
    is_tombstoned: false,
    verification: null,
    created_at: new Date().toISOString(),
    ...overrides,
  });
}

describe('createRootReply', () => {
  it('创建根回复成功', async () => {
    await seedPost('post-1');
    const result = await createRootReply(
      makeReq({ postId: 'post-1', text: '根回复内容', idempotency_key: 'rr-1' }, 'user-2'),
    );

    expect(result.id).toBeTruthy();
    expect(result.post_id).toBe('post-1');
    expect(result.depth).toBe(0);
    expect(result.parent_reply_id).toBeNull();
    expect(result.root_reply_id).toBeNull();
    expect(result.is_tombstoned).toBe(false);

    const store = dumpStore();
    expect(store['playground_replies']).toHaveLength(1);
  });

  it('帖子不存在应拒绝', async () => {
    await expect(
      createRootReply(makeReq({ postId: 'nonexistent', text: '回复' }, 'user-1')),
    ).rejects.toThrow(HttpsError);
  });

  it('未认证用户应拒绝', async () => {
    await expect(
      createRootReply(makeReq({ postId: 'post-1', text: '回复' })),
    ).rejects.toThrow(HttpsError);
  });
});

describe('createDiscussionReply', () => {
  it('创建讨论回复成功', async () => {
    await seedPost('post-1');
    await seedReply('reply-1', 'post-1', 'user-2');

    const result = await createDiscussionReply(
      makeReq({ postId: 'post-1', rootReplyId: 'reply-1', text: '讨论回复', idempotency_key: 'dr-1' }, 'user-3'),
    );

    expect(result.id).toBeTruthy();
    expect(result.depth).toBe(1);
    expect(result.parent_reply_id).toBe('reply-1');
    expect(result.root_reply_id).toBe('reply-1');
  });

  it('深度超过 MAX_REPLY_DEPTH 应拒绝', async () => {
    await seedPost('post-1');
    await seedReply('reply-1', 'post-1', 'user-2');

    await expect(
      createDiscussionReply(
        makeReq({ postId: 'post-1', rootReplyId: 'reply-1', text: '三级回复' }, 'user-3'),
      ),
    ).resolves.toBeDefined();

    const db = admin.firestore();
    const repliesSnap = await db.collection('playground_replies').get();
    const discussionReplyId = repliesSnap.docs.find((d: any) => d.data().depth === 1)?.id;

    if (discussionReplyId) {
      // 尝试第三层 — 应该被拒绝因为 MAX_REPLY_DEPTH = 1 意味着只允许 depth 0 和 1
      // createDiscussionReply 检查 rootReplyId 对应的回复必须是 depth=0 的根回复
      // 而讨论回复的 depth=1，不是根回复
      await expect(
        createDiscussionReply(
          makeReq({ postId: 'post-1', rootReplyId: discussionReplyId, text: '三级' }, 'user-4'),
        ),
      ).rejects.toThrow(HttpsError);
    }
  });

  it('跨帖回复应拒绝', async () => {
    await seedPost('post-1');
    await seedPost('post-2');
    await seedReply('reply-1', 'post-1', 'user-2');

    await expect(
      createDiscussionReply(
        makeReq({ postId: 'post-2', rootReplyId: 'reply-1', text: '跨帖' }, 'user-3'),
      ),
    ).rejects.toThrow(HttpsError);
  });

  it('根回复不存在应拒绝', async () => {
    await seedPost('post-1');
    await expect(
      createDiscussionReply(
        makeReq({ postId: 'post-1', rootReplyId: 'nonexistent', text: '回复' }, 'user-2'),
      ),
    ).rejects.toThrow(HttpsError);
  });
});

describe('deleteReply', () => {
  it('逻辑删除 (tombstone) 成功', async () => {
    await seedPost('post-1');
    await seedReply('reply-1', 'post-1', 'user-2');

    const result = await deleteReply(
      makeReq({ replyId: 'reply-1' }, 'user-2'),
    );

    expect(result.success).toBe(true);

    const db = admin.firestore();
    const snap = await db.collection('playground_replies').doc('reply-1').get();
    expect(snap.data()?.is_tombstoned).toBe(true);
  });

  it('非作者不能删除', async () => {
    await seedPost('post-1');
    await seedReply('reply-1', 'post-1', 'user-2');

    await expect(
      deleteReply(makeReq({ replyId: 'reply-1' }, 'user-3')),
    ).rejects.toThrow(HttpsError);
  });

  it('不存在的回复应拒绝', async () => {
    await expect(
      deleteReply(makeReq({ replyId: 'nonexistent' }, 'user-1')),
    ).rejects.toThrow(HttpsError);
  });
});
