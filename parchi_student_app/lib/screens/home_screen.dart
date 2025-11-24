import 'package:flutter/material.dart';
import '../utils/colours.dart';
import '../widgets/parchi_card.dart';
import '../widgets/brand_card.dart';
import '../widgets/restaurant_big_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controller to track the sheet's position
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  // Animation values
  final ValueNotifier<double> _expandProgress = ValueNotifier(0.0);

  // Layout Constants
  final double _headerHeight = 80.0; // Approx height of Top Section
  final double _cardHeight = 200.0;  // Height of ParchiCard + Padding
  
  // Sheet Extents (0.0 to 1.0 of screen height)
  // We'll calculate these dynamically in the build method based on screen size
  double _minSheetSize = 0.55; 
  final double _maxSheetSize = 0.92; // Stops just below the top header

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChanged);
  }

  void _onSheetChanged() {
    // Calculate progress from 0.0 (Collapsed) to 1.0 (Expanded)
    // We normalize the size between min and max
    double currentSize = _sheetController.size;
    double progress = (currentSize - _minSheetSize) / (_maxSheetSize - _minSheetSize);
    
    // Clamp between 0 and 1
    progress = progress.clamp(0.0, 1.0);
    
    _expandProgress.value = progress;
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic calculation for initial sheet position
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    
    // Calculate how much space the Header + Card takes
    // The sheet should start right after them.
    // 1.0 is full screen. We subtract the pixels taken by top elements.
    double contentTopPixels = _headerHeight + _cardHeight + topPadding;
    _minSheetSize = 1.0 - (contentTopPixels / screenHeight);

    // Safety clamp to prevent errors on very small screens
    if (_minSheetSize < 0.2) _minSheetSize = 0.2;
    if (_minSheetSize > _maxSheetSize) _minSheetSize = _maxSheetSize - 0.1;

    return Scaffold(
      backgroundColor: AppColors.secondary, // Orange Background
      body: Stack(
        children: [
          // ==========================================
          // LAYER 1: Parchi Card (Behind the sheet)
          // ==========================================
          Positioned(
            top: topPadding + _headerHeight - 10, // Position right below header
            left: 0,
            right: 0,
            child: ValueListenableBuilder<double>(
              valueListenable: _expandProgress,
              builder: (context, progress, child) {
                // Fade out card as sheet goes up (Opacity 1.0 -> 0.0)
                return Opacity(
                  opacity: (1.0 - (progress * 2)).clamp(0.0, 1.0), // Fades out twice as fast
                  child: const ParchiCard(),
                );
              },
            ),
          ),

          // ==========================================
          // LAYER 2: Draggable Sheet (White Background)
          // ==========================================
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: _minSheetSize,
            minChildSize: _minSheetSize,
            maxChildSize: _maxSheetSize,
            snap: true, // Snap to min or max, don't float in middle
            builder: (BuildContext context, ScrollController scrollController) {
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
            },
          ),

          // ==========================================
          // LAYER 3: Fixed Header (Search & Notif)
          // ==========================================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ValueListenableBuilder<double>(
                  valueListenable: _expandProgress,
                  builder: (context, progress, child) {
                    return Row(
                      children: [
                        // Expanded Search Bar
                        Expanded(
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
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
                        ),
                        
                        // Animated Container for Notification
                        // Width shrinks to 0 and Opacity fades to 0 as progress -> 1
                        SizeTransition(
                          sizeFactor: AlwaysStoppedAnimation(1.0 - progress),
                          axis: Axis.horizontal,
                          axisAlignment: -1.0,
                          child: FadeTransition(
                            opacity: AlwaysStoppedAnimation(1.0 - progress),
                            child: Row(
                              children: [
                                const SizedBox(width: 12),
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
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}