import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A10 门禁：本任务新增的 13 个源文件中，每一个公开声明都必须紧邻上方
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
    'lib/model/signaling.dart',
    'lib/model/ice_server.dart',
  ];

  // 顶层公开声明：enum / class / final class / sealed class /
  // abstract interface class / abstract final class / typedef
  final topLevel = RegExp(
    r'^(?:enum |class |final class |sealed class |abstract interface class '
    r'|abstract final class |typedef )',
  );

  // 类体内缩进两格的公开成员声明（通用式，不维护类型白名单）。
  //
  // 覆盖形态：
  // - static 成员：`static void register(`、`static Map<...> get all =>`
  // - 普通 getter：`int get currentKeyVersion;`（类型与 get 之间一个空格）
  // - 普通方法：`void throwIfCancelled();`（无参）、
  //   `Future<({int freed, int unreclaimable})> evictCache({`（记录类型返回值）
  // - const 公开构造器：`const BlobHandle({`
  // - const factory：`const factory StoragePolicy.private({`
  // - 公开字段：`final Set<Carrier> carriers;`、`final X y = ...;`、
  //   `static final Map<...> all;`、`static const X y;`（含泛型/记录类型）
  //
  // 排除：
  // - 私有成员：名字以 `_` 开头（`final bool _lan;`、`_byEntityType` 等）
  //   —— 字段/方法/getter 分支的名字都用 `[a-z]\w*`，天然不匹配 `_` 开头；
  //     `static final Map<...> _byEntityType = {};` 的类型部分虽可吞 `_byEntityType`，
  //     但名字 `[a-z]\w*` 回溯后仍不匹配 `_`，整行不命中。
  // - 私有构造器：`const StoragePolicy._();` —— `(?!\.)` 排除类名后跟点。
  final member = RegExp(
    r'^  (?:'
    r'static [A-Za-z_][A-Za-z0-9_<>?,()\[\]{} ]* (?:get [a-z]\w*|[a-z]\w*\()'
    r'|[A-Za-z_][A-Za-z0-9_<>?,()\[\]{} ]* get [a-z]\w*'
    r'|[A-Za-z_][A-Za-z0-9_<>?,()\[\]{} ]* [a-z]\w*\('
    r'|const factory [A-Z][A-Za-z0-9]*\.[a-z]\w*\('
    r'|const [A-Z][A-Za-z0-9]*(?!\.)\('
    r'|(?:static (?:final|const)|final) '
    r'[A-Za-z_][A-Za-z0-9_<>?,()\[\]{} ]* [a-z]\w*(?:;| =)'
    r')',
  );

  final cjk = RegExp(r'[\u4e00-\u9fff]');

  test('chinese_dartdoc_on_every_public_declaration', () {
    final failures = <String>[];
    var memberCount = 0;

    for (final path in files) {
      final lines = File(path).readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (!topLevel.hasMatch(line) && !member.hasMatch(line)) {
          continue;
        }
        if (member.hasMatch(line)) {
          memberCount++;
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

    // 覆盖下限自检：member 正则被改窄后此处立即变红，防止静默漏检。
    // 实测值 133（2026-08-01 字段分支补入后），下限取 123 留余量 ——
    // 低于 123 即说明有人把通用正则改窄成白名单式了。
    // 2026-08-04 Transport 被动侧补丁后实测 142（原 133）：新增
    // DeviceKeyStore 3 项、AdvertisementHandle 4 项、advertise /
    // stopAdvertising / incoming / incomingStreams 4 项。
    // 2026-08-04 S3c-a 信令契约层并入后实测 158（原 142）：signaling.dart
    // 贡献 16 项（3 个信封变体的字段与构造器、SignalingSession 4 项、
    // SignalingChannel 2 项）。下限按 ~10 余量上调至 148。
    // 2026-08-05 S3c-c-pre 背压契约并入后实测 161（原 158）：transport.dart
    // 新增 3 项（bufferedAmount / maxBufferedAmount / overflowPolicy getter）。
    // 下限按 ~10 余量上调至 151。
    // 2026-08-05 S3c-c-pre P3 后实测 165（原 161）：ice_server.dart
    // 新增 4 项（urls / credential 字段、IceServer 构造器、iceServers 方法）。
    // 下限按 ~10 余量上调至 155。
    const minMemberDeclarations = 155;
    expect(memberCount, greaterThanOrEqualTo(minMemberDeclarations),
        reason: 'member 正则覆盖的声明总数 $memberCount 低于下限 '
            '$minMemberDeclarations，正则可能被改窄了');

    if (failures.isNotEmpty) {
      fail('以下公开声明缺中文 dartdoc（或注释块中无 CJK 字符）：\n'
          '${failures.join('\n')}');
    }
  });
}
