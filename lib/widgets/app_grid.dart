import 'package:flutter/material.dart';
import '../api/models.dart';
import '../widgets/app_card.dart';

/// 匹配移动端 .app-card 网格（3 列）
class AppGrid extends StatelessWidget {
  final List<App> apps;
  final ValueChanged<App> onTap;
  final EdgeInsetsGeometry padding;

  const AppGrid({
    super.key,
    required this.apps,
    required this.onTap,
    this.padding = const EdgeInsets.fromLTRB(12, 8, 12, 8),
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemCount: apps.length,
      itemBuilder: (_, i) => AppCard(
        app: apps[i],
        onTap: () => onTap(apps[i]),
      ),
    );
  }
}
