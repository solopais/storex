import 'package:flutter/material.dart';
import '../theme.dart';

/// 一比一对应 mobile.css `.weather-bar` / mobile.js 的 #weatherBar
/// .weather-bar{padding:6px 16px;display:flex;align-items:center;gap:6px;
///   font-size:12px;color:var(--t3);background:rgba(255,255,255,.4);border-bottom:.5px solid var(--bd)}
/// 内容：「☁ 多云 21° 阵雨 40%」整行水平居中
class WeatherBar extends StatelessWidget {
  final String text;
  const WeatherBar({super.key, this.text = '☁ 多云 21°  阵雨 40%'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cardWhite.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(color: bd, width: 0.5),
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: t3,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
