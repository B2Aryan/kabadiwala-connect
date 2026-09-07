/// Represents a created e-waste lot in Kabadiwala Connect
class EwasteLot {
  final String id;
  final String materialKey;
  final String materialName;
  final double quantity;
  final String unit;
  final double ratePerUnit;
  final double estimatedValue;
  final List<String> photos;
  final String condition;
  final String? notes;
  final String status;
  final DateTime createdAt;

  const EwasteLot({
    required this.id,
    required this.materialKey,
    required this.materialName,
    required this.quantity,
    this.unit = 'kg',
    required this.ratePerUnit,
    required this.estimatedValue,
    required this.photos,
    required this.condition,
    this.notes,
    this.status = 'Pending Pickup',
    required this.createdAt,
  });

  EwasteLot copyWith({
    String? id,
    String? materialKey,
    String? materialName,
    double? quantity,
    String? unit,
    double? ratePerUnit,
    double? estimatedValue,
    List<String>? photos,
    String? condition,
    String? notes,
    String? status,
    DateTime? createdAt,
  }) {
    return EwasteLot(
      id: id ?? this.id,
      materialKey: materialKey ?? this.materialKey,
      materialName: materialName ?? this.materialName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      ratePerUnit: ratePerUnit ?? this.ratePerUnit,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      photos: photos ?? this.photos,
      condition: condition ?? this.condition,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
