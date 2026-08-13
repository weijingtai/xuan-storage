/**
 * BLOCK-01 callable 幂等 + 身份解析纯逻辑测试。
 *
 * 覆盖：
 * - resolveMyIdentity：基于 Auth context 返回 appUserId（不信任客户端身份值）
 * - setLike：同 idempotency_key 重试不重复写 likes/outbox
 * - sendDmRequest/respondDmRequest/sendMessage/blockUser/unblockUser：
 *   同 key 重试不重复写 conversations/messages/blocks/outbox
 *
 * 注意：本文件是纯逻辑测试（in-memory store），双证据走真 emulator
 * （firestore.rules.test.ts + Flutter 侧双证据）。
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

import { resolveMyIdentity as _resolveMyIdentity } from '../src/identity';
import { setLike as _setLike } from '../src/likes';
import { setBookmark as _setBookmark } from '../src/bookmarks';
import {
  sendDmRequest as _sendDmRequest,
  respondDmRequest as _respondDmRequest,
  sendMessage as _sendMessage,
  blockUser as _blockUser,
  unblockUser as _unblockUser,
} from '../src/conversations';
import * as admin from 'firebase-admin';
import { HttpsError } from 'firebase-functions/v2/https';

const resolveMyIdentity = _resolveMyIdentity as unknown as (
  req: any,
) => Promise<any>;
const setLike = _setLike as unknown as (req: any) => Promise<any>;
const setBookmark = _setBookmark as unknown as (req: any) => Promise<any>;
const sendDmRequest = _sendDmRequest as unknown as (req: any) => Promise<any>;
const respondDmRequest = _respondDmRequest as unknown as (
  req: any,
) => Promise<any>;
const sendMessage = _sendMessage as unknown as (req: any) => Promise<any>;
const blockUser = _blockUser as unknown as (req: any) => Promise<any>;
const unblockUser = _unblockUser as unknown as (req: any) => Promise<any>;

beforeEach(() => {
  clearStore();
});

function makeReq(data: any, uid?: string) {
  return { data, auth: uid ? { uid } : undefined } as any;
}

async function seedPost(postId: string, authorUid: string) {
  const db = admin.firestore();
  await db.collection('playground_posts').doc(postId).set({
    id: postId,
    text: '测试帖子',
    author_provider_uid: authorUid,
    author_app_user_id: `app-${authorUid}`,
    status: 'active',
    created_at: new Date().toISOString(),
  });
}

describe('resolveMyIdentity', () => {
  it('未认证 → 拒绝', async () => {
    await expect(resolveMyIdentity(makeReq({}))).rejects.toThrow(HttpsError);
  });

  it('认证 → 返回 appUserId 并创建 identity_map', async () => {
    const result = await resolveMyIdentity(makeReq({}, 'user-a'));
    expect(result.appUserId).toBeTruthy();

    const store = dumpStore();
    const idMap = store['identity_map'];
    expect(idMap).toHaveLength(1);
    expect(idMap[0].app_user_id).toBe(result.appUserId);
    expect(idMap[0].provider_uid).toBe('user-a');
  });

  it('同一 uid 重复调用 → 返回相同 appUserId（不重复建映射）', async () => {
    const r1 = await resolveMyIdentity(makeReq({}, 'user-a'));
    const r2 = await resolveMyIdentity(makeReq({}, 'user-a'));
    expect(r2.appUserId).toBe(r1.appUserId);

    const store = dumpStore();
    expect(store['identity_map']).toHaveLength(1);
  });

  it('不同 uid → 各自独立 appUserId', async () => {
    const r1 = await resolveMyIdentity(makeReq({}, 'user-a'));
    const r2 = await resolveMyIdentity(makeReq({}, 'user-b'));
    expect(r1.appUserId).not.toBe(r2.appUserId);
  });
});

describe('setLike 幂等（BLOCK-01）', () => {
  it('同 idempotency_key 重试 → likes/outbox 不重复写', async () => {
    await seedPost('post-1', 'user-a');
    const req = makeReq(
      { postId: 'post-1', action: 'like', idempotency_key: 'like-key-1' },
      'user-a',
    );
    const r1 = await setLike(req);
    const r2 = await setLike(req);

    expect(r2).toEqual(r1);

    const store = dumpStore();
    expect(store['playground_likes']).toHaveLength(1);
    const likeAdded = store['playground_outbox'].filter(
      (e) => e.event_type === 'like_added',
    );
    expect(likeAdded).toHaveLength(1);
  });

  it('不同 idempotency_key → 各自独立处理（unlike 后再 like）', async () => {
    await seedPost('post-2', 'user-a');
    const like = makeReq(
      { postId: 'post-2', action: 'like', idempotency_key: 'like-key-2' },
      'user-a',
    );
    const unlike = makeReq(
      { postId: 'post-2', action: 'unlike', idempotency_key: 'like-key-3' },
      'user-a',
    );
    await setLike(like);
    await setLike(unlike);

    const store = dumpStore();
    expect(store['playground_likes']).toHaveLength(0);
    const removed = store['playground_outbox'].filter(
      (e) => e.event_type === 'like_removed',
    );
    expect(removed).toHaveLength(1);
  });

  it('无 idempotency_key → 正常执行', async () => {
    await seedPost('post-3', 'user-a');
    const result = await setLike(
      makeReq({ postId: 'post-3', action: 'like' }, 'user-a'),
    );
    expect(result.liked).toBe(true);
    const store = dumpStore();
    expect(store['playground_likes']).toHaveLength(1);
  });
});

describe('conversations 幂等（BLOCK-01）', () => {
  it('sendDmRequest 同 key 重试 → 只建一条对话 + 一条首消息', async () => {
    const req = makeReq(
      {
        targetAppUserId: 'app-target',
        initialMessage: '你好',
        idempotency_key: 'dm-key-1',
      },
      'user-a',
    );
    const r1 = await sendDmRequest(req);
    const r2 = await sendDmRequest(req);

    expect(r2.conversation_id).toBe(r1.conversation_id);

    const store = dumpStore();
    expect(store['playground_conversations']).toHaveLength(1);
    const dmRequests = store['playground_messages'].filter(
      (m) => m.type === 'dm_request',
    );
    expect(dmRequests).toHaveLength(1);
    expect(store['playground_conversations'][0]).toMatchObject({
      participant_a_provider_uid: 'user-a',
      participant_a_app_user_id: r1.participants[0],
      participant_b_app_user_id: 'app-target',
      status: 'pending',
    });
    expect(dmRequests[0]).toMatchObject({
      sender_provider_uid: 'user-a',
      sender_app_user_id: r1.participants[0],
      recipient_app_user_id: 'app-target',
      sent_at: expect.anything(),
    });
  });

  it('respondDmRequest 同 key 重试 → outbox 只写一次 dm_accepted', async () => {
    // user-b 通过 resolveMyIdentity 拿到真实 appUserId 作为接收方
    const bobIdentity = await resolveMyIdentity(makeReq({}, 'user-b'));
    const created = await sendDmRequest(
      makeReq(
        {
          targetAppUserId: bobIdentity.appUserId,
          initialMessage: '你好',
          idempotency_key: 'dm-create-1',
        },
        'user-a',
      ),
    );

    const req = makeReq(
      {
        conversationId: created.conversation_id,
        accept: true,
        idempotency_key: 'dm-respond-1',
      },
      'user-b',
    );
    const r1 = await respondDmRequest(req);
    const r2 = await respondDmRequest(req);

    expect(r2.status).toBe(r1.status);
    expect(r1.status).toBe('active');

    const store = dumpStore();
    const accepted = store['playground_outbox'].filter(
      (e) => e.event_type === 'dm_accepted',
    );
    expect(accepted).toHaveLength(1);
  });

  it('sendMessage 同 key 重试 → messages/outbox 各一条', async () => {
    const bobIdentity = await resolveMyIdentity(makeReq({}, 'user-b'));
    const created = await sendDmRequest(
      makeReq(
        {
          targetAppUserId: bobIdentity.appUserId,
          initialMessage: '你好',
          idempotency_key: 'dm-create-2',
        },
        'user-a',
      ),
    );
    await respondDmRequest(
      makeReq(
        {
          conversationId: created.conversation_id,
          accept: true,
          idempotency_key: 'dm-respond-2',
        },
        'user-b',
      ),
    );

    const req = makeReq(
      {
        conversationId: created.conversation_id,
        text: '继续聊聊',
        idempotency_key: 'dm-msg-1',
      },
      'user-a',
    );
    const m1 = await sendMessage(req);
    const m2 = await sendMessage(req);

    expect(m2.message_id).toBe(m1.message_id);

    const store = dumpStore();
    const dmMessages = store['playground_messages'].filter(
      (m) => m.type === 'message',
    );
    expect(dmMessages).toHaveLength(1);
    const outboxMessages = store['playground_outbox'].filter(
      (e) => e.event_type === 'dm_message',
    );
    expect(outboxMessages).toHaveLength(1);
  });

  it('blockUser 同 key 重试 → blocks 只一条', async () => {
    const req = makeReq(
      { targetAppUserId: 'app-target', idempotency_key: 'block-key-1' },
      'user-a',
    );
    const r1 = await blockUser(req);
    const r2 = await blockUser(req);

    expect(r2.blocked).toBe(r1.blocked);

    const store = dumpStore();
    expect(store['playground_blocks']).toHaveLength(1);
  });

  it('unblockUser 删除 block 记录', async () => {
    await blockUser(makeReq({ targetAppUserId: 'app-target' }, 'user-a'));
    const result = await unblockUser(
      makeReq({ targetAppUserId: 'app-target' }, 'user-a'),
    );
    expect(result.unblocked).toBe(true);

    const store = dumpStore();
    expect(store['playground_blocks']).toHaveLength(0);
  });

  it('sendDmRequest 给自己 → 拒绝', async () => {
    const myIdentity = await resolveMyIdentity(makeReq({}, 'user-a'));
    await expect(
      sendDmRequest(
        makeReq(
          { targetAppUserId: myIdentity.appUserId, initialMessage: 'hi' },
          'user-a',
        ),
      ),
    ).rejects.toThrow(HttpsError);
  });

  it('blockUser 未认证 → 拒绝', async () => {
    await expect(
      blockUser(makeReq({ targetAppUserId: 'app-x' })),
    ).rejects.toThrow(HttpsError);
  });
});

describe('bookmarks 幂等（BLOCK-01）', () => {
  it('同 key 重放仅写一个收藏，并返回缓存结果', async () => {
    await seedPost('post-bookmark-1', 'user-b');
    const req = makeReq(
      { postId: 'post-bookmark-1', action: 'bookmark', idempotency_key: 'bookmark-key-1' },
      'user-a',
    );
    const first = await setBookmark(req);
    const replay = await setBookmark(req);

    expect(replay).toEqual(first);
    expect(dumpStore()['playground_bookmarks']).toHaveLength(1);
  });

  it('同 key 不同 payload 拒绝', async () => {
    await seedPost('post-bookmark-2', 'user-b');
    await setBookmark(makeReq(
      { postId: 'post-bookmark-2', action: 'bookmark', idempotency_key: 'bookmark-key-2' },
      'user-a',
    ));
    await expect(setBookmark(makeReq(
      { postId: 'post-bookmark-2', action: 'unbookmark', idempotency_key: 'bookmark-key-2' },
      'user-a',
    ))).rejects.toThrow(HttpsError);
  });
});
