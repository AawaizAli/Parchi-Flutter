import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/colours.dart';
import 'widgets/login_form.dart';
import 'widgets/signup_form.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  
  // 0 = Login (Short Box), 1 = Signup (Tall Box)
  int _currentPage = 0; 

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.0, end: 25.0).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  // Logic to switch views and animate height
  void _toggleAuthMode() {
    if (_currentPage == 0) {
      // Go to Signup
      _pageController.animateToPage(1, duration: const Duration(milliseconds: 600), curve: Curves.easeInOutQuart);
      setState(() => _currentPage = 1);
    } else {
      // Go back to Login
      _pageController.animateToPage(0, duration: const Duration(milliseconds: 600), curve: Curves.easeInOutQuart);
      setState(() => _currentPage = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Dynamic Height Calculation
    // Login: ~55% of screen. Signup: ~85% of screen (Extends up).
    final double containerHeight = _currentPage == 0 ? screenHeight * 0.55 : screenHeight * 0.85;

    return Scaffold(
      resizeToAvoidBottomInset: true, 
      body: Stack(
        children: [
          // 1. BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0xFF0B1021), Color(0xFF1B2845), Color(0xFF274060)],
              ),
            ),
          ),

          // 2. LOGO & TEXT 
          // (Moves up and fades out when box expands to make room)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutQuart,
            top: _currentPage == 0 ? 0 : -150, // Move off screen when signing up
            left: 0, right: 0,
            height: screenHeight * 0.45,
            child: SafeArea(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: _currentPage == 0 ? 1.0 : 0.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (_, __) => Container(
                        height: 80, width: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary, borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: AppColors.primary.withOpacity(0.8), blurRadius: 15),
                            BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: _glowAnimation.value * 2),
                          ],
                        ),
                        child: const Icon(Icons.school, size: 40, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Parchi", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
          ),

          // 3. THE EXPANDING WHITE CONTAINER
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutQuart,
            bottom: 0, left: 0, right: 0,
            height: containerHeight, // [ANIMATED HEIGHT]
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, -5))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // Disable swipe, force button usage
                  children: [
                    // PAGE 0: LOGIN
                    LoginForm(onSignupTap: _toggleAuthMode),
                    
                    // PAGE 1: SIGNUP
                    SignupForm(onLoginTap: _toggleAuthMode),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}