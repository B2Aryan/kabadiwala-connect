import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/main.dart';

void main() {
  testWidgets('KabadiwalaConnectApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger an initial frame
    await tester.pumpWidget(const KabadiwalaConnectApp());
    await tester.pump(const Duration(milliseconds: 500));

    // Verify that Splash screen renders brand title and tagline
    expect(find.text('Kabadiwala Connect'), findsWidgets);
    expect(find.text('Kabadi Se Circular Bharat Tak'), findsOneWidget);
  });
}
