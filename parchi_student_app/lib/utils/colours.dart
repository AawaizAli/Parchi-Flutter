import 'package:flutter/material.dart';

// This class contains the primary color palette for the application.
// Using static const ensures these colors are accessible globally without
// needing an instance of the class (e.g., AppColors.primary).
class AppColors {
  // --- Primary Brand Colors ---
  // Used for: The main Parchi Card Gradient (End color), Active Buttons, Links, Arrow Icons
  static const Color primary = Color(0xFF007AFF); // A vibrant blue

  // Used for: Main App Background (Top Section), Leaderboard Top 3 Ranks, Stats Progress Ring
  static const Color secondary = Color(0xFFFF9500); // A warm orange

  // Used for: Success messages, "Total Saved" green text
  static const Color accent = Color(0xFF34C759); // A bright green

  // --- Background/Surface Colors ---
  // Used for: The rounded white sheet background (the container holding the content)
  static const Color backgroundLight = Color(0xFFF2F2F7); // Light grey background

  // Used for: The Parchi Card Gradient (Start color) to give it depth
  static const Color backgroundDark = Color(0xFF1C1C1E); // Dark charcoal background

  // Used for: Search Bar background, Bottom Navigation Bar, Brand Logo backgrounds
  static const Color surface = Color(0xFFFFFFFF); // Pure white for cards/surfaces

  // --- Text/Content Colors ---
  // Used for: Main Headings ("Top Brands", "Up to 30% off"), Restaurant Names
  static const Color textPrimary = Color(0xFF1C1C1E);

  // Used for: Subtitles, Hints (Search bar placeholder), Unselected Icons, Delivery Times
  static const Color textSecondary = Color(0xFF8E8E93);

  // Used for: Clickable links or accents
  static const Color textLink = primary; 

  // Used for: Text inside the Parchi Card (Name, ID) that sits on dark backgrounds
  static const Color textOnPrimary = Colors.white; 

  // --- Utility Colors ---
  // Used for: "30% OFF" tags on Restaurant cards to grab attention
  static const Color error = Color(0xFFFF3B30); // Red for errors/danger

  // Used for: Positive stats
  static const Color success = accent;

  // Used for: Warnings (Generic)
  static const Color warning = Color(0xFFFFCC00); // Yellow for warnings
}