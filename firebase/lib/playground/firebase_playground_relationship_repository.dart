import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_schema.dart';
import 'firebase_playground_identity_resolver.dart';
import 'firebase_playground_error_mapper.dart';
import 'firebase_playground_cursor.dart';

/// 社交关系（关注/粉丝/好友）Firebase 实现。
///
/// 写操作（follow/unfollow）走受信 Functions（`follow_user_py` /
/// `unfollow_user_py`，firebase.json 只部署 Python codebase，故必须带 `_py`）；
/// 读操作直连 Firestore `playground_follows` 集合 + cursor 分页，
/// 用户展示信息从 `playground_profiles` 读取组装 [PublicAuthor]。
final class FirebasePlaygroundRelationshipRepository
    implements PlaygroundRelationshipRepository {
  FirebasePlaygroundRelationshipRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebasePlaygroundIdentityResolver identityResolver,
    FirebaseFunctions? functions,
  })  : _firestore = firestore,
        _identityResolver = identityResolver,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebasePlaygroundIdentityResolver _identityResolver;
  final FirebaseFunctions _functions;

  @override
  Future<bool> isFollowing(PlaygroundUserId targetUserId) async {
    try {
      final actor = await _identityResolver.resolveActor();
      final snap = await _follows
          .doc('follow_${actor.value}_${targetUserId.value}')
          .get();
      return snap.exists;
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<void> followUser(FollowUserCommand command) async {
    try {
      final params = <String, dynamic>{
        'targetAppUserId': command.targetUserId.value,
        if (command.idempotencyKey != null)
          'idempotency_key': command.idempotencyKey,
      };
      await _functions.httpsCallable('follow_user_py').call(params);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<void> unfollowUser(UnfollowUserCommand command) async {
    try {
      final params = <String, dynamic>{
        'targetAppUserId': command.targetUserId.value,
        if (command.idempotencyKey != null)
          'idempotency_key': command.idempotencyKey,
      };
      await _functions.httpsCallable('unfollow_user_py').call(params);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundPage<RelationshipUser>> getFollowingList(
    GetRelationshipListQuery query,
  ) async {
    try {
      final actor = await _identityResolver.resolveActor();
      final followerIds = await _myFollowerIds(actor);
      final snap = await _readFollowsPage(
        q: _follows
            .where('follower_app_user_id', isEqualTo: actor.value)
            .orderBy('created_at', descending: true),
        query: query,
        idOf: (data) => data['following_app_user_id'] as String? ?? '',
      );
      final authors = await _authorsFor(snap.ids);
      final items = snap.ids.map((id) {
        return RelationshipUser(
          author: authors[id]!,
          isFollowing: true,
          isFollower: followerIds.contains(id),
        );
      }).toList();
      return _page(items, snap.docs, query.limit);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundPage<RelationshipUser>> getFollowerList(
    GetRelationshipListQuery query,
  ) async {
    try {
      final actor = await _identityResolver.resolveActor();
      final followingIds = await _myFollowingIds(actor);
      final snap = await _readFollowsPage(
        q: _follows
            .where('following_app_user_id', isEqualTo: actor.value)
            .orderBy('created_at', descending: true),
        query: query,
        idOf: (data) => data['follower_app_user_id'] as String? ?? '',
      );
      final authors = await _authorsFor(snap.ids);
      final items = snap.ids.map((id) {
        return RelationshipUser(
          author: authors[id]!,
          isFollowing: followingIds.contains(id),
          isFollower: true,
        );
      }).toList();
      return _page(items, snap.docs, query.limit);
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundPage<RelationshipUser>> getFriendList(
    GetRelationshipListQuery query,
  ) async {
    try {
      final actor = await _identityResolver.resolveActor();
      final followingIds = await _myFollowingIds(actor);
      final followerIds = await _myFollowerIds(actor);
      final friendIds = followingIds.intersection(followerIds).toList();
      final pageIds = friendIds.take(query.limit).toList();
      final authors = await _authorsFor(pageIds);
      final items = pageIds.map((id) {
        return RelationshipUser(
          author: authors[id]!,
          isFollowing: true,
          isFollower: true,
        );
      }).toList();
      return PlaygroundPage(
        items: items,
        hasMore: friendIds.length > query.limit,
        totalCount: friendIds.length,
      );
    } catch (e) {
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  // ---- 私有辅助 ----

  CollectionReference<Map<String, dynamic>> get _follows =>
      _firestore.collection(PlaygroundFirestoreSchema.follows);

  CollectionReference<Map<String, dynamic>> get _profiles =>
      _firestore.collection(PlaygroundFirestoreSchema.profiles);

  /// 我关注的用户 id 集合。
  Future<Set<String>> _myFollowingIds(PlaygroundUserId actor) async {
    final snaps = await _follows
        .where('follower_app_user_id', isEqualTo: actor.value)
        .get();
    return snaps.docs
        .map((doc) => doc.data()['following_app_user_id'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  /// 关注我的用户 id 集合。
  Future<Set<String>> _myFollowerIds(PlaygroundUserId actor) async {
    final snaps = await _follows
        .where('following_app_user_id', isEqualTo: actor.value)
        .get();
    return snaps.docs
        .map((doc) => doc.data()['follower_app_user_id'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  /// 读取一页 follows：先应用 cursor（startAfterDocument 优先，values 兜底），
  /// 再 limit —— 顺序颠倒会导致第二页恒空。
  Future<({List<String> ids, List<QueryDocumentSnapshot<Map<String, dynamic>>> docs})>
      _readFollowsPage({
    required Query<Map<String, dynamic>> q,
    required GetRelationshipListQuery query,
    required String Function(Map<String, dynamic> data) idOf,
  }) async {
    var query_ = q;
    final cursor = query.cursor;
    if (cursor != null && cursor.isNotEmpty) {
      final startDoc =
          FirebasePlaygroundCursor.toDocumentReference(cursor, _firestore);
      if (startDoc != null) {
        final startSnap = await startDoc.get();
        if (startSnap.exists) {
          query_ = query_.startAfterDocument(startSnap);
        } else {
          final startValues =
              FirebasePlaygroundCursor.toStartAfterValues(cursor);
          if (startValues != null) {
            query_ = query_.startAfter(startValues);
          }
        }
      } else {
        final startValues = FirebasePlaygroundCursor.toStartAfterValues(cursor);
        if (startValues != null) {
          query_ = query_.startAfter(startValues);
        }
      }
    }
    query_ = query_.limit(query.limit);
    final snap = await query_.get();
    final ids = snap.docs
        .map((doc) => idOf(doc.data()))
        .where((id) => id.isNotEmpty)
        .toList();
    return (ids: ids, docs: snap.docs);
  }

  /// 批量读取用户公开资料，返回 id → PublicAuthor 映射（缺失时用占位名兜底）。
  Future<Map<String, PublicAuthor>> _authorsFor(List<String> ids) async {
    if (ids.isEmpty) return {};
    final result = <String, PublicAuthor>{};
    for (final id in ids) {
      final snap = await _profiles.doc(id).get();
      if (snap.exists) {
        final data = snap.data() ?? const <String, dynamic>{};
        result[id] = PublicAuthor(
          publicPresentationUserId: PlaygroundUserId(id),
          displayAlias: data['display_name'] as String? ??
              data['displayName'] as String? ??
              'User_$id',
          avatarUrl:
              data['avatar_url'] as String? ?? data['avatarUrl'] as String?,
        );
      } else {
        result[id] = PublicAuthor(
          publicPresentationUserId: PlaygroundUserId(id),
          displayAlias: 'User_$id',
        );
      }
    }
    return result;
  }

  PlaygroundPage<RelationshipUser> _page(
    List<RelationshipUser> items,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    int limit,
  ) {
    final nextCursor = docs.isNotEmpty && docs.length == limit
        ? FirebasePlaygroundCursor.fromQueryDocumentWithOrderBy(
            docs.last,
            const ['created_at'],
          )
        : null;
    return PlaygroundPage(
      items: items,
      nextCursor: nextCursor,
      hasMore: nextCursor != null,
      totalCount: -1,
    );
  }
}
