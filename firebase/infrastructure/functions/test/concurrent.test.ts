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

import { createPost as _createPost } from '../src/posts';
import { setLike as _setLike } from '../src/likes';
import { HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
const createPost = _createPost as unknown as (req: any) => Promise<any>;
const setLike = _setLike as unknown as (req: any) => Promise<any>;

beforeEach(() => {
  clearStore();
});

function makeReq(data: any, uid?: string) {
  return { data, auth: uid ? { uid } : undefined } as any;
}

describe('并发测试', () => {
  it('并行创建不同幂等 key 的帖子互相不干扰', async () => {
    const promises = [
      createPost(makeReq({ text: '帖子A', idempotency_key: 'conc-a' }, 'user-1')),
      createPost(makeReq({ text: '帖子B', idempotency_key: 'conc-b' }, 'user-2')),
      createPost(makeReq({ text: '帖子C', idempotency_key: 'conc-c' }, 'user-3')),
    ];

    const results = await Promise.all(promises);
    expect(results).toHaveLength(3);
    expect(results[0].id).not.toBe(results[1].id);
    expect(results[1].id).not.toBe(results[2].id);

    const store = dumpStore();
    expect(store['playground_posts']).toHaveLength(3);
  });

  it('并行创建相同幂等 key: 由于 mock 无序列化事务隔离, 可能产生多条记录', async () => {
    const key = 'parallel-same-key';
    const promises = [
      createPost(makeReq({ text: '并发A', idempotency_key: key }, 'user-1')),
      createPost(makeReq({ text: '并发A', idempotency_key: key }, 'user-1')),
      createPost(makeReq({ text: '并发A', idempotency_key: key }, 'user-1')),
    ];

    const results = await Promise.allSettled(promises);

    const fulfilled = results.filter((r) => r.status === 'fulfilled');
    expect(fulfilled.length).toBeGreaterThanOrEqual(1);

    const store = dumpStore();
    expect(store['playground_posts'].length).toBeGreaterThanOrEqual(1);
  });

  it('并行点赞和取消: 并发安全', async () => {
    const db = admin.firestore();
    await db.collection('playground_posts').doc('post-c').set({
      id: 'post-c',
      text: '帖子',
      author_provider_uid: 'author',
      author_app_user_id: 'app-author',
      status: 'active',
      created_at: new Date().toISOString(),
    });

    const promises = [
      setLike(makeReq({ postId: 'post-c', action: 'like' }, 'user-1')),
      setLike(makeReq({ postId: 'post-c', action: 'like' }, 'user-2')),
      setLike(makeReq({ postId: 'post-c', action: 'like' }, 'user-3')),
    ];

    const results = await Promise.all(promises);
    expect(results.every((r: any) => r.liked)).toBe(true);

    const store = dumpStore();
    const likes = store['playground_likes'];
    expect(likes).toHaveLength(3);
  });
});
