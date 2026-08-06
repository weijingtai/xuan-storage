import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
// 深路径 import 与 barrel import 双轨消费：契约必须能从包入口拿到
// （S3c-a 的教训 —— 契约交付了但消费不到，与没交付等价）。
import 'package:persistence_core/model/ice_server.dart';
import 'package:persistence_core/persistence_core.dart' as barrel;

/// A6 门禁：core 契约层零 TURN 供应商名（S3c-c-preflight P4）。
///
/// 选型结论（三家候选、定价、暴露面）写在选型文档
/// `docs/superpowers/specs/2026-08-05-s3c-c-preflight-turn-selection.md`，
/// 不写进契约 —— 契约里出现供应商名，哪怕只在注释中，也会让后人以为
/// 绑定了它。TURN 是标准协议，换供应商只需换凭证签发地址，契约必须
/// 供应商无关。
///
/// 手法照抄 `signaling_contract_test.dart` 的「A2 · 后端无关」：
/// 源码机械扫描，出现即红。
void main() {
  group('供应商无关守卫（源码扫描）', () {
    // 扫描范围：ICE 端口本身 + 与建连相关的既有契约文件。
    const files = [
      'lib/model/ice_server.dart',
      'lib/model/transport.dart',
      'lib/model/signaling.dart',
    ];

    // 禁止出现的供应商名（大小写双写，防大小写绕过）。
    const banned = [
      'Cloudflare',
      'cloudflare',
      'Twilio',
      'twilio',
      'Xirsys',
      'xirsys',
    ];

    test('A6 · 契约层零供应商名', () {
      final failures = <String>[];
      for (final f in files) {
        final src = File(f).readAsStringSync();
        for (final b in banned) {
          if (src.contains(b)) {
            failures.add('$f 含 "$b"');
          }
        }
      }
      expect(failures, isEmpty,
          reason: '契约层不得提及具体 TURN 供应商（$banned）；'
              '选型结论应留在选型文档，契约必须供应商无关。'
              '命中：${failures.isEmpty ? '无' : failures.join('；')}');
    });
  });

  group('barrel 可消费（契约必须能从包入口拿到）', () {
    test('barrel 导出的 ICE 类型与深路径导出的是同一个', () {
      // 类型引用在编译期解析：若 barrel 未 export ice_server.dart，
      // 这些 barrel.XXX 引用会直接编译失败（S3c-a 栽过的跟头）。
      expect(barrel.IceServer, same(IceServer));
      expect(barrel.IceServerProvider, same(IceServerProvider));

      const viaBarrel = barrel.IceServer(
        urls: 'stun:example.invalid',
        credential: _StaticCredential.fresh,
      );
      expect(viaBarrel, isA<IceServer>(),
          reason: 'barrel 与深路径必须导出同一个 IceServer 类型；'
              '若两者不同，消费方拿到的会是不兼容的类型');

      // 端口类型本身也必须可从 barrel 拿到（消费方要 implements 它们）。
      expect(_BarrelTypeProbe.provider, isNull);
    });
  });
}

/// 探针：确认端口类型能从 barrel 拿到。
///
/// 字段类型写成 `barrel.XXX?`，若 barrel 未导出该类型则编译失败 ——
/// 这比运行期断言更早、更硬。
final class _BarrelTypeProbe {
  /// ICE 服务器提供方端口（经 barrel 引用）。
  static const barrel.IceServerProvider? provider = null;
}

/// 静态凭证（测试用）：证明 credential 可以是任意可异步获取的值。
final class _StaticCredential {
  /// 返回一个固定凭证（测试数据，与任何真实供应商无关）。
  static Future<String> fresh() async => 'test-credential';
}
