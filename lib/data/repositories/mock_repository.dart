import '../models/collector_model.dart';
import '../models/material_price_model.dart';

class MockRepository {
  static const CollectorModel currentCollector = CollectorModel(
    id: 'COL-MH-2026-089',
    name: 'रमेश',
    phone: '+91 98765 43210',
    city: 'Pune, Maharashtra',
    totalEarnings: 14250.0,
    completedLots: 18,
  );

  static const List<MaterialPriceModel> todayPrices = [
    MaterialPriceModel(
      id: 'mat_copper',
      translationKey: 'copper',
      defaultName: 'Copper',
      ratePerKg: 720.0,
      changePercentage: 2.3,
      isUp: true,
    ),
    MaterialPriceModel(
      id: 'mat_aluminium',
      translationKey: 'aluminium',
      defaultName: 'Aluminium',
      ratePerKg: 180.0,
      changePercentage: 1.1,
      isUp: true,
    ),
    MaterialPriceModel(
      id: 'mat_ewaste',
      translationKey: 'eWaste',
      defaultName: 'E-Waste',
      ratePerKg: 35.0,
      changePercentage: 5.4,
      isUp: true,
    ),
  ];
}
