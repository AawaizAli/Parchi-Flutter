import 'package:flutter/material.dart';
import '../../../utils/colours.dart';
import '../../../main.dart';
import '../../../services/auth_service.dart';
import '../sign_up_screens/signup_screen_one.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

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
    _emailController.dispose();
    _passwordController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // Check user role - only students can access the student app
        final user = await authService.getUser();
        if (user == null) {
          setState(() {
            _errorMessage = 'Failed to retrieve user information. Please try again.';
            _isLoading = false;
          });
          return;
        }

        // Validate that user is a student
        if (user.role.toLowerCase() != 'student') {
          // Logout the user since they're not a student
          await authService.logout();
          setState(() {
            _errorMessage = 'Access denied. This app is only for students. Please use the merchant app.';
            _isLoading = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Access denied. This app is only for students.'),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 4),
              ),
            );
          }
          return;
        }

        // Check if account is active
        if (!user.isActive) {
          // Account pending approval
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Your account is pending approval. Please wait for admin approval."),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 4),
              ),
            );
            // Still navigate but user might have limited access
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          }
        } else {
          // Account is active and user is a student, proceed to main screen
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Login failed. Please try again.'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                      child: Form(
                        key: _formKey,
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@') || !value.contains('.')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
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

                            // Error message display
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: AppColors.error, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: TextStyle(
                                          color: AppColors.error,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const Spacer(),

                            // STANDARD PILL BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  disabledBackgroundColor: Colors.grey.shade400,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 5,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
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
    String? Function(String?)? validator,
  }) {
    return Container(
      height: validator != null ? null : 56,
      decoration: BoxDecoration(
        // CHANGED: Made color darker (shade200) so it looks gray against white
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        style: const TextStyle(color: AppColors.textPrimary),
        validator: validator,
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          errorStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}