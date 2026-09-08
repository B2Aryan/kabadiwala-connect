import '../../lots/models/ewaste_lot.dart';
import '../models/recycler.dart';

/// Result container for recycler matching computation.
class RecyclerMatchResult {
  final Recycler recycler;
  final double score; // 0 to 100%
  final String matchReasonEn;
  final String matchReasonHi;
  final String matchReasonMr;
  final bool isMaterialMatch;
  final bool isPickupMatch;

  const RecyclerMatchResult({
    required this.recycler,
    required this.score,
    required this.matchReasonEn,
    required this.matchReasonHi,
    required this.matchReasonMr,
    required this.isMaterialMatch,
    required this.isPickupMatch,
  });

  String localizedReason(String langCode) {
    if (langCode == 'hi') return matchReasonHi;
    if (langCode == 'mr') return matchReasonMr;
    return matchReasonEn;
  }
}

/// Deterministic Recycler Matching Engine.
///
/// NOTE: This engine utilizes clear rule-based scoring (materials, distance decay,
/// pickup capability, rating) and is strictly decoupled from future AI/ML
/// microservice architectures (see TRD §16 & §17).
class RecyclerMatcher {
  /// Ranks a list of recyclers for an optional target lot and user criteria.
  static List<RecyclerMatchResult> rankRecyclers({
    required List<Recycler> recyclers,
    EwasteLot? lot,
    bool preferPickup = true,
    double maxDistanceKm = 50.0,
  }) {
    final List<RecyclerMatchResult> results = [];

    for (final recycler in recyclers) {
      double score = 0.0;
      bool isMaterialMatch = false;
      bool isPickupMatch = false;

      if (lot != null) {
        // 1. Material Compatibility (50 points max)
        if (recycler.acceptsMaterial(lot.materialKey)) {
          isMaterialMatch = true;
          score += 50.0;
        } else {
          // Incompatible material: significant penalty
          score += 5.0;
        }

        // 2. Pickup Availability vs Collector preference (25 points max)
        if (preferPickup && recycler.pickupAvailable) {
          isPickupMatch = true;
          score += 25.0;
        } else if (!preferPickup) {
          score += 20.0;
        } else {
          score += 10.0; // Drop-off only
        }

        // 3. Distance decay (15 points max)
        // Closer recyclers receive higher points
        if (recycler.distanceKm <= 2.0) {
          score += 15.0;
        } else if (recycler.distanceKm <= 5.0) {
          score += 12.0;
        } else if (recycler.distanceKm <= 10.0) {
          score += 8.0;
        } else {
          score += 4.0;
        }

        // 4. Rating / Reliability factor (10 points max)
        final ratingScore = (recycler.rating / 5.0) * 10.0;
        score += ratingScore;
      } else {
        // No specific lot: score based on general capability and proximity
        score += 40.0; // Base score
        if (recycler.pickupAvailable) {
          isPickupMatch = true;
          score += 25.0;
        }
        if (recycler.distanceKm <= 3.0) {
          score += 20.0;
        } else if (recycler.distanceKm <= 6.0) {
          score += 12.0;
        } else {
          score += 6.0;
        }
        score += (recycler.rating / 5.0) * 15.0;
      }

      // Clamp score to 100 max
      final finalScore = score.clamp(10.0, 99.0);

      // Construct localized explanations
      final String reasonEn;
      final String reasonHi;
      final String reasonMr;

      if (lot != null) {
        if (isMaterialMatch && recycler.pickupAvailable) {
          reasonEn =
              'Best match for your ${lot.materialName} lot • Pickup available at your doorstep';
          reasonHi =
              'आपके ${lot.materialName} लॉट के लिए उत्तम मैच • घर से पिकअप उपलब्ध';
          reasonMr =
              'तुमच्या ${lot.materialName} लॉटसाठी सर्वोत्तम जुळणी • पिकअप उपलब्ध';
        } else if (isMaterialMatch) {
          reasonEn =
              'Accepts ${lot.materialName} • Direct yard drop-off facility';
          reasonHi = '${lot.materialName} स्वीकार्य • सीधे डिपो में जमा करें';
          reasonMr = '${lot.materialName} स्वीकार्य • थेट डेपोत जमा करा';
        } else {
          reasonEn =
              'Authorized general e-waste partner • Different material focus';
          reasonHi = 'अधिकृत ई-कचरा केंद्र • अन्य सामग्री स्वीकार्य';
          reasonMr = 'अधिकृत ई-कचरा केंद्र • इतर साहित्य स्वीकार्य';
        }
      } else {
        if (recycler.pickupAvailable) {
          reasonEn =
              'High reliability rating • Pickup service available nearby';
          reasonHi = 'उच्च विश्वसनीयता रेटिंग • नजदीकी पिकअप सेवा उपलब्ध';
          reasonMr = 'उच्च विश्वसनीयता • जवळच पिकअप सेवा उपलब्ध';
        } else {
          reasonEn = 'Near your location • Drop-off processing center';
          reasonHi = 'आपके निकट • डिपो ड्रॉप-ऑफ केंद्र';
          reasonMr = 'तुमच्या जवळ • ड्रॉप-ऑफ केंद्र';
        }
      }

      results.add(
        RecyclerMatchResult(
          recycler: recycler,
          score: finalScore,
          matchReasonEn: reasonEn,
          matchReasonHi: reasonHi,
          matchReasonMr: reasonMr,
          isMaterialMatch: isMaterialMatch,
          isPickupMatch: isPickupMatch,
        ),
      );
    }

    // Sort descending by score
    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }
}
