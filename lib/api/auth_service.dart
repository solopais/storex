import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 轻量登录态管理：仅保存 API token（用于需要鉴权的接口）
class AuthService {
  static final AuthService instance = AuthService._();

  AuthService._();

  String? _token;

  /// 登录态版本号：登录/退出时自增，供「我的」页监听刷新
  final authNotifier = ValueNotifier<int>(0);

  String? get token => _token;

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('api_token');
  }

  Future<void> setToken(String? t) async {
    _token = t;
    final prefs = await SharedPreferences.getInstance();
    if (t == null || t.isEmpty) {
      await prefs.remove('api_token');
    } else {
      await prefs.setString('api_token', t);
    }
    authNotifier.value++;
  }

  Future<void> logout() async {
    await setToken(null);
  }
}
