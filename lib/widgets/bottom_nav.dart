import 'package:flutter/material.dart';
import '../theme.dart';

/// 匹配移动端 .bottom-nav（56px、毛玻璃、激活靛蓝、4 Tab：推荐/发现/消息/我的）
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int? messageBadge;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.messageBadge,
  });

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_outlined, active: Icons.home, label: '推荐'),
    _NavItem(icon: Icons.explore_outlined, active: Icons.explore, label: '发现'),
    _NavItem(
        icon: Icons.chat_bubble_outline, active: Icons.chat_bubble, label: '消息'),
    _NavItem(icon: Icons.person_outline, active: Icons.person, label: '我的'),
  ];

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding.bottom;
    return Container(
      height: 56 + pad,
      padding: EdgeInsets.only(bottom: pad),
      decoration: BoxDecoration(
        color: const Color(0xF2FFFFFF),
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.08), width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_items.length, (i) {
          final active = i == currentIndex;
          final it = _items[i];
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        active ? it.active : it.icon,
                        size: 22,
                        color: active ? pri : t3,
                      ),
                      if (i == 2 &&
                          messageBadge != null &&
                          messageBadge! > 0)
                        Positioned(
                          top: -4,
                          right: -10,
                          child: Container(
                            height: 16,
                            constraints: const BoxConstraints(minWidth: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                messageBadge! > 99
                                    ? '99+'
                                    : '$messageBadge',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    it.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? pri : t3,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData active;
  final String label;
  const _NavItem(
      {required this.icon, required this.active, required this.label});
}
