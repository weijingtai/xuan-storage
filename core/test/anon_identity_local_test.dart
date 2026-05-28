import 'package:test/test.dart';
import 'package:persistence_core/ipc/anon_identity_local.dart';

void main() {
  test('AnonIdentityLocal: generates and persists on first call', () async {
    String? stored;
    var counter = 0;
    final p = AnonIdentityLocal(
      readPersisted: () async => stored,
      writePersisted: (v) async => stored = v,
      generateId: () => 'anon-${++counter}',
    );
    final id1 = await p.sharedAnonId();
    final id2 = await p.sharedAnonId();
    expect(id1, equals(id2));
    expect(counter, equals(1));
    expect(stored, equals(id1));
    expect(await p.isCrossAppShareAvailable(), isFalse);
  });
}
