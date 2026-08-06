import 'dart:math';
import 'package:flutter/material.dart';

/// 仿移动端 body::before/::after 的闪烁星空背景 + 流星（sky-shooter）
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
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _StarPainter(_stars, _ctrl.value),
            child: widget.child,
          ),
        ),
        const ShootingStars(),
      ],
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

/// 模仿移动端 .sky-shooter：几条白色渐变线，周期性从右上滑向左下并淡出
class ShootingStars extends StatefulWidget {
  const ShootingStars({super.key});

  @override
  State<ShootingStars> createState() => _ShootingStarsState();
}

class _ShootingStarsState extends State<ShootingStars>
    with TickerProviderStateMixin {
  late final List<_Shooter> _shooters = [
    _Shooter(top: 0.08, left: 0.5, width: 120, delay: 0.0, dur: 3.0),
    _Shooter(top: 0.15, left: 0.2, width: 90, delay: 1.2, dur: 3.5),
    _Shooter(top: 0.05, left: 0.7, width: 100, delay: 2.5, dur: 4.0),
  ];
  late final List<AnimationController> _ctrls;

  @override
  void initState() {
    super.initState();
    _ctrls = _shooters.map((s) {
      return AnimationController(
          vsync: this,
          duration: Duration(milliseconds: (s.dur * 1000).round()));
    }).toList();
    for (var i = 0; i < _ctrls.length; i++) {
      _ctrls[i].value = (_shooters[i].delay / _shooters[i].dur) % 1.0;
      _ctrls[i].repeat();
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return IgnorePointer(
      child: Stack(
        children: List.generate(_shooters.length, (i) {
          final s = _shooters[i];
          return AnimatedBuilder(
            animation: _ctrls[i],
            builder: (_, __) {
              final p = _ctrls[i].value;
              double opacity;
              if (p < 0.08) {
                opacity = p / 0.08;
              } else if (p < 0.18) {
                opacity = 1 - (p - 0.08) / 0.10;
              } else {
                opacity = 0;
              }
              return Positioned(
                top: s.top * h,
                left: s.left * w,
                child: Transform.translate(
                  offset: Offset(-400 * p, 250 * p),
                  child: Transform.rotate(
                    angle: -25 * pi / 180,
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        height: 2,
                        width: s.width.toDouble(),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class _Shooter {
  final double top;
  final double left;
  final double width;
  final double delay;
  final double dur;
  _Shooter({
    required this.top,
    required this.left,
    required this.width,
    required this.delay,
    required this.dur,
  });
}
