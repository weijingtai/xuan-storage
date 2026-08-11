CREATE TABLE IF NOT EXISTS ge_ju_rules_document (  file_name TEXT PRIMARY KEY,  payload_json TEXT NOT NULL);
DELETE FROM ge_ju_rules_document;
INSERT INTO ge_ju_rules_document ("file_name", "payload_json") VALUES ('common_ge_ju_rules.json', '[
  {
    "id": "common_001_ri_yue_jia_ming",
    "name": "日月夹命",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "common_002_ri_yue_tong_gong",
    "name": "日月同宫",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Sun",
            "Moon"
          ]
        }
      },
      {},
      {},
      {}
    ]
  },
  {
    "id": "common_003_wu_xing_ju_quan",
    "name": "五星聚全",
    "variants": [
      {
        "conditions": {
          "type": "trineGong",
          "stars": [
            "Jupiter",
            "Mars",
            "Saturn",
            "Venus",
            "Mercury"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_001_huo_luo_jia_ming",
    "name": "火罗夹命",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "jin_001_tai_bai_shou_ming",
    "name": "太白守命",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starGuardLife",
              "star": "Venus"
            },
            {
              "type": "starGongStatus",
              "star": "Venus",
              "statuses": [
                "Miao",
                "Wang"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "xian_001_xian_yu_ji",
    "name": "限遇计都",
    "variants": [
      {
        "conditions": {
          "type": "xianMeetStar",
          "stars": [
            "Ji"
          ]
        }
      }
    ]
  },
  {
    "id": "time_001_zhou_sheng_ri_li",
    "name": "昼生日立命",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "isDayBirth",
              "isDay": true
            },
            {
              "type": "starGuardLife",
              "star": "Sun"
            }
          ]
        }
      }
    ]
  }
]');
INSERT INTO ge_ju_rules_document ("file_name", "payload_json") VALUES ('ge_ju_2_rules.json', '[
  {
    "id": "geju2_9acefcb7",
    "name": "计罗截断",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_90e13704",
    "name": "身居闲极",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_d5f1bf68",
    "name": "二主临财",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_826fec08",
    "name": "官福居垣",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_3b4be61c",
    "name": "日月守照",
    "variants": [
      {
        "conditions": {
          "type": "or",
          "conditions": [
            {
              "type": "starGuardLife",
              "star": "Sun",
              "gong": "Life"
            },
            {
              "type": "starGuardLife",
              "star": "Moon",
              "gong": "Life"
            }
          ]
        }
      },
      {
        "conditions": {
          "type": "or",
          "conditions": [
            {
              "type": "starGuardLife",
              "star": "Sun",
              "gong": "Life"
            },
            {
              "type": "starGuardLife",
              "star": "Moon",
              "gong": "Life"
            }
          ]
        }
      },
      {
        "conditions": {
          "type": "or",
          "conditions": [
            {
              "type": "starGuardLife",
              "star": "Sun",
              "gong": "Life"
            },
            {
              "type": "starGuardLife",
              "star": "Moon",
              "gong": "Life"
            }
          ]
        }
      }
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_ee7c2184",
    "name": "二曜朝阳",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_4530977a",
    "name": "官福互垣",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_6f932e9d",
    "name": "官福夹拱",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_92f54ec4",
    "name": "福德引援",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_25835c8f",
    "name": "身命坐贵",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_68c76b99",
    "name": "文魁拱命",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_70d62142",
    "name": "福禄夹身",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_25eaf434",
    "name": "煞前主后",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_5a7a73be",
    "name": "身命互换",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_b50222c3",
    "name": "日月趋朝",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_3dc00f52",
    "name": "背君朝主",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_51bc149d",
    "name": "出乾入巽",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_ce2ced84",
    "name": "戴天履地",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_d111fa22",
    "name": "廷尉辅阳",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_37c8230f",
    "name": "五曜连珠",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_4715a42e",
    "name": "七政入垣",
    "variants": [
      {
        "conditions": {
          "type": "sevenPlanetsInPalace"
        }
      },
      {
        "conditions": {
          "type": "sevenPlanetsInPalace"
        }
      },
      {
        "conditions": {
          "type": "sevenPlanetsInPalace"
        }
      }
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_501aa826",
    "name": "用星对照",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_ec7e1486",
    "name": "四雄朝拱",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_3a7c3464",
    "name": "诸星得位",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_634534e3",
    "name": "诸星得经",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_6b8788df",
    "name": "主星朝君",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_96d8f9d3",
    "name": "母依日月",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_6fbf07c9",
    "name": "令主得助",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_c5c1d979",
    "name": "天元得地",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_13b0f444",
    "name": "朱雀衔符",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_9a6d048a",
    "name": "拱夹端门",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_3bd9768e",
    "name": "金木水日会毕",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_d22a3990",
    "name": "五星并随日月",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_4b355835",
    "name": "火土昼逢",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_dc8a1580",
    "name": "拱夹帝座",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_14604490",
    "name": "日月互垣",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_4b8f33c7",
    "name": "天地通关",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_c3cafd3b",
    "name": "水孛扶印",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_9e57e646",
    "name": "水孛助禄",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_c6d5f844",
    "name": "福禄随官",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_ea3d2177",
    "name": "金水辅阴",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_3ca57d5f",
    "name": "火金逢月",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_de2e3e84",
    "name": "金土富豪",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_001fdbe8",
    "name": "身命逢官",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_ee80cdd4",
    "name": "逢生坐实",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_8abcd786",
    "name": "官禄守籍",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_493abbbc",
    "name": "火气官高",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_98d7717b",
    "name": "月挂柳梢",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_df5db0d8",
    "name": "孛挂朱衣",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_4a7d55cc",
    "name": "命坐玉堂",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_1b317504",
    "name": "文昌照命",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_d47d976c",
    "name": "三台辅命",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_e8667bef",
    "name": "禄勋坐命",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  },
  {
    "id": "geju2_586d637f",
    "name": "日帝居阳",
    "variants": [
      {},
      {},
      {}
    ],
    "scope": "natal"
  }
]');
INSERT INTO ge_ju_rules_document ("file_name", "payload_json") VALUES ('ge_ju_zong_lun_rules.json', '[
  {
    "id": "geju_001_ri_yue_he_ge",
    "name": "日月合格",
    "variants": [
      {
        "conditions": {
          "type": "sunMoonHarmony"
        }
      }
    ]
  },
  {
    "id": "geju_002_ri_yue_ji_ge",
    "name": "日月忌格",
    "variants": [
      {}
    ]
  },
  {
    "id": "geju_003_wu_xing_he_ge",
    "name": "五星合格",
    "variants": [
      {}
    ]
  },
  {
    "id": "geju_004_wu_xing_ji_ge",
    "name": "五星忌格",
    "variants": [
      {}
    ]
  },
  {
    "id": "geju_005_si_yu_he_ge",
    "name": "四余合格",
    "variants": [
      {}
    ]
  },
  {
    "id": "geju_006_zheng_yu_he_ge",
    "name": "政余合格",
    "variants": [
      {}
    ]
  },
  {
    "id": "geju_007_zheng_yu_ji_ge",
    "name": "政余忌格",
    "variants": [
      {}
    ]
  },
  {
    "id": "geju_008_zhu_xing_ci_ge",
    "name": "诸星次格",
    "variants": [
      {}
    ]
  }
]');
INSERT INTO ge_ju_rules_document ("file_name", "payload_json") VALUES ('gui_ge_ge_ju_rules.json', '[
  {
    "id": "guige_001_gui_ge",
    "name": "贵格",
    "variants": [
      {
        "conditions": {
          "type": "officialStarPatterns"
        }
      }
    ]
  },
  {
    "id": "guige_002_jian_ge",
    "name": "贱格",
    "variants": [
      {}
    ]
  },
  {
    "id": "guige_003_pin_ge",
    "name": "贫格",
    "variants": [
      {}
    ]
  },
  {
    "id": "guige_004_ji_ge",
    "name": "疾格",
    "variants": [
      {}
    ]
  }
]');
INSERT INTO ge_ju_rules_document ("file_name", "payload_json") VALUES ('he_ge_ge_ju_rules.json', '[
  {
    "id": "hege_001_shen_ming_he_ge",
    "name": "身命合格",
    "variants": [
      {
        "conditions": {
          "type": "or",
          "conditions": [
            {
              "type": "bodyLifeHarmony"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "hege_002_ming_zhu_he_ge",
    "name": "命主合格",
    "variants": [
      {
        "conditions": {
          "type": "lifeLordInFavorablePlace"
        }
      }
    ]
  },
  {
    "id": "hege_003_tian_zhu_he_ge",
    "name": "田主合格",
    "variants": [
      {}
    ]
  },
  {
    "id": "hege_004_cai_xing_he_ge",
    "name": "财星合格",
    "variants": [
      {}
    ]
  },
  {
    "id": "hege_005_lu_zhu_he_ge",
    "name": "禄主合格",
    "variants": [
      {}
    ]
  },
  {
    "id": "hege_006_fu_xing_he_ge",
    "name": "福星合格",
    "variants": [
      {}
    ]
  },
  {
    "id": "hege_007_qi_xing_he_ge",
    "name": "妻星合格",
    "variants": [
      {}
    ]
  },
  {
    "id": "hege_008_si_xing_he_ge",
    "name": "嗣星合格",
    "variants": [
      {}
    ]
  },
  {
    "id": "jige_009_shen_xing_ji_ge",
    "name": "身星忌格",
    "variants": [
      {}
    ]
  },
  {
    "id": "jige_010_ming_zhu_ji_ge",
    "name": "命主忌格",
    "variants": [
      {}
    ]
  },
  {
    "id": "jige_011_tian_zhu_ji_ge",
    "name": "田主忌格",
    "variants": [
      {}
    ]
  },
  {
    "id": "jige_012_cai_xing_ji_ge",
    "name": "财星忌格",
    "variants": [
      {}
    ]
  },
  {
    "id": "jige_013_lu_zhu_ji_ge",
    "name": "禄主忌格",
    "variants": [
      {}
    ]
  },
  {
    "id": "jige_014_fu_zhu_ji_ge",
    "name": "福主忌格",
    "variants": [
      {}
    ]
  },
  {
    "id": "jige_015_qi_xing_ji_ge",
    "name": "妻星忌格",
    "variants": [
      {}
    ]
  },
  {
    "id": "jige_016_zi_xing_ji_ge",
    "name": "子星忌格",
    "variants": [
      {}
    ]
  },
  {
    "id": "jige_017_zhu_xing_hu_ge",
    "name": "诸星互格",
    "variants": [
      {}
    ]
  }
]');
INSERT INTO ge_ju_rules_document ("file_name", "payload_json") VALUES ('huo_xing_ge_ju_rules.json', '[
  {
    "id": "huo_001_zhu_yi_chi_ri",
    "name": "朱衣驰日",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mars",
                "Sun"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Mars",
                "Qi"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_002_bei_hai_tiao_deng",
    "name": "北海挑灯",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Mars",
          "gongs": [
            "Hai"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_003_bei_yuan_hui_chun",
    "name": "北苑回春",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Mars",
              "gongs": [
                "Zi"
              ]
            },
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "starGuardLife",
              "star": "Mars"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_004_chang_hong_guan_ri",
    "name": "长虹贯日",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Mars",
            "Sun"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_005_zhou_huo_ye_tu",
    "name": "昼火夜土",
    "variants": [
      {
        "conditions": {
          "type": "or",
          "conditions": [
            {
              "type": "and",
              "conditions": [
                {
                  "type": "isDayBirth",
                  "isDay": true
                },
                {
                  "type": "or",
                  "conditions": [
                    {
                      "type": "starGuardLife",
                      "star": "Mars"
                    },
                    {
                      "type": "starGuardLife",
                      "star": "Luo"
                    }
                  ]
                }
              ]
            },
            {
              "type": "and",
              "conditions": [
                {
                  "type": "isDayBirth",
                  "isDay": false
                },
                {
                  "type": "or",
                  "conditions": [
                    {
                      "type": "starGuardLife",
                      "star": "Saturn"
                    },
                    {
                      "type": "starGuardLife",
                      "star": "Ji"
                    }
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_006_huo_luo_xia_hui",
    "name": "火罗夏会",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SUMMER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Mars",
                "Luo"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_007_jin_huo_yi_yuan",
    "name": "金火易垣",
    "variants": [
      {
        "conditions": {
          "type": "or",
          "conditions": [
            {
              "type": "starGongStatus",
              "star": "Mars",
              "statuses": [
                "Yuan"
              ]
            },
            {
              "type": "starGongStatus",
              "star": "Venus",
              "statuses": [
                "Yuan"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_008_zhou_huo_fan_ri",
    "name": "昼火犯日",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "isDayBirth",
              "isDay": true
            },
            {
              "type": "sameGong",
              "stars": [
                "Mars",
                "Sun"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_009_huo_tu_ba_sha",
    "name": "火土八杀",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Mars",
            "Luo",
            "Saturn"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_010_huo_luo_ru_ji",
    "name": "火罗入疾",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInDestinyGong",
              "star": "Mars",
              "destinyGong": "JiE"
            },
            {
              "type": "starInDestinyGong",
              "star": "Luo",
              "destinyGong": "JiE"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_011_huo_ju_song_lu",
    "name": "火居宋鲁",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Mars",
          "gongs": [
            "Mao",
            "Xu"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_012_huo_tu_de_niu",
    "name": "火土得牛",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Mars",
              "gongs": [
                "Chou"
              ]
            },
            {
              "type": "starInGong",
              "star": "Saturn",
              "gongs": [
                "Chou"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_013_zhu_que_fan_shen",
    "name": "朱雀犯身",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInDestinyGong",
              "star": "Mars",
              "destinyGong": "Ming"
            },
            {
              "type": "starInDestinyGong",
              "star": "Luo",
              "destinyGong": "Ming"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_014_huo_zai_ba_gong",
    "name": "火在八宫",
    "variants": [
      {
        "conditions": {
          "type": "starInDestinyGong",
          "star": "Mars",
          "destinyGong": "JiE"
        }
      }
    ]
  },
  {
    "id": "huo_015_shui_huo_xiang_zhan",
    "name": "水火相战",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mars",
                "Mercury"
              ]
            },
            {
              "type": "starInDestinyGong",
              "star": "Mars",
              "destinyGong": "Ming"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_016_huo_lin_yan_di",
    "name": "火临燕地",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Mars",
          "gongs": [
            "Yin"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_017_huo_song_wei_rong",
    "name": "火宋为荣",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Mars",
          "gongs": [
            "Mao"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_018_huo_feng_tai_yi",
    "name": "火逢太乙",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Mars",
              "gongs": [
                "Mao"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Mars",
                "Bei"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_019_huo_wu_feng_mu",
    "name": "火五逢木",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "huo_020_ying_huo_zai_mao",
    "name": "荧惑在卯",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Mars",
          "gongs": [
            "Mao"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_021_huo_bei_shen_you",
    "name": "火孛申酉",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mars",
                "Bei"
              ]
            },
            {
              "type": "or",
              "conditions": [
                {
                  "type": "starInGong",
                  "star": "Mars",
                  "gongs": [
                    "Shen"
                  ]
                },
                {
                  "type": "starInGong",
                  "star": "Mars",
                  "gongs": [
                    "You"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_022_huo_ru_jin_xiang",
    "name": "火入金乡",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Mars",
          "gongs": [
            "Chen",
            "You"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_023_jin_huo_tong_cai",
    "name": "金火同财",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInDestinyGong",
              "star": "Mars",
              "destinyGong": "CaiBo"
            },
            {
              "type": "starInDestinyGong",
              "star": "Venus",
              "destinyGong": "CaiBo"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_024_shui_huo_ju_tian",
    "name": "水火居田",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInDestinyGong",
              "star": "Mars",
              "destinyGong": "TianZhai"
            },
            {
              "type": "starInDestinyGong",
              "star": "Mercury",
              "destinyGong": "TianZhai"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_025_huo_ming_chong_kui",
    "name": "火明冲魁",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Mars",
          "gongs": [
            "Mao",
            "Xu"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_026_huo_yao_lin_yang",
    "name": "火曜临阳",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Mars",
            "Sun"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_027_huo_jin_zi_wei",
    "name": "火金子位",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Mars",
              "gongs": [
                "Zi"
              ]
            },
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Zi"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_028_huo_luo_chan_ming",
    "name": "火罗躔命",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInDestinyGong",
              "star": "Mars",
              "destinyGong": "Ming"
            },
            {
              "type": "starInDestinyGong",
              "star": "Luo",
              "destinyGong": "Ming"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_029_huo_xing_nan_lv",
    "name": "火行南律",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Mars",
          "gongs": [
            "Si",
            "Wu",
            "Wei"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_030_huo_bei_tong_ming",
    "name": "火孛通明",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInDestinyGong",
              "star": "Mars",
              "destinyGong": "Ming"
            },
            {
              "type": "starInDestinyGong",
              "star": "Bei",
              "destinyGong": "Ming"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_031_huo_yao_dang_quan",
    "name": "火曜当权",
    "variants": [
      {
        "conditions": {
          "type": "starGuardLife",
          "star": "Mars"
        }
      }
    ]
  },
  {
    "id": "huo_032_huo_luo_lin_fu",
    "name": "火罗临父",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "huo_033_huo_bei_lin_kun",
    "name": "火孛临坤",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Mars",
              "gongs": [
                "Shen"
              ]
            },
            {
              "type": "starInGong",
              "star": "Bei",
              "gongs": [
                "Shen"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_034_jin_huo_zhan_chen_you",
    "name": "金火战辰酉",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mars",
                "Venus"
              ]
            },
            {
              "type": "or",
              "conditions": [
                {
                  "type": "starInGong",
                  "star": "Mars",
                  "gongs": [
                    "Chen"
                  ]
                },
                {
                  "type": "starInGong",
                  "star": "Mars",
                  "gongs": [
                    "You"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_035_huo_xing_tui_liu",
    "name": "火星退留",
    "variants": [
      {
        "conditions": {
          "type": "starWalkingState",
          "star": "Mars",
          "states": [
            "Stay",
            "Slow"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_036_huo_yue_zheng_guang",
    "name": "火月争光",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "isDayBirth",
              "isDay": false
            },
            {
              "type": "sameGong",
              "stars": [
                "Mars",
                "Moon"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_037_jin_de_huo_ming",
    "name": "金得火明",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "AUTUMN"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Venus",
                "Mars"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_038_xia_huo_jian_yue",
    "name": "夏火见月",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SUMMER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Mars",
                "Moon"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_039_xia_huo_feng_qi",
    "name": "夏火逢气",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SUMMER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Mars",
                "Jupiter"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_040_dong_tu_hui_huo",
    "name": "冻土会火",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Mars"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_041_huo_yue_tong_xiao",
    "name": "火月同宵",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Mars",
            "Moon"
          ]
        }
      },
      {},
      {},
      {}
    ]
  },
  {
    "id": "huo_042_ying_huo_ju_yuan",
    "name": "荧惑居垣",
    "variants": [
      {
        "conditions": {
          "type": "starGongStatus",
          "star": "Mars",
          "statuses": [
            "Yuan"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_043_huo_xing_sheng_dian",
    "name": "火星升殿",
    "variants": [
      {
        "conditions": {
          "type": "starInConstellation",
          "star": "Mars",
          "constellations": [
            "尾",
            "室",
            "觜",
            "翼"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_044_mu_huo_wen_ming",
    "name": "木火文明",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Mars"
              ]
            },
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER",
                "SPRING"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_045_huo_tu_gao_qiang",
    "name": "火土高强",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mars",
                "Saturn"
              ]
            },
            {
              "type": "not",
              "condition": {
                "type": "seasonIs",
                "seasons": [
                  "SUMMER"
                ]
              }
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_046_zhu_que_yu_fu",
    "name": "朱雀御符",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "monthIs",
              "months": [
                "Si",
                "Wu"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Mars",
                "Sun"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_047_huo_ju_shui_di",
    "name": "火居水地",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Mars",
          "gongs": [
            "Si",
            "Shen"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_048_huo_dao_jin_xiang",
    "name": "火到金乡",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Mars",
          "gongs": [
            "Chen",
            "You"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_049_shui_huo_tong_bu",
    "name": "水火同步",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "huo_050_huo_jin_jiao_zhan",
    "name": "火金交战",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "huo_051_huo_qi_zhi_quan",
    "name": "火气职权",
    "variants": [
      {
        "conditions": {
          "type": "starGongStatus",
          "star": "Mars",
          "statuses": [
            "Miao",
            "Wang"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_052_huo_jin_shi_yue",
    "name": "火金侍月",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starGongStatus",
              "star": "Mars",
              "statuses": [
                "Miao",
                "Wang"
              ]
            },
            {
              "type": "starGongStatus",
              "star": "Venus",
              "statuses": [
                "Miao",
                "Wang"
              ]
            },
            {
              "type": "isDayBirth",
              "isDay": false
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_053_chu_gan_ru_kun",
    "name": "出干入坤",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "huo_054_shui_huo_ji_ji",
    "name": "水火既济",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Mercury",
              "gongs": [
                "Zi"
              ]
            },
            {
              "type": "starInGong",
              "star": "Mars",
              "gongs": [
                "Wu"
              ]
            },
            {
              "type": "lifeGongAt",
              "gongs": [
                "Zi",
                "Wu"
              ]
            }
          ]
        }
      },
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Mercury",
            "Mars"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_055_feng_lei_gu_wu",
    "name": "风雷鼓舞",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Mercury",
              "gongs": [
                "Si"
              ]
            },
            {
              "type": "starInGong",
              "star": "Mars",
              "gongs": [
                "Mao"
              ]
            },
            {
              "type": "lifeGongAt",
              "gongs": [
                "Chen"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_056_huo_luo_fan_ri",
    "name": "火罗犯日",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "isDayBirth",
              "isDay": true
            },
            {
              "type": "sameGong",
              "stars": [
                "Mars",
                "Luo"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_057_huo_bei_gong_zhan",
    "name": "火孛共战",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Mars",
            "Bei"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_058_feng_lei_xiang_bo",
    "name": "风雷相薄",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "huo_059_shui_huo_xiang_she",
    "name": "水火相射",
    "variants": [
      {
        "conditions": {
          "type": "or",
          "conditions": [
            {
              "type": "and",
              "conditions": [
                {
                  "type": "starInGong",
                  "star": "Mercury",
                  "gongs": [
                    "Wu"
                  ]
                },
                {
                  "type": "starInGong",
                  "star": "Mars",
                  "gongs": [
                    "Zi"
                  ]
                }
              ]
            },
            {
              "type": "and",
              "conditions": [
                {
                  "type": "starInGong",
                  "star": "Jupiter",
                  "gongs": [
                    "Mao"
                  ]
                },
                {
                  "type": "starInGong",
                  "star": "Mars",
                  "gongs": [
                    "Xu"
                  ]
                }
              ]
            },
            {
              "type": "and",
              "conditions": [
                {
                  "type": "starInGong",
                  "star": "Mars",
                  "gongs": [
                    "Si"
                  ]
                },
                {
                  "type": "starInGong",
                  "star": "Mercury",
                  "gongs": [
                    "Shen"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_060_yu_hou_xiao_yue",
    "name": "玉猴啸月",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInConstellation",
              "star": "Mars",
              "constellations": [
                "觜"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Moon",
              "constellations": [
                "毕"
              ]
            },
            {
              "type": "isDayBirth",
              "isDay": false
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_061_hu_xiao_yuan_yin",
    "name": "虎啸猿吟",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInConstellation",
              "star": "Jupiter",
              "constellations": [
                "尾"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Mars",
              "constellations": [
                "觜"
              ]
            },
            {
              "type": "lifeGongAt",
              "gongs": [
                "Hai",
                "Si"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_062_huo_bei_qing_tian",
    "name": "火孛擎天",
    "variants": [
      {
        "conditions": {
          "type": "or",
          "conditions": [
            {
              "type": "and",
              "conditions": [
                {
                  "type": "starInConstellation",
                  "star": "Mars",
                  "constellations": [
                    "室"
                  ]
                },
                {
                  "type": "starInConstellation",
                  "star": "Bei",
                  "constellations": [
                    "壁"
                  ]
                }
              ]
            },
            {
              "type": "and",
              "conditions": [
                {
                  "type": "starInConstellation",
                  "star": "Mercury",
                  "constellations": [
                    "轸"
                  ]
                },
                {
                  "type": "starInConstellation",
                  "star": "Mars",
                  "constellations": [
                    "翼"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_063_ba_sha_chao_tian",
    "name": "八杀朝天",
    "variants": [
      {
        "conditions": {
          "type": "or",
          "conditions": [
            {
              "type": "and",
              "conditions": [
                {
                  "type": "lifeGongAt",
                  "gongs": [
                    "Xu"
                  ]
                },
                {
                  "type": "starInGong",
                  "star": "Mars",
                  "gongs": [
                    "Xu"
                  ]
                }
              ]
            },
            {
              "type": "and",
              "conditions": [
                {
                  "type": "lifeGongAt",
                  "gongs": [
                    "Wei"
                  ]
                },
                {
                  "type": "starInGong",
                  "star": "Saturn",
                  "gongs": [
                    "Wei"
                  ]
                }
              ]
            },
            {
              "type": "and",
              "conditions": [
                {
                  "type": "lifeGongAt",
                  "gongs": [
                    "Chen"
                  ]
                },
                {
                  "type": "starInGong",
                  "star": "Venus",
                  "gongs": [
                    "Chen"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_064_zhu_que_dang_quan",
    "name": "朱雀当权",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SUMMER"
              ]
            },
            {
              "type": "starInGong",
              "star": "Mars",
              "gongs": [
                "Si",
                "Wu"
              ]
            },
            {
              "type": "lifeGongAt",
              "gongs": [
                "Si",
                "Wu"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_065_li_kan_jiao_hui",
    "name": "离坎交会",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "isDayBirth",
              "isDay": false
            },
            {
              "type": "starGuardLife",
              "star": "Mars"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_066_zi_xing_fu_zheng",
    "name": "子行父政",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Sun",
              "gongs": [
                "Zi"
              ]
            },
            {
              "type": "starInGong",
              "star": "Mars",
              "gongs": [
                "Wu"
              ]
            },
            {
              "type": "lifeGongAt",
              "gongs": [
                "Wu"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_067_huo_shui_wei_ji",
    "name": "火水未济",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Mars",
            "Mercury"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_069_shui_huo_xiang_xing",
    "name": "水火相刑",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "lifeGongAt",
              "gongs": [
                "Mao"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Mars",
              "constellations": [
                "房"
              ]
            },
            {
              "type": "seasonIs",
              "seasons": [
                "SUMMER"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_070_nv_huo_wei_fu",
    "name": "女火为夫",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "huo_071_huo_luo_nong_xue",
    "name": "火罗脓血",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Mars",
            "Luo"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_072_huo_ming_tian_shi",
    "name": "火明天市",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Mars",
          "gongs": [
            "Mao"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_073_huo_hao_wen_chang",
    "name": "火号文昌",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Mars",
          "gongs": [
            "Wei"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_074_huo_gui_kun_di",
    "name": "火归坤地",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Mars",
          "gongs": [
            "Shen"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_075_huo_ju_lou_su",
    "name": "火居娄宿",
    "variants": [
      {
        "conditions": {
          "type": "starInConstellation",
          "star": "Mars",
          "constellations": [
            "娄"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_076_jin_huo_tong_zhou",
    "name": "金火同周",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Wu"
              ]
            },
            {
              "type": "starInGong",
              "star": "Mars",
              "gongs": [
                "Wu"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_077_yi_yang_lai_fu",
    "name": "一阳来复",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "isDayBirth",
              "isDay": false
            },
            {
              "type": "starInGong",
              "star": "Mars",
              "gongs": [
                "Zi"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_078_huo_luo_feng_sha",
    "name": "火罗逢煞",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Mars",
            "Luo"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_079_jue_huo_da_ming",
    "name": "爝火大明",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInKongWang",
              "star": "Mars"
            },
            {
              "type": "isDayBirth",
              "isDay": false
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_080_huo_de_mu_ji",
    "name": "火得木济",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SPRING"
              ]
            },
            {
              "type": "isDayBirth",
              "isDay": false
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_081_tao_hua_gun_lang",
    "name": "桃花滚浪",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Mars",
              "gongs": [
                "Zi",
                "Hai"
              ]
            },
            {
              "type": "starInGong",
              "star": "Mercury",
              "gongs": [
                "Wu",
                "Si"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_082_zi_lai_jiu_mu",
    "name": "子来救母",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mars",
                "Mercury"
              ]
            },
            {
              "type": "starInGong",
              "star": "Saturn",
              "gongs": [
                "Zi",
                "Hai",
                "Wu",
                "Si"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_083_wan_wu_cui_ku",
    "name": "万物摧枯",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mars",
                "Luo"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Mars",
                "Sun"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_084_yi_bei_ji_huo",
    "name": "一孛济火",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "huo_085_gao_miao_de_yu",
    "name": "稿苗得雨",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "huo_086_jiu_yu_feng_qing",
    "name": "久雨逢晴",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "huo_087_mu_qi_fu_huo",
    "name": "木气扶火",
    "variants": [
      {
        "conditions": {
          "type": "seasonIs",
          "seasons": [
            "WINTER"
          ]
        }
      }
    ]
  },
  {
    "id": "huo_088_ye_huo_guan_ri",
    "name": "夜火贯日",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "isDayBirth",
              "isDay": false
            },
            {
              "type": "sameGong",
              "stars": [
                "Mars",
                "Sun"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_089_huo_qi_mai_xu",
    "name": "火气脉虚",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Mars",
                "Mercury"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "huo_090_jing_shen_yun_zhuan",
    "name": "精神运转",
    "variants": [
      {
        "conditions": {
          "type": "seasonIs",
          "seasons": [
            "WINTER"
          ]
        }
      }
    ]
  }
]');
INSERT INTO ge_ju_rules_document ("file_name", "payload_json") VALUES ('jin_xing_ge_ju_rules.json', '[
  {
    "id": "jin_001_jun_chen_qing_hui",
    "name": "君臣庆会",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Venus",
                "Mercury"
              ]
            },
            {
              "type": "starGuardLife",
              "star": "Sun"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_002_shan_xiao_cheng_bao",
    "name": "山啸呈宝",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Venus"
              ]
            },
            {
              "type": "starInKongWang",
              "star": "Saturn"
            },
            {
              "type": "starInKongWang",
              "star": "Venus"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_003_shi_li_jian_feng",
    "name": "石砺剑锋",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "jin_004_zhu_cang_yuan_hai",
    "name": "珠藏渊海",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "jin_005_hu_ju_long_pan",
    "name": "虎踞龙蟠",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starGuardLife",
              "star": "Venus"
            },
            {
              "type": "starGuardLife",
              "star": "Jupiter"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_006_yun_jian_yue_zhuo",
    "name": "云间鸑鷟",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Wu"
              ]
            },
            {
              "type": "starInGong",
              "star": "Qi",
              "gongs": [
                "Wu"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_007_tian_shang_qi_lin",
    "name": "天上麒麟",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Chen"
              ]
            },
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Chen"
              ]
            },
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Mao"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_008_jin_guan_ding_cui",
    "name": "金冠顶翠",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Venus",
            "Jupiter"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_009_yu_chu_kun_gang",
    "name": "玉出昆冈",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Venus",
                "Saturn"
              ]
            },
            {
              "type": "starInKongWang",
              "star": "Venus"
            },
            {
              "type": "starInKongWang",
              "star": "Saturn"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_010_luan_yu_nan_xing",
    "name": "鸾轝南幸",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInConstellation",
              "star": "Venus",
              "constellations": [
                "星",
                "房"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Jupiter",
              "constellations": [
                "星",
                "房"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_011_feng_jia_bei_gui",
    "name": "凤驾北归",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "jin_012_yi_gan_jiu_shi",
    "name": "移干就湿",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "jin_013_jin_wu_cheng_rui",
    "name": "金乌呈瑞",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "jin_014_feng_yu_zuo_lin",
    "name": "风雨作霖",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInConstellation",
              "star": "Venus",
              "constellations": [
                "毕",
                "箕"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Mercury",
              "constellations": [
                "毕",
                "箕"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Sun",
              "constellations": [
                "毕",
                "箕"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_015_lao_bang_han_zhu",
    "name": "老蚌含珠",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Venus"
              ]
            },
            {
              "type": "starInGong",
              "star": "Saturn",
              "gongs": [
                "Hai",
                "Zi",
                "Chen",
                "Si"
              ]
            },
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Hai",
                "Zi",
                "Chen",
                "Si"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_016_su_yue_liu_tian",
    "name": "素月流天",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Moon",
            "Venus"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_017_jin_shui_bei_chi",
    "name": "金水背驰",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "jin_018_jin_shui_fen_ming",
    "name": "金水分明",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "jin_019_jin_shui_hui_yuan",
    "name": "金水会垣",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Venus",
            "Mercury"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_020_jin_han_shui_leng",
    "name": "金寒水冷",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Venus",
                "Mercury"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_021_jin_shui_wei_shi",
    "name": "金水为仕",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInConstellation",
              "star": "Venus",
              "constellations": [
                "奎",
                "壁"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Mercury",
              "constellations": [
                "奎",
                "壁"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_022_jin_shui_hu_yuan",
    "name": "金水互垣",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Mercury",
              "gongs": [
                "Chen",
                "You"
              ]
            },
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Hai",
                "Zi"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_023_jin_bei_qi_ma",
    "name": "金孛骑马",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Venus",
            "Bei"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_024_jin_huo_yi_yuan",
    "name": "金火易垣",
    "variants": [
      {
        "conditions": {
          "type": "or",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Mars",
              "gongs": [
                "Chen",
                "You"
              ]
            },
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Yin",
                "Mao",
                "Si",
                "Wu"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_025_jin_shui_gong_cheng",
    "name": "金水功成",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starGuardLife",
              "star": "Venus"
            },
            {
              "type": "starGuardLife",
              "star": "Mercury"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_026_jin_bei_lin_shen",
    "name": "金孛临身",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starGuardLife",
              "star": "Venus"
            },
            {
              "type": "starGuardLife",
              "star": "Bei"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_027_qing_ji_huo_yuan",
    "name": "庆基获源",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Venus",
          "gongs": [
            "Chen"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_028_jin_shui_hui_she",
    "name": "金水会蛇",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Si"
              ]
            },
            {
              "type": "starInGong",
              "star": "Mercury",
              "gongs": [
                "Si"
              ]
            }
          ]
        }
      },
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Venus",
            "Mercury"
          ],
          "gong": "Spouse"
        }
      },
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Venus",
            "Mercury"
          ],
          "gong": "Spouse"
        }
      },
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Venus",
            "Mercury"
          ],
          "gong": "Spouse"
        }
      }
    ]
  },
  {
    "id": "jin_029_jin_ju_wei_fen",
    "name": "金居卫分",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Venus",
          "gongs": [
            "Hai"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_030_jin_yu_ying_huo",
    "name": "金遇荧惑",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Hai"
              ]
            },
            {
              "type": "starInGong",
              "star": "Mars",
              "gongs": [
                "Hai"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_031_jin_ju_kang_wei",
    "name": "金居亢位",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Venus",
          "gongs": [
            "Chen"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_032_jin_mu_zhao_shu_niu",
    "name": "金木照于鼠牛",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Zi",
                "Chou"
              ]
            },
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Zi",
                "Chou"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_033_jin_cheng_huo_wei",
    "name": "金乘火位",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Venus",
          "gongs": [
            "Mao",
            "Xu"
          ]
        }
      },
      {
        "conditions": {
          "type": "starInGong",
          "star": "Venus",
          "gongs": [
            "Mao",
            "Xu"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_034_mu_jin_hui_tian",
    "name": "木金会田",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Jupiter",
            "Venus"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_035_san_ri_feng_jin",
    "name": "三日逢金",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Moon",
            "Venus"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_036_tai_bai_shuang_tai",
    "name": "太白双胎",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Venus",
          "gongs": [
            "Hai",
            "Si"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_037_huo_jin_zi_wei",
    "name": "火金子位",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Mars",
              "gongs": [
                "Zi"
              ]
            },
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Zi"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_038_jin_shui_wen_zhi",
    "name": "金水文智",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starGuardLife",
              "star": "Venus"
            },
            {
              "type": "starGuardLife",
              "star": "Mercury"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_039_gang_rou_xiang_ji",
    "name": "刚柔相济",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Venus",
            "Jupiter"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_040_jin_xing_shou_ming",
    "name": "金星守命",
    "variants": [
      {
        "conditions": {
          "type": "starGuardLife",
          "star": "Venus"
        }
      }
    ]
  },
  {
    "id": "jin_041_jin_huo_zhan_chen_you",
    "name": "金火战辰酉",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Chen",
                "You"
              ]
            },
            {
              "type": "starInGong",
              "star": "Mars",
              "gongs": [
                "Chen",
                "You"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_042_tu_hui_jin_mai",
    "name": "土晦金埋",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "AUTUMN"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Venus",
                "Saturn"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_043_chun_jin_jian_yue",
    "name": "春金见月",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SPRING"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Venus",
                "Moon"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_044_dong_yue_yu_jin",
    "name": "冬月遇金",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Moon",
                "Venus"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_045_jin_de_huo_ming",
    "name": "金得火明",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "AUTUMN"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Venus",
                "Mars"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_046_xia_jin_xiao_shuo",
    "name": "夏金销铄",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SUMMER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Venus",
                "Sun"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_047_shui_dong_jin_han",
    "name": "水冻金寒",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Venus",
                "Mercury"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_048_tai_bai_ju_yuan",
    "name": "太白居垣",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Venus",
          "gongs": [
            "Chen",
            "You"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_049_jin_xing_sheng_dian",
    "name": "金星升殿",
    "variants": [
      {
        "conditions": {
          "type": "starInConstellation",
          "star": "Venus",
          "constellations": [
            "亢",
            "牛",
            "娄",
            "鬼"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_050_jin_zhu_yue_hua",
    "name": "金助月华",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Venus",
            "Moon"
          ]
        }
      },
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Venus",
                "Moon"
              ]
            },
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "You"
              ]
            }
          ]
        }
      },
      {},
      {},
      {}
    ]
  },
  {
    "id": "jin_051_tu_jin_zao_shou",
    "name": "土金遭受",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Venus",
                "Saturn"
              ]
            },
            {
              "type": "not",
              "condition": {
                "type": "seasonIs",
                "seasons": [
                  "AUTUMN",
                  "WINTER"
                ]
              }
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_052_jin_shui_xiang_han",
    "name": "金水相涵",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Venus",
                "Mercury"
              ]
            },
            {
              "type": "not",
              "condition": {
                "type": "seasonIs",
                "seasons": [
                  "WINTER"
                ]
              }
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_053_bai_hu_cong_jia",
    "name": "白虎从驾",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "jin_055_jin_zai_mu_gong",
    "name": "金在木宫",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Venus",
          "gongs": [
            "Yin",
            "Hai"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_056_jin_mu_gong_chan",
    "name": "金木共躔",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Venus",
            "Jupiter"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_057_huo_jin_jiao_zhan",
    "name": "火金交战",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Venus",
            "Mars"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_058_jin_ji_tong_yuan",
    "name": "金计同垣",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Venus",
                "Ji"
              ]
            },
            {
              "type": "starGongStatus",
              "star": "Venus",
              "statuses": [
                "Yuan",
                "Miao"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_059_jin_shui_cong_yang",
    "name": "金水从阳",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Venus",
                "Mercury"
              ]
            },
            {
              "type": "starGongStatus",
              "star": "Venus",
              "statuses": [
                "Yuan",
                "Dian"
              ]
            },
            {
              "type": "isDayBirth",
              "isDay": true
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_060_huo_jin_shi_yue",
    "name": "火金侍月",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Venus",
                "Mars",
                "Moon"
              ]
            },
            {
              "type": "starGongStatus",
              "star": "Venus",
              "statuses": [
                "Yuan",
                "Miao"
              ]
            },
            {
              "type": "isDayBirth",
              "isDay": false
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_061_san_tai_he_ge",
    "name": "三台合格",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Sun",
                "Venus",
                "Mercury"
              ]
            },
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Wu",
                "Si",
                "Mao"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_062_chu_gan_ru_kun",
    "name": "出干入坤",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "jin_063_shan_ze_tong_qi",
    "name": "山泽通气",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Yin"
              ]
            },
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "You"
              ]
            },
            {
              "type": "lifeGongAt",
              "gongs": [
                "You",
                "Yin"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_064_jin_luo_tong_ke",
    "name": "金罗同克",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Venus",
            "Luo"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_065_qian_kun_pi_se",
    "name": "乾坤否塞",
    "variants": [
      {
        "conditions": {
          "type": "or",
          "conditions": [
            {
              "type": "and",
              "conditions": [
                {
                  "type": "lifeGongAt",
                  "gongs": [
                    "Hai"
                  ]
                },
                {
                  "type": "sameGong",
                  "stars": [
                    "Venus",
                    "Luo"
                  ]
                }
              ]
            },
            {
              "type": "and",
              "conditions": [
                {
                  "type": "lifeGongAt",
                  "gongs": [
                    "Shen"
                  ]
                },
                {
                  "type": "sameGong",
                  "stars": [
                    "Saturn",
                    "Ji"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_066_shan_ze_chen_mai",
    "name": "山泽沉埋",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "jin_067_long_yue_tian_chi",
    "name": "龙跃天池",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInConstellation",
              "star": "Venus",
              "constellations": [
                "亢"
              ]
            },
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Hai"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_068_cang_long_ru_jing",
    "name": "苍龙入井",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "jin_069_jin_ying_su_liu",
    "name": "金莺宿柳",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInConstellation",
              "star": "Venus",
              "constellations": [
                "柳"
              ]
            },
            {
              "type": "starGuardLife",
              "star": "Venus"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_070_ba_sha_chao_tian",
    "name": "八杀朝天",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "or",
              "conditions": [
                {
                  "type": "and",
                  "conditions": [
                    {
                      "type": "lifeGongAt",
                      "gongs": [
                        "Chen"
                      ]
                    },
                    {
                      "type": "starGuardLife",
                      "star": "Venus"
                    }
                  ]
                },
                {
                  "type": "and",
                  "conditions": [
                    {
                      "type": "lifeGongAt",
                      "gongs": [
                        "Xu"
                      ]
                    },
                    {
                      "type": "starGuardLife",
                      "star": "Mars"
                    }
                  ]
                },
                {
                  "type": "and",
                  "conditions": [
                    {
                      "type": "lifeGongAt",
                      "gongs": [
                        "Wei"
                      ]
                    },
                    {
                      "type": "starGuardLife",
                      "star": "Saturn"
                    }
                  ]
                }
              ]
            },
            {
              "type": "isDayBirth",
              "isDay": false
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_071_chang_geng_ru_ming",
    "name": "长庚入命",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Venus",
                "Moon"
              ]
            },
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "You"
              ]
            },
            {
              "type": "isDayBirth",
              "isDay": false
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_072_bai_hu_dang_quan",
    "name": "白虎当权",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "AUTUMN"
              ]
            },
            {
              "type": "lifeGongAt",
              "gongs": [
                "Shen",
                "You"
              ]
            },
            {
              "type": "starGuardLife",
              "star": "Venus"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_073_hu_ju_long_pan",
    "name": "虎踞龙盘",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "or",
              "conditions": [
                {
                  "type": "sameGong",
                  "stars": [
                    "Venus",
                    "Jupiter"
                  ]
                },
                {
                  "type": "and",
                  "conditions": [
                    {
                      "type": "lifeGongAt",
                      "gongs": [
                        "Zi",
                        "Wu"
                      ]
                    },
                    {
                      "type": "starInGong",
                      "star": "Venus",
                      "gongs": [
                        "You"
                      ]
                    },
                    {
                      "type": "starInGong",
                      "star": "Jupiter",
                      "gongs": [
                        "Mao"
                      ]
                    }
                  ]
                }
              ]
            },
            {
              "type": "isDayBirth",
              "isDay": false
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_074_yue_hua_jin_que",
    "name": "月华金阙",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Venus",
                "Moon"
              ]
            },
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Hai",
                "Chen"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_075_ri_hua_jin_que",
    "name": "日华金阙",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Venus",
                "Sun"
              ]
            },
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Hai",
                "Chen"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_076_jin_ju_gan_wei",
    "name": "金居干位",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Hai"
              ]
            },
            {
              "type": "not",
              "condition": {
                "type": "or",
                "conditions": [
                  {
                    "type": "starInGong",
                    "star": "Mars",
                    "gongs": [
                      "Hai"
                    ]
                  },
                  {
                    "type": "starInGong",
                    "star": "Ji",
                    "gongs": [
                      "Hai"
                    ]
                  },
                  {
                    "type": "starInGong",
                    "star": "Luo",
                    "gongs": [
                      "Hai"
                    ]
                  },
                  {
                    "type": "starInGong",
                    "star": "Bei",
                    "gongs": [
                      "Hai"
                    ]
                  }
                ]
              }
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_077_jin_qi_ren_ma",
    "name": "金骑人马",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "lifeGongAt",
              "gongs": [
                "Yin"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Venus",
              "constellations": [
                "尾"
              ]
            },
            {
              "type": "starGuardLife",
              "star": "Venus"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_078_jin_shen_chi_ren",
    "name": "金神持刃",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "lifeGongAt",
              "gongs": [
                "Chen"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Venus",
              "constellations": [
                "亢"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_079_jin_xing_ru_dou",
    "name": "金星入斗",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "lifeGongAt",
              "gongs": [
                "You"
              ]
            },
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Chou"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Venus",
              "constellations": [
                "斗"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_080_jin_mu_hai_shi",
    "name": "金木亥室",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Hai"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Jupiter",
              "constellations": [
                "室"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_081_jin_shui_xing_qiao",
    "name": "金水性巧",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Venus",
            "Mercury"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_082_jin_bei_yin_lao",
    "name": "金孛淫痨",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Venus",
            "Bei"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_083_jin_shui_bei_xian",
    "name": "金水孛咸",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Venus",
            "Mercury",
            "Bei"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_084_jin_shui_bei_mu",
    "name": "金水孛沐",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Venus",
            "Mercury",
            "Bei"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_085_jin_xiao_tian_xie",
    "name": "金销天蝎",
    "variants": [
      {
        "conditions": {
          "type": "starInConstellation",
          "star": "Venus",
          "constellations": [
            "房"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_086_jin_xiao_bai_yang",
    "name": "金销白羊",
    "variants": [
      {
        "conditions": {
          "type": "starInConstellation",
          "star": "Venus",
          "constellations": [
            "奎"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_087_chang_geng_chao_dou",
    "name": "长庚朝斗",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Chou"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Venus",
              "constellations": [
                "斗"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_088_jin_mu_feng_long",
    "name": "金木逢龙",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Chen"
              ]
            },
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Chen"
              ]
            }
          ]
        }
      },
      {},
      {},
      {}
    ]
  },
  {
    "id": "jin_089_shui_run_jin_ming",
    "name": "水润金明",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Chen"
              ]
            },
            {
              "type": "starInGong",
              "star": "Mercury",
              "gongs": [
                "Chen"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_090_jin_hao_tai_chang",
    "name": "金号太常",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Venus",
          "gongs": [
            "Chen"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_091_jin_chan_gui_su",
    "name": "金躔鬼宿",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Wei"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Venus",
              "constellations": [
                "鬼"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_092_jin_xing_zhu_yue",
    "name": "金星助月",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Venus",
            "Moon"
          ]
        }
      }
    ]
  },
  {
    "id": "jin_094_jin_zhang_ren_feng",
    "name": "金掌刃锋",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "jin_095_lan_fu_xiu_zhen",
    "name": "烂斧绣针",
    "variants": [
      {
        "conditions": {
          "type": "starInKongWang",
          "star": "Venus"
        }
      }
    ]
  },
  {
    "id": "jin_096_lian_jin_cheng_qi",
    "name": "炼金成器",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SPRING"
              ]
            },
            {
              "type": "or",
              "conditions": [
                {
                  "type": "sameGong",
                  "stars": [
                    "Venus",
                    "Mars"
                  ]
                },
                {
                  "type": "sameGong",
                  "stars": [
                    "Venus",
                    "Luo"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_097_chun_jin_ji_shui",
    "name": "春金忌水",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SPRING"
              ]
            },
            {
              "type": "or",
              "conditions": [
                {
                  "type": "sameGong",
                  "stars": [
                    "Venus",
                    "Mercury"
                  ]
                },
                {
                  "type": "sameGong",
                  "stars": [
                    "Venus",
                    "Bei"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_098_shuo_shi_feng_yuan",
    "name": "烁石逢源",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SUMMER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Venus",
                "Mercury"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_099_xia_jin_feng_huo",
    "name": "夏金逢火",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SUMMER"
              ]
            },
            {
              "type": "or",
              "conditions": [
                {
                  "type": "sameGong",
                  "stars": [
                    "Venus",
                    "Mars"
                  ]
                },
                {
                  "type": "sameGong",
                  "stars": [
                    "Venus",
                    "Luo"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_100_jin_bai_shui_qing",
    "name": "金白水清",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "AUTUMN"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Venus",
                "Mercury"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "jin_101_dong_jin_xi_nuan",
    "name": "冬金喜暖",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "or",
              "conditions": [
                {
                  "type": "and",
                  "conditions": [
                    {
                      "type": "isDayBirth",
                      "isDay": true
                    },
                    {
                      "type": "sameGong",
                      "stars": [
                        "Venus",
                        "Sun"
                      ]
                    }
                  ]
                },
                {
                  "type": "and",
                  "conditions": [
                    {
                      "type": "isDayBirth",
                      "isDay": false
                    },
                    {
                      "type": "or",
                      "conditions": [
                        {
                          "type": "sameGong",
                          "stars": [
                            "Venus",
                            "Mars"
                          ]
                        },
                        {
                          "type": "sameGong",
                          "stars": [
                            "Venus",
                            "Luo"
                          ]
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  }
]');
INSERT INTO ge_ju_rules_document ("file_name", "payload_json") VALUES ('ling_tai_ge_ju_rules.json', '[
  {
    "id": "lingtaige_001_he_bi_lian_zhu",
    "name": "合璧连珠",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sunMoonHarmony"
            },
            {
              "type": "fivePlanetsAlignment"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "lingtaige_002_ri_yue_he_bi",
    "name": "日月合璧",
    "variants": [
      {}
    ]
  },
  {
    "id": "lingtaige_003_wu_xing_lian_zhu",
    "name": "五星连珠",
    "variants": [
      {}
    ]
  },
  {
    "id": "lingtaige_004_dou_niu_xiu_qi",
    "name": "斗牛秀气",
    "variants": [
      {}
    ]
  },
  {
    "id": "lingtaige_005_wen_zhang_mi_fu",
    "name": "文章秘府",
    "variants": [
      {}
    ]
  },
  {
    "id": "lingtaige_006_wu_xing_chao_dou",
    "name": "五星朝斗",
    "variants": [
      {}
    ]
  },
  {
    "id": "lingtaige_007_bo_yu_dong_jing",
    "name": "孛于东井",
    "variants": [
      {}
    ]
  },
  {
    "id": "lingtaige_008_shou_xie_long_jiao",
    "name": "首携龙角",
    "variants": [
      {}
    ]
  },
  {
    "id": "lingtaige_009_ji_ju_long_wei",
    "name": "计居龙尾",
    "variants": [
      {}
    ]
  },
  {
    "id": "lingtaige_010_yin_yang_lei_ju",
    "name": "阴阳类聚",
    "variants": [
      {}
    ]
  }
]');
INSERT INTO ge_ju_rules_document ("file_name", "payload_json") VALUES ('mu_xing_ge_ju_rules.json', '[
  {
    "id": "mu_001_ri_bian_hong_xing",
    "name": "日边红杏",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Sun"
              ]
            },
            {
              "type": "or",
              "conditions": [
                {
                  "type": "starIsSiZhu",
                  "star": "Jupiter",
                  "roles": [
                    "lifeGongMaster",
                    "lifeConstellationMaster"
                  ]
                },
                {
                  "type": "starFourType",
                  "star": "Jupiter",
                  "target": "Jupiter",
                  "types": [
                    "En"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_002_xue_ya_han_mei",
    "name": "雪压寒梅",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Mercury"
              ]
            },
            {
              "type": "isDayBirth",
              "isDay": false
            },
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_003_qi_cha_han_mei",
    "name": "齐插寒梅",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "lifeGongAt",
              "gongs": [
                "Zi"
              ]
            },
            {
              "type": "starGuardLife",
              "star": "Jupiter"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_004_xiang_yang_hua_mu",
    "name": "向阳花木",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Sun"
              ]
            },
            {
              "type": "isDayBirth",
              "isDay": true
            },
            {
              "type": "seasonIs",
              "seasons": [
                "SPRING",
                "SUMMER"
              ]
            },
            {
              "type": "not",
              "condition": {
                "type": "starWalkingState",
                "star": "Jupiter",
                "states": [
                  "Retrograde"
                ]
              }
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_005_zhao_shui_mei_hua",
    "name": "照水梅花",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Si",
                "Shen"
              ]
            },
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "isDayBirth",
              "isDay": true
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_006_chun_sheng_yang_liu",
    "name": "春生杨柳",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SPRING"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Jupiter",
              "constellations": [
                "箕"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_007_qiu_ri_wu_tong",
    "name": "秋日梧桐",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "AUTUMN"
              ]
            },
            {
              "type": "starWithShenSha",
              "star": "Jupiter",
              "shenShaNames": [
                "孤辰",
                "寡宿",
                "羊刃"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_008_yue_zhong_xian_gui",
    "name": "月中仙桂",
    "variants": [
      {
        "conditions": {
          "type": "or",
          "conditions": [
            {
              "type": "starInConstellation",
              "star": "Jupiter",
              "constellations": [
                "心",
                "张",
                "危",
                "毕"
              ]
            },
            {
              "type": "and",
              "conditions": [
                {
                  "type": "seasonIs",
                  "seasons": [
                    "AUTUMN"
                  ]
                },
                {
                  "type": "sameGong",
                  "stars": [
                    "Jupiter",
                    "Moon"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_009_ri_shai_hua_zhi",
    "name": "日晒花枝",
    "variants": [
      {
        "conditions": {
          "type": "or",
          "conditions": [
            {
              "type": "starInConstellation",
              "star": "Jupiter",
              "constellations": [
                "星",
                "虚",
                "房",
                "昴"
              ]
            },
            {
              "type": "and",
              "conditions": [
                {
                  "type": "seasonIs",
                  "seasons": [
                    "SPRING"
                  ]
                },
                {
                  "type": "sameGong",
                  "stars": [
                    "Jupiter",
                    "Sun"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_010_mei_shao_heng_yue",
    "name": "梅梢横月",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Moon"
              ]
            },
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Zi"
              ]
            },
            {
              "type": "seasonIs",
              "seasons": [
                "AUTUMN",
                "WINTER"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_011_liu_xu_sui_feng",
    "name": "柳絮随风",
    "variants": [
      {
        "conditions": {
          "type": "or",
          "conditions": [
            {
              "type": "starInConstellation",
              "star": "Jupiter",
              "constellations": [
                "箕"
              ]
            },
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Si"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_012_yu_zhou_hua_can",
    "name": "雨骤花残",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SPRING"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Jupiter",
              "constellations": [
                "毕"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_013_feng_yao_ye_luo",
    "name": "风摇叶落",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "AUTUMN"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Jupiter",
              "constellations": [
                "箕"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_014_an_che_pu_lun",
    "name": "安车蒲轮",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "mu_015_mei_ying_heng_chuang",
    "name": "梅影横窗",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameConstellation",
              "stars": [
                "Jupiter",
                "Moon"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Jupiter",
              "constellations": [
                "壁"
              ]
            },
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_016_tao_hua_lang_nuan",
    "name": "桃花浪暖",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Mercury"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Jupiter",
              "constellations": [
                "奎"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_017_hua_li_ting_can",
    "name": "花里停骖",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Moon"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Jupiter",
              "constellations": [
                "张",
                "心",
                "危",
                "毕"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_018_dan_gui_piao_xiang",
    "name": "丹桂飘香",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "AUTUMN"
              ]
            },
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Si"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_019_li_hua_dai_yu",
    "name": "梨花带雨",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SPRING"
              ]
            },
            {
              "type": "or",
              "conditions": [
                {
                  "type": "starInGong",
                  "star": "Jupiter",
                  "gongs": [
                    "You",
                    "Shen"
                  ]
                },
                {
                  "type": "starInConstellation",
                  "star": "Jupiter",
                  "constellations": [
                    "毕"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_020_nan_zhi_xiang_nuan",
    "name": "南枝向暖",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Wu"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_021_san_tai_he_ge",
    "name": "三台合格",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Wu"
              ]
            },
            {
              "type": "seasonIs",
              "seasons": [
                "SPRING",
                "SUMMER"
              ]
            },
            {
              "type": "or",
              "conditions": [
                {
                  "type": "starInGong",
                  "star": "Venus",
                  "gongs": [
                    "Si",
                    "Wei"
                  ]
                },
                {
                  "type": "starInGong",
                  "star": "Mercury",
                  "gongs": [
                    "Si",
                    "Wei"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_022_mu_qi_fu_shen",
    "name": "木气扶身",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Jupiter",
            "Qi",
            "Moon"
          ]
        }
      }
    ]
  },
  {
    "id": "mu_023_mu_qi_jia_ming",
    "name": "木气夹命",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "mu_024_mu_qi_guan_ming",
    "name": "木气贯命",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starGuardLife",
              "star": "Jupiter"
            },
            {
              "type": "starGuardLife",
              "star": "Qi"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_025_mu_xing_zhao_lin",
    "name": "木星照临",
    "variants": [
      {
        "conditions": {
          "type": "starGuardLife",
          "star": "Jupiter"
        }
      }
    ]
  },
  {
    "id": "mu_026_mu_lin_zhen_yuan",
    "name": "木临真垣",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Jupiter",
          "gongs": [
            "Yin",
            "Hai"
          ]
        }
      }
    ]
  },
  {
    "id": "mu_027_sun_ji_ji_ren",
    "name": "损己济人",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Jupiter",
            "Qi"
          ]
        }
      }
    ]
  },
  {
    "id": "mu_028_mu_ru_qin_zhou",
    "name": "木入秦州",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Jupiter",
          "gongs": [
            "Wei"
          ]
        }
      }
    ]
  },
  {
    "id": "mu_029_sui_ju_xie_gui",
    "name": "岁居蟹鬼",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Jupiter",
          "gongs": [
            "Wei"
          ]
        }
      }
    ]
  },
  {
    "id": "mu_030_shui_mu_chong_lin",
    "name": "水木重临",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Jupiter",
            "Mercury"
          ]
        }
      }
    ]
  },
  {
    "id": "mu_031_mu_xian_kan_wei",
    "name": "木嫌坎位",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Jupiter",
          "gongs": [
            "Zi"
          ]
        }
      }
    ]
  },
  {
    "id": "mu_032_mu_da_bao_ping",
    "name": "木打宝瓶",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Jupiter",
          "gongs": [
            "Zi"
          ]
        }
      }
    ]
  },
  {
    "id": "mu_033_mu_luo_dong_jing",
    "name": "木罗东井",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Luo"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Jupiter",
              "constellations": [
                "井"
              ]
            },
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Wei"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_034_mu_zheng_dong_fang",
    "name": "木正东方",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Jupiter",
          "gongs": [
            "Mao"
          ]
        }
      }
    ]
  },
  {
    "id": "mu_035_mu_yang_zhao_qian",
    "name": "木阳照迁",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Sun"
              ]
            },
            {
              "type": "starInDestinyGong",
              "star": "Jupiter",
              "destinyGong": "QianYi"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_036_mu_de_lin_yuan",
    "name": "木德临垣",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Jupiter",
          "gongs": [
            "Yin",
            "Hai"
          ]
        }
      }
    ]
  },
  {
    "id": "mu_037_nv_chan_mu_xian",
    "name": "女缠木限",
    "variants": [
      {
        "conditions": {
          "type": "xianMeetStar",
          "stars": [
            "Jupiter"
          ]
        }
      }
    ]
  },
  {
    "id": "mu_038_tu_mu_xi_zheng",
    "name": "土木息争",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Saturn"
              ]
            },
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Yin"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_039_mu_bu_nan_ben",
    "name": "木不南奔",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Jupiter",
          "gongs": [
            "Wu"
          ]
        }
      }
    ]
  },
  {
    "id": "mu_040_mu_luo_hui_she",
    "name": "木罗会舍",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Luo"
              ]
            },
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Yin"
              ]
            }
          ]
        }
      },
      {},
      {},
      {}
    ]
  },
  {
    "id": "mu_041_shui_fan_mu_piao",
    "name": "水泛木漂",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Venus"
              ]
            },
            {
              "type": "seasonIs",
              "seasons": [
                "SUMMER"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_042_han_mu_xiang_yang",
    "name": "寒木向阳",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Sun"
              ]
            },
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER",
                "SPRING"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_043_qiu_shui_nan_zi",
    "name": "秋水难滋",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Mercury"
              ]
            },
            {
              "type": "seasonIs",
              "seasons": [
                "AUTUMN"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_044_mu_tu_xiang_an",
    "name": "木土相安",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "lifeGongAt",
              "gongs": [
                "Zi"
              ]
            },
            {
              "type": "starInGong",
              "star": "Saturn",
              "gongs": [
                "Zi"
              ]
            },
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Wu"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_045_lin_quan_gao_zhi",
    "name": "林泉高致",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Moon",
            "Jupiter",
            "Qi"
          ]
        }
      }
    ]
  },
  {
    "id": "mu_046_mu_qi_fan_yue",
    "name": "木气犯月",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "lifeGongAt",
              "gongs": [
                "Wu"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Qi",
                "Moon"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_047_yi_xing_ban_yue",
    "name": "一星伴月",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "lifeGongAt",
              "gongs": [
                "Wei"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Moon"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Jupiter",
              "constellations": [
                "井"
              ]
            }
          ]
        }
      },
      {},
      {},
      {}
    ]
  },
  {
    "id": "mu_048_tian_di_kai_ming",
    "name": "天地开明",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Mercury",
              "gongs": [
                "Shen"
              ]
            },
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Hai"
              ]
            },
            {
              "type": "lifeGongAt",
              "gongs": [
                "Shen",
                "Hai"
              ]
            },
            {
              "type": "and",
              "conditions": [
                {
                  "type": "starInGong",
                  "star": "Luo",
                  "gongs": [
                    "Zi",
                    "Wu"
                  ]
                },
                {
                  "type": "starInGong",
                  "star": "Ji",
                  "gongs": [
                    "Zi",
                    "Wu"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_049_shan_ze_tong_qi",
    "name": "山泽通气",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Chou"
              ]
            },
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "You"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_050_shan_ze_chen_mai",
    "name": "山泽沉埋",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Yin"
              ]
            },
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "You"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_051_jie_mu_xing_zai",
    "name": "劫木兴灾",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Jupiter",
          "gongs": [
            "Yin",
            "Hai"
          ]
        }
      }
    ]
  },
  {
    "id": "mu_052_long_hu_feng_yun_hui",
    "name": "龙虎风云会",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "lifeGongAt",
              "gongs": [
                "Mao"
              ]
            },
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Yin",
                "Chen"
              ]
            },
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Yin",
                "Chen"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_053_mu_xing_sheng_dian",
    "name": "木星升殿",
    "variants": [
      {
        "conditions": {
          "type": "starInConstellation",
          "star": "Jupiter",
          "constellations": [
            "角",
            "斗",
            "奎",
            "井"
          ]
        }
      }
    ]
  },
  {
    "id": "mu_054_mu_yue_qing_gui",
    "name": "木月清贵",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Moon"
              ]
            },
            {
              "type": "isDayBirth",
              "isDay": false
            },
            {
              "type": "moonPhaseIs",
              "phases": [
                "Shang_Xian",
                "Full",
                "Xia_Xian"
              ]
            }
          ]
        }
      },
      {},
      {},
      {}
    ]
  },
  {
    "id": "mu_055_mu_huo_wen_ming",
    "name": "木火文明",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Mars"
              ]
            },
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER",
                "SPRING"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_056_qing_long_fu_yan",
    "name": "青龙扶砚",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "monthIs",
              "months": [
                "Yin",
                "Mao"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Sun"
              ]
            }
          ]
        }
      },
      {},
      {},
      {}
    ]
  },
  {
    "id": "mu_057_mu_ru_jin_xiang",
    "name": "木入金乡",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Jupiter",
          "gongs": [
            "Chen",
            "You"
          ]
        }
      }
    ]
  },
  {
    "id": "mu_058_mu_ru_tu_shi",
    "name": "木入土室",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Jupiter",
          "gongs": [
            "Zi",
            "Chou"
          ]
        }
      }
    ]
  },
  {
    "id": "mu_059_mu_tu_xiang_ke",
    "name": "木土相剋",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Jupiter",
            "Saturn"
          ]
        }
      }
    ]
  },
  {
    "id": "mu_060_mu_bei_fu_yin",
    "name": "木孛符印",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Bei"
              ]
            },
            {
              "type": "starGongStatus",
              "star": "Jupiter",
              "statuses": [
                "Miao",
                "Wang"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_061_mu_bi_yang_guang",
    "name": "木蔽阳光",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "isDayBirth",
              "isDay": true
            },
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Sun"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_062_mu_qi_lian_zhi",
    "name": "木气联枝",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Qi",
                "Bei"
              ]
            },
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Yin",
                "Hai"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_063_hu_xiao_yuan_yin",
    "name": "虎啸猿吟",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInConstellation",
              "star": "Jupiter",
              "constellations": [
                "尾",
                "觜"
              ]
            },
            {
              "type": "lifeGongAt",
              "gongs": [
                "Hai",
                "Si"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_064_hu_ju_long_pan",
    "name": "虎踞龙盘",
    "variants": [
      {
        "conditions": {
          "type": "or",
          "conditions": [
            {
              "type": "and",
              "conditions": [
                {
                  "type": "starGuardLife",
                  "star": "Venus"
                },
                {
                  "type": "oppositeGong",
                  "stars": [
                    "Venus",
                    "Jupiter"
                  ]
                },
                {
                  "type": "isDayBirth",
                  "isDay": false
                }
              ]
            },
            {
              "type": "and",
              "conditions": [
                {
                  "type": "sameGong",
                  "stars": [
                    "Jupiter",
                    "Venus"
                  ]
                },
                {
                  "type": "starGuardLife",
                  "star": "Jupiter"
                }
              ]
            },
            {
              "type": "and",
              "conditions": [
                {
                  "type": "lifeGongAt",
                  "gongs": [
                    "Zi",
                    "Wu"
                  ]
                },
                {
                  "type": "starInGong",
                  "star": "Venus",
                  "gongs": [
                    "You"
                  ]
                },
                {
                  "type": "starInGong",
                  "star": "Jupiter",
                  "gongs": [
                    "Mao"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_065_qing_long_dang_quan",
    "name": "青龙当权",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SPRING"
              ]
            },
            {
              "type": "lifeGongAt",
              "gongs": [
                "Yin",
                "Mao"
              ]
            },
            {
              "type": "starGuardLife",
              "star": "Jupiter"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_066_ao_tou_du_bu",
    "name": "鳌头独步",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SPRING"
              ]
            },
            {
              "type": "lifeGongAt",
              "gongs": [
                "Yin",
                "Mao"
              ]
            },
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Yin",
                "Mao"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_067_mu_shang_shui_jing",
    "name": "木上水井",
    "variants": [
      {
        "conditions": {
          "type": "or",
          "conditions": [
            {
              "type": "and",
              "conditions": [
                {
                  "type": "sameGong",
                  "stars": [
                    "Jupiter",
                    "Mercury"
                  ]
                },
                {
                  "type": "lifeGongAt",
                  "gongs": [
                    "Wei"
                  ]
                },
                {
                  "type": "starInConstellation",
                  "star": "Jupiter",
                  "constellations": [
                    "井"
                  ]
                }
              ]
            },
            {
              "type": "and",
              "conditions": [
                {
                  "type": "starInGong",
                  "star": "Jupiter",
                  "gongs": [
                    "Wei"
                  ]
                },
                {
                  "type": "starInGong",
                  "star": "Mercury",
                  "gongs": [
                    "Hai"
                  ]
                },
                {
                  "type": "lifeGongAt",
                  "gongs": [
                    "Wei"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_068_jiao_mu_duan_chan",
    "name": "角木断躔",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "lifeGongAt",
              "gongs": [
                "Chou"
              ]
            },
            {
              "type": "lifeConstellationAt",
              "constellations": [
                "斗"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Saturn",
              "constellations": [
                "斗"
              ]
            },
            {
              "type": "xianAtGong",
              "gongs": [
                "Chen"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Jupiter",
              "constellations": [
                "角"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_069_ji_feng_dou_kou",
    "name": "箕风斗口",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "lifeGongAt",
              "gongs": [
                "Hai"
              ]
            },
            {
              "type": "xianAtGong",
              "gongs": [
                "Yin"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Jupiter",
              "constellations": [
                "箕"
              ]
            },
            {
              "type": "xianAtConstellation",
              "constellations": [
                "箕",
                "斗"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_070_jin_mu_hai_shi",
    "name": "金木亥室",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Venus",
                "Jupiter"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Jupiter",
              "constellations": [
                "室"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_080_jiao_ji_feng_chang",
    "name": "脚疾风肠",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "mu_081_mu_ji_tong_yin",
    "name": "木计同寅",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Yin"
              ]
            },
            {
              "type": "starInGong",
              "star": "Ji",
              "gongs": [
                "Yin"
              ]
            },
            {
              "type": "lifeGongAt",
              "gongs": [
                "Yin"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_082_jin_mu_feng_long",
    "name": "金木逢龙",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Chen"
              ]
            },
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Chen"
              ]
            },
            {
              "type": "lifeGongAt",
              "gongs": [
                "Chen"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_083_mu_chan_jiao_dao",
    "name": "木躔角道",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInConstellation",
              "star": "Jupiter",
              "constellations": [
                "角"
              ]
            },
            {
              "type": "lifeGongAt",
              "gongs": [
                "Chen"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_084_mu_tu_xiang_hui",
    "name": "木土相会",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Shen"
              ]
            },
            {
              "type": "starInGong",
              "star": "Saturn",
              "gongs": [
                "Shen"
              ]
            },
            {
              "type": "lifeGongAt",
              "gongs": [
                "Shen"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_085_jin_mu_cheng_wang",
    "name": "金木乘旺",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Hai"
              ]
            },
            {
              "type": "starInGong",
              "star": "Venus",
              "gongs": [
                "Hai"
              ]
            },
            {
              "type": "lifeGongAt",
              "gongs": [
                "Hai"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_086_mu_lin_ying_shi",
    "name": "木临营室",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInConstellation",
              "star": "Jupiter",
              "constellations": [
                "室"
              ]
            },
            {
              "type": "lifeGongAt",
              "gongs": [
                "Hai"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_087_mu_ji_feng_yu",
    "name": "木计逢鱼",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Hai"
              ]
            },
            {
              "type": "starInGong",
              "star": "Ji",
              "gongs": [
                "Hai"
              ]
            },
            {
              "type": "lifeGongAt",
              "gongs": [
                "Hai"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_088_mu_chu_jin_long",
    "name": "木触金龙",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Jupiter",
          "gongs": [
            "Chen"
          ]
        }
      }
    ]
  },
  {
    "id": "mu_089_chun_mu_ge",
    "name": "纯木格",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starGuardLife",
              "star": "Jupiter"
            },
            {
              "type": "starGongStatus",
              "star": "Jupiter",
              "statuses": [
                "Miao",
                "Wang"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_090_mu_tu_hui_ji",
    "name": "木土会吉",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "lifeConstellationAt",
              "constellations": [
                "斗",
                "奎",
                "井",
                "角"
              ]
            },
            {
              "type": "sameConstellation",
              "stars": [
                "Jupiter",
                "Saturn"
              ]
            },
            {
              "type": "starGongStatus",
              "star": "Jupiter",
              "statuses": [
                "Miao",
                "Wang"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_091_ru_miao_tui_xing",
    "name": "入庙退行",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInConstellation",
              "star": "Jupiter",
              "constellations": [
                "斗"
              ]
            },
            {
              "type": "starGongStatus",
              "star": "Jupiter",
              "statuses": [
                "Miao"
              ]
            },
            {
              "type": "starWalkingState",
              "star": "Jupiter",
              "states": [
                "Retrograde"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_092_ku_zhi_bai_ye",
    "name": "枯枝败叶",
    "variants": [
      {
        "conditions": {
          "type": "starInKongWang",
          "star": "Jupiter"
        }
      }
    ]
  },
  {
    "id": "mu_093_zhuo_xiao_cheng_cai",
    "name": "琢削成材",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInKongWang",
              "star": "Jupiter"
            },
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Venus"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_094_fen_zhe_hui_mie",
    "name": "焚折灰灭",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInKongWang",
              "star": "Jupiter"
            },
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Mars"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_095_piao_cha_fan_fa",
    "name": "漂槎泛筏",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInKongWang",
              "star": "Jupiter"
            },
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Mercury"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_096_ri_lie_mu_jiao",
    "name": "日烈木焦",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SUMMER",
                "AUTUMN"
              ]
            },
            {
              "type": "isDayBirth",
              "isDay": true
            },
            {
              "type": "starInConstellation",
              "star": "Jupiter",
              "constellations": [
                "尾",
                "室",
                "觜",
                "星"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Sun"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_097_shang_xia_ji_run",
    "name": "上下济润",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SUMMER",
                "AUTUMN"
              ]
            },
            {
              "type": "isDayBirth",
              "isDay": true
            },
            {
              "type": "starInConstellation",
              "star": "Jupiter",
              "constellations": [
                "箕",
                "壁",
                "参",
                "轸"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Sun"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_098_bu_zhan_xian_kui",
    "name": "布占先魁",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "isDayBirth",
              "isDay": true
            },
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Sun"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_099_han_gu_hui_chun",
    "name": "寒谷回春",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "isDayBirth",
              "isDay": true
            },
            {
              "type": "or",
              "conditions": [
                {
                  "type": "sameGong",
                  "stars": [
                    "Jupiter",
                    "Mars",
                    "Luo"
                  ]
                },
                {
                  "type": "sameGong",
                  "stars": [
                    "Jupiter",
                    "Mars"
                  ]
                },
                {
                  "type": "sameGong",
                  "stars": [
                    "Jupiter",
                    "Luo"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "mu_100_shui_bei_dong_zhe",
    "name": "水孛冻折",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "isDayBirth",
              "isDay": false
            },
            {
              "type": "starInConstellation",
              "star": "Jupiter",
              "constellations": [
                "牛",
                "娄",
                "鬼",
                "亢"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Mercury",
                "Bei"
              ]
            }
          ]
        }
      }
    ]
  }
]');
INSERT INTO ge_ju_rules_document ("file_name", "payload_json") VALUES ('shi_san_bu_yi_ge_ju_rules.json', '[
  {
    "id": "shisanceng_001_qi_cha_sai_mei",
    "name": "齐插塞梅",
    "variants": [
      {
        "conditions": {
          "type": "starGuardLife",
          "star": "Jupiter",
          "gong": "Life"
        }
      }
    ]
  },
  {
    "id": "shisanceng_002_jiao_mu_duan_chan",
    "name": "角木断躔",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Saturn",
              "gong": "Life",
              "degree": "斗度"
            },
            {
              "type": "xianMeetStar",
              "stars": [
                "Jupiter"
              ],
              "gong": "Travel",
              "degree": "角度"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shisanceng_003_jin_qi_ren_ma",
    "name": "金骑人马",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "gongDegree",
              "gong": "Life",
              "degree": "尾度"
            },
            {
              "type": "starInGong",
              "star": "Venus",
              "gong": "Life"
            },
            {
              "type": "yearBranch",
              "branch": "寅"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shisanceng_004_shui_huo_xiang_xing",
    "name": "水火相刑",
    "variants": [
      {}
    ]
  },
  {
    "id": "shisanceng_005_jin_shen_chi_ren",
    "name": "金神持刃",
    "variants": [
      {}
    ]
  },
  {
    "id": "shisanceng_006_xuan_wu_dang_tai",
    "name": "元武当台",
    "variants": [
      {}
    ]
  },
  {
    "id": "shisanceng_007_zi_cheng_fu_wei",
    "name": "子承父位",
    "variants": [
      {}
    ]
  },
  {
    "id": "shisanceng_008_yue_ming_dou_fu",
    "name": "月明斗府",
    "variants": [
      {}
    ]
  },
  {
    "id": "shisanceng_009_xiang_yun_peng_yue",
    "name": "祥云捧月",
    "variants": [
      {}
    ]
  },
  {
    "id": "shisanceng_010_tai_yi_bao_chan",
    "name": "太乙抱蟾",
    "variants": [
      {},
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Moon",
                "YueBo"
              ],
              "gong": "Travel"
            },
            {
              "type": "gongDegree",
              "gong": "Travel",
              "degree": "未宫"
            }
          ]
        }
      },
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Moon",
                "YueBo"
              ],
              "gong": "Travel"
            },
            {
              "type": "gongDegree",
              "gong": "Travel",
              "degree": "未宫"
            }
          ]
        }
      },
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Moon",
                "YueBo"
              ],
              "gong": "Travel"
            },
            {
              "type": "gongDegree",
              "gong": "Travel",
              "degree": "未宫"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shisanceng_011_shui_shi_zao_xing",
    "name": "水士遭刑",
    "variants": [
      {}
    ]
  },
  {
    "id": "shisanceng_012_jin_xing_ru_dou",
    "name": "金星入斗",
    "variants": [
      {}
    ]
  },
  {
    "id": "shisanceng_013_ji_feng_dou_kou",
    "name": "箕风斗口",
    "variants": [
      {}
    ]
  }
]');
INSERT INTO ge_ju_rules_document ("file_name", "payload_json") VALUES ('shui_xing_ge_ju_rules.json', '[
  {
    "id": "shui_001_jun_chen_qing_hui",
    "name": "君臣庆会",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Mercury",
            "Venus",
            "Sun"
          ]
        }
      }
    ]
  },
  {
    "id": "shui_002_shui_cou_tian_chi",
    "name": "水凑天池",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SPRING"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Mercury",
              "constellations": [
                "壁"
              ]
            },
            {
              "type": "starInGong",
              "star": "Mercury",
              "gongs": [
                "Hai"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_003_gan_xuan_kun_zhuan",
    "name": "干旋坤转",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "shui_004_luan_yu_nan_xing",
    "name": "鸾轝南幸",
    "variants": [
      {
        "conditions": {
          "type": "starInConstellation",
          "star": "Mercury",
          "constellations": [
            "星",
            "房"
          ]
        }
      }
    ]
  },
  {
    "id": "shui_005_feng_jia_bei_gui",
    "name": "凤驾北归",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "shui_006_yi_gan_jiu_shi",
    "name": "移干就湿",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "shui_007_feng_yu_zuo_lin",
    "name": "风雨作霖",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Venus",
                "Sun"
              ]
            },
            {
              "type": "or",
              "conditions": [
                {
                  "type": "starInConstellation",
                  "star": "Mercury",
                  "constellations": [
                    "毕",
                    "箕"
                  ]
                },
                {
                  "type": "starInConstellation",
                  "star": "Venus",
                  "constellations": [
                    "毕",
                    "箕"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_008_jin_shui_bei_chi",
    "name": "金水背驰",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starWalkingState",
              "star": "Venus",
              "states": [
                "Retrograde",
                "Stay"
              ]
            },
            {
              "type": "starWalkingState",
              "star": "Mercury",
              "states": [
                "Retrograde",
                "Stay"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_009_jin_shui_fen_ming",
    "name": "金水分明",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "not",
              "condition": {
                "type": "starWalkingState",
                "star": "Mercury",
                "states": [
                  "Retrograde"
                ]
              }
            },
            {
              "type": "not",
              "condition": {
                "type": "starWalkingState",
                "star": "Venus",
                "states": [
                  "Retrograde"
                ]
              }
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_010_jin_shui_hui_yuan",
    "name": "金水会垣",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Mercury",
            "Venus"
          ]
        }
      }
    ]
  },
  {
    "id": "shui_011_jin_han_shui_leng",
    "name": "金寒水冷",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Venus"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_012_jin_shui_wei_shi",
    "name": "金水为仕",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInConstellation",
              "star": "Mercury",
              "constellations": [
                "奎",
                "壁"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Venus",
              "constellations": [
                "奎",
                "壁"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_013_jin_shui_hu_yuan",
    "name": "金水互垣",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "shui_014_jin_shui_gong_cheng",
    "name": "金水功成",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starGuardLife",
              "star": "Mercury"
            },
            {
              "type": "starGuardLife",
              "star": "Venus"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_015_shui_an_tian_zhai",
    "name": "水暗田宅",
    "variants": [
      {
        "conditions": {
          "type": "starInDestinyGong",
          "star": "Mercury",
          "destinyGong": "TianZhai"
        }
      }
    ]
  },
  {
    "id": "shui_016_shui_zhi_si_shen",
    "name": "水至巳申",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Mercury",
          "gongs": [
            "Si",
            "Shen"
          ]
        }
      }
    ]
  },
  {
    "id": "shui_017_shui_ri_tong_zhou",
    "name": "水日同周",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Sun"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Mercury",
              "constellations": [
                "星",
                "张"
              ]
            },
            {
              "type": "starInGong",
              "star": "Mercury",
              "gongs": [
                "Wu"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_018_jin_shui_hui_she",
    "name": "金水会蛇",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Venus"
              ]
            },
            {
              "type": "starInGong",
              "star": "Mercury",
              "gongs": [
                "Si"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_019_shui_liu_an_chun_wei",
    "name": "水流鹌鹑尾",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Mercury",
          "gongs": [
            "Si"
          ]
        }
      }
    ]
  },
  {
    "id": "shui_020_shui_hui_ji_du",
    "name": "水会计都",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Mercury",
            "Ji"
          ]
        }
      }
    ]
  },
  {
    "id": "shui_021_shui_huo_xiang_zhan",
    "name": "水火相战",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Mercury",
            "Mars"
          ]
        }
      }
    ]
  },
  {
    "id": "shui_022_shui_liu_yang_zhou",
    "name": "水流扬州",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Mercury",
          "gongs": [
            "Chou"
          ]
        }
      }
    ]
  },
  {
    "id": "shui_023_shui_lin_shuang_nv",
    "name": "水临双女",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Mercury",
          "gongs": [
            "Si"
          ]
        }
      }
    ]
  },
  {
    "id": "shui_024_jin_huo_tong_cai",
    "name": "金火同财",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInDestinyGong",
              "star": "Venus",
              "destinyGong": "CaiBo"
            },
            {
              "type": "starInDestinyGong",
              "star": "Mars",
              "destinyGong": "CaiBo"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_025_shui_huo_ju_tian",
    "name": "水火居田",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInDestinyGong",
              "star": "Mercury",
              "destinyGong": "TianZhai"
            },
            {
              "type": "starInDestinyGong",
              "star": "Mars",
              "destinyGong": "TianZhai"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_026_shui_su_lin_cai",
    "name": "水宿临财",
    "variants": [
      {
        "conditions": {
          "type": "starInDestinyGong",
          "star": "Mercury",
          "destinyGong": "CaiBo"
        }
      }
    ]
  },
  {
    "id": "shui_027_shui_mu_chong_lin",
    "name": "水木重临",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Mercury",
            "Jupiter"
          ]
        }
      }
    ]
  },
  {
    "id": "shui_028_shui_jin_tong_chou",
    "name": "水金同丑",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Venus"
              ]
            },
            {
              "type": "starInGong",
              "star": "Mercury",
              "gongs": [
                "Chou"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_029_shui_bei_tong_du",
    "name": "水孛同度",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Bei"
              ]
            },
            {
              "type": "or",
              "conditions": [
                {
                  "type": "starGuardLife",
                  "star": "Mercury"
                },
                {
                  "type": "starGuardLife",
                  "star": "Bei"
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_030_chao_yun_mu_yu",
    "name": "朝云暮雨",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInDestinyGong",
              "star": "Mercury",
              "destinyGong": "QianYi"
            },
            {
              "type": "starInDestinyGong",
              "star": "Bei",
              "destinyGong": "QianYi"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_031_shui_su_ju_qiang",
    "name": "水宿居强",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "isDayBirth",
              "isDay": true
            },
            {
              "type": "starInGong",
              "star": "Mercury",
              "gongs": [
                "Si",
                "Shen",
                "Chen"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_032_shui_xing_shou_ming",
    "name": "水星守命",
    "variants": [
      {
        "conditions": {
          "type": "starGuardLife",
          "star": "Mercury"
        }
      }
    ]
  },
  {
    "id": "shui_033_shui_bei_tian_cai",
    "name": "水孛田财",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "or",
              "conditions": [
                {
                  "type": "starInDestinyGong",
                  "star": "Mercury",
                  "destinyGong": "TianZhai"
                },
                {
                  "type": "starInDestinyGong",
                  "star": "Mercury",
                  "destinyGong": "CaiBo"
                }
              ]
            },
            {
              "type": "or",
              "conditions": [
                {
                  "type": "starInDestinyGong",
                  "star": "Bei",
                  "destinyGong": "TianZhai"
                },
                {
                  "type": "starInDestinyGong",
                  "star": "Bei",
                  "destinyGong": "CaiBo"
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_034_shui_ji_xiang_xing",
    "name": "水计相刑",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Ji"
              ]
            },
            {
              "type": "starInGong",
              "star": "Mercury",
              "gongs": [
                "Si"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_035_shui_ru_yin_gong",
    "name": "水入寅宫",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Mercury",
          "gongs": [
            "Yin"
          ]
        }
      }
    ]
  },
  {
    "id": "shui_036_tu_hun_shui_zhuo",
    "name": "土混水浊",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Saturn"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_037_shui_fan_tu_beng",
    "name": "水泛土崩",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SPRING",
                "SUMMER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Saturn"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_038_xia_shui_ku_he",
    "name": "夏水枯涸",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SUMMER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Mars"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_039_dong_shui_nan_ben",
    "name": "冬水南奔",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Mercury",
              "constellations": [
                "娄"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_040_shui_dong_jin_han",
    "name": "水冻金寒",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Venus"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_041_shui_run_zao_tu",
    "name": "水润燥土",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SUMMER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Saturn"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_042_chen_xing_ju_yuan",
    "name": "辰星居垣",
    "variants": [
      {
        "conditions": {
          "type": "starGongStatus",
          "star": "Mercury",
          "statuses": [
            "Yuan"
          ]
        }
      }
    ]
  },
  {
    "id": "shui_043_shui_xing_sheng_dian",
    "name": "水星升殿",
    "variants": [
      {
        "conditions": {
          "type": "starInConstellation",
          "star": "Mercury",
          "constellations": [
            "箕",
            "壁",
            "参",
            "轸"
          ]
        }
      }
    ]
  },
  {
    "id": "shui_044_shui_han_chan_po",
    "name": "水涵蟾魄",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Mercury",
            "Moon"
          ]
        }
      },
      {},
      {},
      {}
    ]
  },
  {
    "id": "shui_045_jin_shui_xiang_han",
    "name": "金水相涵",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Venus"
              ]
            },
            {
              "type": "not",
              "condition": {
                "type": "seasonIs",
                "seasons": [
                  "WINTER"
                ]
              }
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_046_yuan_wu_chi_jing",
    "name": "元武持旌",
    "variants": [
      {
        "conditions": null
      },
      {},
      {},
      {}
    ]
  },
  {
    "id": "shui_047_shui_ju_tu_shi",
    "name": "水居土室",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Mercury",
          "gongs": [
            "Zi",
            "Chou"
          ]
        }
      }
    ]
  },
  {
    "id": "shui_048_shui_cheng_huo_wei",
    "name": "水乘火位",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Mercury",
          "gongs": [
            "Wu",
            "Si"
          ]
        }
      }
    ]
  },
  {
    "id": "shui_049_jin_shui_cong_yang",
    "name": "金水从阳",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "isDayBirth",
              "isDay": true
            },
            {
              "type": "starGongStatus",
              "star": "Mercury",
              "statuses": [
                "Yuan",
                "Dian"
              ]
            },
            {
              "type": "starGongStatus",
              "star": "Venus",
              "statuses": [
                "Yuan",
                "Dian"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_050_san_tai_he_ge",
    "name": "三台合格",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Sun",
                "Venus",
                "Mercury"
              ]
            },
            {
              "type": "starInGong",
              "star": "Sun",
              "gongs": [
                "Wu",
                "Si",
                "Mao"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_051_tian_di_kai_ming",
    "name": "天地开明",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Mercury",
              "gongs": [
                "Shen"
              ]
            },
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Hai"
              ]
            },
            {
              "type": "lifeGongAt",
              "gongs": [
                "Shen",
                "Hai"
              ]
            },
            {
              "type": "starInGong",
              "star": "Luo",
              "gongs": [
                "Zi",
                "Wu"
              ]
            },
            {
              "type": "starInGong",
              "star": "Ji",
              "gongs": [
                "Zi",
                "Wu"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_052_shui_huo_ji_ji",
    "name": "水火既济",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Mercury",
              "gongs": [
                "Zi"
              ]
            },
            {
              "type": "starInGong",
              "star": "Mars",
              "gongs": [
                "Wu"
              ]
            },
            {
              "type": "lifeGongAt",
              "gongs": [
                "Zi",
                "Wu"
              ]
            }
          ]
        }
      },
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Mars"
              ]
            },
            {
              "type": "starIsSiZhu",
              "star": "Mercury",
              "roles": [
                "lifeGongMaster",
                "lifeConstellationMaster"
              ]
            }
          ]
        }
      },
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mars",
                "Mercury"
              ]
            },
            {
              "type": "waterFireBalance"
            }
          ]
        }
      },
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mars",
                "Mercury"
              ]
            },
            {
              "type": "waterFireBalance"
            }
          ]
        }
      },
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mars",
                "Mercury"
              ]
            },
            {
              "type": "waterFireBalance"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_053_feng_lei_gu_wu",
    "name": "风雷鼓舞",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Mercury",
              "gongs": [
                "Si"
              ]
            },
            {
              "type": "starInGong",
              "star": "Mars",
              "gongs": [
                "Mao"
              ]
            },
            {
              "type": "lifeGongAt",
              "gongs": [
                "Chen"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_054_feng_lei_xiang_bo",
    "name": "风雷相薄",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "shui_055_shui_huo_xiang_she",
    "name": "水火相射",
    "variants": [
      {
        "conditions": {
          "type": "or",
          "conditions": [
            {
              "type": "and",
              "conditions": [
                {
                  "type": "starInGong",
                  "star": "Mercury",
                  "gongs": [
                    "Wu"
                  ]
                },
                {
                  "type": "starInGong",
                  "star": "Mars",
                  "gongs": [
                    "Zi"
                  ]
                }
              ]
            },
            {
              "type": "and",
              "conditions": [
                {
                  "type": "starInGong",
                  "star": "Jupiter",
                  "gongs": [
                    "Mao"
                  ]
                },
                {
                  "type": "starInGong",
                  "star": "Saturn",
                  "gongs": [
                    "Xu"
                  ]
                }
              ]
            },
            {
              "type": "and",
              "conditions": [
                {
                  "type": "starInGong",
                  "star": "Mars",
                  "gongs": [
                    "Si"
                  ]
                },
                {
                  "type": "starInGong",
                  "star": "Mercury",
                  "gongs": [
                    "Shen"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_056_yu_yuan_shou_kun",
    "name": "玉猿守昆",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInConstellation",
              "star": "Mercury",
              "constellations": [
                "参"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Sun"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_057_shuang_yu_xi_shui",
    "name": "双鱼戏水",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Mercury",
          "gongs": [
            "Hai"
          ]
        }
      }
    ]
  },
  {
    "id": "shui_058_yu_nv_chang_e",
    "name": "玉女嫦娥",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInConstellation",
              "star": "Mercury",
              "constellations": [
                "轸"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Moon",
              "constellations": [
                "张"
              ]
            },
            {
              "type": "lifeConstellationAt",
              "constellations": [
                "箕"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_059_yuan_wu_dang_quan",
    "name": "元武当权",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "lifeGongAt",
              "gongs": [
                "Hai",
                "Zi"
              ]
            },
            {
              "type": "starGuardLife",
              "star": "Mercury"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_060_li_kan_jiao_hui",
    "name": "离坎交会",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "isDayBirth",
              "isDay": false
            },
            {
              "type": "starGuardLife",
              "star": "Mars"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_061_zi_xing_fu_zheng",
    "name": "子行父政",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Moon",
              "gongs": [
                "Chou"
              ]
            },
            {
              "type": "starInGong",
              "star": "Mercury",
              "gongs": [
                "Wei"
              ]
            },
            {
              "type": "lifeGongAt",
              "gongs": [
                "Wei"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_062_shui_zhu_dong_nan",
    "name": "水注东南",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Mercury",
              "gongs": [
                "Si"
              ]
            },
            {
              "type": "starInGong",
              "star": "Jupiter",
              "gongs": [
                "Yin"
              ]
            },
            {
              "type": "lifeGongAt",
              "gongs": [
                "Yin"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_063_huo_shui_wei_ji",
    "name": "火水未济",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Mercury",
            "Mars"
          ]
        }
      }
    ]
  },
  {
    "id": "shui_065_shui_huo_xiang_xing",
    "name": "水火相刑",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "lifeGongAt",
              "gongs": [
                "Mao"
              ]
            },
            {
              "type": "lifeConstellationAt",
              "constellations": [
                "房"
              ]
            },
            {
              "type": "seasonIs",
              "seasons": [
                "SUMMER"
              ]
            },
            {
              "type": "xianAtGong",
              "gongs": [
                "Wu"
              ]
            },
            {
              "type": "starInGong",
              "star": "Mercury",
              "gongs": [
                "Wu"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_066_shui_tu_zao_xing",
    "name": "水土遭刑",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "lifeGongAt",
              "gongs": [
                "Shen"
              ]
            },
            {
              "type": "starIsSiZhu",
              "star": "Mercury",
              "roles": [
                "lifeGongMaster"
              ]
            },
            {
              "type": "xianAtGong",
              "gongs": [
                "Xu"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_067_jin_shui_xing_qiao",
    "name": "金水性巧",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Mercury",
            "Venus"
          ]
        }
      }
    ]
  },
  {
    "id": "shui_068_shui_bei_chang_you",
    "name": "水孛倡优",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Mercury",
            "Bei"
          ]
        }
      }
    ]
  },
  {
    "id": "shui_069_jin_shui_bei_xian",
    "name": "金水孛咸",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Mercury",
            "Venus",
            "Bei"
          ]
        }
      }
    ]
  },
  {
    "id": "shui_070_jin_shui_bei_mu",
    "name": "金水孛沐",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Venus",
                "Bei"
              ]
            },
            {
              "type": "or",
              "conditions": [
                {
                  "type": "starGuardLife",
                  "star": "Mercury"
                },
                {
                  "type": "starGuardLife",
                  "star": "Venus"
                },
                {
                  "type": "starGuardLife",
                  "star": "Bei"
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_071_shui_piao_yang_jiao",
    "name": "水漂羊角",
    "variants": [
      {
        "conditions": {
          "type": "starInConstellation",
          "star": "Mercury",
          "constellations": [
            "娄"
          ]
        }
      }
    ]
  },
  {
    "id": "shui_072_shui_liu_ju_xie",
    "name": "水流巨蟹",
    "variants": [
      {
        "conditions": {
          "type": "starInConstellation",
          "star": "Mercury",
          "constellations": [
            "柳"
          ]
        }
      }
    ]
  },
  {
    "id": "shui_073_shui_qing_bao_ping",
    "name": "水清宝瓶",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Mercury",
          "gongs": [
            "Zi"
          ]
        }
      },
      {},
      {},
      {}
    ]
  },
  {
    "id": "shui_074_shui_run_jin_ming",
    "name": "水润金明",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Venus"
              ]
            },
            {
              "type": "starInGong",
              "star": "Mercury",
              "gongs": [
                "Chen"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_075_ri_shui_cheng_wang",
    "name": "日水乘旺",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Sun"
              ]
            },
            {
              "type": "starInGong",
              "star": "Mercury",
              "gongs": [
                "Si"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_076_shui_yang_xiang_hui",
    "name": "水阳相会",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Sun"
              ]
            },
            {
              "type": "starInGong",
              "star": "Mercury",
              "gongs": [
                "Wu"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_077_shui_ming_rong_xian",
    "name": "水名荣显",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Mercury",
          "gongs": [
            "Wu"
          ]
        }
      }
    ]
  },
  {
    "id": "shui_078_shui_bei_fu_chen",
    "name": "水孛浮沉",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Bei"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Mercury",
              "constellations": [
                "尾"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_079_chang_jiang_hao_dang",
    "name": "长江浩荡",
    "variants": [
      {
        "conditions": {
          "type": "starInKongWang",
          "star": "Mercury"
        }
      }
    ]
  },
  {
    "id": "shui_080_hong_shui_tao_tian",
    "name": "洪水滔天",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInKongWang",
              "star": "Mercury"
            },
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Venus"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_081_guang_ji_cheng_che",
    "name": "光霁澄彻",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SPRING"
              ]
            },
            {
              "type": "isDayBirth",
              "isDay": true
            },
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Bei",
                "Sun"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_082_chun_shui_ji_jin",
    "name": "春水忌金",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SPRING"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Venus"
              ]
            },
            {
              "type": "isDayBirth",
              "isDay": false
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_083_xia_shui_feng_di",
    "name": "夏水逢堤",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SUMMER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Saturn"
              ]
            },
            {
              "type": "starGongStatus",
              "star": "Saturn",
              "statuses": [
                "Wang"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_084_qiu_shui_qing_yuan",
    "name": "秋水清源",
    "variants": [
      {
        "conditions": {
          "type": "seasonIs",
          "seasons": [
            "AUTUMN"
          ]
        }
      }
    ]
  },
  {
    "id": "shui_085_dong_shui_san_ling",
    "name": "冬水三令",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "or",
              "conditions": [
                {
                  "type": "sameGong",
                  "stars": [
                    "Mercury",
                    "Mars"
                  ]
                },
                {
                  "type": "sameGong",
                  "stars": [
                    "Mercury",
                    "Saturn"
                  ]
                },
                {
                  "type": "sameGong",
                  "stars": [
                    "Mercury",
                    "Sun"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "shui_086_dong_jin_wu_yi",
    "name": "冬金无义",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Mercury",
                "Venus"
              ]
            }
          ]
        }
      }
    ]
  }
]');
INSERT INTO ge_ju_rules_document ("file_name", "payload_json") VALUES ('tu_xing_ge_ju_rules.json', '[
  {
    "id": "tu_001_gou_chen_zhen_dian",
    "name": "勾陈镇殿",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Sun"
              ]
            },
            {
              "type": "starInConstellation",
              "star": "Saturn",
              "constellations": [
                "虚",
                "房",
                "昴"
              ]
            }
          ]
        }
      },
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "monthIs",
              "months": [
                "Chen",
                "Xu",
                "Chou",
                "Wei"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Sun"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_002_shan_xiao_cheng_bao",
    "name": "山啸呈宝",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInKongWang",
              "star": "Saturn"
            },
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Venus"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_003_shi_li_jian_feng",
    "name": "石砺剑锋",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "tu_004_zhu_cang_yuan_hai",
    "name": "珠藏渊海",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "tu_005_lao_bang_han_zhu",
    "name": "老蚌含珠",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Venus"
              ]
            },
            {
              "type": "or",
              "conditions": [
                {
                  "type": "starInGong",
                  "star": "Saturn",
                  "gongs": [
                    "Hai",
                    "Zi"
                  ]
                },
                {
                  "type": "starInGong",
                  "star": "Saturn",
                  "gongs": [
                    "Chen",
                    "Si"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_006_han_yun_chu_xiu",
    "name": "寒云出岫",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "tu_007_tu_bei_chan",
    "name": "土孛掺",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Saturn",
            "Bei"
          ]
        }
      }
    ]
  },
  {
    "id": "tu_008_zhou_huo_ye_tu",
    "name": "昼火夜土",
    "variants": [
      {
        "conditions": {
          "type": "or",
          "conditions": [
            {
              "type": "and",
              "conditions": [
                {
                  "type": "isDayBirth",
                  "isDay": true
                },
                {
                  "type": "sameGong",
                  "stars": [
                    "Mars",
                    "Luo"
                  ]
                }
              ]
            },
            {
              "type": "and",
              "conditions": [
                {
                  "type": "isDayBirth",
                  "isDay": false
                },
                {
                  "type": "sameGong",
                  "stars": [
                    "Saturn",
                    "Ji"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_009_ye_tu_jie_yue",
    "name": "夜土截月",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "isDayBirth",
              "isDay": false
            },
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Moon"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_010_tu_bei_po_guan",
    "name": "土孛破官",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInDestinyGong",
              "star": "Saturn",
              "destinyGong": "GuanLu"
            },
            {
              "type": "starInDestinyGong",
              "star": "Bei",
              "destinyGong": "GuanLu"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_011_huo_tu_ba_sha",
    "name": "火土八杀",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "tu_012_tu_zai_qi_wu",
    "name": "土在齐吴",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInGong",
              "star": "Saturn",
              "gongs": [
                "Zi",
                "Chou"
              ]
            },
            {
              "type": "isDayBirth",
              "isDay": false
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_013_huo_tu_de_niu",
    "name": "火土得牛",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mars",
                "Saturn"
              ]
            },
            {
              "type": "starInGong",
              "star": "Saturn",
              "gongs": [
                "Chou"
              ]
            }
          ]
        }
      },
      {},
      {},
      {}
    ]
  },
  {
    "id": "tu_014_tu_ju_zheng_guo",
    "name": "土居郑国",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Saturn",
          "gongs": [
            "Chen"
          ]
        }
      }
    ]
  },
  {
    "id": "tu_015_tu_hao_bao_ping",
    "name": "土好宝瓶",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Saturn",
          "gongs": [
            "Zi"
          ]
        }
      }
    ]
  },
  {
    "id": "tu_016_tu_mai_shuang_nv",
    "name": "土埋双女",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Saturn",
          "gongs": [
            "Si"
          ]
        }
      }
    ]
  },
  {
    "id": "tu_017_jin_tu_xiang_feng",
    "name": "金土相逢",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Venus",
            "Saturn"
          ]
        }
      }
    ]
  },
  {
    "id": "tu_018_tu_hao_tai_chang",
    "name": "土号太常",
    "variants": [
      {
        "conditions": {
          "type": "starInConstellation",
          "star": "Saturn",
          "constellations": [
            "斗",
            "牛"
          ]
        }
      }
    ]
  },
  {
    "id": "tu_019_tu_luo_qian_yi",
    "name": "土罗迁移",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInDestinyGong",
              "star": "Saturn",
              "destinyGong": "QianYi"
            },
            {
              "type": "starInDestinyGong",
              "star": "Luo",
              "destinyGong": "QianYi"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_020_tu_bei_si_gong",
    "name": "土孛巳宫",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Bei"
              ]
            },
            {
              "type": "starInGong",
              "star": "Saturn",
              "gongs": [
                "Si"
              ]
            },
            {
              "type": "starGuardLife",
              "star": "Saturn"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_021_tu_xing_ru_ming",
    "name": "土星入命",
    "variants": [
      {
        "conditions": {
          "type": "starGuardLife",
          "star": "Saturn"
        }
      }
    ]
  },
  {
    "id": "tu_022_tu_ji_ju_chen",
    "name": "土计居辰",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Ji"
              ]
            },
            {
              "type": "starInGong",
              "star": "Saturn",
              "gongs": [
                "Chen"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_023_huo_yan_tu_zao",
    "name": "火炎土燥",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SUMMER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Mars"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_024_tu_hui_jin_mai",
    "name": "土晦金埋",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "AUTUMN"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Venus",
                "Saturn"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_025_tu_hun_shui_zhuo",
    "name": "土混水浊",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Mercury"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_026_shui_fan_tu_beng",
    "name": "水泛土崩",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SPRING",
                "SUMMER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Mercury"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_027_dong_tu_hui_huo",
    "name": "冻土会火",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Mars"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_028_han_tu_feng_jin",
    "name": "寒土逢金",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Venus"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_029_tu_mu_zhu_yue",
    "name": "土母助月",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "lifeGongAt",
              "gongs": [
                "Chen",
                "You"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Moon"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_030_shui_run_zao_tu",
    "name": "水润燥土",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SUMMER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Mercury"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_031_zhen_xing_ju_yuan",
    "name": "镇星居垣",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Saturn",
          "gongs": [
            "Zi",
            "Chou"
          ]
        }
      }
    ]
  },
  {
    "id": "tu_032_tu_xing_sheng_dian",
    "name": "土星升殿",
    "variants": [
      {
        "conditions": {
          "type": "starInConstellation",
          "star": "Saturn",
          "constellations": [
            "女",
            "胃",
            "柳",
            "氐"
          ]
        }
      }
    ]
  },
  {
    "id": "tu_033_huo_tu_gao_qiang",
    "name": "火土高强",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Mars",
                "Saturn"
              ]
            },
            {
              "type": "not",
              "condition": {
                "type": "seasonIs",
                "seasons": [
                  "SUMMER"
                ]
              }
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_034_tu_jin_jian_shi",
    "name": "土金坚实",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Venus"
              ]
            },
            {
              "type": "not",
              "condition": {
                "type": "seasonIs",
                "seasons": [
                  "AUTUMN",
                  "WINTER"
                ]
              }
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_036_tu_zai_mu_gong",
    "name": "土在木宫",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Saturn",
          "gongs": [
            "Yin",
            "Hai"
          ]
        }
      }
    ]
  },
  {
    "id": "tu_037_tu_ju_shui_di",
    "name": "土居水地",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Saturn",
          "gongs": [
            "Si",
            "Shen"
          ]
        }
      }
    ]
  },
  {
    "id": "tu_038_mu_tu_xiang_ke",
    "name": "木土相克",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Jupiter",
            "Saturn"
          ]
        }
      }
    ]
  },
  {
    "id": "tu_039_tu_shui_xiang_ji",
    "name": "土水相激",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Saturn",
            "Mercury"
          ]
        }
      }
    ]
  },
  {
    "id": "tu_040_tu_luo_xiang_hui",
    "name": "土罗相会",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Luo"
              ]
            },
            {
              "type": "not",
              "condition": {
                "type": "seasonIs",
                "seasons": [
                  "SUMMER"
                ]
              }
            }
          ]
        }
      },
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Luo"
              ]
            },
            {
              "type": "starInGong",
              "star": "Saturn",
              "gongs": [
                "Chen"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_041_tu_ji_yan_yue",
    "name": "土计掩月",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "isDayBirth",
              "isDay": false
            },
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Ji",
                "Moon"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_042_tu_bei_hun_za",
    "name": "土孛混杂",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Saturn",
            "Bei"
          ]
        }
      }
    ]
  },
  {
    "id": "tu_043_qian_kun_pi_se",
    "name": "乾坤否塞",
    "variants": [
      {
        "conditions": {
          "type": "or",
          "conditions": [
            {
              "type": "and",
              "conditions": [
                {
                  "type": "lifeGongAt",
                  "gongs": [
                    "Hai"
                  ]
                },
                {
                  "type": "sameGong",
                  "stars": [
                    "Venus",
                    "Luo"
                  ]
                }
              ]
            },
            {
              "type": "and",
              "conditions": [
                {
                  "type": "lifeGongAt",
                  "gongs": [
                    "Shen"
                  ]
                },
                {
                  "type": "sameGong",
                  "stars": [
                    "Saturn",
                    "Ji"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_044_ba_sha_chao_tian",
    "name": "八杀朝天",
    "variants": [
      {
        "conditions": {
          "type": "or",
          "conditions": [
            {
              "type": "and",
              "conditions": [
                {
                  "type": "lifeGongAt",
                  "gongs": [
                    "Xu"
                  ]
                },
                {
                  "type": "starGuardLife",
                  "star": "Mars"
                }
              ]
            },
            {
              "type": "and",
              "conditions": [
                {
                  "type": "lifeGongAt",
                  "gongs": [
                    "Wei"
                  ]
                },
                {
                  "type": "starGuardLife",
                  "star": "Saturn"
                }
              ]
            },
            {
              "type": "and",
              "conditions": [
                {
                  "type": "lifeGongAt",
                  "gongs": [
                    "Chen"
                  ]
                },
                {
                  "type": "starGuardLife",
                  "star": "Venus"
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_045_gou_chen_de_wei",
    "name": "勾陈得位",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "lifeGongAt",
              "gongs": [
                "Chen",
                "Xu",
                "Chou",
                "Wei"
              ]
            },
            {
              "type": "starGuardLife",
              "star": "Saturn"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_046_shui_tu_zao_xing",
    "name": "水土遭刑",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "lifeGongAt",
              "gongs": [
                "Shen"
              ]
            },
            {
              "type": "starInGong",
              "star": "Saturn",
              "gongs": [
                "Hai"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_047_tu_xing_fei_da",
    "name": "土星肥大",
    "variants": [
      {
        "conditions": {
          "type": "starGuardLife",
          "star": "Saturn"
        }
      }
    ]
  },
  {
    "id": "tu_048_tu_ming_ji_mu",
    "name": "土命忌木",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starIsSiZhu",
              "star": "Saturn",
              "roles": [
                "lifeGongMaster"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Jupiter"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_049_tu_ke_rou_chuang",
    "name": "土咳肉疮",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "tu_050_tu_zou_shuang_yu",
    "name": "土走双鱼",
    "variants": [
      {
        "conditions": {
          "type": "starInConstellation",
          "star": "Saturn",
          "constellations": [
            "翼"
          ]
        }
      }
    ]
  },
  {
    "id": "tu_051_tu_zou_ren_ma",
    "name": "土走人马",
    "variants": [
      {
        "conditions": {
          "type": "starInConstellation",
          "star": "Saturn",
          "constellations": [
            "尾"
          ]
        }
      }
    ]
  },
  {
    "id": "tu_052_tu_hao_tai_chang_2",
    "name": "土好太常",
    "variants": [
      {
        "conditions": {
          "type": "starInGong",
          "star": "Saturn",
          "gongs": [
            "Chou"
          ]
        }
      }
    ]
  },
  {
    "id": "tu_054_mu_tu_xiang_hui",
    "name": "木土相会",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Jupiter",
                "Saturn"
              ]
            },
            {
              "type": "starInGong",
              "star": "Saturn",
              "gongs": [
                "Shen"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_055_tu_ri_he_zhao",
    "name": "土日合照",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Sun"
              ]
            },
            {
              "type": "starInGong",
              "star": "Saturn",
              "gongs": [
                "Xu"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_056_tu_ji_ren_xiong",
    "name": "土计刃雄",
    "variants": [
      {
        "conditions": {
          "type": "sameGong",
          "stars": [
            "Saturn",
            "Ji"
          ]
        }
      }
    ]
  },
  {
    "id": "tu_057_tu_xian_shan_beng",
    "name": "土陷山崩",
    "variants": [
      {
        "conditions": {
          "type": "starInKongWang",
          "star": "Saturn"
        }
      },
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "or",
              "conditions": [
                {
                  "type": "seasonIs",
                  "seasons": [
                    "SPRING"
                  ]
                },
                {
                  "type": "monthIs",
                  "months": [
                    "Si"
                  ]
                }
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Mercury",
                "Bei"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_058_tian_ao_bu_que",
    "name": "填凹补缺",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "starInKongWang",
              "star": "Saturn"
            },
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Mars"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_059_tian_di_jie_chun",
    "name": "天地皆春",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SPRING"
              ]
            },
            {
              "type": "isDayBirth",
              "isDay": true
            },
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Sun"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_060_ni_feng_fan_hua",
    "name": "泥逢泛滑",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SPRING"
              ]
            },
            {
              "type": "or",
              "conditions": [
                {
                  "type": "sameGong",
                  "stars": [
                    "Saturn",
                    "Mercury"
                  ]
                },
                {
                  "type": "sameGong",
                  "stars": [
                    "Saturn",
                    "Bei"
                  ]
                },
                {
                  "type": "sameGong",
                  "stars": [
                    "Ji",
                    "Mercury"
                  ]
                },
                {
                  "type": "sameGong",
                  "stars": [
                    "Ji",
                    "Bei"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_062_tu_feng_shui_run",
    "name": "土逢水润",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "SUMMER"
              ]
            },
            {
              "type": "or",
              "conditions": [
                {
                  "type": "sameGong",
                  "stars": [
                    "Saturn",
                    "Mercury"
                  ]
                },
                {
                  "type": "sameGong",
                  "stars": [
                    "Saturn",
                    "Bei"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_063_huo_zao_tu_lie",
    "name": "火燥土烈",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "monthIs",
              "months": [
                "Wei",
                "Shen"
              ]
            },
            {
              "type": "or",
              "conditions": [
                {
                  "type": "sameGong",
                  "stars": [
                    "Saturn",
                    "Luo"
                  ]
                },
                {
                  "type": "sameGong",
                  "stars": [
                    "Saturn",
                    "Mars"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_064_ri_lie_tu_jiao",
    "name": "日烈土焦",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "monthIs",
              "months": [
                "Wei",
                "Shen"
              ]
            },
            {
              "type": "isDayBirth",
              "isDay": true
            },
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Sun"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_065_shang_sheng_xia_run",
    "name": "上生下润",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "monthIs",
              "months": [
                "Wei",
                "Shen"
              ]
            },
            {
              "type": "or",
              "conditions": [
                {
                  "type": "sameGong",
                  "stars": [
                    "Saturn",
                    "Mercury"
                  ]
                },
                {
                  "type": "sameGong",
                  "stars": [
                    "Saturn",
                    "Bei"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_066_ri_wen_tu_hua",
    "name": "日温土化",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "sameGong",
              "stars": [
                "Saturn",
                "Sun"
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_067_huo_luo_zhu_tu",
    "name": "火罗助土",
    "variants": [
      {
        "conditions": {
          "type": "and",
          "conditions": [
            {
              "type": "seasonIs",
              "seasons": [
                "WINTER"
              ]
            },
            {
              "type": "isDayBirth",
              "isDay": false
            },
            {
              "type": "or",
              "conditions": [
                {
                  "type": "sameGong",
                  "stars": [
                    "Saturn",
                    "Mars"
                  ]
                },
                {
                  "type": "sameGong",
                  "stars": [
                    "Saturn",
                    "Luo"
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  },
  {
    "id": "tu_068_tu_wei_zai_huan",
    "name": "土为灾缓",
    "variants": [
      {
        "conditions": null
      }
    ]
  }
]');
INSERT INTO ge_ju_rules_document ("file_name", "payload_json") VALUES ('xing_ge_zong_lun_rules.json', '[
  {
    "id": "xinggezonglun_001_qing_zhu_zhi_qi",
    "name": "清浊之气",
    "variants": [
      {
        "conditions": null
      }
    ]
  },
  {
    "id": "xinggezonglun_002_ri_yue_he_bi",
    "name": "日月合璧",
    "variants": [
      {
        "conditions": {
          "type": "or",
          "conditions": [
            {
              "type": "sameGong",
              "stars": [
                "Sun",
                "Moon"
              ]
            },
            {
              "type": "sunMoonHarmony"
            }
          ]
        }
      }
    ]
  },
  {
    "id": "xinggezonglun_003_zhao_shui_mei_hua",
    "name": "照水梅花",
    "variants": [
      {
        "conditions": {
          "type": "jupiterSeasonPosition",
          "season": "winter",
          "positions": [
            "巳",
            "申"
          ]
        }
      }
    ]
  },
  {
    "id": "xinggezonglun_004_mei_ying_heng_chuang",
    "name": "梅影横窗",
    "variants": [
      {}
    ]
  },
  {
    "id": "xinggezonglun_005_bei_yuan_hui_chun",
    "name": "北苑回春",
    "variants": [
      {}
    ]
  },
  {
    "id": "xinggezonglun_006_jin_wu_cheng_rui",
    "name": "金乌呈瑞",
    "variants": [
      {}
    ]
  }
]');
