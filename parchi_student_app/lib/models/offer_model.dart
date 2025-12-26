class OfferModel {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String discountType;
  final num discountValue;
  final DateTime validUntil;
  final Merchant? merchant;
  final double? distance;
  final String? branchName;

  OfferModel({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.discountType,
    required this.discountValue,
    required this.validUntil,
    this.merchant,
    this.distance,
    this.branchName,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      // Backend sends camelCase keys
      imageUrl: json['imageUrl'], 
      discountType: json['discountType'] ?? 'percentage',
      discountValue: json['discountValue'] ?? 0,
      validUntil: DateTime.tryParse(json['validUntil'] ?? '') ?? DateTime.now(),
      merchant: json['merchant'] != null ? Merchant.fromJson(json['merchant']) : null,
      distance: json['distance'] != null ? (json['distance'] as num).toDouble() : null,
      branchName: json['branchName'],
    );
  }

  // Helper to format the discount text for the UI
  String get formattedDiscount {
    if (discountType == 'percentage') {
      return '${discountValue.toStringAsFixed(0)}% OFF';
    } else {
      return 'Rs. ${discountValue.toStringAsFixed(0)} OFF';
    }
  }
}

class Merchant {
  final String id;
  final String businessName;
  final String? logoPath;
  final String? category;

  Merchant({
    required this.id,
    required this.businessName,
    this.logoPath,
    this.category,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['id'] ?? '',
      businessName: json['businessName'] ?? 'Unknown',
      logoPath: json['logoPath'],
      category: json['category'],
    );
  }
}