/// RED: Firestore composite index 合同（Task 7 / Design §10.2）。
///
/// 静态读取 `firestore.indexes.json` 断言：
/// - 旧 playground_likes composite（post_id + user_provider_uid）不存在（v1 like 无此字段）；
/// - 6 条 current-phase composite 逐字匹配（posts×2、replies×1、verifications×2、bookmarks×1）；
/// - post-target likes count 依赖 equality index merge（target_type==post + target_id==postId），
///   不新增 likes composite。
/// 该测试在删除旧 likes composite 之前必须失败（静态 RED）。
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const indexPath = 'infrastructure/firestore.indexes.json';
  late Map<String, dynamic> indexes;
  late List<Map<String, dynamic>> entries;

  setUpAll(() {
    final raw = File(indexPath).readAsStringSync();
    indexes = jsonDecode(raw) as Map<String, dynamic>;
    entries = (indexes['indexes'] as List<dynamic>).cast<Map<String, dynamic>>();
  });

  List<String> fieldsOf(Map<String, dynamic> index) =>
      (index['fields'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((f) => f['fieldPath'] as String)
          .toList();

  bool hasIndex(String collection, List<String> fieldPaths) =>
      entries.any((i) =>
          i['collectionGroup'] == collection &&
          _sameList(fieldsOf(i), fieldPaths));

  bool hasIndexWithArrayContains(String collection, String arrayField,
          List<String> fieldPaths) =>
      entries.any((i) {
        if (i['collectionGroup'] != collection) return false;
        final fields = (i['fields'] as List<dynamic>).cast<Map<String, dynamic>>();
        final paths = fields.map((f) => f['fieldPath'] as String).toList();
        final configs =
            fields.map((f) => f['arrayConfig'] ?? 'ORDER').toList();
        if (!_sameList(paths, fieldPaths)) return false;
        return configs[fieldPaths.indexOf(arrayField)] == 'CONTAINS';
      });

  test('旧 playground_likes composite（post_id + user_provider_uid）不存在', () {
    expect(
      hasIndex('playground_likes', ['post_id', 'user_provider_uid']),
      isFalse,
      reason: 'v1 like 文档无 post_id/user_provider_uid 字段，旧 composite 必须删除',
    );
    expect(
      entries.where((i) => i['collectionGroup'] == 'playground_likes'),
      isEmpty,
      reason: 'post-target likes 用 equality index merge，不新增任何 likes composite',
    );
  });

  test('6 条 current-phase composite 逐字匹配（Design §10.2）', () {
    // posts: status ASC, created_at DESC（无 technique）
    expect(hasIndex('playground_posts', ['status', 'created_at']), isTrue,
        reason: '最新/推荐 Feed 单 query');
    // posts: status ASC + allowed_chart_technique_ids CONTAINS + created_at DESC
    expect(
      hasIndexWithArrayContains('playground_posts',
          'allowed_chart_technique_ids', ['status', 'allowed_chart_technique_ids', 'created_at']),
      isTrue,
      reason: '技法多选 Feed array-contains-any',
    );
    // replies: post_id ASC, is_tombstoned ASC, created_at ASC
    expect(
      hasIndex('playground_replies',
          ['post_id', 'is_tombstoned', 'created_at']),
      isTrue,
      reason: '回复页 v1 查询',
    );
    // verifications: post_id ASC, root_reply_id ASC, revoked_at ASC, created_at ASC
    expect(
      hasIndex('playground_verifications',
          ['post_id', 'root_reply_id', 'revoked_at', 'created_at']),
      isTrue,
      reason: '当前页应验分块查询',
    );
    // verifications: post_id ASC, revoked_at ASC
    expect(hasIndex('playground_verifications', ['post_id', 'revoked_at']),
        isTrue,
        reason: '帖子应验总数 count()');
    // bookmarks: user_provider_uid ASC, created_at DESC
    expect(
      hasIndex('playground_bookmarks', ['user_provider_uid', 'created_at']),
      isTrue,
      reason: '收藏列表分页',
    );
  });

  test('旧 author_app_user_id / depth / root_reply_id profile 索引不得被当前 query 依赖', () {
    // 旧 profile 索引（author_app_user_id...）标记后续，当前 Phase 不得存在。
    expect(
      entries.where((i) => i['collectionGroup'] == 'playground_posts')
          .expand((i) => fieldsOf(i))
          .any((f) => f == 'author_app_user_id'),
      isFalse,
      reason: 'v1 公开 post 无 author_app_user_id，profile 索引后移',
    );
    expect(
      entries.where((i) => i['collectionGroup'] == 'playground_replies')
          .expand((i) => fieldsOf(i))
          .any((f) => f == 'author_app_user_id'),
      isFalse,
      reason: 'v1 公开 reply 无 author_app_user_id',
    );
  });
}

bool _sameList(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
