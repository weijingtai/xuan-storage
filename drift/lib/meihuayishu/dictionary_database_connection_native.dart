import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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
