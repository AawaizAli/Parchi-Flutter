import 'dart:ui'; // [REQUIRED] for ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/colours.dart';
import '../../services/auth_service.dart';
import '../../providers/user_provider.dart';
import '../auth/login_screens/login_screen.dart';
import 'Change_password/change_password_screen.dart';
import 'pfp_change/profile_picture_upload_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with TickerProviderStateMixin {
  // 1. Controller for the main Profile List DraggableSheet
  final DraggableScrollableController _mainSheetController = DraggableScrollableController();
  final ValueNotifier<double> _mainSheetProgress = ValueNotifier(0.0);

  // 2. Controller for the PFP Upload Sheet (Animation + Drag)
  late AnimationController _pfpController;
  
  // Dimensions
  double _minMainSheetSize = 0.6;
  double _maxMainSheetSize = 0.95;

  @override
  void initState() {
    super.initState();
    // Listen to main sheet scrolling for the header fade effect
    _mainSheetController.addListener(_onMainSheetChanged);
    
    // Initialize PFP controller (0.0 = closed, 1.0 = fully open)
    _pfpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 300),
    );
  }

  void _onMainSheetChanged() {
    double currentSize = _mainSheetController.size;
    double progress = (currentSize - _minMainSheetSize) / (_maxMainSheetSize - _minMainSheetSize);
    _mainSheetProgress.value = progress.clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _mainSheetController.removeListener(_onMainSheetChanged);
    _mainSheetController.dispose();
    _pfpController.dispose();
    super.dispose();
  }

  // --- LOGIC: Open/Close PFP Sheet ---
  void _togglePfpSheet(bool open) {
    if (open) {
      _pfpController.forward(from: 0.0);
    } else {
      _pfpController.reverse();
    }
  }

  // --- LOGIC: Handle Dragging the PFP Sheet ---
  void _handlePfpDragUpdate(DragUpdateDetails details) {
    // Convert drag pixels to controller value (0 to 1)
    // We assume the sheet is roughly 400px high. 
    double delta = details.primaryDelta! / 400; 
    _pfpController.value -= delta; // Dragging UP (negative delta) increases value
  }

  void _handlePfpDragEnd(DragEndDetails details) {
    // Snap to open or close based on velocity or position
    if (_pfpController.value > 0.5 || details.primaryVelocity! < -500) {
      _pfpController.forward();
    } else {
      _pfpController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double topPadding = MediaQuery.of(context).padding.top;
    final double headerContentHeight = 340.0;

    _minMainSheetSize = (screenHeight - (topPadding + headerContentHeight)) / screenHeight;
    if (_minMainSheetSize < 0.4) _minMainSheetSize = 0.4;
    if (_minMainSheetSize > 0.75) _minMainSheetSize = 0.75;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        // If PFP sheet is open, close it first
        if (_pfpController.value > 0.1) {
          _togglePfpSheet(false);
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
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

            // --- Widget: The Avatar Logic ---
            Widget buildAvatar({required bool isInteractive}) {
              return Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.backgroundLight,
                      backgroundImage: (user?.profilePicture != null) ? NetworkImage(user!.profilePicture!) : null,
                      child: (user?.profilePicture == null)
                          ? const Icon(Icons.person, size: 60, color: AppColors.textSecondary)
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: GestureDetector(
                      onTap: isInteractive ? () => _togglePfpSheet(true) : null,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2)),
                        child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Stack(
              children: [
                // -------------------------------------------
                // LAYER 1: Main Header (Background)
                // -------------------------------------------
                Positioned(
                  top: topPadding, left: 0, right: 0, height: headerContentHeight,
                  child: ValueListenableBuilder<double>(
                    valueListenable: _mainSheetProgress,
                    builder: (context, progress, child) {
                      return Opacity(
                        opacity: (1.0 - (progress * 3)).clamp(0.0, 1.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            const Text("Profile", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 30),
                            buildAvatar(isInteractive: true),
                            const SizedBox(height: 20),
                            Text(fullName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // -------------------------------------------
                // LAYER 2: Draggable White List Sheet
                // -------------------------------------------
                DraggableScrollableSheet(
                  controller: _mainSheetController,
                  initialChildSize: _minMainSheetSize,
                  minChildSize: _minMainSheetSize,
                  maxChildSize: _maxMainSheetSize,
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
                             // ... Content of your list ...
                            Center(
                              child: Container(
                                width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                              ),
                            ),
                            _buildDetailRow("Email", email),
                            _buildDivider(),
                            _buildDetailRow("University", university),
                            _buildDivider(),
                            _buildDetailRow("Phone", phone), 
                            _buildDivider(),
                            _buildDetailRow("Parchi ID", parchiId),
                            const SizedBox(height: 40),
                            const Text("Account Settings", style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _buildMenuTile(
                              icon: Icons.lock_outline, label: "Change Password",
                              color: const Color(0xFFFFF0F0), iconColor: const Color(0xFFFF3B30),
                              onTap: () => ChangePasswordSheet.show(context),
                            ),
                            _buildMenuTile(
                              icon: Icons.history, label: "Redemption History",
                              color: const Color(0xFFF0FDF4), iconColor: const Color(0xFF34C759),
                              onTap: () {},
                            ),
                            const SizedBox(height: 24),
                            const Text("Support", style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _buildMenuTile(
                              icon: Icons.help_outline, label: "Help Center",
                              color: const Color(0xFFF0F8FF), iconColor: const Color(0xFF007AFF),
                              onTap: () {},
                            ),
                            const SizedBox(height: 40),
                            InkWell(
                              onTap: () => _handleLogout(context, ref),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0F0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.logout, color: AppColors.error, size: 20),
                                    SizedBox(width: 8),
                                    Text("Log Out", style: TextStyle(color: AppColors.error, fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 60), // Extra space for PFP sheet
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // -------------------------------------------
                // LAYER 3: INTERACTIVE BLUR & SHEET
                // -------------------------------------------
                AnimatedBuilder(
                  animation: _pfpController,
                  builder: (context, child) {
                    // Don't render if closed to save resources
                    if (_pfpController.value == 0) return const SizedBox.shrink();

                    return Stack(
                      children: [
                        // A. The Blur Effect (Tied to Controller Value)
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () => _togglePfpSheet(false), // Tap background to close
                            child: BackdropFilter(
                              // FLOWS WITH DRAG: 0.0 -> 10.0
                              filter: ImageFilter.blur(
                                sigmaX: 10 * _pfpController.value, 
                                sigmaY: 10 * _pfpController.value
                              ),
                              child: Container(
                                // FLOWS WITH DRAG: 0.0 -> 0.2
                                color: Colors.black.withOpacity(0.2 * _pfpController.value),
                              ),
                            ),
                          ),
                        ),

                        // B. The Focused Avatar (Tied to Controller Value)
                        Positioned(
                          top: topPadding, left: 0, right: 0, height: headerContentHeight,
                          child: Opacity(
                            // FLOWS WITH DRAG: 0.0 -> 1.0
                            opacity: _pfpController.value,
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                const Text("Profile", style: TextStyle(color: Colors.transparent, fontSize: 20, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 30),
                                buildAvatar(isInteractive: false),
                              ],
                            ),
                          ),
                        ),

                        // C. The Custom Draggable Sheet
                        Positioned(
                          left: 0, right: 0, bottom: 0,
                          // Use transform to slide it in from bottom
                          child: FractionalTranslation(
                            translation: Offset(0, 1.0 - _pfpController.value),
                            child: GestureDetector(
                              // THIS MAKES IT INTERACTIVE
                              onVerticalDragUpdate: _handlePfpDragUpdate,
                              onVerticalDragEnd: _handlePfpDragEnd,
                              child: ProfilePictureUploadSheet(
                                onClose: () => _togglePfpSheet(false),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
          error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.white))),
        ),
      ),
    );
  }

  // --- Helper Widgets (Same as before) ---
  Widget _buildDivider() => const Divider(height: 32, color: AppColors.backgroundLight, thickness: 1);

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

  Widget _buildMenuTile({required IconData icon, required String label, required Color color, required Color iconColor, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600))),
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