import 'package:flutter/material.dart';
import 'dart:math';
import '../../../utils/colours.dart';
import '../../../widgets/home_screen_widgets/bonus_reward_card.dart'; 

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
  // Controller for the card "expanding" entrance (Pop effect)
  late AnimationController _entranceController;
  late Animation<double> _expandAnimation;
  
  // Controller for the "Running Border" effect
  late AnimationController _borderController;

  // Controller for background radiation pulse
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    // 1. Entrance Animation (Smooth Pop with Overshoot)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // easeOutBack gives a professional "pop" expansion
    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );

    _entranceController.forward();

    // 2. Running "Sprint" Border Animation
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // 3. Background Radiation Pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _borderController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85), 
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // [LAYER 1] Background Golden Radiation (Breathing Glow)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: MediaQuery.of(context).size.width * 1.2,
                  height: MediaQuery.of(context).size.width * 1.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFFD700).withOpacity(0.3 + (_pulseController.value * 0.1)), // Pulse opacity
                        Colors.transparent
                      ],
                      stops: const [0.0, 0.7],
                    ),
                  ),
                );
              },
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "ALMOST THERE!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFFD700), 
                    fontSize: 24, 
                    fontWeight: FontWeight.w900, 
                    letterSpacing: 4,
                    shadows: [
                      Shadow(color: Colors.orangeAccent, blurRadius: 20)
                    ],
                    decoration: TextDecoration.none,
                  ),
                ),
                
                const SizedBox(height: 50),

                // [LAYER 2] The Golden Card with Expanding Entrance
                Hero(
                  tag: 'reward_${widget.reward.restaurantName}', 
                  child: Material(
                    color: Colors.transparent,
                    child: ScaleTransition(
                      scale: _expandAnimation,
                      child: _buildGoldParchiCard(),
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    "Tap anywhere to close", 
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5), 
                      fontSize: 12, 
                      letterSpacing: 1.0,
                      decoration: TextDecoration.none
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoldParchiCard() {
    return AnimatedBuilder(
      animation: _borderController,
      builder: (context, child) {
        return Container(
          height: 240, // Expanded height
          width: MediaQuery.of(context).size.width - 60,
          
          // [SPRINT BORDER]
          padding: const EdgeInsets.all(4), // Thicker border for emphasis
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: SweepGradient(
              center: Alignment.center,
              colors: [
                const Color(0xFFB8860B), // Dark Gold
                const Color(0xFFFFD700), // Gold Sprint Head
                Colors.white,            // Brightest Point
                const Color(0xFFFFD700), // Gold Trail
                const Color(0xFFB8860B), // Dark Gold
              ],
              stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
              transform: GradientRotation(_borderController.value * 2 * pi),
            ),
            boxShadow: [
              // Deep shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30, 
                offset: const Offset(0, 15),
              ),
              // Gold Radiation
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.3),
                blurRadius: 40, 
                spreadRadius: 5,
              ),
            ],
          ),
          child: Container(
            // [CARD FACE] Golden Gradient Background (Requested)
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFDAA520), // Goldenrod
                  Color(0xFFFFD700), // Gold
                  Color(0xFFFDB931), // Light Gold
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Decorative Pattern (Subtle overlay)
                Positioned(
                  right: -30,
                  bottom: -30,
                  child: Icon(Icons.star, size: 180, color: Colors.white.withOpacity(0.2)),
                ),
                
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon Container (White/Gold contrast)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.lock_open_rounded, size: 40, color: Color(0xFFDAA520)),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Main Text (White/Dark for readability on Gold)
                      const Text(
                        "Avail 1 more",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900, 
                          height: 1.1,
                          shadows: [
                            Shadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 1))
                          ],
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "to get this meal",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: 22,
                          fontWeight: FontWeight.w700, 
                          letterSpacing: 0.5,
                          height: 1.1,
                          shadows: [
                            Shadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 1))
                          ],
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}