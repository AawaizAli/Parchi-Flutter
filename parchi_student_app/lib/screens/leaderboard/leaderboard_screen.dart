import 'package:flutter/material.dart';
import '../../utils/colours.dart';
import '../../services/leaderboard_service.dart';
import '../../models/leaderboard_model.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/leaderboard_provider.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    // Data loading is handled by the provider's constructor init
  }

  Future<void> _loadMore() async {
    ref.read(leaderboardProvider.notifier).loadMore();
  }

  Future<void> _refresh() async {
    await ref.read(leaderboardProvider.notifier).refresh();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Leaderboard",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final state = ref.watch(leaderboardProvider);

    if (state.isLoading && state.items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.leaderboard_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No leaderboard data available',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    const double indicatorSize = 100.0;
    return CustomRefreshIndicator(
      onRefresh: _refresh,
      offsetToArmed: indicatorSize,
      builder: (BuildContext context, Widget child,
          IndicatorController controller) {
        return Stack(
          children: <Widget>[
            // 1. The Animated Custom Loader (Stays at the top)
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return SizedBox(
                  height: controller.value * indicatorSize,
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

            // 2. The Main Content (Pushes down as you drag)
            Transform.translate(
              offset: Offset(0.0, controller.value * indicatorSize),
              child: child,
            ),
          ],
        );
      },
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: state.items.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (context, index) {
          if (index < state.items.length - 1 ||
              (index == state.items.length - 1 && !state.hasMore)) {
            return const Divider(
              height: 1,
              thickness: 1.0,
              color: AppColors.surfaceVariant,
            );
          }
          return const SizedBox.shrink();
        },
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            // Load more indicator
            return _buildLoadMoreIndicator();
          }

          final item = state.items[index];
          return _buildLeaderboardItem(
            rank: item.rank,
            name: item.name,
            university: item.university,
            redemptions: item.redemptions,
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    final state = ref.watch(leaderboardProvider);
    if (!state.hasMore) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: state.isLoadingMore
          ? const CircularProgressIndicator()
          : GestureDetector(
              onTap: _loadMore,
              child: const Text(
                'Load More',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                ),
              ),
            ),
    );
  }

  Widget _buildLeaderboardItem({
    required int rank,
    required String name,
    required String university,
    required int redemptions,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: Text(
              "#$rank",
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Name & University
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  university,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Total Redemptions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$redemptions",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Redemptions",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- CUSTOM LOADER WIDGET ---
class ParchiLoader extends StatefulWidget {
  final bool isLoading;
  final double progress;

  const ParchiLoader(
      {super.key, required this.isLoading, required this.progress});

  @override
  State<ParchiLoader> createState() => _ParchiLoaderState();
}

class _ParchiLoaderState extends State<ParchiLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1), // Adjust speed here if needed
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(ParchiLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isLoading && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Rotation Logic:
        // Spin continuously if loading, or rotate based on pull distance
        final double rotationValue = widget.isLoading
            ? _controller.value * 2 * math.pi
            : widget.progress * 2 * math.pi;

        return Transform.rotate(
          angle: rotationValue,
          child: Image.asset(
            'assets/parchi-icon.png',
            width: 120,
            height: 120,
          ),
        );
      },
    );
  }
}