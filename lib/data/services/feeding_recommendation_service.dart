import '../models/weather.dart';

/// 智能喂食推荐服务
class FeedingRecommendationService {
  /// 获取喂食推荐
  static FeedingRecommendation getRecommendation({
    required double temperature,
    String? speciesType,
  }) {
    // 根据物种类型调整推荐
    int tempOffset = 0;

    if (speciesType != null) {
      switch (speciesType.toLowerCase()) {
        case 'turtle':
        case '龟':
          // 龟类耐寒性稍好
          tempOffset = -2;
          break;
        case 'snake':
        case '蛇':
          // 蛇类需要较高温度
          tempOffset = 2;
          break;
        case 'lizard':
        case '蜥蜴':
          // 蜥蜴类
          tempOffset = 0;
          break;
        case 'gecko':
        case '守宫':
          // 守宫类
          tempOffset = 0;
          break;
      }
    }

    final adjustedTemp = temperature + tempOffset;
    return FeedingRecommendation.fromTemperature(adjustedTemp);
  }

  /// 从天气数据获取推荐
  static FeedingRecommendation getRecommendationFromWeather(
    WeatherData weather, {
    String? speciesType,
  }) {
    return getRecommendation(
      temperature: weather.temperature,
      speciesType: speciesType,
    );
  }

  /// 获取未来几天的喂食计划
  static List<FeedingPlan> getFeedingPlan({
    required WeatherData currentWeather,
    List<ForecastDay>? forecast,
    String? speciesType,
  }) {
    final plans = <FeedingPlan>[];

    // 今天的推荐
    final today = FeedingPlan(
      date: DateTime.now(),
      recommendation: getRecommendationFromWeather(currentWeather, speciesType: speciesType),
      weather: currentWeather,
    );
    plans.add(today);

    // 未来几天的推荐
    if (forecast != null) {
      for (var day in forecast.take(5)) {
        final plan = FeedingPlan(
          date: day.date,
          recommendation: day.feedingRecommendation,
          forecast: day,
        );
        plans.add(plan);
      }
    }

    return plans;
  }

  /// 生成喂食提醒消息
  static List<String> generateReminders({
    required WeatherData currentWeather,
    List<ForecastDay>? forecast,
    String? speciesType,
  }) {
    final reminders = <String>[];

    final recommendation = getRecommendationFromWeather(
      currentWeather,
      speciesType: speciesType,
    );

    // 今日提醒
    if (!recommendation.canFeed) {
      reminders.add('⚠️ 今日不建议喂食: ${recommendation.warning ?? recommendation.reason}');
    } else if (recommendation.suggestedInterval == 1) {
      reminders.add('✅ 今日适合喂食，温度适宜');
    }

    // 未来天气提醒
    if (forecast != null) {
      // 检查明天是否适合喂食
      if (forecast.isNotEmpty) {
        final tomorrow = forecast.first;
        final tomorrowRec = tomorrow.feedingRecommendation;

        if (!tomorrowRec.canFeed) {
          reminders.add('📅 明日天气提醒: ${tomorrowRec.reason}，建议${tomorrowRec.suggestedInterval}天后喂食');
        } else {
          reminders.add('📅 明日可正常喂食');
        }
      }

      // 检查是否有温度骤变
      for (var i = 0; i < forecast.length - 1; i++) {
        final tempDiff = forecast[i + 1].maxTemp - forecast[i].maxTemp;
        if (tempDiff > 10) {
          reminders.add('🌡️ 温度预警: ${forecast[i + 1].date.month}/${forecast[i + 1].date.day}温度骤降${tempDiff.toStringAsFixed(0)}°C，建议减少喂食');
        }
      }

      // 找出最适合喂食的日期
      final bestDays = forecast.where((d) => d.feedingRecommendation.canFeed).toList();
      if (bestDays.isNotEmpty && !recommendation.canFeed) {
        final nextBest = bestDays.first;
        reminders.add('📆 建议喂食日期: ${nextBest.date.month}/${nextBest.date.day}，温度${nextBest.maxTemp.toStringAsFixed(0)}°C');
      }
    }

    return reminders;
  }

  /// 获取爬宠的适宜温度范围
  static Map<String, double> getOptimalTempRange(String speciesType) {
    switch (speciesType.toLowerCase()) {
      case 'turtle':
      case '龟':
        return {'min': 22, 'max': 30, 'digestion': 25};
      case 'snake':
      case '蛇':
        return {'min': 25, 'max': 32, 'digestion': 28};
      case 'lizard':
      case '蜥蜴':
        return {'min': 25, 'max': 35, 'digestion': 30};
      case 'gecko':
      case '守宫':
        return {'min': 24, 'max': 32, 'digestion': 28};
      default:
        return {'min': 25, 'max': 32, 'digestion': 28};
    }
  }
}

/// 喂食计划
class FeedingPlan {
  final DateTime date;
  final FeedingRecommendation recommendation;
  final WeatherData? weather;
  final ForecastDay? forecast;

  FeedingPlan({
    required this.date,
    required this.recommendation,
    this.weather,
    this.forecast,
  });

  double? get temperature {
    if (weather != null) return weather!.temperature;
    if (forecast != null) return forecast!.maxTemp;
    return null;
  }
}
