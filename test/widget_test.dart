import 'package:flutter_test/flutter_test.dart';
import 'package:joga_sports/app.dart';
import 'package:joga_sports/core/di/app_services.dart';

void main() {
  testWidgets('app opens on onboarding', (tester) async {
    await tester.pumpWidget(
      JogaApp(services: AppServices.fake(latency: Duration.zero)),
    );
    await tester.pumpAndSettle();

    expect(find.text('GET STARTED'), findsOneWidget);
  });
}
