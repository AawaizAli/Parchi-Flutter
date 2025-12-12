import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/colours.dart';
import '../../services/auth_service.dart';
import '../../providers/user_provider.dart';
import '../auth/login_screens/login_screen.dart';
import 'Change_password/change_password_screen.dart';
import 'profile_picture_upload_screen.dart'; // [NEW] Import the new screen

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final ValueNotifier<double> _expandProgress = ValueNotifier(0.0);

  double _minSheetSize = 0.6; 
  double _maxSheetSize = 0.95; 

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChanged);
  }

  void _onSheetChanged() {
    double currentSize = _sheetController.size;
    double progress = (currentSize - _minSheetSize) / (_maxSheetSize - _minSheetSize);
    _expandProgress.value = progress.clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double topPadding = MediaQuery.of(context).padding.top;

    final double headerContentHeight = 340.0; 
    _minSheetSize = (screenHeight - (topPadding + headerContentHeight)) / screenHeight;
    
    if (_minSheetSize < 0.4) _minSheetSize = 0.4;
    if (_minSheetSize > 0.75) _minSheetSize = 0.75;

    return Scaffold(
      backgroundColor: AppColors.secondary, 
      body: userAsync.when(
        data: (user) {
          final fName = user?.firstName ?? "Student";
          final lName = user?.lastName ?? "";
          final fullName = "$fName $lName".trim();
          final email = user?.email ?? "No Email";
          final parchiId = user?.parchiId ?? "PK-????";
          final university = user?.university ?? "University";
          final phone = user?.phone ?? "No Phone";

          return Stack(
            children: [
              // --- 1. HEADER ---
              Positioned(
                top: topPadding, left: 0, right: 0, height: headerContentHeight,
                child: ValueListenableBuilder<double>(
                  valueListenable: _expandProgress,
                  builder: (context, progress, child) {
                    return Opacity(
                      opacity: (1.0 - (progress * 3)).clamp(0.0, 1.0), 
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          const Text("Profile", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 30),
                          Stack(
                            children: [
                              // Avatar
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: AppColors.backgroundLight,
                                  // [UPDATED] Show profile picture if available
                                  backgroundImage: (user?.profilePicture != null) 
                                      ? NetworkImage(user!.profilePicture!) 
                                      : null,
                                  child: (user?.profilePicture == null)
                                      ? const Icon(Icons.person, size: 60, color: AppColors.textSecondary)
                                      : null,
                                ),
                              ),
                              
                              // Camera Icon Button
                              Positioned(
                                bottom: 0, 
                                right: 0,
                                // [UPDATED] Added GestureDetector to handle tap
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const ProfilePictureUploadScreen()),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black87, 
                                      shape: BoxShape.circle, 
                                      border: Border.all(color: Colors.white, width: 2)
                                    ),
                                    child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(fullName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),

                        ],
                      ),
                    );
                  },
                ),
              ),

              // --- 2. DRAGGABLE WHITE SHEET ---
              DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: _minSheetSize,
                minChildSize: _minSheetSize,
                maxChildSize: _maxSheetSize,
                snap: true,
                builder: (BuildContext context, ScrollController scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(24),
                        children: [
                          Center(
                            child: Container(
                              width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                            ),
                          ),

                          // --- INFO SECTION ---
                          _buildDetailRow("Email", email),
                          _buildDivider(),
                          _buildDetailRow("University", university),
                          _buildDivider(),
                          _buildDetailRow("Phone", phone), 
                          _buildDivider(),
                          _buildDetailRow("Parchi ID", parchiId),
                          
                          const SizedBox(height: 40),

                          // --- SETTINGS SECTION ---
                          const Text("Account Settings", style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),

                          // [NEW] Modern List Tiles
                          _buildMenuTile(
                            icon: Icons.lock_outline, 
                            label: "Change Password",
                            color: const Color(0xFFFFF0F0), 
                            iconColor: const Color(0xFFFF3B30),
                            onTap: () {
                              // [UPDATED] Use the static show method to trigger the popup
                              ChangePasswordSheet.show(context);
                            },
                          ),
                          _buildMenuTile(
                            icon: Icons.history, 
                            label: "Redemption History",
                            color: const Color(0xFFF0FDF4), 
                            iconColor: const Color(0xFF34C759),
                            onTap: () {},
                          ),

                          const SizedBox(height: 24),
                          const Text("Support", style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),

                          _buildMenuTile(
                            icon: Icons.help_outline, 
                            label: "Help Center",
                            color: const Color(0xFFF0F8FF), 
                            iconColor: const Color(0xFF007AFF),
                            onTap: () {},
                          ),

                          const SizedBox(height: 40),

                          // --- LOGOUT (Clean & Minimal) ---
                          InkWell(
                            onTap: () => _handleLogout(context, ref),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0F0), // Very light red bg
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout, color: AppColors.error, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    "Log Out",
                                    style: TextStyle(color: AppColors.error, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.white))),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildDivider() {
    return const Divider(height: 32, color: AppColors.backgroundLight, thickness: 1);
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  // [NEW] Clean, Modern Tile Widget
  Widget _buildMenuTile({
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white, // Plain white background
            // No border, just clean layout
            borderRadius: BorderRadius.circular(16),
            // Optional: Very subtle shadow if you want depth, otherwise remove
            // border: Border.all(color: AppColors.backgroundLight), 
          ),
          child: Row(
            children: [
              // Colorful Icon Container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              
              // Text
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              // Arrow
              const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFC7C7CC)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Logout', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
      try {
        await authService.logout();
        ref.read(userProfileProvider.notifier).clearUser();
        if (context.mounted) {
          Navigator.of(context).pop(); 
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout failed: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }
}