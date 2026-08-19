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

import { resolveAppUserId } from '../src/identity';
import { resolveMyIdentity as _rmi } from '../src/identity';
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const resolveMyIdentity = _rmi as any as (req: any) => Promise<any>;

beforeEach(() => {
  clearStore();
});

describe('identity schema convergence', () => {
  it('新建 identity_map → snake_case 字段完整', async () => {
    const result = await resolveAppUserId('alice');

    expect(result.appUserId).toBeTruthy();
    expect(result.appUserId).toMatch(/^app-/);
    expect(result.publicPresentationId).toBeTruthy();
    expect(result.publicPresentationId).toHaveLength(32);
    expect(result.publicDisplayAlias).toBeTruthy();
    expect(result.publicDisplayAlias).toMatch(/^玄友\d{4}$/);

    const store = dumpStore();
    const identityDocs = store['identity_map'];
    expect(identityDocs).toHaveLength(1);
    const doc = identityDocs[0];
    expect(doc.id).toBe('alice');
    expect(doc.app_user_id).toBe(result.appUserId);
    expect(doc.provider_uid).toBe('alice');
    expect(doc.provider_id).toBe('firebase');
    expect(doc.public_presentation_id).toBe(result.publicPresentationId);
    expect(doc.public_display_alias).toBe(result.publicDisplayAlias);
    expect(doc.created_at).toBeTruthy();
  });

  it('已存在 snake_case identity → 读回不覆盖', async () => {
    const { createAdminMock } = require('./helpers');
    const mock = createAdminMock();
    const db = mock.firestore();
    await db.collection('identity_map').doc('alice').set({
      app_user_id: 'app-alice',
      provider_uid: 'alice',
      provider_id: 'firebase',
      public_presentation_id: 'pub_random_128bit',
      public_display_alias: '玄友0001',
    });

    const result = await resolveAppUserId('alice');
    expect(result.appUserId).toBe('app-alice');
    expect(result.publicPresentationId).toBe('pub_random_128bit');
    expect(result.publicDisplayAlias).toBe('玄友0001');

    const store = dumpStore();
    expect(store['identity_map']).toHaveLength(1);
    expect(store['identity_map'][0].app_user_id).toBe('app-alice');
  });

  it('旧 camelCase appUserId → 兼容读回', async () => {
    const { createAdminMock } = require('./helpers');
    const mock = createAdminMock();
    const db = mock.firestore();
    await db.collection('identity_map').doc('bob').set({
      appUserId: 'app-bob-old',
      provider_uid: 'bob',
      provider_id: 'firebase',
      public_presentation_id: 'pub_bob',
      public_display_alias: '玄友0002',
    });

    const result = await resolveAppUserId('bob');
    expect(result.appUserId).toBe('app-bob-old');
    expect(result.publicPresentationId).toBe('pub_bob');
  });

  it('resolveMyIdentity callable 返回完整身份', async () => {
    const req = { auth: { uid: 'charlie' }, data: {}, rawRequest: {} };
    const response = await resolveMyIdentity(req);
    expect(response.appUserId).toBeTruthy();
    expect(response.appUserId).toMatch(/^app-/);
    expect(response.publicPresentationId).toBeTruthy();
    expect(response.publicDisplayAlias).toBeTruthy();
    expect(response.publicDisplayAlias).toMatch(/^玄友\d{4}$/);
  });
});