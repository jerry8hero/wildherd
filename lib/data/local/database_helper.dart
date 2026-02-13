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
        'id': '4',
        'name_chinese': '红耳龟',
        'name_english': 'Red-eared Slider',
        'scientific_name': 'Trachemys scripta elegans',
        'category': 'turtle',
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
    ];

    for (var species in speciesData) {
      await insert('species', species);
    }
  }

  Future<void> close() async {}
}
