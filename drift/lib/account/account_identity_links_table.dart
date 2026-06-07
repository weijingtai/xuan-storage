import 'package:drift/drift.dart';

/// Drift table for anonymous appUserId → registered appUserId links.
///
/// Per HIGH-2 this is semantically separate from Firestore `identity_map`
/// (provider UID → appUserId). This table stores only app-user-id-to-app-user-id
/// links and contains no provider UID column.
@DataClassName('AccountIdentityLinkEntry')
class AccountIdentityLinks extends Table {
  @override
  String get tableName => 'account_identity_links';

  TextColumn get anonymousAppUserId => text().named('anonymous_app_user_id')();
  TextColumn get registeredAppUserId => text().named('registered_app_user_id')();
  TextColumn get providerId => text().named('provider_id')();
  DateTimeColumn get linkedAt => dateTime().named('linked_at')();
  TextColumn get mergeStatus => text()
      .withLength(min: 4, max: 20)
      .named('merge_status')
      .withDefault(const Constant('linked'))();

  @override
  Set<Column> get primaryKey => {anonymousAppUserId};
}
