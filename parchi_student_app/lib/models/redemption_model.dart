import 'offer_model.dart';

class RedemptionModel {
  final String id;
  final OfferModel?
      offer; // Nullable if offer details are missing or simplified
  final String branchId;
  final DateTime redeemedAt;
  final bool isBonusApplied;
  final num bonusDiscountApplied;
  final String? verifiedBy;
  final String? notes;
  final String status;
  final String? branchName; // Often returned by join
  final Merchant? merchant;

  RedemptionModel({
    required this.id,
    this.offer,
    required this.branchId,
    required this.redeemedAt,
    this.isBonusApplied = false,
    this.bonusDiscountApplied = 0,
    this.verifiedBy,
    this.notes,
    required this.status,
    this.branchName,
    this.merchant,
  });

  factory RedemptionModel.fromJson(Map<String, dynamic> json) {
    return RedemptionModel(
      id: json['id'] ?? '',
      offer: json['offer'] != null ? OfferModel.fromJson(json['offer']) : null,
      branchId: json['branch_id'] ?? json['branchId'] ?? '',
      redeemedAt:
          DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ??
              DateTime.now(),
      isBonusApplied:
          json['is_bonus_applied'] ?? json['isBonusApplied'] ?? false,
      bonusDiscountApplied:
          json['bonus_discount_applied'] ?? json['bonusDiscountApplied'] ?? 0,
      verifiedBy: json['verified_by'] ?? json['verifiedBy'],
      notes: json['notes'],
      status: json['status'] ??
          (json['verified_by'] != null ? 'APPROVED' : 'PENDING'),
      branchName: json['branch']?['branch_name'] ??
          json['branch']?['branchName'] ??
          'Unknown Branch',
      merchant: json['merchant'] != null ? Merchant.fromJson(json['merchant']) : null,
    );
  }
}

class RedemptionStats {
  final int totalRedemptions;
  final int bonusesUnlocked;
  final int leaderboardPosition;

  RedemptionStats({
    required this.totalRedemptions,
    required this.bonusesUnlocked,
    required this.leaderboardPosition,
  });

  factory RedemptionStats.fromJson(Map<String, dynamic> json) {
    return RedemptionStats(
      totalRedemptions:
          json['totalRedemptions'] ?? json['redemption_count'] ?? 0,
      bonusesUnlocked: json['bonusesUnlocked'] ?? json['bonuses_unlocked'] ?? 0,
      leaderboardPosition:
          json['leaderboardPosition'] ?? json['leaderboard_position'] ?? 0,
    );
  }
}
