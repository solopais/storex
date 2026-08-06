import 'package:flutter/material.dart';
import '../theme.dart';

/// 消息 Tab 占位（原生版暂未接入聊天，对应移动端「消息」）
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 48, color: t3),
            SizedBox(height: 16),
            Text('消息功能开发中',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt)),
            SizedBox(height: 8),
            Text('聊天功能将在后续版本上线',
                style: TextStyle(fontSize: 13, color: t3)),
          ],
        ),
      ),
    );
  }
}
