import 'package:flutter/material.dart';
import '../theme.dart';

/// ============================================================
/// 与 mobile.css 一比一对应的公共组件
/// 每个数值都直接来自 assets/css/mobile.css，勿随意改动
/// ============================================================

/// 千分位
String nfmt(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

/// .app-item .app-meta 下载量：number_format($downloads/10000,1)万
String wanFmt(int downloads) => '${(downloads / 10000).toStringAsFixed(1)}万';

/// 卡片通用阴影 box-shadow:0 1px 3px rgba(0,0,0,.04)
const List<BoxShadow> cardShadow = [
  BoxShadow(color: Color(0x0A000000), blurRadius: 3, offset: Offset(0, 1)),
];

/// box-shadow:0 2px 8px rgba(0,0,0,.04) —— search-bar
const List<BoxShadow> softShadow = [
  BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
];

/// 网络图 + 失败/加载占位（对应 onerror 切 .xxx-ph）
class NetImg extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final double radius;
  final Widget placeholder;
  final BoxFit fit;

  const NetImg({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    required this.radius,
    required this.placeholder,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (_, child, p) => p == null ? child : placeholder,
      ),
    );
  }
}

/// 首字占位块（对应 .app-icon-ph / .app-card-icon-ph / .ar-thumb-ph）
class InitialBox extends StatelessWidget {
  final String text;
  final double size;
  final double radius;
  final double fontSize;
  final Gradient gradient;

  const InitialBox({
    super.key,
    required this.text,
    required this.size,
    required this.radius,
    required this.fontSize,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Text(
        text.isEmpty ? '?' : text.characters.first,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          height: 1.0,
        ),
      ),
    );
  }
}

/// .section-title
/// padding:16px 16px 10px; font-size:16px; font-weight:800
/// .more{font-size:12px;color:var(--t3);font-weight:400}
/// .section-action{font-size:12px;color:var(--pri);font-weight:600;padding:4px 10px}
class SectionTitle extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? iconColor;
  final String? moreText;
  final VoidCallback? onMore;
  final bool actionStyle; // true = .section-action（紫色），false = .more（灰色）
  final EdgeInsets? padding;

  const SectionTitle({
    super.key,
    required this.text,
    this.icon,
    this.iconColor,
    this.moreText,
    this.onMore,
    this.actionStyle = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: iconColor ?? txt),
                const SizedBox(width: 5),
              ],
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: txt,
                  height: 1.2,
                ),
              ),
            ],
          ),
          if (moreText != null)
            GestureDetector(
              onTap: onMore,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: actionStyle
                    ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
                    : EdgeInsets.zero,
                child: Text(
                  moreText!,
                  style: TextStyle(
                    fontSize: 12,
                    color: actionStyle ? pri : t3,
                    fontWeight:
                        actionStyle ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// .loading{padding:40px 0;color:var(--t3);font-size:13px}
class LoadingView extends StatelessWidget {
  final String? text;
  final double padding;
  const LoadingView({super.key, this.text, this.padding = 40});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: t3),
          ),
          if (text != null) ...[
            const SizedBox(width: 8),
            Text(text!, style: const TextStyle(fontSize: 13, color: t3)),
          ],
        ],
      ),
    );
  }
}

/// .empty{padding:60px 20px}  i{font-size:52px;opacity:.35}  p{font-size:13px}
class EmptyView extends StatelessWidget {
  final IconData icon;
  final String text;
  const EmptyView({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        children: [
          Opacity(opacity: 0.35, child: Icon(icon, size: 52, color: t3)),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(fontSize: 13, color: t3)),
        ],
      ),
    );
  }
}

/// .app-item —— 热门排行 / 搜索结果行
/// margin:0 16px 8px; padding:14px 16px; radius14; gap12
/// .app-rank 24x24 13px/800  r1 #EF4444 r2 #F97316 r3 #EAB308
/// .app-icon 46x46 radius12 | .app-name 14/700 | .app-desc 11 t3 | .app-meta 11 pri
class AppListItem extends StatelessWidget {
  final int? rank;
  final String title;
  final String desc;
  final String icon;
  final Widget? metaWidget;
  final int index; // 用于占位图渐变交替
  final Gradient? placeholderGradient; // 覆盖默认交替渐变（如 vip.php 的橙金）
  final VoidCallback? onTap;

  const AppListItem({
    super.key,
    this.rank,
    required this.title,
    required this.desc,
    required this.icon,
    this.metaWidget,
    this.index = 0,
    this.placeholderGradient,
    this.onTap,
  });

  static Color rankColor(int r) {
    if (r == 1) return const Color(0xFFEF4444);
    if (r == 2) return const Color(0xFFF97316);
    if (r == 3) return const Color(0xFFEAB308);
    return t3;
  }

  @override
  Widget build(BuildContext context) {
    // .app-icon-ph 渐变按索引奇偶交替：pri↔#7C3AED
    final grad = placeholderGradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: index.isOdd ? const [pri, purple] : const [purple, pri],
        );
    final ph = InitialBox(
      text: title,
      size: 46,
      radius: 12,
      fontSize: 20,
      gradient: grad,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: cardWhite,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: cardShadow,
            ),
            child: Row(
              children: [
                if (rank != null) ...[
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Center(
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: rankColor(rank!),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                NetImg(
                    url: icon,
                    width: 46,
                    height: 46,
                    radius: 12,
                    placeholder: ph),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: txt,
                        ),
                      ),
                      if (desc.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          desc,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: t3),
                        ),
                      ],
                    ],
                  ),
                ),
                if (metaWidget != null) ...[
                  const SizedBox(width: 12),
                  metaWidget!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// .app-meta —— 11px pri，带图标
class AppMeta extends StatelessWidget {
  final IconData icon;
  final String text;
  const AppMeta({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: pri),
        const SizedBox(width: 3),
        Text(text, style: const TextStyle(fontSize: 11, color: pri)),
      ],
    );
  }
}

/// .article-row —— 首页「站内公告」/ 全部文章列表行
/// .article-list-m{gap:10px;padding:2px 16px 4px}
/// .article-row{gap:10;radius12;padding:9;border:1px solid #EEF0F5}
/// .ar-thumb 86x64 radius8 渐变 #6B7280→#4B5563
/// .ar-top 橙渐变 .62rem/700 | .ar-title .84rem/600 #102B50
/// .ar-summary .74rem t2（截 42 字） | .ar-footer .68rem t3 gap12
class ArticleRow extends StatelessWidget {
  final String title;
  final String thumbnail;
  final String summary;
  final int views;
  final int comments;
  final bool isTop;
  final VoidCallback? onTap;

  const ArticleRow({
    super.key,
    required this.title,
    required this.thumbnail,
    required this.summary,
    required this.views,
    required this.comments,
    required this.isTop,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sum = summary.trim();
    final cut = sum.characters.length > 42
        ? sum.characters.take(42).toString()
        : sum;

    return Material(
      color: cardWhite,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEF0F5)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 3,
                  offset: Offset(0, 1)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // .ar-thumb
              SizedBox(
                width: 86,
                height: 64,
                child: NetImg(
                  url: thumbnail,
                  width: 86,
                  height: 64,
                  radius: 8,
                  placeholder: Container(
                    width: 86,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6B7280), Color(0xFF4B5563)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      title.isEmpty ? '?' : title.characters.first,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // .ar-header
                    Row(
                      children: [
                        if (isTop) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.push_pin,
                                    size: 9, color: Colors.white),
                                SizedBox(width: 3),
                                Text('置顶',
                                    style: TextStyle(
                                        fontSize: 9.92,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.44, // .84rem
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF102B50),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (cut.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        cut,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11.84, color: t2, height: 1.35),
                      ),
                    ],
                    const SizedBox(height: 4),
                    // .ar-footer
                    Row(
                      children: [
                        const Icon(Icons.visibility_outlined,
                            size: 11, color: t3),
                        const SizedBox(width: 3),
                        Text(nfmt(views),
                            style: const TextStyle(fontSize: 10.88, color: t3)),
                        const SizedBox(width: 12),
                        const Icon(Icons.chat_bubble_outline,
                            size: 11, color: t3),
                        const SizedBox(width: 3),
                        Text(nfmt(comments),
                            style: const TextStyle(fontSize: 10.88, color: t3)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// .hot-page-head —— 热门排行 / VIP专属 二级页头卡
/// margin:12px 16px 14px; padding:16; radius18; 渐变 #fff→#fff7ed
/// .hot-page-icon 46x46 radius14 | .hot-page-title 18/800 | .hot-page-sub 12 t3
class HotPageHead extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String sub;

  const HotPageHead({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFFFF7ED)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: txt)),
              const SizedBox(height: 2),
              Text(sub, style: const TextStyle(fontSize: 12, color: t3)),
            ],
          ),
        ],
      ),
    );
  }
}

/// .load-more-wrap + .load-more-btn + .lm-info + .load-more-end
class LoadMore extends StatelessWidget {
  final bool hasMore;
  final bool loading;
  final int page;
  final int totalPages;
  final VoidCallback onTap;
  final String endText;

  const LoadMore({
    super.key,
    required this.hasMore,
    required this.loading,
    required this.page,
    required this.totalPages,
    required this.onTap,
    this.endText = '— 已加载全部 —',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      child: Center(
        child: hasMore
            ? Opacity(
                opacity: loading ? 0.6 : 1,
                child: Material(
                  color: pri,
                  borderRadius: BorderRadius.circular(22),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: loading ? null : onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            loading ? '加载中...' : '加载更多',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                          if (!loading) ...[
                            const SizedBox(width: 4),
                            Opacity(
                              opacity: 0.75,
                              child: Text('($page/$totalPages)',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 11)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(endText,
                    style: const TextStyle(fontSize: 12, color: t3)),
              ),
      ),
    );
  }
}

/// .comment-more —— 文本型「加载更多 / 没有更多了」
class TextMore extends StatelessWidget {
  final bool hasMore;
  final VoidCallback onTap;
  const TextMore({super.key, required this.hasMore, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasMore ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.only(top: 8),
        alignment: Alignment.center,
        child: Text(
          hasMore ? '加载更多' : '没有更多了',
          style: TextStyle(
            fontSize: 13,
            color: hasMore ? pri : t3,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// .pagination + .pg-nav-btn + .pg-info
class Pagination extends StatelessWidget {
  final int page;
  final int totalPages;
  final ValueChanged<int> onChange;

  const Pagination({
    super.key,
    required this.page,
    required this.totalPages,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _btn(
            enabled: page > 1,
            onTap: () => onChange(page - 1),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left, size: 16),
                SizedBox(width: 2),
                Text('上一页',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            child: Text(
              '$page / $totalPages',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: t2, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),
          _btn(
            enabled: page < totalPages,
            onTap: () => onChange(page + 1),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('下一页',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                SizedBox(width: 2),
                Icon(Icons.chevron_right, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _btn(
      {required bool enabled,
      required VoidCallback onTap,
      required Widget child}) {
    return Opacity(
      opacity: enabled ? 1 : 0.3,
      child: Material(
        color: cardWhite,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 3,
                    offset: Offset(0, 1))
              ],
            ),
            child: DefaultTextStyle(
              style: TextStyle(color: enabled ? pri : t2),
              child: IconTheme(
                data: IconThemeData(color: enabled ? pri : t2, size: 16),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
