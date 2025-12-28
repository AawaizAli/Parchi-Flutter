import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/merchant_detail_model.dart';
import '../services/merchants_service.dart';

// Provider for fetching merchant details by ID
final merchantDetailsProvider = FutureProvider.family<MerchantDetailModel, String>(
  (ref, merchantId) async {
    return merchantsService.getMerchantDetails(merchantId);
  },
);

