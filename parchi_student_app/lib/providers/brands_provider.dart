import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/brand_model.dart';
import '../services/brands_service.dart';

final brandsProvider = FutureProvider<List<BrandModel>>((ref) async {
  return brandsService.getAllBrands();
});
