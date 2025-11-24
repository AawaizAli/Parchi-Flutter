import 'package:flutter/material.dart';
import '../utils/colours.dart';

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
        ],
      ),
    );
  }
}