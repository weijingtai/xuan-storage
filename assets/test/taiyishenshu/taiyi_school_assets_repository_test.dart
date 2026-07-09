import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_assets/taiyishenshu/official_json_repository.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';

class FakeAssetBundle extends CachingAssetBundle {
  final Map<String, String> assets;
  FakeAssetBundle(this.assets);

  @override
  Future<ByteData> load(String key) async {
    if (assets.containsKey(key)) {
      return ByteData.view(Uint8List.fromList(utf8.encode(assets[key]!)).buffer);
    }
    throw Exception('Asset not found: $key');
  }
}

void main() {
  test('OfficialJsonSchoolRepository loads schools and deities from mock AssetBundle', () async {
    final schoolJson = '''
    {
      "id": "jiCheng",
      "name": "集成派",
      "source": "official",
      "epoch": { "ancientBase": 0, "epochYear": 1684, "correction": 0, "tropicalYear": 365.2425 },
      "deityIds": ["taiYi"],
      "wenChangStayRule": false,
      "useTwelveJiShen": true,
      "palaceFormula": "jiCheng",
      "eightDoorMode": "fixed"
    }
    ''';

    final deityJson = '''
    {
      "id": "taiYi",
      "name": "太乙",
      "layer": "tianPan",
      "algorithm": {
        "templateId": "steppedCycle",
        "params": {
          "correction": 0
        }
      },
      "priority": 1,
      "source": "official",
      "tier": "core"
    }
    ''';

    final bundle = FakeAssetBundle({
      'assets/schools/ji-cheng.json': schoolJson,
      'assets/deities/tai-yi.json': deityJson,
    });

    final repo = OfficialJsonSchoolRepository(
      schoolIds: ['jiCheng'],
      deityIds: ['taiYi'],
      bundle: bundle,
    );

    final schools = await repo.loadAllSchools();
    expect(schools, hasLength(1));
    expect(schools.first.id, equals('jiCheng'));
    expect(schools.first.name, equals('集成派'));

    final school = await repo.loadSchool('jiCheng');
    expect(school, isNotNull);
    expect(school!.id, equals('jiCheng'));

    final deities = await repo.loadAllDeities();
    expect(deities, hasLength(1));
    expect(deities.first.id, equals('taiYi'));

    final deity = await repo.loadDeity('taiYi');
    expect(deity, isNotNull);
    expect(deity!.id, equals('taiYi'));
  });

  test('OfficialJsonSchoolRepository write operations throw UnsupportedError', () async {
    final repo = OfficialJsonSchoolRepository(
      schoolIds: [],
      deityIds: [],
      bundle: FakeAssetBundle({}),
    );

    expect(() => repo.saveSchool(const TaiYiSchoolContract(
      id: 's',
      name: 'n',
      source: 's',
      epoch: SchoolEpochConfigContract(
        ancientBase: 0,
        epochYear: 0,
        correction: 0,
        tropicalYear: 365.24,
      ),
      deityIds: [],
      wenChangStayRule: false,
      useTwelveJiShen: false,
      palaceFormula: 'p',
      eightDoorMode: 'e',
    )), throwsUnsupportedError);

    expect(() => repo.deleteSchool('s'), throwsUnsupportedError);
  });
}
