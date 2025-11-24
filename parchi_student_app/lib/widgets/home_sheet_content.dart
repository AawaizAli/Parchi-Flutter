import 'package:flutter/material.dart';
import '../utils/colours.dart';
import 'brand_card.dart';
import 'restaurant_big_card.dart';
import 'restaurant_medium_card.dart'; // Import the new medium card

class HomeSheetContent extends StatelessWidget {
  final ScrollController scrollController;

  // Dummy Data for Brands (Simulating API Response)
  final List<Map<String, String>> brands = List.generate(10, (index) => {
    "name": "Brand ${index + 1}",
    "time": "${15 + index}-25 min",
    "image": "https://placehold.co/100x100/png?text=Logo${index+1}"
  });

  // Dummy Data for Horizontal Restaurants (30% OFF)
  final List<Map<String, String>> promoRestaurants = List.generate(8, (index) => {
    "name": "Promo Rest ${index + 1}",
    "image": "https://placehold.co/600x300/png?text=Promo${index+1}",
    "rating": "4.5",
    "meta": "15-25 min • \$\$",
    "discount": "30% OFF",
  });

  // Dummy Data for Vertical Restaurants (All Restaurants)
  final List<Map<String, String>> allRestaurants = List.generate(8, (index) => {
    "name": "Restaurant ${index + 1}",
    "image": "https://placehold.co/600x300/png?text=Food${index+1}",
    "rating": "${4.0 + (index % 10) / 10}",
    "meta": "${20 + index} min • \$\$ • Cuisine",
    "discount": "${10 + (index * 5)}% OFF",
  });

  HomeSheetContent({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // --- SECTION: TOP BRANDS ---
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Top Brands",
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary
                  ),
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 160,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: brands.length,
                  itemBuilder: (context, index) {
                    final brand = brands[index];
                    return BrandCard(
                      name: brand["name"]!,
                      time: brand["time"]!,
                      image: brand["image"]!,
                    );
                  },
                ),
              ),
            ),

            // --- SECTION: 30% OFF (Horizontal Scroll) ---
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Up to 30% off!",
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary)
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 180, // Height for the medium cards
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: promoRestaurants.length,
                  itemBuilder: (context, index) {
                    final rest = promoRestaurants[index];
                    return RestaurantMediumCard(
                      name: rest["name"]!,
                      image: rest["image"]!,
                      rating: rest["rating"]!,
                      meta: rest["meta"]!,
                      discount: rest["discount"]!,
                    );
                  },
                ),
              ),
            ),

            // --- SECTION: ALL RESTAURANTS (Vertical List) ---
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  "All Restaurants",
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final rest = allRestaurants[index];
                    return RestaurantBigCard(
                      name: rest["name"]!,
                      image: rest["image"]!,
                      rating: rest["rating"]!,
                      meta: rest["meta"]!,
                      discount: rest["discount"]!,
                    );
                  },
                  childCount: allRestaurants.length,
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}