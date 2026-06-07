import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:persistence_preferences/taiyishenshu/taiyishenshu_preferences.dart';

void main() {
  test('SharedPreferencesDeityPreferenceRepository defaults and overrides', () async {
    SharedPreferences.setMockInitialValues({
      'taiyi_deity_preferences': jsonEncode({'deity-1': false}),
    });

    final prefs = await SharedPreferences.getInstance();
    final repo = SharedPreferencesDeityPreferenceRepository(prefs);

    // Assert override
    expect(await repo.isEnabled('deity-1'), isFalse);

    // Assert default
    expect(await repo.isEnabled('deity-2'), isTrue);

    // Save override
    await repo.setEnabled('deity-2', false);
    expect(await repo.isEnabled('deity-2'), isFalse);

    final map = await repo.loadEnabledMap();
    expect(map, equals({'deity-1': false, 'deity-2': false}));
  });
}
