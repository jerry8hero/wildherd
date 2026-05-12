import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/data/models/weather.dart';

void main() {
  final testTimestamp = DateTime(2024, 6, 15, 12, 0);

  group('WeatherData', () {
    test('creates with required fields', () {
      final weather = WeatherData(
        location: '广州',
        temperature: 28.5,
        humidity: 75.0,
        condition: 'sunny',
        timestamp: testTimestamp,
      );

      expect(weather.location, '广州');
      expect(weather.temperature, 28.5);
      expect(weather.humidity, 75.0);
      expect(weather.condition, 'sunny');
      expect(weather.minTemp, isNull);
      expect(weather.maxTemp, isNull);
      expect(weather.forecast, isNull);
    });

    group('fromJson', () {
      test('parses from JSON', () {
        final json = {
          'location': '深圳',
          'temperature': 30.0,
          'humidity': 80.0,
          'condition': 'cloudy',
          'minTemp': 25.0,
          'maxTemp': 33.0,
          'timestamp': testTimestamp.toIso8601String(),
        };

        final weather = WeatherData.fromJson(json);

        expect(weather.location, '深圳');
        expect(weather.temperature, 30.0);
        expect(weather.minTemp, 25.0);
        expect(weather.maxTemp, 33.0);
      });

      test('handles missing optional fields', () {
        final json = {
          'location': '北京',
          'temperature': 20,
          'humidity': 50,
          'condition': 'rainy',
          'timestamp': testTimestamp.toIso8601String(),
        };

        final weather = WeatherData.fromJson(json);

        expect(weather.minTemp, isNull);
        expect(weather.maxTemp, isNull);
        expect(weather.forecast, isNull);
      });

      test('handles null/invalid timestamp', () {
        final json = {
          'location': '',
          'temperature': 0,
          'humidity': 0,
          'condition': 'unknown',
          'timestamp': null,
        };

        final weather = WeatherData.fromJson(json);
        expect(weather.timestamp, isNotNull);
      });
    });

    group('toJson', () {
      test('round-trip preserves data', () {
        final original = WeatherData(
          location: '上海',
          temperature: 26.5,
          humidity: 65.0,
          condition: 'sunny',
          minTemp: 22.0,
          maxTemp: 30.0,
          timestamp: testTimestamp,
        );

        final roundTripped = WeatherData.fromJson(original.toJson());

        expect(roundTripped.location, original.location);
        expect(roundTripped.temperature, original.temperature);
        expect(roundTripped.humidity, original.humidity);
        expect(roundTripped.condition, original.condition);
        expect(roundTripped.minTemp, original.minTemp);
        expect(roundTripped.maxTemp, original.maxTemp);
      });
    });

    group('iconName', () {
      test('returns correct icon for conditions', () {
        expect(WeatherData(location: '', temperature: 0, humidity: 0, condition: 'sunny', timestamp: testTimestamp).iconName, 'wb_sunny');
        expect(WeatherData(location: '', temperature: 0, humidity: 0, condition: 'cloudy', timestamp: testTimestamp).iconName, 'cloud');
        expect(WeatherData(location: '', temperature: 0, humidity: 0, condition: 'rainy', timestamp: testTimestamp).iconName, 'grain');
        expect(WeatherData(location: '', temperature: 0, humidity: 0, condition: 'snowy', timestamp: testTimestamp).iconName, 'ac_unit');
      });
    });
  });

  group('ForecastDay', () {
    test('fromJson parses correctly', () {
      final json = {
        'date': '2024-06-16T00:00:00.000',
        'minTemp': 24.0,
        'maxTemp': 32.0,
        'condition': 'partly_cloudy',
        'humidity': 70.0,
      };

      final forecast = ForecastDay.fromJson(json);

      expect(forecast.minTemp, 24.0);
      expect(forecast.maxTemp, 32.0);
      expect(forecast.condition, 'partly_cloudy');
      expect(forecast.humidity, 70.0);
    });

    test('toJson round-trip', () {
      final original = ForecastDay(
        date: DateTime(2024, 6, 16),
        minTemp: 20.0,
        maxTemp: 30.0,
        condition: 'sunny',
      );

      final roundTripped = ForecastDay.fromJson(original.toJson());

      expect(roundTripped.minTemp, original.minTemp);
      expect(roundTripped.maxTemp, original.maxTemp);
      expect(roundTripped.condition, original.condition);
    });
  });

  group('FeedingRecommendation', () {
    test('cold temperature: do not feed', () {
      final rec = FeedingRecommendation.fromTemperature(15.0);
      expect(rec.canFeed, isFalse);
      expect(rec.title, '不建议喂食');
    });

    test('caution temperature: cautious', () {
      final rec = FeedingRecommendation.fromTemperature(20.0);
      expect(rec.canFeed, isFalse);
      expect(rec.title, '谨慎喂食');
    });

    test('cool temperature: can feed', () {
      final rec = FeedingRecommendation.fromTemperature(23.0);
      expect(rec.canFeed, isTrue);
    });

    test('optimal temperature: suitable', () {
      final rec = FeedingRecommendation.fromTemperature(28.0);
      expect(rec.canFeed, isTrue);
      expect(rec.title, '适合喂食');
    });

    test('hot temperature: can feed with caution', () {
      final rec = FeedingRecommendation.fromTemperature(34.0);
      expect(rec.canFeed, isTrue);
    });

    test('extreme heat: do not feed', () {
      final rec = FeedingRecommendation.fromTemperature(38.0);
      expect(rec.canFeed, isFalse);
      expect(rec.warning, isNotNull);
    });
  });
}
