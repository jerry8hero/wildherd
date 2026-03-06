import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/weather.dart';
import '../local/user_preferences.dart';

/// 天气服务
/// 支持两种模式：
/// 1. Open-Meteo API（免费，无需API Key）
/// 2. OpenWeatherMap API（需要API Key）
class WeatherService {
  // Open-Meteo 免费API（默认使用）
  static const String _openMeteoBaseUrl = 'https://api.open-meteo.com/v1';

  // OpenWeatherMap API（可选，需要填写有效的API Key）
  static const String _openWeatherMapKey = '';
  static const String _openWeatherMapUrl = 'https://api.openweathermap.org/data/2.5';

  /// 获取当前位置天气（使用Open-Meteo）
  static Future<WeatherData?> getCurrentWeather({
    double lat = 39.9,  // 默认北京
    double lon = 116.4,
    String? cityName,
  }) async {
    try {
      final url = '$_openMeteoBaseUrl/forecast'
          '?latitude=$lat'
          '&longitude=$lon'
          '&current=temperature_2m,relative_humidity_2m,weather_code'
          '&timezone=auto';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current'];

        return WeatherData(
          location: cityName ?? '当前地区',
          temperature: (current['temperature_2m'] ?? 0).toDouble(),
          humidity: (current['relative_humidity_2m'] ?? 0).toDouble(),
          condition: _getWeatherCondition(current['weather_code'] ?? 0),
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('获取天气失败: $e');
    }
    return null;
  }

  /// 获取天气预报（使用Open-Meteo）
  static Future<List<ForecastDay>?> getForecast({
    double lat = 39.9,
    double lon = 116.4,
    int days = 5,
  }) async {
    try {
      final url = '$_openMeteoBaseUrl/forecast'
          '?latitude=$lat'
          '&longitude=$lon'
          '&daily=temperature_2m_max,temperature_2m_min,weather_code'
          '&timezone=auto'
          '&forecast_days=$days';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final daily = data['daily'];

        final times = daily['time'] as List;
        final maxTemps = daily['temperature_2m_max'] as List;
        final minTemps = daily['temperature_2m_min'] as List;
        final weatherCodes = daily['weather_code'] as List;

        final forecasts = <ForecastDay>[];
        for (var i = 0; i < times.length; i++) {
          forecasts.add(ForecastDay(
            date: DateTime.parse(times[i]),
            minTemp: (minTemps[i] ?? 0).toDouble(),
            maxTemp: (maxTemps[i] ?? 0).toDouble(),
            condition: _getWeatherCondition(weatherCodes[i] ?? 0),
          ));
        }

        return forecasts;
      }
    } catch (e) {
      debugPrint('获取天气预报失败: $e');
    }
    return null;
  }

  /// 获取带预报的完整天气数据
  /// 如果不传参数，则自动使用用户设置的位置
  static Future<WeatherData?> getFullWeather({
    double? lat,
    double? lon,
    String? cityName,
  }) async {
    // 如果没有提供位置，使用用户设置的位置
    final useDefault = lat == null || lon == null;
    final actualLat = useDefault ? UserPreferences.getLatitude() : lat;
    final actualLon = useDefault ? UserPreferences.getLongitude() : lon;
    final actualCityName = useDefault ? UserPreferences.getCityName() : cityName;

    final weather = await getCurrentWeather(lat: actualLat, lon: actualLon, cityName: actualCityName);
    if (weather != null) {
      final forecast = await getForecast(lat: actualLat, lon: actualLon);
      return WeatherData(
        location: weather.location,
        temperature: weather.temperature,
        humidity: weather.humidity,
        condition: weather.condition,
        timestamp: weather.timestamp,
        forecast: forecast,
      );
    }
    return null;
  }

  /// WMO天气代码转换
  static String _getWeatherCondition(int code) {
    if (code == 0) return 'clear';
    if (code <= 3) return 'cloudy';
    if (code <= 49) return 'foggy';
    if (code <= 59) return 'rainy';
    if (code <= 69) return 'snowy';
    if (code <= 79) return 'snowy';
    if (code <= 84) return 'rainy';
    if (code <= 94) return 'snowy';
    return 'stormy';
  }

  /// 获取指定城市的天气（需要OpenWeatherMap）
  static Future<WeatherData?> getWeatherByCity(String cityName) async {
    if (_openWeatherMapKey.isEmpty) {
      return null;
    }

    try {
      final url = '$_openWeatherMapUrl/weather'
          '?q=$cityName'
          '&appid=$_openWeatherMapKey'
          '&units=metric';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final main = data['main'];
        final weather = data['weather'][0];

        return WeatherData(
          location: data['name'],
          temperature: (main['temp'] ?? 0).toDouble(),
          humidity: (main['humidity'] ?? 0).toDouble(),
          condition: weather['main']?.toString().toLowerCase() ?? 'unknown',
          minTemp: (main['temp_min'] ?? 0).toDouble(),
          maxTemp: (main['temp_max'] ?? 0).toDouble(),
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('获取城市天气失败: $e');
    }
    return null;
  }
}

/// 手动天气输入服务
class ManualWeatherService {
  static WeatherData createManualWeather({
    required double temperature,
    required double humidity,
    String condition = 'clear',
  }) {
    return WeatherData(
      location: '手动输入',
      temperature: temperature,
      humidity: humidity,
      condition: condition,
      timestamp: DateTime.now(),
    );
  }

  static WeatherData createWithForecast({
    required double currentTemp,
    required double humidity,
    List<double>? futureTemps,
  }) {
    final forecasts = <ForecastDay>[];

    if (futureTemps != null) {
      for (var i = 0; i < futureTemps.length; i++) {
        forecasts.add(ForecastDay(
          date: DateTime.now().add(Duration(days: i + 1)),
          minTemp: futureTemps[i] - 3,
          maxTemp: futureTemps[i] + 3,
          condition: 'unknown',
        ));
      }
    }

    return WeatherData(
      location: '手动输入',
      temperature: currentTemp,
      humidity: humidity,
      condition: 'manual',
      timestamp: DateTime.now(),
      forecast: forecasts,
    );
  }
}
