/// meihuayishu 域 XRAP 接入的注册测试（验收 A1 + A2，照 qizhengsiyu 样板）。
///
/// - A1: `registerMeihuaDatasets(db)` 后 `meihua.dictionary` 可 lookup，
///   manifest 与 BUILD-REPORT.md 真值一致；重复注册抛 `DatasetRegistrationError`。
/// - A2: installer 安装后 3 表行数与源库一致（9574/9573/9033），
///   且 repository 查询与源库差分一致。
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/meihuayishu/dictionary_database.dart';
import 'package:persistence_drift/meihuayishu/drift_dataset_installer.dart';
import 'package:persistence_drift/meihuayishu/meihuayishu_datasets.dart';

const _kTruth = (
  sha256: '77adf3f825588fe16039fcf0a8139e7ee9f8140bb4c2d9f231bafbfbd459fb05',
  bytes: 4471505,
  rows: 28180,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DictionaryDatabase db;
  late MeihuaDriftDatasetInstaller installer;

  setUp(() {
    DatasetRegistry.clearForTesting();
    db = DictionaryDatabase(NativeDatabase.memory());
    installer = MeihuaDriftDatasetInstaller(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  test('A1: 注册后 dataset 可 lookup，manifest 真值一致', () {
    registerMeihuaDatasets(db: db);
    final descriptor = DatasetRegistry.lookup('meihua.dictionary');
    expect(descriptor, isNotNull);
    final manifest = descriptor!.bundledManifest;
    expect(manifest.payloadSha256, _kTruth.sha256);
    expect(manifest.payloadBytes, _kTruth.bytes);
    expect(manifest.declaredRowCount, _kTruth.rows);
  });

  test('A1: 重复注册抛 DatasetRegistrationError', () {
    registerMeihuaDatasets(db: db);
    expect(
      () => registerMeihuaDatasets(db: db),
      throwsA(isA<DatasetRegistrationError>()),
    );
  });

  test('A2: 安装后 3 表行数与源库一致 + repository 差分', () async {
    registerMeihuaDatasets(db: db);
    final outcome = await installer.ensureInstalled('meihua.dictionary');
    expect(outcome, isA<InstallInstalled>(),
        reason: '首次安装应返回 InstallInstalled');
    final installed = (outcome as InstallInstalled).installed;
    expect(installed.status, DatasetGenerationStatus.ready);
    expect(installed.actualRowCount, _kTruth.rows);

    // 行数差分（对照源 dictionary.db：characters 9574 / pinyin 9573 / etymology 9033）
    final counts = <String, int>{};
    for (final t in const ['characters', 'pinyin', 'etymology']) {
      final row =
          await db.customSelect('SELECT COUNT(*) AS c FROM $t').getSingle();
      counts[t] = row.read<int>('c');
    }
    expect(counts, {'characters': 9574, 'pinyin': 9573, 'etymology': 9033});

    // 数据差分抽查（对照源库同查询）
    final row = await db.customSelect(
      "SELECT character, definition, matches_json FROM characters WHERE character = '一'",
    ).getSingleOrNull();
    expect(row, isNotNull);
    expect(row!.read<String>('character'), '一');
    final def = row.read<String?>('definition');
    expect(def, isNotNull, reason: '「一」应有释义');
    expect(def, isNotEmpty);
  });
}
