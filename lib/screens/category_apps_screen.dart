import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/models.dart';
import '../theme.dart';
import '../widgets/app_grid.dart';
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
      backgroundColor: appBg,
      appBar: AppBar(title: Text(widget.category.name)),
      body: _apps.isEmpty && _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                AppGrid(
                  apps: _apps,
                  onTap: (a) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AppDetailScreen(appId: a.id),
                    ),
                  ),
                ),
                if (_hasMore)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _loading
                          ? const CircularProgressIndicator()
                          : OutlinedButton(
                              onPressed: _load,
                              child: const Text('加载更多'),
                            ),
                    ),
                  ),
              ],
            ),
    );
  }
}
