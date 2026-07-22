// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combined_divinations_dao.dart';

// ignore_for_file: type=lint
mixin _$CombinedDivinationsDaoMixin
    on DatabaseAccessor<PersistenceDriftDatabase> {
  $SeekersTable get seekers => attachedDatabase.seekers;
  $DivinationsTable get divinations => attachedDatabase.divinations;
  $CombinedDivinationsTable get combinedDivinations =>
      attachedDatabase.combinedDivinations;
  CombinedDivinationsDaoManager get managers =>
      CombinedDivinationsDaoManager(this);
}

class CombinedDivinationsDaoManager {
  final _$CombinedDivinationsDaoMixin _db;
  CombinedDivinationsDaoManager(this._db);
  $$SeekersTableTableManager get seekers =>
      $$SeekersTableTableManager(_db.attachedDatabase, _db.seekers);
  $$DivinationsTableTableManager get divinations =>
      $$DivinationsTableTableManager(_db.attachedDatabase, _db.divinations);
  $$CombinedDivinationsTableTableManager get combinedDivinations =>
      $$CombinedDivinationsTableTableManager(
          _db.attachedDatabase, _db.combinedDivinations);
}
