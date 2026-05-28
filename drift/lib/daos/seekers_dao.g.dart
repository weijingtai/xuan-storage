// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seekers_dao.dart';

// ignore_for_file: type=lint
mixin _$SeekersDaoMixin on DatabaseAccessor<PersistenceDriftDatabase> {
  $SeekersTable get seekers => attachedDatabase.seekers;
  SeekersDaoManager get managers => SeekersDaoManager(this);
}

class SeekersDaoManager {
  final _$SeekersDaoMixin _db;
  SeekersDaoManager(this._db);
  $$SeekersTableTableManager get seekers =>
      $$SeekersTableTableManager(_db.attachedDatabase, _db.seekers);
}
