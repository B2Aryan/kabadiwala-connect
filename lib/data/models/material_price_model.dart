class MaterialPriceModel {
  final String id;
  final String translationKey;
  final String defaultName;
  final double ratePerKg;
  final double changePercentage;
  final bool isUp;

  const MaterialPriceModel({
    required this.id,
    required this.translationKey,
    required this.defaultName,
    required this.ratePerKg,
    required this.changePercentage,
    this.isUp = true,
  });
}
