/**
 * BLOCK-03 游客代表性回复 callable。
 *
 * 设计（PHASE-5-DISPATCH §3）：
 * - 受信服务端确定性选择：排序键 `[isVerified desc, likeCount desc, createdAt asc,
 *   replyId asc]`，无任何随机/时间戳抖动——同一数据快照 + 同一 limit/policyVersion
 *   必须返回完全相同 ID 顺序（spec Scenario 4）。
 * - 允许未认证（`request.auth == null`）：游客的完整回复读取走 callable；
 *   客户端直连 `playground_replies` 仍被 Rules 拒绝（第一道反绕过闸）。
 * - limit 服务端 clamp 到 [5,10]；忽略 cursor/page/offset/sort 等任何额外参数。
 * - 公开 DTO 不含 `author_provider_uid`/`author_app_user_id`/`presentation_identity_id`
 *   等敏感字段；tombstone 不入 visible/total。
 */

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as crypto from 'crypto';
import { db, COLLECTIONS } from './index';

export const SELECTION_POLICY_VERSION = 1;
export const MIN_GUEST_LIMIT = 5;
export const MAX_GUEST_LIMIT = 10;

/** 展示用匿名 ID 派生：基于 provider uid 的稳定哈希，不暴露原始 uid。 */
function derivePresentationId(providerUid: unknown): string {
  const raw =
    typeof providerUid === 'string' && providerUid.length > 0
      ? providerUid
      : 'anonymous';
  return `anon_${crypto.createHash('sha256').update(raw).digest('hex').slice(0, 8)}`;
}

/** 归一化 created_at/updated_at → ISO 字符串；Timestamp/Date/string 均可。 */
function toIsoString(v: unknown): string | null {
  if (v === null || v === undefined) return null;
  if (v instanceof Date) return v.toISOString();
  if (typeof v === 'string') return v;
  if (typeof (v as any).toDate === 'function') {
    const d = (v as any).toDate();
    return d instanceof Date ? d.toISOString() : null;
  }
  return null;
}

/** 时间戳毫秒；缺失 → 最大（asc 排序时排最后），由 replyId 做最终 tie-break。 */
function toMs(v: unknown): number {
  const iso = toIsoString(v);
  if (!iso) return Number.MAX_SAFE_INTEGER;
  const ms = Date.parse(iso);
  return Number.isNaN(ms) ? Number.MAX_SAFE_INTEGER : ms;
}

/** isVerified = reply.verification 非空（verifyRootReply 写入的应验事实）。 */
function isVerified(d: Record<string, any>): boolean {
  const v = d.verification;
  return v !== null && v !== undefined && typeof v === 'object';
}

/** 公开 chart 投影：只取公开字段，忽略内部字段。 */
function toPublicChart(chart: any): any {
  if (!chart || typeof chart !== 'object') return null;
  if (chart.type !== undefined && chart.type !== 'xuanChart') return null;
  return {
    techniqueId: typeof chart.technique_id === 'string' ? chart.technique_id : 'unknown',
    schoolId: typeof chart.school_id === 'string' ? chart.school_id : null,
    publicChartSnapshot:
      typeof chart.public_chart_snapshot === 'string' ? chart.public_chart_snapshot : '',
    rendererSchemaVersion:
      typeof chart.renderer_schema_version === 'number' ? chart.renderer_schema_version : 1,
    source: typeof chart.chart_source === 'string' ? chart.chart_source : 'createdInPlayground',
  };
}

/** 公开媒体投影：只含安全 URL/token、mime、尺寸；禁止内部存储路径。 */
function toPublicMediaAttachments(list: any): any[] {
  if (!Array.isArray(list)) return [];
  return list
    .filter(
      (m) =>
        m &&
        typeof m === 'object' &&
        (m.type === 'image' || m.type === 'video'),
    )
    .map((m) => ({
      type: m.type,
      mediaObjectId:
        typeof m.media_object_id === 'string' ? m.media_object_id : 'unknown',
      mimeType: typeof m.mime_type === 'string' ? m.mime_type : '',
      width: typeof m.width === 'number' ? m.width : null,
      height: typeof m.height === 'number' ? m.height : null,
      durationSeconds:
        typeof m.duration_seconds === 'number' ? m.duration_seconds : null,
      secureUrl: `/public/media/${
        typeof m.media_object_id === 'string' ? m.media_object_id : 'unknown'
      }`,
    }));
}

/** 公开 revision 摘要：只返回最新一条元数据，不返回全文。 */
function toPublicRevisionSummary(revisions: any): any {
  if (!Array.isArray(revisions) || revisions.length === 0) return null;
  const last = revisions[revisions.length - 1];
  if (!last || typeof last !== 'object') return null;
  return {
    editedByAlias:
      typeof last.edited_by === 'string' ? last.edited_by : '未知',
    editedAt:
      toIsoString(last.edited_at) ?? '1970-01-01T00:00:00.000Z',
    changeDescription:
      typeof last.change_description === 'string' ? last.change_description : null,
  };
}

/** 公开作者投影：公开展示 ID + 展示别名；无 canonical appUserId / provider uid。 */
function toPublicAuthor(d: Record<string, any>): any {
  const presentationId =
    typeof d.presentation_identity_id === 'string' && d.presentation_identity_id.length > 0
      ? d.presentation_identity_id
      : derivePresentationId(d.author_provider_uid);
  const short = presentationId.slice(-6);
  return {
    publicPresentationUserId: presentationId,
    displayAlias: `盘友${short}`,
    avatarUrl: null,
    publicProfileRef: null,
  };
}

/** PublicReply JSON（键名 = Dart DTO 字段名约定，PHASE-5-DISPATCH §3.2）。 */
function toPublicReply(replyId: string, d: Record<string, any>): any {
  return {
    publicReplyId: replyId,
    postId: typeof d.post_id === 'string' ? d.post_id : '',
    body: typeof d.body === 'string' ? d.body : '',
    techniqueTags: Array.isArray(d.technique_tags) ? d.technique_tags : [],
    chart: toPublicChart(d.chart_attachment),
    mediaAttachments: toPublicMediaAttachments(d.media_attachments),
    author: toPublicAuthor(d),
    depth: typeof d.depth === 'number' ? d.depth : 0,
    rootReplyId: typeof d.root_reply_id === 'string' ? d.root_reply_id : null,
    replyToReplyId:
      typeof d.reply_to_reply_id === 'string' ? d.reply_to_reply_id : null,
    isVerified: isVerified(d),
    isTombstoned: false,
    presentationMode: 'stableAlias',
    createdAt: toIsoString(d.created_at) ?? '1970-01-01T00:00:00.000Z',
    updatedAt: toIsoString(d.updated_at),
    latestRevision: toPublicRevisionSummary(d.revisions),
  };
}

/** 取该 post 最新的有效最终反馈（deleted_at==null）；无 → null。游客保持可见。 */
async function loadOutcomeFeedback(postId: string): Promise<any | null> {
  const snaps = await db
    .collection(COLLECTIONS.outcomeFeedback)
    .where('post_id', '==', postId)
    .get();
  const active = snaps.docs
    .map((doc) => ({ id: doc.id, data: doc.data() ?? {} }))
    .filter((x) => x.data.deleted_at === null || x.data.deleted_at === undefined);
  if (active.length === 0) return null;

  active.sort((a, b) => {
    const aMs = toMs(a.data.created_at);
    const bMs = toMs(b.data.created_at);
    if (aMs !== bMs) return bMs - aMs; // 最新在前
    return a.id < b.id ? 1 : a.id > b.id ? -1 : 0;
  });

  const latest = active[0].data;
  const publishedAt =
    toIsoString(latest.created_at) ?? '1970-01-01T00:00:00.000Z';
  const updatedAt = toIsoString(latest.updated_at);
  return {
    body:
      typeof latest.outcome_description === 'string'
        ? latest.outcome_description
        : '',
    isEdited: updatedAt !== null && updatedAt !== publishedAt,
    publishedAt,
    updatedAt,
  };
}

export const getGuestRepresentativeReplies = onCall(
  { region: 'asia-east1' },
  async (request) => {
    // 游客 callable：允许 request.auth == null（不调用 requireAuthUid）。

    const data = (request.data ?? {}) as Record<string, any>;

    // 入参白名单：只取 postId / limit / selectionPolicyVersion；
    // cursor/page/offset/sort 等任何额外参数一律忽略（反绕过）。
    const postId = data.postId;
    if (typeof postId !== 'string' || postId.trim().length === 0) {
      throw new HttpsError('invalid-argument', 'postId 不能为空');
    }

    // limit：服务端 clamp 到 [5,10]；非法/缺省 → 5。
    let limit = MIN_GUEST_LIMIT;
    if (typeof data.limit === 'number' && Number.isInteger(data.limit)) {
      limit = Math.min(MAX_GUEST_LIMIT, Math.max(MIN_GUEST_LIMIT, data.limit));
    }

    // selectionPolicyVersion：仅支持 1；未知版本 → invalid-argument；缺省 → 1。
    const policyVersion =
      data.selectionPolicyVersion === undefined ||
      data.selectionPolicyVersion === null
        ? SELECTION_POLICY_VERSION
        : data.selectionPolicyVersion;
    if (
      typeof policyVersion !== 'number' ||
      policyVersion !== SELECTION_POLICY_VERSION
    ) {
      throw new HttpsError(
        'invalid-argument',
        `不支持的 selectionPolicyVersion: ${String(policyVersion)}`,
      );
    }

    const postSnap = await db.collection(COLLECTIONS.posts).doc(postId).get();
    if (!postSnap.exists || postSnap.get('status') !== 'active') {
      throw new HttpsError('not-found', '帖子不存在或已失效');
    }

    // root replies（depth==0）；tombstone 在内存过滤，不入 total/visible。
    const rootsSnap = await db
      .collection(COLLECTIONS.replies)
      .where('post_id', '==', postId)
      .where('depth', '==', 0)
      .get();

    const candidates: Array<{ id: string; data: Record<string, any>; createdAtMs: number }> =
      [];
    for (const doc of rootsSnap.docs) {
      const d = doc.data() ?? {};
      if (d.is_tombstoned === true) continue;
      candidates.push({ id: doc.id, data: d, createdAtMs: toMs(d.created_at) });
    }

    // likes 计数：playground_likes 按 reply_id count（真实 Admin SDK 查询）。
    const likeCounts = new Map<string, number>();
    for (const c of candidates) {
      const likeSnap = await db
        .collection(COLLECTIONS.likes)
        .where('reply_id', '==', c.id)
        .get();
      likeCounts.set(c.id, likeSnap.size);
    }

    // 确定性选择（policy v1）：
    // [isVerified desc, likeCount desc, createdAt asc, replyId asc]。
    const sorted = [...candidates].sort((a, b) => {
      const aVerified = isVerified(a.data);
      const bVerified = isVerified(b.data);
      if (aVerified !== bVerified) return aVerified ? -1 : 1;
      const aLikes = likeCounts.get(a.id) ?? 0;
      const bLikes = likeCounts.get(b.id) ?? 0;
      if (aLikes !== bLikes) return bLikes - aLikes;
      if (a.createdAtMs !== b.createdAtMs) return a.createdAtMs - b.createdAtMs;
      return a.id < b.id ? -1 : a.id > b.id ? 1 : 0;
    });

    const visible = sorted.slice(0, Math.min(limit, sorted.length));
    const totalReplyCount = candidates.length;
    const hiddenReplyCount = Math.max(0, totalReplyCount - visible.length);

    const outcomeFeedback = await loadOutcomeFeedback(postId);

    return {
      postId,
      visibleReplies: visible.map((c) => toPublicReply(c.id, c.data)),
      totalReplyCount,
      hiddenReplyCount,
      selectionPolicyVersion: policyVersion,
      registrationUnlock: {
        requiresRegistration: true,
        ctaMessageKey: 'register_to_unlock_replies',
        unlockRoute: '/register',
      },
      outcomeFeedback,
    };
  },
);
