import 'package:flutter/material.dart';
import '../utils/colours.dart';
import 'brand_card.dart';
import 'restaurant_big_card.dart';

class HomeSheetContent extends StatelessWidget {
  final ScrollController scrollController;

  const HomeSheetContent({
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
            // Spacer inside the sheet
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // 1. Top Brands Title
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

            // 2. Top Brands Carousel
            SliverToBoxAdapter(
              child: SizedBox(
                height: 160,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return BrandCard(
                      name: "Brand ${index + 1}",
                      time: "15-25 min",
                      image: "https://placehold.co/100x100/png?text=Brand",
                    );
                  },
                ),
              ),
            ),

            // 3. "Up to 30% off" Header
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

            // 4. Vertical List of Big Cards
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return const RestaurantBigCard();
                  },
                  childCount: 8,
                ),
              ),
            ),
            
            // Bottom Spacer
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}