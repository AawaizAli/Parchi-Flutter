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

  // We will calculate these in build() based on screen size
  double _minSheetSize = 0.5; 
  double _maxSheetSize = 0.9;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChanged);
  }

  void _onSheetChanged() {
    double currentSize = _sheetController.size;
    // Normalize progress (0.0 = collapsed, 1.0 = fully expanded)
    double progress = (currentSize - _minSheetSize) / (_maxSheetSize - _minSheetSize);
    _expandProgress.value = progress.clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. MEASUREMENTS
    final double screenHeight = MediaQuery.of(context).size.height;
    final double topPadding = MediaQuery.of(context).padding.top;
    
    // Header Height = Top Safe Area + Vertical Padding (16*2) + Search Bar Height (45)
    final double headerHeight = topPadding + 32.0 + 45.0; 
    
    // Card Height (Approx height of ParchiCard widget)
    final double cardHeight = 180.0;
    
    // THE GAP: Space between Card and White Sheet
    // Increased to 50.0 to ensure a visible gap
    const double gap = 50.0;

    // 2. CALCULATE SHEET LIMITS
    // Max Size: Stops exactly at the bottom of the Header
    _maxSheetSize = (screenHeight - headerHeight) / screenHeight;

    // Min Size: Stops after Header + Card + Gap
    _minSheetSize = (screenHeight - (headerHeight + cardHeight + gap)) / screenHeight;

    // Safety Clamps (Prevent crash on very small screens)
    if (_minSheetSize < 0.2) _minSheetSize = 0.2;
    if (_maxSheetSize > 0.95) _maxSheetSize = 0.95;
    if (_minSheetSize > _maxSheetSize) _minSheetSize = _maxSheetSize - 0.05;

    return Scaffold(
      backgroundColor: AppColors.secondary, // Orange Background
      body: Stack(
        children: [
          // ==========================================
          // LAYER 1: Parchi Card (Behind the sheet)
          // ==========================================
          Positioned(
            top: headerHeight, // Starts exactly where header ends
            left: 0,
            right: 0,
            child: ValueListenableBuilder<double>(
              valueListenable: _expandProgress,
              builder: (context, progress, child) {
                // Fade out card as sheet goes up
                return Opacity(
                  opacity: (1.0 - (progress * 3)).clamp(0.0, 1.0), 
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
            snap: true, // Snap to Start or End (no floating in middle)
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
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),

                      // 1. Top Brands
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

                      // Carousel
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

                      // 2. Up to 30% off
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

                      // List of Restaurants
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
                ),
              );
            },
          ),

          // ==========================================
          // LAYER 3: Fixed Header (Stays on Top)
          // ==========================================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: ValueListenableBuilder<double>(
                  valueListenable: _expandProgress,
                  builder: (context, progress, child) {
                    return Row(
                      children: [
                        // Search Bar (Expands)
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
                        
                        // Notification Icon (Shrinks)
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