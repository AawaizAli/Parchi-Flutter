import 'package:flutter/material.dart';
import '../utils/colours.dart';
import 'signup_verification_screen.dart';

class SignupScreenTwo extends StatefulWidget {
  final String name;
  final String email;
  final String university;
  final String age;

  const SignupScreenTwo({
    super.key,
    required this.name,
    required this.email,
    required this.university,
    required this.age,
  });

  @override
  State<SignupScreenTwo> createState() => _SignupScreenTwoState();
}

class _SignupScreenTwoState extends State<SignupScreenTwo> {
  bool _timetableUploaded = false;
  bool _feeChallanUploaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Container(height: 4, color: AppColors.primary)),
                  const SizedBox(width: 8),
                  Expanded(child: Container(height: 4, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                "Verification",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                "Upload documents to prove student status.",
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              _buildLabel("University Timetable"),
              _buildUploadBox(
                "Tap to upload Timetable",
                _timetableUploaded,
                () {
                  setState(() {
                    _timetableUploaded = !_timetableUploaded;
                  });
                },
              ),
              const SizedBox(height: 24),

              _buildLabel("Fee Challan"),
              _buildUploadBox(
                "Tap to upload Fee Challan",
                _feeChallanUploaded,
                () {
                  setState(() {
                    _feeChallanUploaded = !_feeChallanUploaded;
                  });
                },
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupVerificationScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "Submit Verification",
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
        ),
      ),
    );
  }

  Widget _buildUploadBox(String text, bool isUploaded, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isUploaded ? AppColors.success.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded ? AppColors.success : AppColors.textSecondary.withOpacity(0.3),
            width: 1.5,
            style: BorderStyle.solid, 
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUploaded ? Icons.check_circle : Icons.cloud_upload_outlined,
              size: 40,
              color: isUploaded ? AppColors.success : AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              isUploaded ? "Document Uploaded" : text,
              style: TextStyle(
                color: isUploaded ? AppColors.success : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!isUploaded)
              Text(
                "Supported: JPG, PNG, PDF",
                style: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}