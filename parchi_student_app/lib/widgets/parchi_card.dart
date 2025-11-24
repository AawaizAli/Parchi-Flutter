import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for Clipboard
import 'dart:math';
import '../utils/colours.dart';

// =========================================================
// 1. ENTRY POINT
// =========================================================
class ParchiCard extends StatelessWidget {
  const ParchiCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(PageRouteBuilder(
            opaque: false,
            barrierDismissible: true,
            barrierColor: Colors.black87, 
            transitionDuration: const Duration(milliseconds: 600),
            reverseTransitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) {
              return FadeTransition(
                opacity: animation,
                child: const ParchiCardDetail(),
              );
            },
          ));
        },
        child: Hero(
          tag: 'parchi-card-hero',
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.backgroundDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const CardFrontContent(), 
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================
// 2. DETAIL VIEW
// =========================================================
class ParchiCardDetail extends StatefulWidget {
  const ParchiCardDetail({super.key});

  @override
  State<ParchiCardDetail> createState() => _ParchiCardDetailState();
}

// Enum to track the state of the back of the card
enum BackFaceView { currentMonth, yearlyStats, monthDetail }

class _ParchiCardDetailState extends State<ParchiCardDetail> with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  bool _isFront = true;
  
  // State for the Back Face
  BackFaceView _backView = BackFaceView.currentMonth;
  String _selectedMonth = "";

  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOutBack,
    ));

    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), 
    )..repeat(reverse: true);

    _hoverAnimation = Tween<double>(begin: -10, end: 10).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOutSine, 
    ));
  }

  // Logic to toggle flip state (Front <-> Back)
  void _flipCard() {
    if (_isFront) {
      // Flipping to BACK
      _flipController.forward();
      // Reset back view to default when opening
      setState(() {
        _backView = BackFaceView.currentMonth;
      });
    } else {
      // Flipping to FRONT
      _flipController.reverse();
    }
    _isFront = !_isFront;
  }

  // Logic for SWIPING inside the Back Face
  void _handleBackFaceSwipe(DragEndDetails details) {
    if (_isFront) return; // Swipes only work on the back face

    double velocity = details.primaryVelocity ?? 0;

    // Swipe Left (< 0): Go to NEXT view (Yearly Stats)
    if (velocity < 0) {
      if (_backView == BackFaceView.currentMonth) {
        setState(() {
          _backView = BackFaceView.yearlyStats;
        });
      }
    } 
    // Swipe Right (> 0): Go to PREVIOUS view (Current Month)
    else if (velocity > 0) {
      if (_backView == BackFaceView.yearlyStats) {
        setState(() {
          _backView = BackFaceView.currentMonth;
        });
      } else if (_backView == BackFaceView.monthDetail) {
        // If in detail view, swipe right goes back to list
        setState(() {
          _backView = BackFaceView.yearlyStats;
        });
      }
    }
  }

  Future<void> _handleClose() async {
    if (!_isFront) {
      _flipCard();
      await Future.delayed(const Duration(milliseconds: 600));
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleClose, // Tapping outside closes modal
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: GestureDetector(
            // Tapping the card flips it (Front <-> Back)
            onTap: _flipCard,
            // Horizontal Drag handles the internal state changes of the Back Face
            onHorizontalDragEnd: _handleBackFaceSwipe,
            child: AnimatedBuilder(
              animation: Listenable.merge([_flipAnimation, _hoverAnimation]),
              builder: (context, child) {
                final angle = _flipAnimation.value * pi;
                final flipTransform = Matrix4.identity()
                  ..setEntry(3, 2, 0.001) 
                  ..rotateY(angle);

                return Transform.translate(
                  offset: Offset(0, _hoverAnimation.value), 
                  child: Transform(
                    transform: flipTransform,
                    alignment: Alignment.center,
                    child: Hero(
                      tag: 'parchi-card-hero',
                      child: Material(
                        color: Colors.transparent,
                        // If angle < 90deg (pi/2), show Front. Otherwise show Back.
                        child: angle < pi / 2
                            ? _buildFrontFace()
                            : Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(pi),
                                child: _buildBackFace(),
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrontFace() {
    return Container(
      height: 220,
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.backgroundDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.6),
            blurRadius: 40,
            spreadRadius: 10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const CardFrontContent(),
    );
  }

  Widget _buildBackFace() {
    return Container(
      height: 220,
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.backgroundDark, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        // Animated Switcher handles the fade between Month Stats & Yearly Graph
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _buildBackContent(),
        ),
      ),
    );
  }

  Widget _buildBackContent() {
    switch (_backView) {
      case BackFaceView.currentMonth:
        return _buildCurrentMonthStats();
      case BackFaceView.yearlyStats:
        return _buildYearlyStats();
      case BackFaceView.monthDetail:
        return _buildMonthDetail();
    }
  }

  // --- VIEW 1: CURRENT MONTH (Initial Back View) ---
  Widget _buildCurrentMonthStats() {
    return Column(
      key: const ValueKey("CurrentMonth"),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      color: AppColors.textSecondary.withOpacity(0.1),
                      strokeWidth: 8,
                    ),
                  ),
                  const SizedBox(
                    height: 100,
                    width: 100,
                    child: CircularProgressIndicator(
                      value: 0.75,
                      color: AppColors.secondary,
                      strokeCap: StrokeCap.round,
                      strokeWidth: 8,
                    ),
                  ),
                   const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("15", style: TextStyle(color: AppColors.surface, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text("Used", style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            const Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("THIS MONTH", style: TextStyle(color: AppColors.textSecondary, fontSize: 10, letterSpacing: 1)),
                  Divider(color: Colors.white24),
                  SizedBox(height: 5),
                  Text("Discounts: 15/20", style: TextStyle(color: AppColors.surface, fontSize: 16)),
                  SizedBox(height: 5),
                  Text("Total Saved:", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text("PKR 4,500", style: TextStyle(color: AppColors.success, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        const Spacer(),
        // Helper Text at Bottom
        const Text(
          "Swipe left for yearly stats →",
          style: TextStyle(color: Colors.white30, fontSize: 10, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  // --- VIEW 2: YEARLY STATS (Bar Chart) ---
  Widget _buildYearlyStats() {
    final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"];
    final values = [0.3, 0.5, 0.8, 0.4, 0.9, 0.6]; 

    return Column(
      key: const ValueKey("YearlyStats"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "YEARLY OVERVIEW",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 10, letterSpacing: 1.2),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(months.length, (index) {
              return GestureDetector(
                // Tapping bar goes to detail
                onTap: () {
                  setState(() {
                    _selectedMonth = months[index];
                    _backView = BackFaceView.monthDetail;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 12,
                      height: 100 * values[index],
                      decoration: BoxDecoration(
                        color: values[index] > 0.7 ? AppColors.secondary : AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      months[index],
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text(
            "← Swipe right for month | Tap bar for details",
            style: TextStyle(color: Colors.white24, fontSize: 10, fontStyle: FontStyle.italic),
          ),
        )
      ],
    );
  }

  // --- VIEW 3: MONTH DETAIL (List) ---
  Widget _buildMonthDetail() {
    return Column(
      key: const ValueKey("MonthDetail"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$_selectedMonth RECAP",
              style: const TextStyle(color: AppColors.secondary, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 18),
              onPressed: () {
                setState(() {
                  _backView = BackFaceView.yearlyStats;
                });
              },
            )
          ],
        ),
        const Divider(color: Colors.white24),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHistoryItem("KFC", "PKR 500 Saved"),
              _buildHistoryItem("Pizza Max", "PKR 320 Saved"),
              _buildHistoryItem("Burger O'Clock", "PKR 150 Saved"),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildHistoryItem(String name, String saved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant, color: Colors.white54, size: 14),
              const SizedBox(width: 8),
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
          Text(saved, style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// =========================================================
// 3. UI HELPER (Front Face Content)
// =========================================================
class CardFrontContent extends StatelessWidget {
  const CardFrontContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: -20,
          top: -20,
          child: Icon(Icons.school, size: 150, color: AppColors.surface.withOpacity(0.05)),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.nfc, color: AppColors.textOnPrimary, size: 30),
                  Text(
                    "PARCHI STUDENT",
                    style: TextStyle(color: AppColors.textOnPrimary.withOpacity(0.7), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "AAWAIZ ALI",
                    style: TextStyle(color: AppColors.textOnPrimary, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: "PK-12345"));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("ID copied to clipboard!"),
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white24, width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "ID: PK-12345",
                            style: TextStyle(color: AppColors.textOnPrimary, fontSize: 12, fontFamily: 'Courier', fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.copy, size: 12, color: AppColors.textOnPrimary.withOpacity(0.8)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}