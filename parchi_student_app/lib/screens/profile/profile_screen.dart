import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // [NEW] Import Riverpod
import '../../utils/colours.dart';
import '../../services/auth_service.dart';
import '../../providers/user_provider.dart'; // [NEW] Import User Provider
import '../auth/login_screens/login_screen.dart';

// [CHANGED] Convert to ConsumerWidget to listen to providers
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // [NEW] Watch the user provider
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
           IconButton(
             onPressed: (){}, 
             icon: const Icon(Icons.settings, color: AppColors.textPrimary)
           )
        ],
      ),
      body: userAsync.when(
        // 1. DATA READY
        data: (user) {
          final fullName = "${user?.firstName ?? 'Student'} ${user?.lastName ?? ''}".trim();
          final university = user?.university ?? "No University";
          final parchiId = user?.parchiId ?? "PENDING";

          return Column(
            children: [
              const SizedBox(height: 20),
              // Profile Pic
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.backgroundLight,
                  child: Icon(Icons.person, size: 50, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 10),
              
              // [NEW] Dynamic Name
              Text(
                fullName.isEmpty ? "User" : fullName, 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
              ),
              
              // [NEW] Dynamic University
              Text(
                university, 
                style: const TextStyle(color: AppColors.textSecondary)
              ),
              
              const SizedBox(height: 30),
              
              ListTile(
                leading: const Icon(Icons.history, color: AppColors.textSecondary),
                title: const Text("Redemption History", style: TextStyle(color: AppColors.textPrimary)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                onTap: () {},
              ),
              
              // [NEW] Dynamic Parchi ID in list tile
              ListTile(
                leading: const Icon(Icons.qr_code, color: AppColors.textSecondary),
                title: const Text("My Parchi ID", style: TextStyle(color: AppColors.textPrimary)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(parchiId, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                  ],
                ),
                onTap: () {},
              ),
              
              const Divider(),
              
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout", style: TextStyle(color: Colors.red)),
                onTap: () async {
                  _handleLogout(context, ref);
                },
              ),
            ],
          );
        },
        // 2. LOADING STATE (Show skeletons or simple loading)
        loading: () => const Center(child: CircularProgressIndicator()),
        // 3. ERROR STATE
        error: (err, stack) => Center(child: Text("Error: $err")),
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
      }

      try {
        await authService.logout();
        
        // [NEW] Clear Riverpod State so data doesn't persist
        ref.read(userProfileProvider.notifier).clearUser();

        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}