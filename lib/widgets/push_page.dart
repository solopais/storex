import 'package:flutter/material.dart';
import '../theme.dart';
import 'starfield.dart';

/// 一比一对应 mobile 的 `.page.push` 二级页：
/// .app-header{padding:12px 16px;padding-top:calc(12px + safe-area);min-height:44px;background:--bg}
/// .back-btn{32x32;圆;白;18px;shadow 0 1px 3px rgba(0,0,0,.08);margin-right:12}
/// .title{17/700}
class PushPage extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> actions;
  final bool starfield;
  final Color background;

  const PushPage({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
    this.starfield = true,
    this.background = appBg,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          if (starfield) const Positioned.fill(child: StarfieldBackground()),
          Column(
            children: [
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 44),
                padding: EdgeInsets.fromLTRB(16, 12 + top, 16, 12),
                child: Row(
                  children: [
                    _BackBtn(onTap: () => Navigator.of(context).maybePop()),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: txt),
                      ),
                    ),
                    ...actions,
                  ],
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _BackBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cardWhite,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 3,
                  offset: Offset(0, 1)),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.chevron_left, size: 18, color: txt),
        ),
      ),
    );
  }
}
