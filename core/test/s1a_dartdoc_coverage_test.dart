import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A10 门禁：本任务新增的 12 个源文件中，每一个公开声明都必须紧邻上方
/// 有 `///` 注释块，且注释块中至少含一个 CJK 字符（仓库惯例，见 ports.dart）。
void main() {
  const files = [
    'lib/model/storage_classification.dart',
    'lib/model/cancellation_token.dart',
    'lib/model/blob_error.dart',
    'lib/model/storage_policy.dart',
    'lib/model/storage_policy_registry.dart',
    'lib/model/blob_types.dart',
    'lib/model/blob_cipher.dart',
    'lib/model/local_blob_store.dart',
    'lib/model/record_blob_unit_of_work.dart',
    'lib/model/blob_gateway.dart',
    'lib/model/transport.dart',
    'lib/model/export_bundle.dart',
  ];

  // 顶层公开声明：enum / class / final class / sealed class /
  // abstract interface class / abstract final class / typedef
  final topLevel = RegExp(
    r'^(?:enum |class |final class |sealed class |abstract interface class '
    r'|abstract final class |typedef )',
  );

  // 类体内缩进两格的方法与 getter 签名（排除以 `_` 开头的私有成员，
  // `const Xxx._(...)` 的 `._` 不是 `[a-z]`，天然被排除）。
  final member = RegExp(
    r'^  (?:'
    r'(?:Future|Stream|Set|Map|List|int|String|bool|void|double|Duration'
    r'|DateTime|CipherId|DataVisibility|Publisher|Carrier|Source|Channel'
    r'|Encryption|BlobHandle|BlobStatus|BlobTier|BlobVisibility|BlobEntry'
    r'|BlobReadResult|PeerIdentity|DiscoveredPeer|DeviceKeyPair'
    r'|PeerSessionState|PeerStream|PeerSession|Transport|BundleManifest'
    r'|BlobUploadTicket|BlobDownloadTicket|BlobGatewayCapabilities'
    r'|RecordMeta|StoragePolicy|CancellationToken|OutboxRecord'
    r'|RemoteChangesPage)[A-Za-z<>?,() ]+ (?:get [a-z]\w*|[a-z]\w*\()'
    r'|const (?:factory )?[A-Za-z]+\.[a-z]\w*\('
    r')',
  );

  final cjk = RegExp(r'[\u4e00-\u9fff]');

  test('chinese_dartdoc_on_every_public_declaration', () {
    final failures = <String>[];

    for (final path in files) {
      final lines = File(path).readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (!topLevel.hasMatch(line) && !member.hasMatch(line)) {
          continue;
        }

        // 向上收集紧邻的注释块：允许跳过空行与 @ 注解行（dartdoc 惯例
        // 是注释在 @override 等注解的上方）。
        final docs = <String>[];
        var j = i - 1;
        while (j >= 0) {
          final t = lines[j].trim();
          if (t.isEmpty || t.startsWith('@')) {
            j--;
            continue;
          }
          if (t.startsWith('///')) {
            docs.add(t);
            j--;
            continue;
          }
          break;
        }

        if (docs.isEmpty || !docs.any(cjk.hasMatch)) {
          failures.add('$path:${i + 1}: $line');
        }
      }
    }

    if (failures.isNotEmpty) {
      fail('以下公开声明缺中文 dartdoc（或注释块中无 CJK 字符）：\n'
          '${failures.join('\n')}');
    }
  });
}
