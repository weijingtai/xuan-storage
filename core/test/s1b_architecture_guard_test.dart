import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';

/// S1b 架构守卫：把本任务确立的不变式变成可执行测试。
void main() {
  group('barrel 导出', () {
    test('barrel_exports_all_new_public_api', () {
      // 只 import barrel，为每个新增文件引用其独有的公开类型。
      // 编译通过即证明 barrel 完整；遗漏任一条则该类型未定义，编译失败。
      expect(SyncPeer, isNotNull); // sync_peer.dart
      expect(PeerCapabilities, isNotNull); // sync_peer.dart
      expect(PeerId, isNotNull); // sync_peer.dart
      expect(PeerFanoutPusher, isNotNull); // sync_peer.dart
      expect(VersionStamp, isNotNull); // conflict_arbiter.dart
      expect(ArbitrationDecision, isNotNull); // conflict_arbiter.dart
      expect(ConflictArbiter, isNotNull); // conflict_arbiter.dart
      expect(ConflictSide, isNotNull); // types.dart
      expect(DefaultPeerFanoutPusher, isNotNull); // peer_fanout_pusher.dart
      expect(PeerEligibility, isNotNull); // peer_eligibility.dart
      expect(PeerRegistry, isNotNull); // peer_registry.dart
      expect(HlcClock, isNotNull); // hlc_clock.dart
    });

    test('barrel_existing_lines_intact', () async {
      final src = await File('lib/persistence_core.dart').readAsString();
      // S1a 交付的既有 export 逐行仍在
      for (final f in const [
        'model/storage_classification.dart',
        'model/storage_policy.dart',
        'model/storage_policy_registry.dart',
        'model/transport.dart',
        'model/export_bundle.dart',
        'model/blob_types.dart',
      ]) {
        expect(src.contains("export '$f';"), isTrue,
            reason: 'S1a 的 export $f 必须仍在');
      }
      // 新增的 6 行各恰好一次
      for (final f in const [
        'model/sync_peer.dart',
        'model/peer_eligibility.dart',
        'routing/peer_fanout_pusher.dart',
        'sync/peer_registry.dart',
        'sync/hlc_clock.dart',
        'model/conflict_arbiter.dart',
      ]) {
        final n = "export '$f';".allMatches(src).length;
        expect(n, 1, reason: 'export $f 必须恰好出现一次，实际 $n');
      }
      // 不得导出测试用 fake
      expect(src.contains('test_support'), isFalse,
          reason: '不得导出 test_support（fake 不是产品 API）');
    });
  });

  group('六个阻断点收口', () {
    test('six_blockers_are_all_removed', () async {
      final driftSrc =
          await File('../drift/lib/persistence_drift.dart').readAsString();
      final portsSrc = await File('lib/model/ports.dart').readAsString();
      final syncPeerSrc = await File('lib/model/sync_peer.dart').readAsString();
      final fanoutPath = File('lib/routing/peer_fanout_pusher.dart');
      final fanoutSrc = fanoutPath.existsSync()
          ? await fanoutPath.readAsString()
          : '';

      final checks = <String, bool>{
        // ① t_outbox_peer_ack 表存在
        '① t_outbox_peer_ack 表存在': driftSrc.contains('t_outbox_peer_ack'),
        // ② t_sync_state 主键含 peerId
        '② t_sync_state 主键三元组': driftSrc.contains('{scopeUid, peerId, entityType}'),
        // ③ markSuccess 带 peerId
        '③ markSuccess 带 peerId': portsSrc.contains('required PeerId peerId'),
        // ④ pushToAll 带 eligiblePeers
        '④ pushToAll 带 eligiblePeers':
            syncPeerSrc.contains('required Set<PeerId> eligiblePeers'),
        // ⑤ fan-out 实现存在
        '⑤ fan-out 实现存在':
            fanoutSrc.isNotEmpty && fanoutSrc.contains('Future.wait'),
        // ⑥ PeerCapabilities 取代旧网关标识
        '⑥ PeerCapabilities 存在': syncPeerSrc.contains('PeerCapabilities'),
      };

      for (final entry in checks.entries) {
        expect(entry.value, isTrue, reason: '阻断点未拆除: ${entry.key}');
      }
    });
  });

  group('策略与定序守卫', () {
    test('fail_closed_semantics_preserved', () async {
      final src =
          await File('test/policy_channel_filter_test.dart').readAsString();
      expect(src.contains('if (p == null) return false;'), isTrue,
          reason: 'S1a 的可执行规格 fail-closed 必须原样保留');
    });

    test('no_wall_clock_in_conflict_path', () async {
      final src =
          await File('lib/model/conflict_arbiter.dart').readAsString();
      // 包级守卫：定序路径不得有墙上时钟兜底
      expect(src.contains('.now()'), isFalse);
      expect(src.contains('updatedAt'), isFalse);
    });
  });

  group('既有测试计数', () {
    test('existing_test_counts_do_not_regress', () async {
      // 扫 core/test 与 drift/test 下【S1b 之前就存在】的测试文件，
      // 断言 test(/testWidgets( 总数 >= 实测下限，且不含 skip。
      // 2026-08-04 实测：core 88 / drift 293（合并 main 后），下限留余量。
      int countIn(String dir, List<String> excluded) {
        var total = 0;
        for (final f in Directory(dir).listSync(recursive: true).whereType<File>()) {
          if (!f.path.endsWith('.dart')) continue;
          final name = f.path.split('/').last;
          if (excluded.any(name.startsWith)) continue;
          final content = f.readAsStringSync();
          if (!content.contains('test(') && !content.contains('testWidgets(')) {
            continue;
          }
          total += RegExp(r'test\(|testWidgets\(').allMatches(content).length;
        }
        return total;
      }

      final coreCount = countIn('test', const [
        's1b_',
        'policy_channel_filter',
        's1a_dartdoc_coverage',
      ]);
      final driftCount = countIn('../drift/test', const [
        's1b_',
        'peek_batch_channel_filter',
        'hlc_stamp_store',
        'record_local_applier_conflict',
      ]);

      expect(coreCount, greaterThanOrEqualTo(80),
          reason: 'core 既有测试数 $coreCount 低于下限 80（防删测试）');
      expect(driftCount, greaterThanOrEqualTo(270),
          reason: 'drift 既有测试数 $driftCount 低于下限 270（防删测试）');

      // 不得有 skip 标记
      for (final f in Directory('test').listSync(recursive: true).whereType<File>()) {
        if (!f.path.endsWith('.dart')) continue;
        final name = f.path.split('/').last;
        if (name.startsWith('s1b_')) continue;
        final content = f.readAsStringSync();
        expect(content.contains('skip:'), isFalse,
            reason: '${f.path} 不应含 skip:');
        expect(content.contains(', skip'), isFalse,
            reason: '${f.path} 不应含 , skip');
      }
    });
  });

  group('dartdoc 覆盖', () {
    test('chinese_dartdoc_on_new_public_declarations', () async {
      // 照抄 s1a_dartdoc_coverage_test 的通用式正则。
      final files = const [
        '../core/lib/model/sync_peer.dart',
        '../core/lib/model/peer_eligibility.dart',
        '../core/lib/model/conflict_arbiter.dart',
        '../core/lib/routing/peer_fanout_pusher.dart',
        '../core/lib/sync/peer_registry.dart',
        '../core/lib/sync/hlc_clock.dart',
        '../core/lib/test_support/in_memory_stores.dart',
        '../core/lib/model/ports.dart',
      ];

      final topLevel = RegExp(
        r'^(?:enum |class |final class |sealed class |abstract interface class '
        r'|abstract final class |typedef )',
      );
      final member = RegExp(
        r'^  (?:'
        r'static [A-Za-z_][A-Za-z0-9_<>?,()\[\]{} ]* (?:get [a-z]\w*|[a-z]\w*\()'
        r'|[A-Za-z_][A-Za-z0-9_<>?,()\[\]{} ]* get [a-z]\w*'
        r'|[A-Za-z_][A-Za-z0-9_<>?,()\[\]{} ]* [a-z]\w*\('
        r'|const factory [A-Z][A-Za-z0-9]*\.[a-z]\w*\('
        r'|const [A-Z][A-Za-z0-9]*(?!\.)\('
        r'|(?:static (?:final|const)|final) '
        r'[A-Za-z_][A-Za-z0-9_<>?,()\[\]{} ]* [a-z]\w*(?:;| =)'
        r')',
      );
      final cjk = RegExp(r'[\u4e00-\u9fff]');

      final failures = <String>[];
      var memberCount = 0;
      final scannedFiles = <String>{};

      for (final path in files) {
        scannedFiles.add(path);
        final lines = File(path).readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (!topLevel.hasMatch(line) && !member.hasMatch(line)) {
            continue;
          }
          if (member.hasMatch(line)) {
            memberCount++;
          }
          final docs = <String>[];
          var j = i - 1;
          while (j >= 0) {
            final t = lines[j].trim();
            if (t.isEmpty || t.startsWith('@')) {
              j--;
              continue;
            }
            if (t.startsWith('///')) {
              docs.add(t);
              j--;
              continue;
            }
            break;
          }
          if (docs.isEmpty || !docs.any(cjk.hasMatch)) {
            failures.add('$path:${i + 1}: $line');
          }
        }
      }

      // 必须扫满 8 个文件（路径列表漏一个不会报错）
      expect(scannedFiles.length, 8, reason: 'dartdoc 扫描必须覆盖全部 8 个文件');

      // 覆盖数下限：实测后写死，防止正则被改窄。
      const minMemberDeclarations = 30;
      expect(memberCount, greaterThanOrEqualTo(minMemberDeclarations),
          reason: 'member 声明总数 $memberCount 低于下限 $minMemberDeclarations');

      if (failures.isNotEmpty) {
        fail('以下公开声明缺中文 dartdoc：\n${failures.join('\n')}');
      }
    });
  });
}
