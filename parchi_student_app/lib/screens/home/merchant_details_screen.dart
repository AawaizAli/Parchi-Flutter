import 'package:flutter/material.dart';
import '../../models/merchant_detail_model.dart';
import '../../utils/colours.dart';

class MerchantDetailsScreen extends StatelessWidget {
  final MerchantDetailModel merchant;

  const MerchantDetailsScreen({super.key, required this.merchant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // 1. Sliver App Bar with Banner
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // Calculate expansion percentage
                // 200 is expandedHeight, kToolbarHeight is collapsed height (~56)
                // t goes from 1.0 (fully expanded) to 0.0 (fully collapsed)
                final double t = ((constraints.maxHeight - kToolbarHeight) /
                        (200.0 - kToolbarHeight))
                    .clamp(0.0, 1.0);

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // 1. Background Image
                    merchant.bannerUrl != null
                        ? Image.network(
                            merchant.bannerUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              color: AppColors.primary.withOpacity(0.1),
                              child: const Icon(Icons.image_not_supported,
                                  color: AppColors.textSecondary),
                            ),
                          )
                        : Container(
                            color: AppColors.primary.withOpacity(0.1),
                            child: const Center(
                              child: Icon(Icons.store,
                                  color: AppColors.textSecondary, size: 64),
                            ),
                          ),

                    // 2. Gradient Overlay (Bottom Fade)
                    // Always present to make text readable when expanded
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),

                    // 3. Dark Overlay on Scroll
                    // Darkens the whole header as it collapses
                    Container(
                      color: Colors.black.withOpacity((1 - t) * 0.8),
                    ),

                    // 4. Logo (Fades out as t -> 0)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Opacity(
                        opacity: t,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: AppColors.backgroundLight),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: merchant.logoPath != null
                                ? Image.network(
                                    merchant.logoPath!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (ctx, err, stack) =>
                                        const Icon(Icons.store,
                                            color: AppColors.textSecondary),
                                  )
                                : const Icon(Icons.store,
                                    color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ),

                    // 5. Title (Moves from Left -> Center)
                    Align(
                      alignment: Alignment.lerp(
                        Alignment.bottomLeft,
                        Alignment.center,
                        1 - t,
                      )!,
                      child: Padding(
                        padding: EdgeInsets.only(
                          // When expanded (t=1), left padding is 92 (16 + 60 + 16)
                          // When collapsed (t=0), left padding is 0 (centered)
                          left: (16.0 + 60.0 + 16.0) * t,
                          bottom: 30.0 * t, // Move up slightly when expanded
                        ),
                        child: Text(
                          merchant.businessName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16 + (4 * t), // 16 -> 20
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // 2. Branches List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final branch = merchant.branches[index];
                return _buildBranchItem(branch);
              },
              childCount: merchant.branches.length,
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
                branch.address, // Using address as Area for now
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
          if (branch.bonusSettings != null && branch.bonusSettings!.isActive) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.surfaceVariant),
            const SizedBox(height: 12),
            
            // Bonus Header & Progress Text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Bonus: ${branch.bonusSettings!.discountDescription}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
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
