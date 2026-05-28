// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'divination_types_dao.dart';

// ignore_for_file: type=lint
mixin _$DivinationTypesDaoMixin on DatabaseAccessor<PersistenceDriftDatabase> {
  $DivinationTypesTable get divinationTypes => attachedDatabase.divinationTypes;
  DivinationTypesDaoManager get managers => DivinationTypesDaoManager(this);
}

class DivinationTypesDaoManager {
  final _$DivinationTypesDaoMixin _db;
  DivinationTypesDaoManager(this._db);
  $$DivinationTypesTableTableManager get divinationTypes =>
      $$DivinationTypesTableTableManager(
          _db.attachedDatabase, _db.divinationTypes);
}
