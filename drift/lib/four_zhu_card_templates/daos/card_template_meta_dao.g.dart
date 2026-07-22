// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_template_meta_dao.dart';

// ignore_for_file: type=lint
mixin _$CardTemplateMetaDaoMixin on DatabaseAccessor<AppDatabase> {
  $CardTemplateMetasTable get cardTemplateMetas =>
      attachedDatabase.cardTemplateMetas;
  CardTemplateMetaDaoManager get managers => CardTemplateMetaDaoManager(this);
}

class CardTemplateMetaDaoManager {
  final _$CardTemplateMetaDaoMixin _db;
  CardTemplateMetaDaoManager(this._db);
  $$CardTemplateMetasTableTableManager get cardTemplateMetas =>
      $$CardTemplateMetasTableTableManager(
          _db.attachedDatabase, _db.cardTemplateMetas);
}
