// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combined_divinations_dao.dart';

// ignore_for_file: type=lint
mixin _$CombinedDivinationsDaoMixin
    on DatabaseAccessor<PersistenceDriftDatabase> {
  $CombinedDivinationsTable get combinedDivinations =>
      attachedDatabase.combinedDivinations;
  CombinedDivinationsDaoManager get managers =>
      CombinedDivinationsDaoManager(this);
}

class CombinedDivinationsDaoManager {
  final _$CombinedDivinationsDaoMixin _db;
  CombinedDivinationsDaoManager(this._db);
  $$CombinedDivinationsTableTableManager get combinedDivinations =>
      $$CombinedDivinationsTableTableManager(
        _db.attachedDatabase,
        _db.combinedDivinations,
      );
}
