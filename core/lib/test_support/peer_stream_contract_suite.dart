/// 共享 PeerStream 背压契约套件（S3c-c-pre，供 S3c-c 的 WebRTC / LAN socket
/// 实现直接复用）。
///
/// 【为什么存在】`PeerStream` 的背压契约 —— 发送侧有界（bufferedAmount /
/// overflowPolicy）、接收侧 pause() 传导、一条流不得饿死另一条流 —— 是任何
/// 将来传输实现都必须遵守的。提取成套件后，本轮的两个内存 fake 与以后
/// WebRTC / LAN socket 实现跑**同一套断言**，契约的约束不会各写各的。
///
/// 【签名为什么是 `makeSession` 而不是 `makeStream`】A6（一条流不得饿死
/// 另一条流）要求两条流出现在**同一条会话**上，只注入「单流工厂」写不出
/// A6。这与 signaling 套件注入 `makePair`（同一织物上相遇）同因：契约要求
/// 跨成员的关系时，注入的工厂必须能产生这种关系。两条流通过
/// `caller.openStream(kind)` + `callee.incomingStreams` 配对 —— 因此套件
/// 约定：**先预订阅 `callee.incomingStreams`，再 `openStream`**（入站流
/// 是 broadcast，不回放已 add 的事件）。
///
/// 【等待方式】沿用 signaling 套件 D5：正向断言 `await` 真实可观测量本身 +
/// 显式 timeout；负向断言（断言 send 挂起 / 不完成）用有界宽限期
/// [negativeAssertionGrace]，且该常量按拓扑注入（内存 fake 给几十毫秒，
/// socket 给几百毫秒）。
///
/// 【为什么按 `overflowPolicy` 分支而非各写一条测试】契约固定两种明文策略
/// （wait / fail），每个实现运行时自报选哪一种（决定记录 D2）。套件对两种
/// 策略都断言正确的行为，任一 fake 只命中自己的策略分支。
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/storage_error.dart';
import 'package:persistence_core/model/transport.dart';

/// 一对已认证的连接：caller 是主动拨号侧，callee 是接听侧。
typedef PeerSessionPair = ({PeerSession caller, PeerSession callee});

/// 正向断言的可观测超时：等待 send 完成 / 对端消费生效的上限。
///
/// 取 5 秒：内存 fake 全同步级，真实 socket 在 loopback 上也是亚毫秒级，
/// 5 秒只兜「实现坏了」的情况。
const Duration _positiveObservableTimeout = Duration(seconds: 5);

/// 契约测试用的一段固定字节（64B）。
final List<int> _chunk = List<int>.filled(64, 0xAB);

/// 在指定拓扑下运行全部 PeerStream 背压契约测试。
///
/// 参数说明：
/// - [topologyName]: 拓扑名，只用于测试分组展示。
/// - [makeSession]: 构造一对已认证连接。**必须能开多条逻辑流**，且
///   `caller.openStream` 的结果能在 `callee.incomingStreams` 上按开流顺序
///   配对。
/// - [negativeAssertionGrace]: 负向断言（断言 send 挂起 / 不完成）的
///   有界宽限期。**必须按拓扑注入**：内存 fake 给几十毫秒（如 50ms），
///   真实 socket 给几百毫秒（如 300ms）—— 太短会假红，太长会拖慢真实
///   拓扑。
FutureOr<void> runPeerStreamContractSuite({
  required String topologyName,
  required FutureOr<PeerSessionPair> Function() makeSession,
  Duration negativeAssertionGrace = const Duration(milliseconds: 50),
}) {
  group('契约 · $topologyName', () {
    // ── A4：发送侧有界 ──
    test('A4 · 发送侧有界：对端不消费时，触顶行为按 overflowPolicy 发生',
        () async {
      final pair = await makeSession();

      // 先预订阅对端入站流，再开流 —— broadcast 不回放已 add 的事件。
      final receiverFuture = pair.callee.incomingStreams.first
          .timeout(_positiveObservableTimeout);
      final sender = await pair.caller.openStream(StreamKind.blobChunk);
      final receiver = await receiverFuture;

      expect(sender.maxBufferedAmount, greaterThan(0),
          reason: '背压上限必须为正，否则「有界」无从谈起');
      expect(sender.bufferedAmount, 0,
          reason: '新建流的发送水位必须从零开始');

      // 压满：对端不消费（不订阅 receiver.incoming）。
      await _pressureUntilFull(sender);
      expect(
        sender.bufferedAmount,
        greaterThanOrEqualTo(sender.maxBufferedAmount),
        reason: '压满循环后水位必须确实触顶',
      );

      if (sender.overflowPolicy == OverflowPolicy.wait) {
        // 入口已满：再 send 一条必须挂起（负向，有界宽限期）。
        final blocked = sender.send(_chunk);
        await expectLater(
          blocked.timeout(negativeAssertionGrace),
          throwsA(isA<TimeoutException>()),
          reason: 'wait 策略：缓冲已满时 send 必须挂起，不得立即返回',
        );

        // 对端开始消费 → 水位下降 → 挂起的 send 恢复完成。
        final sub = receiver.incoming.listen((_) {});
        await blocked.timeout(_positiveObservableTimeout);
        expect(sender.bufferedAmount, lessThan(sender.maxBufferedAmount),
            reason: '对端消费后水位必须降到上限以下，send 才能恢复');
        await sub.cancel();
      } else {
        expect(sender.overflowPolicy, OverflowPolicy.fail,
            reason: 'overflowPolicy 必须是契约允许的两种策略之一');
        // 触顶后 send 必须抛背压溢出错误（StorageError 子类）。
        await expectLater(
          sender.send(_chunk),
          throwsA(isA<BackpressureOverflowError>()),
          reason: 'fail 策略：缓冲已满时 send 必须抛 '
              'BackpressureOverflowError，不得静默接受',
        );
      }
    });

    // ── A5：接收侧 pause() 传导 ──
    test('A5 · 接收侧 pause() 传导到发送侧，resume() 后恢复', () async {
      final pair = await makeSession();

      final receiverFuture = pair.callee.incomingStreams.first
          .timeout(_positiveObservableTimeout);
      final sender = await pair.caller.openStream(StreamKind.oplog);
      final receiver = await receiverFuture;

      final sub = receiver.incoming.listen((_) {});

      // 正常消费中：发送畅通，水位不触顶。
      await sender.send(_chunk);
      await sender.send(_chunk);
      expect(sender.bufferedAmount, lessThan(sender.maxBufferedAmount),
          reason: '正常消费中水位不应触顶');

      // 订阅者 pause() → 压力必须传导到发送侧（对端停止消费）。
      sub.pause();
      await _pressureUntilFull(sender);
      expect(
        sender.bufferedAmount,
        greaterThanOrEqualTo(sender.maxBufferedAmount),
        reason: 'pause 后持续发送必须能把水位推上顶 —— 这就是「传导」',
      );

      if (sender.overflowPolicy == OverflowPolicy.wait) {
        final blocked = sender.send(_chunk);
        await expectLater(
          blocked.timeout(negativeAssertionGrace),
          throwsA(isA<TimeoutException>()),
          reason: 'A5 · pause 后 wait 策略 send 必须挂起，'
              '证明背压真实传导到发送侧',
        );
        // resume() → 恢复消费 → 挂起的 send 完成。
        sub.resume();
        await blocked.timeout(_positiveObservableTimeout);
      } else {
        await expectLater(
          sender.send(_chunk),
          throwsA(isA<BackpressureOverflowError>()),
          reason: 'A5 · pause 后 fail 策略 send 必须抛错，'
              '证明背压真实传导到发送侧',
        );
        // resume() → 恢复消费 → 发送恢复。
        sub.resume();
        await sender.send(_chunk).timeout(_positiveObservableTimeout);
      }

      await sub.cancel();
    });

    // ── A6：一条流不得饿死另一条流（方案 C 的核心）──
    test('A6 · 一条流不得饿死另一条流（blob 压满时 oplog 照常发送）',
        () async {
      final pair = await makeSession();

      // 先订阅收集入站流，再依次开两条流（入站顺序 == 开流顺序）。
      final got = <PeerStream>[];
      final collectSub = pair.callee.incomingStreams.listen(got.add);

      final blobSender = await pair.caller.openStream(StreamKind.blobChunk);
      final oplogSender = await pair.caller.openStream(StreamKind.oplog);
      await _eventually(() => got.length >= 2);
      // got[0] 是 blob 流（callee 侧）——故意不订阅它的 incoming，即
      // blob 侧持续不消费；got[1] 是 oplog 流。
      final oplogReceiver = got[1];

      // oplog 流保持消费中（模拟 SyncPeer 正常工作）。
      final oplogSub = oplogReceiver.incoming.listen((_) {});

      // 压满 blob 流：对端不消费 blobReceiver.incoming。
      await _pressureUntilFull(blobSender);
      expect(
        blobSender.bufferedAmount,
        greaterThanOrEqualTo(blobSender.maxBufferedAmount),
        reason: 'blob 流必须确实被压满，测试才有效',
      );

      // oplog 流不得被 blob 的背压饿死：send 必须在正向超时内完成。
      await oplogSender.send(_chunk).timeout(_positiveObservableTimeout);
      await oplogSender.send(_chunk).timeout(_positiveObservableTimeout);
      await oplogSender.send(_chunk).timeout(_positiveObservableTimeout);

      await oplogSub.cancel();
      await collectSub.cancel();
    });

    // ── 结构守卫：溢出策略是封闭枚举，不许悄悄加第三种 ──
    test('overflowPolicy 只允许 wait / fail 两种', () async {
      expect(
        OverflowPolicy.values.map((e) => e.name),
        ['wait', 'fail'],
        reason: '溢出策略是封闭枚举；新增策略必须先过决定记录再改套件',
      );
      final pair = await makeSession();
      final sender = await pair.caller.openStream(StreamKind.oplog);
      expect(
        sender.overflowPolicy,
        anyOf(OverflowPolicy.wait, OverflowPolicy.fail),
        reason: '实现必须自报契约允许的策略之一',
      );
    });
  });
}

/// 持续 [send] 直到流的 `bufferedAmount >= maxBufferedAmount`（压满）。
///
/// 对两种策略都安全：
/// - wait：`send` 的入口检查语义（仅当 `bufferedAmount >= maxBufferedAmount`
///   时挂起）保证压满循环 `bufferedAmount < max` 时 send 立即返回，不会
///   死锁；触顶后循环退出。次数上限 10 万次兜底：若实现异常导致水位永远
///   触不了顶（如忽略 pause、消费持续确认），循环也会终止而不是挂死测试。
/// - fail：触顶后 send 抛错，catch 后视为已触顶。
Future<void> _pressureUntilFull(PeerStream stream) async {
  final max = stream.maxBufferedAmount;
  for (var i = 0; i < 100000 && stream.bufferedAmount < max; i++) {
    if (stream.overflowPolicy == OverflowPolicy.wait) {
      await stream.send(_chunk);
    } else {
      try {
        await stream.send(_chunk);
      } on StorageError {
        return;
      }
    }
  }
}

/// 轮询等待 [condition] 为真，超时则 fail。
///
/// 用于「入站流收集到 N 条」这类没有现成 Future 可 await 的异步条件。
Future<void> _eventually(bool Function() condition) async {
  final deadline = DateTime.now().add(_positiveObservableTimeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('等待条件超时：$_positiveObservableTimeout');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}
