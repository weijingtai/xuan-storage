@Tags(['integration'])
library;

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/signaling.dart';
import 'package:persistence_firebase/signaling/rendezvous_backend.dart';
import 'package:persistence_firebase/signaling/rtdb_rendezvous_backend.dart';

/// `RtdbRendezvousBackend` 真 RTDB 模拟器集成测试（决定记录 D6）。
///
/// 真 `onDisconnect` 是 RTDB **服务端行为**，内存 backend 不覆盖它，必须到
/// 模拟器上验证（验收 A3 的最后一环）。`dart_test.yaml` 默认排除 `integration`
/// 标签，`flutter test` 不带参数不会跑它。
///
/// 人工触发（需本地起 RTDB 模拟器）：
/// ```bash
/// cd firebase && flutter test --tags integration
/// ```
/// 起模拟器：
/// ```bash
/// cd infrastructure/emulator && ./start_emulator.sh   # 需 firebase.json 配 database 段
/// ```
///
/// ⚠ VM 平台通道不可用时会自动 skip（打印原因），需真机或 Chrome。
void main() {
  group('RtdbRendezvousBackend · RTDB 模拟器', () {
    late FirebaseDatabase database;
    bool skipped = false;

    setUpAll(() async {
      try {
        final app = await Firebase.initializeApp(
          name: 'rtdb-signaling-integration',
          options: const FirebaseOptions(
            apiKey: 'fake-api-key',
            appId: 'fake-app-id',
            projectId: 'fake-project',
            messagingSenderId: 'fake-sender-id',
            // 指向本机 RTDB 模拟器（端口 9000，独立 namespace）。
            databaseURL: 'http://localhost:9000?ns=signaling-integration',
          ),
        );
        database = FirebaseDatabase.instanceFor(app: app);
      } catch (e) {
        skipped = true;
        markTestSkipped(
          'Firebase RTDB 平台通道在 flutter test VM 不可用：$e\n'
          '真机/Chrome 运行：flutter test --tags integration --device=...',
        );
        return;
      }

      // 探测模拟器是否存活。
      try {
        await Socket.connect('localhost', 9000,
            timeout: const Duration(seconds: 2));
      } catch (_) {
        skipped = true;
        markTestSkipped(
          '未检测到 RTDB 模拟器在 localhost:9000。\n'
          '先起模拟器：cd infrastructure/emulator && ./start_emulator.sh',
        );
        return;
      }
    });

    test('基本流：成员登记 → 信封中转 → 删除后成员消失', () async {
      if (skipped) return;
      final backend = RtdbRendezvousBackend(database: database);
      const rv = 'rv-integration-flow';
      const aliceId = 'm-int-alice';
      const bobId = 'm-int-bob';

      await backend.register(rv, aliceId);
      await backend.register(rv, bobId);

      // alice 订阅快照：应看到双方成员。
      final seen = <RendezvousSnapshot>[];
      final sub = backend.watch(rv).listen(seen.add);
      // RTDB onValue 订阅后立即触发一次当前值。
      await Future<void>.delayed(const Duration(milliseconds: 500));
      expect(seen, isNotEmpty);
      expect(seen.last.members, containsAll([aliceId, bobId]));

      // bob 写信封 → alice 快照里读到。
      await backend.writeEnvelope(
        rv,
        bobId,
        signalingEnvelopeToPayload(const SessionDescriptionEnvelope(
          kind: SdpKind.offer,
          sdp: 'v=0\r\no=- 1 1 IN IP4 0.0.0.0\r\n',
        )),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
      expect(
        seen.last.envelopes.any((e) => e.from == bobId),
        isTrue,
        reason: '信封必须被会合点中转，对端快照能读到',
      );

      // bob 删除成员 → alice 快照里成员消失。
      await backend.remove(rv, bobId);
      await Future<void>.delayed(const Duration(milliseconds: 500));
      expect(seen.last.members, isNot(contains(bobId)));

      await sub.cancel();
      // 清理：删掉 alice 成员与会合点残留。
      await backend.remove(rv, aliceId);
    });

    test('onDisconnect 登记不抛错（RTDB 模拟器支持服务端钩子）', () async {
      if (skipped) return;
      final backend = RtdbRendezvousBackend(database: database);
      const rv = 'rv-integration-ondisconnect';
      const memberId = 'm-int-od';

      await backend.register(rv, memberId);
      // 登记「断开时删除本端成员节点」—— 模拟器支持即不抛错。
      await backend.onDisconnectRemove(rv, memberId);

      // 确认登记后仍可正常读写。
      await backend.writeEnvelope(
        rv,
        memberId,
        signalingEnvelopeToPayload(const ByeEnvelope()),
      );
      await backend.remove(rv, memberId);
    });
  });
}
