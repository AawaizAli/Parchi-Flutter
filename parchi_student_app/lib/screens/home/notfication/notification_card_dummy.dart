import 'package:flutter/material.dart';
import '../../../utils/colours.dart';
import '../../../widgets/home_screen_widgets/bonus_reward_card.dart';

class NotificationScreenDummy extends StatefulWidget {
  const NotificationScreenDummy({super.key});

  @override
  State<NotificationScreenDummy> createState() => _NotificationScreenDummyState();
}

class _NotificationScreenDummyState extends State<NotificationScreenDummy> {
  final bool _isEmpty = false;

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final ValueNotifier<double> _expandProgress = ValueNotifier(0.0);

  double _minSheetSize = 0.5;
  double _maxSheetSize = 0.95;

  // DUMMY DATA
  final List<RewardModel> _rewards = [
    RewardModel(
      restaurantName: "Gold Burger",
      currentCount: 4, // [CHANGED] Set to 4 to trigger "Almost There" state
      targetCount: 5,
      discountText: "Free Premium Meal",
      gradientColors: [const Color(0xFFFFD700), const Color(0xFFFFA500)],
      shadowColor: const Color(0xFFFFD700),
    ),
    RewardModel(
      restaurantName: "KFC",
      currentCount: 3,
      targetCount: 5,
      discountText: "Free Zinger",
      gradientColors: [const Color(0xFFFF3B30), const Color(0xFFFF2D55)],
      shadowColor: const Color(0xFFFF2D55),
    ),
    RewardModel(
      restaurantName: "Pizza Max",
      currentCount: 1,
      targetCount: 3,
      discountText: "Free Pizza",
      gradientColors: [const Color(0xFF007AFF), const Color(0xFF5856D6)],
      shadowColor: const Color(0xFF5856D6),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChanged);
  }

  void _onSheetChanged() {
    double currentSize = _sheetController.size;
    double progress =
        (currentSize - _minSheetSize) / (_maxSheetSize - _minSheetSize);
    _expandProgress.value = progress.clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double topPadding = MediaQuery.of(context).padding.top;

    final double headerHeight = topPadding + 20.0 + 45.0 + 20.0;
    const double cardHeight = 240.0;
    const double gap = 20.0;

    _minSheetSize =
        (screenHeight - (headerHeight + cardHeight + gap)) / screenHeight;

    if (_minSheetSize < 0.3) _minSheetSize = 0.3;
    if (_minSheetSize > 0.8) _minSheetSize = 0.8;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // [LAYER 1] Bonus Cards
          Positioned(
            top: headerHeight,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<double>(
              valueListenable: _expandProgress,
              builder: (context, progress, child) {
                return Opacity(
                  opacity: (1.0 - (progress * 3)).clamp(0.0, 1.0),
                  child: BonusRewardStack(rewards: _rewards),
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withOpacity(0.12),
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30)),
                  child: _isEmpty
                      ? _buildEmptyState()
                      : _buildNotificationList(scrollController),
                ),
              );
            },
          ),

          // [LAYER 3] Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.textPrimary.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            size: 20, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.backgroundLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_off_outlined,
                size: 64, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Notifications Yet",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            "We'll let you know when new discounts arrive!",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        _buildSectionHeader("New Updates"),
        _buildNotificationItem(
          brandName: "KFC",
          message: "Flash Sale! Get 50% OFF on Zinger Burgers tonight.",
          time: "2m ago",
          imageUrl: "https://placehold.co/100x100/png?text=KFC",
          isUnread: true,
        ),
        _buildNotificationItem(
          brandName: "Parchi",
          message: "You successfully redeemed a discount at Burger O'Clock.",
          time: "1h ago",
          imageUrl: "https://placehold.co/100x100/png?text=P",
          isUnread: true,
        ),
        const SizedBox(height: 20),
        _buildSectionHeader("Yesterday"),
        _buildNotificationItem(
          brandName: "Outfitters",
          message: "New Winter Collection is out. Students get flat 20% off.",
          time: "1d ago",
          imageUrl: "https://placehold.co/100x100/png?text=OUT",
          isUnread: false,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String brandName,
    required String message,
    required String time,
    required String imageUrl,
    required bool isUnread,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
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
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        height: 1.4),
                    children: [
                      TextSpan(
                        text: "$brandName ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: message),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color:
                        isUnread ? AppColors.primary : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          if (isUnread)
            Container(
              margin: const EdgeInsets.only(top: 8, left: 8),
              height: 8,
              width: 8,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
