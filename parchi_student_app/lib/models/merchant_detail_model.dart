class MerchantDetailModel {
  final String id;
  final String businessName;
  final String logoPath;
  final String category;
  final String termsAndConditions;
  final List<BranchModel> branches;

  MerchantDetailModel({
    required this.id,
    required this.businessName,
    required this.logoPath,
    required this.category,
    required this.termsAndConditions,
    required this.branches,
  });
}

class BranchModel {
  final String id;
  final String name;
  final String address;
  final BonusSettingsModel? bonusSettings;

  BranchModel({
    required this.id,
    required this.name,
    required this.address,
    this.bonusSettings,
  });
}

class BonusSettingsModel {
  final int redemptionsRequired;
  final int currentRedemptions; // For user progress
  final String discountDescription; // e.g., "50% OFF"

  BonusSettingsModel({
    required this.redemptionsRequired,
    required this.currentRedemptions,
    required this.discountDescription,
  });

  double get progress =>
      (currentRedemptions / redemptionsRequired).clamp(0.0, 1.0);
}
