import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/reconciliation.dart';
import 'package:persistence_core/model/reconciliation_ports.dart';
import 'package:persistence_core/sync/manifest_comparator.dart';

ManifestEntry _entry(
  String id, {
  required int hlcPacked,
  required String deviceId,
  bool isDeleted = false,
}) =>
    ManifestEntry(
      entityId: id,
      hlcPacked: hlcPacked,
      deviceId: deviceId,
      isDeleted: isDeleted,
    );

/// 打包 `(l << 16) | c`，l = UTC 毫秒。
int _packed(int lUtcMs, [int counter = 0]) => (lUtcMs << 16) | counter;

void main() {
  const comparator = DefaultManifestComparator();

  group('classifyLocalEntry 五类（遍历本地清单）', () {
    test('本地有 / 对方无 → sendTerminal', () {
      final local = _entry('e1', hlcPacked: _packed(2000), deviceId: 'a');
      final decision = comparator.classifyLocalEntry(local: local, remote: null);
      expect(decision, ManifestComparatorDecision.sendTerminal);
    });

    test('双方都有且本地戳更新 → sendTerminal', () {
      final local = _entry('e1', hlcPacked: _packed(3000), deviceId: 'a');
      final remote = _entry('e1', hlcPacked: _packed(2000), deviceId: 'b');
      final decision = comparator.classifyLocalEntry(
        local: local,
        remote: remote,
      );
      expect(decision, ManifestComparatorDecision.sendTerminal);
    });

    test('双方都有且对方戳更新 → requestTerminal', () {
      final local = _entry('e1', hlcPacked: _packed(2000), deviceId: 'a');
      final remote = _entry('e1', hlcPacked: _packed(3000), deviceId: 'b');
      final decision = comparator.classifyLocalEntry(
        local: local,
        remote: remote,
      );
      expect(decision, ManifestComparatorDecision.requestTerminal);
    });

    test('版本相同 → skip', () {
      final local = _entry('e1', hlcPacked: _packed(2000), deviceId: 'a');
      final remote = _entry('e1', hlcPacked: _packed(2000), deviceId: 'a');
      final decision = comparator.classifyLocalEntry(
        local: local,
        remote: remote,
      );
      expect(decision, ManifestComparatorDecision.skip);
    });
  });

  group('classifyRemoteEntry 五类（遍历收到清单）', () {
    test('本地无 / 对方有 → requestTerminal（新设备入网核心路径）', () {
      final remote = _entry('e1', hlcPacked: _packed(2000), deviceId: 'a');
      final decision = comparator.classifyRemoteEntry(
        local: null,
        remote: remote,
      );
      expect(decision, ManifestComparatorDecision.requestTerminal);
    });

    test('双方都有且本地戳更新 → sendTerminal', () {
      final local = _entry('e1', hlcPacked: _packed(3000), deviceId: 'a');
      final remote = _entry('e1', hlcPacked: _packed(2000), deviceId: 'b');
      final decision = comparator.classifyRemoteEntry(
        local: local,
        remote: remote,
      );
      expect(decision, ManifestComparatorDecision.sendTerminal);
    });

    test('双方都有且对方戳更新 → requestTerminal', () {
      final local = _entry('e1', hlcPacked: _packed(2000), deviceId: 'a');
      final remote = _entry('e1', hlcPacked: _packed(3000), deviceId: 'b');
      final decision = comparator.classifyRemoteEntry(
        local: local,
        remote: remote,
      );
      expect(decision, ManifestComparatorDecision.requestTerminal);
    });

    test('版本相同 → skip', () {
      final local = _entry('e1', hlcPacked: _packed(2000), deviceId: 'a');
      final remote = _entry('e1', hlcPacked: _packed(2000), deviceId: 'a');
      final decision = comparator.classifyRemoteEntry(
        local: local,
        remote: remote,
      );
      expect(decision, ManifestComparatorDecision.skip);
    });
  });

  group('is_deleted 不参与定序（S1c §3.2① 定稿）', () {
    test('同戳一活一墓碑 → 按戳比较，墓碑位不影响结论', () {
      final alive = _entry(
        'e1',
        hlcPacked: _packed(2000),
        deviceId: 'a',
        isDeleted: false,
      );
      final tombstone = _entry(
        'e1',
        hlcPacked: _packed(2000),
        deviceId: 'a',
        isDeleted: true,
      );
      // 戳完全相同（同 hlcPacked + deviceId）→ skip，与 is_deleted 无关
      expect(
        comparator.classifyLocalEntry(local: alive, remote: tombstone),
        ManifestComparatorDecision.skip,
      );
      expect(
        comparator.classifyRemoteEntry(local: tombstone, remote: alive),
        ManifestComparatorDecision.skip,
      );
    });

    test('墓碑戳更大时，活实体 vs 墓碑 → 活实体索求墓碑', () {
      final alive = _entry(
        'e1',
        hlcPacked: _packed(2000),
        deviceId: 'a',
        isDeleted: false,
      );
      final tombstone = _entry(
        'e1',
        hlcPacked: _packed(3000),
        deviceId: 'b',
        isDeleted: true,
      );
      // 本地活但戳小，远端墓碑戳大 → 索求（拿到后本地也会变墓碑）
      expect(
        comparator.classifyLocalEntry(local: alive, remote: tombstone),
        ManifestComparatorDecision.requestTerminal,
      );
      // 本地墓碑但戳小，远端活戳大 → 索求（复活）
      expect(
        comparator.classifyLocalEntry(local: tombstone, remote: alive),
        ManifestComparatorDecision.sendTerminal,
      );
    });
  });

  group('双遍历对称性', () {
    test('同一对 (local, remote) 两个方法互补（戳不等时）', () {
      final local = _entry('e1', hlcPacked: _packed(3000), deviceId: 'a');
      final remote = _entry('e1', hlcPacked: _packed(2000), deviceId: 'b');
      // 本地遍历：本地更新 → 发出去
      expect(
        comparator.classifyLocalEntry(local: local, remote: remote),
        ManifestComparatorDecision.sendTerminal,
      );
      // 远端遍历：同一对 → 对端视角看到「对方（本地）更新」→ 索求
      expect(
        comparator.classifyRemoteEntry(local: local, remote: remote),
        ManifestComparatorDecision.sendTerminal,
      );
    });
  });
}
