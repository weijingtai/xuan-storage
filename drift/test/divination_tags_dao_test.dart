import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';

void main() {
  late PersistenceDriftDatabase db;
  setUp(() => db = PersistenceDriftDatabase(NativeDatabase.memory()));
  tearDown(() async => await db.close());

  test('divination_tags: insert + findDivinationUuids by composite key', () async {
    await db.divinationTagsDao.insertTags([
      DivinationTagsCompanion.insert(
        divinationUuid: 'div-1',
        domain: 'ba_zi',
        tagKey: 'day_gan',
        tagValue: '甲',
        scopeUid: 'user-x',
        createdAtMs: 1000,
      ),
    ]);
    final ids = await db.divinationTagsDao.findDivinationUuids(
      scopeUid: 'user-x',
      domain: 'ba_zi',
      tagKey: 'day_gan',
      tagValue: '甲',
    );
    expect(ids, contains('div-1'));
  });

  test('divination_tags: clearForDivination removes all tags', () async {
    await db.divinationTagsDao.insertTags([
      DivinationTagsCompanion.insert(
        divinationUuid: 'div-2',
        domain: 'liu_ren',
        tagKey: 'tian_pan',
        tagValue: '贵人',
        scopeUid: 'user-y',
        createdAtMs: 2000,
      ),
    ]);
    await db.divinationTagsDao.clearForDivination('div-2');
    final ids = await db.divinationTagsDao.findDivinationUuids(
      scopeUid: 'user-y',
      domain: 'liu_ren',
      tagKey: 'tian_pan',
      tagValue: '贵人',
    );
    expect(ids, isEmpty);
  });
}
