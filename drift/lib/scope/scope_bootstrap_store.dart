/// Ghost scope_uid 的持久化端口。
///
/// 首次调用 [getOrCreate] 时铸造 UUIDv7 并持久化，
/// 后续调用返回已持久化的值——保证终生不变。
abstract interface class ScopeBootstrapStore {
  /// 返回本设备的稳定 scope_uid，绝不返回空字符串。
  Future<String> getOrCreate();

  /// 仅用于测试/重置场景。生产代码不应调用。
  Future<void> resetForTest();
}

/// InMemory 实现，供测试使用。
class InMemoryScopeBootstrapStore implements ScopeBootstrapStore {
  String? _cached;
  int _generatedCount = 0;

  @override
  Future<String> getOrCreate() async {
    if (_cached != null && _cached!.isNotEmpty) return _cached!;
    _generatedCount++;
    _cached = 'test-scope-$_generatedCount';
    return _cached!;
  }

  @override
  Future<void> resetForTest() async {
    _cached = null;
  }

  int get generatedCount => _generatedCount;
}
