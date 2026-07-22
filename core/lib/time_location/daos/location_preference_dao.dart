import 'dart:convert';
import 'package:repository_interface_divination_pipeline/geo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xuan_time_location/contracts/xuan_time_location_contracts.dart';

/// 时空地点持久化 DAO
/// 后端：SharedPrefs（与旧 SpLocationData/SpMyLocationData 一致）
/// 路径：xuan-storage/core/lib/time_location/daos/location_preference_dao.dart
abstract interface class LocationPreferenceDao {
  /// 迁移旧 SP key 数据到新 store
  /// 旧 key 常量名（来源：xuan-time-location/lib/src/models/sp_location_data.dart）：
  ///   - SpLocationData.SharedPreferencesBaseKey = 'LocationDataModel'
  ///   - SpMyLocationData.SharedPreferencesBaseKey = 'MyLocationDataModel'
  ///   - 实际 SP key = '${module.spPrefix}$SharedPreferencesBaseKey'
  /// 迁移语义：读旧 key → 转换为 GeoPoint → 写入新 store → 删除旧 key
  Future<void> migrateFromOldSpKeys();

  /// 双槽位设计（Q20 收口后自然落地）
  Future<void> setBirthPlace(BirthPlace place);
  Future<BirthPlace?> getBirthPlace();

  Future<void> setObservationPlace(ObservationPlace place);
  Future<ObservationPlace?> getObservationPlace();

  /// 最近选择的地点（三级来源之一）
  Future<XuanResolvedLocation?> getRecentLocation();
  Future<void> setRecentLocation(XuanResolvedLocation location);

  /// 默认出生地/常用地（三级来源之一）
  Future<XuanResolvedLocation?> getDefaultLocation();
  Future<void> setDefaultLocation(XuanResolvedLocation location);
}

class LocationPreferenceDaoImpl implements LocationPreferenceDao {
  static const String oldLocationDataModelKey = 'LocationDataModel';
  static const String oldMyLocationDataModelKey = 'MyLocationDataModel';

  static const String _keyRecent = 'xuan_location_recent';
  static const String _keyDefault = 'xuan_location_default';
  static const String _keyBirthPlace = 'xuan_location_birth_place';
  static const String _keyObservationPlace = 'xuan_location_observation_place';

  final SharedPreferences? _prefs;

  LocationPreferenceDaoImpl({SharedPreferences? prefs}) : _prefs = prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  @override
  Future<void> migrateFromOldSpKeys() async {
    final prefs = await _getPrefs();
    final keys = prefs.getKeys();

    for (final key in keys.toList()) {
      if (key.endsWith(oldLocationDataModelKey) ||
          key.endsWith(oldMyLocationDataModelKey)) {
        final val = prefs.getString(key);
        if (val != null) {
          try {
            final Map<String, dynamic> json = jsonDecode(val);
            final locJson = json['location'] as Map<String, dynamic>? ?? json;
            final lat = (locJson['latitude'] ??
                    locJson['preciseCoordinates']?['latitude'])
                ?.toDouble();
            final lng = (locJson['longitude'] ??
                    locJson['preciseCoordinates']?['longitude'])
                ?.toDouble();
            final name = locJson['name'] as String?;

            if (lat != null && lng != null) {
              final resolved = XuanResolvedLocation(
                latitude: lat,
                longitude: lng,
                name: name,
              );

              if (key.endsWith(oldMyLocationDataModelKey)) {
                await setDefaultLocation(resolved);
              } else {
                await setRecentLocation(resolved);
              }
            }
          } catch (_) {
            // Ignore malformed json
          }
        }
        await prefs.remove(key);
      }
    }
  }

  @override
  Future<void> setBirthPlace(BirthPlace place) async {
    final prefs = await _getPrefs();
    final data = {
      'latitude': place.value.latitude,
      'longitude': place.value.longitude,
      'timeZoneId': place.value.timeZoneId,
    };
    await prefs.setString(_keyBirthPlace, jsonEncode(data));
  }

  @override
  Future<BirthPlace?> getBirthPlace() async {
    final prefs = await _getPrefs();
    final str = prefs.getString(_keyBirthPlace);
    if (str == null) return null;
    final json = jsonDecode(str) as Map<String, dynamic>;
    return BirthPlace(GeoPoint(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timeZoneId: json['timeZoneId'] as String?,
    ));
  }

  @override
  Future<void> setObservationPlace(ObservationPlace place) async {
    final prefs = await _getPrefs();
    final data = {
      'latitude': place.value.latitude,
      'longitude': place.value.longitude,
      'timeZoneId': place.value.timeZoneId,
    };
    await prefs.setString(_keyObservationPlace, jsonEncode(data));
  }

  @override
  Future<ObservationPlace?> getObservationPlace() async {
    final prefs = await _getPrefs();
    final str = prefs.getString(_keyObservationPlace);
    if (str == null) return null;
    final json = jsonDecode(str) as Map<String, dynamic>;
    return ObservationPlace(GeoPoint(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timeZoneId: json['timeZoneId'] as String?,
    ));
  }

  @override
  Future<XuanResolvedLocation?> getRecentLocation() async {
    final prefs = await _getPrefs();
    final str = prefs.getString(_keyRecent);
    if (str == null) return null;
    final json = jsonDecode(str) as Map<String, dynamic>;
    return XuanResolvedLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      name: json['name'] as String?,
    );
  }

  @override
  Future<void> setRecentLocation(XuanResolvedLocation location) async {
    final prefs = await _getPrefs();
    final data = {
      'latitude': location.latitude,
      'longitude': location.longitude,
      'name': location.name,
    };
    await prefs.setString(_keyRecent, jsonEncode(data));
  }

  @override
  Future<XuanResolvedLocation?> getDefaultLocation() async {
    final prefs = await _getPrefs();
    final str = prefs.getString(_keyDefault);
    if (str == null) return null;
    final json = jsonDecode(str) as Map<String, dynamic>;
    return XuanResolvedLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      name: json['name'] as String?,
    );
  }

  @override
  Future<void> setDefaultLocation(XuanResolvedLocation location) async {
    final prefs = await _getPrefs();
    final data = {
      'latitude': location.latitude,
      'longitude': location.longitude,
      'name': location.name,
    };
    await prefs.setString(_keyDefault, jsonEncode(data));
  }
}
