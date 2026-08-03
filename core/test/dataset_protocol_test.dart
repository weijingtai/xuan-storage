/// XRAP 协议契约测试（协议 §6 不变式 I8 / I9 + 注册期约束）。
///
/// 【只测注册期不变式】—— I1–I7 是安装器运行时不变式，
/// 属实现层（persistence_drift）的测试范围，本文件不覆盖。
/// 契约层只能测「非法声明能否被挡住」。
///
/// 门禁纪律（协议 §8.2）：每条断言都必须能因实现变坏而变红，
/// 不写 `expect(SomeClass, isNotNull)` 这类同义反复。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';

/// 构造一份合法清单，供各用例按需覆写字段。
DatasetManifest _manifest({
  String datasetId = 'geo.admin_division',
  String contentVersion = '2026.08',
  int schemaRevision = 1,
  Set<Carrier> carriers = const {Carrier.row},
  String payloadSha256 = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
  int payloadBytes = 1024,
  int? declaredRowCount = 3515,
  String? payloadPath,
}) =>
    DatasetManifest(
      datasetId: datasetId,
      contentVersion: contentVersion,
      schemaRevision: schemaRevision,
      carriers: carriers,
      payloadSha256: payloadSha256,
      payloadBytes: payloadBytes,
      declaredRowCount: declaredRowCount,
      payloadPath: payloadPath,
      publishedAtUtc: DateTime.utc(2026, 8, 2),
    );

/// 计数式 spy 落地器（协议 §8.2 纪律 2：不用 fail() 做断言）。
final class _SpyMaterializer implements DatasetMaterializer {
  _SpyMaterializer(this.datasetId);

  @override
  final String datasetId;

  int materializeCalls = 0;
  int dropCalls = 0;

  @override
  Future<MaterializeOutcome> materialize({
    required DatasetManifest manifest,
    required Stream<List<int>> payload,
    required int generation,
    CancellationToken? cancel,
  }) async {
    materializeCalls++;
    return const MaterializeOutcome(rowCount: 0, bytesOnDisk: 0);
  }

  @override
  Future<void> dropGeneration(int generation) async {
    dropCalls++;
  }
}

DatasetDescriptor _descriptor({
  String datasetId = 'geo.admin_division',
  Set<int> supported = const {1},
  StoragePolicy? policy,
  DatasetManifest? bundled,
}) =>
    DatasetDescriptor(
      datasetId: datasetId,
      supportedSchemaRevisions: supported,
      policy: policy ??
          const StoragePolicy.resource(
            carriers: {Carrier.row},
            sources: {Source.bundled, Source.officialRemote},
          ),
      bundledManifest: bundled ?? _manifest(datasetId: datasetId),
      materializer: () => _SpyMaterializer(datasetId),
    );

void main() {
  setUp(DatasetRegistry.clearForTesting);

  group('注册期不变式（协议 §6 I8 / I9）', () {
    test('合法声明可注册，且能被 lookup 查回', () {
      DatasetRegistry.register(_descriptor());

      final found = DatasetRegistry.lookup('geo.admin_division');
      expect(found, isNotNull);
      expect(found!.datasetId, 'geo.admin_division');
      expect(found.supportedSchemaRevisions, {1});
      // 驱动行为而非同义反复：工厂必须真的能造出落地器。
      expect(found.materializer().datasetId, 'geo.admin_division');
    });

    test('I9：policy 非 resource 时拒绝注册', () {
      expect(
        () => DatasetRegistry.register(
          _descriptor(
            policy: const StoragePolicy.private(carriers: {Carrier.row}),
          ),
        ),
        throwsA(isA<DatasetRegistrationError>().having(
          (e) => e.message,
          'message',
          contains('不是 resource'),
        )),
      );
      expect(DatasetRegistry.all, isEmpty, reason: '拒绝后不得留下半条注册');
    });

    test('I9：policy 的 publisher 非 official 时拒绝注册', () {
      // resource + user：可见性合法，但当前阶段资源一律官方下发（《总纲》§9.1）。
      // 【注意】StoragePolicyRegistry 也会拦这一条，但 XRAP 必须自己拦 ——
      // 两个注册表相互独立，不能假设对方一定被调用过。
      expect(
        () => DatasetRegistry.register(
          _descriptor(
            policy: const StoragePolicy.resource(
              carriers: {Carrier.row},
              sources: {Source.bundled},
              publisher: Publisher.user,
            ),
          ),
        ),
        throwsA(isA<DatasetRegistrationError>().having(
          (e) => e.message,
          'message',
          contains('不是 official'),
        )),
      );
      expect(DatasetRegistry.all, isEmpty, reason: '拒绝后不得留下半条注册');
    });

    test('I8：manifest 的 carriers 超出 policy 的 carriers 时拒绝注册', () {
      expect(
        () => DatasetRegistry.register(
          _descriptor(
            // policy 只允许 row，清单却声明要落 blob。
            bundled: _manifest(carriers: {Carrier.row, Carrier.blob}),
          ),
        ),
        throwsA(isA<DatasetRegistrationError>().having(
          (e) => e.message,
          'message',
          contains('子集'),
        )),
      );
    });

    test('重复注册同一 datasetId 抛异常', () {
      DatasetRegistry.register(_descriptor());
      expect(
        () => DatasetRegistry.register(_descriptor()),
        throwsA(isA<DatasetRegistrationError>()),
      );
    });

    test('descriptor 与 bundledManifest 的 datasetId 不一致时拒绝', () {
      expect(
        () => DatasetRegistry.register(
          _descriptor(
            datasetId: 'geo.admin_division',
            bundled: _manifest(datasetId: 'geo.region'),
          ),
        ),
        throwsA(isA<DatasetRegistrationError>().having(
          (e) => e.message,
          'message',
          contains('不一致'),
        )),
      );
    });

    test('supportedSchemaRevisions 为空集时拒绝 —— 空集永远装不进任何世代', () {
      expect(
        () => DatasetRegistry.register(_descriptor(supported: const {})),
        throwsA(isA<DatasetRegistrationError>().having(
          (e) => e.message,
          'message',
          contains('空集'),
        )),
      );
    });

    test('内置世代的 schemaRevision 不在支持集内时拒绝 —— 自己都装不进自己', () {
      expect(
        () => DatasetRegistry.register(
          _descriptor(
            supported: const {2, 3},
            bundled: _manifest(schemaRevision: 1),
          ),
        ),
        throwsA(isA<DatasetRegistrationError>()),
      );
    });

    test('carriers 含 row 但未声明行数时拒绝 —— 否则落地后无法自检（I4 前置）', () {
      expect(
        () => DatasetRegistry.register(
          _descriptor(bundled: _manifest(declaredRowCount: null)),
        ),
        throwsA(isA<DatasetRegistrationError>().having(
          (e) => e.message,
          'message',
          contains('declaredRowCount'),
        )),
      );
    });

    test('纯 blob 数据集无需声明行数', () {
      DatasetRegistry.register(
        _descriptor(
          datasetId: 'geo.timezone_boundary',
          policy: const StoragePolicy.resource(
            carriers: {Carrier.blob},
            sources: {Source.bundled},
          ),
          bundled: _manifest(
            datasetId: 'geo.timezone_boundary',
            carriers: {Carrier.blob},
            declaredRowCount: null,
          ),
        ),
      );
      expect(DatasetRegistry.lookup('geo.timezone_boundary'), isNotNull);
    });
  });

  group('清单语义（协议 §2.3）', () {
    test('requiresRowCountCheck 由 carriers 决定，与传输方式无关', () {
      expect(_manifest(carriers: {Carrier.row}).requiresRowCountCheck, isTrue);
      expect(_manifest(carriers: {Carrier.blob}).requiresRowCountCheck, isFalse);
      expect(
        _manifest(carriers: {Carrier.row, Carrier.blob}).requiresRowCountCheck,
        isTrue,
      );
    });

    test('supports 只看 schemaRevision，不看 contentVersion（协议 N7）', () {
      final d = _descriptor(supported: const {1, 2});
      // contentVersion 完全不同，但结构版本受支持 → 可装。
      expect(d.supports(_manifest(contentVersion: '9999.12', schemaRevision: 2)),
          isTrue);
      // contentVersion 相同，但结构版本不受支持 → 拒装。
      expect(d.supports(_manifest(contentVersion: '2026.08', schemaRevision: 3)),
          isFalse);
    });
  });

  group('安装结果五态穷尽（协议 §5）', () {
    final bundled = InstalledDataset(
      datasetId: 'geo.admin_division',
      generation: 0,
      manifest: _manifest(),
      status: DatasetGenerationStatus.ready,
      sourceId: 'bundled',
    );

    /// switch 穷尽性由编译器保证；本用例验证每一态都能被区分处理。
    String describe(InstallOutcome o) => switch (o) {
          InstallAlreadyCurrent() => 'current',
          InstallInstalled() => 'installed',
          InstallRejectedSchema() => 'rejected',
          InstallIntegrityFailed() => 'integrity',
          InstallSourceUnavailable() => 'unavailable',
        };

    test('五态各自可区分', () {
      expect(describe(InstallOutcome.alreadyCurrent(bundled)), 'current');
      expect(describe(InstallOutcome.installed(bundled)), 'installed');
      expect(
        describe(InstallOutcome.rejectedSchema(
          requiredRevision: 3,
          supportedRevisions: {1, 2},
          current: bundled,
        )),
        'rejected',
      );
      expect(
        describe(InstallOutcome.integrityFailed(
          reason: 'sha256 mismatch',
          current: bundled,
        )),
        'integrity',
      );
      expect(
        describe(InstallOutcome.sourceUnavailable(
          reason: 'offline',
          current: bundled,
        )),
        'unavailable',
      );
    });

    test('三个非成功态都携带 current —— 兑现 P5「失败沿用现存，永不空手」', () {
      final rejected = InstallOutcome.rejectedSchema(
        requiredRevision: 3,
        supportedRevisions: {1},
        current: bundled,
      );
      expect((rejected as InstallRejectedSchema).current?.isUsable, isTrue);
    });

    test('只有 ready 世代 isUsable（I1 的值层面表达）', () {
      for (final s in DatasetGenerationStatus.values) {
        final d = InstalledDataset(
          datasetId: 'x',
          generation: 1,
          manifest: _manifest(),
          status: s,
          sourceId: 'test',
        );
        expect(d.isUsable, s == DatasetGenerationStatus.ready,
            reason: '$s 的可用性判定错误');
      }
    });
  });
}
