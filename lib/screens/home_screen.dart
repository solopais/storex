import 'dart:async';
import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/models.dart';
import '../globals.dart';
import '../theme.dart';
import '../widgets/app_grid.dart';
import '../widgets/common.dart';
import '../widgets/music_player.dart';
import 'app_detail_screen.dart';
import 'app_list_screen.dart';
import 'article_detail_screen.dart';
import 'articles_screen.dart';

/// 一比一还原 mobile.php #page-home
/// 结构顺序（严格照抄）：
///   .slide-wrap（轮播，230px 高，箭头 + 圆点 + 标题遮罩）
///   .search-bar（圆角999 + .search-btn 渐变紫）
///   .music-player（music_enabled 时）
///   #homeMain
///     ├ 热门排行 section-title + N 条 .app-item（rank r1/r2/r3）
///     ├ VIP专属 section-title + .app-grid（6 个 appCard($a,true)）
///     ├ 站内公告 section-title + .article-list-m（6 条）
///     └ 全部应用 section-title + .app-grid（12 个）+ .pagination
///   #homeSearchResults（搜索时替换 homeMain）
class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  final _api = ApiClient.instance;
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  late Future<_HomeData> _future;

  // 全部应用分页（mobile.php: LIMIT 12，tp = ceil(total/12)）
  List<App> _allApps = [];
  int _page = 1;
  int _totalPages = 1;
  bool _allLoading = false;

  // 内联搜索（mobile.php homeSearch / homeClearSearch）
  bool _searching = false;
  bool _searchLoading = false;
  List<App> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<_HomeData> _load() async {
    final results = await Future.wait([
      _api.getSlides(), // LIMIT 6
      _api.getAppsPaged(sort: 'hot', perPage: 10), // hot_limit 默认 10
      _api.getAppsPaged(sort: 'new', perPage: 6, vip: true), // VIP专属 6
      _api.getArticles(page: 1), // 站内公告 6
      _api.getAppsPaged(sort: 'new', page: 1, perPage: 12), // 全部应用 12/页
    ]);
    final all = results[4] as AppsPage;
    _allApps = all.items;
    _page = 1;
    _totalPages = all.totalPages < 1 ? 1 : all.totalPages;
    return _HomeData(
      slides: results[0] as List<Slide>,
      hot: (results[1] as AppsPage).items,
      vip: (results[2] as AppsPage).items,
      articles: (results[3] as List<Article>).take(6).toList(),
    );
  }

  Future<void> _loadAllApps(int pg) async {
    if (pg < 1 || pg > _totalPages || _allLoading) return;
    setState(() => _allLoading = true);
    try {
      final r = await _api.getAppsPaged(sort: 'new', page: pg, perPage: 12);
      if (!mounted) return;
      setState(() {
        _allApps = r.items;
        _page = pg;
        _totalPages = r.totalPages < 1 ? 1 : r.totalPages;
        _allLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _allLoading = false);
    }
  }

  Future<void> _doSearch() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _searching = true;
      _searchLoading = true;
      _searchResults = [];
    });
    try {
      final r = await _api.search(q, perPage: 30);
      if (!mounted) return;
      setState(() {
        _searchResults = r;
        _searchLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _searchLoading = false);
    }
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() {
      _searching = false;
      _searchResults = [];
    });
  }

  void _openApp(int id) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AppDetailScreen(appId: id)),
      );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_HomeData>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const LoadingView(text: '加载中...');
        }
        if (snap.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const EmptyView(
                    icon: Icons.sentiment_dissatisfied, text: '加载失败'),
                TextButton(
                  onPressed: () => setState(() => _future = _load()),
                  child: const Text('重试', style: TextStyle(color: pri)),
                ),
              ],
            ),
          );
        }
        final d = snap.data!;
        final musicOn = appConfig?.musicEnabled ?? false;

        return RefreshIndicator(
          color: pri,
          onRefresh: () async {
            _clearSearch();
            setState(() => _future = _load());
            await _future;
          },
          child: SingleChildScrollView(
            controller: _scrollCtrl,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (d.slides.isNotEmpty) _SlideWrap(slides: d.slides),
                _SearchBar(
                  controller: _searchCtrl,
                  onSubmit: _doSearch,
                  onClear: _clearSearch,
                ),
                if (musicOn) const MusicPlayer(),
                if (_searching)
                  _searchResultsView()
                else
                  _homeMain(d),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------- #homeMain ----------------

  Widget _homeMain(_HomeData d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 热门排行
        if (d.hot.isNotEmpty) ...[
          SectionTitle(
            text: '热门排行',
            icon: Icons.local_fire_department,
            iconColor: red,
            moreText: '全部',
            onMore: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AppListScreen(mode: AppListMode.hot)),
            ),
          ),
          for (var i = 0; i < d.hot.length; i++)
            AppListItem(
              rank: i + 1,
              index: i,
              title: d.hot[i].title,
              desc: d.hot[i].shortDesc.isNotEmpty
                  ? d.hot[i].shortDesc
                  : d.hot[i].categoryName,
              icon: d.hot[i].icon,
              metaWidget: AppMeta(
                  icon: Icons.download, text: wanFmt(d.hot[i].downloads)),
              onTap: () => _openApp(d.hot[i].id),
            ),
        ],

        // VIP专属
        if (d.vip.isNotEmpty) ...[
          SectionTitle(
            text: 'VIP专属',
            icon: Icons.diamond,
            iconColor: gold,
            moreText: '全部',
            onMore: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AppListScreen(mode: AppListMode.vip)),
            ),
          ),
          AppGrid(
            apps: d.vip,
            forceVipBadge: true,
            onTap: (a) => _openApp(a.id),
          ),
        ],

        // 站内公告
        if (d.articles.isNotEmpty) ...[
          SectionTitle(
            text: '站内公告',
            icon: Icons.newspaper,
            moreText: '全部',
            onMore: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ArticlesScreen()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
            child: Column(
              children: [
                for (var i = 0; i < d.articles.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  ArticleRow(
                    title: d.articles[i].title,
                    thumbnail: d.articles[i].thumbnail,
                    summary: d.articles[i].summary,
                    views: d.articles[i].views,
                    comments: d.articles[i].comments,
                    isTop: d.articles[i].isTop,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ArticleDetailScreen(articleId: d.articles[i].id),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],

        // 全部应用
        const SectionTitle(text: '全部应用', icon: Icons.grid_view_rounded),
        if (_allLoading)
          const LoadingView()
        else if (_allApps.isEmpty)
          const EmptyView(icon: Icons.inbox, text: '暂无应用')
        else
          AppGrid(apps: _allApps, onTap: (a) => _openApp(a.id)),
        Pagination(
          page: _page,
          totalPages: _totalPages,
          onChange: (p) {
            _loadAllApps(p);
            _scrollCtrl.animateTo(
              _scrollCtrl.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
        ),
      ],
    );
  }

  // ---------------- #homeSearchResults ----------------

  Widget _searchResultsView() {
    if (_searchLoading) return const LoadingView(text: '搜索中...');
    if (_searchResults.isEmpty) {
      return const EmptyView(
          icon: Icons.sentiment_dissatisfied, text: '未找到相关应用');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          text: '搜索结果',
          moreText: '✕ 清除',
          onMore: _clearSearch,
        ),
        for (var i = 0; i < _searchResults.length; i++)
          AppListItem(
            index: i,
            title: _searchResults[i].title,
            desc: _searchResults[i].shortDesc.isNotEmpty
                ? _searchResults[i].shortDesc
                : _searchResults[i].categoryName,
            icon: _searchResults[i].icon,
            metaWidget: _searchResults[i].isVip
                ? const AppMeta(icon: Icons.diamond, text: 'VIP')
                : null,
            onTap: () => _openApp(_searchResults[i].id),
          ),
      ],
    );
  }
}

class _HomeData {
  final List<Slide> slides;
  final List<App> hot;
  final List<App> vip;
  final List<Article> articles;
  _HomeData({
    required this.slides,
    required this.hot,
    required this.vip,
    required this.articles,
  });
}

/// .slide-wrap —— margin:0; radius:0（整宽出血）
/// .slide img{height:230px;object-fit:cover}
/// .slide-title{bottom;padding:12px 16px 40px;渐变遮罩;15/700}
/// .slide-arrow{32x32;圆;rgba(0,0,0,.35);left/right:10px}
/// .slide-dots{absolute bottom:12px;gap:5}
/// .slide-dot{16x3;radius2;白35%}  .active{8px;#fff}
/// 自动播放 3500ms（mobile.js: setInterval(next,3500)）
class _SlideWrap extends StatefulWidget {
  final List<Slide> slides;
  const _SlideWrap({required this.slides});

  @override
  State<_SlideWrap> createState() => _SlideWrapState();
}

class _SlideWrapState extends State<_SlideWrap> {
  final _ctrl = PageController();
  Timer? _timer;
  int _idx = 0;

  @override
  void initState() {
    super.initState();
    _startAuto();
  }

  void _startAuto() {
    _timer?.cancel();
    if (widget.slides.length <= 1) return;
    _timer = Timer.periodic(const Duration(milliseconds: 3500), (_) {
      if (!mounted) return;
      _go((_idx + 1) % widget.slides.length, auto: true);
    });
  }

  void _go(int i, {bool auto = false}) {
    if (!auto) _startAuto(); // 手动操作后重置计时（与 mobile.js 一致）
    _ctrl.animateToPage(
      i,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: _ctrl,
            itemCount: widget.slides.length,
            onPageChanged: (i) => setState(() => _idx = i),
            itemBuilder: (_, i) {
              final s = widget.slides[i];
              return Stack(
                fit: StackFit.expand,
                children: [
                  if (s.imageUrl.isNotEmpty)
                    Image.network(
                      s.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: bd),
                    )
                  else
                    Container(color: bd),
                  if (s.title.trim().isNotEmpty)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0xBF000000), Color(0x00000000)],
                          ),
                        ),
                        child: Text(
                          s.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(
                                  color: Color(0x80000000),
                                  blurRadius: 3,
                                  offset: Offset(0, 1)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // .slide-arrow
          if (widget.slides.length > 1) ...[
            Positioned(
              left: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: _arrow(Icons.chevron_left, () {
                  final n =
                      (_idx - 1 + widget.slides.length) % widget.slides.length;
                  _go(n);
                }),
              ),
            ),
            Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: _arrow(Icons.chevron_right, () {
                  _go((_idx + 1) % widget.slides.length);
                }),
              ),
            ),
            // .slide-dots
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < widget.slides.length; i++)
                    GestureDetector(
                      onTap: () => _go(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                        margin: EdgeInsets.only(
                            right: i == widget.slides.length - 1 ? 0 : 5),
                        width: _idx == i ? 8 : 16,
                        height: 3,
                        decoration: BoxDecoration(
                          color: _idx == i
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _arrow(IconData ic, VoidCallback on) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: on,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(ic, size: 16, color: Colors.white),
        ),
      ),
    );
  }
}

/// .search-bar{margin:12px 16px;radius999;padding:6px 6px 6px 14px;shadow 0 2px 8px rgba(0,0,0,.04)}
/// .search-bar i{16px;t3}  input{14px}  ::placeholder{#B8BEC8}
/// .search-btn{h32;padding:0 18px;radius999;渐变 pri→#7C3AED;13/600}
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(999),
        boxShadow: softShadow,
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 16, color: t3),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onSubmit(),
              onChanged: (v) {
                if (v.trim().isEmpty) onClear();
              },
              style: const TextStyle(fontSize: 14, color: txt),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: '搜索应用...',
                hintStyle: TextStyle(fontSize: 14, color: Color(0xFFB8BEC8)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSubmit,
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [pri, purple],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                '搜索',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
