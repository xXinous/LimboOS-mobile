import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limbo_os/main.dart';
import 'package:limbo_os/src/features/auth/data/auth_repository.dart';

void main() {
  testWidgets('App starts with login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateChangesProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const LimboOSApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that the login screen is displayed.
    // We use find.text containing since the text might be stylized.
    expect(find.textContaining('TERMINAL MESTRE'), findsOneWidget);
  });
}
