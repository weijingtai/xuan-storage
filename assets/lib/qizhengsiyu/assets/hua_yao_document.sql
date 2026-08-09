BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS hua_yao_document (  file_name TEXT PRIMARY KEY,  payload_json TEXT NOT NULL);
INSERT INTO hua_yao_document ("file_name", "payload_json") VALUES ('74_huayao_dizhi.json', '[
        

    {
        "name": "爵神",
        "jiXiong": "平",
        "description": ["又称：“地元爵”，为爵必官清。","遇之进爵除拜，最要官福身命为之，又喜任高强，恶居陷地","爵神主功名爵位，象征社会地位与权柄"],
        "locationMapper": {
            "子": "土",
            "申": "土",
            "亥": "火",
            "未": "火",
            "午": "水",
            "丑": "水",
            "卯": "炁",
            "寅": "木",
            "巳": "木",
            "酉": "金",
            "戌": "金",
            "辰": "孛"
        },
        "type":"年地支",
        "locationDescriptionList": [
            "子申爵神土中藏，亥未火位午丑水，卯寅炁木巳酉金，辰宫见孛定荣昌"
        ]
    },
    {
        "name": "天马",
        "jiXiong": "平",
        "description": ["天马主奔波变动，象征升迁远行与机遇"],
        "locationMapper": {
            "子": "火",
            "申": "火",
            "辰": "火",
            "亥": "木",
            "未": "木",
            "卯": "木",
            "午": "水",
            "寅": "水",
            "戌": "水",
            "巳": "计",
            "酉": "计",
            "丑": "计"
        },
        "type":"年地支",
        "locationDescriptionList": ["子申辰马火方行，亥卯宫未木位生，寅午戌位水为地，酉巳丑计驿马程"
        ]
    },
    {
        "name": "地驿",
        "jiXiong": "平",
        "description": [],
        "locationMapper": {
            "子": "木",
            "丑": "水",
            "寅": "金",
            "卯": "火",
            "辰": "木",
            "巳": "水",
            "午": "金",
            "未": "火",
            "申": "木",
            "酉": "水",
            "戌": "金",
            "亥": "火"
        },
        "type":"年地支",
        "locationDescriptionList": []
    },
    {
        "name": "血支",
        "jiXiong": "平",
        "description": [],
        "locationMapper": {
            "子": "木",
            "丑": "土",
            "寅": "土",
            "卯": "木",
            "辰": "火",
            "巳": "金",
            "午": "水",
            "未": "日",
            "申": "月",
            "酉": "水",
            "戌": "金",
            "亥": "火"
        },
        "type":"年地支",
        "locationDescriptionList": []
    },
    {
        "name": "血忌",
        "jiXiong": "平",
        "description": [],
        "locationMapper": {
            "子": "日",
            "丑": "土",
            "寅": "土",
            "卯": "日",
            "辰": "木",
            "巳": "水",
            "午": "火",
            "未": "金",
            "申": "金",
            "酉": "火",
            "戌": "水",
            "亥": "木"
        },
        "type":"年地支",
        "locationDescriptionList": []
    },
    {
        "name": "产星",
        "jiXiong": "平",
        "description": [],
        "locationMapper": {
            "子": "金",
            "丑": "水",
            "寅": "木",
            "卯": "火",
            "辰": "金",
            "巳": "水",
            "午": "木",
            "未": "火",
            "申": "金",
            "酉": "水",
            "戌": "木",
            "亥": "火"
        },
        "type":"年地支",
        "locationDescriptionList": []
    },
    {
        "name": "值难",
        "jiXiong": "平",
        "description": [],
        "locationMapper": {
            "寅": "日",
            "卯": "日",
            "辰": "月",
            "巳": "月",
            "午": "火",
            "未": "罗",
            "申": "水",
            "酉": "孛",
            "戌": "木",
            "亥": "炁",
            "子": "金",
            "丑": "金"
        },
        "type":"月地支",
        "locationDescriptionList": []
    }
]');
INSERT INTO hua_yao_document ("file_name", "payload_json") VALUES ('74_huayao_others.json', '[
    {
        "name": "科甲",
        "jiXiong": "吉",
        "type": "命宫",
        "description": [
            "主科举功名，与天贵星联动。若逢紫炁拱照，主文星入命、金榜题名",
            "命宫逢科甲化曜且无刑克，主学识渊博、官场显达，若与天福同宫则福禄双全"
        ],
        "locationDescriptionList": [
            "官禄宫、福德宫",
            "日居午未庙旺时能量最强"
        ]
    },
    {
        "name": "人元禄",
        "jiXiong": "大吉",
        "type": "命宫",
        "description": [
            "源自福德宫主星，象征先天福报。逢木星、紫炁则主祖荫深厚、财源绵长",
            "若与天贵同度，主得贵人提携；若受计都冲克，则福泽被夺需化解"
        ],
        "locationDescriptionList": [
            "命宫、福德宫",
            "五虎遁至生月取天干定位"
        ]
    },
    {
        "name": "天元禄",
        "jiXiong": "吉",
        "type": "其他",
        "description": [
            "年干化曜之首，主官禄根基。甲年火星为天禄，入官禄宫则职权显赫",
            "逢罗睺计都夹制则主官非，需以天福木星通关化解"
        ],
        "locationDescriptionList": [
            "官禄宫",
            "年干起五虎遁至命宫取曜"
        ]
    },
    {
        "name": "地元禄",
        "jiXiong": "吉",
        "type": "命宫",
        "description": [
            "卦气逆行所至，主田宅积累。戊年土星为地禄，逢辰戌丑未宫则田产丰隆",
            "若与天暗同宫，主暗耗财物，需以天印紫炁制化"
        ],
        "locationDescriptionList": [
            "田宅宫、财帛宫",
            "卦气起点逆推三宫"
        ]
    },
    {
        "name": "职元",
        "jiXiong": "吉",
        "type": "命宫",
        "description": [
            "官禄主星之余气，丙年木星为职元，入命宫主专业技能卓越",
            "逢月孛冲照则职场多小人，需天权金星镇守命宫以稳固"
        ],
        "locationDescriptionList": [
            "命宫、官禄宫",
            "年干顺行至卦气宫取曜"
        ]
    },
    {
        "name": "局主",
        "jiXiong": "平",
        "type": "命宫",
        "description": [
            "命盘格局主导星，庚年水星为局主，三合紫炁则智谋超群",
            "若落陷于巳宫且逢计都，主谋事多阻，需借天荫土星生扶"
        ],
        "locationDescriptionList": [
            "命宫、卦气宫",
            "十干化曜表六合位取星"
        ]
    },
    {
        "name": "马元",
        "jiXiong": "平",
        "type": "其他",
        "description": [
            "驿马主变动，寅午戌年马在申，逢天福木星则远行获利",
            "若与天刑水星同度，主旅途险阻，需佩戴罗睺符牌化解"
        ],
        "locationDescriptionList": [
            "三合局对冲宫",
            "年支定驿马方位"
        ]
    },
    {
        "name": "寿元",
        "jiXiong": "吉",
        "type": "纳音",
        "description": [
            "疾厄宫主星之余，己年太阴为寿元，庙旺则康宁长寿",
            "逢计都侵扰易患慢性病，需借天贵金星调和阴阳"
        ],
        "locationDescriptionList": [
            "疾厄宫、命宫",
            "太阴行度与福德宫联动"
        ]
    },
    {
        "name": "天经",
        "jiXiong": "平",
        "type": "其他",
        "description": [
            "黄道主星经度枢纽，丁年金为天经，主契约文书之事",
            "与地纬计都成轴线时，主天地气运交变，宜静不宜动"
        ],
        "locationDescriptionList": [
            "命度所在黄道经线",
            "日月行度交汇点"
        ]
    },
    {
        "name": "地纬",
        "jiXiong": "平",
        "type": "其他",
        "description": [
            "白道隐曜纬度枢机，壬年计都为地纬，主地下隐疾与因果业力",
            "若与天囚同宫，主牢狱之灾，需以天印紫炁镇守田宅宫化解"
        ],
        "locationDescriptionList": [
            "计都南交点纬度",
            "太阴远地点轨迹"
        ]
    }
]');
INSERT INTO hua_yao_document ("file_name", "payload_json") VALUES ('74_huayao_tiangan.json', '[
    {
        "name": "天禄",
        "jiXiong": "吉",
        "type":"果老",
        "description": ["俸禄之源，主财富地位","与官禄宫同参"],
        "locationMapper": {
            "甲": "火",
            "乙": "孛",
            "丙": "木",
            "丁": "金",
            "戊": "土",
            "己": "月",
            "庚": "水",
            "辛": "炁",
            "壬": "计",
            "癸": "罗"
        },
        "locationDescriptionList": [
            "甲火乙孛丙属木，丁金戊土己月星，庚水辛炁壬计宿，癸罗禄曜显其荣"
        ]
    },
    {
        "name": "天暗",
        "jiXiong": "凶",
        "type":"果老",
        "description": ["暗耗破财，主损失纠纷","与相貌宫同参"],
        "locationMapper": {
            "甲": "孛",
            "乙": "木",
            "丙": "金",
            "丁": "土",
            "戊": "月",
            "己": "水",
            "庚": "炁",
            "辛": "计",
            "壬": "罗",
            "癸": "火"
        },
        "locationDescriptionList": [
            "甲孛乙木丙金居，丁土戊月己水渠，庚炁辛计壬罗火，癸火暗曜需慎趋"
        ]
    },
    {
        "name": "天福",
        "jiXiong": "吉",
        "type":"果老",
        "description": ["福德庇佑，主福炁祥瑞","与福德宫、财帛宫、迁移宫同参"],
        "locationMapper": {
            "甲": "木",
            "乙": "金",
            "丙": "土",
            "丁": "月",
            "戊": "水",
            "己": "炁",
            "庚": "计",
            "辛": "罗",
            "壬": "火",
            "癸": "孛"
        },
        "locationDescriptionList": [
            "甲木乙金丙土精，丁月戊水己炁清，庚计辛罗壬火耀，癸孛福星照命庭"
        ]
    },
    {
        "name": "天耗",
        "jiXiong": "凶",
        "type":"果老",
        "description": ["耗散之星，主破财损耗","与兄弟宫同参"],
        "locationMapper": {
            "甲": "金",
            "乙": "土",
            "丙": "月",
            "丁": "水",
            "戊": "炁",
            "己": "计",
            "庚": "罗",
            "辛": "火",
            "壬": "孛",
            "癸": "木"
        },
        "locationDescriptionList": [
            "甲金乙土丙月明，丁水戊炁己计灵，庚罗辛火壬孛木，癸木耗星慎经营"
        ]
    },
    {
        "name": "天荫",
        "jiXiong": "吉",
        "type":"果老",
        "description": ["荫庇之星，主祖业庇护","与夫妻宫同参"],
        "locationMapper": {
            "甲": "土",
            "乙": "月",
            "丙": "水",
            "丁": "炁",
            "戊": "计",
            "己": "罗",
            "庚": "火",
            "辛": "孛",
            "壬": "木",
            "癸": "金"
        },
        "locationDescriptionList": [
            "甲土乙月丙水清，丁炁戊计己罗星，庚火辛孛壬木秀，癸金荫曜保康宁"
        ]
    },
    {
        "name": "天贵",
        "jiXiong": "吉",
        "type":"果老",
        "description": ["贵人扶持，主官贵机遇","与男女同参"],
        "locationMapper": {
            "甲": "月",
            "乙": "水",
            "丙": "炁",
            "丁": "计",
            "戊": "罗",
            "己": "火",
            "庚": "孛",
            "辛": "木",
            "壬": "金",
            "癸": "土"
        },
        "locationDescriptionList": [
            "甲月乙水丙炁临，丁计戊罗己火星，庚孛辛木壬金贵，癸土贵人助功名"
        ]
    },
    {
        "name": "天刑",
        "jiXiong": "凶",
        "type":"果老",
        "description": ["刑伤之星，主官非刑克","与疾厄宫同参"],
        "locationMapper": {
            "甲": "水",
            "乙": "炁",
            "丙": "计",
            "丁": "罗",
            "戊": "火",
            "己": "孛",
            "庚": "木",
            "辛": "金",
            "壬": "土",
            "癸": "月"
        },
        "locationDescriptionList": [
            "甲水乙炁丙计凶，丁罗戊火己孛逢，庚木辛金壬土刑，癸月刑星需避冲"
        ]
    },
    {
        "name": "天印",
        "jiXiong": "吉",
        "type":"果老",
        "description": ["印绶护身，主学识权柄","与田宅宫同参"],
        "locationMapper": {
            "甲": "炁",
            "乙": "计",
            "丙": "罗",
            "丁": "火",
            "戊": "孛",
            "己": "木",
            "庚": "金",
            "辛": "土",
            "壬": "月",
            "癸": "水"
        },
        "locationDescriptionList": [
            "甲炁乙计丙罗星，丁火戊孛己木青，庚金辛土壬月印，癸水印绶掌权柄"
        ]
    },
    {
        "name": "天囚",
        "jiXiong": "凶",
        "type":"果老",
        "description": ["困顿之星，主阻碍限制","与疾厄宫同参"],
        "locationMapper": {
            "甲": "计",
            "乙": "罗",
            "丙": "火",
            "丁": "孛",
            "戊": "木",
            "己": "金",
            "庚": "土",
            "辛": "月",
            "壬": "水",
            "癸": "炁"
        },
        "locationDescriptionList": [
            "甲计乙罗丙火星，丁孛戊木己金刑，庚土辛月壬水困，癸炁囚星阻前程"
        ]
    },
    {
        "name": "天权",
        "jiXiong": "吉",
        "type":"果老",
        "description": ["权柄之星，主领导决断","与命宫同参"],
        "locationMapper": {
            "甲": "罗",
            "乙": "火",
            "丙": "孛",
            "丁": "木",
            "戊": "金",
            "己": "土",
            "庚": "月",
            "辛": "水",
            "壬": "炁",
            "癸": "计"
        },
        "locationDescriptionList": [
            "甲罗乙火丙孛权，丁木戊金己土全，庚月辛水壬炁贵，癸计权星掌大权"
        ]
    },
{
    "name": "天嗣",
    "jiXiong": "平",
    "description": [],
    "locationMapper": {
        "甲": "月",
        "乙": "水",
        "丙": "炁",
        "丁": "计",
        "戊": "罗",
        "己": "火",
        "庚": "孛",
        "辛": "木",
        "壬": "金",
        "癸": "土"
    },
    "type":"天干",
    "locationDescriptionList": [
        "甲月乙水丙炁余，丁计戊罗己火居，庚孛辛木壬金宿，癸人见土是天嗣"
    ]
},
{
    "name": "文星",
    "jiXiong": "平",
    "description": ["文星主文才学识，象征科名与文职功名"],
    "locationMapper": {
        "甲": "罗",
        "乙": "计",
        "丙": "金",
        "戊": "金",
        "丁": "火",
        "己": "炁",
        "庚": "木",
        "辛": "土",
        "壬": "日",
        "癸": "月"
    },
    "type":"天干",
    "locationDescriptionList": [
        "甲罗乙计丙戊金，丁火己炁庚木星，辛人见土壬逢日，癸人见月定昌荣"
    ]
},
{
    "name": "魁星",
    "jiXiong": "平",
    "description": [],
    "locationMapper": {
        "甲": "月",
        "乙": "日",
        "丙": "罗",
        "戊": "火",
        "丁": "计",
        "己": "金",
        "庚": "木",
        "辛": "孛",
        "壬": "炁",
        "癸": "水"
    },
    "type":"天干",
    "locationDescriptionList": [
        "甲用太阴乙太阳，丙罗丁计戊炎方,己金庚水辛逢孛，壬炁癸水号魁光"
    ]
},
{
    "name": "官星",
    "jiXiong": "平",
    "description": [],
    "locationMapper": {
        "甲": "炁",
        "乙": "水",
        "丙": "罗",
        "丁": "计",
        "戊": "孛",
        "己": "土",
        "庚": "金",
        "辛": "木",
        "壬": "月",
        "癸": "土"
    },
    "type":"天干",
    "locationDescriptionList": [
        "甲炁乙水是官星，丙罗丁计戊孛成，己土庚金辛见木，壬阴癸土定功名"
    ]
},
{
    "name": "印星",
    "jiXiong": "平",
    "description": [],
    "locationMapper": {
        "甲": "木",
        "乙": "日",
        "丙": "火",
        "丁": "月",
        "戊": "土",
        "己": "罗",
        "庚": "金",
        "辛": "计",
        "壬": "水",
        "癸": "孛"
    },
    "type":"天干",
    "locationDescriptionList": [
        "甲木乙日丙是荧，丁月戊土己罗辰，庚金辛计壬逢水，癸人见孛是印星"
    ]
},
{
    "name": "催官",
    "jiXiong": "平",
    "description": [],
    "locationMapper": {
        "甲": "金",
        "乙": "水",
        "丙": "日",
        "丁": "罗",
        "戊": "木",
        "己": "炁",
        "庚": "孛",
        "辛": "土",
        "壬": "月",
        "癸": "计"
    },
    "type":"天干",
    "locationDescriptionList": [
        "甲金乙水丙日宣，丁罗戊木见为欢，己炁庚孛辛土宿，壬月癸计是催官"
    ]
},
{
    "name": "禄神",
    "jiXiong": "平",
    "description": [],
    "locationMapper": {
        "甲": "木",
        "乙": "水",
        "丙": "计",
        "丁": "罗",
        "戊": "土",
        "己": "火",
        "庚": "金",
        "辛": "炁",
        "壬": "日",
        "癸": "月"
    },
    "type":"天干",
    "locationDescriptionList": [
        "甲兼木孛乙水星，丙计丁罗戊土居，己火庚金辛紫炁，壬日癸月是禄神"
    ]
},
{
    "name": "禄元",
    "jiXiong": "平",
    "description": ["禄元主俸禄之源，象征财富与地位根基"],
    "locationMapper": {
        "甲": "木",
        "乙": "火",
        "丙": "水",
        "丁": "日",
        "戊": "水",
        "己": "日",
        "庚": "水",
        "辛": "金",
        "壬": "木",
        "癸": "土"
    },
    "type":"天干",
    "locationDescriptionList": []
},
{
    "name": "仁元",
    "jiXiong": "平",
    "description": ["仁元主仁慈德行，象征人际关系与善行福报"],
    "locationMapper": {
        "甲": "木",
        "乙": "木",
        "丙": "火",
        "丁": "日",
        "戊": "土",
        "己": "土",
        "庚": "金",
        "辛": "金",
        "壬": "水",
        "癸": "水"
    },  
    "type":"天干",
    "locationDescriptionList": []
},
{
    "name": "喜神",
    "jiXiong": "平",
    "description": [],
    "locationMapper": {
        "甲": "罗",
        "乙": "计",
        "丙": "炁",
        "丁": "水",
        "戊": "月",
        "己": "土",
        "庚": "金",
        "辛": "水",
        "壬": "孛",
        "癸": "火"
    },
    "type":"天干",
    "locationDescriptionList": [
        "甲罗乙计丙炁星，丁水戊月是喜神，己土庚金辛见水，壬孛癸火最堪亲"
    ]
},
{
    "name": "生官",
    "jiXiong": "平",
    "description": [],
    "locationMapper": {
        "甲": "月",
        "乙": "土",
        "丙": "炁",
        "丁": "水",
        "戊": "罗",
        "己": "计",
        "庚": "孛",
        "辛": "火",
        "壬": "金",
        "癸": "木"
    },
    "type":"天干",
    "locationDescriptionList": []
},
{
    "name": "伤官",
    "jiXiong": "平",
    "description": [],
    "locationMapper": {
        "甲": "金",
        "乙": "木",
        "丙": "月",
        "丁": "土",
        "戊": "炁",
        "己": "水",
        "庚": "罗",
        "辛": "计",
        "壬": "孛",
        "癸": "火"
    },
    "type":"天干",
    "locationDescriptionList": []
},
{
    "name": "科名",
    "jiXiong": "吉",
    "description": ["假士子用之，主名高位重。庶人有之，亦有声望"],
    "locationMapper": {
        "甲": "木",
        "壬": "水",
        "乙": "木",
        "癸": "水",
        "戊": "土",
        "丙": "火",
        "庚": "金",
        "辛": "金",
        "己": "土",
        "丁": "火"
    },
    "type":"天干",
    "locationDescriptionList": [
        "甲乙生人木向容，丙丁火宿定科名。庚辛金兮戊己土，壬癸生人是水星"
    ]
},
{
    "name": "天官",
    "jiXiong": "吉",
    "description": ["天官主官贵，主官禄文书升迁"],
    "locationMapper": {
        "甲": "炁",
        "乙": "水",
        "丙": "罗",
        "丁": "计",
        "戊": "孛",
        "己": "土",
        "庚": "金",
        "辛": "木",
        "壬": "月",
        "癸": "土"
    },
    "type":"天干"
}
]');
COMMIT;
