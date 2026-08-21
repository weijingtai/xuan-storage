import 'dart:typed_data';

/// 纯 Dart 抽象的 HTTP 响应体封装（零 package:http 依赖）。
final class PlaygroundHttpResponse {
  const PlaygroundHttpResponse({
    required this.statusCode,
    required this.bodyBytes,
    required this.headers,
  });

  final int statusCode;
  final Uint8List bodyBytes;
  final Map<String, String> headers;

  String get body => String.fromCharCodes(bodyBytes);
}

/// 纯 Dart 抽象的 HTTP 传输接口（用于依赖注入，使 lib/playground/ 零第三方 HTTP 依赖）。
abstract interface class PlaygroundHttpTransport {
  Future<PlaygroundHttpResponse> get(
    Uri uri, {
    Map<String, String>? headers,
  });
}
