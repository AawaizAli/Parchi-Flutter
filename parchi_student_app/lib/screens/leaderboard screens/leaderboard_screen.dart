import 'package:flutter/material.dart';
import '../../utils/colours.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboard"),
        centerTitle: true,
      ),
      body: ListView.separated(
        itemCount: 10,
        separatorBuilder: (ctx, i) => const Divider(color: AppColors.textSecondary),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              // Top 3 get the Secondary (Orange/Gold), others get surface color
              backgroundColor: index < 3 ? AppColors.secondary : AppColors.backgroundLight,
              foregroundColor: index < 3 ? AppColors.surface : AppColors.textPrimary,
              child: Text("#${index + 1}"),
            ),
            title: Text(
              "Student ${index + 1}",
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            trailing: Text(
              "${1000 - (index * 50)} Saved",
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success),
            ),
          );
        },
      ),
    );
  }
}