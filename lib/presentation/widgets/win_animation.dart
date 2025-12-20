import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Lightweight confetti animation for win state
class WinAnimation extends StatefulWidget {
  final bool isActive;

  const WinAnimation({
    super.key,
    required this.isActive,
  });

  @override
  State<WinAnimation> createState() => _WinAnimationState();
}

class _WinAnimationState extends State<WinAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _createParticles();
  }

  void _createParticles() {
    final random = math.Random();
    _particles.clear();
    _controllers = [];
    _animations = [];

    for (int i = 0; i < 50; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 2000 + random.nextInt(1000)),
        vsync: this,
      );

      final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOut,
        ),
      );

      _particles.add(Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        color: _getRandomColor(random),
        angle: random.nextDouble() * 2 * math.pi,
        speed: 0.5 + random.nextDouble() * 0.5,
      ));

      _controllers.add(controller);
      _animations.add(animation);
    }
  }

  Color _getRandomColor(math.Random random) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  void didUpdateWidget(WinAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      for (final controller in _controllers) {
        controller.repeat();
      }
    } else if (!widget.isActive && oldWidget.isActive) {
      for (final controller in _controllers) {
        controller.stop();
        controller.reset();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        painter: ConfettiPainter(
          particles: _particles,
          animations: _animations,
        ),
        size: MediaQuery.of(context).size,
      ),
    );
  }
}

class Particle {
  final double x;
  final double y;
  final Color color;
  final double angle;
  final double speed;

  Particle({
    required this.x,
    required this.y,
    required this.color,
    required this.angle,
    required this.speed,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<Particle> particles;
  final List<Animation<double>> animations;

  ConfettiPainter({
    required this.particles,
    required this.animations,
  }) : super(repaint: Listenable.merge(animations));

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < particles.length; i++) {
      final particle = particles[i];
      final progress = animations[i].value;

      final x = particle.x * size.width +
          math.cos(particle.angle) * particle.speed * size.width * progress;
      final y = particle.y * size.height +
          math.sin(particle.angle) * particle.speed * size.height * progress;

      final paint = Paint()
        ..color = particle.color.withOpacity(1.0 - progress)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, y),
          width: 8,
          height: 8,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}

