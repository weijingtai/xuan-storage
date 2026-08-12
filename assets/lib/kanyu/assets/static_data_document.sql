CREATE TABLE IF NOT EXISTS static_data_document (  file_name TEXT PRIMARY KEY,  payload_json TEXT NOT NULL);
DELETE FROM static_data_document;
INSERT INTO static_data_document ("file_name", "payload_json") VALUES ('data/bagua/minggua_formula.json', '{
  "$schema": "../../schema/layer-a-static-data.schema.json",
  "configType": "static",
  "layer": "A",
  "id": "minggua-formula-v1",
  "name": "命卦计算公式",
  "version": "1.0.0",
  "source": "《八宅明镜》八宅派标准命卦公式（不以2000年分割）",
  "description": "年命卦计算公式，东西四命划分。重构时复用 xuan-taiyishenshu 的 MingGuaEngine",
  "reuses": "xuan-taiyishenshu/lib/minggua/core/ming_gua_engine.dart",
  "starNumberMapping": {
    "1": {"trigram": "坎", "element": "水"},
    "2": {"trigram": "坤", "element": "土"},
    "3": {"trigram": "震", "element": "木"},
    "4": {"trigram": "巽", "element": "木"},
    "5": {"trigram": null, "element": "土", "note": "中宫寄宫"},
    "6": {"trigram": "乾", "element": "金"},
    "7": {"trigram": "兑", "element": "金"},
    "8": {"trigram": "艮", "element": "土"},
    "9": {"trigram": "离", "element": "火"}
  },
  "formula": {
    "source": "《八宅明镜》原文",
    "maleRemainder": "remainder = (100 - Y) mod 9",
    "femaleRemainder": "remainder = (Y - 4) mod 9",
    "yDefinition": "公历出生年份后两位数字",
    "postProcessing": {
      "remainderZero": "替换为9",
      "remainderFive": {"male": "寄坤2", "female": "寄艮8"}
    }
  },
  "groups": {
    "eastFour": {"name": "东四命", "numbers": [1, 3, 4, 9], "trigrams": ["坎", "震", "巽", "离"]},
    "westFour": {"name": "西四命", "numbers": [2, 6, 7, 8], "trigrams": ["坤", "乾", "兑", "艮"]}
  },
  "versionSwitch": {
    "description": "部分现代流派使用2000年分界修正公式，预留参数开关",
    "versions": [
      {"name": "八宅明镜原版", "id": "pre-2000-classic", "cutoffYear": null, "default": true},
      {"name": "2000年分界修正版", "id": "post-2000-modern", "cutoffYear": 2000, "default": false}
    ]
  },
  "testFixtures": [
    {"inputYear": 1984, "inputGender": "male", "expectedNumber": 3, "expectedTrigram": "震", "expectedGroup": "东四命"},
    {"inputYear": 1984, "inputGender": "female", "expectedNumber": 2, "expectedTrigram": "坤", "expectedGroup": "西四命"},
    {"inputYear": 1990, "inputGender": "male", "expectedNumber": 1, "expectedTrigram": "坎", "expectedGroup": "东四命"},
    {"inputYear": 2000, "inputGender": "male", "expectedNumber": 9, "expectedTrigram": "离", "expectedGroup": "东四命"}
  ]
}
');
INSERT INTO static_data_document ("file_name", "payload_json") VALUES ('data/bagua/najia_bagua.json', '{
  "$schema": "../../schema/layer-a-static-data.schema.json",
  "configType": "static",
  "layer": "A",
  "id": "bagua-najia-v1",
  "name": "八卦纳甲表（两套体系）",
  "version": "1.0.0",
  "source": "京房纳甲（《京氏易传》）+ 风水净阴净阳纳甲",
  "description": "两套纳甲体系并存：京房原始纳甲（六爻通用）和风水净阴净阳纳甲（辅星翻卦使用）。重构时优先复用 xuan-gua-core/gua_constants.dart 的 yinGuaYaoTianGan/yangGuaYaoTianGan 常量",
  "reuses": "xuan-gua-core/lib/constants/gua_constants.dart",
  "system1_jingFangNajia": {
    "name": "京房原始纳甲",
    "usage": "六爻、天星通用",
    "mappings": [
      {"trigram": "乾", "trigramName": "乾", "najia": ["甲", "壬"]},
      {"trigram": "坤", "trigramName": "坤", "najia": ["乙", "癸"]},
      {"trigram": "震", "trigramName": "震", "najia": ["庚"]},
      {"trigram": "巽", "trigramName": "巽", "najia": ["辛"]},
      {"trigram": "坎", "trigramName": "坎", "najia": ["戊"]},
      {"trigram": "离", "trigramName": "离", "najia": ["己"]},
      {"trigram": "艮", "trigramName": "艮", "najia": ["丙"]},
      {"trigram": "兑", "trigramName": "兑", "najia": ["丁"]}
    ]
  },
  "system2_fengShuiJingYinJingYang": {
    "name": "风水净阴净阳纳甲",
    "usage": "三合、辅星翻卦使用",
    "rule": "立向优先净阴配阴龙、净阳配阳龙，阴阳不交为凶",
    "yangGua": {
      "label": "净阳",
      "mappings": [
        {"trigram": "乾", "najia": ["甲"]},
        {"trigram": "坤", "najia": ["乙"]},
        {"trigram": "坎", "najia": ["癸", "申", "子", "辰"]},
        {"trigram": "离", "najia": ["壬", "寅", "午", "戌"]}
      ]
    },
    "yinGua": {
      "label": "净阴",
      "mappings": [
        {"trigram": "艮", "najia": ["丙"]},
        {"trigram": "巽", "najia": ["辛"]},
        {"trigram": "震", "najia": ["庚", "亥", "卯", "未"]},
        {"trigram": "兑", "najia": ["丁", "巳", "酉", "丑"]}
      ]
    }
  },
  "testFixtures": [
    {"inputTrigram": "乾", "expectedJingFang": ["甲", "壬"], "expectedYinYang": "净阳"},
    {"inputTrigram": "震", "expectedJingFang": ["庚"], "expectedYinYang": "净阴"},
    {"inputTrigram": "离", "expectedJingFang": ["己"], "expectedYinYang": "净阳"}
  ]
}
');
INSERT INTO static_data_document ("file_name", "payload_json") VALUES ('data/bagua/nine_palace.json', '{
  "$schema": "../../schema/layer-a-static-data.schema.json",
  "configType": "static",
  "layer": "A",
  "id": "bagua-nine-palace-v1",
  "name": "九宫八卦方位·洛书元旦盘",
  "version": "1.0.0",
  "source": "后天八卦洛书排布",
  "description": "洛书九宫固定排布：戴九履一，左三右七，二四为肩，六八为足，五居中央。重构时复用 xuan-taiyishenshu/nine_palace.dart 的宫本数和 xuan-meihuayishu/gua_calculator.dart 的后天方位Map",
  "reuses": [
    "xuan-taiyishenshu/lib/taiyi/rules/nine_palace.dart",
    "xuan-meihuayishu/lib/utils/gua_calculator.dart"
  ],
  "luoshuGrid": {
    "description": "后天八卦洛书标准排布，3×3宫格",
    "grid": [
      [{"trigram": "巽", "number": 4, "direction": "东南", "element": "木", "color": "绿"},
       {"trigram": "离", "number": 9, "direction": "正南", "element": "火", "color": "紫"},
       {"trigram": "坤", "number": 2, "direction": "西南", "element": "土", "color": "黑"}],
      [{"trigram": "震", "number": 3, "direction": "正东", "element": "木", "color": "碧"},
       {"trigram": "中宫", "number": 5, "direction": "中央", "element": "土", "color": "黄"},
       {"trigram": "兑", "number": 7, "direction": "正西", "element": "金", "color": "赤"}],
      [{"trigram": "艮", "number": 8, "direction": "东北", "element": "土", "color": "白"},
       {"trigram": "坎", "number": 1, "direction": "正北", "element": "水", "color": "白"},
       {"trigram": "乾", "number": 6, "direction": "西北", "element": "金", "color": "白"}]
    ]
  },
  "directionMapping": [
    {"number": 1, "trigram": "坎", "direction": "正北"},
    {"number": 2, "trigram": "坤", "direction": "西南"},
    {"number": 3, "trigram": "震", "direction": "正东"},
    {"number": 4, "trigram": "巽", "direction": "东南"},
    {"number": 5, "trigram": null, "direction": "中宫"},
    {"number": 6, "trigram": "乾", "direction": "西北"},
    {"number": 7, "trigram": "兑", "direction": "正西"},
    {"number": 8, "trigram": "艮", "direction": "东北"},
    {"number": 9, "trigram": "离", "direction": "正南"}
  ],
  "luoshuForwardPath": {
    "description": "洛书顺行路线：1→2→3→4→5→6→7→8→9",
    "path": [1, 2, 3, 4, 5, 6, 7, 8, 9]
  },
  "baguaDirection": {
    "东四命": {"trigrams": ["坎", "震", "巽", "离"], "numbers": [1, 3, 4, 9]},
    "西四命": {"trigrams": ["坤", "乾", "兑", "艮"], "numbers": [2, 6, 7, 8]}
  },
  "testFixtures": [
    {"inputNumber": 1, "expectedTrigram": "坎", "expectedDirection": "正北", "expectedElement": "水"},
    {"inputNumber": 9, "expectedTrigram": "离", "expectedDirection": "正南", "expectedElement": "火"},
    {"inputNumber": 5, "expectedTrigram": null, "expectedDirection": "中宫", "expectedElement": "土"},
    {"inputTrigram": "坎", "expectedGroup": "东四命"},
    {"inputTrigram": "坤", "expectedGroup": "西四命"}
  ]
}
');
INSERT INTO static_data_document ("file_name", "payload_json") VALUES ('data/bagua/wandering_star.json', '{
  "$schema": "../../schema/layer-a-static-data.schema.json",
  "configType": "static",
  "layer": "A",
  "id": "bagua-wandering-star-v1",
  "name": "八宅游年九星·大游年歌",
  "version": "1.0.0",
  "source": "《八宅明镜》·大游年歌诀",
  "description": "坐山起伏位法，八宫九星完整映射表。分支差异：《阳宅三要》大门起伏位；《八宅明镜》坐山起伏位，双模式预留",
  "starClassification": {
    "auspicious": {
      "name": "四吉星",
      "stars": [
        {"name": "伏位", "description": "宅之本体，平稳"},
        {"name": "生气", "description": "旺丁旺财，上吉"},
        {"name": "延年", "description": "夫妻和睦，长寿"},
        {"name": "天医", "description": "身体健康，祛病"}
      ]
    },
    "inauspicious": {
      "name": "四凶星",
      "stars": [
        {"name": "五鬼", "description": "口舌是非，火灾"},
        {"name": "绝命", "description": "破败伤丁，最凶"},
        {"name": "祸害", "description": "官非败财"},
        {"name": "六煞", "description": "桃花淫乱"}
      ]
    }
  },
  "modeSwitch": {
    "default": "sittingMountain",
    "options": [
      {"mode": "sittingMountain", "description": "坐山起伏位（《八宅明镜》法）"},
      {"mode": "mainDoor", "description": "大门起伏位（《阳宅三要》法）"}
    ]
  },
  "mansionStarMapping": {
    "description": "行=坐山(伏位宫)，列=目标宫(后天八卦序：乾坎艮震巽离坤兑)",
    "columns": ["乾", "坎", "艮", "震", "巽", "离", "坤", "兑"],
    "rows": [
      {"sittingTrigram": "乾", "mansion": "乾宅", "stars": ["伏位", "六煞", "天医", "五鬼", "祸害", "绝命", "延年", "生气"]},
      {"sittingTrigram": "坎", "mansion": "坎宅", "stars": ["五鬼", "伏位", "天医", "生气", "延年", "绝命", "祸害", "六煞"]},
      {"sittingTrigram": "艮", "mansion": "艮宅", "stars": ["六煞", "绝命", "伏位", "祸害", "生气", "延年", "天医", "五鬼"]},
      {"sittingTrigram": "震", "mansion": "震宅", "stars": ["延年", "生气", "祸害", "伏位", "绝命", "五鬼", "六煞", "天医"]},
      {"sittingTrigram": "巽", "mansion": "巽宅", "stars": ["天医", "五鬼", "六煞", "祸害", "伏位", "生气", "绝命", "延年"]},
      {"sittingTrigram": "离", "mansion": "离宅", "stars": ["六煞", "五鬼", "绝命", "延年", "祸害", "伏位", "生气", "天医"]},
      {"sittingTrigram": "坤", "mansion": "坤宅", "stars": ["天医", "延年", "绝命", "生气", "祸害", "五鬼", "伏位", "六煞"]},
      {"sittingTrigram": "兑", "mansion": "兑宅", "stars": ["生气", "祸害", "延年", "绝命", "六煞", "天医", "五鬼", "伏位"]}
    ]
  },
  "testFixtures": [
    {"inputSitting": "乾", "inputTarget": "兑", "expectedStar": "生气", "expectedLuck": "吉"},
    {"inputSitting": "乾", "inputTarget": "离", "expectedStar": "绝命", "expectedLuck": "凶"},
    {"inputSitting": "坎", "inputTarget": "震", "expectedStar": "生气", "expectedLuck": "吉"},
    {"inputSitting": "震", "inputTarget": "兑", "expectedStar": "天医", "expectedLuck": "吉"},
    {"inputSitting": "坤", "inputTarget": "坎", "expectedStar": "祸害", "expectedLuck": "凶"}
  ]
}
');
INSERT INTO static_data_document ("file_name", "payload_json") VALUES ('data/bearing/24_mountains.json', '{
  "$schema": "../schema/layer-a-static-data.schema.json",
  "configType": "static",
  "layer": "A",
  "id": "bearing-24-mountains-v1",
  "name": "二十四山边界表",
  "version": "1.0.0",
  "source": "《罗经透解》·地盘正针",
  "description": "二十四山度数边界，地盘正针基准，正北子山中线=0°(360°)，顺时针递增",
  "bearingStandard": {
    "zeroPoint": "正北·子山中线",
    "zeroDegree": 0,
    "direction": "clockwise",
    "totalDegree": 360,
    "precision": "至少百万分之一度（定点数）",
    "plateType": "地盘正针",
    "offsetFromTrueNorth": 0
  },
  "boundaryRule": {
    "type": "half-open",
    "description": "每山中线±7.5°，下界包含、上界不包含；界线值触发小空亡警告",
    "toleranceForBoundary": 0.000001
  },
  "compatibility": {
    "reuses": [],
    "reusedBy": [
      "fenjin-120-v1",
      "kongwang-lines-v1",
      "feixing-sanyuan-dragon-v1",
      "fan-gua-sequence-v1"
    ]
  },
  "testFixtures": [
    {"input": 0.0, "expectedMountain": "子", "description": "正北中点"},
    {"input": 7.49, "expectedMountain": "子", "description": "子山上界内部"},
    {"input": 7.5, "expectedMountain": null, "expectedWarning": "小空亡", "description": "子癸交界"},
    {"input": 22.49, "expectedMountain": "癸", "description": "癸山下界内部"},
    {"input": 359.999, "expectedMountain": "子", "description": "周期回绕"},
    {"input": 361.0, "expectedMountain": "子", "description": "归一化回绕"}
  ],
  "mountains": [
    {"index": 1, "name": "壬", "startDegree": 337.5, "endDegree": 352.5, "midDegree": 345.0, "trigram": "坎", "baguaNumber": 1, "element": "水", "yinYang": "阳", "threeYuanDragon": "地元龙", "shanType": "天干"},
    {"index": 2, "name": "子", "startDegree": 352.5, "endDegree": 7.5, "midDegree": 0.0, "trigram": "坎", "baguaNumber": 1, "element": "水", "yinYang": "阴", "threeYuanDragon": "天元龙", "shanType": "地支"},
    {"index": 3, "name": "癸", "startDegree": 7.5, "endDegree": 22.5, "midDegree": 15.0, "trigram": "坎", "baguaNumber": 1, "element": "水", "yinYang": "阴", "threeYuanDragon": "人元龙", "shanType": "天干"},
    {"index": 4, "name": "丑", "startDegree": 22.5, "endDegree": 37.5, "midDegree": 30.0, "trigram": "艮", "baguaNumber": 8, "element": "土", "yinYang": "阴", "threeYuanDragon": "地元龙", "shanType": "地支"},
    {"index": 5, "name": "艮", "startDegree": 37.5, "endDegree": 52.5, "midDegree": 45.0, "trigram": "艮", "baguaNumber": 8, "element": "土", "yinYang": "阳", "threeYuanDragon": "天元龙", "shanType": "四维"},
    {"index": 6, "name": "寅", "startDegree": 52.5, "endDegree": 67.5, "midDegree": 60.0, "trigram": "艮", "baguaNumber": 8, "element": "木", "yinYang": "阳", "threeYuanDragon": "人元龙", "shanType": "地支"},
    {"index": 7, "name": "甲", "startDegree": 67.5, "endDegree": 82.5, "midDegree": 75.0, "trigram": "震", "baguaNumber": 3, "element": "木", "yinYang": "阳", "threeYuanDragon": "地元龙", "shanType": "天干"},
    {"index": 8, "name": "卯", "startDegree": 82.5, "endDegree": 97.5, "midDegree": 90.0, "trigram": "震", "baguaNumber": 3, "element": "木", "yinYang": "阴", "threeYuanDragon": "天元龙", "shanType": "地支"},
    {"index": 9, "name": "乙", "startDegree": 97.5, "endDegree": 112.5, "midDegree": 105.0, "trigram": "震", "baguaNumber": 3, "element": "木", "yinYang": "阴", "threeYuanDragon": "人元龙", "shanType": "天干"},
    {"index": 10, "name": "辰", "startDegree": 112.5, "endDegree": 127.5, "midDegree": 120.0, "trigram": "巽", "baguaNumber": 4, "element": "土", "yinYang": "阴", "threeYuanDragon": "地元龙", "shanType": "地支"},
    {"index": 11, "name": "巽", "startDegree": 127.5, "endDegree": 142.5, "midDegree": 135.0, "trigram": "巽", "baguaNumber": 4, "element": "木", "yinYang": "阴", "threeYuanDragon": "天元龙", "shanType": "四维"},
    {"index": 12, "name": "巳", "startDegree": 142.5, "endDegree": 157.5, "midDegree": 150.0, "trigram": "巽", "baguaNumber": 4, "element": "火", "yinYang": "阳", "threeYuanDragon": "人元龙", "shanType": "地支"},
    {"index": 13, "name": "丙", "startDegree": 157.5, "endDegree": 172.5, "midDegree": 165.0, "trigram": "离", "baguaNumber": 9, "element": "火", "yinYang": "阳", "threeYuanDragon": "地元龙", "shanType": "天干"},
    {"index": 14, "name": "午", "startDegree": 172.5, "endDegree": 187.5, "midDegree": 180.0, "trigram": "离", "baguaNumber": 9, "element": "火", "yinYang": "阴", "threeYuanDragon": "天元龙", "shanType": "地支"},
    {"index": 15, "name": "丁", "startDegree": 187.5, "endDegree": 202.5, "midDegree": 195.0, "trigram": "离", "baguaNumber": 9, "element": "火", "yinYang": "阴", "threeYuanDragon": "人元龙", "shanType": "天干"},
    {"index": 16, "name": "未", "startDegree": 202.5, "endDegree": 217.5, "midDegree": 210.0, "trigram": "坤", "baguaNumber": 2, "element": "土", "yinYang": "阴", "threeYuanDragon": "地元龙", "shanType": "地支"},
    {"index": 17, "name": "坤", "startDegree": 217.5, "endDegree": 232.5, "midDegree": 225.0, "trigram": "坤", "baguaNumber": 2, "element": "土", "yinYang": "阴", "threeYuanDragon": "天元龙", "shanType": "四维"},
    {"index": 18, "name": "申", "startDegree": 232.5, "endDegree": 247.5, "midDegree": 240.0, "trigram": "坤", "baguaNumber": 2, "element": "金", "yinYang": "阳", "threeYuanDragon": "人元龙", "shanType": "地支"},
    {"index": 19, "name": "庚", "startDegree": 247.5, "endDegree": 262.5, "midDegree": 255.0, "trigram": "兑", "baguaNumber": 7, "element": "金", "yinYang": "阳", "threeYuanDragon": "地元龙", "shanType": "天干"},
    {"index": 20, "name": "酉", "startDegree": 262.5, "endDegree": 277.5, "midDegree": 270.0, "trigram": "兑", "baguaNumber": 7, "element": "金", "yinYang": "阴", "threeYuanDragon": "天元龙", "shanType": "地支"},
    {"index": 21, "name": "辛", "startDegree": 277.5, "endDegree": 292.5, "midDegree": 285.0, "trigram": "兑", "baguaNumber": 7, "element": "金", "yinYang": "阴", "threeYuanDragon": "人元龙", "shanType": "天干"},
    {"index": 22, "name": "戌", "startDegree": 292.5, "endDegree": 307.5, "midDegree": 300.0, "trigram": "乾", "baguaNumber": 6, "element": "土", "yinYang": "阴", "threeYuanDragon": "地元龙", "shanType": "地支"},
    {"index": 23, "name": "乾", "startDegree": 307.5, "endDegree": 322.5, "midDegree": 315.0, "trigram": "乾", "baguaNumber": 6, "element": "金", "yinYang": "阳", "threeYuanDragon": "天元龙", "shanType": "四维"},
    {"index": 24, "name": "亥", "startDegree": 322.5, "endDegree": 337.5, "midDegree": 330.0, "trigram": "乾", "baguaNumber": 6, "element": "水", "yinYang": "阳", "threeYuanDragon": "人元龙", "shanType": "地支"}
  ],
  "categorization": {
    "threeLucky": ["艮", "巽", "卯"],
    "sixExcellent": ["丙", "丁", "庚", "辛", "艮", "巽"],
    "threeEvil": ["乾", "坤", "午"],
    "sixHarmful": ["子", "丑", "寅", "卯", "辰", "巳"]
  }
}
');
INSERT INTO static_data_document ("file_name", "payload_json") VALUES ('data/feixing/fan_gua_sequence.json', '{
  "$schema": "../../schema/layer-a-static-data.schema.json",
  "configType": "static",
  "layer": "A",
  "id": "fan-gua-sequence-v1",
  "name": "辅星翻卦·中爻起翻",
  "version": "1.0.0",
  "source": "黄石公辅星水法·地母卦",
  "description": "中爻起翻完整推算步骤：中→下→中→上→中→下→中，7次变爻完成八星排布",
  "dependsOn": ["bagua-najia-v1"],
  "variantSteps": {
    "description": "固定变爻顺序",
    "steps": ["中", "下", "中", "上", "中", "下", "中"],
    "totalSteps": 7
  },
  "starSequence": {
    "description": "地母卦·辅星水法九星固定序列",
    "stars": [
      {"index": 0, "name": "辅弼", "luck": "吉", "description": "本宫起点"},
      {"index": 1, "name": "武曲", "luck": "吉", "description": "财帛官禄"},
      {"index": 2, "name": "破军", "luck": "凶", "description": "破败争斗"},
      {"index": 3, "name": "廉贞", "luck": "凶", "description": "火灾恶疾"},
      {"index": 4, "name": "贪狼", "luck": "吉", "description": "旺丁旺财"},
      {"index": 5, "name": "巨门", "luck": "吉", "description": "富贵长寿"},
      {"index": 6, "name": "禄存", "luck": "凶", "description": "官非疾病"},
      {"index": 7, "name": "文曲", "luck": "凶", "description": "桃花淫乱"}
    ]
  },
  "example_qianJiaXiang": {
    "description": "乾甲向示例推演过程",
    "facingDirection": "乾甲",
    "startingTrigram": "乾",
    "steps": [
      {"variantYao": "中", "fromTrigram": "乾", "toTrigram": "离", "starIndex": 1, "star": "武曲"},
      {"variantYao": "下", "fromTrigram": "离", "toTrigram": "艮", "starIndex": 2, "star": "破军"},
      {"variantYao": "中", "fromTrigram": "艮", "toTrigram": "巽", "starIndex": 3, "star": "廉贞"},
      {"variantYao": "上", "fromTrigram": "巽", "toTrigram": "坎", "starIndex": 4, "star": "贪狼"},
      {"variantYao": "中", "fromTrigram": "坎", "toTrigram": "坤", "starIndex": 5, "star": "巨门"},
      {"variantYao": "下", "fromTrigram": "坤", "toTrigram": "震", "starIndex": 6, "star": "禄存"},
      {"variantYao": "中", "fromTrigram": "震", "toTrigram": "兑", "starIndex": 7, "star": "文曲"}
    ],
    "finalMapping": {
      "乾": "辅弼", "离": "武曲", "艮": "破军", "巽": "廉贞",
      "坎": "贪狼", "坤": "巨门", "震": "禄存", "兑": "文曲"
    }
  },
  "variantRule": {
    "description": "爻位编号：上爻=2, 中爻=1, 下爻=0。变爻即翻转该爻阴阳（阳变阴、阴变阳）",
    "trigramYaoEncoding": {
      "乾": [1, 1, 1], "兑": [1, 1, 0], "离": [1, 0, 1], "震": [1, 0, 0],
      "巽": [0, 1, 1], "坎": [0, 1, 0], "艮": [0, 0, 1], "坤": [0, 0, 0]
    }
  },
  "note": "天父卦用于论山龙；地母卦（上述）专论水法。本配置为地母卦",
  "testFixtures": [
    {"inputFacing": "乾", "expectedStep2Star": "武曲", "expectedStep8Trigram": "兑", "expectedStep8Star": "文曲"},
    {"inputFacing": "乾", "expectedStartTrigram": "乾", "expectedStarAtQian": "辅弼"}
  ]
}
');
INSERT INTO static_data_document ("file_name", "payload_json") VALUES ('data/feixing/parent_star.json', '{
  "$schema": "../../schema/layer-a-static-data.schema.json",
  "configType": "static",
  "layer": "A",
  "id": "parent-star-mapping-v1",
  "name": "大玄空阴宅父母星对照表",
  "version": "1.0.0",
  "source": "大玄空阴宅挨星（与沈氏玄空飞星体系互不通用）",
  "description": "本山星逆数四位得父母星。公式：父母星=(本山星+5) mod 9 + 1",
  "formula": {
    "chinese": "父母星=本山星逆数四位",
    "computed": "parentStar = (mountainStar + 5) mod 9 + 1",
    "note": "九星数字序列1,2,3,4,5,6,7,8,9循环逆推"
  },
  "lookupTable": [
    {"mountainStarNumber": 1, "mountainStarName": "一白·贪狼", "parentStarNumber": 7, "parentStarName": "七赤·破军"},
    {"mountainStarNumber": 2, "mountainStarName": "二黑·巨门", "parentStarNumber": 8, "parentStarName": "八白·左辅"},
    {"mountainStarNumber": 3, "mountainStarName": "三碧·禄存", "parentStarNumber": 9, "parentStarName": "九紫·右弼"},
    {"mountainStarNumber": 4, "mountainStarName": "四绿·文曲", "parentStarNumber": 1, "parentStarName": "一白·贪狼"},
    {"mountainStarNumber": 5, "mountainStarName": "五黄·廉贞", "parentStarNumber": 2, "parentStarName": "二黑·巨门"},
    {"mountainStarNumber": 6, "mountainStarName": "六白·武曲", "parentStarNumber": 3, "parentStarName": "三碧·禄存"},
    {"mountainStarNumber": 7, "mountainStarName": "七赤·破军", "parentStarNumber": 4, "parentStarName": "四绿·文曲"},
    {"mountainStarNumber": 8, "mountainStarName": "八白·左辅", "parentStarNumber": 5, "parentStarName": "五黄·廉贞"},
    {"mountainStarNumber": 9, "mountainStarName": "九紫·右弼", "parentStarNumber": 6, "parentStarName": "六白·武曲"}
  ],
  "operationalRule": "阴宅不以运盘坐山星入中，改用父母星入中宫，再依三元龙阴阳顺逆飞布九宫",
  "testFixtures": [
    {"inputMountainStar": 2, "expectedParentStar": 8},
    {"inputMountainStar": 1, "expectedParentStar": 7},
    {"inputMountainStar": 9, "expectedParentStar": 6},
    {"inputMountainStar": 5, "expectedParentStar": 2}
  ]
}
');
INSERT INTO static_data_document ("file_name", "payload_json") VALUES ('data/feixing/three_yuan_dragon.json', '{
  "$schema": "../../schema/layer-a-static-data.schema.json",
  "configType": "static",
  "layer": "A",
  "id": "feixing-sanyuan-dragon-v1",
  "name": "玄空飞星·三元龙阴阳判定表",
  "version": "1.0.0",
  "source": "沈氏玄空·三元龙（天元/地元/人元）",
  "description": "二十四山三元龙阴阳归属，用于飞星排盘时判定顺飞/逆飞。阳顺飞，阴逆飞",
  "dependsOn": ["bearing-24-mountains-v1"],
  "flyingStarTrack": {
    "description": "飞星固定轨迹，九宫位序",
    "sequence": ["中", "乾", "兑", "艮", "离", "坎", "坤", "震", "巽"]
  },
  "threeYuanDragon": {
    "tianYuan": {
      "name": "天元龙",
      "mountains": ["子", "午", "卯", "酉", "乾", "坤", "艮", "巽"],
      "details": [
        {"mountain": "乾", "yinYang": "阳"}, {"mountain": "艮", "yinYang": "阳"},
        {"mountain": "坤", "yinYang": "阴"}, {"mountain": "巽", "yinYang": "阴"},
        {"mountain": "子", "yinYang": "阴"}, {"mountain": "午", "yinYang": "阴"},
        {"mountain": "卯", "yinYang": "阴"}, {"mountain": "酉", "yinYang": "阴"}
      ]
    },
    "diYuan": {
      "name": "地元龙",
      "mountains": ["辰", "戌", "丑", "未", "甲", "庚", "壬", "丙"],
      "details": [
        {"mountain": "甲", "yinYang": "阳"}, {"mountain": "庚", "yinYang": "阳"},
        {"mountain": "壬", "yinYang": "阳"}, {"mountain": "丙", "yinYang": "阳"},
        {"mountain": "辰", "yinYang": "阴"}, {"mountain": "戌", "yinYang": "阴"},
        {"mountain": "丑", "yinYang": "阴"}, {"mountain": "未", "yinYang": "阴"}
      ]
    },
    "renYuan": {
      "name": "人元龙",
      "mountains": ["寅", "申", "巳", "亥", "乙", "丁", "辛", "癸"],
      "details": [
        {"mountain": "寅", "yinYang": "阳"}, {"mountain": "申", "yinYang": "阳"},
        {"mountain": "巳", "yinYang": "阳"}, {"mountain": "亥", "yinYang": "阳"},
        {"mountain": "乙", "yinYang": "阴"}, {"mountain": "丁", "yinYang": "阴"},
        {"mountain": "辛", "yinYang": "阴"}, {"mountain": "癸", "yinYang": "阴"}
      ]
    }
  },
  "flyingDirectionRule": {
    "description": "三元龙阳=顺飞，阴=逆飞",
    "yang": {"direction": "顺飞", "description": "沿固定轨迹正向排布"},
    "yin": {"direction": "逆飞", "description": "沿固定轨迹逆向排布"}
  },
  "starSequence": {
    "description": "九星飞布用数字序列",
    "numbers": [1, 2, 3, 4, 5, 6, 7, 8, 9]
  },
  "testFixtures": [
    {"inputMountain": "子", "expectedDragonType": "天元龙", "expectedYinYang": "阴", "expectedFlyDirection": "逆飞"},
    {"inputMountain": "甲", "expectedDragonType": "地元龙", "expectedYinYang": "阳", "expectedFlyDirection": "顺飞"},
    {"inputMountain": "寅", "expectedDragonType": "人元龙", "expectedYinYang": "阳", "expectedFlyDirection": "顺飞"},
    {"inputMountain": "乙", "expectedDragonType": "人元龙", "expectedYinYang": "阴", "expectedFlyDirection": "逆飞"}
  ]
}
');
INSERT INTO static_data_document ("file_name", "payload_json") VALUES ('data/fenjin/120_fenjin.json', '{
  "$schema": "../../schema/layer-a-static-data.schema.json",
  "configType": "static",
  "layer": "A",
  "id": "fenjin-120-v1",
  "name": "120分金表",
  "version": "1.0.0",
  "source": "《罗经透解》·地盘正针分金",
  "description": "二十四山每山均分5份，每份3°，合计120分金。阳支配甲丙戊庚壬，阴支配乙丁己辛癸。行业通用只取丙丁庚辛48旺相分金",
  "dependsOn": ["bearing-24-mountains-v1"],
  "fenjinPerMountain": 5,
  "widthPerFenjinDegrees": 3.0,
  "selectionRules": {
    "wangXiang": {
      "description": "旺相分金（推荐使用）",
      "allowedGanZhi": ["丙", "丁", "庚", "辛"],
      "count": 48
    },
    "guiJia": {
      "description": "龟甲空亡（禁用）",
      "allowedGanZhi": ["戊", "己"],
      "count": 24
    },
    "guXu": {
      "description": "孤虚（一般不用）",
      "allowedGanZhi": ["甲", "乙", "壬", "癸"],
      "count": 48
    }
  },
  "ganZhiSequence": {
    "yangBranches": {
      "branches": ["子", "寅", "辰", "午", "申", "戌"],
      "ganSequence": ["甲", "丙", "戊", "庚", "壬"],
      "description": "阳支：甲丙戊庚壬"
    },
    "yinBranches": {
      "branches": ["丑", "卯", "巳", "未", "酉", "亥"],
      "ganSequence": ["乙", "丁", "己", "辛", "癸"],
      "description": "阴支：乙丁己辛癸"
    },
    "eightGanAndFourWei": {
      "description": "八干四维从前山取分金序列",
      "ganWei": ["壬", "癸", "甲", "乙", "丙", "丁", "庚", "辛", "乾", "艮", "巽", "坤"]
    }
  },
  "testFixtures": [
    {"input": 0.0, "expectedIndex": 3, "expectedGanZhi": "戊子", "expectedType": "龟甲空亡", "description": "子山中点=戊子=龟甲"},
    {"input": 2.0, "expectedIndex": 4, "expectedGanZhi": "庚子", "expectedType": "旺相", "description": "子山第4格=庚子=旺相"},
    {"input": 3.0, "expectedIndex": 5, "expectedGanZhi": "壬子", "expectedType": "孤虚", "description": "子山第5格=壬子=孤虚"},
    {"input": 352.5, "expectedIndex": null, "expectedType": "小空亡", "description": "亥壬交界"},
    {"input": 7.5, "expectedIndex": null, "expectedType": "小空亡", "description": "子癸交界"}
  ]
}
');
INSERT INTO static_data_document ("file_name", "payload_json") VALUES ('data/fenjin/kongwang_lines.json', '{
  "$schema": "../../schema/layer-a-static-data.schema.json",
  "configType": "static",
  "layer": "A",
  "id": "kongwang-lines-v1",
  "name": "空亡线定义",
  "version": "1.0.0",
  "source": "《罗经透解》·空亡禁忌",
  "description": "大空亡、小空亡、龟甲空亡、孤虚的精确度数定义",
  "dependsOn": ["bearing-24-mountains-v1", "fenjin-120-v1"],
  "smallKongWang": {
    "description": "二十四山两山交界线，气驳杂",
    "degreeList": [22.5, 37.5, 52.5, 67.5, 82.5, 97.5, 112.5, 127.5, 142.5, 157.5, 172.5, 187.5, 202.5, 217.5, 232.5, 247.5, 262.5, 277.5, 292.5, 307.5, 322.5, 337.5, 352.5, 7.5],
    "offsetRecommendation": "偏离界线至少1.5°（半个分金格）"
  },
  "largeKongWang": {
    "description": "八干四维每山正中7.5°中线为核心红线；部分师门含子午卯酉",
    "coreLines": [
      {"mountain": "壬", "midDegree": 345.0, "forbiddenRange": [342.5, 347.5]},
      {"mountain": "癸", "midDegree": 15.0, "forbiddenRange": [12.5, 17.5]},
      {"mountain": "甲", "midDegree": 75.0, "forbiddenRange": [72.5, 77.5]},
      {"mountain": "乙", "midDegree": 105.0, "forbiddenRange": [102.5, 107.5]},
      {"mountain": "丙", "midDegree": 165.0, "forbiddenRange": [162.5, 167.5]},
      {"mountain": "丁", "midDegree": 195.0, "forbiddenRange": [192.5, 197.5]},
      {"mountain": "庚", "midDegree": 255.0, "forbiddenRange": [252.5, 257.5]},
      {"mountain": "辛", "midDegree": 285.0, "forbiddenRange": [282.5, 287.5]},
      {"mountain": "乾", "midDegree": 315.0, "forbiddenRange": [312.5, 317.5]},
      {"mountain": "坤", "midDegree": 225.0, "forbiddenRange": [222.5, 227.5]},
      {"mountain": "艮", "midDegree": 45.0, "forbiddenRange": [42.5, 47.5]},
      {"mountain": "巽", "midDegree": 135.0, "forbiddenRange": [132.5, 137.5]}
    ],
    "extendedParameter": {
      "includeZiWuMaoYou": false,
      "description": "部分师门将子午卯酉地支中线亦纳入大空亡；开关默认关闭"
    }
  },
  "guiJiaKongWang": {
    "description": "地支正中分金带戊己干支，每山第3格（±1.5°）",
    "rule": "每山中线±1.5°为龟甲禁区",
    "example": "子山中线0°，龟甲空亡区间358.5°~1.5°"
  },
  "guXuLine": {
    "description": "孤阳甲壬、孤阴乙癸对应的分金区间，常紧邻大空亡两侧",
    "guYang": ["甲", "壬"],
    "guYin": ["乙", "癸"]
  },
  "testFixtures": [
    {"input": 7.5, "expectedKongWangType": "小空亡", "description": "子癸交界=小空亡"},
    {"input": 45.0, "expectedKongWangType": "大空亡", "description": "艮山中线=大空亡"},
    {"input": 1.5, "expectedKongWangType": "龟甲空亡", "description": "子山龟甲上界"},
    {"input": 358.5, "expectedKongWangType": "龟甲空亡", "description": "子山龟甲下界"},
    {"input": 0.0, "expectedKongWangType": "龟甲空亡", "description": "子山中线=戊子龟甲"}
  ]
}
');
INSERT INTO static_data_document ("file_name", "payload_json") VALUES ('data/lubanchi/luban_chi.json', '{
  "$schema": "../../schema/layer-a-static-data.schema.json",
  "configType": "static",
  "layer": "A",
  "id": "luban-chi-v1",
  "name": "鲁班尺算法（阳尺+阴尺）",
  "version": "1.0.0",
  "source": "传统营造法式·门光尺/丁兰尺",
  "description": "阳尺门光尺（46.08cm周期，8格）和阴尺丁兰尺（39.6cm周期，10格）。Phase 7实现，Phase 1暂不纳入核心开发范围",
  "phase": "Phase 7",
  "yangChi": {
    "name": "阳尺·门光尺",
    "usage": "阳宅门窗尺寸",
    "cycleLengthCm": 46.08,
    "toleranceCm": 0.3,
    "grids": [
      {"index": 0, "name": "财", "startCm": 0.0, "endCm": 5.76, "luck": "吉", "subMeanings": ["财德", "宝库", "六合", "迎福"]},
      {"index": 1, "name": "病", "startCm": 5.76, "endCm": 11.52, "luck": "凶", "subMeanings": ["失脱", "官鬼", "劫财", "孤寡"]},
      {"index": 2, "name": "离", "startCm": 11.52, "endCm": 17.28, "luck": "凶", "subMeanings": ["长库", "劫财", "官鬼", "失脱"]},
      {"index": 3, "name": "义", "startCm": 17.28, "endCm": 23.04, "luck": "吉", "subMeanings": ["添丁", "益利", "贵子", "大吉"]},
      {"index": 4, "name": "官", "startCm": 23.04, "endCm": 28.80, "luck": "吉", "subMeanings": ["顺科", "横财", "进益", "富贵"]},
      {"index": 5, "name": "劫", "startCm": 28.80, "endCm": 34.56, "luck": "凶", "subMeanings": ["死别", "退口", "离乡", "财失"]},
      {"index": 6, "name": "害", "startCm": 34.56, "endCm": 40.32, "luck": "凶", "subMeanings": ["灾至", "死绝", "病临", "口舌"]},
      {"index": 7, "name": "本", "startCm": 40.32, "endCm": 46.08, "luck": "吉", "subMeanings": ["财德", "宝库", "六合", "迎福"]}
    ],
    "formula": "Rem = L mod 46.08; 按余数查表判定格位和吉凶",
    "alternativeVersion": {
      "name": "市面流行42.9cm版本",
      "cycleLengthCm": 42.9,
      "note": "提供切换参数"
    }
  },
  "yinChi": {
    "name": "阴尺·丁兰尺",
    "usage": "墓地、墓碑、灵位、神龛",
    "cycleLengthCm": 39.6,
    "grids": [
      {"name": "丁", "luck": "吉"}, {"name": "害", "luck": "凶"}, {"name": "旺", "luck": "吉"},
      {"name": "苦", "luck": "凶"}, {"name": "义", "luck": "吉"}, {"name": "官", "luck": "吉"},
      {"name": "死", "luck": "凶"}, {"name": "兴", "luck": "吉"}, {"name": "失", "luck": "凶"},
      {"name": "财", "luck": "吉"}
    ]
  },
  "usageRule": "阳宅门窗用阳尺；墓地墓碑用阴尺；不可混用",
  "testFixtures": [
    {"inputCm": 46.08, "expectedGrid": "财", "expectedLuck": "吉", "note": "正好一个周期"},
    {"inputCm": 50.0, "expectedGrid": "财", "expectedLuck": "吉", "note": "余数3.92落在财格"},
    {"inputCm": 55.0, "expectedGrid": "病", "expectedLuck": "凶", "note": "余数8.92落在病格"}
  ]
}
');
INSERT INTO static_data_document ("file_name", "payload_json") VALUES ('data/sanhe/double_mountains.json', '{
  "$schema": "../../schema/layer-a-static-data.schema.json",
  "configType": "static",
  "layer": "A",
  "id": "double-mountains-v1",
  "name": "双山五行表",
  "version": "1.0.0",
  "source": "杨公三合风水·天盘纳水专用",
  "description": "相邻一干一支合并为一组，共12组，对应十二长生。天盘纳水专用，地盘立向不用此表",
  "dependsOn": [],
  "doubleMountains": [
    {"pair": "壬子", "elements": ["壬", "子"], "wuxing": "水", "bureau": "水局", "role": null},
    {"pair": "癸丑", "elements": ["癸", "丑"], "wuxing": "金", "bureau": "金局", "role": "墓库"},
    {"pair": "艮寅", "elements": ["艮", "寅"], "wuxing": "火", "bureau": "火局", "role": "长生"},
    {"pair": "甲卯", "elements": ["甲", "卯"], "wuxing": "木", "bureau": "木局", "role": "帝旺"},
    {"pair": "乙辰", "elements": ["乙", "辰"], "wuxing": "水", "bureau": "水局", "role": "墓库"},
    {"pair": "巽巳", "elements": ["巽", "巳"], "wuxing": "金", "bureau": "金局", "role": "长生"},
    {"pair": "丙午", "elements": ["丙", "午"], "wuxing": "火", "bureau": "火局", "role": "帝旺"},
    {"pair": "丁未", "elements": ["丁", "未"], "wuxing": "木", "bureau": "木局", "role": "墓库"},
    {"pair": "坤申", "elements": ["坤", "申"], "wuxing": "水", "bureau": "水局", "role": "长生"},
    {"pair": "庚酉", "elements": ["庚", "酉"], "wuxing": "金", "bureau": "金局", "role": "帝旺"},
    {"pair": "辛戌", "elements": ["辛", "戌"], "wuxing": "火", "bureau": "火局", "role": "墓库"},
    {"pair": "乾亥", "elements": ["乾", "亥"], "wuxing": "木", "bureau": "木局", "role": "长生"}
  ],
  "quickLookupFormula": {
    "description": "三合五行起长生诀，用于快速判定四大局归属",
    "formula": "坤壬乙→水局, 艮丙辛→火局, 巽庚癸→金局, 乾甲丁→木局"
  },
  "testFixtures": [
    {"input": "壬子", "expectedWuxing": "水", "expectedBureau": "水局"},
    {"input": "癸丑", "expectedWuxing": "金", "expectedBureau": "金局"},
    {"input": "艮寅", "expectedWuxing": "火", "expectedBureau": "火局"},
    {"input": "甲卯", "expectedWuxing": "木", "expectedBureau": "木局"}
  ]
}
');
INSERT INTO static_data_document ("file_name", "payload_json") VALUES ('data/sanhe/four_bureaus.json', '{
  "$schema": "../../schema/layer-a-static-data.schema.json",
  "configType": "static",
  "layer": "A",
  "id": "four-bureaus-v1",
  "name": "四大局·长生十二宫",
  "version": "1.0.0",
  "source": "杨公三合风水·阴宅核心",
  "description": "四大局判定（天盘看水口定局）、十二长生固定序列、顺逆行规则",
  "fourBureaus": {
    "water": {
      "name": "水局",
      "combinedEarthly": ["申", "子", "辰"],
      "description": "辛壬会而聚辰",
      "muKu": "乙辰",
      "changShengStart": "坤申",
      "diWang": "壬子"
    },
    "fire": {
      "name": "火局",
      "combinedEarthly": ["寅", "午", "戌"],
      "description": "乙丙交而趋戌",
      "muKu": "辛戌",
      "changShengStart": "艮寅",
      "diWang": "丙午"
    },
    "metal": {
      "name": "金局",
      "combinedEarthly": ["巳", "酉", "丑"],
      "description": "斗牛纳丁庚之气",
      "muKu": "癸丑",
      "changShengStart": "巽巳",
      "diWang": "庚酉"
    },
    "wood": {
      "name": "木局",
      "combinedEarthly": ["亥", "卯", "未"],
      "description": "金羊收癸甲之灵",
      "muKu": "丁未",
      "changShengStart": "乾亥",
      "diWang": "甲卯"
    }
  },
  "twelveGrowthSequence": ["长生", "沐浴", "冠带", "临官", "帝旺", "衰", "病", "死", "墓", "绝", "胎", "养"],
  "forwardReverseRule": {
    "yinZhai": {
      "description": "阴宅古法：龙属阳顺行，水属阴逆行",
      "dragonDirection": "顺排",
      "waterDirection": "逆排"
    },
    "yangZhaiPingYang": {
      "description": "阳宅平洋：部分流派统一顺排，不论龙顺逆",
      "switchParameter": "yangZhaiUnifiedForward",
      "default": false
    }
  },
  "waterAssessment": {
    "rule": "来水宜生旺；去水宜墓绝。生旺出水为凶，墓绝来水为凶。",
    "goodIncomingWaterPhases": ["长生", "沐浴", "冠带", "临官", "帝旺"],
    "goodOutgoingWaterPhases": ["衰", "病", "死", "墓", "绝"],
    "badIncomingWaterPhases": ["墓", "绝"],
    "badOutgoingWaterPhases": ["长生", "帝旺"]
  },
  "testFixtures": [
    {"inputMouth": "乙辰", "expectedBureau": "水局"},
    {"inputMouth": "辛戌", "expectedBureau": "火局"},
    {"inputMouth": "癸丑", "expectedBureau": "金局"},
    {"inputMouth": "丁未", "expectedBureau": "木局"},
    {"inputBureau": "水局", "expectedChangSheng": "坤申", "expectedDiWang": "壬子"},
    {"inputBureau": "木局", "expectedChangSheng": "乾亥", "expectedDiWang": "甲卯"}
  ]
}
');
INSERT INTO static_data_document ("file_name", "payload_json") VALUES ('data/sanhe/three_pans.json', '{
  "$schema": "../../schema/layer-a-static-data.schema.json",
  "configType": "static",
  "layer": "A",
  "id": "three-pans-v1",
  "name": "地盘·人盘·天盘三针",
  "version": "1.0.0",
  "source": "杨公三合罗盘·赖布衣/杨救贫",
  "description": "三盘偏移量与用途。基准：地盘正针=0°（地磁子午）",
  "pans": [
    {
      "name": "地盘",
      "fullName": "地盘正针",
      "offsetDegrees": 0.0,
      "creator": "古制",
      "purposes": ["格龙", "立坐向", "120分金", "七十二龙", "二十四山"],
      "conversionFormula": "angle = rawAngle"
    },
    {
      "name": "人盘",
      "fullName": "人盘中针",
      "offsetDegrees": -7.5,
      "creator": "赖布衣",
      "purposes": ["消砂", "二十八宿五行论山峰生克"],
      "conversionFormula": "angle = rawAngle - 7.5; if angle < 0 then angle + 360"
    },
    {
      "name": "天盘",
      "fullName": "天盘缝针",
      "offsetDegrees": 7.5,
      "creator": "杨救贫",
      "purposes": ["纳水", "四大局", "十二长生水法"],
      "conversionFormula": "angle = rawAngle + 7.5; if angle >= 360 then angle - 360"
    }
  ],
  "testFixtures": [
    {"input": 0.0, "expectedDipan": 0.0, "expectedRenpan": 352.5, "expectedTianpan": 7.5, "description": "正北点"},
    {"input": 355.0, "expectedDipan": 355.0, "expectedRenpan": 347.5, "expectedTianpan": 2.5, "description": "越界回绕"},
    {"input": 180.0, "expectedDipan": 180.0, "expectedRenpan": 172.5, "expectedTianpan": 187.5, "description": "正南点"}
  ]
}
');
INSERT INTO static_data_document ("file_name", "payload_json") VALUES ('data/sanyuan/nine_yun.json', '{
  "$schema": "../../schema/layer-a-static-data.schema.json",
  "configType": "static",
  "layer": "A",
  "id": "sanyuan-nine-yun-v1",
  "name": "三元九运表",
  "version": "1.0.0",
  "source": "玄空通用·近代180年周期",
  "description": "三元九运完整周期表。重构时复用 xuan-metaphysics-core 的 ThreeYuanNineYunInfo.fromYear()",
  "reuses": "xuan-metaphysics-core/lib/models/yun_yun_info.dart",
  "cycleBase": {"epochYear": 1864, "yunDurationYears": 20, "yuanDurationYears": 60, "grandCycleYears": 180},
  "yuns": [
    {"yunNumber": 1, "starName": "一白·贪狼", "starNumber": 1, "trigram": "坎", "element": "水", "yuan": "上元", "startYear": 1864, "endYear": 1883},
    {"yunNumber": 2, "starName": "二黑·巨门", "starNumber": 2, "trigram": "坤", "element": "土", "yuan": "上元", "startYear": 1884, "endYear": 1903},
    {"yunNumber": 3, "starName": "三碧·禄存", "starNumber": 3, "trigram": "震", "element": "木", "yuan": "上元", "startYear": 1904, "endYear": 1923},
    {"yunNumber": 4, "starName": "四绿·文曲", "starNumber": 4, "trigram": "巽", "element": "木", "yuan": "中元", "startYear": 1924, "endYear": 1943},
    {"yunNumber": 5, "starName": "五黄·廉贞", "starNumber": 5, "trigram": null, "element": "土", "yuan": "中元", "startYear": 1944, "endYear": 1963},
    {"yunNumber": 6, "starName": "六白·武曲", "starNumber": 6, "trigram": "乾", "element": "金", "yuan": "中元", "startYear": 1964, "endYear": 1983},
    {"yunNumber": 7, "starName": "七赤·破军", "starNumber": 7, "trigram": "兑", "element": "金", "yuan": "下元", "startYear": 1984, "endYear": 2003},
    {"yunNumber": 8, "starName": "八白·左辅", "starNumber": 8, "trigram": "艮", "element": "土", "yuan": "下元", "startYear": 2004, "endYear": 2023},
    {"yunNumber": 9, "starName": "九紫·右弼", "starNumber": 9, "trigram": "离", "element": "火", "yuan": "下元", "startYear": 2024, "endYear": 2043}
  ],
  "yunSwitchRule": {
    "description": "流派存在两种换运规则，建模须内置可配置参数",
    "options": [
      {"name": "立春换运", "trigger": "交立春节气具体时刻", "precision": "分钟级", "default": true, "school": "玄空主流"},
      {"name": "元旦换运", "trigger": "公历1月1日0点整", "precision": "秒级", "default": false, "school": "部分流派"}
    ]
  },
  "cycleRule": "2044年起重新进入上元一运，无限循环",
  "testFixtures": [
    {"inputYear": 1864, "expectedYun": 1, "expectedStar": "一白·贪狼", "expectedYuan": "上元"},
    {"inputYear": 2024, "expectedYun": 9, "expectedStar": "九紫·右弼", "expectedYuan": "下元"},
    {"inputYear": 2023, "expectedYun": 8, "expectedStar": "八白·左辅", "expectedYuan": "下元"},
    {"inputYear": 2004, "expectedYun": 8, "expectedStar": "八白·左辅", "expectedYuan": "下元"}
  ]
}
');
INSERT INTO static_data_document ("file_name", "payload_json") VALUES ('data/xingsha/geometry.json', '{
  "$schema": "../../schema/layer-a-static-data.schema.json",
  "configType": "static",
  "layer": "A",
  "id": "xingsha-geometry-v1",
  "name": "五类形煞几何判定标准",
  "version": "1.0.0",
  "source": "传统堪舆形煞理论·量化定义",
  "description": "五类形煞的几何判定量化标准，以建筑太极点为中心建立极坐标系进行检测。只做几何候选，吉凶解释由RuleSet完成",
  "measurementBaseline": {
    "origin": "建筑太极点（几何中心）",
    "coordinateSystem": "极坐标（r, θ），以建筑中轴线为0°方向",
    "distanceFrom": "建筑外墙或地基外缘",
    "heightFrom": "室内±0标高",
    "angleReference": "太极点指向形煞物体质心的连线与建筑中轴线夹角"
  },
  "xingshaTypes": [
    {
      "id": "ge-jiao-shui",
      "name": "割脚水",
      "geometryConditions": {
        "waterDistance": {"max": 3.0, "unit": "m", "description": "水流/道路线性边界与建筑外墙最小水平投影距离≤3m"},
        "waterShape": "平行或半环绕基底",
        "waterElevation": "水体高程接近±0标高",
        "distinction": "环抱水距离＞5m为吉"
      },
      "testFixture": {
        "distance": 2.0,
        "shape": "parallel",
        "expected": "割脚水候选"
      }
    },
    {
      "id": "fan-gong-shui",
      "name": "反弓水（反弓煞）",
      "geometryConditions": {
        "waterShape": "河道/道路呈圆弧曲线",
        "convexSide": "圆弧外侧（弓背）朝向太极点",
        "curvatureCenter": "曲率中心远离建筑",
        "oppositeGood": "玉带水：圆弧内侧环抱建筑为吉"
      },
      "testFixture": {
        "arcDirection": "convexTowardBuilding",
        "expected": "反弓煞候选"
      }
    },
    {
      "id": "bai-hu-chui-xiong",
      "name": "白虎捶胸",
      "geometryConditions": {
        "direction": "建筑右侧（白虎方，兑卦）",
        "rightSideObject": "山体或建筑物",
        "protrusion": "形体向前突出，水平投影侵入明堂范围",
        "targetedAt": "突出部分正对房屋中部（胸线高度）",
        "leftSideCondition": "青龙方低矮无环抱"
      },
      "testFixture": {
        "directionSector": "rightWhiteTiger",
        "protrusionIntoMingTang": true,
        "expected": "白虎捶胸候选"
      }
    },
    {
      "id": "jian-shui",
      "name": "箭水（直冲水）",
      "geometryConditions": {
        "waterPath": "水流呈近似直线",
        "directionTarget": "流向太极点",
        "angleTolerance": {"max": 15.0, "unit": "度", "description": "水流方向与太极点→建筑中轴连线夹角偏差＜15°"},
        "bufferCheck": "无弯曲缓冲，直射明堂"
      },
      "testFixture": {
        "angle": 8.0,
        "expected": "箭水候选"
      }
    },
    {
      "id": "xie-fei-shui",
      "name": "斜飞水",
      "geometryConditions": {
        "condition": "水流抵达明堂前发生分叉、斜向撇出",
        "dispersion": "水流不向远处交汇，向外离散散开",
        "noConvergence": "无合襟"
      },
      "testFixture": {
        "branchBeforeMingTang": true,
        "expected": "斜飞水候选"
      }
    }
  ],
  "pipelineRule": {
    "description": "形煞只产生几何候选+置信度，吉凶解释由版本化RuleSet完成。人工确认后才进入正式解释",
    "outputType": "geometricCandidate",
    "requireManualConfirmation": true
  },
  "extendedReserved": ["天斩煞", "路冲", "孤峰", "探头砂"]
}
');
