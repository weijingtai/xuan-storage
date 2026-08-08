BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS ge_ju_content_document (  file_name TEXT PRIMARY KEY,  payload_json TEXT NOT NULL);
INSERT INTO ge_ju_content_document ("file_name", "payload_json") VALUES ('common_ge_ju_content.json', '[
  {
    "id": "common_001_ri_yue_jia_ming",
    "name": "日月夹命",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "日月夹命格，主大贵。太阳太阴分居命宫两侧。",
        "books": "果老星宗",
        "className": "通用格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "common_002_ri_yue_tong_gong",
    "name": "日月同宫",
    "variants": [
      {
        "source": "《果老星宗》",
        "description": "日月同宫，阴阳交泰。",
        "books": "果老星宗",
        "className": "通用格局",
        "jiXiong": "平",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "日屬陽，月屬陰，如同一宮，謂之陰陽得合。若在亥宮，謂之日月朝天。亥乃天門也。若在巳宮，謂之日月朝北。皆主富貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "日屬陽，月屬陰，如同一宮，謂之陰陽得合。若在亥宮，謂之日月朝天。亥乃天門也。若在巳宮，謂之日月朝北。皆主富貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "日屬陽，月屬陰，如同一宮，謂之陰陽得合。若在亥宮，謂之日月朝天。亥乃天門也。若在巳宮，謂之日月朝北。皆主富貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "common_003_wu_xing_ju_quan",
    "name": "五星聚全",
    "variants": [
      {
        "source": "《果老星宗》",
        "description": "五星聚全于三方，主大贵。木火土金水五星皆在三方之内。",
        "books": "果老星宗",
        "className": "通用格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_001_huo_luo_jia_ming",
    "name": "火罗夹命",
    "variants": [
      {
        "source": "《果老星宗》",
        "description": "火罗夹命，主凶。火星与罗睺分居命宫两侧。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "夭"
      }
    ]
  },
  {
    "id": "jin_001_tai_bai_shou_ming",
    "name": "太白守命",
    "variants": [
      {
        "source": "《果老星宗》",
        "description": "太白金星在命宫，入庙为贵。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "xian_001_xian_yu_ji",
    "name": "限遇计都",
    "variants": [
      {
        "source": "《果老星宗》",
        "description": "行限遇计都，主有灾祸。",
        "books": "果老星宗",
        "className": "行限格局",
        "jiXiong": "凶",
        "geJuType": "夭"
      }
    ]
  },
  {
    "id": "time_001_zhou_sheng_ri_li",
    "name": "昼生日立命",
    "variants": [
      {
        "source": "《果老星宗》",
        "description": "昼生人，太阳守命为吉格。",
        "books": "果老星宗",
        "className": "时间格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  }
]');
INSERT INTO ge_ju_content_document ("file_name", "payload_json") VALUES ('ge_ju_2_content.json', '[
  {
    "id": "geju2_9acefcb7",
    "name": "计罗截断",
    "variants": [
      {
        "source": "《格局2》",
        "description": "計羅截斷者，漏出有用之星辰，晝東南而夜西北，皆主於貴。凡人有晝生夜生會之者，皆主富貴，要兼身主旺而後貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "計羅截斷者，漏出有用之星辰，晝東南而夜西北，皆主於貴。凡人有晝生夜生會之者，皆主富貴，要兼身主旺而後貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "計羅截斷者，漏出有用之星辰，晝東南而夜西北，皆主於貴。凡人有晝生夜生會之者，皆主富貴，要兼身主旺而後貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_90e13704",
    "name": "身居闲极",
    "variants": [
      {
        "source": "《格局2》",
        "description": "身者，身主星也。人命以逢卯安命，遇酉安身。今人不知安身之法，只以太陰為身主者，謬也。閑極宮者，兄弟宮也。乃命宮逆至第三宮也。如身主星居之，主有清閑富貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "身者，身主星也。人命以逢卯安命，遇酉安身。今人不知安身之法，只以太陰為身主者，謬也。閑極宮者，兄弟宮也。乃命宮逆至第三宮也。如身主星居之，主有清閑富貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "身者，身主星也。人命以逢卯安命，遇酉安身。今人不知安身之法，只以太陰為身主者，謬也。閑極宮者，兄弟宮也。乃命宮逆至第三宮也。如身主星居之，主有清閑富貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_d5f1bf68",
    "name": "二主临财",
    "variants": [
      {
        "source": "《格局2》",
        "description": "身主星與命主星同入財帛宮者，其人主富厚，財帛宮，命宮第二宮也。喜坐實，忌空亡，干犯之主消敗也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "身主星與命主星同入財帛宮者，其人主富厚，財帛宮，命宮第二宮也。喜坐實，忌空亡，干犯之主消敗也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "富",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "身主星與命主星同入財帛宮者，其人主富厚，財帛宮，命宮第二宮也。喜坐實，忌空亡，干犯之主消敗也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "富",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_826fec08",
    "name": "官福居垣",
    "variants": [
      {
        "source": "《格局2》",
        "description": "官祿星，福德星二星，吉星也。凡官祿福德二宮，此星各守一宮。本位者，主貴也。子命以卯為官祿，寅為福德，火木二星是也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "官祿星，福德星二星，吉星也。凡官祿福德二宮，此星各守一宮。本位者，主貴也。子命以卯為官祿，寅為福德，火木二星是也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "官祿星，福德星二星，吉星也。凡官祿福德二宮，此星各守一宮。本位者，主貴也。子命以卯為官祿，寅為福德，火木二星是也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_3b4be61c",
    "name": "日月守照",
    "variants": [
      {
        "source": "《格局2》",
        "description": "日乃太陽星也。月乃太陰星也。凡人身命二宮，或日月守之，或對宮照之，皆吉而貴也。凶星不敢犯，更主其人少病也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "夭"
      },
      {
        "source": "《格局2》",
        "description": "日乃太陽星也。月乃太陰星也。凡人身命二宮，或日月守之，或對宮照之，皆吉而貴也。凶星不敢犯，更主其人少病也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "夭",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "日乃太陽星也。月乃太陰星也。凡人身命二宮，或日月守之，或對宮照之，皆吉而貴也。凶星不敢犯，更主其人少病也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "夭",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_ee7c2184",
    "name": "二曜朝阳",
    "variants": [
      {
        "source": "《格局2》",
        "description": "二曜，火星也。水數一，火數二，故曰：二曜與太陽同居午位，謂之朝陽。身命二宮逢之，主貴。更豐榮為官，當居顯秩之職。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "二曜，火星也。水數一，火數二，故曰：二曜與太陽同居午位，謂之朝陽。身命二宮逢之，主貴。更豐榮為官，當居顯秩之職。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "二曜，火星也。水數一，火數二，故曰：二曜與太陽同居午位，謂之朝陽。身命二宮逢之，主貴。更豐榮為官，當居顯秩之職。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_4530977a",
    "name": "官福互垣",
    "variants": [
      {
        "source": "《格局2》",
        "description": "官祿宮，福德宮主星，或官祿宮主星。入福德宮，福德宮主星。入官祿宮，二星相互，謂之官祿互垣。要本主生旺，則主大貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "官祿宮，福德宮主星，或官祿宮主星。入福德宮，福德宮主星。入官祿宮，二星相互，謂之官祿互垣。要本主生旺，則主大貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "官祿宮，福德宮主星，或官祿宮主星。入福德宮，福德宮主星。入官祿宮，二星相互，謂之官祿互垣。要本主生旺，則主大貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_6f932e9d",
    "name": "官福夹拱",
    "variants": [
      {
        "source": "《格局2》",
        "description": "官福二星與命主身主二主星相夾拱者，主人有貴。如子命人官福二星，在亥，在丑為夾拱也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "官福二星與命主身主二主星相夾拱者，主人有貴。如子命人官福二星，在亥，在丑為夾拱也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "官福二星與命主身主二主星相夾拱者，主人有貴。如子命人官福二星，在亥，在丑為夾拱也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_92f54ec4",
    "name": "福德引援",
    "variants": [
      {
        "source": "《格局2》",
        "description": "官福二主星或在身命二宮。前為引援，在身命二宮。後為擁從，主人大貴要。或在命主身主星前後，亦是不拘身命宮也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "官福二主星或在身命二宮。前為引援，在身命二宮。後為擁從，主人大貴要。或在命主身主星前後，亦是不拘身命宮也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "官福二主星或在身命二宮。前為引援，在身命二宮。後為擁從，主人大貴要。或在命主身主星前後，亦是不拘身命宮也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_25835c8f",
    "name": "身命坐贵",
    "variants": [
      {
        "source": "《格局2》",
        "description": "身命主星或身命宮在貴人之地，謂之身命坐貴。如甲戊庚牛羊丑未，即貴人之地，或立命安身在丑未者，主大富貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "身命主星或身命宮在貴人之地，謂之身命坐貴。如甲戊庚牛羊丑未，即貴人之地，或立命安身在丑未者，主大富貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "身命主星或身命宮在貴人之地，謂之身命坐貴。如甲戊庚牛羊丑未，即貴人之地，或立命安身在丑未者，主大富貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_68c76b99",
    "name": "文魁拱命",
    "variants": [
      {
        "source": "《格局2》",
        "description": "文魁二星者，主文章科甲也。在三方拱命，主人登上第也。如甲生人，文在羅 喉 ，魁在太陰，或子上安命，文魁在辰申是也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "嗣"
      },
      {
        "source": "《格局2》",
        "description": "文魁二星者，主文章科甲也。在三方拱命，主人登上第也。如甲生人，文在羅 喉 ，魁在太陰，或子上安命，文魁在辰申是也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "嗣",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "文魁二星者，主文章科甲也。在三方拱命，主人登上第也。如甲生人，文在羅 喉 ，魁在太陰，或子上安命，文魁在辰申是也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "嗣",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_70d62142",
    "name": "福禄夹身",
    "variants": [
      {
        "source": "《格局2》",
        "description": "福星者，天福。星祿乃祿神也。此二星主福祿。若人身宮遇之，左右而相夾者，主其人有大貴。如落空亡剋陷，則不為大貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "夭"
      },
      {
        "source": "《格局2》",
        "description": "福星者，天福。星祿乃祿神也。此二星主福祿。若人身宮遇之，左右而相夾者，主其人有大貴。如落空亡剋陷，則不為大貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "夭",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "福星者，天福。星祿乃祿神也。此二星主福祿。若人身宮遇之，左右而相夾者，主其人有大貴。如落空亡剋陷，則不為大貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "夭",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_25eaf434",
    "name": "煞前主后",
    "variants": [
      {
        "source": "《格局2》",
        "description": "主者，命主星也。煞者，剋我者。如亥命以木為主，以金為難。在戌，火為主，水為難。在子為前，在戌為後，故有前後之分也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "主者，命主星也。煞者，剋我者。如亥命以木為主，以金為難。在戌，火為主，水為難。在子為前，在戌為後，故有前後之分也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "富",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "主者，命主星也。煞者，剋我者。如亥命以木為主，以金為難。在戌，火為主，水為難。在子為前，在戌為後，故有前後之分也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "富",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_5a7a73be",
    "name": "身命互换",
    "variants": [
      {
        "source": "《格局2》",
        "description": "身為外臺，命為內臺，二星互換居垣者入命宮，主人富貴。如寅亥屬木，木為身命主，更得寅亥立命安身者，皆為得令。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "身為外臺，命為內臺，二星互換居垣者入命宮，主人富貴。如寅亥屬木，木為身命主，更得寅亥立命安身者，皆為得令。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "身為外臺，命為內臺，二星互換居垣者入命宮，主人富貴。如寅亥屬木，木為身命主，更得寅亥立命安身者，皆為得令。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_b50222c3",
    "name": "日月趋朝",
    "variants": [
      {
        "source": "《格局2》",
        "description": "日月為太陽太陰也。亥為帝闕之地，如日在子宮，月在丑宮，謂之日月趨朝。諸星在寅卯之位，隨而從之。亥命者，大貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "日月為太陽太陰也。亥為帝闕之地，如日在子宮，月在丑宮，謂之日月趨朝。諸星在寅卯之位，隨而從之。亥命者，大貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "日月為太陽太陰也。亥為帝闕之地，如日在子宮，月在丑宮，謂之日月趨朝。諸星在寅卯之位，隨而從之。亥命者，大貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_3dc00f52",
    "name": "背君朝主",
    "variants": [
      {
        "source": "《格局2》",
        "description": "午者，太陽所主之宮。未者，太陰所主之宮。人命宮逢之，皆主大貴。但忌木星作殃。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "午者，太陽所主之宮。未者，太陰所主之宮。人命宮逢之，皆主大貴。但忌木星作殃。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "午者，太陽所主之宮。未者，太陰所主之宮。人命宮逢之，皆主大貴。但忌木星作殃。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_51bc149d",
    "name": "出乾入巽",
    "variants": [
      {
        "source": "《格局2》",
        "description": "乾，亥宮也。巽巳宮也。計星在亥，羅星在巳，謂之出乾入巽。反此為乾坤定位，人命立乾巽二宮，遇此二星，皆主其貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "乾，亥宮也。巽巳宮也。計星在亥，羅星在巳，謂之出乾入巽。反此為乾坤定位，人命立乾巽二宮，遇此二星，皆主其貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "乾，亥宮也。巽巳宮也。計星在亥，羅星在巳，謂之出乾入巽。反此為乾坤定位，人命立乾巽二宮，遇此二星，皆主其貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_ce2ced84",
    "name": "戴天履地",
    "variants": [
      {
        "source": "《格局2》",
        "description": "以亥為天，丑為地，諸星皆在亥子丑寅之方是也。亥為天門，取天開於子，地闢於丑，人生於寅，安命於此，四宮名此格。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "嗣"
      },
      {
        "source": "《格局2》",
        "description": "以亥為天，丑為地，諸星皆在亥子丑寅之方是也。亥為天門，取天開於子，地闢於丑，人生於寅，安命於此，四宮名此格。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "嗣",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "以亥為天，丑為地，諸星皆在亥子丑寅之方是也。亥為天門，取天開於子，地闢於丑，人生於寅，安命於此，四宮名此格。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "嗣",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_d111fa22",
    "name": "廷尉辅阳",
    "variants": [
      {
        "source": "《格局2》",
        "description": "廷尉者，水星也。陽乃太陽。如同一宮，又謂之水護陽光。若同太陽在子宮行虛度，是謂廷尉輔陽子。命人遇之，大貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "嗣"
      },
      {
        "source": "《格局2》",
        "description": "廷尉者，水星也。陽乃太陽。如同一宮，又謂之水護陽光。若同太陽在子宮行虛度，是謂廷尉輔陽子。命人遇之，大貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "嗣",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "廷尉者，水星也。陽乃太陽。如同一宮，又謂之水護陽光。若同太陽在子宮行虛度，是謂廷尉輔陽子。命人遇之，大貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "嗣",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_37c8230f",
    "name": "五曜连珠",
    "variants": [
      {
        "source": "《格局2》",
        "description": "五曜者，金木水火土也。如土丑，火卯，木寅，金辰，水巳相連不間者，是也。此五星各得其所，是以為貴。只要身命逢之，為吉。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "五曜者，金木水火土也。如土丑，火卯，木寅，金辰，水巳相連不間者，是也。此五星各得其所，是以為貴。只要身命逢之，為吉。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "五曜者，金木水火土也。如土丑，火卯，木寅，金辰，水巳相連不間者，是也。此五星各得其所，是以為貴。只要身命逢之，為吉。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_4715a42e",
    "name": "七政入垣",
    "variants": [
      {
        "source": "《格局2》",
        "description": "七政者，金，木，水，火，土，日，月是也。如土子，計丑，木亥，氣寅，火卯，戌羅，金辰，酉水，申巳，日午，月未，各居本位，皆為入垣，是為貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "七政者，金，木，水，火，土，日，月是也。如土子，計丑，木亥，氣寅，火卯，戌羅，金辰，酉水，申巳，日午，月未，各居本位，皆為入垣，是為貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "七政者，金，木，水，火，土，日，月是也。如土子，計丑，木亥，氣寅，火卯，戌羅，金辰，酉水，申巳，日午，月未，各居本位，皆為入垣，是為貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_501aa826",
    "name": "用星对照",
    "variants": [
      {
        "source": "《格局2》",
        "description": "用星者，主星所生之星也。如木星為命主，木生火，火星為用星也。與命對照，能剋制難忌則大吉也。身命逢之，可以言吉。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "福"
      },
      {
        "source": "《格局2》",
        "description": "用星者，主星所生之星也。如木星為命主，木生火，火星為用星也。與命對照，能剋制難忌則大吉也。身命逢之，可以言吉。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "福",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "用星者，主星所生之星也。如木星為命主，木生火，火星為用星也。與命對照，能剋制難忌則大吉也。身命逢之，可以言吉。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "福",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_ec7e1486",
    "name": "四雄朝拱",
    "variants": [
      {
        "source": "《格局2》",
        "description": "火羅土計為四雄，在丑宮，謂之拱斗。在亥，謂之朝天。凡人命宮在亥在丑者，遇之則主大貴而無疑也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "火羅土計為四雄，在丑宮，謂之拱斗。在亥，謂之朝天。凡人命宮在亥在丑者，遇之則主大貴而無疑也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "火羅土計為四雄，在丑宮，謂之拱斗。在亥，謂之朝天。凡人命宮在亥在丑者，遇之則主大貴而無疑也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_3a7c3464",
    "name": "诸星得位",
    "variants": [
      {
        "source": "《格局2》",
        "description": "如日行奎宿之度，月行婁宿之度，羅行翼宿之度，計行軫宿之度，孛行柳宿之度，氣行斗宿之度，謂之：得位而無所雜也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "如日行奎宿之度，月行婁宿之度，羅行翼宿之度，計行軫宿之度，孛行柳宿之度，氣行斗宿之度，謂之：得位而無所雜也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "如日行奎宿之度，月行婁宿之度，羅行翼宿之度，計行軫宿之度，孛行柳宿之度，氣行斗宿之度，謂之：得位而無所雜也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_634534e3",
    "name": "诸星得经",
    "variants": [
      {
        "source": "《格局2》",
        "description": "諸星各居本宿之度，如木角，金亢，金牛，木獬，土女日馬，月鹿，火虎，水蚓之類，得其所經之宿，謂之得經而不失，皆為貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "諸星各居本宿之度，如木角，金亢，金牛，木獬，土女日馬，月鹿，火虎，水蚓之類，得其所經之宿，謂之得經而不失，皆為貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "諸星各居本宿之度，如木角，金亢，金牛，木獬，土女日馬，月鹿，火虎，水蚓之類，得其所經之宿，謂之得經而不失，皆為貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_6b8788df",
    "name": "主星朝君",
    "variants": [
      {
        "source": "《格局2》",
        "description": "主星，命主星也。君星者，太陽星也，為君，為父，為乾，為男，為陽，為剛。凡人命主星近而傍之，謂之朝君。皆為近貴之命也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "主星，命主星也。君星者，太陽星也，為君，為父，為乾，為男，為陽，為剛。凡人命主星近而傍之，謂之朝君。皆為近貴之命也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "主星，命主星也。君星者，太陽星也，為君，為父，為乾，為男，為陽，為剛。凡人命主星近而傍之，謂之朝君。皆為近貴之命也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_96d8f9d3",
    "name": "母依日月",
    "variants": [
      {
        "source": "《格局2》",
        "description": "母星者，生我之星也。如主星屬木，水為母星也。水能生木者，是也。若得近太陽太陰之傍，是謂：依日月之光而得富貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "母星者，生我之星也。如主星屬木，水為母星也。水能生木者，是也。若得近太陽太陰之傍，是謂：依日月之光而得富貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "母星者，生我之星也。如主星屬木，水為母星也。水能生木者，是也。若得近太陽太陰之傍，是謂：依日月之光而得富貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_6fbf07c9",
    "name": "令主得助",
    "variants": [
      {
        "source": "《格局2》",
        "description": "令主星者，領君之命而行令者是也。如生年為君為命，月建為臣為令是也。命主逢恩而得助，猶木而得水，為恩富且貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "令主星者，領君之命而行令者是也。如生年為君為命，月建為臣為令是也。命主逢恩而得助，猶木而得水，為恩富且貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "令主星者，領君之命而行令者是也。如生年為君為命，月建為臣為令是也。命主逢恩而得助，猶木而得水，為恩富且貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_c5c1d979",
    "name": "天元得地",
    "variants": [
      {
        "source": "《格局2》",
        "description": "天元者，天干之辰也。如甲乙天元屬木，居寅卯辰高強之宮，謂之：得地。餘皆倣此。如命主身，主亦在高強，是為此論。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "天元者，天干之辰也。如甲乙天元屬木，居寅卯辰高強之宮，謂之：得地。餘皆倣此。如命主身，主亦在高強，是為此論。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "天元者，天干之辰也。如甲乙天元屬木，居寅卯辰高強之宮，謂之：得地。餘皆倣此。如命主身，主亦在高強，是為此論。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_13b0f444",
    "name": "朱雀衔符",
    "variants": [
      {
        "source": "《格局2》",
        "description": "朱雀者，南方丙丁火也。司夏令之神，丙丁生於夏三月，與日月同宮，謂之朱雀銜符。身命主屬火，更會此局，主大富貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "朱雀者，南方丙丁火也。司夏令之神，丙丁生於夏三月，與日月同宮，謂之朱雀銜符。身命主屬火，更會此局，主大富貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "朱雀者，南方丙丁火也。司夏令之神，丙丁生於夏三月，與日月同宮，謂之朱雀銜符。身命主屬火，更會此局，主大富貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_9a6d048a",
    "name": "拱夹端门",
    "variants": [
      {
        "source": "《格局2》",
        "description": "端門者，午宮也。天子出入之門，故為尊極。若日月殿駕及身命二星三方，左右拱夾者，謂之拱夾。端門皆為貴人之命也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "嗣"
      },
      {
        "source": "《格局2》",
        "description": "端門者，午宮也。天子出入之門，故為尊極。若日月殿駕及身命二星三方，左右拱夾者，謂之拱夾。端門皆為貴人之命也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "嗣",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "端門者，午宮也。天子出入之門，故為尊極。若日月殿駕及身命二星三方，左右拱夾者，謂之拱夾。端門皆為貴人之命也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "嗣",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_3bd9768e",
    "name": "金木水日会毕",
    "variants": [
      {
        "source": "《格局2》",
        "description": "金星，木星，水星，與太陽星同至畢星度下，主人聰明而且富貴也。畢星在酉宮，有六度，命主酉宮合之者，主有此也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "金星，木星，水星，與太陽星同至畢星度下，主人聰明而且富貴也。畢星在酉宮，有六度，命主酉宮合之者，主有此也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "金星，木星，水星，與太陽星同至畢星度下，主人聰明而且富貴也。畢星在酉宮，有六度，命主酉宮合之者，主有此也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_d22a3990",
    "name": "五星并随日月",
    "variants": [
      {
        "source": "《格局2》",
        "description": "木火土金水，五星並與日月同一宮者，主大富貴也。或人命宮，身宮二主星亦得同之，富貴無疑，亦不被剋陷也，故吉。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "木火土金水，五星並與日月同一宮者，主大富貴也。或人命宮，身宮二主星亦得同之，富貴無疑，亦不被剋陷也，故吉。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "富",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "木火土金水，五星並與日月同一宮者，主大富貴也。或人命宮，身宮二主星亦得同之，富貴無疑，亦不被剋陷也，故吉。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "富",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_4b355835",
    "name": "火土昼逢",
    "variants": [
      {
        "source": "《格局2》",
        "description": "火土二星喜晝而不喜夜，喜明而不喜暗。明則顯，暗則隱。惟辰酉二宮甚利，更有辰酉二宮坐命者，謂之大貴大富之人也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "火土二星喜晝而不喜夜，喜明而不喜暗。明則顯，暗則隱。惟辰酉二宮甚利，更有辰酉二宮坐命者，謂之大貴大富之人也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "火土二星喜晝而不喜夜，喜明而不喜暗。明則顯，暗則隱。惟辰酉二宮甚利，更有辰酉二宮坐命者，謂之大貴大富之人也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_dc8a1580",
    "name": "拱夹帝座",
    "variants": [
      {
        "source": "《格局2》",
        "description": "帝座者，時支也。若貴人祿馬，殿駕日月，身命福德，田財處前後一合，拱而夾之，俱主富貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "帝座者，時支也。若貴人祿馬，殿駕日月，身命福德，田財處前後一合，拱而夾之，俱主富貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "帝座者，時支也。若貴人祿馬，殿駕日月，身命福德，田財處前後一合，拱而夾之，俱主富貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_14604490",
    "name": "日月互垣",
    "variants": [
      {
        "source": "《格局2》",
        "description": "垣者，紫微帝星居之日月，左右互之命宮。遇此者，主上貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "垣者，紫微帝星居之日月，左右互之命宮。遇此者，主上貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "垣者，紫微帝星居之日月，左右互之命宮。遇此者，主上貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_4b8f33c7",
    "name": "天地通关",
    "variants": [
      {
        "source": "《格局2》",
        "description": "通關者，以子通卯，丑通寅，寅關丑，卯關子，辰關亥，巳關戌，午關酉，未關申，申關未，酉關午，戌關巳，亥關辰，子卯相通，丑寅相通，辰亥相通之類。如立命在子宮，通關在卯，若卯宮有祿及殿駕貴人文昌，天廚天月，...",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "通關者，以子通卯，丑通寅，寅關丑，卯關子，辰關亥，巳關戌，午關酉，未關申，申關未，酉關午，戌關巳，亥關辰，子卯相通，丑寅相通，辰亥相通之類。如立命在子宮，通關在卯，若卯宮有祿及殿駕貴人文昌，天廚天月，...",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "富",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "通關者，以子通卯，丑通寅，寅關丑，卯關子，辰關亥，巳關戌，午關酉，未關申，申關未，酉關午，戌關巳，亥關辰，子卯相通，丑寅相通，辰亥相通之類。如立命在子宮，通關在卯，若卯宮有祿及殿駕貴人文昌，天廚天月，...",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "富",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_c3cafd3b",
    "name": "水孛扶印",
    "variants": [
      {
        "source": "《格局2》",
        "description": "水孛二星同宮，在未宮，謂之水孛同秦。秦地分野在未孛廟，在未立命，逢之，若帶印星，謂之水孛扶印。印乃生我恩星也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "水孛二星同宮，在未宮，謂之水孛同秦。秦地分野在未孛廟，在未立命，逢之，若帶印星，謂之水孛扶印。印乃生我恩星也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "水孛二星同宮，在未宮，謂之水孛同秦。秦地分野在未孛廟，在未立命，逢之，若帶印星，謂之水孛扶印。印乃生我恩星也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_9e57e646",
    "name": "水孛助禄",
    "variants": [
      {
        "source": "《格局2》",
        "description": "祿者，祿神也。人命有之，主有天祿而食之。如甲生人，木孛二星為祿神，木既為祿，喜水生之，謂之助祿。舉一則知其他。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "福"
      },
      {
        "source": "《格局2》",
        "description": "祿者，祿神也。人命有之，主有天祿而食之。如甲生人，木孛二星為祿神，木既為祿，喜水生之，謂之助祿。舉一則知其他。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "福",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "祿者，祿神也。人命有之，主有天祿而食之。如甲生人，木孛二星為祿神，木既為祿，喜水生之，謂之助祿。舉一則知其他。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "福",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_c6d5f844",
    "name": "福禄随官",
    "variants": [
      {
        "source": "《格局2》",
        "description": "福者，天福貴人也。如甲生人，甲愛金雞，乙愛猴酉，為福星是也。人命逢官星，更有福祿二星隨之，主富貴雙全而無忌也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "福者，天福貴人也。如甲生人，甲愛金雞，乙愛猴酉，為福星是也。人命逢官星，更有福祿二星隨之，主富貴雙全而無忌也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "福者，天福貴人也。如甲生人，甲愛金雞，乙愛猴酉，為福星是也。人命逢官星，更有福祿二星隨之，主富貴雙全而無忌也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_ea3d2177",
    "name": "金水辅阴",
    "variants": [
      {
        "source": "《格局2》",
        "description": "陰言太陰星也。喜居申酉戌亥之地，更得金水輔之，則吉也。辰酉二宮，金之樂地。申巳二宮，水之樂地。遇太陰而輔是也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "陰言太陰星也。喜居申酉戌亥之地，更得金水輔之，則吉也。辰酉二宮，金之樂地。申巳二宮，水之樂地。遇太陰而輔是也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "陰言太陰星也。喜居申酉戌亥之地，更得金水輔之，則吉也。辰酉二宮，金之樂地。申巳二宮，水之樂地。遇太陰而輔是也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_3ca57d5f",
    "name": "火金逢月",
    "variants": [
      {
        "source": "《格局2》",
        "description": "火金二星與太陰星宮又同度，謂之火金逢月。人命宮得太陰守命，又遇火金，此作貴推之也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "火金二星與太陰星宮又同度，謂之火金逢月。人命宮得太陰守命，又遇火金，此作貴推之也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "火金二星與太陰星宮又同度，謂之火金逢月。人命宮得太陰守命，又遇火金，此作貴推之也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_de2e3e84",
    "name": "金土富豪",
    "variants": [
      {
        "source": "《格局2》",
        "description": "金星若在財帛宮，土星在田宅宮，主人富豪。但人命主合之，皆為富貴之命也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "金星若在財帛宮，土星在田宅宮，主人富豪。但人命主合之，皆為富貴之命也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "金星若在財帛宮，土星在田宅宮，主人富豪。但人命主合之，皆為富貴之命也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_001fdbe8",
    "name": "身命逢官",
    "variants": [
      {
        "source": "《格局2》",
        "description": "身主，命主二星若臨官貴之宮，皆主大貴。若在本命宮或對宮守臨照拱，皆為貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "身主，命主二星若臨官貴之宮，皆主大貴。若在本命宮或對宮守臨照拱，皆為貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "身主，命主二星若臨官貴之宮，皆主大貴。若在本命宮或對宮守臨照拱，皆為貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_ee80cdd4",
    "name": "逢生坐实",
    "variants": [
      {
        "source": "《格局2》",
        "description": "子，寅，辰，午，申，戌六位屬陽，為之實地。丑，卯，巳，未，酉，亥六位屬陰，為之虛地。經曰：逢生坐實占高強，名利兩榮昌。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "嗣"
      },
      {
        "source": "《格局2》",
        "description": "子，寅，辰，午，申，戌六位屬陽，為之實地。丑，卯，巳，未，酉，亥六位屬陰，為之虛地。經曰：逢生坐實占高強，名利兩榮昌。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "嗣",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "子，寅，辰，午，申，戌六位屬陽，為之實地。丑，卯，巳，未，酉，亥六位屬陰，為之虛地。經曰：逢生坐實占高強，名利兩榮昌。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "嗣",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_8abcd786",
    "name": "官禄守籍",
    "variants": [
      {
        "source": "《格局2》",
        "description": "如子宮立命，歲殿登籍在子，更得官祿二星守之，是為此格。且官祿二星人人得而喜之，只要在高強無剋制者，方貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "如子宮立命，歲殿登籍在子，更得官祿二星守之，是為此格。且官祿二星人人得而喜之，只要在高強無剋制者，方貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "如子宮立命，歲殿登籍在子，更得官祿二星守之，是為此格。且官祿二星人人得而喜之，只要在高強無剋制者，方貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_493abbbc",
    "name": "火气官高",
    "variants": [
      {
        "source": "《格局2》",
        "description": "氣者，木氣也，逢火星，木又生之，是為得助。官星得之，豈不為貴乎。故謂之火氣官高。身命二主逢之，拱夾照臨，皆為清貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "氣者，木氣也，逢火星，木又生之，是為得助。官星得之，豈不為貴乎。故謂之火氣官高。身命二主逢之，拱夾照臨，皆為清貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "氣者，木氣也，逢火星，木又生之，是為得助。官星得之，豈不為貴乎。故謂之火氣官高。身命二主逢之，拱夾照臨，皆為清貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_98d7717b",
    "name": "月挂柳梢",
    "variants": [
      {
        "source": "《格局2》",
        "description": "月，太陰星也。如太陰行度在未宮躔柳度，謂之月掛柳梢是也。但人身命二主亦在未宮，或立命在未宮，方斷有此貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "月，太陰星也。如太陰行度在未宮躔柳度，謂之月掛柳梢是也。但人身命二主亦在未宮，或立命在未宮，方斷有此貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "月，太陰星也。如太陰行度在未宮躔柳度，謂之月掛柳梢是也。但人身命二主亦在未宮，或立命在未宮，方斷有此貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_df5db0d8",
    "name": "孛挂朱衣",
    "variants": [
      {
        "source": "《格局2》",
        "description": "孛者，月之餘氣也。此星十二宮皆為禍，惟至亥宮，過天門，不敢為禍。謂之十二宮中皆脫裸，卻來亥上著朱衣。亥命，主貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "孛者，月之餘氣也。此星十二宮皆為禍，惟至亥宮，過天門，不敢為禍。謂之十二宮中皆脫裸，卻來亥上著朱衣。亥命，主貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "孛者，月之餘氣也。此星十二宮皆為禍，惟至亥宮，過天門，不敢為禍。謂之十二宮中皆脫裸，卻來亥上著朱衣。亥命，主貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_4a7d55cc",
    "name": "命坐玉堂",
    "variants": [
      {
        "source": "《格局2》",
        "description": "玉堂，二星名，左為玉，右為堂。如甲生人以丑未為玉堂，且立命在丑未二宮，謂之命坐玉堂。主人極貴，近君王之命也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "玉堂，二星名，左為玉，右為堂。如甲生人以丑未為玉堂，且立命在丑未二宮，謂之命坐玉堂。主人極貴，近君王之命也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "玉堂，二星名，左為玉，右為堂。如甲生人以丑未為玉堂，且立命在丑未二宮，謂之命坐玉堂。主人極貴，近君王之命也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_1b317504",
    "name": "文昌照命",
    "variants": [
      {
        "source": "《格局2》",
        "description": "文昌者，南斗之辰。人命逢之，主有才學過人。如甲生人，文昌在巳亥宮，立命者巳亥相照，謂之照命。餘皆並此而取貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "文昌者，南斗之辰。人命逢之，主有才學過人。如甲生人，文昌在巳亥宮，立命者巳亥相照，謂之照命。餘皆並此而取貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "文昌者，南斗之辰。人命逢之，主有才學過人。如甲生人，文昌在巳亥宮，立命者巳亥相照，謂之照命。餘皆並此而取貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_d47d976c",
    "name": "三台辅命",
    "variants": [
      {
        "source": "《格局2》",
        "description": "三台者，帝垣之星也。如子生人，辰為三台，戌為帝座，凡人立命在辰戌二宮者，拱臨守照，皆為吉貴也。此吉不忌剋陷。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "三台者，帝垣之星也。如子生人，辰為三台，戌為帝座，凡人立命在辰戌二宮者，拱臨守照，皆為吉貴也。此吉不忌剋陷。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "三台者，帝垣之星也。如子生人，辰為三台，戌為帝座，凡人立命在辰戌二宮者，拱臨守照，皆為吉貴也。此吉不忌剋陷。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_e8667bef",
    "name": "禄勋坐命",
    "variants": [
      {
        "source": "《格局2》",
        "description": "祿勳者，如甲生人，以火為祿，寅為勳。如寅宮立命，又見火星入命者，謂之祿勳坐命。主食天子賜爵，其餘依流年推之，取貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "祿勳者，如甲生人，以火為祿，寅為勳。如寅宮立命，又見火星入命者，謂之祿勳坐命。主食天子賜爵，其餘依流年推之，取貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "祿勳者，如甲生人，以火為祿，寅為勳。如寅宮立命，又見火星入命者，謂之祿勳坐命。主食天子賜爵，其餘依流年推之，取貴。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "geju2_586d637f",
    "name": "日帝居阳",
    "variants": [
      {
        "source": "《格局2》",
        "description": "日者，太陽君主星也。正居，午宮諸星不敢犯之，惟忌木氣掩之而已。人命立午宮者逢之，主大貴。只恐主孤而無子也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "日者，太陽君主星也。正居，午宮諸星不敢犯之，惟忌木氣掩之而已。人命立午宮者逢之，主大貴。只恐主孤而無子也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "日者，太陽君主星也。正居，午宮諸星不敢犯之，惟忌木氣掩之而已。人命立午宮者逢之，主大貴。只恐主孤而無子也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  }
]');
INSERT INTO ge_ju_content_document ("file_name", "payload_json") VALUES ('ge_ju_zong_lun_content.json', '[
  {
    "id": "geju_001_ri_yue_he_ge",
    "name": "日月合格",
    "variants": [
      {
        "source": "《格局》",
        "description": "吉相的星格",
        "books": "果老星宗",
        "className": "七政四余格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "geju_002_ri_yue_ji_ge",
    "name": "日月忌格",
    "variants": [
      {
        "source": "《格局》",
        "description": "凶相的星格",
        "books": "果老星宗",
        "className": "七政四余格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "geju_003_wu_xing_he_ge",
    "name": "五星合格",
    "variants": [
      {
        "source": "《格局》",
        "description": "入垣与升殿",
        "books": "果老星宗",
        "className": "七政四余格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "geju_004_wu_xing_ji_ge",
    "name": "五星忌格",
    "variants": [
      {
        "source": "《格局》",
        "description": "星曜相克",
        "books": "果老星宗",
        "className": "七政四余格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "geju_005_si_yu_he_ge",
    "name": "四余合格",
    "variants": [
      {
        "source": "《格局》",
        "description": "四余影响命运吉凶",
        "books": "果老星宗",
        "className": "七政四余格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "geju_006_zheng_yu_he_ge",
    "name": "政余合格",
    "variants": [
      {
        "source": "《格局》",
        "description": "七政四余相合的格局",
        "books": "果老星宗",
        "className": "七政四余格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "geju_007_zheng_yu_ji_ge",
    "name": "政余忌格",
    "variants": [
      {
        "source": "《格局》",
        "description": "几种忌讳的凶格",
        "books": "果老星宗",
        "className": "七政四余格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "geju_008_zhu_xing_ci_ge",
    "name": "诸星次格",
    "variants": [
      {
        "source": "《格局》",
        "description": "仅次于合格的星格",
        "books": "果老星宗",
        "className": "七政四余格局",
        "jiXiong": "平",
        "geJuType": "贵"
      }
    ]
  }
]');
INSERT INTO ge_ju_content_document ("file_name", "payload_json") VALUES ('gui_ge_ge_ju_content.json', '[
  {
    "id": "guige_001_gui_ge",
    "name": "贵格",
    "variants": [
      {
        "source": "《贵格》",
        "description": "官星格局推断",
        "books": "果老星宗",
        "className": "贵格格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "guige_002_jian_ge",
    "name": "贱格",
    "variants": [
      {
        "source": "《贵格》",
        "description": "主灾祸的星格",
        "books": "果老星宗",
        "className": "贵格格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "guige_003_pin_ge",
    "name": "贫格",
    "variants": [
      {
        "source": "《贵格》",
        "description": "主失财凶灾的星格",
        "books": "果老星宗",
        "className": "贵格格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "guige_004_ji_ge",
    "name": "疾格",
    "variants": [
      {
        "source": "《贵格》",
        "description": "主疾病凶险的星格",
        "books": "果老星宗",
        "className": "贵格格局",
        "jiXiong": "凶",
        "geJuType": "疾"
      }
    ]
  }
]');
INSERT INTO ge_ju_content_document ("file_name", "payload_json") VALUES ('he_ge_ge_ju_content.json', '[
  {
    "id": "hege_001_shen_ming_he_ge",
    "name": "身命合格",
    "variants": [
      {
        "source": "《合格》",
        "description": "非富即贵",
        "books": "果老星宗",
        "className": "合格格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "hege_002_ming_zhu_he_ge",
    "name": "命主合格",
    "variants": [
      {
        "source": "《合格》",
        "description": "16种吉格",
        "books": "果老星宗",
        "className": "合格格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "hege_003_tian_zhu_he_ge",
    "name": "田主合格",
    "variants": [
      {
        "source": "《合格》",
        "description": "田宅丰盛",
        "books": "果老星宗",
        "className": "合格格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "hege_004_cai_xing_he_ge",
    "name": "财星合格",
    "variants": [
      {
        "source": "《合格》",
        "description": "事业顺利",
        "books": "果老星宗",
        "className": "合格格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "hege_005_lu_zhu_he_ge",
    "name": "禄主合格",
    "variants": [
      {
        "source": "《合格》",
        "description": "富贵有财",
        "books": "果老星宗",
        "className": "合格格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "hege_006_fu_xing_he_ge",
    "name": "福星合格",
    "variants": [
      {
        "source": "《合格》",
        "description": "福气丰隆",
        "books": "果老星宗",
        "className": "合格格局",
        "jiXiong": "吉",
        "geJuType": "福"
      }
    ]
  },
  {
    "id": "hege_007_qi_xing_he_ge",
    "name": "妻星合格",
    "variants": [
      {
        "source": "《合格》",
        "description": "夫妻和美",
        "books": "果老星宗",
        "className": "合格格局",
        "jiXiong": "吉",
        "geJuType": "婚"
      }
    ]
  },
  {
    "id": "hege_008_si_xing_he_ge",
    "name": "嗣星合格",
    "variants": [
      {
        "source": "《合格》",
        "description": "儿孙兴旺",
        "books": "果老星宗",
        "className": "合格格局",
        "jiXiong": "吉",
        "geJuType": "嗣"
      }
    ]
  },
  {
    "id": "jige_009_shen_xing_ji_ge",
    "name": "身星忌格",
    "variants": [
      {
        "source": "《合格》",
        "description": "11种凶格",
        "books": "果老星宗",
        "className": "忌格格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "jige_010_ming_zhu_ji_ge",
    "name": "命主忌格",
    "variants": [
      {
        "source": "《合格》",
        "description": "命运多舛",
        "books": "果老星宗",
        "className": "忌格格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "jige_011_tian_zhu_ji_ge",
    "name": "田主忌格",
    "variants": [
      {
        "source": "《合格》",
        "description": "田宅衰败",
        "books": "果老星宗",
        "className": "忌格格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "jige_012_cai_xing_ji_ge",
    "name": "财星忌格",
    "variants": [
      {
        "source": "《合格》",
        "description": "损失钱财",
        "books": "果老星宗",
        "className": "忌格格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "jige_013_lu_zhu_ji_ge",
    "name": "禄主忌格",
    "variants": [
      {
        "source": "《合格》",
        "description": "官运不顺",
        "books": "果老星宗",
        "className": "忌格格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "jige_014_fu_zhu_ji_ge",
    "name": "福主忌格",
    "variants": [
      {
        "source": "《合格》",
        "description": "难享福气",
        "books": "果老星宗",
        "className": "忌格格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "jige_015_qi_xing_ji_ge",
    "name": "妻星忌格",
    "variants": [
      {
        "source": "《合格》",
        "description": "配偶不利",
        "books": "果老星宗",
        "className": "忌格格局",
        "jiXiong": "凶",
        "geJuType": "婚"
      }
    ]
  },
  {
    "id": "jige_016_zi_xing_ji_ge",
    "name": "子星忌格",
    "variants": [
      {
        "source": "《合格》",
        "description": "不利儿孙",
        "books": "果老星宗",
        "className": "忌格格局",
        "jiXiong": "凶",
        "geJuType": "嗣"
      }
    ]
  },
  {
    "id": "jige_017_zhu_xing_hu_ge",
    "name": "诸星互格",
    "variants": [
      {
        "source": "《合格》",
        "description": "星曜互垣",
        "books": "果老星宗",
        "className": "忌格格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  }
]');
INSERT INTO ge_ju_content_document ("file_name", "payload_json") VALUES ('huo_xing_ge_ju_content.json', '[
  {
    "id": "huo_001_zhu_yi_chi_ri",
    "name": "朱衣驰日",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "朱衣驰日，朝廷宣使奏差。火会日，与马元同行。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_002_bei_hai_tiao_deng",
    "name": "北海挑灯",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "北海挑灯，位居宰辅。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_003_bei_yuan_hui_chun",
    "name": "北苑回春",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "北苑回春，状元及第。北子位苑，指火也，冬火为用，星居子照，值命身与太阳。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_004_chang_hong_guan_ri",
    "name": "长虹贯日",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "长虹贯日，早冠判臣。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_005_zhou_huo_ye_tu",
    "name": "昼火夜土",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "火土分昼夜之忌。昼生忌火罗，夜生忌土计。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_006_huo_luo_xia_hui",
    "name": "火罗夏会",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "火罗夏会，多招哭泣之灾。夏生遇火罗，有刑伤哭泣之灾。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_007_jin_huo_yi_yuan",
    "name": "金火易垣",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "火金不可易垣。火不可入金垣，金不可入火垣，疑其相攻相克也。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_008_zhou_huo_fan_ri",
    "name": "昼火犯日",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "火化暗，昼生忌与太阳同躔。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_009_huo_tu_ba_sha",
    "name": "火土八杀",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "残疾者，火罗土杂于难宫。火罗土聚于八杀宫，必然残疾也。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_010_huo_luo_ru_ji",
    "name": "火罗入疾",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "火罗不宜入疾厄，如此者，男有暴病，女多产难，若非自灾必伤骨肉。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_011_huo_ju_song_lu",
    "name": "火居宋鲁",
    "variants": [
      {
        "source": "《果老星宗·躔度赋》",
        "description": "火居宋鲁，纵日诞而禄自盈余（火在卯戌）。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "huo_012_huo_tu_de_niu",
    "name": "火土得牛",
    "variants": [
      {
        "source": "《果老星宗·躔度赋》",
        "description": "火土会于牛宫，不独龟龄而已（火土会牛在丑）。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "寿"
      }
    ]
  },
  {
    "id": "huo_013_zhu_que_fan_shen",
    "name": "朱雀犯身",
    "variants": [
      {
        "source": "《果老星宗·躔度赋》",
        "description": "多招横祸，火罗犯于身命之中（火罗朱雀星也）。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_014_huo_zai_ba_gong",
    "name": "火在八宫",
    "variants": [
      {
        "source": "《果老星宗·躔度赋》",
        "description": "求医何数？火在八宫（火主血光）。日日有灾，盖谓八宫见火（疾厄宫，怕见火罗）。疾厄遇火孛，女多产死之因。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_015_shui_huo_xiang_zhan",
    "name": "水火相战",
    "variants": [
      {
        "source": "《果老星宗·躔度赋》",
        "description": "一身迍蹇，火星怕与水星交战。水火同临寿必损。[水火守身命]",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "夭"
      }
    ]
  },
  {
    "id": "huo_016_huo_lin_yan_di",
    "name": "火临燕地",
    "variants": [
      {
        "source": "《果老星宗·躔度赋》",
        "description": "性逸素无拘，盖喜火临燕地（火星在寅宫）。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "huo_017_huo_song_wei_rong",
    "name": "火宋为荣",
    "variants": [
      {
        "source": "《果老星宗·躔度赋》",
        "description": "火躔宋以为荣（火居卯位）。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_018_huo_feng_tai_yi",
    "name": "火逢太乙",
    "variants": [
      {
        "source": "《果老星宗·躔度赋》",
        "description": "火躔宋以为荣（火居卯位），见太乙则早归泉路（孛必克火）。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "夭"
      }
    ]
  },
  {
    "id": "huo_019_huo_wu_feng_mu",
    "name": "火五逢木",
    "variants": [
      {
        "source": "《果老星宗·躔度赋》",
        "description": "火临五位见木，方显儿孙（火木相生临儿）。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "huo_020_ying_huo_zai_mao",
    "name": "荧惑在卯",
    "variants": [
      {
        "source": "《果老星宗·历象赋》",
        "description": "南方荧惑在卯宫，贵饶衣食（火星居卯）。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "huo_021_huo_bei_shen_you",
    "name": "火孛申酉",
    "variants": [
      {
        "source": "《果老星宗·历象赋》",
        "description": "中年命蹇，火孛而守申酉（火孛同申或酉）。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_022_huo_ru_jin_xiang",
    "name": "火入金乡",
    "variants": [
      {
        "source": "《果老星宗·历象赋》",
        "description": "火入金乡，此命早抛兄弟（火怕辰酉位）。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_023_jin_huo_tong_cai",
    "name": "金火同财",
    "variants": [
      {
        "source": "《果老星宗·历象赋》",
        "description": "少失资财，金火同居财位（金火忌守财宫）。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "huo_024_shui_huo_ju_tian",
    "name": "水火居田",
    "variants": [
      {
        "source": "《果老星宗·历象赋》",
        "description": "水火并居田宅，破家荡产（水火忌居田宅）。祖财困辱田宅，火被水来侵。[水火会田宅]",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "huo_025_huo_ming_chong_kui",
    "name": "火明冲魁",
    "variants": [
      {
        "source": "《果老星宗·元通赋》",
        "description": "卯为太冲，戌为河魁，火星临此二宫，兵将之权。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_026_huo_yao_lin_yang",
    "name": "火曜临阳",
    "variants": [
      {
        "source": "《果老星宗·通微赋》",
        "description": "一天黯淡，只缘火曜临阳。[火日同宫]",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_027_huo_jin_zi_wei",
    "name": "火金子位",
    "variants": [
      {
        "source": "《果老星宗·通微赋》",
        "description": "火金子位，如此者非贫即夭。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "huo_028_huo_luo_chan_ming",
    "name": "火罗躔命",
    "variants": [
      {
        "source": "《果老星宗·通微赋》",
        "description": "性躁，猖狂，火罗同躔命度。[火罗刚暴星也]",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_029_huo_xing_nan_lv",
    "name": "火行南律",
    "variants": [
      {
        "source": "《果老星宗·通微赋》",
        "description": "性敏巧明，火行南律。[火星得局也]",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "huo_030_huo_bei_tong_ming",
    "name": "火孛通明",
    "variants": [
      {
        "source": "《果老星宗·通微赋》",
        "description": "火孛通明必外迁。[火孛在命]",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "平",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_031_huo_yao_dang_quan",
    "name": "火曜当权",
    "variants": [
      {
        "source": "《果老星宗·玉衡经》",
        "description": "火若当权，恣行酷毒。[火性烈燥急]",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_032_huo_luo_lin_fu",
    "name": "火罗临父",
    "variants": [
      {
        "source": "《果老星宗·玉衡经》",
        "description": "火罗若临父母，幼失慈亲。[火罗炎威酷毒]",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_033_huo_bei_lin_kun",
    "name": "火孛临坤",
    "variants": [
      {
        "source": "《果老星宗·玉衡经》",
        "description": "火孛临坤，未免腰背屈曲。[火孛临申]",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_034_jin_huo_zhan_chen_you",
    "name": "金火战辰酉",
    "variants": [
      {
        "source": "《果老星宗·玉衡经》",
        "description": "金火战于辰酉，肺心咳嗽。[火主心金主肺]",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_035_huo_xing_tui_liu",
    "name": "火星退留",
    "variants": [
      {
        "source": "《果老星宗·玉衡经》",
        "description": "火若退而迟留，难堪酒糟。[必患酒糟]",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_036_huo_yue_zheng_guang",
    "name": "火月争光",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "火逢月朗而无权。望夜火月争光。月圆火焰，奈争斗而无成。上弦后，下弦前，夜月忌火罗。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_037_jin_de_huo_ming",
    "name": "金得火明",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "金得火明而焕发。[秋金见火为奇]",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_038_xia_huo_jian_yue",
    "name": "夏火见月",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "夏火不妨见月。[夏火本炎，遇太阴以解酷热，火得令能助月]",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "huo_039_xia_huo_feng_qi",
    "name": "夏火逢气",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "盛夏之火何，须木气生扶。[木至六月则绝而不旺，见火反干]",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_040_dong_tu_hui_huo",
    "name": "冻土会火",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "冰冻之土会火，始能发用。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_041_huo_yue_tong_xiao",
    "name": "火月同宵",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "残晦之月，见火增辉。[初八以前，二十以后，三方对照得火相助]",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贤"
      },
      {
        "source": "《格局2》",
        "description": "火者，火星也。月乃太陰星也。夜生人，立命在子丑二宮者，遇此二星，在命方是。若乃日生人，在子丑立命，亦不為吉也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "福"
      },
      {
        "source": "《格局2》",
        "description": "火者，火星也。月乃太陰星也。夜生人，立命在子丑二宮者，遇此二星，在命方是。若乃日生人，在子丑立命，亦不為吉也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "福",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "火者，火星也。月乃太陰星也。夜生人，立命在子丑二宮者，遇此二星，在命方是。若乃日生人，在子丑立命，亦不為吉也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "福",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "huo_042_ying_huo_ju_yuan",
    "name": "荧惑居垣",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "荧惑居垣。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_043_huo_xing_sheng_dian",
    "name": "火星升殿",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "火星升殿：火躔尾室觜翼四宿。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_044_mu_huo_wen_ming",
    "name": "木火文明",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "木火文明：冬春月生，无分昼夜为妙。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_045_huo_tu_gao_qiang",
    "name": "火土高强",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "火土高强：夏生火炎土燥，余月昼夜皆吉。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_046_zhu_que_yu_fu",
    "name": "朱雀御符",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "朱雀御符：巳午月生，火日同宫。火为朱雀星。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_047_huo_ju_shui_di",
    "name": "火居水地",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "火居水地：火在巳申二宫。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_048_huo_dao_jin_xiang",
    "name": "火到金乡",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "火到金乡：火居辰酉二宫。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_049_shui_huo_tong_bu",
    "name": "水火同步",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "水火同步：水火相克。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_050_huo_jin_jiao_zhan",
    "name": "火金交战",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "火金交战：火金相克。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_051_huo_qi_zhi_quan",
    "name": "火气职权",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "火气职权：火为用神，入庙旺宫合格。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_052_huo_jin_shi_yue",
    "name": "火金侍月",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "火金侍月：火金为用神，临垣庙，夜生者妙。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_053_chu_gan_ru_kun",
    "name": "出干入坤",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "出干入坤。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "未知",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_054_shui_huo_ji_ji",
    "name": "水火既济",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "水火既济：水子火午，命坐子午。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《果老星宗·灵台星格》",
        "description": "水火既济：水先入宫，火后入宫，同居一位以照命者是也。盖水性润下，火性炎上，上下相得，而不相违，切嫌一二凶星入侵，则反生祸。更若水星为宫主，为命主，为禄主，则福最厚，富贵双全之命也。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "huo_055_feng_lei_gu_wu",
    "name": "风雷鼓舞",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "风雷鼓舞：水巳火卯，命辰合格。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_056_huo_luo_fan_ri",
    "name": "火罗犯日",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "火罗犯日：昼日怕火罗同宫，掌刃雄尤忌。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_057_huo_bei_gong_zhan",
    "name": "火孛共战",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "火孛共战：火为用神则损矣。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_058_feng_lei_xiang_bo",
    "name": "风雷相薄",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "风雷相薄。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "未知",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_059_shui_huo_xiang_she",
    "name": "水火相射",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "水火相射：水午火子，或木卯戌，或火巳申。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_060_yu_hou_xiao_yue",
    "name": "玉猴啸月",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "玉猴啸月：火觜月毕，坐命火月度，夜生贵。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_061_hu_xiao_yuan_yin",
    "name": "虎啸猿吟",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "虎啸猿吟：木尾火觜，亥命大贵，巳命大富。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_062_huo_bei_qing_tian",
    "name": "火孛擎天",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "火孛擎天：火室孛壁，水轸火翼，皆主富贵。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "huo_063_ba_sha_chao_tian",
    "name": "八杀朝天",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "八千朝天：如戌命火，又未命土，或辰命金。此三星独占天门，得时为上。惟金火尤重，夜生显贵之人也。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_064_zhu_que_dang_quan",
    "name": "朱雀当权",
    "variants": [
      {
        "source": "《果老星宗·灵台星格》",
        "description": "夏生人见火星在巳午安命，乃朱雀当权。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_065_li_kan_jiao_hui",
    "name": "离坎交会",
    "variants": [
      {
        "source": "《果老星宗·灵台星格》",
        "description": "离坎交会：水星禀北方坎宫之气，火星禀南方离宫之气，夜生人火星在命中，水星正照，乃合此格，此格最主为人气概精神，法能剸裁繁剧，禄位优厚。若水火二星同守命宫，则是煎熬星矣，反主灾祸。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_066_zi_xing_fu_zheng",
    "name": "子行父政",
    "variants": [
      {
        "source": "《果老星宗·灵台星格》",
        "description": "子行父政：太阳乃火之精，太阴为水之副，故日为父，火为子。且太阳之庙在午，太阳居之当然也，今则太阳却居子，火星却在午，又于午上安命，是父之政子乃行也；此格主人艰难于始，逸乐于终，以其干蛊之早也。谓且父之创制，子当继之，父之德政，予当行之。此谓人有贤子而继父志，不亦善乎！另有子承父位：午宫星度立命，火星入命，以占父位，太阳飞入卯宫房度，卯乃子位，父居之，必主父子不和，兄弟失伦，行限见木，非犯刑而死，定主恶疾而亡。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_067_huo_shui_wei_ji",
    "name": "火水未济",
    "variants": [
      {
        "source": "《果老星宗·灵台星格》",
        "description": "火水未济：火先入宫，水后入宫，同居一宫，以照命者是也。盖火自上炎，水自下注，相违而不相向，安得能和而能济。曰：未济男之穷也。格中带此者，主贫贱。此系忌格。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "huo_069_shui_huo_xiang_xing",
    "name": "水火相刑",
    "variants": [
      {
        "source": "《果老星宗·布局补遗》",
        "description": "水火相刑：歌曰：命立卯宫在房度，生于夏令主炎库。行限午宫见水星，水入午宫宜柳土。反凶为吉福无边，金玉争光敌国富。若教脱水鬼门关，五十三四归泉路。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_070_nv_huo_wei_fu",
    "name": "女火为夫",
    "variants": [
      {
        "source": "《果老星宗·金箱歌》",
        "description": "女火为夫：妇人只要看火荧，火是夫星为正宗。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "平",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_071_huo_luo_nong_xue",
    "name": "火罗脓血",
    "variants": [
      {
        "source": "《果老星宗·金箱歌》",
        "description": "火罗脓血：火罗为性多毒恶，脓血夭亡灾不薄。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "夭"
      }
    ]
  },
  {
    "id": "huo_072_huo_ming_tian_shi",
    "name": "火明天市",
    "variants": [
      {
        "source": "《果老星宗·元妙经解》",
        "description": "火星卯宫，贵格。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_073_huo_hao_wen_chang",
    "name": "火号文昌",
    "variants": [
      {
        "source": "《果老星宗·元妙经解》",
        "description": "火在未宫，贵格。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_074_huo_gui_kun_di",
    "name": "火归坤地",
    "variants": [
      {
        "source": "《果老星宗·元妙经解》",
        "description": "火申宫，贵格。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_075_huo_ju_lou_su",
    "name": "火居娄宿",
    "variants": [
      {
        "source": "《果老星宗·元妙经解》",
        "description": "火白羊娄宿。贵格。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_076_jin_huo_tong_zhou",
    "name": "金火同周",
    "variants": [
      {
        "source": "《果老星宗·元妙经解》",
        "description": "金火午宫，贱格。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_077_yi_yang_lai_fu",
    "name": "一阳来复",
    "variants": [
      {
        "source": "《果老星宗·谈星奥论》",
        "description": "夜生人独火居子，为一阳来复，女土安命尤奇。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_078_huo_luo_feng_sha",
    "name": "火罗逢煞",
    "variants": [
      {
        "source": "《果老星宗·谈星奥论》",
        "description": "火罗怕头，更带刃雄，廉锋，耗符等煞，金命限人愈甚。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_079_jue_huo_da_ming",
    "name": "爝火大明",
    "variants": [
      {
        "source": "《果老星宗·玄玄妙论》",
        "description": "火星落空谓之爝火大明，乃是离中火虚，反主发达，夜生尤妙，盖火遇夜则明故也。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_080_huo_de_mu_ji",
    "name": "火得木济",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "春令之火，正二月之时寒气未消，最喜火罗木气互度，见太阴，夜生光彩，文武富贵。火本酷烈，逢木慈仁，以善化恶，以刚制柔，刚柔相济，贵而能决，威福权衡。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_081_tao_hua_gun_lang",
    "name": "桃花滚浪",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "春末夏初之际，火入水宫，水入火地，叫做桃花滚浪，水暖花红，名利双清。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_082_zi_lai_jiu_mu",
    "name": "子来救母",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "春末夏初之际，火入水宫，水入火地，称为桃花滚浪，水暖花红，名利双清。但火不宜与水孛同行，谓之受克。逢土有救，能破水孛之气，名曰：子来救母，禄自丰盈。见金为党鬼，独火之气脉虚也。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "huo_083_wan_wu_cui_ku",
    "name": "万物摧枯",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "夏末秋初之火，斯时秋阳杲杲，借水以济其盛，乃刚柔变化，最不宜与木气同照，火罗朝拱，太阳无水济润，迎照度限，万物破坏。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_084_yi_bei_ji_huo",
    "name": "一孛济火",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "夏末秋初之火，斯时秋阳杲杲，借水以济其盛，乃刚柔变化，最不宜与木气同照。火罗朝拱，太阳无水济润，迎照度限，万物破坏。经云：火焰而无水淘溶，纵发而早年夭折。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_085_gao_miao_de_yu",
    "name": "稿苗得雨",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "夏末秋初之火，斯时秋阳杲杲，借水以济其盛，乃刚柔变化，最不宜与木气同照。火罗朝拱，太阳无水济润，迎照度限，万物破坏枯，一陷千丈，如有一水贯日，一孛济火，为之淋漓普济苍生，万物苏茂精神宛转富贵。经云：火焰而无水淘溶，纵发而早年夭折。又有先见火日，后见水孛，此谓之久旱干焦，稿苗得雨，先主艰难而后快活。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_086_jiu_yu_feng_qing",
    "name": "久雨逢晴",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "夏末秋初之火，斯时秋阳杲杲，借水以济其盛，乃刚柔变化，最不宜与木气同照。火罗朝拱，太阳无水济润，迎照度限，万物破坏枯，一陷千丈，如有一水贯日，一孛济火，为之淋漓普济苍生，万物苏茂精神宛转富贵。经云：火焰而无水淘溶，纵发而早年夭折。又有先见水，后见火日，谓之久雨逢晴，先主快活而后艰辛。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "平",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_087_mu_qi_fu_huo",
    "name": "木气扶火",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "冬令之火，斯时黑帝司权，水德用事而火失时，最喜木气相扶。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_088_ye_huo_guan_ri",
    "name": "夜火贯日",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "冬令之火，斯时黑帝司权，水德用事而火失时，若夜火贯日，纳入禄印爵贵佐之，反能富贵名扬天下之人也。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "huo_089_huo_qi_mai_xu",
    "name": "火气脉虚",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "冬令之火，斯时黑帝司权，水德用事而火失时，其火最忌水孛土计罗喉相互作用，火之气脉虚矣。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "huo_090_jing_shen_yun_zhuan",
    "name": "精神运转",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "冬令之火，斯时黑帝司权，水德用事而火失时，其火最忌水孛土计罗喉相互作用，火之气脉虚矣。如有一木飞来泄水之气，助火出色，所谓水生木，木生火，命脉健矣。此乃精神转运，合为贵论。",
        "books": "果老星宗",
        "className": "火星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  }
]');
INSERT INTO ge_ju_content_document ("file_name", "payload_json") VALUES ('jin_xing_ge_ju_content.json', '[
  {
    "id": "jin_001_jun_chen_qing_hui",
    "name": "君臣庆会",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "君臣庆会，钟鸣鼎食之家。金水为官福恩令命元，朝辅太阳者是。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_002_shan_xiao_cheng_bao",
    "name": "山啸呈宝",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "土金同落空亡。山啸呈宝，殿前作赋声摩空。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_003_shi_li_jian_feng",
    "name": "石砺剑锋",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "石砺剑锋，塞上封侯建功节。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_004_zhu_cang_yuan_hai",
    "name": "珠藏渊海",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "珠藏渊海，万人头上之英雄。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_005_hu_ju_long_pan",
    "name": "虎踞龙蟠",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "金果为龙虎之星，各得其用，而照守命宫者，佳。虎踞龙蟠，当朝之士。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_006_yun_jian_yue_zhuo",
    "name": "云间鸑鷟",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "云间鸑鷟，当为邸省之贤。午宫坐命，金气二星入宫坐命。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "jin_007_tian_shang_qi_lin",
    "name": "天上麒麟",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "天上麒麟，定数东宫之贵。金果辰，木在卯，而在卯辰坐命者是。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_008_jin_guan_ding_cui",
    "name": "金冠顶翠",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "金冠顶翠，紫诰金花。金冠指金也，顶翠指木也，金宫会木以合此格也。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_009_yu_chu_kun_gang",
    "name": "玉出昆冈",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "玉出昆冈，罗帏绣幕。玉指金也，昆冈指土也，金土斗度逢空为合格。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "jin_010_luan_yu_nan_xing",
    "name": "鸾轝南幸",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "金果拱日，在星房度。水南幸，人主之尊。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_011_feng_jia_bei_gui",
    "name": "凤驾北归",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "凤驾北归，帝王之象。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_012_yi_gan_jiu_shi",
    "name": "移干就湿",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "移干就湿，必主贫寒。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "jin_013_jin_wu_cheng_rui",
    "name": "金乌呈瑞",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "金乌呈瑞，富贵两全。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "jin_014_feng_yu_zuo_lin",
    "name": "风雨作霖",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "风雨作霖，有济世安民之略。果风毕雨，金水太阳躔毕箕度是也。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_015_lao_bang_han_zhu",
    "name": "老蚌含珠",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "老蚌含珠，乡闾望重。土金在亥子和辰巳宫，须金土为用神者。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_016_su_yue_liu_tian",
    "name": "素月流天",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "素月流天见金，而官居极品。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_017_jin_shui_bei_chi",
    "name": "金水背驰",
    "variants": [
      {
        "source": "《果老星宗·八格赋》",
        "description": "金宝退留，用而无用，来而不来。愚格。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "愚"
      }
    ]
  },
  {
    "id": "jin_018_jin_shui_fen_ming",
    "name": "金水分明",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "金水分明，水前金后，不宜混失退逆。贵。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_019_jin_shui_hui_yuan",
    "name": "金水会垣",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "金水会垣，水忌退于金后。水在金前，水受金生。贵。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_020_jin_han_shui_leng",
    "name": "金寒水冷",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "冬生金寒，水冷，未免孤寒之苦。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "jin_021_jin_shui_wei_shi",
    "name": "金水为仕",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "金水躔奎壁，奎壁乃贵人星，文薮星。当云：五星连壁，五星聚奎，此乃文地。金躔参壁度，曰：金生水。水躔奎斗度曰：水生木，相生之德不混，为文人贵士也。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_022_jin_shui_hu_yuan",
    "name": "金水互垣",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "水居金垣，金入水垣，乃大吉也。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_023_jin_bei_qi_ma",
    "name": "金孛骑马",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "金孛入驿马桃花宫上，必放荡淫邪。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "jin_024_jin_huo_yi_yuan",
    "name": "金火易垣",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "火金不可易垣。火不可入金垣，金不可入火垣，疑其相攻相克也。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "jin_025_jin_shui_gong_cheng",
    "name": "金水功成",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "金水生助命位，益佐官禄，其功名可遂也。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_026_jin_bei_lin_shen",
    "name": "金孛临身",
    "variants": [
      {
        "source": "《果老星宗·女命格》",
        "description": "金孛匪宜临身。金孛同入命，则主淫冶好事。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "jin_027_qing_ji_huo_yuan",
    "name": "庆基获源",
    "variants": [
      {
        "source": "《果老星宗·躔度赋》",
        "description": "庆金因为辰的意思。繇，因为的意思。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_028_jin_shui_hui_she",
    "name": "金水会蛇",
    "variants": [
      {
        "source": "《果老星宗·躔度赋》",
        "description": "金水凑于蛇穴，岂惟鹤发而休（金水会蛇在巳）",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "寿"
      },
      {
        "source": "《格局2》",
        "description": "巳宮屬蛇，金與水同會於巳宮，在軫度則貴。巳宮屬水，軫星屬水，逢金而生水，所謂金水會蛇。凡人巳宮安命及身者，逢之為貴。詩曰：巳宮太白本長生，變曜名為天祿星。與水同宮為奇特，高官厚祿佐王庭。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "巳宮屬蛇，金與水同會於巳宮，在軫度則貴。巳宮屬水，軫星屬水，逢金而生水，所謂金水會蛇。凡人巳宮安命及身者，逢之為貴。詩曰：巳宮太白本長生，變曜名為天祿星。與水同宮為奇特，高官厚祿佐王庭。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "巳宮屬蛇，金與水同會於巳宮，在軫度則貴。巳宮屬水，軫星屬水，逢金而生水，所謂金水會蛇。凡人巳宮安命及身者，逢之為貴。詩曰：巳宮太白本長生，變曜名為天祿星。與水同宮為奇特，高官厚祿佐王庭。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "jin_029_jin_ju_wei_fen",
    "name": "金居卫分",
    "variants": [
      {
        "source": "《果老星宗·躔度赋》《果老星宗·历象赋》",
        "description": "金照卫而主寿（金在亥宫）。西方太白向卫分，益寿延年（金星居亥）。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "寿"
      }
    ]
  },
  {
    "id": "jin_030_jin_yu_ying_huo",
    "name": "金遇荧惑",
    "variants": [
      {
        "source": "《果老星宗·躔度赋》",
        "description": "金照卫而主寿（金在亥宫），遇荧惑而夭天年（火必克金）",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "夭"
      }
    ]
  },
  {
    "id": "jin_031_jin_ju_kang_wei",
    "name": "金居亢位",
    "variants": [
      {
        "source": "《果老星宗·历象赋》",
        "description": "欲问荣华，大抵抗金居亢位（金星在辰）",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "jin_032_jin_mu_zhao_shu_niu",
    "name": "金木照于鼠牛",
    "variants": [
      {
        "source": "《果老星宗·历象赋》",
        "description": "先吉后凶，金木照于鼠牛之地（金木居子居丑）",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "平",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "jin_033_jin_cheng_huo_wei",
    "name": "金乘火位",
    "variants": [
      {
        "source": "《果老星宗·历象赋》《果老星宗·通微赋》",
        "description": "金乘火位，其人少失双亲（金忌居卯戌宫）。金乘火位，在西北则轻。[戌土遇金]",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      },
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "金乘火位：金在卯戌二宫。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "平",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_034_mu_jin_hui_tian",
    "name": "木金会田",
    "variants": [
      {
        "source": "《果老星宗·历象赋》",
        "description": "多荣产业，木金会于田园（金木妙居田宅）",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "jin_035_san_ri_feng_jin",
    "name": "三日逢金",
    "variants": [
      {
        "source": "《果老星宗·历象赋》",
        "description": "年年获福，皆因三日逢金（太阴泊处前后宫共四十五度，谓三日宫）",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "jin_036_tai_bai_shuang_tai",
    "name": "太白双胎",
    "variants": [
      {
        "source": "《果老星宗·元通赋》",
        "description": "亥为登明，巳为太乙。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_037_huo_jin_zi_wei",
    "name": "火金子位",
    "variants": [
      {
        "source": "《果老星宗·通微赋》",
        "description": "如此者非贫即夭。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "夭"
      }
    ]
  },
  {
    "id": "jin_038_jin_shui_wen_zhi",
    "name": "金水文智",
    "variants": [
      {
        "source": "《果老星宗·通微赋》",
        "description": "金水文辞为智巧。[金水在命]",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "jin_039_gang_rou_xiang_ji",
    "name": "刚柔相济",
    "variants": [
      {
        "source": "《果老星宗·通微赋》",
        "description": "金曜本性最无情，见木刚柔须相济[金木宜同行]",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "jin_040_jin_xing_shou_ming",
    "name": "金星守命",
    "variants": [
      {
        "source": "《果老星宗·玉衡经》",
        "description": "金星守命，好色而主清高。[金之色美，人皆好之，故乡]",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "平",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "jin_041_jin_huo_zhan_chen_you",
    "name": "金火战辰酉",
    "variants": [
      {
        "source": "《果老星宗·玉衡经》",
        "description": "金火战于辰酉，肺心咳嗽[火主心金主肺]",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "夭"
      }
    ]
  },
  {
    "id": "jin_042_tu_hui_jin_mai",
    "name": "土晦金埋",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "金埋土而反晦[秋金土重反晦]",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "jin_043_chun_jin_jian_yue",
    "name": "春金见月",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "春金见月，淡薄无成[金未成不能助月]",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "jin_044_dong_yue_yu_jin",
    "name": "冬月遇金",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "冬月遇金，饥寒刺骨[寒月不宜傍金星]",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "jin_045_jin_de_huo_ming",
    "name": "金得火明",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "金得火明而焕发[秋金见火为奇]",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_046_xia_jin_xiao_shuo",
    "name": "夏金销铄",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "夏金遇日销铄无聊[夏金与日同躔必镕]",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "jin_047_shui_dong_jin_han",
    "name": "水冻金寒",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "水冻金寒，纵相生而不发",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "jin_048_tai_bai_ju_yuan",
    "name": "太白居垣",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "太白居垣：金在辰酉二宫。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_049_jin_xing_sheng_dian",
    "name": "金星升殿",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "金星升殿：金躔亢牛娄鬼四宿。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_050_jin_zhu_yue_hua",
    "name": "金助月华",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "金助月华",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《果老星宗·元妙经解》",
        "description": "金月酉宫。贵格。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "未宮為月華也。金星同月居未，謂之金星助月。金與月同在巳宮，申宮，又謂之金助月華。身命更得此三宮，亦主大富貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "未宮為月華也。金星同月居未，謂之金星助月。金與月同在巳宮，申宮，又謂之金助月華。身命更得此三宮，亦主大富貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "未宮為月華也。金星同月居未，謂之金星助月。金與月同在巳宮，申宮，又謂之金助月華。身命更得此三宮，亦主大富貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "jin_051_tu_jin_zao_shou",
    "name": "土金遭受",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "土金坚实：秋冬土埋金寒，余月皆妙。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "平",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_052_jin_shui_xiang_han",
    "name": "金水相涵",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "金水相涵：冬生金寒水冷，余时昼夜皆吉。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_053_bai_hu_cong_jia",
    "name": "白虎从驾",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "金为白虎星。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_055_jin_zai_mu_gong",
    "name": "金在木宫",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "金在木宫：金在寅亥二宫。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "平",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_056_jin_mu_gong_chan",
    "name": "金木共躔",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "金木共躔：金木相克。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "jin_057_huo_jin_jiao_zhan",
    "name": "火金交战",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "火金交战：火金相克。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "jin_058_jin_ji_tong_yuan",
    "name": "金计同垣",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "金计同垣：金为用神，居垣庙吉，冬生减力。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_059_jin_shui_cong_yang",
    "name": "金水从阳",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "金水从阳：金水掌吉神，居垣殿，昼生者奇。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_060_huo_jin_shi_yue",
    "name": "火金侍月",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "火金侍月：火金为用神，临垣庙，夜生者妙。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_061_san_tai_he_ge",
    "name": "三台合格",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "三台合格：午巳卯宫得日金水同行。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_062_chu_gan_ru_kun",
    "name": "出干入坤",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "出干入坤。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "未知",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_063_shan_ze_tong_qi",
    "name": "山泽通气",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "山泽通气：木寅金酉，命坐酉寅，兼格高贵。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_064_jin_luo_tong_ke",
    "name": "金罗同克",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "金罗同克：金为用神则坏矣。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "jin_065_qian_kun_pi_se",
    "name": "乾坤否塞",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "乾坤否塞：亥命金罗，申命土计。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "jin_066_shan_ze_chen_mai",
    "name": "山泽沉埋",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "山泽沉埋。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "jin_067_long_yue_tian_chi",
    "name": "龙跃天池",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "龙跃天池：亢进金龙立命，金亥从日月。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_068_cang_long_ru_jing",
    "name": "苍龙入井",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "苍龙入井。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "未知",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_069_jin_ying_su_liu",
    "name": "金莺宿柳",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "金莺宿柳：金同命躔柳，近太阳尤妙。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_070_ba_sha_chao_tian",
    "name": "八杀朝天",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "八杀朝天：如戌命火，又未命土，或辰命金。此三星独占天门，得时为上。惟金火尤重，夜生显贵之人也。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_071_chang_geng_ru_ming",
    "name": "长庚入命",
    "variants": [
      {
        "source": "《果老星宗·灵台星格》",
        "description": "长庚入命：东有启明乃水星之象，西有长庚乃太白之象。昔李太白母梦长庚星入怀，盖月乃母道也，身之所从出也，夜生金月同在酉，乃合此格。李白母梦长庚入怀，觉而有忧虑，及生李白，命其名曰白，字太白，诗才冠天下，则知长庚入命，必主产不世之奇才也。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_072_bai_hu_dang_quan",
    "name": "白虎当权",
    "variants": [
      {
        "source": "《果老星宗·灵台星格》",
        "description": "秋生人见金星，在申酉安命，乃白虎当权。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_073_hu_ju_long_pan",
    "name": "虎踞龙盘",
    "variants": [
      {
        "source": "《果老星宗·灵台星格》",
        "description": "虎踞龙盘：木星乃东方之苍龙，金星乃西方之白虎，金在命木正照，夜生乃龙盘虎踞。金木同居于命，又为龙虎交驰，更在辰寅二宫坐命者尤妙。盖命宫居于子午，金星在酉，木星在卯，四正得之，正合此格。盖木为青龙在东方，金为白虎在西方，又在前四宫与后四宫拱照，岂得不为贵命。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_074_yue_hua_jin_que",
    "name": "月华金阙",
    "variants": [
      {
        "source": "《果老星宗·灵台星格》",
        "description": "月华金阙：金星在亥，与太阴同宫；金星在辰，与太阴同宫，皆谓之月华金阙。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_075_ri_hua_jin_que",
    "name": "日华金阙",
    "variants": [
      {
        "source": "《果老星宗·灵台星格》",
        "description": "若金星在亥、辰，与太阳同宫者，谓之日华金阙，主富贵。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_076_jin_ju_gan_wei",
    "name": "金居干位",
    "variants": [
      {
        "source": "《果老星宗·灵台星格》",
        "description": "金居干位：亥上乃西北，干位干宫为金，而金星亦居亥上，乃据格。未生与申生人，得金居干位最佳。盖未属井鬼，其分野则在秦；申属觜参，其分野则在晋，得金水正气，又与木日同居于亥，乃金居干位，若无火计罗孛入，皆为贵命。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_077_jin_qi_ren_ma",
    "name": "金骑人马",
    "variants": [
      {
        "source": "《果老星宗·灵台星格》",
        "description": "金骑人马：命立寅宫尾度，金星相会，又是寅年岁驾，谓曰金骑人马。我骑他，盖岁驾有侍从之义，主人禄享千钟，不可概以为不吉也。若罗星来犯，多有为人仆从，妻子早离。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_078_jin_shen_chi_ren",
    "name": "金神持刃",
    "variants": [
      {
        "source": "《果老星宗·灵台星格》",
        "description": "金神持刃：命立辰宫亢金度乃是，乙年刃在辰，却见金星亢度躔之，官封上将，镇守边庭，行限至午，而遇火临柳土，发财可比陶朱，若未限，见土躔井木生秋冬尚可，生于春夏，非夭则残疾。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_079_jin_xing_ru_dou",
    "name": "金星入斗",
    "variants": [
      {
        "source": "《果老星宗·布局补遗》",
        "description": "金星入斗：酉宫立命主，金飞入丑宫斗度，凡人命得此一星，主人才华，俊秀，早步青云，行寅限尾度，见火星，定主刑宪血疾，若在角度，反凶作吉，大主发福寿命延长。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_080_jin_mu_hai_shi",
    "name": "金木亥室",
    "variants": [
      {
        "source": "《果老星宗·指迷歌》",
        "description": "金木亥室：金星与木室相逢，官职荣迁至上公。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_081_jin_shui_xing_qiao",
    "name": "金水性巧",
    "variants": [
      {
        "source": "《果老星宗·金箱歌》",
        "description": "金水性巧：金水主人多精彩，自然巧劣心中藏。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "jin_082_jin_bei_yin_lao",
    "name": "金孛淫痨",
    "variants": [
      {
        "source": "《果老星宗·金箱歌》",
        "description": "金孛淫痨：金孛交会为人淫，必主痨病及其身。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "jin_083_jin_shui_bei_xian",
    "name": "金水孛咸",
    "variants": [
      {
        "source": "《果老星宗·帘幕歌·论女命》",
        "description": "金水孛咸：妇人若见金水孛，三改嫁兮有何说。咸池带水与孛星，朝云暮雨情不歇。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "jin_084_jin_shui_bei_mu",
    "name": "金水孛沐",
    "variants": [
      {
        "source": "《果老星宗·帘幕歌·论女命》",
        "description": "金水孛沐：妇人金水孛星迎，身命同临性偏淫。更兼沐浴在其间，离居奔走落风尘。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "jin_085_jin_xiao_tian_xie",
    "name": "金销天蝎",
    "variants": [
      {
        "source": "《果老星宗·观星要诀》",
        "description": "金销天蝎（房度）。断躔，忌。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "jin_086_jin_xiao_bai_yang",
    "name": "金销白羊",
    "variants": [
      {
        "source": "《果老星宗·观星要诀》",
        "description": "金销白羊（奎度）。断躔，忌。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "jin_087_chang_geng_chao_dou",
    "name": "长庚朝斗",
    "variants": [
      {
        "source": "《果老星宗·元妙经解》",
        "description": "金星丑宫斗木度。贵格。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_088_jin_mu_feng_long",
    "name": "金木逢龙",
    "variants": [
      {
        "source": "《果老星宗·元妙经解》",
        "description": "金木辰宫，贵格。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "金木二星同入辰宮，在角在亢者，謂之角木蛟亢。金龍，辰龍之肖也。謂之金木逢龍。況金入此宮，號太常逢之，主榮遷也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "金木二星同入辰宮，在角在亢者，謂之角木蛟亢。金龍，辰龍之肖也。謂之金木逢龍。況金入此宮，號太常逢之，主榮遷也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "金木二星同入辰宮，在角在亢者，謂之角木蛟亢。金龍，辰龍之肖也。謂之金木逢龍。況金入此宮，號太常逢之，主榮遷也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "jin_089_shui_run_jin_ming",
    "name": "水润金明",
    "variants": [
      {
        "source": "《果老星宗·元妙经解》",
        "description": "水金辰宫，贵格。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_090_jin_hao_tai_chang",
    "name": "金号太常",
    "variants": [
      {
        "source": "《果老星宗·元妙经解》",
        "description": "金辰宫，贵格。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_091_jin_chan_gui_su",
    "name": "金躔鬼宿",
    "variants": [
      {
        "source": "《果老星宗·元妙经解》",
        "description": "金星未宫鬼宿。贵格。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_092_jin_xing_zhu_yue",
    "name": "金星助月",
    "variants": [
      {
        "source": "《果老星宗·元妙经解》",
        "description": "金星助月。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_094_jin_zhang_ren_feng",
    "name": "金掌刃锋",
    "variants": [
      {
        "source": "《果老星宗·谈星奥论》",
        "description": "金怕掌刃锋廉的耗符等煞，木命限人尤凶。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "jin_095_lan_fu_xiu_zhen",
    "name": "烂斧绣针",
    "variants": [
      {
        "source": "《果老星宗·玄玄妙论》",
        "description": "金星落空谓之烂斧绣针，则是常用之物，又主利名有成。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "平",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "jin_096_lian_jin_cheng_qi",
    "name": "炼金成器",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "春令之金不怕火罗，借火罗以温助，谓之炼金成器，变化气质。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_097_chun_jin_ji_shui",
    "name": "春金忌水",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "春令之金，不宜与水孛同行，春初生者，凝寒冻未退，无火日温之，极主贫寒。春月之金性柔体弱。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "jin_098_shuo_shi_feng_yuan",
    "name": "烁石逢源",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "夏令之金，不宜生水，就赖水以制其刚，烁石逢源，主利名显达。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_099_xia_jin_feng_huo",
    "name": "夏金逢火",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "夏令罗火何以相逢，冬月如斯自能发福。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "jin_100_jin_bai_shui_qing",
    "name": "金白水清",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "秋令之金乃白帝司权，金神用事不怕火罗而克，不喜土计而生，借水映色正此谓也。金白水清最喜秋生者，贵。若金水朝拱太阳，最高奇特。经曰：金坚而无火锻炼，终见凶顽。盖火尚杀伐，水尚澄清，文武皆沾，刚柔相济，名扬四海。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "jin_101_dong_jin_xi_nuan",
    "name": "冬金喜暖",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "冬令之金，斯时寒凝冻结，昼喜日光而温之，夜喜火罗而照之，定主文职蒙恩，不宜与水孛相互作用，极主贫寒，水冷故也。最妙昼土逢阳，以温其土，可助其金，主威武之职。又逢火罗拱互降祥，正所谓金罗相会，阃外司权。",
        "books": "果老星宗",
        "className": "金星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  }
]');
INSERT INTO ge_ju_content_document ("file_name", "payload_json") VALUES ('ling_tai_ge_ju_content.json', '[
  {
    "id": "lingtaige_001_he_bi_lian_zhu",
    "name": "合璧连珠",
    "variants": [
      {
        "source": "《灵台格》",
        "description": "大贵之象",
        "books": "果老星宗",
        "className": "灵台格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "lingtaige_002_ri_yue_he_bi",
    "name": "日月合璧",
    "variants": [
      {
        "source": "《灵台格》",
        "description": "大吉之格",
        "books": "果老星宗",
        "className": "灵台格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "lingtaige_003_wu_xing_lian_zhu",
    "name": "五星连珠",
    "variants": [
      {
        "source": "《灵台格》",
        "description": "有名望，居高位",
        "books": "果老星宗",
        "className": "灵台格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "lingtaige_004_dou_niu_xiu_qi",
    "name": "斗牛秀气",
    "variants": [
      {
        "source": "《灵台格》",
        "description": "主人才气高，官运好",
        "books": "果老星宗",
        "className": "灵台格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "lingtaige_005_wen_zhang_mi_fu",
    "name": "文章秘府",
    "variants": [
      {
        "source": "《灵台格》",
        "description": "主人满腹才华",
        "books": "果老星宗",
        "className": "灵台格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "lingtaige_006_wu_xing_chao_dou",
    "name": "五星朝斗",
    "variants": [
      {
        "source": "《灵台格》",
        "description": "主人官运亨通",
        "books": "果老星宗",
        "className": "灵台格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "lingtaige_007_bo_yu_dong_jing",
    "name": "孛于东井",
    "variants": [
      {
        "source": "《灵台格》",
        "description": "主人有权力",
        "books": "果老星宗",
        "className": "灵台格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "lingtaige_008_shou_xie_long_jiao",
    "name": "首携龙角",
    "variants": [
      {
        "source": "《灵台格》",
        "description": "主人显贵",
        "books": "果老星宗",
        "className": "灵台格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "lingtaige_009_ji_ju_long_wei",
    "name": "计居龙尾",
    "variants": [
      {
        "source": "《灵台格》",
        "description": "主人居高位",
        "books": "果老星宗",
        "className": "灵台格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "lingtaige_010_yin_yang_lei_ju",
    "name": "阴阳类聚",
    "variants": [
      {
        "source": "《灵台格》",
        "description": "主人发达",
        "books": "果老星宗",
        "className": "灵台格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  }
]');
INSERT INTO ge_ju_content_document ("file_name", "payload_json") VALUES ('mu_xing_ge_ju_content.json', '[
  {
    "id": "mu_001_ri_bian_hong_xing",
    "name": "日边红杏",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "日邊紅杏，早占鰲頭。[紅杏者木星也，木為官、恩、命、令等用者，與太陽同行。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_002_xue_ya_han_mei",
    "name": "雪压寒梅",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "雪壓寒梅，終身餓莩。[寒梅者木星也，木水同躔，夜生冬值，倘或在子丑地及水宮、水度者亦是。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "mu_003_qi_cha_han_mei",
    "name": "齐插寒梅",
    "variants": [
      {
        "source": "《果老星宗·星格补遗》",
        "description": "命立子宮度，木為福德、財帛二主，飛入命位，是乃謂財福剋命，不可概以木打寶瓶論也。若木遇形剋之星，財福減半；倘命主衰弱，反不能勝矣。經云：安命子宮，木入齊瓶。若非李郭之榮，必有陶朱之富。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "mu_004_xiang_yang_hua_mu",
    "name": "向阳花木",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "向陽花木，三台八座之榮。[木為官恩命令順行，見日晝生春夏者佳。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_005_zhao_shui_mei_hua",
    "name": "照水梅花",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "照水梅花，萬軸五車之學。[木在巳申，冬生逢晝，為美。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "mu_006_chun_sheng_yang_liu",
    "name": "春生杨柳",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "春生楊柳，合作妓娼。[楊柳喻木也，春生木躔箕度]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "mu_007_qiu_ri_wu_tong",
    "name": "秋日梧桐",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "秋日梧桐，堪為僧道。[梧桐喻木也，秋生木遇孤寡羊刃。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "mu_008_yue_zhong_xian_gui",
    "name": "月中仙桂",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "月中仙桂，少年平步青雲。[木躔心、張、危、畢月度，或秋生木月同宮亦是]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_009_ri_shai_hua_zhi",
    "name": "日晒花枝",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "日曬花枝，壯歲趨朝丹闕。[木臨星虛房、昴日度、或春生木日同宮皆是。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_010_mei_shao_heng_yue",
    "name": "梅梢横月",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "梅梢橫月，簞瓢陋巷之人。[木月會子宮，生於秋冬。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "mu_011_liu_xu_sui_feng",
    "name": "柳絮随风",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "柳絮隨風，萍水他鄉之客。[木星秉令躔箕度，或在巳宮巽地。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "mu_012_yu_zhou_hua_can",
    "name": "雨骤花残",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "雨驟花殘，窮愁萬種。[春生木躔畢度，蓋畢宿好雨故也。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "mu_013_feng_yao_ye_luo",
    "name": "风摇叶落",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "風搖葉落，辛苦無閑。[秋生木躔箕度，蓋箕好風故耳。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "mu_014_an_che_pu_lun",
    "name": "安车蒲轮",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "安車蒲輪，翰苑編修集撰。[安車即木也，木會日與馬元同宮。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_015_mei_ying_heng_chuang",
    "name": "梅影横窗",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "梅影橫窗，一生清貴。[梅影喻木也，木月冬生，同在壁府。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_016_tao_hua_lang_nuan",
    "name": "桃花浪暖",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "桃花浪暖，昭代文章。[桃花譬木也，木水會命，在奎度尢妙。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "mu_017_hua_li_ting_can",
    "name": "花里停骖",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "花裏停驂，封侯列仕。[木為命、恩、令同太陰與馬元在張、心、危、畢月度。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_018_dan_gui_piao_xiang",
    "name": "丹桂飘香",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "丹桂飄香，或貧寒尤當食祿。[秋木為用神，在巽巳地。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_019_li_hua_dai_yu",
    "name": "梨花带雨",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "梨花帶雨，縱富貴亦主重夫。[女人之命，春木為夫元、命主，在酉申畢度。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "mu_020_nan_zhi_xiang_nuan",
    "name": "南枝向暖",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "南枝向煖，相國經邦。[南乃午宮，枝言木也，冬木為用神，喜居午上，或太陽合格。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_021_san_tai_he_ge",
    "name": "三台合格",
    "variants": [
      {
        "source": "《果老星宗·八格赋》",
        "description": "或木星在午[木為歲星君象也，得金水巳未，或寅戌二方拱合，亦曰三奇，此木所主，惟春夏得用，秋冬不取。]双鱼按：三台合格的格局不只一种，此处之论木星成格。木星在午，对于狮子座来说是不利的，但是午狮子之位在上天紫微垣乃帝座鶉火之位，而木星又为岁星，太岁乃君象，木星临午则有君临帝座的意味。此格貌似于\"南枝向暖\"格局有些相似之处，但是区别是：1南枝向暖是冬木为用神，喜居午上，取调侯的意思。而木星的三台合格是春夏得用，秋冬不取2木星三台合格须有金水的夹拱辅弼。而南枝向暖无其它附加条件。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_022_mu_qi_fu_shen",
    "name": "木气扶身",
    "variants": [
      {
        "source": "《果老星宗·八格赋》",
        "description": "木氣星同太陰，必賢達者，或老成功而能設策、處公道之人也。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "mu_023_mu_qi_jia_ming",
    "name": "木气夹命",
    "variants": [
      {
        "source": "《果老星宗·八格赋》",
        "description": "木氣拱身夾命，必有壽而聰明。[木氣清高善曜、文學之星，守命臨身，必主聰明清秀，或泊孤寡主有壽孤剋也。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "寿"
      }
    ]
  },
  {
    "id": "mu_024_mu_qi_guan_ming",
    "name": "木气贯命",
    "variants": [
      {
        "source": "《果老星宗·八格赋》",
        "description": "木氣貫命，多於林下逍遙。[木氣二星貫守命度，多宜林下。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "平",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "mu_025_mu_xing_zhao_lin",
    "name": "木星照临",
    "variants": [
      {
        "source": "《果老星宗·八格赋》",
        "description": "木星照臨，主人技藝學、術亦是文人才士。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "mu_026_mu_lin_zhen_yuan",
    "name": "木临真垣",
    "variants": [
      {
        "source": "《果老星宗·躔度赋》",
        "description": "木臨寅亥是真垣，精神百倍（木居寅亥）。《玉衡经》：木德臨垣，剛毅而懷惻隱。[木主仁好善]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "mu_027_sun_ji_ji_ren",
    "name": "损己济人",
    "variants": [
      {
        "source": "《果老星宗·躔度赋》",
        "description": "捐自己之財以濟人，必是木同紫氣(木主剛毅，氣為慈祥)",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "mu_028_mu_ru_qin_zhou",
    "name": "木入秦州",
    "variants": [
      {
        "source": "《果老星宗·历象赋》",
        "description": "木入秦州旺鬼，而初歸巨蟹(木星在未)。《元通赋》：歲居蟹鬼，而順將逆相。（木入秦川）。双鱼按：巨蟹、鬼宿的分野在秦，木到巨蟹入旺，成贵格。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_029_sui_ju_xie_gui",
    "name": "岁居蟹鬼",
    "variants": [
      {
        "source": "《果老星宗·元通赋》",
        "description": "同\"木入秦州\"。歲居蟹鬼，而順將逆相。（木入秦川）",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_030_shui_mu_chong_lin",
    "name": "水木重临",
    "variants": [
      {
        "source": "《果老星宗·元通赋》",
        "description": "水木重臨，文章秀麗.[水木相逢]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "mu_031_mu_xian_kan_wei",
    "name": "木嫌坎位",
    "variants": [
      {
        "source": "《果老星宗·通微赋》",
        "description": "木嫌坎位. [木打寶瓶]。双鱼按：坎位即是宝瓶座，宝瓶属土，木星临此为怒地，不吉。若宝瓶立命，木为福德、财帛主，福财克命反吉。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "mu_032_mu_da_bao_ping",
    "name": "木打宝瓶",
    "variants": [
      {
        "source": "《果老星宗·通微赋》",
        "description": "同\"木嫌坎位\"。木打寶瓶，木星临宝瓶（子宫）为怒地，不吉。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "mu_033_mu_luo_dong_jing",
    "name": "木罗东井",
    "variants": [
      {
        "source": "《果老星宗·通微赋》",
        "description": "木臨東井，要神首以加臨. [木羅同未井度]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_034_mu_zheng_dong_fang",
    "name": "木正东方",
    "variants": [
      {
        "source": "《果老星宗·通微赋》",
        "description": "仁慈聰俊，木正東方. [木星得位]。双鱼按：东方为木旺之地，卯天蝎是木帝旺之乡，木星临此是背中反旺之格，贵。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "mu_035_mu_yang_zhao_qian",
    "name": "木阳照迁",
    "variants": [
      {
        "source": "《果老星宗·通微赋》",
        "description": "人事和同遷移，木得陽臨照. [木日同遷移]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_036_mu_de_lin_yuan",
    "name": "木德临垣",
    "variants": [
      {
        "source": "《果老星宗·玉衡经》",
        "description": "同\"木临真垣\"。《玉衡经》：木德臨垣，剛毅而懷惻隱。[木主仁好善]。《躔度赋》：木臨寅亥是真垣，精神百倍（木居寅亥）",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "mu_037_nv_chan_mu_xian",
    "name": "女缠木限",
    "variants": [
      {
        "source": "《果老星宗·玉衡经》",
        "description": "女命限到木躔防夫害子[木氣乃孤剋之宿]。双鱼按：男人限到金月则招妻纳妾，女人限到木缠，不利于姻缘仔细，因为木气常带孤劫等不利姻缘的神煞。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "mu_038_tu_mu_xi_zheng",
    "name": "土木息争",
    "variants": [
      {
        "source": "《果老星宗·玉衡经》",
        "description": "木土偏愛陽宮，雖戰而無損[土木在寅]。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "平",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_039_mu_bu_nan_ben",
    "name": "木不南奔",
    "variants": [
      {
        "source": "《果老星宗·玉衡经》",
        "description": "木居獅子，居官不能享官[木不南奔午宮也]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "mu_040_mu_luo_hui_she",
    "name": "木罗会舍",
    "variants": [
      {
        "source": "《果老星宗·玉衡经》",
        "description": "木羅會舍，喜入寅宮[木入垣羅入廟]。《十一曜定格》：木為用神冬春生，躔廟旺宮佳。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "木星與羅星同在戌宮，行奎宿度，謂之會舍。戌與卯合，戌宮與卯取屬火而謂之也。羅乃火之餘，得木而生之，故喜而會之。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "福"
      },
      {
        "source": "《格局2》",
        "description": "木星與羅星同在戌宮，行奎宿度，謂之會舍。戌與卯合，戌宮與卯取屬火而謂之也。羅乃火之餘，得木而生之，故喜而會之。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "福",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "木星與羅星同在戌宮，行奎宿度，謂之會舍。戌與卯合，戌宮與卯取屬火而謂之也。羅乃火之餘，得木而生之，故喜而會之。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "福",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "mu_041_shui_fan_mu_piao",
    "name": "水泛木漂",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "無根之木遇惡水，而飄泛東西[木躔金度或與金同，夏月水勢盛反被漂流]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "mu_042_han_mu_xiang_yang",
    "name": "寒木向阳",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "冬春之木見日，則謂向陽",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_043_qiu_shui_nan_zi",
    "name": "秋水难滋",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "秋水非滋木之時[秋木凋零，不能足水之滋]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "mu_044_mu_tu_xiang_an",
    "name": "木土相安",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "土在子，木在午，似有衝而無害[子命]。双鱼按：子命土为命主，木为福元，看似对冲，实则福元克命，无害也。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "平",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_045_lin_quan_gao_zhi",
    "name": "林泉高致",
    "variants": [
      {
        "source": "《果老星宗·广寒赋》",
        "description": "如逢木氣，山間林下作生涯[月逢木氣]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "平",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "mu_046_mu_qi_fan_yue",
    "name": "木气犯月",
    "variants": [
      {
        "source": "《果老星宗·广寒赋》",
        "description": "木氣犯月,命居於鶉火之位。双鱼按：鶉火之位为狮子，立命在此，木气为难，伴月则安身傍难，忌格。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "mu_047_yi_xing_ban_yue",
    "name": "一星伴月",
    "variants": [
      {
        "source": "《果老星宗·广寒赋》",
        "description": "木星伴月朝東井[未命]。双鱼按：一星伴月的格局不只此一种，《李橙问答》中说一星是指水星，但是在《广寒赋》中却列出了四种一星伴月格，除土星外，其他四星皆可成一星伴月之格：凡金星伴月以躔亢[辰命]；水星伴月而入軫[巳命]；火星伴月向南斗[丑命]；木星伴月朝東井[未命]。雖然一星伴月，自古宜有,不如眾星朗朗,孤月獨明。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "一星者，水星也。水數一，故曰：一星。與太陰同宮，為一星伴月。在未宮，方是未，乃月之樂宮，命立未逢此二星，主大貴命也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "一星者，水星也。水數一，故曰：一星。與太陰同宮，為一星伴月。在未宮，方是未，乃月之樂宮，命立未逢此二星，主大貴命也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "一星者，水星也。水數一，故曰：一星。與太陰同宮，為一星伴月。在未宮，方是未，乃月之樂宮，命立未逢此二星，主大貴命也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "mu_048_tian_di_kai_ming",
    "name": "天地开明",
    "variants": [
      {
        "source": "《果老星宗·通元赋》",
        "description": "天地開明[水居申，木居亥，又於此二宮安命，是有開明之義，而得羅計在子午攔截為合格，若羅計在辰戌中攔為破格。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_049_shan_ze_tong_qi",
    "name": "山泽通气",
    "variants": [
      {
        "source": "《果老星宗·通元赋》",
        "description": "山澤通氣[艮為山，木星居之，兌為澤，金星居之，二星得所，為通氣。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_050_shan_ze_chen_mai",
    "name": "山泽沉埋",
    "variants": [
      {
        "source": "《果老星宗·通元赋》",
        "description": "山澤沉埋[金入寅而體絕，木至酉而受傷，乃沉埋之象。]（双鱼按：\"木\"原文作\"水\"，疑误，故改之）",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "mu_051_jie_mu_xing_zai",
    "name": "劫木兴灾",
    "variants": [
      {
        "source": "《果老星宗·通元赋》",
        "description": "劫木為災難避。[木星如梃杖之屬，掌劫亦能害人命限，切忌逢之，寅亥二宮，犯劫是也。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "夭"
      }
    ]
  },
  {
    "id": "mu_052_long_hu_feng_yun_hui",
    "name": "龙虎风云会",
    "variants": [
      {
        "source": "《果老星宗·通元赋》",
        "description": "官魁夾命帶龍虎，則廊廟良材。[如命安在卯，而木金化為官魁，在寅辰歸垣夾命，乃龍虎慶會風雲，必主圭璋美玉。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_053_mu_xing_sheng_dian",
    "name": "木星升殿",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "木躔角斗奎井四宿。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_054_mu_yue_qing_gui",
    "name": "木月清贵",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "弦朢夜生合格，月晦、寒天不取。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "木月清貴如亥命人，命主是木，又在亥宮，謂之木臨營室。與月同守此宮，謂之木月清貴。惟亥命得之，主貴。丑子命得之，則不吉也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "福"
      },
      {
        "source": "《格局2》",
        "description": "木月清貴如亥命人，命主是木，又在亥宮，謂之木臨營室。與月同守此宮，謂之木月清貴。惟亥命得之，主貴。丑子命得之，則不吉也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "福",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "木月清貴如亥命人，命主是木，又在亥宮，謂之木臨營室。與月同守此宮，謂之木月清貴。惟亥命得之，主貴。丑子命得之，則不吉也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "福",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "mu_055_mu_huo_wen_ming",
    "name": "木火文明",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "冬春月生，無分晝夜為妙。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_056_qing_long_fu_yan",
    "name": "青龙扶砚",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "寅卯月生，木日同宮。木為青龍星。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "青龍者，甲乙木也。凡甲乙生人在於春，三月之間，正木旺之鄉。若與日月同宮，則貴。人命主身，主為木合之者，正此謂也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "青龍者，甲乙木也。凡甲乙生人在於春，三月之間，正木旺之鄉。若與日月同宮，則貴。人命主身，主為木合之者，正此謂也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "青龍者，甲乙木也。凡甲乙生人在於春，三月之間，正木旺之鄉。若與日月同宮，則貴。人命主身，主為木合之者，正此謂也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "mu_057_mu_ru_jin_xiang",
    "name": "木入金乡",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "木在辰酉二宮。忌格。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "mu_058_mu_ru_tu_shi",
    "name": "木入土室",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "木居子丑二宮。忌格。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "mu_059_mu_tu_xiang_ke",
    "name": "木土相剋",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "木遇土而剋。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "mu_060_mu_bei_fu_yin",
    "name": "木孛符印",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "木為用神，臨廟旺吉。冬生無力。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_061_mu_bi_yang_guang",
    "name": "木蔽阳光",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "晝生忌木氣掩，夜生宜火羅助。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "mu_062_mu_qi_lian_zhi",
    "name": "木气联枝",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "木氣孛在寅亥，命宮官祿合格。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_063_hu_xiao_yuan_yin",
    "name": "虎啸猿吟",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "木尾火觜，亥命大貴，巳命大富。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_064_hu_ju_long_pan",
    "name": "虎踞龙盘",
    "variants": [
      {
        "source": "《果老星宗·灵台星格》",
        "description": "木星乃東方之蒼龍，金星乃西方之白虎，金在命木正照，夜生乃龍盤虎踞。⊙金木同居於命，又為龍虎交馳，更在辰寅二宮坐命者尤妙。⊙命宮居於子午，金星在酉，木星在卯，四正得之，正合此格。蓋木為青龍在東方，金為白虎在西方，又在前四宮與後四宮拱照，豈得不為貴命。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_065_qing_long_dang_quan",
    "name": "青龙当权",
    "variants": [
      {
        "source": "《果老星宗·灵台星格》",
        "description": "春生人見木星，在寅卯安命，乃青龍用事。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_066_ao_tou_du_bu",
    "name": "鳌头独步",
    "variants": [
      {
        "source": "《果老星宗·灵台星格》",
        "description": "三春生人在寅卯二宮安命，而寅卯上見木星也，此得時得位得用鰲頭，自當獨步也，前格所謂青龍當權，亦此義耳。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_067_mu_shang_shui_jing",
    "name": "木上水井",
    "variants": [
      {
        "source": "《果老星宗·灵台星格》",
        "description": "水先入宮，木後入宮，或木星先入，水星後入，皆為井象，更得在東井未上，又在未上安命，必主道心員融，有常德以食天祿也。⊙井居其所而不遷，地之德也，而木居水上，有養而不窮之義。⊙或人命得木同居於未，而水星對照於亥，此亦得木上水井格。蓋亥居下而有井之象也，然在天之井，則異於是，以井而居河漢之中，其為度，則三十，視其他度數最長，半次實沈、半次鶉首，在實沈者，水為樂宮，在鶉首者，水為入廟，此亦養而不窮之義。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "mu_068_jiao_mu_duan_chan",
    "name": "角木断躔",
    "variants": [
      {
        "source": "《果老星宗·格居补遗》",
        "description": "立命丑宮斗木度，土躔斗度，行限辰宮，木星又躔角度，故曰：角木斷躔，必然主死於非命，定因親族相累，禍起於蕭牆。又云：木度立命，見木帶煞，乃自家殺自家。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "夭"
      }
    ]
  },
  {
    "id": "mu_069_ji_feng_dou_kou",
    "name": "箕风斗口",
    "variants": [
      {
        "source": "《果老星宗·格居补遗》",
        "description": "命立亥，行寅限而遇木星在箕度，箕星好風原，主風搖葉落，行限重見箕度，或斗度，故曰：箕風斗口見之，家破身亡，不然水火而終。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "夭"
      }
    ]
  },
  {
    "id": "mu_070_jin_mu_hai_shi",
    "name": "金木亥室",
    "variants": [
      {
        "source": "《果老星宗·指迷歌》",
        "description": "金星與木室相逢，官職榮遷至上公。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_080_jiao_ji_feng_chang",
    "name": "脚疾风肠",
    "variants": [
      {
        "source": "《果老星宗·金箱歌》",
        "description": "木星為病有一方，必主腳疾及風腸。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "mu_081_mu_ji_tong_yin",
    "name": "木计同寅",
    "variants": [
      {
        "source": "《果老星宗·玄妙经解》",
        "description": "分布得經、俱是十二宮星辰得局貴格。寅宫：木计同寅。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_082_jin_mu_feng_long",
    "name": "金木逢龙",
    "variants": [
      {
        "source": "《果老星宗·玄妙经解》",
        "description": "分布得經、俱是十二宮星辰得局貴格。辰宮：金木逢龍。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_083_mu_chan_jiao_dao",
    "name": "木躔角道",
    "variants": [
      {
        "source": "《果老星宗·玄妙经解》",
        "description": "分布得經、俱是十二宮星辰得局貴格。辰宮：木躔角道。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_084_mu_tu_xiang_hui",
    "name": "木土相会",
    "variants": [
      {
        "source": "《果老星宗·玄妙经解》",
        "description": "分布得經、俱是十二宮星辰得局貴格。申宮：木土相會。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_085_jin_mu_cheng_wang",
    "name": "金木乘旺",
    "variants": [
      {
        "source": "《果老星宗·玄妙经解》",
        "description": "分布得經、俱是十二宮星辰得局貴格。亥宫：金木乘旺。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_086_mu_lin_ying_shi",
    "name": "木临营室",
    "variants": [
      {
        "source": "《果老星宗·玄妙经解》",
        "description": "分布得經、俱是十二宮星辰得局貴格。亥宫：木臨熒室。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_087_mu_ji_feng_yu",
    "name": "木计逢鱼",
    "variants": [
      {
        "source": "《果老星宗·玄妙经解》",
        "description": "分布得經、俱是十二宮星辰得局貴格。亥宫：木计逢鱼。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_088_mu_chu_jin_long",
    "name": "木触金龙",
    "variants": [
      {
        "source": "《果老星宗》",
        "description": "木在辰宫，参考\"木入金乡\"。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "mu_089_chun_mu_ge",
    "name": "纯木格",
    "variants": [
      {
        "source": "《果老星宗·谈星奥论》",
        "description": "天元星最要緊，或守命得令相資，或是身命主聰明，加生旺貴祿為奇。[天元者，如甲天元屬木，而木星守命，或命度純木尤奇。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_090_mu_tu_hui_ji",
    "name": "木土会吉",
    "variants": [
      {
        "source": "《果老星宗·谈星奥论》",
        "description": "四木安命，木土同度得躔，又得生旺財帛擁進，更財福二宮有吉星扶為上格。[四木者，斗木獬、奎木狼、井木犴、角木蛟之類。]",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "mu_091_ru_miao_tui_xing",
    "name": "入庙退行",
    "variants": [
      {
        "source": "《果老星宗·谈星奥论》",
        "description": "木躔斗入廟而退行，得失相伴。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "平",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_092_ku_zhi_bai_ye",
    "name": "枯枝败叶",
    "variants": [
      {
        "source": "《果老星宗·玄玄妙论》",
        "description": "木星落空謂之枯枝敗葉。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "mu_093_zhuo_xiao_cheng_cai",
    "name": "琢削成材",
    "variants": [
      {
        "source": "《果老星宗·玄玄妙论》",
        "description": "木星落空謂之枯枝敗葉，如金會則琢削成材。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "平",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_094_fen_zhe_hui_mie",
    "name": "焚折灰灭",
    "variants": [
      {
        "source": "《果老星宗·玄玄妙论》",
        "description": "木星落空謂之枯枝敗葉，火會則焚折灰滅。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "夭"
      }
    ]
  },
  {
    "id": "mu_095_piao_cha_fan_fa",
    "name": "漂槎泛筏",
    "variants": [
      {
        "source": "《果老星宗·玄玄妙论》",
        "description": "木星落空謂之枯枝敗葉，水會則漂槎泛筏，不免流蕩。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "mu_096_ri_lie_mu_jiao",
    "name": "日烈木焦",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "夏末秋初之木，斯時氣脈虛矣，晝生忌躔四火之度。又不宜與太陽交互，蓋是日烈木焦不足論也。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "mu_097_shang_xia_ji_run",
    "name": "上下济润",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "夏末秋初之木，斯時氣脈虛矣，晝生忌躔四火之度。又不宜與太陽交互，蓋是日烈木焦不足論也。晝生木躔四水之度而與太陽交光，此是上下濟潤不可以木焦日烈而論，乃水之秀麗，枝葉繁茂，精神富貴。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "mu_098_bu_zhan_xian_kui",
    "name": "布占先魁",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "冬令之木，斯時萬物蕭疏。如晝生與太陽交光謂之，日邊紅杏、布占先魁，遇此造化，豈不美哉！兼能有幹，文才清高。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "mu_099_han_gu_hui_chun",
    "name": "寒谷回春",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "冬令之木，斯時萬物蕭疏。如日生遇火羅，謂之寒谷回春，富貴雙全。如無太陽火羅同宮，得生巳午未之時，借日光霽，冰霜凍解，猶可舒暢，或木躔四火之度，又與太陽交輝，可作十全之福也。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "mu_100_shui_bei_dong_zhe",
    "name": "水孛冻折",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "冬令之木，斯時萬物蕭疏。如遇夜生木躔四土之度，又逢水孛凍折，窮之極矣。",
        "books": "果老星宗",
        "className": "木星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  }
]');
INSERT INTO ge_ju_content_document ("file_name", "payload_json") VALUES ('shi_san_bu_yi_ge_ju_content.json', '[
  {
    "id": "shisanceng_001_qi_cha_sai_mei",
    "name": "齐插塞梅",
    "variants": [
      {
        "source": "《十三层》",
        "description": "命宫与木星的吉凶对应",
        "books": "果老星宗",
        "className": "十三层格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "shisanceng_002_jiao_mu_duan_chan",
    "name": "角木断躔",
    "variants": [
      {
        "source": "《十三层》",
        "description": "遭受杀身之祸",
        "books": "果老星宗",
        "className": "十三层格局",
        "jiXiong": "凶",
        "geJuType": "夭"
      }
    ]
  },
  {
    "id": "shisanceng_003_jin_qi_ren_ma",
    "name": "金骑人马",
    "variants": [
      {
        "source": "《十三层》",
        "description": "获得福禄，遇罗睺不幸",
        "books": "果老星宗",
        "className": "十三层格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "shisanceng_004_shui_huo_xiang_xing",
    "name": "水火相刑",
    "variants": [
      {
        "source": "《十三层》",
        "description": "没有福德",
        "books": "果老星宗",
        "className": "十三层格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "shisanceng_005_jin_shen_chi_ren",
    "name": "金神持刃",
    "variants": [
      {
        "source": "《十三层》",
        "description": "吉则为将军，凶则夭折",
        "books": "果老星宗",
        "className": "十三层格局",
        "jiXiong": "平",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shisanceng_006_xuan_wu_dang_tai",
    "name": "元武当台",
    "variants": [
      {
        "source": "《十三层》",
        "description": "人富贵兴旺",
        "books": "果老星宗",
        "className": "十三层格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "shisanceng_007_zi_cheng_fu_wei",
    "name": "子承父位",
    "variants": [
      {
        "source": "《十三层》",
        "description": "父子冲突，使人遭受刑害",
        "books": "果老星宗",
        "className": "十三层格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "shisanceng_008_yue_ming_dou_fu",
    "name": "月明斗府",
    "variants": [
      {
        "source": "《十三层》",
        "description": "吉凶不定",
        "books": "果老星宗",
        "className": "十三层格局",
        "jiXiong": "平",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shisanceng_009_xiang_yun_peng_yue",
    "name": "祥云捧月",
    "variants": [
      {
        "source": "《十三层》",
        "description": "获得才华美貌",
        "books": "果老星宗",
        "className": "十三层格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shisanceng_010_tai_yi_bao_chan",
    "name": "太乙抱蟾",
    "variants": [
      {
        "source": "《十三层》",
        "description": "获得功名，遇计都有凶灾",
        "books": "果老星宗",
        "className": "十三层格局",
        "jiXiong": "平",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "[木 缹 之星是為太乙，又以巳為太乙。]\n未宮，月之樂宮也。月與孛同宮在未，孛入秦鬼，尤貴。謂之太乙抱蟾。未為月殿也，謂之蟾宮。凡人安命未宮者，逢此主大貴。詩曰：太陰在未號天圭，千載欣逢明聖時。月孛更...",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "[木 缹 之星是為太乙，又以巳為太乙。]\n未宮，月之樂宮也。月與孛同宮在未，孛入秦鬼，尤貴。謂之太乙抱蟾。未為月殿也，謂之蟾宮。凡人安命未宮者，逢此主大貴。詩曰：太陰在未號天圭，千載欣逢明聖時。月孛更...",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "[木 缹 之星是為太乙，又以巳為太乙。]\n未宮，月之樂宮也。月與孛同宮在未，孛入秦鬼，尤貴。謂之太乙抱蟾。未為月殿也，謂之蟾宮。凡人安命未宮者，逢此主大貴。詩曰：太陰在未號天圭，千載欣逢明聖時。月孛更...",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "shisanceng_011_shui_shi_zao_xing",
    "name": "水士遭刑",
    "variants": [
      {
        "source": "《十三层》",
        "description": "遭受凶灾",
        "books": "果老星宗",
        "className": "十三层格局",
        "jiXiong": "凶",
        "geJuType": "夭"
      }
    ]
  },
  {
    "id": "shisanceng_012_jin_xing_ru_dou",
    "name": "金星入斗",
    "variants": [
      {
        "source": "《十三层》",
        "description": "才华横溢，获得功名",
        "books": "果老星宗",
        "className": "十三层格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shisanceng_013_ji_feng_dou_kou",
    "name": "箕风斗口",
    "variants": [
      {
        "source": "《十三层》",
        "description": "遭受灾祸，妻离子散",
        "books": "果老星宗",
        "className": "十三层格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  }
]');
INSERT INTO ge_ju_content_document ("file_name", "payload_json") VALUES ('shui_xing_ge_ju_content.json', '[
  {
    "id": "shui_001_jun_chen_qing_hui",
    "name": "君臣庆会",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "君臣庆会，钟鸣鼎食之家。金水为官福恩令命元，朝辅太阳者是。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_002_shui_cou_tian_chi",
    "name": "水凑天池",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "水凑天池，三峡词源之豪迈。春生水为用神，躔壁度，以亥为天池。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_003_gan_xuan_kun_zhuan",
    "name": "干旋坤转",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "干旋坤转，有庆之人。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_004_luan_yu_nan_xing",
    "name": "鸾轝南幸",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "金果拱日，在星房度。水南幸，人主之尊。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_005_feng_jia_bei_gui",
    "name": "凤驾北归",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "凤驾北归，帝王之象。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_006_yi_gan_jiu_shi",
    "name": "移干就湿",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "移干就湿，必主贫寒。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "shui_007_feng_yu_zuo_lin",
    "name": "风雨作霖",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "风雨作霖，有济世安民之略。果风毕雨，金水太阳躔毕箕度是也。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_008_jin_shui_bei_chi",
    "name": "金水背驰",
    "variants": [
      {
        "source": "《果老星宗·八格赋》",
        "description": "金宝退留，用而无用，来而不来。愚格。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "愚"
      }
    ]
  },
  {
    "id": "shui_009_jin_shui_fen_ming",
    "name": "金水分明",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "金水分明，水前金后，不宜混失退逆。贵。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_010_jin_shui_hui_yuan",
    "name": "金水会垣",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "金水会垣，水忌退于金后。水在金前，水受金生。贵。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_011_jin_han_shui_leng",
    "name": "金寒水冷",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "冬生金寒，水冷，未免孤寒之苦。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "shui_012_jin_shui_wei_shi",
    "name": "金水为仕",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "金水躔奎壁，无例外必为仕人。金水躔奎壁，奎壁乃贵人星，文薮星。当云：五星连壁，五星聚奎，此乃文地。金躔参壁度，曰：金生水。水躔奎斗度曰：水生木，相生之德不混，为文人贵士也。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_013_jin_shui_hu_yuan",
    "name": "金水互垣",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "金居互济，终身而有庆。水居金垣，金入水垣，乃大吉也。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_014_jin_shui_gong_cheng",
    "name": "金水功成",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "金水生命中位，益佐官禄，其功名可遂也。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_015_shui_an_tian_zhai",
    "name": "水暗田宅",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "水星本无定性，飘流之星也，况又化暗守田宅，主祖业无依。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "shui_016_shui_zhi_si_shen",
    "name": "水至巳申",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "水至巳申诚入局，气象俱新（水在巳申）",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_017_shui_ri_tong_zhou",
    "name": "水日同周",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "水日合星张之位，陛庭补衮赞皇明（水日在午）",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_018_jin_shui_hui_she",
    "name": "金水会蛇",
    "variants": [
      {
        "source": "《果老星宗·躔度赋》",
        "description": "金水凑于蛇穴，岂惟鹤发而休（金水会蛇在巳）",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "寿"
      }
    ]
  },
  {
    "id": "shui_019_shui_liu_an_chun_wei",
    "name": "水流鹌鹑尾",
    "variants": [
      {
        "source": "《果老星宗·躔度赋》",
        "description": "水流鹌鹑尾，巧计千般（水星在巳）",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "平",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "shui_020_shui_hui_ji_du",
    "name": "水会计都",
    "variants": [
      {
        "source": "《果老星宗·躔度赋》",
        "description": "掠他人之物以利己，盖缘水会计都（水主智谋，计好狡猾）",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "shui_021_shui_huo_xiang_zhan",
    "name": "水火相战",
    "variants": [
      {
        "source": "《果老星宗·躔度赋》",
        "description": "一身迍蹇，火星怕与水星交战",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "shui_022_shui_liu_yang_zhou",
    "name": "水流扬州",
    "variants": [
      {
        "source": "《果老星宗·躔度赋》",
        "description": "眉颦常不足，只嫌水到扬州（水星在丑宫）",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "shui_023_shui_lin_shuang_nv",
    "name": "水临双女",
    "variants": [
      {
        "source": "《果老星宗·历象赋》",
        "description": "给谏功臣，定是水临双女（水星在巳）",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_024_jin_huo_tong_cai",
    "name": "金火同财",
    "variants": [
      {
        "source": "《果老星宗·历象赋》",
        "description": "少失资财，金火同居财位（金火忌守财宫）",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "shui_025_shui_huo_ju_tian",
    "name": "水火居田",
    "variants": [
      {
        "source": "《果老星宗·历象赋》",
        "description": "水火并居田宅，破家荡产（水火忌居田宅）。祖财困辱田宅，火被水来侵。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "shui_026_shui_su_lin_cai",
    "name": "水宿临财",
    "variants": [
      {
        "source": "《果老星宗·历象赋》",
        "description": "财帛衰退，被水宿加临（水星忌居财宫）",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "shui_027_shui_mu_chong_lin",
    "name": "水木重临",
    "variants": [
      {
        "source": "《果老星宗·元通赋》",
        "description": "水木重临，文章秀丽。[水木相逢]",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_028_shui_jin_tong_chou",
    "name": "水金同丑",
    "variants": [
      {
        "source": "《果老星宗·通微赋》",
        "description": "泉枯牛荒，须凭金曜生成。[水金同丑]",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "平",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "shui_029_shui_bei_tong_du",
    "name": "水孛同度",
    "variants": [
      {
        "source": "《果老星宗·通微赋》",
        "description": "水孛同度性偏淫。[水孛照身命]",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "shui_030_chao_yun_mu_yu",
    "name": "朝云暮雨",
    "variants": [
      {
        "source": "《果老星宗·通微赋》",
        "description": "朝云，暮雨，水孛俱坐迁移。[水孛淫荡星也]",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "shui_031_shui_su_ju_qiang",
    "name": "水宿居强",
    "variants": [
      {
        "source": "《果老星宗·通微赋》",
        "description": "水星无心常好动，向昼楚晋郑为强[水宜巳申辰宫]",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_032_shui_xing_shou_ming",
    "name": "水星守命",
    "variants": [
      {
        "source": "《果老星宗·玉衡经》",
        "description": "水如守命，多学少成。[水主智刚无常性]",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "平",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "shui_033_shui_bei_tian_cai",
    "name": "水孛田财",
    "variants": [
      {
        "source": "《果老星宗·玉衡经》",
        "description": "水孛如守田财，难招祖业[水孛漂流无定]",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "shui_034_shui_ji_xiang_xing",
    "name": "水计相刑",
    "variants": [
      {
        "source": "《果老星宗·玉衡经》",
        "description": "水计相刑，怕居巳位[巳乃三刑之地]",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "shui_035_shui_ru_yin_gong",
    "name": "水入寅宫",
    "variants": [
      {
        "source": "《果老星宗·玉衡经》",
        "description": "水入寅宫，喉喉壅塞[寅乃喉舌之府]",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "shui_036_tu_hun_shui_zhuo",
    "name": "土混水浊",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "土混水而致浊[ 冬水冰结土混不清]",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "shui_037_shui_fan_tu_beng",
    "name": "水泛土崩",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "受制之土见猛水，而崩溃四出[ 春夏生物之土乃为受制，遇水反崩溃]",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "shui_038_xia_shui_ku_he",
    "name": "夏水枯涸",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "六月之水最怕火日枯涸[六月水主辅阳，反为不美]",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "shui_039_dong_shui_nan_ben",
    "name": "冬水南奔",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "冬水喜于南奔，戌火忌于发露[居娄宿则吉，微弱宜藏]",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_040_shui_dong_jin_han",
    "name": "水冻金寒",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "水冻金寒，纵相生而不发",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "shui_041_shui_run_zao_tu",
    "name": "水润燥土",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "刚燥之土遇水滋润[ 夏土干燥，爱水滋润]",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_042_chen_xing_ju_yuan",
    "name": "辰星居垣",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "辰星居垣，水星入本垣为贵格。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_043_shui_xing_sheng_dian",
    "name": "水星升殿",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "水星升殿：水躔箕壁参轸四宿。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_044_shui_han_chan_po",
    "name": "水涵蟾魄",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "水涵蟾魄：月寒水冷何益，望前，望后尤佳。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "平",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "蟾，月宮也，未上見之。假使太陰星在未宮，又值水星同宮，謂之水涵蟾魄，極其清徹。凡人命主及命宮逢此者，貴不可言。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "蟾，月宮也，未上見之。假使太陰星在未宮，又值水星同宮，謂之水涵蟾魄，極其清徹。凡人命主及命宮逢此者，貴不可言。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "蟾，月宮也，未上見之。假使太陰星在未宮，又值水星同宮，謂之水涵蟾魄，極其清徹。凡人命主及命宮逢此者，貴不可言。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贵",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "shui_045_jin_shui_xiang_han",
    "name": "金水相涵",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "金水相涵：冬生金寒水冷，余时昼夜皆吉。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_046_yuan_wu_chi_jing",
    "name": "元武持旌",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "元为元武星。水星持旌为贵格。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "元武者，北方壬癸水也。壬癸生於冬三月，與日月同宮，謂之：元武持旌。旌者，旗也。元武，水神也。言持旌，猶言得令也，主貴。\n祥雲拱月 [拱作扶。]\n氣星，木之餘奴也。與月同宮，謂之：拱月。氣在前，月在後，...",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贱"
      },
      {
        "source": "《格局2》",
        "description": "元武者，北方壬癸水也。壬癸生於冬三月，與日月同宮，謂之：元武持旌。旌者，旗也。元武，水神也。言持旌，猶言得令也，主貴。\n祥雲拱月 [拱作扶。]\n氣星，木之餘奴也。與月同宮，謂之：拱月。氣在前，月在後，...",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贱",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "元武者，北方壬癸水也。壬癸生於冬三月，與日月同宮，謂之：元武持旌。旌者，旗也。元武，水神也。言持旌，猶言得令也，主貴。\n祥雲拱月 [拱作扶。]\n氣星，木之餘奴也。與月同宮，謂之：拱月。氣在前，月在後，...",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "贱",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "shui_047_shui_ju_tu_shi",
    "name": "水居土室",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "水居土室：水在子丑二宫。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_048_shui_cheng_huo_wei",
    "name": "水乘火位",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "水乘火位，水星入火位，水火相济。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "平",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_049_jin_shui_cong_yang",
    "name": "金水从阳",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "金水从阳：金水掌吉神，居垣殿，昼生者奇。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_050_san_tai_he_ge",
    "name": "三台合格",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "三台合格：午巳卯宫得日金水同行。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_051_tian_di_kai_ming",
    "name": "天地开明",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "天地开明：水申木亥，命安申亥，罗计子午。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_052_shui_huo_ji_ji",
    "name": "水火既济",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "水火既济：水子火午，命坐子午。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《果老星宗·灵台星格》",
        "description": "水火既济：水先入宫，火后入宫，同居一位以照命者是也。盖水性润下，火性炎上，上下相得，而不相违，切嫌一二凶星入侵，则反生祸。更若水星为宫主，为命主，为禄主，则福最厚，富贵双全之命也。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "水火同宮而水居水度，火居火度，各居本度，謂之水火既濟。如在亥宮，有壁水室火，巳宮有翼火軫水，申宮觜火參水也，寅宮則尾火箕水，皆謂之既濟。身命二宮逢之，並作富貴而推。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "水火同宮而水居水度，火居火度，各居本度，謂之水火既濟。如在亥宮，有壁水室火，巳宮有翼火軫水，申宮觜火參水也，寅宮則尾火箕水，皆謂之既濟。身命二宮逢之，並作富貴而推。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "水火同宮而水居水度，火居火度，各居本度，謂之水火既濟。如在亥宮，有壁水室火，巳宮有翼火軫水，申宮觜火參水也，寅宮則尾火箕水，皆謂之既濟。身命二宮逢之，並作富貴而推。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "shui_053_feng_lei_gu_wu",
    "name": "风雷鼓舞",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "风雷鼓舞：水巳火卯，命辰合格。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_054_feng_lei_xiang_bo",
    "name": "风雷相薄",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "风雷相薄，水火交激之象。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "shui_055_shui_huo_xiang_she",
    "name": "水火相射",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "水火相射：水午火子，或木卯戌，或火巳申。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "shui_056_yu_yuan_shou_kun",
    "name": "玉猿守昆",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "玉猿守昆：水躔参度会日，命安水度者贵。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_057_shuang_yu_xi_shui",
    "name": "双鱼戏水",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "双鱼戏水，水星入亥宫为贵格。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_058_yu_nv_chang_e",
    "name": "玉女嫦娥",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "玉女嫦娥：水轸月张，命箕主贵，女貌倾国。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_059_yuan_wu_dang_quan",
    "name": "元武当权",
    "variants": [
      {
        "source": "《果老星宗·灵台星格》",
        "description": "冬生人见水星，在亥子安命，乃元武当权。元武当台：歌云：巳宫立命水在轸，元武升垣诸杀顺。又兼一点太白来，富贵绵绵应不降低。若还中限见土星，重整门庭兴进永。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_060_li_kan_jiao_hui",
    "name": "离坎交会",
    "variants": [
      {
        "source": "《果老星宗·灵台星格》",
        "description": "离坎交会：水星禀北方坎宫之气，火星禀南方离宫之气，夜生人火星在命中，水星正照，乃合此格，此格最主为人气概精神，法能剸裁繁剧，禄位优厚。若水火二星同守命宫，则是煎熬星矣，反主灾祸。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_061_zi_xing_fu_zheng",
    "name": "子行父政",
    "variants": [
      {
        "source": "《果老星宗·灵台星格》",
        "description": "子行父政：太阴为水之副，月为母，水为子也。太阴之庙在未，太阴居之当然也，今则太阴却居丑，水星却在未，又于未上安命，亦亦行行父政之说也。此格主人艰难于始，逸乐于终，以其干蛊之早也。谓且父之创制，子当继之，父之德政，予当行之。此谓人有贤子而继父志，不亦善乎！",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_062_shui_zhu_dong_nan",
    "name": "水注东南",
    "variants": [
      {
        "source": "《果老星宗·灵台星格》",
        "description": "水注东南：巽居巳位东南之地也，四方之水则皆会之于箕，虽北有溟浡，南有大海，西有流沙，而水之倾注则归于东海，以势不满于东南也。水星在巳，而木星与命宫在寅，乃合此格。酉生人与寅生人，得水星在巳，木星与命在寅是也。盖寅属尾，尾巴在燕，酉属毕，毕分在赵，独得水正气，而流入于巽，是水有所归，况与木命同在寅，或木命与寅生同在酉，得水日在四正之宫，则又为水归地户格。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_063_huo_shui_wei_ji",
    "name": "火水未济",
    "variants": [
      {
        "source": "《果老星宗·灵台星格》",
        "description": "火水未济：火先入宫，水后入宫，同居一宫，以照命者是也。盖火自上炎，水自下注，相违而不相向，安得能和而能济。曰：未济男之穷也。格中带此者，主贫贱。此系忌格。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "shui_065_shui_huo_xiang_xing",
    "name": "水火相刑",
    "variants": [
      {
        "source": "《果老星宗·布局补遗》",
        "description": "水火相刑：歌曰：命立卯宫在房度，生于夏令主炎库。行限午宫见水星，水入午宫宜柳土。反凶为吉福无边，金玉争光敌国富。若教脱水鬼门关，五十三四归泉路。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "平",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "shui_066_shui_tu_zao_xing",
    "name": "水土遭刑",
    "variants": [
      {
        "source": "《果老星宗·布局补遗》",
        "description": "水木遭刑：歌云：申宫立命水为主，限戌恩金在奎度。金木相刑恩受制，反吉为凶横死鬼。限行亥宫见土星，土入江湖壁水度。也教富贵一时来，一十五年花锦丽。脱土半百危十五，溺死官刑骨肉忌。行奎度，在火宫则金受制，行亥见土，则能生金，金生水则发，到危则被土克。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "夭"
      }
    ]
  },
  {
    "id": "shui_067_jin_shui_xing_qiao",
    "name": "金水性巧",
    "variants": [
      {
        "source": "《果老星宗·金箱歌》",
        "description": "金水巧：金水主人多精彩，自然巧劣心中藏。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "shui_068_shui_bei_chang_you",
    "name": "水孛倡优",
    "variants": [
      {
        "source": "《果老星宗·金箱歌》",
        "description": "水孛倡优：女逢水孛是娼优，不是娼优缁素娘。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "shui_069_jin_shui_bei_xian",
    "name": "金水孛咸",
    "variants": [
      {
        "source": "《果老星宗·帘幕歌，论女命》",
        "description": "金池孛咸：妇人若见金水孛，三改嫁兮有何说。咸池带水与孛星，朝云暮雨情不歇。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "shui_070_jin_shui_bei_mu",
    "name": "金水孛沐",
    "variants": [
      {
        "source": "《果老星宗·帘幕歌，论女命》",
        "description": "金水孛沐：妇人金水孛星迎，身命同临性偏偏淫。更兼沐浴在其间，离居奔走落风尘。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "shui_071_shui_piao_yang_jiao",
    "name": "水漂羊角",
    "variants": [
      {
        "source": "《果老星宗·观星要诀》",
        "description": "水漂羊角（娄度）。断躔，忌。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "shui_072_shui_liu_ju_xie",
    "name": "水流巨蟹",
    "variants": [
      {
        "source": "《果老星宗·观星要诀》",
        "description": "水流巨蟹（柳度）。断躔，忌。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "shui_073_shui_qing_bao_ping",
    "name": "水清宝瓶",
    "variants": [
      {
        "source": "《果老星宗·元妙经解》",
        "description": "子宫：水清宝瓶，得局贵格。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《格局2》",
        "description": "寶瓶，子宮也。水星臨之，名曰水清寶瓶。但凡人命立子宮者有之。是以取貴。若得金星助合，富貴榮華，土木加之，不吉。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "寶瓶，子宮也。水星臨之，名曰水清寶瓶。但凡人命立子宮者有之。是以取貴。若得金星助合，富貴榮華，土木加之，不吉。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "富",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "寶瓶，子宮也。水星臨之，名曰水清寶瓶。但凡人命立子宮者有之。是以取貴。若得金星助合，富貴榮華，土木加之，不吉。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "凶",
        "geJuType": "富",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "shui_074_shui_run_jin_ming",
    "name": "水润金明",
    "variants": [
      {
        "source": "《果老星宗·元妙经解》",
        "description": "水金辰宫，贵格。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_075_ri_shui_cheng_wang",
    "name": "日水乘旺",
    "variants": [
      {
        "source": "《果老星宗·元妙经解》",
        "description": "日水巳宫，贵格。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_076_shui_yang_xiang_hui",
    "name": "水阳相会",
    "variants": [
      {
        "source": "《果老星宗·元妙经解》",
        "description": "水太阳在午宫。贵格。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_077_shui_ming_rong_xian",
    "name": "水名荣显",
    "variants": [
      {
        "source": "《果老星宗·元妙经解》",
        "description": "水午宫。贵格。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_078_shui_bei_fu_chen",
    "name": "水孛浮沉",
    "variants": [
      {
        "source": "《果老星宗·元妙经解》",
        "description": "水孛怕尾，忌带浮沉亡劫的耗等煞，火命限人尤畏。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "夭"
      }
    ]
  },
  {
    "id": "shui_079_chang_jiang_hao_dang",
    "name": "长江浩荡",
    "variants": [
      {
        "source": "《果老星宗·玄玄妙论》",
        "description": "水星落空谓之长江浩荡，退败无余。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "shui_080_hong_shui_tao_tian",
    "name": "洪水滔天",
    "variants": [
      {
        "source": "《果老星宗·玄玄妙论》",
        "description": "水星落空谓之长江浩荡，退败无余，如金会则洪水滔天，常有不测之灾。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "夭"
      }
    ]
  },
  {
    "id": "shui_081_guang_ji_cheng_che",
    "name": "光霁澄彻",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "春令之水，斯时冰霜冻冷，借木气火罗温之，自能变化，昼生水孛太阳同行名曰\"光霁澄彻\"谓之\"冰霜冻解\"心宇清吉，作事整肃，政令威仪，当主台省扬名。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_082_chun_shui_ji_jin",
    "name": "春水忌金",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "春令之水，斯时冰霜冻冷，所忌金星相互作用。昼生为妙，夜生贫寒。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "shui_083_xia_shui_feng_di",
    "name": "夏水逢堤",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "经云：水盛而无土，堤防，遂归虚浊。若有土旺不以为倒限，论反主名利发达。惟六月之水最",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_084_qiu_shui_qing_yuan",
    "name": "秋水清源",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "秋令之水，七八月间既济万物，不宜受克，既能借土堤防而不泛滥，又能润土，结实万物，清源可爱，富贵荣华。若水受克泄者，皆水之气脉虚矣，却不为福。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "shui_085_dong_shui_san_ling",
    "name": "冬水三令",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "斯时点水成冰，冻结寒滞，不能变化。得火为上令，得土为次令，得太阳佐之方可言令也。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "shui_086_dong_jin_wu_yi",
    "name": "冬金无义",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "然冬水自得其时，不用金生，使之见金，反为无义，乃曰：道义相忘唯喜在于火木也。",
        "books": "果老星宗",
        "className": "水星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  }
]');
INSERT INTO ge_ju_content_document ("file_name", "payload_json") VALUES ('tu_xing_ge_ju_content.json', '[
  {
    "id": "tu_001_gou_chen_zhen_dian",
    "name": "勾陈镇殿",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "勾陈镇殿，珮玉腰金。土掌官恩，命令，同太阳躔虚星房，昴日度。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      },
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "勾陈镇殿：辰戌丑未月土，日同宫。土为勾陈星。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "tu_002_shan_xiao_cheng_bao",
    "name": "山啸呈宝",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》《果老星宗·玄玄妙论》",
        "description": "山啸呈宝，殿前作赋声摩空。土星落空谓之土陷山崩，必主退败可畏，如有恶星降夹逼迫，多见气蹙噎吃之疾，必主倒限。如金会谓之山啸呈宝，又主名利发达。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "tu_003_shi_li_jian_feng",
    "name": "石砺剑锋",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "石砺剑锋，塞上封侯建功节。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "tu_004_zhu_cang_yuan_hai",
    "name": "珠藏渊海",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "珠藏渊海，万人头上之英雄。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "tu_005_lao_bang_han_zhu",
    "name": "老蚌含珠",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "老蚌含珠，乡闾望重。土金在亥子和辰巳宫，须金土为用神者。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "tu_006_han_yun_chu_xiu",
    "name": "寒云出岫",
    "variants": [
      {
        "source": "《果老星宗·星格贵贱总赋》",
        "description": "寒云出岫遇土，而身隐空山。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "平",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "tu_007_tu_bei_chan",
    "name": "土孛掺",
    "variants": [
      {
        "source": "《果老星宗·八格赋》",
        "description": "土孛相战，星辰崩溃。愚格。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "愚"
      }
    ]
  },
  {
    "id": "tu_008_zhou_huo_ye_tu",
    "name": "昼火夜土",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "火土分昼夜之忌。昼生忌火罗，夜生忌土计。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "tu_009_ye_tu_jie_yue",
    "name": "夜土截月",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "土化刑，夜生嫌与月同行。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "tu_010_tu_bei_po_guan",
    "name": "土孛破官",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "土孛破官，徒向仕途奔走。官星被土孛伤破，可为医，卜，吏，书，卒难成名。九流者，土计孛同于官禄。土孛计会于官禄，宜是九流人也。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "tu_011_huo_tu_ba_sha",
    "name": "火土八杀",
    "variants": [
      {
        "source": "《果老星宗·论诸星总断》",
        "description": "残疾者，火罗土杂于难宫。火罗土聚于八杀宫，必然残疾也。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "tu_012_tu_zai_qi_wu",
    "name": "土在齐吴",
    "variants": [
      {
        "source": "《果老星宗·躔度赋》",
        "description": "原夫土在齐吴，虽夜生而福尤昌炽（土居子丑）。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "tu_013_huo_tu_de_niu",
    "name": "火土得牛",
    "variants": [
      {
        "source": "《果老星宗·躔度赋》",
        "description": "火土会于牛宫，不独龟龄而已（火土会牛在丑）。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "寿"
      },
      {
        "source": "《格局2》",
        "description": "火土二星同在丑宮，謂之得牛。丑宮牛，斗也。同在酉宮，亦謂之得牛。酉宮，金牛之地也。更立命酉丑二宮，遇之，主富貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富"
      },
      {
        "source": "《格局2》",
        "description": "火土二星同在丑宮，謂之得牛。丑宮牛，斗也。同在酉宮，亦謂之得牛。酉宮，金牛之地也。更立命酉丑二宮，遇之，主富貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schoolId": "guolao"
      },
      {
        "source": "《格局2》",
        "description": "火土二星同在丑宮，謂之得牛。丑宮牛，斗也。同在酉宮，亦謂之得牛。酉宮，金牛之地也。更立命酉丑二宮，遇之，主富貴也。",
        "books": "果老星宗",
        "className": "格局2格局",
        "jiXiong": "吉",
        "geJuType": "富",
        "schools": [
          "guolao"
        ]
      }
    ]
  },
  {
    "id": "tu_014_tu_ju_zheng_guo",
    "name": "土居郑国",
    "variants": [
      {
        "source": "《果老星宗·历象赋》",
        "description": "土居郑国好亢，而正庙秤宫（土星在辰）。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "tu_015_tu_hao_bao_ping",
    "name": "土好宝瓶",
    "variants": [
      {
        "source": "《果老星宗·历象赋》",
        "description": "参政学士，盖缘土好宝瓶（土星在子）。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "tu_016_tu_mai_shuang_nv",
    "name": "土埋双女",
    "variants": [
      {
        "source": "《果老星宗·历象赋》",
        "description": "要知浅薄，无过土埋双女（土星在巳）。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "tu_017_jin_tu_xiang_feng",
    "name": "金土相逢",
    "variants": [
      {
        "source": "《果老星宗·历象赋》",
        "description": "金土相逢，此辈盖能修合（金土指道门修合）。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "tu_018_tu_hao_tai_chang",
    "name": "土号太常",
    "variants": [
      {
        "source": "《果老星宗》",
        "description": "斗牛之次，土德庙地。土号太常。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "tu_019_tu_luo_qian_yi",
    "name": "土罗迁移",
    "variants": [
      {
        "source": "《果老星宗》",
        "description": "迁移犯土罗，男有旅亡之兆。土罗居迁移宫。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "夭"
      }
    ]
  },
  {
    "id": "tu_020_tu_bei_si_gong",
    "name": "土孛巳宫",
    "variants": [
      {
        "source": "《果老星宗》",
        "description": "火金子位，土孛巳宫，两相克战，切忌坐命。如此者非贫即夭。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "夭"
      }
    ]
  },
  {
    "id": "tu_021_tu_xing_ru_ming",
    "name": "土星入命",
    "variants": [
      {
        "source": "《果老星宗·玉衡经》",
        "description": "沉谋熟虑，为缘土入命宫。土主信，主人沉重敦厚。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "贤"
      }
    ]
  },
  {
    "id": "tu_022_tu_ji_ju_chen",
    "name": "土计居辰",
    "variants": [
      {
        "source": "《果老星宗·玉衡经》",
        "description": "脸面委黄，土计而居辰位。辰酉属胸膈。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "tu_023_huo_yan_tu_zao",
    "name": "火炎土燥",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "九夏之土逢火而燥。夏火太旺，生土反燥。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "tu_024_tu_hui_jin_mai",
    "name": "土晦金埋",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "金埋土而反晦。秋金土重反晦。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "tu_025_tu_hun_shui_zhuo",
    "name": "土混水浊",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "土混水而致浊。冬水冰结土混不清。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "tu_026_shui_fan_tu_beng",
    "name": "水泛土崩",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "受制之土见猛水，而崩溃四出。春夏生物之土乃为受制，遇水反崩溃。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "tu_027_dong_tu_hui_huo",
    "name": "冻土会火",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "冰冻之土会火，始能发用。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "tu_028_han_tu_feng_jin",
    "name": "寒土逢金",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "寒土何生金之有。所谓土寒者，不生之故。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "tu_029_tu_mu_zhu_yue",
    "name": "土母助月",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "辰酉坐命，土犯月而尤佳。金命喜土为母。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "tu_030_shui_run_zao_tu",
    "name": "水润燥土",
    "variants": [
      {
        "source": "《果老星宗·四时赋》",
        "description": "刚燥之土遇水滋润。夏土干燥，爱水滋润。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "tu_031_zhen_xing_ju_yuan",
    "name": "镇星居垣",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "镇星居垣：土在子丑二宫。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "tu_032_tu_xing_sheng_dian",
    "name": "土星升殿",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "土星升殿：土躔女胃柳氐四宿。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "tu_033_huo_tu_gao_qiang",
    "name": "火土高强",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "火土高强：夏生火炎土燥，余月昼夜皆吉。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "tu_034_tu_jin_jian_shi",
    "name": "土金坚实",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "土金坚实：秋冬土埋金寒，余月皆妙。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "tu_036_tu_zai_mu_gong",
    "name": "土在木宫",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "土在木宫：土在寅亥二宫。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "tu_037_tu_ju_shui_di",
    "name": "土居水地",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "土居水地：土在巳申二宫。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "tu_038_mu_tu_xiang_ke",
    "name": "木土相克",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "木土相克：木遇土而克。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "tu_039_tu_shui_xiang_ji",
    "name": "土水相激",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "土水相激：土克水之故。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "tu_040_tu_luo_xiang_hui",
    "name": "土罗相会",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "土罗相会：土为用神，居庙旺奇，夏生大燥。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "平",
        "geJuType": "贵"
      },
      {
        "source": "《果老星宗·元妙经解》",
        "description": "土罗辰宫，贵格。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "tu_041_tu_ji_yan_yue",
    "name": "土计掩月",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "土计掩月：夜月忌土计同宫，掌杀刃尤甚。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "夭"
      }
    ]
  },
  {
    "id": "tu_042_tu_bei_hun_za",
    "name": "土孛混杂",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "土孛混杂：土为用神则力轻忌格。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "tu_043_qian_kun_pi_se",
    "name": "乾坤否塞",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "乾坤否塞：亥命金罗，申命土计。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "tu_044_ba_sha_chao_tian",
    "name": "八杀朝天",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "八杀朝天：如戌命火，又未命土，或辰命金。此三星独占天门，得时为上。惟金火尤重，夜生显贵之人也。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "tu_045_gou_chen_de_wei",
    "name": "勾陈得位",
    "variants": [
      {
        "source": "《果老星宗·十一曜定格》",
        "description": "四土星在辰戌丑未安命，乃勾陈得位。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "tu_046_shui_tu_zao_xing",
    "name": "水土遭刑",
    "variants": [
      {
        "source": "《果老星宗·布局补遗》",
        "description": "水木遭刑：歌云：申宫立命水为主，限戌恩金在奎度。金木相刑恩受制，反吉为凶横死鬼。限行亥宫见土星，土入江湖壁水度。也教富贵一时来，一十五年花锦丽。脱土半百危十五，溺死官刑骨肉忌。行奎度，在火宫则金受制，行亥见土，则能生金，金生水则发，到危则被土克。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "夭"
      }
    ]
  },
  {
    "id": "tu_047_tu_xing_fei_da",
    "name": "土星肥大",
    "variants": [
      {
        "source": "《果老星宗·金箱歌》",
        "description": "土星肥大：土星主人体重肥，为人禀性迟而愚。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "平",
        "geJuType": "愚"
      }
    ]
  },
  {
    "id": "tu_048_tu_ming_ji_mu",
    "name": "土命忌木",
    "variants": [
      {
        "source": "《果老星宗·金箱歌》",
        "description": "土命忌木：木星刚健若无杀，土命嫌之有破克。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "tu_049_tu_ke_rou_chuang",
    "name": "土咳肉疮",
    "variants": [
      {
        "source": "《果老星宗·金箱歌》",
        "description": "土主咳嗽肉疮：土星为病必咳嗽，皮肉受病多生疮。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  },
  {
    "id": "tu_050_tu_zou_shuang_yu",
    "name": "土走双鱼",
    "variants": [
      {
        "source": "《果老星宗·观星要诀》",
        "description": "土走双鱼（翼度）。断躔，忌。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "tu_051_tu_zou_ren_ma",
    "name": "土走人马",
    "variants": [
      {
        "source": "《果老星宗·观星要诀》",
        "description": "土走人马位（尾度）断躔，忌。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "tu_052_tu_hao_tai_chang_2",
    "name": "土好太常",
    "variants": [
      {
        "source": "《果老星宗·元妙经解》",
        "description": "土星丑宫，贵格。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "tu_054_mu_tu_xiang_hui",
    "name": "木土相会",
    "variants": [
      {
        "source": "《果老星宗·元妙经解》",
        "description": "木土申宫，贵格。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "tu_055_tu_ri_he_zhao",
    "name": "土日合照",
    "variants": [
      {
        "source": "《果老星宗·元妙经解》",
        "description": "土日戌宫。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "tu_056_tu_ji_ren_xiong",
    "name": "土计刃雄",
    "variants": [
      {
        "source": "《果老星宗·谈星奥论》",
        "description": "土计怕怒，忌掌刃雄廉耗等煞，水命限人尤凶。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "夭"
      }
    ]
  },
  {
    "id": "tu_057_tu_xian_shan_beng",
    "name": "土陷山崩",
    "variants": [
      {
        "source": "《果老星宗·玄玄妙论》",
        "description": "土星落空谓之土陷山崩，必主退败可畏，如有恶星降夹逼迫，多见气蹙噎吃之疾，必主倒限。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      },
      {
        "source": "《果老星宗·七政四时论》",
        "description": "如土躔四水之度，又逢水孛，春末夏初生者，谓之土陷山崩，皆非好格，盖春初生者，土计不宜与水孛交会，谓之泥逢泛滑。四五月间洪水滔天，斯时土之气脉虚矣。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "tu_058_tian_ao_bu_que",
    "name": "填凹补缺",
    "variants": [
      {
        "source": "《果老星宗·玄玄妙论》",
        "description": "土星落空谓之土陷山崩，必主退败可畏，如有恶星降夹逼迫，多见气蹙噎吃之疾，必主倒限。如火会，谓之填凹补缺，又主名利发达。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "tu_059_tian_di_jie_chun",
    "name": "天地皆春",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "春令之土昼生与太阳交会，盖是阳和一点天地皆春，若有官令禄印爵魁佐之，主守成富贵，夜生最喜火照。土德朝拱太阳，盖火土俱名精彩，代日行权用事北方生者一人之下，万人之上，忠臣良将。土有生万物之功，其德至大，故得阳数五，三才五行皆不可失。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "tu_060_ni_feng_fan_hua",
    "name": "泥逢泛滑",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "春初生者，土计不宜与水孛交会，谓之泥逢泛滑。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "tu_062_tu_feng_shui_run",
    "name": "土逢水润",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "夏令之土最喜水孛，若得同宫以润土之精神，斯时也，万物长养结实。遇水发生，清源可爱，富贵无言。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "tu_063_huo_zao_tu_lie",
    "name": "火燥土烈",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "夏末初秋之土，不宜与罗火交会，谓之火燥土烈，无水孛济，润万物摧枯，一落千丈，昼生土与太阳交辉，亦为日烈土焦。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "tu_064_ri_lie_tu_jiao",
    "name": "日烈土焦",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "夏末初秋之土，昼生土与太阳交辉，亦为日烈土焦。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贫"
      }
    ]
  },
  {
    "id": "tu_065_shang_sheng_xia_run",
    "name": "上生下润",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "夏末初秋之土，不宜与罗火交会，谓之火燥土烈，无水孛济，润万物捣烂，一落千丈，昼生土与太阳交辉，亦为日烈土焦，如逢水孛，此谓上生下润，土之精彩，万物秀丽，大降吉祥。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "tu_066_ri_wen_tu_hua",
    "name": "日温土化",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "冬令之土最喜日温，自能变化。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "tu_067_huo_luo_zhu_tu",
    "name": "火罗助土",
    "variants": [
      {
        "source": "《果老星宗·七政四时论》",
        "description": "冬令之土，夜生木气火罗，佐助土之精神光彩，朝拱太阳皆主文武富贵，倘与水孛同躔极主贫寒，若得一木飞来泄水之气而又遇火飞来，合度此谓精神展转为妙。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "tu_068_tu_wei_zai_huan",
    "name": "土为灾缓",
    "variants": [
      {
        "source": "《果老星宗·续论七政四余分布宜忌及入格真伪》",
        "description": "土星为灾至缓，主病堆积滞难痊，使人晦涩，作事有头无尾，或出一月方发。土星行最迟二十九年一周天，故主疾淹滞。",
        "books": "果老星宗",
        "className": "土星格局",
        "jiXiong": "凶",
        "geJuType": "贱"
      }
    ]
  }
]');
INSERT INTO ge_ju_content_document ("file_name", "payload_json") VALUES ('xing_ge_zong_lun_content.json', '[
  {
    "id": "xinggezonglun_001_qing_zhu_zhi_qi",
    "name": "清浊之气",
    "variants": [
      {
        "source": "《星格总论》",
        "description": "人分贤愚",
        "books": "果老星宗",
        "className": "星格总论",
        "jiXiong": "平",
        "geJuType": "理"
      }
    ]
  },
  {
    "id": "xinggezonglun_002_ri_yue_he_bi",
    "name": "日月合璧",
    "variants": [
      {
        "source": "《星格总论》",
        "description": "大贵之命",
        "books": "果老星宗",
        "className": "星格总论",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "xinggezonglun_003_zhao_shui_mei_hua",
    "name": "照水梅花",
    "variants": [
      {
        "source": "《星格总论》",
        "description": "出生四时与木星的吉凶对应",
        "books": "果老星宗",
        "className": "星格总论",
        "jiXiong": "平",
        "geJuType": "时"
      }
    ]
  },
  {
    "id": "xinggezonglun_004_mei_ying_heng_chuang",
    "name": "梅影横窗",
    "variants": [
      {
        "source": "《星格总论》",
        "description": "有官财福禄",
        "books": "果老星宗",
        "className": "星格总论",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  },
  {
    "id": "xinggezonglun_005_bei_yuan_hui_chun",
    "name": "北苑回春",
    "variants": [
      {
        "source": "《星格总论》",
        "description": "命格显贵",
        "books": "果老星宗",
        "className": "星格总论",
        "jiXiong": "吉",
        "geJuType": "贵"
      }
    ]
  },
  {
    "id": "xinggezonglun_006_jin_wu_cheng_rui",
    "name": "金乌呈瑞",
    "variants": [
      {
        "source": "《星格总论》",
        "description": "吉祥富贵",
        "books": "果老星宗",
        "className": "星格总论",
        "jiXiong": "吉",
        "geJuType": "富"
      }
    ]
  }
]');
COMMIT;
