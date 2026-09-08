import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/localization/app_localizations.dart';
import 'package:kabadiwala_connect/core/localization/language_provider.dart';
import 'package:kabadiwala_connect/core/theme/theme_provider.dart';
import 'package:kabadiwala_connect/features/earnings/earnings_screen.dart';
import 'package:kabadiwala_connect/features/home/home_dashboard_screen.dart';
import 'package:kabadiwala_connect/features/home/widgets/app_bottom_navigation_bar.dart';
import 'package:kabadiwala_connect/features/home/widgets/recommended_recycler_card.dart';
import 'package:kabadiwala_connect/features/lots/create_lot_screen.dart';
import 'package:kabadiwala_connect/features/lots/lots_screen.dart';
import 'package:kabadiwala_connect/features/lots/models/ewaste_lot.dart';
import 'package:kabadiwala_connect/features/lots/services/lot_provider.dart';
import 'package:kabadiwala_connect/features/onboarding/language_selection_screen.dart';
import 'package:kabadiwala_connect/features/profile/profile_screen.dart';
import 'package:kabadiwala_connect/features/recyclers/models/handover_request.dart';
import 'package:kabadiwala_connect/features/recyclers/models/recycler.dart';
import 'package:kabadiwala_connect/features/recyclers/recyclers_screen.dart';
import 'package:kabadiwala_connect/features/recyclers/screens/handover_tracking_screen.dart';
import 'package:kabadiwala_connect/features/recyclers/screens/recycler_details_screen.dart';
import 'package:kabadiwala_connect/features/recyclers/screens/request_submitted_screen.dart';
import 'package:kabadiwala_connect/features/recyclers/services/recycler_matcher.dart';
import 'package:kabadiwala_connect/features/recyclers/services/recycler_provider.dart';
import 'package:kabadiwala_connect/features/recyclers/services/recycler_service.dart';
import 'package:kabadiwala_connect/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('State Providers & Matching Unit Tests', () {
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
      langProvider.setLanguage(AppLanguage.hindi);
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
      'RecyclerMatcher ranks recyclers by material compatibility and distance',
      () {
        const recyclers = [
          Recycler(
            id: 'REC-1',
            name: 'Copper Hub',
            distanceKm: 1.5,
            acceptedMaterials: ['copper'],
            pickupAvailable: true,
            operatingHours: '9-5',
            address: 'Area 1',
            phone: '123',
            rating: 4.8,
          ),
          Recycler(
            id: 'REC-2',
            name: 'Far PCB Yard',
            distanceKm: 8.0,
            acceptedMaterials: ['eWaste'],
            pickupAvailable: false,
            operatingHours: '9-5',
            address: 'Area 2',
            phone: '456',
            rating: 4.2,
          ),
        ];

        final copperLot = EwasteLot(
          id: 'KC-TEST-COPPER',
          materialKey: 'copper',
          materialName: 'Copper Wires',
          quantity: 10,
          ratePerUnit: 720,
          estimatedValue: 7200,
          photos: const [],
          condition: 'good',
          createdAt: DateTime.now(),
        );

        final ranked = RecyclerMatcher.rankRecyclers(
          recyclers: recyclers,
          lot: copperLot,
        );

        // REC-1 accepts copper, is close, and has pickup -> should score much higher than REC-2
        expect(ranked.first.recycler.id, 'REC-1');
        expect(ranked.first.isMaterialMatch, true);
        expect(ranked.first.score, greaterThan(80.0));
        expect(ranked.last.isMaterialMatch, false);
        expect(ranked.last.score, lessThan(60.0));
      },
    );

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
      'RecyclerProvider offline-first pending sync and sync resolution',
      () async {
        final recyclerProvider = RecyclerProvider();
        final lotProvider = LotProvider();
        await recyclerProvider.loadRecyclers();

        final lot = EwasteLot(
          id: 'KC-OFFLINE-001',
          materialKey: 'copper',
          materialName: 'Copper Motors',
          quantity: 4,
          ratePerUnit: 720,
          estimatedValue: 2880,
          photos: const [],
          condition: 'good',
          status: 'Created',
          createdAt: DateTime.now(),
        );

        // Turn offline mode ON
        recyclerProvider.setOffline(true);
        expect(recyclerProvider.isOffline, true);

        final targetRecycler = recyclerProvider.recyclers.first;
        final req = await recyclerProvider.submitHandoverRequest(
          lot: lot,
          recycler: targetRecycler,
        );

        // Should enter pendingSync state
        expect(req.isPendingSync, true);
        expect(req.status, HandoverStatus.pendingSync);

        lotProvider.assignRecyclerToLot(
          lot.id,
          recyclerId: targetRecycler.id,
          recyclerName: targetRecycler.name,
          newStatus: 'Pending Sync',
        );

        // Verify stored in provider
        final storedReq = recyclerProvider.getRequestForLot(lot.id);
        expect(storedReq, isNotNull);
        expect(storedReq!.isPendingSync, true);

        // Restore network connectivity and sync
        recyclerProvider.setOffline(false);
        final count = recyclerProvider.syncPendingRequests(lotProvider);
        expect(count, 1);

        final syncedReq = recyclerProvider.getRequestForLot(lot.id);
        expect(syncedReq!.isPendingSync, false);
        expect(syncedReq.status, HandoverStatus.reviewing);
      },
    );

    test('Lot and HandoverRequest state lifecycle transitions', () async {
      final recyclerProvider = RecyclerProvider();
      final lotProvider = LotProvider();
      await recyclerProvider.loadRecyclers();

      final lot = EwasteLot(
        id: 'KC-LIFECYCLE-001',
        materialKey: 'eWaste',
        materialName: 'PCBs',
        quantity: 2,
        ratePerUnit: 45,
        estimatedValue: 90,
        photos: const [],
        condition: 'good',
        status: 'Created',
        createdAt: DateTime.now(),
      );

      final recycler = recyclerProvider.recyclers.first;

      // 1. Assign Recycler
      lotProvider.assignRecyclerToLot(
        lot.id,
        recyclerId: recycler.id,
        recyclerName: recycler.name,
      );

      // 2. Submit Handover Request
      await recyclerProvider.submitHandoverRequest(
        lot: lot,
        recycler: recycler,
      );
      lotProvider.updateLotStatus(lot.id, 'Pickup Requested');

      // 3. Advance to Scheduled
      recyclerProvider.advanceRequestStatus(
        lot.id,
        HandoverStatus.scheduled,
        lotProvider,
      );
      expect(
        recyclerProvider.getRequestForLot(lot.id)!.status,
        HandoverStatus.scheduled,
      );

      // 4. Advance to Handover Confirmed
      recyclerProvider.advanceRequestStatus(
        lot.id,
        HandoverStatus.confirmed,
        lotProvider,
      );
      expect(
        recyclerProvider.getRequestForLot(lot.id)!.status,
        HandoverStatus.confirmed,
      );
    });
  });

  group('Navigation & Flow Integration Test', () {
    testWidgets(
      'Language selection cards select language and transition to Home with Recommended Card',
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

        // Verify RecommendedRecyclerCard on Home
        expect(find.byType(RecommendedRecyclerCard), findsOneWidget);

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
        await tester.tap(find.text('Camera'));
        await tester.pumpAndSettle();
        final step1Btn = find.byKey(const Key('step1_continue_button'));
        await tester.ensureVisible(step1Btn);
        await tester.tap(step1Btn);
        await tester.pumpAndSettle();

        // STEP 2: Material Details
        expect(find.text('Material Details'), findsWidgets);
        expect(find.text('What are you selling?'), findsOneWidget);
        await tester.tap(find.text('Copper (तांबा)'));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pumpAndSettle();
        final step2Btn = find.byKey(const Key('step2_continue_button'));
        await tester.ensureVisible(step2Btn);
        await tester.tap(step2Btn);
        await tester.pumpAndSettle();

        // STEP 3: Estimated Value
        expect(find.text('Estimated Value'), findsWidgets);
        expect(find.textContaining('Price Calculation'), findsWidgets);
        final step3Btn = find.byKey(const Key('step3_continue_button'));
        await tester.ensureVisible(step3Btn);
        await tester.tap(step3Btn);
        await tester.pumpAndSettle();

        // STEP 4: Review Lot
        expect(find.text('Review Lot'), findsWidgets);
        expect(find.textContaining('Lot Summary'), findsWidgets);
        final submitBtn = find.byKey(const Key('step4_submit_button'));
        await tester.ensureVisible(submitBtn);
        await tester.tap(submitBtn);
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
