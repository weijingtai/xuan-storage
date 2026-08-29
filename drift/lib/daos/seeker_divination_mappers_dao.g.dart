// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seeker_divination_mappers_dao.dart';

// ignore_for_file: type=lint
mixin _$SeekerDivinationMappersDaoMixin
    on DatabaseAccessor<PersistenceDriftDatabase> {
  $SeekerDivinationMappersTable get seekerDivinationMappers =>
      attachedDatabase.seekerDivinationMappers;
  SeekerDivinationMappersDaoManager get managers =>
      SeekerDivinationMappersDaoManager(this);
}

class SeekerDivinationMappersDaoManager {
  final _$SeekerDivinationMappersDaoMixin _db;
  SeekerDivinationMappersDaoManager(this._db);
  $$SeekerDivinationMappersTableTableManager get seekerDivinationMappers =>
      $$SeekerDivinationMappersTableTableManager(
        _db.attachedDatabase,
        _db.seekerDivinationMappers,
      );
}
