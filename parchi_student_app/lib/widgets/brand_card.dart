import 'package:flutter/material.dart';
import '../utils/colours.dart';

class BrandCard extends StatelessWidget {
  final String name;
  final String image;
  final String time;

  const BrandCard({
    super.key,
    required this.name,
    required this.image,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, // Fixed width for consistent carousel items
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          // Logo Box
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: AppColors.backgroundLight),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.network(
                  image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.restaurant, color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Brand Name
          Text(
            name,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Delivery Time
          Text(
            time,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}