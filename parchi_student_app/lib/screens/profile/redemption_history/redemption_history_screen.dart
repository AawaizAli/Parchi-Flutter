import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/colours.dart';
import '../../../models/redemption_model.dart';
import '../../../services/redemption_service.dart';
import 'redemption_detail_screen.dart';

class RedemptionHistoryScreen extends StatefulWidget {
  const RedemptionHistoryScreen({super.key});

  @override
  State<RedemptionHistoryScreen> createState() =>
      _RedemptionHistoryScreenState();
}

class _RedemptionHistoryScreenState extends State<RedemptionHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<RedemptionModel> _allRedemptions = [];
  RedemptionStats? _stats;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        redemptionService.getRedemptions(), // Fetch all initially
        redemptionService.getStats(),
      ]);

      setState(() {
        _allRedemptions = results[0] as List<RedemptionModel>;
        _stats = results[1] as RedemptionStats;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll("Exception: ", "");
          _isLoading = false;
        });
      }
    }
  }

  // Helper removed as we don't need status filtering anymore for tabs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Redemption History',
            style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Yearly"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(_error!,
                      style: const TextStyle(color: AppColors.error)))
              : Column(
                  children: [
                    if (_stats != null) _buildStatsHeader(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildList(_allRedemptions),
                          _buildYearlyList(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  // --- YEARLY VIEW IMPLEMENTATION ---
  Widget _buildYearlyList() {
    if (_allRedemptions.isEmpty) {
      return _buildList([]); // Show empty state
    }

    // 1. Group by Month (e.g., "December 2025")
    final Map<String, List<RedemptionModel>> grouped = {};
    for (var r in _allRedemptions) {
      final key = DateFormat('MMMM yyyy').format(r.redeemedAt);
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(r);
    }

    // 2. Sort Keys (Months) Descending
    // We need to parse back to sort correctly, or rely on insert order if data is sorted (it usually is from API).
    // Let's force sort by sorting the keys based on the first item's date.
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final dateA = grouped[a]!.first.redeemedAt;
        final dateB = grouped[b]!.first.redeemedAt;
        return dateB.compareTo(dateA); // Descending
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final monthKey = sortedKeys[index];
        final monthItems = grouped[monthKey]!;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text(
                monthKey,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              children:
                  monthItems.map((item) => _buildRedemptionCard(item)).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Total Savings",
              "Rs. ${_stats!.totalSavings.toStringAsFixed(0)}"),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
          _buildStatItem("Redemptions", "${_stats!.totalRedemptions}"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style:
                TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
      ],
    );
  }

  Widget _buildList(List<RedemptionModel> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history,
                size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text("No redemptions found",
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildRedemptionCard(item);
      },
    );
  }

  Widget _buildRedemptionCard(RedemptionModel item) {
    final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(item.redeemedAt);
    Color statusColor = item.status == 'APPROVED'
        ? AppColors.success
        : item.status == 'REJECTED'
            ? AppColors.error
            : AppColors.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.textSecondary.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RedemptionDetailScreen(redemption: item),
              ));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.backgroundLight,
                  image: item.offer?.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(item.offer!.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: item.offer?.imageUrl == null
                    ? const Icon(Icons.confirmation_number,
                        color: AppColors.textSecondary)
                    : null,
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.offer?.title ?? "Redemption",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.branchName ??
                          item.offer?.merchant?.businessName ??
                          "Mergechant",
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(dateStr,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              // Status Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.status,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (item.isBonusApplied) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: Colors.orange.withOpacity(0.5),
                              width: 0.5)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 8, color: Colors.orange),
                          SizedBox(width: 2),
                          Text("BONUS",
                              style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ]
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
