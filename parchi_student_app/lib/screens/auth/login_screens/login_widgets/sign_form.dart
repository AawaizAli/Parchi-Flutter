import 'package:flutter/material.dart';
import '../../../../utils/colours.dart';
import '../../sign_up_screens/signup_screen_two.dart'; // We still navigate to upload screen

class SignupForm extends StatefulWidget {
  final VoidCallback onLoginTap;

  const SignupForm({super.key, required this.onLoginTap});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedUniversity;
  bool _isPasswordVisible = false;
  
  final List<String> _universities = ["FAST NUCES", "IBA Karachi", "LUMS", "NUST", "Karachi University", "Szabist"];

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      if (_selectedUniversity == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Select University"), backgroundColor: Colors.red));
        return;
      }
      
      // Navigate to the Image Upload screen (Phase 2)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SignupScreenTwo(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            phone: _phoneController.text.trim(),
            university: _selectedUniversity!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Switch Back to Login
            Row(
              children: [
                GestureDetector(
                  onTap: widget.onLoginTap, // Shrinks the box back down
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
                  ),
                ),
                const SizedBox(width: 16),
                const Text("Create Account", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),

            // Fields (Using Login Style Consistency)
            _buildTextField(_firstNameController, "First Name", Icons.person_outline),
            const SizedBox(height: 12),
            _buildTextField(_lastNameController, "Last Name", Icons.person_outline),
            const SizedBox(height: 12),
            _buildTextField(_emailController, "Student Email", Icons.email_outlined),
            const SizedBox(height: 12),
            _buildTextField(_passwordController, "Password", Icons.lock_outline, isPassword: true),
            const SizedBox(height: 12),
            _buildTextField(_confirmPasswordController, "Confirm Password", Icons.lock_outline, isPassword: true),
            const SizedBox(height: 12),
            _buildTextField(_phoneController, "Phone (Optional)", Icons.phone_outlined, isNumber: true),
            const SizedBox(height: 12),
            _buildUniversityDropdown(),

            const SizedBox(height: 30),

            // Signup Button (Matched to Login Button Style)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handleNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Matching Login Button
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Next Step", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reused Helper from Login Form for consistency
  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false, bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
      child: TextFormField(
        controller: controller, 
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        validator: (val) {
          if (isNumber) return null; // Optional
          if (val == null || val.isEmpty) return "Required";
          if (isPassword && val.length < 6) return "Min 6 chars";
          return null;
        },
        decoration: InputDecoration(
          hintText: hint, prefixIcon: Icon(icon, color: Colors.grey.shade600),
          suffixIcon: isPassword 
            ? IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)) 
            : null,
          border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildUniversityDropdown() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedUniversity,
          hint: const Text("Select University", style: TextStyle(color: Colors.grey)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
          items: _universities.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
          onChanged: (v) => setState(() => _selectedUniversity = v),
        ),
      ),
    );
  }
}