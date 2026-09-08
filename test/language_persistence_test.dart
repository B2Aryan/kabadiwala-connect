import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/localization/app_localizations.dart';
import 'package:kabadiwala_connect/core/localization/language_provider.dart';
import 'package:kabadiwala_connect/features/home/home_dashboard_screen.dart';
import 'package:kabadiwala_connect/features/onboarding/language_selection_screen.dart';
import 'package:kabadiwala_connect/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Language Selection Persistence & Startup Flow Tests', () {
    testWidgets(
      '1. Fresh install / no saved language: Splash -> Language Selection',
      (tester) async {
        SharedPreferences.setMockInitialValues({});

        await tester.pumpWidget(const KabadiwalaConnectApp());
        await tester.pump(const Duration(milliseconds: 500));

        // Fast forward past splash timer (2600ms)
        await tester.pump(const Duration(milliseconds: 2700));
        await tester.pumpAndSettle();

        // Expect to be on Language Selection screen
        expect(find.byType(LanguageSelectionScreen), findsOneWidget);
        expect(find.byType(HomeDashboardScreen), findsNothing);
        expect(find.text('Choose Your Language'), findsOneWidget);
        expect(find.text('हिन्दी'), findsOneWidget);
        expect(find.text('मराठी'), findsOneWidget);
      },
    );

    testWidgets(
      '2. Select Hindi: Persists language_selected=true and code="hi"',
      (tester) async {
        SharedPreferences.setMockInitialValues({});

        await tester.pumpWidget(const KabadiwalaConnectApp());
        await tester.pump(const Duration(milliseconds: 2700));
        await tester.pumpAndSettle();

        // Tap Hindi card
        await tester.tap(find.text('हिन्दी').first);
        await tester.pumpAndSettle();

        // Expect to land on Home dashboard
        expect(find.byType(HomeDashboardScreen), findsOneWidget);

        // Verify persistent storage
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool(LanguagePreferenceKeys.languageSelected), true);
        expect(prefs.getString(LanguagePreferenceKeys.selectedLanguage), 'hi');
      },
    );

    testWidgets(
      '3. Restart simulation with Hindi: Splash -> Home directly in Hindi',
      (tester) async {
        // Simulate existing stored preferences
        SharedPreferences.setMockInitialValues({
          LanguagePreferenceKeys.languageSelected: true,
          LanguagePreferenceKeys.selectedLanguage: 'hi',
        });

        await tester.pumpWidget(const KabadiwalaConnectApp());
        await tester.pump(const Duration(milliseconds: 500));

        // Fast forward past splash timer
        await tester.pump(const Duration(milliseconds: 2700));
        await tester.pumpAndSettle();

        // Expect to go directly to Home (Language Selection NOT shown)
        expect(find.byType(LanguageSelectionScreen), findsNothing);
        expect(find.byType(HomeDashboardScreen), findsOneWidget);

        // Verify Hindi greeting on Home dashboard
        expect(find.text('नमस्ते, रमेश! 👋'), findsOneWidget);
      },
    );

    testWidgets(
      '4. Select Marathi: Persists language_selected=true and code="mr"',
      (tester) async {
        SharedPreferences.setMockInitialValues({});

        await tester.pumpWidget(const KabadiwalaConnectApp());
        await tester.pump(const Duration(milliseconds: 2700));
        await tester.pumpAndSettle();

        // Tap Marathi card
        await tester.tap(find.text('मराठी').first);
        await tester.pumpAndSettle();

        // Expect to land on Home dashboard
        expect(find.byType(HomeDashboardScreen), findsOneWidget);

        // Verify persistent storage
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool(LanguagePreferenceKeys.languageSelected), true);
        expect(prefs.getString(LanguagePreferenceKeys.selectedLanguage), 'mr');
      },
    );

    testWidgets(
      '5. Restart simulation with Marathi: Splash -> Home directly in Marathi',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          LanguagePreferenceKeys.languageSelected: true,
          LanguagePreferenceKeys.selectedLanguage: 'mr',
        });

        await tester.pumpWidget(const KabadiwalaConnectApp());
        await tester.pump(const Duration(milliseconds: 500));

        // Fast forward past splash timer
        await tester.pump(const Duration(milliseconds: 2700));
        await tester.pumpAndSettle();

        // Expect Home directly
        expect(find.byType(LanguageSelectionScreen), findsNothing);
        expect(find.byType(HomeDashboardScreen), findsOneWidget);

        // Verify Marathi header on Home dashboard
        expect(find.text('आज काय विकणार?'), findsOneWidget);
        expect(find.text('आजचे भाव'), findsOneWidget);
      },
    );

    testWidgets(
      '6a. Select English: Persists language_selected=true and code="en"',
      (tester) async {
        SharedPreferences.setMockInitialValues({});

        await tester.pumpWidget(const KabadiwalaConnectApp());
        await tester.pump(const Duration(milliseconds: 2700));
        await tester.pumpAndSettle();

        // Tap English card
        await tester.tap(find.text('English').first);
        await tester.pumpAndSettle();

        // Expect to land on Home dashboard
        expect(find.byType(HomeDashboardScreen), findsOneWidget);

        // Verify persistent storage
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool(LanguagePreferenceKeys.languageSelected), true);
        expect(prefs.getString(LanguagePreferenceKeys.selectedLanguage), 'en');
      },
    );

    testWidgets(
      '6b. Restart simulation with English: Splash -> Home directly in English',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          LanguagePreferenceKeys.languageSelected: true,
          LanguagePreferenceKeys.selectedLanguage: 'en',
        });

        await tester.pumpWidget(const KabadiwalaConnectApp());
        await tester.pump(const Duration(milliseconds: 500));

        // Fast forward past splash timer
        await tester.pump(const Duration(milliseconds: 2700));
        await tester.pumpAndSettle();

        // Expect Home directly and LanguageSelectionScreen not shown
        expect(find.byType(LanguageSelectionScreen), findsNothing);
        expect(find.byType(HomeDashboardScreen), findsOneWidget);
        expect(find.text('Hello, Ramesh! 👋'), findsOneWidget);
      },
    );

    testWidgets(
      '7. Invalid/missing stored language code gracefully falls back to English',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          LanguagePreferenceKeys.languageSelected: true,
          LanguagePreferenceKeys.selectedLanguage: 'corrupted_code_123',
        });

        final langProvider = LanguageProvider();
        await langProvider.loadSavedLanguage();

        expect(langProvider.currentLanguage, AppLanguage.english);
        expect(langProvider.hasSelectedLanguage, true);
      },
    );

    testWidgets(
      '8. Returning user must NEVER be sent to Language Selection on restart',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          LanguagePreferenceKeys.languageSelected: true,
          LanguagePreferenceKeys.selectedLanguage: 'hi',
        });

        await tester.pumpWidget(const KabadiwalaConnectApp());
        await tester.pump(const Duration(milliseconds: 2700));
        await tester.pumpAndSettle();

        expect(find.byType(LanguageSelectionScreen), findsNothing);
        expect(find.byType(HomeDashboardScreen), findsOneWidget);
      },
    );

    testWidgets(
      '9. Splash Tap-to-Skip respects the same destination (returning user -> Home)',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          LanguagePreferenceKeys.languageSelected: true,
          LanguagePreferenceKeys.selectedLanguage: 'hi',
        });

        await tester.pumpWidget(const KabadiwalaConnectApp());
        await tester.pump(const Duration(milliseconds: 200));

        // Tap on splash to skip
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        // Expect Home directly, not Language Selection
        expect(find.byType(LanguageSelectionScreen), findsNothing);
        expect(find.byType(HomeDashboardScreen), findsOneWidget);
      },
    );

    testWidgets(
      '10. Splash Tap-to-Skip on fresh install leads to Language Selection',
      (tester) async {
        SharedPreferences.setMockInitialValues({});

        await tester.pumpWidget(const KabadiwalaConnectApp());
        await tester.pump(const Duration(milliseconds: 200));

        // Tap on splash to skip
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        // Expect Language Selection
        expect(find.byType(LanguageSelectionScreen), findsOneWidget);
        expect(find.byType(HomeDashboardScreen), findsNothing);
      },
    );
  });
}
