import 'dart:async';
import 'package:crdt/crdt.dart' show Hlc;
import 'package:persistence_core/sync/hlc_clock.dart';
import 'package:test/test.dart';

class _DelayedMemoryStore implements HlcClockStore {
  Hlc? _stored;
  int loadCalls = 0;
  int saveCalls = 0;

  @override
  Future<Hlc?> load() async {
    loadCalls += 1;
    // Simulate realistic async disk I/O delay
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return _stored;
  }

  @override
  Future<void> save(Hlc clock) async {
    saveCalls += 1;
    _stored = clock;
  }
}

void main() {
  group('HLC Concurrency and Boundary Properties (ST-HLC-001)', () {
    test('100 concurrent first-load and tick calls produce strictly unique, monotonically increasing stamps', () async {
      final store = _DelayedMemoryStore();
      final clock = HlcClockImpl(
        deviceId: 'dev_concurrent_1',
        store: store,
      );

      // Launch 100 concurrent tick calls simultaneously
      final futures = List.generate(100, (i) => clock.tick());
      final results = await Future.wait(futures);

      expect(results.length, 100);
      expect(store.loadCalls, 1, reason: 'First-load must only execute once across concurrent callers');

      // Sort and verify strict monotonicity
      for (var i = 1; i < results.length; i++) {
        expect(
          results[i].compareTo(results[i - 1]),
          greaterThan(0),
          reason: 'Every concurrent tick must be strictly greater than the previous tick in serial order',
        );
      }

      // Verify all timestamps are unique
      final uniqueSet = results.map((h) => '${h.dateTime.millisecondsSinceEpoch}_${h.counter}').toSet();
      expect(uniqueSet.length, 100, reason: 'All 100 generated HLC timestamps must be unique');
    });

    test('65535 counter boundary advances physical milliseconds and resets counter to zero', () async {
      final store = _DelayedMemoryStore();
      final fixedTime = DateTime.utc(2026, 1, 1, 12, 0, 0);

      final clock = HlcClockImpl(
        deviceId: 'dev_boundary',
        store: store,
        wallClock: () => fixedTime,
      );

      // Preload clock with counter at 65535
      final highHlc = Hlc(fixedTime, 65535, 'dev_boundary');
      await store.save(highHlc);

      final next = await clock.tick();

      // Millis should advance by 1 ms and counter should reset to 0
      expect(next.dateTime.millisecondsSinceEpoch, fixedTime.millisecondsSinceEpoch + 1);
      expect(next.counter, 0, reason: 'Counter must reset to 0 instead of overflowing 16 bits');
      expect(next.compareTo(highHlc), greaterThan(0));

      // Next tick at same wall clock continues from counter 1
      final next2 = await clock.tick();
      expect(next2.dateTime.millisecondsSinceEpoch, fixedTime.millisecondsSinceEpoch + 1);
      expect(next2.counter, 1);
      expect(next2.compareTo(next), greaterThan(0));
    });
  });
}
