import 'package:flutter/material.dart';
import 'dart:math';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Section 1: Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: "Search restaurants...",
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_none, color: Colors.black),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Section 2: Parchi ID Card (Clickable)
          const SliverToBoxAdapter(
            child: ParchiCard(),
          ),

          // Section 3: Restaurants Header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                "All Restaurants",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Section 4: Restaurants Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return const RestaurantMiniCard();
                },
                childCount: 12,
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

// =========================================================
// PARCHI CARD WIDGET (Entry Point)
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
                  colors: [Color(0xFF0D1B59), Color(0xFFE91E63)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
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
// DETAILED POPUP VIEW (Flip + Hover)
// =========================================================

class ParchiCardDetail extends StatefulWidget {
  const ParchiCardDetail({super.key});

  @override
  State<ParchiCardDetail> createState() => _ParchiCardDetailState();
}

class _ParchiCardDetailState extends State<ParchiCardDetail> with TickerProviderStateMixin {
  // Controller for the FLIP
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  // Controller for the HOVER (Float)
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  bool _isFront = true;

  @override
  void initState() {
    super.initState();

    // 1. Setup FLIP Animation
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOutBack,
    ));

    // 2. Setup HOVER Animation (Continuous Loop)
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Slow, breathing movement
    )..repeat(reverse: true); // Moves up, then reverses down

    _hoverAnimation = Tween<double>(begin: -10, end: 10).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOutSine, // Smooth sine wave
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

  @override
  void dispose() {
    _flipController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: GestureDetector(
            onTap: () {
              // Trigger Flip on Card Tap
              _flipCard(); 
            },
            // merge: Listen to both Flip and Hover animations
            child: AnimatedBuilder(
              animation: Listenable.merge([_flipAnimation, _hoverAnimation]),
              builder: (context, child) {
                
                // 1. Calculate Flip Rotation
                final angle = _flipAnimation.value * pi;
                final flipTransform = Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective
                  ..rotateY(angle);

                // 2. Wrap everything in a Translation for the Hover effect
                return Transform.translate(
                  offset: Offset(0, _hoverAnimation.value), // Move Up/Down
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

  // --- FRONT FACE ---
  Widget _buildFrontFace() {
    return Container(
      height: 220,
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1B59), Color(0xFFE91E63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          // Dynamic Shadow that pulses with the hover could be added here, 
          // but a static large glow works best for performance/visuals.
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.6),
            blurRadius: 40,
            spreadRadius: 10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const CardFrontContent(),
    );
  }

  // --- BACK FACE ---
  Widget _buildBackFace() {
    return Container(
      height: 220,
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFE91E63).withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.3),
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
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 8,
                    ),
                  ),
                  const SizedBox(
                    height: 100,
                    width: 100,
                    child: CircularProgressIndicator(
                      value: 0.75,
                      color: Color(0xFFE91E63),
                      strokeCap: StrokeCap.round,
                      strokeWidth: 8,
                    ),
                  ),
                   const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "15",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Used",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
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
                  Text("MONTHLY STATS", style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                  Divider(color: Colors.white24),
                  SizedBox(height: 5),
                  Text("Discounts: 15/20", style: TextStyle(color: Colors.white, fontSize: 16)),
                  SizedBox(height: 5),
                  Text("Total Saved:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text("PKR 4,500", style: TextStyle(color: Color(0xFF00E676), fontSize: 20, fontWeight: FontWeight.bold)),
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
// REUSABLE CARD CONTENT (FRONT)
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
          child: Icon(Icons.school, size: 150, color: Colors.white.withOpacity(0.1)),
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
                  const Icon(Icons.nfc, color: Colors.white, size: 30),
                  Text(
                    "PARCHI STUDENT",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "AAWAIZ ALI",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "ID: PK-12345",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.bold,
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

class RestaurantMiniCard extends StatelessWidget {
  const RestaurantMiniCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: NetworkImage("https://placehold.co/100x100/png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "KFC",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const Text(
          "20% OFF",
          style: TextStyle(fontSize: 10, color: Color(0xFFE91E63), fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}