import 'package:flutter/material.dart';
import '../../utils/colours.dart';
import '../home_screen_restraunts_widgets/brand_card.dart';
import '../home_screen_restraunts_widgets/restaurant_big_card.dart';
import '../home_screen_restraunts_widgets/restaurant_medium_card.dart';

class HomeSheetContent extends StatelessWidget {
  final ScrollController scrollController;

  // Dummy Data for Brands
  final List<Map<String, String>> brands = List.generate(10, (index) => {
    "name": "Brand ${index + 1}",
    "time": "${15 + index}-25 min",
    "image": "https://placehold.co/100x100/png?text=Logo${index+1}"
  });

  // Dummy Data for Horizontal Restaurants
  final List<Map<String, String>> promoRestaurants = List.generate(8, (index) => {
    "name": "Promo Rest ${index + 1}",
    "image": "https://placehold.co/600x300/png?text=Promo${index+1}",
    "rating": "4.5",
    "meta": "15-25 min • \$\$",
    "discount": "30% OFF",
  });

  // Dummy Data for Vertical Restaurants
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

  // Function to show the Filter Modal
  void _showOffersModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: 320,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Offers",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Filter Options
              _buildFilterOption("30% OFF"),
              _buildFilterOption("15% OFF"),
              _buildFilterOption("10% OFF"),
              
              const Spacer(),
              
              // Apply Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Apply",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

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

            // --- SECTION 1: TOP BRANDS ---
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

            // --- SECTION 2: 30% OFF ---
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
                height: 180, 
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

            // --- SECTION 3: ALL RESTAURANTS HEADER ---
            // This text will scroll away
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
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

            // --- STICKY FILTER HEADER ---
            // This will stick to the top when the above text scrolls away
            SliverPersistentHeader(
              pinned: true,
              delegate: _FilterHeaderDelegate(
                onFilterTap: () => _showOffersModal(context),
              ),
            ),

            // --- ALL RESTAURANTS LIST ---
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

// --- DELEGATE FOR STICKY HEADER ---
class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final VoidCallback onFilterTap;

  _FilterHeaderDelegate({required this.onFilterTap});

  @override
  double get minExtent => 50.0; // Height of the sticky area
  @override
  double get maxExtent => 50.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.backgroundLight, // Matches sheet bg so list scrolls "under" it visually
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface, // White button
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  )
                ],
              ),
              child: const Row(
                children: [
                  Text("Offers", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.textPrimary)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _FilterHeaderDelegate oldDelegate) => false;
}