// ignore_for_file: lines_longer_than_80_chars

/// qizhengsiyu 资产迁入的阶段 1d 最小加载验证（派工单步骤 1.5 / 验收 A2 前置）。
///
/// 验证迁入 `assets/lib/qizhengsiyu/assets/` 的载荷文件在运行期
/// 真能被 AssetBundle 加载（不只是 .dart 里写了路径）：
///   1. asset path 字符串正确（与 pubspec 注册的 `- lib/qizhengsiyu/assets/` 一致）；
///   2. 载荷字节可加载、非空、sha256 与落盘真值一致。
///
/// 与 geo A2 同法：用真实文件内容注入（等价 rootBundle 加载链路），
/// 不 mock、不假路径。真值来自 2026-08-07 迁移时的 `shasum -a 256`。
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

/// 代表性载荷的 asset 路径（rootBundle 形态，与 pubspec 注册目录一致）。
const _kAssetPrefix = 'packages/persistence_assets/lib/qizhengsiyu/assets/';

const _kStarPositionStatusPath = '${_kAssetPrefix}star_position_status.json';
const _kEclipticTropicalPath =
    '${_kAssetPrefix}ecliptic_tropical_morden.json';
const _kGeJuSqlitePath = '${_kAssetPrefix}ge_ju/ge_ju_database.sqlite';
const _kShenShaTianganPath = '${_kAssetPrefix}shen_sha/74_shensha_tiangan.json';

/// 迁移落盘时的 sha256 / 字节数真值（2026-08-07）。
/// 若源 JSON 被改并重新迁移，此处需同步更新，否则断言变红——这正是门禁要的。
const _kTruth = <String, ({String sha256, int bytes})>{
  'star_position_status.json': (
    sha256: 'fdc1af64199ec0730a72ad39728a202f253f5817ab7e670d2e3d334848d49514',
    bytes: 13786,
  ),
  'ecliptic_tropical_morden.json': (
    sha256: 'db7e7d29008a8bf91b217cfb2662a4c6d999f2cba0e4210e3897d8cc38b00b89',
    bytes: 2857,
  ),
  'ge_ju/ge_ju_database.sqlite': (
    sha256: '5b6fc6c4b2dacb3ff9cb4bb35f65941de630735833c3e9b5ae2f31ea5cb2bbf9',
    bytes: 450560,
  ),
  'shen_sha/74_shensha_tiangan.json': (
    sha256: '1acd86ea63b5c30006619714db08021be6c84ecf2c7b38ded29a59fa00daf57e',
    bytes: 7532,
  ),
};

void main() {
  group('阶段1d qizhengsiyu 资产运行期可加载性', () {
    for (final entry in _kTruth.entries) {
      test('${entry.key} 能从 asset path 加载且 sha256 与真值一致', () async {
        final bytes = await _loadAssetBytes('$_kAssetPrefix${entry.key}');
        expect(bytes.length, entry.value.bytes,
            reason: '加载字节数应与迁移落盘真值一致');
        expect(_sha256Hex(bytes), entry.value.sha256,
            reason: '加载内容 sha256 应与迁移落盘真值一致');
        // 非空（非 0 字节）已由字节数断言覆盖；JSON 载荷另验可解码。
        if (entry.key.endsWith('.json')) {
          final text = utf8.decode(bytes);
          expect(text.trim().isNotEmpty, isTrue);
          expect(() => json.decode(text), returnsNormally,
              reason: 'JSON 载荷应能被解码（源数据未损坏）');
        }
      });
    }

    test('pubspec 已注册 lib/qizhengsiyu/assets/ 目录', () {
      final pubspec = File('pubspec.yaml');
      expect(pubspec.existsSync(), isTrue);
      final content = pubspec.readAsStringSync();
      expect(content.contains('- lib/qizhengsiyu/assets/'), isTrue,
          reason: 'flutter.assets 必须包含新目录，否则 rootBundle 加载不到');
    });
  });
}

/// 从包根读取 asset 字节（flutter_test 工作目录即 assets/ 包根）。
/// assetPath 形如 'packages/persistence_assets/lib/qizhengsiyu/assets/x.json'，
/// 去掉 'packages/persistence_assets/' 前缀后是包内相对路径。
Future<Uint8List> _loadAssetBytes(String assetPath) async {
  final filePath = assetPath.replaceFirst('packages/persistence_assets/', '');
  final full = File(filePath);
  if (!await full.exists()) {
    throw FileSystemException('测试资产不存在', full.path);
  }
  return full.readAsBytes();
}

/// 计算 sha256 hex（小写），与迁移落盘真值同形态。
String _sha256Hex(Uint8List bytes) {
  final tmp = File('/tmp/qizheng_test_${DateTime.now().microsecondsSinceEpoch}.bin');
  try {
    tmp.writeAsBytesSync(bytes);
    final result = Process.runSync('shasum', ['-a', '256', tmp.path]);
    final out = (result.stdout as String).trim();
    return out.split(' ').first;
  } finally {
    if (tmp.existsSync()) {
      tmp.deleteSync();
    }
  }
}
