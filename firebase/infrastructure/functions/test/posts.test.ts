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
import * as admin from 'firebase-admin';
import { HttpsError } from 'firebase-functions/v2/https';
const createPost = _createPost as unknown as (req: any) => Promise<any>;

beforeEach(() => {
  clearStore();
});

function makeReq(data: any, uid?: string) {
  return { data, auth: uid ? { uid } : undefined } as any;
}

describe('createPost', () => {
  it('创建帖子成功并返回正确字段', async () => {
    const result = await createPost(
      makeReq({ text: '测试帖子内容', idempotency_key: 'key-1' }, 'user-1'),
    );

    expect(result).toBeDefined();
    expect(result.id).toBeTruthy();
    expect(result.text).toBe('测试帖子内容');
    expect(result.author_app_user_id).toBeTruthy();
    expect(result.status).toBe('active');
    expect(result.allowed_chart_technique_ids).toEqual([]);
    expect(result.attachments).toEqual([]);
    expect(result.created_at).toBeTruthy();

    const store = dumpStore();
    const posts = store['playground_posts'];
    expect(posts).toHaveLength(1);
    expect(posts[0].text).toBe('测试帖子内容');
    expect(posts[0].status).toBe('active');
  });

  it('未认证用户创建帖子应拒绝', async () => {
    await expect(
      createPost(makeReq({ text: '测试' })),
    ).rejects.toThrow(HttpsError);
  });

  it('text 为空应拒绝', async () => {
    await expect(
      createPost(makeReq({ text: '' }, 'user-1')),
    ).rejects.toThrow(HttpsError);

    await expect(
      createPost(makeReq({ text: '   ' }, 'user-1')),
    ).rejects.toThrow(HttpsError);

    await expect(
      createPost(makeReq({}, 'user-1')),
    ).rejects.toThrow(HttpsError);
  });

  it('相同幂等 key 重放返回缓存结果', async () => {
    const req = makeReq({ text: '幂等测试', idempotency_key: 'key-replay' }, 'user-1');
    const result1 = await createPost(req);
    const result2 = await createPost(req);

    expect(result2.id).toBe(result1.id);
    expect(result2.text).toBe(result1.text);

    const store = dumpStore();
    const posts = store['playground_posts'];
    expect(posts).toHaveLength(1);
  });

  it('相同幂等 key 不同 payload 应拒绝 (冲突)', async () => {
    const req1 = makeReq({ text: '内容A', idempotency_key: 'key-conflict' }, 'user-1');
    await createPost(req1);

    const req2 = makeReq({ text: '内容B', idempotency_key: 'key-conflict' }, 'user-1');

    await expect(createPost(req2)).rejects.toThrow(HttpsError);
  });
});
