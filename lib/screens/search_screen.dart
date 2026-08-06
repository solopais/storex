import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/models.dart';
import '../theme.dart';
import '../widgets/app_grid.dart';
import 'app_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;
  const SearchScreen({super.key, this.initialQuery = ''});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  List<App> _results = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _ctrl.text = widget.initialQuery;
    if (widget.initialQuery.trim().isNotEmpty) {
      _doSearch(widget.initialQuery);
    }
  }

  Future<void> _doSearch(String q) async {
    final query = q.trim();
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _loading = true);
    try {
      final list = await ApiClient.instance.search(query);
      setState(() => _results = list);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('搜索失败：$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: widget.initialQuery.isEmpty,
          decoration: const InputDecoration(
            hintText: '搜索应用',
            border: InputBorder.none,
          ),
          onSubmitted: _doSearch,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _doSearch(_ctrl.text),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? const Center(child: Text('输入关键词开始搜索', style: TextStyle(color: t3)))
              : ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    AppGrid(
                      apps: _results,
                      onTap: (a) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AppDetailScreen(appId: a.id),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
