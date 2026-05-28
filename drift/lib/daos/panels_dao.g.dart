// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'panels_dao.dart';

// ignore_for_file: type=lint
mixin _$PanelsDaoMixin on DatabaseAccessor<PersistenceDriftDatabase> {
  $PanelsTable get panels => attachedDatabase.panels;
  PanelsDaoManager get managers => PanelsDaoManager(this);
}

class PanelsDaoManager {
  final _$PanelsDaoMixin _db;
  PanelsDaoManager(this._db);
  $$PanelsTableTableManager get panels =>
      $$PanelsTableTableManager(_db.attachedDatabase, _db.panels);
}
