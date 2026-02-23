import '../local/database_helper.dart';
import '../models/habitat.dart';
import '../models/reptile.dart';

class HabitatRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // 保存环境设置
  Future<void> saveEnvironment(HabitatEnvironment environment) async {
    // 检查是否已存在
    final existing = await getEnvironment(environment.reptileId);
    if (existing != null) {
      await _dbHelper.update(
        'habitats',
        environment.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'reptile_id = ?',
        whereArgs: [environment.reptileId],
      );
    } else {
      await _dbHelper.insert('habitats', environment.toMap());
    }
  }

  // 获取某宠物的环境设置
  Future<HabitatEnvironment?> getEnvironment(String reptileId) async {
    final result = await _dbHelper.queryWhere(
      'habitats',
      where: 'reptile_id = ?',
      whereArgs: [reptileId],
    );
    if (result.isEmpty) return null;
    return HabitatEnvironment.fromMap(result.first);
  }

  // 获取所有宠物的环境设置
  Future<List<HabitatEnvironment>> getAllEnvironments() async {
    final result = await _dbHelper.query('habitats', orderBy: 'reptile_name ASC');
    return result.map((map) => HabitatEnvironment.fromMap(map)).toList();
  }

  // 删除环境设置
  Future<void> deleteEnvironment(String reptileId) async {
    await _dbHelper.delete(
      'habitats',
      where: 'reptile_id = ?',
      whereArgs: [reptileId],
    );
  }

  // 获取物种的标准环境参数
  Future<HabitatStandard?> getStandard(String speciesId) async {
    // 从 species 表获取基本参数
    final speciesResult = await _dbHelper.queryWhere(
      'species',
      where: 'id = ?',
      whereArgs: [speciesId],
    );

    if (speciesResult.isEmpty) return null;

    final species = speciesResult.first;

    // 根据物种类别返回标准参数
    return HabitatStandard(
      speciesId: speciesId,
      minTemp: (species['min_temp'] ?? 20).toDouble(),
      maxTemp: (species['max_temp'] ?? 30).toDouble(),
      idealTemp: ((species['min_temp'] ?? 20) + (species['max_temp'] ?? 30)) / 2,
      minHumidity: (species['min_humidity'] ?? 30).toDouble(),
      maxHumidity: (species['max_humidity'] ?? 70).toDouble(),
      idealHumidity: ((species['min_humidity'] ?? 30) + (species['max_humidity'] ?? 70)) / 2,
      idealUV: _getIdealUV(species['category']),
      suitableSubstrates: _getSuitableSubstrates(species['category']),
      lightingNeed: _getLightingNeed(species['category']),
      minTankSize: _getMinTankSize(species['category']),
      heatingRecommendation: _getHeatingRecommendation(species['category']),
      ventilationNeed: '需要适量通风',
    );
  }

  // 计算环境评分
  HabitatScore calculateScore(HabitatEnvironment environment, HabitatStandard standard) {
    final suggestions = <HabitatSuggestion>[];

    // 温度评分
    double tempScore = _calculateTemperatureScore(environment.temperature, standard, suggestions);

    // 湿度评分
    double humidityScore = _calculateHumidityScore(environment.humidity, standard, suggestions);

    // UV评分
    double uvScore = _calculateUVScore(environment.uvIndex, standard, suggestions);

    // 空间评分
    double spaceScore = _calculateSpaceScore(environment.tankSize, standard, suggestions);

    // 垫材建议
    if (environment.substrate != null) {
      _checkSubstrate(environment.substrate!, standard, suggestions);
    }

    // 计算综合评分
    double overall = (tempScore + humidityScore + uvScore + spaceScore) / 4;

    return HabitatScore(
      temperatureScore: tempScore,
      humidityScore: humidityScore,
      uvScore: uvScore,
      spaceScore: spaceScore,
      overallScore: overall,
      suggestions: suggestions,
    );
  }

  // 生成改进建议
  List<HabitatSuggestion> generateSuggestions(HabitatEnvironment environment, HabitatStandard standard) {
    final suggestions = <HabitatSuggestion>[];
    _calculateTemperatureScore(environment.temperature, standard, suggestions);
    _calculateHumidityScore(environment.humidity, standard, suggestions);
    _calculateUVScore(environment.uvIndex, standard, suggestions);
    _calculateSpaceScore(environment.tankSize, standard, suggestions);
    if (environment.substrate != null) {
      _checkSubstrate(environment.substrate!, standard, suggestions);
    }
    return suggestions;
  }

  // 获取用户的宠物列表
  Future<List<Reptile>> getUserReptiles() async {
    final result = await _dbHelper.query('reptiles', orderBy: 'name ASC');
    return result.map((map) => Reptile.fromMap(map)).toList();
  }

  // 辅助方法：温度评分
  double _calculateTemperatureScore(double temp, HabitatStandard standard, List<HabitatSuggestion> suggestions) {
    if (temp >= standard.idealTemp - 2 && temp <= standard.idealTemp + 2) {
      return 100;
    } else if (temp >= standard.minTemp && temp <= standard.maxTemp) {
      // 在范围内但不在理想范围
      double distance = (temp - standard.idealTemp).abs();
      return (100 - distance * 10).clamp(60, 90);
    } else if (temp < standard.minTemp) {
      double diff = standard.minTemp - temp;
      suggestions.add(HabitatSuggestion(
        title: '温度过低',
        description: '当前温度${temp.toStringAsFixed(1)}°C，低于适宜温度。建议使用加热设备将温度提升至${standard.idealTemp.toStringAsFixed(0)}°C左右。',
        category: 'temperature',
        priority: diff > 5 ? 'high' : 'medium',
      ));
      return (50 - diff * 5).clamp(0, 50);
    } else {
      double diff = temp - standard.maxTemp;
      suggestions.add(HabitatSuggestion(
        title: '温度过高',
        description: '当前温度${temp.toStringAsFixed(1)}°C，高于适宜温度。注意通风和降温。',
        category: 'temperature',
        priority: diff > 5 ? 'high' : 'medium',
      ));
      return (50 - diff * 5).clamp(0, 50);
    }
  }

  // 辅助方法：湿度评分
  double _calculateHumidityScore(double humidity, HabitatStandard standard, List<HabitatSuggestion> suggestions) {
    double idealHumidity = standard.idealHumidity ?? ((standard.minHumidity + standard.maxHumidity) / 2);

    if (humidity >= idealHumidity - 10 && humidity <= idealHumidity + 10) {
      return 100;
    } else if (humidity >= standard.minHumidity && humidity <= standard.maxHumidity) {
      double distance = (humidity - idealHumidity).abs();
      return (100 - distance * 2).clamp(60, 90);
    } else if (humidity < standard.minHumidity) {
      suggestions.add(HabitatSuggestion(
        title: '湿度过低',
        description: '当前湿度${humidity.toStringAsFixed(0)}%，过于干燥。建议增加水盆或使用加湿设备。',
        category: 'humidity',
        priority: 'medium',
      ));
      return 50;
    } else {
      suggestions.add(HabitatSuggestion(
        title: '湿度过高',
        description: '当前湿度${humidity.toStringAsFixed(0)}%，过于潮湿。注意通风以防止霉菌滋生。',
        category: 'humidity',
        priority: 'medium',
      ));
      return 50;
    }
  }

  // 辅助方法：UV评分
  double _calculateUVScore(double? uvIndex, HabitatStandard standard, List<HabitatSuggestion> suggestions) {
    if (standard.idealUV == null || standard.idealUV == 0) {
      return 100; // 不需要UV的物种
    }

    if (uvIndex == null || uvIndex == 0) {
      suggestions.add(HabitatSuggestion(
        title: '缺少UVB照射',
        description: '${standard.lightingNeed}。建议安装UVB灯管以促进钙质吸收。',
        category: 'uv',
        priority: 'high',
      ));
      return 30;
    }

    if (uvIndex >= standard.idealUV! * 0.7 && uvIndex <= standard.idealUV! * 1.3) {
      return 100;
    } else if (uvIndex < standard.idealUV! * 0.7) {
      suggestions.add(HabitatSuggestion(
        title: 'UVB不足',
        description: '当前UV指数${uvIndex.toStringAsFixed(1)}，建议增加至${standard.idealUV!.toStringAsFixed(0)}左右。',
        category: 'uv',
        priority: 'medium',
      ));
      return 50;
    } else {
      suggestions.add(HabitatSuggestion(
        title: 'UVB过强',
        description: '当前UV指数过高，可能会对宠物造成伤害。',
        category: 'uv',
        priority: 'low',
      ));
      return 60;
    }
  }

  // 辅助方法：空间评分
  double _calculateSpaceScore(double? tankSize, HabitatStandard standard, List<HabitatSuggestion> suggestions) {
    if (tankSize == null) {
      suggestions.add(HabitatSuggestion(
        title: '未设置饲养箱尺寸',
        description: '请设置饲养箱大小以获得更准确的评分。建议最小${standard.minTankSize}升。',
        category: 'space',
        priority: 'low',
      ));
      return 70;
    }

    if (tankSize >= standard.minTankSize) {
      return 100;
    } else {
      double ratio = tankSize / standard.minTankSize;
      suggestions.add(HabitatSuggestion(
        title: '饲养箱偏小',
        description: '当前${tankSize.toInt()}升，建议使用至少${standard.minTankSize}升的饲养箱。',
        category: 'space',
        priority: ratio < 0.5 ? 'high' : 'medium',
      ));
      return (ratio * 100).clamp(30, 70).toDouble();
    }
  }

  // 辅助方法：检查垫材
  void _checkSubstrate(String substrate, HabitatStandard standard, List<HabitatSuggestion> suggestions) {
    if (standard.suitableSubstrates.contains(substrate)) {
      return;
    }
    suggestions.add(HabitatSuggestion(
      title: '垫材不适合',
      description: '当前垫材可能不适合该物种。建议使用: ${standard.suitableSubstrates.join("、")}。',
      category: 'substrate',
      priority: 'medium',
    ));
  }

  // 获取理想UV值
  double? _getIdealUV(String? category) {
    switch (category) {
      case 'lizard':
        return 8.0;
      case 'turtle':
        return 5.0;
      case 'gecko':
        return 5.0;
      case 'snake':
        return 3.0;
      default:
        return null;
    }
  }

  // 获取适合的垫材
  List<String> _getSuitableSubstrates(String? category) {
    switch (category) {
      case 'snake':
        return ['reptile_carpet', 'paper_towel', 'bark'];
      case 'lizard':
        return ['coconut_fiber', 'soil_mix', 'sand'];
      case 'turtle':
        return ['gravel', 'soil_mix'];
      case 'gecko':
        return ['coconut_fiber', 'reptile_carpet', 'paper_towel'];
      case 'amphibian':
        return ['coconut_fiber', 'soil_mix'];
      default:
        return ['paper_towel', 'reptile_carpet'];
    }
  }

  // 获取照明需求
  String _getLightingNeed(String? category) {
    switch (category) {
      case 'lizard':
        return '需要充足UVB照射';
      case 'turtle':
        return '需要适量UVB照射';
      case 'gecko':
        return '需要适量UVB（夜行性可较少）';
      case 'snake':
        return '需要少量UVB';
      default:
        return '需要适量UVB';
    }
  }

  // 获取最小饲养箱尺寸
  int _getMinTankSize(String? category) {
    switch (category) {
      case 'snake':
        return 60;
      case 'lizard':
        return 100;
      case 'turtle':
        return 80;
      case 'gecko':
        return 40;
      default:
        return 60;
    }
  }

  // 获取加热建议
  String? _getHeatingRecommendation(String? category) {
    switch (category) {
      case 'snake':
        return '推荐使用陶瓷加热器或加热垫，配合温控使用';
      case 'lizard':
        return '推荐使用汞灯或卤素灯提供热点温度';
      case 'turtle':
        return '推荐使用水中加热器和UVB灯';
      default:
        return '根据物种特性选择合适的加热设备';
    }
  }
}
