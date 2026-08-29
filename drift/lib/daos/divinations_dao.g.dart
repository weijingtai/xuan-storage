// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'divinations_dao.dart';

// ignore_for_file: type=lint
mixin _$DivinationsDaoMixin on DatabaseAccessor<PersistenceDriftDatabase> {
  $DivinationsTable get divinations => attachedDatabase.divinations;
  DivinationsDaoManager get managers => DivinationsDaoManager(this);
}

class DivinationsDaoManager {
  final _$DivinationsDaoMixin _db;
  DivinationsDaoManager(this._db);
  $$DivinationsTableTableManager get divinations =>
      $$DivinationsTableTableManager(_db.attachedDatabase, _db.divinations);
}
