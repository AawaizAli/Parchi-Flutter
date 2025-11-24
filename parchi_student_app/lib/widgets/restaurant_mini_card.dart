import 'package:flutter/material.dart';
import '../utils/colours.dart';

class RestaurantMiniCard extends StatelessWidget {
  const RestaurantMiniCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300], // Placeholder image bg
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: NetworkImage("https://placehold.co/100x100/png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "KFC",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const Text(
          "20% OFF",
          // Used Error color (Red) for discounts as it grabs attention
          style: TextStyle(fontSize: 10, color: AppColors.error, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}