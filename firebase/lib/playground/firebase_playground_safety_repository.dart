/// Playground 黑名单（safety）端口 Firebase adapter。
///
/// 写路径（block/unblock）走受信 Python Functions `block_user_py` /
/// `unblock_user_py`（firebase.json 只部署 codebase: python，callable 名带
/// `_py` 后缀）；读路径（isBlocked/getBlockedUsers）直连 Firestore：
/// - `playground_blocks` 集合，block 文档固定 id `block_{caller}_{target}`
///   （与后端 `xuan/handlers/conversations.py` 的 `_block_user_impl` 一致）；
/// - 字段 `blocker_app_user_id` / `blocked_app_user_id` / `created_at`；
/// - 黑名单列表 join `playground_profiles`（`display_name`/`avatar_url`）
///   组装安全公开投影 [PublicAuthor]（绝不含 canonical appUserId / provider uid）。
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_identity_resolver.dart';
import 'firebase_playground_error_mapper.dart';
import 'firebase_playground_cursor.dart';

/// Firebase 实现 [PlaygroundSafetyRepository]（黑名单管理与社交阻断）。
final class FirebasePlaygroundSafetyRepository
    implements PlaygroundSafetyRepository {
  FirebasePlaygroundSafetyRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebasePlaygroundIdentityResolver identityResolver,
    FirebaseFunctions? functions,
  })  : _firestore = firestore,
        _auth = auth,
        _identityResolver = identityResolver,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebasePlaygroundIdentityResolver _identityResolver;
  final FirebaseFunctions _functions;

  @override
  Future<void> blockUser(BlockUserCommand command) async {
    try {
      // 敏感写走受信 Functions `block_user_py`（Python codebase）。
      // 只传业务参数 + idempotency_key；actor 由 Functions 从 Auth context 解析。
      final params = <String, dynamic>{
        'targetAppUserId': command.blockedUserId.value,
        if (command.idempotencyKey != null)
          'idempotency_key': command.idempotencyKey,
      };
      await _functions.httpsCallable('block_user_py').call(params);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<void> unblockUser(PlaygroundUserId blockedUserId) async {
    try {
      final params = <String, dynamic>{
        'targetAppUserId': blockedUserId.value,
      };
      await _functions.httpsCallable('unblock_user_py').call(params);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<bool> isBlocked(PlaygroundUserId targetUserId) async {
    try {
      // 读路径保持直连（Rules read 允许）：固定文档 id 点查。
      if (_auth.currentUser == null) {
        return false;
      }
      final actor = await _identityResolver.resolveActor();
      final snap = await _firestore
          .collection(PlaygroundFirestoreSchema.blocks)
          .doc(_blockDocId(actor, targetUserId))
          .get();
      return snap.exists;
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundPage<PublicAuthor>> getBlockedUsers({
    PlaygroundCursor? cursor,
    int limit = 20,
  }) async {
    try {
      // 读路径保持直连（Rules read 允许）。
      if (_auth.currentUser == null) {
        return PlaygroundPage.empty();
      }
      final actor = await _identityResolver.resolveActor();

      var q = _firestore
          .collection(PlaygroundFirestoreSchema.blocks)
          .where('blocker_app_user_id', isEqualTo: actor.value)
          .orderBy('created_at', descending: true);

      // 游标必须先于 limit 应用：fake_cloud_firestore 按链式顺序执行操作，
      // 若先 limit 会先截断到第一页再 startAfter → 第二页恒空。
      if (cursor != null && cursor.isNotEmpty) {
        final startDoc =
            FirebasePlaygroundCursor.toDocumentReference(cursor, _firestore);
        if (startDoc != null) {
          final startSnap = await startDoc.get();
          if (startSnap.exists) {
            q = q.startAfterDocument(startSnap);
          } else {
            final startValues =
                FirebasePlaygroundCursor.toStartAfterValues(cursor);
            if (startValues != null) {
              q = q.startAfter(startValues);
            }
          }
        } else {
          final startValues = FirebasePlaygroundCursor.toStartAfterValues(cursor);
          if (startValues != null) {
            q = q.startAfter(startValues);
          }
        }
      }
      q = q.limit(limit);

      final snaps = await q.get();
      final items = <PublicAuthor>[];
      for (final doc in snaps.docs) {
        final data = doc.data();
        final blockedUserId =
            data['blocked_app_user_id'] as String? ?? doc.id;
        if (blockedUserId.isEmpty) continue;
        items.add(await _toPublicAuthor(PlaygroundUserId(blockedUserId)));
      }

      final nextCursor =
          snaps.docs.isNotEmpty && snaps.docs.length == limit
              ? FirebasePlaygroundCursor.fromQueryDocumentWithOrderBy(
                  snaps.docs.last,
                  const ['created_at'],
                )
              : null;

      return PlaygroundPage(
        items: items,
        nextCursor: nextCursor,
        hasMore: nextCursor != null,
        totalCount: -1,
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  /// block 文档固定 id：`block_{caller}_{target}`（与后端 `_block_user_impl`
  /// 的 `doc_id = f"block_{app_user_id}_{target}"` 保持一致）。
  static String blockDocId(PlaygroundUserId caller, PlaygroundUserId target) =>
      'block_${caller.value}_${target.value}';

  String _blockDocId(PlaygroundUserId caller, PlaygroundUserId target) =>
      blockDocId(caller, target);

  /// join `playground_profiles` 组装安全公开投影。
  ///
  /// 命中 profile 时取 `display_name`/`avatar_url`；未命中时退回
  /// `盘友{展示ID尾6位}` 占位别名（与 public mapper 同语义，不暴露身份字段）。
  Future<PublicAuthor> _toPublicAuthor(PlaygroundUserId userId) async {
    try {
      final snap = await _firestore
          .collection(PlaygroundFirestoreSchema.profiles)
          .doc(userId.value)
          .get();
      final data = snap.data();
      if (data != null) {
        return PublicAuthor(
          publicPresentationUserId: userId,
          displayAlias:
              data['display_name'] as String? ?? _fallbackAlias(userId),
          avatarUrl: data['avatar_url'] as String?,
          publicProfileRef: '/profile/${userId.value}',
        );
      }
    } catch (_) {
      // join 失败不阻塞名单展示：退回占位投影。
    }
    return PublicAuthor(
      publicPresentationUserId: userId,
      displayAlias: _fallbackAlias(userId),
      avatarUrl: null,
      publicProfileRef: '/profile/${userId.value}',
    );
  }

  static String _fallbackAlias(PlaygroundUserId userId) {
    final value = userId.value;
    return '盘友${value.length > 6 ? value.substring(value.length - 6) : value}';
  }
}
