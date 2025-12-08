import 'package:flutter/material.dart';
import '../../../utils/colours.dart';
import '../../../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  
  // Animation for the white div sliding up
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Setup entrance animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await authService.changePassword(
        currentPassword: _currentPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );

      if (mounted) {
        // Success Dialog using your app's style
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Success"),
            content: const Text("Your password has been updated successfully."),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pop(context); // Close screen
                },
                child: const Text("OK", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // Allow resizing when keyboard opens so fields are visible
      resizeToAvoidBottomInset: true, 
      body: Stack(
        children: [
          // 1. DARK GRADIENT BACKGROUND (Matches Login)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0B1021), Color(0xFF1B2845), Color(0xFF274060)],
              ),
            ),
          ),

          // 2. HEADER CONTENT (Back Button & Title)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1), 
                            shape: BoxShape.circle
                          ),
                          child: const Icon(Icons.arrow_downward, color: Colors.white, size: 24),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        "Change Password",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. THE WHITE DIV (Matches Login Style)
          // We use SizeTransition/SlideTransition to make it pop up
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Positioned(
                // Position it at the bottom, taking up ~75% of screen
                top: screenHeight * (1 - (0.75 * _slideAnimation.value)), 
                bottom: 0, 
                left: 0, 
                right: 0,
                child: child!,
              );
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3), 
                    blurRadius: 30, 
                    offset: const Offset(0, -10)
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Scaffold(
                  backgroundColor: Colors.transparent, // Important for inner content
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40, height: 4,
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300, 
                                borderRadius: BorderRadius.circular(2)
                              ),
                            ),
                          ),
                          
                          const Text(
                            "Secure your account",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Enter your current password and a strong new password.",
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 30),

                          // --- FORM FIELDS (Light Style) ---
                          _buildTextField(
                            controller: _currentPasswordController,
                            label: "Current Password",
                            hint: "Enter current password",
                            isPassword: true,
                            isVisible: !_obscureCurrentPassword,
                            onVisibilityToggle: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: _newPasswordController,
                            label: "New Password",
                            hint: "Enter new password",
                            isPassword: true,
                            isVisible: !_obscureNewPassword,
                            onVisibilityToggle: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _confirmPasswordController,
                            label: "Confirm Password",
                            hint: "Re-enter new password",
                            isPassword: true,
                            isVisible: !_obscureConfirmPassword,
                            onVisibilityToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            validator: (val) {
                              if (val != _newPasswordController.text) return "Passwords do not match";
                              return null;
                            }
                          ),

                          const SizedBox(height: 40),

                          // --- SUBMIT BUTTON ---
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleChangePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      "Update Password",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                            ),
                          ),
                          // Extra padding for scrollability
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget matching Login Field Style
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onVisibilityToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword && !isVisible,
            validator: validator ?? (val) {
              if (val == null || val.isEmpty) return "Required";
              if (val.length < 6) return "Min 6 characters";
              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                      onPressed: onVisibilityToggle,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}