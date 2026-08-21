import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_firebase/playground/playground.dart';

void main() {
  group('C1 · 一键回滚开关与传输配置 (PlaygroundTransportConfig & Factory)', () {
    test('默认配置严格关闭（默认走 Firestore / snapshots）', () {
      final config = PlaygroundTransportConfig.defaults();
      expect(config.feedTransport, equals(TransportMode.firestore));
      expect(config.postTransport, equals(TransportMode.firestore));
      expect(config.realtimeMode, equals(RealtimeMode.firestoreSnapshots));
      expect(config.isRestFeedEnabled, isFalse);
      expect(config.isRestPostEnabled, isFalse);
      expect(config.isRestPollingEnabled, isFalse);
    });

    test('配置支持动态切换到 REST 并一键回滚回 Firestore', () {
      var config = PlaygroundTransportConfig.defaults();
      expect(config.isRestFeedEnabled, isFalse);

      // 切到 REST
      config = config.copyWith(
        feedTransport: TransportMode.rest,
        postTransport: TransportMode.rest,
        realtimeMode: RealtimeMode.restPolling,
      );
      expect(config.isRestFeedEnabled, isTrue);
      expect(config.isRestPostEnabled, isTrue);
      expect(config.isRestPollingEnabled, isTrue);

      // 一键回滚
      final rollbacked = config.rollbackToFirestore();
      expect(rollbacked.feedTransport, equals(TransportMode.firestore));
      expect(rollbacked.postTransport, equals(TransportMode.firestore));
      expect(rollbacked.realtimeMode, equals(RealtimeMode.firestoreSnapshots));
      expect(rollbacked.isRestFeedEnabled, isFalse);
    });

    test('PlaygroundRepositoryFactory 根据配置动态切换底层实现', () {
      final factory = PlaygroundRepositoryFactory();
      expect(factory.currentConfig.feedTransport, equals(TransportMode.firestore));

      // 默认走 Firestore 模式
      expect(factory.isRollbacked, isTrue);

      // 动态切换
      factory.updateConfig(factory.currentConfig.copyWith(
        feedTransport: TransportMode.rest,
        postTransport: TransportMode.rest,
        realtimeMode: RealtimeMode.restPolling,
      ));
      expect(factory.currentConfig.feedTransport, equals(TransportMode.rest));
      expect(factory.isRollbacked, isFalse);

      // 一键回滚
      factory.rollback();
      expect(factory.currentConfig.feedTransport, equals(TransportMode.firestore));
      expect(factory.isRollbacked, isTrue);
    });
  });
}
