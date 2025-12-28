import 'package:flutter/material.dart';
import '../../../utils/colours.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data List
    final List<Map<String, String>> notifications = [
      {
        "brandName": "KFC",
        "message": "Flash Sale! Get 50% OFF on Zinger Burgers tonight.",
        "time": "2m ago",
        "imageUrl": "https://placehold.co/100x100/png?text=KFC",
      },
      {
        "brandName": "Parchi",
        "message": "You successfully redeemed a discount at Burger O'Clock.",
        "time": "1h ago",
        "imageUrl": "https://placehold.co/100x100/png?text=P",
      },
      {
        "brandName": "Outfitters",
        "message": "New Winter Collection is out. Students get flat 20% off.",
        "time": "1d ago",
        "imageUrl": "https://placehold.co/100x100/png?text=OUT",
      },
      {
        "brandName": "Pizza Max",
        "message": "Buy 1 Get 1 Free on all large pizzas.",
        "time": "2d ago",
        "imageUrl": "https://placehold.co/100x100/png?text=PM",
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.zero, // Remove outer padding
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 1.0,
          color: AppColors.surfaceVariant, // Thin grey line
        ),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return _buildNotificationItem(
            brandName: item["brandName"]!,
            message: item["message"]!,
            time: item["time"]!,
            imageUrl: item["imageUrl"]!,
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem({
    required String brandName,
    required String message,
    required String time,
    required String imageUrl,
  }) {
    return Container(
      // Removed margin and decoration
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circle Image
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.1),
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Heading (Brand Name)
                Text(
                  brandName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Description
                Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
