import 'package:flutter/material.dart';
import '../../utils/colours.dart';
import '../../services/auth_service.dart';
import '../auth/login screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.backgroundLight,
              child: Icon(Icons.person, size: 50, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Aawaiz Ali", 
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
          ),
          const Text(
            "FAST-NUCES", 
            style: TextStyle(color: AppColors.textSecondary)
          ),
          const SizedBox(height: 30),
          ListTile(
            leading: const Icon(Icons.history, color: AppColors.textSecondary),
            title: const Text("Redemption History", style: TextStyle(color: AppColors.textPrimary)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.qr_code, color: AppColors.textSecondary),
            title: const Text("My Parchi ID", style: TextStyle(color: AppColors.textPrimary)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () async {
              // Show confirmation dialog
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
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                try {
                  // Call logout
                  await authService.logout();
                  
                  // Close loading dialog
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }

                  // Navigate to login screen and clear navigation stack
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  // Close loading dialog
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }

                  // Show error message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Logout failed: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }
}