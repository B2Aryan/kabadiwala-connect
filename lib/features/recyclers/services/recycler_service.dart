import '../models/recycler.dart';

/// Abstract service interface for finding e-waste recyclers.
abstract class RecyclerService {
  Future<List<Recycler>> getNearbyRecyclers({
    String? query,
    String? materialKey,
    bool? pickupOnly,
    double? maxDistanceKm,
  });

  Future<Recycler?> getRecyclerById(String id);
}

/// Mock implementation providing clearly designated demo recycler facilities.
///
/// IMPORTANT: All data here represents generic demo facilities for prototype
/// validation and does not represent real government or verified legal entities.
class MockRecyclerService implements RecyclerService {
  static const List<Recycler> _demoRecyclers = [
    Recycler(
      id: 'REC-DEMO-001',
      name: 'GreenCycle Recycling — Demo',
      distanceKm: 1.8,
      acceptedMaterials: ['copper', 'eWaste', 'aluminium'],
      pickupAvailable: true,
      operatingHours: '9:00 AM – 6:00 PM',
      address: 'Plot 42, Hadapsar Industrial Area, Pune',
      phone: '+91 98230 XXXXX (Demo)',
      rating: 4.8,
      statusTag: 'Authorized E-Waste Facility (Demo)',
    ),
    Recycler(
      id: 'REC-DEMO-002',
      name: 'EcoLoop Recycler — Demo',
      distanceKm: 3.2,
      acceptedMaterials: ['copper', 'aluminium', 'other'],
      pickupAvailable: true,
      operatingHours: '8:30 AM – 7:00 PM',
      address: 'Gate 3, Bhosari MIDC, Pune',
      phone: '+91 98221 XXXXX (Demo)',
      rating: 4.6,
      statusTag: 'EPR Registered Partner (Demo)',
    ),
    Recycler(
      id: 'REC-DEMO-003',
      name: 'Circular Tech Recovery — Demo',
      distanceKm: 4.5,
      acceptedMaterials: ['eWaste', 'copper'],
      pickupAvailable: false, // Drop-off only
      operatingHours: '10:00 AM – 5:30 PM',
      address: 'Phase 1, Hinjawadi Eco-Park, Pune',
      phone: '+91 98212 XXXXX (Demo)',
      rating: 4.7,
      statusTag: 'Govt. Authorized Yard (Demo)',
    ),
    Recycler(
      id: 'REC-DEMO-004',
      name: 'Bharat Clean Scrap & E-Waste — Demo',
      distanceKm: 6.0,
      acceptedMaterials: ['copper', 'aluminium', 'eWaste', 'other'],
      pickupAvailable: true,
      operatingHours: '9:00 AM – 6:30 PM',
      address: 'Chakan Industrial Zone, Pune',
      phone: '+91 98244 XXXXX (Demo)',
      rating: 4.5,
      statusTag: 'State Certified Unit (Demo)',
    ),
  ];

  @override
  Future<List<Recycler>> getNearbyRecyclers({
    String? query,
    String? materialKey,
    bool? pickupOnly,
    double? maxDistanceKm,
  }) async {
    // Simulate brief network latency
    await Future.delayed(const Duration(milliseconds: 150));

    return _demoRecyclers.where((rec) {
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final nameMatch = rec.name.toLowerCase().contains(q);
        final addressMatch = rec.address.toLowerCase().contains(q);
        if (!nameMatch && !addressMatch) return false;
      }

      if (materialKey != null &&
          materialKey.isNotEmpty &&
          materialKey != 'all') {
        if (!rec.acceptsMaterial(materialKey)) return false;
      }

      if (pickupOnly == true && !rec.pickupAvailable) {
        return false;
      }

      if (maxDistanceKm != null && rec.distanceKm > maxDistanceKm) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Future<Recycler?> getRecyclerById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _demoRecyclers.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
