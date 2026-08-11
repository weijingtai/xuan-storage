CREATE TABLE IF NOT EXISTS formulas_document (  file_name TEXT PRIMARY KEY,  payload_json TEXT NOT NULL);
DELETE FROM formulas_document;
INSERT INTO formulas_document ("file_name", "payload_json") VALUES ('huang_ji_1_formula.json', '{
  "id": 1,
  "name": "皇极取数法一",
  "description": "来源《铁板神数预测学》中《皇极取数》",
  "groups": [
    {
      "groupId": "元会·基础数一",
      "description": "元会基础数 + 年干(千位数） = 条文数` 以及根据次派生出的条文数",
      "baseNumberDefinition": {
        "name": "元会·基础数一",
        "description": "元会数 + 年干(千位）= 条文数(用户选择)",
        "type": "derived",
        "isSelectable": false,
        "parentGroupId": "元会·基础数一",
        "baseNumberDefinition": {
          "name": "元会基础数",
          "description": "元会基础数",
          "type": "predefined",
          "isSelectable": false,
          "source": "元会"
        },
        "parts": [
          {
            "name": "年干(千位数）",
            "description": "年干太玄数 * 1000",
            "type": "singleNumber",
            "fourZhuGanZhiType": "天干",
            "fourZhuName": "年柱",
            "numberPlace": "千"
          }
        ]
      },
      "formulas": [
        {
          "name": "年支(千位数）",
          "description": "元会·基础数一 + 年支(千位数）",
          "parts": [
            {
              "name": "年支(千位数）",
              "description": "年支太玄数 * 1000",
              "type": "singleNumber",
              "fourZhuGanZhiType": "地支",
              "fourZhuName": "年柱",
              "numberPlace": "千"
            }
          ]
        },
        {
          "name": "月支(百位数）",
          "description": "元会·基础数一 + 月支(百位数）",
          "parts": [
            {
              "name": "月支(百位数）",
              "description": "月支太玄数 * 100",
              "type": "singleNumber",
              "fourZhuGanZhiType": "地支",
              "fourZhuName": "月柱",
              "numberPlace": "百"
            }
          ]
        },
        {
          "name": "月干(百位数）",
          "description": "元会·基础数一 + 月干(百位数）",
          "parts": [
            {
              "name": "月干(百位数）",
              "description": "月干太玄数 * 100",
              "type": "singleNumber",
              "fourZhuGanZhiType": "天干",
              "fourZhuName": "月柱",
              "numberPlace": "百"
            }
          ]
        },
        {
          "name": "日干支互合数",
          "description": "元会·基础数一 + 日干支互数(干为十位+支为个位)",
          "parts": [
            {
              "name": "日干支互数",
              "description": "基础数 + 日干支互数(干为十位+支为个位) = 条文数",
              "type": "compositeNumber",
              "components": [
                {
                  "name": "日干十位",
                  "description": "日干太玄数 * 10",
                  "type": "singleNumber",
                  "fourZhuGanZhiType": "天干",
                  "fourZhuName": "日柱",
                  "numberPlace": "十"
                },
                {
                  "name": "日支个位",
                  "description": "日支太玄数",
                  "type": "singleNumber",
                  "fourZhuGanZhiType": "地支",
                  "fourZhuName": "日柱",
                  "numberPlace": "个"
                }
              ]
            }
          ]
        },
        {
          "name": "时干(个位数）",
          "description": "元会·基础数一 + 时干(个位数）",
          "parts": [
            {
              "name": "时干(个位数）",
              "description": "时干太玄数",
              "type": "singleNumber",
              "fourZhuGanZhiType": "天干",
              "fourZhuName": "时柱",
              "numberPlace": "个"
            }
          ]
        },
        {
          "name": "时支(个位数）",
          "description": "元会·基础数一 + 时支(个位数）",
          "parts": [
            {
              "name": "时支(个位数）",
              "description": "时支太玄数",
              "type": "singleNumber",
              "fourZhuGanZhiType": "地支",
              "fourZhuName": "时柱",
              "numberPlace": "个"
            }
          ]
        },
        {
          "name": "日互合+时支(个位数）",
          "description": "元会·基础数一 + 日互合(干为十位+支为个位) +时支(个位数）",
          "parts": [
            {
              "name": "日互合(干为十位+支为个位)",
              "description": "日互合(干为十位+支为个位)",
              "type": "compositeNumber",
              "components": [
                {
                  "name": "日干十位",
                  "description": "日干太玄数 * 10",
                  "type": "singleNumber",
                  "fourZhuGanZhiType": "天干",
                  "fourZhuName": "日柱",
                  "numberPlace": "十"
                },
                {
                  "name": "日支个位",
                  "description": "日支太玄数",
                  "type": "singleNumber",
                  "fourZhuGanZhiType": "地支",
                  "fourZhuName": "日柱",
                  "numberPlace": "个"
                }
              ]
            },
            {
              "name": "时支(个位数）",
              "description": "时支太玄数",
              "type": "singleNumber",
              "fourZhuGanZhiType": "地支",
              "fourZhuName": "时柱",
              "numberPlace": "个"
            }
          ]
        },
        {
          "name": "日互合+时干(个位数）",
          "description": "元会·基础数一 + 日互合(干为十位+支为个位) +时干(个位数）",
          "parts": [
            {
              "name": "日互合(干为十位+支为个位)",
              "description": "日互合(干为十位+支为个位)",
              "type": "compositeNumber",
              "components": [
                {
                  "name": "日干十位",
                  "description": "日干太玄数 * 10",
                  "type": "singleNumber",
                  "fourZhuGanZhiType": "天干",
                  "fourZhuName": "日柱",
                  "numberPlace": "十"
                },
                {
                  "name": "日支个位",
                  "description": "日支太玄数",
                  "type": "singleNumber",
                  "fourZhuGanZhiType": "地支",
                  "fourZhuName": "日柱",
                  "numberPlace": "个"
                }
              ]
            },
            {
              "name": "时干(个位数）",
              "description": "时干太玄数",
              "type": "singleNumber",
              "fourZhuGanZhiType": "天干",
              "fourZhuName": "时柱",
              "numberPlace": "个"
            }
          ]
        }
      ]
    },
    {
      "groupId": "运世基础数",
      "description": "运世基础数 进行的相关条文数计算",
      "baseNumberDefinition": {
        "name": "运世基础数",
        "description": "运世基础数",
        "type": "predefined",
        "isSelectable": false,
        "source": "运世"
      },
      "formulas": [
        {
          "name": "日互合数",
          "description": "运世基础数 + 日干支互合数",
          "parts": [
            {
              "name": "日互合(干为十位+支为个位)",
              "description": "日互合(干为十位+支为个位)",
              "type": "compositeNumber",
              "components": [
                {
                  "name": "日干十位",
                  "description": "日干太玄数 * 10",
                  "type": "singleNumber",
                  "fourZhuGanZhiType": "天干",
                  "fourZhuName": "日柱",
                  "numberPlace": "十"
                },
                {
                  "name": "日支个位",
                  "description": "日支太玄数",
                  "type": "singleNumber",
                  "fourZhuGanZhiType": "地支",
                  "fourZhuName": "日柱",
                  "numberPlace": "个"
                }
              ]
            }
          ]
        },
        {
          "name": "时干个位",
          "description": "运世基础数 + 时干个位数",
          "parts": [
            {
              "name": "时干个位数",
              "description": "时干太玄数",
              "type": "singleNumber",
              "fourZhuGanZhiType": "天干",
              "fourZhuName": "时柱",
              "numberPlace": "个"
            }
          ]
        },
        {
          "name": "时支个位",
          "description": "运世基础数 + 时支个位数",
          "parts": [
            {
              "name": "时支个位数",
              "description": "时支太玄数",
              "type": "singleNumber",
              "fourZhuGanZhiType": "地支",
              "fourZhuName": "时柱",
              "numberPlace": "个"
            }
          ]
        },
        {
          "name": "日互合数+时干个位",
          "description": "运世基础数 + 日干支互合数 + 时干个位数",
          "parts": [
            {
              "name": "日互合(干为十位+支为个位)",
              "description": "日互合(干为十位+支为个位)",
              "type": "compositeNumber",
              "components": [
                {
                  "name": "日干十位",
                  "description": "日干太玄数 * 10",
                  "type": "singleNumber",
                  "fourZhuGanZhiType": "天干",
                  "fourZhuName": "日柱",
                  "numberPlace": "十"
                },
                {
                  "name": "日支个位",
                  "description": "日支太玄数",
                  "type": "singleNumber",
                  "fourZhuGanZhiType": "地支",
                  "fourZhuName": "日柱",
                  "numberPlace": "个"
                }
              ]
            },
            {
              "name": "时干个位数",
              "description": "时干太玄数",
              "type": "singleNumber",
              "fourZhuGanZhiType": "天干",
              "fourZhuName": "时柱",
              "numberPlace": "个"
            }
          ]
        },
        {
          "name": "日互合数+时支个位",
          "description": "运世基础数 + 日干支互合数 + 时支个位数",
          "parts": [
            {
              "name": "日互合(干为十位+支为个位)",
              "description": "日互合(干为十位+支为个位)",
              "type": "compositeNumber",
              "components": [
                {
                  "name": "日干十位",
                  "description": "日干太玄数 * 10",
                  "type": "singleNumber",
                  "fourZhuGanZhiType": "天干",
                  "fourZhuName": "日柱",
                  "numberPlace": "十"
                },
                {
                  "name": "日支个位",
                  "description": "日支太玄数",
                  "type": "singleNumber",
                  "fourZhuGanZhiType": "地支",
                  "fourZhuName": "日柱",
                  "numberPlace": "个"
                }
              ]
            },
            {
              "name": "时支个位数",
              "description": "时支太玄数",
              "type": "singleNumber",
              "fourZhuGanZhiType": "地支",
              "fourZhuName": "时柱",
              "numberPlace": "个"
            }
          ]
        }
      ]
    }
  ]
}');
INSERT INTO formulas_document ("file_name", "payload_json") VALUES ('huang_ji_2_formula.json', '{
  "id": 2,
  "name": "皇极取数法二",
  "description": "来源《图解易经铁板神数》中《元会运世（一）》",
  "groups": [
    {
      "groupId": "元会·基础数一",
      "description": "元会基础数 + 年干(千位数） = 条文数` 以及根据次派生出的条文数",
      "baseNumberDefinition": {
        "name": "元会基础数",
        "description": "根据元会基础数+年干(千位数）=条文数(用户选择)",
        "type": "selectable",
        "isSelectable": false,
        "initialCandidateFormula": {
          "name": "元会·基础数一",
          "description": "元会数 + 年干(千位）= 条文数(用户选择)",
          "type": "derived",
          "isSelectable": false,
          "parentGroupId": "元会·基础数一",
          "baseNumberDefinition": {
            "name": "元会基础数",
            "description": "元会基础数",
            "type": "predefined",
            "isSelectable": false,
            "source": "元会"
          },
          "parts": [
            {
              "name": "年干(千位数）",
              "description": "年干太玄数 * 1000",
              "type": "singleNumber",
              "fourZhuGanZhiType": "天干",
              "fourZhuName": "年柱",
              "numberPlace": "千"
            }
          ]
        }
      },
      "formulas": [
        {
          "name": "月干太玄(百位数）",
          "description": "元会·基础数一 + 月干(百位数）",
          "parts": [
            {
              "name": "月干(百位数）",
              "description": "月干太玄数 * 100",
              "type": "singleNumber",
              "fourZhuGanZhiType": "天干",
              "fourZhuName": "月柱",
              "numberPlace": "百"
            }
          ]
        },
        {
          "name": "日干(十位数）",
          "description": "元会·基础数一 + 日干(十位数）",
          "parts": [
            {
              "name": "日干(十位数）",
              "description": "日干太玄数 * 10",
              "type": "singleNumber",
              "fourZhuGanZhiType": "天干",
              "fourZhuName": "日柱",
              "numberPlace": "十"
            }
          ]
        },
        {
          "name": "时干(个位数）",
          "description": "元会·基础数一 + 时干(个位数）",
          "parts": [
            {
              "name": "时干(个位数）",
              "description": "时干太玄数(个位)",
              "type": "singleNumber",
              "fourZhuGanZhiType": "天干",
              "fourZhuName": "时柱",
              "numberPlace": "个"
            }
          ]
        },
        {
          "name": "日干(个位数）",
          "description": "元会·基础数一 + 日干(个位数）",
          "parts": [
            {
              "name": "日干(个位数）",
              "description": "日干太玄数(个位)",
              "type": "singleNumber",
              "fourZhuGanZhiType": "天干",
              "fourZhuName": "日柱",
              "numberPlace": "个"
            }
          ]
        }
      ]
    },
    {
      "groupId": "运世·基础数一",
      "description": "运世基础数 + 年干(千位数） = 条文数` 以及根据次派生出的条文数",
      "baseNumberDefinition": {
        "name": "运世·基础数一",
        "description": "运世基础数 + 年干(千位）= 条文数(用户选择)",
        "type": "derived",
        "isSelectable": false,
        "parentGroupId": "运世·基础数一",
        "baseNumberDefinition": {
          "name": "运世基础数",
          "description": "运世基础数",
          "type": "predefined",
          "isSelectable": false,
          "source": "运世"
        },
        "parts": [
          {
            "name": "年干(千位数）",
            "description": "年干太玄数 * 1000",
            "type": "singleNumber",
            "fourZhuGanZhiType": "天干",
            "fourZhuName": "年柱",
            "numberPlace": "千"
          }
        ]
      },
      "formulas": [
        {
          "name": "月干太玄(百位数）",
          "description": "运世·基础数一 + 月干(百位数）",
          "parts": [
            {
              "name": "月干(百位数）",
              "description": "月干太玄数 * 100",
              "type": "singleNumber",
              "fourZhuGanZhiType": "天干",
              "fourZhuName": "月柱",
              "numberPlace": "百"
            }
          ]
        },
        {
          "name": "日干(十位数）",
          "description": "运世·基础数一 + 日干(十位数）",
          "parts": [
            {
              "name": "日干(十位数）",
              "description": "日干太玄数 * 10",
              "type": "singleNumber",
              "fourZhuGanZhiType": "天干",
              "fourZhuName": "日柱",
              "numberPlace": "十"
            }
          ]
        },
        {
          "name": "时干(个位数）",
          "description": "运世·基础数一 + 时干(个位数）",
          "parts": [
            {
              "name": "时干(个位数）",
              "description": "时干太玄数(个位)",
              "type": "singleNumber",
              "fourZhuGanZhiType": "天干",
              "fourZhuName": "时柱",
              "numberPlace": "个"
            }
          ]
        },
        {
          "name": "日干(个位数）",
          "description": "运世·基础数一 + 日干(个位数）",
          "parts": [
            {
              "name": "日干(个位数）",
              "description": "日干太玄数(个位)",
              "type": "singleNumber",
              "fourZhuGanZhiType": "天干",
              "fourZhuName": "日柱",
              "numberPlace": "个"
            }
          ]
        }
      ]
    }
  ]
}');
INSERT INTO formulas_document ("file_name", "payload_json") VALUES ('huang_ji_3_formula.json', '{
  "id": 3,
  "name": "皇极取数法三",
  "description": "来源《图解易经铁板神数》中《元会运世（二）》",
  "groups": [
    {
      "groupId": "元会·基础数一",
      "description": "元会基础数 + 年干(千位数） = 条文数` 以及根据次派生出的条文数",
      "baseNumberDefinition": {
        "name": "元会基础数",
        "description": "根据元会基础数+年干(千位数）=条文数(用户选择)",
        "type": "selectable",
        "isSelectable": false,
        "initialCandidateFormula": {
          "name": "元会·基础数一",
          "description": "元会数 + 年干(千位）= 条文数(用户选择)",
          "type": "derived",
          "isSelectable": false,
          "parentGroupId": "元会·基础数一",
          "baseNumberDefinition": {
            "name": "元会基础数",
            "description": "元会基础数",
            "type": "predefined",
            "isSelectable": false,
            "source": "元会"
          },
          "parts": [
            {
              "name": "年干(千位数）",
              "description": "年干太玄数 * 1000",
              "type": "singleNumber",
              "fourZhuGanZhiType": "天干",
              "fourZhuName": "年柱",
              "numberPlace": "千"
            }
          ]
        }
      },
      "formulas": [
        {
          "name": "月干太玄(百位数）",
          "description": "元会·基础数一 + 月干(百位数）",
          "parts": [
            {
              "name": "月干(百位数）",
              "description": "月干太玄数 * 100",
              "type": "singleNumber",
              "fourZhuGanZhiType": "天干",
              "fourZhuName": "月柱",
              "numberPlace": "百"
            }
          ]
        },
        {
          "name": "月支太玄(百位数）",
          "description": "元会·基础数一 + 月支(百位数）",
          "parts": [
            {
              "name": "月支(百位数）",
              "description": "月支太玄数 * 100",
              "type": "singleNumber",
              "fourZhuGanZhiType": "地支",
              "fourZhuName": "月柱",
              "numberPlace": "百"
            }
          ]
        }
      ]
    },
    {
      "groupId": "元会·基础数二",
      "description": "元会·基础数一(元会+年干千位) + 日干互合(干十位+时干个位数） = 条文数` 以及根据次派生出的条文数",
      "baseNumberDefinition": {
        "name": "元会基础数",
        "description": "根据元会基础数+年干(千位数）=条文数(用户选择)",
        "type": "selectable",
        "isSelectable": false,
        "initialCandidateFormula": {
          "name": "元会·基础数二",
          "description": "元会数 + 年干(千位）= 条文数(用户选择)",
          "type": "derived",
          "isSelectable": false,
          "parentGroupId": "元会·基础数二",
          "baseNumberDefinition": {
            "name": "元会基础数",
            "description": "元会基础数",
            "type": "derived",
            "isSelectable": false,
            "parentGroupId": "元会·基础数二",
            "baseNumberDefinition": {
              "name": "元会基础数",
              "description": "元会基础数",
              "type": "predefined",
              "isSelectable": false,
              "source": "元会"
            },
            "parts": [
              {
                "name": "年干(千位数）",
                "description": "年干太玄数 * 1000",
                "type": "singleNumber",
                "fourZhuGanZhiType": "天干",
                "fourZhuName": "年柱",
                "numberPlace": "千"
              }
            ]
          },
          "parts": [
            {
              "name": "日干互合(干十位+支个位)",
              "description": "日干互合(干十位+支个位)",
              "type": "compositeNumber",
              "components": [
                {
                  "name": "日干(十位）",
                  "description": "日干太玄数 * 10",
                  "type": "singleNumber",
                  "fourZhuGanZhiType": "天干",
                  "fourZhuName": "日柱",
                  "numberPlace": "十"
                },
                {
                  "name": "日支(个位数）",
                  "description": "日支太玄数",
                  "type": "singleNumber",
                  "fourZhuGanZhiType": "地支",
                  "fourZhuName": "日柱",
                  "numberPlace": "个"
                }
              ]
            }
          ]
        }
      },
      "formulas": [
        {
          "name": "时干太玄(个位数）",
          "description": "元会·基础数二 + 时干(个位数）",
          "parts": [
            {
              "name": "时干(个位数）",
              "description": "时干太玄数",
              "type": "singleNumber",
              "fourZhuGanZhiType": "天干",
              "fourZhuName": "时柱",
              "numberPlace": "个"
            }
          ]
        },
        {
          "name": "时支太玄(个位数）",
          "description": "元会·基础数二 + 时支(个位数）",
          "parts": [
            {
              "name": "时支(个位数）",
              "description": "时支太玄数",
              "type": "singleNumber",
              "fourZhuGanZhiType": "地支",
              "fourZhuName": "时柱",
              "numberPlace": "个"
            }
          ]
        }
      ]
    },
    {
      "groupId": "运世·基础数一",
      "description": "运世基础数 + 年干(千位数） = 条文数` 以及根据次派生出的条文数",
      "baseNumberDefinition": {
        "name": "运世基础数",
        "description": "根据运世基础数+年干(千位数）=条文数(用户选择)",
        "type": "selectable",
        "isSelectable": false,
        "initialCandidateFormula": {
          "name": "运世·基础数一",
          "description": "运世基础数 + 年干(千位）= 条文数(用户选择)",
          "type": "derived",
          "isSelectable": false,
          "parentGroupId": "运世·基础数一",
          "baseNumberDefinition": {
            "name": "运世基础数",
            "description": "运世基础数",
            "type": "predefined",
            "isSelectable": false,
            "source": "运世"
          },
          "parts": [
            {
              "name": "年干(千位数）",
              "description": "年干太玄数 * 1000",
              "type": "singleNumber",
              "fourZhuGanZhiType": "天干",
              "fourZhuName": "年柱",
              "numberPlace": "千"
            }
          ]
        }
      },
      "formulas": [
        {
          "name": "月干太玄(百位数）",
          "description": "运世·基础数一 + 月干(百位数）",
          "parts": [
            {
              "name": "月干(百位数）",
              "description": "月干太玄数 * 100",
              "type": "singleNumber",
              "fourZhuGanZhiType": "天干",
              "fourZhuName": "月柱",
              "numberPlace": "百"
            }
          ]
        },
        {
          "name": "月支太玄(百位数）",
          "description": "运世·基础数一 + 月支(百位数）",
          "parts": [
            {
              "name": "月支(百位数）",
              "description": "月支太玄数 * 100",
              "type": "singleNumber",
              "fourZhuGanZhiType": "地支",
              "fourZhuName": "月柱",
              "numberPlace": "百"
            }
          ]
        }
      ]
    },
    {
      "groupId": "运世·基础数二",
      "description": "运世·基础数一(运世+年干千位) + 日干互合(干十位+时干个位数） = 条文数` 以及根据次派生出的条文数",
      "baseNumberDefinition": {
        "name": "运世基础数",
        "description": "根据运世基础数+年干(千位数）=条文数(用户选择)",
        "type": "selectable",
        "isSelectable": false,
        "initialCandidateFormula": {
          "name": "运世·基础数二",
          "description": "运世数 + 年干(千位）= 条文数(用户选择)",
          "type": "derived",
          "isSelectable": false,
          "parentGroupId": "运世·基础数二",
          "baseNumberDefinition": {
            "name": "运世基础数",
            "description": "运世基础数",
            "type": "derived",
            "isSelectable": false,
            "parentGroupId": "运世·基础数二",
            "baseNumberDefinition": {
              "name": "运世基础数",
              "description": "运世基础数",
              "type": "predefined",
              "isSelectable": false,
              "source": "运世"
            },
            "parts": [
              {
                "name": "年干(千位数）",
                "description": "年干太玄数 * 1000",
                "type": "singleNumber",
                "fourZhuGanZhiType": "天干",
                "fourZhuName": "年柱",
                "numberPlace": "千"
              }
            ]
          },
          "parts": [
            {
              "name": "日干互合(干十位+支个位)",
              "description": "日干互合(干十位+支个位)",
              "type": "compositeNumber",
              "components": [
                {
                  "name": "日干(十位）",
                  "description": "日干太玄数 * 10",
                  "type": "singleNumber",
                  "fourZhuGanZhiType": "天干",
                  "fourZhuName": "日柱",
                  "numberPlace": "十"
                },
                {
                  "name": "日支(个位数）",
                  "description": "日支太玄数",
                  "type": "singleNumber",
                  "fourZhuGanZhiType": "地支",
                  "fourZhuName": "日柱",
                  "numberPlace": "个"
                }
              ]
            }
          ]
        }
      },
      "formulas": [
        {
          "name": "时干太玄(个位数）",
          "description": "运世·基础数二 + 时干(个位数）",
          "parts": [
            {
              "name": "时干(个位数）",
              "description": "时干太玄数",
              "type": "singleNumber",
              "fourZhuGanZhiType": "天干",
              "fourZhuName": "时柱",
              "numberPlace": "个"
            }
          ]
        },
        {
          "name": "时支太玄(个位数）",
          "description": "运世·基础数二 + 时支(个位数）",
          "parts": [
            {
              "name": "时支(个位数）",
              "description": "时支太玄数",
              "type": "singleNumber",
              "fourZhuGanZhiType": "地支",
              "fourZhuName": "时柱",
              "numberPlace": "个"
            }
          ]
        }
      ]
    }
  ]
}');


