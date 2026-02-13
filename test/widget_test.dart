import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/app/app.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ReptileCareApp());
    expect(find.text('WildHerd'), findsOneWidget);
  });
}
