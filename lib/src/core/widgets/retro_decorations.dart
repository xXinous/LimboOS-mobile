
import 'dart:math';
import 'package:flutter/material.dart';

class RetroDecorations extends StatelessWidget {
  final Widget child;
  
  const RetroDecorations({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        const ScanlinesOverlay(),
        const NoiseOverlay(),
        const CRTFilter(),
      ],
    );
  }
}

class ScanlinesOverlay extends StatelessWidget {
  const ScanlinesOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.05),
            ],
            stops: const [0.5, 0.5],
            tileMode: TileMode.repeated,
          ),
        ),
        // This is a rough approximation of the 4px background size in CSS
        // In Flutter, we'd ideally use a CustomPainter for perfect pixel control
      ),
    );
  }
}

class NoiseOverlay extends StatelessWidget {
  const NoiseOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Opacity(
        opacity: 0.03,
        child: CustomPaint(
          painter: _NoisePainter(),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  const _NoisePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42); // Fixed seed for consistent noise pattern
    final paint = Paint()..style = PaintingStyle.fill;
    const step = 4.0;

    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        final gray = rng.nextInt(256);
        paint.color = Color.fromARGB(rng.nextInt(60), gray, gray, gray);
        canvas.drawRect(Rect.fromLTWH(x, y, step, step), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CRTFilter extends StatelessWidget {
  const CRTFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.2),
            ],
            stops: const [0.6, 1.0],
          ),
        ),
      ),
    );
  }
}

class ScanlineAnimation extends StatefulWidget {
  const ScanlineAnimation({super.key});

  @override
  State<ScanlineAnimation> createState() => _ScanlineAnimationState();
}

class _ScanlineAnimationState extends State<ScanlineAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
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
        return Positioned(
          top: MediaQuery.of(context).size.height * (_controller.value * 6 - 1),
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            color: const Color(0xFFFF8C00).withValues(alpha: 0.03),
          ),
        );
      },
    );
  }
}
