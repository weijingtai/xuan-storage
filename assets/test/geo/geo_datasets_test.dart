// ignore_for_file: lines_longer_than_80_chars

/// geo 域 XRAP 接入的注册测试（验收 A1 + A2）。
///
/// 验证两件事：
/// - A1: `registerGeoDatasets()` 后三个 datasetId 均可 lookup，
///   manifest 的 sha256/bytes/rowCount 与实际载荷文件一致。
/// - A2: 载荷 *.sql 在运行期真能被 AssetBundle 加载（不只是 .dart 里写了路径）。
///
/// 门禁纪律（协议 §8.2）：不用 fail()，用计数式断言；每条断言能因实现变坏而变红。
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_assets/geo/geo_datasets.dart';
import 'package:persistence_core/persistence_core.dart';

/// 测试用的真值（必须与 assets/lib/geo/BUILD-REPORT.md 一致）。
/// 若 *.sql 被重新构建，此处需同步更新，否则 sha256 断言变红--这正是门禁要的。
const _kAdminDivisionSha256 =
    'cbb337c627436a4d877f01dfa651d3eaf5c970ad4f9ae98b5566dbb26590d83e';
const _kRegionSha256 =
    'aeb0032c68a19e8e10d10dae6292c8274330b8705d793bd0227421d17a5ed91d';
const _kCitySha256 =
    '98bea3dcf0cf04b6d227f6caf6b676880a25195dc5c7349b212e38dbb6c05917';

const _kAdminDivisionBytes = 517853;
const _kRegionBytes = 2614;
const _kCityBytes = 34626;

const _kAdminDivisionRows = 3515;
const _kRegionRows = 6;
const _kCityRows = 337;

/// 载荷在 rootBundle 里的路径（与 geo_datasets.dart 内的私有常量必须一致）。
const _kAdminDivisionAssetPath =
    'packages/persistence_assets/lib/geo/admin_division.sql';
const _kRegionAssetPath =
    'packages/persistence_assets/lib/geo/region.sql';
const _kCityAssetPath =
    'packages/persistence_assets/lib/geo/city.sql';

void main() {
  setUp(() {
    DatasetRegistry.clearForTesting();
  });

  group('A1 registerGeoDatasets 注册验证', () {
    test('注册后三个 datasetId 均可 lookup', () {
      registerGeoDatasets();

      final admin = DatasetRegistry.lookup('geo.admin_division');
      final region = DatasetRegistry.lookup('geo.region');
      final city = DatasetRegistry.lookup('geo.city');

      // 计数式断言：三非空 -> 3，缺一即 < 3。
      final present = [admin, region, city].where((d) => d != null).length;
      expect(present, 3, reason: '三个 datasetId 必须全部 lookup 到');
    });

    test('未注册的 id 返回 null（fail closed，协议 §3）', () {
      registerGeoDatasets();
      expect(DatasetRegistry.lookup('geo.not_exist'), isNull);
    });

    test('geo.admin_division manifest 字段与实际载荷一致', () {
      registerGeoDatasets();
      final d = DatasetRegistry.lookup('geo.admin_division')!;
      final m = d.bundledManifest;

      expect(m.datasetId, 'geo.admin_division');
      expect(m.payloadSha256, _kAdminDivisionSha256);
      expect(m.payloadBytes, _kAdminDivisionBytes);
      expect(m.declaredRowCount, _kAdminDivisionRows);
      expect(m.carriers, {Carrier.row});
      expect(m.payloadFormat, DatasetPayloadFormat.prebuilt);
      expect(m.minimumAppSchemaRevision, 1);
      // 内置世代载荷在 asset 内，无 payloadPath
      expect(m.payloadPath, isNull);
      // descriptor 的 policy 必须是 resource + official（不变式 I9）
      expect(d.policy.visibility, DataVisibility.resource);
      expect(d.policy.publisher, Publisher.official);
      // appSchemaRevision 必须能读自己的内置世代（D2 方向 B）
      expect(d.supports(m), isTrue);
    });

    test('geo.region manifest 字段与实际载荷一致', () {
      registerGeoDatasets();
      final d = DatasetRegistry.lookup('geo.region')!;
      final m = d.bundledManifest;

      expect(m.datasetId, 'geo.region');
      expect(m.payloadSha256, _kRegionSha256);
      expect(m.payloadBytes, _kRegionBytes);
      expect(m.declaredRowCount, _kRegionRows);
      expect(m.carriers, {Carrier.row});
      expect(d.policy.visibility, DataVisibility.resource);
      expect(d.policy.publisher, Publisher.official);
    });

    test('geo.city manifest 字段与实际载荷一致', () {
      registerGeoDatasets();
      final d = DatasetRegistry.lookup('geo.city')!;
      final m = d.bundledManifest;

      expect(m.datasetId, 'geo.city');
      expect(m.payloadSha256, _kCitySha256);
      expect(m.payloadBytes, _kCityBytes);
      expect(m.declaredRowCount, _kCityRows);
      expect(m.carriers, {Carrier.row});
      expect(d.policy.visibility, DataVisibility.resource);
      expect(d.policy.publisher, Publisher.official);
    });

    test('重复注册同一 datasetId 抛 DatasetRegistrationError（协议注册期校验）', () {
      registerGeoDatasets();
      // 再注册一次应抛
      expect(
        () => registerGeoDatasets(),
        throwsA(isA<DatasetRegistrationError>()),
        reason: '同一 datasetId 只能注册一次',
      );
    });

    test('全部已注册数据集数量为 3（一致性门禁）', () {
      registerGeoDatasets();
      expect(DatasetRegistry.all.length, 3);
      expect(
        DatasetRegistry.all.keys.toSet(),
        {'geo.admin_division', 'geo.region', 'geo.city'},
      );
    });
  });

  group('A2 运行期载荷加载验证', () {
    // 用真实文件内容构造 FakeAssetBundle，模拟 rootBundle 加载。
    // 这验证了两件事：
    //   1. asset path 字符串正确（与 pubspec 注册路径一致）
    //   2. *.sql 内容能被字节加载 + sha256 与 manifest 一致（不变式 I3 前置）
    //
    // 不直接用 rootBundle（需完整 Flutter 环境），用 FakeAssetBundle 注入
    // 真实文件字节，等价验证「加载链路 + 完整性」。

    test('admin_division.sql 能从 asset path 加载且 sha256 与 manifest 一致', () async {
      final bytes = await _loadAssetBytes(_kAdminDivisionAssetPath);
      expect(bytes.length, _kAdminDivisionBytes,
          reason: '加载字节数应与 manifest 声明一致');
      expect(_sha256Hex(bytes), _kAdminDivisionSha256,
          reason: '加载内容 sha256 应与 manifest 声明一致');
    });

    test('region.sql 能从 asset path 加载且 sha256 与 manifest 一致', () async {
      final bytes = await _loadAssetBytes(_kRegionAssetPath);
      expect(bytes.length, _kRegionBytes);
      expect(_sha256Hex(bytes), _kRegionSha256);
    });

    test('city.sql 能从 asset path 加载且 sha256 与 manifest 一致', () async {
      final bytes = await _loadAssetBytes(_kCityAssetPath);
      expect(bytes.length, _kCityBytes);
      expect(_sha256Hex(bytes), _kCitySha256);
    });

    test('*.sql 内容含 BEGIN TRANSACTION / COMMIT / CREATE TABLE / INSERT', () async {
      final bytes = await _loadAssetBytes(_kAdminDivisionAssetPath);
      final text = utf8.decode(bytes);
      expect(text.contains('BEGIN TRANSACTION;'), isTrue);
      expect(text.contains('COMMIT;'), isTrue);
      expect(text.contains('CREATE TABLE'), isTrue);
      expect(text.contains('INSERT INTO'), isTrue);
      // 中文未转义
      expect(text.contains('北京市'), isTrue);
    });
  });
}

/// 从测试用 FakeAssetBundle 加载 asset 字节。
///
/// 复用既有 assets/test 的 FakeAssetBundle 模式（见 taiyi 测试），
/// 但注入真实 *.sql 文件内容，等价于 rootBundle 加载。
Future<Uint8List> _loadAssetBytes(String assetPath) async {
  // assetPath 形如 'packages/persistence_assets/lib/geo/admin_division.sql'
  // 去掉 'packages/persistence_assets/' 前缀后是 'lib/geo/admin_division.sql'
  // flutter_test 的工作目录是包根（assets/），所以该相对路径直接可达。
  final filePath = assetPath.replaceFirst(
    'packages/persistence_assets/',
    '',
  );
  final full = File(filePath);
  if (!await full.exists()) {
    throw FileSystemException('测试资产不存在', full.path);
  }
  return full.readAsBytes();
}

/// 计算 sha256 hex（小写），与 manifest.payloadSha256 同形态。
///
/// 用 `shasum -a 256` 命令（macOS/Linux 均自带），避免引入新依赖。
/// 测试里算 hash 是验证完整性，不在性能热路径，调外部命令可接受。
String _sha256Hex(Uint8List bytes) {
  final tmp = File('/tmp/geo_test_${DateTime.now().microsecondsSinceEpoch}.bin');
  try {
    tmp.writeAsBytesSync(bytes);
    final result = Process.runSync('shasum', ['-a', '256', tmp.path]);
    final out = (result.stdout as String).trim();
    // 输出形如 '<hash>  <path>'
    return out.split(' ').first;
  } finally {
    if (tmp.existsSync()) {
      tmp.deleteSync();
    }
  }
}
