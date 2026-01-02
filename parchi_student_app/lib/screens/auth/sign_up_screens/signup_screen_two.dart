import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../../utils/colours.dart';
import '../../../services/supabase_storage_service.dart';
import '../../../services/auth_service.dart';
import 'signup_verification_screen.dart';

class SignupScreenTwo extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phone;
  final String university;

  const SignupScreenTwo({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
    required this.university,
  });

  @override
  State<SignupScreenTwo> createState() => _SignupScreenTwoState();
}

class _SignupScreenTwoState extends State<SignupScreenTwo> {
  final ImagePicker _imagePicker = ImagePicker();
  final SupabaseStorageService _storageService = SupabaseStorageService();
  File? _studentIdImage;
  File? _studentIdBackImage;
  File? _selfieImage;
  String? _validationError;
  bool _isUploading = false;
  final AuthService _authService = AuthService();

  // ... (Keep existing _showImageSourceDialog logic) ...
  void _showImageSourceDialog(int imageType) {
    // imageType: 0 = studentId, 1 = studentIdBack, 2 = selfie
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
          child: Wrap(children: [
        ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () async {
              Navigator.pop(ctx);
              _pickImage(ImageSource.gallery, imageType);
            }),
        ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () async {
              Navigator.pop(ctx);
              _pickImage(ImageSource.camera, imageType);
            }),
      ])),
    );
  }

  Future<void> _pickImage(ImageSource source, int imageType) async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: source, imageQuality: 85);
      if (image != null) {
        setState(() {
          if (imageType == 0) {
            _studentIdImage = File(image.path);
          } else if (imageType == 1) {
            _studentIdBackImage = File(image.path);
          } else {
            _selfieImage = File(image.path);
          }
          _validationError = null;
        });
      }
    } catch (e) {/* Error handling */}
  }

  // ... (Keep _showError, _validateForm, _handleSubmit EXACTLY as they were) ...
  void _showError(String message) {
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  bool _validateForm() {
    if (_studentIdImage == null) {
      setState(() => _validationError = "Upload Student ID Front");
      return false;
    }
    if (_studentIdBackImage == null) {
      setState(() => _validationError = "Upload Student ID Back");
      return false;
    }
    if (_selfieImage == null) {
      setState(() => _validationError = "Upload Selfie");
      return false;
    }
    setState(() => _validationError = null);
    return true;
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;
    setState(() => _isUploading = true);

    // Create temp ID for file path
    final String tempUserId =
        widget.email.replaceAll('@', '_').replaceAll('.', '_');

    try {
      // 1. Upload Images
      final imageUrls = await _storageService.uploadKycImages(
        studentIdImage: _studentIdImage!,
        studentIdBackImage: _studentIdBackImage!,
        selfieImage: _selfieImage!,
        userId: tempUserId,
      );

      // 2. Submit Signup Data
      final signupResponse = await _authService.studentSignup(
        firstName: widget.firstName,
        lastName: widget.lastName,
        email: widget.email,
        password: widget.password,
        phone: widget.phone.isNotEmpty ? widget.phone : null,
        university: widget.university,
        studentIdCardFrontUrl: imageUrls['studentIdUrl']!,
        studentIdCardBackUrl: imageUrls['studentIdBackUrl']!,
        selfieImageUrl: imageUrls['selfieUrl']!,
      );

      // 3. Navigate
      if (mounted)
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => SignupVerificationScreen(
                    parchiId: signupResponse.parchiId,
                    email: signupResponse.email)));
    } catch (e) {
      _showError('Signup failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- 1. DARK GRADIENT BACKGROUND (Matching Theme) ---
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

          // --- 2. WHITE CONTAINER (Consistency) ---
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              child: Container(
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
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: AppColors.textSecondary
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.arrow_back,
                                    size: 20, color: AppColors.textPrimary),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text("Verify Student",
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary)),
                            const Spacer(),
                            SvgPicture.asset(
                              'assets/ParchiFullTextYellow.svg',
                              height: 24,
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                  "Upload your student ID (front & back) and a selfie.",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.textSecondary)),
                              const SizedBox(height: 40),
                              _buildInputLabel("Student ID Front *"),
                              _buildUploadBox(
                                  "Upload ID Front",
                                  _studentIdImage != null,
                                  () => _showImageSourceDialog(0),
                                  image: _studentIdImage),
                              const SizedBox(height: 24),
                              _buildInputLabel("Student ID Back *"),
                              _buildUploadBox(
                                  "Upload ID Back",
                                  _studentIdBackImage != null,
                                  () => _showImageSourceDialog(1),
                                  image: _studentIdBackImage),
                              const SizedBox(height: 24),
                              _buildInputLabel("Selfie Image *"),
                              _buildUploadBox(
                                  "Upload Selfie",
                                  _selfieImage != null,
                                  () => _showImageSourceDialog(2),
                                  image: _selfieImage),
                              if (_validationError != null) ...[
                                const SizedBox(height: 16),
                                Text(_validationError!,
                                    style: const TextStyle(
                                        color: AppColors.error)),
                              ],
                              const SizedBox(height: 40),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed:
                                      _isUploading ? null : _handleSubmit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.textPrimary, // Match Theme
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                  ),
                                  child: _isUploading
                                      ? const CircularProgressIndicator(
                                          color: AppColors.textOnPrimary)
                                      : const Text("Submit Verification",
                                          style: TextStyle(
                                              color: AppColors.textOnPrimary,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
        child: Text(text,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14)));
  }

  Widget _buildUploadBox(String text, bool isUploaded, VoidCallback onTap,
      {File? image}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isUploaded
              ? AppColors.textSecondary.withOpacity(0.1)
              : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isUploaded
                  ? AppColors.primary
                  : AppColors.textSecondary.withOpacity(0.3),
              width: 1.5),
        ),
        child: isUploaded && image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(image,
                    fit: BoxFit.cover, width: double.infinity))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined,
                      size: 48,
                      color: AppColors.textSecondary.withOpacity(0.4)),
                  const SizedBox(height: 12),
                  Text(text,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }
}
