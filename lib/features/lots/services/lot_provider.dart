import 'package:flutter/foundation.dart';

import '../models/ewaste_lot.dart';
import 'rate_service.dart';

/// Manages lots in session and creation workflow
class LotProvider extends ChangeNotifier {
  final RateService _rateService = MockRateService();

  final List<EwasteLot> _lots = [
    EwasteLot(
      id: 'KC-2026-00124',
      materialKey: 'eWaste',
      materialName: 'Mixed Electronic PCBs',
      quantity: 25.0,
      unit: 'kg',
      ratePerUnit: 45.0,
      estimatedValue: 1125.0,
      photos: const ['assets/samples/pcb_board.jpg'],
      condition: 'good',
      status: 'Verified Handover',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    EwasteLot(
      id: 'KC-2026-00119',
      materialKey: 'copper',
      materialName: 'Copper Motors & Wires',
      quantity: 14.0,
      unit: 'kg',
      ratePerUnit: 720.0,
      estimatedValue: 10080.0,
      photos: const ['assets/samples/copper_wire.jpg'],
      condition: 'good',
      status: 'Pickup Scheduled',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<EwasteLot> get lots => List.unmodifiable(_lots);

  // Active Draft Lot creation state
  List<String> _draftPhotos = [];
  String _draftMaterialKey = 'copper';
  double _draftQuantity = 5.0;
  String _draftUnit = 'kg';
  String _draftCondition =
      'good'; // 'good' (ठीक), 'broken' (टूटा हुआ), 'scrap' (खराब)
  String? _draftNotes;

  List<String> get draftPhotos => _draftPhotos;
  String get draftMaterialKey => _draftMaterialKey;
  double get draftQuantity => _draftQuantity;
  String get draftUnit => _draftUnit;
  String get draftCondition => _draftCondition;
  String? get draftNotes => _draftNotes;

  double get currentRate => _rateService.getRateForMaterial(_draftMaterialKey);
  double get currentEstimatedValue =>
      _rateService.calculateEstimatedValue(_draftMaterialKey, _draftQuantity);

  void resetDraft() {
    _draftPhotos = [];
    _draftMaterialKey = 'copper';
    _draftQuantity = 5.0;
    _draftUnit = 'kg';
    _draftCondition = 'good';
    _draftNotes = null;
    notifyListeners();
  }

  void addPhoto(String photoPath) {
    if (!_draftPhotos.contains(photoPath)) {
      _draftPhotos = [..._draftPhotos, photoPath];
      notifyListeners();
    }
  }

  void removePhoto(int index) {
    if (index >= 0 && index < _draftPhotos.length) {
      _draftPhotos = List.from(_draftPhotos)..removeAt(index);
      notifyListeners();
    }
  }

  void setMaterial(String materialKey) {
    _draftMaterialKey = materialKey;
    notifyListeners();
  }

  void setQuantity(double quantity) {
    _draftQuantity = quantity;
    notifyListeners();
  }

  void setUnit(String unit) {
    _draftUnit = unit;
    notifyListeners();
  }

  void setCondition(String condition) {
    _draftCondition = condition;
    notifyListeners();
  }

  void setNotes(String? notes) {
    _draftNotes = notes;
    notifyListeners();
  }

  Future<EwasteLot> createLot() async {
    // Simulate short network / processing state
    await Future.delayed(const Duration(milliseconds: 600));

    final nextIdNumber = 125 + _lots.length - 2;
    final newId = 'KC-2026-00$nextIdNumber';

    final newLot = EwasteLot(
      id: newId,
      materialKey: _draftMaterialKey,
      materialName: _getMaterialDisplayName(_draftMaterialKey),
      quantity: _draftQuantity,
      unit: _draftUnit,
      ratePerUnit: currentRate,
      estimatedValue: currentEstimatedValue,
      photos: _draftPhotos.isEmpty
          ? ['assets/samples/default_lot.jpg']
          : List.from(_draftPhotos),
      condition: _draftCondition,
      notes: _draftNotes,
      status: 'Created',
      createdAt: DateTime.now(),
    );

    _lots.insert(0, newLot);
    resetDraft();
    notifyListeners();
    return newLot;
  }

  /// Assigns a recycler to a lot and updates its status
  void assignRecyclerToLot(
    String lotId, {
    required String recyclerId,
    required String recyclerName,
    String newStatus = 'Recycler Selected',
  }) {
    final index = _lots.indexWhere((l) => l.id == lotId);
    if (index != -1) {
      _lots[index] = _lots[index].copyWith(
        recyclerId: recyclerId,
        recyclerName: recyclerName,
        status: newStatus,
      );
      notifyListeners();
    }
  }

  /// Updates status of a lot by id (e.g. 'Handover Requested', 'Recycler Reviewing')
  void updateLotStatus(String lotId, String newStatus) {
    final index = _lots.indexWhere((l) => l.id == lotId);
    if (index != -1) {
      _lots[index] = _lots[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  String _getMaterialDisplayName(String key) {
    switch (key) {
      case 'copper':
        return 'Copper';
      case 'aluminium':
        return 'Aluminium';
      case 'eWaste':
        return 'E-Waste (Electronics)';
      default:
        return 'Other Scrap';
    }
  }
}
