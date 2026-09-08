import 'package:flutter/material.dart';

import '../../lots/models/ewaste_lot.dart';
import '../../lots/services/lot_provider.dart';
import '../models/handover_request.dart';
import '../models/recycler.dart';
import 'recycler_matcher.dart';
import 'recycler_service.dart';

/// Lightweight provider managing discovery filters, matching lot context,
/// offline-first sync state, and handover lifecycle.
class RecyclerProvider extends ChangeNotifier {
  final RecyclerService _service;

  List<Recycler> _recyclers = [];
  List<RecyclerMatchResult> _rankedResults = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedMaterialFilter = 'all';
  bool _pickupOnly = false;
  double? _maxDistanceKm;
  EwasteLot? _matchingLot;

  // Offline simulation toggle (Offline-First requirement)
  bool _isOffline = false;

  // Active handover requests in this session (keyed by lotId)
  final Map<String, HandoverRequest> _requestsByLotId = {};

  RecyclerProvider({RecyclerService? service})
    : _service = service ?? MockRecyclerService() {
    loadRecyclers();
  }

  List<Recycler> get recyclers => List.unmodifiable(_recyclers);
  List<RecyclerMatchResult> get rankedResults =>
      List.unmodifiable(_rankedResults);
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  String get searchQuery => _searchQuery;
  String get selectedMaterialFilter => _selectedMaterialFilter;
  bool get pickupOnly => _pickupOnly;
  double? get maxDistanceKm => _maxDistanceKm;
  EwasteLot? get matchingLot => _matchingLot;

  int get activeFilterCount {
    int count = 0;
    if (_selectedMaterialFilter != 'all') count++;
    if (_pickupOnly) count++;
    if (_maxDistanceKm != null) count++;
    return count;
  }

  void setOffline(bool offline) {
    _isOffline = offline;
    notifyListeners();
  }

  void toggleOffline() {
    _isOffline = !_isOffline;
    notifyListeners();
  }

  void setMatchingLot(EwasteLot? lot) {
    _matchingLot = lot;
    if (lot != null) {
      _selectedMaterialFilter = lot.materialKey;
    } else {
      _selectedMaterialFilter = 'all';
    }
    loadRecyclers();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadRecyclers();
  }

  void applyFilters({String? material, bool? pickupOnly, double? maxDistance}) {
    if (material != null) _selectedMaterialFilter = material;
    if (pickupOnly != null) _pickupOnly = pickupOnly;
    _maxDistanceKm = maxDistance;
    loadRecyclers();
  }

  void resetFilters() {
    _selectedMaterialFilter = _matchingLot?.materialKey ?? 'all';
    _pickupOnly = false;
    _maxDistanceKm = null;
    _searchQuery = '';
    loadRecyclers();
  }

  Future<void> loadRecyclers() async {
    _isLoading = true;
    notifyListeners();

    // In offline mode, discovery works reliably using cached / local mock data
    _rankedResults = await _service.getRankedRecyclers(
      lot: _matchingLot,
      query: _searchQuery,
      materialKey: _selectedMaterialFilter,
      pickupOnly: _pickupOnly,
      maxDistanceKm: _maxDistanceKm,
    );

    _recyclers = _rankedResults.map((r) => r.recycler).toList();

    _isLoading = false;
    notifyListeners();
  }

  /// Submits a handover request for a lot to an authorized recycler.
  /// If device is offline, request enters a Pending Sync state rather than pretending it was sent.
  Future<HandoverRequest> submitHandoverRequest({
    required EwasteLot lot,
    required Recycler recycler,
    String? notes,
  }) async {
    // Simulate short network or local storage write
    await Future.delayed(const Duration(milliseconds: 300));

    final newReqId = 'REQ-2026-${700 + _requestsByLotId.length + 1}';
    final now = DateTime.now();

    final HandoverRequest request;
    if (_isOffline) {
      // Offline mode: enter pending-sync state
      request = HandoverRequest(
        id: newReqId,
        lotId: lot.id,
        recyclerId: recycler.id,
        recyclerName: recycler.name,
        status: HandoverStatus.pendingSync,
        createdAt: now,
        isPendingSync: true,
        estimatedValue: lot.estimatedValue,
        materialName: lot.materialName,
        quantity: lot.quantity,
        unit: lot.unit,
        notes: notes,
      );
    } else {
      // Online mode: active pickup request sent
      request = HandoverRequest(
        id: newReqId,
        lotId: lot.id,
        recyclerId: recycler.id,
        recyclerName: recycler.name,
        status: HandoverStatus.reviewing,
        createdAt: now,
        requestedAt: now,
        isPendingSync: false,
        estimatedValue: lot.estimatedValue,
        materialName: lot.materialName,
        quantity: lot.quantity,
        unit: lot.unit,
        notes: notes,
      );
    }

    _requestsByLotId[lot.id] = request;
    notifyListeners();
    return request;
  }

  /// Synchronizes pending requests when network is restored
  int syncPendingRequests([LotProvider? lotProvider]) {
    int syncedCount = 0;
    final keys = _requestsByLotId.keys.toList();

    for (final key in keys) {
      final req = _requestsByLotId[key];
      if (req != null && req.isPendingSync) {
        final syncedReq = req.copyWith(
          status: HandoverStatus.reviewing,
          isPendingSync: false,
          requestedAt: DateTime.now(),
        );
        _requestsByLotId[key] = syncedReq;
        lotProvider?.updateLotStatus(req.lotId, 'Recycler Reviewing');
        syncedCount++;
      }
    }

    if (syncedCount > 0) {
      notifyListeners();
    }
    return syncedCount;
  }

  /// Advances request lifecycle state (e.g. from reviewing to scheduled to confirmed)
  void advanceRequestStatus(
    String lotId,
    HandoverStatus newStatus, [
    LotProvider? lotProvider,
  ]) {
    final req = _requestsByLotId[lotId];
    if (req != null) {
      final now = DateTime.now();
      HandoverRequest updated = req.copyWith(status: newStatus);
      if (newStatus == HandoverStatus.scheduled) {
        updated = updated.copyWith(acceptedAt: now);
        lotProvider?.updateLotStatus(lotId, 'Pickup Scheduled');
      } else if (newStatus == HandoverStatus.handoverPending) {
        lotProvider?.updateLotStatus(lotId, 'Handover Pending');
      } else if (newStatus == HandoverStatus.confirmed) {
        updated = updated.copyWith(completedAt: now);
        lotProvider?.updateLotStatus(lotId, 'Handover Confirmed');
      }
      _requestsByLotId[lotId] = updated;
      notifyListeners();
    }
  }

  HandoverRequest? getRequestForLot(String lotId) {
    return _requestsByLotId[lotId];
  }

  List<HandoverRequest> get allRequests =>
      _requestsByLotId.values.toList().reversed.toList();
}
