import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/utils/num_utils.dart';

void main() {
  group('NumUtils', () {
    group('formatDecimal', () {
      test('should format decimal with default 1 decimal place', () {
        expect(NumUtils.formatDecimal(123.456), equals('123.5'));
      });

      test('should format decimal with specified decimal places', () {
        expect(NumUtils.formatDecimal(123.456, decimals: 2), equals('123.46'));
        expect(NumUtils.formatDecimal(123.456, decimals: 0), equals('123'));
        expect(NumUtils.formatDecimal(123.456, decimals: 4), equals('123.4560'));
      });

      test('should format integer correctly', () {
        expect(NumUtils.formatDecimal(123), equals('123.0'));
      });

      test('should format negative numbers', () {
        expect(NumUtils.formatDecimal(-123.456), equals('-123.5'));
      });
    });

    group('formatPercent', () {
      test('should format percentage with default 0 decimal places', () {
        expect(NumUtils.formatPercent(0.75), equals('75%'));
        expect(NumUtils.formatPercent(0.123), equals('12%'));
      });

      test('should format percentage with specified decimal places', () {
        expect(NumUtils.formatPercent(0.756, decimals: 2), equals('75.60%'));
        expect(NumUtils.formatPercent(0.756, decimals: 1), equals('75.6%'));
        expect(NumUtils.formatPercent(0.756, decimals: 0), equals('76%'));
      });

      test('should format percentage for 100%', () {
        expect(NumUtils.formatPercent(1.0), equals('100%'));
      });

      test('should format percentage for 0%', () {
        expect(NumUtils.formatPercent(0.0), equals('0%'));
      });

      test('should format negative percentage', () {
        expect(NumUtils.formatPercent(-0.25), equals('-25%'));
      });
    });

    group('formatTemperature', () {
      test('should format temperature with default °C unit', () {
        expect(NumUtils.formatTemperature(23.456), equals('23.5°C'));
      });

      test('should format temperature with 1 decimal place', () {
        expect(NumUtils.formatTemperature(23.456, unit: '°C'), equals('23.5°C'));
      });

      test('should format temperature with custom unit', () {
        expect(NumUtils.formatTemperature(23.456, unit: '°F'), equals('23.5°F'));
        expect(NumUtils.formatTemperature(23.456, unit: 'K'), equals('23.5K'));
      });

      test('should format negative temperature', () {
        expect(NumUtils.formatTemperature(-5.67), equals('-5.7°C'));
      });
    });

    group('formatHumidity', () {
      test('should format humidity with 0 decimal places', () {
        expect(NumUtils.formatHumidity(45.67), equals('46%'));
        expect(NumUtils.formatHumidity(78.9), equals('79%'));
      });

      test('should format humidity for 0%', () {
        expect(NumUtils.formatHumidity(0.0), equals('0%'));
      });

      test('should format humidity for 100%', () {
        expect(NumUtils.formatHumidity(1.0), equals('100%'));
      });

      test('should format negative humidity', () {
        expect(NumUtils.formatHumidity(-0.25), equals('-25%'));
      });
    });

    group('tryParseDouble', () {
      test('should parse valid string to double', () {
        expect(NumUtils.tryParseDouble('123.45'), equals(123.45));
        expect(NumUtils.tryParseDouble('123'), equals(123.0));
      });

      test('should return null for null input', () {
        expect(NumUtils.tryParseDouble(null), isNull);
      });

      test('should return null for empty string', () {
        expect(NumUtils.tryParseDouble(''), isNull);
      });

      test('should return default value for invalid string', () {
        expect(NumUtils.tryParseDouble('invalid', defaultValue: 0.0), equals(0.0));
        expect(NumUtils.tryParseDouble('123.45', defaultValue: 999.0), equals(123.45));
      });

      test('should return null without default value for invalid string', () {
        expect(NumUtils.tryParseDouble('invalid'), isNull);
      });
    });

    group('clamp', () {
      test('should return value if within range', () {
        expect(NumUtils.clamp(5.0, 0.0, 10.0), equals(5.0));
        expect(NumUtils.clamp(0.0, 0.0, 10.0), equals(0.0));
        expect(NumUtils.clamp(10.0, 0.0, 10.0), equals(10.0));
      });

      test('should return min if value below range', () {
        expect(NumUtils.clamp(-5.0, 0.0, 10.0), equals(0.0));
        expect(NumUtils.clamp(-1.0, 0.0, 10.0), equals(0.0));
      });

      test('should return max if value above range', () {
        expect(NumUtils.clamp(15.0, 0.0, 10.0), equals(10.0));
        expect(NumUtils.clamp(11.0, 0.0, 10.0), equals(10.0));
      });

      test('should handle negative range', () {
        expect(NumUtils.clamp(-5.0, -10.0, -1.0), equals(-5.0));
        expect(NumUtils.clamp(-15.0, -10.0, -1.0), equals(-10.0));
        expect(NumUtils.clamp(0.0, -10.0, -1.0), equals(-1.0));
      });
    });
  });
}