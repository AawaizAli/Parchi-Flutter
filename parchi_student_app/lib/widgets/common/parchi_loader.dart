import 'package:flutter/material.dart';
import 'dart:math' as math;

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
