import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/redemption_model.dart';
import '../services/redemption_service.dart';

final redemptionStatsProvider = FutureProvider<RedemptionStats>((ref) async {
  return await redemptionService.getStats();
});

// We can add more specific providers if needed, e.g. recentRedemptions
final recentRedemptionsProvider =
    FutureProvider.autoDispose<List<RedemptionModel>>((ref) async {
  // Fetch only first page
  return await redemptionService.getRedemptions(page: 1);
});
