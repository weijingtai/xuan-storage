// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_template_setting_dao.dart';

// ignore_for_file: type=lint
mixin _$CardTemplateSettingDaoMixin on DatabaseAccessor<AppDatabase> {
  $CardTemplateSettingsTable get cardTemplateSettings =>
      attachedDatabase.cardTemplateSettings;
  CardTemplateSettingDaoManager get managers =>
      CardTemplateSettingDaoManager(this);
}

class CardTemplateSettingDaoManager {
  final _$CardTemplateSettingDaoMixin _db;
  CardTemplateSettingDaoManager(this._db);
  $$CardTemplateSettingsTableTableManager get cardTemplateSettings =>
      $$CardTemplateSettingsTableTableManager(
          _db.attachedDatabase, _db.cardTemplateSettings);
}
