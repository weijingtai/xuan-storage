import { readFileSync } from 'fs';
import { resolve } from 'path';

const indexes = JSON.parse(readFileSync(resolve(__dirname, '../../firestore.indexes.json'), 'utf8'));

function hasIndex(fields: string[]) {
  return indexes.indexes.some((index: any) =>
    index.fields.map((field: any) => field.fieldPath).join('|') === fields.join('|'));
}

describe('Firestore composite index contract', () => {
  test('profile posts query has canonical author/status/presentation/time index', () => {
    expect(hasIndex(['author_app_user_id', 'status', 'presentation_mode', 'created_at'])).toBe(true);
  });

  test('profile replies query has canonical author/time index', () => {
    expect(hasIndex(['author_app_user_id', 'created_at'])).toBe(true);
  });
});
