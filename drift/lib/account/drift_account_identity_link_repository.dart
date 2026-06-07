import 'package:drift/drift.dart';
import 'package:repository_interface_account/repository_interface_account.dart';

import 'account_database.dart';

/// Drift-backed [AccountIdentityLinkRepository].
///
/// Stores anonymous appUserId → registered appUserId links in the
/// `account_identity_links` table.
///
/// Per HIGH-2 this repository does NOT handle provider UID → appUserId
/// resolution (that's [AppUserIdResolver]'s job via `identity_map`).
final class DriftAccountIdentityLinkRepository
    implements AccountIdentityLinkRepository {
  DriftAccountIdentityLinkRepository(this._db);

  final AccountDatabase _db;

  @override
  Future<AccountIdentityLink?> getByAnonymousUserId(
    AccountUserId anonymousId,
  ) async {
    final row = await (_db.select(_db.accountIdentityLinks)
          ..where(
            (t) => t.anonymousAppUserId.equals(anonymousId.value),
          ))
        .getSingleOrNull();
    if (row == null) return null;
    return _toDomain(row);
  }

  @override
  Future<AccountIdentityLink?> getByRegisteredUserId(
    AccountUserId registeredId,
  ) async {
    final rows = await (_db.select(_db.accountIdentityLinks)
          ..where(
            (t) => t.registeredAppUserId.equals(registeredId.value),
          ))
        .get();
    if (rows.isEmpty) return null;
    return _toDomain(rows.first);
  }

  @override
  Future<void> saveLink(AccountIdentityLink link) async {
    await _db.into(_db.accountIdentityLinks).insertOnConflictUpdate(
          AccountIdentityLinksCompanion.insert(
            anonymousAppUserId: link.anonymousAppUserId.value,
            registeredAppUserId: link.registeredAppUserId.value,
            providerId: link.providerId,
            linkedAt: link.linkedAt,
            mergeStatus: Value(link.mergeStatus.name),
          ),
        );
  }

  AccountIdentityLink _toDomain(AccountIdentityLinkEntry row) {
    return AccountIdentityLink(
      anonymousAppUserId: AccountUserId(row.anonymousAppUserId),
      registeredAppUserId: AccountUserId(row.registeredAppUserId),
      providerId: row.providerId,
      linkedAt: row.linkedAt,
      mergeStatus: AccountIdentityLinkMergeStatus.values.firstWhere(
        (s) => s.name == row.mergeStatus,
        orElse: () => AccountIdentityLinkMergeStatus.linked,
      ),
    );
  }
}
