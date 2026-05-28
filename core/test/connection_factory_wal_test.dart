import 'package:test/test.dart';
import 'package:persistence_core/core/connection_factory.dart';

void main() {
  group('IConnectionFactory contract for cross-process safety', () {
    test('exposes the required PRAGMA list for WAL + multi-process safety', () {
      expect(
        IConnectionFactory.requiredPragmas,
        containsAll(<String>[
          'journal_mode = WAL',
          'busy_timeout = 5000',
          'foreign_keys = ON',
        ]),
      );
    });
  });
}
