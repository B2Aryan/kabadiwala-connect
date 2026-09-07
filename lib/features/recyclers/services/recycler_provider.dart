import 'package:flutter/material.dart';

import '../../lots/models/ewaste_lot.dart';
import '../models/handover_request.dart';
import '../models/recycler.dart';
import 'recycler_service.dart';

/// Lightweight provider managing discovery filters, matching lot context,
/// and handover submission/tracking.
class RecyclerProvider extends ChangeNotifier {
  final RecyclerService _service;

  List<Recycler> _recyclers = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedMaterialFilter = 'all';
  bool _pickupOnly = false;
  double? _maxDistanceKm;
  EwasteLot? _matchingLot;

  // Active handover requests in this session (keyed by lotId)
  final Map<String, HandoverRequest> _requestsByLotId = {};

  RecyclerProvider({RecyclerService? service})
    : _service = service ?? MockRecyclerService() {
    loadRecyclers();
  }

  List<Recycler> get recyclers => List.unmodifiable(_recyclers);
  bool get isLoading => _isLoading;
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

  void setMatchingLot(EwasteLot? lot) {
    _matchingLot = lot;
    if (lot != null) {
      // Automatically default filter to match the lot's material
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

    _recyclers = await _service.getNearbyRecyclers(
      query: _searchQuery,
      materialKey: _selectedMaterialFilter,
      pickupOnly: _pickupOnly,
      maxDistanceKm: _maxDistanceKm,
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Submits a handover request for a lot to a recycler
  Future<HandoverRequest> submitHandoverRequest({
    required EwasteLot lot,
    required Recycler recycler,
    String? notes,
  }) async {
    // Simulate short network processing
    await Future.delayed(const Duration(milliseconds: 400));

    final newReqId = 'REQ-2026-${700 + _requestsByLotId.length + 1}';
    final request = HandoverRequest(
      id: newReqId,
      lotId: lot.id,
      recyclerId: recycler.id,
      recyclerName: recycler.name,
      status: HandoverStatus
          .reviewing, // Initial state: Request Sent, Recycler Reviewing
      createdAt: DateTime.now(),
      estimatedValue: lot.estimatedValue,
      materialName: lot.materialName,
      quantity: lot.quantity,
      unit: lot.unit,
      notes: notes,
    );

    _requestsByLotId[lot.id] = request;
    notifyListeners();
    return request;
  }

  HandoverRequest? getRequestForLot(String lotId) {
    return _requestsByLotId[lotId];
  }

  List<HandoverRequest> get allRequests =>
      _requestsByLotId.values.toList().reversed.toList();
}
