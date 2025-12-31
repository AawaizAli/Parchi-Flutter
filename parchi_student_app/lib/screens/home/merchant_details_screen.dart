import 'package:flutter/material.dart';
import '../../models/merchant_detail_model.dart';
import '../../utils/colours.dart';

class MerchantDetailsScreen extends StatelessWidget {
  final MerchantDetailModel merchant;

  const MerchantDetailsScreen({super.key, required this.merchant});

  @override
  Widget build(BuildContext context) {
    // Filter branches that have at least one offer
    final visibleBranches =
        merchant.branches.where((b) => b.offers.isNotEmpty).toList();
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // 1. Sticky Header with Stacked Logo & Title
          SliverAppBar(
            surfaceTintColor: AppColors.surface,
            pinned: true,
            floating: false,
            backgroundColor: AppColors.surface,
            elevation: 0,
            // [UPDATED] Increased height to fit stacked content
            toolbarHeight: 100, 
            centerTitle: true, // Centers the column horizontally
            leading: Container(
              alignment: Alignment.topLeft, // Keeps back button at top-left
              margin: const EdgeInsets.only(top: 8, left: 8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // [UPDATED] Changed Row to Column for stacking
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Logo on Top
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.surfaceVariant),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: merchant.logoPath != null
                        ? Image.network(
                            merchant.logoPath!,
                            fit: BoxFit.contain,
                            errorBuilder: (ctx, err, stack) => const Icon(
                                Icons.store,
                                size: 24,
                                color: AppColors.textSecondary),
                          )
                        : const Icon(Icons.store,
                            size: 24, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 8), // Vertical spacing
                // 2. Heading Below
                Text(
                  merchant.businessName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 2. Branches List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final branch = visibleBranches[index];
                return _buildBranchItem(branch);
              },
              childCount: visibleBranches.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildBranchItem(BranchModel branch) {
    // Get Base Offer (First offer)
    final String baseOffer = branch.offers.isNotEmpty
        ? branch.offers.first.formattedDiscount
        : "No Offers";

    final bonus = branch.bonusSettings;
    final int remaining = bonus != null 
        ? (bonus.nextGoal - (bonus.currentRedemptions ?? 0)) 
        : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branch Name & Area
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                branch.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                branch.address, 
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Base Offer
          Text(
            baseOffer,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          // Bonus Progress (if active)
          if (branch.bonusSettings != null &&
              branch.bonusSettings!.isActive) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.surfaceVariant),
            const SizedBox(height: 12),

            // Bonus Header & Progress Text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Redeem $remaining more times to unlock ${branch.bonusSettings!.discountDescription}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  "${branch.bonusSettings!.currentRedemptions ?? 0}/${branch.bonusSettings!.nextGoal}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: branch.bonusSettings!.cycleProgress,
                backgroundColor: AppColors.surfaceVariant,
                color: AppColors.primary,
                minHeight: 8,
              ),
            ),
          ],
        ],
      ),
    );
  }
}