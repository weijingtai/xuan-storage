// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playground_post_cache_store.dart';

// ignore_for_file: type=lint
mixin _$DriftPlaygroundPostCacheStoreMixin
    on DatabaseAccessor<PersistenceDriftDatabase> {
  $PlaygroundPostCachesTable get playgroundPostCaches =>
      attachedDatabase.playgroundPostCaches;
  DriftPlaygroundPostCacheStoreManager get managers =>
      DriftPlaygroundPostCacheStoreManager(this);
}

class DriftPlaygroundPostCacheStoreManager {
  final _$DriftPlaygroundPostCacheStoreMixin _db;
  DriftPlaygroundPostCacheStoreManager(this._db);
  $$PlaygroundPostCachesTableTableManager get playgroundPostCaches =>
      $$PlaygroundPostCachesTableTableManager(
        _db.attachedDatabase,
        _db.playgroundPostCaches,
      );
}
