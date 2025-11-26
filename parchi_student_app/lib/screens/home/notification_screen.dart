import 'package:flutter/material.dart';
import '../../utils/colours.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Toggle this to see the Empty State design
  final bool _isEmpty = false; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () {},
          )
        ],
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
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Notifications Yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 10),
        _buildSectionHeader("New"),
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
          imageUrl: "https://placehold.co/100x100/png?text=P", // Parchi Logo placeholder
          isUnread: true,
        ),
        
        const SizedBox(height: 24),
        _buildSectionHeader("Yesterday"),
        _buildNotificationItem(
          brandName: "Outfitters",
          message: "New Winter Collection is out. Students get flat 20% off.",
          time: "1d ago",
          imageUrl: "https://placehold.co/100x100/png?text=OUT",
          isUnread: false,
        ),
        _buildNotificationItem(
          brandName: "Gloria Jeans",
          message: "Buy 1 Get 1 Free on all coffees.",
          time: "1d ago",
          imageUrl: "https://placehold.co/100x100/png?text=GJ",
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
          // 1. Square Rounded Brand Image
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12), // Rounded Square
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
          
          // 2. Content
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

          // 3. Unread Dot (Optional)
          if (isUnread)
            Container(
              margin: const EdgeInsets.only(top: 8, left: 8),
              height: 8,
              width: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}