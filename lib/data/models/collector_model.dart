class CollectorModel {
  final String id;
  final String name;
  final String phone;
  final String city;
  final double totalEarnings;
  final int completedLots;

  const CollectorModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.city,
    required this.totalEarnings,
    required this.completedLots,
  });
}
