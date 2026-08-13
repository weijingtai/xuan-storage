import { clearStore, dumpStore } from './helpers';

jest.mock('firebase-admin', () => ({ createAdminMock: undefined, ...require('./helpers').createAdminMock() }));
jest.mock('firebase-functions/v2/https', () => {
  const actual = jest.requireActual('firebase-functions/v2/https');
  return { ...actual, onCall: (...args: any[]) => (typeof args[0] === 'function' ? args[0] : args[1]) };
});
jest.mock('firebase-functions/v2/firestore', () => ({ onDocumentCreated: jest.fn() }));
jest.mock('firebase-functions/v2/storage', () => ({ onObjectFinalized: jest.fn() }));
jest.mock('firebase-functions/v2/scheduler', () => ({ onSchedule: jest.fn() }));

import { updateMyProfile as _updateMyProfile } from '../src/profiles';
import { HttpsError } from 'firebase-functions/v2/https';
const updateMyProfile = _updateMyProfile as unknown as (req: any) => Promise<any>;
const req = (data: any, uid?: string) => ({ data, auth: uid ? { uid } : undefined });

beforeEach(clearStore);

describe('updateMyProfile', () => {
  it('mints profile ownership from the trusted actor and rejects caller identity', async () => {
    await updateMyProfile(req({ displayName: '盘友', appUserId: 'forged', user_provider_uid: 'forged' }, 'u-1'));
    const profile = dumpStore()['playground_profiles'][0];
    expect(profile.user_provider_uid).toBe('u-1');
    expect(profile.display_name).toBe('盘友');
    expect(profile.appUserId).toBeUndefined();
  });

  it('rejects unauthenticated and empty updates', async () => {
    await expect(updateMyProfile(req({ displayName: 'x' }))).rejects.toThrow(HttpsError);
    await expect(updateMyProfile(req({}, 'u-1'))).rejects.toThrow(HttpsError);
  });
});
