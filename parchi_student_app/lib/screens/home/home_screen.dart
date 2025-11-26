import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // [NEW]
import '../../utils/colours.dart';
import '../../widgets/home_screen_parchicard_widgets/parchi_card.dart';
import '../../widgets/home_screen_restraunts_widgets/home_sheet_content.dart';
import '../../providers/user_provider.dart'; // [NEW]

// [CHANGED] Extend ConsumerStatefulWidget
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

// [CHANGED] Use ConsumerState
class _HomeScreenState extends ConsumerState<HomeScreen> {
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final ValueNotifier<double> _expandProgress = ValueNotifier(0.0);

  double _minSheetSize = 0.5; 
  double _maxSheetSize = 0.9;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChanged);
  }

  void _onSheetChanged() {
    double currentSize = _sheetController.size;
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double topPadding = MediaQuery.of(context).padding.top;
    
    final double headerHeight = topPadding + 32.0 + 45.0; 
    final double cardHeight = 180.0;
    
    const double initialGap = 50.0;
    const double expandedGap = 20.0;

    _maxSheetSize = (screenHeight - (headerHeight + expandedGap)) / screenHeight;
    _minSheetSize = (screenHeight - (headerHeight + cardHeight + initialGap)) / screenHeight;

    if (_minSheetSize < 0.2) _minSheetSize = 0.2;
    if (_maxSheetSize > 0.95) _maxSheetSize = 0.95;
    if (_minSheetSize > _maxSheetSize) _minSheetSize = _maxSheetSize - 0.05;

    // [NEW] Watch the provider! 
    // This 'userAsync' variable contains the Data, Loading state, OR Error.
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Stack(
        children: [
          // LAYER 1: Parchi Card
          Positioned(
            top: headerHeight, 
            left: 0,
            right: 0,
            child: ValueListenableBuilder<double>(
              valueListenable: _expandProgress,
              builder: (context, progress, child) {
                return Opacity(
                  opacity: (1.0 - (progress * 3)).clamp(0.0, 1.0), 
                  
                  // [NEW] Handle states cleanly
                  child: userAsync.when(
                    data: (user) {
                      final fname = user?.firstName ?? "Student";
                      final lname = user?.lastName ?? "";
                      final fullName = "$fname $lname".trim().toUpperCase();
                      final pId = user?.parchiId ?? "PENDING";
                      
                      return ParchiCard(
                        studentName: fullName.isEmpty ? "STUDENT" : fullName,
                        studentId: pId,
                      );
                    },
                    loading: () => const ParchiCard(
                      studentName: "LOADING...",
                      studentId: "PK-....",
                    ),
                    error: (err, stack) => const ParchiCard(
                      studentName: "OFFLINE",
                      studentId: "ERROR",
                    ),
                  ),
                );
              },
            ),
          ),

          // LAYER 2: Draggable Sheet
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: _minSheetSize,
            minChildSize: _minSheetSize,
            maxChildSize: _maxSheetSize,
            snap: true,
            builder: (BuildContext context, ScrollController scrollController) {
              return HomeSheetContent(scrollController: scrollController);
            },
          ),

          // LAYER 3: Fixed Header
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