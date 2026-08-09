BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS ephemeris_document (  file_name TEXT PRIMARY KEY,  payload_json TEXT NOT NULL);
INSERT INTO ephemeris_document ("file_name", "payload_json") VALUES ('ecliptic_ancient_365.json', '{
  "systemType": "ecliptic_tropical",
  "constellationSystemType": "ancient",
  "panelSystemType": "tropical",
  "epochCorrection": 0.0,
  "totalDegree": 365.25,
  "gongOrder": ["zi", "chou", "yin", "mao", "chen", "si", "wu", "wei", "shen", "you", "xu", "hai"],
  "starInnOrder": ["jiao", "kang", "di", "fang", "xin", "wei", "ji", "dou", "niu", "nu", "xu", "wei_low", "shi", "bi", "kui", "lou", "wei_st", "mao_st", "bi_st", "zi_st", "can", "jing", "gui", "liu", "xing", "zhang", "yi", "zhen"],
  "gongDegreeSeq": [],
  "starInnDegreeSeq": [],
  "zeroPointAtGong": {"gong": "zi", "degree": 0.0},
  "zeroPointAtConstellation": {"constellation": "dou", "degree": 0.0},
  "alignmentPointAtGong": {"gong": "zi", "degree": 0.0},
  "alignmentPointAtConstellation": {"constellation": "dou", "degree": 0.0},
  "specificationList": ["Ancient 365.25 system"],
  "projectionConfig": {
    "strategy": "linear",
    "offset": 0.0
  }
}
');
INSERT INTO ephemeris_document ("file_name", "payload_json") VALUES ('ecliptic_tuihuangdao.json', '{
  "systemType": "擬黄道术",
  "constellationSystemType": "ancient_adjusted",
  "panelSystemType": "tropical",
  "epochCorrection": 0.0,
  "totalDegree": 365.2575,
  "gongOrder": ["zi", "chou", "yin", "mao", "chen", "si", "wu", "wei", "shen", "you", "xu", "hai"],
  "starInnOrder": ["jiao", "kang", "di", "fang", "xin", "wei", "ji", "dou", "niu", "nu", "xu", "wei_low", "shi", "bi", "kui", "lou", "wei_st", "mao_st", "bi_st", "zi_st", "can", "jing", "gui", "liu", "xing", "zhang", "yi", "zhen"],
  "gongDegreeSeq": [],
  "starInnDegreeSeq": [],
  "zeroPointAtGong": {"gong": "zi", "degree": 0.0},
  "zeroPointAtConstellation": {"constellation": "dou", "degree": 0.0},
  "alignmentPointAtGong": {"gong": "zi", "degree": 0.0},
  "alignmentPointAtConstellation": {"constellation": "dou", "degree": 0.0},
  "specificationList": ["Ming dynasty Tui Huang Dao Shu"],
  "projectionConfig": {
    "strategy": "piecewise",
    "sourcePoints": [0.0, 90.0, 180.0, 270.0, 360.0],
    "targetPoints": [0.0, 91.314, 182.628, 273.942, 365.2575]
  }
}
');
INSERT INTO ephemeris_document ("file_name", "payload_json") VALUES ('four_season.json', '[
    {
      "star": "木星",
      "fourSeasonRelationshipMapper": {
        "春": {
          "喜": [
            {"star": "火星", "reason": ["木生火发荣", "春木向阳早达"]},
            {"star": "金星", "reason": ["金琢木成器", "春末修枝促长"]}
          ],
          "忌": [
            {"star": "月孛", "reason": ["水寒伤木根", "阴湿滞生机"]}
          ],
          "调候": [
            {"star": "太阳", "reason": ["昼阳融寒助长", "寒木向阳富贵"]}
          ]
        },
        "夏": {
          "喜": [
            {"star": "水星", "reason": ["水润夏木荣", "清华显智"]}
          ],
          "忌": [
            {"star": "土星", "reason": ["土燥根枯", "火炎土裂"]},
            {"star": "火星", "reason": ["盛火焚木", "自毁根基"]}
          ],
          "调候": [
            {"star": "月孛", "reason": ["夜露润燥", "水火既济"]}
          ]
        },
        "秋": {
          "喜": [
            {"star": "火星", "reason": ["火煅金护木", "秋木存根"]}
          ],
          "忌": [
            {"star": "金星", "reason": ["金锐伐木", "凋零之祸"]}
          ],
          "调候": [
            {"star": "太阳", "reason": ["日照存气", "寒而不枯"]}
          ]
        },
        "冬": {
          "喜": [
            {"star": "太阳", "reason": ["昼阳化冻", "寒木回春"]},
            {"star": "火星", "reason": ["夜火温局", "根暖自生"]}
          ],
          "忌": [
            {"star": "月孛", "reason": ["寒凝成冰", "生机断绝"]}
          ],
          "调候": [
            {"star": "土星", "reason": ["土固水护根", "寒木得培"]}
          ]
        }
      }
    },
    {
      "star": "火星",
      "fourSeasonRelationshipMapper": {
        "春": {
          "喜": [
            {"star": "木星", "reason": ["木生火明", "初春祛寒"]}
          ],
          "忌": [
            {"star": "水星", "reason": ["水克初火", "生机受抑"]}
          ],
          "调候": [
            {"star": "太阳", "reason": ["阳火助势", "寒春化暖"]}
          ]
        },
        "夏": {
          "喜": [
            {"star": "水星", "reason": ["水火既济", "消暑解炎"]}
          ],
          "忌": [
            {"star": "木星", "reason": ["木助火焚", "自毁根基"]},
            {"star": "土星", "reason": ["土晦火明", "光热受阻"]}
          ],
          "调候": [
            {"star": "月孛", "reason": ["夜露降燥", "温润调和"]}
          ]
        },
        "秋": {
          "喜": [
            {"star": "金星", "reason": ["火炼秋金", "成器之兆"]}
          ],
          "忌": [
            {"star": "水星", "reason": ["水灭火光", "贵气消散"]}
          ],
          "调候": [
            {"star": "土星", "reason": ["土蓄火温", "秋夜驱寒"]}
          ]
        },
        "冬": {
          "喜": [
            {"star": "木星", "reason": ["木生火暖", "寒夜生辉"]}
          ],
          "忌": [
            {"star": "水星", "reason": ["水冻火熄", "生机断绝"]}
          ],
          "调候": [
            {"star": "太阳", "reason": ["昼借日光", "补火不足"]}
          ]
        }
      }
    },
    {
      "star": "土星",
      "fourSeasonRelationshipMapper": {
        "春": {
          "喜": [
            {"star": "火星", "reason": ["火暖寒土", "生机萌发"]}
          ],
          "忌": [
            {"star": "木星", "reason": ["木克湿土", "根气不固"]},
            {"star": "水星", "reason": ["水泛土流", "堤防溃败"]}
          ],
          "调候": [
            {"star": "太阳", "reason": ["阳和培土", "寒湿得解"]}
          ]
        },
        "夏": {
          "喜": [
            {"star": "水星", "reason": ["水润燥土", "万物长养"]}
          ],
          "忌": [
            {"star": "火星", "reason": ["火炎土焦", "寸草不生"]}
          ],
          "调候": [
            {"star": "月孛", "reason": ["夜露降暑", "阴阳调和"]}
          ]
        },
        "秋": {
          "喜": [
            {"star": "金星", "reason": ["土生金秀", "秋实丰收"]}
          ],
          "忌": [
            {"star": "木星", "reason": ["木克秋土", "仓廪不实"]}
          ],
          "调候": [
            {"star": "火星", "reason": ["火煅湿土", "固本培元"]}
          ]
        },
        "冬": {
          "喜": [
            {"star": "火星", "reason": ["火暖冻土", "寒地藏金"]}
          ],
          "忌": [
            {"star": "水星", "reason": ["水冻土僵", "生机闭藏"]}
          ],
          "调候": [
            {"star": "太阳", "reason": ["昼阳融冻", "地气回升"]}
          ]
        }
      }
    },
        {
          "star": "太阳",
          "fourSeasonRelationshipMapper": {
            "春": {
              "喜": [
                {"star": "金星", "reason": ["金生水济阳", "金水辅阳解春寒"]},
                {"star": "水星", "reason": ["水火既济调候", "春阳需水润燥"]}
              ],
              "忌": [
                {"star": "木星", "reason": ["木气克阳", "遮阳损君威"]},
                {"star": "紫气", "reason": ["祥云蔽日", "阴晦损光明"]}
              ],
              "调候": [
                {"star": "火星", "reason": ["火罗温局", "祛除残冬寒气"]}
              ]
            },
            "夏": {
              "喜": [
                {"star": "水星", "reason": ["水济夏炎", "晴霁兼行主名利"]},
                {"star": "月孛", "reason": ["夜露降暑", "调和酷热"]}
              ],
              "忌": [
                {"star": "火星", "reason": ["火炎土燥", "暴烈伤万物"]},
                {"star": "罗睺", "reason": ["争明损辉", "天变致灾"]}
              ],
              "调候": [
                {"star": "土星", "reason": ["土蓄火温", "固本防旱"]}
              ]
            },
            "秋": {
              "喜": [
                {"star": "金星", "reason": ["金白水清", "秋高气爽显贵格"]},
                {"star": "水星", "reason": ["水火调和", "燥气得润"]}
              ],
              "忌": [
                {"star": "土星", "reason": ["土晦日光", "秋虎成灾"]},
                {"star": "计都", "reason": ["蚀神犯日", "朝纲紊乱"]}
              ],
              "调候": [
                {"star": "木星", "reason": ["木疏土气", "保秋阳清明"]}
              ]
            },
            "冬": {
              "喜": [
                {"star": "火星", "reason": ["火暖寒冬", "寒谷回春化贫贱"]},
                {"star": "罗睺", "reason": ["火余助阳", "夜火补日衰"]}
              ],
              "忌": [
                {"star": "水星", "reason": ["水冻阳凝", "生机闭藏"]},
                {"star": "月孛", "reason": ["寒凝成冰", "损阳寿"]}
              ],
              "调候": [
                {"star": "土星", "reason": ["土固水护", "培元御寒"]}
              ]
            }
          }
        },
        {
          "star": "月亮",
          "fourSeasonRelationshipMapper": {
            "春": {
              "喜": [
                {"star": "太阳", "reason": ["阳火解寒", "月借日辉"]},
                {"star": "火星", "reason": ["火暖月华", "夜生得暖"]}
              ],
              "忌": [
                {"star": "土星", "reason": ["土晦月光", "母仪受损"]},
                {"star": "计都", "reason": ["蚀神犯月", "阴晦招灾"]}
              ],
              "调候": [
                {"star": "木星", "reason": ["木疏土气", "保月华清明"]}
              ]
            },
            "夏": {
              "喜": [
                {"star": "金星", "reason": ["金水润局", "夏月生凉"]},
                {"star": "水星", "reason": ["水火既济", "夜露降燥"]}
              ],
              "忌": [
                {"star": "火星", "reason": ["火炎月枯", "暴烈损阴"]},
                {"star": "罗睺", "reason": ["争辉失柔", "妻宫不宁"]}
              ],
              "调候": [
                {"star": "月孛", "reason": ["孛润燥土", "阴阳调和"]}
              ]
            },
            "秋": {
              "喜": [
                {"star": "金星", "reason": ["金水相涵", "秋月最明"]},
                {"star": "紫气", "reason": ["祥云捧月", "贵气天成"]}
              ],
              "忌": [
                {"star": "土星", "reason": ["土混金埋", "月华蒙尘"]},
                {"star": "计都", "reason": ["蚀神夺魄", "母仪危殆"]}
              ],
              "调候": [
                {"star": "水星", "reason": ["水润秋燥", "保月魄清润"]}
              ]
            },
            "冬": {
              "喜": [
                {"star": "火星", "reason": ["火罗温局", "寒夜生辉"]},
                {"star": "太阳", "reason": ["昼借日光", "补月魄不足"]}
              ],
              "忌": [
                {"star": "水星", "reason": ["水冻月僵", "生机断绝"]},
                {"star": "月孛", "reason": ["寒凝成冰", "损阴寿"]}
              ],
              "调候": [
                {"star": "土星", "reason": ["土制水护", "固本培元"]}
              ]
            }
          }
        },
        {
          "star": "金星",
          "fourSeasonRelationshipMapper": {
            "春": {
              "喜": [
                {"star": "土星", "reason": ["土生金秀", "春金需煅"]},
                {"star": "水星", "reason": ["水润金明", "刚柔并济"]}
              ],
              "忌": [
                {"star": "火星", "reason": ["火销金镕", "刚折失威"]},
                {"star": "罗睺", "reason": ["火余克金", "肃杀过甚"]}
              ],
              "调候": [
                {"star": "太阳", "reason": ["阳和煅金", "寒金得暖"]}
              ]
            },
            "夏": {
              "喜": [
                {"star": "水星", "reason": ["水济夏燥", "刚金得润"]},
                {"star": "月孛", "reason": ["孛润火土", "固本防销"]}
              ],
              "忌": [
                {"star": "太阳", "reason": ["日烈金熔", "贵气消散"]},
                {"star": "木星", "reason": ["木耗金气", "刚柔失序"]}
              ],
              "调候": [
                {"star": "土星", "reason": ["土蓄金气", "防夏火过旺"]}
              ]
            },
            "秋": {
              "喜": [
                {"star": "水星", "reason": ["金白水清", "秋金成器"]},
                {"star": "土星", "reason": ["土生金实", "富厚丰常"]}
              ],
              "忌": [
                {"star": "火星", "reason": ["火煅过刚", "剑锋易折"]},
                {"star": "紫气", "reason": ["木余犯金", "肃杀受损"]}
              ],
              "调候": [
                {"star": "金星", "reason": ["同类相扶", "刚健中正"]}
              ]
            },
            "冬": {
              "喜": [
                {"star": "火星", "reason": ["火暖寒金", "冬金焕彩"]},
                {"star": "太阳", "reason": ["阳和温局", "寒谷藏金"]}
              ],
              "忌": [
                {"star": "水星", "reason": ["水沉金寒", "刚金失用"]},
                {"star": "月孛", "reason": ["寒凝滞气", "生机闭藏"]}
              ],
              "调候": [
                {"star": "土星", "reason": ["土培金根", "固本御寒"]}
              ]
            }
          }
        },
        {
            "star": "水星",
            "fourSeasonRelationshipMapper": {
              "春": {
                "喜": [
                  {
                    "star": "太阳",
                    "reason": ["日水同宫增威严", "昼生人格魅力显赫"]
                  },
                  {
                    "star": "火星",
                    "reason": ["火温春寒促智发", "水火既济主名利"]
                  }
                ],
                "忌": [
                  {
                    "star": "金星",
                    "reason": ["金寒水凝损生机", "夜生孤寒清高格"]
                  },
                  {
                    "star": "月孛",
                    "reason": ["水余增寒损智性", "春水泛溢主愚钝"]
                  }
                ],
                "调候": [
                  {
                    "star": "土星",
                    "reason": ["土止春水防泛滥", "培根固源利学业"]
                  }
                ]
              },
              "夏": {
                "喜": [
                  {
                    "star": "土星",
                    "reason": ["土镇夏水防洪灾", "逻辑缜密事业兴"]
                  },
                  {
                    "star": "木星",
                    "reason": ["木疏水气通才智", "文昌显赫主文名"]
                  }
                ],
                "忌": [
                  {
                    "star": "太阳",
                    "reason": ["日烈水枯损健康", "未月水弱忌阳灼"]
                  },
                  {
                    "star": "罗睺",
                    "reason": ["火余增燥焚水智", "言行失度招灾祸"]
                  }
                ],
                "调候": [
                  {
                    "star": "月孛",
                    "reason": ["孛润夏燥济水火", "阴阳调和利商贸"]
                  }
                ]
              },
              "秋": {
                "喜": [
                  {
                    "star": "火星",
                    "reason": ["火煅秋金生水智", "敏捷超群富贵格"]
                  },
                  {
                    "star": "金星",
                    "reason": ["金生水秀成器局", "秋高气爽显贵气"]
                  }
                ],
                "忌": [
                  {
                    "star": "土星",
                    "reason": ["土重埋金水滞涩", "思维僵化招困顿"]
                  },
                  {
                    "star": "计都",
                    "reason": ["土余晦光损智性", "术数失灵招口舌"]
                  }
                ],
                "调候": [
                  {
                    "star": "木星",
                    "reason": ["木疏土气通水源", "保秋水清润不浊"]
                  }
                ]
              },
              "冬": {
                "喜": [
                  {
                    "star": "太阳",
                    "reason": ["日融寒冰启智性", "寒水得暖主贵格"]
                  },
                  {
                    "star": "罗睺",
                    "reason": ["火余温局解冻凝", "智勇双全名利收"]
                  }
                ],
                "忌": [
                  {
                    "star": "金星",
                    "reason": ["金寒水冻滞生机", "多病孤冷招灾厄"]
                  },
                  {
                    "star": "月孛",
                    "reason": ["水余增寒成冰局", "商业阻滞破财帛"]
                  }
                ],
                "调候": [
                  {
                    "star": "土星",
                    "reason": ["土固水源防泛滥", "培元御寒护根基"]
                  }
                ]
              }
            }
          }
  ]');
INSERT INTO ephemeris_document ("file_name", "payload_json") VALUES ('han_chidao_hengxin.json', '{
      "systemType": "天赤道制",
      "starInnType": "古宿",
      "starInnSystem": "恒星制",
      "epochCorrection": "汉·太初历",
      "totalDegree": 365.25,
      "twelvGongDegreeMap": {
        "子": 30.44,
        "丑": 30.44,
        "寅": 30.44,
        "卯": 30.44,
        "辰": 30.44,
        "巳": 30.44,
        "午": 30.44,
        "未": 30.44,
        "申": 30.44,
        "酉": 30.44,
        "戌": 30.44,
        "亥": 30.44
    },
    "starInnDegreeMap": {
"角": 12.0, "亢": 9.0, "氐": 15.0, "房": 5.0, "心": 5.0,"尾":18.0,"箕": 11.0,
"斗": 26.25, "牛": 8.0, "女": 12.0, "虚": 10.0, "危": 17.0,"室":16.0,"壁": 9.0,
"奎": 16.0, "娄": 12.0, "胃": 14.0, "昴": 11.0, "毕": 16.0,"觜":2.0,"参": 9.0,
"井": 33.0, "鬼": 4.0, "柳": 15.0, "星": 7.0, "张": 18.0,"翼":18.0,"轸": 17.0
    },
    "alignmentPointAtStarInn": {
      "starInn": "牛宿",
      "degree": 0.0
    },
    "alignmentPointAtGong": {
      "gong": "丑",
      "degree": 15.0
    },
      "zeroPointJieQi": "冬至",
      "zeroPointAtStarInn": {"starInn": "牛宿", "degree": 0.0},
      "zeroPointAtGong": {"gong": "子宫", "degree": 15.0},
      "celestialLongitude": 270.0,
      "rightAscension": 240.5,
      "zeroPointOffsetToNow": 28.0

  }');
INSERT INTO ephemeris_document ("file_name", "payload_json") VALUES ('han_chidao_hengxin.v2.json', '{
  "systemType": "天赤道制",
  "constellationSystemType": "古宿制",
  "panelSystemType": "恒星制",
  "epochCorrection": "汉·太初历",
  "totalDegree": 365.25,
  "gongOrder": [
    "戌",
    "酉",
    "申",
    "未",
    "午",
    "巳",
    "辰",
    "卯",
    "寅",
    "丑",
    "子",
    "亥"
  ],
  "starInnOrder": [
    "角",
    "亢",
    "氐",
    "房",
    "心",
    "尾",
    "箕",
    "斗",
    "牛",
    "女",
    "虚",
    "危",
    "室",
    "壁",
    "奎",
    "娄",
    "胃",
    "昴",
    "毕",
    "觜",
    "参",
    "井",
    "鬼",
    "柳",
    "星",
    "张",
    "翼",
    "轸"
  ],
  "gongDegreeSeq": [
    { "gong": "子", "degree": 30.44 },
    { "gong": "丑", "degree": 30.44 },
    { "gong": "寅", "degree": 30.44 },
    { "gong": "卯", "degree": 30.44 },
    { "gong": "辰", "degree": 30.44 },
    { "gong": "巳", "degree": 30.44 },
    { "gong": "午", "degree": 30.44 },
    { "gong": "未", "degree": 30.44 },
    { "gong": "申", "degree": 30.44 },
    { "gong": "酉", "degree": 30.44 },
    { "gong": "戌", "degree": 30.44 },
    { "gong": "亥", "degree": 30.44 }
  ],
  "starInnDegreeSeq": [
    { "constellation": "角", "degree": 12.0 },
    { "constellation": "亢", "degree": 9.0 },
    { "constellation": "氐", "degree": 15.0 },
    { "constellation": "房", "degree": 5.0 },
    { "constellation": "心", "degree": 5.0 },
    { "constellation": "尾", "degree": 18.0 },
    { "constellation": "箕", "degree": 11.0 },
    { "constellation": "斗", "degree": 26.25 },
    { "constellation": "牛", "degree": 8.0 },
    { "constellation": "女", "degree": 12.0 },
    { "constellation": "虚", "degree": 10.0 },
    { "constellation": "危", "degree": 17.0 },
    { "constellation": "室", "degree": 16.0 },
    { "constellation": "壁", "degree": 9.0 },
    { "constellation": "奎", "degree": 16.0 },
    { "constellation": "娄", "degree": 12.0 },
    { "constellation": "胃", "degree": 14.0 },
    { "constellation": "昴", "degree": 11.0 },
    { "constellation": "毕", "degree": 16.0 },
    { "constellation": "觜", "degree": 2.0 },
    { "constellation": "参", "degree": 9.0 },
    { "constellation": "井", "degree": 33.0 },
    { "constellation": "鬼", "degree": 4.0 },
    { "constellation": "柳", "degree": 15.0 },
    { "constellation": "星", "degree": 7.0 },
    { "constellation": "张", "degree": 18.0 },
    { "constellation": "翼", "degree": 18.0 },
    { "constellation": "轸", "degree": 17.0 }
  ],
  "alignmentPointAtConstellation": {
    "constellation": "牛",
    "degree": 0.0
  },
  "alignmentPointAtGong": {
    "gong": "丑",
    "degree": 15.0
  },
  "zeroPointJieQi": "冬至",
  "zeroPointAtConstellation": {
    "constellation": "牛",
    "degree": 0.0
  },
  "zeroPointAtGong": {
    "gong": "子",
    "degree": 15.0
  },
  "celestialLongitude": 270.0,
  "zeroPointOffsetToNow": 28.0,
  "rightAscension": 240.5,
  "specificationList": [
    "汉太初天赤道恒星制，总度数 365.25 度"
  ]
}
');
INSERT INTO ephemeris_document ("file_name", "payload_json") VALUES ('yuan_chidao_hengxing.json', '{
      "systemType": "赤道制",
      "starInnType": "古宿",
      "starInnSystem": "恒星制",
      "epochCorrection": "元·授时历",
      "totalDegree": 365.25,
      "twelvGongDegreeMap": {
        "子": 30.438,
        "丑": 30.438,
        "寅": 30.438,
        "卯": 30.438,
        "辰": 30.438,
        "巳": 30.438,
        "午": 30.438,
        "未": 30.438,
        "申": 30.438,
        "酉": 30.438,
        "戌": 30.438,
        "亥": 30.438
    },
    "starInnDegreeMap": {
"角":12,
"亢":9,
"氐":15,
"房":5,
"心":5,
"尾":18,
"箕":11,

"斗":26.25,
"牛":8,
"女":12,
"虚":10,
"危":17,
"室":16,
"壁":9,

"奎":16,
"娄":12,
"胃":14,
"昴":11,
"毕":16,
"觜":2,
"参":9,

"井":33,
"鬼":4,
"柳":15,
"星":7,
"张":18,
"翼":18,
"轸":17
    },
    "alignmentPointAtStarInn": {
      "starInn": "女宿",
      "degree": 2.1
    },
    "alignmentPointAtGong": {
      "gong": "子",
      "degree": 0
    },
      "zeroPointJieQi": "冬至",
      "zeroPointAtStarInn": {"starInn": "虚宿", "degree": 6},
      "zeroPointAtGong": {"gong": "子宫", "degree": 15.0},
      "celestialLongitude": 270.0,
      "rightAscension": 240.5,
      "zeroPointOffsetToNow": 28.0
  }');
INSERT INTO ephemeris_document ("file_name", "payload_json") VALUES ('yuan_chidao_hengxing.v2.json', '{
  "systemType": "赤道制",
  "constellationSystemType": "古宿制",
  "panelSystemType": "恒星制",
  "epochCorrection": "元·授时历",
  "totalDegree": 365.25,
  "gongOrder": [
    "戌",
    "酉",
    "申",
    "未",
    "午",
    "巳",
    "辰",
    "卯",
    "寅",
    "丑",
    "子",
    "亥"
  ],
  "starInnOrder": [
    "角",
    "亢",
    "氐",
    "房",
    "心",
    "尾",
    "箕",
    "斗",
    "牛",
    "女",
    "虚",
    "危",
    "室",
    "壁",
    "奎",
    "娄",
    "胃",
    "昴",
    "毕",
    "觜",
    "参",
    "井",
    "鬼",
    "柳",
    "星",
    "张",
    "翼",
    "轸"
  ],
  "gongDegreeSeq": [
    { "gong": "子", "degree": 30.438 },
    { "gong": "丑", "degree": 30.438 },
    { "gong": "寅", "degree": 30.438 },
    { "gong": "卯", "degree": 30.438 },
    { "gong": "辰", "degree": 30.438 },
    { "gong": "巳", "degree": 30.438 },
    { "gong": "午", "degree": 30.438 },
    { "gong": "未", "degree": 30.438 },
    { "gong": "申", "degree": 30.438 },
    { "gong": "酉", "degree": 30.438 },
    { "gong": "戌", "degree": 30.438 },
    { "gong": "亥", "degree": 30.438 }
  ],
  "starInnDegreeSeq": [
    { "constellation": "角", "degree": 12.0 },
    { "constellation": "亢", "degree": 9.0 },
    { "constellation": "氐", "degree": 15.0 },
    { "constellation": "房", "degree": 5.0 },
    { "constellation": "心", "degree": 5.0 },
    { "constellation": "尾", "degree": 18.0 },
    { "constellation": "箕", "degree": 11.0 },
    { "constellation": "斗", "degree": 26.25 },
    { "constellation": "牛", "degree": 8.0 },
    { "constellation": "女", "degree": 12.0 },
    { "constellation": "虚", "degree": 10.0 },
    { "constellation": "危", "degree": 17.0 },
    { "constellation": "室", "degree": 16.0 },
    { "constellation": "壁", "degree": 9.0 },
    { "constellation": "奎", "degree": 16.0 },
    { "constellation": "娄", "degree": 12.0 },
    { "constellation": "胃", "degree": 14.0 },
    { "constellation": "昴", "degree": 11.0 },
    { "constellation": "毕", "degree": 16.0 },
    { "constellation": "觜", "degree": 2.0 },
    { "constellation": "参", "degree": 9.0 },
    { "constellation": "井", "degree": 33.0 },
    { "constellation": "鬼", "degree": 4.0 },
    { "constellation": "柳", "degree": 15.0 },
    { "constellation": "星", "degree": 7.0 },
    { "constellation": "张", "degree": 18.0 },
    { "constellation": "翼", "degree": 18.0 },
    { "constellation": "轸", "degree": 17.0 }
  ],
  "alignmentPointAtConstellation": {
    "constellation": "女",
    "degree": 2.1
  },
  "alignmentPointAtGong": {
    "gong": "子",
    "degree": 0
  },
  "zeroPointJieQi": "冬至",
  "zeroPointAtConstellation": {
    "constellation": "虚",
    "degree": 6.0
  },
  "zeroPointAtGong": {
    "gong": "子",
    "degree": 15.0
  },
  "celestialLongitude": 270.0,
  "zeroPointOffsetToNow": 28.0,
  "rightAscension": 240.5,
  "specificationList": [
    "元授时赤道恒星制，总度数 365.25 度"
  ]
}
');
INSERT INTO ephemeris_document ("file_name", "payload_json") VALUES ('yuan_shoushi_chidao_hengxin.json', '{
  "systemType": "天赤道制",
  "constellationSystemType": "古宿制",
  "panelSystemType": "恒星制",
  "epochCorrection": "元·授时历",
  "totalDegree": 365.25,
  "gongOrder": [
    "戌",
    "酉",
    "申",
    "未",
    "午",
    "巳",
    "辰",
    "卯",
    "寅",
    "丑",
    "子",
    "亥"
  ],
  "starInnOrder": [
    "角",
    "亢",
    "氐",
    "房",
    "心",
    "尾",
    "箕",
    "斗",
    "牛",
    "女",
    "虚",
    "危",
    "室",
    "壁",
    "奎",
    "娄",
    "胃",
    "昴",
    "毕",
    "觜",
    "参",
    "井",
    "鬼",
    "柳",
    "星",
    "张",
    "翼",
    "轸"
  ],
  "gongDegreeSeq": [
    {
      "gong": "子",
      "degree": 30.0
    },
    {
      "gong": "丑",
      "degree": 30.0
    },
    {
      "gong": "寅",
      "degree": 30.0
    },
    {
      "gong": "卯",
      "degree": 30.0
    },
    {
      "gong": "辰",
      "degree": 30.0
    },
    {
      "gong": "巳",
      "degree": 30.0
    },
    {
      "gong": "午",
      "degree": 30.0
    },
    {
      "gong": "未",
      "degree": 30.0
    },
    {
      "gong": "申",
      "degree": 30.0
    },
    {
      "gong": "酉",
      "degree": 30.0
    },
    {
      "gong": "戌",
      "degree": 30.0
    },
    {
      "gong": "亥",
      "degree": 30.0
    }
  ],
  "starInnDegreeSeq": [
    {
      "constellation": "角",
      "degree": 11.926078
    },
    {
      "constellation": "亢",
      "degree": 9.067762
    },
    {
      "constellation": "氐",
      "degree": 16.065708
    },
    {
      "constellation": "房",
      "degree": 5.519507
    },
    {
      "constellation": "心",
      "degree": 6.406571
    },
    {
      "constellation": "尾",
      "degree": 18.825462
    },
    {
      "constellation": "箕",
      "degree": 10.250513
    },
    {
      "constellation": "斗",
      "degree": 24.837782
    },
    {
      "constellation": "牛",
      "degree": 7.096509
    },
    {
      "constellation": "女",
      "degree": 11.186858
    },
    {
      "constellation": "虚",
      "degree": 8.821355
    },
    {
      "constellation": "危",
      "degree": 15.178645
    },
    {
      "constellation": "室",
      "degree": 16.854209
    },
    {
      "constellation": "壁",
      "degree": 8.476386
    },
    {
      "constellation": "奎",
      "degree": 16.361396
    },
    {
      "constellation": "娄",
      "degree": 11.63039
    },
    {
      "constellation": "胃",
      "degree": 15.37577
    },
    {
      "constellation": "昴",
      "degree": 11.137577
    },
    {
      "constellation": "毕",
      "degree": 17.149897
    },
    {
      "constellation": "觜",
      "degree": 0.049281
    },
    {
      "constellation": "参",
      "degree": 10.940452
    },
    {
      "constellation": "井",
      "degree": 32.821355
    },
    {
      "constellation": "鬼",
      "degree": 2.168378
    },
    {
      "constellation": "柳",
      "degree": 13.10883
    },
    {
      "constellation": "星",
      "degree": 6.209446
    },
    {
      "constellation": "张",
      "degree": 17.002053
    },
    {
      "constellation": "翼",
      "degree": 18.480493
    },
    {
      "constellation": "轸",
      "degree": 17.051335
    }
  ],
  "alignmentPointAtConstellation": {
    "constellation": "女",
    "degree": 1.971253
  },
  "alignmentPointAtGong": {
    "gong": "丑",
    "degree": 14.784394
  },
  "zeroPointJieQi": "冬至",
  "zeroPointAtConstellation": {
    "constellation": "女",
    "degree": 1.971253
  },
  "zeroPointAtGong": {
    "gong": "子",
    "degree": 14.784394
  },
  "celestialLongitude": 270.0,
  "rightAscension": 240.5,
  "zeroPointOffsetToNow": 28.0,
  "specificationList": [
    "元授时天赤道恒星制，郭守敬 28 宿距度表，总度数 365.25 度"
  ]
}');
INSERT INTO ephemeris_document ("file_name", "payload_json") VALUES ('yuan_sky_equatorial_sidereal.json', '{
      "systemType": "赤道制",
      "constellationSystemType": "古宿制",
      "starInnSystem": "恒星制",
      "epochCorrection": "元·授时历",
      "totalDegree": 365.25,
      "gongDegreeSeq": [
        {"gong":"子","degree": 30.438},
        {"gong":"丑","degree": 30.438},
        {"gong":"寅","degree": 30.438},
        {"gong":"卯","degree": 30.438},
        {"gong":"辰","degree": 30.438},
        {"gong":"巳","degree": 30.438},
        {"gong":"午","degree": 30.438},
        {"gong":"未","degree": 30.438},
        {"gong":"申","degree": 30.438},
        {"gong":"酉","degree": 30.438},
        {"gong":"戌","degree": 30.438},
        {"gong":"亥","degree": 30.438}
      ],
    "starInnDegreeSeq": [
{"constellation":"角","degree":12},
{"constellation":"亢","degree":9},
{"constellation":"氐","degree":15},
{"constellation":"房","degree":5},
{"constellation":"心","degree":5},
{"constellation":"尾","degree":18},
{"constellation":"箕","degree":11},

{"constellation":"斗","degree":26.25},
{"constellation":"牛","degree":8},
{"constellation":"女","degree":12},
{"constellation":"虚","degree":10},
{"constellation":"危","degree":17},
{"constellation":"室","degree":16},
{"constellation":"壁","degree":9},

{"constellation":"奎","degree":16},
{"constellation":"娄","degree":12},
{"constellation":"胃","degree":14},
{"constellation":"昴","degree":11},
{"constellation":"毕","degree":16},
{"constellation":"觜","degree":2},
{"constellation":"参","degree":9},

{"constellation":"井","degree":33},
{"constellation":"鬼","degree":4},
{"constellation":"柳","degree":15},
{"constellation":"星","degree":7},
{"constellation":"张","degree":18},
{"constellation":"翼","degree":18},
{"constellation":"轸","degree":17}
    ],
    "alignmentPointAtStarInn": {
      "starInn": "女宿",
      "degree": 2.1
    },
    "alignmentPointAtGong": {
      "gong": "子",
      "degree": 0
    },
      "zeroPointJieQi": "冬至",
      "zeroPointAtStarInn": {"starInn": "虚宿", "degree": 6},
      "zeroPointAtGong": {"gong": "子宫", "degree": 15.0},
      "celestialLongitude": 270.0,
      "rightAscension": 240.5,
      "zeroPointOffsetToNow": 28.0,
      "specificationList":[
        "元朝七政四余，使用的赤道恒星制，女宿2.1°子宫零度,365.25°，等宫制"
      ]
  }');
INSERT INTO ephemeris_document ("file_name", "payload_json") VALUES ('ming_si_huangdao_hengxing.json', '{
      "systemType": "似黄道制",
      "starInnType": "古宿",
      "starInnSystem": "恒星制",
      "epochCorrection": "元·授时历",
      "totalDegree": 365.25,
      "twelvGongDegreeMap": {
        "子": 30.44,
        "丑": 30.44,
        "寅": 30.44,
        "卯": 30.44,
        "辰": 30.44,
        "巳": 30.44,
        "午": 30.44,
        "未": 30.44,
        "申": 30.44,
        "酉": 30.44,
        "戌": 30.44,
        "亥": 30.44
    },
    "starInnDegreeMap": {
"角": 12.0, "亢": 9.0, "氐": 15.0, "房": 5.0, "心": 5.0,"尾":18.0,"箕": 11.0,
"斗": 26.25, "牛": 8.0, "女": 12.0, "虚": 10.0, "危": 17.0,"室":16.0,"壁": 9.0,
"奎": 16.0, "娄": 12.0, "胃": 14.0, "昴": 11.0, "毕": 16.0,"觜":2.0,"参": 9.0,
"井": 33.0, "鬼": 4.0, "柳": 15.0, "星": 7.0, "张": 18.0,"翼":18.0,"轸": 17.0
    },
    "alignmentPointAtStarInn": {
      "starInn": "女宿",
      "degree": 1.38
    },
    "alignmentPointAtGong": {
      "gong": "子宫",
      "degree": 0.0
    },
      "zeroPointJieQi": "冬至",
      "zeroPointAtStarInn": {"starInn": "牛宿", "degree": 0.0},
      "zeroPointAtGong": {"gong": "子宫", "degree": 15.0},
      "celestialLongitude": 270.0,
      "rightAscension": 240.5,
      "zeroPointOffsetToNow": 28.0,
    "description": "明代常用，似黄道恒星制。从元代的赤道恒星制发展而来，以黄道为基，采用不等宫制。"
  }');
INSERT INTO ephemeris_document ("file_name", "payload_json") VALUES ('ming_si_huangdao_hengxing.v2.json', '{
  "systemType": "似黄道恒星制",
  "constellationSystemType": "古宿制",
  "panelSystemType": "恒星制",
  "epochCorrection": "元·授时历",
  "totalDegree": 365.25,
  "gongOrder": [
    "戌",
    "酉",
    "申",
    "未",
    "午",
    "巳",
    "辰",
    "卯",
    "寅",
    "丑",
    "子",
    "亥"
  ],
  "starInnOrder": [
    "角",
    "亢",
    "氐",
    "房",
    "心",
    "尾",
    "箕",
    "斗",
    "牛",
    "女",
    "虚",
    "危",
    "室",
    "壁",
    "奎",
    "娄",
    "胃",
    "昴",
    "毕",
    "觜",
    "参",
    "井",
    "鬼",
    "柳",
    "星",
    "张",
    "翼",
    "轸"
  ],
  "gongDegreeSeq": [
    { "gong": "子", "degree": 30.44 },
    { "gong": "丑", "degree": 30.44 },
    { "gong": "寅", "degree": 30.44 },
    { "gong": "卯", "degree": 30.44 },
    { "gong": "辰", "degree": 30.44 },
    { "gong": "巳", "degree": 30.44 },
    { "gong": "午", "degree": 30.44 },
    { "gong": "未", "degree": 30.44 },
    { "gong": "申", "degree": 30.44 },
    { "gong": "酉", "degree": 30.44 },
    { "gong": "戌", "degree": 30.44 },
    { "gong": "亥", "degree": 30.44 }
  ],
  "starInnDegreeSeq": [
    { "constellation": "角", "degree": 12.0 },
    { "constellation": "亢", "degree": 9.0 },
    { "constellation": "氐", "degree": 15.0 },
    { "constellation": "房", "degree": 5.0 },
    { "constellation": "心", "degree": 5.0 },
    { "constellation": "尾", "degree": 18.0 },
    { "constellation": "箕", "degree": 11.0 },
    { "constellation": "斗", "degree": 26.25 },
    { "constellation": "牛", "degree": 8.0 },
    { "constellation": "女", "degree": 12.0 },
    { "constellation": "虚", "degree": 10.0 },
    { "constellation": "危", "degree": 17.0 },
    { "constellation": "室", "degree": 16.0 },
    { "constellation": "壁", "degree": 9.0 },
    { "constellation": "奎", "degree": 16.0 },
    { "constellation": "娄", "degree": 12.0 },
    { "constellation": "胃", "degree": 14.0 },
    { "constellation": "昴", "degree": 11.0 },
    { "constellation": "毕", "degree": 16.0 },
    { "constellation": "觜", "degree": 2.0 },
    { "constellation": "参", "degree": 9.0 },
    { "constellation": "井", "degree": 33.0 },
    { "constellation": "鬼", "degree": 4.0 },
    { "constellation": "柳", "degree": 15.0 },
    { "constellation": "星", "degree": 7.0 },
    { "constellation": "张", "degree": 18.0 },
    { "constellation": "翼", "degree": 18.0 },
    { "constellation": "轸", "degree": 17.0 }
  ],
  "alignmentPointAtConstellation": {
    "constellation": "女",
    "degree": 1.38
  },
  "alignmentPointAtGong": {
    "gong": "子",
    "degree": 0.0
  },
  "zeroPointJieQi": "冬至",
  "zeroPointAtConstellation": {
    "constellation": "牛",
    "degree": 0.0
  },
  "zeroPointAtGong": {
    "gong": "子",
    "degree": 15.0
  },
  "celestialLongitude": 270.0,
  "zeroPointOffsetToNow": 28.0,
  "rightAscension": 240.5,
  "specificationList": [
    "明似黄道恒星制，从元代赤道恒星制发展而来，以黄道为基，采用不等宫制"
  ]
}
');
INSERT INTO ephemeris_document ("file_name", "payload_json") VALUES ('song_sanchentongzai.json', '{
  "systemType": "黄道制",
  "constellationSystemType": "古宿制",
  "panelSystemType": "恒星制",
  "epochCorrection": "宋·三辰通载（钱如璧传）",
  "totalDegree": 365.255,
  "gongOrder": [
    "戌",
    "酉",
    "申",
    "未",
    "午",
    "巳",
    "辰",
    "卯",
    "寅",
    "丑",
    "子",
    "亥"
  ],
  "starInnOrder": [
    "角",
    "亢",
    "氐",
    "房",
    "心",
    "尾",
    "箕",
    "斗",
    "牛",
    "女",
    "虚",
    "危",
    "室",
    "壁",
    "奎",
    "娄",
    "胃",
    "昴",
    "毕",
    "觜",
    "参",
    "井",
    "鬼",
    "柳",
    "星",
    "张",
    "翼",
    "轸"
  ],
  "gongDegreeSeq": [
    { "gong": "子", "degree": 30.438 },
    { "gong": "丑", "degree": 30.4379 },
    { "gong": "寅", "degree": 30.4379 },
    { "gong": "卯", "degree": 30.4379 },
    { "gong": "辰", "degree": 30.4379 },
    { "gong": "巳", "degree": 30.4379 },
    { "gong": "午", "degree": 30.438 },
    { "gong": "未", "degree": 30.4379 },
    { "gong": "申", "degree": 30.4379 },
    { "gong": "酉", "degree": 30.4379 },
    { "gong": "戌", "degree": 30.4379 },
    { "gong": "亥", "degree": 30.4379 }
  ],
  "starInnDegreeSeq": [
    { "constellation": "角", "degree": 13.0 },
    { "constellation": "亢", "degree": 9.0 },
    { "constellation": "氐", "degree": 16.0 },
    { "constellation": "房", "degree": 5.0 },
    { "constellation": "心", "degree": 5.0 },
    { "constellation": "尾", "degree": 17.0 },
    { "constellation": "箕", "degree": 10.0 },
    { "constellation": "斗", "degree": 24.0 },
    { "constellation": "牛", "degree": 7.0 },
    { "constellation": "女", "degree": 11.5 },
    { "constellation": "虚", "degree": 10.255 },
    { "constellation": "危", "degree": 18.0 },
    { "constellation": "室", "degree": 17.0 },
    { "constellation": "壁", "degree": 10.0 },
    { "constellation": "奎", "degree": 17.5 },
    { "constellation": "娄", "degree": 13.0 },
    { "constellation": "胃", "degree": 14.5 },
    { "constellation": "昴", "degree": 11.0 },
    { "constellation": "毕", "degree": 16.0 },
    { "constellation": "觜", "degree": 1.0 },
    { "constellation": "参", "degree": 9.0 },
    { "constellation": "井", "degree": 30.0 },
    { "constellation": "鬼", "degree": 3.0 },
    { "constellation": "柳", "degree": 14.0 },
    { "constellation": "星", "degree": 7.0 },
    { "constellation": "张", "degree": 19.0 },
    { "constellation": "翼", "degree": 19.0 },
    { "constellation": "轸", "degree": 18.5 }
  ],
  "alignmentPointAtConstellation": {
    "constellation": "虚",
    "degree": 1.6275
  },
  "alignmentPointAtGong": {
    "gong": "子",
    "degree": 0.0
  },
  "zeroPointJieQi": "春分",
  "zeroPointAtConstellation": {
    "constellation": "虚",
    "degree": 1.6275
  },
  "zeroPointAtGong": {
    "gong": "子",
    "degree": 0.0
  },
  "celestialLongitude": 0.0,
  "rightAscension": 0.0,
  "zeroPointOffsetToNow": 0.0,
  "specificationList": [
    "出处：《三辰通载》三十卷，宋·钱如璧传，影宋抄本 PDF（用户提供）。黄道恒星制、古宿。",
    "锚点（1-D 定案）：子宫0° = 虚宿 1.6275°；戌宫0° = 奎宿 7.2484°。周天 365.255°，等宫制（子午宫 30.438°、其余宫 30.4379°，合计 365.255°）。",
    "二十八宿黄道宿度由原表十二宫分段表反推，求和 = 365.255°，且与''周天黄道二十八宿求度数''歌诀逐字吻合（室17、奎17.5、娄13、胃14.5、井30、张翼各19、危18、虚10.255…）。系原表 decimalized，非现代均分反推。",
    "岁差参数 zeroPointOffsetToNow 暂置 0.0（未由本次史料坐实，接入排盘前需另行计算）。",
    "考订与互证详见 docs/project/tasks/1D-sanchen-primary-source.md、1D-claude-analysis.md。"
  ]
}
');
INSERT INTO ephemeris_document ("file_name", "payload_json") VALUES ('huangdao_huigui_gu.json', '{
      "systemType": "黄道制",
      "starInnType": "古宿制",
      "starInnSystem": "回归制",
      "epochCorrection": "开禧历",
      "totalDegree": 360.00,
      "twelvGongDegreeMap": {
        "子": 30.0,
        "丑": 30.0,
        "寅": 30.0,
        "卯": 30.0,
        "辰": 30.0,
        "巳": 30.0,
        "午": 30.0,
        "未": 30.0,
        "申": 30.0,
        "酉": 30.0,
        "戌": 30.0,
        "亥": 30.0
    },
    "starInnDegreeMap": {
      "危": 15.3, "室": 15.8, "壁": 8.9, "奎": 17.6, "娄": 10.4,
      "胃": 14.8, "昴": 12.1, "毕": 15.8, "觜": 1, "参": 11.8,
      "井": 30.5, "鬼": 2.9, "柳": 15.3, "星": 5.9, "张": 15.0,
      "翼": 18.7, "轸": 17.1, "角": 12.8, "亢": 8.9, "氐": 16.3,
      "房": 5.4, "心": 6.4, "尾": 18.6, "箕": 10.7, "斗": 23.8,
      "牛": 7.9, "女": 10.9, "虚": 9.4
    },
    "alignmentPointAtStarInn": {
      "starInn": "奎宿",
      "degree": 1.7
    },
    "alignmentPointAtGong": {
      "gong": "戌",
      "degree": 0.0
    },
      "zeroPointJieQi": "春分",
      "zeroPointAtStarInn": {"starInn": "奎宿", "degree": 1.7},
      "zeroPointAtGong": {"gong": "戌宫", "degree": 0.0},
      "celestialLongitude": 0.0,
      "zeroPointOffsetToNow": 14.0,
      "specificationList":[
        "来自moira, 奎宿1.7° 戌白羊0° 春分点, 黄经0°，岁差为14.09° 使用14.0°"
      ]
  }');
INSERT INTO ephemeris_document ("file_name", "payload_json") VALUES ('huangdao_huigui_gu_corrected.json', '{
      "systemType": "黄道",
      "starInnType": "古宿矫正",
      "starInnSystem": "回归制",
      "epochCorrection": "开禧历",
      "totalDegree": 360.00,
      "twelvGongDegreeMap": {
        "子": 30.0,
        "丑": 30.0,
        "寅": 30.0,
        "卯": 30.0,
        "辰": 30.0,
        "巳": 30.0,
        "午": 30.0,
        "未": 30.0,
        "申": 30.0,
        "酉": 30.0,
        "戌": 30.0,
        "亥": 30.0
    },
    "starInnDegreeMap": {
      "危": 15.3, "室": 15.8, "壁": 8.9, "奎": 17.6, "娄": 10.4,
      "胃": 14.8, "昴": 12.1, "毕": 15.8, "觜": 1, "参": 11.8,
      "井": 30.5, "鬼": 2.9, "柳": 15.3, "星": 5.9, "张": 15.0,
      "翼": 18.7, "轸": 17.1, "角": 12.8, "亢": 8.9, "氐": 16.3,
      "房": 5.4, "心": 6.4, "尾": 18.6, "箕": 10.7, "斗": 23.8,
      "牛": 7.9, "女": 10.9, "虚": 9.4
    },
    "alignmentPointAtStarInn": {
      "starInn": "室宿",
      "degree": 12.7
    },
    "alignmentPointAtGong": {
      "gong": "戌",
      "degree": 0.0
    },
      "zeroPointJieQi": "春分",
      "zeroPointAtStarInn": {"starInn": "室宿", "degree": 12.7},
      "zeroPointAtGong": {"gong": "戌宫", "degree": 0.0},
      "celestialLongitude": 0.0,
      "zeroPointOffsetToNow": 0.0,
      "specificationList":[
        "来自moira, 室宿12.7° 戌白羊0° 春分点, 黄经0°，岁差为0°已矫正"
      ]
  }');
INSERT INTO ephemeris_document ("file_name", "payload_json") VALUES ('huangdao_huigui_gu_now.json', '{
      "systemType": "黄道",
      "starInnType": "今宿",
      "starInnSystem": "回归制",
      "epochCorrection": "j2000",
      "totalDegree": 360.00,
      "twelvGongDegreeMap": {
        "子": 30.0,
        "丑": 30.0,
        "寅": 30.0,
        "卯": 30.0,
        "辰": 30.0,
        "巳": 30.0,
        "午": 30.0,
        "未": 30.0,
        "申": 30.0,
        "酉": 30.0,
        "戌": 30.0,
        "亥": 30.0
    },
    "starInnDegreeMap": {
      "危":20.07, "室":16.75, "壁":12.22, "奎":11.52, "娄":12.97,
      "胃":12.48, "昴":9.05, "毕":15.2, "觜":1, "参":10.62,
      "井":30.45, "鬼":4.99, "柳":15.98, "星":7.99, "张":19.07,
      "翼":16.93, "轸":12.81, "角":10.99, "亢":10.59, "氐":17.85,
      "房":4.85, "心":8.25, "尾":15.20, "箕":8.94, "斗":23.92,
      "牛":7.67, "女":11.67, "虚":9.97
    },
    "alignmentPointAtStarInn": {
      "starInn": "室宿",
      "degree": 6.55
    },
    "alignmentPointAtGong": {
      "gong": "戌",
      "degree": 0.0
    },
      "zeroPointJieQi": "春分",
      "zeroPointAtStarInn": {"starInn": "室宿", "degree": 6.55},
      "zeroPointAtGong": {"gong": "戌宫", "degree": 0.0},
      "celestialLongitude": 0.0,
      "zeroPointOffsetToNow": 0.0,
      "specificationList":[
        "来自moira, 室宿12.7° 戌白羊0° 春分点, 黄经0°，岁差为0°已矫正"
      ]
  }');
INSERT INTO ephemeris_document ("file_name", "payload_json") VALUES ('stars_four_relationship.json', '
{
  "relationships": [
    {
      "star": "土",
      "className": "果老星宗",
      "fourRelationshipMapper": {
        "恩": ["火", "罗"],
        "难": ["木", "炁"],
        "仇": ["水", "孛"],
        "用": ["金"]
      }
    },
    {
      "star": "木",
      "className": "果老星宗",
      "fourRelationshipMapper": {
        "恩": ["水", "孛"],
        "难": ["金"],
        "仇": ["土", "计"],
        "用": ["火", "罗"]
      }
    },
    {
      "star": "火",
      "className": "果老星宗",
      "fourRelationshipMapper": {
        "恩": ["木", "炁"],
        "难": ["水", "孛"],
        "仇": ["金"],
        "用": ["土", "计"]
      }
    },
    {
      "star": "金",
      "className": "果老星宗",
      "fourRelationshipMapper": {
        "恩": ["土", "计"],
        "难": ["火", "罗"],
        "仇": ["木", "炁"],
        "用": ["水", "孛"]
      }
    },
    {
      "star": "水",
      "className": "果老星宗",
      "fourRelationshipMapper": {
        "恩": ["金"],
        "难": ["土", "计"],
        "仇": ["火", "罗"],
        "用": ["木", "炁"]
      }
    },
    {
      "star": "日",
      "className": "果老星宗",
      "fourRelationshipMapper": {
        "恩": ["金", "水"],
        "难": ["木", "炁"],
        "仇": ["土", "计"],
        "用": ["火", "罗"]
      }
    },
    {
      "star": "月",
      "className": "果老星宗",
      "fourRelationshipMapper": {
        "恩": ["金"],
        "难": ["土", "计"],
        "仇": ["火", "罗"],
        "用": ["木", "炁"]
      }
    },
    {
      "star": "罗",
      "className": "果老星宗",
      "fourRelationshipMapper": {
        "恩": ["木", "炁"],
        "难": ["水", "孛"],
        "仇": ["金"],
        "用": ["土", "计"]
      }
    },
    {
      "star": "计",
      "className": "果老星宗",
      "fourRelationshipMapper": {
        "恩": ["火", "罗"],
        "难": ["木", "炁"],
        "仇": ["水", "孛"],
        "用": ["金"]
      }
    },
    {
      "star": "孛",
      "className": "果老星宗",
      "fourRelationshipMapper": {
        "恩": ["金"],
        "难": ["土", "计"],
        "仇": ["火", "罗"],
        "用": ["木", "炁"]
      }
    },
    {
      "star": "炁",
      "className": "果老星宗",
      "fourRelationshipMapper": {
        "恩": ["水", "孛"],
        "难": ["金"],
        "仇": ["土", "计"],
        "用": ["火", "罗"]
      }
    }
  ]
} ');
INSERT INTO ephemeris_document ("file_name", "payload_json") VALUES ('zheng_shi_xing_an.json', '{
      "systemType": "似黄道恒星制",
      "constellationSystemType": "古宿制",
      "panelSystemType": "恒星制",
      "epochCorrection": "郑氏星案",
      "totalDegree": 360.00,
      "gongOrder":[
        "子","亥","戌","酉","申","未","午","巳","辰","卯","寅","丑"
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
        "女","虚","危","室","壁","奎","娄","胃","昴","毕","觜","参","井","鬼","柳","星","张","翼","轸","角","亢","氐","房","心","尾","箕","斗","牛"
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
    "alignmentPointAtConstellation": {"constellation":"虚","degree": 6.0},
    "alignmentPointAtGong": {
      "gong": "子",
      "degree": 15.0
    },
      "zeroPointJieQi": "立春",
      "zeroPointAtConstellation": {"constellation":"女","degree": 2.1},
      "zeroPointAtGong": {"gong": "子", "degree": 0.0},
      "celestialLongitude": 0.0,
      "rightAscension": 0.0,
      "zeroPointOffsetToNow": 0.0,
      "specificationList":[
        "来自moira, 郑氏星案"
      ]
  }');
COMMIT;
