import 'package:flutter/material.dart';
import '../../../utils/colours.dart';
import 'signup_screen_two.dart';

class SignupScreenOne extends StatefulWidget {
  const SignupScreenOne({super.key});

  @override
  State<SignupScreenOne> createState() => _SignupScreenOneState();
}

class _SignupScreenOneState extends State<SignupScreenOne> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedUniversity;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _universityError;

  final List<String> _universities = [
    "FAST NUCES",
    "IBA Karachi",
    "LUMS",
    "NUST",
    "Karachi University",
    "Szabist",
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    bool isValid = true;
    
    // Reset errors
    setState(() {
      _firstNameError = null;
      _lastNameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _universityError = null;
    });

    // Validate First Name
    if (_firstNameController.text.trim().isEmpty) {
      setState(() {
        _firstNameError = "First name is required";
      });
      isValid = false;
    }

    // Validate Last Name
    if (_lastNameController.text.trim().isEmpty) {
      setState(() {
        _lastNameError = "Last name is required";
      });
      isValid = false;
    }

    // Validate Email
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _emailError = "Email is required";
      });
      isValid = false;
    } else if (!_isValidEmail(email)) {
      setState(() {
        _emailError = "Please enter a valid email address";
      });
      isValid = false;
    }

    // Validate Password
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _passwordError = "Password is required";
      });
      isValid = false;
    } else if (password.length < 8) {
      setState(() {
        _passwordError = "Password must be at least 8 characters";
      });
      isValid = false;
    }

    // Validate Confirm Password
    final confirmPassword = _confirmPasswordController.text;
    if (confirmPassword.isEmpty) {
      setState(() {
        _confirmPasswordError = "Please confirm your password";
      });
      isValid = false;
    } else if (password != confirmPassword) {
      setState(() {
        _confirmPasswordError = "Passwords do not match";
      });
      isValid = false;
    }

    // Validate University
    if (_selectedUniversity == null || _selectedUniversity!.isEmpty) {
      setState(() {
        _universityError = "Please select a university";
      });
      isValid = false;
    }

    return isValid;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _handleNextStep() {
    if (_validateForm()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignupScreenTwo(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            phone: _phoneController.text.trim(),
            university: _selectedUniversity ?? "",
          ),
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all required fields correctly"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE8F5E9), Color(0xFFF5F7FA)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Nav
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Enter your personal details to get started.",
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 40),

                  _buildInputLabel("First Name *"),
                  _buildAfluctaTextField(_firstNameController, "John", Icons.person_outline, errorText: _firstNameError),
                  if (_firstNameError != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                      child: Text(
                        _firstNameError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  _buildInputLabel("Last Name *"),
                  _buildAfluctaTextField(_lastNameController, "Doe", Icons.person_outline, errorText: _lastNameError),
                  if (_lastNameError != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                      child: Text(
                        _lastNameError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  _buildInputLabel("Student Email ID *"),
                  _buildAfluctaTextField(_emailController, "john@gmail.com", Icons.email_outlined, errorText: _emailError),
                  if (_emailError != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                      child: Text(
                        _emailError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  _buildInputLabel("Password *"),
                  _buildPasswordTextField(),
                  if (_passwordError != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                      child: Text(
                        _passwordError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  _buildInputLabel("Confirm Password *"),
                  _buildConfirmPasswordTextField(),
                  if (_confirmPasswordError != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                      child: Text(
                        _confirmPasswordError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  _buildInputLabel("Phone Number (Optional)"),
                  _buildAfluctaTextField(_phoneController, "+92 300 1234567", Icons.phone_outlined, isNumber: true),
                  const SizedBox(height: 24),

                  _buildInputLabel("University *"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _universityError != null ? Colors.red : Colors.grey.shade300,
                        width: _universityError != null ? 1.5 : 1,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedUniversity,
                        hint: Text("Select University", style: TextStyle(color: Colors.grey.shade400)),
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500),
                        items: _universities.map((String uni) {
                          return DropdownMenuItem<String>(
                            value: uni,
                            child: Text(uni, style: const TextStyle(color: AppColors.textPrimary)),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedUniversity = newValue;
                            _universityError = null; // Clear error when selection is made
                          });
                        },
                      ),
                    ),
                  ),
                  if (_universityError != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                      child: Text(
                        _universityError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),

                  // Neon Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF27AE60)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _handleNextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Next Step",
                        style: TextStyle(
                          color: Colors.white,
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
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String text) {
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

  Widget _buildAfluctaTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false, String? errorText}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: errorText != null ? Colors.red : Colors.grey.shade300,
          width: errorText != null ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: AppColors.textPrimary),
        onChanged: (value) {
          // Clear error when user starts typing
          if (errorText != null) {
            setState(() {
              if (controller == _firstNameController) {
                _firstNameError = null;
              } else if (controller == _lastNameController) {
                _lastNameError = null;
              } else if (controller == _emailController) {
                _emailError = null;
              } else if (controller == _passwordController) {
                _passwordError = null;
              } else if (controller == _confirmPasswordController) {
                _confirmPasswordError = null;
              }
            });
          }
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(icon, color: errorText != null ? Colors.red : Colors.grey.shade500),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordTextField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _passwordError != null ? Colors.red : Colors.grey.shade300,
          width: _passwordError != null ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        keyboardType: TextInputType.visiblePassword,
        style: const TextStyle(color: AppColors.textPrimary),
        onChanged: (value) {
          // Clear error when user starts typing
          if (_passwordError != null) {
            setState(() {
              _passwordError = null;
            });
          }
          // Check if confirm password matches in real-time
          if (_confirmPasswordController.text.isNotEmpty) {
            if (value != _confirmPasswordController.text) {
              setState(() {
                _confirmPasswordError = "Passwords do not match";
              });
            } else {
              setState(() {
                _confirmPasswordError = null;
              });
            }
          }
        },
        decoration: InputDecoration(
          hintText: "Enter your password",
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: _passwordError != null ? Colors.red : Colors.grey.shade500,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Colors.grey.shade500,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordTextField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _confirmPasswordError != null ? Colors.red : Colors.grey.shade300,
          width: _confirmPasswordError != null ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: _confirmPasswordController,
        obscureText: _obscureConfirmPassword,
        keyboardType: TextInputType.visiblePassword,
        style: const TextStyle(color: AppColors.textPrimary),
        onChanged: (value) {
          // Clear error when user starts typing
          if (_confirmPasswordError != null) {
            setState(() {
              _confirmPasswordError = null;
            });
          }
          // Also check if passwords match in real-time
          if (value.isNotEmpty && _passwordController.text.isNotEmpty) {
            if (value != _passwordController.text) {
              setState(() {
                _confirmPasswordError = "Passwords do not match";
              });
            } else {
              setState(() {
                _confirmPasswordError = null;
              });
            }
          }
        },
        decoration: InputDecoration(
          hintText: "Confirm your password",
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: _confirmPasswordError != null ? Colors.red : Colors.grey.shade500,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Colors.grey.shade500,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }
}