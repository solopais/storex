import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/models.dart';
import '../theme.dart';
import '../widgets/app_grid.dart';
import 'app_detail_screen.dart';
import 'category_apps_screen.dart';
import 'search_screen.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HomeData> _load() async {
    final api = ApiClient.instance;
    final results = await Future.wait([
      api.getConfig(),
      api.getCategories(),
      api.getSlides(),
      api.getApps(sort: 'hot', perPage: 20),
    ]);
    return _HomeData(
      config: results[0] as SiteConfig,
      categories: results[1] as List<Category>,
      slides: results[2] as List<Slide>,
      hotApps: results[3] as List<App>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_HomeData>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('加载失败：${snap.error}'),
                TextButton(
                  onPressed: () => setState(() => _future = _load()),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }
        final d = snap.data!;
        return RefreshIndicator(
          onRefresh: () async => setState(() => _future = _load()),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Hero(config: d.config),
                _SearchPill(onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                )),
                if (d.slides.isNotEmpty) _Slides(slides: d.slides),
                _CategoryRow(
                  categories: d.categories,
                  onTap: (c) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryAppsScreen(category: c),
                    ),
                  ),
                ),
                const _SectionTitle(title: '热门应用', more: '更多'),
                AppGrid(
                  apps: d.hotApps,
                  onTap: (a) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AppDetailScreen(appId: a.id),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HomeData {
  final SiteConfig config;
  final List<Category> categories;
  final List<Slide> slides;
  final List<App> hotApps;
  _HomeData({
    required this.config,
    required this.categories,
    required this.slides,
    required this.hotApps,
  });
}

class _Hero extends StatelessWidget {
  final SiteConfig config;
  const _Hero({required this.config});

  @override
  Widget build(BuildContext context) {
    final title = config.siteTitle.isNotEmpty ? config.siteTitle : 'Store X';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 44, 20, 24),
      decoration: const BoxDecoration(
        gradient: primaryGradient,
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: config.siteLogo.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(config.siteLogo, fit: BoxFit.cover),
                  )
                : const Icon(Icons.storefront,
                    size: 28, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              )),
          const SizedBox(height: 4),
          const Text('精选热门应用 · 安全下载',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        height: 44,
        padding: const EdgeInsets.only(left: 16, right: 6),
        decoration: BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: t3, size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('搜索应用',
                  style: TextStyle(color: t3, fontSize: 14)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              decoration: const BoxDecoration(
                gradient: primaryGradient,
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
              child: const Text('搜索',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slides extends StatefulWidget {
  final List<Slide> slides;
  const _Slides({required this.slides});

  @override
  State<_Slides> createState() => _SlidesState();
}

class _SlidesState extends State<_Slides> {
  final _ctrl = PageController();
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          height: 170,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: bd,
          ),
          clipBehavior: Clip.antiAlias,
          child: PageView.builder(
            controller: _ctrl,
            itemCount: widget.slides.length,
            onPageChanged: (i) => setState(() => _idx = i),
            itemBuilder: (_, i) {
              final s = widget.slides[i];
              return s.imageUrl.isNotEmpty
                  ? Image.network(s.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Center(child: Icon(Icons.image, size: 40)))
                  : const Center(child: Icon(Icons.image, size: 40));
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.slides.length,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _idx == i ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _idx == i ? pri : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final List<Category> categories;
  final ValueChanged<Category> onTap;
  const _CategoryRow({required this.categories, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemBuilder: (_, i) {
          final c = categories[i];
          return GestureDetector(
            onTap: () => onTap(c),
            child: SizedBox(
              width: 60,
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: c.icon.isNotEmpty
                        ? Image.network(c.icon, fit: BoxFit.cover)
                        : Center(
                            child: Text(c.name.isNotEmpty ? c.name[0] : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                )),
                          ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11, color: t2),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? more;
  const _SectionTitle({required this.title, this.more});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: txt,
              )),
          const Spacer(),
          if (more != null)
            Text(more!,
                style: const TextStyle(fontSize: 12, color: t3)),
        ],
      ),
    );
  }
}
