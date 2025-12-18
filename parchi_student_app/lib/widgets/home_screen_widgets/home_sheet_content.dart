import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../../utils/colours.dart';
import '../../providers/offers_provider.dart';
import '../../providers/brands_provider.dart';
import 'package:parchi_student_app/widgets/home_screen_restraunts_widgets/brand_card.dart';
import '../home_screen_restraunts_widgets/restaurant_big_card.dart';
import '../home_screen_restraunts_widgets/restaurant_medium_card.dart';
import '../../screens/home/offers/offer_details_screen.dart';

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
  // --- DUMMY DATA FOR BRANDS REMOVED ---


  // --- DUMMY DATA FOR ALL RESTAURANTS ---
  final List<Map<String, String>> allRestaurants = List.generate(8, (index) => {
    "name": "Restaurant ${index + 1}",
    "image": "https://placehold.co/600x300/png?text=Food${index+1}",
    "rating": "${4.0 + (index % 10) / 10}",
    "meta": "${20 + index} min • \$\$ • Cuisine",
    "discount": "${10 + (index * 5)}% OFF",
  });

  // --- REFRESH LOGIC ---
  Future<void> _refreshData() async {
    try {
      // Load fresh data
      await ref.refresh(activeOffersProvider.future);
      await ref.refresh(brandsProvider.future);
      // await ref.refresh(allRestaurantsProvider.future); 
      // await Future.delayed(const Duration(seconds: 2)); // Uncomment to test the loader duration
    } catch (e) {
      debugPrint("Refresh failed: $e");
    }
  }

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
    final offersAsync = ref.watch(activeOffersProvider);
    const double indicatorSize = 100.0; // Total height area for the loader

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
        child: CustomRefreshIndicator(
          onRefresh: _refreshData,
          offsetToArmed: indicatorSize,
          builder: (BuildContext context, Widget child, IndicatorController controller) {
            return Stack(
              children: <Widget>[
                // 1. The Animated Custom Loader (Stays at the top)
                AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) {
                    return SizedBox(
                      height: controller.value * indicatorSize,
                      width: double.infinity,
                      child: Center(
                        child: ParchiLoader(
                          isLoading: controller.isLoading,
                          progress: controller.value,
                        ),
                      ),
                    );
                  },
                ),

                // 2. The Main Content (Pushes down as you drag)
                Transform.translate(
                  offset: Offset(0.0, controller.value * indicatorSize),
                  child: child,
                ),
              ],
            );
          },
          child: CustomScrollView(
            controller: widget.scrollController,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
                  child: ref.watch(brandsProvider).when(
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                    data: (brands) {
                      if (brands.isEmpty) {
                        return const Center(child: Text("No brands available"));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: brands.length,
                        itemBuilder: (context, index) {
                          final brand = brands[index];
                          return BrandCard(
                            name: brand.businessName,
                            time: "30-45 min", // Placeholder
                            image: brand.logoPath ?? "https://placehold.co/100x100/png?text=No+Image",
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // --- SECTION 2: ACTIVE OFFERS ---
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
                          final String displayImage = offer.imageUrl ?? 
                                                      offer.merchant?.logoPath ?? 
                                                      "https://placehold.co/600x300/png?text=No+Image";

                          return GestureDetector(
                            onTap: () => _onOfferTap(context, offer.id),
                            child: RestaurantMediumCard(
                              name: offer.merchant?.businessName ?? offer.title,
                              image: displayImage,
                              rating: "4.5", 
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
      ),
    );
  }
}

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

// --- CUSTOM LOADER WIDGET ---
class ParchiLoader extends StatefulWidget {
  final bool isLoading;
  final double progress; 

  const ParchiLoader({
    super.key, 
    required this.isLoading, 
    required this.progress
  });

  @override
  State<ParchiLoader> createState() => _ParchiLoaderState();
}

class _ParchiLoaderState extends State<ParchiLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1), // Adjust speed here if needed
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(ParchiLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isLoading && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Rotation Logic: 
        // Spin continuously if loading, or rotate based on pull distance
        final double rotationValue = widget.isLoading 
            ? _controller.value * 2 * math.pi 
            : widget.progress * 2 * math.pi;

        return Transform.rotate(
          angle: rotationValue,
          child: Image.asset(
            'assets/parchi-icon.png',
            width: 120, 
            height: 120,
          ),
        );
      },
    );
  }
}