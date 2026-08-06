import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/models.dart';
import '../widgets/common.dart';
import '../widgets/push_page.dart';
import 'article_detail_screen.dart';

/// 一比一还原 mobile.js App.openArticles()
/// 结构：.article-list-m(padding-top:8) + .comment-more（加载更多 / 没有更多了）
class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  final _api = ApiClient.instance;
  final List<Article> _items = [];
  int _page = 1;
  bool _loading = true;
  bool _hasMore = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _fetch(1);
  }

  Future<void> _fetch(int pg) async {
    if (pg == 1) setState(() => _loading = true);
    try {
      final list = await _api.getArticles(page: pg);
      if (!mounted) return;
      setState(() {
        if (pg == 1) _items.clear();
        _items.addAll(list);
        _page = pg;
        // articles.php 每页固定条数；返回满页即认为还有下一页
        _hasMore = list.isNotEmpty && list.length >= 10;
        _loading = false;
        _failed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (pg == 1) _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PushPage(title: '全部文章', child: _body());
  }

  Widget _body() {
    if (_loading) return const LoadingView(text: '加载中...');
    if (_failed) {
      return const EmptyView(icon: Icons.sentiment_dissatisfied, text: '加载失败');
    }
    if (_items.isEmpty) {
      return const EmptyView(icon: Icons.inbox, text: '暂无文章');
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        for (var i = 0; i < _items.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          ArticleRow(
            title: _items[i].title,
            thumbnail: _items[i].thumbnail,
            summary: _items[i].summary,
            views: _items[i].views,
            comments: _items[i].comments,
            isTop: _items[i].isTop,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ArticleDetailScreen(articleId: _items[i].id),
              ),
            ),
          ),
        ],
        TextMore(hasMore: _hasMore, onTap: () => _fetch(_page + 1)),
      ],
    );
  }
}
