// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seeker_divination_mappers_dao.dart';

// ignore_for_file: type=lint
mixin _$SeekerDivinationMappersDaoMixin
    on DatabaseAccessor<PersistenceDriftDatabase> {
  $SeekersTable get seekers => attachedDatabase.seekers;
  $DivinationsTable get divinations => attachedDatabase.divinations;
  $SeekerDivinationMappersTable get seekerDivinationMappers =>
      attachedDatabase.seekerDivinationMappers;
  SeekerDivinationMappersDaoManager get managers =>
      SeekerDivinationMappersDaoManager(this);
}

class SeekerDivinationMappersDaoManager {
  final _$SeekerDivinationMappersDaoMixin _db;
  SeekerDivinationMappersDaoManager(this._db);
  $$SeekersTableTableManager get seekers =>
      $$SeekersTableTableManager(_db.attachedDatabase, _db.seekers);
  $$DivinationsTableTableManager get divinations =>
      $$DivinationsTableTableManager(_db.attachedDatabase, _db.divinations);
  $$SeekerDivinationMappersTableTableManager get seekerDivinationMappers =>
      $$SeekerDivinationMappersTableTableManager(
          _db.attachedDatabase, _db.seekerDivinationMappers);
}
