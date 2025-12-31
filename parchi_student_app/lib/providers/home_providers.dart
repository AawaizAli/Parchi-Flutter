// lib/providers/home_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/home_models.dart';

// --- 1. MOCK API SERVICE (Simulates network calls) ---
class MockApiService {
  Future<List<Brand>> fetchBrands() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    return List.generate(10, (index) => Brand(
      name: "Brand ${index + 1}",
      time: "${15 + index}-25 min",
      image: "https://placehold.co/100x100/png?text=Logo${index+1}",
    ));
  }

  Future<List<Restaurant>> fetchPromoRestaurants() async {
    await Future.delayed(const Duration(seconds: 2));
    return List.generate(8, (index) => Restaurant(
      name: "Promo Rest ${index + 1}",
      image: "https://placehold.co/600x300/png?text=Promo${index+1}",
      rating: "4.5",
      meta: "15-25 min • \$\$",
      discount: "30% OFF",
    ));
  }

  Future<List<Restaurant>> fetchAllRestaurants() async {
    await Future.delayed(const Duration(seconds: 2));
    return List.generate(8, (index) => Restaurant(
      name: "Restaurant ${index + 1}",
      image: "https://placehold.co/600x300/png?text=Food${index+1}",
      rating: "${4.0 + (index % 10) / 10}",
      meta: "${20 + index} min • \$\$ • Cuisine",
      discount: "${10 + (index * 5)}% OFF",
    ));
  }
}

// --- 2. PROVIDERS ---

// A simple provider for the API service
final apiServiceProvider = Provider((ref) => MockApiService());

// Provider for Top Brands
final brandsProvider = FutureProvider<List<Brand>>((ref) async {
  return ref.read(apiServiceProvider).fetchBrands();
});

// Provider for Promo Restaurants (30% OFF)
final promoRestaurantsProvider = FutureProvider<List<Restaurant>>((ref) async {
  return ref.read(apiServiceProvider).fetchPromoRestaurants();
});

// Provider for All Restaurants
final allRestaurantsProvider = FutureProvider<List<Restaurant>>((ref) async {
  return ref.read(apiServiceProvider).fetchAllRestaurants();
});