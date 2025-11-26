import 'package:flutter/material.dart';
import '../utils/colours.dart';
import '../widgets/parchi_card.dart';
import '../widgets/home_sheet_content.dart';
import '../services/auth_service.dart'; // [NEW] Added import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final ValueNotifier<double> _expandProgress = ValueNotifier(0.0);

  double _minSheetSize = 0.5; 
  double _maxSheetSize = 0.9;

  // [CHANGED] Use state variables initialized to loading
  String _userName = "LOADING...";
  String _userId = "....";

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChanged);
    // [LOGIC ADDED] Fetch profile on screen load
    _loadUserProfile();
  }

  // [LOGIC ADDED] Method to fetch real user data
  Future<void> _loadUserProfile() async {
    try {
      // 1. Fetch from backend API
      final profileResponse = await authService.getProfile();
      
      if (mounted) {
        setState(() {
          // 2. Parse User Data
          // Combine First + Last Name
          final String firstName = profileResponse.user.firstName ?? "Student";
          final String lastName = profileResponse.user.lastName ?? "";
          
          _userName = "$firstName $lastName".trim().toUpperCase();
          
          // Get Parchi ID (fallback to Pending if null)
          _userId = profileResponse.user.parchiId ?? "PENDING";
        });
      }
    } catch (e) {
      // 3. Fallback: If network fails, try to load from local storage
      print("Network fetch failed: $e. Trying local storage...");
      
      final localUser = await authService.getUser();
      if (localUser != null && mounted) {
        setState(() {
          final String firstName = localUser.firstName ?? "Student";
          final String lastName = localUser.lastName ?? "";
          _userName = "$firstName $lastName".trim().toUpperCase();
          _userId = localUser.parchiId ?? "PK-????";
        });
      }
    }
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
                  child: ParchiCard(
                    studentName: _userName, // [CHANGED] Uses real state variable
                    studentId: _userId,     // [CHANGED] Uses real state variable
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