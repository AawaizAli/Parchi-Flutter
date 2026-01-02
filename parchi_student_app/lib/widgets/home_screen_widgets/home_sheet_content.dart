import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../../utils/colours.dart';
import '../../providers/offers_provider.dart';
import '../../providers/brands_provider.dart';
import '../../providers/merchants_provider.dart';
import 'package:parchi_student_app/widgets/home_screen_restraunts_widgets/brand_card.dart';
import '../home_screen_restraunts_widgets/restaurant_big_card.dart';
import '../home_screen_restraunts_widgets/restaurant_medium_card.dart';
import '../../screens/home/offers/offer_details_screen.dart';
import '../../screens/home/merchant_details_screen.dart';
import '../../models/merchant_detail_model.dart';
import '../../models/student_merchant_model.dart';

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

  // --- DUMMY DATA FOR ALL RESTAURANTS (MERCHANTS) ---
  // --- DUMMY DATA FOR ALL RESTAURANTS (MERCHANTS) ---
  // --- DUMMY DATA REMOVED ---

  // --- REFRESH LOGIC ---
  Future<void> _refreshData() async {
    try {
      // Load fresh data
      await ref.refresh(activeOffersProvider.future);
      await ref.refresh(brandsProvider.future);
      await ref.refresh(studentMerchantsProvider.future);
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

  void _onMerchantTap(BuildContext context, String merchantId) {
    // Navigate to merchant details screen which will fetch data using the provider
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _MerchantDetailsScreenWrapper(merchantId: merchantId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offersAsync = ref.watch(activeOffersProvider);
    final studentMerchantsAsync = ref.watch(studentMerchantsProvider);
    const double indicatorSize = 100.0; // Total height area for the loader

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
      ),
      child: CustomRefreshIndicator(
        onRefresh: _refreshData,
        offsetToArmed: indicatorSize,
        builder: (BuildContext context, Widget child,
            IndicatorController controller) {
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
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // --- SECTION 1: TOP BRANDS (GRID) ---
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.0),
                child: Text(
                  "Top Brands",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 290, // Height for 2 rows of items
                child: ref.watch(brandsProvider).when(
                      loading: () => const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary)),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                      data: (brands) {
                        if (brands.isEmpty) {
                          return const Center(
                              child: Text("No brands available"));
                        }
                        // Take first 6 brands for 2x3 grid
                        final displayBrands = brands.take(6).toList();

                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: displayBrands.length,
                          itemBuilder: (context, index) {
                            final brand = displayBrands[index];
                            return GestureDetector(
                              onTap: () => _onMerchantTap(
                                context,
                                brand.id,
                              ),
                              child: BrandCard(
                                name: brand.businessName,
                                image: brand.logoPath ??
                                    "https://placehold.co/100x100/png?text=No+Image",
                              ),
                            );
                          },
                        );
                      },
                    ),
              ),
            ),

            // --- SECTION 2: ACTIVE OFFERS (CAROUSEL) ---
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18, 24, 18, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Featured Offers",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    
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
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  data: (offers) {
                    if (offers.isEmpty) {
                      return const Center(
                        child: Text(
                          "No active offers right now.",
                          style: TextStyle(color: AppColors.textSecondary),
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
                            "https://placehold.co/600x300/png?text=No+Image";

                        return GestureDetector(
                          onTap: () => _onOfferTap(context, offer.id),
                          child: RestaurantMediumCard(
                            name: offer.title,
                            image: displayImage,
                            discount: offer.formattedDiscount,
                            branchName: offer.branchName ?? "All Branches",
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
                padding: EdgeInsets.fromLTRB(18, 24, 18, 8),
                child: Text(
                  "All Restaurants",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
              ),
            ),

            // --- ALL RESTAURANTS LIST ---
            studentMerchantsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),
              error: (err, stack) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      "Error loading restaurants",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
              data: (merchants) {
                if (merchants.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          "No restaurants available yet.",
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final merchant = merchants[index];
                        return GestureDetector(
                          onTap: () => _onMerchantTap(context, merchant.id),
                          child: RestaurantBigCard(
                            name: merchant.businessName,
                            image: merchant.bannerUrl ??
                                "https://placehold.co/600x300/png?text=No+Image",
                            category: merchant.category ?? "General",
                          ),
                        );
                      },
                      childCount: merchants.length,
                    ),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
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
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
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
                border:
                    Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  )
                ],
              ),
              child: const Row(
                children: [
                  Text("Offers",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down,
                      size: 18, color: AppColors.textPrimary)
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

  const ParchiLoader(
      {super.key, required this.isLoading, required this.progress});

  @override
  State<ParchiLoader> createState() => _ParchiLoaderState();
}

class _ParchiLoaderState extends State<ParchiLoader>
    with SingleTickerProviderStateMixin {
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

// Wrapper widget to handle loading and error states for merchant details
class _MerchantDetailsScreenWrapper extends ConsumerWidget {
  final String merchantId;

  const _MerchantDetailsScreenWrapper({required this.merchantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final merchantAsync = ref.watch(merchantDetailsProvider(merchantId));

    return merchantAsync.when(
      data: (merchant) => MerchantDetailsScreen(merchant: merchant),
      loading: () => Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Loading...',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Error',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load merchant details',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(merchantDetailsProvider(merchantId));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
