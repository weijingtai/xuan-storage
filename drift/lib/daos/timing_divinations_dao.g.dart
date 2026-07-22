// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timing_divinations_dao.dart';

// ignore_for_file: type=lint
mixin _$TimingDivinationsDaoMixin
    on DatabaseAccessor<PersistenceDriftDatabase> {
  $TimingDivinationsTable get timingDivinations =>
      attachedDatabase.timingDivinations;
  TimingDivinationsDaoManager get managers => TimingDivinationsDaoManager(this);
}

class TimingDivinationsDaoManager {
  final _$TimingDivinationsDaoMixin _db;
  TimingDivinationsDaoManager(this._db);
  $$TimingDivinationsTableTableManager get timingDivinations =>
      $$TimingDivinationsTableTableManager(
          _db.attachedDatabase, _db.timingDivinations);
}
