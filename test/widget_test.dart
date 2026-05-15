import 'package:flutter_test/flutter_test.dart';
import 'package:dynavia/main.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DynaviaApp());

    // Verify that splash screen text is shown
    expect(find.text('Dynavia'), findsOneWidget);
  });
}
