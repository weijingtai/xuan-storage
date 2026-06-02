// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layout_templates_dao.dart';

// ignore_for_file: type=lint
mixin _$LayoutTemplatesDaoMixin on DatabaseAccessor<AppDatabase> {
  $LayoutTemplatesTable get layoutTemplates => attachedDatabase.layoutTemplates;
  LayoutTemplatesDaoManager get managers => LayoutTemplatesDaoManager(this);
}

class LayoutTemplatesDaoManager {
  final _$LayoutTemplatesDaoMixin _db;
  LayoutTemplatesDaoManager(this._db);
  $$LayoutTemplatesTableTableManager get layoutTemplates =>
      $$LayoutTemplatesTableTableManager(
          _db.attachedDatabase, _db.layoutTemplates);
}
