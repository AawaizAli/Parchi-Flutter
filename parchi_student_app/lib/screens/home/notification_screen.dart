import 'package:flutter/material.dart';
import '../../utils/colours.dart';
import '../../widgets/home_screen_widgets/bonus_reward_card.dart'; 

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final bool _isEmpty = false; 

  // DUMMY DATA
  final List<RewardModel> _rewards = [
    // [NEW] COMPLETED CARD (Test the Gold Unlock here!)
    RewardModel(
      restaurantName: "Gold Burger",
      currentCount: 5, // 5/5 = COMPLETED
      targetCount: 5,
      discountText: "Free Premium Meal",
      gradientColors: [const Color(0xFFFFD700), const Color(0xFFFFA500)], 
      shadowColor: const Color(0xFFFFD700),
    ),
    // Standard Card 1
    RewardModel(
      restaurantName: "KFC",
      currentCount: 3,
      targetCount: 5,
      discountText: "Free Zinger",
      gradientColors: [const Color(0xFFFF3B30), const Color(0xFFFF2D55)], 
      shadowColor: const Color(0xFFFF2D55),
    ),
    // Standard Card 2
    RewardModel(
      restaurantName: "Pizza Max",
      currentCount: 1,
      targetCount: 3,
      discountText: "Free Pizza",
      gradientColors: [const Color(0xFF007AFF), const Color(0xFF5856D6)], 
      shadowColor: const Color(0xFF5856D6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isEmpty ? _buildEmptyState() : _buildNotificationList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.backgroundLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Notifications Yet",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            "We'll let you know when new discounts arrive!",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // The Stack
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: BonusRewardStack(rewards: _rewards),
        ),
        
        const SizedBox(height: 10),
        
        _buildSectionHeader("New Updates"),
        _buildNotificationItem(
          brandName: "KFC",
          message: "Flash Sale! Get 50% OFF on Zinger Burgers tonight.",
          time: "2m ago",
          imageUrl: "https://placehold.co/100x100/png?text=KFC",
          isUnread: true,
        ),
        _buildNotificationItem(
          brandName: "Parchi",
          message: "You successfully redeemed a discount at Burger O'Clock.",
          time: "1h ago",
          imageUrl: "https://placehold.co/100x100/png?text=P",
          isUnread: true,
        ),
        
        const SizedBox(height: 20),
        _buildSectionHeader("Yesterday"),
        _buildNotificationItem(
          brandName: "Outfitters",
          message: "New Winter Collection is out. Students get flat 20% off.",
          time: "1d ago",
          imageUrl: "https://placehold.co/100x100/png?text=OUT",
          isUnread: false,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String brandName,
    required String message,
    required String time,
    required String imageUrl,
    required bool isUnread,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.4),
                    children: [
                      TextSpan(
                        text: "$brandName ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: message),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: isUnread ? AppColors.primary : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          if (isUnread)
            Container(
              margin: const EdgeInsets.only(top: 8, left: 8),
              height: 8,
              width: 8,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}