import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/auth_service.dart';
import '../api/models.dart';
import '../theme.dart';
import '../widgets/app_grid.dart';
import 'app_detail_screen.dart';
import 'login_screen.dart';

class MeBody extends StatefulWidget {
  const MeBody({super.key});

  @override
  State<MeBody> createState() => _MeBodyState();
}

class _MeBodyState extends State<MeBody> {
  late Future<_MeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
    AuthService.instance.authNotifier.addListener(_onAuthChange);
  }

  @override
  void dispose() {
    AuthService.instance.authNotifier.removeListener(_onAuthChange);
    super.dispose();
  }

  void _onAuthChange() {
    if (mounted) setState(() => _future = _load());
  }

  Future<_MeData> _load() async {
    if (!AuthService.instance.isLoggedIn) {
      return _MeData(user: null, favorites: const []);
    }
    final api = ApiClient.instance;
    final user = await api.me();
    final favs = await api.getFavorites();
    return _MeData(user: user, favorites: favs);
  }

  void _goLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_MeData>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final d = snap.data!;
        if (d.user == null) return _LoggedOut(onLogin: _goLogin);
        return _LoggedIn(
          user: d.user!,
          favorites: d.favorites,
          onLogout: _logout,
          onOpen: (a) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AppDetailScreen(appId: a.id),
            ),
          ),
        );
      },
    );
  }
}

class _MeData {
  final User? user;
  final List<App> favorites;
  _MeData({required this.user, required this.favorites});
}

class _LoggedOut extends StatelessWidget {
  final VoidCallback onLogin;
  const _LoggedOut({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: const BoxDecoration(gradient: primaryGradient),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 36, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text('未登录',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('登录后查看收藏与会员', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onLogin,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text('登录 / 注册',
                  style: TextStyle(color: purple, fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoggedIn extends StatelessWidget {
  final User user;
  final List<App> favorites;
  final VoidCallback onLogout;
  final ValueChanged<App> onOpen;

  const _LoggedIn({
    required this.user,
    required this.favorites,
    required this.onLogout,
    required this.onOpen,
  });

  /// 移动端「我的」页 header 深紫渐变（.me-header）
  static const _meGrad = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1E1B4B), Color(0xFF4C1D95), Color(0xFF7C3AED)],
  );

  @override
  Widget build(BuildContext context) {
    final initial =
        user.username.isNotEmpty ? user.username[0].toUpperCase() : '?';
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 28),
            decoration: const BoxDecoration(gradient: _meGrad),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      child: Text(initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                    // 金色 VIP 小星角标
                    if (user.isVip)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [goldL, gold],
                            ),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Icon(Icons.star,
                              size: 12, color: Color(0xFF5B4300)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(user.username,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                user.isVip
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFF7D774), Color(0xFFC9A54B)],
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text('VIP 会员',
                            style: TextStyle(
                                color: Color(0xFF3B2A00),
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text('普通用户',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ),
              ],
            ),
          ),
          // 统计卡（-60 上移压住 header 底部，与移动端一致）
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Container(
              margin: const EdgeInsets.only(top: -28),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 10,
                      offset: Offset(0, 3)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _Stat(
                        label: '我的收藏', value: '${favorites.length}'),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                const Text('我的收藏',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: txt)),
                const Spacer(),
                if (favorites.isNotEmpty)
                  Text('${favorites.length} 个',
                      style: const TextStyle(fontSize: 12, color: t3)),
              ],
            ),
          ),
          favorites.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text('还没有收藏', style: TextStyle(color: t3)),
                )
              : AppGrid(apps: favorites, onTap: onOpen),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: onLogout,
              child: const Text('退出登录'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
        ],
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: txt)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: t3)),
        ],
      ),
    );
  }
}
