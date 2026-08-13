import { readFileSync } from 'fs';
import { resolve } from 'path';

const indexes = JSON.parse(readFileSync(resolve(__dirname, '../../firestore.indexes.json'), 'utf8'));

function hasIndex(collection: string, fields: string[]) {
  return indexes.indexes.some((index: any) =>
    index.collectionGroup === collection &&
    index.fields.map((field: any) => field.fieldPath).join('|') === fields.join('|'));
}

function hasArrayContainsIndex(collection: string, fields: string[], arrayField: string) {
  return indexes.indexes.some((index: any) => {
    if (index.collectionGroup !== collection) return false;
    const paths = index.fields.map((f: any) => f.fieldPath);
    const configs = index.fields.map((f: any) => f.arrayConfig ?? 'ORDER');
    if (paths.join('|') !== fields.join('|')) return false;
    return configs[fields.indexOf(arrayField)] === 'CONTAINS';
  });
}

describe('Firestore composite index contract (Design §10.2, direct-write v1)', () => {
  test('6 current-phase composites exist verbatim', () => {
    // posts ×2（无/含 technique）
    expect(hasIndex('playground_posts', ['status', 'created_at'])).toBe(true);
    expect(hasArrayContainsIndex('playground_posts', ['status', 'allowed_chart_technique_ids', 'created_at'], 'allowed_chart_technique_ids')).toBe(true);
    // replies ×1
    expect(hasIndex('playground_replies', ['post_id', 'is_tombstoned', 'created_at'])).toBe(true);
    // verifications ×2
    expect(hasIndex('playground_verifications', ['post_id', 'root_reply_id', 'revoked_at', 'created_at'])).toBe(true);
    expect(hasIndex('playground_verifications', ['post_id', 'revoked_at'])).toBe(true);
    // bookmarks ×1
    expect(hasIndex('playground_bookmarks', ['user_provider_uid', 'created_at'])).toBe(true);
  });

  test('old playground_likes composite (post_id+user_provider_uid) removed', () => {
    expect(hasIndex('playground_likes', ['post_id', 'user_provider_uid'])).toBe(false);
    const likes = indexes.indexes.filter((i: any) => i.collectionGroup === 'playground_likes');
    expect(likes).toHaveLength(0);
  });

  test('old author_app_user_id profile indexes not in current phase', () => {
    const posts = indexes.indexes.filter((i: any) => i.collectionGroup === 'playground_posts')
      .flatMap((i: any) => i.fields.map((f: any) => f.fieldPath));
    const replies = indexes.indexes.filter((i: any) => i.collectionGroup === 'playground_replies')
      .flatMap((i: any) => i.fields.map((f: any) => f.fieldPath));
    expect(posts).not.toContain('author_app_user_id');
    expect(replies).not.toContain('author_app_user_id');
  });
});
