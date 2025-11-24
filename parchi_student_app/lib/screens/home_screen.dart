import 'package:flutter/material.dart';
import '../utils/colours.dart';
import '../widgets/parchi_card.dart';
import '../widgets/brand_card.dart';
import '../widgets/restaurant_big_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. The main background is now Orange (Secondary) as requested
      backgroundColor: AppColors.secondary, 
      body: SafeArea(
        bottom: false, // Allow the white sheet to extend behind the bottom nav
        child: Column(
          children: [
            // ==========================================
            // TOP SECTION (Orange Background)
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                children: [
                  // Row 1: Location/Title + Notification
                  Row(
                    children: [
                      // Using White for contrast on Orange background
                      const Icon(Icons.location_on, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Current Location",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              "Gulistan-e-Jauhar, Karachi",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_none, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Row 2: Search Bar
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: AppColors.surface, // White Surface
                      borderRadius: BorderRadius.circular(25),
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
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ==========================================
            // BOTTOM SECTION (Rounded Sheet)
            // ==========================================
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.backgroundLight, // Light Grey Sheet
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  child: CustomScrollView(
                    slivers: [
                      // Spacer to push content down slightly inside the sheet
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),

                      // 1. Parchi ID Card
                      const SliverToBoxAdapter(
                        child: ParchiCard(),
                      ),

                      // 2. Top Brands Title
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                          child: Text(
                            "Top Brands",
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary // Dark Charcoal
                            ),
                          ),
                        ),
                      ),

                      // 3. Top Brands Carousel
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

                      // 4. "Up to 30% off" Header
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
                                  color: AppColors.textPrimary // Dark Charcoal
                                ),
                              ),
                              // Arrow uses Primary Blue
                              Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary)
                            ],
                          ),
                        ),
                      ),

                      // 5. Vertical List of Big Cards
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}