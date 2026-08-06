import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/auth_service.dart';
import '../api/models.dart';
import '../theme.dart';
import 'app_detail_screen.dart';
import 'login_screen.dart';

class MeScreen extends StatefulWidget {
  const MeScreen({super.key});

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> {
  late Future<_MeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_MeData> _load() async {
    final api = ApiClient.instance;
    final user = await api.me();
    final favs = await api.getFavorites();
    return _MeData(user: user, favorites: favs);
  }

  void _goLogin() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    if (res == true && mounted) setState(() => _future = _load());
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (mounted) setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthService.instance.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('我的')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_outline, size: 64, color: softGrey),
              const SizedBox(height: 16),
              const Text('未登录', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _goLogin,
                child: const Text('登录 / 注册'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          TextButton(onPressed: _logout, child: const Text('退出')),
        ],
      ),
      body: FutureBuilder<_MeData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('加载失败：${snap.error}'));
          }
          final d = snap.data!;
          final u = d.user;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: kleinBlue,
                child: Text(
                  u.username.isNotEmpty ? u.username[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),
              Text(u.username,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              u.isVip
                  ? const Text('VIP 会员', style: TextStyle(color: kleinBlue))
                  : const Text('普通用户', style: TextStyle(color: softGrey)),
              const SizedBox(height: 24),
              const Text('我的收藏',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if (d.favorites.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('还没有收藏', style: TextStyle(color: softGrey)),
                ),
              ...d.favorites.map(
                (a) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: a.icon.isNotEmpty
                      ? Image.network(a.icon,
                          width: 40,
                          height: 40,
                          errorBuilder: (_, __, ___) => const Icon(Icons.android))
                      : const Icon(Icons.android),
                  title: Text(a.title),
                  subtitle: Text(a.version),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AppDetailScreen(appId: a.id)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MeData {
  final User user;
  final List<App> favorites;
  _MeData({required this.user, required this.favorites});
}
