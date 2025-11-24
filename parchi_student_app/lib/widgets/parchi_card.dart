import 'package:flutter/material.dart';
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
                  // Using Primary (Blue) and BackgroundDark (Charcoal) for a sleek look
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

class _ParchiCardDetailState extends State<ParchiCardDetail> with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  bool _isFront = true;

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

  void _flipCard() {
    if (_isFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    _isFront = !_isFront;
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
      onTap: _handleClose,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: GestureDetector(
            onTap: _flipCard,
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
          // Back side uses Dark Background for contrast
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
        child: Row(
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
                      color: AppColors.secondary, // Using Secondary (Orange) for stats
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
                  Text("MONTHLY STATS", style: TextStyle(color: AppColors.textSecondary, fontSize: 10, letterSpacing: 1)),
                  Divider(color: Colors.white24),
                  SizedBox(height: 5),
                  Text("Discounts: 15/20", style: TextStyle(color: AppColors.surface, fontSize: 16)),
                  SizedBox(height: 5),
                  Text("Total Saved:", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  // Using Success color (Green) for money saved
                  Text("PKR 4,500", style: TextStyle(color: AppColors.success, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// 3. UI HELPER
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "ID: PK-12345",
                      style: TextStyle(color: AppColors.textOnPrimary, fontSize: 12, fontFamily: 'Courier', fontWeight: FontWeight.bold),
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