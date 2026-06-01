import 'package:shared_preferences/shared_preferences.dart';
import 'package:metaphysics_core/enums/datetime_strategy_enums.dart';
import 'package:metaphysics_core/enums/phenology_strategy.dart';

/// 数据层：节气和物候策略运行时存储
///
/// 使用 SharedPreferences 持久化用户的节气和物候策略选择。
/// 上层不应直接使用此 Store，应通过 LogicModel 获取当前配置。
class JieQiPhenologyStore {
  /// 当前节气类型选择。默认为定气法。
  static JieQiType jieQiType = JieQiType.stabilizing;

  /// 物候计算基准。默认为基于定气法。
  static PhenologyStrategy phenologyStrategy = PhenologyStrategy.stabilizingBased;

  static const String _spJieQiDefaultKey = 'calc_jieqi_type_default';
  static const String _spPhenologyDefaultKey = 'calc_phenology_strategy_default';

  /// 从 SharedPreferences 初始化
  static Future<void> initFromPrefs() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final jq = sp.getString(_spJieQiDefaultKey);
      final ph = sp.getString(_spPhenologyDefaultKey);
      final parsedJq = _parseJieQi(jq);
      final parsedPh = _parsePhenology(ph);
      if (parsedJq != null) jieQiType = parsedJq;
      if (parsedPh != null) phenologyStrategy = parsedPh;
    } catch (_) {
      // ignore
    }
  }

  /// 持久化默认值到 SharedPreferences
  static Future<void> persistDefaults({JieQiType? jq, PhenologyStrategy? ph}) async {
    final sp = await SharedPreferences.getInstance();
    if (jq != null) await sp.setString(_spJieQiDefaultKey, _jieQiToString(jq));
    if (ph != null) await sp.setString(_spPhenologyDefaultKey, _phenologyToString(ph));
  }

  static String _jieQiToString(JieQiType t) => switch (t) {
        JieQiType.leveling => 'leveling',
        JieQiType.stabilizing => 'stabilizing',
      };

  static JieQiType? _parseJieQi(String? s) => switch (s) {
        'leveling' => JieQiType.leveling,
        'stabilizing' => JieQiType.stabilizing,
        _ => null,
      };

  static String _phenologyToString(PhenologyStrategy t) => switch (t) {
        PhenologyStrategy.stabilizingBased => 'stabilizingBased',
        PhenologyStrategy.levelingBased => 'levelingBased',
      };

  static PhenologyStrategy? _parsePhenology(String? s) => switch (s) {
        'stabilizingBased' => PhenologyStrategy.stabilizingBased,
        'levelingBased' => PhenologyStrategy.levelingBased,
        _ => null,
      };
}
