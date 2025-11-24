import 'package:flutter/material.dart';

// This class contains the primary color palette for the application.
class AppColors {
  // --- Primary Brand Colors ---
  static const Color primary = Color(0xFF007AFF); // A vibrant blue
  static const Color secondary = Color(0xFFFF9500); // A warm orange
  static const Color accent = Color(0xFF34C759); // A bright green

  // --- Background/Surface Colors ---
  static const Color backgroundLight = Color(0xFFF2F2F7); // Light grey background
  static const Color backgroundDark = Color(0xFF1C1C1E); // Dark charcoal background
  static const Color surface = Color(0xFFFFFFFF); // Pure white for cards/surfaces

  // --- Text/Content Colors ---
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textLink = primary; // Links often use the primary color
  static const Color textOnPrimary = Colors.white; // Text on colored backgrounds

  // --- Utility Colors ---
  static const Color error = Color(0xFFFF3B30); // Red for errors/danger
  static const Color success = accent;
  static const Color warning = Color(0xFFFFCC00); // Yellow for warnings
}