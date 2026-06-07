import 'package:drift/drift.dart';
import 'account_identity_links_table.dart';

part 'account_database.g.dart';

/// Drift database for account identity link storage.
@DriftDatabase(tables: [AccountIdentityLinks])
class AccountDatabase extends _$AccountDatabase {
  AccountDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}
