// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_template_skill_usage_dao.dart';

// ignore_for_file: type=lint
mixin _$CardTemplateSkillUsageDaoMixin on DatabaseAccessor<AppDatabase> {
  $CardTemplateSkillUsagesTable get cardTemplateSkillUsages =>
      attachedDatabase.cardTemplateSkillUsages;
  CardTemplateSkillUsageDaoManager get managers =>
      CardTemplateSkillUsageDaoManager(this);
}

class CardTemplateSkillUsageDaoManager {
  final _$CardTemplateSkillUsageDaoMixin _db;
  CardTemplateSkillUsageDaoManager(this._db);
  $$CardTemplateSkillUsagesTableTableManager get cardTemplateSkillUsages =>
      $$CardTemplateSkillUsagesTableTableManager(
          _db.attachedDatabase, _db.cardTemplateSkillUsages);
}
