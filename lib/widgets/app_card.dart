import 'package:flutter/material.dart';
import '../api/models.dart';
import '../theme.dart';
import 'common.dart';

/// 一比一对应 mobile.php 的 appCard() + mobile.css 的 .app-card
/// .app-card{radius16;padding:14px 10px;居中;box-shadow:0 1px 3px rgba(0,0,0,.04)}
/// .app-card-icon(-ph){52x52;radius14;margin-bottom:10}
/// .app-card-icon-ph 渐变固定为 linear-gradient(135deg,#6B7280,#4B5563)（见 mobile.php 内联样式）
/// .app-card-name{13/700} .app-card-desc{10;t3;margin-top:4}
/// .app-card-badge{top:8;right:8;9px/700;padding:2px 6px;radius4}
/// .vip{linear-gradient(135deg,#1E1E2E,#16213E);color:--goldl}  .free{--grnb;#065F46}
class AppCard extends StatelessWidget {
  final App app;
  final bool forceVip;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.app,
    this.forceVip = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cardWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NetImg(
                      url: app.icon,
                      width: 52,
                      height: 52,
                      radius: 14,
                      placeholder: InitialBox(
                        text: app.title,
                        size: 52,
                        radius: 14,
                        fontSize: 22,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF6B7280), Color(0xFF4B5563)],
                        ),
                      ),
                    ),
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
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      app.shortDesc.isEmpty ? 'v${app.version}' : app.shortDesc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 10, color: t3, height: 1.25),
                    ),
                  ],
                ),
              ),
              Positioned(top: 8, right: 8, child: _badge()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge() {
    final vip = forceVip || app.isVip;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: vip ? vipGradient : null,
        color: vip ? null : grnB,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        vip ? 'VIP' : '免费',
        style: TextStyle(
          color: vip ? goldL : vipText,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
    );
  }
}
