@Tags(['integration'])
library;

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/signaling.dart';
import 'package:persistence_firebase/signaling/rendezvous_backend.dart';
import 'package:persistence_firebase/signaling/rtdb_rendezvous_backend.dart';

/// `RtdbRendezvousBackend` 真 RTDB 模拟器集成测试（**冒烟占位**，验收 R8）。
///
/// 真 `onDisconnect` 是 RTDB **服务端行为**，内存 backend 不覆盖它。本测试只在
/// 本机起 RTDB 模拟器时才有意义；起不来（无模拟器 / 平台通道不可用）时两条
/// 都报 **SKIPPED**（`markTestSkipped`），**不许报 PASSED**（验收 R3）。
///
/// 【A3 的服务端事实由谁保证】「服务端 onDisconnect 真的删成员节点」这一环在
/// 本仓由窄端口 + 内存 backend 的「已登记删除」语义 + 契约套件「A4 · 非正常
/// 断开产出 departed」保证。本集成测试只冒烟验证后端在真实 RTDB 上读写不抛错，
/// **不**声称验证了服务端断开删除（那需要真实断连 + 第二连接观察，超出单进程
/// 测试能力）—— 见决定记录「集成测试」段。
///
/// 人工触发（需本地起 RTDB 模拟器）：
/// ```bash
/// cd firebase && flutter test --tags integration --run-skipped
/// ```
/// 起模拟器：
/// ```bash
/// cd infrastructure/emulator && ./start_emulator.sh
/// ```
///
/// ⚠ VM 平台通道不可用时会报 SKIPPED（打印原因），需真机或 Chrome。
void main() {
  group('RtdbRendezvousBackend · RTDB 模拟器', () {
    late FirebaseDatabase database;
    String? skipReason;

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
        skipReason =
            'Firebase RTDB 平台通道在 flutter test VM 不可用：$e\n'
            '真机/Chrome 运行：flutter test --tags integration --device=...';
        return;
      }

      // 探测模拟器是否存活。
      try {
        await Socket.connect('localhost', 9000,
            timeout: const Duration(seconds: 2));
      } catch (_) {
        skipReason = '未检测到 RTDB 模拟器在 localhost:9000。\n'
            '先起模拟器：cd infrastructure/emulator && ./start_emulator.sh';
        return;
      }
    });

    test('冒烟 · 成员登记 → 信封中转 → 删除后成员消失', () async {
      if (skipReason != null) {
        markTestSkipped(skipReason!);
        return;
      }
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

    test('冒烟 · onDisconnect 登记与读写不抛错', () async {
      if (skipReason != null) {
        markTestSkipped(skipReason!);
        return;
      }
      final backend = RtdbRendezvousBackend(database: database);
      const rv = 'rv-integration-ondisconnect';
      const memberId = 'm-int-od';

      await backend.register(rv, memberId);
      // 登记「断开时删除本端成员节点」—— 冒烟：模拟器支持即不抛错。
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
