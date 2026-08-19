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
    await db.divinationTagsDao.clearForDivination('div-2', scopeUid: 'user-y');
    final ids = await db.divinationTagsDao.findDivinationUuids(
      scopeUid: 'user-y',
      domain: 'liu_ren',
      tagKey: 'tian_pan',
      tagValue: '贵人',
    );
    expect(ids, isEmpty);
  });

  test('divination_tags: clearForDivination 不应跨 scope 删除别人的标签', () async {
    // scope-x 和 scope-y 各有一条 tag（相同 divinationUuid）
    await db.divinationTagsDao.insertTags([
      DivinationTagsCompanion.insert(
        divinationUuid: 'div-shared',
        domain: 'qi_men',
        tagKey: 'yong_shen',
        tagValue: '值符',
        scopeUid: 'scope-x',
        createdAtMs: 3000,
      ),
      DivinationTagsCompanion.insert(
        divinationUuid: 'div-shared',
        domain: 'qi_men',
        tagKey: 'yong_shen',
        tagValue: '值符',
        scopeUid: 'scope-y',
        createdAtMs: 3001,
      ),
    ]);

    // 清除 scope-x 的 tag
    await db.divinationTagsDao.clearForDivination('div-shared', scopeUid: 'scope-x');

    // 验证 scope-x 的 tag 被删除
    final idsX = await db.divinationTagsDao.findDivinationUuids(
      scopeUid: 'scope-x',
      domain: 'qi_men',
      tagKey: 'yong_shen',
      tagValue: '值符',
    );
    expect(idsX, isEmpty, reason: 'scope-x 的 tag 应被删除');

    // 验证 scope-y 的 tag 仍然存在
    final idsY = await db.divinationTagsDao.findDivinationUuids(
      scopeUid: 'scope-y',
      domain: 'qi_men',
      tagKey: 'yong_shen',
      tagValue: '值符',
    );
    expect(idsY, contains('div-shared'), reason: 'scope-y 的 tag 不应被删除（越权）');
  });
}
