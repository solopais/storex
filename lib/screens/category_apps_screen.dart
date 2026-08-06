import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/models.dart';
import '../widgets/app_card.dart';
import 'app_detail_screen.dart';

class CategoryAppsScreen extends StatefulWidget {
  final Category category;
  const CategoryAppsScreen({super.key, required this.category});

  @override
  State<CategoryAppsScreen> createState() => _CategoryAppsScreenState();
}

class _CategoryAppsScreenState extends State<CategoryAppsScreen> {
  final List<App> _apps = [];
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    try {
      final list = await ApiClient.instance
          .getApps(categoryId: widget.category.id, page: _page);
      if (list.length < 20) _hasMore = false;
      setState(() => _apps.addAll(list));
      _page++;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('加载失败：$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name)),
      body: _apps.isEmpty && _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _apps.length + (_hasMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                if (i == _apps.length) {
                  _load();
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ));
                }
                final a = _apps[i];
                return AppCard(
                  app: a,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AppDetailScreen(appId: a.id)),
                  ),
                );
              },
            ),
    );
  }
}
