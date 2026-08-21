import 'dart:convert';
import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

import 'playground_http_transport.dart';
import 'rest_playground_feed_repository.dart';

/// 基于 REST + ETag 条件请求的帖子详情 RemoteDataSource（路线 2 专用端点）。
///
/// 读路径：`GET /playground/posts/{id}` + ETag 缓存协商；
/// 写路径：按 FW1 规范保持不动，委托给既有 Firestore 写入实现。
final class RestPlaygroundPostRemoteDataSource
    implements PlaygroundPostRemoteDataSource {
  RestPlaygroundPostRemoteDataSource({
    required this.baseUrl,
    required PlaygroundHttpTransport transport,
    PlaygroundPostRemoteDataSource? fallbackWriter,
  })  : _transport = transport,
        _fallbackWriter = fallbackWriter;

  final Uri baseUrl;
  final PlaygroundHttpTransport _transport;
  final PlaygroundPostRemoteDataSource? _fallbackWriter;
  final Map<String, String> _etagCache = {};
  final Map<String, PlaygroundPost> _postCache = {};

  Uri _buildUri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return baseUrl.replace(
      path: '${baseUrl.path.replaceAll(RegExp(r'/+$'), '')}$normalizedPath',
    );
  }

  @override
  Future<PlaygroundPost?> getPost(PlaygroundPostId postId) async {
    final path = '/playground/posts/${postId.value}';
    final uri = _buildUri(path);
    final headers = <String, String>{
      'accept': 'application/json',
      if (_etagCache.containsKey(postId.value))
        'if-none-match': _etagCache[postId.value]!,
    };

    final response = await _transport.get(uri, headers: headers);

    if (response.statusCode == 304) {
      return _postCache[postId.value];
    }

    if (response.statusCode == 404) {
      _etagCache.remove(postId.value);
      _postCache.remove(postId.value);
      return null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final etag = response.headers['etag'];
      if (etag != null) {
        _etagCache[postId.value] = etag;
      }

      final json = jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
      final post = RestPlaygroundFeedRemoteDataSource.parsePostFromJson(json);
      _postCache[postId.value] = post;
      return post;
    }

    throw Exception(
        'REST Post request failed for ${postId.value}: HTTP ${response.statusCode}');
  }

  @override
  Future<PlaygroundPost> createPost(CreatePostCommand command) {
    if (_fallbackWriter != null) {
      return _fallbackWriter.createPost(command);
    }
    throw UnimplementedError('Write path is handled by Firestore writer');
  }

  @override
  Future<PlaygroundPost> editPost(EditPostCommand command) {
    if (_fallbackWriter != null) {
      return _fallbackWriter.editPost(command);
    }
    throw UnimplementedError('Write path is handled by Firestore writer');
  }

  @override
  Future<PlaygroundPost> deletePost(DeletePostCommand command) {
    if (_fallbackWriter != null) {
      return _fallbackWriter.deletePost(command);
    }
    throw UnimplementedError('Write path is handled by Firestore writer');
  }
}
