import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/push_page.dart';
import 'app_detail_screen.dart';

enum AppListMode { hot, vip }

/// 一比一还原 /mobile/ajax/hot.php 与 /mobile/ajax/vip.php 渲染的二级页
/// 结构：.hot-page-head + .hot-list(.app-item xN) + .load-more-wrap
/// 每页 20 条（$per = 20）
class AppListScreen extends StatefulWidget {
  final AppListMode mode;
  const AppListScreen({super.key, required this.mode});

  @override
  State<AppListScreen> createState() => _AppListScreenState();
}

class _AppListScreenState extends State<AppListScreen> {
  final _api = ApiClient.instance;
  final List<App> _items = [];
  int _page = 1;
  int _totalPages = 1;
  bool _loading = true;
  bool _more = false;
  bool _failed = false;

  bool get _isHot => widget.mode == AppListMode.hot;

  @override
  void initState() {
    super.initState();
    _fetch(1);
  }

  Future<void> _fetch(int pg) async {
    setState(() {
      if (pg == 1) _loading = true;
      _more = pg > 1;
    });
    try {
      final r = await _api.getAppsPaged(
        page: pg,
        perPage: 20,
        sort: _isHot ? 'hot' : 'new',
        vip: _isHot ? null : true,
      );
      if (!mounted) return;
      setState(() {
        if (pg == 1) _items.clear();
        _items.addAll(r.items);
        _page = pg;
        _totalPages = r.totalPages < 1 ? 1 : r.totalPages;
        _loading = false;
        _more = false;
        _failed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _more = false;
        if (pg == 1) _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PushPage(
      title: _isHot ? '热门排行' : 'VIP专属',
      child: _body(),
    );
  }

  Widget _body() {
    if (_loading) return const LoadingView();
    if (_failed) {
      return const EmptyView(icon: Icons.sentiment_dissatisfied, text: '加载失败');
    }
    if (_items.isEmpty) {
      return EmptyView(icon: Icons.inbox, text: _isHot ? '暂无热门应用' : '暂无VIP应用');
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // .hot-page-head
        HotPageHead(
          icon: _isHot ? Icons.local_fire_department : Icons.diamond,
          iconColor: _isHot ? red : const Color(0xFFF59E0B),
          iconBg: _isHot
              ? const Color(0x1AEF4444)
              : const Color(0x1AF59E0B),
          title: _isHot ? '热门排行' : 'VIP专属',
          sub: _isHot ? '按下载热度排序' : '会员专享应用合集',
        ),
        // .hot-list
        for (var i = 0; i < _items.length; i++)
          AppListItem(
            // hot.php 带全局排名；vip.php 无 rank
            rank: _isHot ? i + 1 : null,
            index: i,
            title: _items[i].title,
            desc: _items[i].shortDesc.isNotEmpty
                ? _items[i].shortDesc
                : _items[i].categoryName,
            icon: _items[i].icon,
            // vip.php 占位图为橙金渐变 #F59E0B→#D97706
            placeholderGradient: _isHot
                ? null
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
            metaWidget: _isHot
                ? AppMeta(
                    icon: Icons.download, text: wanFmt(_items[i].downloads))
                : const AppMeta(icon: Icons.diamond, text: 'VIP'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AppDetailScreen(appId: _items[i].id)),
            ),
          ),
        const SizedBox(height: 4),
        if (_page < _totalPages || _more)
          LoadMore(
            hasMore: true,
            loading: _more,
            page: _page,
            totalPages: _totalPages,
            onTap: () => _fetch(_page + 1),
          )
        else
          const LoadMore(
            hasMore: false,
            loading: false,
            page: 1,
            totalPages: 1,
            onTap: _noop,
          ),
      ],
    );
  }
}

void _noop() {}
