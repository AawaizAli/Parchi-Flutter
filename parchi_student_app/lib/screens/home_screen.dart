import 'package:flutter/material.dart';
import '../utils/colours.dart';
import '../widgets/parchi_card.dart';
import '../widgets/home_sheet_content.dart'; // Import the new separated widget

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
    
    // GAP 1: Space between Card and Sheet (Initial State)
    const double initialGap = 50.0;
    
    // GAP 2: Space between Search Bar and Sheet (Expanded State)
    const double expandedGap = 20.0;

    // 2. CALCULATE SHEET LIMITS
    
    // Max Size: Stops below the Header + Expanded Gap
    _maxSheetSize = (screenHeight - (headerHeight + expandedGap)) / screenHeight;

    // Min Size: Stops after Header + Card + Initial Gap
    _minSheetSize = (screenHeight - (headerHeight + cardHeight + initialGap)) / screenHeight;

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
            snap: true, // Snap to Start or End
            builder: (BuildContext context, ScrollController scrollController) {
              // Using the extracted widget here for cleaner code
              return HomeSheetContent(scrollController: scrollController);
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
                        
                        // Notification Icon (Shrinks & Fades)
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