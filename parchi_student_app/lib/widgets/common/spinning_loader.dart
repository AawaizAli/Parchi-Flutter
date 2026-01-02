import 'package:flutter/material.dart';
import 'dart:math' as math;

class SpinningLoader extends StatefulWidget {
  final double size;
  final Color? color; 

  const SpinningLoader({super.key, this.size = 24.0, this.color});

  @override
  State<SpinningLoader> createState() => _SpinningLoaderState();
}

class _SpinningLoaderState extends State<SpinningLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
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
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: Image.asset(
            'assets/parchi-icon.png',
            width: widget.size,
            height: widget.size,
            // If the icon needs tinting, we can add color here, but usually the icon is full color.
            // color: widget.color, 
          ),
        );
      },
    );
  }
}
