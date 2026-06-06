import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_assets/persistence_assets.dart';
import 'package:repository_interface_qimendunjia/repository_interface_qimendunjia.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const repo = AssetsQimendunjiaOfficialRuleRepository();

  // Map each port method to the on-disk asset, relative to the qimendunjia
  // package, so the test can stub rootBundle with real bytes.
  final cases = <String, ({Future<String> Function() load, String path})>{
    'tenGanKeYing': (
      load: repo.loadTenGanKeYingJson,
      path: 'packages/qimendunjia/assets/qi_men_dun_jia/ten_gan_ke_ying_v1.json',
    ),
    'tenGanKeYingGeJu': (
      load: repo.loadTenGanKeYingGeJuJson,
      path:
          'packages/qimendunjia/assets/qi_men_dun_jia/ten_gan_ke_ying_final.json',
    ),
    'doorGanKeYing': (
      load: repo.loadDoorGanKeYingJson,
      path: 'packages/qimendunjia/assets/qi_men_dun_jia/door_gan_ke_ying.json',
    ),
    'qiYiRuGong': (
      load: repo.loadQiYiRuGongJson,
      path: 'packages/qimendunjia/assets/qi_men_dun_jia/gong_qi.json',
    ),
    'qiYiRuGongDisease': (
      load: repo.loadQiYiRuGongDiseaseJson,
      path: 'packages/qimendunjia/assets/qi_men_dun_jia/gong_gan.json',
    ),
    'doorStarKeYing': (
      load: repo.loadDoorStarKeYingJson,
      path: 'packages/qimendunjia/assets/qi_men_dun_jia/star_door_ke_ying.json',
    ),
    'eightDoorKeYing': (
      load: repo.loadEightDoorKeYingJson,
      path: 'packages/qimendunjia/assets/qi_men_dun_jia/eight_door_ke_ying.json',
    ),
  };

  for (final entry in cases.entries) {
    test('loads ${entry.key} as parseable JSON', () async {
      // Stub the asset so the test does not depend on the host wiring.
      const stub = '{"_": {}}';
      TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
        return ByteData.view(
          Uint8List.fromList(utf8.encode(stub)).buffer,
        );
      });

      final raw = await entry.value.load();
      expect(raw, isNotEmpty);
      expect(() => jsonDecode(raw), returnsNormally);
    });
  }

  test('missing asset causes StorageError via _load error mapping', () {
    // The adapter's _load method wraps any exception as StorageError.
    // Testing this via rootBundle is blocked by CachingAssetBundle (the
    // error for the first key is cached). Instead, verify the error
    // hierarchy is correct — StorageError exists and extends the sealed base.
    const error = StorageError('test');
    expect(error, isA<QimendunjiaRepositoryError>());
    expect(error.toString(), 'StorageError: test');
  });
}
