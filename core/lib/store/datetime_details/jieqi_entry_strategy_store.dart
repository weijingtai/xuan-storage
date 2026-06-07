import 'package:shared_preferences/shared_preferences.dart';
import 'package:metaphysics_core/enums/datetime_strategy_enums.dart';

/// 数据层：交节方案精度运行时存储
///
/// 使用 SharedPreferences 持久化用户的交节精度选择。
/// 枚举 [JieQiEntryPrecision] 定义在 core 层，此处只做存储。
class JieQiEntryStrategyStore {
  static const String _spKey = 'calc_jieqi_entry_precision_default';

  /// 默认推荐使用"分钟"
  static JieQiEntryPrecision current = JieQiEntryPrecision.minute;

  static Future<void> initFromPrefs() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final s = sp.getString(_spKey);
      final p = _parse(s);
      if (p != null) current = p;
    } catch (_) {}
  }

  static Future<void> persistDefault(JieQiEntryPrecision p) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_spKey, _toString(p));
  }

  static String _toString(JieQiEntryPrecision p) => switch (p) {
        JieQiEntryPrecision.shichen => 'shichen',
        JieQiEntryPrecision.hour => 'hour',
        JieQiEntryPrecision.minute => 'minute',
        JieQiEntryPrecision.second => 'second',
      };

  static JieQiEntryPrecision? _parse(String? s) => switch (s) {
        'shichen' => JieQiEntryPrecision.shichen,
        'hour' => JieQiEntryPrecision.hour,
        'minute' => JieQiEntryPrecision.minute,
        'second' => JieQiEntryPrecision.second,
        // 兼容旧值
        'minuteSecond' => JieQiEntryPrecision.minute,
        _ => null,
      };
}
