import 'package:flutter/material.dart';
import '../../utils/colours.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data
    final List<Map<String, dynamic>> leaderboardData = List.generate(
      10,
      (index) => {
        "rank": index + 1,
        "name": "Student ${index + 1}",
        "university": "University of Karachi", // Placeholder
        "redemptions": 1000 - (index * 50),
      },
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        
        title: const Text(
          "Leaderboard",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: leaderboardData.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 1.0,
          color: AppColors.surfaceVariant,
        ),
        itemBuilder: (context, index) {
          final item = leaderboardData[index];
          return _buildLeaderboardItem(
            rank: item["rank"],
            name: item["name"],
            university: item["university"],
            redemptions: item["redemptions"],
          );
        },
      ),
    );
  }

  Widget _buildLeaderboardItem({
    required int rank,
    required String name,
    required String university,
    required int redemptions,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: Text(
              "#$rank",
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Name & University
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  university,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Total Redemptions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$redemptions",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Redemptions",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}