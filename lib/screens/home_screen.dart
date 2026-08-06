import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/auth_service.dart';
import '../api/models.dart';
import '../theme.dart';
import '../widgets/app_card.dart';
import 'app_detail_screen.dart';
import 'category_apps_screen.dart';
import 'search_screen.dart';
import 'me_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('StoreX'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MeScreen()),
            ),
          ),
        ],
      ),
      body: FutureBuilder<_HomeData>(
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
            child: ListView(
              children: [
                if (d.slides.isNotEmpty) _Slides(keys: d.slides),
                _CategoryRow(categories: d.categories),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('热门应用',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
                ...d.hotApps.map((a) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: AppCard(
                        app: a,
                        onTap: () => _openApp(context, a.id),
                      ),
                    )),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openApp(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AppDetailScreen(appId: id)),
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

class _Slides extends StatefulWidget {
  final List<Slide> keys;
  const _Slides({required this.keys});

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
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _ctrl,
            itemCount: widget.keys.length,
            onPageChanged: (i) => setState(() => _idx = i),
            itemBuilder: (_, i) {
              final s = widget.keys[i];
              return Container(
                margin: const EdgeInsets.all(12),
                color: Colors.grey.shade100,
                child: s.imageUrl.isNotEmpty
                    ? Image.network(s.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Center(child: Icon(Icons.image, size: 40)))
                    : const Center(child: Icon(Icons.image, size: 40)),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.keys.length,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _idx == i ? 16 : 6,
              height: 6,
              color: _idx == i ? kleinBlue : Colors.grey.shade300,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final List<Category> categories;
  const _CategoryRow({required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = categories[i];
          return ActionChip(
            label: Text(c.name),
            backgroundColor: Colors.grey.shade100,
            labelStyle: const TextStyle(color: inkBlack),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryAppsScreen(category: c),
              ),
            ),
          );
        },
      ),
    );
  }
}
