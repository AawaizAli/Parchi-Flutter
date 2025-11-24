import 'package:flutter/material.dart';
import '../utils/colours.dart';
import '../widgets/parchi_card.dart';
import '../widgets/brand_card.dart';       
import '../widgets/restaurant_big_card.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // ==========================================
          // SECTION 1: Header (Search & Notification)
          // ==========================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.textSecondary.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: "Search restaurants...",
                          hintStyle: TextStyle(color: AppColors.textSecondary),
                          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textSecondary.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==========================================
          // SECTION 2: Parchi ID Card
          // ==========================================
          const SliverToBoxAdapter(
            child: ParchiCard(),
          ),

          // ==========================================
          // SECTION 3: TOP BRANDS (Horizontal Carousel)
          // ==========================================
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
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

          // Horizontal ListView for Brands
          SliverToBoxAdapter(
            child: SizedBox(
              height: 160, // Height to fit card + text
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

          // ==========================================
          // SECTION 4: UP TO 30% OFF (Vertical List)
          // ==========================================
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
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

          // Vertical List of Big Cards
          // We use SliverList instead of SliverGrid now
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
          
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}