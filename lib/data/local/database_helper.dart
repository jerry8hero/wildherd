import 'dart:convert';

/// Web平台兼容的数据存储助手
/// 使用浏览器 localStorage 存储 JSON 数据
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static bool _initialized = false;

  DatabaseHelper._init();

  /// 检查是否在Web平台
  bool get _isWeb {
    try {
      return identical(this, {});
    } catch (_) {
      return false;
    }
  }

  /// 获取存储数据（Web使用内存存储）
  static final Map<String, List<Map<String, dynamic>>> _memoryStorage = {};

  /// 获取存储键名
  String _tableKey(String table) => 'wildherd_$table';

  /// 获取存储数据
  List<Map<String, dynamic>> _getData(String table) {
    return _memoryStorage[_tableKey(table)] ?? [];
  }

  /// 保存存储数据
  Future<void> _saveData(String table, List<Map<String, dynamic>> data) async {
    _memoryStorage[_tableKey(table)] = data;
  }

  /// 获取所有数据
  Future<List<Map<String, dynamic>>> query(String table, {String? orderBy}) async {
    var result = _getData(table);

    // 排序
    if (orderBy != null) {
      final orderField = orderBy.replaceAll(' DESC', '').replaceAll(' ASC', '');
      final isDesc = orderBy.contains('DESC');
      result = List.from(result);
      result.sort((a, b) {
        final aVal = a[orderField];
        final bVal = b[orderField];
        int compare;
        if (aVal == null && bVal == null) {
          compare = 0;
        } else if (aVal == null) {
          compare = -1;
        } else if (bVal == null) {
          compare = 1;
        } else {
          compare = Comparable.compare(aVal, bVal);
        }
        return isDesc ? -compare : compare;
      });
    }

    return result;
  }

  /// 条件查询
  Future<List<Map<String, dynamic>>> queryWhere(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    var allData = _getData(table);

    if (where == null || whereArgs == null || whereArgs.isEmpty) {
      // 需要排序
      if (orderBy != null) {
        return query(table, orderBy: orderBy);
      }
      return allData;
    }

    // 简单的条件过滤
    allData = allData.where((row) {
      bool matches = true;
      final parts = where.split(' ');
      if (parts.length >= 3 && parts[1] == '=') {
        final field = parts[0];
        final expectedValue = whereArgs[0];
        matches = row[field] == expectedValue;
      }
      return matches;
    }).toList();

    // 排序
    if (orderBy != null) {
      final orderField = orderBy.replaceAll(' DESC', '').replaceAll(' ASC', '');
      final isDesc = orderBy.contains('DESC');
      allData.sort((a, b) {
        final aVal = a[orderField];
        final bVal = b[orderField];
        int compare;
        if (aVal == null && bVal == null) {
          compare = 0;
        } else if (aVal == null) {
          compare = -1;
        } else if (bVal == null) {
          compare = 1;
        } else {
          compare = Comparable.compare(aVal, bVal);
        }
        return isDesc ? -compare : compare;
      });
    }

    return allData;
  }

  /// 插入数据
  Future<void> insert(String table, Map<String, dynamic> data) async {
    final allData = _getData(table);
    allData.add(data);
    await _saveData(table, allData);
  }

  /// 更新数据
  Future<void> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final allData = _getData(table);

    for (int i = 0; i < allData.length; i++) {
      bool shouldUpdate = true;
      if (where != null && whereArgs != null && whereArgs.isNotEmpty) {
        final parts = where.split(' ');
        if (parts.length >= 3 && parts[1] == '=') {
          final field = parts[0];
          shouldUpdate = allData[i][field] == whereArgs[0];
        }
      }
      if (shouldUpdate) {
        allData[i] = {...allData[i], ...data};
      }
    }

    await _saveData(table, allData);
  }

  /// 删除数据
  Future<void> delete(String table, {String? where, List<dynamic>? whereArgs}) async {
    var allData = _getData(table);

    if (where == null || whereArgs == null || whereArgs.isEmpty) {
      allData.clear();
    } else {
      final parts = where.split(' ');
      if (parts.length >= 3 && parts[1] == '=') {
        final field = parts[0];
        allData = allData.where((row) => row[field] != whereArgs[0]).toList();
      }
    }

    await _saveData(table, allData);
  }

  /// 初始化百科数据
  Future<void> initEncyclopediaData() async {
    final existingData = await query('species');
    if (existingData.isNotEmpty) return;

    final speciesData = [
      // 蛇类
      {
        'id': '1',
        'name_chinese': '玉米蛇',
        'name_english': 'Corn Snake',
        'scientific_name': 'Pantherophis guttatus',
        'category': 'snake',
        'description': '玉米蛇是最受欢迎的宠物蛇之一，性格温顺，颜色多样。它们原产于北美，野生种群分布广泛。玉米蛇易于饲养，是新手入门的好选择。',
        'difficulty': 1,
        'lifespan': 15,
        'max_length': 180,
        'min_temp': 21,
        'max_temp': 32,
        'min_humidity': 40,
        'max_humidity': 60,
        'diet': 'carnivore',
      },
      {
        'id': '6',
        'name_chinese': '球蟒',
        'name_english': 'Ball Python',
        'scientific_name': 'Python regius',
        'category': 'snake',
        'description': '球蟒是非洲最受欢迎的宠物蛇，因受到惊吓时会缩成球状而得名。它们性格温顺，体型适中，是很好的宠物蛇选择。',
        'difficulty': 2,
        'lifespan': 30,
        'max_length': 150,
        'min_temp': 24,
        'max_temp': 32,
        'min_humidity': 50,
        'max_humidity': 60,
        'diet': 'carnivore',
      },
      {
        'id': '7',
        'name_chinese': '黑王蛇',
        'name_english': 'Black Rat Snake',
        'scientific_name': 'Pantherophis obsoletus',
        'category': 'snake',
        'description': '黑王蛇是一种北美原产的温顺蛇类，通体黑色，非常漂亮。它们体质强健，容易饲养，是进阶玩家的好选择。',
        'difficulty': 1,
        'lifespan': 20,
        'max_length': 180,
        'min_temp': 21,
        'max_temp': 32,
        'min_humidity': 40,
        'max_humidity': 60,
        'diet': 'carnivore',
      },
      {
        'id': '8',
        'name_chinese': '奶蛇',
        'name_english': 'Milk Snake',
        'scientific_name': 'Lampropeltis triangulum',
        'category': 'snake',
        'description': '奶蛇以其鲜艳的红黄黑环纹闻名，原产于美洲。它们性格温顺，体型适中，是非常受欢迎的宠物蛇。',
        'difficulty': 1,
        'lifespan': 15,
        'max_length': 120,
        'min_temp': 21,
        'max_temp': 32,
        'min_humidity': 40,
        'max_humidity': 60,
        'diet': 'carnivore',
      },
      {
        'id': '9',
        'name_chinese': '猪鼻蛇',
        'name_english': 'Hognose Snake',
        'scientific_name': 'Heterodon nasicus',
        'category': 'snake',
        'description': '猪鼻蛇因鼻子向上翘起而得名，它们性格有趣，受到威胁时会装死。原产于北美，体型小巧，适合新手。',
        'difficulty': 1,
        'lifespan': 15,
        'max_length': 80,
        'min_temp': 21,
        'max_temp': 32,
        'min_humidity': 40,
        'max_humidity': 60,
        'diet': 'carnivore',
      },
      // 守宫类
      {
        'id': '2',
        'name_chinese': '豹纹守宫',
        'name_english': 'Leopard Gecko',
        'scientific_name': 'Eublepharis macularius',
        'category': 'gecko',
        'description': '豹纹守宫是最受欢迎的宠物守宫之一，原产于巴基斯坦和印度。它们夜行性，性格温顺，容易饲养。各种基因变异使其拥有丰富的外表选择。',
        'difficulty': 1,
        'lifespan': 15,
        'max_length': 25,
        'min_temp': 24,
        'max_temp': 32,
        'min_humidity': 30,
        'max_humidity': 40,
        'diet': 'carnivore',
      },
      {
        'id': '10',
        'name_chinese': '睫角守宫',
        'name_english': 'Crested Gecko',
        'scientific_name': 'Correlophus ciliatus',
        'category': 'gecko',
        'description': '睫角守宫原产于新喀里多尼亚，因眼睛上方有睫毛状突起而得名。它们不需要加热设备，饲养简单，是非常好的宠物守宫。',
        'difficulty': 1,
        'lifespan': 15,
        'max_length': 20,
        'min_temp': 18,
        'max_temp': 28,
        'min_humidity': 60,
        'max_humidity': 80,
        'diet': 'omnivore',
      },
      {
        'id': '11',
        'name_chinese': '巨人守宫',
        'name_english': 'Giant Gecko',
        'scientific_name': 'Rhacodactylus leachianus',
        'category': 'gecko',
        'description': '巨人守宫是世界上最大的守宫之一，原产于新喀里多尼亚。它们体型魁梧，性格相对温顺，是高端守宫玩家的首选。',
        'difficulty': 2,
        'lifespan': 20,
        'max_length': 40,
        'min_temp': 18,
        'max_temp': 28,
        'min_humidity': 60,
        'max_humidity': 80,
        'diet': 'omnivore',
      },
      // 蜥蜴类
      {
        'id': '3',
        'name_chinese': '绿鬣蜥',
        'name_english': 'Green Iguana',
        'scientific_name': 'Iguana iguana',
        'category': 'lizard',
        'description': '绿鬣蜥是大型蜥蜴，原产于中美洲和南美洲。它们需要较大的饲养空间和精心的照顾。成年后体型可达1.5米以上。',
        'difficulty': 3,
        'lifespan': 20,
        'max_length': 200,
        'min_temp': 24,
        'max_temp': 35,
        'min_humidity': 60,
        'max_humidity': 80,
        'diet': 'herbivore',
      },
      {
        'id': '5',
        'name_chinese': '鬃狮蜥',
        'name_english': 'Bearded Dragon',
        'scientific_name': 'Pogona vitticeps',
        'category': 'lizard',
        'description': '鬃狮蜥是澳洲特有的蜥蜴，性格温顺，是最受欢迎的宠物蜥蜴之一。它们日行性，需要充足的UVB光照。杂食性，适合新手饲养。',
        'difficulty': 1,
        'lifespan': 15,
        'max_length': 60,
        'min_temp': 24,
        'max_temp': 40,
        'min_humidity': 30,
        'max_humidity': 40,
        'diet': 'omnivore',
      },
      {
        'id': '12',
        'name_chinese': '蓝舌石龙子',
        'name_english': 'Blue-tongued Skink',
        'scientific_name': 'Tiliqua scincoides',
        'category': 'lizard',
        'description': '蓝舌石龙子因舌头呈蓝色而得名，原产于澳大利亚。它们性格温顺，体型适中，是很好的家庭宠物。',
        'difficulty': 1,
        'lifespan': 20,
        'max_length': 50,
        'min_temp': 24,
        'max_temp': 35,
        'min_humidity': 40,
        'max_humidity': 60,
        'diet': 'omnivore',
      },
      {
        'id': '13',
        'name_chinese': '高冠变色龙',
        'name_english': 'Veiled Chameleon',
        'scientific_name': 'Chamaeleo calyptratus',
        'category': 'lizard',
        'description': '高冠变色龙头部有高耸的头冠，原产于也门。它们以其出色的变色能力闻名，需要较高的饲养难度。',
        'difficulty': 3,
        'lifespan': 8,
        'max_length': 60,
        'min_temp': 24,
        'max_temp': 32,
        'min_humidity': 50,
        'max_humidity': 70,
        'diet': 'omnivore',
      },
      // 龟类 - 水龟
      {
        'id': '4',
        'name_chinese': '红耳龟',
        'name_english': 'Red-eared Slider',
        'scientific_name': 'Trachemys scripta elegans',
        'category': 'turtle',
        'sub_category': 'aquatic',
        'description': '红耳龟是最常见的宠物龟，原产于美国。它们水栖，需要水质管理和充足的晒背空间。杂食性，幼体偏肉食，成年后偏素食。',
        'difficulty': 2,
        'lifespan': 40,
        'max_length': 30,
        'min_temp': 20,
        'max_temp': 32,
        'min_humidity': 0,
        'max_humidity': 0,
        'diet': 'omnivore',
      },
      {
        'id': '14',
        'name_chinese': '麝香龟',
        'name_english': 'Musk Turtle',
        'scientific_name': 'Sternotherus odoratus',
        'category': 'turtle',
        'sub_category': 'aquatic',
        'description': '麝香龟体型小巧，原产于北美洲。它们水性好，会释放麝香味道来驱赶天敌。适合小水体饲养。',
        'difficulty': 2,
        'lifespan': 30,
        'max_length': 15,
        'min_temp': 20,
        'max_temp': 30,
        'min_humidity': 0,
        'max_humidity': 0,
        'diet': 'omnivore',
      },
      {
        'id': '15',
        'name_chinese': '地图龟',
        'name_english': 'Map Turtle',
        'scientific_name': 'Graptemys geographica',
        'category': 'turtle',
        'sub_category': 'aquatic',
        'description': '地图龟因其背甲上的花纹像地图而得名，原产于美国。它们水性好，需要较大的饲养空间。',
        'difficulty': 2,
        'lifespan': 30,
        'max_length': 25,
        'min_temp': 20,
        'max_temp': 30,
        'min_humidity': 0,
        'max_humidity': 0,
        'diet': 'omnivore',
      },
      {
        'id': '21',
        'name_chinese': '草龟',
        'name_english': 'Chinese Pond Turtle',
        'scientific_name': 'Mauremys reevesii',
        'category': 'turtle',
        'sub_category': 'aquatic',
        'description': '草龟是中国本土的原生龟种，又称乌龟。它们适应性强，价格亲民，是很多龟友的入门选择。',
        'difficulty': 1,
        'lifespan': 50,
        'max_length': 28,
        'min_temp': 15,
        'max_temp': 32,
        'min_humidity': 0,
        'max_humidity': 0,
        'diet': 'omnivore',
      },
      {
        'id': '22',
        'name_chinese': '巴西龟',
        'name_english': 'Yellow-bellied Slider',
        'scientific_name': 'Trachemys scripta scripta',
        'category': 'turtle',
        'sub_category': 'aquatic',
        'description': '巴西龟是最常见的宠物龟之一，原产于美国南部。它们活泼好动，适应性强，非常适合新手饲养。',
        'difficulty': 1,
        'lifespan': 40,
        'max_length': 30,
        'min_temp': 20,
        'max_temp': 32,
        'min_humidity': 0,
        'max_humidity': 0,
        'diet': 'omnivore',
      },
      // 龟类 - 半水龟
      {
        'id': '23',
        'name_chinese': '黄缘闭壳龟',
        'name_english': 'Chinese Box Turtle',
        'scientific_name': 'Cuora flavomarginata',
        'category': 'turtle',
        'sub_category': 'semi_aquatic',
        'description': '黄缘闭壳龟是中国四大闭壳龟之一，因其金色的边框而得名。它们性格温顺，互动性好，是非常受欢迎的国龟。',
        'difficulty': 2,
        'lifespan': 50,
        'max_length': 20,
        'min_temp': 18,
        'max_temp': 32,
        'min_humidity': 50,
        'max_humidity': 70,
        'diet': 'omnivore',
      },
      {
        'id': '24',
        'name_chinese': '锯缘摄龟',
        'name_english': 'Keeled Box Turtle',
        'scientific_name': 'Pyxidea mouhotii',
        'category': 'turtle',
        'sub_category': 'semi_aquatic',
        'description': '锯缘摄龟因背甲边缘呈锯齿状而得名。它们半水栖，性格活泼，互动性较好。',
        'difficulty': 2,
        'lifespan': 30,
        'max_length': 20,
        'min_temp': 18,
        'max_temp': 32,
        'min_humidity': 50,
        'max_humidity': 70,
        'diet': 'omnivore',
      },
      {
        'id': '25',
        'name_chinese': '三线闭壳龟',
        'name_english': 'Three-striped Box Turtle',
        'scientific_name': 'Cuora trifasciata',
        'category': 'turtle',
        'sub_category': 'semi_aquatic',
        'description': '三线闭壳龟又称金钱龟，是中国传统名贵龟种。它们背甲有三条明显的黑线，价值较高。',
        'difficulty': 3,
        'lifespan': 60,
        'max_length': 25,
        'min_temp': 18,
        'max_temp': 30,
        'min_humidity': 50,
        'max_humidity': 70,
        'diet': 'omnivore',
      },
      {
        'id': '26',
        'name_chinese': '日本石龟',
        'name_english': 'Japanese Pond Turtle',
        'scientific_name': 'Mauremys japonica',
        'category': 'turtle',
        'sub_category': 'semi_aquatic',
        'description': '日本石龟原产于日本，是一种中小型半水龟。它们性格温和，外形清秀。',
        'difficulty': 2,
        'lifespan': 40,
        'max_length': 20,
        'min_temp': 15,
        'max_temp': 30,
        'min_humidity': 40,
        'max_humidity': 60,
        'diet': 'omnivore',
      },
      // 龟类 - 陆龟
      {
        'id': '27',
        'name_chinese': '辐射陆龟',
        'name_english': 'Radiated Tortoise',
        'scientific_name': 'Astrochelys radiata',
        'category': 'turtle',
        'sub_category': 'terrestrial',
        'description': '辐射陆龟是马达加斯加的特有物种，以其放射状花纹的背甲闻名。它们是世界上最美丽的陆龟之一。',
        'difficulty': 3,
        'lifespan': 80,
        'max_length': 40,
        'min_temp': 22,
        'max_temp': 35,
        'min_humidity': 30,
        'max_humidity': 50,
        'diet': 'herbivore',
      },
      {
        'id': '28',
        'name_chinese': '豹纹陆龟',
        'name_english': 'Leopard Tortoise',
        'scientific_name': 'Stigmochelys pardalis',
        'category': 'turtle',
        'sub_category': 'terrestrial',
        'description': '豹纹陆龟是非洲的大型陆龟，背甲有豹纹状花纹。它们性格温顺，是受欢迎的宠物陆龟。',
        'difficulty': 2,
        'lifespan': 80,
        'max_length': 60,
        'min_temp': 22,
        'max_temp': 35,
        'min_humidity': 30,
        'max_humidity': 50,
        'diet': 'herbivore',
      },
      {
        'id': '29',
        'name_chinese': '赫曼陆龟',
        'name_english': 'Hermann\'s Tortoise',
        'scientific_name': 'Testudo hermanni',
        'category': 'turtle',
        'sub_category': 'terrestrial',
        'description': '赫曼陆龟是欧洲最常见的宠物陆龟之一，体型适中，性格活泼。它们是很好的入门级陆龟。',
        'difficulty': 2,
        'lifespan': 50,
        'max_length': 25,
        'min_temp': 18,
        'max_temp': 32,
        'min_humidity': 30,
        'max_humidity': 50,
        'diet': 'herbivore',
      },
      {
        'id': '30',
        'name_chinese': '印度星龟',
        'name_english': 'Indian Star Tortoise',
        'scientific_name': 'Geochelone elegans',
        'category': 'turtle',
        'sub_category': 'terrestrial',
        'description': '印度星龟以其背甲上放射状的星形花纹闻名，原产于印度。它们体型小巧，非常受欢迎。',
        'difficulty': 2,
        'lifespan': 50,
        'max_length': 30,
        'min_temp': 22,
        'max_temp': 35,
        'min_humidity': 40,
        'max_humidity': 60,
        'diet': 'herbivore',
      },
      {
        'id': '31',
        'name_chinese': '红腿陆龟',
        'name_english': 'Red-footed Tortoise',
        'scientific_name': 'Chelonoidis carbonarius',
        'category': 'turtle',
        'sub_category': 'terrestrial',
        'description': '红腿陆龟原产于南美洲，因四肢呈红色而得名。它们性格活泼，互动性好，是受欢迎的宠物陆龟。',
        'difficulty': 2,
        'lifespan': 60,
        'max_length': 45,
        'min_temp': 22,
        'max_temp': 35,
        'min_humidity': 50,
        'max_humidity': 70,
        'diet': 'omnivore',
      },
      // 两栖类
      {
        'id': '16',
        'name_chinese': '角蛙',
        'name_english': 'Horned Frog',
        'scientific_name': 'Ceratophrys ornata',
        'category': 'amphibian',
        'description': '角蛙因眼睛上方有角状突起而得名，原产于南美洲。它们体型圆胖，食量惊人，是非常受欢迎的宠物蛙。',
        'difficulty': 1,
        'lifespan': 10,
        'max_length': 15,
        'min_temp': 20,
        'max_temp': 30,
        'min_humidity': 60,
        'max_humidity': 80,
        'diet': 'carnivore',
      },
      {
        'id': '17',
        'name_chinese': '蝾螈',
        'name_english': 'Axolotl',
        'scientific_name': 'Ambystoma mexicanum',
        'category': 'amphibian',
        'description': '蝾螈又称六角龙鱼，原产于墨西哥。它们一生保持幼体形态，以其独特的外表和萌态深受喜爱。',
        'difficulty': 2,
        'lifespan': 15,
        'max_length': 30,
        'min_temp': 16,
        'max_temp': 20,
        'min_humidity': 0,
        'max_humidity': 0,
        'diet': 'carnivore',
      },
      // 蜘蛛类
      {
        'id': '18',
        'name_chinese': '智利红玫瑰',
        'name_english': 'Chilean Rose Tarantula',
        'scientific_name': 'Grammostola rosea',
        'category': 'arachnid',
        'description': '智利红玫瑰是经典的宠物捕鸟蛛，原产于智利。它们性格温顺，行动缓慢，非常适合新手饲养。',
        'difficulty': 1,
        'lifespan': 20,
        'max_length': 15,
        'min_temp': 20,
        'max_temp': 30,
        'min_humidity': 40,
        'max_humidity': 60,
        'diet': 'carnivore',
      },
      {
        'id': '19',
        'name_chinese': '墨西哥红膝',
        'name_english': 'Mexican Red Knee',
        'scientific_name': 'Brachypelma smithi',
        'category': 'arachnid',
        'description': '墨西哥红膝是捕鸟蛛中的明星品种，以其鲜艳的红膝关节闻名。它们性格温顺，寿命长，是经典宠物蜘蛛。',
        'difficulty': 1,
        'lifespan': 25,
        'max_length': 17,
        'min_temp': 20,
        'max_temp': 30,
        'min_humidity': 40,
        'max_humidity': 60,
        'diet': 'carnivore',
      },
      {
        'id': '20',
        'name_chinese': '巴西白膝',
        'name_english': 'White Knee Tarantula',
        'scientific_name': 'Brachypelma albopilosum',
        'category': 'arachnid',
        'description': '巴西白膝以其白色的膝盖毛发和卷曲的触肢毛闻名，原产于中美洲。它们性格温顺，非常适合作为第一只捕鸟蛛。',
        'difficulty': 1,
        'lifespan': 20,
        'max_length': 16,
        'min_temp': 20,
        'max_temp': 30,
        'min_humidity': 50,
        'max_humidity': 70,
        'diet': 'carnivore',
      },
    ];

    for (var species in speciesData) {
      await insert('species', species);
    }
  }

  Future<void> close() async {}
}
