CREATE TABLE IF NOT EXISTS deities_document (  file_name TEXT PRIMARY KEY,  payload_json TEXT NOT NULL);
DELETE FROM deities_document;
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('bai-hu.json', '{
  "id": "baiHu",
  "name": "白虎",
  "layer": "shenPan",
  "algorithm": {
    "templateId": "fixedPosition",
    "params": {
      "gong": "兑"
    }
  },
  "priority": 47,
  "source": "official",
  "tier": "weather"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('bai-liu.json', '{
  "id": "baiLiu",
  "name": "百六",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 4320,
          "step": 288,
          "label": "百六"
        },
        {
          "cycle": 288,
          "step": 24,
          "label": "邦"
        }
      ],
      "palaceSystem": "sixteenZhengJian",
      "direction": "forward",
      "startPalace": "寅"
    }
  },
  "priority": 31,
  "source": "official",
  "tier": "spiritual",
  "chartTypes": [
    "year",
    "month"
  ]
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('chen-ji.json', '{
  "id": "chenJi",
  "name": "臣基",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 360,
          "step": 36,
          "label": "邦"
        },
        {
          "cycle": 36,
          "step": 3,
          "label": "年"
        }
      ],
      "palaceSystem": "sixteenZhengJian",
      "direction": "forward",
      "startPalace": "戌"
    }
  },
  "priority": 21,
  "source": "official",
  "tier": "jiShen"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('chi-qi.json', '{
  "id": "chiQi",
  "name": "赤旗",
  "layer": "shenPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 60,
          "step": 1,
          "label": "年"
        }
      ],
      "palaceSystem": "sixteenZhengJian",
      "direction": "forward",
      "startPalace": "午"
    }
  },
  "priority": 53,
  "source": "official",
  "tier": "weather"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('da-you.json', '{
  "id": "daYou",
  "name": "大游",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": -145,
      "steps": [
        {
          "cycle": 288,
          "step": 36,
          "label": "宫"
        }
      ],
      "palaceSystem": "nineGong",
      "palaceSeq": [
        {
          "palace": "坤"
        },
        {
          "palace": "兑"
        },
        {
          "palace": "乾"
        },
        {
          "palace": "坎"
        },
        {
          "palace": "艮"
        },
        {
          "palace": "震"
        },
        {
          "palace": "巽"
        },
        {
          "palace": "离"
        }
      ],
      "direction": "forward",
      "startPalace": "坤"
    }
  },
  "priority": 24,
  "source": "official",
  "tier": "auspicious"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('di-yi.json', '{
  "id": "diYi",
  "name": "地乙",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 360,
          "step": 36,
          "label": "周"
        },
        {
          "cycle": 36,
          "step": 3,
          "label": "宫"
        }
      ],
      "palaceSystem": "sixteenZhengJian",
      "palaceSeq": [
        {
          "palace": "巳"
        },
        {
          "palace": "戌"
        },
        {
          "palace": "未"
        },
        {
          "palace": "丑"
        },
        {
          "palace": "亥"
        },
        {
          "palace": "午"
        },
        {
          "palace": "寅"
        },
        {
          "palace": "卯"
        },
        {
          "palace": "辰"
        },
        {
          "palace": "酉"
        },
        {
          "palace": "申"
        },
        {
          "palace": "子"
        }
      ],
      "direction": "forward",
      "startPalace": "巳"
    }
  },
  "priority": 28,
  "source": "official",
  "tier": "auspicious"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('ding-can-jiang.json', '{
  "id": "dingCanJiang",
  "name": "定参将",
  "layer": "renPan",
  "algorithm": {
    "templateId": "fixedPosition",
    "params": {
      "gong": "中"
    }
  },
  "priority": 7,
  "source": "official",
  "tier": "generals"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('ding-da-jiang.json', '{
  "id": "dingDaJiang",
  "name": "定大将",
  "layer": "renPan",
  "algorithm": {
    "templateId": "fixedPosition",
    "params": {
      "gong": "中"
    }
  },
  "priority": 6,
  "source": "official",
  "tier": "generals"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('fei-fu.json', '{
  "id": "feiFu",
  "name": "飞符",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "relativeOffset",
    "params": {
      "sourceDeityId": "taiYi",
      "offset": 2
    }
  },
  "priority": 32,
  "source": "official",
  "tier": "auspicious"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('feng-bo.json', '{
  "id": "fengBo",
  "name": "风伯",
  "layer": "shenPan",
  "algorithm": {
    "templateId": "branchWalker",
    "params": {
      "cycle": 12,
      "branches": [
        "申",
        "酉",
        "戌",
        "亥",
        "子",
        "丑",
        "寅",
        "卯",
        "辰",
        "巳",
        "午",
        "未"
      ]
    }
  },
  "priority": 49,
  "source": "official",
  "tier": "weather"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('gui-shen-zhi-shi.json', '{
  "id": "guiShenZhiShi",
  "name": "贵神值事",
  "layer": "shenPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 60,
          "step": 1,
          "label": "年"
        }
      ],
      "palaceSystem": "sixteenZhengJian",
      "direction": "forward",
      "startPalace": "子"
    }
  },
  "priority": 54,
  "source": "official",
  "tier": "weather"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('he-shen.json', '{
  "id": "heShen",
  "name": "合神",
  "layer": "shenPan",
  "algorithm": {
    "templateId": "relativeOffset",
    "params": {
      "sourceDeityId": "zhiFu",
      "offset": 6
    }
  },
  "priority": 43,
  "source": "official",
  "tier": "chronos"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('hei-qi.json', '{
  "id": "heiQi",
  "name": "黑旗",
  "layer": "shenPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 60,
          "step": 1,
          "label": "年"
        }
      ],
      "palaceSystem": "sixteenZhengJian",
      "direction": "forward",
      "startPalace": "子"
    }
  },
  "priority": 52,
  "source": "official",
  "tier": "weather"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('ji-shen.json', '{
  "id": "jiShen",
  "name": "计神",
  "layer": "renPan",
  "algorithm": {
    "templateId": "branchWalker",
    "params": {
      "cycle": 72,
      "branches": [
        "子",
        "丑",
        "艮",
        "寅",
        "卯",
        "辰",
        "巽",
        "巳",
        "午",
        "未",
        "坤",
        "申",
        "酉",
        "戌",
        "乾",
        "亥"
      ]
    }
  },
  "priority": 11,
  "source": "official",
  "tier": "core"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('jiang-gong.json', '{
  "id": "jiangGong",
  "name": "绛宫",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 24,
          "step": 3,
          "label": "宫"
        }
      ],
      "palaceSystem": "nineGong",
      "direction": "forward",
      "startPalace": "巽"
    }
  },
  "priority": 37,
  "source": "official",
  "tier": "auspicious",
  "chartTypes": ["year", "month", "day"],
  "schoolScopes": ["jingMirror", "tongZong", "jiCheng", "fuYing"]
}
');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('jun-ji.json', '{
  "id": "junJi",
  "name": "君基",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 360,
          "step": 30,
          "label": "邦"
        }
      ],
      "palaceSystem": "sixteenZhengJian",
      "direction": "forward",
      "startPalace": "戌"
    }
  },
  "priority": 20,
  "source": "official",
  "tier": "jiShen"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('ke-can-jiang.json', '{
  "id": "keCanJiang",
  "name": "客参将",
  "layer": "renPan",
  "algorithm": {
    "templateId": "fixedPosition",
    "params": {
      "gong": "中"
    }
  },
  "priority": 5,
  "source": "official",
  "tier": "generals"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('ke-da-jiang.json', '{
  "id": "keDaJiang",
  "name": "客大将",
  "layer": "renPan",
  "algorithm": {
    "templateId": "fixedPosition",
    "params": {
      "gong": "中"
    }
  },
  "priority": 3,
  "source": "official",
  "tier": "generals"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('min-ji.json', '{
  "id": "minJi",
  "name": "民基",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 360,
          "step": 12,
          "label": "邦"
        }
      ],
      "palaceSystem": "sixteenZhengJian",
      "direction": "forward",
      "startPalace": "戌"
    }
  },
  "priority": 22,
  "source": "official",
  "tier": "jiShen"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('ming-tang.json', '{
  "id": "mingTang",
  "name": "明堂",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 24,
          "step": 3,
          "label": "宫"
        }
      ],
      "palaceSystem": "nineGong",
      "direction": "forward",
      "startPalace": "乾"
    }
  },
  "priority": 38,
  "source": "official",
  "tier": "auspicious",
  "chartTypes": ["year", "month", "day"],
  "schoolScopes": ["jingMirror", "tongZong", "jiCheng", "fuYing"]
}
');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('qing-long-qi.json', '{
  "id": "qingLongQi",
  "name": "青龙旗",
  "layer": "shenPan",
  "algorithm": {
    "templateId": "relativeOffset",
    "params": {
      "sourceDeityId": "taiSui",
      "offset": 0
    }
  },
  "priority": 51,
  "source": "official",
  "tier": "weather"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('qing-long.json', '{
  "id": "qingLong",
  "name": "青龙",
  "layer": "shenPan",
  "algorithm": {
    "templateId": "fixedPosition",
    "params": {
      "gong": "艮"
    }
  },
  "priority": 45,
  "source": "official",
  "tier": "weather"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('she-ti.json', '{
  "id": "sheTi",
  "name": "摄提",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 32,
          "step": 4,
          "label": "宫"
        }
      ],
      "palaceSystem": "nineGong",
      "direction": "forward",
      "startPalace": "乾"
    }
  },
  "priority": 32,
  "source": "official",
  "tier": "auspicious",
  "chartTypes": ["year", "month", "day"],
  "schoolScopes": ["jingMirror", "tongZong", "jiCheng", "fuYing"]
}
');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('shi-ji.json', '{
  "id": "shiJi",
  "name": "始击",
  "layer": "renPan",
  "algorithm": {
    "templateId": "relativeOffset",
    "params": {
      "sourceDeityId": "jiShen",
      "offset": 0,
      "palaceSystem": "sixteenZhengJian"
    }
  },
  "priority": 12,
  "source": "official",
  "tier": "core"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('si-shen.json', '{
  "id": "siShen",
  "name": "四神",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 36,
          "step": 3,
          "label": "宫"
        }
      ],
      "palaceSystem": "mixed",
      "palaceSeq": [
        {
          "palace": "乾"
        },
        {
          "palace": "离"
        },
        {
          "palace": "艮"
        },
        {
          "palace": "震"
        },
        {
          "palace": "中"
        },
        {
          "palace": "兑"
        },
        {
          "palace": "坤"
        },
        {
          "palace": "坎"
        },
        {
          "palace": "巽"
        },
        {
          "palace": "巳"
        },
        {
          "palace": "申"
        },
        {
          "palace": "寅"
        }
      ],
      "direction": "forward",
      "startPalace": "乾"
    }
  },
  "priority": 26,
  "source": "official",
  "tier": "auspicious"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('sui-po.json', '{
  "id": "suiPo",
  "name": "岁破",
  "layer": "shenPan",
  "algorithm": {
    "templateId": "relativeOffset",
    "params": {
      "sourceDeityId": "taiSui",
      "offset": 6
    }
  },
  "priority": 41,
  "source": "official",
  "tier": "chronos"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('tai-sui.json', '{
  "id": "taiSui",
  "name": "太岁",
  "layer": "shenPan",
  "algorithm": {
    "templateId": "branchWalker",
    "params": {
      "cycle": 60,
      "branches": [
        "子",
        "丑",
        "寅",
        "卯",
        "辰",
        "巳",
        "午",
        "未",
        "申",
        "酉",
        "戌",
        "亥"
      ]
    }
  },
  "priority": 40,
  "source": "official",
  "tier": "chronos"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('tai-yi.json', '{
  "id": "taiYi",
  "name": "太乙",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 72,
          "step": 3,
          "label": "宫"
        }
      ],
      "palaceSystem": "nineGong",
      "direction": "forward",
      "startPalace": "乾"
    }
  },
  "priority": 1,
  "source": "official",
  "tier": "core"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('tian-fu.json', '{
  "id": "tianFu",
  "name": "天符",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 72,
          "step": 9,
          "label": "宫"
        }
      ],
      "palaceSystem": "nineGong",
      "direction": "forward",
      "startPalace": "兑"
    }
  },
  "priority": 35,
  "source": "official",
  "tier": "auspicious",
  "chartTypes": ["year", "month", "day"],
  "schoolScopes": ["jingMirror", "tongZong", "jiCheng", "fuYing"]
}
');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('tian-huang.json', '{
  "id": "tianHuang",
  "name": "天皇",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 200,
          "step": 20,
          "label": "周"
        },
        {
          "cycle": 20,
          "step": 1,
          "label": "宫"
        }
      ],
      "palaceSystem": "sixteenZhengJian",
      "palaceSeq": [
        {
          "palace": "申"
        },
        {
          "palace": "酉"
        },
        {
          "palace": "戌"
        },
        {
          "palace": "乾",
          "staySteps": 2
        },
        {
          "palace": "亥"
        },
        {
          "palace": "子"
        },
        {
          "palace": "丑"
        },
        {
          "palace": "艮",
          "staySteps": 2
        },
        {
          "palace": "寅"
        },
        {
          "palace": "卯"
        },
        {
          "palace": "辰"
        },
        {
          "palace": "巽",
          "staySteps": 2
        },
        {
          "palace": "巳"
        },
        {
          "palace": "午"
        },
        {
          "palace": "未"
        },
        {
          "palace": "坤",
          "staySteps": 2
        }
      ],
      "direction": "forward",
      "startPalace": "申"
    }
  },
  "priority": 30,
  "source": "official",
  "tier": "auspicious",
  "chartTypes": ["year", "month", "day"],
  "schoolScopes": ["jingMirror", "tongZong", "jiCheng", "fuYing"]
}
');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('tian-yi-star.json', '{
  "id": "tianYiStar",
  "name": "天乙",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 360,
          "step": 36,
          "label": "周"
        },
        {
          "cycle": 36,
          "step": 3,
          "label": "宫"
        }
      ],
      "palaceSystem": "sixteenZhengJian",
      "palaceSeq": [
        {
          "palace": "酉"
        },
        {
          "palace": "申"
        },
        {
          "palace": "子"
        },
        {
          "palace": "巳"
        },
        {
          "palace": "戌"
        },
        {
          "palace": "未"
        },
        {
          "palace": "丑"
        },
        {
          "palace": "亥"
        },
        {
          "palace": "午"
        },
        {
          "palace": "寅"
        },
        {
          "palace": "卯"
        },
        {
          "palace": "辰"
        }
      ],
      "direction": "forward",
      "startPalace": "酉"
    }
  },
  "priority": 27,
  "source": "official",
  "tier": "auspicious"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('wen-chang.json', '{
  "id": "wenChang",
  "name": "文昌",
  "layer": "renPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 18,
          "step": 1,
          "label": "步"
        }
      ],
      "palaceSystem": "sixteenZhengJian",
      "yangConfig": {
        "direction": "forward",
        "startPalace": "申",
        "palaceSeq": [
          {
            "palace": "申"
          },
          {
            "palace": "酉"
          },
          {
            "palace": "戌"
          },
          {
            "palace": "乾",
            "staySteps": 2
          },
          {
            "palace": "亥"
          },
          {
            "palace": "子"
          },
          {
            "palace": "丑"
          },
          {
            "palace": "艮"
          },
          {
            "palace": "寅"
          },
          {
            "palace": "卯"
          },
          {
            "palace": "辰"
          },
          {
            "palace": "巽"
          },
          {
            "palace": "巳"
          },
          {
            "palace": "午"
          },
          {
            "palace": "未"
          },
          {
            "palace": "坤",
            "staySteps": 2
          }
        ]
      },
      "yinConfig": {
        "direction": "reverse",
        "startPalace": "寅",
        "palaceSeq": [
          {
            "palace": "申"
          },
          {
            "palace": "未"
          },
          {
            "palace": "坤",
            "staySteps": 2
          },
          {
            "palace": "午"
          },
          {
            "palace": "巳"
          },
          {
            "palace": "巽"
          },
          {
            "palace": "辰"
          },
          {
            "palace": "卯"
          },
          {
            "palace": "寅"
          },
          {
            "palace": "艮"
          },
          {
            "palace": "丑"
          },
          {
            "palace": "子"
          },
          {
            "palace": "亥"
          },
          {
            "palace": "乾",
            "staySteps": 2
          },
          {
            "palace": "戌"
          },
          {
            "palace": "酉"
          }
        ]
      }
    }
  },
  "priority": 10,
  "source": "official",
  "tier": "core"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('wu-fu.json', '{
  "id": "wuFu",
  "name": "五福",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 225,
          "step": 45,
          "label": "宫"
        }
      ],
      "palaceSystem": "mixed",
      "palaceSeq": [
        {
          "palace": "乾"
        },
        {
          "palace": "艮"
        },
        {
          "palace": "巽"
        },
        {
          "palace": "坤"
        },
        {
          "palace": "中"
        }
      ],
      "direction": "forward",
      "startPalace": "乾"
    }
  },
  "priority": 23,
  "source": "official",
  "tier": "auspicious"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('xian-chi.json', '{
  "id": "xianChi",
  "name": "咸池",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 120,
          "step": 15,
          "label": "宫"
        }
      ],
      "palaceSystem": "nineGong",
      "direction": "forward",
      "startPalace": "坎"
    }
  },
  "priority": 36,
  "source": "official",
  "tier": "auspicious",
  "chartTypes": ["year", "month", "day"],
  "schoolScopes": ["jingMirror", "tongZong", "jiCheng", "fuYing"]
}
');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('xiao-you.json', '{
  "id": "xiaoYou",
  "name": "小游",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 360,
          "step": 24,
          "label": "宫"
        },
        {
          "cycle": 24,
          "step": 3,
          "label": "年"
        }
      ],
      "palaceSystem": "mixed",
      "palaceSeq": [
        {
          "palace": "乾"
        },
        {
          "palace": "离"
        },
        {
          "palace": "艮"
        },
        {
          "palace": "震"
        },
        {
          "palace": "兑"
        },
        {
          "palace": "坤"
        },
        {
          "palace": "坎"
        },
        {
          "palace": "巽"
        }
      ],
      "direction": "forward",
      "startPalace": "乾"
    }
  },
  "priority": 25,
  "source": "official",
  "tier": "auspicious"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('xuan-wu.json', '{
  "id": "xuanWu",
  "name": "玄武",
  "layer": "shenPan",
  "algorithm": {
    "templateId": "fixedPosition",
    "params": {
      "gong": "坎"
    }
  },
  "priority": 48,
  "source": "official",
  "tier": "weather"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('xuan-yuan.json', '{
  "id": "xuanYuan",
  "name": "轩辕",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 40,
          "step": 5,
          "label": "宫"
        }
      ],
      "palaceSystem": "nineGong",
      "direction": "forward",
      "startPalace": "离"
    }
  },
  "priority": 33,
  "source": "official",
  "tier": "auspicious",
  "chartTypes": ["year", "month", "day"],
  "schoolScopes": ["jingMirror", "tongZong", "jiCheng", "fuYing"]
}
');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('yang-jiu.json', '{
  "id": "yangJiu",
  "name": "阳九",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 4560,
          "step": 456,
          "label": "阳九"
        },
        {
          "cycle": 456,
          "step": 38,
          "label": "邦"
        }
      ],
      "palaceSystem": "sixteenZhengJian",
      "direction": "forward",
      "startPalace": "寅"
    }
  },
  "priority": 30,
  "source": "official",
  "tier": "spiritual",
  "chartTypes": [
    "year",
    "month"
  ]
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('yu-shi.json', '{
  "id": "yuShi",
  "name": "雨师",
  "layer": "shenPan",
  "algorithm": {
    "templateId": "branchWalker",
    "params": {
      "cycle": 12,
      "branches": [
        "酉",
        "戌",
        "亥",
        "子",
        "丑",
        "寅",
        "卯",
        "辰",
        "巳",
        "午",
        "未",
        "申"
      ]
    }
  },
  "priority": 50,
  "source": "official",
  "tier": "weather"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('yu-tang.json', '{
  "id": "yuTang",
  "name": "玉堂",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 24,
          "step": 3,
          "label": "宫"
        }
      ],
      "palaceSystem": "nineGong",
      "direction": "forward",
      "startPalace": "离"
    }
  },
  "priority": 39,
  "source": "official",
  "tier": "auspicious",
  "chartTypes": ["year", "month", "day"],
  "schoolScopes": ["jingMirror", "tongZong", "jiCheng", "fuYing"]
}
');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('zhao-yao.json', '{
  "id": "zhaoYao",
  "name": "招摇",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 48,
          "step": 6,
          "label": "宫"
        }
      ],
      "palaceSystem": "nineGong",
      "direction": "forward",
      "startPalace": "震"
    }
  },
  "priority": 34,
  "source": "official",
  "tier": "auspicious",
  "chartTypes": ["year", "month", "day"],
  "schoolScopes": ["jingMirror", "tongZong", "jiCheng", "fuYing"]
}
');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('zhi-fu-star.json', '{
  "id": "zhiFuStar",
  "name": "直符",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 360,
          "step": 36,
          "label": "周"
        },
        {
          "cycle": 36,
          "step": 3,
          "label": "宫"
        }
      ],
      "palaceSystem": "sixteenZhengJian",
      "palaceSeq": [
        {
          "palace": "酉"
        },
        {
          "palace": "申"
        },
        {
          "palace": "子"
        },
        {
          "palace": "巳"
        },
        {
          "palace": "戌"
        },
        {
          "palace": "未"
        },
        {
          "palace": "丑"
        },
        {
          "palace": "亥"
        },
        {
          "palace": "午"
        },
        {
          "palace": "寅"
        },
        {
          "palace": "卯"
        },
        {
          "palace": "辰"
        }
      ],
      "direction": "forward",
      "startPalace": "中"
    }
  },
  "priority": 29,
  "source": "official",
  "tier": "auspicious"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('zhi-fu.json', '{
  "id": "zhiFu",
  "name": "直符",
  "layer": "shenPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "baseVariable": "ji",
      "correction": 0,
      "steps": [
        { "cycle": 360, "step": 36, "label": "周" },
        { "cycle": 36, "step": 3, "label": "宫" }
      ],
      "palaceSystem": "nineGong",
      "palaceSeq": [
        { "palace": "中" },
        { "palace": "兑" },
        { "palace": "坤" },
        { "palace": "坎" },
        { "palace": "巽" },
        { "palace": "绛宫" },
        { "palace": "明堂" },
        { "palace": "玉堂" },
        { "palace": "乾" },
        { "palace": "离" },
        { "palace": "艮" },
        { "palace": "震" }
      ],
      "direction": "forward",
      "startPalace": "中"
    }
  },
  "priority": 42,
  "source": "official",
  "tier": "chronos"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('zhu-can-jiang.json', '{
  "id": "zhuCanJiang",
  "name": "主参将",
  "layer": "renPan",
  "algorithm": {
    "templateId": "fixedPosition",
    "params": {
      "gong": "中"
    }
  },
  "priority": 4,
  "source": "official",
  "tier": "generals"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('zhu-da-jiang.json', '{
  "id": "zhuDaJiang",
  "name": "主大将",
  "layer": "renPan",
  "algorithm": {
    "templateId": "fixedPosition",
    "params": {
      "gong": "中"
    }
  },
  "priority": 2,
  "source": "official",
  "tier": "generals"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('zhu-que.json', '{
  "id": "zhuQue",
  "name": "朱雀",
  "layer": "shenPan",
  "algorithm": {
    "templateId": "fixedPosition",
    "params": {
      "gong": "离"
    }
  },
  "priority": 46,
  "source": "official",
  "tier": "weather"
}');
INSERT INTO deities_document ("file_name", "payload_json") VALUES ('zi-wei.json', '{
  "id": "ziWei",
  "name": "紫微",
  "layer": "tianPan",
  "algorithm": {
    "templateId": "steppedCycle",
    "params": {
      "correction": 0,
      "steps": [
        {
          "cycle": 180,
          "step": 18,
          "label": "周"
        },
        {
          "cycle": 18,
          "step": 1,
          "label": "宫"
        }
      ],
      "palaceSystem": "sixteenZhengJian",
      "palaceSeq": [
        {
          "palace": "寅"
        },
        {
          "palace": "卯"
        },
        {
          "palace": "辰"
        },
        {
          "palace": "巽"
        },
        {
          "palace": "巳"
        },
        {
          "palace": "午"
        },
        {
          "palace": "未"
        },
        {
          "palace": "坤",
          "staySteps": 2
        },
        {
          "palace": "申"
        },
        {
          "palace": "酉"
        },
        {
          "palace": "戌"
        },
        {
          "palace": "乾",
          "staySteps": 2
        },
        {
          "palace": "亥"
        },
        {
          "palace": "子"
        },
        {
          "palace": "丑"
        },
        {
          "palace": "艮"
        }
      ],
      "direction": "forward",
      "startPalace": "寅"
    }
  },
  "priority": 31,
  "source": "official",
  "tier": "auspicious",
  "chartTypes": ["year", "month", "day"],
  "schoolScopes": ["jingMirror", "tongZong", "jiCheng", "fuYing"]
}
');
