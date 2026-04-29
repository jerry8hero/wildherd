import '../../constants/feeding_constants.dart';

/// 天气数据模型
class WeatherData {
  final String location;
  final double temperature; // 当前温度(°C)
  final double humidity; // 当前湿度(%)
  final String condition; // 天气状况: sunny, cloudy, rainy, etc.
  final double? minTemp; // 最低温度
  final double? maxTemp; // 最高温度
  final DateTime timestamp;
  final List<ForecastDay>? forecast; // 未来天气预报

  WeatherData({
    required this.location,
    required this.temperature,
    required this.humidity,
    required this.condition,
    this.minTemp,
    this.maxTemp,
    required this.timestamp,
    this.forecast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      location: json['location'] ?? '',
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      condition: json['condition'] ?? 'unknown',
      minTemp: json['minTemp']?.toDouble(),
      maxTemp: json['maxTemp']?.toDouble(),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      forecast: (json['forecast'] as List?)
          ?.map((f) => ForecastDay.fromJson(f))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'temperature': temperature,
      'humidity': humidity,
      'condition': condition,
      'minTemp': minTemp,
      'maxTemp': maxTemp,
      'timestamp': timestamp.toIso8601String(),
      'forecast': forecast?.map((f) => f.toJson()).toList(),
    };
  }

  // 获取天气图标名称（用于Material Icons）
  String get iconName {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return 'wb_sunny';
      case 'cloudy':
      case 'partly_cloudy':
        return 'cloud';
      case 'rainy':
      case 'rain':
        return 'grain';
      case 'stormy':
      case 'thunderstorm':
        return 'thunderstorm';
      case 'snowy':
        return 'ac_unit';
      case 'foggy':
      case 'fog':
        return 'foggy';
      default:
        return 'wb_cloudy';
    }
  }

  // 判断是否适合喂食（基于温度）
  FeedingRecommendation get feedingRecommendation {
    return FeedingRecommendation.fromWeather(this);
  }
}

/// 天气预报（单天）
class ForecastDay {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String condition;
  final double? humidity;

  ForecastDay({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.condition,
    this.humidity,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      date: DateTime.parse(json['date']),
      minTemp: (json['minTemp'] ?? 0).toDouble(),
      maxTemp: (json['maxTemp'] ?? 0).toDouble(),
      condition: json['condition'] ?? 'unknown',
      humidity: json['humidity']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'minTemp': minTemp,
      'maxTemp': maxTemp,
      'condition': condition,
      'humidity': humidity,
    };
  }

  FeedingRecommendation get feedingRecommendation {
    final avgTemp = (minTemp + maxTemp) / 2;
    return FeedingRecommendation.fromTemperature(avgTemp);
  }
}

/// 喂食推荐
class FeedingRecommendation {
  final bool canFeed; // 是否可以喂食
  final String title; // 标题
  final String reason; // 原因
  final int suggestedInterval; // 建议喂食间隔(天)
  final String? warning; // 警告信息

  FeedingRecommendation({
    required this.canFeed,
    required this.title,
    required this.reason,
    required this.suggestedInterval,
    this.warning,
  });

  // 基于天气数据生成推荐
  factory FeedingRecommendation.fromWeather(WeatherData weather) {
    return FeedingRecommendation.fromTemperature(weather.temperature);
  }

  // 基于温度生成推荐
  factory FeedingRecommendation.fromTemperature(double temp) {
    // 爬宠消化最佳温度通常在25-35°C
    if (temp < FeedingConstants.tempStopFeeding) {
      return FeedingRecommendation(
        canFeed: false,
        title: '不建议喂食',
        reason: '温度过低，爬宠消化系统运作缓慢',
        suggestedInterval: FeedingConstants.intervalCold,
        warning: '低于18°C时应停止喂食，避免食物在肠道中腐烂',
      );
    } else if (temp < FeedingConstants.tempCaution) {
      return FeedingRecommendation(
        canFeed: false,
        title: '谨慎喂食',
        reason: '温度偏低，消化效率较低',
        suggestedInterval: FeedingConstants.intervalCool,
        warning: '建议等温度回升后再喂食',
      );
    } else if (temp < FeedingConstants.tempNormalLow) {
      return FeedingRecommendation(
        canFeed: true,
        title: '可以喂食',
        reason: '温度适宜，但消化较慢',
        suggestedInterval: FeedingConstants.intervalCool,
      );
    } else if (temp <= FeedingConstants.tempOptimalHigh) {
      return FeedingRecommendation(
        canFeed: true,
        title: '适合喂食',
        reason: '温度适宜，消化系统活跃',
        suggestedInterval: FeedingConstants.intervalNormal,
      );
    } else if (temp <= FeedingConstants.tempWarning) {
      return FeedingRecommendation(
        canFeed: true,
        title: '可以喂食',
        reason: '温度较高，注意保持水分',
        suggestedInterval: FeedingConstants.intervalNormal,
      );
    } else {
      return FeedingRecommendation(
        canFeed: false,
        title: '不建议喂食',
        reason: '温度过高，爬宠可能中暑',
        suggestedInterval: FeedingConstants.intervalNormal,
        warning: '高于35°C时应减少活动，避免喂食',
      );
    }
  }
}
