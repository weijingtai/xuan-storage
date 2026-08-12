CREATE TABLE IF NOT EXISTS schema_document (  file_name TEXT PRIMARY KEY,  payload_json TEXT NOT NULL);
DELETE FROM schema_document;
INSERT INTO schema_document ("file_name", "payload_json") VALUES ('schema/layer-a-static-data.schema.json', '{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://xuan-migration/xunq-kanyu/layer-a-static-data.schema.json",
  "title": "Layer A 静态数据集 Schema",
  "description": "寻炁堪舆平台Layer A静态数据JSON配置文件格式规范。所有二十四山、分金、纳甲等静态查表数据均按此schema",
  "type": "object",
  "required": ["$schema", "configType", "layer", "id", "name", "version", "source", "description"],
  "properties": {
    "$schema": {
      "type": "string",
      "description": "JSON Schema引用路径"
    },
    "configType": {
      "type": "string",
      "enum": ["static"],
      "description": "配置类型：static=静态数据"
    },
    "layer": {
      "type": "string",
      "enum": ["A"],
      "description": "所属架构层级"
    },
    "id": {
      "type": "string",
      "description": "全局唯一标识符，格式：类别-名称-版本",
      "pattern": "^[a-z][a-z0-9-]+-[a-z][a-z0-9-]+-v\\d+$"
    },
    "name": {
      "type": "string",
      "description": "中文名称"
    },
    "version": {
      "type": "string",
      "pattern": "^\\d+\\.\\d+\\.\\d+$",
      "description": "语义版本号"
    },
    "source": {
      "type": "string",
      "description": "典籍来源或数据出处"
    },
    "description": {
      "type": "string",
      "description": "详细说明"
    },
    "dependsOn": {
      "type": "array",
      "items": {"type": "string"},
      "description": "依赖的其他Layer A配置文件ID列表"
    },
    "reuses": {
      "type": "string",
      "description": "复用的现有子项目代码路径或常量"
    },
    "note": {
      "type": "string",
      "description": "补充说明"
    },
    "phase": {
      "type": "string",
      "description": "所属开发阶段（如Phase 7）"
    },
    "testFixtures": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["description"],
        "properties": {
          "input": {},
          "expected": {},
          "description": {"type": "string"}
        }
      },
      "description": "内置自检用例，输入→期望输出的验证对"
    }
  },
  "additionalProperties": true
}
');
INSERT INTO schema_document ("file_name", "payload_json") VALUES ('schema/layer-b-rule-config.schema.json', '{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://xuan-migration/xunq-kanyu/layer-b-rule-config.schema.json",
  "title": "Layer B 算法规则配置 Schema",
  "description": "寻炁堪舆平台Layer B算法规则JSON配置文件格式规范。每套算法是一个声明式RuleSet定义",
  "type": "object",
  "required": ["$schema", "configType", "layer", "ruleId", "name", "version", "source", "authorType", "pipeline"],
  "properties": {
    "$schema": {"type": "string"},
    "configType": {"type": "string", "enum": ["rule"]},
    "layer": {"type": "string", "enum": ["B"]},
    "ruleId": {"type": "string", "description": "规则全局唯一ID，如 ba-zhai-you-nian-v1"},
    "name": {"type": "string", "description": "中文规则名称"},
    "version": {"type": "string", "pattern": "^\\d+\\.\\d+\\.\\d+$"},
    "source": {"type": "string", "description": "典籍来源"},
    "authorType": {
      "type": "string",
      "enum": ["built-in", "user"],
      "description": "官方预设(built-in)或用户自定义(user)"
    },
    "derivedFrom": {
      "type": "string",
      "description": "若为用户自定义，指向来源官方预设ruleId"
    },
    "changeNote": {
      "type": "string",
      "description": "用户自定义方案的修改说明"
    },
    "description": {"type": "string"},
    "category": {
      "type": "string",
      "enum": ["yangzhai", "yinzai", "common", "rendering"],
      "description": "规则分类"
    },
    "parameters": {
      "type": "array",
      "description": "规则需要的输入参数定义",
      "items": {
        "type": "object",
        "required": ["name", "type"],
        "properties": {
          "name": {"type": "string"},
          "type": {"type": "string", "description": "参数类型：Mountain24, Degree, Year, Gender, enum:value1|value2"},
          "required": {"type": "boolean", "default": true},
          "default": {},
          "description": {"type": "string"}
        }
      }
    },
    "dataRefs": {
      "type": "array",
      "description": "引用的Layer A静态数据文件ID列表",
      "items": {"type": "string"}
    },
    "pipeline": {
      "type": "array",
      "description": "算法执行步骤链",
      "items": {
        "type": "object",
        "required": ["step", "name", "action"],
        "properties": {
          "step": {"type": "integer", "description": "步骤序号（1-based）"},
          "name": {"type": "string", "description": "步骤名称"},
          "description": {"type": "string"},
          "action": {"type": "string", "description": "操作类型：lookup, compute, condition, normalize, classify"},
          "ref": {"type": "string", "description": "引用的数据表或规则ID"},
          "input": {"type": "object", "description": "步骤输入参数映射"},
          "output": {"type": "string", "description": "输出变量名"},
          "conditions": {"$ref": "#/definitions/conditionTree", "description": "条件判断树"},
          "flyTrack": {"type": "string", "description": "飞星轨迹常量名"},
          "flyDirection": {"type": "string", "description": "顺飞/逆飞判定"}
        }
      }
    },
    "outputs": {
      "type": "object",
      "description": "最终输出结构定义",
      "additionalProperties": {
        "type": "object",
        "properties": {
          "type": {"type": "string"},
          "description": {"type": "string"}
        }
      }
    },
    "testFixtures": {
      "type": "array",
      "description": "内置自检用例",
      "items": {
        "type": "object",
        "required": ["description"],
        "properties": {
          "input": {"type": "object", "description": "输入参数键值对"},
          "expected": {"type": "object", "description": "期望输出键值对"},
          "description": {"type": "string"}
        }
      }
    }
  },
  "definitions": {
    "conditionTree": {
      "type": "object",
      "required": ["type"],
      "properties": {
        "type": {
          "type": "string",
          "enum": ["and", "or", "not", "lookup", "compute", "compare"],
          "description": "条件类型"
        },
        "conditions": {
          "type": "array",
          "items": {"$ref": "#/definitions/conditionTree"},
          "description": "嵌套子条件（and/or/not使用时）"
        },
        "when": {"type": "string", "description": "条件表达式"},
        "then": {"type": "string", "description": "满足条件时的结论"}
      }
    }
  }
}
');
