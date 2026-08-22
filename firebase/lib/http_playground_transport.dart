import 'package:http/http.dart' as http;
import 'playground/playground_http_transport.dart';

/// 基于 `package:http` 的默认 PlaygroundHttpTransport 实现（位于 lib/playground/ 边界之外）。
final class DefaultPlaygroundHttpTransport implements PlaygroundHttpTransport {
  DefaultPlaygroundHttpTransport([http.Client? client])
      : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<PlaygroundHttpResponse> get(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    final response = await _client.get(uri, headers: headers);
    return PlaygroundHttpResponse(
      statusCode: response.statusCode,
      bodyBytes: response.bodyBytes,
      headers: response.headers,
    );
  }

  @override
  Future<PlaygroundHttpResponse> put(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final response = await _client.put(
      uri,
      headers: headers,
      body: body,
    );
    return PlaygroundHttpResponse(
      statusCode: response.statusCode,
      bodyBytes: response.bodyBytes,
      headers: response.headers,
    );
  }

  void close() {
    _client.close();
  }
}
