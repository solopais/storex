import 'package:flutter/material.dart';

/// 匹配移动端 mobile.css 的设计令牌（靛蓝/紫渐变 + 星空底 + 金 VIP）

/// 主色：靛蓝
const Color pri = Color(0xFF6366F1);
const Color pri2 = Color(0xFF4F46E5);
/// 渐变终点：紫
const Color purple = Color(0xFF7C3AED);
/// VIP 金
const Color gold = Color(0xFFC9A54B);
const Color goldL = Color(0xFFF7D774);
/// 页面背景（浅灰）
const Color appBg = Color(0xFFF2F3F7);
/// 卡片/白
const Color cardWhite = Color(0xFFFFFFFF);
/// 文字层级
const Color txt = Color(0xFF1F2937);
const Color t2 = Color(0xFF6B7280);
const Color t3 = Color(0xFF9CA3AF);
/// 边框
const Color bd = Color(0xFFE5E7EB);
/// 状态色
const Color red = Color(0xFFEF4444);
const Color grn = Color(0xFF10B981);
const Color grnB = Color(0xFFD1FAE5);
const Color redB = Color(0xFFFEE2E2);
/// 主色浅底
const Color priL = Color(0xFFEEF2FF);
/// VIP 徽章深底
const Color vipDark1 = Color(0xFF1E1E2E);
const Color vipDark2 = Color(0xFF16213E);
const Color vipText = Color(0xFF065F46);

/// 主渐变（hero / 按钮 / 图标）
const LinearGradient primaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [pri, purple],
);

/// VIP 徽章渐变
const LinearGradient vipGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [vipDark1, vipDark2],
);

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: appBg,
  primaryColor: pri,
  colorScheme: ColorScheme.fromSeed(
    seedColor: pri,
    primary: pri,
    secondary: gold,
    surface: cardWhite,
    onSurface: txt,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: cardWhite,
    foregroundColor: txt,
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    titleTextStyle: TextStyle(
      color: txt,
      fontSize: 17,
      fontWeight: FontWeight.w700,
    ),
    iconTheme: IconThemeData(color: txt),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: txt),
    titleMedium: TextStyle(color: txt, fontWeight: FontWeight.w600),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: pri,
      foregroundColor: Colors.white,
      minimumSize: const Size(0, 46),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: pri,
      side: BorderSide(color: pri),
      minimumSize: const Size(0, 46),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: bd)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: bd)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: pri)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  ),
  cardTheme: CardThemeData(
    color: cardWhite,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
);
