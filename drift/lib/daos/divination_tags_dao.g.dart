// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'divination_tags_dao.dart';

// ignore_for_file: type=lint
mixin _$DivinationTagsDaoMixin on DatabaseAccessor<PersistenceDriftDatabase> {
  $DivinationTagsTable get divinationTags => attachedDatabase.divinationTags;
  DivinationTagsDaoManager get managers => DivinationTagsDaoManager(this);
}

class DivinationTagsDaoManager {
  final _$DivinationTagsDaoMixin _db;
  DivinationTagsDaoManager(this._db);
  $$DivinationTagsTableTableManager get divinationTags =>
      $$DivinationTagsTableTableManager(
          _db.attachedDatabase, _db.divinationTags);
}
