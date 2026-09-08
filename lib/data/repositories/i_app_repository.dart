import '../../features/earnings/models/transaction_model.dart';
import '../../features/lots/models/ewaste_lot.dart';
import '../../features/recyclers/models/handover_request.dart';
import '../../features/recyclers/models/recycler.dart';

/// Contract for Recycler data access (coexisting with mock & API)
abstract class IRecyclerRepository {
  Future<List<Recycler>> getRecyclers({
    String? query,
    String? materialKey,
    bool? pickupOnly,
    double? maxDistanceKm,
  });

  Future<Recycler?> getRecyclerById(String id);
}

/// Contract for Lot data access
abstract class ILotRepository {
  Future<List<EwasteLot>> getLots({String? status});
  Future<EwasteLot?> getLotById(String id);
  Future<EwasteLot> createLot(EwasteLot lot);
  Future<EwasteLot?> updateLot(EwasteLot lot);
}

/// Contract for Handover data access
abstract class IHandoverRepository {
  Future<HandoverRequest> createHandoverRequest({
    required String lotId,
    required String recyclerId,
    String? notes,
  });
  Future<HandoverRequest?> getHandoverRequestById(String id);
}

/// Contract for Digital Transaction Ledger data access
abstract class ITransactionRepository {
  Future<List<Transaction>> getTransactions();
  Future<Transaction?> getTransactionById(String id);
  Future<Transaction> recordTransaction(Transaction transaction);
}
