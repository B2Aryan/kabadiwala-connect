import 'package:flutter/material.dart';

import '../../lots/models/ewaste_lot.dart';
import '../../recyclers/models/handover_request.dart';
import '../models/transaction_model.dart';
import 'transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _service;

  List<Transaction> _transactions = [];
  bool _isLoading = false;

  TransactionProvider({TransactionService? service})
    : _service = service ?? MockTransactionService() {
    loadTransactions();
  }

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;

  /// Aggregation: Total verified net earnings
  double get totalEarnings {
    return _transactions
        .where((t) => t.status == TransactionStatus.completed)
        .fold(0.0, (sum, t) => sum + t.netAmount);
  }

  /// Aggregation: Earnings in the current calendar month
  double get thisMonthEarnings {
    final now = DateTime.now();
    return _transactions
        .where(
          (t) =>
              t.status == TransactionStatus.completed &&
              t.completedAt != null &&
              t.completedAt!.year == now.year &&
              t.completedAt!.month == now.month,
        )
        .fold(0.0, (sum, t) => sum + t.netAmount);
  }

  /// Aggregation: Count of completed recycling lots
  int get completedLotsCount {
    return _transactions
        .where((t) => t.status == TransactionStatus.completed)
        .length;
  }

  /// Aggregation: Pending transaction value
  double get pendingEarnings {
    return _transactions
        .where((t) => t.status == TransactionStatus.pending)
        .fold(0.0, (sum, t) => sum + t.netAmount);
  }

  /// Count of offline transactions waiting for sync
  int get pendingSyncCount =>
      _transactions.where((t) => t.isPendingSync).length;

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    _transactions = await _service.getTransactions();
    _isLoading = false;
    notifyListeners();
  }

  /// Convenience method to record transaction from HandoverRequest
  Future<Transaction> recordHandoverCompletionFromRequest({
    required HandoverRequest request,
    EwasteLot? lot,
    double facilitationFeePercent = 0.0,
    bool isOffline = false,
  }) async {
    final effectiveLot =
        lot ??
        EwasteLot(
          id: request.lotId,
          materialKey: request.materialName.toLowerCase(),
          materialName: request.materialName,
          quantity: request.quantity,
          unit: request.unit,
          ratePerUnit: request.quantity > 0
              ? (request.estimatedValue / request.quantity)
              : 0,
          estimatedValue: request.estimatedValue,
          photos: const [],
          condition: 'good',
          status: 'Handover Confirmed',
          createdAt: request.createdAt,
        );
    return recordHandoverCompletion(
      request: request,
      lot: effectiveLot,
      facilitationFeePercent: facilitationFeePercent,
      isOffline: isOffline,
    );
  }

  /// Records a circular economy ledger transaction from a completed lot handover
  Future<Transaction> recordHandoverCompletion({
    required HandoverRequest request,
    required EwasteLot lot,
    double facilitationFeePercent = 0.0,
    bool isOffline = false,
  }) async {
    // Check if already recorded for this lot
    final existingIndex = _transactions.indexWhere((t) => t.lotId == lot.id);
    if (existingIndex != -1) {
      final existing = _transactions[existingIndex];
      // If was pending and now completed
      if (!isOffline && existing.status == TransactionStatus.pending) {
        final updated = existing.copyWith(
          status: TransactionStatus.completed,
          paymentStatus: PaymentStatus.recorded,
          completedAt: DateTime.now(),
          isPendingSync: false,
        );
        _transactions[existingIndex] = updated;
        notifyListeners();
        return updated;
      }
      return existing;
    }

    final newTxn = await _service.recordTransactionFromHandover(
      request: request,
      lot: lot,
      facilitationFeePercent: facilitationFeePercent,
      isOffline: isOffline,
    );

    _transactions.insert(0, newTxn);
    notifyListeners();
    return newTxn;
  }

  /// Synchronizes offline transactions when network is restored
  int syncPendingTransactions() {
    int syncedCount = 0;
    for (int i = 0; i < _transactions.length; i++) {
      if (_transactions[i].isPendingSync) {
        _transactions[i] = _transactions[i].copyWith(
          status: TransactionStatus.completed,
          paymentStatus: PaymentStatus.recorded,
          completedAt: DateTime.now(),
          isPendingSync: false,
        );
        syncedCount++;
      }
    }
    if (syncedCount > 0) {
      notifyListeners();
    }
    return syncedCount;
  }

  Transaction? getTransactionByLotId(String lotId) {
    try {
      return _transactions.firstWhere((t) => t.lotId == lotId);
    } catch (_) {
      return null;
    }
  }

  Transaction? getTransactionById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}
