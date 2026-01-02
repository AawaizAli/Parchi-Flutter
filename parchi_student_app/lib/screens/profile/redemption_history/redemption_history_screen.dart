import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/colours.dart';
import '../../../models/redemption_model.dart';
import '../../../services/redemption_service.dart';
import 'redemption_detail_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/redemption_provider.dart';

class RedemptionHistoryScreen extends ConsumerStatefulWidget {
  const RedemptionHistoryScreen({super.key});

  @override
  ConsumerState<RedemptionHistoryScreen> createState() =>
      _RedemptionHistoryScreenState();
}

class _RedemptionHistoryScreenState extends ConsumerState<RedemptionHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final ValueNotifier<double> _expandProgress = ValueNotifier(0.0);

  // Sheet configuration
  final double _minSheetSize = 0.65;
  final double _maxSheetSize = 0.92;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _sheetController.addListener(_onSheetChanged);
  }

  void _onSheetChanged() {
    double currentSize = _sheetController.size;
    double progress =
        (currentSize - _minSheetSize) / (_maxSheetSize - _minSheetSize);
    _expandProgress.value = progress.clamp(0.0, 1.0);
  }

  Future<void> _refresh() async {
     ref.refresh(redemptionStatsProvider);
     ref.refresh(redemptionHistoryProvider);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers
    final statsAsync = ref.watch(redemptionStatsProvider);
    final historyAsync = ref.watch(redemptionHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.primary, // Matches top section
      appBar: AppBar(
        title: const Text('Redemption History',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. STATS HEADER (Primary Background)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
            child: statsAsync.when(
              data: (stats) => Column(
                children: [
                   const Text(
                    "TOTAL REDEMPTIONS",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${stats.totalRedemptions}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildHeaderStat("Visited", "${stats.totalRedemptions}"),
                      Container(width: 1, height: 24, color: Colors.white24),
                      _buildHeaderStat("Rewards", "${stats.bonusesUnlocked}"),
                      Container(width: 1, height: 24, color: Colors.white24),
                      _buildHeaderStat(
                          "Rank",
                          stats.leaderboardPosition > 0
                              ? "#${stats.leaderboardPosition}"
                              : "-"),
                    ],
                  ),
                ],
              ),
              loading: () => const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          // 2. LIST BODY (White Surface)
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: historyAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                    child: Text('Error: $err',
                        style: const TextStyle(color: AppColors.error))),
                data: (items) {
                  if (items.isEmpty) return _buildEmptyState();
                  return ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(30)),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const Divider(
                          height: 1, color: AppColors.surfaceVariant),
                      itemBuilder: (context, index) {
                        return _buildRedemptionNotificationItem(items[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Header Helpers ---
  Widget _buildHeaderStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // --- List Item (Notification Style) ---
  Widget _buildRedemptionNotificationItem(RedemptionModel item) {
    // Data extraction
    final merchantName = item.merchant?.businessName ?? item.offer?.merchant?.businessName ?? "Parchi Merchant";
    final branchName = item.branchName ?? "Unknown Branch";
    final logoUrl = item.merchant?.logoPath ?? item.offer?.merchant?.logoPath ?? item.offer?.imageUrl;
    final timeStr = DateFormat('MMM d').format(item.redeemedAt); // e.g. Oct 24
    
    // Status Logic
    final isApproved = item.status == 'APPROVED';
    final statusColor = isApproved
        ? AppColors.success
        : (item.status == 'REJECTED' ? AppColors.error : AppColors.primary);

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RedemptionDetailScreen(redemption: item),
            ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Circle Avatar (Logo)
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
                image: logoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(logoUrl), fit: BoxFit.cover)
                    : null,
              ),
              child: logoUrl == null
                  ? Icon(Icons.store, color: AppColors.textSecondary, size: 24)
                  : null,
            ),
            const SizedBox(width: 16),
            
            // 2. Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Merchant Name
                  Text(
                    merchantName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Branch Name
                  Text(
                    branchName,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // 3. Trailing Info (Time & Status)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeStr,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                // Small Status Dot or Text
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.status.toLowerCase(), // e.g. approved
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text("No redemption history yet",
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
