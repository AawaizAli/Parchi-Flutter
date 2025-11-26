import 'package:flutter/material.dart';
import 'dart:math';
import '../../utils/colours.dart';
import '../../widgets/home_screen_parchicard_widgets/parchi_card.dart';
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

class _GoldUnlockScreenState extends State<GoldUnlockScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showBack = false; // False = Reward Card, True = Parchi Card

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Slow, dramatic flip
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    _controller.addListener(() {
      // Switch content halfway through flip
      if (_controller.value >= 0.5 && !_showBack) {
        setState(() {
          _showBack = true;
        });
      }
    });

    // Auto start
    Future.delayed(const Duration(milliseconds: 500), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _showBack ? 1.0 : 0.0,
              child: const Text(
                "GOLD STATUS UNLOCKED!",
                style: TextStyle(color: Color(0xFFFFD700), fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            ),
            
            const SizedBox(height: 40),

            // THE FLIPPING CARD
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                double angle = _animation.value * pi;
                
                final transform = Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective
                  ..rotateY(angle);

                return Transform(
                  transform: transform,
                  alignment: Alignment.center,
                  child: _showBack 
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(pi), // Fix mirror image
                        child: ParchiCard(
                          studentName: widget.studentName,
                          studentId: widget.studentId,
                          isGolden: true, // [GOLD MODE]
                        ),
                      )
                    : _buildFrontRewardCard(),
                );
              },
            ),

            const SizedBox(height: 40),

            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _showBack ? 1.0 : 0.0,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Continue", style: TextStyle(color: Colors.white70)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrontRewardCard() {
    return Container(
      height: 180,
      width: MediaQuery.of(context).size.width - 32,
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
            Icon(Icons.card_giftcard, size: 60, color: Colors.white),
            SizedBox(height: 10),
            Text("UNLOCKING...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }
}