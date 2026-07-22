import 'package:repository_interface_four_zhu_card/repository_interface_four_zhu_card.dart';

import 'daos/card_template_skill_usage_dao.dart';

class FourZhuCardTemplateUsageRecorderAdapter
    implements FourZhuCardTemplateUsageRecorder {
  FourZhuCardTemplateUsageRecorderAdapter(this._dao);

  final CardTemplateSkillUsageDao _dao;

  @override
  Future<void> insertUsage({
    required String queryUuid,
    required String templateUuid,
    required int skillId,
    required String usedAt,
  }) async {
    await _dao.insertUsage(
      queryUuid: queryUuid,
      templateUuid: templateUuid,
      skillId: skillId,
      usedAt: usedAt,
    );
  }

  @override
  Future<UsageRecord?> findLatestByQueryAndSkill({
    required String queryUuid,
    required int skillId,
  }) async {
    final row = await _dao.findLatestByQueryAndSkill(
      queryUuid: queryUuid,
      skillId: skillId,
    );
    if (row == null) return null;
    return UsageRecord(
      queryUuid: row.queryUuid,
      templateUuid: row.templateUuid,
      skillId: row.skillId,
      usedAt: row.usedAt,
    );
  }

  @override
  Future<List<UsageRecord>> findByTemplate({
    required String templateUuid,
    int? limit,
  }) async {
    final rows = await _dao.findByTemplate(
      templateUuid: templateUuid,
      limit: limit,
    );
    return rows
        .map(
          (row) => UsageRecord(
            queryUuid: row.queryUuid,
            templateUuid: row.templateUuid,
            skillId: row.skillId,
            usedAt: row.usedAt,
          ),
        )
        .toList(growable: false);
  }
}
