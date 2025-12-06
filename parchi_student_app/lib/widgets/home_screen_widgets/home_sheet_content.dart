import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/colours.dart';
import '../../providers/offers_provider.dart';
import 'package:parchi_student_app/widgets/home_screen_restraunts_widgets/brand_card.dart';
import '../home_screen_restraunts_widgets/restaurant_big_card.dart';
import '../home_screen_restraunts_widgets/restaurant_medium_card.dart';
import '../../screens/home/offer_details_screen.dart';

class HomeSheetContent extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const HomeSheetContent({
    super.key,
    required this.scrollController,
  });

  @override
  ConsumerState<HomeSheetContent> createState() => _HomeSheetContentState();
}

class _HomeSheetContentState extends ConsumerState<HomeSheetContent> {
  // --- DUMMY DATA FOR BRANDS ---
  final List<Map<String, String>> brands = List.generate(10, (index) => {
    "name": "Brand ${index + 1}",
    "time": "${15 + index}-25 min",
    "image": "https://placehold.co/100x100/png?text=Logo${index+1}"
  });

  // --- DUMMY DATA FOR ALL RESTAURANTS ---
  final List<Map<String, String>> allRestaurants = List.generate(8, (index) => {
    "name": "Restaurant ${index + 1}",
    "image": "https://placehold.co/600x300/png?text=Food${index+1}",
    "rating": "${4.0 + (index % 10) / 10}",
    "meta": "${20 + index} min • \$\$ • Cuisine",
    "discount": "${10 + (index * 5)}% OFF",
  });

  // --- NAVIGATION LOGIC ---
  void _onOfferTap(BuildContext context, String offerId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfferDetailsScreen(offerId: offerId),
      ),
    );
  }

  // --- FILTER MODAL LOGIC ---
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
              _buildFilterOption("30% OFF"),
              _buildFilterOption("15% OFF"),
              _buildFilterOption("10% OFF"),
              const Spacer(),
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
    // Watch the Riverpod provider for cached data
    final offersAsync = ref.watch(activeOffersProvider);

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
          controller: widget.scrollController,
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

            // --- SECTION 2: ACTIVE OFFERS (CONNECTED TO API) ---
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Active Offers",
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
                // Use .when to handle loading/error/data states elegantly
                child: offersAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (err, stack) => Center(
                    child: Text(
                      "Error loading offers", 
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  data: (offers) {
                    if (offers.isEmpty) {
                      return Center(
                        child: Text(
                          "No active offers right now.",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: offers.length,
                      itemBuilder: (context, index) {
                        final offer = offers[index];
                        
                        // Fallback Image Logic: Offer Image -> Merchant Logo -> Placeholder
                        final String displayImage = offer.imageUrl ?? 
                                                    offer.merchant?.logoPath ?? 
                                                    "https://placehold.co/600x300/png?text=No+Image";

                        // Wrap in GestureDetector for click functionality
                        return GestureDetector(
                          onTap: () => _onOfferTap(context, offer.id),
                          child: RestaurantMediumCard(
                            // Prefer merchant name, fall back to offer title
                            name: offer.merchant?.businessName ?? offer.title,
                            image: displayImage,
                            rating: "4.5", // API doesn't provide rating yet
                            meta: "Valid until ${offer.validUntil.day}/${offer.validUntil.month}",
                            discount: offer.formattedDiscount,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // --- SECTION 3: ALL RESTAURANTS HEADER ---
            // This header scrolls away normally
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
            // This stays pinned to the top as you scroll the restaurant list
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
  double get minExtent => 50.0;
  @override
  double get maxExtent => 50.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.backgroundLight,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
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