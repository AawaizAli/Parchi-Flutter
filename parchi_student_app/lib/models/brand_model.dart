class BrandModel {
  final String id;
  final String businessName;
  final String? logoPath;
  final String? category;
  final String discountType;
  final num discountValue;

  BrandModel({
    required this.id,
    required this.businessName,
    this.logoPath,
    this.category,
    required this.discountType,
    required this.discountValue,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] ?? '',
      businessName: json['business_name'] ?? json['businessName'] ?? 'Unknown',
      logoPath: json['logo_path'] ?? json['logoPath'],
      category: json['category'],
      discountType: json['discount_type'] ?? json['discountType'] ?? 'percentage',
      discountValue: json['discount_value'] ?? json['discountValue'] ?? 0,
    );
  }
}
