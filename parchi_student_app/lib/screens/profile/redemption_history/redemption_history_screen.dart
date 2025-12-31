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
    // Dynamic layout calculation
    final double screenHeight = MediaQuery.of(context).size.height;
    final double topPadding = MediaQuery.of(context).padding.top;
    
    // Watch providers
    final statsAsync = ref.watch(redemptionStatsProvider);
    final historyAsync = ref.watch(redemptionHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // [LAYER 1] Animated Background / Header (The Stats)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.45, // Occupy top portion
            child: ValueListenableBuilder<double>(
              valueListenable: _expandProgress,
              builder: (context, progress, child) {
                return Opacity(
                  opacity: (1.0 - (progress * 2)).clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, -progress * 50),
                    child: _buildStatsBackground(),
                  ),
                );
              },
            ),
          ),

          // [LAYER 2] Draggable Sheet
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: _minSheetSize,
            minChildSize: _minSheetSize,
            maxChildSize: _maxSheetSize,
            snap: true,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Tabs
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      tabs: const [
                        Tab(text: "All Activity"),
                        Tab(text: "Monthly Statements"),
                      ],
                    ),
                    const Divider(height: 1),

                    // Content
                    Expanded(
                      child: historyAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => Center(
                            child: Text(err.toString(),
                                style: const TextStyle(color: AppColors.error))),
                        data: (allRedemptions) => TabBarView(
                          controller: _tabController,
                          children: [
                            RefreshIndicator(
                              onRefresh: _refresh,
                              child: _buildList(allRedemptions),
                            ),
                            RefreshIndicator(
                              onRefresh: _refresh,
                              child: _buildYearlyList(allRedemptions),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // [LAYER 3] Custom Back Button at the very top
          

          // Title next to back button
          Positioned(
            top: topPadding + 20,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                "Redemption History",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBackground() {
    final statsAsync = ref.watch(redemptionStatsProvider);
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, Color(0xFF2A5298)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text("TOTAL REDEMPTIONS",
              style: TextStyle(
                  color: Colors.white70,
                  letterSpacing: 1.5,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          statsAsync.when(
            data: (stats) => Text(
              "${stats.totalRedemptions}",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56, // Larger for emphasis
                  fontWeight: FontWeight.bold),
            ),
            loading: () => const Text("...",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.bold)),
            error: (_, __) => const Text("-",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          // Secondary Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeaderStatItem(
                label: "Bonuses",
                value: statsAsync.value?.bonusesUnlocked.toString() ?? "-",
                icon: Icons.card_giftcard,
              ),
              const SizedBox(width: 24), // Spacing
              Container(width: 1, height: 30, color: Colors.white24), // Vertical Divider
              const SizedBox(width: 24), // Spacing
              _buildHeaderStatItem(
                label: "Rank",
                value: (statsAsync.value?.leaderboardPosition ?? 0) > 0 
                  ? "#${statsAsync.value!.leaderboardPosition}" 
                  : "-",
                icon: Icons.leaderboard,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStatItem({required String label, required String value, required IconData icon}) {
     return Row(
       children: [
         Icon(icon, color: Colors.white70, size: 16),
         const SizedBox(width: 8),
         Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text(value, 
               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
             ),
             Text(label.toUpperCase(),
               style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)
             ),
           ],
         )
       ],
     );
  }

  // Reuse existing list builders but adapt formatting if needed
  Widget _buildList(List<RedemptionModel> items) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildRedemptionCard(item);
      },
    );
  }

  Widget _buildYearlyList(List<RedemptionModel> allRedemptions) {
    if (allRedemptions.isEmpty) {
      return _buildEmptyState();
    }

    // 1. Group by Month
    final Map<String, List<RedemptionModel>> grouped = {};
    for (var r in allRedemptions) {
      final key = DateFormat('MMMM yyyy').format(r.redeemedAt);
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(r);
    }

    // 2. Sort Keys (Months) Descending
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final dateA = grouped[a]!.first.redeemedAt;
        final dateB = grouped[b]!.first.redeemedAt;
        return dateB.compareTo(dateA);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final monthKey = sortedKeys[index];
        final monthItems = grouped[monthKey]!;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: index == 0, // Expand first month by default
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text(
                monthKey,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 16),
              ),
              subtitle: Text("${monthItems.length} redemptions",
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children:
                  monthItems.map((item) => _buildRedemptionCard(item)).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history_toggle_off,
                size: 48, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          const Text("No redemptions yet",
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildRedemptionCard(RedemptionModel item) {
    // Condensed card style to fit list better
    final dateStr = DateFormat('MMM d, h:mm a').format(item.redeemedAt);
    final statusColor = item.status == 'APPROVED'
        ? AppColors.success
        : item.status == 'REJECTED'
            ? AppColors.error
            : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RedemptionDetailScreen(redemption: item),
              ));
        },
        child: Row(
          children: [
            // Icon
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                image: item.offer?.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(item.offer!.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item.offer?.imageUrl == null
                  ? Icon(Icons.local_offer, color: AppColors.primary, size: 24)
                  : null,
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.offer?.title ?? "Redemption",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.branchName ?? "Unknown Branch",
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Status/Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(dateStr,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 10)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
