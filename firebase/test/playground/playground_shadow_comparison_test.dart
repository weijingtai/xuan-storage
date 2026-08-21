import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_firebase/playground/playground.dart';
import 'package:repository_interface_playground/repository_interface_playground.dart';

final class _FakeFeedRemoteDataSource implements PlaygroundFeedRemoteDataSource {
  _FakeFeedRemoteDataSource({required this.page});

  final PlaygroundPage<PlaygroundPost> page;

  @override
  Future<PlaygroundPage<PlaygroundPost>> getFeed(GetFeedQuery query) async => page;

  @override
  Future<PlaygroundPage<PlaygroundPost>> getRecommendedFeed(GetFeedQuery query) async => page;

  @override
  Future<PlaygroundPage<PlaygroundPost>> getPendingDivinationFeed(GetFeedQuery query) async => page;

  @override
  Future<PlaygroundPage<PlaygroundPost>> getLatestFeed(GetFeedQuery query) async => page;
}

void main() {
  group('C4 · 有鉴别力的影子比对与反例注入 (PlaygroundShadowComparator)', () {
    final baseTime = DateTime.parse('2026-08-21T10:00:00.000Z');

    final samplePostA = PlaygroundPost(
      id: const PlaygroundPostId('post-100'),
      text: '测试正文',
      authorUserId: const PlaygroundUserId('user-100'),
      status: PlaygroundPostStatus.active,
      allowedChartTechniqueIds: const ['tech-a', 'tech-b'],
      attachments: [
        PlaygroundAttachment.xuanChart(
          techniqueId: 'tech-a',
          schoolId: 'school-1',
          publicChartSnapshot: 'snap-1',
          rendererSchemaVersion: 1,
          source: PlaygroundChartSource.createdInPlayground,
        ),
      ],
      revisions: [
        PlaygroundRevision(
          body: '测试正文修订',
          editedBy: 'user-100',
          editedAt: baseTime,
        ),
      ],
      createdAt: baseTime,
      updatedAt: baseTime.add(const Duration(seconds: 10)),
      hasOutcomeFeedback: true,
    );

    test('正例：字段完全一致且时间戳在 ±1000ms 容差内判定为 Match', () {
      final postBWithTimeDrift = samplePostA.copyWith(
        createdAt: baseTime.add(const Duration(milliseconds: 500)), // +500ms 漂移
        updatedAt: baseTime.add(const Duration(seconds: 10, milliseconds: -400)), // -400ms 漂移
      );

      final result = PlaygroundShadowComparator.comparePost(samplePostA, postBWithTimeDrift);
      expect(result.isMatch, isTrue);
      expect(result.discrepancies, isEmpty);
    });

    test('正例：Feed 列表等价性比对通过', () {
      final pageA = PlaygroundPage(
        items: [samplePostA],
        nextCursor: const PlaygroundCursor('cur-1'),
        hasMore: true,
      );
      final pageB = PlaygroundPage(
        items: [samplePostA.copyWith(createdAt: baseTime.add(const Duration(milliseconds: 200)))],
        nextCursor: const PlaygroundCursor('cur-1'),
        hasMore: true,
      );

      final result = PlaygroundShadowComparator.compareFeedPage(pageA, pageB);
      expect(result.isMatch, isTrue);
      expect(result.discrepancies, isEmpty);
    });

    group('反例注入（硬性要求：证明比对具备真鉴别力，非自我克隆假双跑）', () {
      test('反例 1：正文 text 被篡改时必须断言出差异', () {
        final mutated = samplePostA.copyWith(text: '被篡改的正文！');
        final result = PlaygroundShadowComparator.comparePost(samplePostA, mutated);

        expect(result.isMatch, isFalse, reason: '正文不一致必须被影子比对拦截');
        expect(result.discrepancies, contains(contains('text')));
      });

      test('反例 2：技法列表 allowedChartTechniqueIds 缺失时必须断言出差异', () {
        final mutated = samplePostA.copyWith(allowedChartTechniqueIds: const ['tech-a']);
        final result = PlaygroundShadowComparator.comparePost(samplePostA, mutated);

        expect(result.isMatch, isFalse, reason: '技法过滤字段不一致必须被拦截');
        expect(result.discrepancies, contains(contains('allowedChartTechniqueIds')));
      });

      test('反例 3：时间戳漂移超过 ±1000ms 容差（如 +1500ms）时必须断言出差异', () {
        final mutated = samplePostA.copyWith(
          createdAt: baseTime.add(const Duration(milliseconds: 1500)), // 超出 1000ms
        );
        final result = PlaygroundShadowComparator.comparePost(samplePostA, mutated);

        expect(result.isMatch, isFalse, reason: '时间戳容差超出 1000ms 必须被拦截');
        expect(result.discrepancies, contains(contains('createdAt')));
      });

      test('反例 4：附件 attachments 数量或内容不一致时必须断言出差异', () {
        final mutated = samplePostA.copyWith(attachments: const []);
        final result = PlaygroundShadowComparator.comparePost(samplePostA, mutated);

        expect(result.isMatch, isFalse, reason: '附件不一致必须被拦截');
        expect(result.discrepancies, contains(contains('attachments')));
      });

      test('反例 5：hasOutcomeFeedback 标志不一致时必须断言出差异', () {
        final mutated = samplePostA.copyWith(hasOutcomeFeedback: false);
        final result = PlaygroundShadowComparator.comparePost(samplePostA, mutated);

        expect(result.isMatch, isFalse, reason: 'hasOutcomeFeedback 不一致必须被拦截');
        expect(result.discrepancies, contains(contains('hasOutcomeFeedback')));
      });

      test('反例 6：Feed 列表条目数不一致时必须断言出差异', () {
        final pageA = PlaygroundPage(
          items: [samplePostA],
          hasMore: false,
        );
        final pageB = PlaygroundPage<PlaygroundPost>(
          items: const [],
          hasMore: false,
        );

        final result = PlaygroundShadowComparator.compareFeedPage(pageA, pageB);
        expect(result.isMatch, isFalse);
        expect(result.discrepancies, contains(contains('items.length')));
      });
    });

    group('ShadowPlaygroundFeedRemoteDataSource 影子双跑数据源', () {
      test('影子双跑：一致时触发 onComparison 回调 match', () async {
        final primary = _FakeFeedRemoteDataSource(
          page: PlaygroundPage(items: [samplePostA], hasMore: false),
        );
        final secondary = _FakeFeedRemoteDataSource(
          page: PlaygroundPage(items: [samplePostA], hasMore: false),
        );

        ShadowComparisonResult? capturedResult;
        String? capturedOp;

        final shadow = ShadowPlaygroundFeedRemoteDataSource(
          primary: primary,
          secondary: secondary,
          onComparison: (res, op) {
            capturedResult = res;
            capturedOp = op;
          },
        );

        final resultPage = await shadow.getRecommendedFeed(
          const GetFeedQuery(tab: PlaygroundFeedTab.recommended),
        );

        expect(resultPage.items.length, equals(1));
        expect(capturedResult?.isMatch, isTrue);
        expect(capturedOp, equals('getRecommendedFeed'));
      });

      test('影子双跑反例：副数据源异常时断言出差异且主流程不受影响', () async {
        final primary = _FakeFeedRemoteDataSource(
          page: PlaygroundPage(items: [samplePostA], hasMore: false),
        );
        final secondaryMutated = _FakeFeedRemoteDataSource(
          page: PlaygroundPage(
            items: [samplePostA.copyWith(text: '被篡改的副数据源内容')],
            hasMore: false,
          ),
        );

        ShadowComparisonResult? capturedResult;

        final shadow = ShadowPlaygroundFeedRemoteDataSource(
          primary: primary,
          secondary: secondaryMutated,
          onComparison: (res, op) {
            capturedResult = res;
          },
        );

        final resultPage = await shadow.getRecommendedFeed(
          const GetFeedQuery(tab: PlaygroundFeedTab.recommended),
        );

        // 主流程正常返回 primary 内容
        expect(resultPage.items.first.text, equals('测试正文'));
        // 影子比对准确捕获到不一致
        expect(capturedResult?.isMatch, isFalse);
        expect(capturedResult?.discrepancies, contains(contains('text')));
      });
    });
  });
}
