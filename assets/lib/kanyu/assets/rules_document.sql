CREATE TABLE IF NOT EXISTS rules_document (  file_name TEXT PRIMARY KEY,  payload_json TEXT NOT NULL);
DELETE FROM rules_document;
INSERT INTO rules_document ("file_name", "payload_json") VALUES ('rules/ba_zhai/wandering_star.json', '{
  "$schema": "../../schema/layer-b-rule-config.schema.json",
  "configType": "rule",
  "layer": "B",
  "ruleId": "ba-zhai-you-nian-v1",
  "name": "八宅游年九星·坐山起伏位法",
  "version": "1.0.0",
  "source": "《八宅明镜》",
  "authorType": "built-in",
  "category": "yangzhai",
  "description": "以坐山为伏位，按大游年歌诀排布八宫九星。支持坐山起伏位和大门起伏位双模式切换",
  "parameters": [
    {"name": "sittingMountain", "type": "Mountain24", "required": true, "description": "宅坐山（二十四山之一）"},
    {"name": "mode", "type": "enum:sittingMountain|mainDoor", "required": false, "default": "sittingMountain", "description": "起伏位模式"},
    {"name": "mainDoorDirection", "type": "Mountain24", "required": false, "description": "大门朝向（mode=mainDoor时必填）"}
  ],
  "dataRefs": ["bagua-wandering-star-v1", "bearing-24-mountains-v1", "bagua-nine-palace-v1"],
  "pipeline": [
    {
      "step": 1, "name": "确定伏位宫", "action": "classify",
      "description": "根据mode参数确定伏位所在的八卦宫",
      "input": {"mode": "{{parameters.mode}}", "sittingMountain": "{{parameters.sittingMountain}}", "mainDoorDirection": "{{parameters.mainDoorDirection}}"},
      "ref": "bearing-24-mountains-v1",
      "output": "fuweiTrigram"
    },
    {
      "step": 2, "name": "查大游年映射表", "action": "lookup",
      "description": "以伏位宫为行，遍历八宫列为目标，查大游年歌矩阵",
      "input": {"fuweiTrigram": "{{fuweiTrigram}}"},
      "ref": "bagua-wandering-star-v1",
      "output": "palaceStarMapping"
    },
    {
      "step": 3, "name": "分类吉凶", "action": "classify",
      "description": "将每个宫的九星归类为吉或凶",
      "input": {"palaceStars": "{{palaceStarMapping}}"},
      "ref": "bagua-wandering-star-v1.starClassification",
      "output": "palaceLuckMapping"
    },
    {
      "step": 4, "name": "组装输出", "action": "compose",
      "description": "将结果组装为结构化输出",
      "output": "result"
    }
  ],
  "outputs": {
    "mansionType": {"type": "string", "description": "宅型（乾宅/坎宅/...）"},
    "fuweiPalace": {"type": "string", "description": "伏位所在八卦宫"},
    "mode": {"type": "string", "description": "使用的起伏位模式"},
    "palaceResults": {
      "type": "array",
      "items": {
        "palace": {"type": "string"},
        "star": {"type": "string"},
        "luck": {"type": "string", "enum": ["吉", "凶"]},
        "description": {"type": "string"}
      }
    }
  },
  "testFixtures": [
    {"input": {"sittingMountain": "乾", "mode": "sittingMountain"}, "expected": {"mansionType": "乾宅", "fuweiPalace": "乾"}, "description": "乾宅坐山法"},
    {"input": {"sittingMountain": "坎", "mode": "sittingMountain"}, "expected": {"mansionType": "坎宅", "fuweiPalace": "坎"}, "description": "坎宅坐山法"},
    {"input": {"sittingMountain": "兑", "mode": "sittingMountain"}, "expected": {"mansionType": "兑宅"}, "description": "兑宅坐山法"}
  ]
}
');
INSERT INTO rules_document ("file_name", "payload_json") VALUES ('rules/fan_gua/fan_gua.json', '{
  "$schema": "../../schema/layer-b-rule-config.schema.json",
  "configType": "rule",
  "layer": "B",
  "ruleId": "fan-gua-water-v1",
  "name": "辅星翻卦水法",
  "version": "1.0.0",
  "source": "黄石公辅星水法·地母卦",
  "authorType": "built-in",
  "category": "yinzai",
  "description": "根据二十四山立向输出纳甲映射、翻卦步骤、九星方位分布",
  "parameters": [
    {"name": "facingMountain", "type": "Mountain24", "required": true, "description": "立向（向上纳甲）"}
  ],
  "dataRefs": ["bearing-24-mountains-v1", "bagua-najia-v1", "fan-gua-sequence-v1"],
  "pipeline": [
    {"step": 1, "name": "向上纳甲取本卦", "action": "lookup", "description": "取向上纳甲之卦为本宫辅弼起点", "input": {"facingMountain": "{{parameters.facingMountain}}"}, "ref": "bagua-najia-v1.system2_fengShuiJingYinJingYang", "output": "baseTrigram"},
    {"step": 2, "name": "逐爻变卦推演", "action": "compute", "description": "按中下中上下中顺序7次变爻", "input": {"baseTrigram": "{{baseTrigram}}"}, "ref": "fan-gua-sequence-v1", "output": "starPositions"},
    {"step": 3, "name": "九星八宫分布", "action": "compose", "description": "将九星分配到对应八卦宫位", "input": {"starPositions": "{{starPositions}}"}, "output": "result"}
  ],
  "outputs": {
    "baseTrigram": {"type": "string"},
    "steps": {"type": "array", "items": {"fromTrigram": "string", "toTrigram": "string", "variantYao": "string", "starName": "string", "luck": "吉|凶"}},
    "palaceStars": {"type": "object", "description": "八卦宫->九星名+吉凶映射"}
  },
  "testFixtures": [
    {"input": {"facingMountain": "乾"}, "expected": {"baseTrigram": "乾"}, "description": "乾甲向→本卦乾→辅弼"}
  ]
}
');
INSERT INTO rules_document ("file_name", "payload_json") VALUES ('rules/fenjin/fenjin_kongwang.json', '{
  "$schema": "../../schema/layer-b-rule-config.schema.json",
  "configType": "rule",
  "layer": "B",
  "ruleId": "fenjin-kongwang-v1",
  "name": "120分金·空亡判定",
  "version": "1.0.0",
  "source": "《罗经透解》",
  "authorType": "built-in",
  "category": "yinzai",
  "description": "根据坐向度数输出二十四山归属、分金干支序号、空亡类型判定",
  "parameters": [
    {"name": "bearingDegree", "type": "Degree", "required": true, "description": "地盘坐向角度（0-359.999...°）"}
  ],
  "dataRefs": ["bearing-24-mountains-v1", "fenjin-120-v1", "kongwang-lines-v1"],
  "pipeline": [
    {"step": 1, "name": "二十四山归属", "action": "lookup", "description": "根据度数查表确定所属二十四山", "input": {"degree": "{{parameters.bearingDegree}}"}, "ref": "bearing-24-mountains-v1", "output": "mountainInfo"},
    {"step": 2, "name": "分金序号与干支", "action": "compute", "description": "在山内5等份中确定分金序号和干支", "input": {"degree": "{{parameters.bearingDegree}}", "mountainInfo": "{{mountainInfo}}"}, "ref": "fenjin-120-v1", "output": "fenjinInfo"},
    {"step": 3, "name": "空亡判定", "action": "condition", "description": "按大空亡→小空亡→龟甲→孤虚优先级逐级判定", "input": {"degree": "{{parameters.bearingDegree}}", "mountainInfo": "{{mountainInfo}}", "fenjinInfo": "{{fenjinInfo}}"}, "ref": "kongwang-lines-v1", "output": "kongwangType"},
    {"step": 4, "name": "可用性判定", "action": "classify", "description": "综合空亡和孤虚判定分金是否可用", "input": {"fenjinInfo": "{{fenjinInfo}}", "kongwangType": "{{kongwangType}}"}, "output": "usability"}
  ],
  "outputs": {
    "mountainName": {"type": "string"},
    "fenjinIndex": {"type": "integer", "description": "1-5"},
    "fenjinGanZhi": {"type": "string"},
    "kongwangType": {"type": "string", "enum": ["无", "小空亡", "大空亡", "龟甲空亡", "孤虚"]},
    "usable": {"type": "boolean"},
    "recommendation": {"type": "string"}
  },
  "testFixtures": [
    {"input": {"bearingDegree": 0.0}, "expected": {"kongwangType": "龟甲空亡", "usable": false}, "description": "子山中线=戊子龟甲"},
    {"input": {"bearingDegree": 3.0}, "expected": {"fenjinGanZhi": "庚子", "usable": true}, "description": "子山第4格=庚子旺相"},
    {"input": {"bearingDegree": 7.5}, "expected": {"kongwangType": "小空亡"}, "description": "子癸交界小空亡"},
    {"input": {"bearingDegree": 45.0}, "expected": {"kongwangType": "大空亡", "usable": false}, "description": "艮山中线大空亡"}
  ]
}
');
INSERT INTO rules_document ("file_name", "payload_json") VALUES ('rules/san_he/three_pan.json', '{
  "$schema": "../../schema/layer-b-rule-config.schema.json",
  "configType": "rule",
  "layer": "B",
  "ruleId": "san-he-three-pan-v1",
  "name": "杨公三合·三盘消砂纳水",
  "version": "1.0.0",
  "source": "杨公三合风水·阴宅版",
  "authorType": "built-in",
  "category": "yinzai",
  "description": "根据坐山、水口和砂峰输出四大局判定、十二长生排布、三盘消砂纳水",
  "parameters": [
    {"name": "sittingMountain", "type": "Mountain24", "required": true, "description": "地盘坐山"},
    {"name": "waterMouth", "type": "Mountain24", "required": true, "description": "天盘水口方位"},
    {"name": "sandPeaks", "type": "array", "required": false, "description": "砂峰数组[{方位, 五行}]"},
    {"name": "mode", "type": "enum:yinZhai|yangZhaiPingYang", "required": false, "default": "yinZhai", "description": "阴宅古法/阳宅平洋"},
    {"name": "unifiedForward", "type": "boolean", "required": false, "default": false, "description": "阳宅平洋统一顺排开关"}
  ],
  "dataRefs": ["bearing-24-mountains-v1", "double-mountains-v1", "four-bureaus-v1", "three-pans-v1"],
  "pipeline": [
    {"step": 1, "name": "天盘纳水定局", "action": "lookup", "description": "将水口转为天盘角度，查四大局归属", "input": {"waterMouth": "{{parameters.waterMouth}}"}, "ref": "four-bureaus-v1", "output": "bureau"},
    {"step": 2, "name": "排十二长生", "action": "compute", "description": "从本局长生起点按顺逆行排十二宫", "input": {"bureau": "{{bureau}}", "mode": "{{parameters.mode}}", "unifiedForward": "{{parameters.unifiedForward}}"}, "ref": "four-bureaus-v1", "output": "twelveGrowth"},
    {"step": 3, "name": "纳水判定", "action": "condition", "description": "来水生旺、去水墓绝为吉", "input": {"twelveGrowth": "{{twelveGrowth}}"}, "ref": "four-bureaus-v1.waterAssessment", "output": "waterJudgment"},
    {"step": 4, "name": "人盘消砂", "action": "compute", "description": "砂峰转人盘角度，论生克", "input": {"sandPeaks": "{{parameters.sandPeaks}}", "sittingMountain": "{{parameters.sittingMountain}}"}, "ref": "three-pans-v1", "output": "sandJudgment"}
  ],
  "outputs": {
    "bureau": {"type": "string", "enum": ["水局", "火局", "金局", "木局"]},
    "twelveGrowthPalaces": {"type": "object"},
    "waterJudgment": {"type": "string"},
    "sandJudgment": {"type": "array"}
  },
  "testFixtures": [
    {"input": {"sittingMountain": "子", "waterMouth": "乙辰", "mode": "yinZhai"}, "expected": {"bureau": "水局"}, "description": "水口乙辰=水局"}
  ]
}
');
INSERT INTO rules_document ("file_name", "payload_json") VALUES ('rules/xingsha/detection.json', '{
  "$schema": "../../schema/layer-b-rule-config.schema.json",
  "configType": "rule",
  "layer": "B",
  "ruleId": "xingsha-detection-v1",
  "name": "形煞几何检测",
  "version": "1.0.0",
  "source": "传统堪舆形煞理论",
  "authorType": "built-in",
  "category": "yinzai",
  "description": "从地图几何数据检测五类形煞，输出几何候选+置信度。吉凶解释由独立RuleSet完成",
  "parameters": [
    {"name": "centerPoint", "type": "Coordinate2D", "required": true, "description": "太极点坐标"},
    {"name": "buildingAxis", "type": "Degree", "required": true, "description": "建筑中轴线角度"},
    {"name": "waterGeometries", "type": "array", "required": false, "description": "水路几何数据（线/面）"},
    {"name": "buildingGeometries", "type": "array", "required": false, "description": "周边建筑/山体几何数据"}
  ],
  "dataRefs": ["xingsha-geometry-v1"],
  "pipeline": [
    {"step": 1, "name": "建立极坐标系", "action": "compute", "description": "以太极点为原点，建筑中轴线为0°建立极坐标", "input": {"center": "{{parameters.centerPoint}}", "axis": "{{parameters.buildingAxis}}"}, "output": "polarSystem"},
    {"step": 2, "name": "逐煞检测", "action": "compute", "description": "对每个形煞类型套用几何条件判定", "input": {"polarSystem": "{{polarSystem}}", "geometries": "{{parameters}}"}, "ref": "xingsha-geometry-v1", "output": "candidates"},
    {"step": 3, "name": "置信度评估", "action": "classify", "description": "按几何条件匹配度计算置信度", "input": {"candidates": "{{candidates}}"}, "output": "scoredCandidates"}
  ],
  "outputs": {
    "candidates": {
      "type": "array",
      "items": {
        "xingshaType": {"type": "string"},
        "confidence": {"type": "number", "minimum": 0, "maximum": 1},
        "evidence": {"type": "object", "description": "几何证据"},
        "status": {"type": "string", "enum": ["candidate_unconfirmed", "user_confirmed", "rejected"]}
      }
    }
  },
  "note": "形煞只输出候选，吉凶解释由独立版本化RuleSet完成。人工确认后才进入正式解释。检测条件见xingsha-geometry-v1"
}
');
INSERT INTO rules_document ("file_name", "payload_json") VALUES ('rules/xuan_kong/feixing.json', '{
  "$schema": "../../schema/layer-b-rule-config.schema.json",
  "configType": "rule",
  "layer": "B",
  "ruleId": "xuan-kong-feixing-v1",
  "name": "沈氏玄空飞星基础盘",
  "version": "1.0.0",
  "source": "《沈氏玄空学》",
  "authorType": "built-in",
  "category": "common",
  "description": "排运盘→山盘→向盘→断局。与阴宅大玄空父母星体系互不通用",
  "note": "沈氏玄空（阳宅主流）≠大玄空（阴宅父母星体系）。本配置为沈氏玄空，用于阳宅和阴宅玄空的基础盘",
  "parameters": [
    {"name": "currentYun", "type": "integer", "required": true, "description": "当前元运编号（1-9），可通过sanyuan-nine-yun-v1从年份推算"},
    {"name": "sittingMountain", "type": "Mountain24", "required": true, "description": "坐山"},
    {"name": "facingMountain", "type": "Mountain24", "required": true, "description": "向首（坐山的对宫）"}
  ],
  "dataRefs": ["bearing-24-mountains-v1", "feixing-sanyuan-dragon-v1", "bagua-nine-palace-v1"],
  "pipeline": [
    {
      "step": 1, "name": "排运盘", "action": "compute",
      "description": "当运星入中宫，永久顺飞九宫",
      "input": {"currentYun": "{{parameters.currentYun}}"},
      "flyTrack": "中→乾→兑→艮→离→坎→坤→震→巽",
      "flyDirection": "顺飞",
      "output": "yunPan"
    },
    {
      "step": 2, "name": "取山星原点", "action": "lookup",
      "description": "在运盘中读取坐山方位之星作为山星原点",
      "input": {"yunPan": "{{yunPan}}", "sittingMountain": "{{parameters.sittingMountain}}"},
      "ref": "bearing-24-mountains-v1",
      "output": "mountainStarOrigin"
    },
    {
      "step": 3, "name": "取向星原点", "action": "lookup",
      "description": "在运盘中读取向首方位之星作为向星原点",
      "input": {"yunPan": "{{yunPan}}", "facingMountain": "{{parameters.facingMountain}}"},
      "ref": "bearing-24-mountains-v1",
      "output": "facingStarOrigin"
    },
    {
      "step": 4, "name": "判定山星顺逆", "action": "classify",
      "description": "根据坐山所属三元龙阴阳判定顺飞/逆飞",
      "input": {"mountain": "{{parameters.sittingMountain}}"},
      "ref": "feixing-sanyuan-dragon-v1",
      "output": "mountainFlyDirection"
    },
    {
      "step": 5, "name": "排山盘", "action": "compute",
      "description": "山星原点入中宫，按三元龙阴阳飞布",
      "input": {"starOrigin": "{{mountainStarOrigin}}", "flyDirection": "{{mountainFlyDirection}}"},
      "flyTrack": "中→乾→兑→艮→离→坎→坤→震→巽",
      "output": "shanPan"
    },
    {
      "step": 6, "name": "判定向星顺逆", "action": "classify",
      "description": "根据向首所属三元龙阴阳判定顺飞/逆飞",
      "input": {"mountain": "{{parameters.facingMountain}}"},
      "ref": "feixing-sanyuan-dragon-v1",
      "output": "facingFlyDirection"
    },
    {
      "step": 7, "name": "排向盘", "action": "compute",
      "description": "向星原点入中宫，按三元龙阴阳飞布",
      "input": {"starOrigin": "{{facingStarOrigin}}", "flyDirection": "{{facingFlyDirection}}"},
      "flyTrack": "中→乾→兑→艮→离→坎→坤→震→巽",
      "output": "xiangPan"
    },
    {
      "step": 8, "name": "断局", "action": "condition",
      "description": "山上龙神不下水，水里龙神不上山。判定旺山旺向/双星到坐/双星到向/上山下水",
      "input": {"yunPan": "{{yunPan}}", "shanPan": "{{shanPan}}", "xiangPan": "{{xiangPan}}", "sittingPalace": "{{sittingPalace}}", "facingPalace": "{{facingPalace}}"},
      "conditions": {
        "type": "and",
        "conditions": [
          {
            "when": "currentStar.mountainPalace == sittingPalace AND currentStar.facingPalace == facingPalace",
            "then": "旺山旺向·最吉"
          },
          {
            "when": "currentStar.mountainPalace == sittingPalace AND currentStar.facingPalace == sittingPalace",
            "then": "双星到坐·旺丁不旺财"
          },
          {
            "when": "currentStar.mountainPalace == facingPalace AND currentStar.facingPalace == facingPalace",
            "then": "双星到向·旺财不旺丁"
          },
          {
            "when": "currentStar.mountainPalace == facingPalace AND currentStar.facingPalace == sittingPalace",
            "then": "上山下水·大凶"
          }
        ]
      },
      "output": "judgment"
    }
  ],
  "outputs": {
    "yunPan": {"type": "object", "description": "运盘九宫->星数映射"},
    "shanPan": {"type": "object", "description": "山盘九宫->星数映射"},
    "xiangPan": {"type": "object", "description": "向盘九宫->星数映射"},
    "judgment": {"type": "string", "description": "断局结论"}
  },
  "testFixtures": [
    {"input": {"currentYun": 9, "sittingMountain": "壬", "facingMountain": "丙"}, "expected": {"说明": "九运壬山丙向样例——具体期望值需专家验证后填入"}, "description": "九运壬山丙向基础排盘"}
  ]
}
');
