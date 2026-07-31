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
import { HttpsError } from 'firebase-functions/v2/https';
const createPost = _createPost as unknown as (req: any) => Promise<any>;

beforeEach(() => {
  clearStore();
});

function makeReq(data: any, uid?: string) {
  return { data, auth: uid ? { uid } : undefined } as any;
}

describe('idempotency', () => {
  it('首次执行返回结果并写入幂等记录', async () => {
    const result = await createPost(
      makeReq({ text: '幂等测试-首次', idempotency_key: 'idem-1' }, 'user-a'),
    );

    expect(result.id).toBeTruthy();

    const store = dumpStore();
    const idemDocs = store['playground_idempotency'];
    expect(idemDocs).toHaveLength(1);
    expect(idemDocs[0].idempotency_key).toBe('idem-1');
  });

  it('重放相同 key+payload 返回缓存', async () => {
    const req = makeReq({ text: '幂等测试-重放', idempotency_key: 'idem-2' }, 'user-a');

    const result1 = await createPost(req);
    const result2 = await createPost(req);

    expect(result2).toEqual(result1);

    const store = dumpStore();
    expect(store['playground_posts']).toHaveLength(1);
  });

  it('相同 key 不同 payload 冲突拒绝', async () => {
    const req1 = makeReq({ text: '内容A', idempotency_key: 'idem-3' }, 'user-a');
    await createPost(req1);

    const req2 = makeReq({ text: '内容B', idempotency_key: 'idem-3' }, 'user-a');

    await expect(createPost(req2)).rejects.toThrow(HttpsError);
  });

  it('无幂等 key 每次新建', async () => {
    await createPost(makeReq({ text: '无key1' }, 'user-a'));
    await createPost(makeReq({ text: '无key2' }, 'user-a'));

    const store = dumpStore();
    expect(store['playground_posts']).toHaveLength(2);
  });
});
