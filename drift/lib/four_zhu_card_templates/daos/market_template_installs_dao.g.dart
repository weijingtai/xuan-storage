// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_template_installs_dao.dart';

// ignore_for_file: type=lint
mixin _$MarketTemplateInstallsDaoMixin on DatabaseAccessor<AppDatabase> {
  $MarketTemplateInstallsTable get marketTemplateInstalls =>
      attachedDatabase.marketTemplateInstalls;
  MarketTemplateInstallsDaoManager get managers =>
      MarketTemplateInstallsDaoManager(this);
}

class MarketTemplateInstallsDaoManager {
  final _$MarketTemplateInstallsDaoMixin _db;
  MarketTemplateInstallsDaoManager(this._db);
  $$MarketTemplateInstallsTableTableManager get marketTemplateInstalls =>
      $$MarketTemplateInstallsTableTableManager(
          _db.attachedDatabase, _db.marketTemplateInstalls);
}
