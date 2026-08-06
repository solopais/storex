import 'dart:math';
import 'package:flutter/material.dart';

/// 仿移动端 body::before/::after 的闪烁星空背景
class StarfieldBackground extends StatefulWidget {
  final Widget? child;
  const StarfieldBackground({super.key, this.child});

  @override
  State<StarfieldBackground> createState() => _StarfieldBackgroundState();
}

class _StarfieldBackgroundState extends State<StarfieldBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))
        ..repeat();
  late final List<_Star> _stars = _makeStars(90);

  static List<_Star> _makeStars(int n) {
    // 固定种子伪随机，避免每次 build 闪烁跳动
    var s = 20260806;
    int next() {
      s = (s * 1664525 + 1013904223) & 0x7fffffff;
      return s;
    }

    double rnd() => next() / 0x7fffffff;
    return List.generate(n, (_) {
      return _Star(
        x: rnd(),
        y: rnd(),
        r: 0.5 + rnd() * 1.2,
        phase: rnd() * 2 * pi,
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _StarPainter(_stars, _ctrl.value),
        child: widget.child,
      ),
    );
  }
}

class _Star {
  final double x;
  final double y;
  final double r;
  final double phase;
  _Star({required this.x, required this.y, required this.r, required this.phase});
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double progress;
  _StarPainter(this.stars, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (final st in stars) {
      final a = 0.35 + 0.45 * (0.5 + 0.5 * sin(progress * 2 * pi + st.phase));
      paint.color = Colors.white.withOpacity(a);
      canvas.drawCircle(
        Offset(st.x * size.width, st.y * size.height),
        st.r,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter old) => true;
}
