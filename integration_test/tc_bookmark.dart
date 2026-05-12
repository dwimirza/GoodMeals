import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:goodmeals/main.dart' as app;
import 'package:goodmeals/login_page.dart';

Future<void> _ensureLoggedIn(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(seconds: 5));

  final guestGreeting = find.textContaining('Hi, Guest');
  final anyGreeting = find.textContaining('Hi,');

  if (guestGreeting.evaluate().isNotEmpty) {
    final loginIcon = find.byIcon(Icons.login);
    expect(loginIcon, findsOneWidget);

    await tester.tap(loginIcon);
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Login to GoodMeals'), findsOneWidget);

    const email = 'ananda120206@gmail.com';
    const password = 'akunnanda';

    final textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(2));

    await tester.enterText(textFields.at(0), email);
    await tester.enterText(textFields.at(1), password);
    await tester.pump();

    await tester.tap(find.text('Login'));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 10));

    expect(find.textContaining('Hi, Guest'), findsNothing);
    expect(anyGreeting, findsWidgets);
    return;
  }

  if (anyGreeting.evaluate().isNotEmpty) {
    // Already logged in, nothing to do
    return;
  }

  await tester.pumpAndSettle(const Duration(seconds: 5));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('TC-BOOKMARK-001 Add recipe to bookmark from Home screen', () {
    testWidgets(
      'Selected recipe is saved and appears in Bookmark page',
      (tester) async {
        // 1. Launch app
        await app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // 2. Ensure we are logged in
        await _ensureLoggedIn(tester);

        // 3. Wait for recipes to load
        await tester.pumpAndSettle(const Duration(seconds: 10));

        // Count filled bookmarks BEFORE tap
        final filledBefore = find.byIcon(Icons.bookmark);
        final initialFilledCount = filledBefore.evaluate().length;

        final outlineIconFinder = find.byIcon(Icons.bookmark_outline);

        final firstBookmarkIcon = outlineIconFinder.first;
        await tester.tap(firstBookmarkIcon);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // After tap: filled bookmark count should increase (or at least be >= 1)
        final filledAfter = find.byIcon(Icons.bookmark);
        final afterFilledCount = filledAfter.evaluate().length;
        expect(afterFilledCount, greaterThan(initialFilledCount));

        // 5. Open Bookmark page via bottom nav
        final bottomBookmarkNavIcon = find.byIcon(Icons.bookmark_outline).last;
        await tester.tap(bottomBookmarkNavIcon);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // 6. Verify bookmark page has at least one filled bookmark icon
        expect(find.byIcon(Icons.bookmark), findsWidgets);
      },
    );
  });
}