/// Lifecycle status of a digital ledger transaction
enum TransactionStatus {
  pending('Pending Settlement', 'निपटान प्रतीक्षित', 'निकाली प्रलंबित'),
  completed('Completed & Verified', 'सत्यापित व पूर्ण', 'पडताळणी पूर्ण'),
  cancelled('Cancelled', 'रद्द', 'रद्द');

  final String labelEn;
  final String labelHi;
  final String labelMr;

  const TransactionStatus(this.labelEn, this.labelHi, this.labelMr);

  String localizedLabel(String langCode) {
    if (langCode == 'hi') return labelHi;
    if (langCode == 'mr') return labelMr;
    return labelEn;
  }
}

/// Settlement status of the transaction record.
/// NOTE: Differentiates "Digitally Recorded Ledger" from actual banking/UPI disbursement.
enum PaymentStatus {
  notApplicable('Not Applicable', 'लागू नहीं', 'लागू नाही'),
  pending(
    'Pending Physical Settlement',
    'भौतिक भुगतान प्रतीक्षित',
    'प्रत्यक्ष पेमेंट प्रलंबित',
  ),
  recorded(
    'Recorded in Circular Ledger',
    'डिजिटल लेजर में दर्ज',
    'डिजिटल लेजरमध्ये नोंदवले',
  );

  final String labelEn;
  final String labelHi;
  final String labelMr;

  const PaymentStatus(this.labelEn, this.labelHi, this.labelMr);

  String localizedLabel(String langCode) {
    if (langCode == 'hi') return labelHi;
    if (langCode == 'mr') return labelMr;
    return labelEn;
  }
}

/// Represents a formal circular economy digital ledger record between an informal
/// collector and an authorized recycling facility.
class Transaction {
  final String id;
  final String lotId;
  final String? handoverRequestId;
  final String recyclerId;
  final String recyclerName;
  final String material;
  final double quantity;
  final String unit;
  final double agreedRate;
  final double grossAmount;
  final double facilitationFee;
  final double netAmount;
  final TransactionStatus status;
  final PaymentStatus paymentStatus;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isPendingSync;
  final bool isDemo;
  final String disclaimer;

  // Compatibility getters
  String get materialName => material;
  double get ratePerUnit => agreedRate;
  DateTime get timestamp => createdAt;
  String get disclaimerNotice => disclaimer;

  const Transaction({
    required this.id,
    required this.lotId,
    this.handoverRequestId,
    required this.recyclerId,
    required this.recyclerName,
    required this.material,
    required this.quantity,
    required this.unit,
    required this.agreedRate,
    required this.grossAmount,
    this.facilitationFee = 0.0,
    required this.netAmount,
    this.status = TransactionStatus.completed,
    this.paymentStatus = PaymentStatus.recorded,
    required this.createdAt,
    this.completedAt,
    this.isPendingSync = false,
    this.isDemo = true,
    this.disclaimer = 'Digital circular transaction record. No real bank transfer or legal tax settlement is claimed in this prototype.',
  });

  Transaction copyWith({
    String? id,
    String? lotId,
    String? handoverRequestId,
    String? recyclerId,
    String? recyclerName,
    String? material,
    double? quantity,
    String? unit,
    double? agreedRate,
    double? grossAmount,
    double? facilitationFee,
    double? netAmount,
    TransactionStatus? status,
    PaymentStatus? paymentStatus,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? isPendingSync,
    bool? isDemo,
    String? disclaimer,
  }) {
    return Transaction(
      id: id ?? this.id,
      lotId: lotId ?? this.lotId,
      handoverRequestId: handoverRequestId ?? this.handoverRequestId,
      recyclerId: recyclerId ?? this.recyclerId,
      recyclerName: recyclerName ?? this.recyclerName,
      material: material ?? this.material,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      agreedRate: agreedRate ?? this.agreedRate,
      grossAmount: grossAmount ?? this.grossAmount,
      facilitationFee: facilitationFee ?? this.facilitationFee,
      netAmount: netAmount ?? this.netAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      isPendingSync: isPendingSync ?? this.isPendingSync,
      isDemo: isDemo ?? this.isDemo,
      disclaimer: disclaimer ?? this.disclaimer,
    );
  }
}
