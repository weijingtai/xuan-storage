import 'package:drift/drift.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
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

  Future<AccountIdentityLink?> getByAnonymousUserId(
    AccountUserId anonymousId,
  ) async {
    final row =
        await (_db.select(_db.accountIdentityLinks)
              ..where((t) => t.anonymousAppUserId.equals(anonymousId.value)))
            .getSingleOrNull();
    if (row == null) return null;
    return _toDomain(row);
  }

  Future<AccountIdentityLink?> getByRegisteredUserId(
    AccountUserId registeredId,
  ) async {
    final rows = await (_db.select(
      _db.accountIdentityLinks,
    )..where((t) => t.registeredAppUserId.equals(registeredId.value))).get();
    if (rows.isEmpty) return null;
    return _toDomain(rows.first);
  }

  Future<void> saveLink(AccountIdentityLink link) async {
    // Conflict detection: if a link already exists for this anonymous user
    // with a DIFFERENT registered user, throw instead of silently overwriting.
    final existing = await getByAnonymousUserId(link.anonymousAppUserId);
    if (existing != null &&
        existing.registeredAppUserId != link.registeredAppUserId) {
      throw AccountRepositoryError(
        code: AccountErrorCode.identityMappingConflict,
        message:
            'Identity link conflict: anonymous ${link.anonymousAppUserId.value} '
            'already linked to ${existing.registeredAppUserId.value}, '
            'cannot overwrite with ${link.registeredAppUserId.value}',
      );
    }

    await _db
        .into(_db.accountIdentityLinks)
        .insertOnConflictUpdate(
          AccountIdentityLinksCompanion.insert(
            anonymousAppUserId: link.anonymousAppUserId.value,
            registeredAppUserId: link.registeredAppUserId.value,
            providerId: link.providerId,
            linkedAt: link.linkedAt,
            mergeStatus: Value(link.mergeStatus.name),
          ),
        );
  }

  // ── L0 切片：Readable / Writable / Queryable / Transactional ──
  //
  // id 语义取匿名 appUserId 字符串（表内唯一键）。

  @override
  Future<Result<AccountIdentityLink?>> get(
    String id,
    RequestContext ctx,
  ) async {
    try {
      final link = await getByAnonymousUserId(AccountUserId(id));
      return Ok(link);
    } catch (e) {
      return Err(
        XuanError(
          code: ErrorCode.internal,
          message: 'identity link get failed: $e',
        ),
      );
    }
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async {
    final r = await get(id, ctx);
    return switch (r) {
      Ok(:final value) => Ok(value != null),
      Err(:final error) => Err(error),
    };
  }

  @override
  Future<Result<Rev>> put(
    AccountIdentityLink entity,
    RequestContext ctx, {
    Precondition pre = const Unconditional(),
  }) async {
    try {
      final existing = await getByAnonymousUserId(entity.anonymousAppUserId);
      if (existing != null &&
          existing.registeredAppUserId != entity.registeredAppUserId) {
        return const Err(
          XuanError(
            code: ErrorCode.conflictUnique,
            message: 'identity link already bound to another registered user',
          ),
        );
      }
      await _db
          .into(_db.accountIdentityLinks)
          .insertOnConflictUpdate(
            AccountIdentityLinksCompanion.insert(
              anonymousAppUserId: entity.anonymousAppUserId.value,
              registeredAppUserId: entity.registeredAppUserId.value,
              providerId: entity.providerId,
              linkedAt: entity.linkedAt,
              mergeStatus: Value(entity.mergeStatus.name),
            ),
          );
      return Ok(Rev(entity.anonymousAppUserId.value));
    } catch (e) {
      return Err(
        XuanError(
          code: ErrorCode.internal,
          message: 'identity link put failed: $e',
        ),
      );
    }
  }

  @override
  Future<Result<Page<AccountIdentityLink>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    try {
      final all = await _queryAll(spec);
      final start = page.cursor == null ? 0 : int.parse(page.cursor!);
      final end = (start + page.limit).clamp(0, all.length);
      final items = all.sublist(start, end);
      final hasMore = end < all.length;
      return Ok(
        Page<AccountIdentityLink>(
          items: items,
          nextCursor: hasMore ? '$end' : null,
        ),
      );
    } catch (e) {
      return Err(
        XuanError(
          code: ErrorCode.internal,
          message: 'identity link query failed: $e',
        ),
      );
    }
  }

  @override
  Future<Result<int>> count(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) async {
    try {
      return Ok(await _queryAll(spec).then((v) => v.length));
    } catch (e) {
      return Err(
        XuanError(
          code: ErrorCode.internal,
          message: 'identity link count failed: $e',
        ),
      );
    }
  }

  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async {
    try {
      final result = await _db.transaction(() => body());
      return Ok(result);
    } catch (e) {
      return Err(
        XuanError(
          code: ErrorCode.internal,
          message: 'identity link transaction failed: $e',
        ),
      );
    }
  }

  /// 按 spec 等值过滤全部链路（游标用偏移量字符串表达）。
  Future<List<AccountIdentityLink>> _queryAll(Map<String, Object?> spec) async {
    final query = _db.select(_db.accountIdentityLinks);
    if (spec case {'anonymousAppUserId': final String v}) {
      query.where((t) => t.anonymousAppUserId.equals(v));
    }
    if (spec case {'registeredAppUserId': final String v}) {
      query.where((t) => t.registeredAppUserId.equals(v));
    }
    if (spec case {'providerId': final String v}) {
      query.where((t) => t.providerId.equals(v));
    }
    final rows = await query.get();
    return rows.map(_toDomain).toList();
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
