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

import { setOutcomeFeedback as _sof, revokeOutcomeFeedback as _rof } from '../src/outcome_feedback';
import { createRootReply as _crr } from '../src/replies';
import * as admin from 'firebase-admin';
import { HttpsError } from 'firebase-functions/v2/https';
const setOutcomeFeedback = _sof as unknown as (req: any) => Promise<any>;
const revokeOutcomeFeedback = _rof as unknown as (req: any) => Promise<any>;
const createRootReply = _crr as unknown as (req: any) => Promise<any>;

beforeEach(() => {
  clearStore();
});

function makeReq(data: any, uid?: string) {
  return { data, auth: uid ? { uid } : undefined } as any;
}

async function seedPost(postId: string, authorUid: string = 'user-1') {
  const db = admin.firestore();
  await db.collection('playground_posts').doc(postId).set({
    id: postId,
    text: '测试帖子',
    author_provider_uid: authorUid,
    author_app_user_id: `app-${authorUid}`,
    status: 'active',
    has_outcome_feedback: false,
    created_at: new Date().toISOString(),
  });
}

describe('setOutcomeFeedback', () => {
  it('帖子作者设置成功', async () => {
    await seedPost('post-1', 'user-1');
    const result = await setOutcomeFeedback(
      makeReq({ postId: 'post-1', outcome_description: '预测准确，结果匹配' }, 'user-1'),
    );

    expect(result.id).toBeTruthy();
    expect(result.post_id).toBe('post-1');
    expect(result.outcome_description).toBe('预测准确，结果匹配');

    const store = dumpStore();
    expect(store['playground_outcome_feedback']).toHaveLength(1);

    const post = store['playground_posts'].find((p: any) => p.id === 'post-1');
    expect(post).toBeDefined();
    expect(post!.has_outcome_feedback).toBe(true);
  });

  it('非帖子作者拒绝', async () => {
    await seedPost('post-1', 'user-1');
    await expect(
      setOutcomeFeedback(
        makeReq({ postId: 'post-1', outcome_description: '结果' }, 'user-2'),
      ),
    ).rejects.toThrow(HttpsError);
  });

  it('重复设置反馈拒绝', async () => {
    await seedPost('post-1', 'user-1');
    await setOutcomeFeedback(
      makeReq({ postId: 'post-1', outcome_description: '第一次反馈' }, 'user-1'),
    );

    await expect(
      setOutcomeFeedback(
        makeReq({ postId: 'post-1', outcome_description: '第二次反馈' }, 'user-1'),
      ),
    ).rejects.toThrow(HttpsError);
  });

  it('反馈后仍可回复', async () => {
    await seedPost('post-1', 'user-1');
    await setOutcomeFeedback(
      makeReq({ postId: 'post-1', outcome_description: '反馈' }, 'user-1'),
    );

    const replyResult = await createRootReply(
      makeReq({ postId: 'post-1', text: '反馈后回复', idempotency_key: 'rr-feedback-1' }, 'user-2'),
    );
    expect(replyResult.id).toBeTruthy();
  });
});

describe('revokeOutcomeFeedback', () => {
  it('撤销反馈成功', async () => {
    await seedPost('post-1', 'user-1');
    await setOutcomeFeedback(
      makeReq({ postId: 'post-1', outcome_description: '反馈内容' }, 'user-1'),
    );

    const result = await revokeOutcomeFeedback(
      makeReq({ postId: 'post-1' }, 'user-1'),
    );
    expect(result.success).toBe(true);

    const db = admin.firestore();
    const feedbackSnap = await db.collection('playground_outcome_feedback').get();
    expect(feedbackSnap.docs[0].data().deleted_at).toBeTruthy();

    const postSnap = await db.collection('playground_posts').doc('post-1').get();
    expect(postSnap.data()?.has_outcome_feedback).toBe(false);
  });

  it('无权撤销他人反馈', async () => {
    await seedPost('post-1', 'user-1');
    await setOutcomeFeedback(
      makeReq({ postId: 'post-1', outcome_description: '反馈' }, 'user-1'),
    );

    await expect(
      revokeOutcomeFeedback(makeReq({ postId: 'post-1' }, 'user-2')),
    ).rejects.toThrow(HttpsError);
  });
});
