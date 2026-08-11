CREATE TABLE IF NOT EXISTS zhou_tian_document (  file_name TEXT PRIMARY KEY,  payload_json TEXT NOT NULL);
DELETE FROM zhou_tian_document;
INSERT INTO zhou_tian_document ("file_name", "payload_json") VALUES ('ecliptic_tropical_classical.json', '{
      "systemType": "黄道制",
      "constellationSystemType": "古宿制",
      "panelSystemType": "回归制",
      "epochCorrection": "开禧历",
      "totalDegree": 360.00,
      "gongOrder":[
        "戌","酉","申","未","午","巳","辰","卯","寅","丑","子","亥"
      ],
      "starInnOrder":[
        "奎","娄","胃","昴","毕","觜","参","井","鬼","柳","星","张","翼","轸","角","亢","氐","房","心","尾","箕","斗","牛","女","虚","危","室","壁"
      ],
      "gongDegreeSeq": [
        {"gong":"亥","degree": 30.0},
        {"gong":"戌","degree": 30.0},
        {"gong":"酉","degree": 30.0},
        {"gong":"申","degree": 30.0},
        {"gong":"未","degree": 30.0},
        {"gong":"午","degree": 30.0},
        {"gong":"巳","degree": 30.0},
        {"gong":"辰","degree": 30.0},
        {"gong":"卯","degree": 30.0},
        {"gong":"寅","degree": 30.0},
        {"gong":"丑","degree": 30.0},
        {"gong":"子","degree": 30.0}
      ],
    "starInnDegreeSeq": [
      {"constellation":"危","degree": 15.3}, 
      {"constellation":"室","degree": 15.8},
      {"constellation":"壁","degree": 8.9},
      {"constellation":"奎","degree": 17.6},
      {"constellation":"娄","degree": 10.4},
      {"constellation":"胃","degree": 14.8},
      {"constellation":"昴","degree": 12.1},
      {"constellation":"毕","degree": 15.8},
      {"constellation":"觜","degree": 1},
      {"constellation":"参","degree": 11.8},
      {"constellation":"井","degree": 30.5},
      {"constellation":"鬼","degree": 2.9},
      {"constellation":"柳","degree": 15.3},
      {"constellation":"星","degree": 5.9},
      {"constellation":"张","degree": 15.0},
      {"constellation":"翼","degree": 18.7},
      {"constellation":"轸","degree": 17.1},
      {"constellation":"角","degree": 12.8},
      {"constellation":"亢","degree": 8.9},
      {"constellation":"氐","degree": 16.3},
      {"constellation":"房","degree": 5.4},
      {"constellation":"心","degree": 6.4},
      {"constellation":"尾","degree": 18.6},
      {"constellation":"箕","degree": 10.7},
      {"constellation":"斗","degree": 23.8},
      {"constellation":"牛","degree": 7.9},
      {"constellation":"女","degree": 10.9},
      {"constellation":"虚","degree": 9.4}
    ],
    "alignmentPointAtConstellation": {"constellation":"奎","degree": 1.7},
    "alignmentPointAtGong": {
      "gong": "戌",
      "degree": 0.0
    },
      "zeroPointJieQi": "春分",
      "zeroPointAtConstellation": {"constellation":"奎","degree": 1.7},
      "zeroPointAtGong": {"gong": "戌", "degree": 0.0},
      
      "celestialLongitude": 0.0,
      "rightAscension": 0.0,
      "zeroPointOffsetToNow": 14.0,
      "specificationList":[
        "来自moira, 奎宿1.7° 戌白羊0° 春分点, 黄经0°，岁差为14.09°，古宿制未进行岁差校准"
      ]
  }');
INSERT INTO zhou_tian_document ("file_name", "payload_json") VALUES ('ecliptic_tropical_classical_adjusted.json', '{
      "systemType": "黄道制",
      "constellationSystemType": "矫正古宿制",
      "panelSystemType": "回归制",
      "epochCorrection": "开禧历",
      "totalDegree": 360.00,
      "gongOrder":[
        "戌","酉","申","未","午","巳","辰","卯","寅","丑","子","亥"
      ],
      "gongDegreeSeq": [
        {"gong":"亥","degree": 30.0},
        {"gong":"戌","degree": 30.0},
        {"gong":"酉","degree": 30.0},
        {"gong":"申","degree": 30.0},
        {"gong":"未","degree": 30.0},
        {"gong":"午","degree": 30.0},
        {"gong":"巳","degree": 30.0},
        {"gong":"辰","degree": 30.0},
        {"gong":"卯","degree": 30.0},
        {"gong":"寅","degree": 30.0},
        {"gong":"丑","degree": 30.0},
        {"gong":"子","degree": 30.0}
      ],
      "starInnOrder":[
        "室","壁","奎","娄","胃","昴","毕","觜","参","井","鬼","柳","星","张","翼","轸","角","亢","氐","房","心","尾","箕","斗","牛","女","虚","危"
      ],

    "starInnDegreeSeq": [
      {"constellation":"危","degree": 15.3}, 
      {"constellation":"室","degree": 15.8},
      {"constellation":"壁","degree": 8.9},
      {"constellation":"奎","degree": 17.6},
      {"constellation":"娄","degree": 10.4},
      {"constellation":"胃","degree": 14.8},
      {"constellation":"昴","degree": 12.1},
      {"constellation":"毕","degree": 15.8},
      {"constellation":"觜","degree": 1},
      {"constellation":"参","degree": 11.8},
      {"constellation":"井","degree": 30.5},
      {"constellation":"鬼","degree": 2.9},
      {"constellation":"柳","degree": 15.3},
      {"constellation":"星","degree": 5.9},
      {"constellation":"张","degree": 15.0},
      {"constellation":"翼","degree": 18.7},
      {"constellation":"轸","degree": 17.1},
      {"constellation":"角","degree": 12.8},
      {"constellation":"亢","degree": 8.9},
      {"constellation":"氐","degree": 16.3},
      {"constellation":"房","degree": 5.4},
      {"constellation":"心","degree": 6.4},
      {"constellation":"尾","degree": 18.6},
      {"constellation":"箕","degree": 10.7},
      {"constellation":"斗","degree": 23.8},
      {"constellation":"牛","degree": 7.9},
      {"constellation":"女","degree": 10.9},
      {"constellation":"虚","degree": 9.4}
    ],
    "alignmentPointAtConstellation": {"constellation":"室","degree": 12.7},
    "alignmentPointAtGong": {
      "gong": "戌",
      "degree": 0
    },
      "zeroPointJieQi": "春分",
      "zeroPointAtConstellation": {"constellation":"室","degree": 12.7},
      "zeroPointAtGong": {"gong": "戌", "degree": 0.0},
      
      "celestialLongitude": 0.0,
      "rightAscension": 0.0,
      "zeroPointOffsetToNow": 14.0,
      "specificationList":[
        "来自moira, 奎宿1.7° 戌白羊0° 春分点, 黄经0°，岁差为14.09°，古宿制未进行岁差校准"
      ]
  }');
INSERT INTO zhou_tian_document ("file_name", "payload_json") VALUES ('ecliptic_tropical_morden.json', '{
      "systemType": "黄道制",
      "constellationSystemType": "今宿制",
      "panelSystemType": "回归制",
      "epochCorrection": "j2000",
      "totalDegree": 360.00,
      "gongOrder":[
        "戌","酉","申","未","午","巳","辰","卯","寅","丑","子","亥"
      ],
      "gongDegreeSeq": [
        {"gong":"亥","degree": 30.0},
        {"gong":"戌","degree": 30.0},
        {"gong":"酉","degree": 30.0},
        {"gong":"申","degree": 30.0},
        {"gong":"未","degree": 30.0},
        {"gong":"午","degree": 30.0},
        {"gong":"巳","degree": 30.0},
        {"gong":"辰","degree": 30.0},
        {"gong":"卯","degree": 30.0},
        {"gong":"寅","degree": 30.0},
        {"gong":"丑","degree": 30.0},
        {"gong":"子","degree": 30.0}
      ],
      "starInnOrder":[
        "室","壁","奎","娄","胃","昴","毕","觜","参","井","鬼","柳","星","张","翼","轸","角","亢","氐","房","心","尾","箕","斗","牛","女","虚","危"
      ],
    "starInnDegreeSeq": [
      {"constellation":"危","degree":20.07},
      {"constellation":"室","degree":16.75},
      {"constellation":"壁","degree":12.22},
      {"constellation":"奎","degree":11.52},
      {"constellation":"娄","degree":12.97},
      {"constellation":"胃","degree":12.48},
      {"constellation":"昴","degree":9.05},
      {"constellation":"毕","degree":15.2},
      {"constellation":"觜","degree":1},
      {"constellation":"参","degree":10.62},
      {"constellation":"井","degree":30.45},
      {"constellation":"鬼","degree":4.99},
      {"constellation":"柳","degree":15.98},
      {"constellation":"星","degree":7.99},
      {"constellation":"张","degree":19.07},
      {"constellation":"翼","degree":16.93},
      {"constellation":"轸","degree":12.81},
      {"constellation":"角","degree":10.99},
      {"constellation":"亢","degree":10.59},
      {"constellation":"氐","degree":17.85},
      {"constellation":"房","degree":4.85},
      {"constellation":"心","degree":8.25},
      {"constellation":"尾","degree":15.20},
      {"constellation":"箕","degree":8.94},
      {"constellation":"斗","degree":23.92},
      {"constellation":"牛","degree":7.67},
      {"constellation":"女","degree":11.67},
      {"constellation":"虚","degree":9.97}
    ],
    "alignmentPointAtConstellation": {"constellation":"室","degree": 6.55},
    "alignmentPointAtGong": {
      "gong": "戌",
      "degree": 0.0
    },
      "zeroPointJieQi": "春分",
      "zeroPointAtConstellation": {"constellation":"室","degree": 6.55},
      "zeroPointAtGong": {"gong": "戌", "degree": 0.0},
      "celestialLongitude": 0.0,
      "rightAscension": 0.0,
      "zeroPointOffsetToNow": 0.0,
      "specificationList":[
        "来自moira, 室宿12.7° 戌白羊0° 春分点, 黄经0°，岁差为0°已矫正"
      ]
  }');
