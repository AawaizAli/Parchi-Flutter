import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/offer_model.dart';
import '../services/offers_service.dart';

// This provider fetches the offers once and caches the result.
// It will NOT refresh automatically unless you explicitly invalidate it.
final activeOffersProvider = FutureProvider<List<OfferModel>>((ref) async {
  // We use the singleton instance we created in the service file
  return offersService.getActiveOffers();
});