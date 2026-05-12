import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/utils/gender_utils.dart';

void main() {
  group('GenderUtils', () {
    group('getGenderText', () {
      test('should return "雄性" for "male"', () {
        expect(GenderUtils.getGenderText('male'), equals('雄性'));
      });

      test('should return "雌性" for "female"', () {
        expect(GenderUtils.getGenderText('female'), equals('雌性'));
      });

      test('should return "未知" for null input', () {
        expect(GenderUtils.getGenderText(null), equals('未知'));
      });

      test('should return "未知" for unknown gender code', () {
        expect(GenderUtils.getGenderText('unknown'), equals('未知'));
        expect(GenderUtils.getGenderText(''), equals('未知'));
      });
    });

    group('getText', () {
      test('should return "雄性" for "雄性"', () {
        expect(GenderUtils.getText('雄性'), equals('雄性'));
      });

      test('should return "雌性" for "雌性"', () {
        expect(GenderUtils.getText('雌性'), equals('雌性'));
      });

      test('should return "未知" for null input', () {
        expect(GenderUtils.getText(null), equals('未知'));
      });

      test('should return "未知" for unknown gender text', () {
        expect(GenderUtils.getText('未知'), equals('未知'));
        expect(GenderUtils.getText(''), equals('未知'));
        expect(GenderUtils.getText('other'), equals('未知'));
      });
    });

    group('getIcon', () {
      test('should return male icon for "雄性"', () {
        final icon = GenderUtils.getIcon('雄性');
        expect(icon, isA<Type>());
      });

      test('should return female icon for "雌性"', () {
        final icon = GenderUtils.getIcon('雌性');
        expect(icon, isA<Type>());
      });

      test('should return help_outline icon for null', () {
        final icon = GenderUtils.getIcon(null);
        expect(icon, isA<Type>());
      });

      test('should return help_outline icon for unknown gender', () {
        final icon = GenderUtils.getIcon('unknown');
        expect(icon, isA<Type>());
      });
    });

    group('getColor', () {
      test('should return blue color for "雄性"', () {
        final color = GenderUtils.getColor('雄性');
        expect(color, isA<Type>());
      });

      test('should return pink color for "雌性"', () {
        final color = GenderUtils.getColor('雌性');
        expect(color, isA<Type>());
      });

      test('should return grey color for null', () {
        final color = GenderUtils.getColor(null);
        expect(color, isA<Type>());
      });

      test('should return grey color for unknown gender', () {
        final color = GenderUtils.getColor('unknown');
        expect(color, isA<Type>());
      });
    });

    group('getDropdownItems', () {
      test('should return 3 dropdown items for gender options', () {
        final items = GenderUtils.getDropdownItems();
        expect(items.length, equals(3));
      });

      test('should include "雄性" option', () {
        final items = GenderUtils.getDropdownItems();
        expect(items.any((item) => item.value == '雄性'), isTrue);
      });

      test('should include "雌性" option', () {
        final items = GenderUtils.getDropdownItems();
        expect(items.any((item) => item.value == '雌性'), isTrue);
      });

      test('should include "未知" option', () {
        final items = GenderUtils.getDropdownItems();
        expect(items.any((item) => item.value == '未知'), isTrue);
      });

      test('should include correct icons for each option', () {
        final items = GenderUtils.getDropdownItems();
        final maleItem = items.firstWhere((item) => item.value == '雄性');
        final femaleItem = items.firstWhere((item) => item.value == '雌性');
        final unknownItem = items.firstWhere((item) => item.value == '未知');

        expect(maleItem.child, isA<Type>());
        expect(femaleItem.child, isA<Type>());
        expect(unknownItem.child, isA<Type>());
      });

      test('should include correct colors for each option', () {
        final items = GenderUtils.getDropdownItems();
        final maleItem = items.firstWhere((item) => item.value == '雄性');
        final femaleItem = items.firstWhere((item) => item.value == '雌性');
        final unknownItem = items.firstWhere((item) => item.value == '未知');

        expect((maleItem.child as dynamic).children[0], isA<Type>());
        expect((femaleItem.child as dynamic).children[0], isA<Type>());
        expect((unknownItem.child as dynamic).children[0], isA<Type>());
      });
    });
  });
}