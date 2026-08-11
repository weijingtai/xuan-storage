CREATE TABLE IF NOT EXISTS shen_sha_document (  file_name TEXT PRIMARY KEY,  payload_json TEXT NOT NULL);
DELETE FROM shen_sha_document;
INSERT INTO shen_sha_document ("file_name", "payload_json") VALUES ('6_shensha_gan.json', '[
  {
    "name": "干德",
    "jiXiong": "吉",
    "descriptionList": ["主转凶为吉"],
    "type": "干煞",
    "locationMapper": {
      "甲": "寅",
      "己": "寅",
      "乙": "申",
      "庚": "申",
      "丙": "巳",
      "辛": "巳",
      "丁": "亥",
      "壬": "亥",
      "戊": "巳",
      "癸": "巳"
    },
    "locationDescriptionList": ["甲己见寅，乙庚见申，丙辛戊癸见巳，丁壬见亥"]
  },
  {
    "name": "干禄",
    "jiXiong": "吉",
    "descriptionList": ["主俸禄、食物"],
    "type": "干煞",
    "locationMapper": {
      "甲": "寅",
      "乙": "卯",
      "丙": "巳",
      "戊": "巳",
      "丁": "午",
      "己": "午",
      "庚": "申",
      "辛": "酉",
      "壬": "亥",
      "癸": "子"
    },
    "locationDescriptionList": ["甲见寅，乙见卯，丙戊见巳，丁己见午，庚见申，辛见酉，壬见亥，癸见子"]
  },
  {
    "name": "游都",
    "jiXiong": "凶",
    "descriptionList": ["主贼盗、来敌"],
    "type": "干煞",
    "locationMapper": {
      "甲": "丑",
      "己": "丑",
      "乙": "子",
      "庚": "子",
      "丙": "寅",
      "辛": "寅",
      "丁": "巳",
      "壬": "巳",
      "戊": "申",
      "癸": "申"
    },
    "locationDescriptionList": ["甲己见丑，乙庚见子，丙辛见寅，丁壬见巳，戊癸见申"]
  },
  {
    "name": "日德",
    "jiXiong": "吉",
    "descriptionList": ["主道德、贵人"],
    "type": "干煞",
    "locationMapper": {
      "甲": "寅",
      "己": "寅",
      "乙": "申",
      "庚": "申",
      "丙": "巳",
      "辛": "巳",
      "丁": "亥",
      "壬": "亥",
      "戊": "巳",
      "癸": "巳"
    },
    "locationDescriptionList": ["甲己见寅，乙庚见申，丙辛戊癸见巳，丁壬见亥"]
  },
  {
    "name": "禄神",
    "jiXiong": "吉",
    "descriptionList": ["主福禄、食物"],
    "type": "干煞",
    "locationMapper": {
      "甲": "寅",
      "乙": "卯",
      "丙": "巳",
      "戊": "巳",
      "丁": "午",
      "己": "午",
      "庚": "申",
      "辛": "酉",
      "壬": "亥",
      "癸": "子"
    },
    "locationDescriptionList": ["甲见寅，乙见卯，丙戊见巳，丁己见午，庚见申，辛见酉，壬见亥，癸见子"]
  },
  {
    "name": "羊刃",
    "jiXiong": "凶",
    "descriptionList": ["主财物耗散，血光之灾"],
    "type": "干煞",
    "locationMapper": {
      "甲": "卯",
      "乙": "寅",
      "丙": "午",
      "戊": "午",
      "丁": "巳",
      "己": "巳",
      "庚": "酉",
      "辛": "申",
      "壬": "子",
      "癸": "亥"
    },
    "locationDescriptionList": ["甲见卯，乙见寅，丙戊见午，丁己见巳，庚见酉，辛见申，壬见子，癸见亥"]
  },
  {
    "name": "败神",
    "jiXiong": "凶",
    "descriptionList": ["主破败、淫乱"],
    "type": "干煞",
    "locationMapper": {
      "甲": "申",
      "乙": "酉",
      "丙": "子",
      "丁": "丑",
      "戊": "子",
      "己": "丑",
      "庚": "寅",
      "辛": "卯",
      "壬": "巳",
      "癸": "午"
    },
    "locationDescriptionList": ["甲见申，乙见酉，丙戊见子，丁己见丑，庚见寅，辛见卯，壬见巳，癸见午"]
  },
    {
    "name": "鲁都",
    "jiXiong": "凶",
    "descriptionList": ["主争斗、是非，象征外来冲突"],
    "type": "干煞",
    "locationMapper": {
      "甲": "寅",
      "己": "寅",
      "乙": "卯",
      "庚": "卯",
      "丙": "巳",
      "辛": "巳",
      "丁": "午",
      "壬": "午",
      "戊": "申",
      "癸": "申"
    },
    "locationDescriptionList": ["甲己在寅，乙庚在卯，丙辛在巳，丁壬在午，戊癸在申，主外来纷争"]
  },  
  {
    "name": "日贼",
    "jiXiong": "凶",
    "descriptionList": ["主暗中侵害、损耗，需防小人算计、财物暗失"],
    "type": "干煞",
    "locationMapper": {
      "甲": "申",
      "乙": "酉",
      "丙": "亥",
      "丁": "子",
      "戊": "亥",
      "己": "子",
      "庚": "寅",
      "辛": "卯",
      "壬": "巳",
      "癸": "午"
    },
    "locationDescriptionList": ["日干被克之支为日贼，如甲日贼在申，主暗中受克"]
  },
    {
    "name": "日奸",
    "jiXiong": "凶",
    "descriptionList": ["主奸邪、背叛，象征内部奸佞、暗中作乱"],
    "type": "支煞",
    "locationMapper": {
      "甲": "己",
      "乙": "庚",
      "丙": "辛",
      "丁": "壬",
      "戊": "癸",
      "己": "甲",
      "庚": "乙",
      "辛": "丙",
      "壬": "丁",
      "癸": "戊"
    },
    "locationDescriptionList": ["日干受克且相合之支为日奸，如甲日奸在己，主阴谋诡计"]
  },
    {
    "name": "贤贵",
    "jiXiong": "吉",
    "descriptionList": ["主贤才、贵人，象征贤能之士、贵人相助"],
    "type": "干煞",
    "locationMapper": {
      "甲": "丑",
      "乙": "申",
      "丙": "寅",
      "丁": "寅",
      "戊": "午",
      "己": "丑",
      "庚": "申",
      "辛": "寅",
      "壬": "寅",
      "癸": "午"
    },
    "locationDescriptionList": ["干禄地支为贤贵，如甲日贤贵在寅，主遇贵人相助"]
  },
  {
    "name": "文星",
    "jiXiong": "吉",
    "descriptionList": ["主文学、智慧", "除戊己日外，俱是五行之长生之地，与学堂同","文星并龙加子，大贵"],
    "type": "干煞",
    "locationMapper": {
      "甲": "亥",
      "乙": "寅",
      "丙": "午",
      "丁": "巳",
      "戊": "申",
      "己": "亥",
      "庚": "寅",
      "辛": "午",
      "壬": "巳",
      "癸": "申"
    },
    "locationDescriptionList": ["甲己日亥，丙辛日午，戊癸日申，乙庚日寅，丁壬日巳"]
  },
    {
    "name": "日下大煞",
    "jiXiong": "凶",
    "descriptionList": ["凡事忌，与月大煞类似"],
    "type": "干煞",
    "locationMapper": {
      "甲": "亥",
      "乙": "未",
      "丙": "戌",
      "丁": "寅",
      "戊": "巳",
      "己": "亥",
      "庚": "未",
      "辛": "戌",
      "壬": "寅",
      "癸": "巳"
    },
    "locationDescriptionList": ["甲己日亥，乙庚日未，丙辛日戌，丁壬日寅，戊癸日巳"]
  },
      {
    "name": "日淫",
    "jiXiong": "凶",
    "descriptionList": [""],
    "type": "干煞",
    "locationMapper": {
      "甲": "午",
      "乙": "未",
      "丙": "戌",
      "丁": "寅",
      "戊": "午",
      "己": "亥",
      "庚": "未",
      "辛": "戌",
      "壬": "寅",
      "癸": "巳"
    },
    "locationDescriptionList": ["甲己日午，乙庚日未，丙辛日戌，戊癸日巳"]
  },
    {
    "name": "学堂",
    "jiXiong": "吉",
    "descriptionList": ["主文学、智慧", "俱是五行之长生之地，与文星同"],
    "type": "干煞",
    "locationMapper": {
      "甲": "亥",
      "乙": "亥",
      "丙": "寅",
      "丁": "寅",
      "戊": "午",
      "己": "午",
      "庚": "巳",
      "辛": "巳",
      "壬": "申",
      "癸": "申"
    },
    "locationDescriptionList": ["甲乙日亥，丙丁日寅，戊己日午，庚辛日巳，壬癸日申"]
  },
  {
    "name": "福星",
    "jiXiong": "吉",
    "descriptionList": ["主福德、吉庆","作事吉，逢刑则关系不睦"],
    "type": "干煞",
    "locationMapper": {
      "甲": "子",
      "乙": "丑",
      "丙": "子",
      "丁": "子",
      "戊": "未",
      "己": "未",
      "庚": "丑",
      "辛": "丑",
      "壬": "巳",
      "癸": "巳"
    },
    "locationDescriptionList": ["甲日子，乙日丑，丙丁日子，戊己日未，庚辛日丑，壬癸日巳"]
  },
  {
    "name": "直符",
    "jiXiong": "吉",
    "descriptionList": ["主中正、权威，象征直接指令、核心力量"],
    "type": "干煞",
    "locationMapper": {
      "甲": "巳",
      "乙": "辰",
      "丙": "卯",
      "丁": "寅",
      "戊": "丑",
      "己": "午",
      "庚": "未",
      "辛": "申",
      "壬": "酉",
      "癸": "戌"
    },
    "locationDescriptionList": ["六甲旬首所临地支为直符，主号令统一，行事顺遂"]
  },
    {
    "name": "兼务",
    "jiXiong": "吉",
    "descriptionList": ["占官主兼两任"],
    "type": "干煞",
    "locationMapper": {
      "甲": "戌",
      "乙": "酉",
      "丙": "申",
      "丁": "未",
      "戊": "午",
      "己": "巳",
      "庚": "辰",
      "辛": "卯",
      "壬": "寅",
      "癸": "亥"
    },
    "locationDescriptionList": [""]
  },
      {
    "name": "日解",
    "jiXiong": "吉",
    "descriptionList": ["解凶"],
    "type": "干煞",
    "locationMapper": {
      "甲": "亥",
      "乙": "申",
      "丙": "未",
      "丁": "丑",
      "戊": "酉",
      "己": "亥",
      "庚": "申",
      "辛": "未",
      "壬": "丑",
      "癸": "酉"
    },
    "locationDescriptionList": [""]
  },
        {
    "name": "日医",
    "jiXiong": "吉",
    "descriptionList": ["生合日干可服其药，否则不吉急病视日医，缓病视天地医"],
    "type": "干煞",
    "locationMapper": {
      "甲": "卯",
      "乙": "亥",
      "丙": "丑",
      "丁": "未",
      "戊": "巳",
      "己": "卯",
      "庚": "亥",
      "辛": "丑",
      "壬": "未",
      "癸": "巳"
    },
    "locationDescriptionList": [""]
  },
  {
    "name": "日盗",
    "jiXiong": "凶",
    "descriptionList": ["遗失、偷盗"],
    "type": "干煞",
    "locationMapper": {
      "甲": "子",
      "乙": "亥",
      "丙": "卯",
      "丁": "申",
      "戊": "巳",
      "己": "子",
      "庚": "亥",
      "辛": "卯",
      "壬": "申",
      "癸": "巳"
    },
    "locationDescriptionList": [""]
  },
    {
    "name": "天盗",
    "jiXiong": "凶",
    "descriptionList": ["遗失、偷盗"],
    "type": "干煞",
    "locationMapper": {
      "甲": "子",
      "乙": "亥",
      "丙": "卯",
      "丁": "申",
      "戊": "巳",
      "己": "子",
      "庚": "亥",
      "辛": "卯",
      "壬": "申",
      "癸": "巳"
    },
    "locationDescriptionList": [""]
  },
      {
    "name": "金舆",
    "jiXiong": "吉",
    "descriptionList": ["得妻财"],
    "type": "干煞",
    "locationMapper": {
      "甲": "辰",
      "乙": "巳",
      "丙": "未",
      "丁": "申",
      "戊": "未",
      "己": "申",
      "庚": "戌",
      "辛": "亥",
      "壬": "丑",
      "癸": "寅"
    },
    "locationDescriptionList": [""]
  },
        {
    "name": "文昌",
    "jiXiong": "吉",
    "descriptionList": ["聪明、学习好"],
    "type": "干煞",
    "locationMapper": {
      "甲": "巳",
      "乙": "午",
      "丙": "申",
      "丁": "酉",
      "戊": "申",
      "己": "酉",
      "庚": "亥",
      "辛": "子",
      "壬": "寅",
      "癸": "卯"
    },
    "locationDescriptionList": [""]
  },
  {
    "name": "天贼",
    "jiXiong": "凶",
    "descriptionList": [""],
    "type": "干煞",
    "locationMapper": {
      "甲": "辰",
      "乙": "午",
      "丙": "申",
      "丁": "亥",
      "戊": "寅",
      "己": "辰",
      "庚": "午",
      "辛": "申",
      "壬": "亥",
      "癸": "寅"
    },
    "locationDescriptionList": [""]
  },
    {
    "name": "五合",
    "jiXiong": "吉",
    "descriptionList": ["和合之神，凡占大吉"],
    "type": "干煞",
    "locationMapper": {
      "甲": "未",
      "乙": "申",
      "丙": "戌",
      "丁": "亥",
      "戊": "丑",
      "己": "寅",
      "庚": "辰",
      "辛": "巳",
      "壬": "未",
      "癸": "巳"
    },
    "locationDescriptionList": [""]
  },
    {
    "name": "进神",
    "jiXiong": "吉",
    "descriptionList": ["主前进事", "进神不可退，退则可惜"],
    "type": "日煞",
    "locationMapper": {
      "甲": "子午",
      "乙": "子午",
      "丙": "子午",
      "丁": "子午",
      "戊": "子午",
      "己": "卯酉",
      "庚": "卯酉",
      "辛": "卯酉",
      "壬": "卯酉",
      "癸": "卯酉"
    },
    "locationDescriptionList": ["甲乙丙丁戊日子午为进神", "己庚辛壬癸日卯酉为进神"]
  },
  {
    "name": "退神",
    "jiXiong": "凶",
    "descriptionList": ["主后退事", "退神不可进，进则多阻"],
    "type": "日煞",
    "locationMapper": {
      "甲": "丑未",
      "乙": "丑未",
      "丙": "丑未",
      "丁": "丑未",
      "戊": "丑未",
      "己": "辰戌",
      "庚": "辰戌",
      "辛": "辰戌",
      "壬": "辰戌",
      "癸": "辰戌"
    },
    "locationDescriptionList": ["甲乙丙丁戊日子午为退神", "己庚辛壬癸日辰戌为退神"]
  },
    {
    "name": "贵人",
    "jiXiong": "凶",
    "descriptionList": ["主后退事", "退神不可进，进则多阻"],
    "type": "日煞",
    "locationMapper": {
      "甲": "丑未",
      "乙": "子申",
      "丙": "亥酉",
      "丁": "亥酉",
      "戊": "丑未",
      "己": "子申",
      "庚": "丑未",
      "辛": "午寅",
      "壬": "卯巳",
      "癸": "卯巳"
    },
    "locationDescriptionList": ["甲乙丙丁戊日子午为退神", "己庚辛壬癸日辰戌为退神"]
  },
    {
    "name": "红艳",
    "jiXiong": "凶",
    "descriptionList": ["主后退事", "退神不可进，进则多阻"],
    "type": "日煞",
    "locationMapper": {
      "甲": "午申",
      "乙": "午申",
      "丙": "寅",
      "丁": "未",
      "戊": "辰",
      "己": "辰",
      "庚": "戌",
      "辛": "酉",
      "壬": "子",
      "癸": "申"
    },
    "locationDescriptionList": ["甲乙丙丁戊日子午为退神", "己庚辛壬癸日辰戌为退神"]
  }
]');
INSERT INTO shen_sha_document ("file_name", "payload_json") VALUES ('6_shensha_ji.json', '[
  {
    "name": "天喜",
    "jiXiong": "吉",
    "descriptionList": ["主喜庆、恩泽、官迁、财喜"],
    "type": "季煞",
    "locationMapper": {
      "春": "戌",
      "夏": "丑",
      "秋": "辰",
      "冬": "未"
    },
    "locationDescriptionList": ["春戌夏丑秋辰冬未"]
  },
  {
    "name": "孤辰",
    "jiXiong": "凶",
    "descriptionList": ["主孤独、婚失"],
    "type": "季煞",
    "locationMapper": {
      "春": "巳",
      "夏": "申",
      "秋": "亥",
      "冬": "寅"
    },
    "locationDescriptionList": ["春起巳，顺四孟，四季之病地也，即春巳夏申秋亥冬寅"]
  },
  {
    "name": "寡宿",
    "jiXiong": "凶",
    "descriptionList": ["义同孤辰", "春起丑，顺四库，四季之冠带也"],
    "type": "季煞",
    "locationMapper": {
      "春": "丑",
      "夏": "辰",
      "秋": "未",
      "冬": "戌"
    },
    "locationDescriptionList": ["春起丑，顺四库，四季之冠带也，即春丑夏辰秋未冬戌"]
  },
  {
    "name": "关神",
    "otherNameList":["关官"],
    "jiXiong": "凶",
    "descriptionList": ["占讼有拘幽"],
    "type": "季煞",
    "locationMapper": {
      "春": "丑",
      "夏": "辰",
      "秋": "未",
      "冬": "戌"
    },
    "locationDescriptionList": ["春起丑，顺四库，四季之冠带也，即春丑夏辰秋未冬戌"]
  },
  {
    "name": "三丘",
    "jiXiong": "凶",
    "descriptionList": ["主坟墓事，占病主死丧之象"],
    "type": "季煞",
    "locationMapper": {
      "春": "丑",
      "夏": "辰",
      "秋": "未",
      "冬": "戌"
    },
    "locationDescriptionList": ["春起丑，顺四库，四季之冠带也，即春丑夏辰秋未冬戌"]
  },
    {
    "name": "死别",
    "jiXiong": "凶",
    "descriptionList": [""],
    "type": "季煞",
    "locationMapper": {
      "春": "戌",
      "夏": "酉",
      "秋": "申",
      "冬": "未"
    },
    "locationDescriptionList": ["「春戌逆回为死别」"]
  },
  {
    "name": "天车",
    "jiXiong": "凶",
    "descriptionList": ["天车煞不宜出行，主损蹄轮,不宜出兵"],
    "type": "季煞",
    "locationMapper": {
      "春": "丑",
      "夏": "辰",
      "秋": "未",
      "冬": "戌"
    },
    "locationDescriptionList": ["春起丑，顺四库，四季之冠带也，即春丑夏辰秋未冬戌"]
  },
  
   {
    "name": "天车2",
    "jiXiong": "凶",
    "descriptionList": ["天车煞不宜出行，主损蹄轮"],
    "type": "季煞",
    "locationMapper": {
      "春": "巳",
      "夏": "辰",
      "秋": "未",
      "冬": "酉"
    },
    "locationDescriptionList": ["「巳辰未酉天车惊」"]
  },
    {
    "name": "泰神",
    "jiXiong": "吉",
    "descriptionList": ["占信用"],
    "type": "季煞",
    "locationMapper": {
      "春": "丑",
      "夏": "子",
      "秋": "戌",
      "冬": "亥"
    },
    "locationDescriptionList": ["「丑子戌亥忧泰决」"]
  },
      {
    "name": "忧神",
    "jiXiong": "凶",
    "descriptionList": ["占信用"],
    "type": "季煞",
    "locationMapper": {
      "春": "丑",
      "夏": "子",
      "秋": "戌",
      "冬": "亥"
    },
    "locationDescriptionList": ["「丑子戌亥忧泰决」"]
  },
  {
    "name": "五墓",
    "jiXiong": "凶",
    "descriptionList": ["五墓、哭神主坟墓，占病主死"],
    "type": "季煞",
    "locationMapper": {
      "春": "未",
      "夏": "戌",
      "秋": "丑",
      "冬": "辰"
    },
    "locationDescriptionList": ["三丘之对冲，春起未，顺四库，四季之墓地也，即春未夏戌秋丑冬辰"]
  },
  {
    "name": "墓神",
    "jiXiong": "凶",
    "descriptionList": ["五墓、哭神主坟墓，占病主死"],
    "type": "季煞",
    "locationMapper": {
      "春": "未",
      "夏": "戌",
      "秋": "丑",
      "冬": "辰"
    },
    "locationDescriptionList": ["三丘之对冲，春起未，顺四库，四季之墓地也，即春未夏戌秋丑冬辰"]
  },
  {
    "name": "哭神",
    "jiXiong": "凶",
    "descriptionList": ["五墓、哭神主坟墓，占病主死"],
    "type": "季煞",
    "locationMapper": {
      "春": "未",
      "夏": "戌",
      "秋": "丑",
      "冬": "辰"
    },
    "locationDescriptionList": ["三丘之对冲，春起未，顺四库，四季之墓地也，即春未夏戌秋丑冬辰"]
  },
  {
    "name": "皇书",
    "jiXiong": "吉",
    "descriptionList": ["主科名，功名、词讼喜之"],
    "type": "季煞",
    "locationMapper": {
      "春": "寅",
      "夏": "巳",
      "秋": "申",
      "冬": "亥"
    },
    "locationDescriptionList": ["春起寅，顺四孟，四季之禄神也，即春寅夏巳秋申冬亥"]
  },
  {
    "name": "皇诏",
    "jiXiong": "吉",
    "descriptionList": ["主科名，功名、词讼喜之"],
    "type": "季煞",
    "locationMapper": {
      "春": "寅",
      "夏": "巳",
      "秋": "申",
      "冬": "亥"
    },
    "locationDescriptionList": ["春起寅，顺四孟，四季之禄神也，即春寅夏巳秋申冬亥"]
  },
  {
    "name": "战雄",
    "jiXiong": "吉",
    "descriptionList": ["主战胜"],
    "type": "季煞",
    "locationMapper": {
      "春": "寅",
      "夏": "巳",
      "秋": "申",
      "冬": "亥"
    },
    "locationDescriptionList": ["春起寅，顺四孟，四季之禄神也，即春寅夏巳秋申冬亥"]
  },
  {
    "name": "孤雄",
    "jiXiong": "吉",
    "descriptionList": ["主战胜"],
    "type": "季煞",
    "locationMapper": {
      "春": "寅",
      "夏": "巳",
      "秋": "申",
      "冬": "亥"
    },
    "locationDescriptionList": ["春起寅，顺四孟，四季之禄神也，即春寅夏巳秋申冬亥"]
  },
  {
    "name": "九天",
    "jiXiong": "吉",
    "descriptionList": ["主战胜"],
    "type": "季煞",
    "locationMapper": {
      "春": "寅",
      "夏": "巳",
      "秋": "申",
      "冬": "亥"
    },
    "locationDescriptionList": ["春起寅，顺四孟，四季之禄神也，即春寅夏巳秋申冬亥"]
  },
  {
    "name": "战雌",
    "jiXiong": "凶",
    "descriptionList": ["主战败"],
    "type": "季煞",
    "locationMapper": {
      "春": "申",
      "夏": "亥",
      "秋": "寅",
      "冬": "巳"
    },
    "locationDescriptionList": ["战雄之对冲，春起申，顺四孟，四季之绝地也，即春申夏亥秋寅冬巳"]
  },
  {
    "name": "天目",
    "jiXiong": "凶",
    "descriptionList": ["占宅主家中有鬼祟，多用于捕盗、寻人","主怪异，占宅有鬼，有伏尸"],
    "type": "季煞",
    "locationMapper": {
      "春": "辰",
      "夏": "未",
      "秋": "戌",
      "冬": "丑"
    },
    "locationDescriptionList": ["春起辰，顺四库，四季之衰地也，即春辰夏未秋戌冬丑"]
  },
  {
    "name": "浴盆",
    "jiXiong": "凶",
    "descriptionList": ["占病凶，不逢水者吉","小儿占病忌之（占病忌见水，地盘浴盆上见亥、子，天盘浴盆上见天后、玄武）"],
    "type": "季煞",
    "locationMapper": {
      "春": "辰",
      "夏": "未",
      "秋": "戌",
      "冬": "丑"
    },
    "locationDescriptionList": ["春起辰，顺四库，四季之衰地也，即春辰夏未秋戌冬丑"]
  },
    {
    "name": "钥神",
    "jiXiong": "吉",
    "descriptionList": ["主释放"],
    "type": "季煞",
    "locationMapper": {
      "春": "辰",
      "夏": "未",
      "秋": "戌",
      "冬": "丑"
    },
    "locationDescriptionList": ["春起辰，顺四库，四季之衰地也，即春辰夏未秋戌冬丑"]
  },
  {
    "name": "天耳",
    "jiXiong": "吉",
    "descriptionList": ["同天目论，为耳目视听之神,所临之方宜查探、追捕"],
    "type": "季煞",
    "locationMapper": {
      "春": "戌",
      "夏": "丑",
      "秋": "辰",
      "冬": "未"
    },
    "locationDescriptionList": ["天目对冲之辰，春起戌，顺四库，四季之养神也，即春戌夏丑秋辰冬未"]
  },
  {
    "name": "丧车",
    "jiXiong": "凶",
    "descriptionList": ["丧车克日主病死"],
    "type": "季煞",
    "locationMapper": {
      "春": "酉",
      "夏": "子",
      "秋": "卯",
      "冬": "午"
    },
    "locationDescriptionList": ["春起酉，顺四仲，四季之胎神也，即春酉夏子秋卯冬午"]
  },
  {
    "name": "四废",
    "jiXiong": "凶",
    "descriptionList": ["主百事无成"],
    "type": "季煞",
    "locationMapper": {
      "春": "酉",
      "夏": "子",
      "秋": "卯",
      "冬": "午"
    },
    "locationDescriptionList": ["春起酉，顺四仲，四季之胎神也，即春酉夏子秋卯冬午"]
  },
  {
    "name": "火鬼",
    "jiXiong": "凶",
    "descriptionList": ["火鬼乘蛇雀主火厄"],
    "otherNameList":["火煞"],
    "type": "季煞",
    "locationMapper": {
      "春": "午",
      "夏": "酉",
      "秋": "子",
      "冬": "卯"
    },
    "locationDescriptionList": ["春起午，顺四仲，四季之死地也，即春午夏酉秋子冬卯"]
  },
  {
    "name": "返魂",
    "jiXiong": "吉",
    "descriptionList": ["占病死而复生"],
    "type": "季煞",
    "locationMapper": {
      "春": "亥子",
      "夏": "寅卯",
      "秋": "巳午",
      "冬": "申酉"
    },
    "locationDescriptionList": ["四季之长生与败神也，即春亥子，夏寅卯，秋巳午，冬申酉"]
  },
  {
    "name": "迷惑",
    "jiXiong": "凶",
    "descriptionList": ["主痴迷走失"],
    "type": "季煞",
    "locationMapper": {
      "春": "丑",
      "夏": "戌",
      "秋": "未",
      "冬": "辰"
    },
    "locationDescriptionList": ["春起丑，逆四库，即春丑夏戌秋未冬辰"]
  },
  {
    "name": "游神",
    "jiXiong": "中性",
    "descriptionList": ["为动神，在家想出，在外想回"],
    "type": "季煞",
    "locationMapper": {
      "春": "丑",
      "夏": "子",
      "秋": "亥",
      "冬": "戌"
    },
    "locationDescriptionList": ["春起丑，逆四辰，即春丑，夏子，秋亥，冬戌"]
  },
  {
    "name": "戏神",
    "jiXiong": "中性",
    "descriptionList": ["同游神"],
    "type": "季煞",
    "locationMapper": {
      "春": "巳",
      "夏": "子",
      "秋": "酉",
      "冬": "辰"
    },
    "locationDescriptionList": ["春巳，夏子，秋酉，冬辰"]
  },
    {
    "name": "大德",
    "jiXiong": "吉",
    "descriptionList": ["官迁，谋望大吉"],
    "type": "季煞",
    "locationMapper": {
      "春": "午",
      "夏": "辰",
      "秋": "子",
      "冬": "寅"
    },
    "locationDescriptionList": ["大德午辰子寅"]
  },
  {
    "name": "时盗",
    "jiXiong": "凶",
    "descriptionList": ["主奸私盗贼"],
    "type": "季煞",
    "locationMapper": {
      "春": "卯",
      "夏": "巳",
      "秋": "申",
      "冬": "子"
    },
    "locationDescriptionList": ["春卯、夏巳、秋申、冬子"]
  },
  {
    "name": "贼神",
    "jiXiong": "凶",
    "descriptionList": ["主奸私盗贼"],
    "type": "季煞",
    "locationMapper": {
      "春": "卯",
      "夏": "巳",
      "秋": "申",
      "冬": "子"
    },
    "locationDescriptionList": ["春卯、夏巳、秋申、冬子"]
  },
  {
    "name": "贼符",
    "jiXiong": "凶",
    "descriptionList": ["主奸私盗贼"],
    "type": "季煞",
    "locationMapper": {
      "春": "卯",
      "夏": "巳",
      "秋": "申",
      "冬": "子"
    },
    "locationDescriptionList": ["春卯、夏巳、秋申、冬子"]
  },
  {
    "name": "奸神",
    "jiXiong": "凶",
    "descriptionList": ["主奸私盗贼"],
    "type": "季煞",
    "locationMapper": {
      "春": "卯",
      "夏": "巳",
      "秋": "申",
      "冬": "子"
    },
    "locationDescriptionList": ["春卯、夏巳、秋申、冬子"]
  },
  {
    "name": "丝麻",
    "jiXiong": "凶",
    "descriptionList": ["主奸私盗贼"],
    "type": "季煞",
    "locationMapper": {
      "春": "卯",
      "夏": "巳",
      "秋": "申",
      "冬": "子"
    },
    "locationDescriptionList": ["春卯、夏巳、秋申、冬子"]
  },
  {
    "name": "天赦",
    "jiXiong": "大吉",
    "descriptionList": ["主恩赦人情，官讼喜见", "天之生育甲与戊，地之成立子午寅申，故以甲戊配成天赦"],
    "type": "季煞",
    "locationMapper": {
      "春": "戊寅",
      "夏": "甲午",
      "秋": "戊申",
      "冬": "甲子"
    },
    "locationDescriptionList": ["春戊寅、夏甲午、秋戊申、冬甲子也。以《指南》课例观之，春遇寅，夏遇午，秋遇申，冬遇子，亦可做天赦看"]
  },
    {
    "name": "四煞",
    "jiXiong": "凶",
    "descriptionList": ["主四时凶煞，易犯灾祸、凶祸"],
    "type": "季煞",
    "locationMapper": {
      "春": "巳",
      "夏": "申",
      "秋": "亥",
      "冬": "寅"
    },
    "locationDescriptionList": ["春煞在巳，夏煞在申，秋煞在亥，冬煞在寅，每季需避对应方位"]
  },
      {
    "name": "天城",
    "jiXiong": "吉",
    "descriptionList": ["主四时凶煞，易犯灾祸、凶祸"],
    "type": "季煞",
    "locationMapper": {
      "春": "申",
      "夏": "申",
      "秋": "申",
      "冬": "申"
    },
    "locationDescriptionList": []
  },
        {
    "name": "天吏",
    "jiXiong": "吉",
    "descriptionList": ["求官吉，占讼词乘吉将者吉。乘勾、武、虎、蛇、雀者，主追呼"],
    "type": "季煞",
    "locationMapper": {
      "春": "寅",
      "夏": "寅",
      "秋": "寅",
      "冬": "寅"
    },
    "locationDescriptionList": []
  },
          {
    "name": "飞祸",
    "jiXiong": "吉",
    "descriptionList": ["刑四孟之神，主横祸"],
    "type": "季煞",
    "locationMapper": {
      "春": "申",
      "夏": "寅",
      "秋": "巳",
      "冬": "亥"
    },
    "locationDescriptionList": []
  },
  {
    "name": "天盗",
    "jiXiong": "凶",
    "descriptionList": [""],
    "type": "季煞",
    "locationMapper": {
      "春": "卯",
      "夏": "午",
      "秋": "酉",
      "冬": "子"
    },
    "locationDescriptionList": []
  },
    {
    "name": "转煞",
    "jiXiong": "凶",
    "descriptionList": ["四季之旺神，物极必反，凡占皆有凶灾"],
    "type": "季煞",
    "locationMapper": {
      "春": "卯",
      "夏": "午",
      "秋": "酉",
      "冬": "子"
    },
    "locationDescriptionList": []
  },
      {
    "name": "飞魂",
    "jiXiong": "凶",
    "descriptionList": ["主鬼祟相侵，夜梦不祥，占宅有怪"],
    "type": "季煞",
    "locationMapper": {
      "春": "子",
      "夏": "卯",
      "秋": "午",
      "冬": "酉"
    },
    "locationDescriptionList": []
  },
  {
    "name": "奸神2",
    "jiXiong": "凶",
    "descriptionList": ["主奸私盗贼"],
    "type": "季煞",
    "locationMapper": {
      "春": "卯",
      "夏": "巳",
      "秋": "申",
      "冬": "子"
    },
    "locationDescriptionList": ["春卯、夏巳、秋申、冬子，基于四季旺支（卯为春旺、巳为夏旺、申为秋旺、子为冬旺）推导，以旺气过盛为奸盗之因"]
  },
  {
    "name": "奸神1",
    "jiXiong": "凶",
    "descriptionList": ["主奸私盗贼"],
    "type": "季煞",
    "locationMapper": {
      "春": "寅",
      "夏": "亥",
      "秋": "申",
      "冬": "巳"
    },
    "locationDescriptionList": ["春寅、夏亥、秋申、冬巳，基于地支刑冲关系（寅申冲、巳亥冲）推导，以冲克为是非奸盗之因，秋申与冬巳为固定位"]
  },
  {
    "name": "钥神1",
    "jiXiong": "吉",
    "descriptionList": ["主释放"],
    "type": "季煞",
    "locationMapper": {
      "春": "辰",
      "夏": "未",
      "秋": "戌",
      "冬": "丑"
    },
    "locationDescriptionList": ["春起辰，顺四库，四季之衰地也，即春辰夏未秋戌冬丑，以四季土库（辰、未、戌、丑）为核心，取“库藏解锁”之意"]
  },
  {
    "name": "钥神2",
    "jiXiong": "吉",
    "descriptionList": ["主释放"],
    "type": "季煞",
    "locationMapper": {
      "春": "巳",
      "夏": "申",
      "秋": "亥",
      "冬": "寅"
    },
    "locationDescriptionList": ["春起辰，顺四库，四季之衰地也，即春辰夏未秋戌冬丑（记载矛盾），实际基于四生之地（巳、申、亥、寅）推导，取“生气萌发而释放”之意"]
  },
  {
    "name": "天盗1",
    "jiXiong": "凶",
    "descriptionList": [""],
    "type": "季煞",
    "locationMapper": {
      "春": "卯",
      "夏": "午",
      "秋": "酉",
      "冬": "子"
    },
    "locationDescriptionList": ["春卯、夏午、秋酉、冬子，基于四正位（卯、午、酉、子为东南西北正位）推导，以“正位气纯而易生盗乱”为因"]
  },
  {
    "name": "天盗2",
    "jiXiong": "凶",
    "descriptionList": [""],
    "type": "季煞",
    "locationMapper": {
      "春": "酉",
      "夏": "午",
      "秋": "卯",
      "冬": "子"
    },
    "locationDescriptionList": ["春酉、夏午、秋卯、冬子，基于对冲关系（酉冲卯、卯冲酉）推导，以“冲克破局”为盗乱之因，夏午、冬子为固定位"]
  }
]');
INSERT INTO shen_sha_document ("file_name", "payload_json") VALUES ('6_shensha_month.json', '[
  {
    "name": "生气",
    "jiXiong": "吉",
    "descriptionList": [
      "壬学中最吉之物，解凶增吉，成就新事",
      "乘后合有孕",
      "乘龙财有婚",
      "唯占盗贼，鬼作生气，恐贼再来",
      "占病逢生气，病症日重"
    ],
    "type": "月煞",
    "locationMapper": {
      "寅": "子",
      "卯": "丑",
      "辰": "寅",
      "巳": "卯",
      "午": "辰",
      "未": "巳",
      "申": "午",
      "酉": "未",
      "戌": "申",
      "亥": "酉",
      "子": "戌",
      "丑": "亥"
    },
    "locationDescriptionList": ["月建后二辰", "正月起子，顺十二辰"]
  },
    {
    "name": "地医2",
    "jiXiong": "吉",
    "descriptionList": [
      "即生气，占与天医同"
    ],
    "type": "月煞",
    "locationMapper": {
      "寅": "子",
      "卯": "丑",
      "辰": "寅",
      "巳": "卯",
      "午": "辰",
      "未": "巳",
      "申": "午",
      "酉": "未",
      "戌": "申",
      "亥": "酉",
      "子": "戌",
      "丑": "亥"
    },
    "locationDescriptionList": ["月建后二辰", "正月起子，顺十二辰"]
  },
  {
    "name": "雨师",
    "jiXiong": "中性",
    "descriptionList": ["主雨"],
    "type": "月煞",
    "locationMapper": {
      "寅": "子",
      "卯": "丑",
      "辰": "寅",
      "巳": "卯",
      "午": "辰",
      "未": "巳",
      "申": "午",
      "酉": "未",
      "戌": "申",
      "亥": "酉",
      "子": "戌",
      "丑": "亥"
    },
    "locationDescriptionList": ["月建后二辰", "正月起子，顺十二辰"]
  },
  {
    "name": "血支",
    "jiXiong": "凶",
    "descriptionList": ["主血光，产孕病忌之"],
    "type": "月煞",
    "locationMapper": {
      "寅": "丑",
      "卯": "寅",
      "辰": "卯",
      "巳": "辰",
      "午": "巳",
      "未": "午",
      "申": "未",
      "酉": "申",
      "戌": "酉",
      "亥": "戌",
      "子": "亥",
      "丑": "子"
    },
    "locationDescriptionList": ["正月起丑，顺行十二辰", "起于旺建之后，生气之前（月建后一辰）"]
  },
  {
    "name": "天坑",
    "jiXiong": "凶",
    "descriptionList": ["出门遇之主不顺，防损伤之灾"],
    "type": "月煞",
    "locationMapper": {
      "寅": "丑",
      "卯": "寅",
      "辰": "卯",
      "巳": "辰",
      "午": "巳",
      "未": "午",
      "申": "未",
      "酉": "申",
      "戌": "酉",
      "亥": "戌",
      "子": "亥",
      "丑": "子"
    },
    "locationDescriptionList": ["正月起丑，顺行十二辰", "出门遇之主不顺，防损伤之灾"]
  },
    {
    "name": "兽煞",
    "jiXiong": "凶",
    "descriptionList": ["主走兽"],
    "type": "月煞",
    "locationMapper": {
      "寅": "戌",
      "卯": "子",
      "辰": "寅",
      "巳": "辰",
      "午": "午",
      "未": "申",
      "申": "戌",
      "酉": "子",
      "戌": "寅",
      "亥": "辰",
      "子": "午",
      "丑": "申"
    },
    "locationDescriptionList": ["正七戌，二八子....；「戌子寅辰午申，兽煞戌宫以例论」"]
  },
  {
    "name": "小时",
    "jiXiong": "凶",
    "descriptionList": ["主阻滞，忌行师", "蛇加惊恐", "龙加为青龙煞吉"],
    "type": "月煞",
    "locationMapper": {
      "寅": "寅",
      "卯": "卯",
      "辰": "辰",
      "巳": "巳",
      "午": "午",
      "未": "未",
      "申": "申",
      "酉": "酉",
      "戌": "戌",
      "亥": "亥",
      "子": "子",
      "丑": "丑"
    },
    "locationDescriptionList": ["同月建，正月起寅，顺十二辰"]
  },
  {
    "name": "天龙",
    "jiXiong": "吉",
    "descriptionList": ["利求名禄"],
    "type": "月煞",
    "locationMapper": {
      "寅": "卯",
      "卯": "辰",
      "辰": "巳",
      "巳": "午",
      "午": "未",
      "未": "申",
      "申": "酉",
      "酉": "戌",
      "戌": "亥",
      "亥": "子",
      "子": "丑",
      "丑": "寅"
    },
    "locationDescriptionList": ["月建前一位", "正月起卯，顺行十二辰", "指南云“天龙游煞草蛇伏”"]
  },
  {
    "name": "游煞",
    "jiXiong": "中性",
    "descriptionList": ["为游动之煞，主游动", "概因下一个月，为将旺之气，有渐渐增长的意思"],
    "type": "月煞",
    "locationMapper": {
      "寅": "卯",
      "卯": "辰",
      "辰": "巳",
      "巳": "午",
      "午": "未",
      "未": "申",
      "申": "酉",
      "酉": "戌",
      "戌": "亥",
      "亥": "子",
      "子": "丑",
      "丑": "寅"
    },
    "locationDescriptionList": ["月建前一位", "正月起卯，顺行十二辰", "指南云“天龙游煞草蛇伏”"]
  },
  {
    "name": "草煞",
    "jiXiong": "中性",
    "descriptionList": ["取渐渐增长之象"],
    "type": "月煞",
    "locationMapper": {
      "寅": "卯",
      "卯": "辰",
      "辰": "巳",
      "巳": "午",
      "午": "未",
      "未": "申",
      "申": "酉",
      "酉": "戌",
      "戌": "亥",
      "亥": "子",
      "子": "丑",
      "丑": "寅"
    },
    "locationDescriptionList": ["月建前一位", "正月起卯，顺行十二辰", "指南云“天龙游煞草蛇伏”"]
  },
  {
    "name": "蛇煞",
    "jiXiong": "中性",
    "descriptionList": ["取渐渐增长之象"],
    "type": "月煞",
    "locationMapper": {
      "寅": "卯",
      "卯": "辰",
      "辰": "巳",
      "巳": "午",
      "午": "未",
      "未": "申",
      "申": "酉",
      "酉": "戌",
      "戌": "亥",
      "亥": "子",
      "子": "丑",
      "丑": "寅"
    },
    "locationDescriptionList": ["月建前一位", "正月起卯，顺行十二辰", "指南云“天龙游煞草蛇伏”"]
  },
  {
    "name": "天医1",
    "jiXiong": "吉",
    "descriptionList": ["主病用，代表医生"],
    "type": "月煞",
    "locationMapper": {
      "寅": "辰",
      "卯": "巳",
      "辰": "午",
      "巳": "未",
      "午": "申",
      "未": "酉",
      "申": "戌",
      "酉": "亥",
      "戌": "子",
      "亥": "丑",
      "子": "寅",
      "丑": "卯"
    },
    "locationDescriptionList": ["正月起辰，顺行十二辰"]
  },
  {
    "name": "天医2",
    "jiXiong": "吉",
    "descriptionList": ["主病用，代表医生，生合日干，可服其药；作鬼克干，必为医误"],
    "type": "月煞",
    "locationMapper": {
      "寅": "子",
      "卯": "卯",
      "辰": "午",
      "巳": "酉",
      "午": "子",
      "未": "卯",
      "申": "午",
      "酉": "酉",
      "戌": "子",
      "亥": "卯",
      "子": "午",
      "丑": "酉"
    },
    "locationDescriptionList": ["寅午戌子，亥卯未卯，申子辰午，巳酉丑酉"]
  },
  {
    "name": "雌虎",
    "jiXiong": "凶",
    "descriptionList": ["主虎狼害"],
    "type": "月煞",
    "locationMapper": {
      "寅": "辰",
      "卯": "巳",
      "辰": "午",
      "巳": "未",
      "午": "申",
      "未": "酉",
      "申": "戌",
      "酉": "亥",
      "戌": "子",
      "亥": "丑",
      "子": "寅",
      "丑": "卯"
    },
    "locationDescriptionList": ["正月起辰，顺行十二辰"]
  },
  {
    "name": "瘟",
    "jiXiong": "凶",
    "descriptionList": ["主疫"],
    "type": "月煞",
    "locationMapper": {
      "寅": "辰",
      "卯": "巳",
      "辰": "午",
      "巳": "未",
      "午": "申",
      "未": "酉",
      "申": "戌",
      "酉": "亥",
      "戌": "子",
      "亥": "丑",
      "子": "寅",
      "丑": "卯"
    },
    "locationDescriptionList": ["正月起辰，顺行十二辰"]
  },
  {
    "name": "天巫",
    "jiXiong": "吉",
    "descriptionList": ["宜做福"],
    "type": "月煞",
    "locationMapper": {
      "寅": "辰",
      "卯": "巳",
      "辰": "午",
      "巳": "未",
      "午": "申",
      "未": "酉",
      "申": "戌",
      "酉": "亥",
      "戌": "子",
      "亥": "丑",
      "子": "寅",
      "丑": "卯"
    },
    "locationDescriptionList": ["正月起辰，顺行十二辰"]
  },
  {
    "name": "死气",
    "jiXiong": "凶",
    "descriptionList": [
      "主死丧之事",
      "病讼孕产最忌",
      "死气加临日干年命之上，必有死亡之惊",
      "死气再并飞魂、天鬼、病符、丧吊诸凶煞者，尤为凶象，更的"
    ],
    "type": "月煞",
    "locationMapper": {
      "寅": "午",
      "卯": "未",
      "辰": "申",
      "巳": "酉",
      "午": "戌",
      "未": "亥",
      "申": "子",
      "酉": "丑",
      "戌": "寅",
      "亥": "卯",
      "子": "辰",
      "丑": "巳"
    },
    "locationDescriptionList": ["月建前四位", "正月起午，顺十二辰", "为生气之冲辰，言彼旺则我死，与生气相对"]
  },
  {
    "name": "官符",
    "jiXiong": "凶",
    "descriptionList": ["主官司词讼之事"],
    "type": "月煞",
    "locationMapper": {
      "寅": "午",
      "卯": "未",
      "辰": "申",
      "巳": "酉",
      "午": "戌",
      "未": "亥",
      "申": "子",
      "酉": "丑",
      "戌": "寅",
      "亥": "卯",
      "子": "辰",
      "丑": "巳"
    },
    "locationDescriptionList": ["月建前四位", "正月起午，顺十二辰", "又为岁煞"]
  },
  {
    "name": "谩语",
    "jiXiong": "凶",
    "descriptionList": ["多虚诞"],
    "type": "月煞",
    "locationMapper": {
      "寅": "午",
      "卯": "未",
      "辰": "申",
      "巳": "酉",
      "午": "戌",
      "未": "亥",
      "申": "子",
      "酉": "丑",
      "戌": "寅",
      "亥": "卯",
      "子": "辰",
      "丑": "巳"
    },
    "locationDescriptionList": ["月建前四位", "正月起午，顺十二辰"]
  },
  {
    "name": "死神",
    "jiXiong": "凶",
    "descriptionList": ["与死气同论","占病凶，乘虎威衔尸，尤忌。"],
    "type": "月煞",
    "locationMapper": {
      "寅": "巳",
      "卯": "午",
      "辰": "未",
      "巳": "申",
      "午": "酉",
      "未": "戌",
      "申": "亥",
      "酉": "子",
      "戌": "丑",
      "亥": "寅",
      "子": "卯",
      "丑": "辰"
    },
    "locationDescriptionList": ["死气后一辰也", "正月起巳，顺十二辰"]
  },
  {
    "name": "月破",
    "jiXiong": "凶",
    "descriptionList": ["主破坏、离散", "婚嫁忌", "产易生", "事体月内不成"],
    "type": "月煞",
    "locationMapper": {
      "寅": "申",
      "卯": "酉",
      "辰": "戌",
      "巳": "亥",
      "午": "子",
      "未": "丑",
      "申": "寅",
      "酉": "卯",
      "戌": "辰",
      "亥": "巳",
      "子": "午",
      "丑": "未"
    },
    "locationDescriptionList": ["月建所冲之辰也", "正月起申，顺十二辰", "又为伏殃"]
  },
  {
    "name": "天机",
    "jiXiong": "中性",
    "descriptionList": ["主口舌"],
    "type": "月煞",
    "locationMapper": {
      "寅": "酉",
      "卯": "戌",
      "辰": "亥",
      "巳": "子",
      "午": "丑",
      "未": "寅",
      "申": "卯",
      "酉": "辰",
      "戌": "巳",
      "亥": "午",
      "子": "未",
      "丑": "申"
    },
    "locationDescriptionList": ["正月起酉，顺行十二位", "即月建后五位"]
  },
  {
    "name": "天信",
    "jiXiong": "吉",
    "descriptionList": ["并朱雀主信函", "又为信神、书信"],
    "type": "月煞",
    "locationMapper": {
      "寅": "酉",
      "卯": "戌",
      "辰": "亥",
      "巳": "子",
      "午": "丑",
      "未": "寅",
      "申": "卯",
      "酉": "辰",
      "戌": "巳",
      "亥": "午",
      "子": "未",
      "丑": "申"
    },
    "locationDescriptionList": ["正月起酉，顺行十二位", "月破前一位"]
  },
  {
    "name": "天钱",
    "jiXiong": "吉凶参半",
    "descriptionList": ["主钱怪或有钱堆积"],
    "type": "月煞",
    "locationMapper": {
      "寅": "酉",
      "卯": "戌",
      "辰": "亥",
      "巳": "子",
      "午": "丑",
      "未": "寅",
      "申": "卯",
      "酉": "辰",
      "戌": "巳",
      "亥": "午",
      "子": "未",
      "丑": "申"
    },
    "locationDescriptionList": ["正月起酉，顺行十二位"]
  },
  {
    "name": "地医1",
    "jiXiong": "吉",
    "descriptionList": ["与天医同论"],
    "type": "月煞",
    "locationMapper": {
      "寅": "戌",
      "卯": "亥",
      "辰": "子",
      "巳": "丑",
      "午": "寅",
      "未": "卯",
      "申": "辰",
      "酉": "巳",
      "戌": "午",
      "亥": "未",
      "子": "申",
      "丑": "酉"
    },
    "locationDescriptionList": ["天医所冲之辰也", "正月起戌，顺行十二辰"]
  },
  {
    "name": "天诏",
    "jiXiong": "吉",
    "descriptionList": ["主诏书之喜"],
    "type": "月煞",
    "locationMapper": {
      "寅": "亥",
      "卯": "子",
      "辰": "丑",
      "巳": "寅",
      "午": "卯",
      "未": "辰",
      "申": "巳",
      "酉": "午",
      "戌": "未",
      "亥": "申",
      "子": "酉",
      "丑": "戌"
    },
    "locationDescriptionList": ["月建后三位", "正月起亥，顺行十二辰"]
  },
  {
    "name": "飞魂",
    "jiXiong": "凶",
    "descriptionList": ["主神魂不定，夜多凶梦，鬼祟相侵"],
    "type": "月煞",
    "locationMapper": {
      "寅": "亥",
      "卯": "子",
      "辰": "丑",
      "巳": "寅",
      "午": "卯",
      "未": "辰",
      "申": "巳",
      "酉": "午",
      "戌": "未",
      "亥": "申",
      "子": "酉",
      "丑": "戌"
    },
    "locationDescriptionList": ["月建后三位", "正月起亥，顺行十二辰"]
  },
    {
    "name": "天贼2",
    "jiXiong": "凶",
    "descriptionList": [],
    "type": "月煞",
    "locationMapper": {
      "寅": "丑",
      "卯": "子",
      "辰": "亥",
      "巳": "戌",
      "午": "酉",
      "未": "申",
      "申": "未",
      "酉": "午",
      "戌": "巳",
      "亥": "辰",
      "子": "卯",
      "丑": "寅"
    },
    "locationDescriptionList": []
  },
      {
    "name": "天贼3",
    "jiXiong": "凶",
    "descriptionList": [],
    "type": "月煞",
    "locationMapper": {
      "寅": "辰",
      "卯": "酉",
      "辰": "寅",
      "巳": "未",
      "午": "子",
      "未": "巳",
      "申": "戌",
      "酉": "卯",
      "戌": "申",
      "亥": "丑",
      "子": "午",
      "丑": "亥"
    },
    "locationDescriptionList": []
  },
  {
    "name": "天怪",
    "jiXiong": "凶",
    "descriptionList": ["占天变"],
    "type": "月煞",
    "locationMapper": {
      "寅": "丑",
      "卯": "子",
      "辰": "亥",
      "巳": "戌",
      "午": "酉",
      "未": "申",
      "申": "未",
      "酉": "午",
      "戌": "巳",
      "亥": "辰",
      "子": "卯",
      "丑": "寅"
    },
    "locationDescriptionList": ["正月起丑（亦有午之说），逆行十二辰"]
  },
  {
    "name": "风煞",
    "jiXiong": "凶",
    "descriptionList": ["主有风"],
    "type": "月煞",
    "locationMapper": {
      "寅": "寅",
      "卯": "丑",
      "辰": "子",
      "巳": "亥",
      "午": "戌",
      "未": "酉",
      "申": "申",
      "酉": "未",
      "戌": "午",
      "亥": "巳",
      "子": "辰",
      "丑": "卯"
    },
    "locationDescriptionList": ["正月起寅，逆行十二辰"]
  },
  {
    "name": "厌对",
    "jiXiong": "凶",
    "descriptionList": ["忌婚娶"],
    "type": "月煞",
    "locationMapper": {
      "寅": "辰",
      "卯": "卯",
      "辰": "寅",
      "巳": "丑",
      "午": "子",
      "未": "亥",
      "申": "戌",
      "酉": "酉",
      "戌": "申",
      "亥": "未",
      "子": "午",
      "丑": "巳"
    },
    "locationDescriptionList": ["月厌对冲之辰", "正月起辰，逆行十二辰"]
  },
  {
    "name": "血光",
    "jiXiong": "凶",
    "descriptionList": ["有血灾"],
    "type": "月煞",
    "locationMapper": {
      "寅": "辰",
      "卯": "卯",
      "辰": "寅",
      "巳": "丑",
      "午": "子",
      "未": "亥",
      "申": "戌",
      "酉": "酉",
      "戌": "申",
      "亥": "未",
      "子": "午",
      "丑": "巳"
    },
    "locationDescriptionList": ["月厌对冲之辰", "正月起辰，逆行十二辰"]
  },
  {
    "name": "阴煞",
    "jiXiong": "凶",
    "descriptionList": ["主阴人口舌，病凶"],
    "type": "月煞",
    "locationMapper": {
      "寅": "巳",
      "卯": "辰",
      "辰": "卯",
      "巳": "寅",
      "午": "丑",
      "未": "子",
      "申": "亥",
      "酉": "戌",
      "戌": "酉",
      "亥": "申",
      "子": "未",
      "丑": "午"
    },
    "locationDescriptionList": ["正月起巳，逆行十二辰"]
  },
  {
    "name": "阴奸",
    "jiXiong": "凶",
    "descriptionList": ["主阴暗、私通、奸邪不正", "预测人品，婚外情等用之"],
    "type": "月煞",
    "locationMapper": {
      "寅": "未",
      "卯": "午",
      "辰": "巳",
      "巳": "辰",
      "午": "卯",
      "未": "寅",
      "申": "丑",
      "酉": "子",
      "戌": "亥",
      "亥": "戌",
      "子": "酉",
      "丑": "申"
    },
    "locationDescriptionList": ["正月起未，逆行十二辰"]
  },
  {
    "name": "风伯",
    "jiXiong": "中性",
    "descriptionList": ["主风"],
    "type": "月煞",
    "locationMapper": {
      "寅": "申",
      "卯": "未",
      "辰": "午",
      "巳": "巳",
      "午": "辰",
      "未": "卯",
      "申": "寅",
      "酉": "丑",
      "戌": "子",
      "亥": "亥",
      "子": "戌",
      "丑": "酉"
    },
    "locationDescriptionList": ["正月起申，逆行十二辰"]
  },
  {
    "name": "天鸡",
    "jiXiong": "中性",
    "descriptionList": ["主音信"],
    "type": "月煞",
    "locationMapper": {
      "寅": "酉",
      "卯": "申",
      "辰": "未",
      "巳": "午",
      "午": "巳",
      "未": "辰",
      "申": "卯",
      "酉": "寅",
      "戌": "丑",
      "亥": "子",
      "子": "亥",
      "丑": "戌"
    },
    "locationDescriptionList": ["正月起酉，逆行十二辰"]
  },

    {
    "name": "火光煞",
    "jiXiong": "凶",
    "descriptionList": [],
    "type": "月煞",
    "locationMapper": {
      "寅": "戌",
      "卯": "酉",
      "辰": "申",
      "巳": "未",
      "午": "午",
      "未": "巳",
      "申": "辰",
      "酉": "卯",
      "戌": "寅",
      "亥": "丑",
      "子": "子",
      "丑": "亥"
    },
    "locationDescriptionList": [""]
  },
  {
    "name": "月厌",
    "jiXiong": "凶",
    "descriptionList": [
      "妨嫁娶",
      "加玄盗贼",
      "加蛇怪梦",
      "加虎克日病死",
      "加朱勾忧禁",
      "逃者忌向此方",
      "又为脏神、埋汰神"
    ],
    "type": "月煞",
    "locationMapper": {
      "寅": "戌",
      "卯": "酉",
      "辰": "申",
      "巳": "未",
      "午": "午",
      "未": "巳",
      "申": "辰",
      "酉": "卯",
      "戌": "寅",
      "亥": "丑",
      "子": "子",
      "丑": "亥"
    },
    "locationDescriptionList": ["月建后四位", "正月起戌，逆行十二辰"]
  },
  {
    "name": "月合",
    "jiXiong": "吉",
    "descriptionList": ["主有吉喜庆", "勿与月将混","生干有吉"],
    "type": "月煞",
    "locationMapper": {
      "寅": "亥",
      "卯": "戌",
      "辰": "酉",
      "巳": "申",
      "午": "未",
      "未": "午",
      "申": "巳",
      "酉": "辰",
      "戌": "卯",
      "亥": "寅",
      "子": "丑",
      "丑": "子"
    },
    "locationDescriptionList": ["正月起亥，逆行十二辰"]
  },
  {
    "name": "成神1",
    "jiXiong": "吉",
    "descriptionList": ["主所谋得遂，成合事体","旺相生合，作事成就"],
    "type": "月煞",
    "locationMapper": {
      "寅": "巳",
      "卯": "寅",
      "辰": "亥",
      "巳": "申",
      "午": "巳",
      "未": "寅",
      "申": "亥",
      "酉": "申",
      "戌": "巳",
      "亥": "寅",
      "子": "亥",
      "丑": "申"
    },
    "locationDescriptionList": ["正月起巳，逆行四孟（巳、寅、亥、申），周而复始"]
  },
    {
    "name": "成神2",
    "jiXiong": "吉",
    "descriptionList": ["主所谋得遂，成合事体","旺相生合，作事成就"],
    "type": "月煞",
    "locationMapper": {
      "寅": "巳",
      "卯": "申",
      "辰": "亥",
      "巳": "寅",
      "午": "巳",
      "未": "申",
      "申": "亥",
      "酉": "寅",
      "戌": "巳",
      "亥": "申",
      "子": "亥",
      "丑": "寅"
    },
    "locationDescriptionList": ["正月起巳，顺行四孟（巳、申、亥、寅），周而复始"]
  },
  {
    "name": "奸门",
    "jiXiong": "凶",
    "descriptionList": ["主奸淫"],
    "type": "月煞",
    "locationMapper": {
      "寅": "申",
      "卯": "亥",
      "辰": "寅",
      "巳": "巳",
      "午": "申",
      "未": "亥",
      "申": "寅",
      "酉": "巳",
      "戌": "申",
      "亥": "亥",
      "子": "寅",
      "丑": "巳"
    },
    "locationDescriptionList": ["正月起申，顺行四孟（申、亥、寅、巳），周而复始"]
  },
  {
    "name": "阳煞",
    "jiXiong": "凶",
    "descriptionList": ["主阳人口舌"],
    "type": "月煞",
    "locationMapper": {
      "寅": "亥",
      "卯": "寅",
      "辰": "巳",
      "巳": "申",
      "午": "亥",
      "未": "寅",
      "申": "巳",
      "酉": "申",
      "戌": "亥",
      "亥": "寅",
      "子": "巳",
      "丑": "申"
    },
    "locationDescriptionList": ["正月起亥，顺行四孟（亥、寅、巳、申），周而复始"]
  },
  {
    "name": "雨煞",
    "jiXiong": "中性",
    "descriptionList": ["发用或传出，主雨"],
    "type": "月煞",
    "locationMapper": {
      "寅": "子",
      "卯": "卯",
      "辰": "午",
      "巳": "酉",
      "午": "子",
      "未": "卯",
      "申": "午",
      "酉": "酉",
      "戌": "子",
      "亥": "卯",
      "子": "午",
      "丑": "酉"
    },
    "locationDescriptionList": ["正月起子，顺行四仲（子、卯、午、酉），周而复始"]
  },
  {
    "name": "天破",
    "jiXiong": "凶",
    "descriptionList": ["出门遇之主不顺，防损伤之灾"],
    "type": "月煞",
    "locationMapper": {
      "寅": "午",
      "卯": "酉",
      "辰": "子",
      "巳": "卯",
      "午": "午",
      "未": "酉",
      "申": "子",
      "酉": "卯",
      "戌": "午",
      "亥": "酉",
      "子": "子",
      "丑": "卯"
    },
    "locationDescriptionList": ["正月起午，顺行四仲（午、酉、子、卯），周而复始"]
  },
  {
    "name": "天盗",
    "jiXiong": "凶",
    "descriptionList": ["主盗贼事"],
    "type": "月煞",
    "locationMapper": {
      "寅": "寅",
      "卯": "亥",
      "辰": "申",
      "巳": "巳",
      "午": "寅",
      "未": "亥",
      "申": "申",
      "酉": "巳",
      "戌": "寅",
      "亥": "亥",
      "子": "申",
      "丑": "巳"
    },
    "locationDescriptionList": ["正月起寅，逆行四孟（寅、亥、申、巳），周而复始"]
  },
  {
    "name": "雷公",
    "jiXiong": "中性",
    "descriptionList": ["主雷","乘蛇雀雷电，后武雨，贵空晴"],
    "type": "月煞",
    "locationMapper": {
      "寅": "寅",
      "卯": "亥",
      "辰": "申",
      "巳": "巳",
      "午": "寅",
      "未": "亥",
      "申": "申",
      "酉": "巳",
      "戌": "寅",
      "亥": "亥",
      "子": "申",
      "丑": "巳"
    },
    "locationDescriptionList": ["正月起寅，逆行四孟（寅、亥、申、巳），周而复始"]
  },
  {
    "name": "亡神",
    "jiXiong": "凶",
    "descriptionList": ["主坟墓事", "占病主死丧之象"],
    "type": "月煞",
    "locationMapper": {
      "寅": "巳",
      "卯": "寅",
      "辰": "亥",
      "巳": "申",
      "午": "巳",
      "未": "寅",
      "申": "亥",
      "酉": "申",
      "戌": "巳",
      "亥": "寅",
      "子": "亥",
      "丑": "申"
    },
    "locationDescriptionList": ["正月起巳，逆行四孟（巳、寅、亥、申），周而复始"]
  },
  {
    "name": "游祸",
    "jiXiong": "凶",
    "descriptionList": ["动有灾祸"],
    "type": "月煞",
    "locationMapper": {
      "寅": "巳",
      "卯": "寅",
      "辰": "亥",
      "巳": "申",
      "午": "巳",
      "未": "寅",
      "申": "亥",
      "酉": "申",
      "戌": "巳",
      "亥": "寅",
      "子": "亥",
      "丑": "申"
    },
    "locationDescriptionList": ["正月起巳，逆行四孟（巳、寅、亥、申），周而复始"]
  },
  {
    "name": "月德",
    "jiXiong": "吉",
    "descriptionList": ["主逢凶化吉"],
    "type": "月煞",
    "locationMapper": {
      "寅": "巳",
      "卯": "寅",
      "辰": "亥",
      "巳": "申",
      "午": "巳",
      "未": "寅",
      "申": "亥",
      "酉": "申",
      "戌": "巳",
      "亥": "寅",
      "子": "亥",
      "丑": "申"
    },
    "locationDescriptionList": ["正月起巳，逆行四孟（巳、寅、亥、申），周而复始"]
  },
  {
    "name": "墓门",
    "jiXiong": "凶",
    "descriptionList": ["亡神对冲，主坟墓事"],
    "type": "月煞",
    "locationMapper": {
      "寅": "亥",
      "卯": "申",
      "辰": "巳",
      "巳": "寅",
      "午": "亥",
      "未": "申",
      "申": "巳",
      "酉": "寅",
      "戌": "亥",
      "亥": "申",
      "子": "巳",
      "丑": "寅"
    },
    "locationDescriptionList": ["正月起亥，逆行四孟（亥、申、巳、寅），周而复始", "亡神对冲为为墓门"]
  },
  {
    "name": "女灾",
    "jiXiong": "凶",
    "descriptionList": ["主产胎危"],
    "type": "月煞",
    "locationMapper": {
      "寅": "亥",
      "卯": "申",
      "辰": "巳",
      "巳": "寅",
      "午": "亥",
      "未": "申",
      "申": "巳",
      "酉": "寅",
      "戌": "亥",
      "亥": "申",
      "子": "巳",
      "丑": "寅"
    },
    "locationDescriptionList": ["正月起亥，逆行四孟（亥、申、巳、寅），周而复始"]
  },
  {
    "name": "天狱",
    "jiXiong": "凶",
    "descriptionList": ["主讼忧"],
    "type": "月煞",
    "locationMapper": {
      "寅": "亥",
      "卯": "申",
      "辰": "巳",
      "巳": "寅",
      "午": "亥",
      "未": "申",
      "申": "巳",
      "酉": "寅",
      "戌": "亥",
      "亥": "申",
      "子": "巳",
      "丑": "寅"
    },
    "locationDescriptionList": ["正月起亥，逆行四孟（亥、申、巳、寅），周而复始"]
  },
  {
    "name": "雷煞",
    "jiXiong": "凶",
    "descriptionList": ["主雷，与雷公同"],
    "type": "月煞",
    "locationMapper": {
      "寅": "亥",
      "卯": "申",
      "辰": "巳",
      "巳": "寅",
      "午": "亥",
      "未": "申",
      "申": "巳",
      "酉": "寅",
      "戌": "亥",
      "亥": "申",
      "子": "巳",
      "丑": "寅"
    },
    "locationDescriptionList": ["正月起亥，逆行四孟（亥、申、巳、寅），周而复始"]
  },
  {
    "name": "悬索",
    "jiXiong": "凶",
    "descriptionList": ["占贼必自屋而下", "占病必有自缢鬼"],
    "type": "月煞",
    "locationMapper": {
      "寅": "卯",
      "卯": "子",
      "辰": "酉",
      "巳": "午",
      "午": "卯",
      "未": "子",
      "申": "酉",
      "酉": "午",
      "戌": "卯",
      "亥": "子",
      "子": "酉",
      "丑": "午"
    },
    "locationDescriptionList": ["正月起卯，逆行四仲（卯、子、酉、午），周而复始"]
  },
  {
    "name": "桃花",
    "jiXiong": "凶",
    "descriptionList": ["主口舌、淫乱，妇女不正"],
    "type": "月煞",
    "locationMapper": {
      "寅": "卯",
      "卯": "子",
      "辰": "酉",
      "巳": "午",
      "午": "卯",
      "未": "子",
      "申": "酉",
      "酉": "午",
      "戌": "卯",
      "亥": "子",
      "子": "酉",
      "丑": "午"
    },
    "locationDescriptionList": ["正月起卯，逆行四仲（卯、子、酉、午），周而复始"]
  },
  {
    "name": "咸池",
    "jiXiong": "凶",
    "descriptionList": ["主口舌、淫乱，妇女不正"],
    "type": "月煞",
    "locationMapper": {
      "寅": "卯",
      "卯": "子",
      "辰": "酉",
      "巳": "午",
      "午": "卯",
      "未": "子",
      "申": "酉",
      "酉": "午",
      "戌": "卯",
      "亥": "子",
      "子": "酉",
      "丑": "午"
    },
    "locationDescriptionList": ["正月起卯，逆行四仲（卯、子、酉、午），周而复始"]
  },
  {
    "name": "大时",
    "jiXiong": "凶",
    "descriptionList": ["忌出行", "兵捕必获"],
    "type": "月煞",
    "locationMapper": {
      "寅": "卯",
      "卯": "子",
      "辰": "酉",
      "巳": "午",
      "午": "卯",
      "未": "子",
      "申": "酉",
      "酉": "午",
      "戌": "卯",
      "亥": "子",
      "子": "酉",
      "丑": "午"
    },
    "locationDescriptionList": ["正月起卯，逆行四仲（卯、子、酉、午），周而复始"]
  },
  {
            "name": "天解神",
            "jiXiong": "吉",
            "descriptionList": ["有解除灾祸、化解不利的意象，可缓解命理中一些凶煞影响"],
            "type": "月煞",
            "locationMapper": {
                "寅": "卯",
                "卯": "寅",
                "辰": "丑",
                "巳": "子",
                "午": "亥",
                "未": "戌",
                "申": "酉",
                "酉": "申",
                "戌": "未",
                "亥": "午",
                "子": "巳",
                "丑": "辰"
            },
            "locationDescriptionList": ["按十二地支对应不同位置，象征其解厄作用的落点分布"]
        },

        {
            "name": "地解神",
            "jiXiong": "吉",
            "descriptionList": ["辅助化解诸如意外、琐事等带来的不利，在命理中为趋吉神煞",
                "从表格看不同地支对应重复等情况，体现其在特定方位的解厄属性"],
            "type": "月煞",
            "locationMapper": {
                "寅": "申",
                "卯": "申",
                "辰": "酉",
                "巳": "酉",
                "午": "戌",
                "未": "戌",
                "申": "亥",
                "酉": "亥",
                "戌": "午",
                "亥": "午",
                "子": "未",
                "丑": "未"
            },
            "locationDescriptionList": ["以十二地支为基础对应位置，反映地解神在不同方位的解厄影响"]
        },
{
    "name": "大煞1",
    "jiXiong": "凶",
    "descriptionList": ["象征较强的灾祸、凶险，易引发诸如意外、坎坷等严重不利情况"],
    "type": "月煞",
    "locationMapper": {
      "寅": "辰",
      "卯": "未",
      "辰": "辰",
      "巳": "丑",
      "午": "未",
      "未": "辰",
      "申": "丑",
      "酉": "未",
      "戌": "辰",
      "亥": "丑",
      "子": "未",
      "丑": "辰"
    },
    "locationDescriptionList": ["基于五行四库理论，对应辰、未、丑土库，以地支与四季土旺之库绑定为核心，体现空间固定凶性"]
  },
  {
    "name": "大煞2",
    "jiXiong": "凶",
    "descriptionList": ["主灾速"],
    "type": "月煞",
    "locationMapper": {
      "寅": "午",
      "卯": "卯",
      "辰": "子",
      "巳": "酉",
      "午": "午",
      "未": "卯",
      "申": "子",
      "酉": "酉",
      "戌": "午",
      "亥": "卯",
      "子": "子",
      "丑": "酉"
    },
    "locationDescriptionList": ["基于四仲逆行规则，正月起午，循午、卯、子、酉流转，结合月令与五行极盛理论，体现时间动态凶性"]
  },
  {
    "name": "长绳",
    "jiXiong": "凶",
    "descriptionList": ["见鬼主缢死事", "绳索俱主囚係"],
    "type": "月煞",
    "locationMapper": {
      "寅": "酉",
      "卯": "午",
      "辰": "卯",
      "巳": "子",
      "午": "酉",
      "未": "午",
      "申": "卯",
      "酉": "子",
      "戌": "酉",
      "亥": "午",
      "子": "卯",
      "丑": "子"
    },
    "locationDescriptionList": ["正月起酉，逆行四仲（酉、午、卯、子），周而复始"]
  },
  {
    "name": "天吏",
    "jiXiong": "吉",
    "descriptionList": ["主升迁、公讼事", "作日的官星，求官最喜"],
    "type": "月煞",
    "locationMapper": {
      "寅": "酉",
      "卯": "午",
      "辰": "卯",
      "巳": "子",
      "午": "酉",
      "未": "午",
      "申": "卯",
      "酉": "子",
      "戌": "酉",
      "亥": "午",
      "子": "卯",
      "丑": "子"
    },
    "locationDescriptionList": ["正月起酉，逆行四仲（酉、午、卯、子），周而复始"]
  },
  {
    "name": "天鬼",
    "jiXiong": "凶",
    "descriptionList": ["主兵亡、产死、祸患、疫气"],
    "type": "月煞",
    "locationMapper": {
      "寅": "酉",
      "卯": "午",
      "辰": "卯",
      "巳": "子",
      "午": "酉",
      "未": "午",
      "申": "卯",
      "酉": "子",
      "戌": "酉",
      "亥": "午",
      "子": "卯",
      "丑": "子"
    },
    "locationDescriptionList": ["正月起酉，逆行四仲（酉、午、卯、子），周而复始"]
  },
  {
    "name": "小煞",
    "jiXiong": "凶",
    "descriptionList": ["主小儿灾"],
    "type": "月煞",
    "locationMapper": {
      "寅": "丑",
      "卯": "戌",
      "辰": "未",
      "巳": "辰",
      "午": "丑",
      "未": "戌",
      "申": "未",
      "酉": "辰",
      "戌": "丑",
      "亥": "戌",
      "子": "未",
      "丑": "辰"
    },
    "locationDescriptionList": ["正月起丑，逆行四季（丑、戌、未、辰），周而复始"]
  },
  {
    "name": "天煞",
    "jiXiong": "凶",
    "descriptionList": ["主小儿灾", "又为岁煞、支煞"],
    "type": "月煞",
    "locationMapper": {
      "寅": "丑",
      "卯": "戌",
      "辰": "未",
      "巳": "辰",
      "午": "丑",
      "未": "戌",
      "申": "未",
      "酉": "辰",
      "戌": "丑",
      "亥": "戌",
      "子": "未",
      "丑": "辰"
    },
    "locationDescriptionList": ["正月起丑，逆行四季（丑、戌、未、辰），周而复始"]
  },
  {
    "name": "五盗",
    "jiXiong": "凶",
    "descriptionList": ["主小儿灾"],
    "type": "月煞",
    "locationMapper": {
      "寅": "丑",
      "卯": "戌",
      "辰": "未",
      "巳": "辰",
      "午": "丑",
      "未": "戌",
      "申": "未",
      "酉": "辰",
      "戌": "丑",
      "亥": "戌",
      "子": "未",
      "丑": "辰"
    },
    "locationDescriptionList": ["正月起丑，逆行四季（丑、戌、未、辰），周而复始"]
  },
  {
    "name": "华盖",
    "jiXiong": "凶",
    "descriptionList": ["覆日人昏晦", "又为黄幡、迷魂幡"],
    "type": "月煞",
    "locationMapper": {
      "寅": "戌",
      "卯": "未",
      "辰": "辰",
      "巳": "丑",
      "午": "戌",
      "未": "未",
      "申": "辰",
      "酉": "丑",
      "戌": "戌",
      "亥": "未",
      "子": "辰",
      "丑": "丑"
    },
    "locationDescriptionList": ["正月起戌，逆行四季（戌、未、辰、丑），周而复始", "常居三合局中的墓辰之位"]
  },
  {
    "name": "光怪",
    "jiXiong": "凶",
    "descriptionList": ["主火光鬼怪"],
    "type": "月煞",
    "otherNameList":["光影","火怪"],
    "locationMapper": {
      "寅": "戌",
      "卯": "未",
      "辰": "辰",
      "巳": "丑",
      "午": "戌",
      "未": "未",
      "申": "辰",
      "酉": "丑",
      "戌": "戌",
      "亥": "未",
      "子": "辰",
      "丑": "丑"
    },
    "locationDescriptionList": ["正月起戌，逆行四季（戌、未、辰、丑），周而复始"]
  },
  {
    "name": "丧魄",
    "jiXiong": "凶",
    "descriptionList": ["与飞魂同论，主神魂不定，夜多凶梦，鬼祟相侵", "并金神血支血忌加临年命刑克日干者，主刀下凶灾"],
    "type": "月煞",
    "locationMapper": {
      "寅": "未",
      "卯": "辰",
      "辰": "丑",
      "巳": "戌",
      "午": "未",
      "未": "辰",
      "申": "丑",
      "酉": "戌",
      "戌": "未",
      "亥": "辰",
      "子": "丑",
      "丑": "戌"
    },
    "locationDescriptionList": ["正月起未，逆行四季（未、辰、丑、戌），周而复始"]
  },
    {
    "name": "怪煞",
    "jiXiong": "凶",
    "descriptionList": ["有凶事"],
    "type": "月煞",
    "locationMapper": {
      "寅": "卯",
      "卯": "巳",
      "辰": "未",
      "巳": "酉",
      "午": "亥",
      "未": "丑",
      "申": "卯",
      "酉": "巳",
      "戌": "未",
      "亥": "酉",
      "子": "亥",
      "丑": "丑"
    },
    "locationDescriptionList": ["正月起寅，（卯、巳、未、酉、亥、丑），周而复始"]
  },
  {
    "name": "天刑",
    "jiXiong": "凶",
    "descriptionList": ["忧囚係"],
    "type": "月煞",
    "locationMapper": {
      "寅": "寅",
      "卯": "辰",
      "辰": "午",
      "巳": "申",
      "午": "戌",
      "未": "子",
      "申": "寅",
      "酉": "辰",
      "戌": "午",
      "亥": "申",
      "子": "戌",
      "丑": "子"
    },
    "locationDescriptionList": ["正月起寅，顺行六阳辰（寅、辰、午、申、戌、子），周而复始"]
  },
  {
    "name": "天财",
    "jiXiong": "吉",
    "descriptionList": ["主财喜"],
    "type": "月煞",
    "locationMapper": {
      "寅": "辰",
      "卯": "午",
      "辰": "申",
      "巳": "戌",
      "午": "子",
      "未": "寅",
      "申": "辰",
      "酉": "午",
      "戌": "申",
      "亥": "戌",
      "子": "子",
      "丑": "寅"
    },
    "locationDescriptionList": ["正月起辰，顺行六阳辰（辰、午、申、戌、子、寅），周而复始"]
  },
  {
    "name": "天马",
    "jiXiong": "吉",
    "descriptionList": ["主迁动诏命出行之事","官升迁，行人至。凡占主速加大煞尤速。捕亡难获。"],
    "type": "月煞",
    "locationMapper": {
      "寅": "午",
      "卯": "申",
      "辰": "戌",
      "巳": "子",
      "午": "寅",
      "未": "辰",
      "申": "午",
      "酉": "申",
      "戌": "戌",
      "亥": "子",
      "子": "寅",
      "丑": "辰"
    },
    "locationDescriptionList": ["正月起午，顺行六阳辰（午、申、戌、子、寅、辰），周而复始"]
  },
  {
    "name": "皇恩",
    "jiXiong": "吉",
    "otherNameList":["天恩"],
    "descriptionList": ["主皇恩庇护","官占有诏命迁转、恩泽升迁之吉"],
    "type": "月煞",
    "locationMapper": {
      "寅": "未",
      "卯": "酉",
      "辰": "亥",
      "巳": "丑",
      "午": "卯",
      "未": "巳",
      "申": "未",
      "酉": "酉",
      "戌": "亥",
      "亥": "丑",
      "子": "卯",
      "丑": "巳"
    },
    "locationDescriptionList": ["正月起未，顺行六阴辰（未、酉、亥、丑、卯、巳），周而复始"]
  },
    {
    "name": "皇恩大赦",
    "jiXiong": "吉",
    "descriptionList": ["主皇恩庇护","官占有诏命迁转、恩泽升迁之吉"],
    "type": "月煞",
    "locationMapper": {
      "寅": "戌",
      "卯": "丑",
      "辰": "辰",
      "巳": "未",
      "午": "卯",
      "未": "酉",
      "申": "子",
      "酉": "午",
      "戌": "亥",
      "亥": "寅",
      "子": "巳",
      "丑": "申"
    },
    "locationDescriptionList": [""]
  },
  {
    "name": "天贼1",
    "jiXiong": "凶",
    "descriptionList": ["主贼盗"],
    "type": "月煞",
    "locationMapper": {
      "寅": "辰",
      "卯": "寅",
      "辰": "子",
      "巳": "戌",
      "午": "申",
      "未": "午",
      "申": "酉",
      "酉": "未",
      "戌": "巳",
      "亥": "卯",
      "子": "丑",
      "丑": "亥"
    },
    "locationDescriptionList": ["阳月起辰，逆行六阳辰（辰、寅、子、戌、申、午）", "阴月起酉，逆行六阴辰（酉、未、巳、卯、丑、亥）"]
  },
  {
    "name": "血忌",
    "jiXiong": "凶",
    "descriptionList": ["血忌主血灾，难产。血支同断。女灾，羊刃均注产胎危。又浴盆见水，主产吉；浴盆占病见水，主病危。","《说约》：血支主阳人血光，阴人堕胎。血忌同断。"],
    "type": "月煞",
    "locationMapper": {
      "寅": "丑",
      "卯": "未",
      "辰": "寅",
      "巳": "申",
      "午": "卯",
      "未": "酉",
      "申": "辰",
      "酉": "戌",
      "戌": "巳",
      "亥": "亥",
      "子": "午",
      "丑": "子"
    },
    "locationDescriptionList": ["阳月起丑，顺行六辰（丑、寅、卯、辰、巳、午）", "阴月起未，顺行六辰（未、申、酉、戌、亥、子）"]
  },
  {
    "name": "圣心",
    "jiXiong": "吉",
    "descriptionList": ["代表恩泽，庶人利动宦迁除","占章奏喜生合日干，克冲破害不吉。"],
    "type": "月煞",
    "locationMapper": {
      "寅": "亥",
      "卯": "巳",
      "辰": "子",
      "巳": "午",
      "午": "丑",
      "未": "未",
      "申": "寅",
      "酉": "申",
      "戌": "卯",
      "亥": "酉",
      "子": "辰",
      "丑": "戌"
    },
    "locationDescriptionList": ["阳月起亥，顺行六辰（亥、子、丑、寅、卯、辰）", "阴月起巳，顺行六辰（巳、午、未、申、酉、戌）"]
  },
  {
    "name": "玉宇",
    "jiXiong": "吉",
    "descriptionList": ["有贵"],
    "type": "月煞",
    "locationMapper": {
      "寅": "卯",
      "卯": "酉",
      "辰": "辰",
      "巳": "戌",
      "午": "巳",
      "未": "亥",
      "申": "午",
      "酉": "子",
      "戌": "未",
      "亥": "丑",
      "子": "申",
      "丑": "寅"
    },
    "locationDescriptionList": ["「玉宇卯正依例取」"]
  },
  {
    "name": "金堂",
    "jiXiong": "吉",
    "descriptionList": ["月德，主有贵"],
    "type": "月煞",
    "locationMapper": {
      "寅": "辰",
      "卯": "戌",
      "辰": "巳",
      "巳": "亥",
      "午": "午",
      "未": "子",
      "申": "未",
      "酉": "丑",
      "戌": "申",
      "亥": "寅",
      "子": "酉",
      "丑": "卯"
    },
    "locationDescriptionList": ["「金堂辰上亦正逢」"]
  },
    {
    "name": "受死",
    "jiXiong": "大凶",
    "descriptionList": ["一切大凶"],
    "type": "月煞",
    "locationMapper": {
      "寅": "戌",
      "卯": "辰",
      "辰": "亥",
      "巳": "巳",
      "午": "子",
      "未": "午",
      "申": "丑",
      "酉": "未",
      "戌": "寅",
      "亥": "申",
      "子": "卯",
      "丑": "酉"
    },
    "locationDescriptionList": ["「受死戌正行门忌」"]
  },
  {
    "name": "午正",
    "jiXiong": "凶",
    "descriptionList": ["罪至讼招凶"],
    "type": "月煞",
    "locationMapper": {
      "寅": "午",
      "卯": "子",
      "辰": "未",
      "巳": "丑",
      "午": "申",
      "未": "寅",
      "申": "酉",
      "酉": "卯",
      "戌": "戌",
      "亥": "辰",
      "子": "亥",
      "丑": "死"
    },
    "locationDescriptionList": ["「午子为丑申寅酉卯戌辰亥巳，午正罪至讼招凶。」"]
  },
  {
    "name": "解神",
    "jiXiong": "吉",
    "descriptionList": ["乃化煞之神，可转凶为吉", "又为天解"],
    "type": "月煞",
    "locationMapper": {
      "寅": "申",
      "卯": "申",
      "辰": "戌",
      "巳": "戌",
      "午": "子",
      "未": "子",
      "申": "寅",
      "酉": "寅",
      "戌": "辰",
      "亥": "辰",
      "子": "午",
      "丑": "午"
    },
    "locationDescriptionList": ["两月一辰，正月、二月起申，顺行六阳辰"]
  },
  {
    "name": "天德",
    "jiXiong": "吉",
    "descriptionList": ["德神能逢凶化吉"],
    "type": "月煞",
    "locationMapper": {
      "寅": "未",
      "卯": "申",
      "辰": "亥",
      "巳": "戌",
      "午": "亥",
      "未": "寅",
      "申": "丑",
      "酉": "寅",
      "戌": "巳",
      "亥": "辰",
      "子": "巳",
      "丑": "申"
    },
    "locationDescriptionList": ["正月丁（未），二月坤（申），三月壬（亥），四月辛（戌），五月乾（亥），六月甲（寅），七月癸（丑），八月艮（寅），九月丙（巳），十月乙（辰），十一巽（巳），十二庚（申）", "《考原》云：天德者，三合之气也。"]
  },
  {
    "name": "往亡",
    "jiXiong": "凶",
    "descriptionList": ["忌出行"],
    "type": "月煞",
    "locationMapper": {
      "寅": "寅",
      "卯": "巳",
      "辰": "申",
      "巳": "亥",
      "午": "卯",
      "未": "午",
      "申": "酉",
      "酉": "子",
      "戌": "辰",
      "亥": "未",
      "子": "戌",
      "丑": "丑"
    },
    "locationDescriptionList": ["正月起寅，顺行四孟", "五月起卯，顺行四仲", "九月起辰，顺行四季"]
  },
  {
    "name": "飞廉",
    "jiXiong": "凶",
    "descriptionList": ["主速", "行人必动", "课传凶则有灾"],
    "type": "月煞",
    "locationMapper": {
      "寅": "戌",
      "卯": "巳",
      "辰": "午",
      "巳": "未",
      "午": "申",
      "未": "酉",
      "申": "辰",
      "酉": "亥",
      "戌": "子",
      "亥": "丑",
      "子": "寅",
      "丑": "卯"
    },
    "locationDescriptionList": ["正戌、二巳、三午、四未、五申、六酉、七辰、八亥、九子、十丑、冬寅、腊卯", "又为：戌、巳、午、未、寅、卯、辰、亥、子、丑、申、酉"]
  },
  {
    "name": "五鬼",
    "jiXiong": "凶",
    "descriptionList": ["出行忌，主遇灾祸"],
    "type": "月煞",
    "locationMapper": {
      "寅": "午",
      "卯": "辰",
      "辰": "寅",
      "巳": "酉",
      "午": "卯",
      "未": "申",
      "申": "丑",
      "酉": "巳",
      "戌": "子",
      "亥": "亥",
      "子": "未",
      "丑": "戌"
    },
    "locationDescriptionList": ["五鬼之星忌出行，午辰寅共酉卯牢，丑巳子亥未戌寻",
    "正午、二辰、三寅、四卯、五酉、六申、七丑、八巳、九子、十亥、冬未、腊戌"]
  },
    {
    "name": "相负",
    "jiXiong": "凶",
    "descriptionList": ["主被人负及有冤，被人辜负"],
    "type": "月煞",
    "locationMapper": {
      "寅": "亥",
      "卯": "亥",
      "辰": "丑",
      "巳": "丑",
      "午": "卯",
      "未": "卯",
      "申": "巳",
      "酉": "巳",
      "戌": "未",
      "亥": "未",
      "子": "酉",
      "丑": "酉"
    },
    "locationDescriptionList": ["正二登明三四丑、依例顺阴人相负，冤枉屈情冲有位"]
  },
      {
    "name": "枉屈",
    "jiXiong": "凶",
    "descriptionList": ["主有冤屈"],
    "type": "月煞",
    "locationMapper": {
      "寅": "巳",
      "卯": "巳",
      "辰": "未",
      "巳": "未",
      "午": "酉",
      "未": "酉",
      "申": "亥",
      "酉": "亥",
      "戌": "丑",
      "亥": "丑",
      "子": "卯",
      "丑": "卯"
    },
    "locationDescriptionList": ["正二登明三四丑、依例顺阴人相负，冤“枉屈”情冲有位"]
  },
  {
    "name": "瓦煞",
    "jiXiong": "凶",
    "descriptionList": ["此阳日之瓦煞，阴日干冲位取之。"],
    "type": "月煞",
    "locationMapper": {
      "寅": "巳",
      "卯": "子",
      "辰": "丑",
      "巳": "寅",
      "午": "卯",
      "未": "辰",
      "申": "亥",
      "酉": "午",
      "戌": "未",
      "亥": "申",
      "子": "酉",
      "丑": "戌"
    },
    "locationDescriptionList": ["阳日瓦煞阴冲出，正巳子丑寅卯辰，七亥午未申酉戌"]
  },
    {
    "name": "瓦煞",
    "jiXiong": "凶",
    "descriptionList": ["此阳日之瓦煞，阴日干冲位取之。"],
    "type": "月煞",
    "locationMapper": {
      "寅": "巳",
      "卯": "子",
      "辰": "丑",
      "巳": "寅",
      "午": "卯",
      "未": "辰",
      "申": "亥",
      "酉": "午",
      "戌": "未",
      "亥": "申",
      "子": "酉",
      "丑": "戌"
    },
    "locationDescriptionList": ["阳日瓦煞阴冲出，正巳子丑寅卯辰，七亥午未申酉戌"]
  },
      {
    "name": "门煞",
    "jiXiong": "凶",
    "descriptionList": ["主门户事"],
    "type": "月煞",
    "locationMapper": {
      "寅": "戌",
      "卯": "酉",
      "辰": "辰",
      "巳": "卯",
      "午": "戌",
      "未": "酉",
      "申": "卯",
      "酉": "午",
      "戌": "戌",
      "亥": "酉",
      "子": "辰",
      "丑": "卯"
    },
    "locationDescriptionList": ["「正五九兮三合轮，戌酉辰卯『煞曰门』，辰戌丑未梦神论」"]
  },
  {
    "name": "梦神",
    "jiXiong": "凶",
    "descriptionList": ["主梦事"],
    "type": "月煞",
    "locationMapper": {
      "寅": "辰",
      "卯": "戌",
      "辰": "丑",
      "巳": "未",
      "午": "辰",
      "未": "戌",
      "申": "丑",
      "酉": "未",
      "戌": "辰",
      "亥": "戌",
      "子": "丑",
      "丑": "为"
    },
    "locationDescriptionList": ["「正五九兮三合轮，戌酉辰卯『煞曰门』，辰戌丑未『梦神』论」"]
  },
  {
    "name": "会神",
    "jiXiong": "吉",
    "descriptionList": ["占行人、占逃亡，主行人得会、逃亡可捕","婚姻成，行人至"],
    "type": "月煞",
    "locationMapper": {
      "寅": "未",
      "卯": "戌",
      "辰": "寅",
      "巳": "亥",
      "午": "酉",
      "未": "子",
      "申": "丑",
      "酉": "午",
      "戌": "巳",
      "亥": "卯",
      "子": "申",
      "丑": "辰"
    },
    "locationDescriptionList": ["正未、二戌、三寅、四亥、五酉、六子、七丑、八午、九巳、十卯、冬申、腊辰"]
  },
  {
    "name": "金神",
    "jiXiong": "凶",
    "otherNameList":["破碎","红沙","暗金"],
    "descriptionList": [
      "又为支煞，主物破、财损、血光、刀刃之伤等，占病病重",
      "堪舆，破碎乘其地欠缺和杂乱，如乘青龙左砂破碎，乘朱雀案山不完整；天空主孤寡，故破碎乘之子孙败绝。"
    ],
    "type": "月煞",
    "locationMapper": {
      "子": "巳",
      "午": "巳",
      "卯": "巳",
      "酉": "巳",
      "寅": "酉",
      "申": "酉",
      "巳": "酉",
      "亥": "酉",
      "辰": "丑",
      "戌": "丑",
      "丑": "丑",
      "未": "丑"
    },
    "locationDescriptionList": [
      "子午卯酉四仲月在巳",
      "寅申巳亥四孟月在酉",
      "辰戌丑未四季月在丑",
      "巳酉丑三合金局"
    ]
  },
    {
    "name": "白衣",
    "jiXiong": "凶",
    "descriptionList": [
      "即加子孙六亲上"
    ],
    "type": "月煞",
    "locationMapper": {
      "子": "辰",
      "午": "辰",
      "卯": "辰",
      "酉": "辰",
      "寅": "未",
      "申": "未",
      "巳": "未",
      "亥": "未",
      "辰": "丑",
      "戌": "丑",
      "丑": "丑",
      "未": "丑"
    },
    "locationDescriptionList": [
      "子午卯酉四仲月在辰",
      "寅申巳亥四孟月在未",
      "辰戌丑未四季月在丑"
    ]
  },
  {
    "name": "章光",
    "jiXiong": "凶",

    "otherNameList":["归忌"],
    "descriptionList": [
      "又为归忌，忌出行",
      "孟月乙丑、仲月丙寅、季月甲子",
      "亦为孟月丑、仲月寅、季月子"
    ],
    "type": "月煞",
    "locationMapper": {
      "寅": "丑",
      "卯": "寅",
      "辰": "子",
      "巳": "丑",
      "午": "寅",
      "未": "子",
      "申": "丑",
      "酉": "寅",
      "戌": "子",
      "亥": "丑",
      "子": "寅",
      "丑": "子"
    },
    "locationDescriptionList": [
      "孟月（寅、巳、申、亥）在丑",
      "仲月（卯、午、酉、子）在寅",
      "季月（辰、未、戌、丑）在子"
    ]
  },
    {
    "name": "信神",
    "jiXiong": "吉",
    "descriptionList": ["主信用、文书，象征消息可靠、承诺兑现"],
    "type": "月煞",
    "locationMapper": {
      "子": "申",
      "丑": "酉",
      "寅": "戌",
      "卯": "亥",
      "辰": "子",
      "巳": "丑",
      "午": "寅",
      "未": "卯",
      "申": "辰",
      "酉": "巳",
      "戌": "午",
      "亥": "未"
    },
    "locationDescriptionList": ["子日在申，丑日在酉，顺行三位为信神，主消息灵通"]
  },

    {
    "name": "火烛",
    "jiXiong": "凶",
    "descriptionList": ["主火灾、烛照，象征火光引发的吉凶，忌火灾隐患","乘蛇雀克干身灾，克支焚宅"],
    "type": "月煞",
    "locationMapper": {
      "寅": "巳",
      "卯": "午",
      "辰": "未",
      "巳": "申",
      "午": "酉",
      "未": "戌",
      "申": "亥",
      "酉": "子",
      "戌": "丑",
      "亥": "寅",
      "子": "卯",
      "丑": "辰"
    },
    "locationDescriptionList": [""]
  },

     {
    "name": "活天赦",
    "jiXiong": "吉",
    "descriptionList": ["生合日干，主赦罪"],
    "type": "月煞",
    "locationMapper": {
      "寅": "未",
      "卯": "戌",
      "辰": "丑",
      "巳": "辰",
      "午": "未",
      "未": "戌",
      "申": "丑",
      "酉": "辰",
      "戌": "未",
      "亥": "戌",
      "子": "丑",
      "丑": "辰"
    },
    "locationDescriptionList": [""]
  },
  {
            "name": "月刑",
            "jiXiong": "凶",
            "descriptionList": ["命理中代表刑罚、是非等不利影响","占病讼忌"],
            "type": "月煞",
            "locationMapper": {
                "寅": "巳",
                "卯": "子",
                "辰": "辰",
                "巳": "申",
                "午": "午",
                "未": "丑",
                "申": "寅",
                "酉": "酉",
                "戌": "未",
                "亥": "亥",
                "子": "卯",
                "丑": "戌"
            },
            "locationDescriptionList": ["依十二地支对应查找，不同地支对应不同位置体现影响"]
        },
        {
            "name": "天鼠",
            "jiXiong": "凶",
            "descriptionList": ["命理里常关联一些隐晦、不安类的意象"],
            "type": "月煞",
            "locationMapper": {
                "寅": "卯",
                "卯": "辰",
                "辰": "巳",
                "巳": "午",
                "午": "未",
                "未": "申",
                "申": "酉",
                "酉": "戌",
                "戌": "亥",
                "亥": "子",
                "子": "丑",
                "丑": "寅"
            },
            "locationDescriptionList": ["按十二地支顺序对应不同位置，象征其影响分布"]
        },
        {
            "name": "迷惑",
            "jiXiong": "凶",
            "descriptionList": ["命理中寓意使人思想迷惑、行事失准的神煞"],
            "type": "月煞",
            "locationMapper": {
                "寅": "辰",
                "卯": "未",
                "辰": "丑",
                "巳": "戌",
                "午": "辰",
                "未": "未",
                "申": "丑",
                "酉": "戌",
                "戌": "辰",
                "亥": "未",
                "子": "丑",
                "丑": "辰"
            },
            "locationDescriptionList": ["以十二地支为基础对应位置，体现迷惑影响的落点"]
        },
        {
            "name": "丧车",
            "jiXiong": "凶",
            "descriptionList": ["传统命理中与丧事、出行不吉等相关的神煞"],
            "type": "月煞",
            "locationMapper": {
                "寅": "辰",
                "卯": "丑",
                "辰": "戌",
                "巳": "未",
                "午": "辰",
                "未": "丑",
                "申": "戌",
                "酉": "未",
                "戌": "辰",
                "亥": "丑",
                "子": "戌",
                "丑": "未"
            },
            "locationDescriptionList": ["依据十二地支对应，显示丧车影响相关位置指向"]
        },
                {
            "name": "丧魂",
            "jiXiong": "凶",
            "descriptionList": [],
            "type": "月煞",
            "locationMapper": {
                "寅": "未",
                "卯": "辰",
                "辰": "丑",
                "巳": "戌",
                "午": "未",
                "未": "辰",
                "申": "丑",
                "酉": "戌",
                "戌": "未",
                "亥": "辰",
                "子": "丑",
                "丑": "戌"
            },
            "locationDescriptionList": []
        },
        {
            "name": "邪神",
            "jiXiong": "凶",
            "descriptionList": [],
            "type": "月煞",
            "locationMapper": {
                "寅": "未",
                "卯": "午",
                "辰": "巳",
                "巳": "辰",
                "午": "卯",
                "未": "寅",
                "申": "丑",
                "酉": "子",
                "戌": "辰",
                "亥": "巳",
                "子": "酉",
                "丑": "申"
            },
            "locationDescriptionList": ["正月起未逆行十二支"]
        },
        {
            "name": "枯骨",
            "jiXiong": "凶",
            "descriptionList": ["命理里代表陈旧、衰败、不吉气场的神煞"],
            "type": "月煞",
            "locationMapper": {
                "寅": "卯",
                "卯": "辰",
                "辰": "巳",
                "巳": "午",
                "午": "未",
                "未": "申",
                "申": "酉",
                "酉": "戌",
                "戌": "亥",
                "亥": "子",
                "子": "丑",
                "丑": "寅"
            },
            "locationDescriptionList": ["通过十二地支对应位置，展现枯骨神煞的影响方位"]
        },
        {
            "name": "产煞",
            "jiXiong": "凶",
            "descriptionList": ["命理中与生育、生产过程可能遇阻碍等相关的神煞"],
            "type": "月煞",
            "locationMapper": {
                "寅": "寅",
                "卯": "巳",
                "辰": "申",
                "巳": "亥",
                "午": "寅",
                "未": "巳",
                "申": "申",
                "酉": "亥",
                "戌": "寅",
                "亥": "巳",
                "子": "申",
                "丑": "亥"
            },
            "locationDescriptionList": ["以十二地支循环对应，明确产煞影响的位置关联"]
        }
]');
INSERT INTO shen_sha_document ("file_name", "payload_json") VALUES ('6_shensha_month_gan.json', '[
            {
            "name": "产煞",
            "jiXiong": "凶",
            "descriptionList": ["命理中与生育、生产过程可能遇阻碍等相关的神煞"],
            "type": "月干",
            "locationMapper": {
                "寅": "寅",
                "卯": "巳",
                "辰": "申",
                "巳": "亥",
                "午": "寅",
                "未": "巳",
                "申": "申",
                "酉": "亥",
                "戌": "寅",
                "亥": "巳",
                "子": "申",
                "丑": "亥"
            },
            "locationDescriptionList": ["以十二地支循环对应，明确产煞影响的位置关联"]
        }
]');
INSERT INTO shen_sha_document ("file_name", "payload_json") VALUES ('6_shensha_month_zhi_gan.json', '[
    {
    "name": "道神",
    "jiXiong": "平",
    "descriptionList": ["亡神对冲，主坟墓事"],
    "type": "月煞",
    "locationMapper": {
      "寅": "庚",
      "卯": "辛",
      "辰": "甲",
      "巳": "癸",
      "午": "壬",
      "未": "乙",
      "申": "丙",
      "酉": "丁",
      "戌": "戊",
      "亥": "己",
      "子": "庚",
      "丑": "辛"
    },
    "locationDescriptionList": []
  },
      {
    "name": "月徳合",
    "jiXiong": "平",
    "descriptionList": ["亡神对冲，主坟墓事"],
    "type": "月煞",
    "locationMapper": {
      "寅": "辛",
      "卯": "己",
      "辰": "丁",
      "巳": "乙",
      "午": "辛",
      "未": "己",
      "申": "丁",
      "酉": "乙",
      "戌": "辛",
      "亥": "己",
      "子": "丁",
      "丑": "乙"
    },
    "locationDescriptionList": ["寅午戌辛，亥卯未己，申子辰丁，巳酉丑乙"]
  }
]');
INSERT INTO shen_sha_document ("file_name", "payload_json") VALUES ('6_shensha_xun.json', '[
  {
    "name": "旬奇",
    "jiXiong": "吉",
    "descriptionList": [
      "奇主奇逢，逢凶化吉"
    ],
    "type": "旬煞",
    "locationMapper": {
      "甲子": "亥",
      "甲戌": "亥",
      "甲申": "子",
      "甲午": "子",
      "甲辰": "丑",
      "甲寅": "丑"
    },
    "locationDescriptionList": [
      "甲子甲戌旬奇在亥，甲申甲午旬奇在子，甲辰甲寅旬奇在丑"
    ]
  },
  {
    "name": "奇神",
    "jiXiong": "吉",
    "descriptionList": [
      "奇主奇逢，逢凶化吉"
    ],
    "type": "旬煞",
    "locationMapper": {
      "甲子": "丑",
      "甲戌": "丑",
      "甲申": "子",
      "甲午": "子",
      "甲辰": "亥",
      "甲寅": "亥"
    },
    "locationDescriptionList": [
      "甲子甲戌旬奇在丑，甲申甲午旬奇在子，甲辰甲寅旬奇在亥"
    ]
  },
  {
    "name": "三奇",
    "jiXiong": "吉",
    "descriptionList": [
      "奇主奇逢，逢凶化吉"
    ],
    "type": "旬煞",
    "locationMapper": {
      "甲子": "丑",
      "甲戌": "丑",
      "甲申": "子",
      "甲午": "子",
      "甲辰": "亥",
      "甲寅": "亥"
    },
    "locationDescriptionList": [
      "甲子甲戌旬奇在丑，甲申甲午旬奇在子，甲辰甲寅旬奇在亥"
    ]
  },
  {
    "name": "旬仪",
    "jiXiong": "吉",
    "descriptionList": [
      "凡事吉庆，有礼仪之尊，首领之意"
    ],
    "type": "旬煞",
    "locationMapper": {
      "甲子": "子",
      "甲戌": "戌",
      "甲申": "申",
      "甲午": "午",
      "甲辰": "辰",
      "甲寅": "寅"
    },
    "locationDescriptionList": [
      "每旬之中六甲之辰"
    ],
    "otherNameList": ["仪神", "旬首", "旬甲"]
  },
  {
    "name": "旬乙",
    "jiXiong": "凶",
    "descriptionList": [
      "主盗贼事"
    ],
    "type": "旬煞",
    "locationMapper": {
      "甲子": "丑",
      "甲戌": "亥",
      "甲申": "酉",
      "甲午": "未",
      "甲辰": "巳",
      "甲寅": "卯"
    },
    "locationDescriptionList": [
      "每旬之中六乙之辰"
    ],
    "otherNameList": ["旬盗", "盗神"]
  },
  {
    "name": "旬丁",
    "jiXiong": "凶",
    "descriptionList": [
      "丁马主摇动不安、出行之事",
      "亦为妖神，专主不祥、怪异、忧惊",
      "长生禄神乘丁，皆主生意。禄神不安，恐难持久作福",
      "本命逢丁马，心惊不安，坐地盘长生之上，可作避难逃生论",
      "丁马要看日干，壬癸日逢之多主财动婚动，庚辛逢丁多主凶动",
      "六庚日巳加申，六辛日午加辛皆丁神临宅，人宅俱动俱灾"
    ],
    "type": "旬煞",
    "locationMapper": {
      "甲子": "卯",
      "甲戌": "丑",
      "甲申": "亥",
      "甲午": "酉",
      "甲辰": "未",
      "甲寅": "巳"
    },
    "locationDescriptionList": [
      "每旬之中六丁之辰"
    ],
    "otherNameList": ["六丁", "丁马", "丁神"]
  },
  {
    "name": "旬庚",
    "jiXiong": "凶",
    "descriptionList": [
      "为响动，官病忌"
    ],
    "type": "旬煞",
    "locationMapper": {
      "甲子": "申",
      "甲戌": "午",
      "甲申": "辰",
      "甲午": "寅",
      "甲辰": "子",
      "甲寅": "戌"
    },
    "locationDescriptionList": [
      "每旬之中六庚之辰"
    ],
    "otherNameList": ["旬响", "响神"]
  },
  {
    "name": "旬辛",
    "jiXiong": "凶",
    "descriptionList": [
      "主死亡、骨骸",
      "《指南》云''旬辛便是五亡煞''",
      "出逢盗贼，若并空亡玄，主走失"
    ],
    "type": "旬煞",
    "locationMapper": {
      "甲子": "酉",
      "甲戌": "未",
      "甲申": "巳",
      "甲午": "卯",
      "甲辰": "丑",
      "甲寅": "亥"
    },
    "locationDescriptionList": [
      "每旬之中六辛之辰"
    ],
    "otherNameList": ["旬亡", "五亡", "亡神"]
  },
  {
    "name": "旬癸",
    "jiXiong": "凶",
    "descriptionList": [
      "闭口主人不言、病不食，机关莫测",
      "禄神闭口，难依俸禄；财爻闭口，难求其财；长生闭口，生意已尽；鬼爻闭口，凡事忍让，闭口不言，则祸可渐散矣"
    ],
    "type": "旬煞",
    "locationMapper": {
      "甲子": "亥",
      "甲戌": "酉",
      "甲申": "未",
      "甲午": "巳",
      "甲辰": "卯",
      "甲寅": "丑"
    },
    "locationDescriptionList": [
      "每旬之中六癸之辰"
    ],
    "otherNameList": ["旬尾"]
  }
]');
INSERT INTO shen_sha_document ("file_name", "payload_json") VALUES ('6_shensha_year.json', '[
    {
        "name": "太岁",
        "jiXiong": "吉",
        "descriptionList": ["天子，元首，主一年吉凶"],
        "type": "年煞",
        "locationMapper": {
            "寅": "寅",
            "卯": "卯",
            "辰": "辰",
            "巳": "巳",
            "午": "午",
            "未": "未",
            "申": "申",
            "酉": "酉",
            "戌": "戌",
            "亥": "亥",
            "子": "子",
            "丑": "丑"
        },
        "locationDescriptionList": ["年支本身"]
    },
    {
        "name": "岁破",
        "jiXiong": "凶",
        "descriptionList": ["主破耗财物，岁破作鬼主讼"],
        "type": "年煞",
        "locationMapper": {
            "寅": "申",
            "卯": "酉",
            "辰": "戌",
            "巳": "亥",
            "午": "子",
            "未": "丑",
            "申": "寅",
            "酉": "卯",
            "戌": "辰",
            "亥": "巳",
            "子": "午",
            "丑": "未"
        },
        "locationDescriptionList": ["太岁对冲之支"]
    },
    {
        "name": "病符",
        "jiXiong": "凶",
        "descriptionList": ["代表病气，陈年旧事"],
        "type": "年煞",
        "locationMapper": {
            "寅": "丑",
            "卯": "寅",
            "辰": "卯",
            "巳": "辰",
            "午": "巳",
            "未": "午",
            "申": "未",
            "酉": "申",
            "戌": "酉",
            "亥": "戌",
            "子": "亥",
            "丑": "子"
        },
        "locationDescriptionList": ["旧太岁（去年太岁）"]
    },
    {
        "name": "丧门",
        "jiXiong": "凶",
        "descriptionList": ["主丧事，披麻带孝","丧吊俱到克干克支者，方以丧服论，否则不作丧吊看。"],
        "type": "年煞",
        "locationMapper": {
            "寅": "辰",
            "卯": "巳",
            "辰": "午",
            "巳": "未",
            "午": "申",
            "未": "酉",
            "申": "戌",
            "酉": "亥",
            "戌": "子",
            "亥": "丑",
            "子": "寅",
            "丑": "卯"
        },
        "locationDescriptionList": ["岁前二辰（年支前两位）"]
    },
    {
        "name": "吊客",
        "jiXiong": "凶",
        "descriptionList": ["与丧门同主丧事"],
        "type": "年煞",
        "locationMapper": {
            "寅": "子",
            "卯": "丑",
            "辰": "寅",
            "巳": "卯",
            "午": "辰",
            "未": "巳",
            "申": "午",
            "酉": "未",
            "戌": "申",
            "亥": "酉",
            "子": "戌",
            "丑": "亥"
        },
        "locationDescriptionList": ["岁后二辰（年支后两位）"]
    },
    {
        "name": "官符",
        "jiXiong": "凶",
        "descriptionList": ["主官司词讼之事"],
        "type": "年煞",
        "locationMapper": {
            "寅": "午",
            "卯": "未",
            "辰": "申",
            "巳": "酉",
            "午": "戌",
            "未": "亥",
            "申": "子",
            "酉": "丑",
            "戌": "寅",
            "亥": "卯",
            "子": "辰",
            "丑": "巳"
        },
        "locationDescriptionList": ["太岁三合局前支"]
    },
    {
        "name": "白虎",
        "jiXiong": "凶",
        "descriptionList": ["主血光凶丧之事"],
        "type": "年煞",
        "locationMapper": {
            "寅": "戌",
            "卯": "亥",
            "辰": "子",
            "巳": "丑",
            "午": "寅",
            "未": "卯",
            "申": "辰",
            "酉": "巳",
            "戌": "午",
            "亥": "未",
            "子": "申",
            "丑": "酉"
        },
        "locationDescriptionList": ["太岁三合局后支"]
    },
    {
        "name": "小耗",
        "jiXiong": "凶",
        "descriptionList": ["主小破财"],
        "type": "年煞",
        "locationMapper": {
            "寅": "未",
            "卯": "申",
            "辰": "酉",
            "巳": "戌",
            "午": "亥",
            "未": "子",
            "申": "丑",
            "酉": "寅",
            "戌": "卯",
            "亥": "辰",
            "子": "巳",
            "丑": "午"
        },
        "locationDescriptionList": ["病符对冲之支"]
    },
    {
        "name": "大耗",
        "jiXiong": "凶",
        "descriptionList": ["主大破财"],
        "type": "年煞",
        "locationMapper": {
            "寅": "申",
            "卯": "酉",
            "辰": "戌",
            "巳": "亥",
            "午": "子",
            "未": "丑",
            "申": "寅",
            "酉": "卯",
            "戌": "辰",
            "亥": "巳",
            "子": "午",
            "丑": "未"
        },
        "locationDescriptionList": ["岁破同位"]
    },
  {
    "name": "岁刑",
    "jiXiong": "凶",
    "descriptionList": ["主刑伤、纠纷，岁中易犯官司、伤病，需防人际关系不和"],
    "type": "年煞",
    "locationMapper": {
      "子": "卯",
      "卯": "子",
      "寅": "巳",
      "巳": "申",
      "申": "寅",
      "丑": "戌",
      "戌": "未",
      "未": "丑",
      "辰": "辰",
      "午": "午",
      "酉": "酉",
      "亥": "亥"
    },
    "locationDescriptionList": ["子刑卯、卯刑子、寅刑巳、巳刑申、申刑寅、丑刑戌、戌刑未、未刑丑、辰午酉亥自刑"]
  },
  {
    "name": "大将军",
    "jiXiong": "吉",
    "descriptionList": ["主权威、征战，宜主动进取，忌冲撞，象征当年权势力量"],
    "type": "年煞",
    "locationMapper": {
      "子": "子",
      "丑": "丑",
      "寅": "寅",
      "卯": "卯",
      "辰": "辰",
      "巳": "巳",
      "午": "午",
      "未": "未",
      "申": "申",
      "酉": "酉",
      "戌": "戌",
      "亥": "亥"
    },
    "locationDescriptionList": ["正月起寅顺行十二支"]
  },
  {
    "name": "孝服",
    "jiXiong": "凶",
    "descriptionList": ["主丧服、孝事，逢之需防亲属丧事，或有孝服在身之事"],
    "type": "年煞",
    "locationMapper": {
      "子": "午",
      "丑": "未",
      "寅": "申",
      "卯": "酉",
      "辰": "戌",
      "巳": "亥",
      "午": "子",
      "未": "丑",
      "申": "寅",
      "酉": "卯",
      "戌": "辰",
      "亥": "巳"
    },
    "locationDescriptionList": ["年支前六位（如子年孝服在午）"]
  },
  {
    "name": "死符",
    "jiXiong": "凶",
    "descriptionList": ["主死亡、符煞，象征死亡威胁、凶符降临，需防重疾、横祸"],
    "type": "年煞",
    "locationMapper": {
      "子": "卯",
      "丑": "辰",
      "寅": "巳",
      "卯": "午",
      "辰": "未",
      "巳": "申",
      "午": "酉",
      "未": "戌",
      "申": "亥",
      "酉": "子",
      "戌": "丑",
      "亥": "寅"
    },
    "locationDescriptionList": ["年支后三位（如子年死符在卯）"]
  },
  {
    "name": "岁宅",
    "jiXiong": "中性",
    "descriptionList": ["主家宅、岁中居所，象征当年家宅运势，利修宅、安住，忌宅中动土不吉"],
    "type": "年煞",
    "locationMapper": {
      "子": "子",
      "丑": "丑",
      "寅": "寅",
      "卯": "卯",
      "辰": "辰",
      "巳": "巳",
      "午": "午",
      "未": "未",
      "申": "申",
      "酉": "酉",
      "戌": "戌",
      "亥": "亥"
    },
    "locationDescriptionList": ["年支本位（如子年宅在子）"]
  },
  {
    "name": "大煞",
    "jiXiong": "凶",
    "descriptionList": ["主大凶、破耗，象征重大灾祸、大破财，需避岁破之方，忌重大决策"],
    "type": "年煞",
    "locationMapper": {
      "子": "午",
      "丑": "未",
      "寅": "申",
      "卯": "酉",
      "辰": "戌",
      "巳": "亥",
      "午": "子",
      "未": "丑",
      "申": "寅",
      "酉": "卯",
      "戌": "辰",
      "亥": "巳"
    },
    "locationDescriptionList": ["子年在午、丑年在未、寅年在申、卯年在酉等岁破位"]
    },
    {
        "name": "天煞",
        "jiXiong": "凶",
        "descriptionList": [""],
        "type": "年煞",
        "locationMapper": {
            "寅": "戌",
            "午": "戌",
            "戌": "戌",
            "亥": "未",
            "卯": "未",
            "未": "未",
            "申": "辰",
            "子": "辰",
            "辰": "辰",
            "巳": "丑",
            "酉": "丑",
            "丑": "丑"
        },
        "locationDescriptionList": ["寅午戌在戌，亥卯未在未，申子辰在辰，巳酉丑在丑（三合墓地）"]
    },

        {
        "name": "华盖",
        "jiXiong": "凶",
        "descriptionList": ["主孤，好学"],
        "type": "年煞",
    "locationMapper": {
      "寅": "戌",
      "卯": "未",
      "辰": "辰",
      "巳": "丑",
      "午": "戌",
      "未": "未",
      "申": "辰",
      "酉": "丑",
      "戌": "戌",
      "亥": "未",
      "子": "辰",
      "丑": "丑"
    },
        "locationDescriptionList": [""]
    },
      {
    "name": "劫煞",
    "jiXiong": "凶",
    "descriptionList": ["是非破财","主劫盗伤杀之事，诸占速应，劫煞乘白虎、玄武、贼符等，必主劫盗之应"],
    "type": "年煞",
    "locationMapper": {
      "寅": "亥",
      "午": "亥",
      "戌": "亥",
      "亥": "申",
      "卯": "申",
      "未": "申",
      "申": "巳",
      "子": "巳",
      "辰": "巳",
      "巳": "寅",
      "酉": "寅",
      "丑": "寅"
    },
    "locationDescriptionList": ["寅午戌在亥，亥卯未在申，申子辰在巳，巳酉丑在寅（三合绝地）"]
  },
    {
    "name": "破碎",
    "jiXiong": "凶",
    "descriptionList": ["主破坏，凡事难成","主物破、财损、血光"],
    "type": "年煞",
    "locationMapper": {
      "寅": "酉",
      "巳": "酉",
      "申": "酉",
      "亥": "酉",
      "子": "巳",
      "卯": "巳",
      "午": "巳",
      "酉": "巳",
      "丑": "丑",
      "辰": "丑",
      "未": "丑",
      "戌": "丑"
    },
    "locationDescriptionList": ["寅巳申亥见酉，子卯午酉见巳，丑辰未戌见丑"]
  },
    {
    "name": "驿马",
    "jiXiong": "吉",
    "descriptionList": ["主变动奔波","主动变，最喜与禄神并","主动，又主速，日马尤为重要"],
    "type": "年煞",
    "locationMapper": {
      "寅": "申",
      "午": "申",
      "戌": "申",
      "亥": "巳",
      "卯": "巳",
      "未": "巳",
      "申": "寅",
      "子": "寅",
      "辰": "寅",
      "巳": "亥",
      "酉": "亥",
      "丑": "亥"
    },
    "locationDescriptionList": ["寅午戌见申，亥卯未见巳，申子辰见寅，巳酉丑见亥"]
  },
  {
    "name": "天喜",
    "jiXiong": "吉",
    "descriptionList": ["喜庆"],
    "type": "年煞",
    "locationMapper": {
      "寅": "未",
      "午": "午",
      "戌": "巳",
      "亥": "辰",
      "卯": "卯",
      "未": "寅",
      "申": "丑",
      "子": "子",
      "辰": "辰",
      "巳": "巳",
      "酉": "酉",
      "丑": "申"
    },
    "locationDescriptionList": []
  },
  {
    "name": "将星",
    "jiXiong": "吉",
    "descriptionList": ["权禄","主将才、中心，象征核心人物、领导才能，利主事、统管，增强权威"],
    "type": "年煞",
    "locationMapper": {
      "寅": "午",
      "午": "午",
      "戌": "午",
      "亥": "卯",
      "卯": "卯",
      "未": "卯",
      "申": "子",
      "子": "子",
      "辰": "子",
      "巳": "酉",
      "酉": "酉",
      "丑": "酉"
    },
    "locationDescriptionList": ["寅午戌在午、亥卯未在卯、申子辰在子、巳酉丑在酉（三合旺地）"]
  },
  {
    "name": "大煞",
    "jiXiong": "吉",
    "descriptionList": ["年内旺气，生干吉，克干凶。"],
    "type": "年煞",
    "locationMapper": {
      "寅": "午",
      "午": "午",
      "戌": "午",
      "亥": "卯",
      "卯": "卯",
      "未": "卯",
      "申": "子",
      "子": "子",
      "辰": "子",
      "巳": "酉",
      "酉": "酉",
      "丑": "酉"
    },
    "locationDescriptionList": ["寅午戌在午、亥卯未在卯、申子辰在子、巳酉丑在酉（三合旺地）"]
  },
    {
        "name": "岁刑",
        "jiXiong": "凶",
        "descriptionList": ["岁支之刑辰，主刑伤，病讼最忌"],
        "type": "年煞",
        "locationMapper": {
            "寅": "巳",
            "卯": "子",
            "辰": "辰",
            "巳": "申",
            "午": "午",
            "未": "丑",
            "申": "寅",
            "酉": "酉",
            "戌": "未",
            "亥": "亥",
            "子": "卯",
            "丑": "戌"
        },
        "locationDescriptionList": ["依十二地支对应查找，不同地支对应不同位置体现影响"]
    },
      {
    "name": "桃花",
    "jiXiong": "凶",
    "descriptionList": ["主婚恋、淫乱"],
    "type": "年煞",
    "locationMapper": {
      "寅": "卯",
      "卯": "子",
      "辰": "酉",
      "巳": "午",
      "午": "卯",
      "未": "子",
      "申": "酉",
      "酉": "午",
      "戌": "卯",
      "亥": "子",
      "子": "酉",
      "丑": "午"
    },
    "locationDescriptionList": ["正月起卯，逆行四仲（卯、子、酉、午），周而复始"]
  },
{
    "name": "岁煞",
    "jiXiong": "凶",
    "descriptionList": ["凡占皆凶，劫煞、灾煞、岁煞名曰三煞"],
    "type": "年煞",
    "locationMapper": {
      "寅": "丑",
      "卯": "戌",
      "辰": "未",
      "巳": "辰",
      "午": "丑",
      "未": "戌",
      "申": "未",
      "酉": "辰",
      "戌": "丑",
      "亥": "戌",
      "子": "未",
      "丑": "辰"
    },
    "locationDescriptionList": []
  },
  {
    "name": "红鸾",
    "jiXiong": "吉",
    "descriptionList": ["喜庆"],
    "type": "年煞",
    "locationMapper": {
      "寅": "丑",
      "卯": "子",
      "辰": "亥",
      "巳": "戌",
      "午": "酉",
      "未": "申",
      "申": "未",
      "酉": "午",
      "戌": "巳",
      "亥": "辰",
      "子": "卯",
      "丑": "寅"
    },
    "locationDescriptionList": []
  },
  {
    "name": "灾煞",
    "jiXiong": "凶",
    "descriptionList": ["凡占皆凶"],
    "type": "年煞",
    "locationMapper": {
      "寅": "子",
      "午": "子",
      "戌": "子",
      "亥": "酉",
      "卯": "酉",
      "未": "酉",
      "申": "午",
      "子": "午",
      "辰": "午",
      "巳": "卯",
      "酉": "卯",
      "丑": "卯"
    },
    "locationDescriptionList": ["寅午戌在子，亥卯未在酉，申子辰在午，巳酉丑在卯（三合胎地）"]
  },
      {
    "name": "岁合",
    "jiXiong": "吉",
    "descriptionList": ["岁支之合辰，凡占皆吉","主契合、合作，象征地支间的和谐共振，利联合、成事，增强事物稳定性"],
    "type": "年煞",
    "locationMapper": {
      "子": "丑",
      "丑": "子",
      "寅": "亥",
      "亥": "寅",
      "卯": "戌",
      "戌": "卯",
      "辰": "酉",
      "酉": "辰",
      "巳": "申",
      "申": "巳",
      "午": "未",
      "未": "午"
    },
    "locationDescriptionList": ["地支六合（子丑合、寅亥合、卯戌合、辰酉合、巳申合、午未合）"]
  },
    {
    "name": "岁墓",
    "jiXiong": "吉",
    "descriptionList": ["太歲後五辰也。主墳墓、病訟、宅災等事。 "],
    "type": "年煞",
    "locationMapper": {
      "寅": "酉",
      "卯": "戌",
      "辰": "亥",
      "巳": "子",
      "午": "丑",
      "未": "寅",
      "申": "卯",
      "酉": "辰",
      "戌": "巳",
      "亥": "午",
      "子": "未",
      "丑": "申"
    },
    "locationDescriptionList": [""]
  },
      {
    "name": "合神",
    "jiXiong": "吉",
    "descriptionList": [],
    "type": "年煞",
    "locationMapper": {
      "寅": "巳",
      "卯": "午",
      "辰": "未",
      "巳": "申",
      "午": "酉",
      "未": "戌",
      "申": "亥",
      "酉": "子",
      "戌": "丑",
      "亥": "寅",
      "子": "卯",
      "丑": "辰"
    },
    "locationDescriptionList": [""]
  },

        {
    "name": "太阳",
    "jiXiong": "平",
    "descriptionList": [],
    "type": "年煞",
    "locationMapper": {
      "寅": "卯",
      "卯": "辰",
      "辰": "巳",
      "巳": "午",
      "午": "未",
      "未": "申",
      "申": "酉",
      "酉": "戌",
      "戌": "亥",
      "亥": "子",
      "子": "丑",
      "丑": "寅"
    },
    "locationDescriptionList": [""]
  }
]');
INSERT INTO shen_sha_document ("file_name", "payload_json") VALUES ('6_shensha_year_gan.json', '[
    {
    "name": "岁徳",
    "jiXiong": "吉",
    "descriptionList": ["阳年即岁干，阴年岁干之合，入占福集殃消"],
    "type": "年干",
    "locationMapper": {
        "甲": "乙",
        "乙": "庚",
        "丙": "丙",
        "丁": "壬",
        "戊": "戊",
        "己": "甲",
        "庚": "庚",
        "辛": "丙",
        "壬": "壬",
        "癸": "戊"
    },
    "locationDescriptionList": [""]
},
    {
    "name": "岁徳合",
    "jiXiong": "吉",
    "descriptionList": ["岁徳之合，入占与岁徳同"],
    "type": "年干",
    "locationMapper": {
        "甲": "己",
        "乙": "庚",
        "丙": "辛",
        "丁": "壬",
        "戊": "癸",
        "己": "甲",
        "庚": "乙",
        "辛": "丙",
        "壬": "丁",
        "癸": "戊"
    },
    "locationDescriptionList": [""]
},
    {
    "name": "天廷",
    "jiXiong": "吉",
    "descriptionList": ["岁干禄位后一辰，主事干朝廷"],
    "type": "年干",
    "locationMapper": {
        "甲": "丑",
        "乙": "寅",
        "丙": "辰",
        "丁": "巳",
        "戊": "辰",
        "己": "巳",
        "庚": "未",
        "辛": "申",
        "壬": "戌",
        "癸": "亥"
    },
    "locationDescriptionList": [""]
}
]');
INSERT INTO shen_sha_document ("file_name", "payload_json") VALUES ('6_shensha_zhi.json', '[
  {
    "name": "驿马",
    "jiXiong": "吉",
    "otherNameList":["日马"],
    "descriptionList": ["主变动奔波","主动变，最喜与禄神并","主动，又主速，日马尤为重要"],
    "type": "支煞",
    "locationMapper": {
      "寅": "申",
      "午": "申",
      "戌": "申",
      "亥": "巳",
      "卯": "巳",
      "未": "巳",
      "申": "寅",
      "子": "寅",
      "辰": "寅",
      "巳": "亥",
      "酉": "亥",
      "丑": "亥"
    },
    "locationDescriptionList": ["寅午戌见申，亥卯未见巳，申子辰见寅，巳酉丑见亥"]
  },
  {
    "name": "劫煞",
    "jiXiong": "凶",
    "descriptionList": ["主劫盗伤杀之事，诸占速应，劫煞乘白虎、玄武、贼符等，必主劫盗之应"],
    "type": "支煞",
    "locationMapper": {
      "寅": "亥",
      "午": "亥",
      "戌": "亥",
      "亥": "申",
      "卯": "申",
      "未": "申",
      "申": "巳",
      "子": "巳",
      "辰": "巳",
      "巳": "寅",
      "酉": "寅",
      "丑": "寅"
    },
    "locationDescriptionList": ["寅午戌在亥，亥卯未在申，申子辰在巳，巳酉丑在寅（三合绝地）"]
  },
  {
    "name": "灾煞",
    "jiXiong": "凶",
    "descriptionList": ["主飞横不测之事"],
    "type": "支煞",
    "locationMapper": {
      "寅": "子",
      "午": "子",
      "戌": "子",
      "亥": "酉",
      "卯": "酉",
      "未": "酉",
      "申": "午",
      "子": "午",
      "辰": "午",
      "巳": "卯",
      "酉": "卯",
      "丑": "卯"
    },
    "locationDescriptionList": ["寅午戌在子，亥卯未在酉，申子辰在午，巳酉丑在卯（三合胎地）"]
  },
  {
    "name": "亡神",
    "jiXiong": "凶",
    "descriptionList": ["主人亡物失"],
    "type": "支煞",
    "locationMapper": {
      "寅": "巳",
      "午": "巳",
      "戌": "巳",
      "亥": "寅",
      "卯": "寅",
      "未": "寅",
      "申": "亥",
      "子": "亥",
      "辰": "亥",
      "巳": "申",
      "酉": "申",
      "丑": "申"
    },
    "locationDescriptionList": ["寅午戌见巳，亥卯未见寅，申子辰见亥，巳酉丑见申"]
  },
  {
    "name": "破碎",
    "jiXiong": "凶",
    "descriptionList": ["主物破、财损、血光"],
    "type": "支煞",
    "locationMapper": {
      "寅": "酉",
      "巳": "酉",
      "申": "酉",
      "亥": "酉",
      "子": "巳",
      "卯": "巳",
      "午": "巳",
      "酉": "巳",
      "丑": "丑",
      "辰": "丑",
      "未": "丑",
      "戌": "丑"
    },
    "locationDescriptionList": ["寅巳申亥见酉，子卯午酉见巳，丑辰未戌见丑"]
  },
  {
    "name": "华盖",
    "jiXiong": "平",
    "descriptionList": ["主孤独、艺术、僧道，日上主昏迷，三合之季辰。"],
    "type": "支煞",
    "locationMapper": {
      "寅": "戌",
      "卯": "未",
      "辰": "辰",
      "巳": "丑",
      "午": "戌",
      "未": "未",
      "申": "辰",
      "酉": "丑",
      "戌": "戌",
      "亥": "未",
      "子": "辰",
      "丑": "丑"
    },
    "locationDescriptionList": ["寅午戌见戌，亥卯未见未，申子辰见辰，巳酉丑见丑"]
  },
  {
    "name": "桃花",
    "jiXiong": "凶",
    "descriptionList": ["主口舌、淫乱"],
    "type": "支煞",
    "locationMapper": {
      "寅": "卯",
      "午": "卯",
      "戌": "卯",
      "亥": "子",
      "卯": "子",
      "未": "子",
      "申": "酉",
      "子": "酉",
      "辰": "酉",
      "巳": "午",
      "酉": "午",
      "丑": "午"
    },
    "locationDescriptionList": ["寅午戌在卯，亥卯未在子，申子辰在酉，巳酉丑在午（三合败地）"]
  },
  {
    "name": "悬索",
    "jiXiong": "凶",
    "descriptionList": ["占贼必自屋而下，占病必有自缢鬼"],
    "type": "支煞",
    "locationMapper": {
      "寅": "卯",
      "午": "卯",
      "戌": "卯",
      "亥": "子",
      "卯": "子",
      "未": "子",
      "申": "酉",
      "子": "酉",
      "辰": "酉",
      "巳": "午",
      "酉": "午",
      "丑": "午"
    },
    "locationDescriptionList": ["寅午戌在卯，亥卯未在子，申子辰在酉，巳酉丑在午（三合败地）"]
  },
  {
    "name": "支德",
    "jiXiong": "吉",
    "descriptionList": ["主子嗣、道德"],
    "type": "支煞",
    "locationMapper": {
      "子": "巳",
      "丑": "午",
      "寅": "未",
      "卯": "申",
      "辰": "酉",
      "巳": "戌",
      "午": "亥",
      "未": "子",
      "申": "丑",
      "酉": "寅",
      "戌": "卯",
      "亥": "辰"
    },
    "locationDescriptionList": ["子见巳，丑见午，寅见未，卯见申，辰见酉，巳见戌，午见亥，未见子，申见丑，酉见寅，戌见卯，亥见辰"]
  },
  {
    "name": "雨师",
    "jiXiong": "平",
    "descriptionList": ["主雨"],
    "type": "支煞",
    "locationMapper": {
      "子": "申",
      "丑": "酉",
      "寅": "戌",
      "卯": "亥",
      "辰": "子",
      "巳": "丑",
      "午": "寅",
      "未": "卯",
      "申": "辰",
      "酉": "巳",
      "戌": "午",
      "亥": "未"
    },
    "locationDescriptionList": ["子见申，丑见酉，寅见戌，卯见亥，辰见子，巳见丑，午见寅，未见卯，申见辰，酉见巳，戌见午，亥见未"]
  },
  {
    "name": "晴郎",
    "jiXiong": "吉",
    "descriptionList": ["主晴"],
    "type": "支煞",
    "locationMapper": {
      "子": "午",
      "丑": "未",
      "寅": "申",
      "卯": "酉",
      "辰": "戌",
      "巳": "亥",
      "午": "子",
      "未": "丑",
      "申": "寅",
      "酉": "卯",
      "戌": "辰",
      "亥": "巳"
    },
    "locationDescriptionList": ["子见午，丑见未，寅见申，卯见酉，辰见戌，巳见亥，午见子，未见丑，申见寅，酉见卯，戌见辰，亥见巳"]
  },
  {
    "name": "罗网",
    "jiXiong": "凶",
    "descriptionList": ["主束缚、困境"],
    "type": "支煞",
    "locationMapper": {
      "子": "亥",
      "丑": "子",
      "寅": "丑",
      "卯": "寅",
      "辰": "卯",
      "巳": "辰",
      "午": "巳",
      "未": "午",
      "申": "未",
      "酉": "申",
      "戌": "酉",
      "亥": "戌"
    },
    "locationDescriptionList": ["子见亥，丑见子，寅见丑，卯见寅，辰见卯，巳见辰，午见巳，未见午，申见未，酉见申，戌见酉，亥见戌"]
  },
    {
    "name": "支合",
    "jiXiong": "吉",
    "descriptionList": ["主契合、合作，象征地支间的和谐共振，利联合、成事，增强事物稳定性"],
    "type": "支煞",
    "otherNameList":["六合"],
    "locationMapper": {
      "子": "丑",
      "丑": "子",
      "寅": "亥",
      "亥": "寅",
      "卯": "戌",
      "戌": "卯",
      "辰": "酉",
      "酉": "辰",
      "巳": "申",
      "申": "巳",
      "午": "未",
      "未": "午"
    },
    "locationDescriptionList": ["地支六合（子丑合、寅亥合、卯戌合、辰酉合、巳申合、午未合）"]
  },
  {
    "name": "支破",
    "jiXiong": "凶",
    "descriptionList": ["主破损、破裂，象征地支间的相互破坏，利破除旧物，忌重要事物、关系"],
    "type": "支煞",
    "otherNameList": ["破六"],
    "locationMapper": {
      "子": "酉",
      "酉": "子",
      "午": "卯",
      "卯": "午",
      "巳": "申",
      "申": "巳",
      "寅": "亥",
      "亥": "寅",
      "辰": "丑",
      "丑": "辰",
      "戌": "未",
      "未": "戌"
    },
    "locationDescriptionList": ["地支六破（子酉破、午卯破、巳申破、寅亥破、辰丑破、戌未破）"]
  },  {
    "name": "天城",
    "jiXiong": "吉",
    "descriptionList": ["主城防、守护，象征天城守护，利守城、防御，忌城破、失防"],
    "type": "支煞",
    "locationMapper": {
      "申": "辰",
      "子": "辰",
      "辰": "辰",
      "亥": "未",
      "卯": "未",
      "未": "未",
      "寅": "戌",
      "午": "戌",
      "戌": "戌",
      "巳": "丑",
      "酉": "丑",
      "丑": "丑"
    },
    "locationDescriptionList": ["申子辰日在辰、亥卯未日在未、寅午戌日在戌、巳酉丑日在丑"]
  },
    {
    "name": "将星",
    "jiXiong": "吉",
    "descriptionList": ["三合之仲，兵占旺相吉","主将才、中心，象征核心人物、领导才能，利主事、统管，增强权威"],
    "type": "支煞",
    "locationMapper": {
      "寅": "午",
      "午": "午",
      "戌": "午",
      "亥": "卯",
      "卯": "卯",
      "未": "卯",
      "申": "子",
      "子": "子",
      "辰": "子",
      "巳": "酉",
      "酉": "酉",
      "丑": "酉"
    },
    "locationDescriptionList": ["三合之仲，寅午戌日在午、亥卯未日在卯、申子辰日在子、巳酉丑日在酉（三合旺地）"]
  },

  {
    "name": "将军",
    "jiXiong": "吉",
    "descriptionList": ["主大将、威严，象征高级将领、强大权威，利指挥、征战，忌轻敌妄动"],
    "type": "支煞",
    "locationMapper": {      
        "寅": "午",
      "午": "午",
      "戌": "午",
      "亥": "卯",
      "卯": "卯",
      "未": "卯",
      "申": "子",
      "子": "子",
      "辰": "子",
      "巳": "酉",
      "酉": "酉",
      "丑": "酉"
    },
    "locationDescriptionList": ["与将星同支，力量更强"]
  },
    {
    "name": "支亡",
    "jiXiong": "凶",
    "descriptionList": ["主消亡、损失，象征地支能量消亡，利散事，忌聚合"],
    "type": "支煞",
    "locationMapper": {
      "寅": "巳",
      "卯": "申",
      "辰": "亥",
      "巳": "申",
      "午": "亥",
      "未": "寅",
      "申": "亥",
      "酉": "寅",
      "戌": "巳",
      "亥": "寅",
      "子": "巳",
      "丑": "申"
    },
    "locationDescriptionList": ["地支十二长生中的 “亡神” 位（如寅日亡神在巳）"]
  },
    {
    "name": "风伯",
    "jiXiong": "凶",
    "descriptionList": ["主风灾、动荡，象征大风、风波，利出行扬帆，忌防风险"],
    "type": "支煞",
    "locationMapper": {
      "申": "亥",
      "子": "亥",
      "辰": "亥",
      "亥": "寅",
      "卯": "寅",
      "未": "寅",
      "寅": "巳",
      "午": "巳",
      "戌": "巳",
      "巳": "申",
      "酉": "申",
      "丑": "申"
    },
    "locationDescriptionList": ["申子辰日在亥、亥卯未日在寅、寅午戌日在巳、巳酉丑日在申"]
  },
    {
    "name": "飞符",
    "jiXiong": "中性",
    "descriptionList": ["主紧急、文书，象征突发符令、急事催促，宜快速应对"],
    "type": "支煞",
    "locationMapper": {
      "寅": "巳",
      "卯": "午",
      "辰": "未",
      "巳": "申",
      "午": "酉",
      "未": "戌",
      "申": "亥",
      "酉": "子",
      "戌": "丑",
      "亥": "寅",
      "子": "卯",
      "丑": "辰"
    },
    "locationDescriptionList": ["正月起巳顺行十二支"]
  },
    {
    "name": "游神",
    "jiXiong": "中性",
    "descriptionList": ["主动荡、不安，象征外出游荡、心神不宁，利出行不利守成"],
    "type": "支煞",
    "locationMapper": {
      "寅": "巳",
      "午": "巳",
      "戌": "巳",
      "亥": "申",
      "卯": "申",
      "未": "申",
      "申": "亥",
      "子": "亥",
      "辰": "亥",
      "巳": "寅",
      "酉": "寅",
      "丑": "寅"
    },
    "locationDescriptionList": ["寅午戌日在巳、亥卯未日在申、申子辰日在亥、巳酉丑日在寅"]
  },
    {
    "name": "三刑",
    "jiXiong": "凶",
    "descriptionList": ["主多重刑伤，比单刑更重，易犯官非、伤病，能量相互克制耗散"],
    "type": "支煞",
    "locationMapper": {
      "子": "卯",
      "卯": "子",
      "寅": "巳",
      "巳": "申",
      "申": "寅",
      "丑": "戌",
      "戌": "未",
      "未": "丑",
      "辰": "辰",
      "午": "午",
      "酉": "酉",
      "亥": "亥"
    },
    "locationDescriptionList": ["同岁刑支刑规则"]
  },

    {
    "name": "六害",
    "jiXiong": "凶",
    "descriptionList": ["主妨害、不和，人际关系易生矛盾，谋事多受阻挠"],
    "type": "支煞",
    "locationMapper": {
      "子": "未",
      "丑": "午",
      "寅": "巳",
      "卯": "辰",
      "申": "亥",
      "酉": "戌",
      "戌": "酉",
      "亥": "申",
      "巳": "寅",
      "午": "丑",
      "辰": "卯",
      "未": "子"
    },
    "locationDescriptionList": ["子未害、丑午害、寅巳害、卯辰害、申亥害、酉戌害"]
  },
    {
    "name": "六冲",
    "jiXiong": "凶",
    "descriptionList": ["主冲克、离散，谋事易变、人际关系破裂，逢凶则加剧凶性"],
    "type": "支煞",
    "locationMapper": {
      "子": "午",
      "丑": "未",
      "寅": "申",
      "卯": "酉",
      "辰": "戌",
      "巳": "亥",
      "午": "子",
      "未": "丑",
      "申": "寅",
      "酉": "卯",
      "戌": "辰",
      "亥": "巳"
    },
    "locationDescriptionList": ["子午冲、丑未冲、寅申冲、卯酉冲、辰戌冲、巳亥冲"]
  },
    {
    "name": "天煞",
    "jiXiong": "凶",
    "descriptionList": ["又为岁煞、月煞，劫煞后一位"],
    "type": "支煞",
    "locationMapper": {
      "寅": "戌",
      "午": "戌",
      "戌": "戌",
      "亥": "未",
      "卯": "未",
      "未": "未",
      "申": "辰",
      "子": "辰",
      "辰": "辰",
      "巳": "丑",
      "酉": "丑",
      "丑": "丑"
    },
    "locationDescriptionList": ["寅午戌在戌，亥卯未在未，申子辰在辰，巳酉丑在丑（三合墓地）"]
  },
  {
    "name": "华盖",
    "jiXiong": "凶",
    "descriptionList": ["又为月煞，最忌与日干墓库并，为华盖覆日人昏晦，尤凶"],
    "type": "支煞",
    "locationMapper": {
      "午": "戌",
      "戌": "戌",
      "亥": "未",
      "卯": "未",
      "未": "未",
      "申": "辰",
      "子": "辰",
      "丑": "丑",
      "寅": "戌",
      "辰": "辰",
      "巳": "丑",
      "酉": "丑"
    },
    "locationDescriptionList": ["寅午戌在戌，亥卯未在未，申子辰在辰，巳酉丑在丑（三合墓地）"]
  },
  {
    "name": "日刑",
    "jiXiong": "凶",
    "descriptionList": ["主刑伤"],
    "type": "支煞",
    "locationMapper": {
      "寅": "巳",
      "午": "午",
      "戌": "未",
      "申": "寅",
      "子": "卯",
      "辰": "辰",
      "巳": "申",
      "酉": "酉",
      "丑": "戌",
      "亥": "亥",
      "卯": "子",
      "未": "丑"
    },
    "locationDescriptionList": ["日支所刑之辰。寅午戌日刑分别在巳午未方；申子辰日刑分别在寅卯辰方；巳酉丑日刑分别在申酉戌方；亥卯未日刑分别在亥子丑方"]
  },
    {
    "name": "白衣翰林",
    "jiXiong": "吉",
    "descriptionList": ["主天晴"],
    "type": "支煞",
    "locationMapper": {
      "子": "酉",
      "丑": "未",
      "寅": "巳",
      "卯": "卯",
      "辰": "丑",
      "巳": "亥",
      "午": "酉",
      "未": "未",
      "申": "巳",
      "酉": "卯",
      "戌": "丑",
      "亥": "亥"
    },
    "locationDescriptionList": ["日支冲辰也，子日起午，顺行十二辰"]
  },
  {
    "name": "晴朗",
    "jiXiong": "吉",
    "descriptionList": ["主天晴"],
    "type": "支煞",
    "locationMapper": {
      "子": "午",
      "丑": "未",
      "寅": "申",
      "卯": "酉",
      "辰": "戌",
      "巳": "亥",
      "午": "子",
      "未": "丑",
      "申": "寅",
      "酉": "卯",
      "戌": "辰",
      "亥": "巳"
    },
    "locationDescriptionList": ["日支冲辰也，子日起午，顺行十二辰"]
  },
    {
    "name": "日医",
    "jiXiong": "吉",
    "descriptionList": ["主医药、治疗，象征当日医生、良药"],
    "type": "支煞",
    "locationMapper": {
      "子": "丑",
      "丑": "子",
      "寅": "卯",
      "卯": "寅",
      "辰": "巳",
      "巳": "辰",
      "午": "未",
      "未": "午",
      "申": "酉",
      "酉": "申",
      "戌": "亥",
      "亥": "戌"
    },
    "locationDescriptionList": ["日支相邻地支为日医，如子日医在丑，主疾病痊愈"]
  },
    {
    "name": "日盗",
    "jiXiong": "凶",
    "descriptionList": ["主盗窃、损耗，象征财物被偷、暗中消耗"],
    "type": "支煞",
    "locationMapper": {
      "子": "丑",
      "丑": "子",
      "寅": "卯",
      "卯": "寅",
      "辰": "巳",
      "巳": "辰",
      "午": "未",
      "未": "午",
      "申": "酉",
      "酉": "申",
      "戌": "亥",
      "亥": "戌"
    },
    "locationDescriptionList": ["日支泄气之支为日盗，如寅日盗在卯，主财物损耗"]
  },
    {
    "name": "产煞",
    "jiXiong": "凶",
    "descriptionList": ["主生育、产难，象征生产不顺、难产之险"],
    "type": "支煞",
    "locationMapper": {
      "子": "午",
      "午": "子",
      "丑": "未",
      "未": "丑",
      "寅": "申",
      "申": "寅",
      "卯": "酉",
      "酉": "卯",
      "辰": "戌",
      "戌": "辰",
      "巳": "亥",
      "亥": "巳"
    }
},
  {
    "name": "天庭",
    "jiXiong": "吉",
    "descriptionList": ["主官贵、天庭关注，利求官、见贵"],
    "type": "支煞",
    "locationMapper": {
      "子": "午",
      "丑": "未",
      "寅": "申",
      "卯": "酉",
      "辰": "戌",
      "巳": "亥",
      "午": "子",
      "未": "丑",
      "申": "寅",
      "酉": "卯",
      "戌": "辰",
      "亥": "巳"
    },
    "locationDescriptionList": ["地支对冲位为天庭，如子日天庭在午，主得上司青睐"]
  },
   {
            "name": "支仪",
            "jiXiong": "吉（传统命理中多为辅助、助力意象 ）",
            "descriptionList": ["在命理神煞体系里，对日柱等有一定增益、调和作用"],
            "type": "支煞",
            "locationMapper": {
                "子": "午",
                "丑": "巳",
                "寅": "辰",
                "卯": "卯",
                "辰": "寅",
                "巳": "丑",
                "午": "未",
                "未": "申",
                "申": "酉",
                "酉": "戌",
                "戌": "亥",
                "亥": "子"
            },
            "locationDescriptionList": ["以日支十二地支为基础，对应不同位置体现支仪影响"]
        },
        {
            "name": "支德",
            "jiXiong": "吉（传统认知中为德神，可带来吉祥、化解小厄 ）",
            "descriptionList": ["命理中象征品德、福运，有助于缓解不利，增益运势"],
            "type": "支煞",
            "locationMapper": {
                "子": "巳",
                "丑": "午",
                "寅": "未",
                "卯": "申",
                "辰": "酉",
                "巳": "戌",
                "午": "亥",
                "未": "子",
                "申": "丑",
                "酉": "寅",
                "戌": "卯",
                "亥": "辰"
            },
            "locationDescriptionList": ["按日支十二地支对应，反映支德在不同方位的吉利属性"]
        },
        {
            "name": "日马",
            "jiXiong": "吉（传统命理中与奔波、进取、机遇相关，吉时主积极变化 ）",
            "descriptionList": ["寓意有奔波、走动带来机遇等情况，若契合运势，可助力发展"],
            "type": "支煞",
            "locationMapper": {
                "子": "寅",
                "丑": "亥",
                "寅": "申",
                "卯": "巳",
                "辰": "寅",
                "巳": "亥",
                "午": "申",
                "未": "巳",
                "申": "寅",
                "酉": "亥",
                "戌": "申",
                "亥": "巳"
            },
            "locationDescriptionList": ["依据日支十二地支对应位置，显示日马所关联的动态、机遇指向"]
        },
        {
            "name": "雷电",
            "jiXiong": "凶（传统神煞中多象征突发、激烈的不利影响 ）",
            "descriptionList": ["命理里寓意可能遭遇突发、冲击性的灾祸或困扰"],
            "type": "支煞",
            "locationMapper": {
                "子": "辰",
                "丑": "辰",
                "寅": "未",
                "卯": "未",
                "辰": "戌",
                "巳": "戌",
                "午": "丑",
                "未": "丑",
                "申": "寅",
                "酉": "寅",
                "戌": "卯",
                "亥": "卯"
            },
            "locationDescriptionList": ["通过日支十二地支对应，体现雷电神煞带来突发不利的位置关联"]
        }
]');
