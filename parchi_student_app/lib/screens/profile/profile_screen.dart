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
  // 1. Controller for the main Profile List DraggableSheet (The white background list)
  final DraggableScrollableController _mainSheetController = DraggableScrollableController();
  final ValueNotifier<double> _mainSheetProgress = ValueNotifier(0.0);

  // 2. GENERIC MODAL CONTROLLER (Handles BOTH PFP and Password sheets)
  late AnimationController _modalController;
  
  // State to track WHICH sheet is open
  Widget? _activeSheetContent; 
  // State to track if we should show the "Floating Avatar" effect
  bool _showFocusedAvatar = false; 

  // Layout Dimensions
  double _minMainSheetSize = 0.6;
  double _maxMainSheetSize = 0.95;

  @override
  void initState() {
    super.initState();
    // Listener for the main list header fade effect
    _mainSheetController.addListener(_onMainSheetChanged);
    
    // Initialize the shared modal animation controller
    _modalController = AnimationController(
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
    _modalController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------
  // LOGIC: OPENING SHEETS
  // ---------------------------------------------------------

  // 1. Open Profile Picture Sheet (With Focused Avatar)
  void _openPfpSheet() {
    setState(() {
      _activeSheetContent = ProfilePictureUploadSheet(onClose: _closeModal);
      _showFocusedAvatar = true; // <--- TRUE: Avatar stays bright on top
    });
    _modalController.forward(from: 0.0);
  }

  // 2. Open Password Sheet (Standard Blur)
  void _openPasswordSheet() {
    setState(() {
      _activeSheetContent = ChangePasswordSheet(onClose: _closeModal);
      _showFocusedAvatar = false; // <--- FALSE: Avatar gets blurred with background
    });
    _modalController.forward(from: 0.0);
  }

  // 3. Close Any Active Modal
  void _closeModal() {
    // Reverse animation, then clear content
    _modalController.reverse().whenComplete(() {
      if (mounted) {
        setState(() => _activeSheetContent = null);
      }
    });
  }

  // ---------------------------------------------------------
  // LOGIC: DRAGGING INTERACTION
  // ---------------------------------------------------------
  void _handleModalDragUpdate(DragUpdateDetails details) {
    // Normalize drag distance against screen height (~60% of screen)
    double delta = details.primaryDelta! / (MediaQuery.of(context).size.height * 0.6); 
    _modalController.value -= delta; // Drag down reduces value
  }

  void _handleModalDragEnd(DragEndDetails details) {
    // Snap open or closed based on position or velocity
    if (_modalController.value > 0.5 || details.primaryVelocity! < -500) {
      _modalController.forward();
    } else {
      _closeModal();
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

    // PopScope intercepts the Back Button
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        // If our custom modal is open, close it first. Otherwise pop screen.
        if (_modalController.value > 0.1) {
          _closeModal();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.secondary,
        resizeToAvoidBottomInset: false, // Handle keyboard manually in the stack
        body: userAsync.when(
          data: (user) {
            final fName = user?.firstName ?? "Student";
            final lName = user?.lastName ?? "";
            final fullName = "$fName $lName".trim();
            final email = user?.email ?? "No Email";
            final parchiId = user?.parchiId ?? "PK-????";
            final university = user?.university ?? "University";
            final phone = user?.phone ?? "No Phone";

            // --- Reusable Avatar Builder ---
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
                      onTap: isInteractive ? _openPfpSheet : null,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.black87, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                        child: const Icon(Icons.edit, size: 18, color: Colors.white),                      
                        ),
                    ),
                  ),
                ],
              );
            }

            return Stack(
              children: [
                // -------------------------------------------
                // LAYER 1: Header (Background)
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
                // LAYER 2: Main List Sheet
                // -------------------------------------------
                DraggableScrollableSheet(
                  controller: _mainSheetController,
                  initialChildSize: _minMainSheetSize,
                  minChildSize: _minMainSheetSize,
                  maxChildSize: _maxMainSheetSize,
                  snap: true,
                  builder: (context, scrollController) {
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
                            Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
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
                            
                            // CHANGE PASSWORD TILE
                            _buildMenuTile(
                              icon: Icons.lock_outline, 
                              label: "Change Password",
                              color: const Color(0xFFFFF0F0), 
                              iconColor: const Color(0xFFFF3B30),
                              onTap: _openPasswordSheet, // <--- Triggers generic modal
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
                                decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(12)),
                                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.logout, color: AppColors.error), SizedBox(width: 8), Text("Log Out", style: TextStyle(color: AppColors.error, fontSize: 16, fontWeight: FontWeight.bold))]),
                              ),
                            ),
                            const SizedBox(height: 100), // Space for bottom sheets
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // -------------------------------------------
                // LAYER 3: INTERACTIVE MODAL OVERLAY
                // -------------------------------------------
                AnimatedBuilder(
                  animation: _modalController,
                  builder: (context, child) {
                    // Performance optimization: Don't render if closed
                    if (_modalController.value == 0 || _activeSheetContent == null) return const SizedBox.shrink();

                    return Stack(
                      children: [
                        // A. BLURRED BACKGROUND
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: _closeModal, // Tap outside to close
                            child: BackdropFilter(
                              // Blur flows with the drag (0.0 -> 10.0)
                              filter: ImageFilter.blur(
                                sigmaX: 10 * _modalController.value, 
                                sigmaY: 10 * _modalController.value
                              ),
                              child: Container(
                                // Dim opacity flows with drag (0.0 -> 0.2)
                                color: Colors.black.withOpacity(0.2 * _modalController.value),
                              ),
                            ),
                          ),
                        ),

                        // B. FOCUSED AVATAR (Conditional)
                        // Only render this if it's the PFP sheet (_showFocusedAvatar == true)
                        if (_showFocusedAvatar)
                          Positioned(
                            top: topPadding, left: 0, right: 0, height: headerContentHeight,
                            child: Opacity(
                              opacity: _modalController.value, // Fade in with drag
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  // Invisible text to maintain exact layout alignment
                                  const Text("Profile", style: TextStyle(color: Colors.transparent, fontSize: 20, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 30),
                                  // The Bright, Sharp Avatar
                                  buildAvatar(isInteractive: false),
                                ],
                              ),
                            ),
                          ),

                        // C. THE SHEET CONTENT
                        Positioned(
                          left: 0, right: 0, bottom: 0,
                          // Slide up from bottom based on controller value
                          child: FractionalTranslation(
                            translation: Offset(0, 1.0 - _modalController.value),
                            child: GestureDetector(
                              onVerticalDragUpdate: _handleModalDragUpdate,
                              onVerticalDragEnd: _handleModalDragEnd,
                              child: Padding(
                                // Push content up when keyboard opens (Critical for Password field)
                                padding: MediaQuery.of(context).viewInsets,
                                child: _activeSheetContent,
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

  // --- Helper Widgets ---

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