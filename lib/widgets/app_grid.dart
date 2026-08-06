import 'package:flutter/material.dart';
import '../api/models.dart';
import 'app_card.dart';

/// 一比一对应 mobile.css：
/// .app-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:10px;padding:0 16px;margin-bottom:16px}
class AppGrid extends StatelessWidget {
  final List<App> apps;
  final ValueChanged<App> onTap;
  final bool forceVipBadge; // appCard($a, true) —— VIP专属区块强制显示 VIP 徽章
  final EdgeInsetsGeometry padding;

  const AppGrid({
    super.key,
    required this.apps,
    required this.onTap,
    this.forceVipBadge = false,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 132, // 14+52+10+18+4+14 ≈ .app-card 实际高度
      ),
      itemCount: apps.length,
      itemBuilder: (_, i) => AppCard(
        app: apps[i],
        forceVip: forceVipBadge,
        onTap: () => onTap(apps[i]),
      ),
    );
  }
}
