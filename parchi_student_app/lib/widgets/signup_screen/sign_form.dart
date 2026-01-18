import 'package:flutter/material.dart';
import '../../utils/colours.dart';
import '../common/spinning_loader.dart';
import '../../screens/auth/sign_up_screens/signup_screen_two.dart'; 

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
  final _cnicController = TextEditingController(); // NEW
  final _dobController = TextEditingController(); // NEW
  String? _selectedUniversity;
  DateTime? _selectedDate; // NEW
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _universities = [
    "FAST NUCES",
    "IBA Karachi",
    "LUMS",
    "NUST",
    "Karachi University",
    "Szabist"
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _cnicController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Default to 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
         return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary, // Header background color
              onPrimary: AppColors.textOnPrimary, // Header text color
              onSurface: AppColors.textPrimary, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = "${picked.toLocal()}".split(' ')[0]; // yyyy-mm-dd
      });
    }
  }

  Future<void> _handleNext() async {
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _phoneController.text.trim().isEmpty || // Phone is now mandatory
        _cnicController.text.trim().isEmpty || // CNIC mandatory
        _dobController.text.isEmpty || // DOB mandatory
        _selectedUniversity == null) {
      setState(() => _errorMessage = "Please Fill Out All The Fields");
      return;
    }

    // CNIC Validation (Example: 13 digits)
    if (_cnicController.text.trim().length != 13) {
       setState(() => _errorMessage = "CNIC must be 13 digits");
       return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = "Passwords Don't Match");
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null; 
      });
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SignupScreenTwo(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            phone: _phoneController.text.trim(),
            university: _selectedUniversity!,
            cnic: _cnicController.text.trim(),
            dateOfBirth: _dobController.text.trim(),
          ),
        ),
      );

      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              const SizedBox(height: 20),

              Row(
                children: [
                  GestureDetector(
                    onTap: widget.onLoginTap, 
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(0.1),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back,
                          color: AppColors.textPrimary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text("Create Account",
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),

              _buildTextField(_firstNameController, "First Name",
                  Icons.person_outline, action: TextInputAction.next),
              const SizedBox(height: 12),
              _buildTextField(
                  _lastNameController, "Last Name", Icons.person_outline, action: TextInputAction.next),
              const SizedBox(height: 12),
              _buildTextField(_emailController, "Student Email",
                  Icons.email_outlined, action: TextInputAction.next),
              const SizedBox(height: 12),
              _buildTextField(_passwordController, "Password",
                  Icons.lock_outline,
                  isPassword: true, action: TextInputAction.next),
              const SizedBox(height: 12),
              _buildTextField(_confirmPasswordController,
                  "Confirm Password", Icons.lock_outline,
                  isPassword: true, action: TextInputAction.next),
              const SizedBox(height: 12),
              // Phone (Mandatory)
              _buildTextField(_phoneController, "Phone Number",
                  Icons.phone_outlined,
                  isNumber: true, action: TextInputAction.next),
              const SizedBox(height: 12),
               // CNIC (Mandatory)
              _buildTextField(_cnicController, "CNIC (13 digits)",
                  Icons.credit_card,
                  isNumber: true, maxLength: 13, action: TextInputAction.next),
              const SizedBox(height: 12),
              // Date of Birth (Mandatory)
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: _buildTextField(_dobController, "Date of Birth",
                      Icons.calendar_today,
                      isReadOnly: true, action: TextInputAction.done),
                ),
              ),
              const SizedBox(height: 12),
              _buildUniversityDropdown(),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(_errorMessage!,
                    style: const TextStyle(
                        color: AppColors.error, fontSize: 12)),
              ],

              const SizedBox(height: 18),

              // Signup Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? const SpinningLoader(size: 30)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Next Step",
                                style: TextStyle(
                                    color: AppColors.textOnPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward,
                                color: AppColors.textOnPrimary, size: 20),
                          ],
                        ),
                ),
              ),
              // Bottom padding for the form itself
              const SizedBox(height: 24), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool isPassword = false, bool isNumber = false, int? maxLength, bool isReadOnly = false, TextInputAction action = TextInputAction.done}) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.textSecondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16)),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        textInputAction: action, // Controls keyboard return key
        readOnly: isReadOnly,
        maxLength: maxLength,
        onTap: isReadOnly ? () => _selectDate(context) : null,
        validator: (val) {
          if (isReadOnly) return null; // Date picker handled separately
          if (val == null || val.isEmpty) return "Required";
          if (isPassword && val.length < 6) return "Min 6 chars";
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          counterText: "", // Hide character counter
          prefixIcon: Icon(icon, color: AppColors.textSecondary),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.textSecondary),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible))
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildUniversityDropdown() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: AppColors.textSecondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedUniversity,
          hint: const Text("Select University",
              style: TextStyle(color: AppColors.textSecondary)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          items: _universities
              .map((u) => DropdownMenuItem(value: u, child: Text(u)))
              .toList(),
          onChanged: (v) => setState(() => _selectedUniversity = v),
        ),
      ),
    );
  }
}