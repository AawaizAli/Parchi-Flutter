import 'package:flutter/material.dart';

class BlinkingSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color baseColor;

  const BlinkingSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.baseColor = const Color(0x40FFFFFF), // Subtle translucent white
  });

  @override
  State<BlinkingSkeleton> createState() => _BlinkingSkeletonState();
}

class _BlinkingSkeletonState extends State<BlinkingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.baseColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }
}
