import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../../utils/colours.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/redemption_provider.dart';

// =========================================================
// 1. ENTRY POINT
// =========================================================
class ParchiCard extends StatelessWidget {
  final String studentName;
  final String studentId;
  final bool isGolden; // [NEW] Gold Mode Flag

  const ParchiCard({
    super.key,
    this.studentName = "AAWAIZ ALI",
    this.studentId = "PK-12345",
    this.isGolden = false, // Default is standard
  });

  @override
  Widget build(BuildContext context) {
    // Define Gradients
    final standardGradient = const LinearGradient(
      colors: [AppColors.backgroundDark, AppColors.primary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final goldGradient = const LinearGradient(
      colors: [
        AppColors.goldStart, // Goldenrod
        AppColors.goldMid, // Gold
        AppColors.goldEnd, // Dark Goldenrod
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: [0.1, 0.5, 0.9],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(PageRouteBuilder(
            opaque: false,
            barrierDismissible: true,
            barrierColor: AppColors.textPrimary.withOpacity(0.87),
            transitionDuration: const Duration(milliseconds: 600),
            reverseTransitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) {
              return FadeTransition(
                opacity: animation,
                child: ParchiCardDetail(
                  studentName: studentName,
                  studentId: studentId,
                  isGolden: isGolden, // Pass state to detail view
                ),
              );
            },
          ));
        },
        child: Hero(
          tag: isGolden ? 'gold-parchi-card' : 'parchi-card-hero',
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: isGolden ? goldGradient : standardGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isGolden
                        ? AppColors.goldShadow.withOpacity(0.6)
                        : AppColors.primary.withOpacity(0.3),
                    blurRadius: isGolden ? 20 : 10,
                    spreadRadius: isGolden ? 2 : 0,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CardFrontContent(
                studentName: studentName,
                studentId: studentId,
                isGolden: isGolden,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================
// 2. DETAIL VIEW
// =========================================================
class ParchiCardDetail extends ConsumerStatefulWidget {
  final String studentName;
  final String studentId;
  final bool isGolden;

  const ParchiCardDetail({
    super.key,
    required this.studentName,
    required this.studentId,
    this.isGolden = false,
  });

  @override
  ConsumerState<ParchiCardDetail> createState() => _ParchiCardDetailState();
}

// enum BackFaceView removed as we only show current month

class _ParchiCardDetailState extends ConsumerState<ParchiCardDetail>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  bool _isFront = true;

  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOutBack,
    ));

    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _hoverAnimation =
        Tween<double>(begin: -10, end: 10).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOutSine,
    ));
  }

  void _flipCard() {
    if (_isFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    _isFront = !_isFront;
  }

  // Swipe handler removed

  Future<void> _handleClose() async {
    if (!_isFront) {
      _flipCard();
      await Future.delayed(const Duration(milliseconds: 600));
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleClose,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: GestureDetector(
            onTap: _flipCard,
            child: AnimatedBuilder(
              animation: Listenable.merge([_flipAnimation, _hoverAnimation]),
              builder: (context, child) {
                final angle = _flipAnimation.value * pi;
                final flipTransform = Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle);

                return Transform.translate(
                  offset: Offset(0, _hoverAnimation.value),
                  child: Transform(
                    transform: flipTransform,
                    alignment: Alignment.center,
                    child: Hero(
                      tag: widget.isGolden
                          ? 'gold-parchi-card'
                          : 'parchi-card-hero',
                      child: Material(
                        color: Colors.transparent,
                        child: angle < pi / 2
                            ? _buildFrontFace()
                            : Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(pi),
                                child: _buildBackFace(),
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrontFace() {
    final standardGradient = const LinearGradient(
      colors: [AppColors.backgroundDark, AppColors.primary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final goldGradient = const LinearGradient(
      colors: [AppColors.goldStart, AppColors.goldMid, AppColors.goldEnd],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      height: 220,
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        gradient: widget.isGolden ? goldGradient : standardGradient,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: widget.isGolden
                ? AppColors.goldShadow.withOpacity(0.6)
                : AppColors.primary.withOpacity(0.6),
            blurRadius: 40,
            spreadRadius: 10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: CardFrontContent(
        studentName: widget.studentName,
        studentId: widget.studentId,
        isGolden: widget.isGolden,
      ),
    );
  }

  Widget _buildBackFace() {
    // Keep back face standard for readability or make it dark gold
    return Container(
      height: 220,
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.backgroundDark, AppColors.textPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
            color: widget.isGolden
                ? AppColors.goldShadow
                : AppColors.primary.withOpacity(0.5),
            width: 1),
        boxShadow: [
          BoxShadow(
            color: widget.isGolden
                ? AppColors.goldShadow.withOpacity(0.3)
                : AppColors.primary.withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _buildBackContent(),
        ),
      ),
    );
  }

  Widget _buildBackContent() {
    return _buildCurrentMonthStats();
  }

  Widget _buildCurrentMonthStats() {
    final statsAsync = ref.watch(redemptionStatsProvider);

    return statsAsync.when(
      data: (stats) {
        final int usedCount = stats.totalRedemptions;
        const int totalCount = 20; // Hardcoded limit for now
        final String totalSaved =
            "PKR ${stats.totalSavings.toStringAsFixed(0)}";
        double progress = (usedCount / totalCount).clamp(0.0, 1.0);

        return Column(
          key: const ValueKey("CurrentMonth"),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator(
                          value: 1.0,
                          color: AppColors.textSecondary.withOpacity(0.1),
                          strokeWidth: 8,
                        ),
                      ),
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator(
                          value: progress,
                          color: AppColors.secondary,
                          strokeCap: StrokeCap.round,
                          strokeWidth: 8,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("$usedCount",
                              style: const TextStyle(
                                  color: AppColors.surface,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                          const Text("Used",
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("THIS MONTH",
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                              letterSpacing: 1)),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 5),
                      Text("Discounts: $usedCount/$totalCount",
                          style: const TextStyle(
                              color: AppColors.surface, fontSize: 16)),
                      const SizedBox(height: 5),
                      const Text("Total Saved:",
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                      Text(totalSaved,
                          style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        );
      },
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.secondary)),
      error: (err, stack) => Center(
          child: Text("Error loading stats",
              style: TextStyle(color: AppColors.error))),
    );
  }
}

// =========================================================
// 3. UI HELPER (Front Face Content)
// =========================================================
class CardFrontContent extends StatelessWidget {
  final String studentName;
  final String studentId;
  final bool isGolden; // [NEW]

  const CardFrontContent({
    super.key,
    required this.studentName,
    required this.studentId,
    this.isGolden = false,
  });

  @override
  Widget build(BuildContext context) {
    // Adjust colors for Gold Background readability
    final textColor = isGolden
        ? AppColors.textPrimary.withOpacity(0.87)
        : AppColors.textOnPrimary;
    final secondaryTextColor = isGolden
        ? AppColors.textPrimary.withOpacity(0.54)
        : AppColors.textOnPrimary.withOpacity(0.7);
    final iconColor = isGolden
        ? AppColors.textOnPrimary.withOpacity(0.3)
        : AppColors.surface.withOpacity(0.05);

    return Stack(
      children: [
        Positioned(
          right: -20,
          top: -20,
          child: Icon(
              isGolden ? Icons.emoji_events : Icons.school, // Trophy for gold
              size: 150,
              color: iconColor),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.nfc, color: textColor, size: 30),
                  Text(
                    isGolden ? "GOLD MEMBER" : "PARCHI STUDENT",
                    style: TextStyle(
                        color: secondaryTextColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentName,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: studentId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("ID copied to clipboard!"),
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isGolden
                            ? AppColors.textPrimary.withOpacity(0.12)
                            : AppColors.surface.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: isGolden
                                ? AppColors.textPrimary.withOpacity(0.12)
                                : Colors.white24,
                            width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "ID: $studentId",
                            style: TextStyle(
                                color: textColor,
                                fontSize: 12,
                                fontFamily: 'Courier',
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.copy, size: 12, color: secondaryTextColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
