import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_assets/persistence_assets.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssetsQiZhengOfficialDataRepositories Tests', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
        // message is a ByteData containing the asset key.
        // Let's decode it.
        final key = utf8.decode(message!.buffer.asUint8List(message.offsetInBytes, message.lengthInBytes));
        
        if (key.endsWith('star_position_status.json')) {
          final mockList = [
            {
              'id': 1,
              'className': 'Default',
              'star': 'Sun',
              'starPositionStatusType': 'Gong',
              'positionList': ['子'],
              'descriptionList': ['desc'],
              'geJuList': ['geju']
            }
          ];
          return ByteData.view(Uint8List.fromList(utf8.encode(json.encode(mockList))).buffer);
        } else if (key.endsWith('sun_speeds.json')) {
          final mockMap = {'DongZhi': 1.0};
          return ByteData.view(Uint8List.fromList(utf8.encode(json.encode(mockMap))).buffer);
        } else if (key.endsWith('resource_name')) {
          return ByteData.view(Uint8List.fromList(utf8.encode('resource content')).buffer);
        } else if (key.endsWith('ecliptic_tropical_morden.json') ||
                   key.endsWith('ecliptic_tropical_classical_adjusted.json') ||
                   key.endsWith('ecliptic_tropical_classical.json')) {
          final mockModel = {
            'systemType': 'Tropical',
            'panelSystemType': 'Tropical',
            'constellationSystemType': 'Modern'
          };
          return ByteData.view(Uint8List.fromList(utf8.encode(json.encode(mockModel))).buffer);
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });

    test('AssetsQiZhengStarPositionStatusRepository loads and parses correctly', () async {
      const repo = AssetsQiZhengStarPositionStatusRepository();
      final result = await repo.loadStarPositionStatus();
      expect(result, isNotEmpty);
      expect(result.first.raw['className'], 'Default');
    });

    test('AssetsQiZhengHistoricalEphemerisRepository loads correctly', () async {
      const repo = AssetsQiZhengHistoricalEphemerisRepository();
      final result = await repo.loadHistoricalEphemeris();
      expect(result, isNotEmpty);
      expect(result['DongZhi'], 1.0);
    });

    test('AssetsQiZhengEphemerisResourceRepository loads correctly', () async {
      const repo = AssetsQiZhengEphemerisResourceRepository();
      final result = await repo.loadEphemerisResource('resource_name');
      expect(result, 'resource content');
    });

    test('AssetsQiZhengZhouTianModelRepository loads all built-in models', () async {
      const repo = AssetsQiZhengZhouTianModelRepository();
      final result = await repo.loadBuiltInZhouTianModels();
      expect(result, hasLength(3));
      expect(result.first.raw['systemType'], 'Tropical');
    });

    test('missing asset throws StorageError', () async {
      const repo = AssetsQiZhengEphemerisResourceRepository(prefix: 'nonexistent/');
      expect(
        () => repo.loadEphemerisResource('missing_file'),
        throwsA(isA<StorageError>()),
      );
    });
  });
}
