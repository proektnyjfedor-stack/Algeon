import 'package:flutter_test/flutter_test.dart';
import 'package:math_pilot/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AlgeonBootstrap());
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Algeon'), findsWidgets);
  });
}
