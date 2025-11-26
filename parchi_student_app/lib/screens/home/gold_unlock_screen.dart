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
  // Controller for the initial "Reveal" animation
  late AnimationController _entranceController;
  late Animation<double> _entranceFlip;
  late Animation<double> _entranceScale;

  // Controller for the manual "Flip to see Reward" interaction
  late AnimationController _manualFlipController;
  late Animation<double> _manualFlipAnimation;

  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  bool _hasRevealed = false; // True once the initial reveal is done
  bool _showRewardSide = false; // False = ID Side, True = Reward Side

  @override
  void initState() {
    super.initState();

    // 1. Entrance Animation (Unlocking -> Gold ID)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _entranceFlip = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeInOutBack),
    );

    _entranceScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 50), 
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.0), weight: 50), 
    ]).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeInOut));

    // 2. Manual Flip Animation (Gold ID <-> Reward Detail)
    _manualFlipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _manualFlipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _manualFlipController, curve: Curves.easeInOutBack),
    );

    // 3. Hover (Breathing) Animation
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _hoverAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOutSine),
    );

    // Listeners to toggle content visibility
    _entranceController.addListener(() {
      if (_entranceController.value >= 0.5 && !_hasRevealed) {
        setState(() { _hasRevealed = true; });
      }
    });

    _manualFlipController.addListener(() {
      // If we are halfway through manual flip, toggle the view
      // We use a small threshold logic to ensure we don't flicker
      final val = _manualFlipController.value;
      if (val >= 0.5 && !_showRewardSide) {
        setState(() => _showRewardSide = true);
      } else if (val < 0.5 && _showRewardSide) {
        setState(() => _showRewardSide = false);
      }
    });

    // Start Entrance
    Future.delayed(const Duration(milliseconds: 300), () {
      _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _manualFlipController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Only allow flipping after entrance is done
    if (_entranceController.isCompleted) {
      if (_showRewardSide) {
        _manualFlipController.reverse(); // Go back to ID
      } else {
        _manualFlipController.forward(); // Go to Reward
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87, 
      body: GestureDetector(
        onTap: _handleTap, // Tap anywhere to flip
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dynamic Header Text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _showRewardSide ? "YOUR REWARD" : "GOLD STATUS UNLOCKED!",
                  key: ValueKey(_showRewardSide),
                  style: const TextStyle(
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
                animation: Listenable.merge([_entranceController, _manualFlipController, _hoverController]),
                builder: (context, child) {
                  // Combined rotation: Entrance Flip (0 to 180) + Manual Flip (0 to 180)
                  // Note: Entrance goes 0->1. Manual goes 0->1.
                  // We use entrance value initially. Once revealed, we add manual flip value.
                  
                  double angle;
                  double scale = _entranceScale.value;

                  if (!_entranceController.isCompleted) {
                    angle = _entranceFlip.value * pi; // 0 to 180
                  } else {
                    // Start from 180 (PI) and add manual flip
                    angle = pi + (_manualFlipAnimation.value * pi);
                  }
                  
                  // 3D Transform
                  final transform = Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // Perspective
                    ..rotateY(angle);

                  // Correct text orientation logic
                  // If angle is between 90 and 270, we are looking at the "Back" (ID)
                  // If angle > 270, we are looking at the "Front" (Reward) again?
                  // Let's simplify:
                  // Entrance: Front (Lock) -> Back (ID). Ends at 180.
                  // Manual: Starts at 180 (ID). Goes to 360 (Reward).
                  
                  bool showBackFace = angle >= (pi / 2) && angle < (3 * pi / 2); 
                  // Explanation:
                  // 0-90: Lock Card
                  // 90-270: Gold ID Card
                  // 270-360: Reward Detail Card

                  return Transform.translate(
                    offset: Offset(0, _hasRevealed ? _hoverAnimation.value : 0), 
                    child: Transform.scale(
                      scale: scale,
                      child: Transform(
                        transform: transform,
                        alignment: Alignment.center,
                        child: showBackFace 
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(pi), // Mirror fix for ID
                              child: _buildGoldParchiCard(),
                            )
                          : (_entranceController.isCompleted 
                              ? _buildGoldRewardDetailCard() // The "What I Won" Card
                              : _buildInitialLockCard()), // The "Unlocking" Card
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 60),

              // Hint Text
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _entranceController.isCompleted ? 1.0 : 0.0,
                child: const Text(
                  "Tap card to flip details", 
                  style: TextStyle(color: Colors.white38, fontSize: 12)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- CARD FACES ---

  // 1. Initial "Unlocking..." Card (Red/Gold)
  Widget _buildInitialLockCard() {
    return Container(
      height: 180,
      width: MediaQuery.of(context).size.width - 32, // [FIXED] Matches ParchiCard width
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDAA520), Color(0xFFFFD700)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
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
            Icon(Icons.lock_open_rounded, size: 60, color: Colors.white),
            SizedBox(height: 10),
            Text("UNLOCKING...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }

  // 2. The Gold ID Card (Front Face after unlock)
  Widget _buildGoldParchiCard() {
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
      width: MediaQuery.of(context).size.width - 32, // [FIXED] Width
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: goldGradient,
        borderRadius: BorderRadius.circular(20), // Match ParchiCard radius
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.6),
            blurRadius: 40, 
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: CardFrontContent(
        studentName: widget.studentName,
        studentId: widget.studentId,
        isGolden: true, 
      ),
    );
  }

  // 3. The "What I Won" Card (Back Face after tap)
  Widget _buildGoldRewardDetailCard() {
    // Same Gold Gradient to match texture
    const goldGradient = LinearGradient(
      colors: [
        Color(0xFFDAA520), 
        Color(0xFFFFD700), 
        Color(0xFFB8860B), 
      ],
      begin: Alignment.topRight, // Reversed slightly for visual difference
      end: Alignment.bottomLeft,
      stops: [0.1, 0.5, 0.9],
    );

    return Container(
      height: 180,
      width: MediaQuery.of(context).size.width - 32,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: goldGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.6),
            blurRadius: 40, 
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned(
            right: -30,
            bottom: -30,
            child: Icon(Icons.fastfood, size: 180, color: Colors.white.withOpacity(0.15)),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.star, color: Colors.black54, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "REWARD DETAILS",
                      style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ],
                ),
                Center(
                  child: Text(
                    widget.reward.discountText.toUpperCase(), // e.g. "FREE PREMIUM MEAL"
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black87, 
                      fontSize: 28, 
                      fontWeight: FontWeight.w900,
                      height: 1.1
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black26),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "CODE: ",
                        style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "GOLD-777",
                        style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Courier'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}