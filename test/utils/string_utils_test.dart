import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/lib/utils/string_utils.dart';

void main() {
  group('StringUtils', () {
    group('isEmpty', () {
      test('should return true for null', () {
        expect(StringUtils.isEmpty(null), isTrue);
      });

      test('should return true for empty string', () {
        expect(StringUtils.isEmpty(''), isTrue);
      });

      test('should return true for whitespace only', () {
        expect(StringUtils.isEmpty('   '), isTrue);
        expect(StringUtils.isEmpty('\t\n'), isTrue);
      });

      test('should return false for non-empty string', () {
        expect(StringUtils.isEmpty('hello'), isFalse);
        expect(StringUtils.isEmpty('  hello  '), isFalse);
      });
    });

    group('isNotEmpty', () {
      test('should return false for null', () {
        expect(StringUtils.isNotEmpty(null), isFalse);
      });

      test('should return false for empty string', () {
        expect(StringUtils.isNotEmpty(''), isFalse);
      });

      test('should return false for whitespace only', () {
        expect(StringUtils.isNotEmpty('   '), isFalse);
        expect(StringUtils.isNotEmpty('\t\n'), isFalse);
      });

      test('should return true for non-empty string', () {
        expect(StringUtils.isNotEmpty('hello'), isTrue);
        expect(StringUtils.isNotEmpty('  hello  '), isTrue);
      });
    });

    group('truncate', () {
      test('should return original string if within maxLength', () {
        expect(StringUtils.truncate('hello', 10), equals('hello'));
        expect(StringUtils.truncate('hello', 5), equals('hello'));
      });

      test('should truncate string and add suffix', () {
        expect(StringUtils.truncate('hello world', 5), equals('hello...'));
        expect(StringUtils.truncate('hello world', 8), equals('hello wo...'));
      });

      test('should truncate with custom suffix', () {
        expect(StringUtils.truncate('hello world', 5, suffix: '..'), equals('hel..'));
        expect(StringUtils.truncate('hello world', 10, suffix: '—'), equals('hello worl—'));
      });

      test('should handle empty string', () {
        expect(StringUtils.truncate('', 5), equals(''));
      });
    });

    group('defaultIfEmpty', () {
      test('should return default value for null', () {
        expect(StringUtils.defaultIfEmpty(null, 'default'), equals('default'));
      });

      test('should return default value for empty string', () {
        expect(StringUtils.defaultIfEmpty('', 'default'), equals('default'));
      });

      test('should return default value for whitespace only', () {
        expect(StringUtils.defaultIfEmpty('   ', 'default'), equals('default'));
      });

      test('should return original value if not empty', () {
        expect(StringUtils.defaultIfEmpty('hello', 'default'), equals('hello'));
        expect(StringUtils.defaultIfEmpty('  hello  ', 'default'), equals('  hello  '));
      });
    });

    group('formatDateTimeShort', () {
      test('should format date and time correctly', () {
        final date = DateTime(2023, 5, 15, 14, 30);
        expect(StringUtils.formatDateTimeShort(date), equals('5/15 14:30'));
      });

      test('should format with single digit month', () {
        final date = DateTime(2023, 1, 5, 9, 5);
        expect(StringUtils.formatDateTimeShort(date), equals('1/5 9:05'));
      });
    });

    group('sanitizeForLog', () {
      test('should return original string if within visibleChars', () {
        expect(StringUtils.sanitizeForLog('hello', visibleChars: 5), equals('hello'));
        expect(StringUtils.sanitizeForLog('hi', visibleChars: 3), equals('hi'));
      });

      test('should truncate and mask sensitive data', () {
        expect(StringUtils.sanitizeForLog('password123', visibleChars: 3), equals('pas***'));
        expect(StringUtils.sanitizeForLog('topsecret', visibleChars: 5), equals('topse***'));
      });

      test('should handle empty string', () {
        expect(StringUtils.sanitizeForLog('', visibleChars: 3), equals(''));
      });
    });
  });
}