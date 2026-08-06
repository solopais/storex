import 'dart:ui';
import 'package:flutter/material.dart';

/// 一比一对应 mobile.css `.mobile-image-lightbox`
/// position:fixed;inset:0;padding:20px;background:rgba(15,23,42,.9);backdrop-filter:blur(8px)
/// img{max-width:100%;max-height:86vh;object-fit:contain;border-radius:14px;background:#fff;
///     box-shadow:0 18px 60px rgba(0,0,0,.45)}
/// .mil-close{top:calc(st+14px);right:16px;40x40;圆;border 1px rgba(255,255,255,.22);
///            background:rgba(255,255,255,.14);color:#fff;font-size:17px;blur(10px)}
void showImageLightbox(BuildContext context, String url) {
  if (url.isEmpty) return;
  Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, __, ___) => _Lightbox(url: url),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    ),
  );
}

class _Lightbox extends StatelessWidget {
  final String url;
  const _Lightbox({required this.url});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: const Color(0xE60F172A), // rgba(15,23,42,.9)
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: mq.size.height * 0.86,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        color: Colors.white,
                        child: Image.network(
                          url,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const SizedBox(
                            width: 120,
                            height: 120,
                            child: Icon(Icons.broken_image_outlined,
                                size: 40, color: Color(0xFF9CA3AF)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: mq.padding.top + 14,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x24FFFFFF), // rgba(255,255,255,.14)
                  border: Border.all(color: const Color(0x38FFFFFF)),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.close, size: 17, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
