import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api_client.dart';
import '../api/auth_service.dart';
import '../api/models.dart';
import '../theme.dart';
import 'login_screen.dart';

class AppDetailScreen extends StatefulWidget {
  final int appId;
  const AppDetailScreen({super.key, required this.appId});

  @override
  State<AppDetailScreen> createState() => _AppDetailScreenState();
}

class _AppDetailScreenState extends State<AppDetailScreen> {
  late Future<App> _future;
  bool _fav = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<App> _load() async {
    final a = await ApiClient.instance.getApp(widget.appId);
    _fav = a.isFavorite;
    return a;
  }

  Future<void> _toggleFav(App app) async {
    if (!AuthService.instance.isLoggedIn) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }
    try {
      final fav = await ApiClient.instance.toggleFavorite(app.id);
      setState(() => _fav = fav);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      appBar: AppBar(title: const Text('应用详情')),
      body: FutureBuilder<App>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('加载失败：${snap.error}'));
          }
          final a = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  a.icon.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(a.icon,
                              width: 72, height: 72, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _phIcon()),
                        )
                      : _phIcon(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.title,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800, color: txt)),
                        const SizedBox(height: 4),
                        Text(a.developer, style: const TextStyle(color: t2)),
                        if (a.isVip)
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: vipGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('VIP 专享',
                                style: TextStyle(color: goldL, fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Stat(label: '版本', value: a.version),
                  _Stat(label: '大小', value: a.fileSizeText),
                  _Stat(label: '下载', value: '${a.downloads}'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: primaryGradient,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: ElevatedButton(
                        onPressed: a.fileUrl.isEmpty ? null : () => _openLink(a.fileUrl),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                        ),
                        child: const Text('下载'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => _toggleFav(a),
                    child: Icon(
                      _fav ? Icons.favorite : Icons.favorite_border,
                      color: pri,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('简介',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: txt)),
              const SizedBox(height: 8),
              Text(
                a.description?.isNotEmpty == true ? a.description! : a.shortDesc,
                style: const TextStyle(height: 1.5, color: txt),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _phIcon() => Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          gradient: primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.android, size: 36, color: Colors.white),
      );

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('无法打开链接：$url')));
    }
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: txt)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: t2, fontSize: 12)),
        ],
      ),
    );
  }
}
