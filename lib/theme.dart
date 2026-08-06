import 'package:flutter/material.dart';

/// 国际克莱因蓝 + 纯白 的高对比编辑风主题
const Color kleinBlue = Color(0xFF002FA7);
const Color inkBlack = Color(0xFF1A1A1A);
const Color softGrey = Color(0xFF8A8A8A);

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.white,
  primaryColor: kleinBlue,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kleinBlue,
    primary: kleinBlue,
    background: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: kleinBlue,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: inkBlack,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    ),
    iconTheme: IconThemeData(color: kleinBlue),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: inkBlack),
    titleMedium: TextStyle(color: inkBlack, fontWeight: FontWeight.w600),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kleinBlue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: Colors.grey.shade200),
      borderRadius: BorderRadius.zero,
    ),
  ),
);
