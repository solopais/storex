import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../widgets/starfield.dart';
import '../widgets/bottom_nav.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'messages_screen.dart';
import 'me_screen.dart';

/// 主壳：底部 4 Tab 导航 + 星空背景（对应移动端 home/categories/messages/profile）
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  final List<Widget> _pages = const [
    HomeBody(),
    CategoriesScreen(),
    MessagesScreen(),
    MeBody(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: appBg,
        body: SafeArea(
          top: true,
          bottom: false,
          child: Stack(
            children: [
              const StarfieldBackground(),
              Column(
                children: [
                  Expanded(
                    child: IndexedStack(
                      index: _tab,
                      children: _pages,
                    ),
                  ),
                  BottomNavBar(
                    currentIndex: _tab,
                    onTap: (i) => setState(() => _tab = i),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
