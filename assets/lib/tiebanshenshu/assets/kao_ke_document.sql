BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS kao_ke_document (  file_name TEXT PRIMARY KEY,  payload_json TEXT NOT NULL);
INSERT INTO kao_ke_document ("file_name", "payload_json") VALUES ('geng_mu_jia_liu_du.json', '{
    "name": "庚木甲流度",
    "description": "推查男的结四次婚，娶四妻的先天定数",
    "zhiMapper": {
        "子": {"chiperText": "甲丙月月月丙", "chiperNumber": 12002, "yearGanZhi": "甲子"},
        "丑": {"chiperText": "甲丙月壬丙", "chiperNumber": 12052, "yearGanZhi": "乙丑"},
        "寅": {"chiperText": "甲丙甲月丙", "chiperNumber": 12102, "yearGanZhi": "甲寅"},
        "卯": {"chiperText": "甲丙甲壬丙", "chiperNumber": 12252, "yearGanZhi": "乙卯"},
        "辰": {"chiperText": "甲丙丙支丙", "chiperNumber": 12202, "yearGanZhi": "甲辰"},
        "巳": {"chiperText": "甲丙丙壬丙", "chiperNumber": 12252, "yearGanZhi": "乙巳"},
        "午": {"chiperText": "甲丙戊支丙", "chiperNumber": 12302, "yearGanZhi": "甲午"},
        "未": {"chiperText": "甲丙戊壬丙", "chiperNumber": 12352, "yearGanZhi": "乙未"},
        "申": {"chiperText": "甲丙庚月丙", "chiperNumber": 12402, "yearGanZhi": "甲申"},
        "酉": {"chiperText": "甲丙庚壬丙", "chiperNumber": 12452, "yearGanZhi": "乙酉"},
        "戌": {"chiperText": "甲丙壬月丙", "chiperNumber": 12502, "yearGanZhi": "甲戌"},
        "亥": {"chiperText": "甲丙壬壬丙", "chiperNumber": 12552, "yearGanZhi": "乙亥"}
    }
}');
INSERT INTO kao_ke_document ("file_name", "payload_json") VALUES ('jin_gong_jia_liu_du.json', '{
    "name": "金宫甲流度",
    "description": "用来推查丈夫的生年的先天定数",
    "zhiMapper": {
        "子": {"chiperText": "甲月戊乙戊", "chiperNumber": 10363, "yearGanZhi": "甲子"},
        "丑": {"chiperText": "甲月庚甲戊", "chiperNumber": 10413, "yearGanZhi": "乙丑"},
        "寅": {"chiperText": "甲月庚乙戊", "chiperNumber": 10463, "yearGanZhi": "甲寅"},
        "卯": {"chiperText": "甲月壬甲戊", "chiperNumber": 10513, "yearGanZhi": "乙卯"},
        "辰": {"chiperText": "甲月壬乙戊", "chiperNumber": 10563, "yearGanZhi": "甲辰"},
        "巳": {"chiperText": "甲月乙甲戊", "chiperNumber": 10613, "yearGanZhi": "乙巳"},
        "午": {"chiperText": "甲月乙乙戊", "chiperNumber": 10663, "yearGanZhi": "甲午"},
        "未": {"chiperText": "甲支丁甲戊", "chiperNumber": 10713, "yearGanZhi": "乙未"},
        "申": {"chiperText": "甲月丁乙戊", "chiperNumber": 10763, "yearGanZhi": "甲申"},
        "酉": {"chiperText": "甲月己乙戊", "chiperNumber": 10813, "yearGanZhi": "乙酉"},
        "戌": {"chiperText": "甲月己乙戊", "chiperNumber": 10863, "yearGanZhi": "甲戌"},
        "亥": {"chiperText": "甲月辛甲戊", "chiperNumber": 10913, "yearGanZhi": "乙亥"}
    }
}');
INSERT INTO kao_ke_document ("file_name", "payload_json") VALUES ('jin_jia_yi_liu_du.json', '{
    "name": "金甲乙流度",
    "description": "推查女人第二任丈夫生年的先天定数",
    "zhiMapper": {
        "子": {"chiperText": "甲丙庚月乙", "chiperNumber": 12406, "yearGanZhi": "甲子"},
        "丑": {"chiperText": "甲丙庚壬乙", "chiperNumber": 12456, "yearGanZhi": "乙丑"},
        "寅": {"chiperText": "甲丙壬月乙", "chiperNumber": 12506, "yearGanZhi": "甲寅"},
        "卯": {"chiperText": "甲丙壬壬乙", "chiperNumber": 12556, "yearGanZhi": "乙卯"},
        "辰": {"chiperText": "甲丙乙月乙", "chiperNumber": 12606, "yearGanZhi": "甲辰"},
        "巳": {"chiperText": "甲丙乙壬乙", "chiperNumber": 12656, "yearGanZhi": "乙巳"},
        "午": {"chiperText": "甲丙丁月乙", "chiperNumber": 12706, "yearGanZhi": "甲午"},
        "未": {"chiperText": "甲丙丁壬乙", "chiperNumber": 12756, "yearGanZhi": "乙未"},
        "申": {"chiperText": "甲丙己甲乙", "chiperNumber": 12806, "yearGanZhi": "甲申"},
        "酉": {"chiperText": "甲丙己壬乙", "chiperNumber": 12856, "yearGanZhi": "乙酉"},
        "戌": {"chiperText": "甲丙辛甲乙", "chiperNumber": 12906, "yearGanZhi": "甲戌"},
        "亥": {"chiperText": "甲丙辛壬乙", "chiperNumber": 12956, "yearGanZhi": "乙亥"}
    }
}');
INSERT INTO kao_ke_document ("file_name", "payload_json") VALUES ('jin_mu_jia_liu_du.json', '{
    "name": "金木甲流度",
    "description": "用来推查夫妻生年的先天定数",
    "zhiMapper": {
        "子": {"chiperText": "甲甲月月戊", "chiperNumber": 11003, "yearGanZhi": "甲子"},
        "丑": {"chiperText": "甲甲月壬戊", "chiperNumber": 11503, "yearGanZhi": "乙丑"},
        "寅": {"chiperText": "甲甲甲月戊", "chiperNumber": 11103, "yearGanZhi": "甲寅"},
        "卯": {"chiperText": "甲甲甲壬戊", "chiperNumber": 11153, "yearGanZhi": "乙卯"},
        "辰": {"chiperText": "甲甲丙月戊", "chiperNumber": 11203, "yearGanZhi": "甲辰"},
        "巳": {"chiperText": "甲甲丙壬戊", "chiperNumber": 11253, "yearGanZhi": "乙巳"},
        "午": {"chiperText": "甲甲戊月戊", "chiperNumber": 11303, "yearGanZhi": "甲午"},
        "未": {"chiperText": "甲甲戊壬戊", "chiperNumber": 11353, "yearGanZhi": "乙未"},
        "申": {"chiperText": "甲甲庚月戊", "chiperNumber": 11403, "yearGanZhi": "甲申"},
        "酉": {"chiperText": "甲甲庚壬戊", "chiperNumber": 11453, "yearGanZhi": "乙酉"},
        "戌": {"chiperText": "甲甲壬月戊", "chiperNumber": 11503, "yearGanZhi": "甲戌"},
        "亥": {"chiperText": "甲甲壬壬戊", "chiperNumber": 11553, "yearGanZhi": "乙亥"}
    }
}');
INSERT INTO kao_ke_document ("file_name", "payload_json") VALUES ('kun_gong_jia_liu_du.json', '{"name": "坤宫甲流度","description": "用来查母亲的生年的先天定数","zhiMapper": {"子": {"chiperText": "辛乙月壬", "chiperNumber": 9605},"丑": {"chiperText": "辛乙壬壬", "chiperNumber": 9655},"寅": {"chiperText": "辛丁月壬", "chiperNumber": 9705},"卯": {"chiperText": "辛丁壬壬", "chiperNumber": 9755},"辰": {"chiperText": "辛己月壬", "chiperNumber": 9805},"巳": {"chiperText": "辛己壬壬", "chiperNumber": 9855},"午": {"chiperText": "辛辛月壬", "chiperNumber": 9905},"未": {"chiperText": "辛辛壬壬", "chiperNumber": 9955},"申": {"chiperText": "甲月月支壬", "chiperNumber": 10005},"酉": {"chiperText": "甲月月壬壬", "chiperNumber": 10055},"戌": {"chiperText": "甲月甲月壬", "chiperNumber": 10105},"亥": {"chiperText": "甲月甲壬壬", "chiperNumber": 10155}}}');
INSERT INTO kao_ke_document ("file_name", "payload_json") VALUES ('mu_gong_jia_liu_du.json', '{
    "name": "木宫甲流度",
    "description": "用来推妻子的生年的先天定数",
    "zhiMapper": {
        "子": {"chiperText": "辛丁乙丁", "chiperNumber": 9767, "yearGanZhi": "甲子"},
        "丑": {"chiperText": "辛己甲丁", "chiperNumber": 9817, "yearGanZhi": "乙丑"},
        "寅": {"chiperText": "辛己乙丁", "chiperNumber": 9867, "yearGanZhi": "甲寅"},
        "卯": {"chiperText": "辛辛甲丁", "chiperNumber": 9867, "yearGanZhi": "乙卯"},
        "辰": {"chiperText": "辛辛乙丁", "chiperNumber": 9967, "yearGanZhi": "甲辰"},
        "巳": {"chiperText": "甲月月甲丁", "chiperNumber": 10017, "yearGanZhi": "乙巳"},
        "午": {"chiperText": "甲月月乙丁", "chiperNumber": 10067, "yearGanZhi": "甲午"},
        "未": {"chiperText": "甲月甲甲丁", "chiperNumber": 10117, "yearGanZhi": "乙未"},
        "申": {"chiperText": "甲月甲乙丁", "chiperNumber": 10167, "yearGanZhi": "甲申"},
        "酉": {"chiperText": "甲月丙甲丁", "chiperNumber": 10217, "yearGanZhi": "乙酉"},
        "戌": {"chiperText": "甲月丙乙丁", "chiperNumber": 10267, "yearGanZhi": "甲戌"},
        "亥": {"chiperText": "甲月戌甲丁", "chiperNumber": 10317, "yearGanZhi": "乙亥"}
    }
}');
INSERT INTO kao_ke_document ("file_name", "payload_json") VALUES ('mu_gong_jia_yi_du.json', '{
    "name": "木宫甲乙度",
    "description": "用来推男子结第二次婚，妻子的生年",
    "zhiMapper": {
        "子": {"chiperText": "辛己甲己", "chiperNumber": 9818, "yearGanZhi": "甲子"},
        "丑": {"chiperText": "辛己乙己", "chiperNumber": 9868, "yearGanZhi": "乙丑"},
        "寅": {"chiperText": "辛辛甲己", "chiperNumber": 9918, "yearGanZhi": "甲寅"},
        "卯": {"chiperText": "辛辛乙己", "chiperNumber": 9968, "yearGanZhi": "乙卯"},
        "辰": {"chiperText": "甲月月甲己", "chiperNumber": 10018, "yearGanZhi": "甲辰"},
        "巳": {"chiperText": "甲月月乙己", "chiperNumber": 10068, "yearGanZhi": "乙巳"},
        "午": {"chiperText": "甲月甲甲己", "chiperNumber": 10118, "yearGanZhi": "甲午"},
        "未": {"chiperText": "甲月甲乙己", "chiperNumber": 10168, "yearGanZhi": "乙未"},
        "申": {"chiperText": "甲月丙甲己", "chiperNumber": 10218, "yearGanZhi": "甲申"},
        "酉": {"chiperText": "甲月丙乙己", "chiperNumber": 10268, "yearGanZhi": "乙酉"},
        "戌": {"chiperText": "甲月戊甲己", "chiperNumber": 10318, "yearGanZhi": "甲戌"},
        "亥": {"chiperText": "甲月戊乙己", "chiperNumber": 10368, "yearGanZhi": "乙亥"}
    }
}');
INSERT INTO kao_ke_document ("file_name", "payload_json") VALUES ('na_bi_gua_jia.json', '{
    "name": "纳比卦（甲表）",
    "description": "推查兄弟若干先天定数",
    "gongEachList": [
        {"chiperText": "丁丁乙庚", "chiperNumber": 7764},
        {"chiperText": "丁壬庚甲", "chiperNumber": 7541},
        {"chiperText": "丁乙壬辛", "chiperNumber": 7659},
        {"chiperText": "丁辛丁戊", "chiperNumber": 7973},
        {"chiperText": "丁丁庚戊", "chiperNumber": 7743},
        {"chiperText": "戊庚己己", "chiperNumber": 8488},
        {"chiperText": "戊壬甲丁", "chiperNumber": 3517},
        {"chiperText": "戊壬庚辛", "chiperNumber": 3549},
        {"chiperText": "戊乙壬乙", "chiperNumber": 3656},
        {"chiperText": "戊庚乙己", "chiperNumber": 3468}
    ]
}');
INSERT INTO kao_ke_document ("file_name", "payload_json") VALUES ('na_bi_gua_yi.json', '{
    "name": "纳比卦（乙表）",
    "description": "纳比卦相关密数表",
    "zhiMapper": {
        "子": {"chiperText": "辛己乙戊", "chiperNumber": 9863},
        "丑": {"chiperText": "辛己丁戊", "chiperNumber": 9873},
        "寅": {"chiperText": "辛己己戊", "chiperNumber": 9883},
        "卯": {"chiperText": "辛己辛戊", "chiperNumber": 9893},
        "辰": {"chiperText": "辛辛癸戊", "chiperNumber": 9903},
        "巳": {"chiperText": "辛辛甲戊", "chiperNumber": 9913},
        "午": {"chiperText": "辛辛丙戊", "chiperNumber": 9923},
        "未": {"chiperText": "辛辛戊戊", "chiperNumber": 9933},
        "申": {"chiperText": "辛辛庚戊", "chiperNumber": 9943},
        "酉": {"chiperText": "辛辛壬戊", "chiperNumber": 9953},
        "戌": {"chiperText": "辛辛乙戊", "chiperNumber": 9963},
        "亥": {"chiperText": "辛辛丁戊", "chiperNumber": 9973}
    }
}');
INSERT INTO kao_ke_document ("file_name", "payload_json") VALUES ('na_gen_gua_bing.json', '{
    "name": "纳艮卦（丙表）",
    "description": "女儿相关密数表",
    "zhiMapper": {
        "子": {"chiperText": "甲丙丙庚戊", "chiperNumber": 12243},
        "丑": {"chiperText": "甲丙丙壬戊", "chiperNumber": 12253},
        "寅": {"chiperText": "甲丙丙乙戊", "chiperNumber": 12263},
        "卯": {"chiperText": "甲丙丙丁戊", "chiperNumber": 12273},
        "辰": {"chiperText": "甲丙丙己戊", "chiperNumber": 12283},
        "巳": {"chiperText": "甲丙丙辛戊", "chiperNumber": 12293},
        "午": {"chiperText": "甲丙丙癸戊", "chiperNumber": 12303},
        "未": {"chiperText": "甲丙戊甲戊", "chiperNumber": 12313},
        "申": {"chiperText": "甲丙戊丙戊", "chiperNumber": 12323},
        "酉": {"chiperText": "甲丙戊戊戊", "chiperNumber": 12333},
        "戌": {"chiperText": "甲丙戊庚戊", "chiperNumber": 12343},
        "亥": {"chiperText": "甲丙戊壬戊", "chiperNumber": 12353}
    }
}');
INSERT INTO kao_ke_document ("file_name", "payload_json") VALUES ('na_gen_gua_yi.json', '{
    "name": "纳艮卦（乙表）",
    "description": "用来推查儿子的生肖",
    "zhiMapper": {
        "子": {"chiperText": "甲丙甲丙戊", "chiperNumber": 12123},
        "丑": {"chiperText": "甲丙甲戊戊", "chiperNumber": 12133},
        "寅": {"chiperText": "申丙甲庚戊", "chiperNumber": 12143},
        "卯": {"chiperText": "甲丙甲壬戊", "chiperNumber": 12153},
        "辰": {"chiperText": "甲丙甲乙戊", "chiperNumber": 12163},
        "巳": {"chiperText": "甲丙甲丁戊", "chiperNumber": 12173},
        "午": {"chiperText": "甲丙甲己戊", "chiperNumber": 12183},
        "未": {"chiperText": "甲丙甲辛戊", "chiperNumber": 12193},
        "申": {"chiperText": "甲丙丙癸戊", "chiperNumber": 12203},
        "酉": {"chiperText": "甲丙丙丙戊", "chiperNumber": 12213},
        "亥": {"chiperText": "甲丙丙戊戊", "chiperNumber": 12233}
    }
}');
INSERT INTO kao_ke_document ("file_name", "payload_json") VALUES ('qian_gong_jia_liu_du.json', '{
    "name": "乾宫甲流度",
    "description": "可用来查父亲的生年的先天定数",
    "zhiMapper": {
        "子":{"chiperText": "辛月月戊","chiperNumber": 9003},
        "丑":{"chiperText": "辛月壬戊","chiperNumber": 9053},
        "寅":{"chiperText": "辛甲月戊","chiperNumber": 9103},
        "卯":{"chiperText": "辛甲壬戊","chiperNumber": 9153},
        "辰":{"chiperText": "辛丙月戊","chiperNumber": 9203},
        "巳":{"chiperText": "辛丙壬戊","chiperNumber": 9253},
        "午":{"chiperText": "辛戊月戊","chiperNumber": 9303},
        "未":{"chiperText": "辛戊壬戊","chiperNumber": 9353},
        "申":{"chiperText": "辛庚月戊","chiperNumber": 9403},
        "酉":{"chiperText": "辛庚壬戊","chiperNumber": 9453},
        "戌":{"chiperText": "辛壬月戊","chiperNumber": 9503},
        "亥":{"chiperText": "辛壬壬戊","chiperNumber": 9553}
    }
}
');
INSERT INTO kao_ke_document ("file_name", "payload_json") VALUES ('qian_kun_jia_liu_du.json', '{
    "name": "乾坤甲流度",
    "description": "推查父母同一生年的先天定数",
    "zhiMapper": {
        "子": {"chiperText": "辛月丙庚", "chiperNumber": 9024},
        "丑": {"chiperText": "辛甲庚庚", "chiperNumber": 9144},
        "寅": {"chiperText": "辛丙乙庚", "chiperNumber": 9264},
        "卯": {"chiperText": "辛戊己庚", "chiperNumber": 9384},
        "辰": {"chiperText": "辛壬月庚", "chiperNumber": 9504},
        "巳": {"chiperText": "辛乙丙庚", "chiperNumber": 9624},
        "午": {"chiperText": "辛丁庚庚", "chiperNumber": 9744},
        "未": {"chiperText": "辛己乙庚", "chiperNumber": 9864},
        "申": {"chiperText": "辛辛己庚", "chiperNumber": 9984},
        "酉": {"chiperText": "甲月甲月庚", "chiperNumber": 10104},
        "戌": {"chiperText": "甲月丙丙庚", "chiperNumber": 10224},
        "亥": {"chiperText": "甲月戊庚庚", "chiperNumber": 10344}
    }
}');
INSERT INTO kao_ke_document ("file_name", "payload_json") VALUES ('sheng_xian_month.json', '{
    "name": "升仙月爻密码",
    "description": "推查死于何月",
    "zhiMapper": {
        "子": {"chiperText": "庚己丙丙", "chiperNumber": 4822},
        "丑": {"chiperText": "戊丁庚丙", "chiperNumber": 3742},
        "寅": {"chiperText": "甲乙支壬", "chiperNumber": 1605},
        "卯": {"chiperText": "戊己辛辛", "chiperNumber": 3899},
        "辰": {"chiperText": "甲庚庚甲", "chiperNumber": 1441},
        "巳": {"chiperText": "壬乙乙己", "chiperNumber": 5668},
        "午": {"chiperText": "丙甲壬庚", "chiperNumber": 2154},
        "未": {"chiperText": "壬己乙己", "chiperNumber": 5868},
        "申": {"chiperText": "庚壬乙辛", "chiperNumber": 4569},
        "酉": {"chiperText": "丙庚丁丙", "chiperNumber": 2472},
        "戌": {"chiperText": "丙丙丙壬", "chiperNumber": 2225},
        "亥": {"chiperText": "庚丁庚戊", "chiperNumber": 4743}
    }
}');
INSERT INTO kao_ke_document ("file_name", "payload_json") VALUES ('sheng_xian_year.json', '{
    "name": "升仙年爻密码",
    "description": "推查死于何年",
    "zhiMapper": {
        "子": {"chiperText": "丁甲丁丁", "chiperNumber": 7177},
        "丑": {"chiperText": "丁甲月丙", "chiperNumber": 7102},
        "寅": {"chiperText": "壬甲壬甲", "chiperNumber": 5151},
        "卯": {"chiperText": "壬丙丙丙", "chiperNumber": 5222},
        "辰": {"chiperText": "壬乙乙壬", "chiperNumber": 5665},
        "巳": {"chiperText": "己己甲壬", "chiperNumber": 8815},
        "午": {"chiperText": "己壬己丁", "chiperNumber": 8387},
        "未": {"chiperText": "己壬甲壬", "chiperNumber": 8515},
        "申": {"chiperText": "壬己支己", "chiperNumber": 8508},
        "酉": {"chiperText": "壬壬乙丁", "chiperNumber": 5567},
        "戌": {"chiperText": "丁庚乙戊", "chiperNumber": 7463},
        "亥": {"chiperText": "丁丁乙壬", "chiperNumber": 7765}
    }
}');
INSERT INTO kao_ke_document ("file_name", "payload_json") VALUES ('shi_tu.json', '{
    "name": "师徒爻密数",
    "description": "推查师父生年的先天定数",
    "zhiMapper": {
        "子": {"chiperText": "甲甲月庚壬", "chiperNumber": 11045, "yearGanZhi": "甲子"},
        "丑": {"chiperText": "甲甲月辛壬", "chiperNumber": 11096, "yearGanZhi": "乙丑"},
        "寅": {"chiperText": "甲甲甲庚壬", "chiperNumber": 11145, "yearGanZhi": "甲寅"},
        "卯": {"chiperText": "甲甲甲辛壬", "chiperNumber": 11195, "yearGanZhi": "乙卯"},
        "辰": {"chiperText": "甲甲丙庚壬", "chiperNumber": 11245, "yearGanZhi": "甲辰"},
        "巳": {"chiperText": "甲甲丙辛壬", "chiperNumber": 11295, "yearGanZhi": "乙巳"},
        "午": {"chiperText": "甲甲戊庚壬", "chiperNumber": 11345, "yearGanZhi": "甲午"},
        "未": {"chiperText": "甲甲戊辛壬", "chiperNumber": 11395, "yearGanZhi": "乙未"},
        "申": {"chiperText": "甲甲庚庚壬", "chiperNumber": 11445, "yearGanZhi": "甲申"},
        "酉": {"chiperText": "甲甲庚辛壬", "chiperNumber": 11495, "yearGanZhi": "乙酉"},
        "戌": {"chiperText": "甲甲壬庚壬", "chiperNumber": 11545, "yearGanZhi": "甲戌"},
        "亥": {"chiperText": "甲甲壬辛壬", "chiperNumber": 11595, "yearGanZhi": "乙亥"}
    }
}');
INSERT INTO kao_ke_document ("file_name", "payload_json") VALUES ('six_qin_kao_fen.json', '{
  "name": "六亲考分",
  "source": "《图解易经铁板神数》",
  "description": [
    "出生时分与夫妻、子女情况的对照表。",
    "可由出生时刻推知、子女的情况，也可由已知的夫妻、子女的命运考定刻分。"
  ],
  "shiChenKeMapper": {
    "子": [
      {
        "shiChen": "子",
        "fen": 1,
        "wifeInfo": "偕妻",
        "childInfo": "五子",
        "husbandInfo": "夫强"
      },
      {
        "shiChen": "子",
        "fen": 2,
        "wifeInfo": "克妻",
        "childInfo": "少子",
        "husbandInfo": "克夫"
      },
      {
        "shiChen": "子",
        "fen": 3,
        "wifeInfo": "和妻",
        "childInfo": "四子",
        "husbandInfo": "佳夫"
      },
      {
        "shiChen": "子",
        "fen": 4,
        "wifeInfo": "丧妻",
        "childInfo": "多子",
        "husbandInfo": "丧夫"
      },
      {
        "shiChen": "子",
        "fen": 5,
        "wifeInfo": "有妾",
        "childInfo": "无子",
        "husbandInfo": "又再嫁"
      },
      {
        "shiChen": "子",
        "fen": 6,
        "wifeInfo": "贤妻",
        "childInfo": "一子",
        "husbandInfo": "偕夫"
      },
      {
        "shiChen": "子",
        "fen": 7,
        "wifeInfo": "无妾",
        "childInfo": "无子",
        "husbandInfo": "无夫"
      },
      {
        "shiChen": "子",
        "fen": 8,
        "wifeInfo": "丧妾",
        "childInfo": "多子",
        "husbandInfo": "夫又丧"
      },
      {
        "shiChen": "子",
        "fen": 9,
        "wifeInfo": "克妾",
        "childInfo": "少子",
        "husbandInfo": "有夫"
      },
      {
        "shiChen": "子",
        "fen": 10,
        "wifeInfo": "佳妻",
        "childInfo": "二子",
        "husbandInfo": "和夫"
      },
      {
        "shiChen": "子",
        "fen": 11,
        "wifeInfo": "续妻",
        "childInfo": "少子",
        "husbandInfo": "再嫁"
      },
      {
        "shiChen": "子",
        "fen": 12,
        "wifeInfo": "强妻",
        "childInfo": "三子",
        "husbandInfo": "夫兴"
      },
      {
        "shiChen": "子",
        "fen": 13,
        "wifeInfo": "有妾",
        "childInfo": "多子",
        "husbandInfo": "又再嫁"
      },
      {
        "shiChen": "子",
        "fen": 14,
        "wifeInfo": "续妻",
        "childInfo": "多子",
        "husbandInfo": "再嫁"
      },
      {
        "shiChen": "子",
        "fen": 15,
        "wifeInfo": "有妻",
        "childInfo": "无子",
        "husbandInfo": "夫又丧"
      }
    ],
    "丑": [
      {
        "shiChen": "丑",
        "fen": 1,
        "wifeInfo": "和妻",
        "childInfo": "四子",
        "husbandInfo": "佳夫"
      },
      {
        "shiChen": "丑",
        "fen": 2,
        "wifeInfo": "克妻",
        "childInfo": "少子",
        "husbandInfo": "夫丧"
      },
      {
        "shiChen": "丑",
        "fen": 3,
        "wifeInfo": "有妾",
        "childInfo": "多子",
        "husbandInfo": "又再嫁"
      },
      {
        "shiChen": "丑",
        "fen": 4,
        "wifeInfo": "贤妻",
        "childInfo": "二子",
        "husbandInfo": "和夫"
      },
      {
        "shiChen": "丑",
        "fen": 5,
        "wifeInfo": "丧妻",
        "childInfo": "多子",
        "husbandInfo": "夫丧"
      },
      {
        "shiChen": "丑",
        "fen": 6,
        "wifeInfo": "有妻",
        "childInfo": "无子",
        "husbandInfo": "有夫"
      },
      {
        "shiChen": "丑",
        "fen": 7,
        "wifeInfo": "佳妻",
        "childInfo": "一子",
        "husbandInfo": "偕夫"
      },
      {
        "shiChen": "丑",
        "fen": 8,
        "wifeInfo": "续妻",
        "childInfo": "少于",
        "husbandInfo": "再嫁"
      },
      {
        "shiChen": "丑",
        "fen": 9,
        "wifeInfo": "丧妾",
        "childInfo": "多子",
        "husbandInfo": "夫又丧"
      },
      {
        "shiChen": "丑",
        "fen": 10,
        "wifeInfo": "强妻",
        "childInfo": "三子",
        "husbandInfo": "夫兴"
      },
      {
        "shiChen": "丑",
        "fen": 11,
        "wifeInfo": "无妻",
        "childInfo": "无子",
        "husbandInfo": "无夫"
      },
      {
        "shiChen": "丑",
        "fen": 12,
        "wifeInfo": "续妻",
        "childInfo": "多子",
        "husbandInfo": "再嫁"
      },
      {
        "shiChen": "丑",
        "fen": 13,
        "wifeInfo": "偕妻",
        "childInfo": "五子",
        "husbandInfo": "夫强"
      },
      {
        "shiChen": "丑",
        "fen": 14,
        "wifeInfo": "续妻",
        "childInfo": "无子",
        "husbandInfo": "又再嫁"
      },
      {
        "shiChen": "丑",
        "fen": 15,
        "wifeInfo": "无妻",
        "childInfo": "少子",
        "husbandInfo": "又丧夫"
      }
    ],
    "寅": [
      {
        "shiChen": "寅",
        "fen": 1,
        "wifeInfo": "贤妻",
        "childInfo": "二子",
        "husbandInfo": "和夫"
      },
      {
        "shiChen": "寅",
        "fen": 2,
        "wifeInfo": "克妻",
        "childInfo": "少子",
        "husbandInfo": "克夫"
      },
      {
        "shiChen": "寅",
        "fen": 3,
        "wifeInfo": "有妾",
        "childInfo": "多子",
        "husbandInfo": "又再嫁"
      },
      {
        "shiChen": "寅",
        "fen": 4,
        "wifeInfo": "佳妻",
        "childInfo": "一子",
        "husbandInfo": "偕夫"
      },
      {
        "shiChen": "寅",
        "fen": 5,
        "wifeInfo": "丧妻",
        "childInfo": "多子",
        "husbandInfo": "丧夫"
      },
      {
        "shiChen": "寅",
        "fen": 6,
        "wifeInfo": "续妻",
        "childInfo": "多子",
        "husbandInfo": "再嫁"
      },
      {
        "shiChen": "寅",
        "fen": 7,
        "wifeInfo": "强妻",
        "childInfo": "三子",
        "husbandInfo": "夫兴"
      },
      {
        "shiChen": "寅",
        "fen": 8,
        "wifeInfo": "续妻",
        "childInfo": "少子",
        "husbandInfo": "再嫁"
      },
      {
        "shiChen": "寅",
        "fen": 9,
        "wifeInfo": "偕妻",
        "childInfo": "五子",
        "husbandInfo": "强夫"
      },
      {
        "shiChen": "寅",
        "fen": 10,
        "wifeInfo": "无妻",
        "childInfo": "无子",
        "husbandInfo": "无夫"
      },
      {
        "shiChen": "寅",
        "fen": 11,
        "wifeInfo": "丧妾",
        "childInfo": "多子",
        "husbandInfo": "夫又丧"
      },
      {
        "shiChen": "寅",
        "fen": 12,
        "wifeInfo": "和妻",
        "childInfo": "四子",
        "husbandInfo": "佳夫"
      },
      {
        "shiChen": "寅",
        "fen": 13,
        "wifeInfo": "有妾",
        "childInfo": "无子",
        "husbandInfo": "又再嫁"
      },
      {
        "shiChen": "寅",
        "fen": 14,
        "wifeInfo": "克妻",
        "childInfo": "少子",
        "husbandInfo": "夫又丧"
      },
      {
        "shiChen": "寅",
        "fen": 15,
        "wifeInfo": "贤妻",
        "childInfo": "二子",
        "husbandInfo": "和夫"
      }
    ],
    "卯": [
      {
        "shiChen": "卯",
        "fen": 1,
        "wifeInfo": "佳妻",
        "childInfo": "一子",
        "husbandInfo": "偕夫"
      },
      {
        "shiChen": "卯",
        "fen": 2,
        "wifeInfo": "续妻",
        "childInfo": "少子",
        "husbandInfo": "再嫁"
      },
      {
        "shiChen": "卯",
        "fen": 3,
        "wifeInfo": "丧妾",
        "childInfo": "多子",
        "husbandInfo": "夫又丧"
      },
      {
        "shiChen": "卯",
        "fen": 4,
        "wifeInfo": "强妻",
        "childInfo": "三子",
        "husbandInfo": "夫兴"
      },
      {
        "shiChen": "卯",
        "fen": 5,
        "wifeInfo": "无妻",
        "childInfo": "无子",
        "husbandInfo": "无夫"
      },
      {
        "shiChen": "卯",
        "fen": 6,
        "wifeInfo": "贤妻",
        "childInfo": "二子",
        "husbandInfo": "有夫"
      },
      {
        "shiChen": "卯",
        "fen": 7,
        "wifeInfo": "偕妻",
        "childInfo": "五子",
        "husbandInfo": "夫强"
      },
      {
        "shiChen": "卯",
        "fen": 8,
        "wifeInfo": "克妾",
        "childInfo": "少子",
        "husbandInfo": "夫又丧"
      },
      {
        "shiChen": "卯",
        "fen": 9,
        "wifeInfo": "和妻",
        "childInfo": "四子",
        "husbandInfo": "佳夫"
      },
      {
        "shiChen": "卯",
        "fen": 10,
        "wifeInfo": "克妻",
        "childInfo": "少子",
        "husbandInfo": "丧夫"
      },
      {
        "shiChen": "卯",
        "fen": 11,
        "wifeInfo": "有妾",
        "childInfo": "多子",
        "husbandInfo": "又再嫁"
      },
      {
        "shiChen": "卯",
        "fen": 12,
        "wifeInfo": "有妻",
        "childInfo": "无子",
        "husbandInfo": "和夫"
      },
      {
        "shiChen": "卯",
        "fen": 13,
        "wifeInfo": "丧妻",
        "childInfo": "多子",
        "husbandInfo": "克夫"
      },
      {
        "shiChen": "卯",
        "fen": 14,
        "wifeInfo": "续妻",
        "childInfo": "多子",
        "husbandInfo": "再嫁"
      },
      {
        "shiChen": "卯",
        "fen": 15,
        "wifeInfo": "佳妻",
        "childInfo": "一子",
        "husbandInfo": "偕夫"
      }
    ],
    "辰": [
      {
        "shiChen": "辰",
        "fen": 1,
        "wifeInfo": "强妻",
        "childInfo": "三子",
        "husbandInfo": "夫兴"
      },
      {
        "shiChen": "辰",
        "fen": 2,
        "wifeInfo": "有妾",
        "childInfo": "无子",
        "husbandInfo": "又再嫁"
      },
      {
        "shiChen": "辰",
        "fen": 3,
        "wifeInfo": "丧妾",
        "childInfo": "多子",
        "husbandInfo": "夫又丧"
      },
      {
        "shiChen": "辰",
        "fen": 4,
        "wifeInfo": "偕妻",
        "childInfo": "五子",
        "husbandInfo": "强夫"
      },
      {
        "shiChen": "辰",
        "fen": 5,
        "wifeInfo": "无妾",
        "childInfo": "无子",
        "husbandInfo": "无夫"
      },
      {
        "shiChen": "辰",
        "fen": 6,
        "wifeInfo": "克妾",
        "childInfo": "无子",
        "husbandInfo": "夫又丧"
      },
      {
        "shiChen": "辰",
        "fen": 7,
        "wifeInfo": "和妻",
        "childInfo": "四子",
        "husbandInfo": "佳夫"
      },
      {
        "shiChen": "辰",
        "fen": 8,
        "wifeInfo": "克妻",
        "childInfo": "少子",
        "husbandInfo": "克夫"
      },
      {
        "shiChen": "辰",
        "fen": 9,
        "wifeInfo": "有妾",
        "childInfo": "多子",
        "husbandInfo": "又再嫁"
      },
      {
        "shiChen": "辰",
        "fen": 10,
        "wifeInfo": "贤妾",
        "childInfo": "二子",
        "husbandInfo": "和夫"
      },
      {
        "shiChen": "辰",
        "fen": 11,
        "wifeInfo": "续妻",
        "childInfo": "多子",
        "husbandInfo": "再嫁"
      },
      {
        "shiChen": "辰",
        "fen": 12,
        "wifeInfo": "有妻",
        "childInfo": "无子",
        "husbandInfo": "有夫"
      },
      {
        "shiChen": "辰",
        "fen": 13,
        "wifeInfo": "佳妻",
        "childInfo": "一子",
        "husbandInfo": "偕夫"
      },
      {
        "shiChen": "辰",
        "fen": 14,
        "wifeInfo": "续妻",
        "childInfo": "少子",
        "husbandInfo": "再嫁"
      },
      {
        "shiChen": "辰",
        "fen": 15,
        "wifeInfo": "丧妻",
        "childInfo": "多子",
        "husbandInfo": "丧夫"
      }
    ],
    "巳": [
      {
        "shiChen": "巳",
        "fen": 1,
        "wifeInfo": "和妻",
        "childInfo": "四子",
        "husbandInfo": "佳夫"
      },
      {
        "shiChen": "巳",
        "fen": 2,
        "wifeInfo": "有妾",
        "childInfo": "无子",
        "husbandInfo": "又再嫁"
      },
      {
        "shiChen": "巳",
        "fen": 3,
        "wifeInfo": "克妾",
        "childInfo": "少子",
        "husbandInfo": "又克夫"
      },
      {
        "shiChen": "巳",
        "fen": 4,
        "wifeInfo": "偕妻",
        "childInfo": "五子",
        "husbandInfo": "夫强"
      },
      {
        "shiChen": "巳",
        "fen": 5,
        "wifeInfo": "克妻",
        "childInfo": "少子",
        "husbandInfo": "克夫"
      },
      {
        "shiChen": "巳",
        "fen": 6,
        "wifeInfo": "有妾",
        "childInfo": "多子",
        "husbandInfo": "又再嫁"
      },
      {
        "shiChen": "巳",
        "fen": 7,
        "wifeInfo": "贤妻",
        "childInfo": "二子",
        "husbandInfo": "和夫"
      },
      {
        "shiChen": "巳",
        "fen": 8,
        "wifeInfo": "丧妻",
        "childInfo": "多子",
        "husbandInfo": "克夫"
      },
      {
        "shiChen": "巳",
        "fen": 9,
        "wifeInfo": "有妻",
        "childInfo": "无子",
        "husbandInfo": "有夫"
      },
      {
        "shiChen": "巳",
        "fen": 10,
        "wifeInfo": "佳妻",
        "childInfo": "一子",
        "husbandInfo": "偕夫"
      },
      {
        "shiChen": "巳",
        "fen": 11,
        "wifeInfo": "续妻",
        "childInfo": "少子",
        "husbandInfo": "再嫁"
      },
      {
        "shiChen": "巳",
        "fen": 12,
        "wifeInfo": "丧妻",
        "childInfo": "多子",
        "husbandInfo": "又克夫"
      },
      {
        "shiChen": "巳",
        "fen": 13,
        "wifeInfo": "强妻",
        "childInfo": "三子",
        "husbandInfo": "夫兴"
      },
      {
        "shiChen": "巳",
        "fen": 14,
        "wifeInfo": "无妻",
        "childInfo": "无子",
        "husbandInfo": "无夫"
      },
      {
        "shiChen": "巳",
        "fen": 15,
        "wifeInfo": "续妻",
        "childInfo": "多子",
        "husbandInfo": "再嫁"
      }
    ],
    "午": [
      {
        "shiChen": "午",
        "fen": 1,
        "wifeInfo": "克妻",
        "childInfo": "少子",
        "husbandInfo": "克夫"
      },
      {
        "shiChen": "午",
        "fen": 2,
        "wifeInfo": "有妾",
        "childInfo": "多子",
        "husbandInfo": "又再嫁"
      },
      {
        "shiChen": "午",
        "fen": 3,
        "wifeInfo": "和妻",
        "childInfo": "五子",
        "husbandInfo": "夫强"
      },
      {
        "shiChen": "午",
        "fen": 4,
        "wifeInfo": "丧妻",
        "childInfo": "多子",
        "husbandInfo": "克夫"
      },
      {
        "shiChen": "午",
        "fen": 5,
        "wifeInfo": "有妻",
        "childInfo": "无子",
        "husbandInfo": "有夫"
      },
      {
        "shiChen": "午",
        "fen": 6,
        "wifeInfo": "贤妻",
        "childInfo": "三子",
        "husbandInfo": "夫兴"
      },
      {
        "shiChen": "午",
        "fen": 7,
        "wifeInfo": "续妻",
        "childInfo": "少子",
        "husbandInfo": "再嫁"
      },
      {
        "shiChen": "午",
        "fen": 8,
        "wifeInfo": "丧妻",
        "childInfo": "多子",
        "husbandInfo": "夫又丧"
      },
      {
        "shiChen": "午",
        "fen": 9,
        "wifeInfo": "佳妻",
        "childInfo": "五子",
        "husbandInfo": "和夫"
      },
      {
        "shiChen": "午",
        "fen": 10,
        "wifeInfo": "无妻",
        "childInfo": "无子",
        "husbandInfo": "无夫"
      },
      {
        "shiChen": "午",
        "fen": 11,
        "wifeInfo": "续妻",
        "childInfo": "多子",
        "husbandInfo": "再嫁"
      },
      {
        "shiChen": "午",
        "fen": 12,
        "wifeInfo": "强妻",
        "childInfo": "一子",
        "husbandInfo": "偕夫"
      },
      {
        "shiChen": "午",
        "fen": 13,
        "wifeInfo": "有妾",
        "childInfo": "无子",
        "husbandInfo": "又再嫁"
      },
      {
        "shiChen": "午",
        "fen": 14,
        "wifeInfo": "克妾",
        "childInfo": "少子",
        "husbandInfo": "夫又丧"
      },
      {
        "shiChen": "午",
        "fen": 15,
        "wifeInfo": "偕妻",
        "childInfo": "四子",
        "husbandInfo": "佳夫"
      }
    ],
    "未": [
      {
        "shiChen": "未",
        "fen": 1,
        "wifeInfo": "妻丧",
        "childInfo": "多子",
        "husbandInfo": "夫丧"
      },
      {
        "shiChen": "未",
        "fen": 2,
        "wifeInfo": "有妻",
        "childInfo": "无子",
        "husbandInfo": "有夫"
      },
      {
        "shiChen": "未",
        "fen": 3,
        "wifeInfo": "贤妻",
        "childInfo": "三子",
        "husbandInfo": "夫兴"
      },
      {
        "shiChen": "未",
        "fen": 4,
        "wifeInfo": "续妻",
        "childInfo": "少子",
        "husbandInfo": "再嫁"
      },
      {
        "shiChen": "未",
        "fen": 5,
        "wifeInfo": "丧妻",
        "childInfo": "多子",
        "husbandInfo": "又丧夫"
      },
      {
        "shiChen": "未",
        "fen": 6,
        "wifeInfo": "佳妻",
        "childInfo": "二子",
        "husbandInfo": "和夫"
      },
      {
        "shiChen": "未",
        "fen": 7,
        "wifeInfo": "无妾",
        "childInfo": "无子",
        "husbandInfo": "无夫"
      },
      {
        "shiChen": "未",
        "fen": 8,
        "wifeInfo": "续妻",
        "childInfo": "多子",
        "husbandInfo": "再嫁"
      },
      {
        "shiChen": "未",
        "fen": 9,
        "wifeInfo": "强妻",
        "childInfo": "一子",
        "husbandInfo": "偕夫"
      },
      {
        "shiChen": "未",
        "fen": 10,
        "wifeInfo": "有妾",
        "childInfo": "无子",
        "husbandInfo": "又再嫁"
      },
      {
        "shiChen": "未",
        "fen": 11,
        "wifeInfo": "克妾",
        "childInfo": "少子",
        "husbandInfo": "夫又丧"
      },
      {
        "shiChen": "未",
        "fen": 12,
        "wifeInfo": "偕妻",
        "childInfo": "四子",
        "husbandInfo": "佳夫"
      },
      {
        "shiChen": "未",
        "fen": 13,
        "wifeInfo": "克妻",
        "childInfo": "少子",
        "husbandInfo": "克夫"
      },
      {
        "shiChen": "未",
        "fen": 14,
        "wifeInfo": "有妾",
        "childInfo": "多子",
        "husbandInfo": "又再嫁"
      },
      {
        "shiChen": "未",
        "fen": 15,
        "wifeInfo": "和妻",
        "childInfo": "五子",
        "husbandInfo": "强夫"
      }
    ],
    "申": [
      {
        "shiChen": "申",
        "fen": 1,
        "wifeInfo": "续妻",
        "childInfo": "少子",
        "husbandInfo": "再嫁"
      },
      {
        "shiChen": "申",
        "fen": 2,
        "wifeInfo": "丧妾",
        "childInfo": "多子",
        "husbandInfo": "夫又丧"
      },
      {
        "shiChen": "申",
        "fen": 3,
        "wifeInfo": "佳妻",
        "childInfo": "二子",
        "husbandInfo": "和夫"
      },
      {
        "shiChen": "申",
        "fen": 4,
        "wifeInfo": "无妻",
        "childInfo": "无子",
        "husbandInfo": "无夫"
      },
      {
        "shiChen": "申",
        "fen": 5,
        "wifeInfo": "续妻",
        "childInfo": "多女",
        "husbandInfo": "再嫁"
      },
      {
        "shiChen": "申",
        "fen": 6,
        "wifeInfo": "强妻",
        "childInfo": "一子",
        "husbandInfo": "偕夫"
      },
      {
        "shiChen": "申",
        "fen": 7,
        "wifeInfo": "有妾",
        "childInfo": "无子",
        "husbandInfo": "又再嫁"
      },
      {
        "shiChen": "申",
        "fen": 8,
        "wifeInfo": "克妻",
        "childInfo": "少子",
        "husbandInfo": "夫又丧"
      },
      {
        "shiChen": "申",
        "fen": 9,
        "wifeInfo": "偕妻",
        "childInfo": "四子",
        "husbandInfo": "佳夫"
      },
      {
        "shiChen": "申",
        "fen": 10,
        "wifeInfo": "克妻",
        "childInfo": "少子",
        "husbandInfo": "克夫"
      },
      {
        "shiChen": "申",
        "fen": 11,
        "wifeInfo": "有妾",
        "childInfo": "多子",
        "husbandInfo": "又再嫁"
      },
      {
        "shiChen": "申",
        "fen": 12,
        "wifeInfo": "和妻",
        "childInfo": "五子",
        "husbandInfo": "夫强"
      },
      {
        "shiChen": "申",
        "fen": 13,
        "wifeInfo": "丧妻",
        "childInfo": "多子",
        "husbandInfo": "克夫"
      },
      {
        "shiChen": "申",
        "fen": 14,
        "wifeInfo": "有妻",
        "childInfo": "无子",
        "husbandInfo": "有夫"
      },
      {
        "shiChen": "申",
        "fen": 15,
        "wifeInfo": "贤妻",
        "childInfo": "三子",
        "husbandInfo": "兴夫"
      }
    ],
    "酉": [
      {
        "shiChen": "酉",
        "fen": 1,
        "wifeInfo": "无妻",
        "childInfo": "无子",
        "husbandInfo": "无夫"
      },
      {
        "shiChen": "酉",
        "fen": 2,
        "wifeInfo": "丧妾",
        "childInfo": "多子",
        "husbandInfo": "夫又丧"
      },
      {
        "shiChen": "酉",
        "fen": 3,
        "wifeInfo": "佳妻",
        "childInfo": "一子",
        "husbandInfo": "偕夫"
      },
      {
        "shiChen": "酉",
        "fen": 4,
        "wifeInfo": "有妾",
        "childInfo": "无子",
        "husbandInfo": "又再嫁"
      },
      {
        "shiChen": "酉",
        "fen": 5,
        "wifeInfo": "克妾",
        "childInfo": "少子",
        "husbandInfo": "夫又丧"
      },
      {
        "shiChen": "酉",
        "fen": 6,
        "wifeInfo": "偕妻",
        "childInfo": "四子",
        "husbandInfo": "佳失"
      },
      {
        "shiChen": "酉",
        "fen": 7,
        "wifeInfo": "克妻",
        "childInfo": "少子",
        "husbandInfo": "克夫"
      },
      {
        "shiChen": "酉",
        "fen": 8,
        "wifeInfo": "有妾",
        "childInfo": "多子",
        "husbandInfo": "又再嫁"
      },
      {
        "shiChen": "酉",
        "fen": 9,
        "wifeInfo": "和妻",
        "childInfo": "五子",
        "husbandInfo": "强夫"
      },
      {
        "shiChen": "酉",
        "fen": 10,
        "wifeInfo": "贤妻",
        "childInfo": "三子",
        "husbandInfo": "夫兴"
      },
      {
        "shiChen": "酉",
        "fen": 11,
        "wifeInfo": "丧妻",
        "childInfo": "多子",
        "husbandInfo": "克夫"
      },
      {
        "shiChen": "酉",
        "fen": 12,
        "wifeInfo": "有妻",
        "childInfo": "无子",
        "husbandInfo": "有夫"
      },
      {
        "shiChen": "酉",
        "fen": 13,
        "wifeInfo": "续妻",
        "childInfo": "少子",
        "husbandInfo": "再嫁"
      },
      {
        "shiChen": "酉",
        "fen": 14,
        "wifeInfo": "佳妻",
        "childInfo": "二子",
        "husbandInfo": "夫和"
      },
      {
        "shiChen": "酉",
        "fen": 15,
        "wifeInfo": "续妻",
        "childInfo": "多女",
        "husbandInfo": "再嫁"
      }
    ],
    "戌": [
      {
        "shiChen": "戌",
        "fen": 1,
        "wifeInfo": "有妾",
        "childInfo": "无子",
        "husbandInfo": "又再嫁"
      },
      {
        "shiChen": "戌",
        "fen": 2,
        "wifeInfo": "克妾",
        "childInfo": "少子",
        "husbandInfo": "夫又丧"
      },
      {
        "shiChen": "戌",
        "fen": 3,
        "wifeInfo": "偕妻",
        "childInfo": "四子",
        "husbandInfo": "佳夫"
      },
      {
        "shiChen": "戌",
        "fen": 4,
        "wifeInfo": "克妻",
        "childInfo": "少子",
        "husbandInfo": "克夫"
      },
      {
        "shiChen": "戌",
        "fen": 5,
        "wifeInfo": "有妾",
        "childInfo": "多子",
        "husbandInfo": "又再嫁"
      },
      {
        "shiChen": "戌",
        "fen": 6,
        "wifeInfo": "和妻",
        "childInfo": "五子",
        "husbandInfo": "夫强"
      },
      {
        "shiChen": "戌",
        "fen": 7,
        "wifeInfo": "丧妻",
        "childInfo": "多子",
        "husbandInfo": "夫丧"
      },
      {
        "shiChen": "戌",
        "fen": 8,
        "wifeInfo": "有妻",
        "childInfo": "无子",
        "husbandInfo": "有夫"
      },
      {
        "shiChen": "戌",
        "fen": 9,
        "wifeInfo": "贤妻",
        "childInfo": "三子",
        "husbandInfo": "夫兴"
      },
      {
        "shiChen": "戌",
        "fen": 10,
        "wifeInfo": "续妻",
        "childInfo": "少子",
        "husbandInfo": "再嫁"
      },
      {
        "shiChen": "戌",
        "fen": 11,
        "wifeInfo": "丧妾",
        "childInfo": "多子",
        "husbandInfo": "夫又丧"
      },
      {
        "shiChen": "戌",
        "fen": 12,
        "wifeInfo": "佳妻",
        "childInfo": "二女",
        "husbandInfo": "和夫"
      },
      {
        "shiChen": "戌",
        "fen": 13,
        "wifeInfo": "无妻",
        "childInfo": "无子",
        "husbandInfo": "无夫"
      },
      {
        "shiChen": "戌",
        "fen": 14,
        "wifeInfo": "续妻",
        "childInfo": "多子",
        "husbandInfo": "再嫁"
      },
      {
        "shiChen": "戌",
        "fen": 15,
        "wifeInfo": "强妻",
        "childInfo": "一子",
        "husbandInfo": "夫偕"
      }
    ],
    "亥": [
      {
        "shiChen": "亥",
        "fen": 1,
        "wifeInfo": "有妾",
        "childInfo": "多子",
        "husbandInfo": "又再嫁"
      },
      {
        "shiChen": "亥",
        "fen": 2,
        "wifeInfo": "强夫",
        "childInfo": "无子",
        "husbandInfo": "和妻"
      },
      {
        "shiChen": "亥",
        "fen": 3,
        "wifeInfo": "亡妻",
        "childInfo": "少子",
        "husbandInfo": "亡夫"
      },
      {
        "shiChen": "亥",
        "fen": 4,
        "wifeInfo": "有妻",
        "childInfo": "少子",
        "husbandInfo": "有夫"
      },
      {
        "shiChen": "亥",
        "fen": 5,
        "wifeInfo": "贤妻",
        "childInfo": "三子",
        "husbandInfo": "夫兴"
      },
      {
        "shiChen": "亥",
        "fen": 6,
        "wifeInfo": "亡妻",
        "childInfo": "多子",
        "husbandInfo": "亡夫"
      },
      {
        "shiChen": "亥",
        "fen": 7,
        "wifeInfo": "丧妻",
        "childInfo": "多子",
        "husbandInfo": "丧失"
      },
      {
        "shiChen": "亥",
        "fen": 8,
        "wifeInfo": "有妻",
        "childInfo": "二子",
        "husbandInfo": "有夫"
      },
      {
        "shiChen": "亥",
        "fen": 9,
        "wifeInfo": "续妻",
        "childInfo": "少子",
        "husbandInfo": "夫兴"
      },
      {
        "shiChen": "亥",
        "fen": 10,
        "wifeInfo": "亡妾",
        "childInfo": "少子",
        "husbandInfo": "亡犬"
      },
      {
        "shiChen": "亥",
        "fen": 11,
        "wifeInfo": "强妾",
        "childInfo": "一子",
        "husbandInfo": "夫又丧"
      },
      {
        "shiChen": "亥",
        "fen": 12,
        "wifeInfo": "佳妻",
        "childInfo": "无子",
        "husbandInfo": "和夫"
      },
      {
        "shiChen": "亥",
        "fen": 13,
        "wifeInfo": "无妻",
        "childInfo": "多子",
        "husbandInfo": "无夫"
      },
      {
        "shiChen": "亥",
        "fen": 14,
        "wifeInfo": "偕妻",
        "childInfo": "四子",
        "husbandInfo": "再嫁"
      },
      {
        "shiChen": "亥",
        "fen": 15,
        "wifeInfo": "无妻",
        "childInfo": "无子",
        "husbandInfo": "无夫"
      }
    ]
  }
}');
INSERT INTO kao_ke_document ("file_name", "payload_json") VALUES ('six_qin_kao_ke_1.json', '{
  "name": "六亲考刻一",
  "source": "《图解易经铁板神数》",
  "description": [
    "出生时刻与父母、兄弟（姊妹）情况的对照表。可由出生时刻推知父母、兄弟（姊妹）的情况，也可由已知父母、兄弟（姊妹）的命运考定刻分"
  ],
  "shiChenKeMapper": {
    "子": [
      {"shiChen": "子", "ke": "first", "parentsInfo": "父母寿", "siblingsInfo": "弟兄多", "guaYaoInfo": "得乾中爻"},
      {"shiChen": "子", "ke": "second", "parentsInfo": "母丧", "siblingsInfo": "弟兄少", "guaYaoInfo": "得乾上爻"},
      {"shiChen": "子", "ke": "third", "parentsInfo": "父母丧", "siblingsInfo": "弟兄四五", "guaYaoInfo": "得乾初爻"},
      {"shiChen": "子", "ke": "fourth", "parentsInfo": "父丧母寿", "siblingsInfo": "弟兄多", "guaYaoInfo": "得坤初爻"},
      {"shiChen": "子", "ke": "fifth", "parentsInfo": "父母丧", "siblingsInfo": "弟兄无", "guaYaoInfo": "得坤中爻"},
      {"shiChen": "子", "ke": "sixth", "parentsInfo": "父母寿", "siblingsInfo": "弟兄无", "guaYaoInfo": "兑离巽"},
      {"shiChen": "子", "ke": "seventh", "parentsInfo": "父丧母寿", "siblingsInfo": "弟兄二三", "guaYaoInfo": "得坤上爻"},
      {"shiChen": "子", "ke": "eighth", "parentsInfo": "父丧", "siblingsInfo": "弟兄无", "guaYaoInfo": "坎艮震"}
    ],
    "丑": [
      {"shiChen": "丑", "ke": "first", "parentsInfo": "母丧父寿", "siblingsInfo": "弟兄四五", "guaYaoInfo": "得乾中爻"},
      {"shiChen": "丑", "ke": "second", "parentsInfo": "父母寿", "siblingsInfo": "弟兄二三", "guaYaoInfo": "乾上爻"},
      {"shiChen": "丑", "ke": "third", "parentsInfo": "父丧", "siblingsInfo": "弟兄二三", "guaYaoInfo": "得乾初爻"},
      {"shiChen": "丑", "ke": "fourth", "parentsInfo": "母丧", "siblingsInfo": "弟兄四五", "guaYaoInfo": "得坤初爻"},
      {"shiChen": "丑", "ke": "fifth", "parentsInfo": "母丧", "siblingsInfo": "弟兄少", "guaYaoInfo": "得坤中爻"},
      {"shiChen": "丑", "ke": "sixth", "parentsInfo": "父母丧", "siblingsInfo": "弟兄无", "guaYaoInfo": "兑离巽"},
      {"shiChen": "丑", "ke": "seventh", "parentsInfo": "父母寿", "siblingsInfo": "弟兄少", "guaYaoInfo": "得坤上爻"},
      {"shiChen": "丑", "ke": "eighth", "parentsInfo": "父丧母寿", "siblingsInfo": "弟兄少", "guaYaoInfo": "艮坎震"}
    ],
    "寅": [
      {"shiChen": "寅", "ke": "first", "parentsInfo": "母丧父寿", "siblingsInfo": "弟兄四五", "guaYaoInfo": "得乾中爻"},
      {"shiChen": "寅", "ke": "second", "parentsInfo": "父母寿", "siblingsInfo": "弟兄多", "guaYaoInfo": "得乾上爻"},
      {"shiChen": "寅", "ke": "third", "parentsInfo": "父母丧", "siblingsInfo": "弟兄二三", "guaYaoInfo": "得乾初爻"},
      {"shiChen": "寅", "ke": "fourth", "parentsInfo": "母丧父寿", "siblingsInfo": "弟兄二三", "guaYaoInfo": "得坤初爻"},
      {"shiChen": "寅", "ke": "fifth", "parentsInfo": "父丧", "siblingsInfo": "弟兄多", "guaYaoInfo": "得坤中爻"},
      {"shiChen": "寅", "ke": "sixth", "parentsInfo": "母丧", "siblingsInfo": "弟兄少", "guaYaoInfo": "兑离巽"},
      {"shiChen": "寅", "ke": "seventh", "parentsInfo": "父母丧", "siblingsInfo": "弟兄四五", "guaYaoInfo": "得坤上爻"},
      {"shiChen": "寅", "ke": "eighth", "parentsInfo": "父母寿", "siblingsInfo": "弟兄少", "guaYaoInfo": "艮坎震"}
    ],
    "卯": [
      {"shiChen": "卯", "ke": "first", "parentsInfo": "母丧父寿", "siblingsInfo": "弟兄多", "guaYaoInfo": "得乾中爻"},
      {"shiChen": "卯", "ke": "second", "parentsInfo": "父丧母寿", "siblingsInfo": "弟兄二三", "guaYaoInfo": "得乾初爻"},
      {"shiChen": "卯", "ke": "third", "parentsInfo": "父母寿", "siblingsInfo": "弟兄四五", "guaYaoInfo": "得乾初爻"},
      {"shiChen": "卯", "ke": "fourth", "parentsInfo": "父母丧", "siblingsInfo": "弟兄无", "guaYaoInfo": "得坤初爻"},
      {"shiChen": "卯", "ke": "fifth", "parentsInfo": "父丧", "siblingsInfo": "弟兄多", "guaYaoInfo": "得坤中爻"},
      {"shiChen": "卯", "ke": "sixth", "parentsInfo": "母丧", "siblingsInfo": "弟兄少", "guaYaoInfo": "兑离巽"},
      {"shiChen": "卯", "ke": "seventh", "parentsInfo": "父母寿", "siblingsInfo": "弟兄二三", "guaYaoInfo": "得坤上爻"},
      {"shiChen": "卯", "ke": "eighth", "parentsInfo": "父母丧", "siblingsInfo": "弟兄二三", "guaYaoInfo": "艮坎震"}
    ],
    "辰": [
      {"shiChen": "辰", "ke": "first", "parentsInfo": "母丧父寿", "siblingsInfo": "弟兄三四", "guaYaoInfo": "得乾中爻"},
      {"shiChen": "辰", "ke": "second", "parentsInfo": "父母寿", "siblingsInfo": "弟兄无", "guaYaoInfo": "得乾上爻"},
      {"shiChen": "辰", "ke": "third", "parentsInfo": "父母丧", "siblingsInfo": "弟兄四五", "guaYaoInfo": "得乾初爻"},
      {"shiChen": "辰", "ke": "fourth", "parentsInfo": "父丧母寿", "siblingsInfo": "弟兄四五", "guaYaoInfo": "得坤初爻"},
      {"shiChen": "辰", "ke": "fifth", "parentsInfo": "父母寿", "siblingsInfo": "弟兄二三", "guaYaoInfo": "得坤中爻"},
      {"shiChen": "辰", "ke": "sixth", "parentsInfo": "父母丧", "siblingsInfo": "弟兄少", "guaYaoInfo": "兑离巽"},
      {"shiChen": "辰", "ke": "seventh", "parentsInfo": "母丧", "siblingsInfo": "弟兄无", "guaYaoInfo": "得坤上爻"},
      {"shiChen": "辰", "ke": "eighth", "parentsInfo": "父丧", "siblingsInfo": "弟兄无", "guaYaoInfo": "艮坎震"}
    ],
    "巳": [
      {"shiChen": "巳", "ke": "first", "parentsInfo": "父母寿", "siblingsInfo": "弟兄四五", "guaYaoInfo": "得乾中爻"},
      {"shiChen": "巳", "ke": "second", "parentsInfo": "母丧", "siblingsInfo": "弟兄四五", "guaYaoInfo": "得乾上爻"},
      {"shiChen": "巳", "ke": "third", "parentsInfo": "父丧母寿", "siblingsInfo": "弟兄二三", "guaYaoInfo": "得乾初爻"},
      {"shiChen": "巳", "ke": "fourth", "parentsInfo": "父母丧", "siblingsInfo": "弟兄二三", "guaYaoInfo": "得坤初爻"},
      {"shiChen": "巳", "ke": "fifth", "parentsInfo": "父丧母寿", "siblingsInfo": "弟兄无", "guaYaoInfo": "得坤初爻"},
      {"shiChen": "巳", "ke": "sixth", "parentsInfo": "父母寿", "siblingsInfo": "弟兄少", "guaYaoInfo": "兑离巽"},
      {"shiChen": "巳", "ke": "seventh", "parentsInfo": "母丧", "siblingsInfo": "弟兄二三", "guaYaoInfo": "得坤上爻"},
      {"shiChen": "巳", "ke": "eighth", "parentsInfo": "父母丧", "siblingsInfo": "弟兄少", "guaYaoInfo": "艮坎震"}
    ],
    "午": [
      {"shiChen": "午", "ke": "first", "parentsInfo": "父母丧", "siblingsInfo": "弟兄四五", "guaYaoInfo": "得乾中爻"},
      {"shiChen": "午", "ke": "second", "parentsInfo": "父丧", "siblingsInfo": "弟兄四五", "guaYaoInfo": "得乾上爻"},
      {"shiChen": "午", "ke": "third", "parentsInfo": "父母寿", "siblingsInfo": "弟兄多", "guaYaoInfo": "得乾初爻"},
      {"shiChen": "午", "ke": "fourth", "parentsInfo": "母丧", "siblingsInfo": "弟兄无", "guaYaoInfo": "得坤初爻"},
      {"shiChen": "午", "ke": "fifth", "parentsInfo": "父母寿", "siblingsInfo": "弟兄二三", "guaYaoInfo": "得坤中爻"},
      {"shiChen": "午", "ke": "sixth", "parentsInfo": "母丧父寿", "siblingsInfo": "弟兄多", "guaYaoInfo": "兑离巽"},
      {"shiChen": "午", "ke": "seventh", "parentsInfo": "父母丧", "siblingsInfo": "弟兄二三", "guaYaoInfo": "得坤上爻"},
      {"shiChen": "午", "ke": "eighth", "parentsInfo": "父丧母寿", "siblingsInfo": "弟兄二三", "guaYaoInfo": "艮坎震"}
    ],
    "未": [
      {"shiChen": "未", "ke": "first", "parentsInfo": "父丧母寿", "siblingsInfo": "弟兄多", "guaYaoInfo": "得乾中爻"},
      {"shiChen": "未", "ke": "second", "parentsInfo": "父母丧", "siblingsInfo": "弟兄无", "guaYaoInfo": "得乾上爻"},
      {"shiChen": "未", "ke": "third", "parentsInfo": "母丧", "siblingsInfo": "弟兄二三", "guaYaoInfo": "得乾初爻"},
      {"shiChen": "未", "ke": "fourth", "parentsInfo": "父母寿", "siblingsInfo": "弟兄无", "guaYaoInfo": "得坤初爻"},
      {"shiChen": "未", "ke": "fifth", "parentsInfo": "父丧母寿", "siblingsInfo": "弟兄二三", "guaYaoInfo": "得坤中爻"},
      {"shiChen": "未", "ke": "sixth", "parentsInfo": "母丧", "siblingsInfo": "弟兄多", "guaYaoInfo": "兑离巽"},
      {"shiChen": "未", "ke": "seventh", "parentsInfo": "父母爻", "siblingsInfo": "弟兄二三", "guaYaoInfo": "得坤上爻"},
      {"shiChen": "未", "ke": "eighth", "parentsInfo": "父母丧", "siblingsInfo": "弟兄二三", "guaYaoInfo": "艮坎震"}
    ],
    "申": [
      {"shiChen": "申", "ke": "first", "parentsInfo": "父丧母寿", "siblingsInfo": "弟兄四五", "guaYaoInfo": "得乾中爻"},
      {"shiChen": "申", "ke": "second", "parentsInfo": "母丧", "siblingsInfo": "弟兄四五", "guaYaoInfo": "得乾上爻"},
      {"shiChen": "申", "ke": "third", "parentsInfo": "父母寿", "siblingsInfo": "弟兄四五", "guaYaoInfo": "得乾初爻"},
      {"shiChen": "申", "ke": "fourth", "parentsInfo": "父母丧", "siblingsInfo": "弟兄四五", "guaYaoInfo": "得坤初爻"},
      {"shiChen": "申", "ke": "fifth", "parentsInfo": "母丧父寿", "siblingsInfo": "弟兄无", "guaYaoInfo": "得坤中爻"},
      {"shiChen": "申", "ke": "sixth", "parentsInfo": "父母丧", "siblingsInfo": "弟兄少", "guaYaoInfo": "兑离巽"},
      {"shiChen": "申", "ke": "seventh", "parentsInfo": "父丧", "siblingsInfo": "弟兄无", "guaYaoInfo": "得坤上爻"},
      {"shiChen": "申", "ke": "eighth", "parentsInfo": "父母寿", "siblingsInfo": "弟兄二三", "guaYaoInfo": "艮坎震"}
    ],
    "酉": [
      {"shiChen": "酉", "ke": "first", "parentsInfo": "父母丧", "siblingsInfo": "弟兄二三", "guaYaoInfo": "得乾中爻"},
      {"shiChen": "酉", "ke": "second", "parentsInfo": "母丧", "siblingsInfo": "弟兄二三", "guaYaoInfo": "得乾上爻"},
      {"shiChen": "酉", "ke": "third", "parentsInfo": "父母寿", "siblingsInfo": "弟兄无", "guaYaoInfo": "得乾初爻"},
      {"shiChen": "酉", "ke": "fourth", "parentsInfo": "父丧母寿", "siblingsInfo": "弟兄二三", "guaYaoInfo": "得坤初爻"},
      {"shiChen": "酉", "ke": "fifth", "parentsInfo": "父丧", "siblingsInfo": "弟兄无", "guaYaoInfo": "得坤中爻"},
      {"shiChen": "酉", "ke": "sixth", "parentsInfo": "母丧父寿", "siblingsInfo": "弟兄少", "guaYaoInfo": "兑离巽"},
      {"shiChen": "酉", "ke": "seventh", "parentsInfo": "父母丧", "siblingsInfo": "弟兄少", "guaYaoInfo": "得坤上爻"},
      {"shiChen": "酉", "ke": "eighth", "parentsInfo": "父母寿", "siblingsInfo": "弟兄多", "guaYaoInfo": "艮坎震"}
    ],
    "戌": [
      {"shiChen": "戌", "ke": "first", "parentsInfo": "父母寿", "siblingsInfo": "弟兄二三", "guaYaoInfo": "得乾中爻"},
      {"shiChen": "戌", "ke": "second", "parentsInfo": "父丧", "siblingsInfo": "弟兄四五", "guaYaoInfo": "得乾上爻"},
      {"shiChen": "戌", "ke": "third", "parentsInfo": "父母寿", "siblingsInfo": "弟兄四五", "guaYaoInfo": "得乾初爻"},
      {"shiChen": "戌", "ke": "fourth", "parentsInfo": "母丧父寿", "siblingsInfo": "弟兄四五", "guaYaoInfo": "得坤初爻"},
      {"shiChen": "戌", "ke": "fifth", "parentsInfo": "父母丧", "siblingsInfo": "弟兄二三", "guaYaoInfo": "得坤中爻"},
      {"shiChen": "戌", "ke": "sixth", "parentsInfo": "父丧母寿", "siblingsInfo": "弟兄少", "guaYaoInfo": "兑离巽"},
      {"shiChen": "戌", "ke": "seventh", "parentsInfo": "父母寿", "siblingsInfo": "弟兄四五", "guaYaoInfo": "得坤上爻"},
      {"shiChen": "戌", "ke": "eighth", "parentsInfo": "母丧", "siblingsInfo": "弟兄二三", "guaYaoInfo": "艮坎震"}
    ],
    "亥": [
      {"shiChen": "亥", "ke": "first", "parentsInfo": "父母丧", "siblingsInfo": "弟兄无", "guaYaoInfo": "得乾中爻"},
      {"shiChen": "亥", "ke": "second", "parentsInfo": "父丧母寿", "siblingsInfo": "弟兄二三", "guaYaoInfo": "得乾上爻"},
      {"shiChen": "亥", "ke": "third", "parentsInfo": "母丧", "siblingsInfo": "弟兄无", "guaYaoInfo": "得乾初爻"},
      {"shiChen": "亥", "ke": "fourth", "parentsInfo": "父母寿", "siblingsInfo": "弟兄无", "guaYaoInfo": "得坤初爻"},
      {"shiChen": "亥", "ke": "fifth", "parentsInfo": "母丧父寿", "siblingsInfo": "弟兄多", "guaYaoInfo": "得坤中爻"},
      {"shiChen": "亥", "ke": "sixth", "parentsInfo": "父丧", "siblingsInfo": "弟兄四五", "guaYaoInfo": "兑离巽"},
      {"shiChen": "亥", "ke": "seventh", "parentsInfo": "父母丧", "siblingsInfo": "弟兄二三", "guaYaoInfo": "得坤上爻"},
      {"shiChen": "亥", "ke": "eighth", "parentsInfo": "父母寿", "siblingsInfo": "弟兄二三", "guaYaoInfo": "艮坎震"}
    ]
  }
}');
INSERT INTO kao_ke_document ("file_name", "payload_json") VALUES ('six_qin_kao_ke_2.json', '{
  "name": "六亲考刻二",
  "source": "网络",
  "description": [
    "註：現代醫療很好，父母早喪已經很少，可能要改，改為父母分離，跟父或母同住。（命主在十八歳前登天國才算是父母早喪。）",
"註：現代很少有兄弟三四，可改變為兄弟感情好。現代兄弟數可加入姐妹數。",
"最後的卦是加入命卦中取數。"
  ],
  "shiChenKeMapper": {
    "子": [
      {
        "shiChen": "子",
        "ke": "first",
        "parentsInfo": "父母壽",
        "siblingsInfo": "多兄弟",
        "guaYaoInfo": "爻中乾得"
      },
      {
        "shiChen": "子",
        "ke": "second",
        "parentsInfo": "喪",
        "siblingsInfo": "兄弟少",
        "guaYaoInfo": "爻上乾得"
      },
      {
        "shiChen": "子",
        "ke": "3父母喪",
        "parentsInfo": "兄弟四五",
        "siblingsInfo": "爻初亁得",
        "guaYaoInfo": ""
      },
      {
        "shiChen": "子",
        "ke": "4父喪母壽",
        "parentsInfo": "兄弟多",
        "siblingsInfo": "爻初坤得",
        "guaYaoInfo": ""
      },
      {
        "shiChen": "子",
        "ke": "fifth",
        "parentsInfo": "父母喪",
        "siblingsInfo": "無兄弟",
        "guaYaoInfo": "爻中坤得"
      },
      {
        "shiChen": "子",
        "ke": "sixth",
        "parentsInfo": "父母壽",
        "siblingsInfo": "無兄弟",
        "guaYaoInfo": "巽離兌"
      },
      {
        "shiChen": "子",
        "ke": "seventh",
        "parentsInfo": "父壽母喪",
        "siblingsInfo": "兄弟二三",
        "guaYaoInfo": "爻上坤得"
      },
      {
        "shiChen": "子",
        "ke": "eighth",
        "parentsInfo": "父喪",
        "siblingsInfo": "無兄弟",
        "guaYaoInfo": "震坎艮"
      }
    ],
    "丑": [
      {
        "shiChen": "丑",
        "ke": "first",
        "parentsInfo": "父壽母喪",
        "siblingsInfo": "兄弟四五",
        "guaYaoInfo": "爻中乾得"
      },
      {
        "shiChen": "丑",
        "ke": "second",
        "parentsInfo": "母壽",
        "siblingsInfo": "兄弟二三",
        "guaYaoInfo": "爻上乾得"
      },
      {
        "shiChen": "丑",
        "ke": "3父喪",
        "parentsInfo": "兄弟四五",
        "siblingsInfo": "爻初亁得",
        "guaYaoInfo": ""
      },
      {
        "shiChen": "丑",
        "ke": "4父母喪",
        "parentsInfo": "兄弟四五",
        "siblingsInfo": "爻初坤得",
        "guaYaoInfo": ""
      },
      {
        "shiChen": "丑",
        "ke": "fifth",
        "parentsInfo": "母喪",
        "siblingsInfo": "兄弟少",
        "guaYaoInfo": "爻中坤得"
      },
      {
        "shiChen": "丑",
        "ke": "sixth",
        "parentsInfo": "父母喪",
        "siblingsInfo": "無兄弟",
        "guaYaoInfo": "巽離兌"
      },
      {
        "shiChen": "丑",
        "ke": "seventh",
        "parentsInfo": "父母壽",
        "siblingsInfo": "兄弟少",
        "guaYaoInfo": "爻上坤得"
      },
      {
        "shiChen": "丑",
        "ke": "eighth",
        "parentsInfo": "母壽父喪",
        "siblingsInfo": "少兄弟",
        "guaYaoInfo": "震坎艮"
      }
    ],
    "寅": [
      {
        "shiChen": "寅",
        "ke": "first",
        "parentsInfo": "父喪母壽",
        "siblingsInfo": "兄弟四五",
        "guaYaoInfo": "爻中乾得"
      },
      {
        "shiChen": "寅",
        "ke": "second",
        "parentsInfo": "母壽",
        "siblingsInfo": "兄弟多",
        "guaYaoInfo": "爻上乾得"
      },
      {
        "shiChen": "寅",
        "ke": "3父母喪",
        "parentsInfo": "兄弟二三",
        "siblingsInfo": "爻初亁得",
        "guaYaoInfo": ""
      },
      {
        "shiChen": "寅",
        "ke": "4父壽母喪",
        "parentsInfo": "兄弟二三",
        "siblingsInfo": "爻初坤得",
        "guaYaoInfo": ""
      },
      {
        "shiChen": "寅",
        "ke": "fifth",
        "parentsInfo": "父喪",
        "siblingsInfo": "無兄弟",
        "guaYaoInfo": "爻中坤得"
      },
      {
        "shiChen": "寅",
        "ke": "sixth",
        "parentsInfo": "母喪",
        "siblingsInfo": "兄弟少",
        "guaYaoInfo": "巽離兌"
      },
      {
        "shiChen": "寅",
        "ke": "seventh",
        "parentsInfo": "父母喪",
        "siblingsInfo": "兄弟四五",
        "guaYaoInfo": "爻上坤得"
      },
      {
        "shiChen": "寅",
        "ke": "eighth",
        "parentsInfo": "父母壽",
        "siblingsInfo": "兄弟少",
        "guaYaoInfo": "震坎艮"
      }
    ],
    "卯": [
      {
        "shiChen": "卯",
        "ke": "first",
        "parentsInfo": "父壽母喪",
        "siblingsInfo": "兄弟多",
        "guaYaoInfo": "爻中乾得"
      },
      {
        "shiChen": "卯",
        "ke": "second",
        "parentsInfo": "喪母壽",
        "siblingsInfo": "兄弟二三",
        "guaYaoInfo": "爻上乾得"
      },
      {
        "shiChen": "卯",
        "ke": "3父母壽",
        "parentsInfo": "兄弟四五",
        "siblingsInfo": "爻初亁得",
        "guaYaoInfo": ""
      },
      {
        "shiChen": "卯",
        "ke": "4父母喪",
        "parentsInfo": "兄弟無",
        "siblingsInfo": "爻初坤得",
        "guaYaoInfo": ""
      },
      {
        "shiChen": "卯",
        "ke": "fifth",
        "parentsInfo": "父喪",
        "siblingsInfo": "兄弟多",
        "guaYaoInfo": "爻中坤得"
      },
      {
        "shiChen": "卯",
        "ke": "sixth",
        "parentsInfo": "母喪",
        "siblingsInfo": "兄弟少",
        "guaYaoInfo": "巽離兌"
      },
      {
        "shiChen": "卯",
        "ke": "seventh",
        "parentsInfo": "父母壽",
        "siblingsInfo": "兄弟二三",
        "guaYaoInfo": "爻上坤得"
      },
      {
        "shiChen": "卯",
        "ke": "eighth",
        "parentsInfo": "父母喪",
        "siblingsInfo": "兄弟二三",
        "guaYaoInfo": "震坎艮"
      }
    ],
    "辰": [
      {
        "shiChen": "辰",
        "ke": "first",
        "parentsInfo": "父壽母喪",
        "siblingsInfo": "兄弟三四",
        "guaYaoInfo": "爻中乾得"
      },
      {
        "shiChen": "辰",
        "ke": "second",
        "parentsInfo": "母壽",
        "siblingsInfo": "兄弟無",
        "guaYaoInfo": "爻上乾得"
      },
      {
        "shiChen": "辰",
        "ke": "3父母喪",
        "parentsInfo": "兄弟四五",
        "siblingsInfo": "爻初亁得",
        "guaYaoInfo": ""
      },
      {
        "shiChen": "辰",
        "ke": "4父壽母喪",
        "parentsInfo": "兄弟四五",
        "siblingsInfo": "爻初坤得",
        "guaYaoInfo": ""
      },
      {
        "shiChen": "辰",
        "ke": "fifth",
        "parentsInfo": "父母壽",
        "siblingsInfo": "兄弟二三",
        "guaYaoInfo": "爻中坤得"
      },
      {
        "shiChen": "辰",
        "ke": "sixth",
        "parentsInfo": "父母喪",
        "siblingsInfo": "兄弟少",
        "guaYaoInfo": "巽離兌"
      },
      {
        "shiChen": "辰",
        "ke": "seventh",
        "parentsInfo": "母喪",
        "siblingsInfo": "兄弟無",
        "guaYaoInfo": "爻上坤得"
      },
      {
        "shiChen": "辰",
        "ke": "eighth",
        "parentsInfo": "父喪",
        "siblingsInfo": "兄弟無",
        "guaYaoInfo": "震坎艮"
      }
    ],
    "巳": [
      {
        "shiChen": "巳",
        "ke": "first",
        "parentsInfo": "父母壽",
        "siblingsInfo": "兄弟四五",
        "guaYaoInfo": "爻中乾得"
      },
      {
        "shiChen": "巳",
        "ke": "second",
        "parentsInfo": "喪",
        "siblingsInfo": "兄弟四五",
        "guaYaoInfo": "爻上乾得"
      },
      {
        "shiChen": "巳",
        "ke": "3父壽母喪",
        "parentsInfo": "兄弟二三",
        "siblingsInfo": "爻初亁得",
        "guaYaoInfo": ""
      },
      {
        "shiChen": "巳",
        "ke": "4父母喪",
        "parentsInfo": "兄弟二三",
        "siblingsInfo": "爻初坤得",
        "guaYaoInfo": ""
      },
      {
        "shiChen": "巳",
        "ke": "fifth",
        "parentsInfo": "父喪母壽",
        "siblingsInfo": "兄弟無",
        "guaYaoInfo": "爻中坤得"
      },
      {
        "shiChen": "巳",
        "ke": "sixth",
        "parentsInfo": "父母壽",
        "siblingsInfo": "兄弟少",
        "guaYaoInfo": "巽離兌"
      },
      {
        "shiChen": "巳",
        "ke": "seventh",
        "parentsInfo": "父壽母喪",
        "siblingsInfo": "兄弟二三",
        "guaYaoInfo": "爻上坤得"
      },
      {
        "shiChen": "巳",
        "ke": "eighth",
        "parentsInfo": "父母喪",
        "siblingsInfo": "兄弟少",
        "guaYaoInfo": "震坎艮"
      }
    ],
    "午": [
      {
        "shiChen": "午",
        "ke": "first",
        "parentsInfo": "父母喪",
        "siblingsInfo": "兄弟四五",
        "guaYaoInfo": "爻中乾得"
      },
      {
        "shiChen": "午",
        "ke": "second",
        "parentsInfo": "壽",
        "siblingsInfo": "兄弟四五",
        "guaYaoInfo": "爻上乾得"
      },
      {
        "shiChen": "午",
        "ke": "3父母壽",
        "parentsInfo": "兄弟多",
        "siblingsInfo": "爻初亁得",
        "guaYaoInfo": ""
      },
      {
        "shiChen": "午",
        "ke": "4母喪",
        "parentsInfo": "兄弟無",
        "siblingsInfo": "爻初坤得",
        "guaYaoInfo": ""
      },
      {
        "shiChen": "午",
        "ke": "fifth",
        "parentsInfo": "父母壽",
        "siblingsInfo": "兄弟二三",
        "guaYaoInfo": "爻中坤得"
      },
      {
        "shiChen": "午",
        "ke": "sixth",
        "parentsInfo": "父壽母喪",
        "siblingsInfo": "兄弟多",
        "guaYaoInfo": "巽離兌"
      },
      {
        "shiChen": "午",
        "ke": "seventh",
        "parentsInfo": "父母喪",
        "siblingsInfo": "兄弟二三",
        "guaYaoInfo": "爻上坤得"
      },
      {
        "shiChen": "午",
        "ke": "eighth",
        "parentsInfo": "父喪母壽",
        "siblingsInfo": "兄弟二三",
        "guaYaoInfo": "震坎艮"
      }
    ],
    "未": [
      {
        "shiChen": "未",
        "ke": "first",
        "parentsInfo": "父壽母喪",
        "siblingsInfo": "兄弟多",
        "guaYaoInfo": "爻中乾得"
      },
      {
        "shiChen": "未",
        "ke": "second",
        "parentsInfo": "母喪",
        "siblingsInfo": "兄弟無",
        "guaYaoInfo": "爻上乾得"
      },
      {
        "shiChen": "未",
        "ke": "3父壽母喪",
        "parentsInfo": "兄弟二三",
        "siblingsInfo": "爻初亁得",
        "guaYaoInfo": ""
      },
      {
        "shiChen": "未",
        "ke": "4母喪",
        "parentsInfo": "兄弟二三",
        "siblingsInfo": "爻初坤得",
        "guaYaoInfo": ""
      },
      {
        "shiChen": "未",
        "ke": "fifth",
        "parentsInfo": "父喪母壽",
        "siblingsInfo": "兄弟無",
        "guaYaoInfo": "爻中坤得"
      },
      {
        "shiChen": "未",
        "ke": "sixth",
        "parentsInfo": "父母壽",
        "siblingsInfo": "兄弟無",
        "guaYaoInfo": "巽離兌"
      },
      {
        "shiChen": "未",
        "ke": "seventh",
        "parentsInfo": "父母壽",
        "siblingsInfo": "兄弟二三",
        "guaYaoInfo": "爻上坤得"
      },
      {
        "shiChen": "未",
        "ke": "eighth",
        "parentsInfo": "父母喪",
        "siblingsInfo": "兄弟二三",
        "guaYaoInfo": "震坎艮"
      }
    ],
    "申": [
      {
        "shiChen": "申",
        "ke": "first",
        "parentsInfo": "父喪母壽",
        "siblingsInfo": "兄弟四五",
        "guaYaoInfo": "爻中乾得"
      },
      {
        "shiChen": "申",
        "ke": "second",
        "parentsInfo": "喪",
        "siblingsInfo": "兄弟四五",
        "guaYaoInfo": "爻上乾得"
      },
      {
        "shiChen": "申",
        "ke": "3父母壽",
        "parentsInfo": "兄弟四五",
        "siblingsInfo": "爻初亁得",
        "guaYaoInfo": ""
      },
      {
        "shiChen": "申",
        "ke": "4父母喪",
        "parentsInfo": "兄弟四五",
        "siblingsInfo": "爻初坤得",
        "guaYaoInfo": ""
      },
      {
        "shiChen": "申",
        "ke": "fifth",
        "parentsInfo": "父壽母喪",
        "siblingsInfo": "兄弟無",
        "guaYaoInfo": "爻中坤得"
      },
      {
        "shiChen": "申",
        "ke": "sixth",
        "parentsInfo": "父母喪",
        "siblingsInfo": "兄弟多",
        "guaYaoInfo": "巽離兌"
      },
      {
        "shiChen": "申",
        "ke": "seventh",
        "parentsInfo": "父喪",
        "siblingsInfo": "兄弟無",
        "guaYaoInfo": "爻上坤得"
      },
      {
        "shiChen": "申",
        "ke": "eighth",
        "parentsInfo": "父母壽",
        "siblingsInfo": "兄弟二三",
        "guaYaoInfo": "震坎艮"
      }
    ],
    "酉": [
      {
        "shiChen": "酉",
        "ke": "first",
        "parentsInfo": "父母喪",
        "siblingsInfo": "兄弟二三",
        "guaYaoInfo": "爻中乾得"
      },
      {
        "shiChen": "酉",
        "ke": "second",
        "parentsInfo": "喪",
        "siblingsInfo": "兄弟二三",
        "guaYaoInfo": "爻上乾得"
      },
      {
        "shiChen": "酉",
        "ke": "3父母壽",
        "parentsInfo": "兄弟無",
        "siblingsInfo": "爻初亁得",
        "guaYaoInfo": ""
      },
      {
        "shiChen": "酉",
        "ke": "4父喪母壽",
        "parentsInfo": "兄弟二三",
        "siblingsInfo": "爻初坤得",
        "guaYaoInfo": ""
      },
      {
        "shiChen": "酉",
        "ke": "fifth",
        "parentsInfo": "父喪",
        "siblingsInfo": "兄弟無",
        "guaYaoInfo": "爻中坤得"
      },
      {
        "shiChen": "酉",
        "ke": "sixth",
        "parentsInfo": "父壽母喪",
        "siblingsInfo": "兄弟少",
        "guaYaoInfo": "爻上乾得"
      },
      {
        "shiChen": "酉",
        "ke": "seventh",
        "parentsInfo": "父母喪",
        "siblingsInfo": "兄弟少",
        "guaYaoInfo": "爻初亁得"
      },
      {
        "shiChen": "酉",
        "ke": "eighth",
        "parentsInfo": "父母壽",
        "siblingsInfo": "兄弟多",
        "guaYaoInfo": "爻初坤得"
      }
    ],
    "戌": [
      {
        "shiChen": "戌",
        "ke": "first",
        "parentsInfo": "父壽",
        "siblingsInfo": "兄弟二三",
        "guaYaoInfo": "爻中乾得"
      },
      {
        "shiChen": "戌",
        "ke": "second",
        "parentsInfo": "喪",
        "siblingsInfo": "兄弟四五",
        "guaYaoInfo": "爻上乾得"
      },
      {
        "shiChen": "戌",
        "ke": "3父母喪",
        "parentsInfo": "兄弟四五",
        "siblingsInfo": "爻初亁得",
        "guaYaoInfo": ""
      },
      {
        "shiChen": "戌",
        "ke": "4父壽母喪",
        "parentsInfo": "兄弟四五",
        "siblingsInfo": "爻初坤得",
        "guaYaoInfo": ""
      },
      {
        "shiChen": "戌",
        "ke": "fifth",
        "parentsInfo": "父母喪",
        "siblingsInfo": "兄弟二三",
        "guaYaoInfo": "爻中坤得"
      },
      {
        "shiChen": "戌",
        "ke": "sixth",
        "parentsInfo": "父喪母壽",
        "siblingsInfo": "兄弟少",
        "guaYaoInfo": "巽離兌"
      },
      {
        "shiChen": "戌",
        "ke": "seventh",
        "parentsInfo": "父母壽",
        "siblingsInfo": "兄弟四五",
        "guaYaoInfo": "爻上坤得"
      },
      {
        "shiChen": "戌",
        "ke": "eighth",
        "parentsInfo": "母喪",
        "siblingsInfo": "兄弟二三",
        "guaYaoInfo": "震坎艮"
      }
    ],
    "亥": [
      {
        "shiChen": "亥",
        "ke": "first",
        "parentsInfo": "父母喪",
        "siblingsInfo": "兄弟無",
        "guaYaoInfo": "爻中乾得"
      },
      {
        "shiChen": "亥",
        "ke": "second",
        "parentsInfo": "喪母壽",
        "siblingsInfo": "兄弟二三",
        "guaYaoInfo": "爻上乾得"
      },
      {
        "shiChen": "亥",
        "ke": "3父母喪",
        "parentsInfo": "兄弟無",
        "siblingsInfo": "爻初亁得",
        "guaYaoInfo": ""
      },
      {
        "shiChen": "亥",
        "ke": "4父母壽",
        "parentsInfo": "兄弟多",
        "siblingsInfo": "爻初坤得",
        "guaYaoInfo": ""
      },
      {
        "shiChen": "亥",
        "ke": "fifth",
        "parentsInfo": "父喪",
        "siblingsInfo": "兄弟四五",
        "guaYaoInfo": "爻中坤得"
      },
      {
        "shiChen": "亥",
        "ke": "sixth",
        "parentsInfo": "父喪",
        "siblingsInfo": "兄弟二三",
        "guaYaoInfo": "爻上乾得"
      },
      {
        "shiChen": "亥",
        "ke": "seventh",
        "parentsInfo": "父母喪",
        "siblingsInfo": "兄弟二三",
        "guaYaoInfo": "爻初亁得"
      },
      {
        "shiChen": "亥",
        "ke": "eighth",
        "parentsInfo": "父母壽",
        "siblingsInfo": "兄弟二三",
        "guaYaoInfo": "爻初坤得"
      }
    ]
  }
}');
INSERT INTO kao_ke_document ("file_name", "payload_json") VALUES ('wu_jin_jia_liu_du.json', '{
    "name": "戊金甲流度",
    "description": "推查女人第三任丈夫生年的先天定数",
    "zhiMapper": {
        "子": {"chiperText": "甲甲甲丙乙", "chiperNumber": 11126, "yearGanZhi": "甲子"},
        "丑": {"chiperText": "甲甲甲丁乙", "chiperNumber": 11176, "yearGanZhi": "乙丑"},
        "寅": {"chiperText": "甲甲丙丙乙", "chiperNumber": 11226, "yearGanZhi": "甲寅"},
        "卯": {"chiperText": "甲甲丙丁乙", "chiperNumber": 11276, "yearGanZhi": "乙卯"},
        "辰": {"chiperText": "甲甲戊丙乙", "chiperNumber": 11326, "yearGanZhi": "甲辰"},
        "巳": {"chiperText": "甲甲戊丁乙", "chiperNumber": 11376, "yearGanZhi": "乙巳"},
        "午": {"chiperText": "甲甲庚丙乙", "chiperNumber": 11426, "yearGanZhi": "甲午"},
        "未": {"chiperText": "甲甲庚丁乙", "chiperNumber": 11476, "yearGanZhi": "乙未"},
        "申": {"chiperText": "甲甲壬甲乙", "chiperNumber": 11526, "yearGanZhi": "甲申"},
        "酉": {"chiperText": "甲甲壬丁乙", "chiperNumber": 11576, "yearGanZhi": "乙酉"},
        "戌": {"chiperText": "甲甲乙丙乙", "chiperNumber": 11626, "yearGanZhi": "甲戌"},
        "亥": {"chiperText": "甲甲乙丁乙", "chiperNumber": 11676, "yearGanZhi": "乙亥"}
    }
}');
INSERT INTO kao_ke_document ("file_name", "payload_json") VALUES ('wu_mu_jia_liu_du.json', '{
    "name": "戊木甲流度",
    "description": "用来推男子结第三次婚，妻子的先天定数",
    "zhiMapper": {
        "子": {"chiperText": "甲月乙丙丙", "chiperNumber": 10622},
        "丑": {"chiperText": "甲月乙戊丙", "chiperNumber": 10632},
        "寅": {"chiperText": "甲月乙庚丙", "chiperNumber": 10642},
        "卯": {"chiperText": "甲月乙壬丙", "chiperNumber": 10652},
        "辰": {"chiperText": "甲月乙乙丙", "chiperNumber": 10662},
        "巳": {"chiperText": "甲月乙丁丙", "chiperNumber": 10672},
        "午": {"chiperText": "甲月乙己丙", "chiperNumber": 10682},
        "未": {"chiperText": "甲月乙辛丙", "chiperNumber": 10692},
        "申": {"chiperText": "甲月丁月丙", "chiperNumber": 10702},
        "酉": {"chiperText": "甲月丁甲丙", "chiperNumber": 10712},
        "戌": {"chiperText": "甲月丁丙丙", "chiperNumber": 10722},
        "亥": {"chiperText": "甲月丁戊丙", "chiperNumber": 10732}
    }
}');
COMMIT;
