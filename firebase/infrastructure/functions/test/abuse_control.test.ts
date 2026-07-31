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

import { checkRateLimit, recordAction } from '../src/abuse_control';
import { HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

beforeEach(() => {
  clearStore();
});

function makeReq(data: any, uid?: string) {
  return { data, auth: uid ? { uid } : undefined } as any;
}

describe('abuse_control — 频率限制', () => {
  it('首次操作不触发限制', async () => {
    await expect(
      checkRateLimit({ appUserId: 'app-u1', action: 'create_post', maxPerMinute: 5 }),
    ).resolves.toBeUndefined();
  });

  it('超过频率限制抛出 resource-exhausted', async () => {
    const params = { appUserId: 'app-u2', action: 'create_post', maxPerMinute: 3 };

    for (let i = 0; i < 3; i++) {
      await recordAction({ appUserId: 'app-u2', action: 'create_post', idempotencyKey: `abuse-${i}` });
    }

    await expect(checkRateLimit(params)).rejects.toThrow(HttpsError);
  });

  it('不同用户独立计数', async () => {
    for (let i = 0; i < 3; i++) {
      await recordAction({ appUserId: 'app-ua', action: 'create_post', idempotencyKey: `ua-${i}` });
    }

    await expect(
      checkRateLimit({ appUserId: 'app-ua', action: 'create_post', maxPerMinute: 3 }),
    ).rejects.toThrow(HttpsError);

    await expect(
      checkRateLimit({ appUserId: 'app-ub', action: 'create_post', maxPerMinute: 3 }),
    ).resolves.toBeUndefined();
  });

  it('不同操作独立计数', async () => {
    for (let i = 0; i < 3; i++) {
      await recordAction({ appUserId: 'app-uc', action: 'create_post', idempotencyKey: `cp-${i}` });
    }

    await expect(
      checkRateLimit({ appUserId: 'app-uc', action: 'create_post', maxPerMinute: 3 }),
    ).rejects.toThrow(HttpsError);

    await expect(
      checkRateLimit({ appUserId: 'app-uc', action: 'create_reply', maxPerMinute: 3 }),
    ).resolves.toBeUndefined();
  });
});
