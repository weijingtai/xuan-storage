// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'divination_panel_mappers_dao.dart';

// ignore_for_file: type=lint
mixin _$DivinationPanelMappersDaoMixin
    on DatabaseAccessor<PersistenceDriftDatabase> {
  $DivinationPanelMappersTable get divinationPanelMappers =>
      attachedDatabase.divinationPanelMappers;
  DivinationPanelMappersDaoManager get managers =>
      DivinationPanelMappersDaoManager(this);
}

class DivinationPanelMappersDaoManager {
  final _$DivinationPanelMappersDaoMixin _db;
  DivinationPanelMappersDaoManager(this._db);
  $$DivinationPanelMappersTableTableManager get divinationPanelMappers =>
      $$DivinationPanelMappersTableTableManager(
          _db.attachedDatabase, _db.divinationPanelMappers);
}
