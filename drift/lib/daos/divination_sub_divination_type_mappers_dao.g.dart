// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'divination_sub_divination_type_mappers_dao.dart';

// ignore_for_file: type=lint
mixin _$DivinationSubDivinationTypeMappersDaoMixin
    on DatabaseAccessor<PersistenceDriftDatabase> {
  $DivinationTypesTable get divinationTypes => attachedDatabase.divinationTypes;
  $SubDivinationTypesTable get subDivinationTypes =>
      attachedDatabase.subDivinationTypes;
  $DivinationSubDivinationTypeMappersTable
      get divinationSubDivinationTypeMappers =>
          attachedDatabase.divinationSubDivinationTypeMappers;
  DivinationSubDivinationTypeMappersDaoManager get managers =>
      DivinationSubDivinationTypeMappersDaoManager(this);
}

class DivinationSubDivinationTypeMappersDaoManager {
  final _$DivinationSubDivinationTypeMappersDaoMixin _db;
  DivinationSubDivinationTypeMappersDaoManager(this._db);
  $$DivinationTypesTableTableManager get divinationTypes =>
      $$DivinationTypesTableTableManager(
          _db.attachedDatabase, _db.divinationTypes);
  $$SubDivinationTypesTableTableManager get subDivinationTypes =>
      $$SubDivinationTypesTableTableManager(
          _db.attachedDatabase, _db.subDivinationTypes);
  $$DivinationSubDivinationTypeMappersTableTableManager
      get divinationSubDivinationTypeMappers =>
          $$DivinationSubDivinationTypeMappersTableTableManager(
              _db.attachedDatabase, _db.divinationSubDivinationTypeMappers);
}
