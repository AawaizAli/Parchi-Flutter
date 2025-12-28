
class MerchantDetailModel {
  final String id;
  final String businessName;
  final String? logoPath;
  final String? bannerUrl;
  final String? category;
  final String? termsAndConditions;
  final List<BranchModel> branches;

  MerchantDetailModel({
    required this.id,
    required this.businessName,
    this.logoPath,
    this.bannerUrl,
    this.category,
    this.termsAndConditions,
    required this.branches,
  });

  factory MerchantDetailModel.fromJson(Map<String, dynamic> json) {
    return MerchantDetailModel(
      id: json['id'] ?? '',
      businessName: json['businessName'] ?? json['business_name'] ?? 'Unknown',
      logoPath: json['logoPath'] ?? json['logo_path'],
      bannerUrl: json['bannerUrl'] ?? json['banner_url'],
      category: json['category'],
      termsAndConditions: json['termsAndConditions'] ?? json['terms_and_conditions'],
      branches: (json['branches'] as List<dynamic>?)
              ?.map((branch) => BranchModel.fromJson(branch))
          .toList() ??
          [],
    );
  }
}

class BranchOffer {
  final String id;
  final String title;
  final String? imageUrl;
  final String discountType;
  final num discountValue;
  final String formattedDiscount;

  BranchOffer({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.discountType,
    required this.discountValue,
    required this.formattedDiscount,
  });

  factory BranchOffer.fromJson(Map<String, dynamic> json) {
    // Calculate formatted discount if not provided
    String formattedDiscount = json['formattedDiscount'] ?? '';
    if (formattedDiscount.isEmpty) {
      if (json['discountType'] == 'percentage') {
        formattedDiscount = '${json['discountValue']}% OFF';
      } else {
        formattedDiscount = 'Rs. ${json['discountValue']} OFF';
      }
    }

    return BranchOffer(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'],
      discountType: json['discountType'] ?? json['discount_type'] ?? 'percentage',
      discountValue: json['discountValue'] ?? json['discount_value'] ?? 0,
      formattedDiscount: formattedDiscount,
    );
  }
}

class BranchModel {
  final String id;
  final String name;
  final String address;
  final String? city;
  final double? latitude;
  final double? longitude;
  final String? contactPhone;
  final BonusSettingsModel? bonusSettings;
  final List<BranchOffer> offers;

  BranchModel({
    required this.id,
    required this.name,
    required this.address,
    this.city,
    this.latitude,
    this.longitude,
    this.contactPhone,
    this.bonusSettings,
    required this.offers,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      contactPhone: json['contactPhone'] ?? json['contact_phone'],
      bonusSettings: json['bonusSettings'] != null
          ? BonusSettingsModel.fromJson(json['bonusSettings'])
          : null,
      offers: (json['offers'] as List<dynamic>?)
              ?.map((offer) => BranchOffer.fromJson(offer))
          .toList() ??
          [],
    );
  }
}

class BonusSettingsModel {
  final int redemptionsRequired;
  final int? currentRedemptions; // For user progress (optional if not logged in)
  final String discountDescription; // e.g., "50% OFF"
  final bool isActive;

  BonusSettingsModel({
    required this.redemptionsRequired,
    this.currentRedemptions,
    required this.discountDescription,
    required this.isActive,
  });

  factory BonusSettingsModel.fromJson(Map<String, dynamic> json) {
    return BonusSettingsModel(
      redemptionsRequired: json['redemptionsRequired'] ?? json['redemptions_required'] ?? 0,
      currentRedemptions: json['currentRedemptions'],
      discountDescription: json['discountDescription'] ?? json['discount_description'] ?? '',
      isActive: json['isActive'] ?? json['is_active'] ?? true,
    );
  }

  double get progress {
    if (currentRedemptions == null || redemptionsRequired == 0) return 0.0;
    return (currentRedemptions! / redemptionsRequired).clamp(0.0, 1.0);
  }
}
