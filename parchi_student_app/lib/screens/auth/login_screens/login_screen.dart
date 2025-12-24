import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/colours.dart';
import '../../../widgets/login_screen/login_form.dart';
import '../../../widgets/signup_screen/sign_form.dart';
import 'forgot_password/forgot_password_form.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  // Initialize PageController to start at index 1 (Login)
  // This places ForgotPassword at 0 (Left) and Signup at 2 (Right)
  final PageController _pageController = PageController(initialPage: 1);

  // 0 = Forgot Password, 1 = Login, 2 = Signup
  int _currentPage = 1;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.0, end: 25.0).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  // Switch to Signup (Index 2)
  void _goToSignup() {
    _pageController.animateToPage(2,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutQuart);
    setState(() => _currentPage = 2);
  }

  // Switch to Login (Index 1)
  void _goToLogin() {
    _pageController.animateToPage(1,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutQuart);
    setState(() => _currentPage = 1);
  }

  // Switch to Forgot Password (Index 0)
  void _goToForgotPassword() {
    _pageController.animateToPage(0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutQuart);
    setState(() => _currentPage = 0);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Dynamic Height Calculation
    // Login (1): 55%
    // Signup (2): 85% (Needs more space)
    // Forgot Password (0): 55% (Similar to login)
    double containerHeight;
    if (_currentPage == 2) {
      containerHeight = screenHeight * 0.85;
    } else {
      containerHeight = screenHeight * 0.55;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.authGradientStart,
                  AppColors.authGradientMid,
                  AppColors.authGradientEnd
                ],
              ),
            ),
          ),

          // 2. LOGO & TEXT
          // Moves up and fades out ONLY when signing up (index 2).
          // Stays visible for Login (1) and Forgot Password (0).
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutQuart,
            top:
                _currentPage == 2 ? -150 : 0, // Move off screen only for Signup
            left: 0, right: 0,
            height: screenHeight * 0.45,
            child: SafeArea(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity:
                    _currentPage == 2 ? 0.0 : 1.0, // Fade out only for Signup
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (_, __) => Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.primary.withOpacity(0.8),
                                blurRadius: 15),
                            BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: _glowAnimation.value * 2),
                          ],
                        ),
                        child: const Icon(Icons.school,
                            size: 40, color: AppColors.textOnPrimary),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Parchi",
                        style: TextStyle(
                            color: AppColors.textOnPrimary,
                            fontSize: 36,
                            fontWeight: FontWeight.w900)),
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
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, -5))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: PageView(
                  controller: _pageController,
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable swipe
                  children: [
                    // PAGE 0: FORGOT PASSWORD
                    ForgotPasswordForm(onBackTap: _goToLogin),

                    // PAGE 1: LOGIN
                    LoginForm(
                      onSignupTap: _goToSignup,
                      onForgotTap: _goToForgotPassword,
                    ),

                    // PAGE 2: SIGNUP
                    SignupForm(onLoginTap: _goToLogin),
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
