import 'dart:ui'; // Required for the Blur effect
import 'package:flutter/material.dart';
import '../../../utils/colours.dart';
import '../../../services/auth_service.dart';

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  // --- STATIC HELPER TO SHOW THE SHEET ---
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows sheet to go full height if needed
      backgroundColor: Colors.transparent, // Transparent so we can see the blur
      barrierColor: Colors.black.withOpacity(0.2), // Slight dimming behind
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 600), // Slower, smoother animation like Login
      ),
      builder: (context) => const ChangePasswordSheet(),
    );
  }

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
        Navigator.pop(context); // Close the sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
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
    // This padding ensures the sheet content moves up when the keyboard opens
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // --- THE BLUR EFFECT ---
      child: Container(
        height: screenHeight * 0.85, // Takes up 85% of the screen like Signup
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)), // Rounded top like Login
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // --- HEADER WITH CLOSE BUTTON ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 20, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Change Password",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            // --- FORM CONTENT ---
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPadding + 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      // Info Text
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.security, color: AppColors.primary, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "To secure your account, please verify your current password.",
                                style: TextStyle(
                                  color: AppColors.textPrimary.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Current Password
                      _buildLabel("Current Password"),
                      _buildTextField(
                        controller: _currentPasswordController,
                        hint: "Enter current password",
                        isPassword: true,
                        isVisible: !_obscureCurrent,
                        onVisibilityToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                      ),
                      const SizedBox(height: 20),

                      // New Password
                      _buildLabel("New Password"),
                      _buildTextField(
                        controller: _newPasswordController,
                        hint: "Enter new password",
                        isPassword: true,
                        isVisible: !_obscureNew,
                        onVisibilityToggle: () => setState(() => _obscureNew = !_obscureNew),
                        validator: (val) {
                          if (val == null || val.length < 6) return "Min 6 characters";
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Confirm Password
                      _buildLabel("Confirm New Password"),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        hint: "Re-enter new password",
                        isPassword: true,
                        isVisible: !_obscureConfirm,
                        onVisibilityToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (val) {
                          if (val != _newPasswordController.text) return "Passwords do not match";
                          return null;
                        },
                      ),

                      const SizedBox(height: 40),

                      // Submit Button (Black, Rounded - Matches Login)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleChangePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Update Password",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
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
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  // --- TEXT FIELD STYLE MATCHING LOGIN FORM ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onVisibilityToggle,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Light grey background like Login
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !isVisible,
        validator: validator ?? (val) => val!.isEmpty ? "Required" : null,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }
}