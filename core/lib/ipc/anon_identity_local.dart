import 'dart:async';
import 'package:persistence_core/ipc/anon_identity_provider.dart';

/// Fallback implementation when cross-app sharing is unavailable.
/// Generates a deviceLocal anon ID stored in-memory + persisted by the
/// caller (caller is responsible for SharedPreferences/etc).
class AnonIdentityLocal implements AnonIdentityProvider {
  final Future<String?> Function() _readPersisted;
  final Future<void> Function(String) _writePersisted;
  final String Function() _generateId;
  final _controller = StreamController<String>.broadcast();
  String? _cached;

  AnonIdentityLocal({
    required Future<String?> Function() readPersisted,
    required Future<void> Function(String) writePersisted,
    required String Function() generateId,
  })  : _readPersisted = readPersisted,
        _writePersisted = writePersisted,
        _generateId = generateId;

  @override
  Future<String> sharedAnonId() async {
    if (_cached != null) return _cached!;
    final existing = await _readPersisted();
    if (existing != null) {
      _cached = existing;
      return existing;
    }
    final fresh = _generateId();
    await _writePersisted(fresh);
    _cached = fresh;
    _controller.add(fresh);
    return fresh;
  }

  @override
  Stream<String> watchAnonId() => _controller.stream;

  @override
  Future<bool> isCrossAppShareAvailable() async => false;
}
