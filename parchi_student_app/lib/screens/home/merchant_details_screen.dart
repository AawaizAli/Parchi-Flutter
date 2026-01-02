import 'package:flutter/material.dart';
import '../../models/merchant_detail_model.dart';
import '../../utils/colours.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../../widgets/common/parchi_refresh_loader.dart';
import '../../widgets/common/blinking_skeleton.dart';
import '../../providers/merchants_provider.dart';

class MerchantDetailsScreen extends ConsumerWidget {
  final MerchantDetailModel merchant;

  const MerchantDetailsScreen({super.key, required this.merchant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Filter branches that have at least one offer
    final visibleBranches =
        merchant.branches.where((b) => b.offers.isNotEmpty).toList();
    Future<void> refresh() async {
      return ref.refresh(merchantDetailsProvider(merchant.id).future);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      // 1. Fixed AppBar (Header) that stays on top
      appBar: AppBar(
        surfaceTintColor: AppColors.surface,
        backgroundColor: AppColors.surface,
        elevation: 0,
        toolbarHeight: 100, // Matches previous height
        centerTitle: true,
        leading: Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.only(top: 8, left: 8),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
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
            const SizedBox(height: 8),
            // Heading
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

      // 2. Refreshable List Body
      body: CustomRefreshIndicator(
        onRefresh: refresh,
        offsetToArmed: 100.0,
        builder: (BuildContext context, Widget child,
            IndicatorController controller) {
          return Stack(
            children: <Widget>[
              AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  return SizedBox(
                    height: controller.value * 100.0,
                    width: double.infinity,
                    child: Center(
                      child: ParchiLoader(
                        isLoading: controller.isLoading,
                        progress: controller.value,
                      ),
                    ),
                  );
                },
              ),
              Transform.translate(
                offset: Offset(0.0, controller.value * 100.0),
                child: child,
              ),
            ],
          );
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 40),
          itemCount: visibleBranches.length,
          itemBuilder: (context, index) {
            final branch = visibleBranches[index];
            // Ensure container margin acts nicely in list view
            return _buildBranchItem(branch);
          },
        ),
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

class MerchantDetailsSkeleton extends StatelessWidget {
  const MerchantDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        surfaceTintColor: AppColors.surface,
        backgroundColor: AppColors.surface,
        elevation: 0,
        toolbarHeight: 100,
        centerTitle: true,
        leading: Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.only(top: 8, left: 8),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Skeleton Logo
            BlinkingSkeleton(
              width: 45,
              height: 45,
              borderRadius: 10,
              baseColor: Colors.grey.withOpacity(0.2),
            ),
            const SizedBox(height: 8),
            // Skeleton Name
            BlinkingSkeleton(
              width: 150,
              height: 16,
              baseColor: Colors.grey.withOpacity(0.2),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 20),
        itemCount: 4,
        itemBuilder: (context, index) => _buildSkeletonItem(),
      ),
    );
  }

  Widget _buildSkeletonItem() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BlinkingSkeleton(
                  width: 120, height: 16, baseColor: Colors.grey.withOpacity(0.1)),
              BlinkingSkeleton(
                  width: 80, height: 14, baseColor: Colors.grey.withOpacity(0.1)),
            ],
          ),
          const SizedBox(height: 12),
          BlinkingSkeleton(
              width: 100, height: 14, baseColor: Colors.grey.withOpacity(0.1)),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.surfaceVariant),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: BlinkingSkeleton(
                    width: double.infinity,
                    height: 14,
                    baseColor: Colors.grey.withOpacity(0.1)),
              ),
              const SizedBox(width: 16),
              BlinkingSkeleton(
                  width: 30, height: 12, baseColor: Colors.grey.withOpacity(0.1)),
            ],
          ),
          const SizedBox(height: 8),
          BlinkingSkeleton(
              width: double.infinity,
              height: 8,
              borderRadius: 4,
              baseColor: Colors.grey.withOpacity(0.1)),
        ],
      ),
    );
  }
}