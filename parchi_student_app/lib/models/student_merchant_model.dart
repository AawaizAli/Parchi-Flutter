class StudentMerchantModel {
  final String id;
  final String businessName;
  final String? bannerUrl;
  final String? category;
  final int totalRedemptions;

  StudentMerchantModel({
    required this.id,
    required this.businessName,
    this.bannerUrl,
    this.category,
    required this.totalRedemptions,
  });

  factory StudentMerchantModel.fromJson(Map<String, dynamic> json) {
    return StudentMerchantModel(
      id: json['id'] ?? '',
      businessName: json['businessName'] ?? 'Unknown Merchant',
      bannerUrl: json['bannerUrl'],
      category: json['category'],
      totalRedemptions: json['totalRedemptions'] ?? 0,
    );
  }
}
