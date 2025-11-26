import 'package:flutter/material.dart';
import 'dart:math';
import '../../utils/colours.dart';
import '../../widgets/home_screen_parchicard_widgets/parchi_card.dart'; // Needed for CardFrontContent
import '../../widgets/home_screen_widgets/bonus_reward_card.dart'; 

class GoldUnlockScreen extends StatefulWidget {
  final RewardModel reward;
  final String studentName;
  final String studentId;

  const GoldUnlockScreen({
    super.key,
    required this.reward,
    required this.studentName,
    required this.studentId,
  });

  @override
  State<GoldUnlockScreen> createState() => _GoldUnlockScreenState();
}

class _GoldUnlockScreenState extends State<GoldUnlockScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _flipAnimation;
  late Animation<double> _scaleAnimation;

  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  bool _showBack = false; // False = Reward Card, True = Parchi Card

  @override
  void initState() {
    super.initState();

    // 1. Main Controller for Flip & Extend
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // Smooth, premium speed
    );

    // Flip: 0 to 180 degrees
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOutBack),
    );

    // Extend: Scale up slightly as it flips to emphasize importance
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 50), // Shrink slightly first
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.1), weight: 50), // Then pop out larger
    ]).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeInOut));

    // 2. Hover Controller for "Floating" effect
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _hoverAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOutSine),
    );

    // Logic to switch content halfway through flip
    _mainController.addListener(() {
      if (_mainController.value >= 0.5 && !_showBack) {
        setState(() {
          _showBack = true;
        });
      }
    });

    // Start animation automatically
    Future.delayed(const Duration(milliseconds: 300), () {
      _mainController.forward();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // [FIXED] Matches Home Screen modal darkness (Colors.black87)
      backgroundColor: Colors.black87, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header Text
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _showBack ? 1.0 : 0.0,
              child: const Text(
                "GOLD STATUS UNLOCKED!",
                style: TextStyle(
                  color: Color(0xFFFFD700), 
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 2
                ),
              ),
            ),
            
            const SizedBox(height: 40),

            // THE ANIMATED CARD
            AnimatedBuilder(
              animation: Listenable.merge([_mainController, _hoverController]),
              builder: (context, child) {
                double angle = _flipAnimation.value * pi;
                
                // 3D Transform Matrix
                final transform = Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective
                  ..rotateY(angle);

                return Transform.translate(
                  // Apply floating hover only when flipped
                  offset: Offset(0, _showBack ? _hoverAnimation.value : 0), 
                  child: Transform.scale(
                    scale: _scaleAnimation.value, // Apply extending scale
                    child: Transform(
                      transform: transform,
                      alignment: Alignment.center,
                      child: _showBack 
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(pi), // Correct mirror text
                            child: _buildGoldParchiCard(), // [NEW] No Tap logic here
                          )
                        : _buildFrontRewardCard(),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 60),

            // Continue Button
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _showBack ? 1.0 : 0.0,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Tap to Continue", 
                  style: TextStyle(color: Colors.white54, fontSize: 14)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CARD FACES ---

  Widget _buildFrontRewardCard() {
    return Container(
      height: 180,
      width: MediaQuery.of(context).size.width - 48, // Match Notification Card width
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDAA520), Color(0xFFFFD700)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.8),
            blurRadius: 30,
            spreadRadius: 5,
          )
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard, size: 60, color: Colors.white),
            SizedBox(height: 10),
            Text(
              "UNLOCKING...", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoldParchiCard() {
    // We build the Parchi Card manually here using 'CardFrontContent'
    // This ensures it looks exactly like the ParchiCard but WITHOUT the GestureDetector
    
    const goldGradient = LinearGradient(
      colors: [
        Color(0xFFDAA520), // Goldenrod
        Color(0xFFFFD700), // Gold
        Color(0xFFB8860B), // Dark Goldenrod
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: [0.1, 0.5, 0.9],
    );

    return Container(
      height: 180,
      width: MediaQuery.of(context).size.width - 48,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: goldGradient,
        borderRadius: BorderRadius.circular(24), // Match bonus card radius
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.6),
            blurRadius: 40, // Intense Gold Glow
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: CardFrontContent(
        studentName: widget.studentName,
        studentId: widget.studentId,
        isGolden: true, // Triggers gold text styles
      ),
    );
  }
}