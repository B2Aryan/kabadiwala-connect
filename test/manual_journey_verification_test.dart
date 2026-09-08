import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/localization/app_localizations.dart';
import 'package:kabadiwala_connect/core/localization/language_provider.dart';
import 'package:kabadiwala_connect/features/home/home_dashboard_screen.dart';
import 'package:kabadiwala_connect/features/home/widgets/recommended_recycler_card.dart';
import 'package:kabadiwala_connect/features/lots/lots_screen.dart';
import 'package:kabadiwala_connect/features/lots/services/lot_provider.dart';
import 'package:kabadiwala_connect/features/onboarding/language_selection_screen.dart';
import 'package:kabadiwala_connect/features/recyclers/models/handover_request.dart';
import 'package:kabadiwala_connect/features/recyclers/recyclers_screen.dart';
import 'package:kabadiwala_connect/features/recyclers/screens/handover_tracking_screen.dart';
import 'package:kabadiwala_connect/features/recyclers/screens/recycler_details_screen.dart';
import 'package:kabadiwala_connect/features/recyclers/screens/request_submitted_screen.dart';
import 'package:kabadiwala_connect/features/recyclers/services/recycler_provider.dart';
import 'package:kabadiwala_connect/features/recyclers/widgets/recycler_card.dart';
import 'package:kabadiwala_connect/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Comprehensive User Journey & Visual Verification Tests', () {
    testWidgets(
      'Complete Journey: Home -> Nearby Recyclers -> Details -> Request Handover -> Tracking -> My Lots (Zero Overflow)',
      (WidgetTester tester) async {
        // Standard phone resolution
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

        // 1. Language Selection Screen -> Select English
        expect(find.byType(LanguageSelectionScreen), findsOneWidget);
        await tester.tap(find.text('English').first);
        await tester.pumpAndSettle();

        // 2. Home Dashboard
        expect(find.byType(HomeDashboardScreen), findsOneWidget);
        expect(find.byType(RecommendedRecyclerCard), findsOneWidget);
        expect(find.text('Nearby Recyclers'), findsWidgets);

        // Tap Recommended Recycler Card 'View →' to test direct shortcut
        final recViewBtn = find.descendant(
          of: find.byType(RecommendedRecyclerCard),
          matching: find.text('View →'),
        );
        expect(recViewBtn, findsOneWidget);
        await tester.tap(recViewBtn);
        await tester.pumpAndSettle();

        // Should land on RecyclerDetailsScreen
        expect(find.byType(RecyclerDetailsScreen), findsOneWidget);
        expect(
          find.textContaining('Demo facility for prototype validation'),
          findsOneWidget,
        );

        // Pop back to Home
        await tester.tap(find.byIcon(Icons.arrow_back_rounded));
        await tester.pumpAndSettle();
        expect(find.byType(HomeDashboardScreen), findsOneWidget);

        // 3. Tap 'Nearby Recyclers' Quick Action -> lands on RecyclersScreen
        await tester.tap(find.text('Nearby Recyclers'));
        await tester.pumpAndSettle();
        expect(find.byType(RecyclersScreen), findsOneWidget);
        expect(find.byType(RecyclerCard), findsWidgets);

        // Verify match scores and demo badges are displayed
        expect(find.textContaining('Match'), findsWidgets);
        expect(find.textContaining('DEMO DATA'), findsWidgets);

        // 4. Test Filter Sheet
        final filterBtn = find.byKey(const Key('recycler_filter_button'));
        expect(filterBtn, findsOneWidget);
        await tester.tap(filterBtn);
        await tester.pumpAndSettle();

        // Filter modal is open
        expect(find.textContaining('Filter Recyclers'), findsWidgets);
        expect(find.textContaining('Copper (तांबा)'), findsWidgets);

        // Apply Copper filter
        await tester.tap(find.text('Copper (तांबा)'));
        await tester.pumpAndSettle();
        final applyBtn = find.text('Apply Filters');
        await tester.ensureVisible(applyBtn);
        await tester.tap(applyBtn);
        await tester.pumpAndSettle();

        // Verify filtered recyclers list is present and zero overflow
        expect(find.byType(RecyclerCard), findsWidgets);

        // 5. Navigate to Recycler Details on the top recycler
        final firstDetailsBtn = find.text('View Details').first;
        await tester.ensureVisible(firstDetailsBtn);
        await tester.tap(firstDetailsBtn);
        await tester.pumpAndSettle();

        expect(find.byType(RecyclerDetailsScreen), findsOneWidget);

        // 6. Request Handover CTA
        final reqCta = find.byKey(const Key('request_handover_cta_button'));
        await tester.ensureVisible(reqCta);
        await tester.tap(reqCta);
        await tester.pumpAndSettle();

        // Handover Confirmation Modal opens
        final sendBtn = find.byKey(const Key('send_handover_request_button'));
        expect(sendBtn, findsOneWidget);
        await tester.tap(sendBtn);
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        // 7. Request Submitted Screen
        expect(find.byType(RequestSubmittedScreen), findsOneWidget);
        expect(find.textContaining('Handover Request Sent!'), findsWidgets);

        // 8. Track Handover
        final trackBtn = find.byKey(const Key('track_handover_button'));
        expect(trackBtn, findsOneWidget);
        await tester.tap(trackBtn);
        await tester.pumpAndSettle();

        // 9. Handover Tracking Screen
        expect(find.byType(HandoverTrackingScreen), findsOneWidget);
        expect(find.textContaining('Handover Tracking'), findsWidgets);
        expect(find.textContaining('Recycler Reviewing'), findsWidgets);

        // 10. Back to My Lots
        final backLotsBtn = find.textContaining('Back to My Lots').first;
        await tester.tap(backLotsBtn);
        await tester.pumpAndSettle();

        expect(find.byType(LotsScreen), findsOneWidget);
        expect(find.textContaining('Recycler Reviewing'), findsWidgets);
      },
    );

    testWidgets('Verify Light & Dark Mode visual stability across new screens', (
      WidgetTester tester,
    ) async {
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

      // Tap Hindi
      await tester.tap(find.text('हिन्दी'));
      await tester.pumpAndSettle();

      // Find theme toggle button in AppHeader (dark_mode_rounded in light mode)
      final themeToggleBtn = find.byIcon(Icons.dark_mode_rounded);
      expect(themeToggleBtn, findsOneWidget);

      // Switch to Dark Mode
      await tester.tap(themeToggleBtn);
      await tester.pumpAndSettle();

      // Verify Home in Dark Mode (now shows light mode toggle icon)
      expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
      expect(find.byType(RecommendedRecyclerCard), findsOneWidget);

      // Open RecyclersScreen in Dark Mode
      await tester.tap(find.text('पास के Recycler'));
      await tester.pumpAndSettle();
      expect(find.byType(RecyclersScreen), findsOneWidget);

      // Open RecyclerDetailsScreen in Dark Mode
      await tester.tap(find.text('विवरण देखें (View)').first);
      await tester.pumpAndSettle();
      expect(find.byType(RecyclerDetailsScreen), findsOneWidget);

      // Pop back to RecyclersScreen
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // Pop back to Home
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // Switch back to Light Mode
      await tester.tap(find.byIcon(Icons.light_mode_rounded));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
    });

    testWidgets('Verify Multilingual vernacular stability (HI, MR, EN)', (
      WidgetTester tester,
    ) async {
      final langProvider = LanguageProvider();

      // Hindi verification
      langProvider.setLanguage(AppLanguage.hindi);
      expect(langProvider.tr('recyclersTitle'), 'पास के Recycler (Demo)');
      expect(
        langProvider.tr('recommendedRecycler'),
        'अनुशंसित रीसायकलकर्ता (Recommended)',
      );
      expect(langProvider.tr('pendingSync'), 'सिंक प्रतीक्षित');
      expect(
        langProvider.tr('statusRecyclerSelected'),
        'रीसायकलकर्ता चुना गया',
      );

      // Marathi verification
      langProvider.setLanguage(AppLanguage.marathi);
      expect(langProvider.tr('recyclersTitle'), 'जवळचे Recycler (Demo)');
      expect(
        langProvider.tr('recommendedRecycler'),
        'शिफारस केलेले रीसायकलर (Recommended)',
      );
      expect(langProvider.tr('pendingSync'), 'सिंक प्रलंबित');
      expect(
        langProvider.tr('statusRecyclerSelected'),
        'पुनर्चक्रणकर्ता निवडला',
      );

      // English verification
      langProvider.setLanguage(AppLanguage.english);
      expect(langProvider.tr('recyclersTitle'), 'Nearby Recyclers (Demo)');
      expect(langProvider.tr('recommendedRecycler'), 'Recommended Recycler');
      expect(langProvider.tr('pendingSync'), 'Pending Sync');
      expect(langProvider.tr('statusRecyclerSelected'), 'Recycler Selected');
    });

    test('Offline Mode Simulation and Pending Sync Flow', () async {
      final recyclerProvider = RecyclerProvider();
      final lotProvider = LotProvider();
      await recyclerProvider.loadRecyclers();

      // Set offline mode
      recyclerProvider.setOffline(true);
      expect(recyclerProvider.isOffline, true);

      final lot = lotProvider.lots.first;
      final recycler = recyclerProvider.recyclers.first;

      // Submit while offline
      final request = await recyclerProvider.submitHandoverRequest(
        lot: lot,
        recycler: recycler,
      );

      // Verify request entered pendingSync state
      expect(request.isPendingSync, true);
      expect(request.status, HandoverStatus.pendingSync);

      // Assign to lot as Pending Sync
      lotProvider.assignRecyclerToLot(
        lot.id,
        recyclerId: recycler.id,
        recyclerName: recycler.name,
        newStatus: 'Pending Sync',
      );

      expect(lotProvider.lots.first.status, 'Pending Sync');

      // Reconnect and trigger sync
      recyclerProvider.setOffline(false);
      final synced = recyclerProvider.syncPendingRequests(lotProvider);
      expect(synced, 1);

      // Verify transitioned to Recycler Reviewing
      expect(
        recyclerProvider.getRequestForLot(lot.id)!.status,
        HandoverStatus.reviewing,
      );
      expect(lotProvider.lots.first.status, 'Recycler Reviewing');
    });
  });
}
