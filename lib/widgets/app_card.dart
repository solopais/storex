import 'package:flutter/material.dart';
import '../api/models.dart';
import '../theme.dart';

/// 匹配移动端 .app-card：白卡、圆角16、竖排居中、VIP金/免费绿徽章
class AppCard extends StatelessWidget {
  final App app;
  final VoidCallback? onTap;

  const AppCard({super.key, required this.app, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cardWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _icon(),
                  const SizedBox(height: 10),
                  Text(
                    app.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: txt,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    app.shortDesc.isEmpty ? 'v${app.version}' : app.shortDesc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10, color: t3),
                  ),
                ],
              ),
            ),
            Positioned(top: 8, right: 8, child: _badge()),
          ],
        ),
      ),
    );
  }

  Widget _badge() {
    if (app.isVip) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          gradient: vipGradient,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text('VIP',
            style: TextStyle(color: goldL, fontSize: 9, fontWeight: FontWeight.w700)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: grnB, borderRadius: BorderRadius.circular(4)),
      child: const Text('免费',
          style: TextStyle(color: vipText, fontSize: 9, fontWeight: FontWeight.w700)),
    );
  }

  Widget _icon() {
    final ph = Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          app.title.isNotEmpty ? app.title[0] : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
    if (app.icon.isEmpty) return ph;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        app.icon,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => ph,
        loadingBuilder: (_, child, p) {
          if (p == null) return child;
          return SizedBox(
            width: 52,
            height: 52,
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: pri),
              ),
            ),
          );
        },
      ),
    );
  }
}
