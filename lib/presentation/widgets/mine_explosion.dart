import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Lightweight explosion animation for mine hit
class MineExplosion extends StatefulWidget {
  final bool isActive;
  final Offset position;

  const MineExplosion({
    super.key,
    required this.isActive,
    required this.position,
  });

  @override
  State<MineExplosion> createState() => _MineExplosionState();
}

class _MineExplosionState extends State<MineExplosion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void didUpdateWidget(MineExplosion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ExplosionPainter(
            scale: _scaleAnimation.value,
            opacity: _opacityAnimation.value,
          ),
          size: Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height,
          ),
        );
      },
    );
  }
}

class ExplosionPainter extends CustomPainter {
  final double scale;
  final double opacity;

  ExplosionPainter({
    required this.scale,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 30.0 * scale;

    // Outer glow
    final outerPaint = Paint()
      ..color = Colors.orange.withOpacity(opacity * 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 1.5, outerPaint);

    // Middle ring
    final middlePaint = Paint()
      ..color = Colors.red.withOpacity(opacity * 0.6)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, middlePaint);

    // Inner core
    final innerPaint = Paint()
      ..color = Colors.yellow.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.5, innerPaint);

    // Particles
    for (int i = 0; i < 20; i++) {
      final angle = (i / 20) * 2 * math.pi;
      final distance = radius * 0.8;
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;

      final particlePaint = Paint()
        ..color = Colors.orange.withOpacity(opacity * 0.8)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 3, particlePaint);
    }
  }

  @override
  bool shouldRepaint(ExplosionPainter oldDelegate) =>
      oldDelegate.scale != scale || oldDelegate.opacity != opacity;
}

