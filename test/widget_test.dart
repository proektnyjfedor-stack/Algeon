import 'package:flutter_test/flutter_test.dart';
import 'package:math_pilot/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AlgeonApp());
    await tester.pumpAndSettle();
  });
}
