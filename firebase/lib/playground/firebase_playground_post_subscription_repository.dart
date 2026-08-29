/// Firestore 直写帖子订阅/静音仓库（帖子事件订阅：新回复/应验/作者更新）。
///
/// 集合：`playground_post_subscriptions`（与后端 Python 的
/// `playground_subscriptions`「通知偏好」集合**不同**；本仓库只服务
/// 「帖子事件订阅」端口，直接读写 `playground_post_subscriptions`）。
///
/// 文档 ID：`sub_{subscriberAppUserId}_{postId}` —— 确定性、可回读、
/// 天然幂等（同 actor 对同帖只有一份）。
///
/// 字段（snake_case，与 schema fixture / Rules 一致）：
/// - `subscriber_app_user_id`(String)  订阅者 app user id
/// - `post_id`(String)
/// - `enabled_events`(List<String>)    事件类型 name 列表（`newReply`/
///   `outcomeFeedback`/`authorUpdate`；`unknown` 不落库）
/// - `muted`(bool)
/// - `follows_post`(bool)
/// - `created_at`/`updated_at`(Timestamp)
///
/// 语义（与 RI 端口文档一致）：
/// - subscribe = 幂等合并（已存在则并集），follows_post=true、muted=false；
/// - unsubscribe = 删除文档（幂等：不存在也成功）；
/// - mute = muted=true、follows_post=false，enabled_events 收缩为
///   「保留应验/保留重要更新」交集（其余事件关闭）；
/// - 写路径与 FirestoreDirect* 直写仓库同一风格：actor 经
///   `requireDirectActor`（identity_map）解析，错误统一
///   [FirebasePlaygroundErrorMapper.map] / [directPlaygroundError]。
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'firebase_playground_cursor.dart';
import 'firebase_playground_error_mapper.dart';
import 'firebase_playground_schema.dart';
import 'firestore_direct_playground_command_support.dart';

/// 帖子订阅直写仓库 —— 生产装配的 provider。
final class FirebasePlaygroundPostSubscriptionRepository
    implements PlaygroundPostSubscriptionRepository {
  FirebasePlaygroundPostSubscriptionRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _subscriptions => _firestore
      .collection(PlaygroundFirestoreSchema.postSubscriptions);

  // ---- 写 ----

  @override
  Future<void> subscribePostEvents(SubscribePostEventsCommand command) async {
    try {
      _requireIdempotencyKey(command.idempotencyKey);
      final actor = await requireDirectActor(firestore: _firestore, auth: _auth);
      // 落库存事件 name（Firestore 不接受 enum 实例）。
      final events = command.enabledEvents
          .where((e) => e != PlaygroundSubscriptionEventType.unknown)
          .map((e) => e.name)
          .toSet();

      final docRef = _docRef(actor.appUserId, command.postId.value);
      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(docRef);
        final existing = snap.exists
            ? _eventNamesFromDoc(snap.data()!)
            : <String>{};
        tx.set(docRef, {
          'subscriber_app_user_id': actor.appUserId,
          'post_id': command.postId.value,
          'enabled_events': events.union(existing).toList(growable: false),
          'muted': false,
          'follows_post': true,
          'created_at': snap.exists
              ? (snap.data()?['created_at'] ??
                    FieldValue.serverTimestamp())
              : FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      if (e is PlaygroundError) rethrow;
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<void> unsubscribePost(UnsubscribePostCommand command) async {
    try {
      _requireIdempotencyKey(command.idempotencyKey);
      final actor = await requireDirectActor(firestore: _firestore, auth: _auth);
      final docRef = _docRef(actor.appUserId, command.postId.value);
      final snap = await docRef.get();
      if (snap.exists) {
        await docRef.delete();
      }
      // 不存在 = 已取消订阅：幂等成功。
    } catch (e) {
      if (e is PlaygroundError) rethrow;
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<void> mutePost(MutePostCommand command) async {
    try {
      _requireIdempotencyKey(command.idempotencyKey);
      final actor = await requireDirectActor(firestore: _firestore, auth: _auth);

      // 保留集合：应验/作者更新按选项保留，其余事件（新回复）一律关闭。
      final retained = <String>{
        if (command.keepOutcomeFeedback)
          PlaygroundSubscriptionEventType.outcomeFeedback.name,
        if (command.keepAuthorUpdate)
          PlaygroundSubscriptionEventType.authorUpdate.name,
      };

      final docRef = _docRef(actor.appUserId, command.postId.value);
      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(docRef);
        final existing = snap.exists
            ? _eventNamesFromDoc(snap.data()!)
            : <String>{};
        // 静音语义：已订阅则收缩为保留集合交集；从未订阅则直接落保留集合
        // （与 RI in-memory 参考实现的 mutePost 语义一致）。
        final enabled = existing.isEmpty
            ? retained.toList(growable: false)
            : existing.intersection(retained).toList(growable: false);
        tx.set(docRef, {
          'subscriber_app_user_id': actor.appUserId,
          'post_id': command.postId.value,
          'enabled_events': enabled,
          'muted': true,
          'follows_post': false,
          'created_at': snap.exists
              ? (snap.data()?['created_at'] ??
                    FieldValue.serverTimestamp())
              : FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      if (e is PlaygroundError) rethrow;
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  // ---- 读 ----

  @override
  Future<PlaygroundPostSubscription?> getMySubscription(
    PlaygroundPostId postId,
  ) async {
    try {
      final actor = await requireDirectActor(firestore: _firestore, auth: _auth);
      final snap = await _docRef(actor.appUserId, postId.value).get();
      if (!snap.exists) return null;
      return _docToSubscription(snap.id, snap.data()!);
    } catch (e) {
      if (e is PlaygroundError) rethrow;
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  @override
  Future<PlaygroundPage<PlaygroundPostSubscription>> getMySubscriptions({
    PlaygroundCursor? cursor,
    int limit = 20,
  }) async {
    try {
      final actor = await requireDirectActor(firestore: _firestore, auth: _auth);

      var query = _subscriptions
          .where('subscriber_app_user_id', isEqualTo: actor.appUserId)
          .orderBy('updated_at', descending: true);

      if (cursor != null && cursor.isNotEmpty) {
        final startDoc =
            FirebasePlaygroundCursor.toDocumentReference(cursor, _firestore);
        if (startDoc != null) {
          final startSnap = await startDoc.get();
          if (startSnap.exists) {
            query = query.startAfterDocument(startSnap);
          } else {
            final start = FirebasePlaygroundCursor.toStartAfterValues(cursor);
            if (start != null) {
              query = query.startAfter(start);
            }
          }
        } else {
          final start = FirebasePlaygroundCursor.toStartAfterValues(cursor);
          if (start != null) {
            query = query.startAfter(start);
          }
        }
      }
      query = query.limit(limit);

      final snaps = await query.get();
      final items = snaps.docs
          .map((doc) => _docToSubscription(doc.id, doc.data()))
          .toList(growable: false);

      final nextCursor = snaps.docs.isNotEmpty && snaps.docs.length == limit
          ? FirebasePlaygroundCursor.fromQueryDocumentWithOrderBy(
              snaps.docs.last,
              const ['updated_at'],
            )
          : null;

      return PlaygroundPage(
        items: items,
        nextCursor: nextCursor,
        hasMore: nextCursor != null,
        totalCount: -1,
      );
    } catch (e) {
      if (e is PlaygroundError) rethrow;
      throw FirebasePlaygroundErrorMapper.map(e);
    }
  }

  // ---- helpers ----

  DocumentReference<Map<String, dynamic>> _docRef(String appUserId, String postId) {
    return _subscriptions.doc('sub_${appUserId}_$postId');
  }

  static PlaygroundPostSubscription _docToSubscription(
    String docId,
    Map<String, dynamic> data,
  ) {
    final muted = data['muted'] == true;
    final events = _eventNamesFromDoc(data).map(_eventFromName).toSet();
    final postId = PlaygroundPostId(data['post_id'] as String? ?? '');
    final subscriber = PlaygroundUserId(
      data['subscriber_app_user_id'] as String? ?? '',
    );

    if (muted) {
      return PlaygroundPostSubscription.muted(
        postId: postId,
        subscriberUserId: subscriber,
        enabledEvents: events,
      );
    }
    return PlaygroundPostSubscription(
      postId: postId,
      subscriberUserId: subscriber,
      enabledEvents: events,
    );
  }

  static Set<String> _eventNamesFromDoc(Map<String, dynamic> data) {
    final raw = data['enabled_events'];
    if (raw is! List) return <String>{};
    return raw.whereType<String>().toSet();
  }

  static PlaygroundSubscriptionEventType _eventFromName(String name) {
    for (final value in PlaygroundSubscriptionEventType.values) {
      if (value.name == name) return value;
    }
    return PlaygroundSubscriptionEventType.unknown;
  }

  static String _requireIdempotencyKey(String? key) {
    if (key == null || key.isEmpty) {
      throw directPlaygroundError(
        code: PlaygroundErrorCode.invalidArgument,
        machineCode: 'idempotency/invalid-key',
        message: '缺少幂等键',
      );
    }
    return key;
  }
}
