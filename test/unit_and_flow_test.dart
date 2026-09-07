import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/localization/app_localizations.dart';
import 'package:kabadiwala_connect/core/localization/language_provider.dart';
import 'package:kabadiwala_connect/core/theme/theme_provider.dart';
import 'package:kabadiwala_connect/features/earnings/earnings_screen.dart';
import 'package:kabadiwala_connect/features/home/home_dashboard_screen.dart';
import 'package:kabadiwala_connect/features/home/widgets/app_bottom_navigation_bar.dart';
import 'package:kabadiwala_connect/features/lots/create_lot_screen.dart';
import 'package:kabadiwala_connect/features/lots/lots_screen.dart';
import 'package:kabadiwala_connect/features/lots/models/ewaste_lot.dart';
import 'package:kabadiwala_connect/features/onboarding/language_selection_screen.dart';
import 'package:kabadiwala_connect/features/profile/profile_screen.dart';
import 'package:kabadiwala_connect/features/recyclers/models/handover_request.dart';
import 'package:kabadiwala_connect/features/recyclers/recyclers_screen.dart';
import 'package:kabadiwala_connect/features/recyclers/screens/handover_tracking_screen.dart';
import 'package:kabadiwala_connect/features/recyclers/screens/recycler_details_screen.dart';
import 'package:kabadiwala_connect/features/recyclers/screens/request_submitted_screen.dart';
import 'package:kabadiwala_connect/features/recyclers/services/recycler_provider.dart';
import 'package:kabadiwala_connect/features/recyclers/services/recycler_service.dart';
import 'package:kabadiwala_connect/main.dart';

void main() {
  group('State Providers Unit Tests', () {
    test('ThemeProvider toggles between light and dark', () {
      final themeProvider = ThemeProvider();
      expect(themeProvider.themeMode, ThemeMode.light);
      expect(themeProvider.isDarkMode, false);

      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.dark);
      expect(themeProvider.isDarkMode, true);

      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.light);
      expect(themeProvider.isDarkMode, false);
    });

    test('LanguageProvider correctly switches vernacular translations', () {
      final langProvider = LanguageProvider();
      expect(langProvider.currentLanguage, AppLanguage.hindi);
      expect(langProvider.tr('createNewLot'), 'नया लॉट बनाएँ');

      langProvider.setLanguage(AppLanguage.marathi);
      expect(langProvider.currentLanguage, AppLanguage.marathi);
      expect(langProvider.tr('createNewLot'), 'नवीन लॉट तयार करा');

      langProvider.setLanguage(AppLanguage.english);
      expect(langProvider.currentLanguage, AppLanguage.english);
      expect(langProvider.tr('createNewLot'), 'Create New Lot');
    });

    test(
      'MockRecyclerService filters by material, pickup, and distance',
      () async {
        final service = MockRecyclerService();
        final all = await service.getNearbyRecyclers();
        expect(all.length, greaterThanOrEqualTo(3));

        final copperOnly = await service.getNearbyRecyclers(
          materialKey: 'copper',
        );
        for (final r in copperOnly) {
          expect(r.acceptedMaterials.contains('copper'), true);
        }

        final pickupOnly = await service.getNearbyRecyclers(pickupOnly: true);
        for (final r in pickupOnly) {
          expect(r.pickupAvailable, true);
        }

        final closeOnly = await service.getNearbyRecyclers(maxDistanceKm: 3.5);
        for (final r in closeOnly) {
          expect(r.distanceKm, lessThanOrEqualTo(3.5));
        }
      },
    );

    test(
      'RecyclerProvider manages filters and submits handover request',
      () async {
        final provider = RecyclerProvider();
        await provider.loadRecyclers();
        expect(provider.recyclers.isNotEmpty, true);

        final lot = EwasteLot(
          id: 'KC-TEST-001',
          materialKey: 'copper',
          materialName: 'Copper',
          quantity: 5,
          unit: 'kg',
          ratePerUnit: 720,
          estimatedValue: 3600,
          photos: const [],
          condition: 'good',
          createdAt: DateTime.now(),
        );

        provider.setMatchingLot(lot);
        expect(provider.selectedMaterialFilter, 'copper');

        final targetRecycler = provider.recyclers.first;
        final req = await provider.submitHandoverRequest(
          lot: lot,
          recycler: targetRecycler,
        );

        expect(req.lotId, 'KC-TEST-001');
        expect(req.status, HandoverStatus.reviewing);
        expect(provider.getRequestForLot('KC-TEST-001'), isNotNull);
      },
    );
  });

  group('Navigation & Flow Integration Test', () {
    testWidgets(
      'Language selection cards select language and transition to Home',
      (WidgetTester tester) async {
        await tester.pumpWidget(const KabadiwalaConnectApp());
        await tester.pump(const Duration(milliseconds: 500));

        // Fast forward past splash timer (2600ms)
        await tester.pump(const Duration(milliseconds: 2700));
        await tester.pumpAndSettle();

        // Now on Language Selection screen
        expect(find.byType(LanguageSelectionScreen), findsOneWidget);
        expect(find.text('हिन्दी'), findsOneWidget);
        expect(find.text('मराठी'), findsOneWidget);
        expect(find.text('English'), findsWidgets);

        // Tap Hindi option
        await tester.tap(find.text('हिन्दी'));
        await tester.pumpAndSettle();

        // Now on HomeDashboardScreen
        expect(find.byType(HomeDashboardScreen), findsOneWidget);
        expect(find.text('नमस्ते, रमेश! 👋'), findsOneWidget);
        expect(find.text('आज के भाव'), findsOneWidget);
        expect(find.text('नया लॉट बनाएँ'), findsOneWidget);

        // Tap Create New Lot CTA -> navigates to CreateLotScreen
        await tester.tap(find.text('नया लॉट बनाएँ'));
        await tester.pumpAndSettle();
        expect(find.byType(CreateLotScreen), findsOneWidget);

        // Pop back to Home
        await tester.tap(find.byIcon(Icons.arrow_back_rounded));
        await tester.pumpAndSettle();
        expect(find.byType(HomeDashboardScreen), findsOneWidget);

        // Tap Nearby Recyclers -> navigates to RecyclersScreen
        await tester.tap(find.text('पास के Recycler'));
        await tester.pumpAndSettle();
        expect(find.byType(RecyclersScreen), findsOneWidget);

        // Pop back to Home
        await tester.tap(find.byIcon(Icons.arrow_back_rounded));
        await tester.pumpAndSettle();

        // Test Bottom Navigation tabs
        // Tap Lots tab on bottom navigation bar
        await tester.tap(
          find.descendant(
            of: find.byType(AppBottomNavigationBar),
            matching: find.byIcon(Icons.inventory_2_outlined),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(LotsScreen), findsOneWidget);

        // Tap Earnings tab on bottom navigation bar
        await tester.tap(
          find.descendant(
            of: find.byType(AppBottomNavigationBar),
            matching: find.byIcon(Icons.account_balance_wallet_outlined),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(EarningsScreen), findsOneWidget);

        // Tap Profile tab on bottom navigation bar
        await tester.tap(
          find.descendant(
            of: find.byType(AppBottomNavigationBar),
            matching: find.byIcon(Icons.person_outline_rounded),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ProfileScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Complete 4-Step Create Lot flow and verify lot appears in My Lots',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(const KabadiwalaConnectApp());
        await tester.pump(const Duration(milliseconds: 500));

        // Fast forward past splash timer
        await tester.pump(const Duration(milliseconds: 2700));
        await tester.pumpAndSettle();

        // Select English language
        await tester.tap(find.text('English').first);
        await tester.pumpAndSettle();

        // Tap Create New Lot button
        await tester.tap(find.text('Create New Lot'));
        await tester.pumpAndSettle();
        expect(find.byType(CreateLotScreen), findsOneWidget);

        // STEP 1: Add Photos
        expect(find.text('Add Photos'), findsWidgets);
        // Tap Camera to add photo
        await tester.tap(find.text('Camera'));
        await tester.pumpAndSettle();
        // Tap Continue -> Step 2
        final step1Btn = find.byKey(const Key('step1_continue_button'));
        await tester.ensureVisible(step1Btn);
        await tester.tap(step1Btn);
        await tester.pumpAndSettle();

        // STEP 2: Material Details
        expect(find.text('Material Details'), findsWidgets);
        expect(find.text('What are you selling?'), findsOneWidget);
        // Select Copper
        await tester.tap(find.text('Copper (तांबा)'));
        await tester.pumpAndSettle();
        // Tap Increment on quantity
        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pumpAndSettle();
        // Tap Continue -> Step 3
        final step2Btn = find.byKey(const Key('step2_continue_button'));
        await tester.ensureVisible(step2Btn);
        await tester.tap(step2Btn);
        await tester.pumpAndSettle();

        // STEP 3: Estimated Value
        expect(find.text('Estimated Value'), findsWidgets);
        expect(find.textContaining('Price Calculation'), findsWidgets);
        // Tap Continue -> Step 4
        final step3Btn = find.byKey(const Key('step3_continue_button'));
        await tester.ensureVisible(step3Btn);
        await tester.tap(step3Btn);
        await tester.pumpAndSettle();

        // STEP 4: Review Lot
        expect(find.text('Review Lot'), findsWidgets);
        expect(find.textContaining('Lot Summary'), findsWidgets);
        // Tap Create Lot
        final submitBtn = find.byKey(const Key('step4_submit_button'));
        await tester.ensureVisible(submitBtn);
        await tester.tap(submitBtn);
        // Wait for simulated async creation in mock lot provider
        await tester.pump(const Duration(milliseconds: 800));
        await tester.pumpAndSettle();

        // SUCCESS SCREEN
        expect(find.textContaining('Lot Created Successfully'), findsWidgets);
        expect(find.textContaining('View My Lots'), findsWidgets);

        // Tap View My Lots
        await tester.tap(find.textContaining('View My Lots').first);
        await tester.pumpAndSettle();

        // Should now be on LotsScreen and see the newly created lot
        expect(find.byType(LotsScreen), findsOneWidget);
        expect(find.text('Copper'), findsWidgets);
      },
    );

    testWidgets(
      'Complete Handover flow: Created Lot -> Find Recyclers -> View Recycler -> Request Handover -> Track -> Verify in My Lots',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(const KabadiwalaConnectApp());
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 2700));
        await tester.pumpAndSettle();

        // Select English
        await tester.tap(find.text('English').first);
        await tester.pumpAndSettle();

        // Step 1: Create a Lot
        await tester.tap(find.text('Create New Lot'));
        await tester.pumpAndSettle();

        // Step 1: Photos -> Continue
        final step1Btn = find.byKey(const Key('step1_continue_button'));
        await tester.ensureVisible(step1Btn);
        await tester.tap(step1Btn);
        await tester.pumpAndSettle();

        // Step 2: Material Details -> Select Copper -> Continue
        await tester.tap(find.text('Copper (तांबा)'));
        await tester.pumpAndSettle();
        final step2Btn = find.byKey(const Key('step2_continue_button'));
        await tester.ensureVisible(step2Btn);
        await tester.tap(step2Btn);
        await tester.pumpAndSettle();

        // Step 3: Estimated Value -> Continue
        final step3Btn = find.byKey(const Key('step3_continue_button'));
        await tester.ensureVisible(step3Btn);
        await tester.tap(step3Btn);
        await tester.pumpAndSettle();

        // Step 4: Submit Lot
        final submitBtn = find.byKey(const Key('step4_submit_button'));
        await tester.ensureVisible(submitBtn);
        await tester.tap(submitBtn);
        await tester.pump(const Duration(milliseconds: 800));
        await tester.pumpAndSettle();

        // Now on Success Screen -> Tap "Find Nearby Recyclers"
        expect(find.textContaining('Find Nearby Recyclers'), findsWidgets);
        await tester.tap(find.textContaining('Find Nearby Recyclers').first);
        await tester.pumpAndSettle();

        // Verify on RecyclersScreen
        expect(find.byType(RecyclersScreen), findsOneWidget);
        expect(find.textContaining('Nearby Recyclers'), findsWidgets);
        expect(find.textContaining('Recommended for Lot'), findsWidgets);

        // Tap View Details on the first recycler card
        final viewBtn = find.textContaining('View Details').first;
        await tester.ensureVisible(viewBtn);
        await tester.tap(viewBtn);
        await tester.pumpAndSettle();

        // Verify on RecyclerDetailsScreen
        expect(find.byType(RecyclerDetailsScreen), findsOneWidget);
        expect(find.textContaining('Request Handover'), findsWidgets);

        // Tap Request Handover CTA -> Opens RequestHandoverModal
        final reqHandoverBtn = find.byKey(
          const Key('request_handover_cta_button'),
        );
        await tester.ensureVisible(reqHandoverBtn);
        await tester.tap(reqHandoverBtn);
        await tester.pumpAndSettle();

        // In Modal: Tap "Send Request"
        final sendBtn = find.byKey(const Key('send_handover_request_button'));
        expect(sendBtn, findsOneWidget);
        await tester.tap(sendBtn);
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        // Verify on RequestSubmittedScreen
        expect(find.byType(RequestSubmittedScreen), findsOneWidget);
        expect(find.textContaining('Request Sent'), findsWidgets);
        expect(find.byKey(const Key('track_handover_button')), findsOneWidget);

        // Tap "Track Handover" -> Lands on HandoverTrackingScreen
        await tester.tap(find.byKey(const Key('track_handover_button')));
        await tester.pumpAndSettle();

        expect(find.byType(HandoverTrackingScreen), findsOneWidget);
        expect(find.textContaining('Handover Tracking'), findsWidgets);
        expect(find.textContaining('Recycler Reviewing'), findsWidgets);

        // Tap "Back to My Lots" -> Lands on LotsScreen
        await tester.tap(find.textContaining('Back to My Lots').first);
        await tester.pumpAndSettle();

        expect(find.byType(LotsScreen), findsOneWidget);
        // Verify lot now shows "Recycler Reviewing" status!
        expect(find.textContaining('Recycler Reviewing'), findsWidgets);
      },
    );
  });
}
