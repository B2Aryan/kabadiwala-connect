import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/localization/app_localizations.dart';
import 'package:kabadiwala_connect/core/localization/language_provider.dart';
import 'package:kabadiwala_connect/core/navigation/app_router.dart';
import 'package:kabadiwala_connect/core/theme/app_theme.dart';
import 'package:kabadiwala_connect/core/theme/theme_provider.dart';
import 'package:kabadiwala_connect/features/earnings/services/transaction_provider.dart';
import 'package:kabadiwala_connect/features/home/home_dashboard_screen.dart';
import 'package:kabadiwala_connect/features/lots/services/lot_provider.dart';
import 'package:kabadiwala_connect/features/recyclers/services/recycler_provider.dart';
import 'package:provider/provider.dart';

Widget _createFullApp() {
  final langProvider = LanguageProvider()..setLanguage(AppLanguage.english);
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider.value(value: langProvider),
      ChangeNotifierProvider(create: (_) => LotProvider()),
      ChangeNotifierProvider(create: (_) => RecyclerProvider()),
      ChangeNotifierProvider(create: (_) => TransactionProvider()),
    ],
    child: Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, langProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const HomeDashboardScreen(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    ),
  );
}

void main() {
  testWidgets(
    'End-to-End Journey: Handover Completion -> Transaction Recorded -> Earnings Ledger Updated',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_createFullApp());
      await tester.pumpAndSettle();

      // 1. Verify Home Screen loaded
      expect(find.byType(HomeDashboardScreen), findsOneWidget);

      // 2. Switch to 'My Lots' tab (index 1)
      final lotsTabFinder = find.text('Lots');
      expect(lotsTabFinder, findsOneWidget);
      await tester.tap(lotsTabFinder);
      await tester.pumpAndSettle();

      // 3. In My Lots, check seeded lot KC-2026-00124 (Verified Handover)
      expect(find.text('KC-2026-00124'), findsOneWidget);
      expect(find.text('Handover Verified'), findsWidgets);
      expect(find.text('View Receipt →'), findsWidgets);

      // 4. Tap 'View Receipt →'
      final receiptBtn = find.text('View Receipt →').first;
      await tester.tap(receiptBtn);
      await tester.pumpAndSettle();

      // 5. Verify TransactionDetailScreen receipt opened
      expect(find.text('Digital Transaction Receipt'), findsOneWidget);
      expect(find.text('Net Recorded Amount'), findsOneWidget);
      expect(find.textContaining('prototype'), findsWidgets);

      // 6. Go back to previous screen
      final backBtn = find.byIcon(Icons.arrow_back);
      if (backBtn.evaluate().isNotEmpty) {
        await tester.tap(backBtn.first);
        await tester.pumpAndSettle();
      }

      // 7. Switch to 'Earnings' tab (index 2)
      final earningsTabFinder = find.text('Earnings');
      expect(earningsTabFinder, findsOneWidget);
      await tester.tap(earningsTabFinder);
      await tester.pumpAndSettle();

      // 8. Verify dynamic Earnings Ledger
      expect(find.text('Digital Transaction Ledger'), findsOneWidget);
      expect(find.text('Total Recorded Value'), findsOneWidget);
      expect(find.text('Circular Ledger'), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('Recent Transactions'), findsOneWidget);

      // 9. Verify filter chips interaction
      final allChip = find.text('All Transactions');
      final completedChip = find.text('Completed');
      expect(allChip, findsOneWidget);
      expect(completedChip, findsOneWidget);

      await tester.tap(completedChip);
      await tester.pumpAndSettle();

      // 10. Switch language to Hindi and verify vernacular strings
      final langProvider = Provider.of<LanguageProvider>(
        tester.element(find.byType(HomeDashboardScreen)),
        listen: false,
      );
      langProvider.setLanguage(AppLanguage.hindi);
      await tester.pumpAndSettle();

      expect(find.text('डिजिटल लेनदेन बहीखाता'), findsOneWidget);
      expect(find.text('कुल दर्ज मूल्य'), findsOneWidget);
      expect(find.text('इस महीने'), findsOneWidget);

      // 11. Switch language to Marathi and verify vernacular strings
      langProvider.setLanguage(AppLanguage.marathi);
      await tester.pumpAndSettle();

      expect(find.text('डिजिटल व्यवहार नोंदवही'), findsOneWidget);
      expect(find.text('एकूण नोंदवलेले मूल्य'), findsOneWidget);
      expect(find.text('या महिन्यात'), findsOneWidget);
    },
  );
}
