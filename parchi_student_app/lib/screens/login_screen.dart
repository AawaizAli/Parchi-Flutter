import 'package:flutter/material.dart';
import '../utils/colours.dart';
import '../main.dart';
import 'signup_screen_one.dart';
import 'dart:math' as math;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  // Logo Glow Animation
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
   
  @override
  void initState() {
    super.initState();
    
    // 1. Logo Pulse (Originating from Logo)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.0, end: 25.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_emailController.text == 'email' && _passwordController.text == '123') {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const MainScreen())
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid credentials. Use email: 'email', pass: '123'")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // --- 1. STATIC BACKGROUND (No Breathing) ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0B1021), // Very Dark Blue/Black
                  Color(0xFF1B2845), // Deep Space Blue
                  Color(0xFF274060), // Lighter Blue near horizon
                ],
              ),
            ),
          ),

          // --- 2. TOP SECTION: LOGO & TEXT ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.45, // Slightly adjusted top space since bottom is smaller
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Parchi Logo with STRONG RIPPLE PULSE
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        height: 80, 
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary, 
                          borderRadius: BorderRadius.circular(20), 
                          boxShadow: [
                            // Core Glow
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.8),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                            // Ripple 1 (Expands with animation)
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: _glowAnimation.value * 2,
                              spreadRadius: _glowAnimation.value,
                            ),
                            // Ripple 2 (Expands wider)
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.1),
                              blurRadius: _glowAnimation.value * 4,
                              spreadRadius: _glowAnimation.value * 3,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.school, size: 40, color: Colors.white),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 30), 
                  
                  // CHANGED: Text from "Let's get you signed in!" to "Parchi"
                  const Text(
                    "Parchi",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36, // Increased size slightly for brand impact
                      fontWeight: FontWeight.w900, // Extra bold
                      height: 1.2,
                      shadows: [
                        Shadow(
                          blurRadius: 15.0,
                          color: Colors.black,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- 3. BOTTOM SECTION: FLOATING WHITE SHEET ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              child: SizedBox(
                // CHANGED: Reduced height from 0.68 to 0.5 (50% of screen)
                height: screenHeight * 0.5, 
                child: Stack(
                  children: [
                    // White Background Container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40), 
                      ),
                    ),
                    
                    // Form Content
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Ensures content doesn't stretch weirdly
                        children: [
                          // Sign Up Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "You don't have an account yet? ",
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => const SignupScreenOne(),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        const begin = Offset(0.0, 1.0);
                                        const end = Offset.zero;
                                        const curve = Curves.easeInOut;
                                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: AppColors.textLink,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 25), // Adjusted spacing

                          _buildAfluctaTextField(
                            controller: _emailController,
                            hint: "Enter your email",
                            icon: Icons.email_outlined,
                          ),
                          
                          const SizedBox(height: 16),

                          _buildAfluctaTextField(
                            controller: _passwordController,
                            hint: "Enter your password",
                            icon: Icons.lock_outline,
                            isPassword: true,
                            isPasswordVisible: _isPasswordVisible,
                            onVisibilityToggle: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),

                          const SizedBox(height: 12),

                          const Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Forgot password?",
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),

                          const Spacer(),

                          // STANDARD PILL BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black, 
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 5,
                              ),
                              child: const Text(
                                "Sign In",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10), // Small bottom padding
                        ],
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

  Widget _buildAfluctaTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        // CHANGED: Made color darker (shade200) so it looks gray against white
        color: Colors.grey.shade200, 
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }
}