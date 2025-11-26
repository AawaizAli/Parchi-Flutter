import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // [NEW]
import 'package:parchi_student_app/screens/auth/sign_up_screens/signup_screen_one.dart';
import '../../../utils/colours.dart';
import '../../../main.dart';
import '../../../services/auth_service.dart';
import '../../../providers/user_provider.dart'; // [NEW]

// [CHANGED] Use ConsumerStatefulWidget
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Animation variables
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
   
  @override
  void initState() {
    super.initState();
    
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
      // 1. Perform Login API Call
      await authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // 2. [CRITICAL FIX] Force refresh the User Provider
        // This fetches the full profile (Name, Uni, ID) from the backend /me endpoint
        // and updates the state so HomeScreen shows data immediately.
        await ref.read(userProfileProvider.notifier).refresh();

        // 3. Validate Role & Active Status (Double check via provider or service)
        final user = ref.read(userProfileProvider).value;
        
        if (user == null) {
           throw Exception("Failed to load user profile.");
        }

        if (user.role.toLowerCase() != 'student') {
          await authService.logout();
          ref.read(userProfileProvider.notifier).clearUser(); // Clear state
          throw Exception("Access denied. Students only.");
        }

        if (!user.isActive) {
           // Show pending message but let them in (or block them based on your requirement)
           if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Account pending approval. Functionality may be limited."),
                backgroundColor: Colors.orange,
              ),
            );
           }
        }

        // 4. Navigate to Main Screen
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });

      if (mounted) {
        // Check specifically for Pending Account error from backend
        if (e.toString().toLowerCase().contains('pending')) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Your account is pending approval. Verification takes 24-48 hours."),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage ?? 'Login failed. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
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
          // --- 1. BACKGROUND ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0B1021), 
                  Color(0xFF1B2845), 
                  Color(0xFF274060), 
                ],
              ),
            ),
          ),

          // --- 2. LOGO & TEXT ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.45, 
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.8),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: _glowAnimation.value * 2,
                              spreadRadius: _glowAnimation.value,
                            ),
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
                  const Text(
                    "Parchi",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36, 
                      fontWeight: FontWeight.w900, 
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

          // --- 3. FORM SHEET ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              child: SizedBox(
                height: screenHeight * 0.5, 
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40), 
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min, 
                          children: [
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
                            
                            const SizedBox(height: 25), 

                            _buildAfluctaTextField(
                              controller: _emailController,
                              hint: "Enter your email",
                              icon: Icons.email_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter your email';
                                if (!value.contains('@') || !value.contains('.')) return 'Please enter a valid email';
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
                                if (value == null || value.isEmpty) return 'Please enter your password';
                                if (value.length < 6) return 'Password must be at least 6 characters';
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
                                        style: const TextStyle(color: AppColors.error, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const Spacer(),

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
                            const SizedBox(height: 10), 
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