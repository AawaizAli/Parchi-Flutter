import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utils/colours.dart';
import '../login_screens/login_screen.dart';

class SignupVerificationScreen extends StatefulWidget {
  final String? parchiId;
  final String? email;

  const SignupVerificationScreen({
    super.key,
    this.parchiId,
    this.email,
  });

  @override
  State<SignupVerificationScreen> createState() =>
      _SignupVerificationScreenState();
}

class _SignupVerificationScreenState extends State<SignupVerificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final containerHeight = screenHeight * 0.75; // Same as SignupScreenTwo

    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND (Solid Primary)
          Container(
            color: AppColors.primary,
          ),

          // 2. LOGO (Positioned at top)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutQuart,
            top: -screenHeight * 0.10, // Moves up same as SignupScreenTwo
            left: 0, right: 0,
            height: screenHeight * 0.45,
            child: SafeArea(
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: SvgPicture.asset(
                    'assets/ParchiFullTextYellow.svg',
                    colorFilter: const ColorFilter.mode(
                        Color(0xFFE3E935), BlendMode.srcIn),
                  ),
                ),
              ),
            ),
          ),

          // 3. WHITE CONTAINER (Floating)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutQuart,
            bottom: 0, left: 0, right: 0,
            height: containerHeight,
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
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
                child: Column(
                  children: [
                    // --- HEADER ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                      child: Row(
                        children: [
                          const SizedBox(width: 8), // Spacer since no back button or maybe home button
                          const Text("Verification",
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    ),

                    // --- CONTENT ---
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                             const SizedBox(height: 20),

                            // Animated Tick
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                height: 140,
                                width: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.surface,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppColors.primary.withOpacity(0.15),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.check_circle_rounded,
                                    size: 90,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            const Text(
                              "You're all set!",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Your documents have been submitted.\nVerification usually takes 24-48 hours.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary.withOpacity(0.8),
                                height: 1.5,
                              ),
                            ),

                            if (widget.parchiId != null) ...[
                              const SizedBox(height: 32),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      "YOUR PARCHI ID",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.parchiId!,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 40),

                            // Back to Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen()),
                                    (route) => false,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  "Back to Login",
                                  style: TextStyle(
                                    color: AppColors.textOnPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
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
