// 天气对宠物状态影响服务

import '../models/weather.dart';
import '../models/electronic_pet.dart';

/// 天气对宠物的影响结果
class WeatherEffect {
  final int happinessChange;  // 快乐度变化
  final int healthChange;     // 健康度变化
  final String message;        // 提示信息
  final PetMood moodChange;   // 心情变化

  const WeatherEffect({
    required this.happinessChange,
    required this.healthChange,
    required this.message,
    this.moodChange = PetMood.normal,
  });
}

/// 宠物天气服务
class PetWeatherService {
  /// 获取天气对宠物的影响
  static WeatherEffect getWeatherEffect(WeatherData weather) {
    final condition = weather.condition.toLowerCase();
    final temperature = weather.temperature;

    // 基于天气状况计算影响
    switch (condition) {
      case 'sunny':
      case 'clear':
        return WeatherEffect(
          happinessChange: 5,
          healthChange: 0,
          message: '阳光明媚！宠物心情愉快。',
          moodChange: PetMood.happy,
        );

      case 'cloudy':
      case 'partly_cloudy':
        return WeatherEffect(
          happinessChange: 0,
          healthChange: 0,
          message: '天气多云，对宠物没有影响。',
        );

      case 'rainy':
      case 'rain':
        return WeatherEffect(
          happinessChange: -5,
          healthChange: 0,
          message: '雨天让宠物有些烦躁。',
          moodChange: PetMood.restless,
        );

      case 'stormy':
      case 'thunderstorm':
        return WeatherEffect(
          happinessChange: -10,
          healthChange: -5,
          message: '雷暴天气！宠物感到害怕和不安。',
          moodChange: PetMood.restless,
        );

      case 'snowy':
        return WeatherEffect(
          happinessChange: -10,
          healthChange: -5,
          message: '下雪了！爬宠类宠物通常怕冷。',
          moodChange: PetMood.sad,
        );

      case 'foggy':
      case 'fog':
        return WeatherEffect(
          happinessChange: -3,
          healthChange: 0,
          message: '雾气弥漫，宠物有点不适应。',
        );

      default:
        return WeatherEffect(
          happinessChange: 0,
          healthChange: 0,
          message: '天气对宠物没有特殊影响。',
        );
    }
  }

  /// 获取温度对宠物的影响
  static WeatherEffect getTemperatureEffect(double temperature) {
    if (temperature < 15) {
      return WeatherEffect(
        happinessChange: -10,
        healthChange: -10,
        message: '温度过低！宠物感到寒冷，健康可能受影响。',
        moodChange: PetMood.sick,
      );
    } else if (temperature < 20) {
      return WeatherEffect(
        happinessChange: -5,
        healthChange: -3,
        message: '温度偏低，宠物活动减少。',
        moodChange: PetMood.sad,
      );
    } else if (temperature >= 25 && temperature <= 32) {
      return WeatherEffect(
        happinessChange: 5,
        healthChange: 5,
        message: '温度适宜！宠物非常活跃。',
        moodChange: PetMood.happy,
      );
    } else if (temperature > 35) {
      return WeatherEffect(
        happinessChange: -10,
        healthChange: -10,
        message: '温度过高！宠物有中暑风险。',
        moodChange: PetMood.sick,
      );
    }

    return WeatherEffect(
      happinessChange: 0,
      healthChange: 0,
      message: '温度适宜。',
    );
  }

  /// 获取湿度对宠物的影响
  static WeatherEffect getHumidityEffect(double humidity) {
    if (humidity < 30) {
      return WeatherEffect(
        happinessChange: -5,
        healthChange: -3,
        message: '空气干燥，宠物可能不舒服。',
        moodChange: PetMood.restless,
      );
    } else if (humidity > 80) {
      return WeatherEffect(
        happinessChange: -5,
        healthChange: -3,
        message: '空气潮湿，容易滋生细菌。',
        moodChange: PetMood.restless,
      );
    }

    return WeatherEffect(
      happinessChange: 0,
      healthChange: 0,
      message: '湿度适宜。',
    );
  }

  /// 应用天气效果到宠物
  static ElectronicPet applyWeatherEffect(ElectronicPet pet, WeatherData weather) {
    final weatherEffect = getWeatherEffect(weather);
    final tempEffect = getTemperatureEffect(weather.temperature);
    final humidityEffect = getHumidityEffect(weather.humidity);

    int totalHappinessChange = weatherEffect.happinessChange +
        tempEffect.happinessChange +
        humidityEffect.happinessChange;
    int totalHealthChange = weatherEffect.healthChange +
        tempEffect.healthChange +
        humidityEffect.healthChange;

    // 合并心情效果
    PetMood newMood = pet.mood;
    if (weatherEffect.moodChange != PetMood.normal) {
      newMood = weatherEffect.moodChange;
    } else if (tempEffect.moodChange != PetMood.normal) {
      newMood = tempEffect.moodChange;
    }

    return pet.copyWith(
      happiness: (pet.happiness + totalHappinessChange).clamp(0, 100),
      healthScore: (pet.healthScore + totalHealthChange).clamp(0, 100),
      mood: newMood,
      updatedAt: DateTime.now(),
    );
  }

  /// 获取综合天气提示
  static String getWeatherTips(WeatherData weather) {
    final tips = <String>[];

    // 天气状况提示
    final condition = weather.condition.toLowerCase();
    if (condition == 'sunny' || condition == 'clear') {
      tips.add('好天气适合带宠物出去晒晒太阳，注意不要暴晒。');
    } else if (condition == 'rainy' || condition == 'rain') {
      tips.add('雨天湿度大，注意饲养箱的通风防潮。');
    } else if (condition == 'stormy' || condition == 'thunderstorm') {
      tips.add('雷暴天气请确保宠物处于安全安静的环境中。');
    } else if (condition == 'snowy') {
      tips.add('雪天注意保温，爬宠类宠物需要加温设备。');
    }

    // 温度提示
    if (weather.temperature < 20) {
      tips.add('温度偏低，建议使用加热设备。');
    } else if (weather.temperature > 35) {
      tips.add('温度过高，注意降温通风。');
    }

    // 湿度提示
    if (weather.humidity < 30) {
      tips.add('空气干燥，建议使用加湿设备或放置水盆。');
    } else if (weather.humidity > 80) {
      tips.add('湿度过高，注意通风换气，防止霉变。');
    }

    return tips.isEmpty ? '天气条件良好，正常饲养即可。' : tips.join('\n');
  }
}
