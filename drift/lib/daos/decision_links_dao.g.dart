// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decision_links_dao.dart';

// ignore_for_file: type=lint
mixin _$DecisionLinksDaoMixin on DatabaseAccessor<PersistenceDriftDatabase> {
  $DecisionLinksTable get decisionLinks => attachedDatabase.decisionLinks;
  DecisionLinksDaoManager get managers => DecisionLinksDaoManager(this);
}

class DecisionLinksDaoManager {
  final _$DecisionLinksDaoMixin _db;
  DecisionLinksDaoManager(this._db);
  $$DecisionLinksTableTableManager get decisionLinks =>
      $$DecisionLinksTableTableManager(_db.attachedDatabase, _db.decisionLinks);
}
