// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playground_reply_cache_store.dart';

// ignore_for_file: type=lint
mixin _$DriftPlaygroundReplyCacheStoreMixin
    on DatabaseAccessor<PersistenceDriftDatabase> {
  $PlaygroundReplyCachesTable get playgroundReplyCaches =>
      attachedDatabase.playgroundReplyCaches;
  DriftPlaygroundReplyCacheStoreManager get managers =>
      DriftPlaygroundReplyCacheStoreManager(this);
}

class DriftPlaygroundReplyCacheStoreManager {
  final _$DriftPlaygroundReplyCacheStoreMixin _db;
  DriftPlaygroundReplyCacheStoreManager(this._db);
  $$PlaygroundReplyCachesTableTableManager get playgroundReplyCaches =>
      $$PlaygroundReplyCachesTableTableManager(
        _db.attachedDatabase,
        _db.playgroundReplyCaches,
      );
}
