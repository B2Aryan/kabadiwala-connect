/// Lifecycle status of a lot handover to an authorized recycler.
enum HandoverStatus {
  pendingSync(
    'Pending Sync',
    'सिंक प्रतीक्षित (ऑफलाइन)',
    'सिंक प्रलंबित (ऑफलाइन)',
  ),
  requested('Pickup Requested', 'पिकअप अनुरोध भेजा गया', 'पिकअप विनंती पाठवली'),
  reviewing(
    'Recycler Reviewing',
    'रीसायकलकर्ता समीक्षा कर रहा है',
    'पुनर्चक्रणकर्ता तपासत आहे',
  ),
  scheduled('Pickup Scheduled', 'पिकअप निर्धारित', 'पिकअप नियोजित'),
  handoverPending(
    'Handover Pending',
    'हैंडओवर प्रतीक्षित',
    'हँडओव्हर प्रलंबित',
  ),
  confirmed(
    'Handover Confirmed',
    'हैंडओवर सत्यापित व पूर्ण',
    'हँडओव्हर पूर्ण व पडताळणी',
  );

  final String labelEn;
  final String labelHi;
  final String labelMr;

  const HandoverStatus(this.labelEn, this.labelHi, this.labelMr);

  String localizedLabel(String langCode) {
    if (langCode == 'hi') return labelHi;
    if (langCode == 'mr') return labelMr;
    return labelEn;
  }
}

/// Represents a formal digital handover request between an informal collector and a recycler facility.
class HandoverRequest {
  final String id;
  final String lotId;
  final String recyclerId;
  final String recyclerName;
  final HandoverStatus status;
  final DateTime createdAt;
  final DateTime? requestedAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final bool isPendingSync;
  final String? notes;
  final double estimatedValue;
  final String materialName;
  final double quantity;
  final String unit;

  const HandoverRequest({
    required this.id,
    required this.lotId,
    required this.recyclerId,
    required this.recyclerName,
    required this.status,
    required this.createdAt,
    this.requestedAt,
    this.acceptedAt,
    this.completedAt,
    this.isPendingSync = false,
    required this.estimatedValue,
    required this.materialName,
    required this.quantity,
    required this.unit,
    this.notes,
  });

  HandoverRequest copyWith({
    String? id,
    String? lotId,
    String? recyclerId,
    String? recyclerName,
    HandoverStatus? status,
    DateTime? createdAt,
    DateTime? requestedAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
    bool? isPendingSync,
    double? estimatedValue,
    String? materialName,
    double? quantity,
    String? unit,
    String? notes,
  }) {
    return HandoverRequest(
      id: id ?? this.id,
      lotId: lotId ?? this.lotId,
      recyclerId: recyclerId ?? this.recyclerId,
      recyclerName: recyclerName ?? this.recyclerName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      requestedAt: requestedAt ?? this.requestedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      isPendingSync: isPendingSync ?? this.isPendingSync,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      materialName: materialName ?? this.materialName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
    );
  }
}
