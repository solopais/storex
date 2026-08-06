import 'package:flutter/material.dart';

/// 仿移动端 .toast：居中半透明黑底圆角提示
class Toast {
  static void show(BuildContext context, String msg) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;
    final entry = OverlayEntry(
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(msg,
              style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () {
      entry.remove();
    });
  }
}
