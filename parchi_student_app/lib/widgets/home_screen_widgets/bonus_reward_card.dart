import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/colours.dart';
import '../../screens/home/notfication/gold_unlock_screen.dart'; 
import '../../providers/user_provider.dart';

class RewardModel {
  final String restaurantName;
  final int currentCount;
  final int targetCount;
  final String discountText;
  final List<Color> gradientColors;
  final Color shadowColor;

  RewardModel({
    required this.restaurantName,
    required this.currentCount,
    required this.targetCount,
    required this.discountText,
    required this.gradientColors,
    required this.shadowColor,
  });
}

class BonusRewardStack extends StatefulWidget {
  final List<RewardModel> rewards;
  const BonusRewardStack({super.key, required this.rewards});

  @override
  State<BonusRewardStack> createState() => _BonusRewardStackState();
}

class _BonusRewardStackState extends State<BonusRewardStack> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 0.0,
      lowerBound: -1.0,
      upperBound: 1.0,
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.rewards.length;
        });
        _animationController.value = 0.0; 
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    double delta = details.primaryDelta! / -250;
    _animationController.value += delta;
  }

  void _onDragEnd(DragEndDetails details) {
    double velocity = details.primaryVelocity ?? 0;
    double currentVal = _animationController.value;

    if (currentVal > 0) {
      if (velocity < -800 || currentVal > 0.4) {
        _animationController.animateTo(1.0, curve: Curves.easeOut);
      } else {
        _animationController.animateTo(0.0, curve: Curves.easeOut);
      }
    } else {
      if (velocity > 800 || currentVal < -0.4) {
        _animationController.animateTo(-1.0, curve: Curves.easeOut);
      } else {
        _animationController.animateTo(0.0, curve: Curves.easeOut);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rewards.isEmpty) return const SizedBox.shrink();

    final int totalItems = widget.rewards.length;
    final int renderCount = totalItems > 3 ? 3 : totalItems;

    return Center(
      child: SizedBox(
        height: 240,
        child: GestureDetector(
          onVerticalDragUpdate: _onDragUpdate,
          onVerticalDragEnd: _onDragEnd,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.topCenter,
                children: List.generate(renderCount, (i) {
                  final int stackPos = (renderCount - 1) - i;
                  final int dataIndex = (_currentIndex + stackPos) % totalItems;
                  final reward = widget.rewards[dataIndex];

                  return _buildAnimatedCard(
                    stackPos: stackPos,
                    reward: reward,
                    animationValue: _animationController.value,
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({
    required int stackPos,
    required RewardModel reward,
    required double animationValue,
  }) {
    double yOffset;
    double scale;
    double opacity = 1.0;
    double rotation = 0.0;
    
    final double absProgress = animationValue.abs();
    final double staticY = stackPos * 15.0;
    final double staticScale = 1.0 - (stackPos * 0.05);

    if (stackPos == 0) {
      yOffset = staticY - (300 * animationValue);
      opacity = (1.0 - (absProgress * 1.5)).clamp(0.0, 1.0);
      scale = staticScale + (0.05 * absProgress);
      rotation = animationValue * 0.1; 
    } else {
      final int targetStackPos = stackPos - 1;
      final double targetY = targetStackPos * 15.0;
      final double targetScale = 1.0 - (targetStackPos * 0.05);

      yOffset = lerpDouble(staticY, targetY, absProgress)!;
      scale = lerpDouble(staticScale, targetScale, absProgress)!;
    }

    return Positioned(
      top: yOffset,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: rotation,
          child: Transform.scale(
            scale: scale,
            child: SingleBonusCard(
              reward: reward,
              isTopCard: stackPos == 0,
            ),
          ),
        ),
      ),
    );
  }
}

class SingleBonusCard extends ConsumerWidget {
  final RewardModel reward;
  final bool isTopCard;

  const SingleBonusCard({
    super.key,
    required this.reward,
    required this.isTopCard,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double progress = (reward.currentCount / reward.targetCount).clamp(0.0, 1.0);
    final bool isCompleted = reward.currentCount >= reward.targetCount;
    final bool isAlmostThere = reward.currentCount == (reward.targetCount - 1);
    
    final width = MediaQuery.of(context).size.width - 48;

    // Use special colors if it's in "Hype Mode" (4/5 or 5/5)
    final bool isSpecialState = isCompleted || isAlmostThere;

    final List<Color> bgColors = isSpecialState 
        ? [const Color(0xFFDAA520), const Color(0xFFFFD700)] 
        : reward.gradientColors;
    
    final Color glowColor = isSpecialState 
        ? const Color(0xFFFFD700)
        : reward.shadowColor;

    Widget cardContent = Container(
      height: 180,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: bgColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.6),
            blurRadius: isSpecialState ? 40 : 35,
            spreadRadius: isSpecialState ? 5 : -2, 
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isCompleted ? "GOLD REWARD READY" : (isAlmostThere ? "ALMOST THERE!" : "Loyalty Reward"),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: isSpecialState ? 1.0 : 0,
                    decoration: TextDecoration.none,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "#${reward.restaurantName}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCompleted ? Icons.emoji_events : Icons.card_giftcard, 
                    color: Colors.white, 
                    size: 20
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCompleted ? "Reward Unlocked!" : "Unlock ${reward.discountText}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isCompleted 
                          ? "Tap to view details" 
                          : (isAlmostThere ? "Avail 1 more time to unlock a free meal" : "${reward.currentCount} out of ${reward.targetCount} orders completed"),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
                          fontWeight: isAlmostThere ? FontWeight.bold : FontWeight.normal,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Stack(
              children: [
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD60A),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD60A).withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (isCompleted || isAlmostThere) ? "Tap to View" : "View History",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
              ],
            ),
          ],
        ),
      ),
    );

    Widget heroWrapper = isTopCard 
      ? Hero(
          tag: 'reward_${reward.restaurantName}',
          child: Material(color: Colors.transparent, child: cardContent),
        )
      : cardContent;

    return GestureDetector(
      // [UPDATED] Allow tap if completed OR almost there (4/5)
      onTap: () {
        if ((isCompleted || isAlmostThere) && isTopCard) {
          final user = ref.read(userProfileProvider).value;
          final fName = user?.firstName ?? "Student";
          final lName = user?.lastName ?? "";
          final realName = "$fName $lName".trim().toUpperCase();
          final realId = user?.parchiId ?? "PENDING";

          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false, 
              transitionDuration: const Duration(milliseconds: 800),
              reverseTransitionDuration: const Duration(milliseconds: 600),
              pageBuilder: (_, __, ___) => GoldUnlockScreen(
                reward: reward,
                studentName: realName.isEmpty ? "STUDENT" : realName, 
                studentId: realId,
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      },
      child: heroWrapper,
    );
  }
}