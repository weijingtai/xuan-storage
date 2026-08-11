BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS school_dataset_document (  file_name TEXT PRIMARY KEY,  payload_json TEXT NOT NULL);
INSERT INTO school_dataset_document ("file_name", "payload_json") VALUES ('daliuren_dataset.json', '{
  "version": "1.0.0",
  "description": "大六壬数据集",
  "天干": [
    "甲",
    "乙",
    "丙",
    "丁",
    "戊",
    "己",
    "庚",
    "辛",
    "壬",
    "癸"
  ],
  "地支": [
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
}');
COMMIT;
