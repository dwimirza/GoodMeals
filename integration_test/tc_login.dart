// integration_test/tc_login_001_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:goodmeals/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('TC-LOGIN-001: Login with valid credentials', () {
    testWidgets(
      'Login succeeds and app returns to main flow',
      (WidgetTester tester) async {
        // Arrange: Launch the app
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // If SplashScreen is shown, wait for it to finish
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Act: Tap the Login icon in the top app bar (GoodMealsHome)
        final loginIcon = find.byIcon(Icons.login);
        expect(loginIcon, findsOneWidget);
        await tester.tap(loginIcon);
        await tester.pumpAndSettle();

        // Verify: LoginPage is shown
        expect(find.text('Login to GoodMeals'), findsOneWidget);

        // Act: Enter valid email
        final emailField = find.byType(TextField).first;
        await tester.tap(emailField);
        await tester.enterText(emailField, 'ananda120206@gmail.com');
        await tester.pump();

        // Act: Enter valid password
        final passwordField = find.byType(TextField).at(1);
        await tester.tap(passwordField);
        await tester.enterText(passwordField, 'akunnanda');
        await tester.pump();

        // Act: Tap Login button
        final loginButton = find.text('Login');
        expect(loginButton, findsOneWidget);
        await tester.tap(loginButton);

        // Wait for async login + navigation to complete
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Assert: LoginPage is dismissed (not in widget tree)
        expect(find.text('Login to GoodMeals'), findsNothing);

        // Assert: Main flow is shown — hero text visible on GoodMealsHome
        expect(find.textContaining('cooking today'), findsOneWidget);

        // Assert: Logout icon is visible (user is now logged in)
        expect(find.byIcon(Icons.logout), findsOneWidget);
      },
    );
  });
}