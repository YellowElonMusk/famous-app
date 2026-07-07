import 'package:flutter_test/flutter_test.dart';

import 'package:fakelive/main.dart';

void main() {
  testWidgets('Selection screen shows all three platforms', (tester) async {
    await tester.pumpWidget(const FakeLiveApp());

    expect(find.text('FakeLive'), findsOneWidget);
    expect(find.text('Instagram Live'), findsOneWidget);
    expect(find.text('TikTok Live'), findsOneWidget);
    expect(find.text('Twitch Live'), findsOneWidget);
  });
}
