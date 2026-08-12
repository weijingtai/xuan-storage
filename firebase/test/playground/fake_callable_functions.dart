import 'package:cloud_functions/cloud_functions.dart';

/// 记录型 Fake FirebaseFunctions：捕获 httpsCallable 名称与每次 call 参数。
///
/// 仅用于 adapter 单元测试（RED-A 白名单/调用断言）；双证据走真 emulator。
///
/// 支持两种响应方式：
/// - [handlers]：按 callable 名称注册自定义行为（可模拟落库副作用，供
///   repository 契约套件使用，如 setLike 写入 FakeFirestore）。
/// - [responses]：静态预设响应（未注册 handler 时优先 handlers，否则
///   查 responses，再退到 [defaultResult]）。
class FakeFirebaseFunctions implements FirebaseFunctions {
  FakeFirebaseFunctions();

  /// 被调用的 callable 名称（按调用顺序）。
  final List<String> calledNames = [];

  /// 每次 call 的原始参数 map（与 calledNames 一一对应）。
  final List<Map<String, dynamic>?> calledParameters = [];

  /// callable 名称 → 自定义行为。返回响应 data；可包含副作用。
  final Map<String, Future<dynamic> Function(Map<String, dynamic>? parameters)>
      handlers = {};

  /// callable 名称 → 预设响应。未注册 handler 时优先 handlers。
  final Map<String, dynamic> responses = {};

  /// 未预设响应时返回的默认值。
  dynamic defaultResult = <String, dynamic>{'success': true};

  /// 是否抛错；true 时 call 抛 [FirebaseFunctionsException]。
  bool shouldThrow = false;
  String throwCode = 'permission-denied';
  String throwMessage = 'mock denial';

  /// 与 [shouldThrow] 等效的按名错误注入：callable 名称 → 抛出的异常。
  /// handler 与 responses 之前检查。
  final Map<String, Exception> throwFor = {};

  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) {
    calledNames.add(name);
    return FakeHttpsCallable((parameters) async {
      calledParameters.add(parameters);
      final injected = throwFor[name];
      if (injected != null) {
        throw injected;
      }
      if (shouldThrow) {
        throw FirebaseFunctionsException(
          code: throwCode,
          message: throwMessage,
        );
      }
      final handler = handlers[name];
      if (handler != null) {
        return handler(parameters);
      }
      return responses[name] ?? defaultResult;
    });
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 可编程 HttpsCallable：handler 返回原始 data。
class FakeHttpsCallable implements HttpsCallable {
  FakeHttpsCallable(this._handler);

  final Future<dynamic> Function(Map<String, dynamic>? parameters) _handler;

  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    final result =
        await _handler((parameters as Map?)?.cast<String, dynamic>());
    return FakeHttpsCallableResult<T>(result as T);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 可构造的 HttpsCallableResult（生产类型构造私有，仅测试可构造）。
class FakeHttpsCallableResult<T> implements HttpsCallableResult<T> {
  FakeHttpsCallableResult(this.data);

  @override
  final T data;
}
