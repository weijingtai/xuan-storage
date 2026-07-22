import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/time_location/daos/location_preference_dao.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocationPreferenceDao Migration Tests', () {
    test('migrateFromOldSpKeys reads old keys, converts to new store, and clears old keys', () async {
      final oldLocationData = {
        'module': 'golabel',
        'isRemembered': true,
        'location': {
          'latitude': 39.9042,
          'longitude': 116.4074,
          'name': 'Beijing',
        },
      };

      final oldMyLocationData = {
        'module': 'golabel',
        'isDefault': true,
        'location': {
          'latitude': 31.2304,
          'longitude': 121.4737,
          'name': 'Shanghai',
        },
      };

      SharedPreferences.setMockInitialValues({
        'LocationDataModel': jsonEncode(oldLocationData),
        'MyLocationDataModel': jsonEncode(oldMyLocationData),
      });

      final prefs = await SharedPreferences.getInstance();
      final dao = LocationPreferenceDaoImpl(prefs: prefs);

      await dao.migrateFromOldSpKeys();

      final recent = await dao.getRecentLocation();
      expect(recent, isNotNull);
      expect(recent!.latitude, equals(39.9042));
      expect(recent.longitude, equals(116.4074));
      expect(recent.name, equals('Beijing'));

      final defaultLoc = await dao.getDefaultLocation();
      expect(defaultLoc, isNotNull);
      expect(defaultLoc!.latitude, equals(31.2304));
      expect(defaultLoc.longitude, equals(121.4737));
      expect(defaultLoc.name, equals('Shanghai'));

      expect(prefs.containsKey('LocationDataModel'), isFalse);
      expect(prefs.containsKey('MyLocationDataModel'), isFalse);
    });
  });
}
