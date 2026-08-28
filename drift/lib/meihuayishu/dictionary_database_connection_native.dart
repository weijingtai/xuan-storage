import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// 旧实现：整库拷贝连接（已废弃）。
///
/// XRAP 迁移后（2026-08-11）字典数据以 `meihua.dictionary` 数据集
/// （dictionary_database.sql 载荷）灌入 [DictionaryDatabase]，不再整库拷贝
/// 二进制 db。默认构造保留以兼容旧调用，但新装配一律显式传 executor +
/// [MeihuaDriftDatasetInstaller]。
@Deprecated(
  '改用 XRAP：DictionaryDatabase(executor) + registerMeihuaDatasets + MeihuaDriftDatasetInstaller',
)
QueryExecutor createDictionaryConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'dictionary.db'));

    if (!await file.exists()) {
      // 尝试已知的资产路径
      ByteData? blob;
      const assetPaths = [
        'assets/sql/dictionary.db',
        'packages/persistence_drift/meihuayishu/assets/sql/dictionary.db',
      ];

      for (final path in assetPaths) {
        try {
          blob = await rootBundle.load(path);
          print('成功加载资产: $path');
          break;
        } catch (e) {
          print('加载资产失败: $path - $e');
        }
      }

      if (blob != null) {
        await file.writeAsBytes(
          blob.buffer.asUint8List(blob.offsetInBytes, blob.lengthInBytes),
          flush: true,
        );
        print('数据库文件已复制到: ${file.path}');
      } else {
        print('警告: 无法加载数据库资产文件');
      }
    } else {
      print('数据库文件已存在: ${file.path}');
    }

    return NativeDatabase.createInBackground(file);
  });
}
