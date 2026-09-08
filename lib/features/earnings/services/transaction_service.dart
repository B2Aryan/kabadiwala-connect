import '../../lots/models/ewaste_lot.dart';
import '../../recyclers/models/handover_request.dart';
import '../models/transaction_model.dart';

abstract class TransactionService {
  Future<List<Transaction>> getTransactions();
  Future<Transaction> recordTransactionFromHandover({
    required HandoverRequest request,
    required EwasteLot lot,
    double facilitationFeePercent = 0.0, // Zero fee default for MVP
    bool isOffline = false,
  });
}

class MockTransactionService implements TransactionService {
  final bool simulateDelay;

  MockTransactionService({this.simulateDelay = false});

  static final List<Transaction> _demoTransactions = [
    Transaction(
      id: 'TXN-2026-00088',
      lotId: 'KC-2026-00124',
      recyclerId: 'REC-DEMO-001',
      recyclerName: 'GreenCycle Recycling — Demo',
      material: 'Mixed Electronic PCBs',
      quantity: 25.0,
      unit: 'kg',
      agreedRate: 45.0,
      grossAmount: 1125.0,
      facilitationFee: 0.0,
      netAmount: 1125.0,
      status: TransactionStatus.completed,
      paymentStatus: PaymentStatus.recorded,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      completedAt: DateTime.now().subtract(const Duration(hours: 3)),
      isPendingSync: false,
      isDemo: true,
    ),
    Transaction(
      id: 'TXN-2026-00085',
      lotId: 'KC-2026-00115',
      recyclerId: 'REC-DEMO-002',
      recyclerName: 'EcoLoop Recycler — Demo',
      material: 'Copper Motors & Wires',
      quantity: 8.0,
      unit: 'kg',
      agreedRate: 720.0,
      grossAmount: 5760.0,
      facilitationFee: 0.0,
      netAmount: 5760.0,
      status: TransactionStatus.completed,
      paymentStatus: PaymentStatus.recorded,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      completedAt: DateTime.now().subtract(const Duration(days: 2)),
      isPendingSync: false,
      isDemo: true,
    ),
  ];

  @override
  Future<List<Transaction>> getTransactions() async {
    if (simulateDelay) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return List.from(_demoTransactions);
  }

  @override
  Future<Transaction> recordTransactionFromHandover({
    required HandoverRequest request,
    required EwasteLot lot,
    double facilitationFeePercent = 0.0,
    bool isOffline = false,
  }) async {
    if (simulateDelay) {
      await Future.delayed(const Duration(milliseconds: 150));
    }

    final gross = lot.quantity * lot.ratePerUnit;
    final fee = (gross * facilitationFeePercent) / 100.0;
    final net = gross - fee;

    final nextIdNum = 89 + _demoTransactions.length - 2;
    final newTxnId = 'TXN-2026-00$nextIdNum';
    final now = DateTime.now();

    final newTxn = Transaction(
      id: newTxnId,
      lotId: lot.id,
      recyclerId: request.recyclerId,
      recyclerName: request.recyclerName,
      material: lot.materialName,
      quantity: lot.quantity,
      unit: lot.unit,
      agreedRate: lot.ratePerUnit,
      grossAmount: gross,
      facilitationFee: fee,
      netAmount: net,
      status: isOffline
          ? TransactionStatus.pending
          : TransactionStatus.completed,
      paymentStatus: isOffline ? PaymentStatus.pending : PaymentStatus.recorded,
      createdAt: request.createdAt,
      completedAt: isOffline ? null : now,
      isPendingSync: isOffline,
      isDemo: true,
    );

    _demoTransactions.insert(0, newTxn);
    return newTxn;
  }
}
