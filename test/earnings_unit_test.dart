import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kabadiwala_connect/core/localization/app_localizations.dart';
import 'package:kabadiwala_connect/core/localization/language_provider.dart';
import 'package:kabadiwala_connect/core/theme/theme_provider.dart';
import 'package:kabadiwala_connect/features/earnings/earnings_screen.dart';
import 'package:kabadiwala_connect/features/earnings/models/transaction_model.dart';
import 'package:kabadiwala_connect/features/earnings/screens/transaction_detail_screen.dart';
import 'package:kabadiwala_connect/features/earnings/services/transaction_provider.dart';
import 'package:kabadiwala_connect/features/earnings/services/transaction_service.dart';
import 'package:kabadiwala_connect/features/lots/models/ewaste_lot.dart';
import 'package:kabadiwala_connect/features/lots/services/lot_provider.dart';
import 'package:kabadiwala_connect/features/recyclers/models/handover_request.dart';
import 'package:kabadiwala_connect/features/recyclers/services/recycler_provider.dart';
import 'package:kabadiwala_connect/core/navigation/app_router.dart';
import 'package:provider/provider.dart';

Widget _createTestableWidget({
  required Widget child,
  TransactionProvider? txnProvider,
  LanguageProvider? langProvider,
  ThemeProvider? themeProvider,
}) {
  final effectiveLang =
      langProvider ?? (LanguageProvider()..setLanguage(AppLanguage.english));
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => themeProvider ?? ThemeProvider()),
      ChangeNotifierProvider.value(value: effectiveLang),
      ChangeNotifierProvider(create: (_) => LotProvider()),
      ChangeNotifierProvider(create: (_) => RecyclerProvider()),
      ChangeNotifierProvider(
        create: (_) => txnProvider ?? TransactionProvider(),
      ),
    ],
    child: MaterialApp(home: child, onGenerateRoute: AppRoutes.onGenerateRoute),
  );
}

void main() {
  group('1. Transaction Model & Math Calculations', () {
    test(
      'Correctly computes gross and net amounts with 0% facilitation fee',
      () {
        final txn = Transaction(
          id: 'TXN-TEST-001',
          handoverRequestId: 'REQ-TEST-001',
          lotId: 'KC-2026-001',
          material: 'Copper Motors',
          quantity: 10.0,
          unit: 'kg',
          agreedRate: 700.0,
          grossAmount: 7000.0,
          facilitationFee: 0.0,
          netAmount: 7000.0,
          recyclerId: 'REC-001',
          recyclerName: 'GreenCycle Recycling',
          createdAt: DateTime.now(),
        );

        expect(txn.grossAmount, 7000.0);
        expect(txn.facilitationFee, 0.0);
        expect(txn.netAmount, 7000.0);
        expect(txn.status, TransactionStatus.completed);
        expect(txn.disclaimerNotice, contains('circular'));
      },
    );

    test('Correctly computes transparent facilitation fee when specified', () {
      final txn = Transaction(
        id: 'TXN-TEST-002',
        handoverRequestId: 'REQ-TEST-002',
        lotId: 'KC-2026-002',
        material: 'Aluminium Heat Sinks',
        quantity: 20.0,
        unit: 'kg',
        agreedRate: 180.0,
        grossAmount: 3600.0,
        facilitationFee: 72.0, // 2%
        netAmount: 3528.0,
        recyclerId: 'REC-002',
        recyclerName: 'EcoTech Hub',
        createdAt: DateTime.now(),
      );

      expect(txn.grossAmount, 3600.0);
      expect(txn.facilitationFee, 72.0);
      expect(txn.netAmount, 3528.0);
      expect(txn.grossAmount - txn.facilitationFee, txn.netAmount);
    });

    test('Offline transaction creates pending status and disclaimer flag', () {
      final txn = Transaction(
        id: 'TXN-OFFLINE-001',
        handoverRequestId: 'REQ-OFFLINE-001',
        lotId: 'KC-2026-003',
        material: 'E-Waste PCBs',
        quantity: 5.0,
        unit: 'kg',
        agreedRate: 50.0,
        grossAmount: 250.0,
        facilitationFee: 0.0,
        netAmount: 250.0,
        recyclerId: 'REC-001',
        recyclerName: 'GreenCycle Recycling',
        createdAt: DateTime.now(),
        status: TransactionStatus.pending,
        paymentStatus: PaymentStatus.pending,
        isPendingSync: true,
      );

      expect(txn.isPendingSync, isTrue);
      expect(txn.status, TransactionStatus.pending);
    });
  });

  group('2. Transaction Service & Provider Aggregations', () {
    test(
      'TransactionProvider initializes with seeded demo transactions',
      () async {
        final service = MockTransactionService();
        final provider = TransactionProvider(service: service);
        await provider.loadTransactions();

        expect(provider.transactions.length, greaterThanOrEqualTo(2));
        expect(provider.totalEarnings, greaterThan(0));
        expect(provider.completedLotsCount, greaterThan(0));
      },
    );

    test(
      'TransactionProvider records new transaction from HandoverRequest',
      () async {
        final service = MockTransactionService();
        final provider = TransactionProvider(service: service);
        await provider.loadTransactions();

        final initialCount = provider.transactions.length;
        final initialTotal = provider.totalEarnings;

        final lot = EwasteLot(
          id: 'KC-2026-99999',
          materialKey: 'copper',
          materialName: 'High-grade Copper',
          quantity: 10.0,
          unit: 'kg',
          ratePerUnit: 700.0,
          estimatedValue: 7000.0,
          photos: const [],
          condition: 'good',
          status: 'Handover Confirmed',
          createdAt: DateTime.now(),
        );

        final req = HandoverRequest(
          id: 'REQ-99999',
          lotId: lot.id,
          recyclerId: 'REC-001',
          recyclerName: 'GreenCycle Recycling',
          status: HandoverStatus.confirmed,
          createdAt: DateTime.now(),
          estimatedValue: 7000.0,
          materialName: lot.materialName,
          quantity: lot.quantity,
          unit: lot.unit,
        );

        final txn = await provider.recordHandoverCompletion(
          request: req,
          lot: lot,
        );

        expect(txn.lotId, lot.id);
        expect(txn.netAmount, 7000.0);
        expect(provider.transactions.length, initialCount + 1);
        expect(provider.totalEarnings, initialTotal + 7000.0);
        expect(provider.getTransactionByLotId(lot.id), isNotNull);
      },
    );

    test(
      'Offline transaction sync updates pending transaction to completed',
      () async {
        final service = MockTransactionService();
        final provider = TransactionProvider(service: service);
        await provider.loadTransactions();

        final req = HandoverRequest(
          id: 'REQ-OFFLINE-99',
          lotId: 'KC-OFFLINE-99',
          recyclerId: 'REC-001',
          recyclerName: 'GreenCycle Recycling',
          status: HandoverStatus.pendingSync,
          createdAt: DateTime.now(),
          estimatedValue: 1200.0,
          materialName: 'PCBs',
          quantity: 10.0,
          unit: 'kg',
          isPendingSync: true,
        );

        await provider.recordHandoverCompletionFromRequest(
          request: req,
          isOffline: true,
        );

        expect(provider.pendingSyncCount, greaterThanOrEqualTo(1));
        expect(provider.pendingEarnings, greaterThanOrEqualTo(1200.0));

        final syncedCount = provider.syncPendingTransactions();
        expect(syncedCount, greaterThanOrEqualTo(1));
        expect(provider.pendingSyncCount, 0);
      },
    );
  });

  group('3. EarningsScreen UI Widget Tests', () {
    testWidgets('Renders Total Recorded Value hero card and transaction list', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final provider = TransactionProvider();
      await provider.loadTransactions();

      await tester.pumpWidget(
        _createTestableWidget(
          child: const EarningsScreen(isTab: false),
          txnProvider: provider,
        ),
      );
      await tester.pumpAndSettle();

      // Verify Ledger Title
      expect(find.text('Digital Transaction Ledger'), findsOneWidget);

      // Verify Total Recorded Value & Circular Ledger Badge
      expect(find.text('Total Recorded Value'), findsOneWidget);
      expect(find.text('Circular Ledger'), findsOneWidget);

      // Verify Metrics Row: This Month & Pending
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('Pending Verification'), findsOneWidget);

      // Verify seeded transactions render
      expect(
        find.text('TXN-2026-00088'),
        findsNothing,
      ); // Cards show recycler name
      expect(find.textContaining('GreenCycle Recycling'), findsWidgets);
      expect(find.textContaining('Copper'), findsWidgets);
    });

    testWidgets('Tapping a transaction card opens TransactionDetailScreen', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final provider = TransactionProvider();
      await provider.loadTransactions();

      await tester.pumpWidget(
        _createTestableWidget(
          child: const EarningsScreen(isTab: false),
          txnProvider: provider,
        ),
      );
      await tester.pumpAndSettle();

      // Find first transaction card by text and tap
      final firstCard = find.textContaining('GreenCycle Recycling').first;
      await tester.tap(firstCard);
      await tester.pumpAndSettle();

      // Detail screen should open with Receipt Title
      expect(find.text('Digital Transaction Receipt'), findsOneWidget);
      expect(find.text('Agreed Demo Rate'), findsOneWidget);
      expect(find.text('Gross Value'), findsOneWidget);
      expect(find.text('Facilitation Fee (0%)'), findsOneWidget);
      expect(find.text('Net Recorded Amount'), findsOneWidget);
      expect(find.textContaining('prototype'), findsWidgets);
    });
  });

  group('4. TransactionDetailScreen Widget Tests', () {
    testWidgets('Displays complete financial breakdown and disclaimer', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final txn = Transaction(
        id: 'TXN-2026-TEST01',
        handoverRequestId: 'REQ-2026-TEST01',
        lotId: 'KC-2026-TEST01',
        material: 'High Purity Copper',
        quantity: 8.0,
        unit: 'kg',
        agreedRate: 720.0,
        grossAmount: 5760.0,
        facilitationFee: 0.0,
        netAmount: 5760.0,
        recyclerId: 'REC-001',
        recyclerName: 'GreenCycle Recycling Pune',
        createdAt: DateTime(2026, 9, 8, 14, 30),
      );

      await tester.pumpWidget(
        _createTestableWidget(child: TransactionDetailScreen(transaction: txn)),
      );
      await tester.pumpAndSettle();

      expect(find.text('TXN-2026-TEST01'), findsOneWidget);
      expect(find.text('KC-2026-TEST01'), findsOneWidget);
      expect(find.text('High Purity Copper'), findsOneWidget);
      expect(find.text('8.0 kg'), findsOneWidget);
      expect(find.text('GreenCycle Recycling Pune'), findsOneWidget);
      expect(find.text('₹720/kg'), findsOneWidget);
      expect(find.text('₹5760'), findsWidgets);
      expect(find.text('₹0'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.textContaining('prototype'), findsWidgets);
    });
  });
}
