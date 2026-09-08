import '../../lots/models/ewaste_lot.dart';

/// Model representing a verified or authorized e-waste recycler.
///
/// NOTE: In this development phase, all recycler facilities are clearly
/// designated as mock/demo data until real-time government and EPR APIs are connected.
class Recycler {
  final String id;
  final String name;
  final double distanceKm;
  final List<String>
  acceptedMaterials; // e.g. ['copper', 'aluminium', 'eWaste', 'other']
  final bool pickupAvailable;
  final String operatingHours;
  final String address;
  final String phone;
  final double rating;
  final bool isDemo;
  final String statusTag; // e.g. 'Demo Authorized Facility'
  final String disclaimer;

  const Recycler({
    required this.id,
    required this.name,
    required this.distanceKm,
    required this.acceptedMaterials,
    required this.pickupAvailable,
    required this.operatingHours,
    required this.address,
    required this.phone,
    this.rating = 4.8,
    this.isDemo = true,
    this.statusTag = 'Demo Authorized Facility',
    this.disclaimer = 'Demo facility for prototype validation. Not connected to live CPCB/SPCB government portal.',
  });

  /// Check if this recycler accepts a given material key
  bool acceptsMaterial(String materialKey) {
    return acceptedMaterials.contains(materialKey);
  }

  /// Generates a human-friendly match explanation for a specific collector lot
  String matchReasonFor(EwasteLot? lot) {
    if (lot == null) {
      return pickupAvailable
          ? 'पिकअप उपलब्ध • Pickup Available'
          : 'ड्रॉप-ऑफ सुविधा • Direct Drop-off';
    }

    final accepts = acceptsMaterial(lot.materialKey);
    if (accepts && pickupAvailable) {
      return 'आपके ${lot.materialName} लॉट के लिए उत्तम मैच • पिकअप उपलब्ध';
    } else if (accepts) {
      return '${lot.materialName} स्वीकार्य • डिपो ड्रॉप-ऑफ सुविधा';
    } else {
      return 'नजदीकी रीसाइक्लिंग केंद्र (Demo Facility)';
    }
  }

  /// English match explanation helper
  String matchReasonEnglish(EwasteLot? lot) {
    if (lot == null) {
      return pickupAvailable ? 'Pickup Available' : 'Drop-off Facility';
    }
    final accepts = acceptsMaterial(lot.materialKey);
    if (accepts && pickupAvailable) {
      return 'Great match for your ${lot.materialName} lot • Pickup available';
    } else if (accepts) {
      return 'Accepts ${lot.materialName} • Drop-off available';
    } else {
      return 'General recycling center (Demo Facility)';
    }
  }
}
