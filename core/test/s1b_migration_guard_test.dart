import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/sync_peer.dart';
import 'package:persistence_core/model/types.dart';
import 'package:persistence_core/routing/region.dart';
import 'package:persistence_core/routing/remote_gateway_router.dart';

/// ACT 02 迁移守卫：单 peer 网关 → SyncPeer 全量迁移。
///
/// ⚠ 本文件【不得】出现字面量 `Remote` + `Gateway` 拼接的完整标识符 ——
/// ACT 02 的 VERIFICATION 会 grep 整个 core/test 目录，守卫测试自身
/// 含该标识符会让门禁误报。因此本文件用 [_banned] 常量拼接生成。
void main() {
  group('单 peer 网关标识符绝迹', () {
    test('no_remote_gateway_identifier_left_anywhere', () {
      final scanned = _scanForBareIdentifier();
      // 下限自检：扫到的 .dart 文件数必须 >= 写死下限（2026-08-02 实测 179）。
      // 没有下限，glob 写错导致一个文件都没扫到时门禁会静默全绿（S1a 的教训）。
      expect(scanned.fileCount, greaterThanOrEqualTo(150),
          reason: '扫描到的文件数异常偏少（${scanned.fileCount}），可能 glob 写错');

      expect(scanned.violations, isEmpty,
          reason: '仍存在 $_banned 标识符:\n${scanned.violations.join('\n')}');

      // 三个保留类名必须仍然存在（类名一个都不能改）。
      for (final needle in const [
        'class RemoteGatewayRouter implements SyncPeer',
        'class FirestoreRemoteGateway implements SyncPeer',
        'class FirebaseRealtimeRemoteGateway implements SyncPeer',
      ]) {
        expect(scanned.allContent.any((c) => c.contains(needle)), isTrue,
            reason: '找不到 $needle —— 类名或 implements 被改坏了');
      }
    });
  });

  group('三个实现者都是 SyncPeer 且 peerId 稳定', () {
    test('three_implementors_are_sync_peer_with_stable_ids', () async {
      // router 是代理：身份跟随当前 region。
      var current = Region.firebase;
      final router = RemoteGatewayRouter(
        gateways: {
          Region.firebase: _FakePeer(PeerId('firestore'), Channel.cloud),
          Region.supabase: _FakePeer(PeerId('supabase'), Channel.cloud),
        },
        currentRegion: () => current,
      );

      expect(router, isA<SyncPeer>());
      expect(router.peerId, PeerId('firestore'));
      expect(router.channel, Channel.cloud);

      current = Region.supabase;
      expect(router.peerId, PeerId('supabase'));

      // 两个 firebase 实现的 peerId 字面量必须逐字等于 ACT 03 的 ack 表行键。
      // 以纯文本读源文件断言，不构造实例（构造需要真实 SDK 初始化）。
      final container = _locateContainerDir(
        probe: const ['drift', 'firebase'],
        start: Directory.current,
      );
      expect(container, isNotNull, reason: '无法定位容器目录');

      final firestoreSrc = File(
        '${container!.path}/firebase/lib/persistence_firebase.dart',
      ).readAsStringSync();
      final realtimeSrc = File(
        '${container.path}/firebase/lib/firebase_realtime_remote_gateway.dart',
      ).readAsStringSync();

      expect(firestoreSrc, contains("PeerId('firestore')"),
          reason: 'FirestoreRemoteGateway.peerId 字面量必须为 firestore');
      expect(realtimeSrc, contains("PeerId('firebase_realtime')"),
          reason: 'FirebaseRealtimeRemoteGateway.peerId 字面量必须为 firebase_realtime');
    });
  });

  group('getCapabilities 不得抛异常', () {
    test('get_capabilities_never_throws', () async {
      final router = RemoteGatewayRouter(
        gateways: {
          Region.firebase: _FakePeer(PeerId('firestore'), Channel.cloud),
        },
        currentRegion: () => Region.firebase,
      );

      for (final SyncPeer peer in [router, _FakePeer(PeerId('a'), Channel.lan)]) {
        final caps = await peer.getCapabilities();
        expect(caps, isA<PeerCapabilities>());
        // 返回值的 peerId 必须与该实现的 peerId 一致（不是随便填的）。
        expect(caps.peerId, peer.peerId);
        expect(caps.channel, peer.channel);
      }
    });
  });

  group('router 仍是 1-of-N 选择器（行为不变守卫）', () {
    test('router_still_selects_one_of_n_not_fanout', () async {
      final fb = _CountingPeer(PeerId('firestore'));
      final sb = _CountingPeer(PeerId('supabase'));
      var current = Region.firebase;

      final router = RemoteGatewayRouter(
        gateways: {
          Region.firebase: fb,
          Region.supabase: sb,
        },
        currentRegion: () => current,
      );

      await router.push(_sampleRecord('op-1'));

      expect(fb.pushCount, 1);
      expect(sb.pushCount, 0);

      current = Region.supabase;
      await router.push(_sampleRecord('op-2'));
      expect(fb.pushCount, 1);
      expect(sb.pushCount, 1);
    });
  });
}

/// 被禁标识符，用拼接避免本文件自身命中门禁。
const _banned = 'Remote' 'Gateway';

/// 扫描结果：文件总数 + 违规清单 + 全部内容（供类名白名单检查）。
class _ScanResult {
  _ScanResult(this.fileCount, this.violations, this.allContent);

  final int fileCount;
  final List<String> violations;
  final List<String> allContent;
}

/// 扫描 core/lib、core/test、drift/test、firebase/lib、firebase/test 下的全部
/// .dart 文件，找出单独出现的 `Remote` + `Gateway` 标识符（排除三个保留类名）。
_ScanResult _scanForBareIdentifier() {
  final container = _locateContainerDir(
    probe: const ['drift', 'firebase'],
    start: Directory.current,
  );
  expect(container, isNotNull, reason: '无法定位容器目录');

  final roots = <String>[
    '${container!.path}/core/lib',
    '${container.path}/core/test',
    '${container.path}/drift/test',
    '${container.path}/firebase/lib',
    '${container.path}/firebase/test',
  ];

  // 正则：标识符单独出现，且不是三个保留类名的一部分。
  // \b 不会匹配 RemoteGatewayRouter（后面还有词字符），
  // 但会匹配 FirestoreRemoteGateway / FirebaseRealtimeRemoteGateway 的子串，
  // 所以再排除"前面紧跟一个词字符"的情况。
  final bare = RegExp('(?<![A-Za-z0-9_])$_banned\\b');

  final violations = <String>[];
  final allContent = <String>[];
  var count = 0;

  for (final root in roots) {
    final dir = Directory(root);
    if (!dir.existsSync()) {
      violations.add('目录不存在: $root');
      continue;
    }
    final files = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();
    count += files.length;
    for (final f in files) {
      final content = f.readAsStringSync();
      allContent.add(content);
      for (final m in bare.allMatches(content)) {
        final line = content.substring(0, m.start).split('\n').last;
        violations.add('${f.path}: $line');
      }
    }
  }
  return _ScanResult(count, violations, allContent);
}

/// 从 [start] 逐级向上找同时包含 [probe] 全部子目录的那一级（容器目录）。
///
/// 照抄 firebase 边界测试的定位方式：不写死相对层数，worktree 深浅都能用。
/// 找不到返回 null（不抛异常）。
Directory? _locateContainerDir({
  required List<String> probe,
  required Directory start,
}) {
  var dir = start;
  while (true) {
    final found = probe.every((p) => Directory('${dir.path}/$p').existsSync());
    if (found) return dir;
    final parent = dir.parent;
    if (parent.path == dir.path) return null; // 到文件系统根仍未命中
    dir = parent;
  }
}

/// 计数式 fake peer：记录 push 调用次数（不用 fail()——catch-all 会吞 TestFailure）。
class _CountingPeer implements SyncPeer {
  _CountingPeer(this.peerId);

  @override
  final PeerId peerId;

  int pushCount = 0;

  @override
  Channel get channel => Channel.cloud;

  @override
  Future<SyncError?> push(OutboxRecord record) async {
    pushCount++;
    return null;
  }

  @override
  Future<RemoteChangesPage> listChanges({
    required String scopeUid,
    required String entityType,
    required PullCursor? sinceCursor,
    required int limit,
  }) async {
    return RemoteChangesPage(changes: const [], nextCursor: null, hasMore: false);
  }

  @override
  Future<PeerCapabilities> getCapabilities() async {
    return PeerCapabilities(
      peerId: peerId,
      channel: channel,
      entityVersions: const {},
      supportedFeatures: const {},
      protocolVersion: 1,
    );
  }
}

/// 返回固定身份的最小 fake peer。
class _FakePeer implements SyncPeer {
  _FakePeer(this.peerId, this.channel);

  @override
  final PeerId peerId;

  @override
  final Channel channel;

  @override
  Future<SyncError?> push(OutboxRecord record) async => null;

  @override
  Future<RemoteChangesPage> listChanges({
    required String scopeUid,
    required String entityType,
    required PullCursor? sinceCursor,
    required int limit,
  }) async {
    return RemoteChangesPage(changes: const [], nextCursor: null, hasMore: false);
  }

  @override
  Future<PeerCapabilities> getCapabilities() async {
    return PeerCapabilities(
      peerId: peerId,
      channel: channel,
      entityVersions: const {},
      supportedFeatures: const {},
      protocolVersion: 1,
    );
  }
}

OutboxRecord _sampleRecord(String operationId) {
  return OutboxRecord(
    operationId: operationId,
    scopeUid: 'scope-1',
    entityType: 'record',
    entityId: 'entity-1',
    opType: 'upsert',
    payloadJson: '{}',
    createdAtUtc: DateTime.utc(2026, 8, 2),
    attempt: 0,
  );
}
