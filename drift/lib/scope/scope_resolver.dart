import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_account/repository_interface_account.dart';
import 'scope_handover.dart';
import 'scope_ledger.dart';
import 'scope_alias_entry.dart';

/// Scope 解析结果。
///
/// isUpgrade/isConflict 为 Phase 5+ 预留（冲突合并、epoch 重绑）。
/// Phase 2.5 的 DI 装配仅使用 scopeUid。
class ResolvedScope {
  const ResolvedScope({
    required this.scopeUid,
    required this.isUpgrade,
    required this.isConflict,
  });

  /// 解析出的 scope_uid，绝不为空。
  final String scopeUid;

  /// true = 这是一次升级 (匿名→注册，复用 device scope)。
  final bool isUpgrade;

  /// true = 这是一次真冲突 (登录已有账户，新铸 scope)。
  final bool isConflict;
}

/// 所有 scope 取值的唯一出口。
///
/// 空值在此一票否决——绝不返回空 scope_uid。
class ScopeResolver {
  ScopeResolver({
    required AccountSessionRepository sessionRepository,
    required AccountIdentityLinkRepository identityLinkRepository,
    required ScopeLedger ledger,
    required ScopeHandoverService handoverService,
  }) : _sessionRepository = sessionRepository,
       _identityLinkRepository = identityLinkRepository,
       _ledger = ledger,
       _handoverService = handoverService;

  final AccountSessionRepository _sessionRepository;
  final AccountIdentityLinkRepository _identityLinkRepository;
  final ScopeLedger _ledger;
  final ScopeHandoverService _handoverService;

  /// 解析当前 session 对应的 scope_uid。
  ///
  /// 绝不返回空字符串。任何异常路径都抛出而非静默返回空值。
  Future<ResolvedScope> resolve() async {
    // The bootstrap/device scope is the only scope known before reading the
    // current session. It is still a real ledger scope, never a sentinel.
    final deviceScope = await _ledger.deviceScope();
    final ctx = RequestContext(scopeUid: deviceScope);
    final sessionResult = await _sessionRepository.get('current', ctx);
    final session = switch (sessionResult) {
      Ok(:final value) => value,
      Err(:final error) => throw StateError(
        'ScopeResolver: session retrieval failed: $error',
      ),
    };

    // 1. 无 session (登出 / 尚未登录) → 返回 device scope
    if (session == null) {
      return ResolvedScope(
        scopeUid: deviceScope,
        isUpgrade: false,
        isConflict: false,
      );
    }

    // 2. 空 appUserId → 抛错 (解 C3 空 scope 坍缩)
    final appUserId = session.appUserId.value;
    if (appUserId.isEmpty) {
      throw StateError(
        'ScopeResolver: appUserId is empty — '
        'this would cause scope collapse (C3). '
        'Session kind=${session.kind}, providerId=${session.providerId}',
      );
    }

    // 3. 查别名 → 命中则返回
    final authKind = session.isAnonymous
        ? ScopeAuthKind.anonymous
        : ScopeAuthKind.registered;
    final hit = await _ledger.scopeForIdentity(appUserId, authKind);
    if (hit != null) {
      return ResolvedScope(scopeUid: hit, isUpgrade: false, isConflict: false);
    }

    // 4. appUserId 还没有别名 → 检查 device scope
    final entries = await _ledger.entriesForScope(deviceScope);

    if (entries.isEmpty) {
      // device scope 未被任何身份占用 → 直接绑定
      await _ledger.bind(appUserId, authKind, deviceScope);
      return ResolvedScope(
        scopeUid: deviceScope,
        isUpgrade: false,
        isConflict: false,
      );
    }

    // 5. device scope 已被占用 → 检查是否能通过 link 链回
    final canLinkBack = await _canLinkBack(appUserId, entries);
    if (canLinkBack) {
      // 升级：铸新 scope，把匿名槽位（device scope）下全部数据 owner
      // 改为新 scope，并腾空匿名槽位绑定供下一位设备主人复用。
      // （修复：不再复用 device scope —— 那会让第二位主人 B 注册后数据劈裂）
      final newScope = await _ledger.mintAndBind(appUserId, authKind);
      try {
        await _handoverService.handover(
          fromScope: deviceScope,
          toScope: newScope,
        );
      } catch (_) {
        // handover 失败（备份磁盘满、blob 复制失败等）：
        // 回滚刚铸的绑定，避免留下「新 scope 已绑定但数据仍在 device scope」
        // 的中间态 —— 否则下次 resolve() 走「有 alias → 直接返回已有 scope」
        // 路径，用户看到空白（比丢数据更难排查）。
        await _ledger.clearScope(newScope);
        rethrow;
      }
      return ResolvedScope(
        scopeUid: newScope,
        isUpgrade: true,
        isConflict: false,
      );
    }

    // 6. 真冲突：登录已有账户，本地 device scope 属于另一个用户
    final newScope = await _ledger.mintAndBind(appUserId, authKind);
    return ResolvedScope(
      scopeUid: newScope,
      isUpgrade: false,
      isConflict: true,
    );
  }

  /// 检查 appUserId 是否能通过 AccountIdentityLink 链回
  /// device scope 的占用者。
  Future<bool> _canLinkBack(
    String appUserId,
    List<ScopeAliasEntry> deviceEntries,
  ) async {
    final deviceScope = await _ledger.deviceScope();
    final ctx = RequestContext(scopeUid: deviceScope);
    for (final entry in deviceEntries) {
      if (entry.authKind == ScopeAuthKind.anonymous) {
        final linkResult = await _identityLinkRepository.get(entry.authId, ctx);
        final link = switch (linkResult) {
          Ok(:final value) => value,
          Err(:final error) => throw StateError(
            'ScopeResolver: identity-link retrieval failed: $error',
          ),
        };
        if (link != null && link.registeredAppUserId.value == appUserId) {
          return true;
        }
      }
      if (entry.authKind == ScopeAuthKind.registered) {
        final linkResult = await _identityLinkRepository.get(entry.authId, ctx);
        final link = switch (linkResult) {
          Ok(:final value) => value,
          Err(:final error) => throw StateError(
            'ScopeResolver: identity-link retrieval failed: $error',
          ),
        };
        if (link != null && link.anonymousAppUserId.value == appUserId) {
          return true;
        }
      }
    }
    return false;
  }
}
