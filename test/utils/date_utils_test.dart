import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/utils/date_utils.dart';

void main() {
  group('DateTimeUtils', () {
    group('formatDate', () {
      test('should return "未设置" for null date', () {
        expect(DateTimeUtils.formatDate(null), equals('未设置'));
      });

      test('should format date correctly for valid date', () {
        final date = DateTime(2023, 5, 15);
        expect(DateTimeUtils.formatDate(date), equals('2023-05-15'));
      });

      test('should format date with single digit month and day', () {
        final date = DateTime(2023, 1, 5);
        expect(DateTimeUtils.formatDate(date), equals('2023-01-05'));
      });

      test('should format date with single digit day', () {
        final date = DateTime(2023, 10, 8);
        expect(DateTimeUtils.formatDate(date), equals('2023-10-08'));
      });
    });

    group('formatRelativeTime', () {
      test('should return "刚刚" for less than 1 minute ago', () {
        final now = DateTime.now();
        final time = now.subtract(const Duration(seconds: 30));
        expect(DateTimeUtils.formatRelativeTime(time), equals('刚刚'));
      });

      test('should return minutes ago for less than 60 minutes', () {
        final now = DateTime.now();
        final time = now.subtract(const Duration(minutes: 5));
        expect(DateTimeUtils.formatRelativeTime(time), equals('5分钟前'));

        final time2 = now.subtract(const Duration(minutes: 59));
        expect(DateTimeUtils.formatRelativeTime(time2), equals('59分钟前'));
      });

      test('should return hours ago for less than 24 hours', () {
        final now = DateTime.now();
        final time = now.subtract(const Duration(hours: 1));
        expect(DateTimeUtils.formatRelativeTime(time), equals('1小时前'));

        final time2 = now.subtract(const Duration(hours: 23));
        expect(DateTimeUtils.formatRelativeTime(time2), equals('23小时前'));
      });

      test('should return days ago for less than 7 days', () {
        final now = DateTime.now();
        final time = now.subtract(const Duration(days: 1));
        expect(DateTimeUtils.formatRelativeTime(time), equals('1天前'));

        final time2 = now.subtract(const Duration(days: 6));
        expect(DateTimeUtils.formatRelativeTime(time2), equals('6天前'));
      });

      test('should return weeks ago for less than 30 days', () {
        final now = DateTime.now();
        final time = now.subtract(const Duration(days: 7));
        expect(DateTimeUtils.formatRelativeTime(time), equals('1周前'));

        final time2 = now.subtract(const Duration(days: 14));
        expect(DateTimeUtils.formatRelativeTime(time2), equals('2周前'));

        final time3 = now.subtract(const Duration(days: 27));
        expect(DateTimeUtils.formatRelativeTime(time3), equals('3周前'));
      });

      test('should return months ago for less than 365 days', () {
        final now = DateTime.now();
        final time = now.subtract(const Duration(days: 30));
        expect(DateTimeUtils.formatRelativeTime(time), equals('1个月前'));

        final time2 = now.subtract(const Duration(days: 89));
        expect(DateTimeUtils.formatRelativeTime(time2), equals('2个月前'));

        final time3 = now.subtract(const Duration(days: 365));
        expect(DateTimeUtils.formatRelativeTime(time3), equals('1个月前'));
      });

      test('should return years ago for 365 days or more', () {
        final now = DateTime.now();
        final time = now.subtract(const Duration(days: 365));
        expect(DateTimeUtils.formatRelativeTime(time), equals('1年前'));

        final time2 = now.subtract(const Duration(days: 730));
        expect(DateTimeUtils.formatRelativeTime(time2), equals('2年前'));
      });
    });

    group('formatMonthDay', () {
      test('should format month-day correctly', () {
        final date = DateTime(2023, 5, 15);
        expect(DateTimeUtils.formatMonthDay(date), equals('5-15'));
      });

      test('should format single digit month and day', () {
        final date = DateTime(2023, 1, 5);
        expect(DateTimeUtils.formatMonthDay(date), equals('1-5'));
      });
    });

    group('formatTime', () {
      test('should format time with leading zeros', () {
        final date = DateTime(2023, 5, 15, 9, 5);
        expect(DateTimeUtils.formatTime(date), equals('09:05'));
      });

      test('should format time without leading zeros', () {
        final date = DateTime(2023, 5, 15, 14, 30);
        expect(DateTimeUtils.formatTime(date), equals('14:30'));
      });

      test('should format single digit minute', () {
        final date = DateTime(2023, 5, 15, 15, 8);
        expect(DateTimeUtils.formatTime(date), equals('15:08'));
      });
    });
  });
}