/// Rate calculation and retrieval service abstraction
abstract class RateService {
  double getRateForMaterial(String materialKey);
  double calculateEstimatedValue(String materialKey, double quantity);
}

/// Mock demo rate implementation based on approved rates:
/// Copper: ₹720/kg
/// Aluminium: ₹180/kg
/// E-Waste: ₹35/kg
/// Other: ₹25/kg
class MockRateService implements RateService {
  static const Map<String, double> _rates = {
    'copper': 720.0,
    'aluminium': 180.0,
    'eWaste': 35.0,
    'other': 25.0,
  };

  @override
  double getRateForMaterial(String materialKey) {
    return _rates[materialKey] ?? 35.0;
  }

  @override
  double calculateEstimatedValue(String materialKey, double quantity) {
    final rate = getRateForMaterial(materialKey);
    return rate * quantity;
  }
}
